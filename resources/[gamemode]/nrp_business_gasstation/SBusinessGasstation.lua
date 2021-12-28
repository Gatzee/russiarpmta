loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SBusiness" )
FILLING = {}
FILLING_POSES_TO_CHECK = {}
FILLING_TIMERS = {}

addEvent( "onGasstationFillRequest", true )
function onGasstationFillRequest( vehicle, level )
	if vehicle ~= source.vehicle then return end

	local iSpaceLeft = vehicle:GetMaxFuel() - vehicle:GetFuel()

	if iSpaceLeft < level then
		level = iSpaceLeft
	end

	local price = vehicle:GetFuelPrice( level )

	if not source:TakeMoney( price, "gas_station_purchase" ) then
		source:EnoughMoneyOffer( "Gas station fill", price, "onGasstationFillRequest", source, vehicle, level )
		return
	end
	FILLING[vehicle] = { level, source }
	FILLING_POSES_TO_CHECK[vehicle] = vehicle:getPosition()

	triggerEvent( "PlayerAction_VehicleFilling", source, vehicle, level )

	if not VEHICLE_CONFIG[ vehicle.model ].is_electric then
		triggerClientEvent( source, "StartFillingSound", source, { vehicle.position.x, vehicle.position.y, vehicle.position.z } )
	end

	vehicle.engineState = false

	if VEHICLE_CONFIG[ vehicle.model ].is_electric then
		local percent = math.floor( level * vehicle:GetMaxFuel( ) / 100 )
		source:ShowInfo( "Ожидайте зарядки вашего транспорта" )
		WriteLog( "gasstation", "[Зарядка] %s зарядил автомобиль %s на сумму %s (%s процентов)", source, vehicle, price, percent )
		triggerEvent( "onActionLogRequest", source, 17, source, "Зарядка автомобиля (ID:"..vehicle:GetID()..") на сумму "..price )
	else
		source:ShowInfo( "Ожидайте заправки вашего транспорта" )
		WriteLog( "gasstation", "[Заправка] %s заправил автомобиль %s на сумму %s (%s л.)", source, vehicle, price, level )
		triggerEvent( "onActionLogRequest", source, 17, source, "Заправка автомобиля (ID:"..vehicle:GetID()..") на сумму "..price )
		-- Retention task "gas45"
		triggerEvent( "onGasBuy", source, level )
	end

	triggerClientEvent( source, "GasstationShowUI", source, true, { vehicle = vehicle, filling = true } )
	FILLING_TIMERS[vehicle] = setTimer( Gasstation_fillvehicles, 300, 0, vehicle )

	triggerEvent( "onPlayerPurchaseFuelForVehicle", source, vehicle, price, level )
end
addEventHandler("onGasstationFillRequest", root, onGasstationFillRequest)

function onGasstationJerryBuyRequest( oil_count, battery_count )
    local price = ( oil_count + battery_count ) * 2500
	if source:TakeMoney(price, "gas_station_jerry_purchase" ) then
		source:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy_product.wav" )
		source:triggerEvent( "GasstationJerryShowUI", source, nil )

		if oil_count > 0 then
			triggerEvent( "onActionLogRequest", source, 17, source, "Покупка канистры за " .. oil_count * 2500 )
			source:InfoWindow( "Канистра куплена! Нажми Q чтобы использовать" )
			source:InventoryAddItem( IN_CANISTER, nil, oil_count )
			WriteLog( "gasstation", "[Канистра] %s купил канистру %s л. на сумму %s", source, 20, oil_count * 2500 )
		end

		if battery_count > 0 then
			triggerEvent( "onActionLogRequest", source, 17, source, "Покупка батареи за " .. battery_count * 2500 )
			source:InfoWindow( "Батарея куплена! Нажми Q чтобы использовать" )
			source:InventoryAddItem( IN_BATTERY, nil, battery_count )
			WriteLog( "gasstation", "[Батарея] %s купил батарею %s процентов на сумму %s", source, 25, battery_count * 2500 )
		end
	else
		source:ShowError( "Недостаточно средств!" )
	end
end
addEvent( "onGasstationJerryBuyRequest", true )
addEventHandler( "onGasstationJerryBuyRequest", root, onGasstationJerryBuyRequest )

function Gasstation_fillvehicles( vehicle )

	local function stop_fill( vehicle, player, typ )
		if isTimer( FILLING_TIMERS[vehicle] ) then
			killTimer( FILLING_TIMERS[vehicle] )
		end
		FILLING[vehicle] = nil
		FILLING_TIMERS[vehicle] = nil
		FILLING_POSES_TO_CHECK[vehicle] = nil
		if isElement( player ) then
			local is_electric = VEHICLE_CONFIG[ vehicle.model ].is_electric

			if not is_electric then
				triggerClientEvent( player, "StopFillingSound", player )
			end

			if typ == "filled" then
				player:ShowInfo( "Ваш транспорт " .. ( is_electric and "заряжен" or "заправлен" ) )

				if not is_electric and ( VEHICLE_CONFIG[ vehicle.model ].fuel or 100 ) <= vehicle:GetPermanentData( "fuel" ) then
					triggerEvent( "onPlayerSomeDo", player, "fuel_car" ) -- achievements
				end
			elseif typ == "exitzone" then
				player:ShowInfo( "Вы покинули заправку." )
			elseif typ == "engineState" then
				player:ShowInfo( "Нельзя заправлять авто с включённым двигателем." )
			end
		end
	end

	local function is_in_shape( vehicle )
		if not FILLING_POSES_TO_CHECK[vehicle] then return false; end
		local curr_pos = vehicle:getPosition()
		if not curr_pos then return false; end
		if getDistanceBetweenPoints3D( FILLING_POSES_TO_CHECK[vehicle], curr_pos ) < 5 then
			return true
		end
	end
	if not FILLING[vehicle] then
		stop_fill( vehicle )
		return
	end
	local level_left, player = unpack( FILLING[vehicle] )

	if not isElement( vehicle ) then
		stop_fill( vehicle, player )
		return
	end

	if not is_in_shape( vehicle ) then
		stop_fill( vehicle, player, "exitzone" )
		return
	end

	if level_left <= 0 then
		stop_fill( vehicle, player, "filled" )
		return
	end

	if vehicle.engineState then
		stop_fill( vehicle, player, "engineState" )
		return
	end

	local level = CUSTOM_GASOLINE_LEVELS[ vehicle.vehicleType ] or 1
	vehicle:GiveFuel( level )
	FILLING[vehicle][1] = level_left - level

end
