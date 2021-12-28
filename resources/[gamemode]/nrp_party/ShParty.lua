loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShVehicleConfig" )
Extend( "Globals" ) -- TODO: enum need move from Globals to Interfacer

enum "ePartyRoles" {
    "PARTY_ROLE_REQUEST",
    "PARTY_ROLE_MEMBER",
    "PARTY_ROLE_LEADER",
}

enum "ePartyActions" {
    "PARTY_WINDOW_STATE",
    "PARTY_DELETE_MEMBER",
    "PARTY_ACCEPT_MEMBER",
    "PARTY_DECLINE_MEMBER",
    "PARTY_ACCEPT_MEMBER_ALL",
    "PARTY_INVITE_MEMBER",
    "PARTY_ACCEPT_INVITE",
    "PARTY_INVITE_RESULT",
    "PARTY_RENAME",
    "PARTY_LEAVE",
    "PARTY_SEND_REQUEST",
    "PARTY_SEND_NOTIFICATION",
    "PARTY_START",
    "PARTY_END",
    "PARTY_START_DRAW",
    "PARTY_REWARD_POS",
    "PARTY_REWARD_PLACE",
}

enum "ePartyUpdateData" {
    "PARTY_MAIN",
    "PARTY_MEMBERS",
    "PARTY_TOP_LIST",
    "PARTY_UP_TIMER",
    "PARTY_REWARD_RESULT",
}

REWARDS_LIST = {
    {
        requirement = 0,
        rewards = {
            { type = "vinyl",   id = "s27",      cost = 129000,     places = { 7, 10 },     name = "Кибер воительница" },
            { type = "vehicle", id = 467,        cost = 349000,     places = { 4, 6 },                                 },
            { type = "case",    id = "german",   cost = 699000,     places = { 2, 3 },      name = "Кейс Немецкий"     },
            { type = "vehicle", id = 6528,       cost = 1100000,    places = { 1, 1 },                                 },
        },
    },
    {
        requirement = 50,
        rewards = {
            { type = "case",        cost = 249000,      places = { 7, 10 },     id = "monte_carlo", name = "Кейс Monte Carlo"   },
            { type = "vehicle",     cost = 649000,      places = { 4, 6 },      id = 436                                        },
            { type = "vehicle",     cost = 1500000,     places = { 2, 3 },      id = 410                                        },
            { type = "vehicle",     cost = 10000000,    places = { 1, 1 },      id = 470                                        },
        },
    },
    {
        requirement = 100,
        rewards = {
            { type = "vehicle",     cost = 550000,      places = { 7, 10 },     id = 473 },
            { type = "vehicle",     cost = 1400000,     places = { 4, 6 },      id = 581 },
            { type = "vehicle",     cost = 3000000,     places = { 2, 3 },      id = 554 },
            { type = "vehicle",     cost = 29900000,    places = { 1, 1 },      id = 545 },
        },
    },
    {
        requirement = 150,
        rewards = {
            { type = "case",        cost = 699000,      places = { 7, 10 },     id = "german",      name = "Кейс Немецкий" },
            { type = "vehicle",     cost = 2000000,     places = { 4, 6 },      id = 587                                   },
            { type = "vehicle",     cost = 4500000,     places = { 2, 3 },      id = 6563                                  },
            { type = "vehicle",     cost = 39900000,    places = { 1, 1 },      id = 6602                                  },
        },
    },
    {
        requirement = 200,
        rewards = {
            { type = "case",        cost = 999000,      places = { 7, 10 },     id = "major",       name = "Кейс Мажорный"   },
            { type = "vehicle",     cost = 2500000,     places = { 4, 6 },      id = 521                                     },
            { type = "vehicle",     cost = 6000000,     places = { 2, 3 },      id = 6565                                    },
            { type = "vehicle",     cost = 45000000,    places = { 1, 1 },      id = 526                                     },
        },
    },
}

function getRewardByPosition( pack_id, pos )
    for _, reward in pairs( REWARDS_LIST[ pack_id ].rewards ) do
        if pos >= reward.places[ 1 ] and pos <= reward.places[ 2 ] then
            return reward
        end
    end
end