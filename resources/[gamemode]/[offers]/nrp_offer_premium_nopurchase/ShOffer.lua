loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

VARIANTS = {
    { -- 1
        {
            name = "Basic",
            premium_days = 3,
            price = 339,
            -- items
            items = {
                { id = IN_REPAIRBOX, count = 2 },
                { id = IN_FIRSTAID, count = 2 },
                { id = IN_JAILKEYS, count = 3 },
            },
            free_evacuation = 2,
        },
        {
            name = "Standart",
            premium_days = 7,
            price = 519,
            -- items
            accessory_id = "cap6",
        },
        {
            name = "Comfort",
            premium_days = 14,
            price = 599,
            -- items
            vinyl_id = 10,
        },
        {
            name = "Best",
            premium_days = 30,
            price = 759,
            -- items
            vinyl_id = 8,
            accessory_id = "m2_asce22",
        },
    },
    { -- 2
        {
            name = "Basic",
            premium_days = 3,
            price = 269,
        },
        {
            name = "Standart",
            premium_days = 7,
            price = 479,
        },
        {
            name = "Comfort",
            premium_days = 14,
            price = 569,
            -- items
            items = {
                { id = IN_REPAIRBOX, count = 2 },
                { id = IN_FIRSTAID, count = 2 },
                { id = IN_JAILKEYS, count = 3 },
            },
            free_evacuation = 2,
        },
        {
            name = "Best",
            premium_days = 30,
            price = 599,
            -- items
            items = {
                { id = IN_REPAIRBOX, count = 2 },
                { id = IN_FIRSTAID, count = 2 },
                { id = IN_JAILKEYS, count = 3 },
            },
            free_evacuation = 2,
        },
    },
}