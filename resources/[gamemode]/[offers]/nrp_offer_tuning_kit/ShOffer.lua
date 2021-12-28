loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShVehicleConfig" )

DATA_NAME = "offer_tuning_kit"
PACKS = {
    {
        name = "base",
        pos = 30,
        tuning_cases_list = {
            { id = 1, amount = 1, name = "base" },
            { id = 2, amount = 1, name = "happy" },
            { id = 3, amount = 1, name = "lucky" },
        },
        price_by_class = {
            { old_price = 427500, new_price = 363375 }, -- A
            { old_price = 1125000, new_price = 956250 }, -- B
            { old_price = 1318500, new_price = 1120725 }, -- C
            { old_price = 1674000, new_price = 1422900 }, -- D
            { old_price = 4788000, new_price = 4069800 }, -- S
            { old_price = 1318500, new_price = 1120725 }, -- M
        },
    },
    {
        name = "king",
        pos = 360,
        tuning_cases_list = {
            { id = 3, amount = 3, name = "lucky" },
        },
        vinyl_cases_list = {
            { id = 3, amount = 1, "king" },
        },
        price_by_class = {
            { old_price = 570000, new_price = 427500 }, -- A
            { old_price = 1500000, new_price = 1125000 }, -- B
            { old_price = 1758000, new_price = 1318500 }, -- C
            { old_price = 2232000, new_price = 1674000 }, -- D
            { old_price = 6384000, new_price = 4788000 }, -- S
            { old_price = 1758000, new_price = 1318500 }, -- M
        },
    },
    {
        name = "dominant",
        pos = 686,
        tuning_cases_list = {
            { id = 3, amount = 3, name = "lucky" },
            { id = 5, amount = 2, name = "maximum" },
        },
        price_by_class = {
            { old_price = 868, new_price = 521, is_hard = true }, -- A
            { old_price = 1998, new_price = 1199, is_hard = true }, -- B
            { old_price = 2456, new_price = 1474, is_hard = true }, -- C
            { old_price = 3130, new_price = 1878, is_hard = true }, -- D
            { old_price = 7482, new_price = 4490, is_hard = true }, -- S
            { old_price = 2456, new_price = 1474, is_hard = true }, -- M
        },
    },
}

function isAvailableModel( model )
    local config = VEHICLE_CONFIG[ model ]
    return config and not config.is_boat and not config.is_airplane and model ~= 468
end