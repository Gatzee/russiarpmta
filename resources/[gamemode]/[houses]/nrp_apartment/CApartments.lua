loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShApartments" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "CInterior" )
Extend( "ib" )

local apartment_id = nil
local apartment_markers = { }
local col_disabled_players = { }
local attempt_count = 0
local apartments_reverse = { }
local IS_GLOBAL_MARKERS_CREATED = false

function updateApartmentsElement( id )
	local data = APARTMENTS_LIST[ id ]
	local marker = data.marker_ref

	-- if player is owner
	if apartments_reverse[ id ] and not marker.elements then
		marker.elements = { }

		-- blip
		marker.elements.blip = Blip( marker.x, marker.y, marker.z, 0, 2, 255, 0, 0, 255, 0, 300 )
		marker.elements.blip:setData( "extra_blip", 71, false )

		-- enter parking marker
		marker.elements.parking_marker = TeleportPoint( {
			radius = 1.5,
			x = data.parking_position.x,
			y = data.parking_position.y,
			z = data.parking_position.z,
		} )
		marker.elements.parking_marker.marker:setColor( 128, 245, 128, 128 )
		marker.elements.parking_marker:SetImage( ":nrp_house_garage/images/marker.png" )
		marker.elements.parking_marker.text = "ALT Взаимодействие"
		marker.elements.parking_marker.keypress = "lalt"
		marker.elements.parking_marker.element:setData( "material", true, false )
		marker.elements.parking_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 245, 128, 255, 1.15 } )

		marker.elements.parking_marker.PostJoin = function(self, player )
			self.OnLeave( player )
			triggerServerEvent( "PlayerWantShowGarage", resourceRoot, id )
		end

		marker.elements.parking_marker.PostLeave = function( )
			triggerEvent( "HideUIGarage", root )
		end

		-- vehicle marker
		marker.elements.vehicle_marker = TeleportPoint( {
			radius = 4,
			x = data.vehicle_position.x,
			y = data.vehicle_position.y,
			z = data.vehicle_position.z,
			accepted_elements = { vehicle = true },
		} )
		marker.elements.vehicle_marker.marker:setColor( 245, 128, 128, 50 )
		marker.elements.vehicle_marker:SetImage( "images/marker_spawn_vehicle.png" )
		marker.elements.vehicle_marker.slowdown_coefficient = nil
		marker.elements.vehicle_marker.text = "ALT Взаимодействие"
		marker.elements.vehicle_marker.keypress = "lalt"
		marker.elements.vehicle_marker.element:setData( "material", true, false )
		marker.elements.vehicle_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 128, 255, 3 } )

		marker.elements.vehicle_marker.PreJoin = function( )
			return localPlayer.vehicle
		end

		marker.elements.vehicle_marker.PostJoin = function(self, player )
			self.OnLeave( player )
			triggerServerEvent( "PlayerWantParkVehicle", resourceRoot, id )
		end

	elseif not apartments_reverse[ id ] and marker.elements then
		for idx, element in pairs( marker.elements or { } ) do
			element:destroy( )
		end

		marker.elements = nil
	end
end

function CreateApartmentMarkers( id, number, dimension, data )
	DestoryApartmentMarkers( )

	apartment_id = id

	local class_data = APARTMENTS_CLASSES[ APARTMENTS_LIST[ id ].class ]

	local config = {
		radius = 1,
		marker_text = "Выход",
		x = class_data.exit_position.x;
		y = class_data.exit_position.y;
		z = class_data.exit_position.z;
		interior = class_data.interior;
		dimension = dimension;
	}

	apartment_markers.exit = TeleportPoint( config )
	apartment_markers.exit.element:setData( "material", true, false )
	apartment_markers.exit:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 128, 255, 0.8 } )
	apartment_markers.exit.text = "ALT Взаимодействие"
	apartment_markers.exit.keypress = "lalt"
	apartment_markers.exit.marker:setColor( 245, 128, 128, 50 )
	apartment_markers.exit.PostJoin = function( self, player )
		self.OnLeave( player )

		DestoryApartmentMarkers( )

		triggerEvent( "onClientPlayerHouseExit", resourceRoot, id, number )

		triggerServerEvent( "PlayerExitFromApartments", resourceRoot, id )
		apartment_id = nil
	end


	local config = {
		radius = 1,
		x = class_data.control_position.x;
		y = class_data.control_position.y;
		z = class_data.control_position.z;
		interior = class_data.interior;
		dimension = dimension;
	}

	apartment_markers.control = TeleportPoint( config )
	apartment_markers.control.text = false
	apartment_markers.control.keypress = false
	apartment_markers.control.marker:setColor( 245, 245, 128, 50 )

	apartment_markers.control:SetImage( ":nrp_house_control/images/marker.png" )
	apartment_markers.control.element:setData( "material", true, false )
	apartment_markers.control:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 245, 128, 255, 0.8 } )

	apartment_markers.control.PreJoin = function( self )
		return not localPlayer:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
	end
	apartment_markers.control.PostJoin = function( self, player )
		self.OnLeave( player )

		triggerServerEvent( "PlayerEnterOnApartmentsControl", resourceRoot, id, number )
	end
	local beds_position = class_data.bed_position
	--Инициализируем таблицу для кроватей
	apartment_markers.beds = {  }
	for i,bedConf in pairs( beds_position ) do 
		local config = {
			text = "ALT Взаимодействие",
			keypress = "lalt",
			radius = 1.7,
			x = bedConf.x;
			y = bedConf.y;
			z = bedConf.z - 1;
			interior = class_data.interior;
			dimension = dimension;
			color = { 0, 0, 0, 0 },
		}
	
		apartment_markers.beds[i] = TeleportPoint( config )
		apartment_markers.beds[i].PreJoin = function( self )
			return not localPlayer:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
		end
	
		apartment_markers.beds[i].PostJoin = function( self, player )
			apartment_markers.beds[i].OnLeave( localPlayer )
			if player:getData( "is_sleeping" ) then return end
			triggerEvent( "SetPlayerSleepOnBed", localPlayer, true, id, number, i )
		end
	end


	local config = {
		text = "ALT Взаимодействие",
		keypress = "lalt",
		radius = 1.3,
		x = class_data.wardrobe_position.x;
		y = class_data.wardrobe_position.y;
		z = class_data.wardrobe_position.z;
		interior = class_data.interior;
		dimension = dimension;
		color = { 101, 51, 255, 50 },
	}

	apartment_markers.wardrobe = TeleportPoint( config )

	apartment_markers.wardrobe:SetImage( ":nrp_house_wardrobe/images/marker.png" )
	apartment_markers.wardrobe.element:setData( "material", true, false )
    apartment_markers.wardrobe:SetDropImage( { ":nrp_shared/img/dropimage.png", 101, 51, 255, 255, 1 } )

	apartment_markers.wardrobe.PreJoin = function( self )
		return not localPlayer:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
	end
	apartment_markers.wardrobe.PostJoin = function( self, player )
		self.OnLeave( player )

		triggerServerEvent( "PlayerEnterOnApartmentsWardrobe", resourceRoot, id, number )
	end


	local config = {
		text = "ALT Взаимодействие",
		keypress = "lalt",
		radius = 0.7,
		x = class_data.cooking_position.x;
		y = class_data.cooking_position.y;
		z = class_data.cooking_position.z;
		interior = class_data.interior;
		dimension = dimension;
		color = { 255, 153, 0, 50 },
	}
	apartment_markers.cooking = TeleportPoint( config )

	apartment_markers.cooking:SetImage( ":nrp_house_cooking/images/marker.png" )
	apartment_markers.cooking.element:setData( "material", true, false )
    apartment_markers.cooking:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 153, 0, 255, 0.53 } )

	apartment_markers.cooking.PreJoin = function( self )
		return not localPlayer:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
	end
	apartment_markers.cooking.PostJoin = function( self, player )
		triggerServerEvent( "PlayerEnterOnApartmentsCooking", resourceRoot, id, number )
	end


	apartment_markers.inventory = exports.nrp_house_inventory:CreateMarker( id, number, class_data.inventory_position, class_data.interior, dimension )


    for k, v in pairs( getElementsWithinRange( localPlayer.position, 50, "player" ) ) do
        if v.interior == class_data.interior and v.dimension == dimension then
			localPlayer:setCollidableWith( v, false )
			table.insert( col_disabled_players, v )
        end
	end
end
addEvent( "CreateApartmentMarkers", true )
addEventHandler( "CreateApartmentMarkers", resourceRoot, CreateApartmentMarkers )

function DestoryApartmentMarkers( )
	for i, marker in pairs( apartment_markers ) do
		if isElement( marker ) or isElement( marker.element ) then
			marker:destroy( )
		end
	end

	for k, v in pairs( col_disabled_players ) do
		if isElement( v ) then
			localPlayer:setCollidableWith( v, true )
		end
	end
	col_disabled_players = { }
end

function CreateOrUpdateGlobalMapMarkers( )
	local apartments = localPlayer:getData( "apartments" )

	if attempt_count <= 2 and not apartments then
		attempt_count = attempt_count + 1
		return
	end

	if isElement( sourceTimer ) then
		killTimer( sourceTimer )
	end

	for idx, data in pairs( localPlayer:getData( "wedding_at_apartments_data" ) or { } ) do
		table.insert( apartments, data )
	end

	apartments_reverse = { }
	for idx, apart in pairs( apartments or { } ) do
		apartments_reverse[ apart.id ] = apart
	end

	if not IS_GLOBAL_MARKERS_CREATED then
		for i, position in ipairs( APARTMENTS_COMPLEX_LIST ) do
		   position.y = position.y + 860
			Blip( position, 31, 2, 255, 255, 0, 255, -99999, 200 )
		end

		for id, data in ipairs( APARTMENTS_LIST ) do
			local enter_marker = TeleportPoint( {
				radius = 1.5,
				x = data.enter_position.x,
				y = data.enter_position.y,
				z = data.enter_position.z,
				marker_text = "Подъезд #".. id,
			} )

			enter_marker.marker:setColor( 255, 255, 255, 128 )
            enter_marker:SetImage( "images/marker.png" )
		    enter_marker.element:setData( "material", true, false )
    	    enter_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.15 } )
			enter_marker.text = false
			enter_marker.keypress = false
			enter_marker.PostJoin = function( self, player )
				self.OnLeave( player )

				triggerServerEvent( "PlayerWantShowListApartments", resourceRoot, id )
			end
			enter_marker.PostLeave = function( self, player )
				setTimer( function ( )
					if isInsideColShape( self.colshape, player.position ) then return end

					DestroyUIInfo( )
					DestroyUIList( )
				end, 1000, 1 )
			end

			data.marker_ref = enter_marker

			updateApartmentsElement( id )
		end

		IS_GLOBAL_MARKERS_CREATED = true
	else
		for id in ipairs( APARTMENTS_LIST ) do
			updateApartmentsElement( id )
		end
	end
end

addEvent( "onUpdateApartmentsMarkersData", true )
addEventHandler( "onUpdateApartmentsMarkersData", resourceRoot, function ( )
	setTimer( CreateOrUpdateGlobalMapMarkers, 1000, 1 )
end )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	setTimer( CreateOrUpdateGlobalMapMarkers, 5000, 3 )
end)