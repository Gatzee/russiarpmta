loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CInterior" )
Extend( "ib" )
Extend( "CQuestCoop" )

local CHECK_DISTANCE_TMR = nil
local FAIL_TEXT_AREA = nil

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuestCoop( QUEST_DATA )

	engineReplaceCOL  ( engineLoadCOL( "files/musur_3.col" ), 712 )
	engineImportTXD   ( engineLoadTXD( "files/musur_3.txd" ), 712 )
	engineReplaceModel( engineLoadDFF( "files/musur_3.dff" ), 712 )
end )

function CheckPlayerQuestVehicle( not_show_errors )
	if localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		if not not_show_errors then
			localPlayer:ShowError( "Ты не в служебной машине" )
		end
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		if not not_show_errors then
			localPlayer:ShowError( "Ты не водитель служебной машины" )
		end
		return false
	end

	return true
end

function CreateMarkerToJobVehicle( lobby_data, is_driver )
	if isPedInVehicle( localPlayer ) then
		triggerServerEvent( lobby_data.end_step, resourceRoot )
		return
	end

	local job_vehicle = localPlayer:getData( "job_vehicle" )

	CreateQuestPoint( job_vehicle.position + job_vehicle.matrix.forward * 3.5, function( )
		localPlayer:ShowInfo( "Нажмите " .. ( is_driver and "F" or "G" ) .. " чтобы сесть в машину" )
	end, _, 4 )

	local function onClientVehicleEnter_handler( player )
		if player == localPlayer then
			removeEventHandler( "onClientVehicleEnter", job_vehicle, onClientVehicleEnter_handler )
			triggerServerEvent( lobby_data.end_step, resourceRoot )
		end
	end
	addEventHandler( "onClientVehicleEnter", job_vehicle, onClientVehicleEnter_handler )
end