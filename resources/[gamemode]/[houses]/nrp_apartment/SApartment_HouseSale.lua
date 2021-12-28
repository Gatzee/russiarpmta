----------------------------------------------------------------------------------------------
-- для продажи недвижимости через объявление в зданиях мэрий
----------------------------------------------------------------------------------------------
BLOCK_SALE_TIMESTAMP = 72 * 60 * 60

function CalculateDailyCost( id, number )
	local info = APARTMENTS_LIST_OWNERS[ id ][ number ]
	local class_data = APARTMENTS_CLASSES[ APARTMENTS_LIST[ id ].class ]
	local metering_factor = REAL_METERING_DEVICE_FACTOR[ info.meter_type or 0 ] or 1
	local cost_day = class_data.cost_day * metering_factor

	for i = 1, info.paid_upgrade do
		cost_day = cost_day - class_data.upgrades[ i ].profit
	end

	return cost_day
end

function CalculateTotalRentalFee( id, number )
	local info = APARTMENTS_LIST_OWNERS[ id ][ number ]
	local cost_day = CalculateDailyCost( id, number )
	local total_rental_fee = info.paid_days * cost_day

	return total_rental_fee
end

function onPublishApartmentSale_handler( publisher, hid, cost, possible_buyer_id )
	-- владелец, размещающий обьявление, должен быть онлайн
	if not isElement( publisher ) then return end

	local _, _, id, number = utf8.find( hid, "^(%d+)_(%d+)$" )
	id = tonumber( id )
	number = tonumber( number )

	if not id or not number
		or id < 1 or id > #APARTMENTS_LIST
		or not APARTMENTS_LIST[id]
	then
		return publisher:ShowError( "У вас нет недвижимости!" )
	end

	local publisher_id = publisher:GetUserID( )

	local pApartment = APARTMENTS_LIST_OWNERS[ id ][ number ]

	if pApartment.user_id ~= publisher_id then
		return publisher:ShowError( "Это не твои апартаменты!" )
	elseif pApartment.sale_state > CONST_SALE_STATE.NOT_SALE then
		return publisher:ShowError( "Эта недвижимость уже размещена в продажу!" )
	elseif ( getRealTime( ).timestamp - pApartment.owner_change_time ) < BLOCK_SALE_TIMESTAMP then
		return publisher:ShowError( "Нельзя перепродать дом в течении 3-х дней после покупки!" )
	end

	-- обновляем статус продажи
	local sale_state = possible_buyer_id and possible_buyer_id > 0 and CONST_SALE_STATE.INDIVIDUAL_SALE or CONST_SALE_STATE.SHARED_SALE
	pApartment.sale_state = sale_state
	SaveApartmentData( id, number )

	-- размещаем квартиру на бирже
	local pSaleData = {
		hid                      = hid,
		house_type               = CONST_HOUSE_TYPE.APARTMENT,
		possible_buyer_id        = possible_buyer_id or 0,
		seller_id                = publisher_id,
		sale_state               = sale_state,
		total_rental_fee         = CalculateTotalRentalFee( id, number ),
		sale_publish_date        = getRealTime( ).timestamp,
		sale_cost                = cost,
		location_id              = GetLocationIDFromHID( hid, CONST_HOUSE_TYPE.APARTMENT ),
	}

	triggerEvent( "onChangeHouseSaleData", sourceResourceRoot, hid, pSaleData )

	if possible_buyer_id and possible_buyer_id > 0 then
		local buyer = GetPlayer( possible_buyer_id )
		if buyer and buyer:IsInGame( ) then
			buyer:PhoneNotification( {
				title = "Покупка дома",
				msg = "На бирже есть недвижимость специально для вас."
			} )
		else
			-- оффлайн
			local possible_buyer_client_id = exports.nrp_player_offline:GetOfflineDataFromUserID( possible_buyer_id, "client_id" )

			if not possible_buyer_client_id then
				DB:queryAsync( function( query )
					local result = query:poll( 0 )

					if not result then
						outputDebugString( "Игрок с таким UserID не найден (" .. tostring( possible_buyer_id ) ..")", 0 )
						return
					end

					local possible_buyer_client_id = result[1]["client_id"]

					possible_buyer_client_id:PhoneNotification( {
						title = "Покупка дома",
						msg = "На бирже есть недвижимость специально для вас."
					} )

				end, {}, "SELECT client_id FROM nrp_players WHERE id=? LIMIT 1", possible_buyer_id )

			else
				possible_buyer_client_id:PhoneNotification( {
					title = "Покупка дома",
					msg = "На бирже есть недвижимость специально для вас."
				} )
			end
		end
	end

	publisher:ShowSuccess( "Дом успешно выставлен на продажу." )
end
addEvent( "onPublishApartmentSale", false )
addEventHandler( "onPublishApartmentSale", root, onPublishApartmentSale_handler )

function onCancelApartmentSale_handler( owner, hid )
	-- владелец должен быть онлайн
	if not isElement( owner ) then return end

	local _, _, id, number = utf8.find( hid, "^(%d+)_(%d+)$" )
	id = tonumber( id )
	number = tonumber( number )

	if not id or not number
		or id < 1 or id > #APARTMENTS_LIST
		or not APARTMENTS_LIST[ id ]
	then
		return owner:ShowError( "У вас нет недвижимости!" )
	end

	local owner_id = owner:GetUserID( )
	local pApartment = APARTMENTS_LIST_OWNERS[ id ][ number ]

	if pApartment.user_id ~= owner_id then
		return owner:ShowError( "Это не твои апартаменты!" )
	elseif pApartment.sale_state == CONST_SALE_STATE.NOT_SALE then
		return owner:ShowError( "Этой недвижимости нету в списке продаж!" )
	end

	-- обновляем статус продажи
	pApartment.sale_state = CONST_SALE_STATE.NOT_SALE
	SaveApartmentData( id, number )

	onPlayerCompleteLogin_handler( owner )

	-- обнуляем продажу на бирже
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

	triggerEvent( "onChangeHouseSaleData", sourceResourceRoot, hid, pData )

	owner:InfoWindow( "Вы успешно отменили продажу дома!" )
end
addEvent( "onCancelApartmentSale", false )
addEventHandler( "onCancelApartmentSale", root, onCancelApartmentSale_handler )

function onChangeApartmentOwner_handler( buyer, hid, cost, seller_id )

	-- покупатель должен быть онлайн
	if not isElement( buyer ) then return end

	local _, _, id, number = utf8.find( hid, "^(%d+)_(%d+)$" )
	id = tonumber( id )
	number = tonumber( number )

	if not id or not number
		or id < 1 or id > #APARTMENTS_LIST
		or not APARTMENTS_LIST[id]
	then
		return buyer:ShowError( "Выбранная недвижимость не найдена!" )
	end

	local pApartment = APARTMENTS_LIST_OWNERS[ id ][ number ]

	if not pApartment or pApartment.sale_state == CONST_SALE_STATE.NOT_SALE then
		return buyer:ShowError( "Эта недвижимость не продается!" )
	elseif pApartment.user_id ~= seller_id then
		return buyer:ShowError( "У недвижимости сменился хозяин! Попробуйте позже." )
	end

	if buyer:GetMoney( ) < cost then
		return buyer:ShowError( "Не хватает средств на покупку недвижимости!" )
	end

	buyer:TakeMoney( cost, "nrp_house_sale" )

	local timestamp = getRealTime( ).timestamp
	local time_since_last_owner = timestamp - pApartment.owner_change_time

	local buyer_id = buyer:GetUserID( )
	pApartment.user_id           = buyer_id
	pApartment.owner_change_time = timestamp
	pApartment.sale_state        = CONST_SALE_STATE.NOT_SALE
	pApartment.inventory_data	 = {}

	onApartmentOwnerChange( id, number )
	SaveApartmentData( id, number )

	onPlayerCompleteLogin_handler( buyer )

    local message = {
        title = "Продажа дома",
        msg = string.format("Вы продали квартиру %s класса за %s.", APARTMENTS_LIST[id].class, format_price(  math.floor( 0.95 * cost ) )
    )}

	local seller = GetPlayer( seller_id )
	if seller and seller:IsInGame( ) then
		onPlayerCompleteLogin_handler( seller )
		seller:GiveMoney( math.floor( 0.95 * cost ), "nrp_house_sale" )
        seller:PhoneNotification( message )
    else
		-- оффлайн
		local seller_client_id = exports.nrp_player_offline:GetOfflineDataFromUserID( seller_id, "client_id" )

		if not seller_client_id then
			DB:queryAsync( function( query )
				local result = query:poll( 0 )

				if not result then
					outputDebugString( "Игрок с таким UserID не найден (" .. tostring( seller_id ) ..")", 0 )
					return
				end

				local seller_client_id = result[1]["client_id"]
				seller_client_id:GiveMoney( math.floor( 0.95 * cost ), "nrp_house_sale" )
				seller_client_id:PhoneNotification( message )

			end, {}, "SELECT client_id FROM nrp_players WHERE id=? LIMIT 1", seller_id )

		else
			seller_client_id:GiveMoney( math.floor( 0.95 * cost ), "nrp_house_sale" )
			seller_client_id:PhoneNotification( message )
		end
	end

	-- обнуляем продажу на бирже
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

	triggerEvent( "onChangeHouseSaleData", sourceResourceRoot, hid, pData )

	-- Обновляем хаты у партнёра ( если замужем/женат )
	triggerEvent( "onWeddingUpdateApartList", buyer )

	-- Аналитика
	local info = APARTMENTS_LIST[id]
	triggerEvent( "onPlayerHousePurchase", buyer,
		{
			mortage_type               = "flat",
			mortage_purchase_type      = "player",
			mortage_group              = info.class,
			mortage_id                 = id * 100 + number,
			is_first_owner             = false,
			days_since_last_owner      = math.floor( time_since_last_owner / ( 24 * 60 * 60 ) ),
			mortage_cost               = cost,
			currency                   = "soft",
			mortage_daily_service_cost = CalculateDailyCost( id, number ),
		}
	)

	buyer:ShowInfo( "Вы успешно купили дом!" )

	triggerEvent( "onPlayerSomeDo", buyer, "buy_house" ) -- achievements
end
addEvent( "onChangeApartmentOwner", false )
addEventHandler( "onChangeApartmentOwner", root, onChangeApartmentOwner_handler )
----------------------------------------------------------------------------------------------
