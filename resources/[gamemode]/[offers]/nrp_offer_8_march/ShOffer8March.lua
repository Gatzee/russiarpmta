loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )

OFFER_START_DATE = getTimestampFromString( "08.03.2021" )
OFFER_END_DATE   = getTimestampFromString( "10.03.2021" )

PACKS = {

    {
        name = "Свобода",
        key = "biker",
        {
            cost = 352,
            cost_original = 470,
            discount = 25,
            items = {
                { type = "skin", id = 56, name = "Одинокая волчица", cost = 450, exchange = { exp = 1000, soft = 150000 }, },
                { type = "vinyl", id = "s88", name = "Душа", cost = 20, },
            },
        },
        {
            cost = 571,
            cost_original = 714,
            discount = 20,
            items = {
                { type = "skin", id = 56, name = "Одинокая волчица", cost = 450, exchange = { exp = 1000, soft = 150000 }, },
                { type = "vinyl", id = "s88", name = "Душа", cost = 20, },
                { type = "vinyl", id = "s83", name = "Байкерша", cost = 45, },
                { type = "case", id = "silver", name = "Серебряный", cost = 199, },
            },
        },
        {
            cost = 1370,
            cost_original = 1713,
            discount = 20,
            items = {
                { type = "skin", id = 56, name = "Одинокая волчица", cost = 450, exchange = { exp = 1000, soft = 150000 }, },
                { type = "vinyl", id = "s88", name = "Душа", cost = 20, },
                { type = "vinyl", id = "s83", name = "Байкерша", cost = 45, },
                { type = "case", id = "biker", name = "Biker", cost = 599, count = 2, },
            },
        },
        {
            cost = 5034,
            cost_original = 6713,
            discount = 25,
            items = {
                { type = "vehicle", id = 522, name = "Ducati Desmosedici", cost = 5000, tuning = { color = { 0, 0, 0 }, headlights_color = {}, height_level = 0, installed_vinyls = { {   [3] = 6,   [7] = 25,   [10] = 120000,   [14] = "soft",   [15] = 25,   [16] = 1,   [17] = {    color = -5633498,    rotation = 170.13077,    size = 1.5,    x = 513,    y = 738   }  }, {   [3] = 6,   [7] = "dlf6",   [10] = 90000,   [14] = "soft",   [15] = "dlf6",   [16] = 2,   [17] = {    color = -5633498,    rotation = 0,    size = 0.85897434,    x = 512,    y = 291   }  } }, neon_data = {}, tuning_external = {}, wheels_camber = { 0, 0 }, wheels_offset = { 0, 0 }, wheels_width = { 0, 0 }, windows_color = { 0, 0, 0, 120 } }, },
                { type = "skin", id = 56, name = "Одинокая волчица", cost = 450, exchange = { exp = 1000, soft = 150000 }, },
                { type = "vinyl", id = "s88", name = "Душа", cost = 20, },
                { type = "vinyl", id = "s83", name = "Байкерша", cost = 45, },
                { type = "case", id = "biker", name = "Biker", cost = 599, count = 2, },
            },
        },
    },

    {
        name = "Власть",
        key = "godmother",
        {
            cost = 290,
            cost_original = 363,
            discount = 20,
            items = {
                { type = "skin", id = 6721, name = "Бизнесвумен", cost = 249, exchange = { exp = 900, soft = 130000 }, },
                { type = "vinyl", id = "s89", name = "Паук", cost = 15, },
                { type = "case", id = "bronze", name = "Бронзовый", cost = 99, },
            },
        },
        {
            cost = 565,
            cost_original = 707,
            discount = 20,
            items = {
                { type = "skin", id = 6721, name = "Бизнесвумен", cost = 249, exchange = { exp = 900, soft = 130000 }, },
                { type = "vinyl", id = "s89", name = "Паук", cost = 15, },
                { type = "vinyl", id = "s82", name = "Черная Вдова", cost = 45, },
                { type = "case", id = "silver", name = "Серебряный", cost = 199, count = 2, },
            },
        },
        {
            cost = 1281,
            cost_original = 1508,
            discount = 15,
            items = {
                { type = "skin", id = 6721, name = "Бизнесвумен", cost = 249, exchange = { exp = 900, soft = 130000 }, },
                { type = "vinyl", id = "s89", name = "Паук", cost = 15, },
                { type = "vinyl", id = "s82", name = "Черная Вдова", cost = 45, },
                { type = "soft", id = "200k_soft", name = "200000 софты", cost = 200, count = 200000, },
                { type = "case", id = "italy", name = "Итальянский", cost = 999, },
            },
        },
        {
            cost = 4806,
            cost_original = 6008,
            discount = 20,
            items = {
                { type = "vehicle", id = 518, name = "Chevrolet Camaro", cost = 4700, tuning = { color = { 0, 0, 0 }, headlights_color = { 255, 187, 99 }, height_level = 0, installed_vinyls = { {   [3] = 4,   [7] = "spitfire5",   [10] = 100000,   [14] = "soft",   [15] = "spitfire5",   [16] = 1,   [17] = {    color = -27865,    mirror = true,    rotation = 179.21538,    size = 1.8076923,    x = 512,    y = 352   }  }, {   [3] = 4,   [7] = "ramsy",   [10] = 208000,   [14] = "soft",   [15] = "ramsy",   [16] = 2,   [17] = {    color = -27865,    rotation = 25.36923,    size = 0.29487181,    x = 453,    y = 512   }  } }, neon_data = {}, tuning_external = {}, wheels_camber = { 0, 0 }, wheels_offset = { 0, 0 }, wheels_width = { 0, 0 }, windows_color = { 0, 0, 0, 120 } }, },
                { type = "skin", id = 6721, name = "Бизнесвумен", cost = 249, exchange = { exp = 900, soft = 130000 }, },
                { type = "vinyl", id = "s89", name = "Паук", cost = 15, },
                { type = "vinyl", id = "s82", name = "Черная Вдова", cost = 45, },
                { type = "case", id = "italy", name = "Итальянский", cost = 999, },
            },
        },
    },

    {
        name = "Сила",
        key = "revolution",
        {
            cost = 290,
            cost_original = 341,
            discount = 15,
            items = {
                { type = "skin", id = 39, name = "Лилит", cost = 217, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s86", name = "Кулак", cost = 25, },
                { type = "case", id = "bronze", name = "Бронзовый", cost = 99, },
            },
        },
        {
            cost = 535,
            cost_original = 630,
            discount = 15,
            items = {
                { type = "skin", id = 39, name = "Лилит", cost = 217, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s86", name = "Кулак", cost = 25, },
                { type = "vinyl", id = "s84", name = "Офицерша", cost = 30, },
                { type = "case", id = "patriot", name = "Отечественный", cost = 179, count = 2, },
            },
        },
        {
            cost = 1249,
            cost_original = 1470,
            discount = 15,
            items = {
                { type = "skin", id = 39, name = "Лилит", cost = 217, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s86", name = "Кулак", cost = 25, },
                { type = "vinyl", id = "s84", name = "Офицерша", cost = 30, },
                { type = "case", id = "powerful", name = "Мощный", cost = 599, count = 2, },
            },
        },
        {
            cost = 3799,
            cost_original = 4470,
            discount = 15,
            items = {
                { type = "vehicle", id = 554, name = "Ford Raptor", cost = 3000, tuning = { color = { 156, 154, 92 }, headlights_color = { 255, 39, 16 }, height_level = 0, installed_vinyls = { {   [3] = 2,   [7] = "mirage2",   [10] = 63000,   [14] = "soft",   [15] = "mirage2",   [16] = 1,   [17] = {    color = -610436,    mirror = true,    rotation = 0,    size = 1.3461539,    x = 569,    y = 200   }  }, {   [3] = 2,   [7] = 213,   [10] = 115200,   [14] = "soft",   [15] = 213,   [16] = 2,   [17] = {    rotation = 295.38461,    size = 0.32679486,    x = 800,    y = 425   }  }, {   [3] = 2,   [7] = "dlf6",   [10] = 67500,   [14] = "soft",   [15] = "dlf6",   [16] = 3,   [17] = {    color = -610436,    rotation = 298.46155,    size = 0.70512819,    x = 223,    y = 391   }  }, {   [3] = 2,   [7] = "dlf6",   [10] = 67500,   [14] = "soft",   [15] = "dlf6",   [16] = 4,   [17] = {    color = -610436,    rotation = 0,    size = 1.5,    x = 329,    y = 889   }  }, {   [3] = 2,   [7] = "dlf6",   [10] = 67500,   [14] = "soft",   [15] = "dlf6",   [16] = 5,   [17] = {    color = -610436,    rotation = 0,    size = 0.98717946,    x = 743,    y = 833   }  }, {   [3] = 2,   [7] = "dragon",   [10] = 315000,   [14] = "soft",   [15] = "dragon",   [16] = 6,   [17] = {    color = -2153970,    mirror = true,    rotation = 58.46154,    size = 1.5,    x = 776,    y = 590   }  }, {   [3] = 2,   [7] = 32,   [10] = 82500,   [14] = "soft",   [15] = 32,   [16] = 7,   [17] = {    color = -5896187,    rotation = 90.130768,    size = 2.0769231,    x = 169,    y = 512   }  } }, neon_data = {}, tuning_external = {}, wheels_camber = { 0, 0 }, wheels_offset = { 0, 0 }, wheels_width = { 0, 0 }, windows_color = { 0, 0, 0, 120 } }, },
                { type = "skin", id = 39, name = "Лилит", cost = 217, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s86", name = "Кулак", cost = 25, },
                { type = "vinyl", id = "s84", name = "Офицерша", cost = 30, },
                { type = "case", id = "powerful", name = "Мощный", cost = 599, count = 2, },
            },
        },
    },

    {
        name = "Скорость",
        key = "racer",
        {
            cost = 290,
            cost_original = 323,
            discount = 10,
            items = {
                { type = "skin", id = 142, name = "Лилу", cost = 199, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s87", name = "Череп с розами", cost = 25, },
                { type = "case", id = "bronze", name = "Бронзовый", cost = 99, },
            },
        },
        {
            cost = 452,
            cost_original = 503,
            discount = 10,
            items = {
                { type = "skin", id = 142, name = "Лилу", cost = 199, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s87", name = "Череп с розами", cost = 25, },
                { type = "vinyl", id = "s85", name = "Байк и флаг", cost = 30, },
                { type = "case", id = "monte_carlo", name = "Monte-Carlo", cost = 249, },
            },
        },
        {
            cost = 1126,
            cost_original = 1252,
            discount = 10,
            items = {
                { type = "skin", id = 142, name = "Лилу", cost = 199, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s87", name = "Череп с розами", cost = 25, },
                { type = "vinyl", id = "s85", name = "Байк и флаг", cost = 30, },
                { type = "case", id = "formula1", name = "Формула1", cost = 499, count = 2, },
            },
        },
        {
            cost = 2025,
            cost_original = 2251,
            discount = 10,
            items = {
                { type = "vehicle", id = 471, name = "Квадроцикл", cost = 500, },
                { type = "skin", id = 142, name = "Лилу", cost = 199, exchange = { exp = 500, soft = 100000 }, },
                { type = "vinyl", id = "s87", name = "Череп с розами", cost = 25, },
                { type = "vinyl", id = "s85", name = "Байк и флаг", cost = 30, },
                { type = "case", id = "formula1", name = "Формула1", cost = 499, count = 3, },
            },
        },
    },
}

for pack_id, pack_conf in pairs( PACKS ) do
    for pack_lvl, pack in ipairs( pack_conf ) do
        setmetatable( pack, { __index = pack_conf } )
        for i, item in ipairs( pack.items ) do
            item.model = item.id
            if item.type == "vinyl" then
                item.cost = item.cost / 0.2
            end
        end
    end
end

VINYL_CASE = {
    id = "vinyl_8march",
    cost = 149,
    cost_original = 299,
    items = {
        "s82",
        "s83",
        "s84",
        "s85",
        "s86",
        "s87",
        "s88",
        "s89",
    }
}

REGISTERED_ITEMS = { }