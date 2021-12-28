Extend( "CPlayer" )
Extend( "CInterior" )

function CreateGameMarker( )
    for k, v in pairs( LOTTERY_MARKERS ) do
        local tpoint = TeleportPoint( { 
            x = v.x, y = v.y, z = v.z, 
            interior = v.interior, dimension = v.dimension, 
            radius = 1.5,
            color = { 255, 50, 0, 20 },
            keypress = "lalt",
            text = "ALT Взаимодействие",
            marker_text = "Лотерея",
            marker_image = "img/marker_icon.png",
        } )

        tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, tpoint.radius * 0.78 } )
        tpoint.PostJoin = function( )
            triggerServerEvent( "onPlayerLotteryPlayStart", resourceRoot )
        end
        tpoint.PostLeave = function( )
            CloseLotteryUI( false )
        end
    end

    -- Вращающийся подиум с супер призом

    local podium_model = 634
	engineReplaceCOL( engineLoadCOL( "files/podium.col" ), podium_model )
    
    local position = Vector3{ x = -68.3, y = -491.241, z = 913.46 }
    local podium = createObject( podium_model, position )
    podium.dimension = 1
    podium.interior = 1

    local vehicle = createVehicle( 526, position )
    vehicle.dimension = 1
    vehicle.interior = 1
    vehicle:setColor( 255, 255, 255 )
    vehicle:attach( podium, 0, 0, 0.77 )

    function onClientPreRender_rotatePodium( )
        local rz = 360 * ( getTickCount( ) % 40000 ) / 40000
        podium:setRotation( 0, 0, rz )
        vehicle:setRotation( 0, 0, rz )
        -- костыль, чтобы скрыть лагающую тень машины
        vehicle.position = position
    end

    addEvent( "onClientPlayerCasinoEnter", true )
    addEventHandler( "onClientPlayerCasinoEnter", localPlayer, function( casino_id )
        if casino_id ~= CASINO_THREE_AXE then return end

        removeEventHandler( "onClientPreRender", root, onClientPreRender_rotatePodium )
        addEventHandler( "onClientPreRender", root, onClientPreRender_rotatePodium )
    end )

    addEvent( "onClientPlayerCasinoExit", true )
    addEventHandler( "onClientPlayerCasinoExit", localPlayer, function( casino_id )
        if casino_id ~= CASINO_THREE_AXE then return end
        
        removeEventHandler( "onClientPreRender", root, onClientPreRender_rotatePodium )
    end )

    local moscow_data = 
    {
        vehicles = {
            {
                id = 526,
                x = 2393.1845, y = -1321.1772, z = 2800.1423, rx = 0, ry = 0, rz = 90,
                dimension = 1,
                interior = 4,
                color = { 0, 0, 0 },
            },
            {
                id = 526,
                x = 2404.6481, y = -1321.1772, z = 2800.1423, rx = 0, ry = 0, rz = 270,
                dimension = 1,
                interior = 4,
                color = { 255, 255, 255 },
            },
        },

        peds = {
            {
                id = 127, 
                x = -92.25, y = -497.72, z = 913.97, rz = 270,
                dimension = 1,
                interior = 1,
            },
            --moscow
            {
                id = 132,
                x = 2388.7792, y = -1308.1495, z = 2800.0783, rz = 225,
                dimension = 1,
                interior = 4,
            },
            {
                id = 135,
                x = 2409.9516, y = -1308.3962, z = 2800.0783, rz = 135,
                dimension = 1,
                interior = 4,
            },
        }
    }

    for k, v in pairs( moscow_data.vehicles ) do
        local veh = createVehicle( v.id, v.x, v.y, v.z, v.rx, v.ry, v.rz )
        veh.dimension = v.dimension
        veh.interior = v.interior
        veh:setColor( unpack( v.color ) )
    end

    for k, v in pairs( moscow_data.peds ) do
        local ped = createPed( v.id, v.x, v.y, v.z, v.rz )
        ped.frozen = true
        ped.dimension = v.dimension
        ped.interior = v.interior
        addEventHandler( "onClientPedDamage", ped, cancelEvent )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, CreateGameMarker )