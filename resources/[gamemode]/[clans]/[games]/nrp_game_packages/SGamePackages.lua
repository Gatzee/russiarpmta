loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "ShTimelib" )
Extend( "SClans" )

PACKAGE_SEARCH_TIME_LIST = { "06:00", "18:00" }
PACKAGE_SEARCH_WEEKDAYS = EACHDAY

PACKAGE_POSITIONS = LoadXMLIntoVector3Positions( "map/packages_0.map" )

PACKAGES = { }
PACKAGE_SEARCH_AMOUNT = 135  -- В оригинале 25 шт.
PACKAGE_BUSY_POSITIONS = { }

PACKAGE_SEARCH_EXP_REWARD = 100 -- поиск множества коробок на карте
PACKAGE_SEARCH_HONOR_REWARD = 150
PACKAGE_SEARCH_MONEY_REWARD = 3000

addEvent( "onServerPlayerTakeClanPackage", true )
addEventHandler( "onServerPlayerTakeClanPackage", root, function( package_number )
    local clan_id = client:GetClanID()

    if not PACKAGE_BUSY_POSITIONS[ package_number ] or not clan_id then
        return
    end

    SetClanData( clan_id, "packages", ( GetClanData( clan_id, "packages" ) or 0 ) + 1 )
    SetClanData( clan_id, "packages_score", ( GetClanData( clan_id, "packages_score" ) or 0 ) + PACKAGE_SEARCH_HONOR_REWARD )

    client:GiveMoney( PACKAGE_SEARCH_MONEY_REWARD, "band_game_package_reward" )
    client:GiveClanEXP( PACKAGE_SEARCH_EXP_REWARD )
    GiveClanHonor( clan_id, PACKAGE_SEARCH_HONOR_REWARD, "treasure", client, PACKAGE_SEARCH_EXP_REWARD )

    client:ShowInfo( "Ты забрал эту закладку для своего клана! +" .. PACKAGE_SEARCH_EXP_REWARD .. " XP и " .. format_price( PACKAGE_SEARCH_MONEY_REWARD ) .. " р." )

    PACKAGE_BUSY_POSITIONS[ package_number ] = nil
    for k, v in pairs( PACKAGES ) do
        if v[ 1 ] == package_number then
            PACKAGES[ k ] = nil
            break
        end
    end

    triggerClientEvent( GetPlayersInGame(), "onClientDeleteClanPackage", resourceRoot, package_number )

end )

function onPlayerReadyToPlay_handler( )
	triggerClientEvent( source, "onClientCreateClanPackages", resourceRoot, PACKAGES )
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function CreateRandomPackageData()
    local package_number = math.random( 1, #PACKAGE_POSITIONS )
    local i = 0
    while PACKAGE_BUSY_POSITIONS[ package_number ] do
        package_number = math.random( 1, #PACKAGE_POSITIONS )
        i = i + 1
        if i > 2048 then return end
    end
    local package = PACKAGE_POSITIONS[ package_number ]
    table.insert( PACKAGES, { package_number, package.x, package.y, package.z } )
    PACKAGE_BUSY_POSITIONS[ package_number ] = true
end

function CreatePackages()
    -- Удаление старых пакетов
    for i, v in pairs( PACKAGES ) do
        PACKAGE_BUSY_POSITIONS[ i ] = nil
        PACKAGES[ i ] = nil
    end
    PACKAGES = {}
    PACKAGE_BUSY_POSITIONS = {}

    for i = 1, PACKAGE_SEARCH_AMOUNT do
        CreateRandomPackageData( )
    end

    triggerClientEvent( GetPlayersInGame(), "onClientCreateClanPackages", resourceRoot, PACKAGES )
end

function PackageCollection_StartTimed()
    ExecAtWeekdays( PACKAGE_SEARCH_WEEKDAYS, function( self )
        for i, time in pairs( PACKAGE_SEARCH_TIME_LIST ) do
            ExecAtTime( time, CreatePackages )
        end
    end, self )
end
PACKAGECOLLECTION_TIMER = Timer( PackageCollection_StartTimed, MS24H, 0 )
PackageCollection_StartTimed()

-- Сброс счётчиков в новом сезоне
-- function onClansReset_handler( )
--     for i, band in pairs( BANDS_CONF ) do
--         SetClanData( band.id, "packages", 0 )
--     end
-- end
-- addEvent( "onClansReset", true )
-- addEventHandler( "onClansReset", root, onClansReset_handler )

if SERVER_NUMBER > 100 then
    addCommandHandler( "gotopackage", function ( player, cmd, point )
        local package = PACKAGE_POSITIONS[ tonumber( point ) or 1 ]
        if not package then return end

        outputConsole( "your position is: " .. package.x .. ", " .. package.y .. ", " .. package.z .. ", id: " .. point .. "/" .. #PACKAGE_POSITIONS )
        local obj = createObject( 3052, package.x, package.y, package.z )
        obj.collisions = false
        player.position = Vector3( package.x, package.y, package.z )
    end )

    addCommandHandler( "recreatepackages", function( )
        CreatePackages()
    end )

    local testing_packages_counter = 0
    addCommandHandler( "createpackage", function( player, cmd, x, y, z )
        if not x or not y or not z then 
            local pos = player:getPosition()
            x = pos.x + 3
            y = pos.y
            z = pos.z
        end

        local package_number = 9999 + testing_packages_counter

        table.insert( PACKAGES, { package_number, x, y, z } )
        PACKAGE_BUSY_POSITIONS[ package_number ] = true

        testing_packages_counter = testing_packages_counter + 1

        triggerClientEvent( GetPlayersInGame(), "onClientCreateClanPackages", resourceRoot, PACKAGES )

        player:ShowInfo( "Закладка успешно создана" )
    end )
end