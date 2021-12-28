loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "rewards/_ShItems" )

REQUIRED_PLAYER_LEVEL = 6
COOP_QUESTS_CONFIG = { }
REGISTERED_CASE_ITEMS = { }

enum "eCoopQuestTypes" {
	"QUEST_TYPE_POINT_CAPTURE",
	"QUEST_TYPE_DRUGS_COLLECTION",
	"QUEST_TYPE_DATA_COLLECTION",
}

SHOP_ITEMS_LIST = 
{
	{
		type = "vinyl_case",
		id = 1,
		cost = 4,
		soft_value = { 69000, 99000, 149000, 199000, 249000 },
		name = "Стильный Винил кейс",
		count = 1,
	},
	{
		type = "vinyl_case",
		id = 3,
		cost = 12,
		soft_value = { 269000, 299000, 349000, 399000, 499000 },
		name = "Королевский Винил кейс",
		count = 1,
	},
	{
		type = "tuning_case",
		id = 3,
		cost = 20,
		soft_value = { 190000, 500000, 586000, 744000, 2128000 },
		name = "Фартовый Тюнинг кейс",
		count = 1,
	},
	{
		type = "tuning_case",
		id = 4,
		cost = 28,
		soft_value = { 99000, 199000, 269000, 349000, 499000 },
		name = "Скоростной Тюнинг кейс",
		count = 1,
	},
	{
		type = "repairbox",
		cost = 2,
		soft_value = 25000,
		name = "Ремкомплект",
		count = 1,
	},
	{
		type = "case",
		id = "bp_season_21",
		cost = 56,
		soft_value = 299000,
		name = "Кейс Сезонный 21",
		count = 1,
		is_case = true,
	}
}

QUEST_START_LOCATIONS = 
{
	-- НСК
	{
		ped_conf = { x = 488.800, y = 2192.781, z = 15.207, rz = 200 },
		vehicle_conf = { x = 447.271, y = 2179.038, z = 15.82, rz = 10 },
		spawn_conf =  { x = 451.893, y = 2179.461, z = 15.681 }, --{ x = 487.98, y = 2191.38, z = 15.21 },
	},
	
	-- ГРК
	{
		ped_conf = { x = -44.421, y = 2584.076, z = 21.607, rz = 230 },
		vehicle_conf = { x = -23.429, y = 2498.620, z = 21.43, rz = 150 },
		spawn_conf = { x = -27.936, y = 2501.496, z = 21.607 },
	},

	-- МСК
	{
		ped_conf = { x = -649.25, y = 2136.03, z = 20.12, rz = 50 },
		vehicle_conf = { x = -630.257, y = 2129.847, z = 15.670, rz = 150 },
		spawn_conf = { x = -649.25, y = 2136.03, z = 20.12 },
	},
}

function GetTimerString( time_left )
	local minutes = math.floor( time_left/60 )
	local seconds = time_left - 60*minutes

	return string.format( "%02d:%02d", minutes, seconds )
end