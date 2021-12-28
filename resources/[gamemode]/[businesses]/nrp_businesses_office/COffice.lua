Extend( "CInterior" )

local exit_office_marker, control_office_marker, secretary_office_marker, secretary_ped

function onClientResourceStart_handler( )
	for idx, pos in pairs( CONST_OFFICE_BUILD_ENTER_POSITIONS ) do
		local enter_office_marker = TeleportPoint( {
			x = pos.x, y = pos.y, z = pos.z;
			interior = 0;
			dimension = 0;
			radius = 2;
			marker_text = "Бизнес центр";
		} )

		enter_office_marker.text = "ALT Взаимодействие"
		enter_office_marker.marker:setColor( 128, 128, 245, 64 )
		enter_office_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 128, 245, 255, 1.5 } )

		enter_office_marker.PostJoin = function( self, player )
			triggerServerEvent( "ClientRequestOfficeEnter", resourceRoot, nil, idx )
		end

		enter_office_marker.elements = { }
		enter_office_marker.elements.blip = createBlipAttachedTo( enter_office_marker.marker, 0, 2, 255, 255, 255, 255, 0, 150 )
		enter_office_marker.elements.blip:setData( "extra_blip", 73, false )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )

function onPlayerEnterOffice_handler( owner_player, office_data )
	do
		local pos = CONST_OFFICE_INTERIOR_EXIT_POSITIONS[ office_data.class ]
		exit_office_marker = TeleportPoint( {
			x = pos.x, y = pos.y, z = pos.z;
			interior = 1;
			dimension = localPlayer.dimension;

			radius = 1.5;

			marker_text = "Выход";
		} )

		exit_office_marker.text = "ALT Взаимодействие"
		exit_office_marker.marker:setColor( 245, 128, 128, 50 )

		exit_office_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 128, 255, 1.05 } )

		exit_office_marker.PostJoin = function( self, player )
			triggerServerEvent( "ClientRequestOfficeExit", resourceRoot )
		end
	end

	if owner_player == localPlayer then
		local pos = CONST_OFFICE_INTERIOR_CONTROL_POSITIONS[ office_data.class ]
		control_office_marker = TeleportPoint( {
			x = pos.x, y = pos.y, z = pos.z;
			interior = 1;
			dimension = localPlayer.dimension;

			radius = 1;

			marker_text = ( office_data.deposit < 0 and "ТРЕБУЕТСЯ ОПЛАТА\n" or "" ) .."Управление\nофисом";
		} )

		control_office_marker.text = "ALT Взаимодействие"
		control_office_marker.marker:setColor( 128, 245, 128, 50 )

		control_office_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 245, 128, 255, 0.75 } )

		control_office_marker.PostJoin = function( self, player )
			triggerServerEvent( "onPlayerRequestOfficeControlMenu", resourceRoot )
		end
	end

	if office_data.secretary then
		secretary_ped = createPed( CONST_OFFICE_SECRETARY_MODELS[ office_data.secretary ], CONST_OFFICE_SECRETARY[ office_data.class ].ped_position, CONST_OFFICE_SECRETARY[ office_data.class ].ped_rotation )
		secretary_ped.interior = 1;
		secretary_ped.dimension = localPlayer.dimension;
		secretary_ped.frozen = true

		if owner_player == localPlayer then
			local pos = CONST_OFFICE_SECRETARY[ office_data.class ].marker_position
			secretary_office_marker = TeleportPoint( {
				x = pos.x, y = pos.y, z = pos.z;
				interior = 1;
				dimension = localPlayer.dimension;

				radius = 1;

				marker_text = "Секретарша";
			} )

			secretary_office_marker.text = "ALT Взаимодействие"
			secretary_office_marker.marker:setColor( 245, 128, 245, 50 )

			secretary_office_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 245, 255, 0.75 } )

			secretary_office_marker.PostJoin = function( self, player )
				triggerServerEvent( "onPlayerRequestOfficeSecretaryMenu", resourceRoot )
			end
		end
	end
end
addEvent( "onPlayerEnterOffice", true )
addEventHandler( "onPlayerEnterOffice", resourceRoot, onPlayerEnterOffice_handler )

function onPlayerExitOffice_handler( )
	iprint( exit_office_marker, control_office_marker, secretary_office_marker, secretary_ped )
	if isElement( exit_office_marker ) then
		exit_office_marker:destroy( )
	end

	if isElement( control_office_marker ) then
		control_office_marker:destroy( )
	end

	if isElement( secretary_office_marker ) then
		secretary_office_marker:destroy( )
	end

	if isElement( secretary_ped ) then
		destroyElement( secretary_ped )
	end
end
addEvent( "onPlayerExitOffice", true )
addEventHandler( "onPlayerExitOffice", resourceRoot, onPlayerExitOffice_handler )