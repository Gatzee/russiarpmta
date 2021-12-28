loadstring( exports.interfacer:extend( "Interfacer" ) )( )

MAX_BUSINESS_LEVEL = 2

MAX_SUCCES_VALUE = 100 -- Необходимое колво успешности для повышения уровня

SUCCES_VALUE_CALC_COEF = 1 / 0.25 -- Пополнение по 1 очку за каждые 25% от максимально возможной ежедневной прибыли

BRIBE_BUSINESS_LEVEL = 2 -- Откаты доступны со 2 уровня
BRIBE_TAKING_COOLDOWN = 24 * 60 * 60

BRIBE_ITEMS = {
    faction = {
        faction_exp = 25,
        social_rating = 3,
    },
    clan = {
        clan_money = 5000,
        clan_exp = 20,
        social_rating = -3,
    },
    choice = {
        {
            social_rating = 4,
        },
        {
            social_rating = -4,
        },
    },
}

-- Основные бизнесы
BUSINESSES = { }

local xml = xmlLoadFile( "map/businesses.map" )
local nodes = xmlNodeGetChildren( xml )
local businesses_reverse = { }

for i, v in pairs( nodes ) do
    local attrs = v.attributes

    local id = attrs.id
    local x, y, z = attrs.posX, attrs.posY + 860, attrs.posZ
    local size = attrs.size
    local icon = attrs.icon and true or false

    if businesses_reverse[ id ] then
        Debug( "duplicate business id = " .. tostring( id ), 1 )
    else
        table.insert( BUSINESSES, { id = id, x = x, y = y, z = z, radius = size, icon = icon, } )
    end
end

xmlUnloadFile( xml )

-- Точки Бирж
SELL_POINTS = {
    -- НСК
    { x = -446.479, y = -1908.601 + 860, z = 22.915, radius = 3 },
}

function GetBusinessesList( )
    return BUSINESSES
end

function GetLocations( )
    return SELL_POINTS
end

function GetMaxSuccesValue( )
    return MAX_SUCCES_VALUE
end