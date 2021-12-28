LEADERBOARD_LIST = { }

function GetClansSeasonData( current )
	return {
        season = CURRENT_SEASON_ID,
        locked = LOCKED_SEASON,
        start_date = LOCKED_SEASON and SEASON_END_DATE + LOCKED_SEASON_DURATION or SEASON_START_DATE,
        end_date = SEASON_END_DATE,
        leaderboard = not current and LOCKED_SEASON and LOCKED_SEASON_LEADEBOARD or LEADERBOARD_LIST,
    }
end

addEvent( "onPlayerShowLeaderboardRequest", true )
addEventHandler( "onPlayerShowLeaderboardRequest", root, function( current )
    local player = client or source
    triggerClientEvent( player, "ShowClansLeaderboard", player, GetClansSeasonData( current ) )
end )

function GetClanLeaderboardPosition( clan )
    clan = tonumber( clan ) and CLANS_BY_ID[ clan ] or clan
    if LOCKED_SEASON then
        return not clan.seasons_positions and ( #LOCKED_SEASON_LEADEBOARD + 1 ) or clan.seasons_positions[ CURRENT_SEASON_ID ] or 0
    elseif clan.cartel then
        return -clan.cartel
    else
        local clan_score = clan.leaderboard_data[ LB_CLAN_SCORE ]
        local clan_members_count = clan.leaderboard_data[ LB_CLAN_MEMBERS_COUNT ]
        local position = 1
        for i, data in pairs( LEADERBOARD_LIST ) do
            local other_score = data[ LB_CLAN_SCORE ]
            if other_score > clan_score or other_score == clan_score and data[ LB_CLAN_MEMBERS_COUNT ] > clan_members_count then
                position = position + 1
            end
        end
        return position
    end
end

function SendClanLeaderboardAnalyticsData( clan_id, position )
    local clan = CLANS_BY_ID[ clan_id ]
    if not clan then return end

    SendElasticGameEvent( nil, "clan_lb_season_track", {
        clan_id = clan.id,
        clan_name = clan.name,
        clan_money = clan.money,
        clan_honor_points = clan.honor,
        clan_lb_points = clan.score,
        clan_lb_position = not LOCKED_SEASON and clan.cartel and -clan.cartel or position,
        clan_member_limit = clan.slots,
        clan_member_count = clan.members_count,
        season_num = CURRENT_SEASON_ID,
        clan_join_count = clan.today_join_count,
        clan_leave_count = clan.today_leave_count,
        clan_creation_date = clan.create_date,
    } )
    clan.today_join_count = 0
    clan.today_leave_count = 0
end

function SendLeaderboardAnalyticsData( )
    local sorted_leaderboard = LOCKED_SEASON and LOCKED_SEASON_LEADEBOARD or table.copy( LEADERBOARD_LIST )
    if not LOCKED_SEASON then
	    table.sort( sorted_leaderboard, function( a, b ) return not a.cartel and ( a[ LB_CLAN_SCORE ] > b[ LB_CLAN_SCORE ] or a[ LB_CLAN_SCORE ] == b[ LB_CLAN_SCORE ] and a[ LB_CLAN_MEMBERS_COUNT ] > b[ LB_CLAN_MEMBERS_COUNT ] ) end )
    end

    if LOCKED_SEASON then
        for position, data in pairs( LOCKED_SEASON_CARTELS ) do
            SendClanLeaderboardAnalyticsData( data[ LB_CLAN_ID ], -position )
        end
    end
    
    for position, data in pairs( sorted_leaderboard ) do
        SendClanLeaderboardAnalyticsData( data[ LB_CLAN_ID ], position )
    end

    setTimer( SendLeaderboardAnalyticsData, MS24H, 1 )
end
ExecAtTime( "02:00", SendLeaderboardAnalyticsData )










if SERVER_NUMBER > 100 then




    addCommandHandler( "doleaderboardanal", function( )
        SendLeaderboardAnalyticsData( )
    end )
    
    



end