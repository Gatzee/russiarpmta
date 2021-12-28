loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "ShApartments" )
Extend( "ShVipHouses" )
Extend( "CPlayer" )
Extend( "CInterior" )

function InitModules( )
	if not _MODULES_INITIALIZED then
		Extend( "ib" )
		_MODULES_INITIALIZED = true
	end
end

local house_owners = { }
local attempt_count = 0
local viphouses_reverse = { }
local current_house_id = nil
local current_house_markers = { }
local IS_GLOBAL_MARKERS_CREATED = false
local col_disabled_players = { }

function updateVipHouseElement( id )
	local data = VIP_HOUSES_LIST[ id ]
	local is_villa = data.class == "Вилла"
	local marker_conf = is_villa and data.control_config or data.enter_marker_position
	local marker = marker_conf.marker_ref

	if not marker_conf or not marker then return end

	-- if player is owner
	if viphouses_reverse[ id ] and not marker.elements then
		marker.elements = { }

		-- blip
		marker.elements.blip = Blip( marker_conf.x, marker_conf.y +860, marker_conf.z, 0, 2, 255, 0, 0, 255, 0, 300 )
		marker.elements.blip:setData( "extra_blip", 71, false )

		-- parking
		local parking_config = data.parking_marker_position
		if parking_config then
			parking_config.text = "ALT Взаимодействие"
			parking_config.vehicle_text = "ALT Взаимодействие"
			parking_config.keypress = "lalt"
			parking_config.dimension = data.dimension or 0
			parking_config.interior = data.interior or 0
			parking_config.radius = 2
			parking_config.accepted_elements = { player = true, vehicle = true }

			marker.elements.parking_marker = TeleportPoint( parking_config )
			marker.elements.parking_marker.element:setData( "ignore_dist", true )
			marker.elements.parking_marker.marker:setColor( 0, 255, 0, 50 )
			marker.elements.parking_marker:SetImage( ":nrp_house_garage/images/marker.png" )
			marker.elements.parking_marker.element:setData( "material", true, false )
			marker.elements.parking_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 0,255,0, 255, 1.55 } )
			marker.elements.parking_marker.house_id = data.hid

			marker.elements.parking_marker.PostJoin = function( self )
				triggerServerEvent( "PlayerEnterParkingMarker", resourceRoot, self.house_id )
			end

			marker.elements.parking_marker.PostLeave = function( self )
				triggerEvent( "HideUIGarage", localPlayer )
			end
		end

		-- special for villa
		if is_villa then
			marker.elements.wardrobe = CreateVipHouseWardrobeMarker( data.wardrobe_position, id )
			marker.elements.cooking = CreateVipHouseCookingMarker( data.cooking_position, id )
			marker.elements.inventory = exports.nrp_house_inventory:CreateMarker( 0, id, data.inventory_position )
		end

	elseif not viphouses_reverse[ id ] and marker.elements then
		for idx, element in pairs( marker.elements or { } ) do
			element:destroy( )
		end

		marker.elements = nil
	end
end

function isBlipElementExist( marker )
    return marker.elements and isElement( marker.elements.blip )
end

function CreateOrUpdateGlobalMapMarkers( )
	local viphouse = localPlayer:getData( "viphouse" ) or { }

	if attempt_count <= 2 and not next( viphouse ) then
		attempt_count = attempt_count + 1
		return
	end

	if isElement( sourceTimer ) then
		killTimer( sourceTimer )
	end

	for idx, data in pairs( localPlayer:getData( "wedding_at_viphouse_data" ) or { } ) do
		table.insert( viphouse, tonumber( data.id ) and data.id or data.id.id ) -- well data from sWedding.lua, TODO: refactoring
	end

	viphouses_reverse = { }
	for idx, id in ipairs( viphouse ) do
		viphouses_reverse[ id ] = id
	end

	if not IS_GLOBAL_MARKERS_CREATED then

		for id, config in pairs( VIP_HOUSES_LIST ) do
			config:client_create( )

			local owner_name = house_owners[ config.hid ]
			local enter_config = config.enter_marker_position

			if enter_config then
				enter_config.marker_text = owner_name and owner_name .. "\n" .. config.name or config.name
				enter_config.dimension = enter_config.dimension or 0
				enter_config.interior = enter_config.interior or 0
				enter_config.radius = 1.5
				enter_config.text = "ALT Взаимодействие"
				enter_config.keypress = "lalt"

				local enter_marker = TeleportPoint( enter_config )
				enter_marker.element:setData( "ignore_dist", true )
                enter_marker:SetImage( "img/marker.png" )
			    enter_marker.element:setData( "material", true, false )
    		    enter_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 255, 0, 255, 1.15 } )
				enter_marker.marker:setColor( 0, 255, 0, 50 )
				enter_marker.house_id = config.hid

				enter_marker.PostJoin = function( )
					if localPlayer:GetBlockInteriorInteraction() then
						localPlayer:ShowInfo( "Вы не можете войти во время задания" )
						return false
					end
					triggerServerEvent( "PlayerWantEnterVipHouse", resourceRoot, id )
				end

				enter_config.marker_ref = enter_marker
			end

			local control_config = config.control_marker_position

			if not control_config then
				local class_data = APARTMENTS_CLASSES[ config.apartments_class ]
				control_config = {
					x = class_data.control_position.x,
					y = class_data.control_position.y,
					z = class_data.control_position.z,
					interior = class_data.interior,
					dimension = 5000 + id,
				}
			end

			control_config.marker_text = ""
			control_config.dimension = control_config.dimension or 0
			control_config.interior = control_config.interior or 0
			control_config.radius = 1.5
			control_config.keypress = "lalt"
			control_config.text = "ALT Взаимодействие"

			local control_marker = TeleportPoint(control_config)
			control_marker:SetText( "" )
			control_marker.element:setData( "ignore_dist", true )
			control_marker.marker:setColor( 0, 255, 0, 50 )
            control_marker:SetImage( ":nrp_house_control/images/marker.png" )
		    control_marker.element:setData( "material", true, false )
		    control_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 255, 0, 255, 1.15 } )
			control_marker.house_id = config.hid

			control_marker.PostJoin = function( )
				triggerServerEvent( "PlayerWantShowControlVipHouse", resourceRoot, id )
			end

			config.control_config = control_config
			control_config.marker_ref = control_marker

			if config.class == "Вилла" then
				local owner_name = house_owners[ config.hid ]
				local text = ( owner_name and owner_name .. "\n" or "" ) .. ( config.name or "" )

				control_marker:SetText( text )

				CreateBedsMarkers( config.bed_position, id )

				local bed_check_col = createColSphere( Vector3( config.bed_position[ 1 ] ), 20 )
				addEventHandler( "onClientColShapeHit", bed_check_col, function( element )
					if element == localPlayer then
						triggerServerEvent( "onPlayerEnterVilla", resourceRoot, id )
					end
				end )

				addEventHandler( "onClientColShapeLeave", bed_check_col, function( element )
					if element == localPlayer then
						triggerServerEvent( "onPlayerExitVilla", resourceRoot, id )
						triggerEvent( "onClientPlayerHouseExit", resourceRoot, 0, id )
					end
				end )
			end

			updateVipHouseElement( id )
		end

		IS_GLOBAL_MARKERS_CREATED = true
	else
		for id in pairs( VIP_HOUSES_LIST ) do
			updateVipHouseElement( id )
		end
	end
end

addEvent( "onReceiveViphouseMarkersData", true )
addEventHandler( "onReceiveViphouseMarkersData", resourceRoot, function ( pData )
	house_owners = pData
	setTimer( CreateOrUpdateGlobalMapMarkers, 1000, 3 )
end )

addEventHandler("onClientResourceStart", resourceRoot, function ( )
	setTimer( triggerServerEvent, 1000, 1, "onRequestVipHouseOwners", resourceRoot )
end )

function CreateBedsMarkers( beds, house_id, interior, dimension )
	--Инициализируем таблицу для кроватей
	if not beds then return end
	
	bedsMarkers = {  }
	for i,v in pairs( beds ) do
		bedsMarkers[i] = CreateVipHouseBedMarker( i, v, house_id, interior, dimension )
	end

	return bedsMarkers
end

function CreateVipHouseMarkers( data )
	DestoryVipHouseMarkers()

	current_house_id = data.id

	local class_data = APARTMENTS_CLASSES[ data.apartments_class ]
	local interior = class_data.interior
	local dimension = data.dimension

	current_house_markers.exit = CreateVipHouseExitMarker( class_data.exit_position, current_house_id, interior, dimension )
	current_house_markers.beds = CreateBedsMarkers( class_data.bed_position, current_house_id, interior, dimension )

	if class_data.wardrobe_position then
		current_house_markers.wardrobe = CreateVipHouseWardrobeMarker( class_data.wardrobe_position, current_house_id, interior, dimension )
	end

	if class_data.cooking_position then
		current_house_markers.cooking = CreateVipHouseCookingMarker( class_data.cooking_position, current_house_id, interior, dimension )
	end

	if class_data.inventory_position then
		current_house_markers.inventory = exports.nrp_house_inventory:CreateMarker( 0, current_house_id, class_data.inventory_position, interior, dimension )
	end

    for k, v in pairs( getElementsWithinRange( localPlayer.position, 50, "player" ) ) do
        if v.interior == interior and v.dimension == dimension then
			localPlayer:setCollidableWith( v, false )
			table.insert( col_disabled_players, v )
        end
    end
end
addEvent( "CreateVipHouseMarkers", true )
addEventHandler( "CreateVipHouseMarkers", resourceRoot, CreateVipHouseMarkers )

function CreateVipHouseExitMarker( position, house_id, interior, dimension )
	local config = {
		text = "ALT Взаимодействие",
		marker_text = "Выход",
		keypress = "lalt",
		radius = 1,
		x = position.x;
		y = position.y;
		z = position.z;
		interior = interior or 0;
		dimension = dimension or 0;
		color = { 245, 128, 128, 50 },
	}

	local exit_marker = TeleportPoint( config )
	exit_marker.element:setData( "material", true, false )
    exit_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 128, 255, 0.75 } )

	exit_marker.PostJoin = function( self, player )
		self.OnLeave( player )

		DestoryVipHouseMarkers()

		triggerEvent( "onClientPlayerHouseExit", resourceRoot, 0, current_house_id )

		triggerServerEvent( "PlayerExitFromVipHouse", resourceRoot, current_house_id )

		current_house_id = nil
	end

	return exit_marker
end

function CreateVipHouseBedMarker( bed_id, position, house_id, interior, dimension )
	local bed_config = {
		text = "ALT Взаимодействие",
		keypress = "lalt",
		radius = 1.7,
		x = position.x;
		y = position.y;
		z = position.z - 1;
		interior = interior or 0;
		dimension = dimension or 0;
		color = { 0, 0, 0, 0 },
	}

	local bed_marker = TeleportPoint( bed_config )

	bed_marker.PreJoin = function( _, player )
		return not player:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
	end

	bed_marker.PostJoin = function( _, player )
		bed_marker.OnLeave( player )
		if player:getData( "is_sleeping" ) then return end
		triggerEvent( "SetPlayerSleepOnBed", player, true, 0, house_id, bed_id )
	end

	return bed_marker
end

function CreateVipHouseWardrobeMarker( position, house_id, interior, dimension )
	local wardrobe_config = {
		text = "ALT Взаимодействие",
		keypress = "lalt",
		radius = 1.3,
		x = position.x;
		y = position.y;
		z = position.z;
		interior = interior or 0;
		dimension = dimension or 0;
		color = { 101, 51, 255, 50 },
	}

	local wardrobe_marker = TeleportPoint( wardrobe_config )
	
	wardrobe_marker:SetImage( ":nrp_house_wardrobe/images/marker.png" )
	wardrobe_marker.element:setData( "material", true, false )
    wardrobe_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 101, 51, 255, 255, 1 } )
	
	wardrobe_marker.PreJoin = function( _, player )
		return not player:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
	end

	wardrobe_marker.PostJoin = function( _, player )
		triggerServerEvent( "onViphouseWardrobeEnter", player, house_id )
	end

	return wardrobe_marker
end

function CreateVipHouseCookingMarker( position, house_id, interior, dimension )
	local cooking_config = {
		text = "ALT Взаимодействие",
		keypress = "lalt",
		radius = 1,
		x = position.x;
		y = position.y;
		z = position.z;
		interior = interior or 0;
		dimension = dimension or 0;
		color = { 255, 153, 0, 50 },
	}

	local cooking_marker = TeleportPoint( cooking_config )
	
	cooking_marker:SetImage( ":nrp_house_cooking/images/marker.png" )
	cooking_marker.element:setData( "material", true, false )
    cooking_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 153, 0, 255, 0.75 } )

	cooking_marker.PreJoin = function( _, player )
		return not player:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
	end

	cooking_marker.PostJoin = function( _, player )
		triggerServerEvent( "onViphouseCookingEnter", player, house_id )
	end

	return cooking_marker
end

function DestoryVipHouseMarkers()
	for i, marker in pairs( current_house_markers ) do
		if isElement( marker.element ) then
			marker.destroy()
		end
	end

    for k, v in pairs( col_disabled_players ) do
		if isElement( v ) then
			localPlayer:setCollidableWith( v, true )
		end
	end

	col_disabled_players = { }
end