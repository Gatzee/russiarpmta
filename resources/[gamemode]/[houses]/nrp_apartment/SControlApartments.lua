function PlayerWantBuyApartment(id, number)
	local client = client or source
	if not client then return end

	id = tonumber(id)
	number = tonumber(number)

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local info = APARTMENTS_LIST[id]
	local data = APARTMENTS_LIST_OWNERS[ id ][ number ]
	if data and data.user_id ~= 0 then return end

	local cost = APARTMENTS_CLASSES[ info.class ].cost

	local mortage_id = id * 100 + number
	local timestamp = getRealTimestamp( )
	local apartments_offer = client:GetPermanentData( "apartments_offer" ) or 0
	local apart20_offer = ( client:GetPermanentData( "offer_property" ) or { } ).time_to or 0
	local apartments_offer_active = false
	local apart20_offer_active = false

	if apartments_offer > timestamp then
		cost = APARTMENTS_CLASSES[ info.class ].discount_cost or math.floor( cost * 0.8 )
		apartments_offer_active = true
	elseif apart20_offer > timestamp then
		cost = math.floor( cost * 0.8 )
		apart20_offer_active = true
	end

	if not client:TakeMoney( cost, "apartments_purchase", "flat" ) then
		client:EnoughMoneyOffer( "Apartments purchase", cost, "PlayerWantBuyApartment", client, id, number )
		return
	end

	local is_first_owner = not data or (data.owner_change_time or 0) == 0
    local time_since_last_owner = is_first_owner and 0 or ( timestamp - data.owner_change_time )

	local user_id = client:GetUserID()
	local time_to_pay = timestamp + 24 * 60 * 60

	APARTMENTS_LIST_OWNERS[ id ][ number ] = {
		id = id;
		number = number;
		user_id = user_id;
		paid_days = 1;
		time_to_pay = time_to_pay;
		sale_state = 0;
		paid_upgrade = 0;
		owner_change_time = timestamp;
	}

	onApartmentOwnerChange( id, number )
	SaveApartmentData( id, number, not data )

	-- обновляем apartments
	onPlayerCompleteLogin_handler( client )

	client:ShowSuccess( "Поздравляем с покупкой квартиры!" )
	CheckPlayerVehiclesSlots(client)

	triggerEvent( "onPlayerSomeDo", client, "buy_house" ) -- achievements

	if not client:GetBlockInteriorInteraction( ) then
		triggerEvent( "PlayerWantEnterApartment", client, id, number )
	end

	--Обновляем хаты у партнёра ( если замужем/женат )
	triggerEvent( "onWeddingUpdateApartList", client )
	UpdateParkingMarkerWeddingPartner_handler( client )

	triggerEvent( "onPlayerHousePurchase", client, {
		mortage_type = "flat",
		mortage_purchase_type = "gov",
		mortage_group = info.class,
		mortage_id = mortage_id,
		is_first_owner = is_first_owner,
		days_since_last_owner = math.floor( time_since_last_owner / ( 24 * 60 * 60 ) ),
		mortage_cost = cost,
		currency = "soft",
		mortage_daily_service_cost = APARTMENTS_CLASSES[ info.class ].cost_day,
	} )

	if apartments_offer_active then
		triggerEvent( "SDEV2DEV_apartments_offer_purchase", client, "flat", mortage_id, cost, "soft" )
	elseif apart20_offer_active then
		triggerEvent( "onPlayerBoughtPropertyViaOffer", client, mortage_id, info.class, cost )
	end
end
addEvent( "PlayerWantBuyApartment", true )
addEventHandler( "PlayerWantBuyApartment", root, PlayerWantBuyApartment )

function PlayerEnterOnApartmentsControl( id, number )
	if not client then return end

	id = tonumber(id)
	number = tonumber(number)

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local user_id = client:GetUserID()
	if not APARTMENTS_LIST_OWNERS[ id ][ number ] or APARTMENTS_LIST_OWNERS[ id ][ number ].user_id ~= user_id then
		client:ShowInfo("Это не твоя квартира")
		return
	end

	local info = APARTMENTS_LIST_OWNERS[ id ][ number ]
	local class_info = APARTMENTS_CLASSES[ APARTMENTS_LIST[ id ].class ]

	local pay_minus = 0
	for i = 1, info.paid_upgrade do
		pay_minus = pay_minus + class_info.upgrades[ i ].profit
	end

	local metering_factor = REAL_METERING_DEVICE_FACTOR[ info.meter_type or 0 ] or 1
	local cost_day = class_info.cost_day * metering_factor - pay_minus

	client:triggerEvent("ShowUIControl", resourceRoot, {
		is_apartments = true,
		id = id,
		number = number,
		name = "Квартира №"..number,
		days = info.paid_days;
		cost_day = cost_day;
		paid_upgrade = info.paid_upgrade;		
		cost = class_info.cost;
	})
end
addEvent( "PlayerEnterOnApartmentsControl", true )
addEventHandler( "PlayerEnterOnApartmentsControl", resourceRoot, PlayerEnterOnApartmentsControl )

function PlayerWantSellApartment(id, number)
	if not client then return end

	id = tonumber(id)
	number = tonumber(number)

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local user_id = client:GetUserID()
	if not APARTMENTS_LIST_OWNERS[ id ][ number ] or APARTMENTS_LIST_OWNERS[ id ][ number ].user_id ~= user_id then
		client:ShowInfo("Это не твои апартаменты")	
		client:triggerEvent("HideUIControl", resourceRoot)
		return
	end

	local data = APARTMENTS_LIST_OWNERS[ id ][ number ]

    local timestamp = getRealTimestamp()
    local is_first_owner = data.owner_change_time == 0
    local owned_time = is_first_owner and 0 or ( timestamp - data.owner_change_time )

	if not is_first_owner and owned_time < BLOCK_SALE_TIMESTAMP then
		return client:ShowError( "Нельзя перепродать дом в течении 3-х дней после покупки!" )
	end

	local class = APARTMENTS_LIST[ id ].class
	local price = math.floor(APARTMENTS_CLASSES[ class ].cost * 0.5)
	client:GiveMoney(price, "apartments_gov_sell", "flat") 

	data.user_id = 0
	data.time_to_pay = 0
	data.paid_days = 1
	data.paid_upgrade = 0
	data.owner_change_time = timestamp
	data.inventory_data = nil

	onApartmentOwnerChange( id, number )
	SaveApartmentData( id, number )

	onPlayerCompleteLogin_handler( client )

	WriteLog("apartments", "[Server.Apartments.Sell] Апартаменты [ID:%s/%s] были проданы игроком за [%s]. Бывший владелец: [ID:%s]", id, number, price, user_id)

	CheckPlayerVehiclesSlots(client)

	triggerEvent( "PlayerExitFromApartments", client, id )
	local wedded_id = client:GetPermanentData( "wedding_at_id" )
	if wedded_id then
		local player_wed = GetPlayer( wedded_id ) 
		if player_wed and isElement( player_wed ) then
			local apart_id, apart_number = GetApartmentPlayerIsInside( player_wed )
			if apart_id == id and apart_number == number then
				triggerEvent( "PlayerExitFromApartments", player_wed, apart_id )
			end
		end
	end

	--Обновляем хаты у партнёра ( если замужем/женат )
	triggerEvent( "onWeddingUpdateApartList", client )
	UpdateParkingMarkerWeddingPartner_handler( client )

	-- обнуляем продажу на бирже недвижимости
	local hid = id.."_"..number
	local pData = {
		hid                      = hid,
		house_type               = CONST_HOUSE_TYPE.APARTMENT,
		possible_buyer_id        = 0,
		seller_id                = 0,
		sale_state               = CONST_SALE_STATE.NOT_SALE,
		total_rental_fee         = 0,
		sale_publish_date        = 0,
		sale_cost                = 0,
		location_id              = GetLocationIDFromHID( hid, CONST_HOUSE_TYPE.APARTMENT ),
	}

	triggerEvent( "onChangeHouseSaleData", resourceRoot, hid, pData )

	triggerEvent( "onPlayerHouseLoss", client, 
		{
			mortage_type = "flat",
			mortage_group = class,
			mortage_id = id * 100 + number,
			loss_reason = "gov_sale",
			sum = price,
			owned_days = math.floor( owned_time / ( 24 * 60 * 60 ) )  
		},
		not player and owner_id
	)
end
addEvent("PlayerWantSellApartment", true)
addEventHandler("PlayerWantSellApartment", root, PlayerWantSellApartment)

function PlayerWantBuyPaidUpgradeApartment(id, number)
	if not client then return end

	id = tonumber(id)
	number = tonumber(number)

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local user_id = client:GetUserID()
	if not APARTMENTS_LIST_OWNERS[ id ][ number ] or APARTMENTS_LIST_OWNERS[ id ][ number ].user_id ~= user_id then
		client:ShowInfo("Это не твои апартаменты")
		client:triggerEvent("HideUIControl", resourceRoot)
		return
	end

	local info = APARTMENTS_LIST_OWNERS[ id ][ number ]
	if info.paid_upgrade >= 3 then return end
	
	local class = APARTMENTS_LIST[ id ].class

	local price = APARTMENTS_CLASSES[class].upgrades[info.paid_upgrade + 1].cost
	if not client:TakeMoney( price, "apartments_upgrade_purchase", "flat" ) then
		client:ShowError("У вас недостаточно денег")
		return
	end

	info.paid_upgrade = info.paid_upgrade + 1
	SaveApartmentData( id, number )

	WriteLog("apartments", "[Server.Apartments.BuyPaidUpgrade] Улучшение квартиры [ID:%s/%s] за [%s]. Уровень улучшения [%s]. Улучшил: [%s]", id, number, price, info.paid_upgrade, client)


	local pay_minus = 0
	for i = 1, info.paid_upgrade do
		pay_minus = pay_minus + APARTMENTS_CLASSES[class].upgrades[i].profit
	end
	local new_cost_day = APARTMENTS_CLASSES[ class ].cost_day - pay_minus

	client:triggerEvent("ShowUIControl", resourceRoot, {
		is_apartments = true,
		id = id,
		number = number,
		name = "Квартира №"..number,
		days = info.paid_days;
		cost_day = new_cost_day;
		paid_upgrade = info.paid_upgrade;		
		cost = APARTMENTS_CLASSES[ class ].cost;
	})

	triggerEvent( "onPlayerHouseUpgradePurchase", client, 
		{
			mortage_type = "flat",
			mortage_group = class,
			mortage_id = id * 100 + number,
			counter_cost = price,
			currency = "soft",
			discount_sum = APARTMENTS_CLASSES[ class ].upgrades[ info.paid_upgrade ].profit,
			new_mortage_daily_service_cost = new_cost_day
		}
	)
end
addEvent("PlayerWantBuyPaidUpgradeApartment", true)
addEventHandler("PlayerWantBuyPaidUpgradeApartment", root, PlayerWantBuyPaidUpgradeApartment)

function PlayerWantPayApartment(id, number, count_days, pay_with_phone)
	if not client then return end

	id = tonumber(id)
	number = tonumber(number)
	count_days = tonumber(count_days)

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local user_id = client:GetUserID()
	if not APARTMENTS_LIST_OWNERS[ id ][ number ] or APARTMENTS_LIST_OWNERS[ id ][ number ].user_id ~= user_id then
		client:ShowInfo("Это не твои апартаменты")
		client:triggerEvent("HideUIControl", resourceRoot)
		return
	end

	local info = APARTMENTS_LIST_OWNERS[ id ][ number ]

	if pay_with_phone and info.paid_days + count_days > 3 then
		client:ShowError("Нельзя произвести оплату больше чем на 3 дня")
		return
	end

	if info.paid_days + count_days > 15 then
		client:ShowError("Нельзя произвести оплату больше чем на 15 дней")
		return
	end

	local pay_minus = 0
	for i = 1, info.paid_upgrade do
		pay_minus = pay_minus + APARTMENTS_CLASSES[APARTMENTS_LIST[id].class].upgrades[i].profit
	end

	local metering_factor = REAL_METERING_DEVICE_FACTOR[ info.meter_type or 0 ] or 1
	local base_cost_day = APARTMENTS_CLASSES[APARTMENTS_LIST[id].class].cost_day
	local cost_day = base_cost_day * metering_factor - pay_minus
	local price = count_days * cost_day * ( client:IsPremiumActive() and 0.5 or 1 )

	if client:TakeMoney( price, "apartments_days_purchase", "flat" ) then
		info.paid_days = info.paid_days + count_days
		SaveApartmentData( id, number )

		if not pay_with_phone then
			client:triggerEvent("ShowUIControl", resourceRoot, {
				is_apartments = true,
				id = id,
				number = number,
				name = "Квартира №"..number,
				days = info.paid_days;
				cost_day = cost_day;
				paid_upgrade = info.paid_upgrade;				
				cost = APARTMENTS_CLASSES[APARTMENTS_LIST[id].class].cost;
			})
		end

		client:ShowSuccess("Кварплата успешно оплачена!")

		WriteLog("apartments", "[Server.Apartments.PaidDays] Оплата квартиры [ID:%s/%s] на [%s] дней. Всего оплачено: [%s] дней. Оплатил: [%s]", id, number, count_days, info.paid_days, client)
	end
end
addEvent("PlayerWantPayApartment", true)
addEventHandler("PlayerWantPayApartment", root, PlayerWantPayApartment)

function UpdateParkingMarkerWeddingPartner_handler( player )
	player = player or source
    local partner_id = player:GetPermanentData( "wedding_at_id" )
	if partner_id then
		local partner = GetPlayer( partner_id )
        if partner and partner:IsInGame( ) then
            onPlayerCompleteLogin_handler( partner )
        end
    end
end
addEvent( "UpdateParkingMarkerWeddingPartner", true )
addEventHandler( "UpdateParkingMarkerWeddingPartner", root, UpdateParkingMarkerWeddingPartner_handler )