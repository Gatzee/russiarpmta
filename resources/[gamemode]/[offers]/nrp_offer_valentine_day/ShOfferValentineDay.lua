loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "Globals" )

OFFER_NAME = "valentine_day"

OFFER_START_DATE = getTimestampFromString( "13 февраля 2021 00:00" )
OFFER_END_DATE   = getTimestampFromString( "14 февраля 2021 23:59" )

PACK_DATA = 
{
    [ 1 ] =
    {
        {
            id = "valentine_pack_10",
            name = "cupids_set",
            name_ingame = "Купидонов",
            cost = 1742,
            true_cost = 2049,
            rewards = 
            {
                { type = "case",  item_id = "major",    item_name = "Кейс \"Major\"",    currency = "hard", quantity = 1, cost = 999  },
                { type = "vinyl", item_id = "s60",      item_name = "Винил \"Купидон\"", currency = "hard", quantity = 1, cost = 50   },
                { type = "soft",  item_id = "1kk_soft", item_name = "1 000 000 рублей",  currency = "hard", quantity = 1, cost = 1000 },
            },
        },

        {
            id = "valentine_pack_11",
            name = "valentines_present",
            name_ingame = "Валентинов презент",
            cost = 2038,
            true_cost = 2548,
            rewards = 
            {
                { type = "case",           item_id = "viking",         item_name = "Кейс \"Викинг\"",   currency = "hard", quantity = 1, cost = 1499 },
                { type = "vinyl",          item_id = "s59",            item_name = "Винил \"Пошлый\"",  currency = "hard", quantity = 1, cost = 50   },
                { type = "soft",           item_id = "500k_soft",      item_name = "500 000 рублей",    currency = "hard", quantity = 1, cost = 500  },
                { type = "iventory_item",  item_id = IN_WEDDING_START, item_name = "Свадебная коробка", currency = "hard", quantity = 1, cost = 499  },
            },
        },

        {
            id = "valentine_pack_12",
            name = "lupercal",
            name_ingame = "Луперкаль",
            cost = 2660,
            true_cost = 3547,
            rewards = 
            {
                { type = "case",  item_id = "italy",     item_name = "Кейс \"Итальянский\"",        currency = "hard", quantity = 3, cost = 999 },
                { type = "vinyl", item_id = "s58",       item_name = "Винил \"Пронзенное сердце\"", currency = "hard", quantity = 1, cost = 50  },
                { type = "soft",  item_id = "500k_soft", item_name = "500 000 рублей",              currency = "hard", quantity = 1, cost = 500 },
            },
        },
    },
    [ 2 ] =
    {
        {
            id = "valentine_pack_7",
            name = "cupids_set",
            name_ingame = "Купидонов",
            cost = 763,
            true_cost = 848,
            rewards = 
            {
                { type = "vinyl",          item_id = "s60",            item_name = "Винил \"Купидон\"", currency = "hard", quantity = 1, cost = 50   },
                { type = "case",           item_id = "dubai",          item_name = "Кейс \"Дубай\"",    currency = "hard", quantity = 1, cost = 299  },
                { type = "iventory_item",  item_id = IN_WEDDING_START, item_name = "Свадебная коробка", currency = "hard", quantity = 1, cost = 499  },
            },
        },

        {
            id = "valentine_pack_8",
            name = "valentines_present",
            name_ingame = "Валентинов презент",
            cost = 892,
            true_cost = 1049,
            rewards = 
            {
                { type = "vinyl", item_id = "s59",       item_name = "Винил \"Пошлый\"",   currency = "hard", quantity = 1, cost = 50  },
                { type = "case",  item_id = "formula1",  item_name = "Кейс \"Формула 1\"", currency = "hard", quantity = 1, cost = 499 },
                { type = "soft",  item_id = "500k_soft", item_name = "500 000 рублей",     currency = "hard", quantity = 1, cost = 500 },
            },
        },

        {
            id = "valentine_pack_9",
            name = "lupercal",
            name_ingame = "Луперкаль",
            cost = 998,
            true_cost = 1248,
            rewards = 
            {
                { type = "vinyl", item_id = "s58",    item_name = "Винил \"Пронзенное сердце\"", currency = "hard", quantity = 1, cost = 50  },
                { type = "case",  item_id = "sport", item_name = "Кейс \"Спортивный\"",         currency = "hard", quantity = 1, cost = 499 },
                { type = "case",  item_id = "hero",   item_name = "Кейс \"Героический\"",        currency = "hard", quantity = 1, cost = 699 },
            },
        },

    },
    [ 3 ] =
    {
        {
            id = "valentine_pack_4",
            name = "cupids_set",
            name_ingame = "Купидонов",
            cost = 449,
            true_cost = 499,
            rewards = 
            {
                { type = "vinyl", item_id = "s60",       item_name = "Винил \"Купидон\"", currency = "hard", quantity = 1, cost = 50  },
                { type = "case",  item_id = "sea",       item_name = "Кейс \"Морской\"",  currency = "hard", quantity = 1, cost = 249 },
                { type = "soft",  item_id = "200k_soft", item_name = "200 000 рублей",    currency = "hard", quantity = 1, cost = 200 },
            },
        },

        {
            id = "valentine_pack_5",
            name = "valentines_present",
            name_ingame = "Валентинов презент",
            cost = 466,
            true_cost = 548,
            rewards = 
            {
                { type = "vinyl", item_id = "s59",   item_name = "Винил \"Пошлый\"", currency = "hard", quantity = 1, cost = 50  },
                { type = "case",  item_id = "lamba", item_name = "Кейс \"Ламба\"",   currency = "hard", quantity = 2, cost = 249 },
            },
        },

        {
            id = "valentine_pack_6",
            name = "lupercal",
            name_ingame = "Луперкаль",
            cost = 559,
            true_cost = 699,
            rewards = 
            {
                { type = "vinyl", item_id = "s58",       item_name = "Винил \"Пронзенное сердце\"", currency = "hard", quantity = 1, cost = 50  },
                { type = "soft",  item_id = "350k_soft", item_name = "350 000 рублей",              currency = "hard", quantity = 1, cost = 350 },
                { type = "case",  item_id = "euro",      item_name = "Кейс \"Европа\"",             currency = "hard", quantity = 1, cost = 299 },
            },
        },
    },
    [ 4 ] =
    {
        {
            id = "valentine_pack_1",
            name = "cupids_set",
            name_ingame = "Купидонов",
            cost = 134,
            true_cost = 149,
            rewards = 
            {
                { type = "vinyl", item_id = "s60",    item_name = "Винил \"Купидон\"",  currency = "hard", quantity = 1, cost = 50 },
                { type = "case",  item_id = "bronze", item_name = "Кейс \"Бронзовый\"", currency = "hard", quantity = 1, cost = 99 },
            },
        },

        {
            id = "valentine_pack_2",
            name = "valentines_present",
            name_ingame = "Валентинов презент",
            cost = 254,
            true_cost = 299,
            rewards = 
            {
                { type = "vinyl", item_id = "s59",         item_name = "Винил \"Пошлый\"",     currency = "hard", quantity = 1, cost = 50  },
                { type = "case",  item_id = "monte_carlo", item_name = "Кейс \"Monte-Carlo\"", currency = "hard", quantity = 1, cost = 249 },
            },
        },

        {
            id = "valentine_pack_3",
            name = "lupercal",
            name_ingame = "Луперкаль",
            cost = 295,
            true_cost = 347,
            rewards = 
            {
                { type = "vinyl", item_id = "s58",    item_name = "Винил \"Пронзенное сердце\"", currency = "hard", quantity = 1, cost = 50 },
                { type = "case",  item_id = "bronze", item_name = "Кейс \"Бронзовый\"",          currency = "hard", quantity = 3, cost = 99 },
            },
        },
    },
}

function IsOfferActive()
    local ts = getRealTimestamp()
    return ts > OFFER_START_DATE and ts < OFFER_END_DATE
end