
loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )

CASINO_DATA =
{
    [ CASINO_THREE_AXE ] =
    {
        woke_up_position = Vector3( 754.5271, -157.4979, 20.9033 ),
    },
    [ CASINO_MOSCOW ] = 
    {
        woke_up_position = Vector3( 2605.2651, 2596.8898, 8.0754 ),
    },
}


enum "eAlcoholLevels" {
	"ALCOHOL_INTOXICATION_EASY",
	"ALCOHOL_INTOXICATION_MIDDLE",
	"ALCOHOL_INTOXICATION_STRONG",
    "ALCOHOL_INTOXICATION_VERY_STRONG",
    "ALCOHOL_INTOXICATION_DEATH",
}

ALCOHOL_INTOXICATION_LEVELS =
{
    [ ALCOHOL_INTOXICATION_EASY ]        = 1 * 60,
    [ ALCOHOL_INTOXICATION_MIDDLE ]      = 2 * 60,
    [ ALCOHOL_INTOXICATION_STRONG ]      = 4 * 60,
    [ ALCOHOL_INTOXICATION_VERY_STRONG ] = 6 * 60,
    [ ALCOHOL_INTOXICATION_DEATH ]       = 8 * 60,
}

enum "eAlcoholTypes" {
	"ALCOHOL_BEER",
	"ALCOHOL_COCKTAIL",
	"ALCOHOL_VODKA",
	"ALCOHOL_WISKI",
}

DRINKS =
{
    [ ALCOHOL_BEER ] = {
        id = "beer",
        name = "Пиво",
        cost = 500,
        currency = "soft",
        intoxication = 60,
    },
    [ ALCOHOL_COCKTAIL ] = {
        id = "cocktail",
        name = "Коктейль",
        cost = 750,
        currency = "soft",
        intoxication = 90,
    },
    [ ALCOHOL_VODKA ] = {
        id = "vodka",
        name = "Водка",
        cost = 1500,
        currency = "soft",
        intoxication = 120,
    },
    [ ALCOHOL_WISKI ] = {
        id = "wiski",
        name = "Виски",
        cost = 2500,
        currency = "soft",
        intoxication = 150,
    },
}