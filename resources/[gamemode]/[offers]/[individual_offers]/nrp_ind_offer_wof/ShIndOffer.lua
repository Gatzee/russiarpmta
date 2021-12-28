OFFER = {
    id = resource.name:sub( 5 ),
    duration = 2 * 60 * 60,
    need_level = 4,
    need_visits_count = 5,
    need_visits_period = 7 * 24 * 60 * 60,
    
    cooldown = 7 * 24 * 60 * 60,
    variants = {
        {
            cost = 88,
            cost_original = 135,
            items = {
                { type = "wof_coin", coin_type = "default", count = 3 },
                { type = "wof_coin", coin_type = "gold", count = 1 },
            },
        },
        {
            cost = 135,
            cost_original = 225,
            items = {
                { type = "wof_coin", coin_type = "gold", count = 3 },
            },
        },
        {
            cost = 225,
            cost_original = 375,
            items = {
                { type = "wof_coin", coin_type = "gold", count = 5 },
            },
        },
    },
}