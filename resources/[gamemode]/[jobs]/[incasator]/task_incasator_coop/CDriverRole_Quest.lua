function onDriverTryExitFromVehicle( player )
	local job_vehicle = localPlayer:getData( "job_vehicle" )
	if job_vehicle and player == localPlayer and CEs.current_point then
		local distance = getDistanceBetweenPoints3D( CEs.current_point, job_vehicle.position )
		if distance < 25 then 
			localPlayer:ShowInfo( "Оставайся в машине" )
			cancelEvent() 
		end
	end
end

function CheckAllPlayersInVehicle( lobby_data )
	for k, v in pairs( lobby_data.participants ) do
		if isElement( v.player ) and v.player:GetCoopJobLobbyId() == lobby_data.lobby_id and v.player.vehicle ~= lobby_data.job_vehicle then
			return false
		end
	end
	return true
end

function onClientCreateBankPoint_handler( lobby_data )
	CEs.current_point = BANK_LOAD_POINT[ lobby_data.bank_point_id ].parking
	CreateQuestPoint( CEs.current_point, function()
		if not CheckAllPlayersInVehicle( lobby_data ) then
			localPlayer:ShowError( "Для сбора денег все участники должны быть в машине")
			return false
		end

		CEs.marker:destroy()
		triggerServerEvent( lobby_data.end_step, localPlayer )
	end, _, 5, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20, 3 )
end
addEvent( "onClientCreateBankPoint", true )
addEventHandler( "onClientCreateBankPoint", root, onClientCreateBankPoint_handler )

function CreateUnloadVehiclePoint( lobby_data )
	CEs.current_point = BANK_UNLOAD_POINTS_VEHICLE[ math.random(1, #BANK_UNLOAD_POINTS_VEHICLE)]
	CreateQuestPoint( CEs.current_point, function()
		if not CheckAllPlayersInVehicle( lobby_data ) then
			localPlayer:ShowError( "Для разгрузки денег все участники должны быть в машине")
			return false
		end

		CEs.marker:destroy()
		triggerServerEvent( lobby_data.end_step, localPlayer )
	end, _, 5, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20, 3 )
end