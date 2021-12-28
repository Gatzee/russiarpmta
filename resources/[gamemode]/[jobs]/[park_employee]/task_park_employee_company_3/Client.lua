loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")
Extend("CUI")

IGNORE_GPS_ROUTE = true

local old_value

CENTER_PARK_POINT = Vector3( 1864.9016, 1073.3876 + 860, 16.3221 )
CURRENT_AREA_ID = -1
AREAS = 
{
	Vector3( 1930.9310302734, 769.0495605469, 16.181449890137 ),
	Vector3( 1886.0803222656, 974.8635253906, 16.337211608887 ),
	Vector3( 2210.1335449219, 1560.1020507813, 16.167861938477 ),
	Vector3( 2280.2360839844, 1275.7346191406, 24.914318084717 ),
	Vector3( 2114.4614257813, 1434.4833984375, 24.904487609863 ),
	Vector3( 2286.1989746094, 1452.0644531252, 33.678771972656 ),
	Vector3( 1537.4643554688, 737.8774414063, 16.228712081909 ),
	Vector3( 1922.6368408203, 1151.0667724609, 16.161975860596 ),
	Vector3( 1943.6811523438, 1593.8710937512, 16.164413452148 ),
	Vector3( 2383.1069335938, 1445.0495605469, 16.164600372314 ),
	Vector3( 1774.0415039063, 887.9810791016, 16.320846557617 ),
	Vector3( 1981.4936523438, 859.4935302734, 16.172889709473 ),
	Vector3( 1994.0566406252, 1474.8674316406, 16.188207626343 ),
	Vector3( 2077.3681640625, 1606.5876464844, 16.586837768555 ),
	Vector3( 2195.5620117188, 1337.1188964844, 22.889461517334 ),
	Vector3( 1648.4310302734, 968.6396484375, 16.214462280273 ),
	Vector3( 1496.7214355469, 843.3115234375, 16.160850524902 ),
	Vector3( 1682.6961669922, 711.2092285156, 16.166847229004 ),
	Vector3( 2147.5749511719, 1178.1096191406, 16.162050247192 ),
	Vector3( 1908.1680908203, 1695.6313476563, 20.874462127686 ),
	Vector3( 1974.8629150391, 1268.8264160156, 16.158962249756 ),
	Vector3( 1663.9693603516, 1377.2387695313, 16.739686965942 ),
	Vector3( 1845.3375244141, 1305.8867187523, 16.160537719727 ),
	Vector3( 1734.6319580078, 1514.4018554688, 16.353212356567 ),
	Vector3( 1647.1466064453, 1621.0659179688, 21.039688110352 ),
	Vector3( 1714.7945556641, 1654.0437011719, 16.160387039185 ),
	Vector3( 1788.2387695313, 1716.0310058594, 18.197662353516 ),
	Vector3( 2003.1363525391, 1027.3212890625, 16.427402496338 ),
	Vector3( 2348.4096679688, 1194.4855957031, 16.158512115479 ),
	Vector3( 2439.6633300781, 1376.1164550781, 16.164600372314 ),
};

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuest( QUEST_DATA )
end )

function resetParkEmployeeSetting( )
	CURRENT_AREA_ID = -1
	if CURRENT_UI_ELEMENT then
		CURRENT_UI_ELEMENT:destroy( )
		CURRENT_UI_ELEMENT = nil
	end
	if isTimer( CHECK_POS_TIMER ) then
		killTimer( CHECK_POS_TIMER )
		CHECK_POS_TIMER = nil
	end
	localPlayer:setAnimation()
	removeEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle )
end
addEventHandler( "onClientResourceStop", resourceRoot, resetParkEmployeeSetting )

addEvent( "onParkEmployeeCompany_3_EndShiftRequestReset", true )
addEventHandler( "onParkEmployeeCompany_3_EndShiftRequestReset", root, resetParkEmployeeSetting )

function StartCheckPosition( target )
	CHECK_POS_TIMER = Timer( function( )
		if getDistanceBetweenPoints3D( target.x, target.y, target.z, getElementPosition(localPlayer) ) > 900 then
			triggerServerEvent( "onJobEndShiftRequest", resourceRoot )
		end
	end, 5000, 0 )
end

function GetFreeArea( prev_area )
	local zone_loads = {}
	for k, v in pairs( AREAS ) do
		local players_count = 0
		for _, player in pairs( Element.getWithinRange( v, 20, "player" ) ) do
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

	local iteration = 0
	local value = math.random( 1, temp[ math.random( 1, #temp ) ].id )

	while (value == old_value) do
		value = math.random( 1, temp[ math.random( 1, #temp ) ].id )

		-- не более пяти итераций
		-- а то в случае если все координаты принадлежат другим игрокам
		-- а только одна свободная - произойдет зацикливание до того момента
		-- пока один из игроков не закончит задание
		iteration = iteration + 1
		if iteration >= 5 then 
			return value
		end
	end

	return value
end

function onFailQuestEnterInVehicle( player )
	local vehicle_model = source:getModel()
	if player == localPlayer and vehicle_model ~= 572  then
		triggerServerEvent( "onJobEndShiftRequest", localPlayer )
	end
end