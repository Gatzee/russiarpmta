loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CInterior" )
Extend( "ShBusiness" )
Extend( "ShClans" )
Extend( "CPlayer" )
Extend( "ib" )

TUNING_POSITIONS = GetCoords( 3 )

for i, n in pairs( TUNING_POSITIONS ) do

	local config = { }
	config.x, config.y, config.z = n.x, n.y+860, n.z

	config.elements = { }
	config.elements.blip = createBlip( config.x, config.y, config.z, 63, 2, 255, 255, 255, 255, 0, 150 )

	config.radius = 3
	config.marker_text = ""

	tpoint = TeleportPoint( config )
    tpoint.text = "ALT Взаимодействие"
    tpoint.accepted_elements = { vehicle = true }
	tpoint.marker:setColor( 128, 128, 245, 10 )

    tpoint:SetImage( { "img/image.png", 255, 255, 255, 255, 3 } )
    tpoint:SetDropImage( { "img/dropimage.png", 128, 128, 245, 255, 2.5 } )

	tpoint.PostJoin = function( self, player )
		if isTuningUIOpen( ) or player.dimension ~= 0 then return end
		triggerEvent( "ToggleDisableFirstPerson", localPlayer )
		triggerServerEvent( "onTuningShopJoinRequest", resourceRoot )
	end

	tpoint.PostLeave = function( self, player )
		if player.dimension ~= 0 then return end
        triggerServerEvent( "onTuningShopLeaveRequest", resourceRoot )
	end

end
