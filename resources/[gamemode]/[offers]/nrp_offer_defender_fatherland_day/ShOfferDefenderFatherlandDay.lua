loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ShVinyls" )
Extend( "ShVehicle" )
Extend( "ShSkin" )
Extend( "ShVehicleConfig" )

OFFER_NAME = "defender_fatherland_day"

OFFER_START_DATE = getTimestampFromString( "22 февраля 2021 00:00" )
OFFER_END_DATE   = getTimestampFromString( "23 февраля 2021 23:59" )

PACK_DATA = 
{
    [ 1 ] =
    {
        {
            id = "defender_pack_10",
            name = "for_military_merit",
            name_ingame = "За боевые заслуги",
            cost = 1690,
            true_cost = 1988,
            rewards = 
            {
                { type = "vinyl",   item_id = "50",     item_name = "Винил \"Советский\"", currency = "hard", quantity = 1, cost = 99  },
                { type = "case",    item_id = "elite",  item_name = "Кейс \"Элитный\"",    currency = "hard", quantity = 1, cost = 999 },
                { type = "vehicle", item_id = 490,      item_name = "Уаз патриот",         currency = "hard", quantity = 1, cost = 890 },
            },
        },
        {
            id = "defender_pack_11",
            name = "for_personal_courage",
            name_ingame = "За личное мужество",
            cost = 2799,
            true_cost = 3499,
            rewards = 
            {
                { type = "case", item_id = "imperial", item_name = "Кейс \"Императорский\"", currency = "hard", quantity = 1, cost = 1499 },
                { type = "soft", item_id = "2kk_soft", item_name = "2 000 000 рублей",       currency = "hard", quantity = 1, cost = 2000 },
            },
        },
        {
            id = "defender_pack_12",
            name = "for_valor",
            name_ingame = "За отвагу",
            cost = 5990,
            true_cost = 7488,
            rewards = 
            {
                { type = "vehicle", item_id = 445,       item_name = "Toyota Land Cruiser 5.7 AT", currency = "hard", quantity = 1, cost = 4490 },
                { type = "case",    item_id = "elite",    item_name = "Кейс \"Элитный\"",          currency = "hard", quantity = 1, cost = 999  },
                { type = "case",    item_id = "imperial", item_name = "Кейс \"Императорский\"",    currency = "hard", quantity = 1, cost = 1499 },
                { type = "skin",    item_id = 182,        item_name = "Скин \"Спарта\"",           currency = "hard", quantity = 1, cost = 500, convert_cost = 125000 },
            },
        },
    },
    
    [ 2 ] =
    {
        {
            id = "defender_pack_7",
            name = "for_military_merit",
            name_ingame = "За боевые заслуги",
            cost = 673,
            true_cost = 748,
            rewards = 
            {
                { type = "case", item_id = "army",      item_name = "Кейс \"Армейский\"", currency = "hard", quantity = 1, cost = 149 },
                { type = "case", item_id = "earth",     item_name = "Кейс \"Земля\"",     currency = "hard", quantity = 1, cost = 299 },
                { type = "soft", item_id = "300k_soft", item_name = "300 000 рублей",     currency = "hard", quantity = 1, cost = 300 },
            },
        },
        {
            id = "defender_pack_8",
            name = "for_personal_courage",
            name_ingame = "За личное мужество",
            cost = 1698,
            true_cost = 1998,
            rewards = 
            {
                { type = "vinyl", item_id = "s11",      item_name = "Винил \"Череп в дыму\"", currency = "hard", quantity = 1, cost = 199  },
                { type = "case",  item_id = "war",      item_name = "Кейс \"Война\"",         currency = "hard", quantity = 1, cost = 299  },
                { type = "soft",  item_id = "1_5kk_soft", item_name = "1 500 000 рублей",       currency = "hard", quantity = 1, cost = 1500 },
            },
        },
        {
            id = "defender_pack_9",
            name = "for_valor",
            name_ingame = "За отвагу",
            cost = 4151,
            true_cost = 5189,
            rewards = 
            {
                { type = "vehicle", item_id = 445,    item_name = "Toyota Land Cruiser 5.7 AT", currency = "hard", quantity = 1, cost = 4490 },
                { type = "case",    item_id = "hero", item_name = "Кейс \"Героический\"",       currency = "hard", quantity = 1, cost = 699  },
            },
        },
    },

    [ 3 ] =
    {
        {
            id = "defender_pack_4",
            name = "for_military_merit",
            name_ingame = "За боевые заслуги",
            cost = 449,
            true_cost = 499,
            rewards = 
            {
                { type = "case", item_id = "bmw",       item_name = "Кейс \"BMW\"",   currency = "hard", quantity = 1, cost = 299 },
                { type = "soft", item_id = "200k_soft", item_name = "200 000 рублей", currency = "hard", quantity = 1, cost = 200 },
            },
        },
        {
            id = "defender_pack_5",
            name = "for_personal_courage",
            name_ingame = "За личное мужество",
            cost = 482,
            true_cost = 567,
            rewards = 
            {
                { type = "vinyl", item_id = "s9",     item_name = "Винил \"Мужик\"",    currency = "hard", quantity = 1, cost = 69  },
                { type = "case",  item_id = "soviet", item_name = "Кейс \"Советский\"", currency = "hard", quantity = 2, cost = 498 },
            },
        },
        {
            id = "defender_pack_6",
            name = "for_valor",
            name_ingame = "За отвагу",
            cost = 652,
            true_cost = 815,
            rewards = 
            {
                { type = "skin",    item_id = 176,       item_name = "Скин \"Дизель\"",        currency = "hard", quantity = 1, cost = 99, convert_cost = 24750  },
                { type = "case",    item_id = "patriot", item_name = "Кейс \"Отечественный\"", currency = "hard", quantity = 4, cost = 179 },
            },
        },
    },

    [ 4 ] =
    {
        {
            id = "defender_pack_1",
            name = "for_military_merit",
            name_ingame = "За боевые заслуги",
            cost = 133,
            true_cost = 148,
            rewards = 
            {
                { type = "skin", item_id = 112,      item_name = "Скин \"Чувак\"",     currency = "hard", quantity = 1, cost = 49, convert_cost = 12250 },
                { type = "case", item_id = "bronze", item_name = "Кейс \"Бронзовый\"", currency = "hard", quantity = 1, cost = 99 },
            },
        },
        {
            id = "defender_pack_2",
            name = "for_personal_courage",
            name_ingame = "За личное мужество",
            cost = 254,
            true_cost = 299,
            rewards = 
            {
                { type = "case", item_id = "bronze",    item_name = "Кейс \"Бронзовый\"", currency = "hard", quantity = 1, cost = 99  },
                { type = "soft", item_id = "200k_soft", item_name = "200 000 рублей",     currency = "hard", quantity = 1, cost = 200 },
            },
        },
        {
            id = "defender_pack_3",
            name = "for_valor",
            name_ingame = "За отвагу",
            cost = 338,
            true_cost = 398,
            rewards = 
            {
                { type = "case", item_id = "silver", item_name = "Кейс \"Серебрянный\"", currency = "hard", quantity = 2, cost = 199 },
            },
        },
    },
}

function IsOfferActive()
    local ts = getRealTimestamp()
    return ts > OFFER_START_DATE and ts < OFFER_END_DATE
end