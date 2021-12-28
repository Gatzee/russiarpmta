function GetItemPrice( item, vehicle )
    local class, value = unpack( item )

    local vehicle = vehicle or DATA and DATA.vehicle
    local vehicle_cost = vehicle:GetPrice( DATA and DATA.variant )

    local items_convert = {

        [ TUNING_TASK_COLOR ] = function( item, vehicle, vehicle_cost )
            local tiers_coeffs = TUNING_PARAMS[ TUNING_TASK_COLOR ]
            local cost = vehicle_cost * tiers_coeffs[ vehicle:GetTier( ) ]
            return cost
        end,

        [ TUNING_TASK_LIGHTSCOLOR ] = function( item, vehicle, vehicle_cost )
            local tiers_coeffs = TUNING_PARAMS[ TUNING_TASK_LIGHTSCOLOR ]
            local cost = vehicle_cost * tiers_coeffs[ vehicle:GetTier( ) ]
            return cost
        end,
        
        [ TUNING_TASK_TONING ] = function( item, vehicle, vehicle_cost )
            local coeffs = { }
            for i, v in pairs( TUNING_PARAMS[ TUNING_TASK_TONING ] ) do
                if v.Level == item[ 2 ] then
                    coeffs = v.Price
                    break
                end
            end
            return vehicle_cost * coeffs[ vehicle:GetTier( ) ]
        end,

        [ TUNING_TASK_WHEELS ] = function( item, vehicle, vehicle_cost )
            if not item[ 2 ] then return 0 end
            for i, v in ipairs( TUNING_PARAMS[ TUNING_TASK_WHEELS ] ) do
                if v.Level == item[ 2 ] then
                    return v.Price
                end
            end
        end,

        [ TUNING_TASK_WHEELS_EDIT ] = function( item, vehicle, vehicle_cost )
            return vehicle_cost * TUNING_PARAMS[ TUNING_TASK_WHEELS_EDIT ][ vehicle:GetTier( ) ]
        end,

        [ TUNING_TASK_WHEELS_COLOR ] = function( item, vehicle, vehicle_cost )
            return vehicle_cost * TUNING_PARAMS[ TUNING_TASK_WHEELS_COLOR ][ vehicle:GetTier( ) ]
        end,

        [ TUNING_TASK_HYDRAULICS ] = function( item, vehicle, vehicle_cost )
            if item[ 2 ] == true then
                local coeffs = TUNING_PARAMS[ TUNING_TASK_HYDRAULICS ]
                return vehicle_cost * coeffs[ vehicle:GetTier( ) ]
            else
                return 0
            end
        end,

        [ TUNING_TASK_SUSPENSION ] = function( item, vehicle, vehicle_cost )
            local coeffs = TUNING_PARAMS[ TUNING_TASK_SUSPENSION ]
            return vehicle_cost * coeffs[ item[ 2 ] ][ vehicle:GetTier( ) ]
        end,

        [ TUNING_TASK_NUMBERS ] = function( item, vehicle, vehicle_cost )
            return item[2][2]
        end,
        
    }

    -- Покупка статических или динамических элементов
    if items_convert[ class ] then
        if type( items_convert[ class ] ) == "number" then
            return math.floor( items_convert[ class ] )

        elseif type( items_convert[ class ] ) == "function" then
            local result = items_convert[ class ]( item, vehicle, vehicle_cost )
            return result and math.floor( result )

        end

    -- Покупка компонентов
    elseif TUNING_IDS[ class ] then
        local vehicle_model = getElementModel( vehicle )
        local components = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].custom_tuning
        local components_list = components[ class ]
        local component = components_list[ value ]
        return math.floor( component.cost or 0 )

    end
end

-- Применяет скидку ко всему тюнингу, в том числе и на тюнинг кейсы
function ApplyDiscount( cost, player )
    player = localPlayer or player
    return cost and math.ceil( cost * ( 1 - player:GetClanBuffValue( CLAN_UPGRADE_TUNING_DISCOUNT ) / 100 ) )
end

function CartGetCalculated( cart, player, vehicle )
    local items = cart or UI_elements and UI_elements.cart or { }

    local calculated_price = 0
    local calculated_items = { }

    for i, v in ipairs( items ) do
        local price = ApplyDiscount( GetItemPrice( v, vehicle ), player )
        if price then
            table.insert( calculated_items, { item = v, price = price } )
            calculated_price = calculated_price + price

        else
            table.insert( calculated_items, { item = v, price = 0 } )
        end
    end

    return calculated_items, calculated_price
end

function getSellPriceOfPart( part, damaged )
    local price = part.price

    if damaged then
        price = math.floor( price * 0.05 )
    else
        price = math.floor( price * 0.2 )
    end

    return price
end
