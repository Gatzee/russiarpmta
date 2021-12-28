Import( "Globals" )

enum "eFood" {
    "FOOD_SALAD",
    "FOOD_SOUP",
    "FOOD_NAVY_PASTA",
    "FOOD_CARBONARA",
    "FOOD_UKHA",
    "FOOD_OMELETTE",
    "FOOD_SPAGHETTI_FANICINI",
    "FOOD_FISH_WITH_VEGETABLES",
    "FOOD_CHEESE_SANDWICH",
}

enum "eFoodBuffs" {
    "BUFF_HUNGER",
    "BUFF_HEALTH",
    "BUFF_STAMINA",
}

FOOD_BUFFS_INFO = { 
    [ BUFF_HUNGER ] = { max_duration = 60 * 60 },
    [ BUFF_HEALTH ] = { max_duration = 10 * 60, interval = 5, add_value = 10 },
    [ BUFF_STAMINA ] = { max_duration = 10 * 60, interval = 1, add_value = 5 },
}

FOOD_DISHES = {
    [ FOOD_SALAD ] = {
        in_item_id = IN_FOOD_SALAD,
        img = "salad",
        name = "Салат",
        weight = 0.2,
        calories = 25,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 30 * 60 },
        },
    },

    [ FOOD_SOUP ] = {
        in_item_id = IN_FOOD_SOUP,
        img = "soup",
        name = "Суп",
        weight = 0.3,
        calories = 75,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 60 * 60 },
            [ BUFF_HEALTH ] = { duration = 10 * 60, interval = 10, add_value = 5 },
            [ BUFF_STAMINA ] = { duration = 10 * 60, interval = 5, add_value = 1 },
        },
    },

    [ FOOD_NAVY_PASTA ] = {
        in_item_id = IN_FOOD_NAVY_PASTA,
        img = "navy_pasta",
        name = "Макароны по-флотски",
        weight = 0.2,
        calories = 50,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 40 * 60 },
            [ BUFF_HEALTH ] = { duration = 10 * 60, interval = 10, add_value = 5 },
        },
    },

    [ FOOD_CARBONARA ] = {
        in_item_id = IN_FOOD_CARBONARA,
        img = "carbonara",
        name = "Паста Карбонара",
        weight = 0.2,
        calories = 75,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 30 * 60 },
            [ BUFF_HEALTH ] = { duration = 10 * 60, interval = 10, add_value = 5 },
            [ BUFF_STAMINA ] = { duration = 10 * 60, interval = 5, add_value = 1 },
        },
    },

    [ FOOD_UKHA ] = {
        in_item_id = IN_FOOD_UKHA,
        img = "ukha",
        name = "Уха",
        weight = 0.2,
        calories = 50,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 40 * 60 },
            [ BUFF_STAMINA ] = { duration = 10 * 60, interval = 5, add_value = 1 },
        },
    },

    [ FOOD_OMELETTE ] = {
        in_item_id = IN_FOOD_OMELETTE,
        img = "omelette",
        name = "Яичница",
        weight = 0.2,
        calories = 25,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 30 * 60 },
        },
    },

    [ FOOD_SPAGHETTI_FANICINI ] = {
        in_item_id = IN_FOOD_SPAGHETTI_FANICINI,
        img = "spaghetti_fanicini",
        name = "Спагетти Фаничини",
        weight = 0.2,
        calories = 75,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 30 * 60 },
            [ BUFF_HEALTH ] = { duration = 10 * 60, interval = 10, add_value = 5 },
            [ BUFF_STAMINA ] = { duration = 10 * 60, interval = 5, add_value = 1 },
        },
    },

    [ FOOD_FISH_WITH_VEGETABLES ] = {
        in_item_id = IN_FOOD_FISH_WITH_VEGETABLES,
        img = "fish_with_vegetables",
        name = "Рыба с овощами",
        weight = 0.3,
        calories = 50,
        buffs = {
            [ BUFF_HUNGER ] = { duration = 40 * 60 },
            [ BUFF_HEALTH ] = { duration = 10 * 60, interval = 10, add_value = 5 },
        },
    },

    [ FOOD_CHEESE_SANDWICH ] = {
        in_item_id = IN_FOOD_CHEESE_SANDWICH,
        img = "cheese_sandwich",
        name = "Бутерброд с сыром",
        weight = 0.1,
        calories = 25,
        buffs = {
            [ BUFF_STAMINA ] = { duration = 10 * 60, interval = 5, add_value = 1 },
        },
    },
}

-- увеличиваем длительность баффа на голод в 2 раза, 
-- уменьшая при этом трату калорий во время баффа в 2 раза.
-- результат: время до голода увеличивается, как необходимо,
-- а игрок при этом видит, что трата калорий замедлилась
for food_id, food in pairs( FOOD_DISHES ) do
    for buff_id, buff in pairs( food.buffs ) do
        if buff_id == BUFF_HUNGER then
            buff.duration = buff.duration * 2
        end
    end
end