--[[
    {
        start = время начала,
        passed = текущее время,
        last_started = время начала текущей смены,
    }
]]

function Player.GetShiftRemainingTime( self )
    local shift = self:getData( "job_shift" )
    if not shift then return self:GetShiftDuration( ) end
    shift.passed = shift.passed or 0

    local time_passed
    if shift.last_started then 
        time_passed = shift.passed + ( getRealTimestamp( ) - shift.last_started )
    else
        time_passed =  shift.passed
    end

    return math.max( 0, self:GetShiftDuration( ) - time_passed )
end

function Player.IsNewShiftDay( self )
    local time = getRealTime( getRealTimestamp( ) - SHIFT_CHANGE_TIME )
    local shift = self:getData( "job_shift" )

    if not shift or not shift.started_day then return true end

    return shift.started_day[ 1 ] ~= time.month or shift.started_day[ 2 ] ~= time.monthday
end