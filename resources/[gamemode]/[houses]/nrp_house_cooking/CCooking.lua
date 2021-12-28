loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "ib" )

PLAYER_RECIPES = { }
PLAYER_INGREDIENTS = { }

addEvent( "onClientShowCookingUI", true )
addEventHandler( "onClientShowCookingUI", root, function( recipes, ingredients )
    PLAYER_RECIPES = recipes
    PLAYER_INGREDIENTS = ingredients

    ShowCookingUI( )
end )

addEvent( "onClientFoodOrderFinish", true )
addEventHandler( "onClientFoodOrderFinish", root, function( id, count )
    PLAYER_INGREDIENTS[ id ] = ( PLAYER_INGREDIENTS[ id ] or 0 ) + count
    localPlayer:ShowInfo( "Ваш заказ (" .. FOOD_INGREDIENTS[ id ].name .. ", " .. count .. " шт.) доставлен" )

    if UI then
        UpdateCookingUI( )
    end
end )

local is_cooking_minigame_started = false

function StartCookingMinigame( dish_id )
    if is_cooking_minigame_started then return end
    is_cooking_minigame_started = true

    local recipe = RECIPES[ dish_id ]

    function OnCookingComplete( )
        is_cooking_minigame_started = false
        triggerServerEvent( "onPlayerCookDishFinish", localPlayer, recipe.id )

        for i, v in pairs( recipe.ingredients ) do
            local ingredient_id = v[ 1 ]
            local need_count = v[ 2 ]
            PLAYER_INGREDIENTS[ ingredient_id ] = ( PLAYER_INGREDIENTS[ ingredient_id ] or 0 ) - need_count
        end
        UpdateCookingUI( )
    end

    MINIGAMES[ recipe.class ][ 1 ]( )
end
addEvent( "onClientStartCookingMinigame", true )
addEventHandler( "onClientStartCookingMinigame", root, StartCookingMinigame )

MINIGAMES = {
    [ 1 ] = {
        [ 1 ] = function(  )
            ibInfoPressKeyProgress( {
                do_text = "Нажимай",
                text = "чтобы нарезать ингредиенты",
                key = "mouse2",
                black_bg = 0x80495f76,
                click_count = 10,
                end_handler = MINIGAMES[ 1 ][ 2 ],
            } )
        end,

        [ 2 ] = function( )
            ibInfoPressKeyZone( {
                do_text = "Нажми",
                text = "чтобы перемешать",
                key = "mouse1",
                black_bg = 0x80495f76,
                click_count = 1,
                end_handler = MINIGAMES[ 1 ][ 3 ],
            } )
        end,

        [ 3 ] = function( )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы положить еду в контейнер";
                key = "mouse1",
                key_state = "down",
                black_bg = 0x80495f76,
                key_handler = OnCookingComplete,
            } )
        end,
    },

    [ 2 ] = {
        [ 1 ] = function(  )
            ibInfoPressKeyCircle( {
                do_text = "Нажми",
                text = "чтобы положить ингредиенты",
                key = "mouse1",
                black_bg = 0x80495f76,
                end_handler = MINIGAMES[ 2 ][ 2 ],
            } )
        end,

        [ 2 ] = function( )
            ibInfoPressKeyProgress( {
                do_text = "Нажимай",
                text = "чтобы перемешать",
                key = "mouse2",
                black_bg = 0x80495f76,
                click_count = 10,
                end_handler = MINIGAMES[ 2 ][ 3 ],
            } )
        end,

        [ 3 ] = function( )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы положить еду в контейнер";
                key = "mouse1",
                black_bg = 0x80495f76,
                key_handler = OnCookingComplete,
            } )
        end,
    },

    [ 3 ] = {
        [ 1 ] = function(  )
            ibInfoHoldArrowInRegion( {
                text = "Удерживай стрелку, чтобы положить ингридиенты",
                black_bg = 0x80495f76,
                callback = MINIGAMES[ 3 ][ 2 ],
            } )
        end,

        [ 2 ] = function( )
            ibInfoPressKeyProgress( {
                do_text = "Нажимай",
                text = "чтобы перемешать",
                key = "mouse2",
                black_bg = 0x80495f76,
                click_count = 10,
                end_handler = MINIGAMES[ 3 ][ 3 ],
            } )
        end,

        [ 3 ] = function( )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы положить еду в контейнер";
                key = "mouse1",
                black_bg = 0x80495f76,
                key_handler = OnCookingComplete,
            } )
        end,
    },
}