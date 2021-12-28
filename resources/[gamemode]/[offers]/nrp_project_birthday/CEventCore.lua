loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "CInterior" )

ibUseRealFonts( true )

QUEST_PED = nil
PED_POSITIONS =
{
    Vector3( -459.94641113281, -992.7041015625, 20.999950408936 ),
    Vector3( -264.59396362305, -535.94097900391, 20.66690826416 ),
    Vector3( -17.421686172485, -431.96514892578, 20.59384727478 ),
    Vector3( 409.97314453125, -433.36895751953, 21.548751831055 ),
    Vector3( 594.53057861328, -781.80358886719, 20.975763320923 ),
    Vector3( 470.47583007813, -1801.5743408203, 20.820911407471 ),
    Vector3( 12.62255859375, -1534.5377197266, 20.827320098877 ),
    Vector3( 281.98602294922, -1106.1115722656, 20.97608757019 ),
    Vector3( 510.3547668457, -1413.2711181641, 20.793287277222 ),
    Vector3( -517.59283447266, -724.01373291016, 7.2849197387695 ),
    Vector3( -1334.5639648438, -773.38110351563, 21.043622970581 ),
    Vector3( -2111.5092773438, -821.20123291016, 19.297620773315 ),
    Vector3( -2063.5498046875, -511.31936645508, 21.121681213379 ),
    Vector3( -1898.376953125, -60.160865783691, 19.027654647827 ),
    Vector3( -2930.2094726563, 230.58975219727, 18.398010253906 ),
    Vector3( -786.64514160156, -1206.6547851563, 2.174017906189 ),
    Vector3( 1017.6293945313, -642.43774414063, 261.13623046875 ),
    Vector3( 1068.2803955078, -1281.7120361328, 210.6309967041 ),
    Vector3( 2273.9963378906, -1505.6149902344, 21.290336608887 ),
    Vector3( 1594.9586181641, -640.75616455078, 29.506576538086 ),
    Vector3( 1613.4686279297, 561.03424072266, 27.190723419189 ),
    Vector3( 1921.3819580078, 569.21057128906, 60.748374938965 ),
    Vector3( 2014.3013916016, 374.11526489258, 60.557422637939 ),
    Vector3( 2234.9562988281, 370.84677124023, 62.420349121094 ),
    Vector3( 1919.9757080078, 58.793418884277, 60.664157867432 ),
    Vector3( 2425.6975097656, -526.62719726563, 73.084678649902 ),
    Vector3( 2410.4094238281, -178.48149108887, 60.700298309326 ),
    Vector3( 2413.6179199219, 102.34873962402, 60.819801330566 ),
    Vector3( 1950.1252441406, -369.17874145508, 60.622253417969 ),
    Vector3( 2071.9931640625, 405.96557617188, 60.740875244141 ),
}

function onClientStartStage_handler( event_data )
    if EVENT[ "stage_" .. event_data.stage ] and IsEventActive() then
        DestroyCurrentData()
        E_DATA = {}

        local event = EVENT[ "stage_" .. event_data.stage ]
        event.client( event_data )
        onChangeClientStage_handler( event_data )
    end
end
addEvent( "onClientStartStage", true )
addEventHandler( "onClientStartStage", resourceRoot, onClientStartStage_handler )

function DestroyCurrentData()
    for k, v in pairs( E_DATA ) do
        if isElement( v ) or type( v ) == "table" then
            v:destroy()
        end
    end
end

function onChangeClientStage_handler( event_data )
    local event = nil
    if event_data then
        event = EVENT[ "stage_" .. event_data.stage or -1 ] or nil
    end
    if event and event.stage_type == "wait" and event_data.time_wait then
        triggerEvent( "ShowCurrentBirthdayStep", localPlayer, true, 
        {
            type        = event.stage_type,
            tittle      = event.tittle,
            time_left   = event_data.time_wait,
            start_text  = event.start_text,
            finish_text = event.finish_text,
        })
    elseif event and event.stage_type == "proc" then
        triggerEvent( "ShowCurrentBirthdayStep", localPlayer, true, 
        {
            type = event.stage_type,
            tittle = event.tittle,
            desc = event.description,
        })
    else
        triggerEvent( "ShowCurrentBirthdayStep", localPlayer, false )
    end
end
addEvent( "onChangeClientStage", true )
addEventHandler( "onChangeClientStage", resourceRoot, onChangeClientStage_handler )

function onClientCreateClientContent_handler()
    if IsEventActive() then
        QUEST_PED = createPed( 299, EVENT_PED_POSITION.x, EVENT_PED_POSITION.y, EVENT_PED_POSITION.z )
        QUEST_PED.frozen = true

        VEHICLE_NEXT =
        {
        	id = 503,
        	position = Vector3( -105.324, -1130.713, 20.446 ),
        	rotation = Vector3( 0, 0, 304 )
        }
        local vehicle = createVehicle( VEHICLE_NEXT.id, VEHICLE_NEXT.position, VEHICLE_NEXT.rotation )
        setVehicleColor( vehicle, 120, 10, 10 )
        addEventHandler( "onClientPedDamage", QUEST_PED, cancelEvent )
    end
end
addEvent( "onClientCreateClientContent", true )
addEventHandler( "onClientCreateClientContent", resourceRoot, onClientCreateClientContent_handler )

function onClientResourceStart_handler()
    EVENT_STARTS = getTimestampFromString( EVENT_STARTS )
    EVENT_ENDS = getTimestampFromString( EVENT_ENDS )
    onClientCreateClientContent_handler()
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )