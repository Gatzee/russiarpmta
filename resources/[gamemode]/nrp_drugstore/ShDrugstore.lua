loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

MEDS_LIST = {
    { name = "Аспирин", health = 9, cost = 110 },
    { name = "Парацетамол", health = 15, cost = 130 },
    { name = "Ибупрофен", health = 20, cost = 150 },
    { name = "Анальгин", health = 25, cost = 240 },
    { name = "Адреналин", health = 33, cost = 280 },
}

SHOPS = {
    -- НСК
    { x = -200.10001, y = -1296.89999, z = 20.8 },
    { x = -222.10001, y = -1690.29999, z = 21 },
    { x = 312.408, y = -2108.831, z = 21.75 },
    { x = 176.028, y = -2296.375, z = 21.179 },
    { x = -2873.7534, y = 1657.1494, z = 14.1205 },
    -- Горки
    { x = 2499.6699, y = -773.38, z = 60.76 },
    { x = 2299.645, y = -553.934, z = 62.415 },
    { x = 1928.28, y = -519.39999, z = 60.8 },
    -- Армия
    { x = -2344.693, y = -153.103, z = 21.094, interior = 0, dimension = URGENT_MILITARY_DIMENSION },
    { x = -2344.693, y = -153.103, z = 21.094 },
    -- ОП
    { x = 1906.386, y = 1158.589, z = 16.396 },
    -- Подмосковье
    { x = 722.22, y = -428.594, z = 20.904 },
    { x = -104.107, y = 518.702, z = 20.909 },
}

function GetLocations()
    return SHOPS
end