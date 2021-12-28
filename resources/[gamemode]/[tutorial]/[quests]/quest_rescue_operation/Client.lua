loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CUI" )
Extend( "CActionTasksUtils" )
Extend ("CQuest" )
Extend( "CAI" )

addEventHandler("onClientResourceStart", resourceRoot, function( )
    CQuest( QUEST_DATA )
end )

--[[
local objects = {
    { model = 2973, position = Vector3( { x = -2413, y = 1695, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 296 } ) },
    { model = 2973, position = Vector3( { x = -2412, y = 1721.4, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 296 } ) },
    { model = 2973, position = Vector3( { x = -2417.3, y = 1715.3, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 295.999 } ) },
    { model = 2973, position = Vector3( { x = -2409.4, y = 1712.7, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 295.999 } ) },
    { model = 2973, position = Vector3( { x = -2412.4, y = 1704.7, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 295.999 } ) },
    { model = 2991, position = Vector3( { x = -2407.6001, y = 1691.4, z = 13.7 } ), rotation = Vector3( { x = 0, y = 0, z = 26 } ) },
    { model = 1299, position = Vector3( { x = -2405.8, y = 1703.5, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 226 } ) },
    { model = 1217, position = Vector3( { x = -2401.3999, y = 1688.1, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1217, position = Vector3( { x = -2398.5, y = 1685.8, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1217, position = Vector3( { x = -2398.8999, y = 1689, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1218, position = Vector3( { x = -2400.7, y = 1686.4, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1218, position = Vector3( { x = -2399.1001, y = 1687, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1218, position = Vector3( { x = -2397.5, y = 1686.7, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1218, position = Vector3( { x = -2396.8999, y = 1685, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1217, position = Vector3( { x = -2397.3, y = 1688.7, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1217, position = Vector3( { x = -2401.3, y = 1689.9, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1217, position = Vector3( { x = -2399.7, y = 1684.8, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
    { model = 1218, position = Vector3( { x = -2398.5, y = 1684.1, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
}

for idx, obj in pairs( objects ) do
    object = createObject( obj.model, obj.position )
    object.rotation = obj.rotation
    object.dimension = localPlayer.dimension
end

local fsin_cars = {
    { model = 579, position = Vector3( -2440.89, 1736.41, 14 ), rotation = 230 },
    { model = 579, position = Vector3( -2436.04, 1690.90, 14 ), rotation = 250 },
    { model = 579, position = Vector3( -2423.32, 1672.14, 14 ), rotation = 280 },
}

for _, data in pairs( fsin_cars ) do
    local fsin_car = createVehicle( data.model, data.position, Vector3( 0, 0, data.rotation ) )
    fsin_car.paintjob = 0
    fsin_car:setColor( 255, 255, 255 )
end


local respwans_pos = {
    Vector3( -2439.508, 1738.622, 14.080 ),
    Vector3( -2435.588, 1693.283, 14.080 ),
    Vector3( -2423.266, 1675.122, 14.080 ),
}

fsin_bots = {
    Vector3( -2439.508, 1738.622, 14.080 ),
    Vector3( -2435.588, 1693.283, 14.080 ),
    Vector3( -2423.266, 1675.122, 14.080 ),
}


local function loadBot( idx, pos_id )
    ped = CreateAIPed( 201, pos_id and respwans_pos[ pos_id ] or fsin_bots[ idx ] )
    ped.dimension = localPlayer.dimension
    
    setPedStat( ped, 77, 300 )
    givePedWeapon( ped, 30, 999999, true )

    addEventHandler( "onClientPedWasted", ped, function ( )
        ped_tmr = setTimer( function ( source )
            if isElement( source ) then
                source:destroy( )
                loadBot( idx, math.random( #respwans_pos ) )
            end
        end, 5000, 1, source )
    end )
end

for idx, _ in pairs( fsin_bots ) do
    loadBot( idx )
end
--]]
