Extend( "ShFood" )
Extend( "ShHobby" )
Import( "ShWedding" )

COOKING_COOLDOWN = 15 * 60

ORDER_COOLDOWN = 60 * 60
MAX_ORDER_ITEM_COUNT = 3

FOOD_INGREDIENTS = {
    { sid = "cucumber",    name = "Огурец",      cost = 50,  delivery_time = 60 * 25,  max_count = 10 },
    { sid = "tomato",      name = "Помидор",     cost = 50,  delivery_time = 60 * 25,  max_count = 10 },
    { sid = "condiment",   name = "Приправа",    cost = 5,   delivery_time = 60 * 2.5, max_count = 10 },
    { sid = "carrot",      name = "Морковь",     cost = 30,  delivery_time = 60 * 15,  max_count = 10 },
    { sid = "potato",      name = "Картофель",   cost = 20,  delivery_time = 60 * 10,  max_count = 10 },
    { sid = "onion",       name = "Лук",         cost = 20,  delivery_time = 60 * 10,  max_count = 10 },
    { sid = "pasta",       name = "Макароны",    cost = 70,  delivery_time = 60 * 35,  max_count = 10 },
    { sid = "egg",         name = "Яйцо",        cost = 30,  delivery_time = 60 * 15,  max_count = 10 },
    { sid = "spaghetti",   name = "Спагетти",    cost = 80,  delivery_time = 60 * 40,  max_count = 10 },
    { sid = "cheese",      name = "Сыр",         cost = 60,  delivery_time = 60 * 30,  max_count = 10 },
    { sid = "cream",       name = "Сливки",      cost = 60,  delivery_time = 60 * 30,  max_count = 10 },
    { sid = "bread",       name = "Хлеб",        cost = 20,  delivery_time = 60 * 10,  max_count = 10 },
    { sid = "meat",        name = "Мясо",        tooltip = "Есть 30% шанс получить, снимая шкуру с животного" },
    { sid = "fish",        name = "Рыба",        tooltip = "Есть 30% шанс получить, поймав рыбу" },
}

function GetIngerdientCost( ingredient_id, player )
    local cost = FOOD_INGREDIENTS[ ingredient_id ].cost
    if cost and WEDDING_FOOD_COOKING_DISCOUNT_ENABLED and ( localPlayer or player ):getData( "wedding_at_id" ) then
        return math.floor( cost * ( 1 - WEDDING_FOOD_COOKING_DISCOUNT / 100 ) )
    else
        return cost
    end
end

FOOD_INGREDIENTS_REVERSE = { }
for i, v in pairs( FOOD_INGREDIENTS ) do
	FOOD_INGREDIENTS_REVERSE[ v.sid ] = i
end

RECIPES = {
    [ FOOD_SALAD ] = {
        class = 1,
        description = "Увеличивает время до голода на 30 минут.",
        how_get_text = "По достижению уровня 5",
        ingredients = {
            { "cucumber", 1 },
            { "tomato", 1 },
            { "condiment", 1 },
        },
    },

    [ FOOD_SOUP ] = {
        class = 3,
        description = "Увеличивает время до голода на 60 минут.\n"
                    .."Восстанавливает выносливость в течении 10 минут \n"
                    .."за каждую 1 секунду по 5 ед.\n"
                    .."Восстанавливает жизни в течении 10 минут \n"
                    .."каждые 5 сек по 10 ед.",
        how_get_text = "На 20 продаже добычи с охоты",
        ingredients = {
            { "carrot", 1 },
            { "potato", 1 },
            { "meat", 1 },
            { "onion", 1 },
            { "condiment", 1 },
        },
    },

    [ FOOD_NAVY_PASTA ] = {
        class = 2,
        description = "Увеличивает время до голода на 40 минут.\n"
                    .."Восстанавливает жизни в течении 10 минут \n"
                    .."каждые 5 сек по 10 ед.",
        how_get_text = "На 10 продаже добычи с охоты",
        ingredients = {
            { "meat", 1 },
            { "pasta", 1 },
            { "condiment", 1 },
            { "onion", 1 },
        },
    },

    [ FOOD_CARBONARA ] = {
        class = 3,
        hard_cost = 199,
        description = "Увеличивает время до голода на 60 минут.\n"
                    .."Восстанавливает выносливость в течении 10 минут \n"
                    .."за каждую 1 секунду по 5 ед.\n"
                    .."Восстанавливает жизни в течении 10 минут \n"
                    .."каждые 5 сек по 10 ед.",
        how_get_text = "Покупка",
        ingredients = {
            { "egg", 1 },
            { "spaghetti", 1 },
            { "cheese", 1 },
            { "onion", 1 },
            { "meat", 1 },
        },
    },

    [ FOOD_UKHA ] = {
        class = 2,
        description = "Увеличивает время до голода на 40 минут.\n"
                    .."Восстанавливает выносливость в течении 10 минут \n"
                    .."за каждую 1 секунду по 5 ед.",
        how_get_text = "На 10 продаже добычи с рыбалки",
        ingredients = {
            { "potato", 1 },
            { "fish", 1 },
            { "onion", 1 },
            { "condiment", 1 },
        },
    },

    [ FOOD_OMELETTE ] = {
        class = 1,
        description = "Увеличивает время до голода на 30 минут.",
        how_get_text = "По достижению уровня 10",
        ingredients = {
            { "egg", 1 },
            { "condiment", 1 },
        },
    },

    [ FOOD_SPAGHETTI_FANICINI ] = {
        class = 3,
        hard_cost = 249,
        description = "Увеличивает время до голода на 60 минут.\n"
                    .."Восстанавливает выносливость в течении 10 минут \n"
                    .."за каждую 1 секунду по 5 ед.\n"
                    .."Восстанавливает жизни в течении 10 минут \n"
                    .."каждые 5 сек по 10 ед.",
        how_get_text = "Покупка",
        ingredients = {
            { "carrot", 1 },
            { "spaghetti", 1 },
            { "cheese", 1 },
            { "onion", 1 },
            { "cream", 1 },
        },
    },

    [ FOOD_FISH_WITH_VEGETABLES ] = {
        class = 2,
        description = "Увеличивает время до голода на 40 минут.\n"
                    .."Восстанавливает жизни в течении 10 минут \n"
                    .."каждые 5 сек по 10 ед.",
        how_get_text = "На 10 продаже добычи с рыбалки",
        ingredients = {
            { "carrot", 1 },
            { "tomato", 1 },
            { "fish", 1 },
            { "onion", 1 },
            { "condiment", 1 },
        },
    },

    [ FOOD_CHEESE_SANDWICH ] = {
        class = 1,
        description = "Восстанавливает выносливость в течении 10 минут \n"
                    .."за каждую 1 секунду по 5 ед.",
        how_get_text = "По достижению уровня 5",
        ingredients = {
            { "bread", 1 },
            { "cheese", 1 },
        },
    },
}

for id, v in pairs( RECIPES ) do
    v.id = id
    
    local dish = FOOD_DISHES[ id ]
    v.name = dish.name
    v.img = dish.img
    v.calories = dish.calories

    for i, ingredient_data in pairs( v.ingredients ) do
        ingredient_data[ 1 ] = FOOD_INGREDIENTS_REVERSE[ ingredient_data[ 1 ] ]
    end
end