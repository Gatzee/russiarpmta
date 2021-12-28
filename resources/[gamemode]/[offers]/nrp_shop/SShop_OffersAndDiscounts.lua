CONST_GET_SPECIAL_OFFERS_URL = SERVER_NUMBER > 100 and "https://pyapi.devhost.nextrp.ru/v1.0/get_special_offers/" or "https://pyapi.gamecluster.nextrp.ru/v1.0/get_special_offers/"

PLAYER_SEGMENTS = { }

SEGMENTS_AMOUNTS = {
	[ 1 ] = 35000,
	[ 2 ] = 6500,
	[ 3 ] = 1500,
	[ 4 ] = 0,
}

function GetAllSegments( )
    return SEGMENTS_AMOUNTS
end

VEHICLE_CLASSES_NAMES_REVERSE = { }
for class, name in pairs( VEHICLE_CLASSES_NAMES ) do
    VEHICLE_CLASSES_NAMES_REVERSE[ name ] = class
end

OFFERS_TABS = {
    discounts = {
        vehicle_discount = {
            analytics_conf = {
                item_type = "car",
                currency = "soft",
            },
            array = {
                [ 6627 ] ={
                    cost = 10990000,
                    cost_original = 13639500,
                    name = "Maserati GranTurismo S",
                    start_date = getTimestampFromString( "21.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "23.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                },

                [ 479 ] ={
                    cost = 3490000,
                    cost_original = 6000000,
                    name = "Mercedes GL",
                    start_date = getTimestampFromString( "21.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "23.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                    variant = 1,
                },

                [ 448 ] ={
                    cost = 2890000,
                    cost_original = 3490000,
                    name = "APRILIA RSV4 R",
                    start_date = getTimestampFromString( "21.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "23.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                },

                [ 6605 ] ={
                    cost = 1490000,
                    cost_original = 2190000,
                    name = "ЗИЛ-114",
                    start_date = getTimestampFromString( "21.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "23.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                },

                [ 518 ] ={
                    cost = 3590000,
                    cost_original = 4935000,
                    name = "Chevrolet Camaro",
                    start_date = getTimestampFromString( "28.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "30.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                },

                [ 6579 ] ={
                    cost = 19990000,
                    cost_original = 25190000,
                    name = "Ferrari California T 2015",
                    start_date = getTimestampFromString( "28.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "30.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                },

                [ 405 ] ={
                    cost = 1490000,
                    cost_original = 2100000,
                    name = "Mitsubishi lancer X",
                    start_date = getTimestampFromString( "28.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "30.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                    variant = 1,
                },

                [ 421] ={
                    cost = 6490000,
                    cost_original = 8400000,
                    name = "BMW X5M",
                    start_date = getTimestampFromString( "28.06.2021 00:00" ),
                    finish_date = getTimestampFromString( "30.06.2021 23:59" ),
                    active_for_all = true,
                    show_on_map = true,
                },
            },
            fn_call = function( self, id, params, client )
                if not params.ignore_slots and not VEHICLE_CONFIG[ id ].is_moto then
                    if not client:HasFreeVehicleSlot( ) then
                        triggerClientEvent( client, "onPlayerNotHaveSlotsForPurchase", resourceRoot )
                        return
                    end
                end

                local cost = params.cost
				if client:GetMoney( ) < cost then
					triggerClientEvent( client, "onShopNotEnoughHard", client, "Vehicle Special" )
                    return
                end

                if client.interior ~= 0 or client.dimension ~= 0 then
                    client:ErrorWindow( "Покупать машины можно только на улице, не находясь на задании!" )
                    return
                end

                if client:getData( "jailed" ) then
                    client:ErrorWindow( "В тюрьме нельзя делать покупки" )
                    return
                end

                client:TakeMoney( cost, "f4_discount", "vehicle_" .. id )

                local owner_pid	= "p:" .. client:GetUserID( )
                local vehicle_conf	= {
                    model 		= id,
                    variant		= params.variant or 1,
                    x			= 0,
                    y			= 0,
                    z			= 0,
                    rx			= 0,
                    ry			= 0,
                    rz			= 0,
                    owner_pid	= owner_pid,
                    color		= params.color or { 255, 255, 255 },
                }

                exports.nrp_vehicle:AddVehicle( vehicle_conf, true, "onDiscountedVehiclePurchaseCallback", { player = client, cost = cost } )
                client:InfoWindow( "Транспорт успешно приобретён!" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                return true, { cost = cost, name = params.name }
            end,
        }
    },

    special = {
        weapon = {
            analytics_conf = {
                item_type = "weapon",
                currency = "hard",
            },
            fn_call = function( self, id, params, client, amount )
                amount = tonumber( amount )
                if not amount or amount ~= amount or math.ceil( amount ) ~= amount then
                    return
                end

                local cost = params.cost * amount

                if client:GetDonate( ) < cost then
                    triggerClientEvent( client, "onShopNotEnoughHard", client, "Weapon special" )
                    return
                end

                client:TakeDonate( cost, "f4_special", "weapon_" .. id )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

                SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_weapon_purchase" )

                client:InventoryAddItem( IN_WEAPON, { id }, amount )

                client:InfoWindow( "Оружие успешно приобретено!\nТы можешь применить его в Инвентаре" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                return true, { cost = cost, name = params.name }
            end,
        },

        accessory = {
            analytics_conf = {
                item_type = "accessory",
                currency = "hard",
            },
            fn_call = function( self, id, params, client )
                if client:GetOwnedAccessories()[ id ] then
                    client:ErrorWindow( "Вы уже приобрели данный аксессуар" )
                    return
                end

                local cost = params.cost
                if client:GetDonate( ) < cost then
                    triggerClientEvent( client, "onShopNotEnoughHard", client, "Accessory special" )
                    return
                end

                client:TakeDonate( cost, "f4_special", "accessory_" .. id )

                client:AddOwnedAccessory( id )
                client:InfoWindow( "Аксессуар успешно приобретен!\nТы можешь применить его в Магазине Одежды" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

				SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_accessory_purchase" )

                return true, { cost = cost, name = params.name }
            end,
        },

        vehicle = {
            analytics_conf = {
                item_type = "car",
                currency = "hard",
            },
            fn_call = function( self, id, params, client, color )
                local cost, coupon_discount_value = client:GetCostWithCouponDiscount( "special_vehicle", params.cost )
				if client:GetDonate( ) < cost then
					SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_auto_confirmation_ok_reject_balance" )
					triggerClientEvent( client, "onShopNotEnoughHard", client, "Vehicle special" )
                    return
				end

                if not params.ignore_slots and not VEHICLE_CONFIG[ id ].is_moto then
                    if not client:HasFreeVehicleSlot( ) then
						SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_auto_confirmation_ok_reject_slot" )
                        triggerClientEvent( client, "onPlayerNotHaveSlotsForPurchase", resourceRoot )
                        return
                    end
                end

                if client.interior ~= 0 or client.dimension ~= 0 then
                    client:ErrorWindow( "Покупать машины можно только на улице, не находясь на задании!" )
                    return
                end

                if client:getData( "jailed" ) then
                    client:ErrorWindow( "В тюрьме нельзя делать покупки" )
                    return
                end

                client:TakeDonate( cost, "f4_special", "vehicle_" .. id )
                if coupon_discount_value then
                    client:TakeSpecialCouponDiscount( coupon_discount_value, "special_vehicle" ) 
                    triggerEvent( "onPlayerRequestDonateMenu", client, "special" )
                end

                --local cost_original = VEHICLE_CONFIG[ id ].variants[ params.variant or 1 ].cost or cost
                local cost_original = cost * 1000
                local owner_pid	= "p:" .. client:GetUserID( )
                local vehicle_conf	= {
                    model         = id                            ,
                    variant       = params.variant or 1           ,
                    x             = 0                             ,
                    y             = 0                             ,
                    z             = 0                             ,
                    rx            = 0                             ,
                    ry            = 0                             ,
                    rz            = 0                             ,
                    owner_pid     = owner_pid                     ,
                    color         = color or params.color or { 255, 255, 255 },
                    first_owner   = owner_pid                     ,
                    showroom_cost = cost_original                 ,
                    showroom_date = getRealTime( ).timestamp      ,
                }

                exports.nrp_vehicle:AddVehicle( vehicle_conf, true, "onOfferedVehiclePurchaseCallback", { player = client, cost = cost_original } )
                client:InfoWindow( "Транспорт успешно приобретён!" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

				SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_auto_purchase" )

                return true, { cost = cost, name = params.name }
            end,
        },

        skin = {
            analytics_conf = {
                item_type = "skin",
                currency = "hard",
            },
            fn_call = function( self, id, params, client )
                if client:HasSkin( id ) then
                    client:ErrorWindow( "Ты уже владеешь этим скином" )
                    return
                end

                local cost, coupon_discount_value = client:GetCostWithCouponDiscount( "special_skin", params.cost )
                if client:GetDonate( ) < cost then
                    triggerClientEvent( client, "onShopNotEnoughHard", client, "Skin special" )
                    return
                end

                client:TakeDonate( cost, "f4_special", "skin_" .. id )
                if coupon_discount_value then 
                    client:TakeSpecialCouponDiscount( coupon_discount_value, "special_skin" ) 
                    triggerEvent( "onPlayerRequestDonateMenu", client, "special" )
                end

                client:GiveSkin( id )

                client:InfoWindow( "Скин успешно приобретён и добавлен в твой гардероб!" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

                return true, { cost = cost, name = params.name }
            end,
        },

        numberplate = {
            analytics_conf = {
                item_type = "numberplate",
                currency = "hard",
            },
            fn_call = function( self, id, params, client, vehicle )
                local cost, coupon_discount_value = params.cost, false
                if not cost then
                    return iprint( "CANT FIND cost VAR FOR PLATE:",params.name)
                end
                
                cost, coupon_discount_value = client:GetCostWithCouponDiscount( "special_numberplate", cost )
                if client:GetDonate( ) < cost then
                    triggerClientEvent( client, "onShopNotEnoughHard", client, "Numberplate special" )
                    return
                end

                local region = tonumber( params.region ) and string.format( "%02d", params.region ) or tostring( params.region )
                local numberplate = PLATE_TYPE_SPECIAL .. ":" .. params.name .. region
                local result = exports.nrp_vehicle_numberplates:OnPlayerTryBuyNumberPlate( vehicle, numberplate, client, cost )

                if not result then
                    client:ErrorWindow( "Ошибка установки номера!" )
                    return
                end

                if coupon_discount_value then 
                    client:TakeSpecialCouponDiscount( coupon_discount_value, "special_numberplate" ) 
                    triggerEvent( "onPlayerRequestDonateMenu", client, "special" )
                end

                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

				SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_auto_accessory_purchase" )

                return true, { cost = cost, name = params.name }
            end,
		},

        neon = {
            analytics_conf = {
                item_type = "neon",
                currency = "hard",
            },
            fn_call = function( self, id, params, client )
                local cost, coupon_discount_value = client:GetCostWithCouponDiscount( "special_neon", params.cost )
                if not client:TakeDonate( cost, "f4_special", "neon_" .. id ) then
                    client:ErrorWindow( "Недостаточно средств!" )
                    return
                end

                if coupon_discount_value then 
                    client:TakeSpecialCouponDiscount( coupon_discount_value, "special_neon" ) 
                    triggerEvent( "onPlayerRequestDonateMenu", client, "special" )
                end

                client:GiveNeon( { cost = cost * 1000, neon_image = id, sell_cost = math.floor( ( cost * 1000 ) * 0.2 ), takeoffs_count = 0 } )
                client:InfoWindow( "Неон успешно приобретен!\nТы можешь применить его в тюнинг ателье" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

                SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_auto_accessory_purchase" )

                return true, { cost = cost, name = params.name }
            end,
        },

		vinyl = {
            analytics_conf = {
                item_type = "vinyl",
                currency = "hard",
            },
			fn_call = function( self, id, params, client, vehicle )

                local cost, coupon_discount_value = client:GetCostWithCouponDiscount( "special_vinyl", params.cost )
                if client:GetDonate( ) < cost then
                    client:ErrorWindow( "Недостаточно средств!" )
                    return
                end

                client:TakeDonate( cost, "f4_special", "vinyl_" .. id )
                if coupon_discount_value then 
                    client:TakeSpecialCouponDiscount( coupon_discount_value, "special_vinyl" ) 
                    triggerEvent( "onPlayerRequestDonateMenu", client, "special" )
                end

				client:GiveVinyl({ 
                    [ P_PRICE_TYPE ] = "hard",
                    [ P_IMAGE ]      = id,
                    [ P_CLASS ]      = vehicle:GetTier( ),
                    [ P_NAME ]       = params.name,
                    [ P_PRICE ]      = cost,
                })
                client:InfoWindow( "Винил успешно приобретен!\nТы можешь применить его в тюнинг ателье" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

				SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_auto_accessory_purchase" )

                return true, { cost = cost, name = params.name }
            end,
		},
        
        pack = {
            analytics_conf = {
                item_type = "packs",
                currency = "hard",
            },

            fns_give = {
                vehicle = function( client, item )
                    local params = item.params
                    local owner_pid = "p:" .. client:GetUserID( )
                    local vehicle_conf	= {
                        model         = params.model               ,
                        variant       = params.variant or 1        ,
                        x             = 0                          ,
                        y             = 0                          ,
                        z             = 0                          ,
                        rx            = 0                          ,
                        ry            = 0                          ,
                        rz            = 0                          ,
                        owner_pid     = owner_pid                  ,
                        color         = params.color or { 255, 255, 255 },
                        first_owner   = owner_pid                  ,
                        showroom_cost = item.cost * 1000           ,
                        showroom_date = getRealTime( ).timestamp   ,
                    }
                    if params.tuning then
                        for k, v in pairs( params.tuning ) do
                            vehicle_conf[ k ] = v
                        end
                    end
                    exports.nrp_vehicle:AddVehicle( vehicle_conf, true, "onOfferedVehiclePurchaseCallback", { player = client, cost = item.cost * 1000 } )
                end,

                skin = function( client, item )
                    client:GiveSkin( item.params.model )
                end,

                accessory = function( client, item )
                    client:AddOwnedAccessory( item.params.model )
                end,

                dance = function( client, item )
                    client:AddDance( params.id )
                end,

                tuning_case = function( client, item )
                    local params = item.params
                    client:GiveTuningCase( params.id, VEHICLE_CLASSES_NAMES_REVERSE[ params.class ], tonumber( params.subtype ) or 1, params.count or 1 )
                end,
            },

            fn_call = function( self, id, params, client )
                local cost = params.cost
                if client:GetDonate( ) < cost then
                    triggerClientEvent( client, "onShopNotEnoughHard", client, "Special pack" )
                    return
                end

                local add_vehicle_count = 0
                local add_moto_count = 0
                for i, item in pairs( params.items ) do
                    if item.id == "vehicle" then
                        add_vehicle_count = add_vehicle_count + 1
                        if VEHICLE_CONFIG[ item.params.model ].is_moto then
                            add_moto_count = add_moto_count + 1
                        end
                    end
                end

                if add_vehicle_count > 0 then
                    if client.interior ~= 0 or client.dimension ~= 0 then
                        client:ErrorWindow( "Покупать машины можно только на улице, не находясь на задании!" )
                        return
                    end

                    if client:getData( "jailed" ) then
                        client:ErrorWindow( "В тюрьме нельзя делать покупки" )
                        return
                    end

                    if add_vehicle_count ~= add_moto_count and not client:HasFreeVehicleSlot( add_vehicle_count - add_moto_count ) then
                        triggerClientEvent( client, "onPlayerNotHaveSlotsForPurchase", resourceRoot )
                        return
                    end
                end
                
                local cost, coupon_discount_value = client:GetCostWithCouponDiscount( "special_pack", params.cost )
                client:TakeDonate( cost, "f4_special", "pack_" .. id )
                if coupon_discount_value then 
                    client:TakeSpecialCouponDiscount( coupon_discount_value, "special_pack" ) 
                    triggerEvent( "onPlayerRequestDonateMenu", client, "special" )
                end

                for i, item in pairs( params.items ) do
                    self.fns_give[ item.id ]( client, item )
                end

                client:InfoWindow( "Пак успешно приобретен!" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

				SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_pack_purchase" )

                return true, { cost = cost, name = params.analytics_name, model = "pack_" .. id }
            end,
        },

        pack_limit = {
            analytics_conf = {
                item_type = "pack_limit",
                currency = "hard",
            },

            fn_call = function( self, id, params, client )
                local cost = params.cost
                if client:GetDonate( ) < cost then
                    triggerClientEvent( client, "onShopNotEnoughHard", client, "Special pack limit" )
                    return
                end

                client:TakeDonate( cost, "f4_special", "pack_limit" )

                if params.items then
                    for item_type, item_params in pairs( params.items ) do
                        REGISTERED_ITEMS[ item_type ].rewardPlayer_func( client, item_params )
                    end
                else
                    REGISTERED_ITEMS[ id ].rewardPlayer_func( client, params.params )
                end

                client:InfoWindow( "Пак успешно приобретен!" )
                client:PlaySound( SOUND_TYPE_2D, "sfx/reward_big.wav" )

                triggerEvent( "onPlayerSomeDo", client, "buy_uniq_thing" ) -- achievements

				-- SendElasticGameEvent( client:GetClientID( ), "f4r_f4_unique_pack_purchase" )

                return true, { cost = cost, name = params.name }
            end,
        },
    },
}

function onMariaDBUpdate_handler( key, value )
    if key ~= "special_offers" then return end

    OFFERS_TABS.special.array = { }
    for i, offer in pairs( value or { } ) do
        offer.type = "special"
        offer.model = tonumber( offer.model ) or offer.model
        offer.name = offer.name ~= "" and offer.name or nil
        offer.cost_original = offer.cost_original or nil
        offer.limit_count = offer.limit_count or nil
        offer.start_date = offer.start_date and getTimestampFromString( offer.start_date ) or nil
        offer.finish_date = offer.finish_date and getTimestampFromString( offer.finish_date ) or nil
        offer.segment = offer.segment and fromJSON( offer.segment ) or nil

        local data = offer.data and fromJSON( offer.data ) or { }
        offer.data = nil
        for k, v in pairs( data ) do
            offer[ k ] = type( v ) == "table" and FixTableKeys( v, true ) or v
        end

        OFFERS_TABS.special.array[ offer.id ] = offer
    end
end
onMariaDBUpdate_handler( "special_offers", MariaGet( "special_offers" ) )
addEvent( "onMariaDBUpdate" )
addEventHandler( "onMariaDBUpdate", root, onMariaDBUpdate_handler )

function GetCurrentSegment( player )
    return ( PLAYER_SEGMENTS[ player ] or { } ).newest or 4
end

function GetAmountSegment( amount )
	for i, v in ipairs( SEGMENTS_AMOUNTS ) do
		if amount >= v then return i end
	end
end

function GetCurrentOffersList( ignore_specials )
    local available_offers = { }

    local timestamp = getRealTimestamp( )
    local function check_offer( offer )
        return  ( not offer.start_date or timestamp >= offer.start_date )
                and ( not offer.finish_date or timestamp <= offer.finish_date )
    end

    for offer_type, offer_list in pairs( OFFERS_TABS ) do
        for class, data in pairs( offer_list ) do
            for model, offer in pairs( table.copy( data.array or { } ) ) do
                if check_offer( offer ) then
                    offer.class = class
                    offer.model = model
                    offer.type  = offer_type
                    table.insert( available_offers, offer )
                end
            end
        end
    end

    if not ignore_specials then
        for i, offer in pairs( OFFERS_TABS.special.array ) do
            if check_offer( offer ) then
                table.insert( available_offers, offer )
            end
        end
    end

	return available_offers
end

function GetSuitableOffers( player )
	local available_offers = GetCurrentOffersList( )
    return FilterOffersBySegment( available_offers, ( PLAYER_SEGMENTS[ player ] or { } ).dates )
end

function GetOfferDiscountPriceForModel( offer_type, player, model, variant )
    for i, v in pairs( GetSuitableOffers( player ) ) do
        if v.model == model and v.type == offer_type then
            if not variant or not v.variant or v.variant == variant then
                return v.cost
            end
            return
        end
    end
end

function IsOfferActiveForModel( offer_type, player, model )
    for i, v in pairs( GetSuitableOffers( player ) ) do
        if v.type == offer_type and v.model == model then return true end
    end
end

function SyncPlayerPaymentSegments( player, force )
	local timestamp = getRealTimestamp()

	local available_offers = GetCurrentOffersList( )

	-- Ищем все даты начала оффера
	local start_dates = { }
	for i, v in pairs( available_offers ) do
		start_dates[ v.start_date or timestamp ] = true
	end

	-- Составляем уникальный список
	local start_dates_list = { }
	for i, v in pairs( start_dates ) do
		table.insert( start_dates_list, i )
	end

	if next( start_dates_list ) or force then
		local client_id = player:GetClientID( )

		local query_tbl = { }
		for i, v in pairs( start_dates_list ) do
			local query = CommonDB:prepare( "SELECT CAST(SUM(amount) AS UNSIGNED) as amount, ? AS target_date FROM payments WHERE date<=? AND client_id=?;", v, v, client_id )
			table.insert( query_tbl, query )
		end

		local query_str = table.concat( query_tbl, '' )
		CommonDB:queryAsync( function( query, player )
			if not isElement( player ) then
				dbFree( query )
				return
			end

            -- Получаем данные о возможном кастомном сегменте для игрока
            local segement_data = MariaGet( "segment_nums" )
            segement_data = segement_data and fromJSON( segement_data ) or {}
            local custom_segment = segement_data[ client_id ]

			local multiple_results = query:poll( -1, true )
			local segments_by_date = { }

            for i, result in pairs( type( multiple_results ) == "table" and multiple_results or { } ) do
				local rows = result[ 1 ]
				if rows then

					local row = rows[ 1 ]
                    if row then
                        -- Назначаем на все даты либо кастомный сегмент, либо реальный сегмент на дату внесения доната
						segments_by_date[ tonumber( row.target_date ) ] = custom_segment or GetAmountSegment( row.amount or 0 )
					end
				end
			end
            
            local offers = FilterOffersBySegment( GetCurrentOffersList( true ), segments_by_date )
            local newest_segment = #SEGMENTS_AMOUNTS
            if custom_segment then
                newest_segment = custom_segment
            else
                for i, v in pairs( segments_by_date ) do
                    newest_segment = math.min( newest_segment, v )
                end
            end

            triggerClientEvent( player, "onPlayerSyncOffers", resourceRoot, offers, segments_by_date, newest_segment )
            PLAYER_SEGMENTS[ player ] = nil

            local is_set_segment = not PLAYER_SEGMENTS[ player ]            
            PLAYER_SEGMENTS[ player ] = { newest = newest_segment, dates = segments_by_date }

            removeEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout )
            addEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout )

            if is_set_segment then
                triggerEvent( "onServerPlayerLoadOfferSegment", root, player, newest_segment )
            end
		end, { player }, query_str )
	else
		triggerClientEvent( player, "onClientPlayerSyncOffersFinish", player )
	end
end

function onPlayerPreLogout()
    PLAYER_SEGMENTS[ source ] = nil
end

function onPlayerLoadPaymentDetails_specialHandler( force )
    SyncPlayerPaymentSegments( source, force )
    -- Был рестарт ресурса
    if client then
        triggerClientEvent( source, "LoadSpecialOffers", resourceRoot, CONST_GET_SPECIAL_OFFERS_URL )
    end
end
addEvent( "onPlayerLoadPaymentDetails", true )
addEventHandler( "onPlayerLoadPaymentDetails", root, onPlayerLoadPaymentDetails_specialHandler )

addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, function( )
    triggerClientEvent( source, "LoadSpecialOffers", resourceRoot, CONST_GET_SPECIAL_OFFERS_URL )
end )

addEvent( "onFakeTimestampChange" )
addEventHandler( "onFakeTimestampChange", root, function( )
    for i, player in pairs( GetPlayersInGame( ) ) do
        SyncPlayerPaymentSegments( player )
    end
end )

-- Функция для тестеров [ iexe nrp_shop ChangeSegment( 1, 1 ) ]
function ChangeSegment( user_id, target_segment_id )
    local pPlayer = GetPlayer( tonumber( user_id ) )
    if not isElement( pPlayer ) then 
		iprint( "Invalid user id[1-N]: " .. tostring( user_id ) )
		return 
    end
    
    target_segment_id = tonumber( target_segment_id )
    if type( target_segment_id ) == "number" and (target_segment_id > 4 or target_segment_id < 1) then
        iprint( "Invalid segment id[1-4]: " .. tostring( target_segment_id ))
        return false
    elseif type( target_segment_id ) ~= "number" then 
        target_segment_id = nil
    end
    
    CommonDB:queryAsync( function( query, player, segment_id )
        if not isElement( player ) then
            dbFree( query )
            return
        end

        local result = query:poll( -1 )
        if not result then return end
        local segment_data = #result > 0 and fromJSON( result[ 1 ].cvalue ) or {}
        local is_ckey_exist = next( segment_data )

	    local client_id = player:GetClientID()
	    segment_data[ client_id ] = segment_id

        if is_ckey_exist then
            CommonDB:queryAsync( function( query, player )
                dbFree( query )
                if not isElement( player ) then return end
    
                setTimer( function()
                    if not isElement( player ) then return end
                    triggerEvent( "onPlayerLoadPaymentDetails", player, true )
                end, 5000, 1 )
            end, { player }, "UPDATE global_config SET cvalue=? WHERE ckey=? AND server=?", toJSON( segment_data ), "segment_nums", 0 )
        else
            CommonDB:queryAsync( function( query, player )
                dbFree( query )
                if not isElement( player ) then return end
    
                setTimer( function()
                    if not isElement( player ) then return end
                    triggerEvent( "onPlayerLoadPaymentDetails", player, true )
                end, 5000, 1 )
            end, { player }, "INSERT INTO global_config (ckey, cvalue, server, comment) VALUES (?, ?, ?, ?)", "segment_nums", toJSON( segment_data ), 0, "Кастомные сегменты" )
        end

        iprint( "Segment for player with ID[ " .. player:GetUserID() .. " ] is changed to [ " .. tostring( segment_id ) .. " ]" )
    end, { pPlayer, target_segment_id }, "SELECT cvalue FROM global_config WHERE ckey = ? AND server=?", "segment_nums", 0 )
end