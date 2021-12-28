loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")
Extend("CUI")

IGNORE_GPS_ROUTE = true

CENTER_WOOD_POINT = Vector3( 1866.3865, 333.7227 + 860, 16.3713 )
WOOD_PROCESS = nil
CURRENT_BUNCH_ID = nil
BUNCH_TREES = 
{
	{
		name = "stock_1_bunch_1", 
		position = Vector3( 1743.5664, 100.0573 + 860, 14.6375 ),
		places =
		{
			Vector3( 1749.4061, 88.6401 + 860, 13.6342 ),
			Vector3( 1749.4061, 88.6401 + 860, 13.6342 ),
			Vector3( 1736.52, 85.2954 + 860, 13.1992 ),
			Vector3( 1727.0145, 94.5973 + 860, 13.5961 ),
			Vector3( 1719.5971, 101.4762 + 860, 13.8774 ),
			Vector3( 1726.6206, 112.0133 + 860, 14.8892 ),
			Vector3( 1741.9426, 113.6284 + 860, 15.4536 ),
			Vector3( 1738.4063, 123.8734 + 860, 15.9366 ),
			Vector3( 1762.1289, 102.9462 + 860, 15.3468 ),
			Vector3( 1764.4033, 84.4435 + 860, 13.8706 ),
		},
	},

	{
		name = "stock_1_bunch_1", 
		position = Vector3( 2012.0762, 324.2255 + 860, 15.9221 ),
		places =
		{
			Vector3( 2028.0042, 321.3172 + 860, 16.3889 ),
			Vector3( 2029.2133, 335.5551 + 860, 16.3889 ),
			Vector3( 2036.8216, 340.9422 + 860, 16.8343 ),
			Vector3( 2023.5267, 321.2708 + 860, 16.3889 ),
			Vector3( 2024.5053, 309.191 + 860, 16.638 ),
			Vector3( 2015.8726, 302.3913 + 860, 16.8514 ),
			Vector3( 2006.0111, 309.82 + 860, 16.9592 ),
			Vector3( 2001.3458, 323.3999 + 860, 17.8542 ),
			Vector3( 2000.775, 334.9709 + 860, 18.4237 ),
			Vector3( 2004.8297, 344.4835 + 860, 18.862 ),
		},
	},

	{
		name = "stock_1_bunch_1",
		position = Vector3( 1772.9842, 548.7584 + 860, 15.5850 ),
		places =
		{
			Vector3( 1789.6712, 552.5985 + 860, 17.354 ),
			Vector3( 1788.8122, 540.7562 + 860, 17.332 ),
			Vector3( 1779.2497, 536.1091 + 860, 16.2178 ),
			Vector3( 1769.3662, 527.0639 + 860, 15.8614 ),
			Vector3( 1757.064, 534.014 + 860, 15.8614 ),
			Vector3( 1751.5917, 543.8809 + 860, 15.8614 ),
			Vector3( 1757.1822, 551.005 + 860, 16.0479 ),
			Vector3( 1762.0557, 562.5894 + 860, 16.6986 ),
			Vector3( 1774.8151, 568.0369 + 860, 17.2008 ),
			Vector3( 1791.8509, 563.3439 + 860, 17.1184 ),
		},
	},

	{
		name = "stock_1_bunch_1", 
		position = Vector3( 1671.9334, 425.7666 + 860, 19.0243 ), 
		places =
		{
			Vector3( 1684.4786, 427.8706 + 860, 20.2073 ),
			Vector3( 1686.2791, 436.5791 + 860, 19.3342 ),
			Vector3( 1691.9385, 416.7017 + 860, 19.9637 ),
			Vector3( 1685.9346, 407.1132 + 860, 19.7624 ),
			Vector3( 1672.3391, 405.9141 + 860, 19.0425 ),
			Vector3( 1665.2893, 418.1074 + 860, 19.2831 ),
			Vector3( 1659.5721, 403.8704 + 860, 18.3983 ),
			Vector3( 1676.0224, 392.7728 + 860, 18.3421 ),
			Vector3( 1694.9251, 400.1236 + 860, 19.4974 ),
			Vector3( 1707.8625, 407.3685 + 860, 18.8663 ),
		},
	},
}

CURRENT_STOCK_BUNCH_ID = nil
STOCK_BUNCH = 
{
	{
		name = "stock_2_bunch_1", 
		position = Vector3( 1896.0781, 204.7639 + 860, 15.9221 ),
	},
	{
		name = "stock_2_bunch_1", 
		position = Vector3( 1736.4838, 268.1252 + 860, 15.9221 ),
	},
	{
		name = "stock_2_bunch_1", 
		position = Vector3( 1890.9644, 456.3127 + 860, 15.9221 ),
	},
}

STOCKS =
{
    --забирает
	[ "stock_1_bunch_1" ] = 0,
    
    --кладёт
	[ "stock_2_bunch_1" ] = 0,
}

local CONTROLS = { "next_weapon ", "previous_weapon", "fire", "aim_weapon" }
function SetControlState( state )
	for k, v in pairs( CONTROLS ) do
		toggleControl( v, state )
	end
end

--Запуск таймера, проверяющего позицию игрока относительно работы
function StartCheckPosition( target )
	CHECK_POS_TIMER = Timer( function( )
		if getDistanceBetweenPoints3D( target.x, target.y, target.z, getElementPosition( localPlayer ) ) > 350 then
			triggerServerEvent( "onJobEndShiftRequest", resourceRoot )
			resetWoodcutterSetting( )
		end
	end, 5000, 0 )
end

function onFailQuestEnterInVehicle( player )
	local vehicle_model = source:getModel()
	if player == localPlayer and vehicle_model ~= 456  then
		triggerServerEvent( "onJobEndShiftRequest", localPlayer )
	end
end


addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuest( QUEST_DATA )
end )

--Если ресурс будет перезапущен во время заливки масла сбрасываем данные
function resetWoodcutterSetting()
	CURRENT_BUNCH_ID = nil
	CURRENT_STOCK_BUNCH_ID = nil
	localPlayer:setFrozen( false )
	localPlayer:setAnimation()
	GAME_STEP = nil
	CURRENT_GAME = nil
	if CURRENT_UI_ELEMENT then
		CURRENT_UI_ELEMENT:destroy()
		CURRENT_UI_ELEMENT = nil
	end
	if isElement( WOOD_PROCESS ) then
		WOOD_PROCESS:destroy()
		WOOD_PROCESS = nil
	end
	if isTimer( CHECK_POS_TIMER ) then
		killTimer( CHECK_POS_TIMER )
		CHECK_POS_TIMER = nil
	end
	removeEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle )
	SetControlState( true )
	showCursor( false )
	SetCarryingState( false )
end
addEventHandler( "onClientResourceStop", resourceRoot, resetWoodcutterSetting )

addEvent("onWoodcutterCompany_2_EndShiftRequestReset", true)
addEventHandler( "onWoodcutterCompany_2_EndShiftRequestReset", root, resetWoodcutterSetting )

function onWoodcutterRefreshStockValue_handler( stock, value )
	if type( stock ) == "table" then
		for k, v in pairs( stock ) do
			if STOCKS[ k ] then
				STOCKS[ k ] = v
			end
		end
	else
		if STOCKS[ stock ] then
			STOCKS[ stock ] = value
		end
	end

	if CURRENT_UI_ELEMENT and CURRENT_UI_ELEMENT.RefreshStock then
		CURRENT_UI_ELEMENT:RefreshStock()
	end
end
addEvent( "onWoodcutterRefreshStockValue", true )
addEventHandler( "onWoodcutterRefreshStockValue", root, onWoodcutterRefreshStockValue_handler )

function getPointInFrontOfPoint( position, rz, dist ) 
	
	local offsetRot = math.rad( rz ) 
	
	local vx = position.x + dist * math.cos( offsetRot ) 
	local vy = position.y + dist * math.sin( offsetRot ) 
	
	return Vector3( vx, vy, position.z ) 

end

local carrying_controls = { "jump", "sprint", "crouch", "enter_exit", }
function SetCarryingState( value )
	for k, v in pairs( carrying_controls ) do
		toggleControl( v, not value )
	end
end