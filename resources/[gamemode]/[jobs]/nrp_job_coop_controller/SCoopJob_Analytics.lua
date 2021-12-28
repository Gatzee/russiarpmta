
-- Начало смены
function onJobStarted( player, lobby_id, job_role, is_lobby_creator, players_quantity, search_duration )
    SendElasticGameEvent( player:GetClientID( ), JOB_ID[ player:GetJobClass() ] .. "_job_start",
    {
        lobby_id         = tonumber( lobby_id ),
        current_lvl      = tonumber( player:GetLevel() ),
        job_role         = tostring( job_role ),
        is_lobby_creator = tostring( is_lobby_creator ),
        players_quantity = tonumber( players_quantity ),
        search_duration  = tonumber( search_duration ),
    } )
end