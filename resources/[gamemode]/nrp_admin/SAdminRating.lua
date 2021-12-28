TOTAL_ADMINS_COUNT = 0
TOTAL_WORKED_TIME_IN_MONTH = 0
TOTAL_REPORTS_ACCEPTED_IN_MONTH = 0
TOTAL_ADMINS_RATING = 0

addEventHandler( "onResourceStart", resourceRoot, function ( )
    DB:queryAsync( function( query )
        local result = query:poll( -1 )
        if not result then return end

        local current_date = os.time( )
        for i, data in pairs( result ) do
            local admin_data = data.admin_data and fromJSON( data.admin_data ) or { }
            local worked_time = admin_data.worked_time
            if worked_time and worked_time.month.reset_date > current_date then
                TOTAL_WORKED_TIME_IN_MONTH = TOTAL_WORKED_TIME_IN_MONTH + worked_time.month.time + worked_time.session
            end
            local reports_accepted = admin_data.reports_accepted
            if reports_accepted and reports_accepted.month.reset_date > current_date then
                TOTAL_REPORTS_ACCEPTED_IN_MONTH = TOTAL_REPORTS_ACCEPTED_IN_MONTH + reports_accepted.month.count + reports_accepted.session
            end
            local rating = admin_data.rating
            if rating and rating.total and rating.total >= 0 then
                TOTAL_ADMINS_RATING = TOTAL_ADMINS_RATING + rating.total
            end
        end
        TOTAL_ADMINS_COUNT = #result
    end, { }, "SELECT admin_data FROM nrp_players WHERE accesslevel > 0" )
end )

function onPlayerAccessLevelChange_ratingHandler( old_access_level, new_access_level )
    if old_access_level == 0 and new_access_level > 0 then
        TOTAL_ADMINS_COUNT = TOTAL_ADMINS_COUNT + 1
    elseif old_access_level > 0 and new_access_level == 0 then
        TOTAL_ADMINS_COUNT = TOTAL_ADMINS_COUNT - 1
    end
end  
addEvent( "onPlayerAccessLevelChange" )
addEventHandler( "onPlayerAccessLevelChange", root, onPlayerAccessLevelChange_ratingHandler )

addEvent( "onAdminAcceptReport" )
addEventHandler( "onAdminAcceptReport", root, function( )
    TOTAL_REPORTS_ACCEPTED_IN_MONTH = TOTAL_REPORTS_ACCEPTED_IN_MONTH + 1
end )

function AddTotalWorkedTime( time )
    TOTAL_WORKED_TIME_IN_MONTH = TOTAL_WORKED_TIME_IN_MONTH + time
end

function ResetRatingTotalValues( reset_period )
    if reset_period ~= "month" then return end
    TOTAL_REPORTS_ACCEPTED_IN_MONTH = 0
    TOTAL_WORKED_TIME_IN_MONTH = 0
    TOTAL_ADMINS_RATING = 0
end

local RATING_VALUE_WEIGHT = 0.45
local REPORTS_ACCEPTED_VALUE_WEIGHT = 0.25
local WORKED_TIME_VALUE_WEIGHT = 0.30
local MAX_RATING = 5

addEvent( "onPlayerRateAdmin", true )
addEventHandler( "onPlayerRateAdmin", root, function( admin_info, value )
    local rated_admins = source:GetPermanentData( "rated_admins" ) or { }
    local today_rated_admins_count = 0
    local current_date = os.time( )
    for i, v in pairs( rated_admins ) do
        if current_date - v.date < 24 * 60 * 60 then
            if v.admin_id == admin_info.id then
                return
            else
                today_rated_admins_count = today_rated_admins_count + 1
            end
        else
            rated_admins[ i ] = nil
        end
    end
    if today_rated_admins_count >= 3 then
        return
    end
    table.insert( rated_admins, { admin_id = admin_info.id, date = current_date } )
    source:SetPermanentData( "rated_admins", rated_admins )

	SendElasticGameEvent( source:GetClientID( ), "player_admin_report_rate", {
		admin_client_id = admin_info.client_id,
		admin_name = admin_info.name,
		rating = value,
	} )
    
    local admin = GetPlayer( admin_info.id )
    if not isElement( admin ) then return end

    local admin_rating = admin:GetAdminData( "rating" ) or { sum = 0, count = 0, total = 0 }
    admin_rating.sum = admin_rating.sum + value
    admin_rating.count = admin_rating.count + 1
    admin_rating.average = admin_rating.sum / admin_rating.count

    local reports_accepted = admin:GetAdminData( "reports_accepted" )
    local worked_time = admin:GetAdminData( "worked_time" )

    local Wr = admin_rating.total / ( TOTAL_ADMINS_RATING / TOTAL_ADMINS_COUNT ) * RATING_VALUE_WEIGHT
    local Wa = reports_accepted.month.count / ( TOTAL_REPORTS_ACCEPTED_IN_MONTH / TOTAL_ADMINS_COUNT ) * REPORTS_ACCEPTED_VALUE_WEIGHT
    local Wt = worked_time.month.time / ( TOTAL_WORKED_TIME_IN_MONTH / TOTAL_ADMINS_COUNT ) * WORKED_TIME_VALUE_WEIGHT

    if ( TOTAL_ADMINS_RATING / TOTAL_ADMINS_COUNT ) <= 0 then
        Wr = 1 * RATING_VALUE_WEIGHT
    end

    TOTAL_ADMINS_RATING = TOTAL_ADMINS_RATING - admin_rating.total

    admin_rating.total = Wr + Wa + Wt
    admin:SetAdminData( "rating", admin_rating )

    TOTAL_ADMINS_RATING = TOTAL_ADMINS_RATING + admin_rating.total

    SendToLogserver( "[ADMIN_RATING] Игрок " .. source:GetNickName() .. " поставил оценку админу " .. admin:GetNickName(), { admin_client_id = admin:GetClientID( ), value = value } )
end )