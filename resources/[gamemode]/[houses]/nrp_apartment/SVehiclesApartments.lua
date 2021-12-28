function PlayerReadyToPlay( )
	CheckPlayerVehiclesSlots( source )
end
addEvent( "onPlayerVehiclesLoad", true )
addEventHandler( "onPlayerVehiclesLoad", root, PlayerReadyToPlay )
addEvent( "CheckPlayerVehiclesSlots" )
addEventHandler( "CheckPlayerVehiclesSlots", root, PlayerReadyToPlay )

function GetPlayerHaveVehiclesSlots( player )
	local bought_slots = player:GetPermanentData( "car_slots" )

	-- Поддержка випдомов
	local viphouse_total_car_slot = exports.nrp_vip_house:GetPlayerAllVipHouseCarSlotInfo( player )

	-- Поддержка обычных квартир
	local apartment_total_car_slot = GetPlayerAllApartmentCarSlotInfo( player )

	local have_slot_count = viphouse_total_car_slot + apartment_total_car_slot + bought_slots + 1

	return have_slot_count, bought_slots
end

function CheckPlayerVehiclesSlots( source )
	local have_slots, bought_slots = GetPlayerHaveVehiclesSlots( source )
	local list = source:GetVehicles( )
	local veh_count = 0
	local vehicle_list = {}
	local blocked_count = 0
	
	for i, vehicle in ipairs( list ) do
		veh_count = veh_count + 1
		if vehicle:GetBlocked( ) then
			blocked_count = blocked_count + 1
		end
		
		table.insert( vehicle_list, {
			name = VEHICLE_CONFIG[vehicle.model] and VEHICLE_CONFIG[vehicle.model].model or ( "No name. ID:".. vehicle.model );
			confiscated = vehicle:IsConfiscated( );
			numberplate = vehicle:GetNumberPlateHR( );
		} )
	end

	if ( veh_count - blocked_count ) > have_slots then
		source:triggerEvent( "ShowUIGarage", resourceRoot, 0, have_slots, bought_slots, vehicle_list, true )
		return false
	
	elseif blocked_count > 0 then
		if veh_count <= have_slots then
			for i, vehicle in ipairs( list ) do
				vehicle:SetBlocked( false )
			end
		elseif ( veh_count - blocked_count ) < have_slots then
			source:triggerEvent( "ShowUIGarage", resourceRoot, 0, have_slots, bought_slots, vehicle_list, true )
			return false
		end
	end

	return true
end

function HasPlayerAnyDebtForApartment( player, id )
	local user_id = player:GetUserID( )
	local apartments = player:getData( "apartments" ) or {}
	for i, apart in ipairs( apartments ) do
		if apart.id == id then
			local info = APARTMENTS_LIST_OWNERS[ id ][ apart.number ]
			if info and info.user_id == user_id and info.paid_days < 0 then
				return true
			end
		end
	end

	return false
end

function PlayerWantShowGarage( id )
	if not isElement( client ) then return end

	if not WEDDING_USE_BOTH_GARAGE then
		if not HasPlayer_AnyApartmentWithId_EqualTo( client, id ) then
			return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
		end
	else
		if not CheckPlayerWeddingAtApartOwner( client, id ) then
			return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
		end
	end

	if not CheckPlayerWeddingAtApartOwner( client, id ) then
		return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
	end

	if HasPlayerAnyDebtForApartment( client, id ) then
		return client:ShowError( "Оплати долг за квартиру!" )
	end

	local info = APARTMENTS_LIST[ id ]

	local have_slots, bought_slots = GetPlayerHaveVehiclesSlots( client )

	local vehicle_list = {}
	local list = client:GetVehicles( true )
	for i, vehicle in ipairs( list ) do
		local price = 3000
		if (info.vehicle_position - vehicle.position).length < 10 then
			price = 500
		end

		table.insert( vehicle_list, {
			name = VEHICLE_CONFIG[ vehicle.model ] and VEHICLE_CONFIG[ vehicle.model ].model or ( "No name. ID:".. vehicle.model );
			parked = vehicle:GetParked();
			confiscated = vehicle:IsConfiscated();
			price = price;
			numberplate = vehicle:GetNumberPlateHR( );
		} )
	end

	triggerClientEvent( client, "HideUIList", resourceRoot )
	triggerClientEvent( client, "ShowUIGarage", resourceRoot, id, have_slots, bought_slots, vehicle_list )
end
addEvent( "PlayerWantShowGarage", true )
addEventHandler( "PlayerWantShowGarage", resourceRoot, PlayerWantShowGarage )

function PlayerWantParkVehicle( id )
	if not client or not client.vehicle then return end

	local vehicle = client.vehicle

	if vehicle:GetSpecialType( ) then return end

	local info = APARTMENTS_LIST[ id ]
	local have_apartments = false
	local user_id = client:GetUserID( )

	if vehicle:GetOwnerID( ) ~= user_id then
		client:ShowError( "Это не ваш транспорт" )
		return
	end

	if vehicle:GetID( ) < 0 then
		client:ShowError( "Это арендованный транспорт" )
		return
	end

	if vehicle:getData( "tow_evac_added" ) or vehicle:getData( "tow_evacuated_real" ) then
		client:ShowError( "Транспорт ожидает эвакуации!" )
		return
	end

	if not WEDDING_USE_BOTH_GARAGE then
		if not HasPlayer_AnyApartmentWithId_EqualTo( client, id ) then
			return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
		end
	else
		if not CheckPlayerWeddingAtApartOwner( client, id ) then
			return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
		end
	end

	if HasPlayerAnyDebtForApartment( client, id ) then
		return client:ShowError( "Оплати долг за квартиру!" )
	end

	if VEHICLE_CONFIG[ vehicle.model ].is_moto and vehicle.model ~= 468 then
		client:ShowError( "Это не автомобиль" )
		return
	end

	client:ShowSuccess( "Ты успешно припарковал транспорт" )

	vehicle:SetParked( true )
end
addEvent( "PlayerWantParkVehicle", true )
addEventHandler( "PlayerWantParkVehicle", resourceRoot, PlayerWantParkVehicle )

function PlayerWantTakeParkedVehicle( id, index )
	if not client then return end

	id = tonumber( id )
	index = tonumber( index )

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local info = APARTMENTS_LIST[id]

	if not WEDDING_USE_BOTH_GARAGE then
		if not HasPlayer_AnyApartmentWithId_EqualTo( client, id ) then
			return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
		end
	else
		if not CheckPlayerWeddingAtApartOwner( client, id ) then
			return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
		end
	end

	local vehicle = client:GetVehicles( true )[index]
	if not vehicle or not vehicle:GetParked( ) or vehicle:GetBlocked( ) then
		return
	end

	vehicle:SetParked( false, info.vehicle_position, info.vehicle_rotation )
	client:warpIntoVehicle( vehicle )
end
addEvent( "PlayerWantTakeParkedVehicle", true )
addEventHandler( "PlayerWantTakeParkedVehicle", root, PlayerWantTakeParkedVehicle )

function PlayerWantTeleportParkedVehicle( id, index )
	if not client then return end

	id = tonumber( id )
	index = tonumber( index )

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local info = APARTMENTS_LIST[id]

	if not WEDDING_USE_BOTH_GARAGE then
		if not HasPlayer_AnyApartmentWithId_EqualTo( client, id ) then
			 return client:ShowError( "Ты не владеешь квартирой в этом подъезде" )
		end
	else
		if not CheckPlayerWeddingAtApartOwner( client, id ) then
			return client:ShowInfo( "Ты не владеешь квартирой в этом подъезде" )
		end
	end

	local list = client:GetVehicles( true )
	local vehicle = list[index]
	if not vehicle or vehicle:GetParked( ) or vehicle:GetBlocked( ) then
		return
	end

    if not vehicle:GetEvacuationAvailable() then
        client:ShowError( "Нельзя эвакуировать этот автомобиль!" )
        return false
    end

	if vehicle:getData( 'tow_evac_added' ) then
		client:ShowError( "Авто ожидает эвакуации!" )
		return
	end

	local price = 3000
	if ( info.vehicle_position - vehicle.position ).length < 10 then
		price = 500
	end

	if client:TakeMoney( price, "apartments_parking_vehicle_teleport", "flat" ) then
		if vehicle:getHealth( ) <= 350.0 then
			vehicle:setHealth( 350.0 );
		end

		vehicle:SetParked( true )

		client:ShowSuccess( "Ты успешно эвакуировал транспорт на парковку" )
	end

	local have_slots, bought_slots = GetPlayerHaveVehiclesSlots( client )
	local vehicle_list = { }

	for i, vehicle in ipairs( list ) do
		local price = 3000
		if ( info.vehicle_position - vehicle.position ).length < 10 then
			price = 500
		end

		table.insert( vehicle_list, {
			name = VEHICLE_CONFIG[ vehicle.model ] and VEHICLE_CONFIG[ vehicle.model ].model or ( "No name. ID:".. vehicle.model );
			parked = vehicle:GetParked( );
			confiscated = vehicle:IsConfiscated( );
			price = price;
			numberplate = vehicle:GetNumberPlateHR( );
		} )
	end

	client:triggerEvent( "ShowUIGarage", resourceRoot, id, have_slots, bought_slots, vehicle_list )
end
addEvent( "PlayerWantTeleportParkedVehicle", true )
addEventHandler( "PlayerWantTeleportParkedVehicle", root, PlayerWantTeleportParkedVehicle )

function PlayerSelectBlockedVehicles( veh_selected )
	if not client then return end

	local blocked_count = 0
	local have_slots, bought_slots = GetPlayerHaveVehiclesSlots( client )
	
	for i, blocked in ipairs( veh_selected ) do
		if blocked then
			blocked_count = blocked_count + 1
		end
	end

	local cars = client:GetVehicles( )
	local veh_count = #cars

	if ( veh_count ~= #veh_selected ) or ( ( veh_count - blocked_count ) > have_slots ) then
		local vehicle_list = { }

		for i, vehicle in ipairs( cars ) do
			table.insert( vehicle_list, {
				name = VEHICLE_CONFIG[vehicle.model] and VEHICLE_CONFIG[vehicle.model].model or ( "No name. ID:".. vehicle.model );
				confiscated = vehicle:IsConfiscated( );
				numberplate = vehicle:GetNumberPlateHR( );
			} )
		end

		client:triggerEvent( "ShowUIGarage", resourceRoot, 0, have_slots, bought_slots, vehicle_list, true )
		
		return
	end

	for i, vehicle in ipairs( cars ) do
		if veh_selected[i] then
			vehicle:SetBlocked( true )
		else
			vehicle:SetBlocked( false )
			vehicle:SetParked( true )
		end
	end
end
addEvent( "PlayerSelectBlockedVehicles", true )
addEventHandler( "PlayerSelectBlockedVehicles", root, PlayerSelectBlockedVehicles )


function onSubscriptionShowUnlockVehicle_handler( )
	if not client then return end
	if not client:IsPremiumActive( ) then return end
	if not client:IsCanChgSubscriptionUnlockVehicle( ) then
		client:ShowError( "Машину можно выбирать лишь один раз!" )
		return 
	end
	
	local list = client:GetVehicles( )
	local vehicle_list = { }

	local function add_vehicle_to_list( vehicle )
		if vehicle:GetBlocked( ) then return end
		if VEHICLES_NO_NUMBERPLATES[ vehicle.model ] then return end

		table.insert( vehicle_list, {
			id = vehicle:GetID( );
			name = VEHICLE_CONFIG[ vehicle.model ] and VEHICLE_CONFIG[ vehicle.model ].model or ( "No name. ID:".. vehicle.model );
		} )
	end

	for i, vehicle in ipairs( list ) do
		add_vehicle_to_list( vehicle )
	end

	triggerClientEvent( client, "ShowUIUnlockSubVehicle", resourceRoot, vehicle_list )
end
addEvent( "onSubscriptionShowUnlockVehicle", true )
addEventHandler( "onSubscriptionShowUnlockVehicle", root, onSubscriptionShowUnlockVehicle_handler )

function PlayerSelectSubscriptionUnlockVehicle_handler( veh_id )
	if not client then return end
	if not client:IsPremiumActive( ) then return end
	if not client:IsCanChgSubscriptionUnlockVehicle( ) then return end
	
	local list = client:GetVehicles( )

	for i, vehicle in ipairs( list ) do
		if not vehicle:GetBlocked( ) and vehicle:GetID( ) == veh_id then
			client:SetSubscriptionUnlockVehicle( veh_id, true )
			return
		end
	end
end
addEvent( "PlayerSelectSubscriptionUnlockVehicle", true )
addEventHandler( "PlayerSelectSubscriptionUnlockVehicle", root, PlayerSelectSubscriptionUnlockVehicle_handler )