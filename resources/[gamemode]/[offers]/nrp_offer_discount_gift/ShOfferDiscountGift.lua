loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )

OFFER_NAME = "offer_discount_gift"
OFFER_DURATION_IN_SEC = 2 * 24 * 60 * 60

OFFER_START_DATE = getTimestampFromString( "15 мая 2021 00:00" )
OFFER_END_DATE   = OFFER_START_DATE + OFFER_DURATION_IN_SEC

PACK_ID  = 905

function IsOfferActive()
    local ts = getRealTimestamp()
    return ts > OFFER_START_DATE and ts < OFFER_END_DATE
end

PACK_DATA =
{
    {
        id = "donatepack14",
        cost = 3999,
        value_sum = 6000,
        currency = "hard",
        discount_data  = { value = 20, items = { "special_case" } },
        discount_text = "Скидка 20% на кейсы",
    },
    {
        id = "donatepack15",
        cost = 6999,
        value_sum = 10000,
        currency = "hard",
        discount_data = { value = 20, items = { "special_case", "special_vehicle" } },
        discount_text = "Скидка 20% на транспорт из\nуникальных предложений и кейсы",
    },
    {
        id = "donatepack10",
        cost = 159,
        value_sum = 179,
        currency = "hard",
        discount_data = { value = 10, items = { "special_vip_wof" } },
        discount_text = "Скидка 10% на жетоны VIP\nколеса фортуны",
    },
    {
        id = "donatepack11",
        cost = 219,
        value_sum = 249,
        currency = "hard",
        discount_data = { value = 10, items = { "special_services" } },
        discount_text = "Скидка 10% на услуги",
    },
    {
        id = "donatepack12",
        cost = 699,
        value_sum = 800,
        currency = "hard",
        discount_data = { value = 15, items = { "special_skin", "special_numberplate", "special_neon" } },
        discount_text = "Скидка 15% на номера, \nскины, неоны из \nуникальных предложений",
    },
    {
        id = "donatepack13",
        cost = 1699,
        value_sum = 2150,
        currency = "hard",
        discount_data = { value = 10, items = { "special_vinyl" } },
        discount_text = "Скидка 10% на винилы\nиз уникальных предложений",
    },
}

PACK_DATA_ALL_DISCOUNTS = { value = 20, items = { "special_pack" } }