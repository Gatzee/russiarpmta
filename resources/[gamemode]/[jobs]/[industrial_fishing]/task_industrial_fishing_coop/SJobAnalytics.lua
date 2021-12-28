
function OnIndustrialFishingJobFinish( player, lobby_data, reason_data )
	local job_duration = getRealTimestamp() - lobby_data.job_start

	local receive_sum = 0
	local exp_sum = 0
	if lobby_data.sum_data and lobby_data.sum_data[ player ] then
		receive_sum = lobby_data.sum_data[ player ].receive_sum
		exp_sum = lobby_data.sum_data[ player ].exp_sum
    end

    local no_change_fail_types =
    {
        [ "vehicle_destroy" ] = true,
        [ "player_wasted" ]   = true,
        [ "success" ]         = true,
        [ "time_out" ]        = true,
    }

    local finish_reason = "other"
    if no_change_fail_types[ reason_data.fail_type ] then
        finish_reason = reason_data.fail_type
    elseif reason_data.fail_type == "player_quit" and reason_data.target_player then
        local reasons = {
            [ DRIVER ] = "pilot_out",
            [ FISHERMAN ] = "fisherman_out",
            [ COORDINATOR ] = "coordinator_out",
        }
        local job_role = reason_data.target_player:GetCoopJobRole()
        finish_reason = reasons[ job_role ] and reasons[ job_role ] or finish_reason
    end

    SendElasticGameEvent( player:GetClientID( ), "industrial_fishing_job_finish",
    {
        lobby_id           = tonumber( lobby_data.lobby_id ),
        players_quantity   = tonumber( #lobby_data.participants ),
        job_duration       = tonumber( job_duration ),
        container_quantity = tonumber( lobby_data.container_unload_quantity ),
        receive_sum        = tonumber( receive_sum ),
        currency           = "soft",
        exp_sum            = tonumber( exp_sum ),
        finish_reason      = tostring( finish_reason ),
    } )
end