loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")
Extend("CUI")

IGNORE_GPS_ROUTE = true

CHECK_POS_TIMER = nil

CENTER_PARK_POINT = Vector3( 1864.9016, 1073.3876, 16.3221 )
CUR_AREA_ID = -1 
AREAS = 
{
	{ start = Vector3( 2272.6687, 1191.5803, 16.1585 ), center = Vector3( 2274.5288, 1211.4448, 16.3296 ), area_size = 22 },
	{ start = Vector3( 2141.6198, 1540.9343, 16.3341 ), center = Vector3( 2155.1384, 1545.0471, 16.3341 ), area_size = 20 },
	{ start = Vector3( 2179.1276, 1559.7734, 16.3341 ), center = Vector3( 2177.0678, 1545.0827, 16.3341 ), area_size = 20 },
	{ start = Vector3( 2276.7128, 1521.4577, 16.328 ), center = Vector3( 2259.9921, 1518.7177, 16.328 ), area_size = 19 },
	{ start = Vector3( 2260.9733, 1549.2608, 16.328 ), center = Vector3( 2261.8815, 1536.4689, 16.3307 ), area_size = 19 },
	{ start = Vector3( 1794.2254, 788.9122, 16.1609 ), center = Vector3( 1780.2805, 799.411, 16.1609 ), area_size = 22 },
	{ start = Vector3( 1794.1368, 784.9645, 16.1609 ), center = Vector3( 1781.2799, 769.2, 16.1609 ), area_size = 22 },
	{ start = Vector3( 1801.7468, 762.7957, 16.82 ), center = Vector3( 1794.2828, 745.0434, 16.82 ), area_size = 22 },
	{ start = Vector3( 1777.8052, 757.6372, 16.3874 ), center = Vector3( 1768.8482, 742.3806, 16.3874 ), area_size = 22 },
	{ start = Vector3( 1759.6121, 786.5856, 16.3861 ), center = Vector3( 1754.477, 771.7413, 16.3861 ), area_size = 22 },
	{ start = Vector3( 1915.1135, 976.9547, 16.4197 ), center = Vector3( 1929.7761, 982.0772, 16.4197 ), area_size = 22 },
	{ start = Vector3( 1904.1777, 1010.9718, 16.4197 ), center = Vector3( 1905.7224, 1025.9033, 16.4197 ), area_size = 20 },
	{ start = Vector3( 1945.2584, 1023.3854, 16.4197 ), center = Vector3( 1948.9063, 1036.8779, 16.4197 ), area_size = 21 },
	{ start = Vector3( 1958.6396, 993.1385, 16.4197 ), center = Vector3( 1969.4724, 1006.7481, 16.4197 ), area_size = 21 },
	{ start = Vector3( 1970.9581, 1022.0214, 16.4274 ), center = Vector3( 1979.2197, 1035.3198, 16.4274 ), area_size = 21 },
	{ start = Vector3( 1993.3706, 1053.1027, 16.4156 ), center = Vector3( 1983.5622, 1068.2098, 16.4186 ), area_size = 21 },
	{ start = Vector3( 2032.8614, 1060.004, 16.4156 ), center = Vector3( 2017.4708, 1066.4572, 16.3808 ), area_size = 21 },
}

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)

function resetParkEmployeeSetting()
	CUR_AREA_ID = -1
	if isElement( SOUND_WATER ) then
		SOUND_WATER:stop()
		SOUND_WATER = nil
	end
	if CURRENT_GAME then
		CURRENT_GAME:destroy()
		CURRENT_GAME = nil
	end
	if isTimer( CHECK_POS_TIMER ) then
		killTimer( CHECK_POS_TIMER )
		CHECK_POS_TIMER = nil
	end
	removeEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle )
end
addEventHandler( "onClientResourceStop", resourceRoot, resetParkEmployeeSetting )

addEvent("onParkEmployeeCompany_2_EndShiftRequestReset", true)
addEventHandler( "onParkEmployeeCompany_2_EndShiftRequestReset", root, resetParkEmployeeSetting )

function GetFreeArea( prev_area )
	local zone_loads = {}
	for k, v in pairs( AREAS ) do
		local players_count = 0
		for _, player in pairs( Element.getWithinRange( v.center, 20, "player" ) ) do
			if getElementData( player, "onshift" ) then
				players_count = players_count + 1
			end
		end
		table.insert( zone_loads, { id = k, players_count = players_count } )
	end
	table.sort( zone_loads, function( a, b )
		return a.players_count < b.players_count
	end )

	local temp = {}
	for k, v in pairs( zone_loads ) do
		if v.players_count == zone_loads[ 1 ].players_count and v.id ~= prev_area then
			table.insert( temp, v )
		end
	end
	return temp[ math.random( 1, #temp ) ].id
end

--Запуск таймера, проверяющего позицию игрока относительно работы
function StartCheckPosition( target )
	CHECK_POS_TIMER = Timer( function( )
		if getDistanceBetweenPoints3D( target.x, target.y, target.z, getElementPosition( localPlayer ) ) > 850 then
			triggerServerEvent( "onJobEndShiftRequest", resourceRoot )
		end
	end, 5000, 0 )
end

function onFailQuestEnterInVehicle( player )
	local vehicle_model = source:getModel()
	if player == localPlayer and vehicle_model ~= 572  then
		triggerServerEvent( "onJobEndShiftRequest", localPlayer )
	end
end