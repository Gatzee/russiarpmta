loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "CActionTasksUtils" )
Extend( "ib" )
Extend( "CQuest" )

function onClientPlayerGiftStart_handler( id, data )
    local gift = GIFTS[ id ]
    if not gift then return end

    gift.onstart.client( gift, data )
end
addEvent( "onClientPlayerGiftStart", true )
addEventHandler( "onClientPlayerGiftStart", root, onClientPlayerGiftStart_handler )

function onClientPlayerGiftFinishWait_handler( id, data )
    local gift = GIFTS[ id ]
    if not gift then return end

    gift.ontimer.client( gift, data )
end
addEvent( "onClientPlayerGiftFinishWait", true )
addEventHandler( "onClientPlayerGiftFinishWait", root, onClientPlayerGiftFinishWait_handler )

function onClientPlayerGiftGiven_handler( id, data )
    local gift = GIFTS[ id ]
    if not gift then return end

    gift.ondone.client( gift, data )
end
addEvent( "onClientPlayerGiftGiven", true )
addEventHandler( "onClientPlayerGiftGiven", root, onClientPlayerGiftGiven_handler )

function GivePlayerGift( id )
    triggerServerEvent( "GivePlayerGift", resourceRoot, _, id )
end

function CreatePoint( position, callback_func, name, radius, interior, dimension, check_func, keypress, keytext, marker_type, r, g, b, a )
	name = name or "marker"

	local tpoint = TeleportPoint( 
		{ 
			x = position.x, y = position.y, z = position.z, 
			radius = radius or 4, gps = true, ignore_gps_route = true, quest_state = true,
			keypress = keypress or false, text = keytext or false, 
			interior = interior or localPlayer.interior, 
			dimension = dimension or localPlayer.dimension 
		}
	)
	tpoint.accepted_elements = { player = true }
	tpoint.marker.markerType = marker_type or "checkpoint"
	tpoint.marker:setColor( r or 250, g or 100, b or 100, a or 150 )
	tpoint.elements = { }
	tpoint.elements.blip = createBlipAttachedTo( tpoint.marker, 41, 5, 250, 100, 100 )
	tpoint.elements.blip.position = tpoint.marker.position
	tpoint.elements.blip:setData( "extra_blip", 80, false )

	triggerEvent( "RefreshRadarBlips", localPlayer )

	if type( callback_func ) == "function" then
		tpoint.PostJoin = callback_func
		tpoint.PreJoin = check_func
    end
    
    return tpoint
end