loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("ShApartments")
Extend("ShVipHouses")
Extend("SPlayer")

HOUSES_SLEEPING_PLAYERS = {}
SLEEPING_PLAYERS_HOUSES = {}

function SetPlayerSleepOnBed( player, id, number, bed_id, force_anim )
    local class_id = id > 0 and APARTMENTS_LIST[ id ].class or VIP_HOUSES_LIST[ number ].apartments_class or 0
	local house_data = class_id > 0 and APARTMENTS_CLASSES[ class_id ] or VIP_HOUSES_LIST[ number ]
    if not HOUSES_SLEEPING_PLAYERS[ id ] then
        HOUSES_SLEEPING_PLAYERS[ id ] = {}
	end
	if not HOUSES_SLEEPING_PLAYERS[ id ][ number ] then
		HOUSES_SLEEPING_PLAYERS[ id ][ number ] = { }
	end
    HOUSES_SLEEPING_PLAYERS[ id ][ number ][ bed_id ] = player
	SLEEPING_PLAYERS_HOUSES[ player ] = { id, number, bed_id }
	
	
    player:SetPrivateData( "is_sleeping", true )
	player:SetPermanentData( "sleep_timestamp", getRealTime( ).timestamp )
	player:SetPermanentData( "sleep_bed_id", bed_id )

	bed_position = house_data.bed_position[ bed_id or 1 ]

	player.position = Vector3( bed_position )
    player.rotation = Vector3( 0, 0, bed_position.r - 90 )
    player.velocity = Vector3( )

    local pPlayersAround = {}
    local interior, dimension = player.interior, player.dimension
    for k, v in pairs( getElementsWithinRange( player.position, 50, "player" ) ) do
        if v.interior == interior and v.dimension == dimension then
            table.insert( pPlayersAround, v )
        end
    end
    triggerClientEvent( pPlayersAround, "OnClientPlayerSleepOnBed", resourceRoot, player, true, force_anim )
end

function PlayerWantSleepOnBed_handler( id, number, bed_id )
    if not client then return end
    if client:getData( "in_clan_event_lobby" ) then return end

	id = tonumber( id )
	number = tonumber( number )

    if not client:HasAccessToHouse( id, number ) then
        client:ShowInfo( "Ты не можешь спать в чужой кровати" )
        return
	end
	--Да простит меня господь(Артём) за такую проверку
	--btw если просто чекать HOUSES_SLEEPING_PLAYERS[ id ][ number ][ bed_id ], то может ебашить ерроры
	if HOUSES_SLEEPING_PLAYERS[ id ] and HOUSES_SLEEPING_PLAYERS[ id ][ number ] and HOUSES_SLEEPING_PLAYERS[ id ][ number ][ bed_id ] then 
		client:ShowInfo( "Вам лучше не ложится друг на друга" )
		return
	end
	SetPlayerSleepOnBed( client, id, number, bed_id )
end
addEvent( "PlayerWantSleepOnBed", true )
addEventHandler( "PlayerWantSleepOnBed", root, PlayerWantSleepOnBed_handler )

function onPlayerSuccessTryToSleepAtForeignBed_handler( id, number )
    SetPlayerSleepOnBed( source, id, number )
end
addEvent( "onPlayerSuccessTryToSleepAtForeignBed", true )
addEventHandler( "onPlayerSuccessTryToSleepAtForeignBed", root, onPlayerSuccessTryToSleepAtForeignBed_handler )

function PlayerWantLeaveBed_handler( )
    if not client then return end

    local id, number, bed_id = unpack( SLEEPING_PLAYERS_HOUSES[ client ] )
    SLEEPING_PLAYERS_HOUSES[ client ] = nil
    if HOUSES_SLEEPING_PLAYERS[ id ] then
        HOUSES_SLEEPING_PLAYERS[ id ][ number ][ bed_id ] = nil
    end

	client:SetPrivateData( "is_sleeping", false )
    client:SetPermanentData( "sleep_timestamp", nil )
    client:SetPermanentData( "sleep_bed_id", nil )

    local pPlayersAround = {}
    local interior, dimension = client.interior, client.dimension
    for k, v in pairs( getElementsWithinRange( client.position, 50, "player" ) ) do
        if v.interior == interior and v.dimension == dimension then
            table.insert( pPlayersAround, v )
        end
    end
	triggerClientEvent( pPlayersAround, "OnClientPlayerSleepOnBed", resourceRoot, client, false )
end
addEvent( "PlayerWantLeaveBed", true )
addEventHandler( "PlayerWantLeaveBed", root, PlayerWantLeaveBed_handler )

addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, function( )
    if SLEEPING_PLAYERS_HOUSES[ source ] then
        local id, number, bed_id = unpack( SLEEPING_PLAYERS_HOUSES[ source ] )
        SLEEPING_PLAYERS_HOUSES[ source ] = nil
        if HOUSES_SLEEPING_PLAYERS[ id ] then
            HOUSES_SLEEPING_PLAYERS[ id ][ number ][ bed_id ] = nil
        end
	end
end )

addEvent( "onPlayerSleepHealing", true )
addEventHandler( "onPlayerSleepHealing", resourceRoot, function( )
    if not client or not client:getData( "is_sleeping" ) then return end

	client:SetPermanentData( "sleep_timestamp", getRealTime( ).timestamp )
end )

function onPlayerEnterHouse_handler( id, number )
    if not HOUSES_SLEEPING_PLAYERS[ id ] then return end    
	local sleeping_players = HOUSES_SLEEPING_PLAYERS[ id ][ number ]
	for bed_id, player in pairs( sleeping_players or { } ) do 
		if player and isElement( player ) and sleeping_player ~= source then
			triggerClientEvent( source, "OnClientPlayerSleepOnBed", resourceRoot, player, true, true )
		end
	end
end
addEvent( "onPlayerEnterApartments" )
addEventHandler( "onPlayerEnterApartments", root, onPlayerEnterHouse_handler )
addEvent( "onPlayerEnterViphouse", true )
addEventHandler( "onPlayerEnterViphouse", root, onPlayerEnterHouse_handler )

function CheckPlayerSleepOnLogin( player )
    player = player or source

    local sleep_timestamp = player:GetPermanentData( "sleep_timestamp" )
    if not sleep_timestamp then return end

    local id, number = player:GetHouseIsInside( )
    if not id then
        local last_visited_viphouse = player:GetPermanentData( "last_visited_viphouse" )
        if last_visited_viphouse then
            local viphouse = VIP_HOUSES_LIST[ last_visited_viphouse.id ]
            if viphouse and viphouse.class == "Вилла" and Vector3( viphouse.spawn_position ):distance( player.position ) <= 25 then
                id, number = 0, last_visited_viphouse.id
            end
        end
    end

    if not id or not player:HasAccessToHouse( id, number ) then 
        player:SetPrivateData( "is_sleeping", false )
        player:SetPermanentData( "sleep_timestamp", nil )
        player:SetPermanentData( "sleep_bed_id", nil )
        return
    end
    if player.health < 100 then
        local hp = SLEEP_HP_PER_MS * ( getRealTime( ).timestamp - sleep_timestamp ) * 1000
        player:SetHP( player.health + hp )
	end
	local sleep_bed_id = player:GetPermanentData( "sleep_bed_id" )
    SetPlayerSleepOnBed( player, id, number, sleep_bed_id, true )
end
addEventHandler( "onPlayerReadyToPlay", root, CheckPlayerSleepOnLogin )

addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function ( )
        for _, player in ipairs( getElementsByType( "player" ) ) do
            if player:IsInGame() then			
                CheckPlayerSleepOnLogin( player )
            end
        end
    end, 2000, 1 )
end )