
-- Создать водителю точку сбора мусора
function CreateDriverParkingPoint( lobby_data )
    local driver = GetJobDriver( lobby_data )
    if not isElement( driver ) then return end

    triggerClientEvent( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), "CreateDriverParkingPoint", resourceRoot, {
        trash_point_id = lobby_data.trash_point_id,
        end_step = lobby_data.end_step,
    } )
end

-- Парковка тачки на точке сбора/разгрузки
function SetTrashTruckParked( lobby_data, state )
    if isTimer( lobby_data.end_shift_tmr ) then killTimer( lobby_data.end_shift_tmr ) end

    setTimer( function()
        if not lobby_data or not isElement( lobby_data.job_vehicle ) then return end
	    lobby_data.job_vehicle:SetStatic( state )
        lobby_data.job_vehicle.engineState = not state
    end, 150, 1 )

    for i, player in pairs( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ) ) do
        -- toggleControl( player, "enter_exit", not state )
        player:SetPrivateData( "block_engine_incasator", state )
    end
end

-- Обновление кол-во мешков в HUDe
function RefreshTrashmanHUD( lobby_data )
    triggerClientEvent( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), "onClientUpdateTrashTruckFull", resourceRoot, lobby_data.count_vehicle_bags / lobby_data.quest_bags_count )
end

-- Обработчики взаимодейтствия с машиной
function AddTrashmanVehicleHandlers( lobby_data )

    local job_driver = GetJobDriver( lobby_data )

    addEventHandler( "onVehicleExit", lobby_data.job_vehicle, function( player, seat, jacker, forced )
        if GetVehicleCountOccupants( source ) == 1 and not lobby_data.job_vehicle.frozen and not isTimer( lobby_data.end_shift_tmr  ) then
            lobby_data.end_shift_tmr = setTimer( triggerEvent, CONST_FAIL_SHIFT_EMPTY_VEHICLE * 1000, 1, "PlayerFailStopCoopQuest", resourceRoot, lobby_data.lobby_id, "Мусоровоз был изъят за бездействие", "fail_idle" )
        end
    end )

    addEventHandler( "onVehicleEnter", lobby_data.job_vehicle, function( player, seat, jacked )
        if GetVehicleCountOccupants( source ) > 1 and isTimer( lobby_data.end_shift_tmr ) then
            killTimer( lobby_data.end_shift_tmr )
        end
    end )

    addEventHandler( "onVehicleStartEnter", lobby_data.job_vehicle, function( player, seat )
		if seat == 0 and player:GetCoopJobRole() ~= JOB_ROLE_DRIVER then
			cancelEvent()
		end
    end )

end

-- Получить водилу
function GetJobDriver( lobby_data )
    for k, v in pairs( lobby_data.participants ) do
        if v.role == JOB_ROLE_DRIVER then
            return v.player
        end
    end
end