function GetHouseMinMaxSaleCost( hid, house_type )
    local cost = 0

    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        local id, number = GetApartmentIdAndNumber( hid )
        local class = APARTMENTS_LIST[ id ].class
        local apart_conf = APARTMENTS_CLASSES[ class ]
        cost = apart_conf.cost
    else
        local vip_conf = VIP_HOUSES_REVERSE[ hid ]
        cost = vip_conf.cost
    end

    local expand_value = GetHouseInventoryExpandValue( hid, house_type )
    if expand_value and expand_value > 0 then
        local expand_cost = SHOP_SERVICES.inventory_house.cost * expand_value / SHOP_SERVICES.inventory_house.value
        cost = cost + expand_cost * 1000
    end

    local min_cost = math.floor( 0.75 * cost )
    local max_cost = math.floor( 3 * cost )

    return {
        min = min_cost,
        max = max_cost,
        default = cost,
    }
end

function GetHouseInventoryExpandValue( hid, house_type )
    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        local id, number = GetApartmentIdAndNumber( hid )
        return exports.nrp_apartment:GetApartmentsData( id, number, "inventory_expand" ) or 0
    else
        return exports.nrp_vip_house:GetVipHouseKeyByID( hid, "inventory_expand" ) or 0
    end
end

function GetHouseInventoryMaxWeight( hid, house_type )
    local default_inventory_max_weight
    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        local id, number = GetApartmentIdAndNumber( hid )
        local class = APARTMENTS_LIST[ id ].class
        default_inventory_max_weight = APARTMENTS_CLASSES[ class ].inventory_max_weight
    else
        default_inventory_max_weight = VIP_HOUSES_REVERSE[ hid ].inventory_max_weight
    end
    return default_inventory_max_weight + GetHouseInventoryExpandValue( hid, house_type )
end

function IsHouseInventoryEmpty( hid, house_type )
    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        local id, number = GetApartmentIdAndNumber( hid )
        return not next( exports.nrp_apartment:GetApartmentsData( id, number, "inventory_data" ) or {} )
    else
        return not next( exports.nrp_vip_house:GetVipHouseKeyByID( hid, "inventory_data" ) or {} )
    end
end

function FilterBy( location_id, house_type )
    local pHouseList = {}

    for _, v in pairs( HOUSE_SALES_DATA ) do
        if v.sale_state > 0
           and ( v.location_id == ( location_id or 1 ) or location_id == CONST_LOCATION.NONE )
           and v.house_type == ( house_type or CONST_HOUSE_TYPE.APARTMENT )
        then
            table.insert( pHouseList, {
                hid                     = v.hid,
                house_type              = v.house_type,
                seller_name             = exports.nrp_player_offline:GetOfflineDataFromUserID( v.seller_id, "nickname" ) or "-",
                seller_id               = v.seller_id,
                debt                    = v.total_rental_fee and v.total_rental_fee < 0 and v.total_rental_fee or 0,
                sale_cost               = v.sale_cost,
                possible_buyer_id       = v.possible_buyer_id,
                location_id             = v.location_id,
		        inventory_max_weight    = GetHouseInventoryMaxWeight( v.hid, v.house_type ),
            } )
        end
    end

    return pHouseList
end

-- Окно покупки недвижимости BuyUI
function onPlayerRequest_OnSaleHouseList_handler( location_id, house_type )
    local pHouseList = FilterBy( location_id, house_type )
    triggerClientEvent( client, "UpdateOnSaleHouseList", resourceRoot, pHouseList )
end
addEvent( "onPlayerRequestOnSaleHouseList", true )
addEventHandler( "onPlayerRequestOnSaleHouseList", resourceRoot, onPlayerRequest_OnSaleHouseList_handler )


-- Окно продажи недвижимости SaleUI
function onPlayerRequest_SelfHouseList_handler( )
    if not isElement( client ) then return end

    local pList = {}
    local pHouseList = GetPlayerHouseList( client )

    for k, v in pairs( pHouseList[ RESOURCE_APARTMENT ] or {} ) do
        local house_type = GetHouseTypeFromHID( v.hid )
        if v.sale_state == CONST_SALE_STATE.NOT_SALE then
            local total_rental_fee = v.paid_days * v.cost_day
            table.insert( pList, {
                hid                 = v.hid,
                house_type          = house_type,
                debt                = total_rental_fee < 0 and total_rental_fee or 0,
                cost                = GetHouseMinMaxSaleCost( v.hid, house_type ),
                is_inventory_empty  = IsHouseInventoryEmpty( v.hid, house_type ),
            } )
        end
    end

    for k, v in pairs( pHouseList[ RESOURCE_VIP_HOUSE ] or {} ) do
        local house_type = GetHouseTypeFromHID( v.hid )
        if v.sale_state == CONST_SALE_STATE.NOT_SALE then
            local total_rental_fee = v.paid_days * v.daily_cost
            table.insert( pList, {
                hid                 = v.hid,
                house_type          = house_type,
                debt                = total_rental_fee < 0 and total_rental_fee or 0,
                cost                = GetHouseMinMaxSaleCost( v.hid, house_type ),
                is_inventory_empty  = IsHouseInventoryEmpty( v.hid, house_type ),
            } )
        end
    end

    triggerClientEvent( client, "onFetchSelfHouseList", resourceRoot, pList )
end
addEvent( "onPlayerRequestSelfHouseList", true )
addEventHandler( "onPlayerRequestSelfHouseList", resourceRoot, onPlayerRequest_SelfHouseList_handler )


-- Игрок пробует оплатить недвижимость
function onPlayerTryPurchaseHouse_handler( hid )
    if not isElement( client ) then return end

    local pHouse = HOUSE_SALES_DATA[ hid ]

    if not pHouse then
        return client:ShowError( "Этого дома нет в продаже!" )
    end

    local buyer_id = client:GetUserID( )
    local seller_id = pHouse.seller_id

    if seller_id == buyer_id or IsPlayerHouseOwner( client, hid ) then
        return client:ShowError( "Нельзя покупать дом у самого себя!" )
    end

    if pHouse.sale_state == CONST_SALE_STATE.INDIVIDUAL_SALE and pHouse.possible_buyer_id ~= buyer_id then
        return client:ShowError( "Этот дом предназначен для другого игрока!" )
    end

    if client:GetMoney( ) < pHouse.sale_cost then
        return client:ShowError( "Не хватает средств на покупку недвижимости!" )
    end

    local cost = pHouse.sale_cost
    local house_type = GetHouseTypeFromHID( hid )
    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        triggerEvent( "onChangeApartmentOwner", resourceRoot, client, hid, cost, seller_id )
    else
        triggerEvent( "onChangeVipHouseOwner", resourceRoot, client, hid, cost, seller_id )
    end

end
addEvent( "onPlayerTryPurchaseHouse", true )
addEventHandler( "onPlayerTryPurchaseHouse", resourceRoot, onPlayerTryPurchaseHouse_handler )


-- Размещение недвижимости в продажу
function onPlayerTryPublishHouseSale_handler( hid, player_cost, target_name )
    if not isElement( client ) then return end

    local house_type = GetHouseTypeFromHID( hid )
    if not house_type then
        return client:ShowError( "Такого дома не существует!" )
    end

    local location_id = GetLocationIDFromHID( hid, house_type )
    if not location_id then
        return client:ShowError( "Такого дома не существует!" )
    end

    if not IsPlayerHouseOwner( client, hid, house_type ) then
        return client:ShowError( "Этот дом не принадлежит вам!" )
    end

    local cost = GetHouseMinMaxSaleCost( hid, house_type )
    if player_cost < cost.min then
        return client:ShowError( "Сумма продажи дома ниже минимального порога!" )
    elseif player_cost > cost.max then
        return client:ShowError( "Сумма продажи дома превышает максимальную стоимость!" )
    end

    local possible_buyer_id = nil
    if target_name then
        local players = GetPlayersInGame( )

        for _, player in pairs( players ) do
            if player:IsInGame( ) and player:GetNickName( ) == target_name then
                possible_buyer_id = player:GetUserID( )
                break
            end
        end

        if not possible_buyer_id then
            return client:ShowError( string.format( "Игрок с ником %s не найден", target_name ) )
        end
    end

    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        triggerEvent( "onPublishApartmentSale", resourceRoot, client, hid, player_cost, possible_buyer_id )
    else
        triggerEvent( "onPublishVipHouseSale", resourceRoot, client, hid, player_cost, possible_buyer_id )
    end

end
addEvent( "onPlayerTryPublishHouseSale", true )
addEventHandler( "onPlayerTryPublishHouseSale", resourceRoot, onPlayerTryPublishHouseSale_handler )


-- Отмена продажи недвижимости
function onPlayerCancelHouseSale_handler( hid )
    if not isElement( client ) then return end

    local house_type = GetHouseTypeFromHID( hid )

    if not IsPlayerHouseOwner( client, hid, house_type ) then
        return client:ShowError( "Этот дом не принадлежит вам!" )
    end

    if not HOUSE_SALES_DATA[ hid ] then
        return client:ShowError( "Этого дома нет в продаже!" )
    end

    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        triggerEvent( "onCancelApartmentSale", resourceRoot, client, hid )
    else
        triggerEvent( "onCancelVipHouseSale", resourceRoot, client, hid )
    end

end
addEvent( "onPlayerCancelHouseSale", true )
addEventHandler( "onPlayerCancelHouseSale", resourceRoot, onPlayerCancelHouseSale_handler )
