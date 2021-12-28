loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CInterior" )
Extend( "ib" )
Extend( "CQuestCoop" )
Extend( "CActionTasksUtils" )

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuestCoop( QUEST_DATA )
end )

function AddExitWarningHandler( target_vehicle, time, warning_text, fail_text )
	GEs._vehicle_exit_handler = target_vehicle
	
	GEs._func_vehicle_enter_handler = function( player )
		if player ~= localPlayer then return end
		StopFailTimer()
	end
	addEventHandler( "onClientVehicleEnter", GEs._vehicle_exit_handler , GEs._func_vehicle_enter_handler )

	GEs._func_vehicle_exit_handler = function( player )
		if player ~= localPlayer then return end

		StopFailTimer()
		StartFailTimer( time, warning_text, fail_text )
	end
	addEventHandler( "onClientVehicleExit", GEs._vehicle_exit_handler, GEs._func_vehicle_exit_handler )
end

function RemoveExitWarningHandler()
	if isElement( GEs._vehicle_exit_handler ) then
		removeEventHandler( "onClientVehicleEnter", GEs._vehicle_exit_handler, GEs._func_vehicle_enter_handler )
		removeEventHandler( "onClientVehicleExit", GEs._vehicle_exit_handler, GEs._func_vehicle_exit_handler )
	end
	StopFailTimer()
end

function onClientKeyHint_handler( key, state )
	if not state then return end
	if key == "2" or key == "3" then
		if CEs.hint then CEs.hint:destroy() end
		removeEventHandler( "onClientKey", root, onClientKeyHint_handler )
	end
end

function ShowStationHint()
	if not localPlayer:GetFactionVoiceChannel() then
		CEs.hint = CreateSutiationalHint( {
			text = "Нажмите key=2 или key=3, чтобы активировать рабочую рацию!",
			condition = function( )
				return true
			end
		} )
		CEs.hint.area:ibData( "priority", 9999999999999999 )
		removeEventHandler( "onClientKey", root, onClientKeyHint_handler )
		addEventHandler( "onClientKey", root, onClientKeyHint_handler )
	end
end