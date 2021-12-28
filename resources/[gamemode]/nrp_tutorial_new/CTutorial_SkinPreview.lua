local UI

local ELEMENTS_BY_MODEL = { }
local ELEMENTS_BY_ID = { }

local _createPed = createPed
function createPed( ... )
    local ped = _createPed( ... )
    if ped then setElementDimension( ped, localPlayer.dimension ) end
    return ped
end

local _createVehicle = createVehicle
function createVehicle( ... )
    local vehicle = _createVehicle( ... )
    if vehicle then setElementDimension( vehicle, localPlayer.dimension ) end
    return vehicle
end

local SKIN_CONFIG = {
    -- Мент и арестант
    [ 117 ] = {
        camera = { 2253.9904785156, -591.23260498047+860, 60.879291534424, 2280.8654785156, -687.37368774414+860, 54.995147705078 },
        target_time = { 20, 0 },
        on_create = function( self, ped )
            local policeman = ELEMENTS_BY_ID[ "ped (1)" ]
            givePedWeapon( policeman, 23, 1, true )
        end,
        on_show = function( self, ped )
            local policeman = ELEMENTS_BY_ID[ "ped (1)" ]

            policeman:setAnimation( )
            ped:setAnimation( )

            table.insert( self.temp_visible_elements, setTimer( function( )
                policeman:setAnimation( "ped", "arrestgun", -1, false, true, true, true, 500, false )
                --[[table.insert( self.temp_visible_elements, setTimer( function( )
                    ped:setAnimation( "ped", "handsup", -1, false, true, true, true, 250, false )
                end, 500, 1 ) )]]
            end, 3000, 1 ) )
            
        end,
        on_hide = function( self, ped )
            local policeman = ELEMENTS_BY_ID[ "ped (1)" ]
            self.temp_visible_elements.timer = setTimer( function( )
                policeman:setAnimation( )
                ped:setAnimation( )
            end, 500, 1 )
        end,
    },
    -- Девушка у такси
    [ 145 ] = {
        camera = { 2213.34765625, -557.28979492187+860, 61.125259399414, 2121.3344726563, -518.95098876953+860, 53.144523620605 },
        target_time = { 21, 50 },
        on_show = function( self, ped )
            ped:setAnimation( "ped", "gumeat", -1, false, true, true, true, 250, false )
        end,
        on_hide = function( self, ped )

        end,
    },
    -- Девушка на свидании
    [ 139 ] = {
        camera = { 2340.7512207031, -611.38600158691+860, 61.860546112061, 2440.5988769531, -609.29156494141+860, 56.754955291748 },
        target_time = { 0, 0 },
        on_create = function( self, ped )
            givePedWeapon( ped, 14, 10, false )
        end,
        on_show = function( self, ped )
            local man = ELEMENTS_BY_ID[ "ped (5)" ]
            setPedWeaponSlot( ped, 0 )
            setPedWeaponSlot( man, 0 )

            table.insert( self.temp_visible_elements, setTimer( function( )
                man:setAnimation( "kissing", "gift_give", -1, false, true, true, true, 500, false )
                table.insert( self.temp_visible_elements, setTimer( function( )
                    setPedWeaponSlot( man, 10 )
                    ped:setAnimation( "kissing", "gift_get", -1, false, true, true, true, 250, false )
                    table.insert( self.temp_visible_elements, setTimer( function( )
                        ped.weaponSlot = 10
                        man.weaponSlot = 0
                    end, 4000, 1 ) )
                end, 500, 1 ) )
            end, 2000, 1 ) )
        end,
        on_hide = function( self, ped )

        end,
    },
    -- Парень на свидании с букетом
    [ 120 ] = {
        camera = { 2342.1828613281, -608.79487609863+860, 61.874214172363, 2357.6613769531, -707.27998352051+860, 54.057682037354 },
        target_time = { 0, 0 },
        on_create = function( self, ped )
            givePedWeapon( ped, 14, 10, true )
        end,
        on_show = function( self, ped )
            local girl = ELEMENTS_BY_ID[ "ped (6)" ]
            setPedWeaponSlot( girl, 0 )
            setPedWeaponSlot( ped, 0 )

            table.insert( self.temp_visible_elements, setTimer( function( )
                ped:setAnimation( "kissing", "gift_give", -1, false, true, true, true, 500, false )
                table.insert( self.temp_visible_elements, setTimer( function( )
                    setPedWeaponSlot( ped, 10 )
                    girl:setAnimation( "kissing", "gift_get", -1, false, true, true, true, 250, false )
                    table.insert( self.temp_visible_elements, setTimer( function( )
                        girl.weaponSlot = 10
                        ped.weaponSlot = 0
                    end, 4000, 1 ) )
                end, 500, 1 ) )
            end, 2000, 1 ) )
        end,
        on_hide = function( self, ped )

        end,
    },
    [ 141 ] = {
        camera = { 2214.8654785156, -570.21035766602+860, 61.08736038208, 2117.1535644531, -587.66845703125+860, 48.937450408936, 0, 70 },
        target_time = { 6, 30 },
        on_show = function( self, ped )
            table.insert( self.temp_visible_elements, createLight(0, ped.position.x, ped.position.y, ped.position.z + 3, 5, 255, 200, 100 ) )
        end,
        on_hide = function( self, ped )

        end,
    },
    [ 118 ] = {
        camera = { 2301.1557617188, -570.51358032227+860, 62.805980682373, 2393.9904785156, -555.11657714844+860, 28.973331451416, 0, 70 },
        target_time = { 6, 0 },
        on_create = function( self, ped )
            --local vehicle = ELEMENTS_BY_ID[ "vehicle (Elegant) (2)" ]
            --warpPedIntoVehicle( ped, vehicle )
        end,
        on_show = function( self, ped )
            if not getPedOccupiedVehicle( ped ) then return end
            --local vehicle = ELEMENTS_BY_ID[ "vehicle (Elegant) (2)" ]
            --[[table.insert( self.temp_visible_elements, setTimer( function( )
                setPedControlState( ped, "enter_exit", true )
                table.insert( self.temp_visible_elements, setTimer( function( )
                    setPedControlState( ped, "enter_exit", false )
                end, 1000, 1 ) )
            end, 3000, 1 ) )]]
        end,
        on_hide = function( self, ped )
            if getPedOccupiedVehicle( ped ) then return end
            --local vehicle = ELEMENTS_BY_ID[ "vehicle (Elegant) (2)" ]
            --[[table.insert( self.temp_visible_elements, setTimer( function( )
                setPedControlState( ped, "enter_exit", true )
                table.insert( self.temp_visible_elements, setTimer( function( )
                    setPedControlState( ped, "enter_exit", false )
                end, 500, 1 ) )
            end, 3000, 1 ) )]]
        end,
    }
}

local MAP_ELEMENT_CONSTRUCTORS = {
    vehicle = function( attrs )
        local vehicle = createVehicle( attrs.model, attrs.posX, attrs.posY, attrs.posZ, attrs.rotX, attrs.rotY, attrs.rotZ )
        if attrs.color then
            addEventHandler( "onClientElementStreamIn", vehicle, function( )
                setVehicleColor( vehicle, unpack( split( attrs.color, "," ) ) )
            end )
        end
        vehicle.frozen = true
        return vehicle
    end,

    ped = function( attrs )
        local ped = createPed( attrs.model, attrs.posX, attrs.posY, attrs.posZ, attrs.rotZ )
        ped.frozen = true

        return ped
    end
}

function StartSkinPreview( )
    StopSkinPreview( )

    UI = { }

    setWeather( 0 )

    setCameraMatrix( 2168.5163574219, -499.57769775391+860, 65.331436157227, 2266.2082519531, -486.97760009766+860, 82.580932617188, 0, 70 )

    LoadPreviewMap( )
end

function StopSkinPreview( )
    iprint( getTickCount( ), "STOP skin preview" )
    removeEventHandler( "onClientPreRender", root, RenderTimeCycle )

    if UI and UI.current_preview and SKIN_CONFIG[ UI.current_preview ] then
        DestroyTableElements( SKIN_CONFIG[ UI.current_preview ].temp_visible_elements )
    end

    DestroyPreviewMap( )
    DestroyTableElements( UI )
    UI = nil
end

function LoadPreviewMap( )
    UI.map_elements = { }
    UI.map_elements_list = { }

    local xml = xmlLoadFile( "map/scenes.map" )
    for i, v in pairs( xmlNodeGetChildren( xml ) ) do
        local attrs = xmlNodeGetAttributes( v )
        local ntype = xmlNodeGetName( v )

        if MAP_ELEMENT_CONSTRUCTORS[ ntype ] then
            local element = MAP_ELEMENT_CONSTRUCTORS[ ntype ]( attrs )
            if element then
                UI.map_elements[ attrs.id ] = element
                table.insert( UI.map_elements_list, element )

                ELEMENTS_BY_MODEL[ tonumber( attrs.model ) ] = element
                ELEMENTS_BY_ID[ attrs.id ] = element
            end
        end
    end

    for i, v in pairs( SKIN_CONFIG ) do
        if v.on_create then
            v:on_create( ELEMENTS_BY_MODEL[ i ] )
        end
    end

    xmlUnloadFile( xml )
end

function DestroyPreviewMap( )
    DestroyTableElements( UI and UI.map_elements_list )
end

function RenderTimeCycle( )
    local progress = ( getTickCount( ) - UI.timestamp_tick ) / 2500
    if progress >= 1 then
        progress = 1 
        removeEventHandler( "onClientPreRender", root, RenderTimeCycle )
    end

    local time = getRealTime( interpolateBetween( UI.timestamp, 0, 0, UI.timestamp_target, 0, 0, progress, "InOutQuad" ) )
    setTime( time.hour, time.minute )
end

function SwitchSkinPreview( skin )
    local conf = SKIN_CONFIG[ skin ]
    if not conf then return end
    if not conf.camera then return end

    local cx, cy, cz, cx1, cy1, cz1 = getCameraMatrix( )

    if UI and UI.current_preview then
        DestroyTableElements( SKIN_CONFIG[ UI.current_preview ].temp_visible_elements )
        if SKIN_CONFIG[ UI.current_preview ].on_hide then
            SKIN_CONFIG[ UI.current_preview ]:on_hide( ELEMENTS_BY_MODEL[ UI.current_preview ] )
        end
    end

    SmoothMoveCamera(
        3000,
        cx, cy, cz,
        cx1, cy1, cz1,
        unpack( conf.camera )
    )

    if SKIN_CONFIG[ skin ].target_time then

        local hour, minute = getTime( )
        UI.timestamp = getRealTime( os.time( { day = 1, month = 1, year = 2019, hour = hour, minute = minute } ) ).timestamp
        UI.timestamp_target = os.time( { day = 1, month = 1, year = 2019, hour = SKIN_CONFIG[ skin ].target_time[ 1 ], minute = SKIN_CONFIG[ skin ].target_time[ 2 ] } )
        UI.timestamp_tick = getTickCount( )
        
        while UI.timestamp_target < UI.timestamp do
            UI.timestamp_target = UI.timestamp_target + 24 * 60 * 60
        end

        removeEventHandler( "onClientPreRender", root, RenderTimeCycle )
        addEventHandler( "onClientPreRender", root, RenderTimeCycle )
        iprint( getTickCount( ), "Add skin preview" )
    end

    UI.current_preview = skin

    if SKIN_CONFIG[ skin ].on_show then
        DestroyTableElements( SKIN_CONFIG[ skin ].temp_visible_elements )
        iprint( getTickCount( ), "Start new", type( skin ), ELEMENTS_BY_MODEL, skin, ELEMENTS_BY_MODEL[ skin ] )
        SKIN_CONFIG[ skin ].temp_visible_elements = { }
        SKIN_CONFIG[ skin ]:on_show( ELEMENTS_BY_MODEL[ skin ] )
    end
end

local sm = { }

local function camRender()
	if sm.active then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientPreRender",root,camRender)
	end
end

local function stopSmoothMoveCamera( )
    removeEventHandler( "onClientPreRender", root, camRender )
    DestroyTableElements( sm )
    sm.active = nil
end

function SmoothMoveCamera( time, x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t )
    if sm.active then stopSmoothMoveCamera( ) end

	sm.object1 = createObject( 1337, x1, y1, z1 )
    sm.object2 = createObject( 1337, x1t, y1t, z1t )
    
	setElementAlpha( sm.object1,0 )
    setElementAlpha( sm.object2,0 )
    
	setObjectScale( sm.object1, 0.01 )
    setObjectScale( sm.object2, 0.01 )
    
	moveObject( sm.object1, time, x2, y2, z2, 0, 0, 0, "InOutQuad" )
    moveObject( sm.object2, time, x2t, y2t, z2t, 0, 0, 0, "InOutQuad" )
    
    sm.active = true
    
	table.insert( sm, setTimer( stopSmoothMoveCamera, time, 1 ) )
    addEventHandler( "onClientPreRender", root, camRender )
    
	return true
end