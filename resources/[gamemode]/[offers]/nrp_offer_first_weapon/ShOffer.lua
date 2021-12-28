loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

OFFERS_PACK = {
    {
        name = "Hunter's pack",
        id = "offer_hunter",
        price = 460,
        discount = 15,
        licenses_days = 20,
        weapon_data = {
            id = 33,
            ammo = 10,
        },
        armor_id = IN_MEDIUMARMOR,
    },
    {
        name = "Citizen's pack",
        id = "offer_citizen",
        price = 225,
        discount = 10,
        licenses_days = 10,
        weapon_data = {
            id = 22,
            ammo = 17,
        },
        armor_id = IN_LIGHTARMOR,
    },
}