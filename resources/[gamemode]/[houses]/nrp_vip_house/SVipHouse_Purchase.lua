function onViphousePurchaseAttempt_handler( hid )
	local client = client or source

    local house = VIP_HOUSES[ hid ]
    if house:IsPurchased() then
        client:ErrorWindow( "Дом уже куплен!" )
        return
	end

    local config = house.config

	local timestamp = getRealTime( ).timestamp
	local apartments_offer = client:GetPermanentData( "apartments_offer" )

	local apartments_offer_active = false
	local cost = config.cost
	if apartments_offer and apartments_offer > timestamp then
		cost = DISCOUNT_COST_CONVERT[ cost ] or math.floor( cost * 0.8 )
		apartments_offer_active = true
	end

    if client:GetMoney( ) < cost then
        client:EnoughMoneyOffer( "Vip house purchase", cost, "onViphousePurchaseAttempt", client, hid )
        return
    end

    local is_first_owner = house.owner_change_time == 0
    local time_since_last_owner = is_first_owner and 0 or ( timestamp - house.owner_change_time )

    house:Reset( true )
    house.owner = client:GetUserID()
    house.owner_change_time = timestamp
    house.paytime = timestamp + 24 * 60 * 60
    house:Save( )
    house:OnOwnerChange( )

    client:TakeMoney( cost, "apartments_purchase", "viphouse" )
    triggerClientEvent( client, "ShowPurchaseUI", resourceRoot, false )
    client:InfoWindow( "Дом успешно куплен!" )

    triggerEvent( "onPlayerSomeDo", client, "buy_house" ) -- achievements

    local house_type = GetHouseTypeFromHID( house.hid )
    if ( house_type == CONST_HOUSE_TYPE.VILLA or house_type == CONST_HOUSE_TYPE.COTTAGE ) then
    	VIP_HOUSE_OWNERS[ house.hid ] = client:GetNickName( )
    end

	onPlayerCompleteLogin_handler( client )
    triggerEvent( "CheckPlayerVehiclesSlots", client )

    --Обновляем хаты у партнёра ( если замужем/женат )
	triggerEvent( "onWeddingUpdateVipHouseData", client )
    UpdateGarageMarkerWeddingPartner_handler( client )

    local str_type = config.village_class and "village" or (config.cottage_class and "cottage" or "country")
    local str_group = config.village_class and config.village_class or (config.cottage_class and config.cottage_class or config.country_class)
    
	triggerEvent( "onPlayerHousePurchase", client, {
        mortage_type = str_type,
        mortage_purchase_type = "gov",
        mortage_group = str_group,
        mortage_id = house.id,
        is_first_owner = is_first_owner,
        days_since_last_owner = math.floor( time_since_last_owner / ( 24 * 60 * 60 ) ),
        mortage_cost = cost,
        currency = "soft",
        mortage_daily_service_cost = config.daily_cost,
    } )

	if apartments_offer_active then
		triggerEvent( "SDEV2DEV_apartments_offer_purchase", client, str_type, house.id, cost, "soft" )
	end
end
addEvent( "onViphousePurchaseAttempt", true )
addEventHandler( "onViphousePurchaseAttempt", root, onViphousePurchaseAttempt_handler )

function onViphouseAddcashAttempt_handler( hid, days, pay_with_phone )
    local house = VIP_HOUSES[ hid ]
    if not house then return end

    if house.owner ~= client:GetUserID() then
        return client:ErrorWindow( "Этот дом не принадлежит вам!" )
    end

    local days = math.abs( math.floor( days ) )

    local config = house.config

    local metering_factor = REAL_METERING_DEVICE_FACTOR[ house.meter_type or 0 ] or 1
    local daily_cost = config.daily_cost * metering_factor

    local services = config.services
	for i, v in pairs( services ) do
		if house.purchased_services[ i ] then 
            daily_cost = daily_cost - services[ i ].reduction
		end
	end

    local cost = math.floor( daily_cost * days ) * ( client:IsPremiumActive() and 0.5 or 1 )
    if client:GetMoney( ) <= cost then
        client:ErrorWindow( "Недостаточно средств для продления!" )
        return
    end

	if pay_with_phone and house.paid_days + days > 3 then
		client:ShowError("Нельзя произвести оплату больше чем на 3 дня")
		return
	end

    if house.paid_days + days > 15 then
        client:ErrorWindow( "Можно оплатить только на 15 дней вперёд" )
        return
    end

    client:TakeMoney( cost, "apartments_days_purchase", "viphouse" )
    house.paid_days = house.paid_days + days
    house:Save( )
    if not pay_with_phone then
        house:ShowControl( client )
    end
    client:InfoWindow( "Дом успешно проплачен!" )
end
addEvent( "onViphouseAddcashAttempt", true )
addEventHandler( "onViphouseAddcashAttempt", root, onViphouseAddcashAttempt_handler )

function onViphouseServicePurchase_handler( hid, service_num )
    local house = VIP_HOUSES[ hid ]
    if not house then return end

    if house.owner ~= client:GetUserID() then
        return client:ErrorWindow( "Этот дом не принадлежит вам!" )
    end

    if house.purchased_services[ service_num ] then
        client:ErrorWindow( "Данное оборудование уже установлено!" )
        return
    end

    local config = house.config
    local services = config.services

    local service = services[ service_num ]
    local cost = service.cost

    if client:GetMoney( ) <= cost then
        client:ErrorWindow( "Недостаточно средств для установки оборудования!" )
        return
    end

    client:TakeMoney( cost, "apartments_upgrade_purchase", "viphouse" )
    house.purchased_services[ service_num ] = 1
    house:Save( )

    house:ShowControl( client, "services" )
    client:InfoWindow( "Оборудование успешно установлено!" )

    local metering_factor = REAL_METERING_DEVICE_FACTOR[ house.meter_type or 0 ] or 1
    local daily_cost = config.daily_cost * metering_factor
	for i, v in pairs( services ) do
		if house.purchased_services[ i ] then 
            daily_cost = daily_cost - services[ i ].reduction
		end
	end

    local str_type = config.village_class and "village" or (config.cottage_class and "cottage" or "country")
    local str_group = config.village_class and config.village_class or (config.cottage_class and config.cottage_class or config.country_class)

	triggerEvent( "onPlayerHouseUpgradePurchase", client, {
        mortage_type = str_type,
        mortage_group = str_group,
		mortage_id = house.id,
		counter_cost = cost,
		currency = "soft",
		discount_sum = services[ service_num ].reduction,
		new_mortage_daily_service_cost = daily_cost
	} )
end
addEvent( "onViphouseServicePurchase", true )
addEventHandler( "onViphouseServicePurchase", root, onViphouseServicePurchase_handler )

function onViphouseSellAttempt_handler( hid )
    local house = VIP_HOUSES[ hid ]
    if not house then return end

    if house.owner ~= client:GetUserID() then
        return client:ErrorWindow( "Этот дом не принадлежит вам!" )
    end

    local config = house.config
    
    local cost = math.floor( config.cost / 2 )

    local timestamp = getRealTimestamp()
    local is_first_owner = house.owner_change_time == 0
    local owned_time = is_first_owner and 0 or ( timestamp - house.owner_change_time )

    if not is_first_owner and owned_time < BLOCK_SALE_TIMESTAMP then
		return client:ShowError( "Нельзя перепродать дом в течении 3-х дней после покупки!" )
	end

    client:GiveMoney( cost, "apartments_sell", "viphouse" )
    house:Reset( )
    client:InfoWindow( "Дом успешно продан!" )
	client:triggerEvent( "HideUIControl", client )
	
	onPlayerCompleteLogin_handler( client )

    local pos = config.reset_position
    if pos then client.position = Vector3( pos.x, pos.y, pos.z ) end

    triggerEvent( "CheckPlayerVehiclesSlots", client )

    --Обновляем хаты у партнёра ( если замужем/женат )
	triggerEvent( "onWeddingUpdateVipHouseData", client )
	UpdateGarageMarkerWeddingPartner_handler( client )

    -- обнуляем продажу на бирже
    local house_type = GetHouseTypeFromHID( hid )
	local pData = {
		hid                      = hid,
		house_type               = house_type,
		possible_buyer_id        = 0,
		seller_id                = 0,
		sale_state               = CONST_SALE_STATE.NOT_SALE,
		total_rental_fee         = 0,
		sale_publish_date        = 0,
		sale_cost                = 0,
		location_id              = GetLocationIDFromHID( hid, house_type ),
    }

	triggerEvent( "onChangeHouseSaleData", resourceRoot, hid, pData )

    local str_type = config.village_class and "village" or (config.cottage_class and "cottage" or "country")
    local str_group = config.village_class and config.village_class or (config.cottage_class and config.cottage_class or config.country_class)

	triggerEvent( "onPlayerHouseLoss", client, {
        mortage_type = str_type,
        mortage_group = str_group,
		mortage_id = house.id,
        loss_reason = "gov_sale",
        sum = cost,
        owned_days = math.floor( owned_time / ( 24 * 60 * 60 ) )
	} )
end
addEvent( "onViphouseSellAttempt", true )
addEventHandler( "onViphouseSellAttempt", root, onViphouseSellAttempt_handler )

function UpdateGarageMarkerWeddingPartner_handler( player )
    player = player or source
    local partner_id = player:GetPermanentData( "wedding_at_id" )
	if partner_id then
		local partner = GetPlayer( partner_id )
        if partner and partner:IsInGame( ) then
            onPlayerCompleteLogin_handler( partner )
        end
    end
end
addEvent( "UpdateGarageMarkerWeddingPartner", true )
addEventHandler( "UpdateGarageMarkerWeddingPartner", root, UpdateGarageMarkerWeddingPartner_handler )