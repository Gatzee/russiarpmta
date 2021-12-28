Extend( "SVehicle" )
Extend( "SPlayer" )

addEvent( "RequestRepairData", true )
addEventHandler( "RequestRepairData", root, function( )
	local player = client or source

	local vehicle = player.vehicle
	if not vehicle then return end

	if vehicle:GetFaction( ) > 0 then
		vehicle:fix()
		player:ShowSuccess( "Фракционный транспорт отремонтирован" )
		return
	end

	if vehicle:getData( "block_repair" ) then 
		player:ShowError( "Ремонт данного транспорта запрещен" )
		return 
	end

	local status_number = vehicle:GetProperty( "statusNumber" ) or 1
	local capital_repair_count = vehicle:GetPermanentData( "engine_repairs" ) or 0
	local capital_repair_cost = getCapitalRepairCost( vehicle )
	triggerClientEvent( player, "CreateRepairUI", resourceRoot, status_number, capital_repair_count, capital_repair_cost )
end )

addEvent( "RequestRepair", true )
addEventHandler( "RequestRepair", root, function( )
	local player = client or source

	local vehicle = player.vehicle
	if not vehicle then return end

	local repair_price = GetRepairPrice( vehicle )
	local repair_cost = GetEngineRepairCost( vehicle, repair_price ) + GetWheelsRepairCost( vehicle, repair_price )
	if repair_cost > 0 then
		if player:TakeMoney( repair_cost, "vehicle_repair" ) then
			vehicle:fix( )

			triggerEvent( "onPlayerSomeDo", player, "repair_car" ) -- achievements
			triggerEvent( "onPlayerRepairVehicle", player, repair_cost, vehicle.model ) -- analytics
		else
			player:EnoughMoneyOffer( "Vehicle repair", repair_cost, "RequestRepair", source )
		end
	end
end )

addEvent( "RequestCapitalRepair", true )
addEventHandler( "RequestCapitalRepair", root, function( )
	local player = client or source

	local vehicle = player.vehicle
	if not vehicle then return end

	if vehicle:GetOwnerID() ~= client:GetUserID() then
		client:ShowError( "Капитальный ремонт может произвести только основной владелец!" )
		return
	end

	local repair_cost = getCapitalRepairCost( vehicle )
	if repair_cost <= 0 then
		return
	end

	if not player:TakeMoney( repair_cost, "capital_vehicle_repair" ) then
		player:EnoughMoneyOffer( "Vehicle capital repair", repair_cost, "RequestCapitalRepair", source )
		return
	end

	local oldMileage = vehicle:GetMileage( )
	local carClass = vehicle:GetTier( )
	-- local tuningDetails = exports.nrp_vehicle_conditions:GetVehicleTuningLevels( vehicle )
	local neededMileage = STATUSES_DATA.mileage[ carClass ][ 1 ] -- * TUNING_EFFECT_WEAR.status[ tuningDetails ]
	local vehicle_id = vehicle:GetID( )

	vehicle:SetMileage( neededMileage )
	vehicle:SetProperty( "statusNumber", STATUS_TYPE_NORM )

	triggerEvent( "onPlayerSomeDo", player, "capital_repair_car" ) -- achievements

	local totalRepairs = vehicle:GetPermanentData( "engine_repairs" ) or 0

	vehicle:SetPermanentData( "engine_repairs", totalRepairs + 1 )

	WriteLog( "money/special", "Покупка: %s восстановил автомобиль %s на сумму %s", client, vehicle_id, repair_cost )

	triggerEvent( "OnRequestVehicleProperties", client, vehicle )
	triggerEvent( "onVehicleCapitalRepair", vehicle, client, oldMileage, capitalRepairCost )
	triggerEvent( "onVehicleChangeStatus", vehicle, STATUS_TYPE_NORM )
end )

function getCapitalRepairCost( vehicle )
	local currentStatus = vehicle:GetProperty( "statusNumber" )
	local capitalRepairCost = 0

	if currentStatus and currentStatus > STATUS_TYPE_NORM then
		local vehClass = vehicle:GetTier()
		capitalRepairCost = STATUSES_DATA.capitalRepairCost[ vehClass ][ currentStatus - 2 ]
		capitalRepairCost = capitalRepairCost * vehicle:GetPrice()
		capitalRepairCost = math.max( STATUSES_DATA.capitalRepairMin[ vehClass ], capitalRepairCost )
		capitalRepairCost = math.min( STATUSES_DATA.capitalRepairMax[ vehClass ], capitalRepairCost )
	end

	return capitalRepairCost
end