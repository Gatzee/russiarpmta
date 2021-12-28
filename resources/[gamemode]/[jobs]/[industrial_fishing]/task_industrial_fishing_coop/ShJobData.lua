loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

enum "eCoopJobRoles" 
{
    "DRIVER",
    "FISHERMAN",
    "COORDINATOR",
}

enum "eManipulatorObject" 
{
	"MANIPULATION_FISH_EMPTY",
	"MANIPULATION_FISH_FULL",
	"MANIPULATION_CONTAINER_CREATE",
	"MANIPULATION_CONTAINER_LOADED",
}

enum "eBoatSides"
{
	"LEFT_BOAT_SIDE",
	"RIGHT_BOAT_SIDE",
}

RESPAWN_POSITIONS = {
	Vector3( -2064.3715, 2834.2731, 3.45 ),
}

SHIP_SPAWN = {
	[ FISHERMAN ] = {
		Vector3(  3, 15, 1.5 ),
		Vector3( -3, 15, 1.5 ),
	},
	[ COORDINATOR ] = Vector3( 0, 15, 2 ),
}

FISHING_ROUTES = {
	-- ROUTE 1
	{
		Vector3( -978.27,  1638.32, 0 ),
		Vector3( -2285.56, 876.18,  0 ),
		Vector3( -2837.51, 2152.71, 0 ),
		Vector3( -3030.24, 881.78,  0 ),
		Vector3( -3224.38, -672.03, 0 ),
		Vector3( -3157.73, 979.57,  0 ),
		Vector3( -3211.13, 2557.31, 0 ),
		Vector3( -2703.51, 3234.15, 0 ),
		Vector3( -2198.33, 2116.76, 0 ),
		Vector3( -1747.24, 2605.46, 0 ),
	},
	-- ROUTE 2
	{
		Vector3( -2271.06, 3022.14, 0 ),
		Vector3( -336.43,  3037.45, 0 ),
		Vector3( 1698.9,   3046.87, 0 ),
		Vector3( 2997.45,  2220.41, 0 ),
		Vector3( 1332.74,  2014.37, 0 ),
		Vector3( 2929.99,  2246.39, 0 ),
		Vector3( 1523.27,  3023.65, 0 ),
		Vector3( -481.65,  3035.36, 0 ),
		Vector3( -2503.64, 2980.38, 0 ),
		Vector3( -1853.72, 2102.32, 0 ),
	},
	-- ROUTE 3
	{
		Vector3( -1905.46, 3021.49, 0 ),
		Vector3( 136.1,    3040.15, 0 ),
		Vector3( 2004.56,  3093.84, 0 ),
		Vector3( 18.08,    3103.58, 0 ),
		Vector3( -1993.37, 3050.26, 0 ),
		Vector3( -3035.56, 2023.67, 0 ),
		Vector3( -2269.12, 924.24,  0 ),
		Vector3( -498.65,  1345.17, 0 ),
		Vector3( -1484.39, 1910.16, 0 ),
		Vector3( -2815.54, 2385.15, 0 ),
	},
	-- ROUTE 4
	{
		Vector3( -3001.62, 827.23,  0 ),
		Vector3( -3149.96, -900.02, 0 ),
		Vector3( -3111.72, 645.9,   0 ),
		Vector3( -3156.5,  2397.24, 0 ),
		Vector3( -2026.76, 1437.35, 0 ),
		Vector3( -2188.63, 865.33,  0 ),
		Vector3( -1191.05, 1364.11, 0 ),
		Vector3( -27.79,   1255.41, 0 ),
		Vector3( -1629.01, 2263.88, 0 ),
		Vector3( -2804.8,  2246.01, 0 ),
	},
	-- ROUTE 5
	{
		Vector3( -3034.42, 840.46,  0 ),
		Vector3( -3216.25, -78.52,  0 ),
		Vector3( -3045.31, 1631.55, 0 ),
		Vector3( -2021.32, 1425.07, 0 ),
		Vector3( -1724.47, 2253.38, 0 ),
		Vector3( -855.39,  1542.92, 0 ),
		Vector3( 748.25,   1219.19, 0 ),
		Vector3( 1174.08,  1367.46, 0 ),
		Vector3( -643.14,  1361.17, 0 ),
		Vector3( -1956.13, 1960.52, 0 ),
	},
	-- ROUTE 6
	{
		Vector3( -2981.22, 1342.63, 0 ),
		Vector3( -3179.96, -210.69, 0 ),
		Vector3( -3206.77, 1701.23, 0 ),
		Vector3( -2766.82, 3223.17, 0 ),
		Vector3( -1895.6,  2323.32, 0 ),
		Vector3( -813.42,  1397.7,  0 ),
		Vector3( 772.74,   1208.69, 0 ),
		Vector3( 1813.74,  2125.51, 0 ),
		Vector3( 602.07,   1215.16, 0 ),
		Vector3( -1216.08, 1473.42, 0 ),
	},
	-- ROUTE 7
	{
		Vector3( -1178.85, 1416.39, 0 ),
		Vector3( 851.16,   1236.05, 0 ),
		Vector3( 2170.97,  1932.21, 0 ),
		Vector3( 846.43,   1264.13, 0 ),
		Vector3( -977.53,  1366.78, 0 ),
		Vector3( -2412.44, 2071.78, 0 ),
		Vector3( -3114.8,  3148.44, 0 ),
		Vector3( -1416.76, 3059.02, 0 ),
		Vector3( -3167.3,  3017.26, 0 ),
		Vector3( -1795.91, 2275.84, 0 ),
	},
	-- ROUTE 8
	{
		Vector3( -3172.51, 3075.61, 0 ),
		Vector3( -1417.51, 3008.26, 0 ),
		Vector3( 488.13,   3055.58, 0 ),
		Vector3( -1496.29, 3073.66, 0 ),
		Vector3( -3145.02, 2701.61, 0 ),
		Vector3( -1755.12, 1515.28, 0 ),
		Vector3( -82.71,   1292.14, 0 ),
		Vector3( 1324.64,  1867.54, 0 ),
		Vector3( 146.26,   1250.87, 0 ),
		Vector3( -1259.25, 1733.35, 0 ),
	},
	-- ROUTE 9
	{
		Vector3( -1478.76, 1688.18, 0 ),
		Vector3( -397.86, 1353.9, 0 ),
		Vector3( 1139.56, 1349.96, 0 ),
		Vector3( -546.76, 1369.96, 0 ),
		Vector3( -2063.14, 924.65, 0 ),
		Vector3( -2465.7, 2081.46, 0 ),
		Vector3( -3038.55, 1487.67, 0 ),
		Vector3( -2966.42, 3198.88, 0 ),
		Vector3( -2448.56, 2221.84, 0 ),
		Vector3( -1638.39, 2051.42, 0 ),
	},
	-- ROUTE 10
	{
		Vector3( -1247.9, 1841.42, 0 ),
		Vector3( -64.55, 1276.44, 0 ),
		Vector3( -1071.64, 1379.64, 0 ),
		Vector3( -2268.83, 940.02, 0 ),
		Vector3( -1752.59, 1906.28, 0 ),
		Vector3( -3092.58, 1519.55, 0 ),
		Vector3( -3096.84, 443.54, 0 ),
		Vector3( -3123.56, 2035.95, 0 ),
		Vector3( -3163.12, 3149.18, 0 ),
		Vector3( -1945.8, 2055.12, 0 ),
	},
}

FISH_DEPTHS = { 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000 }

FISHING_AREA_RADIUS = 100
FISHING_FISH_RADIUS = 12

FISHING_FISH_RANDOM_RADIUS = 50

COUNT_FISH_IN_ZONE = 10

SIZE_FISH_IN_ZONE = 250
SIZE_SIDE_HOLD = SIZE_FISH_IN_ZONE

SIZE_HOLD = #FISHING_ROUTES[ 1 ] * SIZE_FISH_IN_ZONE * 2

CONTAINER_ID = 840
CONTAINER_UNLOAD_COUNT = 3
CONTAINER_SHAPE_RADIUS = 2

PORT_POINTS = 
{
	{ position = Vector3( -2677.7312, 2570.2160, 2.962 ), rotation = Vector3( 0, 0, 180 ) }, -- 1
	{ position = Vector3( -2441.2060, 2570.2160, 2.962 ), rotation = Vector3( 0, 0, 180 ) }, -- 4
	{ position = Vector3( -2202.2060, 2570.2160, 2.962 ), rotation = Vector3( 0, 0, 180 ) }, -- 7
	{ position = Vector3( -2125.2060, 2570.2160, 2.962 ), rotation = Vector3( 0, 0, 180 ) }, -- 8
	{ position = Vector3( -1965.2060, 2570.2160, 2.962 ), rotation = Vector3( 0, 0, 180 ) }, -- 10
}