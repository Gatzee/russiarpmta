ADMIN_WORKED_TIME = { }
TRACKING_START_TIME = { }

NEXT_RESET_DATES = { }

function UpdateNextResetDate( period, old_reset_date, force_reset )
    local dt = os.date( "*t" )
    if period == "month" then
        dt = os.time( { year = dt.year, month = dt.month + 1, day = 1, hour = 0 } )
    elseif period == "week" then
        dt = os.time( { year = dt.year, month = dt.month, day = dt.day + ( 9 - dt.wday ), hour = 0 } )
    elseif period == "week+2h" then
        dt = os.time( { year = dt.year, month = dt.month, day = dt.day + ( 9 - dt.wday ), hour = 2 } )
    elseif period == "day" then
        dt = os.time( { year = dt.year, month = dt.month, day = dt.day + 1, hour = 0 } )
    end
    NEXT_RESET_DATES[ period ] = dt
    if dt == old_reset_date then -- на случай, если таймер сработал раньше даты окончания периода
        setTimer( UpdateNextResetDate, 1000, 1, period, dt, true )
        return
    end
    setTimer( UpdateNextResetDate, ( dt - os.time( ) + 1 ) * 1000, 1, period, dt, true )

    if force_reset then
        if period ~= "week+2h" then
            ResetOnlineAdminsWorkedTime( period, dt )
            ResetOnlineAdminsReportsAccepted( period, dt )
            ResetRatingTotalValues( period )
        end
        ResetOnlineAdminsTasks( period, dt )
        SyncOnlineAdminsWorkData( )
    end
end
UpdateNextResetDate( "month" )
UpdateNextResetDate( "week" )
UpdateNextResetDate( "week+2h" )
UpdateNextResetDate( "day" )

local SAVE_TIMERS = { }
local CONST_TICK_FREQ = 60

local function UpdateWorkedTime( player, worked_time, current_timestamp )
    local time_passed = current_timestamp - TRACKING_START_TIME[ player ]
    TRACKING_START_TIME[ player ] = current_timestamp

    local worked_time_in_day = worked_time.day.time + worked_time.session
    if worked_time_in_day + time_passed > MAX_WORKED_TIME_IN_DAY then
        time_passed = MAX_WORKED_TIME_IN_DAY - worked_time_in_day
        if time_passed <= 0 then return end
    end

    worked_time.session = worked_time.session + time_passed

    AddTotalWorkedTime( time_passed )
    CheckAdminPayoutTime( player, worked_time, time_passed )
end

function UpdateWorkedTimeData( player )
    if not isElement( player ) then
        if isTimer( SAVE_TIMERS[ player ] ) then killTimer( SAVE_TIMERS[ player ] ) end
        SAVE_TIMERS[ player ] = nil
        return
    end

    UpdateWorkedTime( player, ADMIN_WORKED_TIME[ player ], os.time( ) )

    player:SetAdminData( "worked_time", ADMIN_WORKED_TIME[ player ] )
end

function onPlayerCompleteLogin_timeHandler( player )
    local player = isElement( player ) and player or source
    if not player:IsAdmin( ) then return end
	
    local worked_time = player:GetAdminData( "worked_time" )
    if worked_time then
        for period, data in pairs( worked_time ) do
            if period ~= "session" then
                if data.reset_date and NEXT_RESET_DATES[ period ] > data.reset_date then
                    data.time = 0
                    data.reset_date = NEXT_RESET_DATES[ period ]
                else
                    data.time = data.time + worked_time.session
                end
            end
        end
        worked_time.session = 0
    else
        worked_time = {
            total = { time = 0 },
            month = { time = 0, reset_date = NEXT_RESET_DATES.month },
            week = { time = 0, reset_date = NEXT_RESET_DATES.week },
            day = { time = 0, reset_date = NEXT_RESET_DATES.day },
            session = 0,
        }
    end
    player:SetAdminData( "worked_time", worked_time )

    ADMIN_WORKED_TIME[ player ] = worked_time
    TRACKING_START_TIME[ player ] = os.time( )
    SAVE_TIMERS[ player ] = setTimer( UpdateWorkedTimeData, CONST_TICK_FREQ * 1000, 0, player )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_timeHandler, true, "high" )

function onResourceStart_timeHandler()
    for i, v in pairs( GetPlayersInGame( ) ) do
        onPlayerCompleteLogin_timeHandler( v )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_timeHandler, true, "high" )

function ResetOnlineAdminsWorkedTime( reset_period, new_reset_date )
    local current_timestamp = os.time( )
    for player, worked_time in pairs( ADMIN_WORKED_TIME ) do
        UpdateWorkedTime( player, worked_time, current_timestamp )

        local session_time = worked_time.session
        if session_time > 0 then
            for period, data in pairs( worked_time ) do
                if period ~= "session" then
                    data.time = data.time + session_time
                end
            end
            
            SendElasticGameEvent( player:GetClientID( ), "admin_duty_end", {
                duration_time = session_time,
            } )
        end
        worked_time.session = 0
        worked_time[ reset_period ].time = 0
        worked_time[ reset_period ].reset_date = new_reset_date
        player:SetAdminData( "worked_time", worked_time )
    end
end

function onPlayerPreLogout_timeHandler( player )
    local player = isElement( player ) and player or source
    if not ADMIN_WORKED_TIME[ player ] then return end

    if isTimer( SAVE_TIMERS[ player ] ) then killTimer( SAVE_TIMERS[ player ] ) end
    SAVE_TIMERS[ player ] = nil

    local worked_time = ADMIN_WORKED_TIME[ player ]
    UpdateWorkedTime( player, worked_time, os.time( ) )
    player:SetAdminData( "worked_time", worked_time )

    ADMIN_WORKED_TIME[ player ] = nil
    TRACKING_START_TIME[ player ] = nil

	SendElasticGameEvent( player:GetClientID( ), "admin_duty_end", {
		duration_time = worked_time.session,
	} )
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_timeHandler, true, "high" )

function onResourceStop_timeHandler()
    for player, worked_time in pairs( ADMIN_WORKED_TIME ) do
        onPlayerPreLogout_timeHandler( player )
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_timeHandler, true, "high" )

addEvent( "onPlayerAccessLevelChange" )
addEventHandler( "onPlayerAccessLevelChange", root, function( old_access_level, new_access_level )
    if old_access_level == 0 and new_access_level > 0 then
        onPlayerPreLogout_timeHandler( source )
        onPlayerCompleteLogin_timeHandler( source )
    elseif old_access_level > 0 and new_access_level == 0 then
        onPlayerPreLogout_timeHandler( source )
    end
end )