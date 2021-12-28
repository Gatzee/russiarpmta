loadstring( exports.interfacer:extend("Interfacer") )()
Extend( "ib" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShUtils" )

local icon = nil
local px, py = 278, _SCREEN_Y - 224

FORBIDDEN_PARKING_VEHICLES = {}
FORBIDDEN_ZONES = {}
FORBIDDEN_TIME = 5

PARKING_ZONES =
{
    -- НСК
    {
        -280.576, -1443.5541,
        -280.576, -1610.7579,
        -96.4505, -1610.7579,
        -96.3782, -1443.5541,
        -280.576, -1443.5541,
    },
    {
        51.1026, -1494.4891,
        239.3962, -1494.4891,
        239.3962, -1424.2435,
        51.1026, -1424.2435,
        51.1026, -1494.4891,
    },
    {
        -1342.5804, -1298.0526,
        -1187.6641, -1298.0526,
        -1187.6641, -1458.6152,
        -1342.5804, -1458.6152,
        -1342.5804, -1298.0526,
    },
    {
        -1342.2177, -1464.8922,
        -1187.7374, -1464.8922,
        -1187.7374, -1515.6434,
        -1342.2177, -1515.6434,
        -1342.2177, -1464.8922,
    },
    {
        -1342.2177, -1529.9913,
        -1149.8509, -1529.9913,
        -1149.8509, -1557.1734,
        -1342.2177, -1557.1734,
        -1342.2177, -1529.9913,
    },
    {
        -1306.3107, -1564.7446,
        -1149.8509, -1564.7446,
        -1149.8509, -1616.8825,
        -1306.3107, -1616.8825,
        -1306.3107, -1564.7446,
    },
    {
        -1142.2039, -1530.1314,
        -1096.0668, -1530.1314,
        -1096.0668, -1653.8111,
        -1142.2039, -1653.8111,
        -1142.2039, -1530.1314,
    },
    {
        -1003.6604, -1654.2245,
        -1003.6604, -1529.7557,
        -847.3809, -1529.7557,
        -847.3809, -1654.2245,
        -1003.6604, -1654.2245,
    },
    {
        -1254.9626, -1668.6595,
        -1254.9626, -1704.1702,
        -1342.1624, -1704.1702,
        -1342.1624, -1668.2705,
        -1254.9626, -1668.6595,
    },
    {
        -1240.0378, -1834.1922,
        -1240.0378, -1755.4941,
        -1196.5113, -1755.4941,
        -1196.5113, -1834.1922,
        -1240.0378, -1834.1922,
    },
    {
        -1189.2408, -1834.209,
        -1189.2408, -1668.3027,
        -1110.8454, -1668.3027,
        -1110.8454, -1730.6127,
        -1008.7578, -1730.6127,
        -1008.7578, -1668.3027,
        -941.8207, -1668.3027,
        -941.8207, -1834.209,
        -1189.2408, -1834.209,
    },
    {
        -41.2646, -1963.5446,
        -20.5566, -1963.5446,
        47.1211, -1938.2694,
        235.9098, -1938.2746,
        235.9098, -2001.1511,
        -41.2646, -2001.123,
        -41.2646, -1963.5446,
    },
    {
        257.5082, -1938.6586,
        604.2894, -1938.6586,
        604.2894, -2001.201,
        257.5082, -2001.201,
        257.5082, -1938.6586,
    },
    {
        235.914, -2015.1464,
        -41.1978, -2015.1464,
        -41.46, -2049.6242,
        -31.2356, -2079.0703,
        233.4592, -2080.7132,
        235.914, -2015.1464,
    },
    {
        602.0725, -1916.1046,
        602.0725, -1864.9918,
        458.5902, -1864.9918,
        458.5902, -1679.891,
        770.423, -1687.2766,
        770.7463, -1916.1046,
        602.0725, -1916.1046,
    },
    {
        257.5397, -1869.7601,
        297.5091, -1869.7601,
        297.5091, -1823.9502,
        369.0351, -1823.9502,
        369.0351, -1916.0886,
        257.5875, -1916.0886,
        257.5397, -1869.7601,
    },
    {
        236.8008, -1745.6519,
        236.8008, -1591.506,
        52.1863, -1591.506,
        52.1863, -1745.6519,
        236.8008, -1745.6519,
    },
    {
        236.7169, -1808.9113,
        72.9545, -1808.9113,
        72.9545, -1760.0237,
        236.7169, -1760.0237,
        236.7169, -1808.9113,
    },
    {
        47.5112, -1759.8208,
        67.9456, -1759.8208,
        67.9456, -1871.5463,
        51.5777, -1871.5463,
        51.5777, -1915.9399,
        -18.9697, -1942.111,
        -42.6222, -1942.111,
        -42.6222, -1905.4954,
        -24.5157, -1904.5599,
        18.0579, -1888.5903,
        18.0579, -1841.4649,
        47.5112, -1841.4649,
        47.5112, -1759.8208,
    },
    {
        -48.0305, -1842.4819,
        -81.9322, -1842.4819,
        -81.9322, -1941.8347,
        -48.0305, -1941.8347,
        -48.0305, -1842.4819,
    },
    {
        167.6901, -2095.3168,
        232.0507, -2095.3168,
        232.0507, -2170.5826,
        167.6901, -2170.5826,
        167.6901, -2095.3168,
    },
    {
        403.884, -2171.8393,
        403.884, -2105.686,
        594.7793, -2105.686,
        594.7793, -2171.8393,
        403.884, -2171.8393,
    },
    {
        423.8071, -2185.8255,
        423.8071, -2244.5226,
        240.0086, -2244.5226,
        245.6569, -2185.8343,
        423.8071, -2185.8255,
    },
    {
        119.1552, -2185.8597,
        119.1552, -2346.2532,
        68.4628, -2346.2532,
        8.6576, -2185.5332,
        119.1552, -2185.5332,
    },
    {
        253.0105, -2258.3234,
        347.2308, -2258.3234,
        347.2308, -2258.3234,
        347.2308, -2316.9996,
        253.0105, -2316.9996,
        253.0105, -2258.3234,
    },

    -- Горки
    {
        1943.7996, -306.6589,
        1911.7001, -341.7249,
        1950.5736, -377.2197,
        1982.6213, -342.0746,
        1943.7996, -306.6589,
    },
    {
        1815.2998, -447.46,
        1854.8243, -483.5833,
        1886.5776, -448.1977,
        1847.5729, -412.3653,
        1815.2998, -447.46,
    },
    {
        1918.7987, -489.0438,
        2001.0362, -521.7062,
        2051.9909, -423.6349,
        2043.4638, -403.5975,
        2029.5354, -394.3077,
        1982.9122, -439.199,
        1918.7987, -489.0438,
    },
    {
        1914.3985, -654.2054,
        1984.7983, -754.6954,
        2023.0733, -718.3655,
        1976.2972, -658.2513,
        1957.0241, -667.0748,
        1914.3985, -654.2054,
    },
    {
        2085.2777, -960.137,
        2177.3601, -924.594,
        2250.1625, -1070.3761,
        2161.6833, -1112.5109,
        2085.2777, -960.137,
    },
    {
        2296.5822, -863.5411,
        2348.9462, -977.5706,
        2337.4694, -808.8851,
        2316.4372, -731.7723,
        2230.2761, -716.1584,
        2296.5822, -863.5411,
    },
    {
        2348.8986, -979.4277,
        2256.4199, -1035.4482,
        2280.7888, -1086.0312,
        2316.8295, -1099.2728,
        2348.8986, -979.4277,
    },
    {
        2093.8452, -1382.3927,
        2048.9516, -1287.2247,
        2118.4775, -1255.3259,
        2163.3037, -1350.2993,
        2093.8452, -1382.3927,
    },
    {
        2045.2004, -1280.2321,
        2005.9822, -1196.4712,
        2076.0383, -1163.9561,
        2115.2607, -1248.1341,
        2045.2004, -1280.2321,
    },
    {
        1958.5496, -1209.6351,
        1922.7197, -1132.9404,
        2036.6217, -1079.7609,
        2072.8217, -1156.9753,
        1958.5496, -1209.6351,
    },
    {
        2000.9693, -1002.8457,
        1931.0529, -1035.685,
        1963.4161, -1105.4012,
        2033.739, -1073.0216,
        2000.9693, -1002.8457,
    },
    {
        1997.4935, -995.8185,
        1965.106, -926.0885,
        1895.2406, -958.6688,
        1927.7628, -1028.7421,
        1997.4935, -995.8185,
    },
    {
        1995.28, -890.6,
        1962.4, -912.8,
        1965.22, -917.57,
        1885.206, -955.2485,
        1920.7451, -1031.8851,
        1865.9085, -1056.4057,
        1815.6655, -925.7318,
        1944.138, -800.6845,
        1995.28, -890.6,
    },
    {
        2069.2258, -971.1447,
        2007.9101, -999.877,
        2122.2568, -1244.8087,
        2151.6484, -1231.2381,
        2131.9226, -1189.6138,
        2170.8144, -1173.0238,
        2069.2258, -971.1447,
    },
}

addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function( theVehicle, seat )    
    if not IsNormalVehicle( theVehicle ) then return end
	if not FORBIDDEN_PARKING_VEHICLES[ theVehicle ] then return end

	FORBIDDEN_PARKING_VEHICLES[ theVehicle ] = nil

	if isElement( icon ) then
        icon:destroy()
    end
end )

addEventHandler( "onClientPlayerVehicleExit", localPlayer, function( theVehicle, seat )
	if not IsNormalVehicle( theVehicle ) then return end
	if not IsInForbiddenParkingZone( theVehicle ) then return end

	FORBIDDEN_PARKING_VEHICLES[ theVehicle ] = getRealTimestamp()

    if not isElement( icon ) then
        icon = ibCreateImage( px, py, 44, 44, "files/img/not_parking.png" )
    end
end )

addEventHandler( "onClientElementColShapeHit", localPlayer, function( colshape )
    if not isPedInVehicle( source ) then return end

    if not IsNormalVehicle( source.vehicle ) then return end
    if not FORBIDDEN_ZONES[ colshape ] then return end
    
    if not isElement( icon ) then
        icon = ibCreateImage( px, py, 44, 44, "files/img/not_parking.png" )
    end 
end )

addEventHandler( "onClientElementColShapeLeave", localPlayer, function( colshape )
    if not isPedInVehicle( source ) then return end

    if not IsNormalVehicle( source.vehicle ) then return end
    if not FORBIDDEN_ZONES[ colshape ] then return end

    if isElement( icon ) then
        icon:destroy()
    end
end )

function OnClientResourceStart()
	for _, info in pairs( PARKING_ZONES ) do
		local polygon = createColPolygon( unpack( info ) )
		FORBIDDEN_ZONES[ polygon ] = true
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, OnClientResourceStart )

setTimer( function()
	if next( FORBIDDEN_PARKING_VEHICLES ) then
		for k, v in pairs( FORBIDDEN_PARKING_VEHICLES ) do
            if getRealTimestamp() - v > FORBIDDEN_TIME then
                FORBIDDEN_PARKING_VEHICLES[ k ] = getRealTimestamp() + 120
                triggerServerEvent( "onServerPlayerLeftVehicleInForbiddenZone", localPlayer )
				localPlayer:PhoneNotification( {
                    title = "Штраф",
                    msg_short = "Штраф 1000р";
                    msg = "Нарушение - парковка в неположенном месте. Статья 2.13. Штраф 1.000р.";
                } )
			end
		end
	end
end, 1000, 0 )

function IsInForbiddenParkingZone( element )
	for zone in pairs( FORBIDDEN_ZONES ) do
		if isElementWithinColShape( element, zone ) then
			return zone
		end
	end
	return false
end

function IsNormalVehicle( vehicle )
    if not vehicle or not isElement( vehicle ) then return end
    if localPlayer:getData("quest_vehicle") == vehicle then return end
    if getElementDimension( vehicle ) ~= 0 or getPedOccupiedVehicleSeat( localPlayer ) ~= 0 then return end
    local faction = vehicle:GetFaction()
	if faction ~= 0 then return end
	if vehicle:GetSpecialType() then return end

	return true
end

function onClientShowForbiddenParkingIcon_handler( state )
    if isElement( icon ) then
        icon:ibData( "alpha", state and 255 or 0 )
    end
end
addEvent( "onClientShowForbiddenParkingIcon", true )
addEventHandler( "onClientShowForbiddenParkingIcon", root, onClientShowForbiddenParkingIcon_handler )

--[[
--Рендер нужных вам зон и их координат
addEventHandler("onClientRender",root, function() 
	local normalize = {}
	local v = PARKING_ZONES[ 38 ]
	-- for i,v in pairs( PARKING_ZONES ) do 
		-- if v[1] == 2011.391 then outputDebugString(i) end
		for j, val in ipairs( v ) do 
			if j % 2 == 0 then
				normalize[ #normalize ].y = v[ j ]
			else
				normalize[ #normalize + 1 ] = { x = v[ j ], y = 0 }
			end
		end
	-- end
	for i, v in pairs( normalize ) do 
		local endPosition = i == #normalize and normalize[ 1 ] or normalize[ i + 1 ]

		dxDrawLine3D( v.x, v.y, getGroundPosition( v.x, v.y, 90 ) + 5,endPosition.x,endPosition.y,getGroundPosition( endPosition.x, endPosition.y, 90 ) + 5, 0xFF00FF00, 10 )
		
		drawPositionText( v )
		drawPositionText( endPosition )
	end
end)
function drawPositionText( pos )
	pos.z = getGroundPosition( pos.x, pos.y, 90 )
	local pX, pY, pZ = getElementPosition( localPlayer );	
	local distance = getDistanceBetweenPoints3D( pX, pY, pZ, pos.x, pos.y, pos.z )
	
	if ( distance <= 100 ) then
		local x, y = getScreenFromWorldPosition( pos.x, pos.y, pos.z);
		
		if (x and y) then
			dxDrawText( pos.x.." "..pos.y, x, y, _, _, 0xFFFFFFFF, 1, "default", "center", "center", false, false, false, false);
			return true;
		end
	end
end
]]