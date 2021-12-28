Extend( "SPlayer" )
Extend( "SVehicle" )

CARTEL_VEHICLES = {}
CARTEL_VEHICLES_LIST_REVERSE = {}
CARTEL_VEHICLES_BY_OWNER = {}

function onPlayerRequestCartelVehicles_handler( cartel_id )
	triggerClientEvent( source, "onClientUpdateCartelVehicles", source, CARTEL_VEHICLES[ cartel_id ] )
end
addEvent( "onPlayerRequestCartelVehicles", true )
addEventHandler( "onPlayerRequestCartelVehicles", root, onPlayerRequestCartelVehicles_handler )

function onCartelVehicleSpawnRequest_handler( list_i, cartel_id )
	local player = client
	
	if player:GetClanCartelID( ) ~= cartel_id then
		player:ShowError( "Этот гараж доступен только членам " .. ( cartel_id == 1 and "Зап. Картеля" or "Вост. Картеля" ) )
		return
	end

	local conf = CARTEL_VEHICLES_LIST[ list_i ]
	if conf.need_rank > player:GetClanRank( ) then
		player:ShowError( "Доступно с " .. conf.need_rank .. " ранга" )
		return
	end

	-- local conf = CARTEL_VEHICLES_LIST[ list_i ]
	-- if conf.need_role > player:GetClanRole( ) then
	-- 	player:ShowError( "Доступно со звания " .. conf.need_rank .. " ранга" )
	-- 	return
	-- end

	if not CARTEL_VEHICLES[ cartel_id ] then
		CARTEL_VEHICLES[ cartel_id ] = { }
	end
	local vehicle = CARTEL_VEHICLES[ cartel_id ][ conf.num ]
	if vehicle then
		local owner = CARTEL_VEHICLES_LIST_REVERSE[ vehicle ].owner
		player:ShowError( "Эту машину уже забрал(а) " .. ( isElement( owner ) and owner:GetNickName( ) or "другой член картеля" ) )
		return
	end

	local old_vehicle = CARTEL_VEHICLES_BY_OWNER[ player ]
	if isElement( CARTEL_VEHICLES_BY_OWNER[ player ] ) then
		old_vehicle:destroy( )
	end

	local random_point
	for i, position in pairs( CARTEL_VEHICLES_PARKING_POSITIONS[ cartel_id ] ) do
		if not isAnythingWithinRange( Vector3( position.x, position.y, position.z ), 3 ) then
			random_point = position
		end
	end

	if random_point then
		local vehicle = CreateCartelVehicle( cartel_id, player, conf, random_point )
		if vehicle then
			setTimer( function( player, vehicle )
				if not isElement( player ) or not isElement( vehicle ) then return end
				warpPedIntoVehicle( player, vehicle )
				setCameraTarget( player, player )
			end, 250, 1, player, vehicle )
		else
			player:ShowError( "Ошибка создания транспорта" )
		end
	else
		player:ShowError( "Все места на парковке заняты. Освободите территорию чтобы получить транспорт" )
	end
end
addEvent( "onCartelVehicleSpawnRequest", true )
addEventHandler( "onCartelVehicleSpawnRequest", root, onCartelVehicleSpawnRequest_handler )

function CreateCartelVehicle( cartel_id, player, conf, position )
	local conf = table.copy( conf )
	local vehicle = Vehicle.CreateTemporary( conf.model, position.x, position.y, position.z, 0, 0, position.rz or 0 )
	if vehicle then
		vehicle:SetNumberPlate( "5:к" .. cartel_id .. "0" .. conf.num .. "кк99" )
		vehicle:SetColor( 0, 0, 0 )
		vehicle:SetFuel( "full" )

		vehicle:SetWindowsColor( 0, 0, 0, 255 )

		conf.cartel_id = cartel_id
		conf.element = vehicle
		conf.owner = player
		CARTEL_VEHICLES_LIST_REVERSE[ vehicle ] = conf
		CARTEL_VEHICLES_BY_OWNER[ player ] = vehicle
		CARTEL_VEHICLES[ cartel_id ][ conf.num ] = vehicle

		local vehicle_exit_timer = false

		local function destroyThisVehicle( )
			CARTEL_VEHICLES_BY_OWNER[ player ] = nil
			if isElement( vehicle ) then vehicle:destroy( ) end
		end
		addEventHandler( "onPlayerQuit" , player, destroyThisVehicle )

		local function onVehicleDestroy( )
			CARTEL_VEHICLES[ cartel_id ][ conf.num ] = nil
			CARTEL_VEHICLES_LIST_REVERSE[ vehicle ] = nil
			if CARTEL_VEHICLES_BY_OWNER[ player ] then
				CARTEL_VEHICLES_BY_OWNER[ player ] = nil
				removeEventHandler( "onPlayerQuit" , player, destroyThisVehicle )
			end
			if isTimer( vehicle_exit_timer ) then killTimer( vehicle_exit_timer ) end
		end
		addEventHandler( "onElementDestroy" , vehicle, onVehicleDestroy )

		local function onVehicleEnter( player, seat )
			if seat ~= 0 then return end
			if isTimer( vehicle_exit_timer ) then killTimer( vehicle_exit_timer ) end
		end
		addEventHandler( "onVehicleEnter", vehicle, onVehicleEnter )

		local function onVehicleStartEnter( player, seat )
			if seat ~= 0 then return end

			if player:GetClanCartelID( ) ~= conf.cartel_id then
				player:ShowError( "Данный транспорт принадлежит " .. ( conf.cartel_id == 1 and "Зап. Картелю" or "Вост. Картелю" ) )
				cancelEvent( )
			elseif player:GetClanRank( ) < conf.need_rank then
				player:ShowError( "Ваш клановый ранг слишком низкий для этого транспорта" )
				cancelEvent( )
			end
		end
		addEventHandler( "onVehicleStartEnter", vehicle, onVehicleStartEnter )

		local function onVehicleExit( player, seat )
			if seat ~= 0 then return end

			vehicle_exit_timer = Timer( function( player, vehicle )
				if isElement( vehicle ) then vehicle:destroy( ) end
				if isElement( player ) then player:ShowError( "Ваш транспорт был возвращен в гараж картеля" ) end
			end, 30 * 60 * 1000, 1, player, vehicle )

			player:ShowInfo( "Транспорт будет возвращен в гараж картеля через 30 минут" )
		end
		addEventHandler( "onVehicleExit", vehicle, onVehicleExit )

		return vehicle
	end
end

function DestroyVehiclesOnStop( )
	for vehicle, data in pairs( CARTEL_VEHICLES_LIST_REVERSE ) do
		if isElement( vehicle ) then
			vehicle:DestroyTemporary( )
		end
	end
end
addEventHandler( "onResourceStop", resourceRoot, DestroyVehiclesOnStop )

function GetVehicleOwner( vehicle )
	if CARTEL_VEHICLES_LIST_REVERSE[ vehicle ] then
		return CARTEL_VEHICLES_LIST_REVERSE[ vehicle ].owner
	end
	return false
end