loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

function onPlayerFoodPurchase_handler( id, coef )
    local player = client

    local food = FOOD_LIST[ id ]
    if not food then return end

    local cost = math.floor( food.cost * ( coef or 1 ) )
    local calories = food.calories

    if cost > player:GetMoney() then
        player:ShowError( "Недостаточно средств!" )
        return
    end

    player:TakeMoney( cost, "food_purchase" )

    player:CompleteDailyQuest( "buy_eat" )

    if food.inventory then
        player:InventoryAddItem( IN_FOOD_LUNCHBOX, 1 )
        return
    end

    local new_calories = player:GetCalories( ) + calories

    if new_calories < 100 or not player:Puke( true ) then
        player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy_product.wav" )
        player:SetCalories( new_calories )
        player:ShowInfo( new_calories < 100 and "Спасибо за покупку! Хотите еще?" or "Спасибо за покупку!" )
    end
    triggerEvent( "onPlayerEat", player, cost, id, food.name )
end
addEvent( "onPlayerFoodPurchase", true )
addEventHandler( "onPlayerFoodPurchase", root, onPlayerFoodPurchase_handler )