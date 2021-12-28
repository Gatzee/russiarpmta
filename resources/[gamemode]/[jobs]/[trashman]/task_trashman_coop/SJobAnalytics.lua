
-- Закончил смену
function onTrashmanJobFinish( player, lobby_data, reason_data )
    local lobby_id = lobby_data.lobby_id
    local players_quantity = #lobby_data.participants
	local job_duration = getRealTimestamp() - lobby_data.job_start
	local bag_quantity = lobby_data.count_delivered_bags

	local receive_sum = 0
	local exp_sum = 0
	if lobby_data.sum_data and lobby_data.sum_data[ player ] then
		receive_sum = lobby_data.sum_data[ player ].receive_sum
		exp_sum = lobby_data.sum_data[ player ].exp_sum
    end

    local finish_reason = reason_data.fail_type or "other"
    if reason_data.fail_type == "vehicle_destroy" then
        finish_reason = "destroy_car"
    elseif reason_data.fail_type == "player_quit" then
        finish_reason = "exit"
    end

    SendElasticGameEvent( player:GetClientID( ), "trashman_job_finish",
    {
        lobby_id         = tonumber( lobby_id ),
        current_lvl      = tonumber( player:GetLevel() ),
        players_quantity = tonumber( players_quantity ),
        job_duration     = tonumber( job_duration ),
        bag_quantity     = tonumber( bag_quantity ),
        receive_sum      = tonumber( receive_sum ),
        finish_reason    = tostring( finish_reason ),
        currency         = "soft",
        exp_sum          = tonumber( exp_sum ),
    } )
end

function onTrashmanJobFinishVoyage( player, lobby_data, receive_sum, exp_sum )
    SendElasticGameEvent( player:GetClientID( ), "trashman_job_finish_voyage",
    {
        lobby_id         = tonumber( lobby_data.lobby_id ),
        current_lvl      = tonumber( player:GetLevel() ),
        players_quantity = tonumber( #lobby_data.participants ),
        job_duration     = tonumber( lobby_data.lap_duration ),
        receive_sum      = tonumber( receive_sum ),
        currency         = "soft",
        exp_sum          = tonumber( exp_sum ),
    } )
end
