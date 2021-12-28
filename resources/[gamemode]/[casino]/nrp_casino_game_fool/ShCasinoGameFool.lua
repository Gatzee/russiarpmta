CARD_COLOR_SPADES   = 1 -- Пики
CARD_COLOR_CLUBS    = 2 -- Трефы
CARD_COLOR_HEARTS   = 3 -- Черви
CARD_COLOR_DIAMONDS = 4 -- Бубень

AVAILABLE_TRUMPS_LIST = {
    CARD_COLOR_SPADES,
    CARD_COLOR_CLUBS,
    CARD_COLOR_HEARTS,
    CARD_COLOR_DIAMONDS,
}

CARDS_ON_TABLE_LIMIT = 5


CARD_JACK   = 11 -- Валет
CARD_QUEEN  = 12 -- Дама
CARD_KING   = 13 -- Король
CARD_ACE    = 14 -- Туз

DECK_36 = 1
DECK_52 = 2

DECKS = {
    -- Колода 36 карт
    [ DECK_36 ] = {
        [ 6 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 7 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 8 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 9 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 10 ]          = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_JACK ]   = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_QUEEN ]  = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_KING ]   = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_ACE ]    = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
    },

    -- Колода 52 карты
    [ DECK_52 ] = {
        [ 2 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 3 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 4 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 5 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 6 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 7 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 8 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 9 ]           = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ 10 ]          = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_JACK ]   = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_QUEEN ]  = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_KING ]   = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
        [ CARD_ACE ]    = { CARD_COLOR_SPADES, CARD_COLOR_CLUBS, CARD_COLOR_HEARTS, CARD_COLOR_DIAMONDS },
    },
}

-- Действия в процессе игры

CASINO_TASK_PLAYING         = 1
CASINO_TASK_WAITING         = 2
CASINO_TASK_DEFENDING       = 3
CASINO_TASK_TAKING          = 4
CASINO_TASK_ADDING          = 5
CASINO_TASK_LOST            = 6
CASINO_TASK_WON             = 7

TASK_TEXTS = {
    [ CASINO_TASK_PLAYING ] = "Делает ход",
    [ CASINO_TASK_WAITING ] = "Ожидает хода",
    [ CASINO_TASK_DEFENDING ] = "Отбивается",
    [ CASINO_TASK_WON ] = "Победил!",
    [ CASINO_TASK_LOST ] = "Проиграл!",
    [ CASINO_TASK_ADDING ] = "Подкидывает",
    [ CASINO_TASK_TAKING ] = "Беру!",
}

-- Генерация полной колоды
DECKS_LISTS = { }

for deck_num, deck_conf in pairs( DECKS ) do
    DECKS_LISTS[ deck_num ] = { }
    for card_value, card_conf in pairs( deck_conf ) do
        for _, card_color in pairs( card_conf ) do
            table.insert( DECKS_LISTS[ deck_num ], { card_value, card_color } )
        end
    end
end


-- Бьет ли одна карта другую?
function DoesCardBeatAnother( card1, card2, CURRENT_TRUMP )
    -- Если той же масти (либо оба козыри) и старше
    if card1[ 2 ] == card2[ 2 ] and card1[ 1 ] > card2[ 1 ] then return true end

    -- Если карта - козырь, а вторая - нет
    if card1[ 2 ] == CURRENT_TRUMP and card2[ 2 ] ~= CURRENT_TRUMP then return true end

    return false
end


-- Сортировка руки/колоды от младшей к старшей
function SortCardsByValue( deck_list, CURRENT_TRUMP )
    local deck_list = table.copy( deck_list )
    table.sort( deck_list, 
        function( a, b )
            local a_trump = a[ 2 ] == CURRENT_TRUMP and 1 or 0
            local b_trump = b[ 2 ] == CURRENT_TRUMP and 1 or 0

            if a_trump < b_trump then
                return true
            else
                return a[ 1 ] < b[ 1 ]
            end
        end
    )
    return deck_list
end


-- Френдли-название карт
local CARDS_FRIENDLY_NAMES = {
    [ CARD_JACK ]   = "Валет",
    [ CARD_QUEEN ]  = "Дама",
    [ CARD_KING ]   = "Король",
    [ CARD_ACE ]    = "Туз",
}

local CARDS_COLORS_FRIENDLY_NAMES = {
    [ CARD_COLOR_SPADES ]   = "Пики",
    [ CARD_COLOR_CLUBS ]    = "Трефы",
    [ CARD_COLOR_HEARTS ]   = "Черви",
    [ CARD_COLOR_DIAMONDS ] = "Бубны",
}

function GetCardName( card )
    local card_num      = card[ 1 ]
    local card_color    = card[ 2 ]

    local card_friendly_num     = CARDS_FRIENDLY_NAMES[ card_num ] or card_num
    local card_friendly_color   = CARDS_COLORS_FRIENDLY_NAMES[ card_color ] or card_color

    return card_friendly_num .. " " .. card_friendly_color
end

function GetColorName( color )
    return CARDS_COLORS_FRIENDLY_NAMES[ color ]
end