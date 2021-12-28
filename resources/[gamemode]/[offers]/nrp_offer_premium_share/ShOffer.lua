loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

VARIANTS = {
    {
        name = "Скоростной",
        en_name = "speed",
        disc = { "Тюнинг кейс базовый (R)", "Винил кейс стильный" },
        amount = { 2, 1 }, -- first is tuning case, second is vinyl case
        prices = {
            { old = 259, new = 168 },
            { old = 599, new = 359 },
            { old = 735, new = 441 },
            { old = 943, new = 519 },
            { old = 2377, new = 713 },
        },
        vinyl_cases_ids = { -- for give ^_^
            VINYL_CASE_1_A,
            VINYL_CASE_1_B,
            VINYL_CASE_1_C,
            VINYL_CASE_1_D,
            VINYL_CASE_1_S,
        },
        vinyl_case_id = 1, -- for draw img
        tuning_case_id = 1, -- for give and draw
    },
    {
        name = "Улетный",
        en_name = "fly",
        disc = { "Тюнинг кейс счастливчик (R)", "Винил кейс королевский" },
        amount = { 2, 1 },
        prices = {
            { old = 554, new = 360 },
            { old = 1049, new = 629 },
            { old = 1228, new = 737 },
            { old = 1515, new = 833 },
            { old = 3641, new = 1092 },
        },
        vinyl_cases_ids = {
            VINYL_CASE_3_A,
            VINYL_CASE_3_B,
            VINYL_CASE_3_C,
            VINYL_CASE_3_D,
            VINYL_CASE_3_S,
        },
        vinyl_case_id = 3,
        tuning_case_id = 2,
    },
    {
        name = "Умопомрачительный",
        en_name = "breathtaking",
        disc = { "Тюнинг кейс фартовый (R)", "Винил кейс королевский" },
        amount = { 2, 2 },
        prices = {
            { old = 918, new = 597 },
            { old = 1598, new = 959 },
            { old = 1870, new = 1122 },
            { old = 2286, new = 1257 },
            { old = 5154, new = 1546 },
        },
        vinyl_cases_ids = {
            VINYL_CASE_3_A,
            VINYL_CASE_3_B,
            VINYL_CASE_3_C,
            VINYL_CASE_3_D,
            VINYL_CASE_3_S,
        },
        vinyl_case_id = 3,
        tuning_case_id = 3,
    },
}