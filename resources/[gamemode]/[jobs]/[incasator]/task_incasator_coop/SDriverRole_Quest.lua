
-- Создать водителю точку сбора денег
function CreateDriverBusinessPoint( lobby_data, reset_van_full )
    local driver = GetJobDriver( lobby_data )
    if not isElement( driver ) then return end
    
    triggerClientEvent( driver, "onClientCreateBankPoint", resourceRoot, {
        lobby_id      = lobby_data.lobby_id,
        bank_point_id = lobby_data.bank_point_id,
        end_step      = lobby_data.end_step,
        participants  = lobby_data.participants,
        job_vehicle   = lobby_data.job_vehicle,
    } )

    if reset_van_full then
        triggerClientEvent( driver, "onClientUpdateVanFull", root, 0 )
    end
end

function GetVehicleCountOccupants( vehicle )
    local count = 0
    for seat, player in pairs( getVehicleOccupants(vehicle) ) do
        count = count + 1
    end
    return count
end

-- Парковка тачки на точке сбора/разгрузки
function ParkingIncasatorVehicle( lobby_data, state )
    if isTimer( lobby_data.end_shift_tmr ) then killTimer( lobby_data.end_shift_tmr ) end
    
    setTimer( function()
        if not lobby_data or not isElement( lobby_data.job_vehicle ) then return end
	    lobby_data.job_vehicle.frozen = state
        lobby_data.job_vehicle.engineState = not state
    end, 150, 1 )
	
    local driver = GetJobDriver( lobby_data )
    if isElement( driver ) then
        toggleControl( driver, "enter_exit", not state )
        driver:SetPrivateData( "block_engine_incasator", state )
    end
    
    SetUnloadBagsState( lobby_data, state )
end

-- Состояние погрузки мешков, для отмены уменьшения соц.рейтинга в случае защиты
function SetUnloadBagsState( lobby_data, state )
    for k, v in pairs( lobby_data.participants ) do
        v.player:setData( "incasator_unload_bags", state, false ) 
    end
end

-- Обновление кол-во мешков в меню у водителя
function RefreshDriverBagsPercent( lobby_data )
    local driver = GetJobDriver( lobby_data )
    if isElement( driver ) then
        triggerClientEvent( driver, "onClientUpdateVanFull", root, lobby_data.count_vehicle_bags / lobby_data.quest_bags_count )
    end
end

-- Обработчики взаимодейтствия с машиной
function AddIncasatorVehicleHandlers( lobby_data )
    
    local job_driver = GetJobDriver( lobby_data )
    bindKey( job_driver, PPS_CALL_KEY, "down", TryCallPPS )
            
    addEventHandler( "onVehicleExit", lobby_data.job_vehicle, function( player, seat, jacker, forced )
        if GetVehicleCountOccupants( source ) == 1 and not lobby_data.job_vehicle.frozen and not isTimer( lobby_data.end_shift_tmr  ) then
            lobby_data.end_shift_tmr = setTimer( triggerEvent, CONST_FAIL_SHIFT_EMPTY_VEHICLE * 1000, 1, "PlayerFailStopCoopQuest", resourceRoot, lobby_data.lobby_id, "Машина инкассации была изъята за бездействие", "fail_idle" )
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

    addEventHandler( "onVehicleDamage", lobby_data.job_vehicle, function( loss )
        if not isElement( lobby_data.job_vehicle ) then return end
        
		local all_damage = source:getData( "all_damage" ) or 0
		if loss > 5 then
			source:setData( "all_damage", all_damage + loss, false )
		end

		if all_damage < CONST_DAMAGE_ARMOR then
			source:setWheelStates( 0, 0, 0, 0 )
            source.health = 1000
            cancelEvent()
		end
    end )
    
end

-- Выдача статьи в случае атаки охранников
function onPlayerDamage_handler( attacker, _, _, loss )
    if source:GetJobClass() == JOB_CLASS_INKASSATOR and source:getData( "onshift" ) and isElement( attacker ) and attacker ~= source then
        
        attacker = attacker.type == "vehicle" and getVehicleOccupant( attacker ) or attacker

        if attacker.type == "player" and attacker:GetFaction() == 0 and (attacker:GetJobClass() ~= JOB_CLASS_INKASSATOR or not attacker:getData( "onshift" )) then
            attacker:AddWanted( "1.14", 1, true )
        end
    end
end
addEventHandler( "onPlayerDamage", root, onPlayerDamage_handler )

-- Получить водилу
function GetJobDriver( lobby_data )
    for k, v in pairs( lobby_data.participants ) do
        if v.role == JOB_ROLE_DRIVER then
            return v.player
        end
    end
end