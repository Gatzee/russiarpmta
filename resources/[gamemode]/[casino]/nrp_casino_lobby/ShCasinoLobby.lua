loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

COUNT_PLAYER_GAME_VARIANTS = 
{
    default = { 3, 4, 5 },
	[ CASINO_GAME_DICE_VIP ] = { 2 },
	[ CASINO_GAME_ROULETTE ] = { 2, 4, 6 },
}

HARD_GAMES =
{
    [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = true,
}

BET_GAME_VARIANTS = 
{
    [ CASINO_MOSCOW ] =
    {
        default = { 500, 1000, 5000, 10000, 25000, 75000, 150000 },
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = { 5, 10, 20, 50, 100, 500 },
    },
    [ CASINO_THREE_AXE ] =
    {
        default = { 500, 1000, 5000, 10000, 25000, 75000, 150000 },
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = { 5, 10, 20, 50, 100, 500 },
    },
}