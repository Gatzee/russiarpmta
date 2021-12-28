Player.GetHobbyBackpackSize = function( self )
    local iLevel = self:GetLevel( )
    local iSize = 5
    for k, v in pairs( HOBBY_BACKPACKS ) do
        if k <= iLevel and v > iSize then
            iSize = v
        end
    end

    return iSize
end

enum "eHobbyClass" {
    "HOBBY_FISHING",
    "HOBBY_HUNTING",
    "HOBBY_DIGGING",
}

HOBBY_NAMES = {
    [HOBBY_FISHING] = "Рыбалка",
    [HOBBY_HUNTING] = "Охота",
    [HOBBY_DIGGING] = "Охота за сокровищами",
}

HOBBY_BACKPACKS = {
    [1] = 10,
    [8] = 15,
    [14] = 20,
    [18] = 25,
}

HOBBY_SELL_MULTIPLIERS = {
    [1] = 1,
    [8] = 1.2,
    [14] = 1.4,
    [18] = 1.6,
}

HOBBY_LEVELS = {
    [HOBBY_FISHING] = {
        {
            exp = 0,
        },
        {
            exp = 1000,
        },
        {
            exp = 2000,
        },
        {
            exp = 3000,
        },
        {
            exp = 4000,
        },
        {
            exp = 5000,
        },
        {
            exp = 6000,
        },
        {
            exp = 7000,
        },
        {
            exp = 8000,
        },
        {
            exp = 9000,
        },
        {
            exp = 10000,
        },
    },

    [HOBBY_HUNTING] = {
        {
            exp = 0,
        },
        {
            exp = 1000,
        },
        {
            exp = 2000,
        },
        {
            exp = 3000,
        },
        {
            exp = 4000,
        },
        {
            exp = 5000,
        },
        {
            exp = 6000,
        },
        {
            exp = 7000,
        },
        {
            exp = 8000,
        },
        {
            exp = 9000,
        },
        {
            exp = 10000,
        },
    },

    [HOBBY_DIGGING] = {
        {
            exp = 0,
        },
        {
            exp = 1000,
        },
        {
            exp = 2000,
        },
        {
            exp = 3000,
        },
        {
            exp = 4000,
        },
        {
            exp = 5000,
        },
        {
            exp = 6000,
        },
        {
            exp = 7000,
        },
        {
            exp = 8000,
        },
        {
            exp = 9000,
        },
        {
            exp = 10000,
        },
    },
}

HOBBY_EQUIPMENT = {
    [HOBBY_FISHING] = {
        {
            class = "fishing:rod",
            default_name = "Удочка",
            default_icon = "files/img/icon_rod_1.png",
            column_names =
            {
                "Товар",
                "Прочность",
                "Стоимость",
            },

            items =
            {
                {
                    level = 1,
                    durability = 10,
                    cost = 1500,
                    unlock_cost = 0,
                    exp_amount = 50,
                    cost_multiplier = 340,
                    model = 677,
                },
                {
                    level = 2,
                    durability = 12,
                    cost = 1800,
                    unlock_cost = 19,
                    exp_amount = 60,
                    cost_multiplier = 342,
                    model = 677,
                },
                {
                    level = 3,
                    durability = 14,
                    cost = 2100,
                    unlock_cost = 29,
                    exp_amount = 70,
                    cost_multiplier = 345,
                    model = 677,
                },
                {
                    level = 4,
                    durability = 16,
                    cost = 2400,
                    unlock_cost = 39,
                    exp_amount = 80,
                    cost_multiplier = 350,
                    model = 679,
                },
                {
                    level = 5,
                    durability = 18,
                    cost = 2700,
                    unlock_cost = 49,
                    exp_amount = 90,
                    cost_multiplier = 355,
                    model = 679,
                },
                {
                    level = 6,
                    durability = 21,
                    cost = 3150,
                    unlock_cost = 59,
                    exp_amount = 100,
                    cost_multiplier = 357,
                    model = 679,
                },
                {
                    level = 7,
                    durability = 24,
                    cost = 3600,
                    unlock_cost = 69,
                    exp_amount = 110,
                    cost_multiplier = 360,
                    model = 678
                },
                {
                    level = 8,
                    durability = 27,
                    cost = 4050,
                    unlock_cost = 79,
                    exp_amount = 120,
                    cost_multiplier = 363,
                    model = 678
                },
                {
                    level = 9,
                    durability = 30,
                    cost = 4500,
                    unlock_cost = 89,
                    exp_amount = 130,
                    cost_multiplier = 365,
                    model = 682
                },
                {
                    level = 10,
                    durability = 35,
                    cost = 5250,
                    unlock_cost = 99,
                    exp_amount = 140,
                    cost_multiplier = 368,
                    model = 682
                },
                {
                    level = 11,
                    durability = 45,
                    cost = 6750,
                    unlock_cost = 109,
                    exp_amount = 140,
                    cost_multiplier = 370,
                    model = 692
                },
            }
        },

        {
            class = "fishing:bait",
            default_name = "Наживка",
            class_capacity = 100,
            default_icon = "files/img/icon_worm_1.png",
            column_names =
            {
                "Товар",
                "Количество",
                "Стоимость",
            },
            items =
            {
                {
                    level = 1,
                    cost = 40,
                    max_capacity = 30,
                    multiplier = 0,
                },
                {
                    level = 1,
                    cost = 60,
                    unlock_cost = 19,
                    max_capacity = 30,
                    multiplier = 10,
                },
                {
                    level = 4,
                    cost = 80,
                    unlock_cost = 29,
                    max_capacity = 30,
                    multiplier = 20,
                },
                {
                    level = 7,
                    cost = 100,
                    unlock_cost = 39,
                    max_capacity = 30,
                    multiplier = 30,
                },
                {
                    level = 10,
                    cost = 120,
                    unlock_cost = 49,
                    max_capacity = 30,
                    multiplier = 40,
                },
            }
        },

        {
            class = "backpack",
            default_name = "Рюкзак",
            default_icon = "files/img/icon_backpack.png",
            column_names =
            {
                "Товар",
                "Допустимый вес",
                "Заполненность",
            },
            items =
            {
                {
                    player_level = 1,
                    size = 10,
                },
                {
                    player_level = 8,
                    cost = 0,
                    size = 15,
                },
                {
                    player_level = 14,
                    size = 20,
                },
                {
                    player_level = 18,
                    size = 25,
                },
            }
        },
    },

    [HOBBY_HUNTING] = {
        {
            class = "hunting:rifle",
            default_name = "Ружье",
            default_icon = "files/img/icon_rifle_1.png",
            column_names =
            {
                "Товар",
                "Прочность",
                "Стоимость",
            },

            items =
            {
                {
                    level = 1,
                    durability = 10,
                    cost = 1500,
                    unlock_cost = 0,
                    exp_amount = 50,
                    cost_multiplier = 340,
                    model = 677,
                },
                {
                    level = 2,
                    durability = 12,
                    cost = 1800,
                    unlock_cost = 19,
                    exp_amount = 60,
                    cost_multiplier = 342,
                    model = 677,
                },
                {
                    level = 3,
                    durability = 14,
                    cost = 2100,
                    unlock_cost = 29,
                    exp_amount = 70,
                    cost_multiplier = 345,
                    model = 677,
                },
                {
                    level = 4,
                    durability = 16,
                    cost = 2400,
                    unlock_cost = 39,
                    exp_amount = 80,
                    cost_multiplier = 350,
                    model = 679,
                },
                {
                    level = 5,
                    durability = 18,
                    cost = 2700,
                    unlock_cost = 49,
                    exp_amount = 90,
                    cost_multiplier = 355,
                    model = 679,
                },
                {
                    level = 6,
                    durability = 21,
                    cost = 3150,
                    unlock_cost = 59,
                    exp_amount = 100,
                    cost_multiplier = 357,
                    model = 679,
                },
                {
                    level = 7,
                    durability = 24,
                    cost = 3600,
                    unlock_cost = 69,
                    exp_amount = 110,
                    cost_multiplier = 360,
                    model = 678
                },
                {
                    level = 8,
                    durability = 27,
                    cost = 4050,
                    unlock_cost = 79,
                    exp_amount = 120,
                    cost_multiplier = 363,
                    model = 678
                },
                {
                    level = 9,
                    durability = 30,
                    cost = 4500,
                    unlock_cost = 89,
                    exp_amount = 130,
                    cost_multiplier = 365,
                    model = 682
                },
                {
                    level = 10,
                    durability = 35,
                    cost = 5250,
                    unlock_cost = 99,
                    exp_amount = 140,
                    cost_multiplier = 368,
                    model = 682
                },
                {
                    level = 11,
                    durability = 45,
                    cost = 6750,
                    unlock_cost = 109,
                    exp_amount = 140,
                    cost_multiplier = 370,
                    model = 692
                },
            }
        },

        {
            class = "hunting:ammo",
            default_name = "Патроны",
            class_capacity = 100,
            default_icon = "files/img/icon_ammo_1.png",
            column_names =
            {
                "Товар",
                "Количество",
                "Стоимость",
            },
            items =
            {
                {
                    level = 1,
                    cost = 20,
                    max_capacity = 30,
                    multiplier = 0,
                },
                {
                    level = 2,
                    cost = 30,
                    unlock_cost = 19,
                    max_capacity = 30,
                    multiplier = 10,
                },
                {
                    level = 4,
                    cost = 40,
                    unlock_cost = 29,
                    max_capacity = 30,
                    multiplier = 20,
                },
                {
                    level = 7,
                    cost = 50,
                    unlock_cost = 39,
                    max_capacity = 30,
                    multiplier = 30,
                },
                {
                    level = 10,
                    cost = 60,
                    unlock_cost = 49,
                    max_capacity = 30,
                    multiplier = 40,
                },
            }
        },

        {
            class = "backpack",
            default_name = "Рюкзак",
            default_icon = "files/img/icon_backpack.png",
            column_names =
            {
                "Товар",
                "Допустимый вес",
                "Заполненность",
            },
            items =
            {
                {
                    player_level = 1,
                    size = 10,
                },
                {
                    player_level = 8,
                    cost = 0,
                    size = 15,
                },
                {
                    player_level = 14,
                    size = 20,
                },
                {
                    player_level = 18,
                    size = 25,
                },
            }
        },
    },

    [HOBBY_DIGGING] = {
        {
            class = "digging:shovel",
            default_name = "Лопата",
            default_icon = "files/img/icon_shovel_1.png",
            column_names =
            {
                "Товар",
                "Прочность",
                "Стоимость",
            },

            items =
            {
                {
                    level = 1,
                    durability = 10,
                    cost = 1500,
                    unlock_cost = 0,
                    exp_amount = 50,
                    cost_multiplier = 700,
                    model = 1219,
                },
                {
                    level = 2,
                    durability = 12,
                    cost = 1800,
                    unlock_cost = 19,
                    exp_amount = 60,
                    cost_multiplier = 725,
                    model = 1219,
                },
                {
                    level = 3,
                    durability = 14,
                    cost = 2100,
                    unlock_cost = 29,
                    exp_amount = 70,
                    cost_multiplier = 750,
                    model = 1219,
                },
                {
                    level = 4,
                    durability = 16,
                    cost = 2400,
                    unlock_cost = 39,
                    exp_amount = 80,
                    cost_multiplier = 775,
                    model = 1220,
                },
                {
                    level = 5,
                    durability = 18,
                    cost = 2700,
                    unlock_cost = 49,
                    exp_amount = 90,
                    cost_multiplier = 800,
                    model = 1220,
                },
                {
                    level = 6,
                    durability = 21,
                    cost = 3150,
                    unlock_cost = 59,
                    exp_amount = 100,
                    cost_multiplier = 830,
                    model = 1220,
                },
                {
                    level = 7,
                    durability = 24,
                    cost = 3600,
                    unlock_cost = 69,
                    exp_amount = 110,
                    cost_multiplier = 860,
                    model = 1220,
                },
                {
                    level = 8,
                    durability = 27,
                    cost = 4050,
                    unlock_cost = 79,
                    exp_amount = 120,
                    cost_multiplier = 890,
                    model = 1221,
                },
                {
                    level = 9,
                    durability = 30,
                    cost = 4500,
                    unlock_cost = 89,
                    exp_amount = 130,
                    cost_multiplier = 920,
                    model = 1221,
                },
                {
                    level = 10,
                    durability = 35,
                    cost = 5250,
                    unlock_cost = 99,
                    exp_amount = 140,
                    cost_multiplier = 950,
                    model = 1221,
                },
                {
                    level = 11,
                    durability = 45,
                    cost = 6750,
                    unlock_cost = 109,
                    exp_amount = 140,
                    cost_multiplier = 1000,
                    model = 1221,
                },
            }
        },

        {
            class = "digging:map",
            default_name = "Карта",
            class_capacity = 100,
            default_icon = "files/img/icon_map_1.png",
            custom_msg = "Карта куплена и добавлена в инвентарь! Нажми Q чтобы открыть инвентарь",
            column_names =
            {
                "Товар",
                "Количество",
                "Стоимость",
            },
            items =
            {
                {
                    level = 1,
                    cost = 500,
                    max_capacity = 30,
                    multiplier = 0,
                },
            },
            on_bought = function( player, amount )
                player:InventoryAddItem( IN_TREASURE_MAP, amount )
            end,
        },

        {
            class = "backpack",
            default_name = "Рюкзак",
            default_icon = "files/img/icon_backpack.png",
            column_names =
            {
                "Товар",
                "Допустимый вес",
                "Заполненность",
            },
            items =
            {
                {
                    player_level = 1,
                    size = 10,
                },
                {
                    player_level = 8,
                    cost = 0,
                    size = 15,
                },
                {
                    player_level = 14,
                    size = 20,
                },
                {
                    player_level = 18,
                    size = 25,
                },
            }
        },
    }
}
HOBBY_ITEMS = {
    [HOBBY_FISHING] = {
        {
            name = "Карась",
            chance = 0.22,
            icon = "fish_1",
        },
        {
            name = "Вобла",
            chance = 0.2,
            icon = "fish_1",
        },
        {
            name = "Скумбрия",
            chance = 0.1,
            icon = "fish_1",
        },
        {
            name = "Сельдь",
            chance = 0.095,
            icon = "fish_1",
        },
        {
            name = "Палтус",
            chance = 0.095,
            icon = "fish_1",
        },
        {
            name = "Щука",
            chance = 0.095,
            icon = "fish_2",
        },
        {
            name = "Сом",
            chance = 0.075,
            icon = "fish_2",
        },
        {
            name = "Сибас",
            chance = 0.05,
            icon = "fish_2",
            chance_increasable = true,
        },
        {
            name = "Семга",
            chance = 0.03,
            icon = "fish_2",
            chance_increasable = true,
        },
        {
            name = "Форель",
            chance = 0.02,
            icon = "fish_2",
            chance_increasable = true,
        },
        {
            name = "Лосось",
            chance = 0.01,
            icon = "fish_2",
            chance_increasable = true,
        },
        {
            name = "Белуга",
            is_unique = true,
            chance = 0.01,
            icon = "fish_3",

            f_available = function( player )
                local last_drop = player:GetPermanentData( "last_fish3_drop" )
                if last_drop and getRealTime( ).timestamp - last_drop <= 60 * 60 then
                    return false
                end

                local pTime = getRealTime()

                if pTime.hour >= 6 and pTime.hour < 7 or pTime.hour >= 11 and pTime.hour < 12 then
                    return true
                end
            end
        },
    },

    [HOBBY_HUNTING] = {
        {
            name = "Шкура кабана",
            animal_type = "boar",
            icon = "fur",
            chance = 0.2,
        },
        {
            name = "Шкура самки оленя",
            animal_type = "deer",
            icon = "fur",
            chance = 0.15,
        },
        {
            name = "Шкура самца оленя",
            animal_type = "deer",
            icon = "fur",
            chance = 0.1,
        },
        {
            name = "Шкура самки медведя",
            animal_type = "bear",
            icon = "fur",
            chance = 0.1,
        },
        {
            name = "Шкура самца медведя",
            animal_type = "bear",
            icon = "fur",
            chance = 0.1,
        },
        {
            name = "Шкура белого оленя",
            animal_type = "white_deer",
            icon = "fur",
            is_unique = true,
            chance = 0.1,
        },
        {
            name = "Мясо кабана",
            animal_type = "boar",
            icon = "meat",
            chance = 0.1,
        },
        {
            name = "Мясо самца оленя",
            animal_type = "deer",
            icon = "meat",
            chance = 0.1,
        },
        {
            name = "Мясо самки оленя",
            animal_type = "deer",
            icon = "meat",
            chance = 0.1,
        },
        {
            name = "Мясо медведя",
            animal_type = "bear",
            icon = "meat",
            chance = 0.1,
        },
        {
            name = "Мясо самца медведя",
            animal_type = "bear",
            icon = "meat",
            chance = 0.1,
        },
        {
            name = "Мясо белого оленя",
            animal_type = "white_deer",
            icon = "meat",
            chance = 0.1,
            is_unique = true,
        },

        {
            name = "Рога самца оленя",
            animal_type = "deer",
            icon = "horns",
            chance = 0.1,
        },
        {
            name = "Рога белого оленя",
            animal_type = "white_deer",
            icon = "horns",
            chance = 0.1,
            is_unique = true,
        },
    },

    [HOBBY_DIGGING] = {
        {
            name = "Серебряный набор",
            icon = "box_1",
            chance = 0.25,
        },
        {
            name = "Серебряные кувшины",
            icon = "box_1",
            chance = 0.25,
        },
        {
            name = "Цепочка с янтарём",
            icon = "box_1",
            chance = 0.095,
        },
        {
            name = "Серебряный резной нож",
            icon = "box_1",
            chance = 0.095,
        },
        {
            name = "Кинжал с аметистом",
            icon = "box_2",
            chance = 0.09,
        },
        {
            name = "Золотая цепь",
            icon = "box_2",
            chance = 0.08,
        },
        {
            name = "Необработанный изумруд",
            icon = "box_2",
            chance = 0.06,
        },
        {
            name = "Необработанный рубин",
            icon = "box_2",
            chance = 0.04,
        },
        {
            name = "Необработанный сапфир",
            icon = "box_3",
            chance = 0.02,
        },
        {
            name = "Платиновый набор украшений",
            icon = "box_3",
            chance = 0.01,
        },
        {
            name = "Украшения с изумрудом",
            icon = "box_3",
            chance = 0.01,
            is_unique = true,
            chance_increasable = true,
            f_available = function( player )
                local last_drop = player:GetPermanentData( "last_treasure3_drop" )
                if last_drop and getRealTime( ).timestamp - last_drop <= 60 * 60 then
                    return false
                end

                return true
            end
        },
    },
}
