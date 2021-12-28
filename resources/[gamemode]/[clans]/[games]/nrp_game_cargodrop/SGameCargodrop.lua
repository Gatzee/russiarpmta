loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "ShTimelib" )
Extend( "SClans" )

DROPS_START_TIME_LIST = { "12:00", "16:00", "20:00", "00:00" }
DROPS_WEEKDAYS = EACHDAY
DROPS_MODEL = 2977
DROPS_EXP_REWARD = 300
DROPS_HONOR_REWARD = 500
DROPS_MONEY_REWARD = 10000

DROPS_LIFE_DURATION = 2 * 60 * 60 * 1000

DROPS_POSITIONS = {
    { x = 2594.1201, y = -2517.42 + 860, z = 10.75 },
    { x = 2722.71, y = -2111.24 + 860, z = 0.09 },
    { x = 2781.1899, y = -1664.32001 + 860, z = 73.3 },
    { x = 2747.79, y = -1089.89999 + 860, z = 128.59 },
    { x = 2159.3501, y = -63.07001 + 860, z = 105.85 },
    { x = 1022.83, y = -1220.70999 + 860, z = 18.01 },
    { x = 1427.7803, y = -325.78027 + 860, z = 30.55 },
    { x = -1736.22, y = -710.53999 + 860, z = 11.52 },
    { x = 443.42969, y = -1055.87012 + 860, z = 6.8 },
    { x = -1357.7002, y = -828.12012 + 860, z = 12.63 },
    { x = -2088.95, y = -203.19 + 860, z = 19.22 },
    { x = -2791.78, y = 244.12 + 860, z = 14.25 },
    { x = -1653, y = 495.52 + 860, z = 20.69 },
    { x = -1958.6895, y = 760.6797 + 860, z = 16.27 },
    { x = -1364.91, y = 335.9 + 860, z = 18.01 },
    { x = -1260.59, y = -289.34998 + 860, z = 25.03 },
    { x = -1786.67, y = -1087.94 + 860, z = 17.78 },
    { x = -1747.83, y = 33.34003 + 860, z = 74.32 },

    { x = 899.6,    y = 954.92 + 860,   z = 20.99  },
    { x = 2212.66,  y = 1371.88 + 860,  z = 21.89  },
    { x = 1777.78,  y = -209.57 + 860,  z = 65.98  },
    { x = 2492.62,  y = -426.74 + 860,  z = 103.71 },
    { x = 2596.56,  y = -1909.3 + 860,  z = 108.93 },
    { x = 2456.01,  y = -1257.61 + 860, z = 106.17 },
    { x = 1067.62,  y = -2179.02 + 860, z = 209.81 },
    { x = 1039.37,  y = -1479.6 + 860,  z = 259.98 },
    { x = -536.63,  y = 733.5 + 860,    z = 28.34  },
    { x = -1344.11, y = 963.91 + 860,   z = 25.89  },
    { x = 395.48,   y = -346.32 + 860,  z = 36.42  },
}

for k,v in pairs(DROPS_POSITIONS) do
    v.z = v.z - 0.1
end

DROPS = { }
DROPS_REVERSE = { }

function CreateRandomDrop()
    local drop_number = math.random( 1, #DROPS_POSITIONS )
    local drop = DROPS_POSITIONS[ drop_number ]
    return CreateDrop( drop, drop_number )
end

function CreateDrop( drop, drop_number )
    drop = table.copy( drop )

    local object = Object( DROPS_MODEL, drop.x, drop.y, drop.z, drop.rx or 0, drop.ry or 0, drop.rz or 0 )

    drop.elements = { }
    drop.elements.object = object
    drop.elements.corona = corona
    drop.elements.timer = Timer( function( )
        drop:destroy( )
    end, DROPS_LIFE_DURATION, 1 )

    setElementFrozen( drop.elements.object, true )
    drop.elements.blip = Blip( drop.x, drop.y, drop.z, 39, 4, 255, 255, 255, 255, 1, 9999999 )
    drop.elements.blip.size = 8

    -- if not drop.noarea then
    --     drop.elements.radar_area = RadarArea( drop.x, drop.y, 100, 100 )
    --     drop.elements.radar_area.flashing = true
    --     drop.elements.radar_area:setColor( 255, 255, 0, 50 )
    -- end

    drop.color = { 0, 0, 0, 0 }
    drop.z = drop.z + 1
    drop.keypress = false
    drop.radius = 2.5
    drop.drop_number = drop_number
    drop.PreJoin = function( self, player )
        if not player:IsInClan() then 
            player:ShowError( "Порядочные граждане не трогают закладки" )
            return
        end
        return true
    end
    drop.PostJoin = function( self, player )
        local clan_id = player:GetClanID()

        if self.drop_number then
            DROPS_REVERSE[ self.drop_number ] = nil
        end

        self:destroy()

        GiveClanHonor( clan_id, DROPS_HONOR_REWARD, "box_drop", player, DROPS_EXP_REWARD )
        AlertAllClans( "Груз забран членом клана " .. GetClanName( clan_id ) .. "! +" .. DROPS_HONOR_REWARD .. " очков чести", "info" )

        SetClanData( clan_id, "cargodrops", ( GetClanData( clan_id, "cargodrops" ) or 0 ) + 1 )
        SetClanData( clan_id, "cargodrops_score", ( GetClanData( clan_id, "cargodrops_score" ) or 0 ) + DROPS_HONOR_REWARD )

        player:GiveClanEXP( DROPS_EXP_REWARD )
        player:GiveMoney( DROPS_MONEY_REWARD, "band_game_cargodrop_reward" )
        player:ShowSuccess( "Ты нашел груз и получил +" .. DROPS_EXP_REWARD .. " XP и " .. format_price( DROPS_MONEY_REWARD ) .. " р.!")
    end
    
    local tpoint = TeleportPoint( drop )
    table.insert( DROPS, tpoint )

    if drop_number then
        DROPS_REVERSE[ drop_number ] = tpoint
    end
end
addEvent( "CreateDrop", true )
addEventHandler( "CreateDrop", root, CreateDrop )

function CargoDrop_StartTimed()
    for i, time in pairs( DROPS_START_TIME_LIST ) do
        -- ExecAtTime( time, function( )
        --     AlertAllClans( "Груз забран членом клана " .. GetClanName( clan_id ) .. "! +" .. DROPS_HONOR_REWARD .. " очков чести", "info" )
        -- end )
        ExecAtTime( time, function( )
            -- Удаление старых пакетов
            for i, v in pairs( DROPS ) do
                DROPS_REVERSE[ i ] = nil
                if v and v.destroy then
                    v:destroy()
                end
            end

            -- Создание новых
            Async:foreach( getElementsByType( "player" ), function( v )
                if isElement( v ) and v:IsInClan() then
                    v:ShowNotification( "На карте отмечена территория сброса очень важного груза! Захвати пока это не сделал другой клан!" )
                end
            end )
            CreateRandomDrop( )
        end )
    end
end
CARGODROP_TIMER = Timer( CargoDrop_StartTimed, MS24H, 0 )
CargoDrop_StartTimed()

-- Сброс счётчиков в новом сезоне
-- function onClansReset_handler( )
--     for i, band in pairs( BANDS_CONF ) do
--         SetClanData( band.id, "cargodrops", 0 )
--     end
-- end
-- addEvent( "onClansReset", true )
-- addEventHandler( "onClansReset", root, onClansReset_handler )

-- local function everyDayZeroing()
--     for i, band in pairs( BANDS_CONF ) do
--         SetClanData( band.id, "holdarea_wins", 0 )
--         SetClanData( band.id, "drops", 0 )
--         SetClanData( band.id, "cargodrops", 0 )
--     end

--     setTimer( function() 
--             ExecAtTime( "00:00", everyDayZeroing )
--     end, 300 * 1000, 1 )
-- end
-- ExecAtTime( "00:00", everyDayZeroing )





if SERVER_NUMBER > 100 then
    addCommandHandler( "createcargodrop", function( player, cmd, drop_number )
        drop_number = tonumber( drop_number )
        if not drop_number then return end

        CreateDrop( DROPS_POSITIONS[ drop_number ], drop_number )
        print"createcargodrop"
    end )

    addCommandHandler( "createrandomcargodrop", function( )
        CreateRandomDrop()
        print"createrandomcargodrop"
    end )

    local testing_packages_counter = 0
    addCommandHandler( "createdrop", function( player, cmd, x, y, z )
        local pos = player:getPosition()
        local drop = { x = x or pos.x, y = y or pos.y, z = z or pos.z }

        local package_number = 9999 + testing_packages_counter

        testing_packages_counter = testing_packages_counter + 1

        CreateDrop( drop, package_number )

        player:ShowInfo( "Груз успешно создан" )
    end )
end