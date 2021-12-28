BLOCK_SALE_TIMESTAMP = 72 * 60 * 60

function CalculateDailyCost( hid )
	local pVipHouse = VIP_HOUSES[ hid ]
	local config = pVipHouse.config
	local metering_factor = REAL_METERING_DEVICE_FACTOR[ pVipHouse.meter_type or 0 ] or 1
	local daily_cost = config.daily_cost * metering_factor
	local services = config.services
	for i, v in pairs( services ) do
		if pVipHouse.purchased_services[ i ] then
			daily_cost = daily_cost - services[ i ].reduction
		end
	end

	return daily_cost
end

function CalculateTotalRentalFee( hid )
	local pVipHouse = VIP_HOUSES[ hid ]
	local daily_cost = CalculateDailyCost( hid )
	local total_rental_fee = pVipHouse.paid_days * daily_cost

	return total_rental_fee
end

function onPublishVipHouseSale_handler( publisher, hid, cost, possible_buyer_id )
	-- владелец, размещающий обьявление, должен быть онлайн
	if not isElement( publisher ) then return end

	if not VIP_HOUSES[ hid ] then
		return publisher:ShowError( "У вас нет недвижимости!" )
	end

	local pVipHouse = VIP_HOUSES[ hid ]
	local publisher_id = publisher:GetUserID( )
	local house_type = GetHouseTypeFromHID( hid )

	if pVipHouse.owner ~= publisher_id then
		return publisher:ShowError( "Это не твои апартаменты!" )
	elseif pVipHouse.sale_state > CONST_SALE_STATE.NOT_SALE then
		return publisher:ShowError( "Это недвижимость уже размещена в продажу!" )
	elseif ( getRealTime( ).timestamp - pVipHouse.owner_change_time ) < BLOCK_SALE_TIMESTAMP then
		return publisher:ShowError( "Нельзя перепродать дом в течении 3-х дней после покупки!" )
	end

	-- обновляем статус продажи
	pVipHouse.sale_state = possible_buyer_id and possible_buyer_id > 0 and CONST_SALE_STATE.INDIVIDUAL_SALE or CONST_SALE_STATE.SHARED_SALE
	pVipHouse:Save( )

	-- размещаем недвижимость на бирже
	local pSaleData = {
		hid                      = hid,
		house_type               = house_type,
		possible_buyer_id        = possible_buyer_id or 0,
		seller_id                = publisher_id,
		sale_state               = pVipHouse.sale_state,
		total_rental_fee         = CalculateTotalRentalFee( hid ),
		sale_publish_date        = getRealTime( ).timestamp,
		sale_cost                = cost,
		location_id              = GetLocationIDFromHID( hid, house_type ),
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
addEvent( "onPublishVipHouseSale", false )
addEventHandler( "onPublishVipHouseSale", root, onPublishVipHouseSale_handler )

function onCancelVipHouseSale_handler( owner, hid )
	-- владелец должен быть онлайн
	if not isElement( owner ) then return end

	if not VIP_HOUSES[ hid ] then
		return publisher:ShowError( "У вас нет недвижимости!" )
	end

	local pVipHouse  = VIP_HOUSES[ hid ]
	local owner_id   = owner:GetUserID( )
	local house_type = GetHouseTypeFromHID( hid )

	if pVipHouse.owner ~= owner_id then
		return owner:ShowError( "Это не твои апартаменты!" )
	elseif pVipHouse.sale_state == CONST_SALE_STATE.NOT_SALE then
		return owner:ShowError( "Этой недвижимости нету в списке продаж!" )
	end

	-- обновляем статус продажи
    pVipHouse.sale_state = CONST_SALE_STATE.NOT_SALE
	pVipHouse:Save( )

	-- обнуляем продажу на бирже
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

	triggerEvent( "onChangeHouseSaleData", sourceResourceRoot, hid, pData )

	owner:InfoWindow( "Вы успешно отменили продажу дома!" )
end
addEvent( "onCancelVipHouseSale", false )
addEventHandler( "onCancelVipHouseSale", root, onCancelVipHouseSale_handler )

function onChangeVipHouseOwner_handler( buyer, hid, cost, seller_id )
	-- покупатель должен быть онлайн
	if not isElement( buyer ) then return end

	if not VIP_HOUSES[ hid ] then
		return buyer:ShowError( "Выбранная недвижимость не найдена!" )
	end

	local pVipHouse = VIP_HOUSES[ hid ]
	local buyer_id = buyer:GetUserID( )
	local house_type = GetHouseTypeFromHID( hid )

	if pVipHouse.owner ~= seller_id then
		return buyer:ShowError( "У недвижимости сменился хозяин! Попробуйте позже." )
	elseif pVipHouse.sale_state == CONST_SALE_STATE.NOT_SALE then
		return buyer:ShowError( "Эта недвижимость не продается!" )
	end

	if buyer:GetMoney( ) < cost then
        return buyer:ShowError( "Не хватает средств на покупку недвижимости!" )
    end

	buyer:TakeMoney( cost, "nrp_house_sale" )

	local timestamp = getRealTime( ).timestamp
	local time_since_last_owner = timestamp - pVipHouse.owner_change_time

	pVipHouse.owner           	= buyer_id
	pVipHouse.owner_change_time = timestamp
	pVipHouse.sale_state        = CONST_SALE_STATE.NOT_SALE
	pVipHouse.inventory_data	= {}

	pVipHouse:Save( )
	pVipHouse:OnOwnerChange( )
	triggerEvent( "onHouseUpdate", resourceRoot, 0, pVipHouse.id, pVipHouse, pVipHouse.config.inventory_max_weight )


	-- для отображения никнейма владельца на маркерах у входа и обновления блипов
	if house_type == CONST_HOUSE_TYPE.VILLA or house_type == CONST_HOUSE_TYPE.COTTAGE then
		VIP_HOUSE_OWNERS[ hid ] = buyer:GetNickName( )
	end

	onPlayerCompleteLogin_handler( buyer )

    local house_name = "деревенский дом"
    if house_type == CONST_HOUSE_TYPE.VILLA then
        house_name = hid == "vh1" and "Вилла 'Око'" or "виллу"
        house_name = house_name .. " " .. tostring( VIP_HOUSES_REVERSE[ hid ].village_class ) .. " класса"
    elseif house_type == CONST_HOUSE_TYPE.COTTAGE then
        house_name = "коттедж " .. tostring( VIP_HOUSES_REVERSE[ hid ].cottage_class ) .. " класса"
    end

    local message = {
        title = "Продажа дома",
        msg = string.format("Вы продали %s за %s.", house_name, format_price( math.floor( 0.95 * cost ) ) )
    }

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
        house_type               = house_type,
        possible_buyer_id        = 0,
        seller_id                = 0,
        sale_state               = CONST_SALE_STATE.NOT_SALE,
        total_rental_fee         = 0,
        sale_publish_date        = 0,
        sale_cost                = 0,
		location_id              = GetLocationIDFromHID( hid, house_type ),
    }

	triggerEvent( "onChangeHouseSaleData", sourceResourceRoot, hid, pData )

	-- Обновляем хаты у партнёра ( если замужем/женат )
	triggerEvent( "onWeddingUpdateVipHouseData", buyer )

	-- Аналитика
	local config = pVipHouse.config
    local str_type = config.village_class and "village" or (config.cottage_class and "cottage" or "country")
    local str_group = config.village_class and config.village_class or (config.cottage_class and config.cottage_class or config.country_class)
	triggerEvent( "onPlayerHousePurchase", buyer, {
        mortage_type               = str_type,
		mortage_purchase_type      = "player",
        mortage_group              = str_group,
        mortage_id                 = pVipHouse.id,
        is_first_owner             = false,
        days_since_last_owner      = math.floor( time_since_last_owner / ( 24 * 60 * 60 ) ),
        mortage_cost               = cost,
        currency                   = "soft",
        mortage_daily_service_cost = config.daily_cost,
    } )

	buyer:ShowInfo( "Вы успешно купили дом!" )
end
addEvent( "onChangeVipHouseOwner", false )
addEventHandler( "onChangeVipHouseOwner", root, onChangeVipHouseOwner_handler )
