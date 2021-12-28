REWARDS_BY_DAYS = {
    [1] = { -- 1 season
    [1] = {
        regular = {
            [1] = {
                {
                    class = "vehicle",
                    params = { model = 467, temp_days = 1 / 24 },
                },
            },
            [2] = {
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_ENGINE,
                        category = 2,
                    },
                    available_classes = { 1, 2, 3, 4}
                },
            },
        },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 60 * 60 },
                },
            },
        },

        [2] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 500 },
                    },
                },
                [2] = {
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 1000 },
                },
                {
                    class = "money",
                    params = { count = 20000 },
                },
            },
        },

        [3] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "glasses1" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6566, temp_days = 1 / 24 },
                },
            },
        },

        [4] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 2, false },
                    },
                },
                [2] = {
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 4 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 1500 },
                },
                {
                    class = "roulette_coin",
                    params = { 3, false },
                },
            },
        },

        [5] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 467, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ENGINE,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3, 4}
                    },
                },
            },

            premium = {
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_ENGINE,
                        category = 2,
                    },
                    available_classes = { 1, 2, 3 }
                },
                {
                    class = "vehicle",
                    params = { model = 426, temp_days = 1 / 24 },
                },
            },
        },

        [6] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 2000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 529, temp_days = 1 / 24 },
                },
            },
        },

        [7] = {
            regular = {
                [1] = {
                    {
                        class = "skin",
                        params = { id = 111 },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 89 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 24 },
                },
            },
        },

        [8] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY, duration = 5400 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "coffer" },
                    },
                }
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 3000 },
                },
                {
                    class = "money",
                    params = { count = 150000 },
                },
            },
        },

        [9] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 4, false },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 15000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vinyl",
                    params = { id = 7 },
                    available_classes = { 1, 2, 3, 4, 5 },
                },
            },
        },

        [10] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 566, temp_days = 1 / 24, y_offset = - 10 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 436, temp_days = 1 / 24 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 506, temp_days = 1 / 24 },
                },
            },
        },

        [11] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY },
                    },
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 3 * 60 * 60 },
                },
            },
        },

        [12] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP, duration = 3600 * 2 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                },

                [2] = {
                    {
                        class = "money",
                        params = { count = 7000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 4000 },
                },
                {
                    class = "roulette_coin",
                    params = { 2, true },
                },
            },
        },

        [13] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 3000 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "guitar1" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 418, temp_days = 1 / 24 },
                },
            },
        },

        [14] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 2, true },
                    },
                },
                [2] = {
                    {
                        class = "roulette_coin",
                        params = { 5, false },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "roulette_coin",
                    params = { 4, true },
                },
            },
        },

        [15] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 536, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ENGINE,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_ENGINE,
                        category = 3,
                    },
                    available_classes = { 1, 2, 3 }
                },
            },
        },

        [16] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 3000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 30000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 576, temp_days = 1 / 24 },
                },
            },
        },

        [17] = {
            regular = {
                [1] = {
                    {
                        class = "skin",
                        params = { id = 130 },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 192 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 199 },
                },
            },
        },

        [18] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 3 },
                    },
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "cap4" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "money",
                    params = { count = 300000 },
                },
            },
        },

        [19] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 4000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 40000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vinyl",
                    params = { id = 6 },
                    available_classes = { 1, 2, 3, 4, 5 },
                },
            },
        },

        [20] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 6528, temp_days = 1 / 24, y_offset = - 5 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 466, temp_days = 1 / 24 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 401, temp_days = 1 / 24, y_offset = 7 },
                },
            },
        },

        [21] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY, duration = 7200 },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP, duration = 7200 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 7200 },
                },
            },
        },

        [22] = {
            regular = {
                [1] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 5000 },
                },
                {
                    class = "roulette_coin",
                    params = { 3, true },
                },
            },
        },

        [23] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 4000 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "guitar3" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 474, temp_days = 1 / 24 },
                },
            },
        },

        [24] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 3, true },
                    },
                },
                [2] = {
                    {
                        class = "roulette_coin",
                        params = { 7, false },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "roulette_coin",
                    params = { 4, true },
                },
            },
        },

        [25] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 405, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ECU,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_TURBO,
                        category = 3,
                    },
                    available_classes = { 2, 3, 4 }
                },
            },
        },

        [26] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 5000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 50000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 579, temp_days = 1 / 24 },
                },
            },
        },

        [27] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 4, true },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 112 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 103 },
                },
            },
        },

        [28] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 5 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "mask_mick" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "money",
                    params = { count = 500000 },
                },
            },
        },

        [29] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 6000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 75000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 161 },
                },
            },
        },

        [30] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 445, temp_days = 12 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 600, temp_days = 12 / 24 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6579, temp_days = 24 / 24, discount_params = { time = 60 * 60, percent = 15 } },
                },
            },
        },
    },

    [2] = { -- 2 season
        [1] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 60 * 60 },
                },
            },
        },

        [2] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 500 },
                    },
                },
                [2] = {
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 1000 },
                },
                {
                    class = "money",
                    params = { count = 20000 },
                },
            },
        },

        [3] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "m3_acse03" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6576, temp_days = 1 / 24 },
                },
            },
        },

        [4] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 2, false },
                    },
                },
                [2] = {
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 4 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 1500 },
                },
                {
                    class = "roulette_coin",
                    params = { 3, false },
                },
            },
        },

        [5] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 467, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ENGINE,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_ENGINE,
                        category = 2,
                    },
                    available_classes = { 1, 2, 3 }
                },
                {
                    class = "vehicle",
                    params = { model = 540, temp_days = 1 / 24 },
                },
            },
        },

        [6] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 2000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 410, temp_days = 1 / 24 },
                },
            },
        },

        [7] = {
            regular = {
                [1] = {
                    {
                        class = "skin",
                        params = { id = 113 },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 185 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 263 },
                },
            },
        },

        [8] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY, duration = 5400 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "scarf_deserted_r" },
                    },
                }
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 3000 },
                },
                {
                    class = "money",
                    params = { count = 150000 },
                },
            },
        },

        [9] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 4, false },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 15000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 94 },
                },
            },
        },

        [10] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 420, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 419, temp_days = 1 / 24 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6537, temp_days = 1 / 24 },
                },
            },
        },

        [11] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY },
                    },
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 3600 },
                },
            },
        },

        [12] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP, duration = 3600 * 2 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                },

                [2] = {
                    {
                        class = "money",
                        params = { count = 5000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 4000 },
                },
                {
                    class = "roulette_coin",
                    params = { 2, true },
                },
            },
        },

        [13] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 3000 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "cylinder_hat" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 412, temp_days = 1 / 24 },
                },
            },
        },

        [14] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 2, true },
                    },
                },
                [2] = {
                    {
                        class = "roulette_coin",
                        params = { 5, false },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "roulette_coin",
                    params = { 4, true },
                },
            },
        },

        [15] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 6563, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ENGINE,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_ENGINE,
                        category = 3,
                    },
                    available_classes = { 1, 2, 3 }
                },
            },
        },

        [16] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 3000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 30000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6580, temp_days = 1 / 24 },
                },
            },
        },

        [17] = {
            regular = {
                [1] = {
                    {
                        class = "skin",
                        params = { id = 292 },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 177 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 78 },
                },
            },
        },

        [18] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 3 },
                    },
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "cap4" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "money",
                    params = { count = 300000 },
                },
            },
        },

        [19] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 4000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 40000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vinyl",
                    params = { id = 6 },
                    available_classes = { 1, 2, 3, 4, 5 },
                },
            },
        },

        [20] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 559, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 6547, temp_days = 1 / 24, y_offset = - 5 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6545, temp_days = 1 / 24 },
                },
            },
        },

        [21] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY, duration = 7200 },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP, duration = 7200 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 7200 },
                },
            },
        },

        [22] = {
            regular = {
                [1] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 5000 },
                },
                {
                    class = "roulette_coin",
                    params = { 3, true },
                },
            },
        },

        [23] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 4000 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "m3_acse06" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6558, temp_days = 1 / 24, y_offset = - 5 },
                },
            },
        },

        [24] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 3, true },
                    },
                },
                [2] = {
                    {
                        class = "roulette_coin",
                        params = { 7, false },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "roulette_coin",
                    params = { 4, true },
                },
            },
        },

        [25] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 491, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ECU,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_TURBO,
                        category = 3,
                    },
                    available_classes = { 2, 3, 4 }
                },
            },
        },

        [26] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 5000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 50000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6544, temp_days = 1 / 24 },
                },
            },
        },

        [27] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 4, true },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 287 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 164 },
                },
            },
        },

        [28] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 5 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 75000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "money",
                    params = { count = 500000 },
                },
            },
        },

        [29] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 6000 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "m3_acse14" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 163 },
                },
            },
        },

        [30] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 6549, temp_days = 12 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 6542, temp_days = 12 / 24 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 527, temp_days = 24 / 24, discount_params = { time = 60 * 60, percent = 15 }, y_offset = 7 },
                },
            },
        },
    },

    [3] = { -- 3 season
        [1] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 3600 },
                },
            },
        },

        [2] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 500 },
                    },
                },
                [2] = {
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 1000 },
                },
                {
                    class = "money",
                    params = { count = 20000 },
                },
            },
        },

        [3] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "m3_acse11" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 582, temp_days = 1 / 24, y_offset = - 10 },
                },
            },
        },

        [4] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 2, false },
                    },
                },
                [2] = {
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 4 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 1500 },
                },
                {
                    class = "roulette_coin",
                    params = { 3, false },
                },
            },
        },

        [5] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 467, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ENGINE,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_ENGINE,
                        category = 2,
                    },
                    available_classes = { 1, 2, 3 }
                },
                {
                    class = "vehicle",
                    params = { model = 490, temp_days = 1 / 24, y_offset = - 10 },
                },
            },
        },

        [6] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 2000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 418, temp_days = 1 / 24 },
                },
            },
        },

        [7] = {
            regular = {
                [1] = {
                    {
                        class = "skin",
                        params = { id = 9 },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 89 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 127 },
                },
            },
        },

        [8] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY, duration = 5400 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "m3_acse13" },
                    },
                }
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 3000 },
                },
                {
                    class = "money",
                    params = { count = 150000 },
                },
            },
        },

        [9] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 4, false },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 15000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 15 },
                },
            },
        },

        [10] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 6567, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 6564, temp_days = 1 / 24 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6535, temp_days = 1 / 24, y_offset = - 5 },
                },
            },
        },

        [11] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY, duration = 7200 },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP, duration = 7200 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 3600 },
                },
            },
        },

        [12] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP, duration = 7200 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                },

                [2] = {
                    {
                        class = "money",
                        params = { count = 5000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 4000 },
                },
                {
                    class = "roulette_coin",
                    params = { 2, true },
                },
            },
        },

        [13] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 3000 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "cap3" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 418, temp_days = 1 / 24, variant = 2 },
                },
            },
        },

        [14] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 2, true },
                    },
                },
                [2] = {
                    {
                        class = "roulette_coin",
                        params = { 5, false },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "roulette_coin",
                    params = { 4, true },
                },
            },
        },

        [15] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 477, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ENGINE,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_ENGINE,
                        category = 3,
                    },
                    available_classes = { 1, 2, 3 }
                },
            },
        },

        [16] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 3000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 30000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 589, temp_days = 1 / 24 },
                },
            },
        },

        [17] = {
            regular = {
                [1] = {
                    {
                        class = "skin",
                        params = { id = 278 },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 280 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vinyl",
                    params = { id = 1 },
                    available_classes = { 1, 2, 3, 4, 5 },
                },
            },
        },

        [18] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_CANISTER, count = 3 },
                    },
                    {
                        class = "item",
                        params = { id = IN_REPAIRBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "mask_red" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "money",
                    params = { count = 300000 },
                },
            },
        },

        [19] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 4000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 40000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 91 },
                },
            },
        },

        [20] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 6528, temp_days = 1 / 24, y_offset = - 5 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 6557, temp_days = 1 / 24, y_offset = - 7 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 535, temp_days = 1 / 24, y_offset = 5 },
                },
            },
        },

        [21] = {
            regular = {
                [1] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_MONEY, duration = 7200 },
                    },
                },
                [2] = {
                    {
                        class = "booster",
                        params = { id = BOOSTER_DOUBLE_EXP, duration = 7200 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "booster_double_exp_money",
                    params = { duration = 7200 },
                },
            },
        },

        [22] = {
            regular = {
                [1] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 10000 },
                    },
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 1 },
                    },
                },
            },

            premium = {
                {
                    class = "exp",
                    params = { count = 5000 },
                },
                {
                    class = "roulette_coin",
                    params = { 3, true },
                },
            },
        },

        [23] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 4000 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "wreath" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6533, temp_days = 1 / 24 },
                },
            },
        },

        [24] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 3, true },
                    },
                },
                [2] = {
                    {
                        class = "roulette_coin",
                        params = { 7, false },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "roulette_coin",
                    params = { 4, true },
                },
            },
        },

        [25] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 6554, temp_days = 1 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "tuning_part",
                        params = {
                            type = P_TYPE_ECU,
                            category = 2,
                        },
                        available_classes = { 1, 2, 3 }
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "tuning_part",
                    params = {
                        type = P_TYPE_TURBO,
                        category = 3,
                    },
                    available_classes = { 2, 3, 4 }
                },
            },
        },

        [26] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 5000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 50000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6539, temp_days = 1 / 24 },
                },
            },
        },

        [27] = {
            regular = {
                [1] = {
                    {
                        class = "roulette_coin",
                        params = { 4, true },
                    },
                },
                [2] = {
                    {
                        class = "skin",
                        params = { id = 47 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 70 },
                },
            },
        },

        [28] = {
            regular = {
                [1] = {
                    {
                        class = "item",
                        params = { id = IN_FIRSTAID, count = 5 },
                    },
                },
                [2] = {
                    {
                        class = "accessory",
                        params = { id = "glasses3" },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "money",
                    params = { count = 500000 },
                },
            },
        },

        [29] = {
            regular = {
                [1] = {
                    {
                        class = "exp",
                        params = { count = 6000 },
                    },
                },
                [2] = {
                    {
                        class = "money",
                        params = { count = 75000 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "skin",
                    params = { id = 214 },
                },
            },
        },

        [30] = {
            regular = {
                [1] = {
                    {
                        class = "vehicle",
                        params = { model = 475, temp_days = 12 / 24 },
                    },
                },
                [2] = {
                    {
                        class = "vehicle",
                        params = { model = 6560, temp_days = 12 / 24, y_offset = - 3 },
                    },
                },
            },

            premium = {
                {
                    class = "item",
                    params = { id = IN_REPAIRBOX, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FIRSTAID, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_CANISTER, count = 1 },
                },
                {
                    class = "item",
                    params = { id = IN_FOOD_LUNCHBOX, count = 1 },
                },
                {
                    class = "vehicle",
                    params = { model = 6588, temp_days = 24 / 24, discount_params = { time = 60 * 60, percent = 15 }, y_offset = 5 },
                },
            },
        },
    },
}