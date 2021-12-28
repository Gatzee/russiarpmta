
-- Закончил смену
function onDeliveryCarsJobFinish( player, lobby_data, reason_data )
    local lobby_id = lobby_data.lobby_id
    local players_quantity = #lobby_data.participants
	local job_duration = getRealTimestamp() - lobby_data.job_start
	
	local receive_sum = 0
	local exp_sum = 0
	if lobby_data.sum_data and lobby_data.sum_data[ player ] then
		receive_sum = lobby_data.sum_data[ player ].receive_sum
		exp_sum = lobby_data.sum_data[ player ].exp_sum
    end
    
    local finish_reason = "other"
    if reason_data.fail_type == "destroy_car" or reason_data.fail_type == "destroy_helicopter" or reason_data.fail_type == "success" or reason_data.fail_type == "time_out" then
        finish_reason = reason_data.fail_type
    elseif reason_data.fail_type == "player_quit" and reason_data.target_player then
        local reasons = {
            [ JOB_ROLE_DRIVER ] = "driver_out",
            [ JOB_ROLE_COORDINATOR ] = "coordinator_out",
        }
        local job_role = reason_data.target_player:GetCoopJobRole()
        finish_reason = reasons[ job_role ] and reasons[ job_role ] or finish_reason
    end

    SendElasticGameEvent( player:GetClientID( ), "delivery_cars_job_finish",
    {
        lobby_id         = tonumber( lobby_id ),
        current_lvl      = tonumber( player:GetLevel() ),
        job_duration     = tonumber( job_duration ),
        vehicle_count    = tonumber( lobby_data.vehicle_count or 0 ),
        finish_reason    = tostring( finish_reason ),
        receive_sum      = tonumber( receive_sum ),
        currency         = "soft",
        exp_sum          = tonumber( exp_sum ),
    } )
end

-- Игрок закончил очередной рейс
function onDeliveryCarsJobFinishVoyage( player, lobby_data, money, exp )
    local time_speak = 0
    local count_sms = 0
    
    SendElasticGameEvent( player:GetClientID( ), "delivery_cars_job_voyage",
    {
        lobby_id         = tonumber( lobby_data.lobby_id ),
        current_lvl      = tonumber( player:GetLevel() ),
        vehicle_id       = tonumber( lobby_data.vehicle_id ),
        vehicle_name     = tostring( VEHICLE_CONFIG[ lobby_data.vehicle_id ].model ),
        vehicle_class    = tonumber( lobby_data.vehicle_class ),
        players_quantity = tonumber( #lobby_data.participants ),
        count_speak      = tonumber( player:getData( "count_speak" ) or 0 ),
        count_sms        = tonumber( player:getData( "count_sms" ) or 0 ),
        job_role         = tostring( QUEST_DATA.roles[ player:GetCoopJobRole() ].id ),
        job_duration     = tonumber( lobby_data.lap_duration ),
        receive_sum      = tonumber( money or 0 ),
        currency         = "soft",
        exp_sum          = tonumber( exp or 0 ),
    } )
end