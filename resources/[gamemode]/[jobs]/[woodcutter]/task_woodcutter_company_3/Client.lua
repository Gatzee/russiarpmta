loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")
Extend("CUI")

IGNORE_GPS_ROUTE = true

CENTER_WOOD_POINT = Vector3( 1866.3865, 333.7227 + 860, 16.5139 )

SAWMILL_PLAYER_DIMENSION = nil

STOCK_ID = nil
STOCK =
{
	{ 
		name = "stock_2_bunch_1", 
		position = Vector3( 1896.0781, 204.7639 + 860, 15.9221 ),
		take_position =  
		{
			Vector3( 1902.6124, 211.0635 + 860, 16.5139 ),
			Vector3( 1899.7131, 212.111 + 860, 16.5139 ),
			Vector3( 1896.6618, 213.6472 + 860, 16.5139 ),
		},
	},
	{
		name = "stock_2_bunch_1", 
		position = Vector3( 1736.4838, 268.1252 + 860, 15.9221 ),
		take_position =  
		{
			Vector3( 1740.9501, 276.1472 + 860, 16.5139 ),
			Vector3( 1737.2283, 276.7274 + 860, 16.5139 ),
			Vector3( 1734.7884, 277.43 + 860, 16.5139 ),
		},
	},
	{
		name = "stock_2_bunch_1",
		position = Vector3( 1890.9644, 456.3127 + 860, 15.9221 ),
		take_position =  
		{
			Vector3( 1891.0637, 447.4951 + 860, 16.5139 ),
			Vector3( 1894.0781, 449.0631 + 860, 16.5139 ),
			Vector3( 1897.5255, 450.4594 + 860, 16.5139 ),
		},
	},
}

SAWMILL_ID = nil
SAWMILL = 
{
	{ 
		position = Vector3( 1794.9725, 236.6464 + 860, 16.5139 ),
		process_position = Vector3( 1792.6795, 238.5364 + 860, 16.5139 ),
		stock_sawmill = Vector3( 1793.4959, 230.5417 + 860, 17.0143 ),
		stock_result = Vector3( 1918.4749, 292.1164 + 860, 16.5139 ),
	},
	{ 
		position = Vector3( 1984.1750, 451.348 + 860, 16.5139 ),
		process_position = Vector3( 1989.5798, 448.4903 + 860, 16.5139 ),
		stock_sawmill = Vector3( 1992.8850, 447.7646 + 860, 17.0435 ),
		stock_result = Vector3( 1932.0267, 291.6372 + 860, 16.5139 ),
	},
}

STOCKS =
{
    --забирает
	[ "stock_2_bunch_1" ] = 0,
}

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
	if player == localPlayer and vehicle_model ~= 400  then
		triggerServerEvent( "onJobEndShiftRequest", localPlayer )
	end
end

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuest( QUEST_DATA )
end )

--Если ресурс будет перезапущен во время заливки масла сбрасываем данные
function resetWoodcutterSetting()
	STOCK_ID = nil
	SAWMILL_ID = nil
	SAWMILL_PLAYER_DIMENSION = nil

	GAME_STEP = nil
	CURRENT_GAME = nil
	if CURRENT_UI_ELEMENT then
		CURRENT_UI_ELEMENT:destroy()
		CURRENT_UI_ELEMENT = nil
	end
	if CURRENT_UI_DESK then
		CURRENT_UI_DESK:destroy()
		CURRENT_UI_DESK = nil
	end

	showCursor( false )
	setCursorAlpha( 255 )
	
	if isTimer( CHECK_POS_TIMER ) then
		killTimer( CHECK_POS_TIMER )
		CHECK_POS_TIMER = nil
	end
	removeEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle )
	
	local vehicle = localPlayer:getData( "job_vehicle" )
	if isElement( vehicle ) then
		vehicle:setDimension( 0 )
	end
	localPlayer:setDimension( 0 )
	
	SetCarryingState( false )
end
addEventHandler( "onClientResourceStop", resourceRoot, resetWoodcutterSetting )

addEvent("onWoodcutterCompany_3_EndShiftRequestReset", true)
addEventHandler( "onWoodcutterCompany_3_EndShiftRequestReset", root, resetWoodcutterSetting )

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

local carrying_controls = { "jump", "sprint", "crouch", }
function SetCarryingState( value )
	for k, v in pairs( carrying_controls ) do
		toggleControl( v, not value )
	end
end