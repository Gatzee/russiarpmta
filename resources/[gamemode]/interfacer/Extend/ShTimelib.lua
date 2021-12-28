MS24H = 24*60*60*1000
EACHDAY = "mon,tue,wed,thu,fri,sat,sun"
MS10MINS = 10 * 60 * 1000
MS10H = 10 * 60 * 60 * 1000

HOUR_OFFSET = 0 --3

function ExecAtTime( time, func, ... )
    local hour, minute = unpack( split( time, ":" ) )

    hour = tonumber( hour )
    minute = tonumber( minute )

    if not hour or not minute then Debug( "Timelib: Неверно задано время выполнения: h " .. tostring( hour ) .. ", m " .. tostring( minute ), 1 ) return end

    local self = { }

    self.hour = hour
    self.minute = minute

    self.func = func
    self.args = { ... }

    self.ParseTime = function( )
        local realtime = getRealTime( getRealTimestamp( ) + HOUR_OFFSET * 60 * 60 )
        
        local hour = realtime.hour
        local minute = realtime.minute

        if hour ~= self.hour then return end -- не соответствие часу
        if minute ~= self.minute then return end -- не соответствие минуте

        --iprint( THIS_RESOURCE_NAME, "ExecAtTime: run", getRealTime() )

        self:func( unpack( self.args ) )
        self:destroy()

        return true
    end

    self.timer = Timer( self.ParseTime, 1000*1, 0 )

    self.destroy = function( self )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        setmetatable( self, nil )
        return true
    end

    self.again = function( self, delay )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        self.timer = Timer( 
            function()
                self.timer = Timer( self.ParseTime, 1000*1, 0 )
            end
        , delay, 1 )
    end

    return self
end

-- Сводная таблица дней недели
local _DAYLIST = {
    monday = 1,
    tuesday = 2,
    wednesday = 3,
    thursday = 4,
    friday = 5,
    saturday = 6,
    sunday = 0,

    mon = 1,
    tue = 2,
    wed = 3,
    thu = 4,
    fri = 5,
    sat = 6,
    sun = 0,
}

function ExecAtWeekdays( list, func, ... )
    local days = split( list, "," )

    if #days <= 0 then Debug( "Timelib: Неверно указан список дней недели: list " .. inspect( list ), 1 ) return end

    local self = { }

    local days_converted_reverse = { }
    local days_converted = { }
    for i, v in pairs( days ) do
        local day = _DAYLIST[ string.lower( v ) ]
        if day and not days_converted_reverse[ day ] then
            days_converted_reverse[ day ] = true
            table.insert( days_converted, day )
        end
    end

    self.days = days_converted
    self.days_reverse = days_converted_reverse

    self.func = func
    self.args = { ... }

    self.ParseTime = function( )
        local time = getRealTime( getRealTimestamp( ) + HOUR_OFFSET * 60 * 60 )
        
        local weekday = time.weekday
        if not self.days_reverse[ weekday ] then return end

        --iprint( THIS_RESOURCE_NAME, "ExecAtWeekdays: run", getRealTime() )

        self:func( unpack( self.args ) )
        self:destroy()

        return true
    end

    self.timer = Timer( self.ParseTime, 1000*1, 0 )

    self.destroy = function( self )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        setmetatable( self, nil )
        return true
    end

    self.again = function( self, delay )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        self.timer = Timer( 
            function()
                self.timer = Timer( self.ParseTime, 1000*1, 0 )
            end
        , delay, 1 )
    end
end

function ExecAtMonthdays( list, func, ... )
    local days = split( list, "," )

    if #days <= 0 then Debug( "Timelib: Неверно указан список дней месяца: list " .. inspect( list ), 1 ) return end

    local self = { }

    local days_converted_reverse = { }
    local days_converted = { }
    for i, v in pairs( days ) do
        local day = tonumber( v )
        if day and not days_converted_reverse[ day ] then
            days_converted_reverse[ day ] = true
            table.insert( days_converted, day )
        end
    end

    self.days = days_converted
    self.days_reverse = days_converted_reverse

    self.func = func
    self.args = { ... }

    self.ParseTime = function( )
        local time = getRealTime( getRealTimestamp( ) + HOUR_OFFSET * 60 * 60 )
        
        local monthday = time.monthday
        if not self.days_reverse[ monthday ] then return end

        --iprint( THIS_RESOURCE_NAME, "ExecAtMonthdays: run", getRealTime() )

        self:func( unpack( self.args ) )
        self:destroy()

        return true
    end

    self.timer = Timer( self.ParseTime, 1000*1, 0 )

    self.destroy = function( self )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        setmetatable( self, nil )
        return true
    end

    self.again = function( self, delay )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        self.timer = Timer( 
            function()
                self.timer = Timer( self.ParseTime, 1000*1, 0 )
            end
        , delay, 1 )
    end
end


function ExecAtYeardays( list, func, ... )
    local days = split( list, "," )

    if #days <= 0 then Debug( "Timelib: Неверно указан список дней года: list " .. inspect( list ), 1 ) return end

    local self = { }

    local days_converted_reverse = { }
    local days_converted = { }
    for i, v in pairs( days ) do
        local day = tonumber( v )
        if day and not days_converted_reverse[ day ] then
            days_converted_reverse[ day ] = true
            table.insert( days_converted, day )
        end
    end

    self.days = days_converted
    self.days_reverse = days_converted_reverse

    self.func = func
    self.args = { ... }

    self.ParseTime = function( )
        local time = getRealTime( getRealTimestamp( ) + HOUR_OFFSET * 60 * 60 )
        
        local yearday = time.yearday + 1
        if not self.days_reverse[ yearday ] then return end

        --iprint( THIS_RESOURCE_NAME, "ExecAtYeardays: run", getRealTime() )

        self:func( unpack( self.args ) )
        self:destroy()

        return true
    end

    self.timer = Timer( self.ParseTime, 1000*1, 0 )

    self.destroy = function( self )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        setmetatable( self, nil )
        return true
    end

    self.again = function( self, delay )
        if isTimer( self.timer ) then killTimer( self.timer ) end
        self.timer = Timer( 
            function()
                self.timer = Timer( self.ParseTime, 1000*1, 0 )
            end
        , delay, 1 )
    end
end