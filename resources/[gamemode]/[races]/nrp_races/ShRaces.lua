loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend("ShUtils")
Extend("ShVehicleConfig")
Extend( "ShAccessories" )
Extend( "ShRace" )

RACING_DIMENSION = 8276

enum "eLobbyStates" {
	"LOBBY_STATE_CLOSED",
	"LOBBY_STATE_OPENED",
	"LOBBY_STATE_SEARCHING",
	"LOBBY_STATE_PROGRESS",
	"LOBBY_STATE_STARTED",
	"LOBBY_STATE_FINISHED",
	"LOBBY_STATE_DISABLED",
}

enum "eRaceStats" {
	"RACE_STATE_WIN",
	"RACE_STATE_LOSE",
	"RACE_STATE_FINISH",
}

RACE_VEHICLE_CLASSES_NAMES =
{
	[ 1 ] = "A",
	[ 2 ] = "B",
	[ 3 ] = "C",
	[ 4 ] = "D",
	[ 5 ] = "S",
}

RACE_TYPES_DATA = 
{
	[ RACE_TYPE_CIRCLE_TIME ] = 
	{
		type = "circle",
		name = "Круг на время",
		min_participants = 1,
		max_participants = 4,
		maps = { "track_sochi_track" },
		available = true,
	},

	[ RACE_TYPE_DRIFT ]  = 
	{
		type = "drift",
		name = "Дрифт",
		min_participants = 1,
		max_participants = 4,
		maps = { "track_sochi_drift" },
		available = true,
	},

	[ RACE_TYPE_DRAG ] = 
	{
		type = "drag",
		name = "Драг-рейсинг",
		min_participants = 1,
		max_participants = 2,
		maps = { "track_drag_track" },
		available = true,
	},
}
REVERSE_RACE_TYPES = {}
for k, v in pairs( RACE_TYPES_DATA ) do
	REVERSE_RACE_TYPES[ v.type ] = k
end

SEASON_RACE_TYPES = 
{
	[ RACE_TYPE_CIRCLE_TIME ] = true,
	[ RACE_TYPE_DRIFT ] = true,
}

SEASON_REWARD =
{
	[ 1 ] =
	{
		[ RACE_TYPE_DRIFT ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "tuning_case", value = 2 },
			},
			[ 2 ] = 
			{
				[ 1 ] = { type = "vinil",       value = "uniq_3", count = 2, cost = 180000 },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "accessories", value = "m3_acse18",    },
			}
		},
		[ RACE_TYPE_CIRCLE_TIME ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "vinil", 		value = "uniq_1", count = 2, cost = 200000 },
			},
			[ 2 ] =
			{
				[ 1 ] = { type = "accessories", value = "m3_acse20",    },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_5", count = 2, cost = 160000 },
			}
		},
	},

	[ 2 ] =
	{
		[ RACE_TYPE_DRIFT ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_1", count = 2, cost = 200000 },
			},
			[ 2 ] =
			{
				[ 1 ] = { type = "accessories", value = "m3_acse19",    },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_6", count = 2, cost = 150000 },
			},
		},
		[ RACE_TYPE_CIRCLE_TIME ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "tuning_case", value = 2 },
			},
			[ 2 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_2", count = 2, cost = 190000 },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "accessories", value = "m3_acse17",    },
			},
		},
	},

	[ 3 ] =
	{
		[ RACE_TYPE_DRIFT ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "vinil_case",  value = 3 },
			},
			[ 2 ] =
			{
				[ 1 ] = { type = "accessories", value = "m3_acse19",    },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_5", count = 2, cost = 160000 },
			},
		},
		[ RACE_TYPE_CIRCLE_TIME ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_1", count = 2, cost = 200000 },
			},
			[ 2 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_4", count = 2, cost = 170000 },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "accessories", value = "m3_acse17",    },
			},
		},
	},

	[ 4 ] =
	{
		[ RACE_TYPE_DRIFT ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_1", count = 2, cost = 200000 },
			},
			[ 2 ] =
			{
				[ 1 ] = { type = "vinil",       value = "uniq_4", count = 2, cost = 170000 },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "accessories", value = "m3_acse18",    },
			},
		},
		[ RACE_TYPE_CIRCLE_TIME ] =
		{
			[ 1 ] =
			{
				[ 1 ] = { type = "vinil_case", value = 3 },
			},
			[ 2 ] =
			{
				[ 1 ] = { type = "vinil",      value = "uniq_3", count = 2, cost = 180000 },
			},
			[ 3 ] =
			{
				[ 1 ] = { type = "vinil",      value = "uniq_6", count = 2, cost = 150000 },
			},
		},
	},
}

CASES_NAME = {
	tuning_1 = "Базовый",
	tuning_2 = "Счастливчик",
	tuning_3 = "Фартовый",

	vinyl_1 = "Стильный", 
	vinyl_2 = "Легендарный", 
	vinyl_3 = "Королевский",
}

DRAG_DESTOY_TIME = 25

DRAG_RATES = {
	1000,
	2000,
	5000,
	10000,
	15000,
}