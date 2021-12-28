
ORDER_POINTS_BUSY = { }

function GenerateEvacuatedVehicleData( lobby_id )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end
	
	local vehicle_data

	local vehicle, evacuated_zone = next( REAL_VEHICLES )
	if isElement( vehicle ) and isElement( evacuated_zone ) then
		vehicle_data = vehicle
		
		lobby_data.real_vehicle_element = vehicle_data
		RemoveRealVehicle( vehicle_data )
	else
		vehicle_data = GenerateVehicleData( lobby_data )
	end

	lobby_data.evacuated_vehicle_pos = { x = vehicle_data.position.x, y = vehicle_data.position.y, z = vehicle_data.position.z }
	lobby_data.evacuated_vehicle_rot = { x = vehicle_data.rotation.x, y = vehicle_data.rotation.y, z = vehicle_data.rotation.z }
end

function CreateEvacuatedVehicle( lobby_id, hide_notification )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	if isElement( lobby_data.real_vehicle_element ) then
		lobby_data.vehicle_model = getElementModel( lobby_data.real_vehicle_element )

		lobby_data.evacuated_vehicle = lobby_data.real_vehicle_element

		lobby_data.evacuated_vehicle:setData( "work_lobby_id", lobby_data.lobby_id, false )
		lobby_data.evacuated_vehicle:setData( "tow_evac_added", true, false )
		
		removeEventHandler( "onElementDestroy", lobby_data.evacuated_vehicle, onRealVehicleDestroy )
		addEventHandler( "onElementDestroy", lobby_data.evacuated_vehicle, onRealVehicleDestroy )

		lobby_data.evac_type = "police"		
	else
		lobby_data.vehicle_model = lobby_data.vehicle_model or PICKUP_VEHICLES[ math.random( 1, #PICKUP_VEHICLES ) ]
		CreateTempEvacuatedVehicle( lobby_data, "dummy" )

		lobby_data.evac_type = "automatic"
	end

	if lobby_data.evacuated_vehicle then
		CreateOrderVehicleShapeZone( lobby_data )
		
		if not hide_notification then 
			SendPhoneVehicleInfo( lobby_data )
		end
	end
end

function ReplaceRealVehicle( lobby_data, set_parked )
	local r, g, b = getVehicleColor( lobby_data.evacuated_vehicle, true )
	local vinyls = getElementData( lobby_data.evacuated_vehicle, "vehicle_vinyl_data" )
	local number_plate = lobby_data.evacuated_vehicle:GetNumberPlate()
		
	removeEventHandler( "onElementDestroy", lobby_data.evacuated_vehicle, onRealVehicleDestroy )
	lobby_data.evacuated_vehicle:setData( "tow_evac_added", nil, false )
	lobby_data.evacuated_vehicle:setData( "work_lobby_id", nil, false )
	lobby_data.real_vehicle_element = nil

	if set_parked then lobby_data.evacuated_vehicle:SetParked( true ) end
	
	CreateTempEvacuatedVehicle( lobby_data, "replace" )

	if lobby_data.evacuated_vehicle then
		lobby_data.evacuated_vehicle:SetNumberPlate( number_plate )
		setVehicleColor( lobby_data.evacuated_vehicle, r, g, b )
		if vinyls then setElementData( lobby_data.evacuated_vehicle, "vehicle_vinyl_data", vinyls ) end
	end
end

function CreateTempEvacuatedVehicle( lobby_data, reason )
	if not lobby_data.evacuated_vehicle_pos then
		WriteLog( "failed_evac_evehicle", "lobby: %s, reason: %s, poisition: %s, rotation: %s", tostring( lobby_data.lobby_id ), tostring( reason ), tostring( lobby_data.evacuated_vehicle_pos ), tostring( lobby_data.evacuated_vehicle_rot ) )
	end

	lobby_data.evacuated_vehicle = CreateTemporaryQuestVehicle( lobby_data.lobby_id, lobby_data.vehicle_model, lobby_data.evacuated_vehicle_pos, lobby_data.evacuated_vehicle_rot )
	addEventHandler( "onVehicleStartEnter", lobby_data.evacuated_vehicle, function() cancelEvent() end ) 

	if lobby_data.evacuated_vehicle then
		lobby_data.evacuated_vehicle:setData( "block_interaction", true )
		lobby_data.evacuated_vehicle:setLocked( true )
	end
end

function SendPhoneVehicleInfo( lobby_data, vehicle_model )
	local order_num = lobby_data.evacuated_vehicle:GetNumberPlate( false, true )
	local real_num = order_num == "" and "Нет" or split( order_num, ":" )

	if type( real_num ) == "table" then
		real_num = real_num[ #real_num ]
	end

	local pNotification =
	{
		title = "Уведомления Эвакуаторщик",
		msg   = "Заказ на эвакуацию транспорта:\nМодель: " .. VEHICLE_CONFIG[ lobby_data.vehicle_model ].model .. "\nНомер: " .. real_num,
	}

	for k, v in pairs( lobby_data.participants ) do
		v.player:PhoneNotification( pNotification )
	end
end

function DestroyVehicleData( lobby_id, finish_state )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	if isElement( lobby_data.evacuated_vehicle ) then
		local is_real_tow_evac_added = lobby_data.evacuated_vehicle:getData( "tow_evac_added")
		if is_real_tow_evac_added then
			removeEventHandler( "onElementDestroy", lobby_data.evacuated_vehicle, onRealVehicleDestroy )
			lobby_data.evacuated_vehicle:setData( "work_lobby_id", nil, false )
			lobby_data.evacuated_vehicle:setData( "tow_evac_added", nil, false )

			AddRealVehicle( lobby_data.evacuated_vehicle )
		else
			Vehicle.DestroyTemporary( lobby_data.evacuated_vehicle )
		end
	end
	
	lobby_data.evacuated_vehicle = nil
	lobby_data.real_vehicle_element = nil
	lobby_data.vehicle_model = nil

	RemoveOrderVehicleShapeZone( lobby_data )
end

function CreateOrderVehicleShapeZone( lobby_data )
	RemoveOrderVehicleShapeZone( lobby_data )
	lobby_data.evacuated_zone = createColSphere( lobby_data.evacuated_vehicle.position, 15 )
	addEventHandler( "onColShapeLeave", lobby_data.evacuated_zone, OnOrderVehicleShapezoneLeave )
	addEventHandler( "onColShapeHit", lobby_data.evacuated_zone, OnOrderVehicleShapezoneHit )
end

function RemoveOrderVehicleShapeZone( lobby_data )
	if isElement( lobby_data.evacuated_zone ) then
		destroyElement( lobby_data.evacuated_zone )
		lobby_data.evacuated_zone = nil
	end
end

function OnOrderVehicleShapezoneHit( element, dim )
	if not dim or getElementType( element ) ~= "vehicle" then return end
	
	local lobby_id = element:getData( "work_lobby_id" )
	if not lobby_id then return end

	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data or source ~= lobby_data.evacuated_zone or element ~= lobby_data.job_vehicle then return end
	
	
	local is_real_tow_evac_added = lobby_data.evacuated_vehicle:getData( "tow_evac_added")
	if is_real_tow_evac_added then
		ReplaceRealVehicle( lobby_data, true )
	end

	lobby_data.evacuated_vehicle:setFrozen( true )
	
	for k, v in pairs( lobby_data.participants ) do
		local seat = v.player:getOccupiedVehicleSeat( )
		if seat == 0 then
			if #lobby_data.participants == 1 then
				v.player:ShowInfo( "Для управления манипулятором\nпересядьте на пассажирское место" )
			else
				v.player:ShowInfo( "Полностью остановите авто у машины\nваш напарник погрузит её" )
			end
		end
		v.player:ManipulatorControlEnabled( lobby_data, true )
	end
end

function onRealVehicleDestroy()
	local lobby_id = element:getData( "work_lobby_id" )
	if not lobby_id then return end

	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end
	
	local is_real_tow_evac_added = source:getData( "tow_evac_added")
	if is_real_tow_evac_added then
		ReplaceRealVehicle( lobby_data )
	end
end

function OnOrderVehicleShapezoneLeave( element )
	if getElementType( element ) ~= "vehicle" then return end
	
	local lobby_id = element:getData( "work_lobby_id" )
	if not lobby_id then return end

	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data or (getElementType( source ) == "colshape" and source ~= lobby_data.evacuated_zone) then return end

	if element == lobby_data.job_vehicle then
		for k, v in pairs( lobby_data.participants ) do
			v.player:ManipulatorControlEnabled( lobby_data, false )
		end
	elseif element == lobby_data.evacuated_vehicle then
		
		local is_real_tow_evac_added = element:getData( "tow_evac_added")
		if is_real_tow_evac_added then
			ReplaceRealVehicle( lobby_data )
		end
	end
end


function GenerateVehicleData( lobby_data )
	local vehicle_data
	repeat
		local rand_place = math.random( 1, #PICKUP_POINTS[ lobby_data.city ] )
		if not ORDER_POINTS_BUSY[ rand_place ] then
			ORDER_POINTS_BUSY[ rand_place ] = getRealTimestamp()
			vehicle_data = PICKUP_POINTS[ lobby_data.city ][ rand_place ]
		end
	until vehicle_data ~= nil
	return vehicle_data
end

setTimer( function()
	local timestamp = getRealTimestamp()
	for k, v in pairs( ORDER_POINTS_BUSY ) do
		if timestamp - v > 300 then
			ORDER_POINTS_BUSY[ k ] = nil
		end
	end
end, 30 * 1000, 0 )