
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
    local shift = self:getData( "job_shift" )
    if not shift or not shift.started_day then return true end

    local time = getRealTime( getRealTimestamp( ) )
    return shift.started_day[ 1 ] ~= time.month or shift.started_day[ 2 ] ~= time.monthday
end