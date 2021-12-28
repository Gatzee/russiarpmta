loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SDB" )
Extend( "Globals" )

PRIORITY_SERIALS = { }
DEFAULT_SLOTS = 800

USERS_LEVELS_ALLOWED = { }

--[[function UpdateUserLevels( )
    local level = tonumber( fromJSON( MariaGet( "free_server_join" ) ).level )

    DB:queryAsync( function( query )
        local result = query:poll( -1 )

        if isTimer( LEVELS_UPDATE_TIMER ) then return end

        USERS_LEVELS_ALLOWED = { }
        for i, v in pairs( USERS_LEVELS_ALLOWED ) do
            USERS_LEVELS_ALLOWED[ v.client_id ] = tonumber( v.level )
        end

        LEVELS_UPDATE_TIMER = setTimer( UpdateUserLevels, 60 * 1000, 1 )
    end, { }, "SELECT client_id, level FROM nrp_players WHERE level >= ?", level )
end
UpdateUserLevels( )]]

RESERVED_PLAYERS = { }
RESERVED_PLAYERS_COUNT = 0

function onResourceStateChange()
    setMaxPlayers( DEFAULT_SLOTS )
    SET( "reserved_slots", 0 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStateChange )
addEventHandler( "onResourceStop", resourceRoot, onResourceStateChange )

function onPlayerJoin_handler( client_id )
	local serial = source.serial
    local success = true
    local max_players = getMaxPlayers()
    if #getElementsByType( "player" ) >= max_players - getReservedSlots() + RESERVED_PLAYERS_COUNT then
        if not PRIORITY_SERIALS[ serial ] and not USERS_LEVELS_ALLOWED[ client_id ] then
            success = false
            kickPlayer( source, "СЕРВЕР", "Все игровые слоты заняты" )
        end
    end
    if PRIORITY_SERIALS[ serial ] then
        RESERVED_PLAYERS[ source ] = true
        refreshReservedPlayers()
    end
    local text_connection = string.format( "Игрок %s подключается к игре на %s сервер: %s", serial, tostring( SERVER_NUMBER ), tostring( success ) )
    SendToLogserver( text_connection, {
        uid           = serial,
        unixtime      = getRealTime( ).timestamp,
        server_id     = SERVER_NUMBER,
        success       = tostring( success ),
        logtype       = "connect_attempt",
        client_id     = client_id,
        allowed_level = tonumber( USERS_LEVELS_ALLOWED[ client_id ] ) or nil,
    } )
end
addEventHandler( "onPlayerJoin", root, onPlayerJoin_handler )

function onPlayerQuit_handler( )
    RESERVED_PLAYERS[ source ] = nil
    refreshReservedPlayers()
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_handler )

function refreshList( )
    CommonDB:queryAsync( refreshList_Callback, { }, "SELECT * FROM priority_serials.priority_serials WHERE active='Yes'" )
end

function refreshList_Callback( query )
    local result = query:poll( -1 )
    PRIORITY_SERIALS = { }
    local old_reserved_slots = getReservedSlots()
    local slots = 0
    for i, v in pairs( result ) do
        slots = slots + 1
        PRIORITY_SERIALS[ v.serial ] = true
    end
    SET( "reserved_slots", slots )
    local diff = slots - old_reserved_slots
    setMaxPlayers( getMaxPlayers() + diff )
end

function refreshReservedPlayers()
    RESERVED_PLAYERS_COUNT = 0
    for i, v in pairs( RESERVED_PLAYERS ) do
        RESERVED_PLAYERS_COUNT = RESERVED_PLAYERS_COUNT + 1
    end
end

setTimer( refreshList, 5000, 0 )
refreshList( )