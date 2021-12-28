Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

CURRENT_CITY = 0
for job_class, job_data in pairs( JOB_DATA ) do
	for marker_id, marker_data in pairs( job_data.marker_postions ) do
		local config = { }
		config.x, config.y, config.z = marker_data.x, marker_data.y, marker_data.z

		config.elements = { }
		config.elements.blip = createBlip( config.x, config.y, config.z, job_data.blip_id, 2, 255, 255, 255, 255, 0, 150 )

		config.radius = 3
		config.marker_text = marker_data.name or "Название отсутствует"

		tpoint = TeleportPoint( config )
		tpoint.text = false
		tpoint.keypress = false

		local r, g, b = unpack( job_data.marker_color )
		tpoint.marker:setColor( r, g, b, 50 )

		local file_path_icon_marker = "img/" .. JOB_ID[ job_class ] .. "/" .. (marker_data.marker_icon and marker_data.marker_icon or "marker.png")
		if fileExists( file_path_icon_marker ) then
			tpoint:SetImage( file_path_icon_marker )
		end

		tpoint.element:setData( "material", true, false )
		   tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", r, g, b, 255, 2.3 } )

		tpoint.PostJoin = function( self, player )
			CURRENT_CITY = marker_data.city or 0
			triggerServerEvent( "onServerJobInterfaceOpenRequest", resourceRoot, marker_id, job_class )
		end

		tpoint.PostLeave = function( self )
		    ShowJobUI_handler()
		end
	end
end