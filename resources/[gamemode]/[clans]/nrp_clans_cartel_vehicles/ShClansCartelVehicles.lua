loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShClans" )
Extend( "ShVehicleConfig" )

CARTELS_VEHICLE_MARKERS = { 
	-- Запад
	{ x = -1947.5, y = 655.6 + 860, z = 18.485, cartel_id = 1 },
	{ x = -1949.913, y = 669.206 + 860, z = 18.485, cartel_id = 1 },

	-- Восток
	{ x = 1946.099, y = -2252.666 + 860, z = 29.887, cartel_id = 2 },
	{ x = 1932.737, y = -2253.064 + 860, z = 29.847, cartel_id = 2 },
}

CARTEL_VEHICLES_LIST = {
	{ model = 6527,	need_role = CLAN_ROLE_MIDDLE, 	 need_rank = 3 , num = 4 },
	{ model = 6527, need_role = CLAN_ROLE_MIDDLE, 	 need_rank = 3 , num = 3 },
	{ model = 579 ,	need_role = CLAN_ROLE_SENIOR, 	 need_rank = 5 , num = 2 },
	{ model = 579 ,	need_role = CLAN_ROLE_SENIOR, 	 need_rank = 5 , num = 1 },
	{ model = 6565, need_role = CLAN_ROLE_MODERATOR, need_rank = 6, num = 0 },
}

CARTEL_VEHICLES_PARKING_POSITIONS = 
{
	-- Запад
	{
		{ x = -1951.692, y = 666.033 + 860, z = 18.485, rz = 190 },
		{ x = -1947.015, y = 666.033 + 860, z = 18.485, rz = 190 },
		{ x = -1951.692, y = 658.199 + 860, z = 18.485, rz = 10 },
		{ x = -1947.015, y = 658.199 + 860, z = 18.485, rz = 10 },
	},

	--Восток
	{
		{ x = 1947.546, y = -2251.347 + 860, z = 29.946, rz = 95 },
		{ x = 1947.572, y = -2246.227 + 860, z = 30.193, rz = 95 },
		{ x = 1931.375, y = -2252.58 + 860, z = 29.875, rz = 275 },
		{ x = 1931.375, y = -2246.227 + 860, z = 30.193, rz = 275 },
	},
}