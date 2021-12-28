
-- Закончил смену
function onIncasatorJobFinish( player, lobby_data, reason_data )
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
    
    local finish_reason = "other"
    if reason_data.fail_type == "vehicle_destroy" then
        finish_reason = "destroy_car"
    elseif reason_data.fail_type == "player_quit" and reason_data.target_player then
        local reasons = {
            [ JOB_ROLE_DRIVER ] = "driver_out",
            [ JOB_ROLE_GUARD ] = "protectors_out",
        }
        local job_role = reason_data.target_player:GetCoopJobRole()
        finish_reason = reasons[ job_role ] and reasons[ job_role ] or finish_reason
    end

    SendElasticGameEvent( player:GetClientID( ), "incasator_job_finish",
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

-- Водитель нажал на тревожную кнопку
function onIncasatorJobCallPolice( player, lobby_id )
    SendElasticGameEvent( player:GetClientID( ), "incasator_job_call_police",
    {
        lobby_id    = tonumber( lobby_id ),
        current_lvl = tonumber( player:GetLevel() ),
    } )
end

-- Сотрудник ППС принял вызов от инкасаторов
function onIncasatorJobPoliceAccepted( player, lobby_id )
    SendElasticGameEvent( player:GetClientID( ), "incasator_job_police_accepted",
    {
        lobby_id    = tonumber( lobby_id ),
        current_lvl = tonumber( player:GetLevel() ),
    } )
end

-- Потеря денег охраником
function onIncasatorJobNotProtect( player, lobby_id )
    SendElasticGameEvent( player:GetClientID( ), "incasator_job_not_protect",
    {
        lobby_id    = tonumber( lobby_id ),
        current_lvl = tonumber( player:GetLevel() ),    
    } )
end

-- Игрок закончил очередной рейс
function oNIncasatorJobFinishVoyage( player, lobby_data, receive_sum, exp_sum )
    SendElasticGameEvent( player:GetClientID( ), "incasator_job_finish_voyage",
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

addEvent( "onPlayerPreWastedCoopJob" )
addEventHandler( "onPlayerPreWastedCoopJob", root, function( ammo, attacker, weapon_id )
    local player = source
    if not attacker or attacker == player then return end

    local lobby_id = player:getData( "work_lobby_id" )
    if not lobby_id then return end

    local lobby_data = GetLobbyDataById( lobby_id )
    if not lobby_data then return end
    
    if getElementType( attacker ) == "vehicle" then
        attacker = getVehicleOccupant( attacker )
    end

    if attacker and getElementType( attacker ) == "player" then
        SendElasticGameEvent( player:GetClientID( ), "incasator_job_damage_protect",
        {
            lobby_id    = tonumber( lobby_id ),
            current_lvl = tonumber( player:GetLevel() ),
            player_id   = tostring( attacker:GetClientID( ) ),
            gun_id      = tonumber( weapon_id and weapon_id or -1 ),
            gun_name    = tostring( weapon_id and getWeaponNameFromID( weapon_id ) or "other" ),
            is_dead     = tostring( true ),
        } )
    end
end )