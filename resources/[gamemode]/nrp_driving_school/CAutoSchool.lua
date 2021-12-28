Extend( "CPlayer" )
Extend("CInterior")
Extend("CUI")
Extend("ib")

local exam_data = { }
local route = { }

enum "eExamSteps" {
	"EXAM_STEP_SEAT", -- Посадка в автомобиль
	"EXAM_STEP_ENGINE_ON", -- Включение двигателя
	"EXAM_STEP_LIGHTS_ON", -- Включение фар
	"EXAM_STEP_DRIVING", -- Вождение
}

AUTO_SCHOOL_EXAM_SEQUENCE =
{
	[ EXAM_STEP_SEAT ] =
	{
		OnStartClient = function()
			local function Continue( vehicle, seat )
				if vehicle == exam_data.vehicle and seat == 0 then
					vehicle.engineState = false
					NextExamAutoStep( )
					removeEventHandler( "onClientPlayerVehicleEnter", root, Continue )
				end
            end
            
			addEventHandler( "onClientPlayerVehicleEnter", root, Continue )
			addEventHandler( "onClientVehicleStartEnter", root, OnTrySeatVehicleAuto_handler )
			setElementData( localPlayer, "radial_disabled", true, false )

			if exam_data.license_type == LICENSE_TYPE_AUTO then
				ShowHint( true, "Сядьте в автомобиль с инструктором (клавиша F)" )
			elseif exam_data.license_type == LICENSE_TYPE_BUS then
				ShowHint( true, "Сядьте в автобус с инструктором (клавиша F)" )
			elseif exam_data.license_type == LICENSE_TYPE_MOTO then
				ShowHint( true, "Сядьте на мотоцикл (клавиша F)" )
			elseif exam_data.license_type == LICENSE_TYPE_TRUCK then
				ShowHint( true, "Сядьте в грузовик (клавиша F)" )
			end
		end,
	},
	[ EXAM_STEP_ENGINE_ON ] =
	{
		OnStartClient = function()
			local function Continue( )
				local vehicle = getPedOccupiedVehicle( localPlayer )
				if vehicle then
					if vehicle.engineState == true then
						NextExamAutoStep( )
						removeEventHandler( "onClientRender", root, Continue )
						setElementFrozen( vehicle, true )
					end
				end
			end

			setElementData( localPlayer, "radial_disabled", false, false )
			addEventHandler( "onClientRender", root, Continue )
			ShowHint( true, "Включите двигатель, используя радиальное меню (TAB)" )
		end
	},

	[ EXAM_STEP_LIGHTS_ON ] = 
	{
		OnStartClient = function()
			local function Continue( )
				local vehicle = getPedOccupiedVehicle( localPlayer )
				if vehicle then
					if vehicle.overrideLights == 2 then
						NextExamAutoStep( )
						removeEventHandler( "onClientRender", root, Continue )
						setElementFrozen( vehicle, false )
					end
				end
			end
			addEventHandler( "onClientRender", root, Continue )
			ShowHint( true, "Включите фары, используя радиальное меню (TAB)" )
		end
	},
	[ EXAM_STEP_DRIVING ] =
	{
		OnStartClient = function( )
			StartDrivingAutoStage()
			ShowHint( true, "Двигайтесь вдоль линии стараясь не повредить транспортное средство" )

			setTimer( ShowHint, 5000, 1, false )
		end,
	},
}

function OnStartExamAuto_handler( data )
    setElementInterior( localPlayer, 0 )

	exam_data = { }

	exam_data.license_type = data.category
	exam_data.vehicle = data.vehicle
	exam_data.step = 0
	exam_data.school = data.school

	NextExamAutoStep( )

	setElementData( localPlayer, "driving_exam", true, false )
end
addEvent( "OnStartExamAuto", true )
addEventHandler( "OnStartExamAuto", root, OnStartExamAuto_handler )

function NextExamAutoStep( )
	local current_step = exam_data.step or 0
	local next_step = current_step + 1

	if AUTO_SCHOOL_EXAM_SEQUENCE[ next_step ] then
		AUTO_SCHOOL_EXAM_SEQUENCE[ next_step ].OnStartClient( )
		exam_data.step = next_step
	else
		FinishExamAuto( )
	end
end

function FinishExamAuto( state )
	if not exam_data.license_type then return end

	triggerServerEvent( "OnPassedExamAuto", localPlayer, exam_data.license_type, "driving", state )
	exam_data = { }
	setElementData( localPlayer, "driving_exam", false, false )

	if state then ShowPopup( true, "driving_passed" ) end
end

function StartDrivingAutoStage( )
	exam_data.lost_route = 0
	exam_data.last_point = 0
	local school = getElementData( localPlayer, "iDrivingSchool" ) or 1
	route = table.copy( AUTO_SCHOOL_ROUTES[ school ].routes[ exam_data.license_type ] )

	for k, v in pairs( route ) do
		local col_size = 2
		if exam_data.license_type == LICENSE_TYPE_BUS or exam_data.license_type == LICENSE_TYPE_TRUCK then col_size = 4 end
		local col = createColSphere( v, col_size )
		local tab =
		{
			position = v,
			passed = false,
			col = col,
		}
		route[ k ] = tab
	end

	addEventHandler( "onClientColShapeHit", root, OnRouteAutoHit_handler )
	addEventHandler( "onClientRender", root, OnDrawRouteAuto_handler )
	addEventHandler( "onClientPlayerVehicleExit", root, OnLeftVehicleAuto_handler )
	addEventHandler( "onClientPlayerVehicleEnter", root, OnReturnedToVehicleAuto_handler )

	exam_data.check_timer = setTimer( CheckRouteAutoStatus, 1000, 0 )

	triggerServerEvent( "OnStartDrivingAutoStage", localPlayer )
end

function FinishDrivingAutoStage( state )
	removeEventHandler( "onClientColShapeHit", root, OnRouteAutoHit_handler )
	removeEventHandler( "onClientRender", root, OnDrawRouteAuto_handler )
	removeEventHandler( "onClientVehicleStartEnter", root, OnTrySeatVehicleAuto_handler )
	removeEventHandler( "onClientPlayerVehicleExit", root, OnLeftVehicleAuto_handler )
	removeEventHandler( "onClientPlayerVehicleEnter", root, OnReturnedToVehicleAuto_handler )

	if isTimer( exam_data.left_timer ) then killTimer( exam_data.left_timer ) end
	if isTimer( exam_data.check_timer ) then killTimer( exam_data.check_timer ) end

	route = { }
	FinishExamAuto( state )
end

function CheckRouteAutoStatus( )
	if isPedDead( localPlayer ) then
		localPlayer:ShowError( "Экзамен провален!" )
		FinishDrivingAutoStage( false )
		return
	end

	local vehicle = exam_data.vehicle
	if vehicle and isElement( vehicle ) then
		if vehicle.health <= 950 then
			localPlayer:ShowError( "Вы повредили автомобиль, экзамен провален!" )
			FinishDrivingAutoStage( false )
			return
		end

		if isElementInWater( vehicle ) then
			localPlayer:ShowError( "Вы утопили автомобиль, экзамен провален!" )
			FinishDrivingAutoStage( false )
			return
		end

		local next_point = route[ exam_data.last_point + 1 ]
		if next_point then
			local prev_point = route[ exam_data.last_point ]
			if not prev_point then return end

			local distance_between_points = getDistanceBetweenPoints2D( next_point.position.x, next_point.position.y, prev_point.position.x, prev_point.position.y )
			local vx, vy, _ = getElementPosition( vehicle )
			local distance_from_player = getDistanceBetweenPoints2D( vx, vy, next_point.position.x, next_point.position.y )

			if distance_from_player > distance_between_points + 5 then
				localPlayer:ShowError( "Вы отклонились от маршрута!" )
				exam_data.lost_route = exam_data.lost_route + 1
				if exam_data.lost_route >= 60 then
					localPlayer:ShowError( "Вы отклонились от маршрута, экзамен провален!" )
					FinishDrivingAutoStage( false )
				end
			else
				exam_data.lost_route = 0
			end
		end
	end
end

function OnRouteAutoHit_handler( element )
	if element == exam_data.vehicle then
		local last_point = exam_data.last_point
		if route[ last_point + 1 ] then
			if route[ last_point + 1 ].col == source then
				route[ last_point + 1 ].passed = true
				exam_data.last_point = exam_data.last_point + 1
			end

			-- It was the last point
			if not route[ last_point + 2 ] then
				FinishDrivingAutoStage( true )
			end
		end
	end
end

function OnDrawRouteAuto_handler()
	local count = 0
	for key, point in pairs( route ) do
		local vec_next_point = route[ key + 1 ]
		if vec_next_point then
			if count <= 30 and not vec_next_point.passed and not point.passed then
				if vec_next_point then
					dxDrawLine3D( point.position.x, point.position.y, point.position.z, vec_next_point.position.x, vec_next_point.position.y, vec_next_point.position.z, tocolor( 50, 200, 50, 150 ), 12 )
					count = count + 1
				end
			end
		end
	end

	local vehicle = getPedOccupiedVehicle( localPlayer )
	if vehicle then
		setVehicleOverrideLights( vehicle, 2 )
		setVehicleLightState( vehicle, 0, 0 )
		setVehicleLightState( vehicle, 1, 0 )
	end
end

function OnTrySeatVehicleAuto_handler( player, seat, door )
	if player == localPlayer then
		if seat ~= 0 or door ~= 0 then
			cancelEvent( )
			return
		end
	end
end

function OnLeftVehicleAuto_handler( vehicle )
	if source == localPlayer then
		exam_data.left_timer = setTimer( function( )
			FinishDrivingAutoStage( false )
			localPlayer:ShowError( "Вы покинули транспортное средство и провалили экзамен" )
		end, 60000, 1 )
		localPlayer:ShowError( "Вернитесь в транспортное средство, или экзамен будет провален!" )
	end
end

function OnReturnedToVehicleAuto_handler( vehicle )
	if source == localPlayer then
		if isTimer( exam_data.left_timer ) then killTimer( exam_data.left_timer ) end
	end
end