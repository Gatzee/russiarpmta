
Vehicle.getExternalElementsCost = function( self )
	local externalElementsCost = 0
	local variant = self:GetVariant()
	local vehicleCost    = self:GetPrice( variant )
	local vehicleTier    = self:GetTier()

	--Цена за подвеску
	if self:GetHydraulics() then
		externalElementsCost = externalElementsCost + math.floor( vehicleCost * TUNING_PARAMS[TUNING_TASK_HYDRAULICS][vehicleTier] )
	else
		local heightLevel = self:GetHeightLevel() 
		if heightLevel > 0 then
			externalElementsCost = externalElementsCost + math.floor(vehicleCost * TUNING_PARAMS[TUNING_TASK_SUSPENSION][heightLevel][vehicleTier])
		end
	end
	
	--Цена за колёса
	local vehicleWheels = self:GetWheels()
	if vehicleWheels then
		for k, v in ipairs( TUNING_PARAMS[TUNING_TASK_WHEELS] ) do
			if vehicleWheels == v.Level then
				externalElementsCost = externalElementsCost + v.Price
				break
			end
		end
	end
	
	--Цена за изменение колёс
	local front_width, rear_width = self:GetWheelsWidth( )
	local front_camber, rear_camber = self:GetWheelsCamber( )
	local front_offset, rear_offset = self:GetWheelsOffset( )
	if front_width + rear_width + front_camber + rear_camber + front_offset + rear_offset > 0 then
		externalElementsCost = externalElementsCost + TUNING_PARAMS[TUNING_TASK_WHEELS_EDIT][vehicleTier]
	end
	
	--Цена за уровень тонировки
	local toningLevel = self:GetWindowsColor( )
	for k, v in pairs( TUNING_PARAMS[ TUNING_TASK_TONING ] ) do
		local price = v[ "Price" ][ vehicleTier ]

		if v.Level == toningLevel[4] and price then
			externalElementsCost = externalElementsCost + math.floor( vehicleCost * price )
			break
		end
	end
	
	--Цена за внешние модификации
	--vehiclePart - тип модификации, vehiclePartLevel - уровень модификации
	local externalParts = self:GetExternalTuning()
	for vehiclePart, vehicleLevelPart in pairs(externalParts) do
		externalElementsCost = externalElementsCost + VEHICLE_CONFIG[self:getModel()]["custom_tuning"][TUNING_IDS_REVERSE[vehiclePart]][vehicleLevelPart].cost
	end

	return externalElementsCost
end

Vehicle.GetVinylCost = function( self )
	local vinyl_cost = 0
	local vinyls = self:GetVinyls()
	for k, v in pairs( vinyls ) do
		if v[ P_PRICE_TYPE ] == "soft" and v[ P_PRICE ] then
			vinyl_cost = vinyl_cost + v[ P_PRICE ]
		elseif v[ P_PRICE_TYPE ] == "hard" and v[ P_PRICE ] then
			vinyl_cost = vinyl_cost + v[ P_PRICE ] * 1000
		end
	end
	return vinyl_cost
end

-- Вычисление полной, минимальной и рекомендуемой стоимости
Vehicle.GetTradeData = function( self )
	local model = self.model
	local conf = VEHICLE_CONFIG[ model ]
	if not conf then return end

	local variant = self:GetVariant( )
	local parts = self:GetParts( )
	local externalElementsCost = self:getExternalElementsCost()
	local numberCost = exports.nrp_vehicle_numberplates:GetVehicleNumberCost( self )
	local vinylCost = self:GetVinylCost( )
	local inventory_expand = self:GetPermanentData( "inventory_expand" ) or 0
	local inventory_max_weight = VEHICLES_MAX_WEIGHTS[ model ] and ( VEHICLES_MAX_WEIGHTS[ model ] + inventory_expand )

	local conf_variant = conf.variants[ variant ]

	local cost = {}
	cost.default = conf_variant.cost 
	cost.max = cost.default + externalElementsCost

	if inventory_expand > 0 then
		local expand_cost = SHOP_SERVICES.inventory_vehicle.cost * inventory_expand / SHOP_SERVICES.inventory_vehicle.value
		cost.max = cost.max + expand_cost * 1000
	end

	for _, data in pairs( parts or { } ) do
		local id = data.id
		local part = getTuningPartByID( id, self:GetTier( ) )

		if part.price and ( data.damaged or 0 ) <= 0 then
			cost.max = cost.max + part.price
		end
	end

	local state = self:GetProperty( "statusNumber" ) or 1
	local stateCoeff = state > STATUS_TYPE_NORM and 0.7 or 1

	cost.min = math.floor( cost.max  * 0.5 * stateCoeff )
	cost.recommended = math.floor( cost.min + ( cost.max - cost.min ) * 0.5 )
	cost.max = cost.max + ( numberCost or 0 )
	cost.max = cost.max + ( vinylCost or 0 )

	return {
		cost = cost,
		variant = variant,
		parts = parts,
		externalElementsCost = externalElementsCost,
		numberCost = numberCost,
		vinylCost = vinylCost,
		inventory_max_weight = inventory_max_weight,
		is_inventory_empty = not next( self:GetPermanentData( "inventory_data" ) or {} ),
		mileage = self:GetMileage() or 0,
	}
end

function onResourceStart()
	loadstring(exports.interfacer:extend("Interfacer"))()
	Extend("ShUtils")
	Extend("Globals")
	Extend("SPlayer")
	Extend("SInterior")
	Extend("SBusiness")
	Extend("SVehicle")
	Extend("ShVehicleConfig")
	Extend("ShInventoryConfig")

	for i, data in pairs( BUSINESS_ELEMENTS ) do
		if data.business_id == 8 then
			marker_create( data )
		end
	end
end
addEventHandler("onResourceStart",resourceRoot,onResourceStart)

function marker_create( config )
	config.accepted_elements = { vehicle = true }
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"
	config.radius = 2
	config.y = config.y+860
	config.marker_image = "img/green.png"
	config.marker_text = "Продажа транспорта"
	
	if config.create_blip then
		config.blip = createBlip( config.x, config.y, config.z, 0, 2, 255, 255, 255, 255, 0, 150 )
		setElementData( config.blip, 'extra_blip', 83 )
	end

	local boutique = TeleportPoint(config)
	boutique.element:setData( "material", true, false )
    boutique:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.5 } )
	boutique.element:setData( "ignore_dist", true )
	boutique.marker:setColor( 0, 255, 0, 40 )
	
	boutique.PostJoin = onTradeMarkerHit
	boutique.PostLeave = onTradeMarkerLeave
end

function onTradeMarkerHit( marker, player )
	local veh = getPedOccupiedVehicle( player )
	if not veh or veh:GetSpecialType() or player ~= veh.controller then return end
	
	local veh_tier = veh:GetTier()
	if not CAR_TRADE_CLASSES[ marker.carsale_id ][ veh_tier ] then
		return player:ShowWarning( "Данный транспорт можно продать на рынке " .. getCarTradeNameByVehicleClass( veh_tier ) )
	end
	
	local pBlockedUsers = GetTradeBlockedUsers()
	if pBlockedUsers[ player:GetClientID() ] then
		return player:ShowError( "Вам ограничили возможность продажи транспорта" )
	end

	if veh:IsBroken() then
		return player:ShowWarning( "Вы не можете продавать разбитый транспорт" )
	end

	if veh:GetID() <= 0 then
		return player:ShowWarning( "Вы не можете продавать временный транспорт" )
	end

	if player:GetLevel() < 5 then
		return player:ShowError( "Торговать на Б/У можно только с 5-го уровня" );
	end

	if tonumber( veh:GetOwnerID() ) ~= player:GetUserID() then
		return player:ShowWarning( "Вы не владелец этого транспорта")
	end

	local access_level = player:GetAccessLevel( )
	if access_level > 0 and access_level < ACCESS_LEVEL_DEVELOPER then
		return player:ShowWarning( "Продажа транспорта запрещена" )
	end

	local vehicle_data = VEHICLE_CONFIG[ veh.model ]
	if not vehicle_data then
		player:ShowError( "Данный транспорт невозможно продать" )
		return
	end

	local variant_data = vehicle_data.variants[ ( veh:GetVariant() or 1 ) ]
	if not variant_data then
		player:ShowError( "Транспорт данной комплектации невозможно продать" )
		return
	end

	local temp_timeout = veh:GetPermanentData( "temp_timeout" ) or 0
	local is_untradable = not variant_data.level or variant_data.untradable or veh:GetPermanentData( "untradable" ) or temp_timeout > 0
	if is_untradable then
		return player:ShowInfo( "Этот транспорт нельзя продать" );
	end

--	if veh:HasBlackTuning() then
--		return ply:ShowError( "Нельзя продать транспорт в таком виде, сначала сними весь чёрный тюнинг" );
--	end

	if not getVehicleOccupant( veh, 1 ) then
		return player:ShowInfo( "Покупатель должен сидеть на пассажирском кресле" )
	end

	if player:GetJobClass( ) == JOB_CLASS_TAXI_PRIVATE and player:GetOnShift( ) then
		player:ShowError( "Закончи смену в такси чтобы продать транспорт" )
		return
	end

	if player:getData( "transfer" ) then
		player:ShowError( "Нельзя продать транспорт во время переноса аккаунта" )
		return
	end

	local bTradable, iTimeLeft = veh:IsTradeAvailable()
	--[[if not bTradable then
		return player:ShowWarning( "Этот транспорт можно будет продать через ".. math.floor( iTimeLeft / 3600 ).."ч" )
	end]]

	player:setData( "car_market", marker.carsale_id, false )

	triggerClientEvent( player, "CarTradeUIState", resourceRoot, true, veh, 1, veh:GetTradeData() )
end

function onTradeMarkerLeave( marker, player )
	player:setData( "car_market", false, false )
	triggerClientEvent( player, "CarTradeUIState", resourceRoot, false )
end

-- Отправляем потенциальному покупателю предложение покупки
function sendCarSellRequest( veh, cost )
	if not isElement( veh ) or not isElement( source ) then return end

	cost = math.abs( math.floor( tonumber( cost ) or 0 ) )
	if cost <= 0 then return end

	local veh_tier = veh:GetTier()
	local car_market = source:getData( "car_market" )
	if not car_market or not CAR_TRADE_CLASSES[ car_market ][ veh_tier ] then
		return source:ShowWarning( "Данный транспорт можно продать на рынке " .. getCarTradeNameByVehicleClass( veh_tier ) )
	end

	if veh:IsBroken() then
		return source:ShowWarning( "Вы не можете продавать разбитый транспорт" )
	end

	if veh:GetID() <= 0 then
		return source:ShowWarning( "Вы не можете продавать временный транспорт" )
	end

	if source:GetLevel() < 5 then
		return source:ShowError( "Торговать на Б/У можно только с 5-го уровня" );
	end

	if tonumber( veh:GetOwnerID() ) ~= tonumber( source:GetUserID() ) then
		return source:ShowWarning( "Вы не владелец транспорта" )
	end

	local trade_data = veh:GetTradeData()
	if not trade_data then
		return source:ShowError( "Неизвестная ошибка" )
	end

	if cost < trade_data.cost.min then
		return source:ShowInfo( "Цена ниже минимальной" )
	end

	if cost > trade_data.cost.max then
		return source:ShowInfo( "Цена выше максимальной" )
	end

	local buyer = getVehicleOccupant( veh, 1 )
	if not buyer then
		return source:ShowInfo( "Покупатель должен сидеть на пассажирском кресле" )
	end

	if buyer:GetLevel() < 5 then
		source:ShowError( "У покупателя уровень меньше 5-го" );
		return buyer:ShowError( "Торговать на Б/У можно только с 5-го уровня" );
	end

	local vehicle_data = VEHICLE_CONFIG[ veh.model ]
	if not vehicle_data then
		source:ShowError( "Данный транспорт невозможно продать" )
		return
	end

	local variant_data = vehicle_data.variants[ ( veh:GetVariant() or 1 ) ]
	if not variant_data then
		source:ShowError( "Транспорт данной комплектации невозможно продать" )
		return
	end

	if variant_data.level and variant_data.level > buyer:GetLevel() then
		source:ShowError( "У покупателя слишком низкий уровень для покупки этого транспорта" )
		return
	end

	if not vehicle_data.is_moto and not buyer:HasFreeVehicleSlot( ) then
		source:ShowError( "У покупателя нет свободных слотов под транспорт" )
		buyer:ShowError( "У вас нет свободных слотов под новый транспорт" )
		return
	end

	-- У обоих игроков должны быть выполнены условия анлока
	if vehicle_data.blocked then
		local seller_unlock = vehicle_data.blocked.fServerCheck( source )
		local buyer_unlock = vehicle_data.blocked.fServerCheck( buyer )
		
		if not seller_unlock or not buyer_unlock then
			source:ShowError( "Особые условия: " .. vehicle_data.blocked.sReason )
			return
		end
	end

	if vehicle_data.premium then
		if not source:IsPremiumActive( ) then
			source:ShowError( "Продажа доступна с премиумом" )
			return
		elseif not buyer:IsPremiumActive( ) then
			source:ShowError( "У покупателя отсутствует премиум" )
			return
		end
	end

	if source:getData( "transfer" ) then
		source:ShowError( "Нельзя продать транспорт во время переноса аккаунта" )
		return
	end

	trade_data.seller_cost = cost
	triggerClientEvent( buyer, "CarTradeUIState", resourceRoot, true, veh, 3, trade_data )
end
addEvent( "sendCarSellRequest", true )
addEventHandler( "sendCarSellRequest", root, sendCarSellRequest )

-- Передача транспорта
function onVehicleSellRequestAccepted( veh, cost, reject )
	local buyer = source
	local seller = getVehicleOccupant( veh, 0 )

	cost = math.abs( math.floor( tonumber( cost ) or 0 ) )
	if cost <= 0 then return end

	if not isElement( buyer ) or not isElement( seller ) or not seller:IsInGame() or not isElement( veh ) then return end

	local veh_tier = veh:GetTier()
	local car_market_seller = seller:getData( "car_market" )
	if not car_market_seller or not CAR_TRADE_CLASSES[ car_market_seller ][ veh_tier ] then
		seller:ShowWarning( "Данный транспорт можно продать на рынке " .. getCarTradeNameByVehicleClass( veh_tier ) )
		return 
	end

	if reject then
		seller:ShowInfo( "Покупатель отказался от сделки" )
		buyer:ShowInfo( "Вы отказались от сделки" )
		return false
	end

	-- На всякий случай ещё раз убедимся в том, что продавцу эта машина всё ещё принадлежит
	if tonumber( veh:GetOwnerID() ) ~= tonumber( seller:GetUserID() ) then
		return seller:ShowWarning("Вы не владелец транспорта")
	end

	if seller:getData( "transfer" ) then
		seller:ShowError( "Нельзя продать транспорт во время переноса аккаунта" )
		return
	end
	
	local trade_data = veh:GetTradeData()
	if cost < trade_data.cost.min then
		return source:ShowInfo( "Цена ниже минимальной" )
	end

	if cost > trade_data.cost.max then
		return source:ShowInfo( "Цена выше максимальной" )
	end

	if buyer:GetMoney() < cost then
		seller:ShowInfo( "У покупателя недостаточно денег" )
		buyer:ShowInfo( "У вас недостаточно денег!" )
		return
	end

	-- Все условия соблюдены, осуществляем продажу
	local model = veh.model
	buyer:TakeMoney( cost, "car_trade_purchase", model )
	seller:GiveMoney( math.floor( cost * 0.93 ), "car_trade_sell", model )

	buyer:ShowInfo( "Вы успешно приобрели транспорт" )
	seller:ShowInfo( "Вы успешно продали свой транспорт" )

	removePedFromVehicle( seller )

	warpPedIntoVehicle( buyer, veh, 0 )
	warpPedIntoVehicle( seller, veh, 1 )

	veh:SetOwnerPID( "p:"..buyer:GetUserID() )
	veh:SetPermanentData( "last_trade_cost", cost )
	veh:SetPermanentData( "last_trade_date", getRealTimestamp( ) )

	seller:RemoveVehicleFromList( veh )
	seller:InventoryRemoveItem( IN_VEHICLE_PASSPORT )

	buyer:ParkedVehicles()
	buyer:AddVehicleToList( veh )			
	triggerEvent( "CheckPlayerVehiclesSlots", seller )
	
	if veh:HasBlackTuning( ) then
		veh:ResetBlackTuning( )
	end

	exports.nrp_inventory:Inventory_Clear( veh )

	-- Самоизнос деталей при продаже машины
	local parts = veh:GetParts( )
	local usable_parts = { }
	for _, data in pairs( parts ) do
		if ( data.damaged or 0 ) <= 0 then
			table.insert( usable_parts, data )
		end
	end

	-- Подсчёт деталей на износ
	local unusable_required_parts = math.ceil( #usable_parts * 0.6 )
	if #usable_parts > 0 and unusable_required_parts > 0 then
		local i = 0
		repeat i = i + 1
			local part_pos = math.random( 1, #usable_parts )
			local part = usable_parts[ part_pos ]
			
			veh:SetDamagePart( part.id, true )
			
			table.remove( usable_parts, 1 )
		until i >= unusable_required_parts
	end

	veh:ParseHandling( )

	-- Забираем мопед, если есть
	local player_vehicles = buyer:GetVehicles( false, true )
	for _, vehicle in pairs( player_vehicles ) do
		if vehicle.model == 468 then
			exports.nrp_vehicle:DestroyForever( vehicle:GetID( ) )
			break
		end
	end

	triggerEvent( "SaveVehicle", veh )
	triggerEvent( "RefreshVehiclePassport", buyer, veh, 0 )
	
	
	-- Analytics
	triggerEvent( "onVehicleCarTradeSell", seller, buyer, veh, cost, car_market_seller )

	-- Ahievements
	if VEHICLE_CONFIG[ model ].is_moto then
		triggerEvent( "onPlayerSomeDo", buyer, "add_moto" ) 
	elseif not VEHICLE_CONFIG[ model ].is_boat and not VEHICLE_CONFIG[ model ].is_airplane then
		triggerEvent( "onPlayerSomeDo", buyer, "add_car" )
	end
	triggerEvent( "onPlayerSomeDo", buyer, "buy_used_vehicle" )

	-- Logs
	local veh_id = veh:GetID()
	WriteLog( "money/special", "[Car:Продажа] %s продал транспорт (VEH:%s) за %s игроку %s", seller, veh_id, cost, buyer )
	WriteLog( "money/special", "[Car:Покупка] %s приобрёл транспорт (VEH:%s) за %s у %s", buyer, veh_id, cost, seller )
end
addEvent( "onVehicleSellRequestAccepted", true )
addEventHandler( "onVehicleSellRequestAccepted", root, onVehicleSellRequestAccepted )

function GetTradeBlockedUsers()
	local pUsers = MariaGet( "trade_blocked" )
	return pUsers and fromJSON( pUsers ) or {}
end