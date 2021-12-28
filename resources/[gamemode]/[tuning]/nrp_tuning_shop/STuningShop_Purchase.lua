-- У некоторых деталей нет строчного индекса
local ANALYTICS_ITEM_NAME =
{
    [ TUNING_TASK_COLOR ]  = "body_color",
    [ TUNING_TASK_LIGHTSCOLOR ]  = "light_color",
    [ TUNING_TASK_TONING ]  = "tinting",
    [ TUNING_TASK_HYDRAULICS ]  = "suspension_hydr",
    [ TUNING_TASK_SUSPENSION ] = "suspension",
    [ TUNING_TASK_WHEELS ] = "wheels",
    [ TUNING_TASK_WHEELS_EDIT ] = "wheels_edit",
    [ TUNING_TASK_WHEELS_COLOR ] = "wheels_paintig",
    [ TUNING_TASK_NUMBERS ] = "plate",
}

local ITEM_VALUE_TO_ANAL_DATA = {
    [ TUNING_TASK_TONING ] = { },
    [ TUNING_TASK_SUSPENSION ] = {
        [ 0 ] = "_stock",
        [ 1 ] = "_low",
        [ 2 ] = "_high",
    },
}
for i, v in pairs( TUNING_PARAMS[ TUNING_TASK_TONING ] ) do
    ITEM_VALUE_TO_ANAL_DATA[ TUNING_TASK_TONING ][ v.Level ] = "_" .. ( v.Name:match( "%d+") or "stock" )
end

function onTuningShopCartPurchase_handler( cart )
	local player = client or source
	if not player then return end

    local vehicle = player.vehicle
    if not vehicle or vehicle ~= player:getData( "tuning_vehicle" ) then return end

    if not cart then return end

    local items, total_price = CartGetCalculated( cart, player, vehicle )

    if player:GetMoney( ) < total_price then
        player:EnoughMoneyOffer( "Tuning shop cart", total_price, "onTuningShopCartPurchase", player, cart )
        return
    end

    local new_values = { }
    local analytics_table = { }
    local newExternalTuningValues = { }
    local applied_tasks = { }

    for i, v in pairs( cart ) do
        local class, value = unpack( v )
        local cart_data = items[ i ]

        if TUNING_IDS[ class ] then -- external tuning
            local component_id = TUNING_IDS[ class ]
            newExternalTuningValues[ component_id ] = value
            triggerEvent( "onPlayerBuyTuning", player, vehicle, "visual_component_" .. class, cart_data.price )
        else -- any other tuning
            local new_key, new_value = ApplyPurchasedTuning( vehicle, class, value, player, cart_data, applied_tasks )
            if new_key and new_value then
                new_values[ new_key ] = new_value
            end
        end

        if cart_data.price > 0 then
            local anal_data = ITEM_VALUE_TO_ANAL_DATA[ class ]
            table.insert( analytics_table, {
                item_name = tostring( type( class ) == "string" and class or (ANALYTICS_ITEM_NAME[ class ] or class) ) .. ( anal_data and anal_data[ value ] or "" ),
                item_cost = tonumber( cart_data.price ),
                currency  = "soft",
            })
        end

        applied_tasks[ class ] = true
    end

    if next( newExternalTuningValues ) then
        vehicle:SetExternalTuningValues( newExternalTuningValues )
    end

    player:TakeMoney( total_price, "tuning_cart_purchase" )
    triggerClientEvent( player, "onTuningShopCartPurchaseCallback", player, true, new_values )

    if #analytics_table > 0 then
        SendElasticGameEvent( player:GetClientID(), "tuning_cart_items", { items = toJSON( analytics_table ) } )
    end
end
addEvent( "onTuningShopCartPurchase", true )
addEventHandler( "onTuningShopCartPurchase", root, onTuningShopCartPurchase_handler )

function ApplyPurchasedTuning( vehicle, class, value, player, cart_data, applied_tasks )
    local analytics_names = {
        [ TUNING_TASK_COLOR ]              = "color",
        [ TUNING_TASK_LIGHTSCOLOR ]        = "headlights_color",
        [ TUNING_TASK_TONING ]             = "toning",
        [ TUNING_TASK_BLACKMARKET_TONING ] = "blackmarket_toning",
        [ TUNING_TASK_WHEELS ]             = "wheels",
        [ TUNING_TASK_WHEELS_EDIT ]        = "wheels_edit",
        [ TUNING_TASK_WHEELS_COLOR ]       = "wheels_paintig",
        [ TUNING_TASK_HYDRAULICS ]         = "hydraulics",
        [ TUNING_TASK_SUSPENSION ]         = "suspension",
    }

    -- Цвет машины
    if class == TUNING_TASK_COLOR then
        vehicle:SetColor( unpack( value ) )
        local vinyl_list = vehicle:GetVinyls()
        if next( vinyl_list ) then
            player:RefreshInstalledVinyls()
        end
        triggerClientEvent( player, "onTuningChangeOriginalColor", resourceRoot, value )

    -- Цвет фар
    elseif class == TUNING_TASK_LIGHTSCOLOR then
        vehicle:SetHeadlightsColor( unpack( value ) )

    -- Уровень тонировки
    elseif class == TUNING_TASK_TONING then
        local r, g, b = unpack( vehicle:GetWindowsColor() )
        a = value
        vehicle:SetWindowsColor( r, g, b, a )

    -- Цвет тонировки в черном рынке
    elseif class == TUNING_TASK_BLACKMARKET_TONING then
        local _, _, _, a = unpack( vehicle:GetWindowsColor() )
        local r, g, b = unpack( value )
        vehicle:SetWindowsColor( r, g, b, a )

    -- Выбор колёс
    elseif class == TUNING_TASK_WHEELS then
        vehicle:SetWheels( value )
        -- Сбрасываем измененные настройки при смене колёс
        if not applied_tasks[ TUNING_TASK_WHEELS_EDIT ] then
            vehicle:SetWheelsWidth( 0 )
            vehicle:SetWheelsOffset( 0 )
            vehicle:SetWheelsCamber( 0 )
        end

        if not applied_tasks[ TUNING_TASK_WHEELS_COLOR ] then
            vehicle:SetWheelsColor()
        end

    -- Изменение колёс
    elseif class == TUNING_TASK_WHEELS_EDIT then
        vehicle:SetWheelsWidth( unpack( value.width ) )
        vehicle:SetWheelsOffset( unpack( value.offset ) )
        vehicle:SetWheelsCamber( unpack( value.camber ) )

    -- Покраска колёс
    elseif class == TUNING_TASK_WHEELS_COLOR then
        vehicle:SetWheelsColor( unpack( value ) )
        triggerClientEvent( player, "onTuningChangeWheelsColor", resourceRoot, value )
        
    -- Гидравлика
    elseif class == TUNING_TASK_HYDRAULICS then
        if value then vehicle:SetHeightLevel( 0 ) end
        vehicle:SetHydraulics( value )

    -- Занижение машины
    elseif class == TUNING_TASK_SUSPENSION then
        if value then vehicle:SetHydraulics( false ) end
        vehicle:SetHeightLevel( value )
        return "height_level", vehicle:GetHeightLevel()

    -- Номера
    elseif class == TUNING_TASK_NUMBERS then
        if value then 
            triggerEvent( "OnPlayerTryBuyNumberPlate", player, vehicle, value[1] )
        end
        return "numbers", vehicle:GetNumberPlate()

    end

    if analytics_names[ class ] then
        triggerEvent( "onPlayerBuyTuning", player, vehicle, analytics_names[ class ], cart_data.price )
    end
end

-- Цвет номеров применяем сразу
function onNumberplateColorApplyRequest_handler( color )
    local player = client
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    local is_black_tuning_enabled = false

    if player then
        local data = player:GetBatchPermanentData( "vehicle_access_sub_id", "vehicle_access_sub_time" )
        is_black_tuning_enabled = ( data.vehicle_access_sub_id or 0 ) == vehicle:GetID( )
        is_black_tuning_enabled = is_black_tuning_enabled and player:IsPremiumActive()
    end

    if is_black_tuning_enabled then -- TODO убрать для релиза // Зачем?
        vehicle:ApplyNumberPlateColor( color )
        vehicle:SetPermanentData( "black_platecolor", color )
    end
end
addEvent( "onNumberplateColorApplyRequest", true )
addEventHandler( "onNumberplateColorApplyRequest", root, onNumberplateColorApplyRequest_handler )

function onWindowsColorApplyRequest_handler( r, g, b, a )
    local player = client
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    local is_black_tuning_enabled = false

    if player then
        local data = player:GetBatchPermanentData( "vehicle_access_sub_id", "vehicle_access_sub_time" )
        is_black_tuning_enabled = ( data.vehicle_access_sub_id or 0 ) == vehicle:GetID( )
        is_black_tuning_enabled = is_black_tuning_enabled and player:IsPremiumActive()
    end

    if is_black_tuning_enabled then -- TODO убрать для релиза // Зачем?
        vehicle:SetWindowsColor( r, g, b, a )
    end
end
addEvent( "onWindowsColorApplyRequest", true )
addEventHandler( "onWindowsColorApplyRequest", root, onWindowsColorApplyRequest_handler )

function onBlackTuningResetRequest_handler( alpha )
    local player = client
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    if vehicle:HasBlackTuning( ) then
        vehicle:ResetBlackTuning( alpha )
        player:InfoWindow( "Черный тюнинг успешно сброшен!" )
        triggerClientEvent( player, "onBlackTuningResetCallback", resourceRoot, alpha )

    else
        player:ErrorWindow( "Черный тюнинг не установлен на этой машине!" )

    end
end
addEvent( "onBlackTuningResetRequest", true )
addEventHandler( "onBlackTuningResetRequest", root, onBlackTuningResetRequest_handler )