
function onHijackCarsJobFinish( player, lobby_data, reason_data )
    local job_duration = getRealTimestamp() - lobby_data.job_start

    local exp_sum = 0
	local receive_sum = 0
	if lobby_data.sum_data and lobby_data.sum_data[ player ] then
		receive_sum = lobby_data.sum_data[ player ].receive_sum
		exp_sum = lobby_data.sum_data[ player ].exp_sum
    end

    local finish_reason = reason_data.fail_type or "other"
    if reason_data.fail_type == "player_quit" and reason_data.target_player then
        local reasons = {
            [ JOB_ROLE_DRIVER ] = "driver_out",
            [ JOB_ROLE_MASTER ] = "master_out",
        }
        local job_role = reason_data.target_player:GetCoopJobRole()
        finish_reason = reasons[ job_role ] and reasons[ job_role ] or finish_reason
    end
    
    SendElasticGameEvent( player:GetClientID( ), "hijack_cars_job_finish",
    {
        lobby_id      = tonumber( lobby_data.lobby_id ),
        receive_sum   = tonumber( receive_sum ),
        current_lvl   = tonumber( player:GetLevel() ),
        currency      = "soft",
        exp_sum       = tonumber( exp_sum ),
        vehicle_count = tonumber( lobby_data.vehicle_count or 0 ),
        players_num   = tonumber( #lobby_data.participants ),
        job_duration  = tonumber( job_duration ),
        finish_reason = tostring( finish_reason ),
    } )
end

-- Закончил очередной рейс
function onHijackCarsJobVoyage( player, lobby_data, receive_sum, exp_sum )
    SendElasticGameEvent( player:GetClientID( ), "hijack_cars_job_voyage",
    {
        lobby_id         = tonumber( lobby_data.lobby_id ),
        current_lvl      = tonumber( player:GetLevel() ),
        vehicle_id       = tostring( lobby_data.hijacked_vehicle_id ),
        vehicle_name     = tostring( lobby_data.hijacked_vehicle_name ),
        vehicle_class    = tostring( lobby_data.hijacked_vehicle_tier ),
        players_quantity = tonumber( #lobby_data.participants ),
        job_role         = tostring( QUEST_DATA.roles[ player:GetCoopJobRole() ].id ),
        job_duration     = tonumber( lobby_data.lap_duration ),
        receive_sum      = tonumber( receive_sum ),
        currency         = "soft",
        exp_sum          = tonumber( exp_sum ),
    } )
end