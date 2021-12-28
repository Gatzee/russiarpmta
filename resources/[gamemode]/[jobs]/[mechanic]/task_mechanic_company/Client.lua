loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")
Extend("CUI")

IGNORE_GPS_ROUTE = true

VEHICLES = { 

	{ model = 562, forward = true, z = 15.963 }, 
	{ model = 602, forward = true, z = 15.815 },
	{ model = 439, forward = true, z = 15.998 },
	{ model = 536, forward = true, z = 15.683 },
	{ model = 410, forward = true, z = 15.248 },
	{ model = 576, forward = true, z = 15.956 },
	{ model = 518, forward = true, z = 15.708 },
	{ model = 589 ,forward = true, z = 15.803 },
	
	{ model = 496, z = 15.834 },
	{ model = 411, z = 15.658 },
	{ model = 415, z = 15.830 },
	{ model = 451, z = 15.838 },
	{ model = 541, z = 15.792 },
	{ model = 535, z = 15.949 },
	{ model = 527, z = 15.760 },
}

CONST_WAIT_TIME = 30000
NEED_TIMER= false

CUREENT_GARAGE_ID = nil
CUREENT_VEHICLE_ID = nil
GARAGE_DATA =
{
	{
		vehice_data =
		{
			{ position = Vector3( 1488.4332, 869.6381 + 860, 15.59 ), rotation = 30, },
		},
		wheel_marker = Vector3( 1494.2492, 857.4659 + 860, 16 ),
		oil_marker = Vector3( 1498.0822, 858.2114 + 860, 16 ),
	},
	
	{
		vehice_data =
		{
			{ position = Vector3( 1501.3558, 878.7419 + 860, 15.59 ), rotation = 30, },
		},
		wheel_marker = Vector3( 1511.4652, 867.8284 + 860, 16 ),
		oil_marker = Vector3( 1511.3317, 864.0321 + 860, 16 ),
	},
	
	{
		vehice_data =
		{
			{ position = Vector3( 1507.0114, 882.2716 + 860, 15.59 ), rotation = 30, },
		},
		wheel_marker = Vector3( 1511.4652, 867.8284 + 860, 16 ),
		oil_marker = Vector3( 1517.2827, 869.6164 + 860, 16 ),
	},
	
	{
		vehice_data =
		{
			{ position = Vector3( 1520.3479, 890.8092 + 860, 15.59 ), rotation = 30, },
		},
		wheel_marker = Vector3( 1530.734, 880.2022 + 860, 16 ),
		oil_marker = Vector3( 1530.175, 875.9722 + 860, 16 ),
	},
	
	{
		vehice_data =
		{
			{ position = Vector3( 1525.8702, 894.5216 + 860, 15.59 ), rotation = 30, },
		},
		wheel_marker = Vector3( 1530.734, 880.2022 + 860, 16 ),
		oil_marker = Vector3( 1535.9711, 881.6323 + 860, 16 ),
	},
	
	{
		vehice_data =
		{
			{ position = Vector3( 1538.6953, 903.0469 + 860, 15.59 ), rotation = 30, },
		},
		wheel_marker = Vector3( 1545.0028, 889.3875 + 860, 16 ),
		oil_marker = Vector3( 1548.982, 889.9511 + 860, 16 ),
	},
	
	{
		vehice_data =
		{
			{ position = Vector3( 1586.7039, 951.5161 + 860, 15.59 ), rotation = 120, },
		},
		wheel_marker = Vector3( 1595.6582, 961.2053 + 860, 16 ),
		oil_marker = Vector3( 1599.7326, 960.9318 + 860, 16 ),
	},
	
	{
		vehice_data =
		{
			{ position = Vector3( 1583.6054, 957.746 + 860, 15.59 ), rotation = 120, },
		},
		wheel_marker = Vector3( 1595.6582, 961.2053 + 860, 16 ),
		oil_marker = Vector3( 1594.574, 966.6479 + 860, 16 ),
	},
}

	--Детали по кругу в машине с двигателем спереди[1] и сзади[2]
VERIFIABLE_VEHICLE_DETAILS = { 
	[1] = { "bonnet_dummy", "wheel_rf_dummy", "wheel_rb_dummy", "wheel_lb_dummy", "wheel_lf_dummy", },
	[2] = { "bonnet_dummy", "wheel_lb_dummy", "wheel_lf_dummy", "wheel_rf_dummy", "wheel_rb_dummy", }
}

REPAIR_VEHICLE = {}

CURRENT_WHEEL_ID = nil
WHEEL_MODELS = { 1079, 1085,1074,1076,1084,1097,1075,1096,1083,1098,1078,1082,1077, }

START_TASK_TIMER = nil

--Получение позиции сзади и спереди элемента
function GetForwardBackwardElementPosition( self, direction, distance )
	if direction == 1 then distance = distance * -1 end
	local x, y, z  = getElementPosition( self )
	local _, _, rz = getElementRotation( self )
	
    x = x - math.sin( math.rad(rz) ) * distance
	y = y + math.cos( math.rad(rz) ) * distance
	
    return x, y, z
end

--Получение позиции снаружи машины
function getPositionFromMatrixOffset( element, offX, offY, offZ )
	return element:getMatrix():transformPosition( offX, offY, offZ )
end

--Поворот элемента к цели
function setRotationToTarget( self, target )
	local x, y = getElementPosition( self ) 
	setElementRotation( localPlayer, 0,  0, FindRotation( x, y, target.x, target.y ) )
end

--Получени уникальных, не повторяющихся значений
function getUniqueQueue( f_max, f_count )
    local l_check = {}
    for i = 1, f_max do
        l_check[ i ] = i
    end
	local l_result = {}
    while( #l_check ~= 0 and #l_result < f_count ) do
        local l_id = math.random( 1,#l_check )
        table.insert( l_result, l_check[ l_id ] )
        table.remove( l_check,  l_id )
    end
    return l_result
end

--Запуск таймера, проверяющего позицию игрока относительно работы
function StartCheckPosition( target )
	CHECK_POS_TIMER = Timer( function( )
		if getDistanceBetweenPoints3D( target.x, target.y, target.z, getElementPosition( localPlayer ) ) > 150 then
			triggerServerEvent( "onJobEndShiftRequest", resourceRoot )
		end
	end, 5000, 0 )
end

PROXY_VEHICLES = {}
function createVehicles()
	for garage_key, v in pairs( GARAGE_DATA ) do
		for vehicle_key, vehicle_data in pairs( v.vehice_data ) do

			local vehicle_id = math.random( 1, #VEHICLES )
			local vehicle = Vehicle( 
				VEHICLES[ vehicle_id ].model, 
				vehicle_data.position.x, vehicle_data.position.y, VEHICLES[ vehicle_id ].z, 
				0, 0, VEHICLES[ vehicle_id ].forward and vehicle_data.rotation or vehicle_data.rotation + 180, 
				"", 1, 1 )
			setTimer( function( vehicle, pos )
				vehicle:setFrozen( true )
				vehicle:setPosition( unpack( pos ) )
			end, 3000, 1, vehicle, { vehicle_data.position.x, vehicle_data.position.y, VEHICLES[ vehicle_id ].z } )
			
			PROXY_VEHICLES[ garage_key .. vehicle_key ] = vehicle
			triggerEvent( "onVehicleRequestTuningRefresh", vehicle )
		end
		if garage_key == #GARAGE_DATA then
			for k, v in pairs( PROXY_VEHICLES ) do
				v:setVelocity( 0, 0, 0.1 )
			end
		end
	end
end

local marker = nil
addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
	--Маркер для правильного спавна авто с точки зрения высоты
	marker = Marker( 1531.5245, 920.4949 + 860, 16.1644, "cylinder", 4, 0, 0, 0, 0 )
	addEventHandler( "onClientElementStreamIn", marker, function()
		marker:destroy()
		createVehicles()
	end )
end)

--Если ресурс будет перезапущен во время смены
function resetMechanicSetting()
	StopMechanicCarrying()
	localPlayer:setAnimation()
	setCursorAlpha( 255 )
	if isTimer( CHECK_POS_TIMER ) then
		killTimer( CHECK_POS_TIMER )
	end
	if isTimer( START_TASK_TIMER ) then
		killTimer( START_TASK_TIMER )
	end
	if REPAIR_VEHICLE.vehicle then
		REPAIR_VEHICLE.vehicle:setComponentRotation( "bonnet_dummy", 0, 0, 0 )
		REPAIR_VEHICLE.vehicle:setComponentRotation( "rpb_bonnet_dummy", 0, 0, 0 )
		for _, v in pairs( VERIFIABLE_VEHICLE_DETAILS[ 1 ] ) do
			REPAIR_VEHICLE.vehicle:setComponentVisible( v, true )
		end
		REPAIR_VEHICLE.vehicle = nil
		REPAIR_VEHICLE.details = nil
	end
	GAME_STEP = nil
	CURRENT_GAME = nil
	if CURRENT_UI_ELEMENT then
		CURRENT_UI_ELEMENT:destroy()
	end
	CURRENT_UI_ELEMENT = nil
	NEED_TIMER= false
end
addEventHandler( "onClientResourceStop", resourceRoot, resetMechanicSetting )

addEvent("onJobMechanicEndShiftRequestReset", true)
addEventHandler( "onJobMechanicEndShiftRequestReset", root, resetMechanicSetting )




_CARRYING = nil
function StartMechanicCarrying( conf )
	if _CARRYING then return end

	toggleControl( "jump", false )
	toggleControl( "sprint", false )
	toggleControl( "crouch", false )
	toggleControl( "enter_exit", false )
	toggleControl( "next_weapon", false )
	toggleControl( "previous_weapon", false )
	toggleControl( "aim_weapon", false )
	toggleControl( "fire", false )

	setPedWeaponSlot( localPlayer, 0 )

	local object = Object( conf.model or 3052, localPlayer.position )
	object:setScale( conf.scale or 1 )
	exports.bone_attach:attachElementToBone( object, localPlayer, conf.bone or 8, conf.offset_x or 0.1, conf.offset_y or 0.3, conf.offset_z or 0.3, conf.rx or 25, conf.ry or 180, conf.rz or 25 )
	object.dimension = localPlayer.dimension


	_CARRYING = { object = object }

	return object
end

function StopMechanicCarrying( conf )
	if not _CARRYING then return end

	if isTimer( _CARRYING.timer ) then killTimer( _CARRYING.timer ) end
	if isElement( _CARRYING.object ) then destroyElement( _CARRYING.object ) end

	_CARRYING = nil

	toggleControl( "jump", true )
	toggleControl( "sprint", true )
	toggleControl( "crouch", true )
	toggleControl( "enter_exit", true )
	toggleControl( "next_weapon", true )
	toggleControl( "previous_weapon", true )
	toggleControl( "aim_weapon", true )
	toggleControl( "fire", true )
end