loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ShAccessories" )
Extend( "ShVehicleConfig" )

CONST_ACCESSORIES_SLOTS_BONES_INFO = {
	[1] = 1; -- шапка
	[2] = 1; -- очки
	[3] = 2; -- шея
	[4] = 3; -- спина
	[5] = 3; -- сумка
}

LOADED_ACCESSORIES = { }
SYNC_ACCESSORIES = { }

function AddPlayerAccessories( player )
	if not LOADED_ACCESSORIES[ player ] then
		LOADED_ACCESSORIES[ player ] = { }
		addEventHandler( "onClientElementDataChange", player, onClientElementDataChange_handler )
	end

	local current_accessories = player:getData( "current_accessories" )
	if not current_accessories then return end

	for _, slot in pairs( CONST_ACCESSORIES_SLOTS_IDS ) do
		local data = current_accessories.list and current_accessories.list[ slot ]
		if data and CONST_ACCESSORIES_INFO[ data.id ] then
			local id = data.id
			local double = false

			if isElement( LOADED_ACCESSORIES[ player ][ slot ] ) then
				if CONST_ACCESSORIES_INFO[ data.id ].model == LOADED_ACCESSORIES[ player ][ slot ].model then
					double = true
				else
					destroyElement( LOADED_ACCESSORIES[ player ][ slot ] )
				end
			end

			local position = data.position or { x = 0, y = 0, z = 0 }
			local rotation = data.rotation or { x = 0, y = 0, z = 0 }
			local scale = data.scale or 1

			local bone_slot = CONST_ACCESSORIES_SLOTS_BONES_INFO[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ slot ] ]

			if not double then
				local object = Object( CONST_ACCESSORIES_INFO[ data.id ].model, position.x, position.y, position.z )
				object:setScale( scale )
				object.interior = player.interior
				object.dimension = player.dimension

				exports.bone_attach:attachElementToBone( object, player, bone_slot, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z )

				LOADED_ACCESSORIES[ player ][ slot ] = object
			else
				LOADED_ACCESSORIES[ player ][ slot ]:setScale( scale )
				exports.bone_attach:attachElementToBone( LOADED_ACCESSORIES[ player ][ slot ], player, bone_slot, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z )
			end
		elseif isElement( LOADED_ACCESSORIES[ player ][ slot ] ) then
			destroyElement( LOADED_ACCESSORIES[ player ][ slot ] )
		end
	end
end

function RemovePlayerAccessories( player )
	if not LOADED_ACCESSORIES[ player ] then return end

	for _, object in pairs( LOADED_ACCESSORIES[ player ] ) do
		if isElement( object ) then
			destroyElement( object )
		end
	end

	LOADED_ACCESSORIES[ player ] = nil

	if isElement( player ) then
		player:setData( "current_accessories", false, false )
		removeEventHandler( "onClientElementDataChange", player, onClientElementDataChange_handler )
	end
end

function onClientVehicleEnter_handler( player )
	if not LOADED_ACCESSORIES[ player ] or ( VEHICLE_CONFIG[ source.model ] or { } ).is_moto then return end

	RemovePlayerAccessories( player, false )
end
addEventHandler( "onClientVehicleEnter", root, onClientVehicleEnter_handler )

function onClientVehicleExit_handler( player )
	if LOADED_ACCESSORIES[ player ] or ( VEHICLE_CONFIG[ source.model ] or { } ).is_moto then return end

	AddPlayerAccessories( player )
end
addEventHandler( "onClientVehicleExit", root, onClientVehicleExit_handler )

addEventHandler( "onClientResourceStart", resourceRoot, function()
	Timer( ProcessAccessories, 1000, 0 )
end )

addEventHandler( "onClientResourceStop", resourceRoot, function()
	local elements = getElementsWithinRange( localPlayer.position, CONST_DISTANCE_ACCESSORIES_SYNC, "player" )
	for _, player in pairs( elements ) do
		RemovePlayerAccessories( player )
	end
end )

function ProcessAccessories()
	if not localPlayer:IsInGame() then return end

	local players_in_range = { }

	local elements = getElementsWithinRange( localPlayer.position, CONST_DISTANCE_ACCESSORIES_SYNC, "player" )
	for _, player in pairs( elements ) do
		local player_vehicle = player.vehicle
		if isElementStreamedIn( player ) and (not player_vehicle or ( VEHICLE_CONFIG[ player_vehicle.model ] or { } ).is_moto) then
			players_in_range[ player ] = true

			local current_accessories = player:getData( "current_accessories" )
			if not current_accessories or current_accessories.model ~= player.model then
				player:setData( "current_accessories", {
					model = player.model;
					list = player:GetAccessories( player.model );
				}, false )

				AddPlayerAccessories( player )
			end
		end
	end

	local cam_x, cam_y, cam_z = getCameraMatrix( )
	local elements = getElementsWithinRange( Vector3( cam_x, cam_y, cam_z ), CONST_DISTANCE_ACCESSORIES_SYNC, "ped" )
	for _, player in pairs( elements ) do
		players_in_range[ player ] = true
	end

	for player in pairs( LOADED_ACCESSORIES ) do
		local player_vehicle = isElement( player ) and player.vehicle
		if not player or not players_in_range[ player ] or (player_vehicle and not ( VEHICLE_CONFIG[ player_vehicle.model ] or { } ).is_moto) then
			RemovePlayerAccessories( player )
		end
	end
end

function onClientElementDataChange_handler( key, old_value, new_value )
	if key ~= "accessories" then return end

	if not LOADED_ACCESSORIES[ source ] then
		removeEventHandler( "onClientElementDataChange", source, onClientElementDataChange_handler )
		return
	end

	source:setData( "current_accessories", {
		model = source.model;
		list = new_value[ source.model ];
	}, false )

	AddPlayerAccessories( source )
end

function UpdatePedAccessories_handler( player, data )
	if not isElement( player ) then return end

	player:setData( "current_accessories", {
		model = data.model;
		list = data.list;
		ver = data.ver;
	}, false )

	AddPlayerAccessories( player )
end
addEvent( "UpdatePedAccessories", true )
addEventHandler( "UpdatePedAccessories", root, UpdatePedAccessories_handler )