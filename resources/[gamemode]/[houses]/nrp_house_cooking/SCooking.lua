loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShSocialRating" )

PLAYER_RECIPES = { }
PLAYER_INGREDIENTS = { }
PLAYER_ORDERS = { }
PLAYER_ORDER_TIMERS = { }

function GiveRecipe( player, recipe_id )
    if PLAYER_RECIPES[ player ][ recipe_id ] then return end
    PLAYER_RECIPES[ player ][ recipe_id ] = true
    player:SetPermanentData( "food_recipes", PLAYER_RECIPES[ player ] )
    
    player:ShowInfo( "Вы получили рецепт блюда " .. RECIPES[ recipe_id ].name )
end

function GiveIngredient( player, id, count )
    local ingredients = PLAYER_INGREDIENTS[ player ]
    ingredients[ id ] = ( ingredients[ id ] or 0 ) + count
    player:SetPermanentData( "food_ingredients", ingredients )
end

--[[function CollectPlayerFoodDiscount( player )
    local total_discount = 0
    if WEDDING_FOOD_COOKING_DISCOUNT_ENABLED then
        if player:GetPermanentData( "wedding_at_id" ) then
            total_discount = total_discount + WEDDING_FOOD_COOKING_DISCOUNT
        end
    end
    return total_discount
end]]

function Player:ShowCookingUI( )
    self:triggerEvent( "onClientShowCookingUI", self, PLAYER_RECIPES[ self ], PLAYER_INGREDIENTS[ self ] )
end

addEvent( "onPlayerWantShowCookingUI", true )
addEventHandler( "onPlayerWantShowCookingUI", root, function( )
    source:ShowCookingUI( )
end ) 

addEvent( "onPlayerWantBuyRecipe", true )
addEventHandler( "onPlayerWantBuyRecipe", root, function( recipe_id )
    if PLAYER_RECIPES[ source ][ recipe_id ] then
        source:ShowError( "У вас уже имеется этот рецепт" )
        return
    end
    if source:TakeDonate( RECIPES[ recipe_id ].hard_cost, "recipe_purchase" ) then
        GiveRecipe( source, recipe_id )
        source:ShowCookingUI( )
    else
        source:ShowError( "Недостаточно средств" )
    end
end ) 

addEvent( "onPlayerWantOrderIngredients", true )
addEventHandler( "onPlayerWantOrderIngredients", root, function( data )
    local timestamp = getRealTimestamp( )
    local last_order_timestamp = source:GetPermanentData( "last_food_order_ts" ) or 0

    if timestamp - last_order_timestamp < ORDER_COOLDOWN then
        local time_left_str = getHumanTimeString( last_order_timestamp + ORDER_COOLDOWN, true )
        source:ShowError( "Вы сможете сделать новый заказ через " .. time_left_str )
        return
    end

    local total_cost = 0
    for i, v in pairs( data ) do
        local ingredient_id = v[ 1 ]
        local count = v[ 2 ]
        total_cost = total_cost + GetIngerdientCost( ingredient_id, source ) * count
    end

    if source:GetMoney( ) < total_cost then
        source:ShowError( "Недостаточно денег" )
        return
    end

    local orders = PLAYER_ORDERS[ source ]
    for _, v in pairs( data ) do
        local ingredient_id = v[ 1 ]
        local ingredient_data = FOOD_INGREDIENTS[ ingredient_id ]
        v[ 3 ] = timestamp + ingredient_data.delivery_time

        local order_id = #orders + 1
        for i = 1, order_id - 1 do
            if not orders[ i ] then
                order_id = i
                break
            end
        end
        orders[ order_id ] = v

        SetOrderTimer( source, order_id, ingredient_data.delivery_time )
    end
    source:SetPermanentData( "food_orders", orders )
    source:SetPermanentData( "last_food_order_ts", timestamp )
    source:TakeMoney( total_cost )
    source:ShowSuccess( "Вы успешно заказали продукты" )
end )

function SetOrderTimer( player, order_id, time )
    PLAYER_ORDER_TIMERS[ player ][ order_id ] = Timer(
        FinishOrder, 
        time * 1000, 1, 
        player, order_id
    )
end

function FinishOrder( player, order_id )
    local orders = PLAYER_ORDERS[ player ]
    local order_data = orders[ order_id ]
    local ingredient_id = order_data[ 1 ]
    local ordered_count = order_data[ 2 ]
    GiveIngredient( player, ingredient_id, ordered_count )

    orders[ order_id ] = nil
    player:SetPermanentData( "food_orders", orders )
    PLAYER_ORDER_TIMERS[ player ][ order_id ] = nil

    player:triggerEvent( "onClientFoodOrderFinish", player, ingredient_id, ordered_count )
end

addEvent( "onPlayerWantCookDish", true )
addEventHandler( "onPlayerWantCookDish", root, function( dish_id )
    local last_cooking_timestamp = source:GetPermanentData( "last_cooking_ts" ) or 0

    if getRealTimestamp( ) - last_cooking_timestamp < COOKING_COOLDOWN then
        local time_left_str = getHumanTimeString( last_cooking_timestamp + COOKING_COOLDOWN, true )
        source:ShowError( "Вы сможете заняться готовкой через " .. time_left_str )
        return
    end

    source:triggerEvent( "onClientStartCookingMinigame", source, dish_id )
end )

addEvent( "onPlayerCookDishFinish", true )
addEventHandler( "onPlayerCookDishFinish", root, function( dish_id )
    local player_ingredients = PLAYER_INGREDIENTS[ source ]
    local dish_ingredients = RECIPES[ dish_id ].ingredients
    
    for i, v in pairs( dish_ingredients ) do
        local ingredient_id = v[ 1 ]
        local need_count = v[ 2 ]
        local have_count = player_ingredients[ ingredient_id ] or 0
        if have_count < need_count then
            source:ErrorWindow( "Не хватает ингредиентов для приготовления" )
            source:ShowCookingUI( )
            return
        end
    end
    
    for i, v in pairs( dish_ingredients ) do
        local ingredient_id = v[ 1 ]
        local need_count = v[ 2 ]
        player_ingredients[ ingredient_id ] = ( player_ingredients[ ingredient_id ] or 0 ) - need_count
    end
    source:SetPermanentData( "food_ingredients", player_ingredients )
    source:SetPermanentData( "last_cooking_ts", getRealTimestamp( ) )

    source:InventoryAddItem( FOOD_DISHES[ dish_id ].in_item_id, 1 )
    source:ShowSuccess( "Вы успешно приготовили " .. FOOD_DISHES[ dish_id ].name )
    source:ChangeSocialRating( SOCIAL_RATING_RULES.cooking.rating )

    triggerEvent( "onPlayerCookDish", source, dish_id )
end )

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source

    local data = player:GetBatchPermanentData( "food_recipes", "food_ingredients", "food_orders" )
    PLAYER_RECIPES[ player ] = FixTableKeys( data.food_recipes ) or { }
    PLAYER_INGREDIENTS[ player ] = FixTableKeys( data.food_ingredients ) or { }
    PLAYER_ORDERS[ player ] = FixTableKeys( data.food_orders ) or { }
    PLAYER_ORDER_TIMERS[ player ] = { }

    local timestamp = getRealTimestamp( )
    for order_id, order_data in pairs( PLAYER_ORDERS[ player ] ) do
        local remaining_time = order_data[ 3 ] - timestamp
        if remaining_time > 0 then
            SetOrderTimer( player, order_id, remaining_time )
        else
            FinishOrder( player, order_id )
        end
    end

    if player:GetLevel( ) >= 5 then
        GiveRecipe( player, FOOD_SALAD )
        GiveRecipe( player, FOOD_CHEESE_SANDWICH )

        if player:GetLevel( ) >= 10 then
            GiveRecipe( player, FOOD_OMELETTE )
        end
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

addEventHandler( "onResourceStart", resourceRoot, function( )
    for i, v in pairs( GetPlayersInGame( ) ) do
        onPlayerReadyToPlay_handler( v )
    end
end )

addEventHandler( "OnPlayerLevelUp", root, function( level )
    -- Не был вызван onPlayerReadyToPlay_handler
    if not PLAYER_RECIPES[ source ] then return end
    if level == 5 then
        GiveRecipe( source, FOOD_SALAD )
        GiveRecipe( source, FOOD_CHEESE_SANDWICH )
    elseif level == 10 then
        GiveRecipe( source, FOOD_OMELETTE )
    end
end )

addEvent( "HB:OnPlayerSellItems", true )
addEventHandler( "HB:OnPlayerSellItems", root, function( hobby_id, weight, sales_count )
    if hobby_id == HOBBY_HUNTING then
        if sales_count >= 20 then
            GiveRecipe( source, FOOD_SOUP )
        elseif sales_count >= 10 then
            GiveRecipe( source, FOOD_NAVY_PASTA )
        end
    elseif hobby_id == HOBBY_FISHING then
        if sales_count >= 10 then
            GiveRecipe( source, FOOD_UKHA )
            GiveRecipe( source, FOOD_FISH_WITH_VEGETABLES )
        end
    end
end )

addEvent( "HB:OnPlayerReceiveItem", true )
addEventHandler( "HB:OnPlayerReceiveItem", root, function( hobby_id )
    if math.random( ) > 0.3 then return end
    
    if hobby_id == HOBBY_HUNTING then
        GiveIngredient( source, FOOD_INGREDIENTS_REVERSE[ "meat" ], 1 )
        source:ShowInfo( "Вы получили мясо для приготовления еды" )

    elseif hobby_id == HOBBY_FISHING then
        GiveIngredient( source, FOOD_INGREDIENTS_REVERSE[ "fish" ], 1 )
        source:ShowInfo( "Вы получили рыбу для приготовления еды" )
    end
end )

addEventHandler( "onPlayerPreLogout", root, function( data )
    PLAYER_RECIPES[ source ] = nil
    PLAYER_INGREDIENTS[ source ] = nil
    PLAYER_ORDERS[ source ] = nil

	if PLAYER_ORDER_TIMERS[ source ] then
		for i, v in pairs( PLAYER_ORDER_TIMERS[ source ] ) do
			if isTimer( v ) then
				killTimer ( v )
			end
		end
		PLAYER_ORDER_TIMERS[ source ] = nil
	end
end )