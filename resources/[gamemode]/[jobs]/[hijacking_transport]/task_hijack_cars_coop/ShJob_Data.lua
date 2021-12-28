
POSITIONS_HIJACKED_CARS =
{
    {
        vehicle  = { pos = Vector3( -610.03, 369.88 + 860, 19.71 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -593.44, 369.78 + 860, 19.7 ),
    },
    {
        vehicle  = { pos = Vector3( -476.67, 350.39 + 860, 19.7 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -482.5, 373.36 + 860, 19.7 ),
    },
    {
        vehicle  = { pos = Vector3( -481.65, 557.2 + 860, 19.71 ), rot = Vector3( 0, 0, 313 ) },
        break_in = Vector3( -481.3, 583.58 + 860, 19.71 ),
    },
    {
        vehicle  = { pos = Vector3( -423.78, 638.41 + 860, 19.7 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -402.7, 630.29 + 860, 19.7 ),
    },
    {
        vehicle  = { pos = Vector3( -294.57, 634.98 + 860, 19.71 ), rot = Vector3( 0, 0, 122 ) },
        break_in = Vector3( -294.64, 609.66 + 860, 19.71 ),
    },
    {
        vehicle  = { pos = Vector3( -102.5, 630.91 + 860, 19.7 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -83.17, 639.73 + 860, 19.7 ),
    },
    {
        vehicle  = { pos = Vector3( -331.56, 350.25 + 860, 19.7 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -340.29, 370.63 + 860, 19.7 ),
    },
    {
        vehicle  = { pos = Vector3( 166.66, -323.22 + 860, 19.7 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( 166.54, -345.43 + 860, 19.7 ),
    },
    {
        vehicle  = { pos = Vector3( 500.33, 2491.99 + 860, 20.4 ), rot = Vector3( 0, 0, 280 ) },
        break_in = Vector3( 483.21, 2462.72 + 860, 20.4 ),
    },
    {
        vehicle  = { pos = Vector3( 515.37, 2416.23 + 860, 20.4 ), rot = Vector3( 0, 0, 280 ) },
        break_in = Vector3( 500.01, 2394.67 + 860, 20.4 ),
    },
    {
        vehicle  = { pos = Vector3( 22.96, 2798.99 + 860, 14.44 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( 61.49, 2785.69 + 860, 14.44 ),
    },
    {
        vehicle  = { pos = Vector3( -364.83, 2772.99 + 860, 13.93 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -325.23, 2744.55 + 860, 13.93 ),
    },
    {
        vehicle  = { pos = Vector3( -522.78, 2437.51 + 860, 14.94 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -569.75, 2451.91 + 860, 15.69 ),
    },
    {
        vehicle  = { pos = Vector3( -650.13, 2550.89 + 860, 16.72 ), rot = Vector3( 0, 0, 0 ) },
        break_in = Vector3( -677.68, 2572 + 860, 16.72 ),
    },
    
}

--[[
if localPlayer then
    for k, v in pairs( POSITIONS_HIJACKED_CARS ) do
        createBlip( v.break_in )
    end
end
]]

HIJACKED_CARS_ID = 
{ 
    6532, 412, 439, 445, 470, 475, 479, 507, 518, 547, 562, 567, 575, 576, 580, 589, 600, 603, 6527, 6535, 6537, 401, 411, 415, 429, 451, 496, 
    506, 526, 527, 534, 535, 541, 545, 562, 596, 602, 6526, 6529, 6531, 6533, 6538, 6539, 6540, 6541, 6542, 6543, 6545, 6546, 6551, 6553, 533, 
    558, 503, 409, 542, 555, 550, 502, 6558, 6561, 474, 494, 6572, 6574, 6569, 6568, 6580, 6581, 6579, 6585, 6582, 6588, 6592, 6595, 6602
}

HIJACKED_CARS_COLOR = 
{
    { 0,   0,   0   },
    { 255, 255, 255 },
    { 82,  2,   2   },
    { 3,   107, 31  },
    { 82,  53,  2   },
    { 6,   2,   82  },
    { 42,  2,   82  },
    { 153, 153, 153 },
}

POSITIONS_SUMP_CARS =
{
    Vector3( 555.86572, 1375.99, 20.698 ),
    Vector3( 325.047, -309.927, 20.926 ),
    Vector3( -61.049, -489.41152, 20.596 ),
    Vector3( 303.713, -861.62, 20.748 ),
    Vector3( 172.928, 535.3806, 20.7010 ),
   
}

CONST_MAX_CACHE_HIJACK_POINTS = 4
CONST_MIN_DISTANCE_BETWEEN_POINTS = 1000

CONST_ENTER_HIJACK_CAR_TIME_IN_MS = 1 * 60 * 1000
CONST_DELIVERY_HIJACK_CAR_TIME_IN_MS = 5 * 60 * 1000
CONST_FAILURE_TIME_EXIT_HICJAK_CAR_IN_MS = 120 * 1000

CONST_MAX_DISTANCE_FROM_HIJACK_CAR = 100
CONST_FAILURE_TIME_AT_DISTANCE_FROM_CAR_IN_MS = 30 * 1000

CONST_MAX_DISTANCE_BETWEEN_PLAYERS = 200
CONST_FAILURE_TIME_ON_DISTANCE_PLAYERS_IN_MS = 15 * 1000

CONST_DISTANCE_CREATE_MASTER_SUMP_POINT = 100

CONST_BREAKIN_CAR_TIME_IN_SEC = 40
CONST_PASSOWRD_SYMBOLS = { "A", "B", "C", "D", "E", "F", "G", "J", "K", "M", "N", "P", "Q", "R", "S", "U", "V", "W", "Y", "F", "H", "Q", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }

REVERSE_PASSWORD_SYMBOLS =  {}
for k, v in pairs( CONST_PASSOWRD_SYMBOLS ) do
    REVERSE_PASSWORD_SYMBOLS[ v ] = true
end