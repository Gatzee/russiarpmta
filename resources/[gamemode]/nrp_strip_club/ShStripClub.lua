
ENTER_PRICE = 500
STRIP_DATA =
{
    [ 1 ] =
    {
        marker_text = "Стрип клуб",
        keypress = "lalt",
        x         = 195.899,
        y         = -333.906 + 860,
        z         = 21.113,
        dimension = 0,
        interior  = 0,
        radius    = 2,
        outside_position = Vector3( 195.899, -333.906 + 860, 21.113 ),
        inside_position = Vector3( -47.72, -120.08, 1372.66 ),
        inside_int = 1,
        insdie_dim = 1,

        woke_up_position = Vector3( 208.9661, -354.614 + 860, 20.8995 ),
    },
}

STRIP_CLUB_ZONE = 
{
    position = Vector3( -74.25, -121.72, 1371.5 ), 
    size = Vector3( 47, 34, 10 )
}

----------------------------------------------
-- Переменные для бара
----------------------------------------------

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
        price = 500,
        currency = "soft",
        intoxication = 60,
    },
    [ ALCOHOL_COCKTAIL ] = {
        id = "cocktail",
        name = "Коктейль",
        price = 750,
        currency = "soft",
        intoxication = 90,
    },
    [ ALCOHOL_VODKA ] = {
        id = "vodka",
        name = "Водка",
        price = 1500,
        currency = "soft",
        intoxication = 120,
    },
    [ ALCOHOL_WISKI ] = {
        id = "wiski",
        name = "Виски",
        price = 2500,
        currency = "soft",
        intoxication = 150,
    },
}

----------------------------------------------
-- Переменные для подиумных и приватных тацев
----------------------------------------------

IFP_STRIP_BLOCK_NAME = "strip_club.dances"

enum "eDanceGirls" {
	"GIRL_POISON_IVY",
	"GIRL_FAYE_VALENTINE",
	"GIRL_DOMINEERING_SITH",
    "GIRL_HARLEY_QUINN",
    "GIRL_COMMON_DANCE",
}

GIRL_MODELS =
{
    [ GIRL_POISON_IVY ] = 308,
    [ GIRL_FAYE_VALENTINE ] = 307,
    [ GIRL_DOMINEERING_SITH ] = 309,
    [ GIRL_HARLEY_QUINN ] = 306,
}

PODIUM_DANCE_GIRLS =
{
    [ GIRL_POISON_IVY ] ={
        id = "poison_ivy",
        name = "Ядовитый Плющ",
        price = 15000,
        currency = "soft",
        anim_duration = 60,
        dance_duration = 80,
    },
    [ GIRL_FAYE_VALENTINE ] ={
        id = "faye_valentine",
        name = "Фэй Валентайн",
        price = 25000,
        currency = "soft",
        anim_duration = 60,
        dance_duration = 80,
    },
    [ GIRL_DOMINEERING_SITH ] ={
        id = "domineering_sith",
        name = "Властный ситх",
        price = 35000,
        currency = "soft",
        anim_duration = 60,
        dance_duration = 80,
    },
    [ GIRL_HARLEY_QUINN ] ={
        id = "harley",
        name = "Харли Квин",
        price = 45000,
        currency = "soft",
        anim_duration = 60,
        dance_duration = 80,
    },
    [ GIRL_COMMON_DANCE ] ={
        id = "common_dance",
        name = "Общий танец",
        price = 99,
        currency = "hard",
        anim_duration = 60,
        dance_duration = 80,
    },
}


PRIVATE_DANCE_PLAYER_POSITION = Vector3( -52.1449, -114.3229, 1372.8312 )
PRIVATE_DANCE_PLAYER_ROTATION = Vector3( 0, 0, 0 )

FINISH_PRIVATE_DANCE_PLAYER_POSITION = Vector3( -49.2166, -108.8603, 1372.6600 )
FINISH_PRIVATE_DANCE_PLAYER_ROTATION = Vector3( 0, 0, 0 )

PRIVATE_DANCE_GIRLS =
{
    [ GIRL_POISON_IVY ] ={
        id = "poison_ivy",
        name = "Ядовитый Плющ",
        price = 30000,
        currency = "soft"
    },
    [ GIRL_FAYE_VALENTINE ] ={
        id = "faye_valentine",
        name = "Фэй Валентайн",
        price = 50000,
        currency = "soft",
    },
    [ GIRL_DOMINEERING_SITH ] ={
        id = "domineering_sith",
        name = "Властный ситх",
        price = 70000,
        currency = "soft",
    },
    [ GIRL_HARLEY_QUINN ] ={
        id = "harley",
        name = "Харли Квин",
        price = 90000,
        currency = "soft",
    },
}