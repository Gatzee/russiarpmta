loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )

enum "eClassicRouletteRates" {
    "CR_RATE_1",
    "CR_RATE_2",
    "CR_RATE_3",
    "CR_RATE_4",
    "CR_RATE_5",
    "CR_RATE_6",
}

MIN_RATES = 
{
    [ CASINO_THREE_AXE ] = 
    {
        [ CASINO_GAME_CLASSIC_ROULETTE ] = 500,
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = 50,
    },
    [ CASINO_MOSCOW ] =
    {
        [ CASINO_GAME_CLASSIC_ROULETTE ] = 5000,
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = 50,
    },
}

MAX_RATES = 
{
    [ CASINO_THREE_AXE ] = 
    {
        [ CASINO_GAME_CLASSIC_ROULETTE ] = 15000,
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = 500,
    },
    [ CASINO_MOSCOW ] =
    {
        [ CASINO_GAME_CLASSIC_ROULETTE ] = 150000,
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = 500,
    },
}

RATES_VALUES =
{
    [ CASINO_THREE_AXE ] =
    {
        [ CASINO_GAME_CLASSIC_ROULETTE ] = 
        {
            [ CR_RATE_1 ] = 500,
            [ CR_RATE_2 ] = 1000,
            [ CR_RATE_3 ] = 2000,
            [ CR_RATE_4 ] = 3000,
            [ CR_RATE_5 ] = 4000,
            [ CR_RATE_6 ] = 5000,
        },
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] =
        {
            [ CR_RATE_1 ] = 50,
            [ CR_RATE_2 ] = 75,
            [ CR_RATE_3 ] = 100,
            [ CR_RATE_4 ] = 150,
            [ CR_RATE_5 ] = 200,
            [ CR_RATE_6 ] = 250,
        },
    },
    [ CASINO_MOSCOW ] =
    {
        [ CASINO_GAME_CLASSIC_ROULETTE ] = 
        {
            [ CR_RATE_1 ] = 5000,
            [ CR_RATE_2 ] = 10000,
            [ CR_RATE_3 ] = 20000,
            [ CR_RATE_4 ] = 30000,
            [ CR_RATE_5 ] = 40000,
            [ CR_RATE_6 ] = 50000,
        },
        [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] =
        {
            [ CR_RATE_1 ] = 50,
            [ CR_RATE_2 ] = 75,
            [ CR_RATE_3 ] = 100,
            [ CR_RATE_4 ] = 150,
            [ CR_RATE_5 ] = 200,
            [ CR_RATE_6 ] = 250,
        },
    },
}

enum "eClassicRouletteStates" {
    "CR_STATE_RATE",
    "CR_STATE_ROTATE_DIAL",
    "CR_STATE_SHOW_RESULTS",
}

TIME_MOVE_CAMERA = 2
TIMEOUT_TIME = 250

DURATION_STATE =
{
    [ CR_STATE_RATE ]         = 25 + TIME_MOVE_CAMERA,
    [ CR_STATE_ROTATE_DIAL ]  = 13,
    [ CR_STATE_SHOW_RESULTS ] = 4,
}

CAMERA_POSITIONS = 
{
    [ CASINO_THREE_AXE ] =
    {
        [ CR_STATE_RATE ]        = { -86.6412, -471.5094, 916.0059, -86.7284, -471.5094, 915.0097, 0, 70 },
        [ CR_STATE_ROTATE_DIAL ] = { -86.6420, -469.4750, 916.1079, -86.7291, -469.4750, 915.1117, 0, 75 },
        [ CR_STATE_SHOW_RESULTS ] = { -86.6420, -469.4750, 916.1079, -86.7291, -469.4750, 915.1117, 0, 75 },
    },
    [ CASINO_MOSCOW ] =
    {
        [ CR_STATE_RATE ]        =  { 2443.6684570313, -1327.8332519531, 2801.7934570313, 2443.5432128906, -1373.1208496094, 2712.6362304688, 0, 70 },
        [ CR_STATE_ROTATE_DIAL ] =  { 2441.5698242188, -1327.828125, 2801.7934570313, 2441.4445800781, -1373.1157226563, 2712.6362304688, 0, 75 },
        [ CR_STATE_SHOW_RESULTS ] = { 2441.5698242188, -1327.828125, 2801.7934570313, 2441.4445800781, -1373.1157226563, 2712.6362304688, 0, 75 },
    },
}

DIAL_SPEED =
{
    [ CR_STATE_RATE ] = 0,
    [ CR_STATE_ROTATE_DIAL ] = 6,
}

enum "eClassicRouletteNumberColors" {
	"CR_BLACK",
	"CR_RED",
    "CR_GREEN",
    "CR_RED_ALL",
    "CR_BLACK_ALL",
}

COLOR_NAMES = 
{
    [ CR_BLACK ] = "black",
    [ CR_RED ] = "red",
    [ CR_GREEN ] = "green",
}

ROULETTE_FIELDS =
{
    { id = 1,  value = 0,  type = CR_GREEN,     position = { [ CASINO_THREE_AXE ] = Vector3( -86.453048400879 - 0.1, -471.51177612305, 913.91497802734 ), [ CASINO_MOSCOW ] = Vector3( 2443.699, -1328.410, 2799.850 ), }, ring_id = 28 },
    
    { id = 2,  value = 3,  type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -472.51678466797, 913.91497802734 ) }, ring_id = 26 },
    { id = 3,  value = 6,  type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -472.33377075195, 913.91497802734 ) }, ring_id = 1 },
    { id = 4,  value = 9,  type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -472.15078735352, 913.91497802734 ) }, ring_id = 18 },
    { id = 5,  value = 12, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -471.96777343751, 913.91497802734 ) }, ring_id = 24 },
    { id = 6,  value = 15, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -471.78479003906, 913.91497802734 ) }, ring_id = 30 },
    { id = 7,  value = 18, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -471.60177612305, 913.91497802734 ) }, ring_id = 20 },
    { id = 8,  value = 21, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -471.41879272461, 913.91497802734 ) }, ring_id = 33 },
    { id = 9,  value = 24, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -471.23577880859, 913.91497802734 ) }, ring_id = 11 },
    { id = 10, value = 27, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -471.05279541016, 913.91497802734 ) }, ring_id = 2  },
    { id = 11, value = 30, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -470.86978149414, 913.91497802734 ) }, ring_id = 6  },
    { id = 12, value = 33, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -470.68679809572, 913.91497802734 ) }, ring_id = 13 },
    { id = 13, value = 36, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.353050231934 - 0.1, -470.50378417969, 913.91497802734 ) }, ring_id = 4  },
    
    { id = 14, value = 2,  type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -472.51678466797, 913.91497802734 ) }, ring_id = 34 },
    { id = 15, value = 5,  type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -472.33377075195, 913.91497802734 ) }, ring_id = 10 },
    { id = 16, value = 8,  type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -472.15078735352, 913.91497802734 ) }, ring_id = 7  },
    { id = 17, value = 11, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -471.96777343751, 913.91497802734 ) }, ring_id = 5  },
    { id = 18, value = 14, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -471.78479003906, 913.91497802734 ) }, ring_id = 16 },
    { id = 19, value = 17, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -471.60177612305, 913.91497802734 ) }, ring_id = 36 },
    { id = 20, value = 20, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -471.41879272461, 913.91497802734 ) }, ring_id = 15 },
    { id = 21, value = 23, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -471.23577880859, 913.91497802734 ) }, ring_id = 8  },
    { id = 22, value = 26, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -471.05279541016, 913.91497802734 ) }, ring_id = 27 },
    { id = 23, value = 29, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -470.86978149414, 913.91497802734 ) }, ring_id = 21 },
    { id = 24, value = 32, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -470.68679809572, 913.91497802734 ) }, ring_id = 29 },
    { id = 25, value = 35, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -87.063049316406 - 0.1, -470.50378417969, 913.91497802734 ) }, ring_id = 25 },
    
    { id = 26, value = 1,  type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -472.51678466797, 913.91497802734 ) }, ring_id = 14 },
    { id = 27, value = 4,  type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -472.33377075195, 913.91497802734 ) }, ring_id = 32 },
    { id = 28, value = 7,  type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -472.15078735352, 913.91497802734 ) }, ring_id = 22 },
    { id = 29, value = 10, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -471.96777343751, 913.91497802734 ) }, ring_id = 9  },
    { id = 30, value = 13, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -471.78479003906, 913.91497802734 ) }, ring_id = 3  },
    { id = 31, value = 16, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -471.60177612305, 913.91497802734 ) }, ring_id = 12 },
    { id = 32, value = 19, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -471.41879272461, 913.91497802734 ) }, ring_id = 31 },
    { id = 33, value = 22, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -471.23577880859, 913.91497802734 ) }, ring_id = 19 },
    { id = 34, value = 25, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -471.05279541016, 913.91497802734 ) }, ring_id = 35 },
    { id = 35, value = 28, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -470.86978149414, 913.91497802734 ) }, ring_id = 23 },
    { id = 36, value = 31, type = CR_BLACK,     position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -470.68679809572, 913.91497802734 ) }, ring_id = 17 },
    { id = 37, value = 34, type = CR_RED,       position = { [ CASINO_THREE_AXE ] = Vector3( -86.773048400879 - 0.1, -470.50378417969, 913.91497802734 ) }, ring_id = 37 },
 
    { id = 38, value = 37, type = CR_RED_ALL,   position = { [ CASINO_THREE_AXE ] = Vector3( -86.453048400879 - 0.1, -472.12078735352, 913.91497802734 ), [ CASINO_MOSCOW ] = Vector3( 2444.301, -1328.413, 2799.850 ), } },
    { id = 39, value = 38, type = CR_BLACK_ALL, position = { [ CASINO_THREE_AXE ] = Vector3( -86.453048400879 - 0.1, -470.91978149414, 913.91497802734 ), [ CASINO_MOSCOW ] = Vector3( 2443.096, -1328.413, 2799.850), } },
}


function GetRouletteFieldById( field_id )
    for k, v in pairs( ROULETTE_FIELDS ) do
        if k == field_id then
            return table.copy( v )
        end
    end
    return false
end

function GetRouletteFieldByPosition( casino_id, target_pos )
    local available_fields = {}
    for k, v in pairs( ROULETTE_FIELDS ) do
        local distance_between_points = getDistanceBetweenPoints3D( target_pos, v.position[ casino_id ] )
        if distance_between_points <= 0.15 then
            table.insert( available_fields, { id = k, distance = distance_between_points } )
        end
    end
    table.sort( available_fields, function( a, b )
        return a.distance < b.distance
    end )
    if #available_fields > 0 then
        return table.copy( ROULETTE_FIELDS[ available_fields[ 1 ].id ] )
    end
    return false
end

local start = Vector3( 2444.691, -1329.293, 2799.850 )
local x, y = 0, 0
local counter = 0
for i = 2, 37 do
    ROULETTE_FIELDS[ i ].position[ CASINO_MOSCOW ] = start + Vector3( x, y, 0 )
    
    counter = counter + 1
    if counter % 12 == 0 then
        y = y + 0.28 
        x = 0
    else
        x = x - 0.18
    end
end