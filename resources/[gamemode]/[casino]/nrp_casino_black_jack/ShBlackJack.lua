loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShPlayer" )


CAMERA_POSITION = {
    [ CASINO_THREE_AXE ] = { -86.9511, -473.8619, 914.9347, -89.7085, -377.3271, 888.9841, 0, 70 },
    [ CASINO_MOSCOW ] = { 2441.7714, -1314.6571, 2800.9121, 2436.5829, -1220.3734, 2767.6652, 0, 70 },
}

enum "eBlackJackGameState" {
    "BLACK_JACK_STATE_RATE",
    "BLACK_JACK_STATE_ACTION_CARD",
}

DURATION_ACTION = 
{
    [ BLACK_JACK_STATE_RATE ] = 12,
    [ BLACK_JACK_STATE_ACTION_CARD ] = 10,
}

BLACK_JACK_STATE_WAIT = 5

enum "eBlackJackCardActions" {
    "BLACK_JACK_ACTION_CARD_TAKE",
    "BLACK_JACK_ACTION_CARD_PASS",
}

enum "eBlackJackGameResult" {
    "BLACK_JACK_RESULT_WIN",
    "BLACK_JACK_RESULT_LOSE",
    "BLACK_JACK_RESULT_DRAW",
    "BLACK_JACK_RESULT_AFK",
}

TIMEOUT_TIME = 200
MAX_AFK_ROUNDS = 6


MIN_RATES =
{
    [ CASINO_THREE_AXE ] = 500,
    [ CASINO_MOSCOW ] = 5000,
}


MAX_RATES = 
{
    [ CASINO_THREE_AXE ] = 15000,
    [ CASINO_MOSCOW ] = 150000,
}

enum "eBlackJackRates" {
    "BLACK_JACK_RATE_1",
    "BLACK_JACK_RATE_2",
    "BLACK_JACK_RATE_3",
    "BLACK_JACK_RATE_4",
    "BLACK_JACK_RATE_5",
    "BLACK_JACK_RATE_6",
}

RATES_VALUES =
{
    [ CASINO_THREE_AXE ] =
    {
        [ BLACK_JACK_RATE_1 ] = 500,
        [ BLACK_JACK_RATE_2 ] = 1000,
        [ BLACK_JACK_RATE_3 ] = 2000,
        [ BLACK_JACK_RATE_4 ] = 3000,
        [ BLACK_JACK_RATE_5 ] = 4000,
        [ BLACK_JACK_RATE_6 ] = 5000,
    },
    [ CASINO_MOSCOW ] =
    {
        [ BLACK_JACK_RATE_1 ] = 5000,
        [ BLACK_JACK_RATE_2 ] = 10000,
        [ BLACK_JACK_RATE_3 ] = 20000,
        [ BLACK_JACK_RATE_4 ] = 30000,
        [ BLACK_JACK_RATE_5 ] = 40000,
        [ BLACK_JACK_RATE_6 ] = 50000,
    },
}

enum "eCardsSuits" {
    "CARD_SUIT_SPADE",
    "CARD_SUIT_HEART",
    "CARD_SUIT_DIAMOND",
    "CARD_SUIT_CLUB",
}

CARD_NAMES = 
{
    [ CARD_SUIT_SPADE ]   = "Пики",
    [ CARD_SUIT_HEART ]   = "Черви",
    [ CARD_SUIT_DIAMOND ] = "Бубны",
    [ CARD_SUIT_CLUB ]    = "Трефы",
}

MAX_WIN_CARD_SUMM = 21

CARDS_DATA =
{
    [ -1 ] = { name = "back",   weight = 0   },
    [ 2 ]  = { name = "2",      weight = 2,  },
    [ 3 ]  = { name = "3",      weight = 3,  },
    [ 4 ]  = { name = "4",      weight = 4,  },
    [ 5 ]  = { name = "5",      weight = 5,  },
    [ 6 ]  = { name = "6",      weight = 6,  },
    [ 7 ]  = { name = "7",      weight = 7,  },
    [ 8 ]  = { name = "8",      weight = 8,  },
    [ 9 ]  = { name = "9",      weight = 9,  },
    [ 10 ] = { name = "10",     weight = 10, },
    [ 11 ] = { name = "Валет",  weight = 10, },
    [ 12 ] = { name = "Дама",   weight = 10, },
    [ 13 ] = { name = "Король", weight = 10, },
    [ 14 ] = { name = "Туз",    weight = 11, },
}

function CalculateCardSumm( cards )
    local summ = 0
    
    local aces = {}
    for k, v in pairs( cards ) do
        if CARDS_DATA[ v[ 1 ] ].weight == 11 then
            table.insert( aces, v[ 1 ] )
        else
            summ = summ + CARDS_DATA[ v[ 1 ] ].weight
        end
    end

    for k, v in pairs( aces ) do
        if summ + CARDS_DATA[ v ].weight <= MAX_WIN_CARD_SUMM then
            summ = summ + CARDS_DATA[ v ].weight
        else
            summ = summ + 1
        end
    end

    return summ
end