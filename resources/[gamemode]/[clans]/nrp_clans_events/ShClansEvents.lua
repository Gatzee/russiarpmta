EVENT_DIMENSION = 8956

LOBBY_STATE_CLOSED = 1
LOBBY_STATE_REGISTRATION = 2
LOBBY_STATE_PREPARATION = 3
LOBBY_STATE_STARTED = 4
LOBBY_STATE_FINISHED = 5
LOBBY_STATE_DESTROYED = 6

CLAN_EVENT_CONFIG = 
{
	[ CLAN_EVENT_DEATHMATCH ] = 
	{
		key = "deathmatch",
		analytics_key = "deathmatch",
		name = "Смертельный матч",
		resource_name = "nrp_game_team_deathmatch",
		is_available = true,
		reg_starts = { "16:00" },
		reg_duration = 3 * 60 * 60,
		preparation_duration = 20,
		game_duration = 12 * 60,
		players_count_per_clan = 12,

		rewards = 
		{
			clan_honor = 240,
			clan_money = 5000,

			player = 
			{
				clan_exp = 200,

				custom_func = function( pPlayer )
				end,
			}
		},

		loser_clan_honor_loss = 120,
		loser_clan_money_loss = 5000,
	},

	[ CLAN_EVENT_HOLDAREA ] = 
	{
		key = "holdarea",
		analytics_key = "clan_raid",
		name = "Рейдерский захват",
		resource_name = "nrp_game_holdarea",
		reg_starts = { "19:00" },
		is_available = true,
		reg_duration = 3 * 60 * 60,
		preparation_duration = 20,
		game_duration = 12 * 60,
		players_count_per_clan = 8,

		rewards = 
		{
			clan_honor = 240,
			clan_money = 5000,

			player = 
			{
				clan_exp = 200,

				custom_func = function( pPlayer )
				end
			},

			fn_reward = function( )

			end,
		},

		loser_clan_honor_loss = 120,
		loser_clan_money_loss = 5000,
	},

	-- [CLAN_EVENT_CAPTURE_POINTS] = 
	-- {
	-- 	key = "capture_points",
	-- 	name = "Захват трёх флагов",
	-- 	resource_name = "nrp_game_capture_points",
	-- 	is_available = true,
	-- 	reg_starts = { "14:30" },
	-- 	reg_duration = 60 * 60,
	-- 	preparation_duration = 5 * 60,
	-- 	game_duration = 30 * 60,
	-- 	min_participants = 10,
	-- 	max_participants = 100,
	-- 	max_disbalance = 0.6,

	-- 	rewards = 
	-- 	{
	-- 		clan_honor = 500,

	-- 		player = 
	-- 		{
	-- 			money = 50000,
	-- 			clan_exp = 500,

	-- 			custom_func = function( pPlayer )
	-- 			end
	-- 		}
	-- 	}
	-- },

	[ CLAN_EVENT_CARTEL_CAPTURE ] = 
	{
		key = "cartel_capture",
		name = "Война за Дом Картеля",
		resource_name = "nrp_game_team_deathmatch",
		is_available = false,
		join_event_name = "onPlayerWantJoinCartelWarEvent",
		-- reg_starts = { "16:00" },
		-- reg_duration = 3 * 60 * 60,
		preparation_duration = 15 * 60,
		game_duration = 12 * 60,
		players_count_per_clan = 12,
		create_lobby_on_first_register = true,
		is_lobby_managment_available = true,

		rewards = 
		{
			-- clan_honor = 180,

			-- player = 
			-- {
			-- 	money = 15000,
			-- 	clan_exp = 200,

			-- 	custom_func = function( pPlayer )
			-- 	end,
			-- }

		},

		fn_finish = function( results )
			triggerEvent( "onCartelHouseWarFinish", root, results )
		end,
	},

	[ CLAN_EVENT_CARTEL_TAX_WAR ] = 
	{
		key = "cartel_tax",
		name = "Война за общак",
		resource_name = "nrp_game_team_deathmatch",
		is_available = false,
		join_event_name = "onPlayerWantJoinCartelWarEvent",
		-- reg_starts = { "16:00" },
		-- reg_duration = 3 * 60 * 60,
		preparation_duration = 15 * 60,
		game_duration = 12 * 60,
		players_count_per_clan = 12,
		create_lobby_on_first_register = true,
		is_lobby_managment_available = true,

		rewards = 
		{
			-- clan_honor = 180,

			-- player = 
			-- {
			-- 	money = 15000,
			-- 	clan_exp = 200,

			-- 	custom_func = function( pPlayer )
			-- 	end,
			-- }

		},

		fn_finish = function( results )
			triggerEvent( "onCartelDeclaredWarFinish", root, results )
		end,
	},
}

for k, v in pairs( CLAN_EVENT_CONFIG ) do
	v.event_id = k
end

REGISTER_MARKERS = 
{
	{ 
        x = 1960.052, y = -2249.455, z = 30.057,
        band_id = 1,
    },
    { 
        x = 1915.794, y = -2252.392, z = 29.925,
        band_id = 1,
    },

    {
        x = -2745.094, y = -1761.091, z = 22.243,
        band_id = 2,
    },
    {
        x = -2723.105, y = -1756.353, z = 22.231,
        band_id = 2,
    },
}

RETURN_LOCATIONS = 
{
	purple = Vector3( 1939.572, -2244.303, 30.291 ),
	green = Vector3( -2736.034, -1801.862, 22.234 ),
}

function GetEventConfigs( )
	return CLAN_EVENT_CONFIG
end

function onClientClanWarEventStateChange_handler( event_id, state, lobby_id, start_date, enemy_clan_id )
	CLAN_EVENT_CONFIG[ event_id ].is_available = state
	CLAN_EVENT_CONFIG[ event_id ].lobby_id = lobby_id
	CLAN_EVENT_CONFIG[ event_id ].start_date = start_date
end
addEvent( "onClientClanWarEventStateChange", true )
addEventHandler( "onClientClanWarEventStateChange", root, onClientClanWarEventStateChange_handler )