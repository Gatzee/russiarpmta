Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )

CURRENT_CITY = 0

for job_class, job_data in pairs( JOB_DATA ) do
    for i, n in pairs( job_data.markers_positions ) do
    	local config = { }
    	config.x, config.y, config.z = n.x, n.y, n.z

		config.elements = { }
		if job_data.blip_id then
    		config.elements.blip = createBlip( config.x, config.y, config.z, 0, 2, 255, 255, 255, 255, 0, 150 )
			setElementData( config.elements.blip, 'extra_blip', job_data.blip_id )
		end

    	config.radius = n.blip_size or 3
    	config.marker_text = n.name
		config.dimension = n.dimension or 0
		config.interior = n.interior or 0

    	tpoint = TeleportPoint( config )
        tpoint.keypress = "lalt"
    	tpoint.text = "ALT Взаимодействие"
    	tpoint.marker:setColor( 255, 255, 0, 20 )

    	tpoint.PostJoin = function( self, player )
    		CURRENT_CITY = n.city
    		triggerServerEvent( "onServerInterfaceOpenRequest", root, i, job_class )
    	end

    	tpoint:SetImage( "img/" .. JOB_ID[ job_class ]  .. "/marker.png" )
    	tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 0, 255, n.blip_size and (n.blip_size * 0.75) or 2.3 } )

    	tpoint.PostLeave = function( self )
            ShowCoopFinesUI( _ )
            ShowCoopJobUI( _ )
    		ShowCoopJobInviteUI( _ )
    		ShowCoopJobChangeRole( _ )
		end
		
		triggerEvent( "CreateSphericalGreenZone", localPlayer, { position = Vector3( config.x, config.y, config.z ), size = 3, interior = 0, dimension = 0 } )
    end
end