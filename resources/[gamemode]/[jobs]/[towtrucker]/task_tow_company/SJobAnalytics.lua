
-- Закончил смену 
function OnEvacJobFinish( player, lobby_id, players_num, job_duration, cars_num, receive_sum, exp_sum )
    SendElasticGameEvent( player:GetClientID( ), "towtrucker_job_finish",
    {
        lobby_id     = tonumber( lobby_id ),
        players_num  = tonumber( players_num ),
        job_duration = tonumber( job_duration ),
        cars_num     = tonumber( cars_num ),
        receive_sum  = tonumber( receive_sum ),
        currency     = "soft",
        exp_sum      = tonumber( exp_sum ),
    } )
end

-- Закончил очередной рейс
function OnEvacJobVoyage( player, lobby_data, receive_sum, exp_sum )
    SendElasticGameEvent( player:GetClientID( ), "towtrucker_job_voyage",
    {
        lobby_id         = tonumber( lobby_data.lobby_id ),
        current_lvl      = tonumber( player:GetLevel() ),
        players_quantity = tonumber( #lobby_data.participants ),
        job_duration     = tonumber( lobby_data.lap_duration ),
        evac_type        = tostring( lobby_data.evac_type ),
        receive_sum      = tonumber( receive_sum ),
        currency         = "soft",
        exp_sum          = tonumber( exp_sum ),
    } )
end

-- ДПС отметил авто для эвакуации
function OnDpsVehicleMark( player, vehicle )
    local car_marks_today_num = (player:GetPermanentData( "car_marks_today_num" ) or 0) + 1
    local car_marks_total_count = (player:GetPermanentData( "car_marks_total_count" ) or 0) + 1

    player:SetPermanentData( "car_marks_today_num", car_marks_today_num )
    player:SetPermanentData( "car_marks_total_count", car_marks_total_count )

    SendElasticGameEvent( player:GetClientID( ), "police_car_mark",
    {
        officer_rank          = tostring( FACTIONS_LEVEL_NAMES[ player:GetFaction( ) ][ player:GetFactionLevel( ) ] ),
        car_name              = tostring( VEHICLE_CONFIG[ vehicle.model ].model ),
        car_id                = tonumber( vehicle.model ),
        car_marks_today_num   = tonumber( car_marks_today_num ),
        car_marks_total_count = tonumber( car_marks_total_count ),
    } )
end


function ResetCarMark( )
    DB:exec( "UPDATE nrp_players SET car_marks_today_num=0" )
    DATABASE_RESET_TIMER = setTimer( ResetCarMark, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", ResetCarMark )


if SERVER_NUMBER > 100 then
	addCommandHandler( "reset_car_mark", function()
        ResetCarMark( )
	end )
end