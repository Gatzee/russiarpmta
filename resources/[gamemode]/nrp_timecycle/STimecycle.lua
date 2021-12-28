local WEATHER_CYCLE_LIST = { 0, 1, 2, 3, 5, 13, 14 }

-- Каждые 6 часов с 00:00 проходят новые сутки
function resetTimeOfDay()
    local CYCLES_PER_DAY = 4
    local MINUTE_DURATION = 60 * 1000 / CYCLES_PER_DAY
    local FULL_DAY_MINUTES = 24 * 60

    local REALTIME = getRealTime()
    local REAL_H, REAL_M = REALTIME.hour, REALTIME.minute

    local passed_minutes = REAL_H * 60 + REAL_M
    local passed_percent = passed_minutes / ( 24 * 60 )

    local required_percent = passed_percent * CYCLES_PER_DAY
    local required_minutes_total = ( required_percent - math.floor( required_percent ) ) * FULL_DAY_MINUTES

    local required_hours = math.floor( required_minutes_total / 60 )
    local required_minutes = math.floor( required_minutes_total - required_hours * 60 )

    setTime( required_hours, required_minutes )
    setMinuteDuration( MINUTE_DURATION )
end

-- Ивенты на время суток

local LAG_PREVENTION_TICK = 10*1000 -- на всякий случай чтоб точно не слать 2 ивента подряд
local LAST_EVENTS = { }

function CheckTimeOfDay()
    local hour, minute = getTime()
    local current_tick = getTickCount()

    -- Ежечасный ивент (внутриигровой)
    if minute == 0 then
        if not LAST_EVENTS[ 'hour' ] or current_tick - LAST_EVENTS[ 'hour' ] > LAG_PREVENTION_TICK then
            triggerEvent( "onTimecycleHour", root )
            LAST_EVENTS[ 'hour' ] = current_tick
        end
    end

    -- Ивент каждые сутки в 00:00
    if hour == 0 and minute == 0 then
        if not LAST_EVENTS[ 'fullday' ] or current_tick - LAST_EVENTS[ 'fullday' ] > LAG_PREVENTION_TICK then
            triggerEvent( "onTimecycleFullday", root )
            LAST_EVENTS[ 'fullday' ] = current_tick
        end
    end

end

function onGameTimeRequest_handler( )
    triggerClientEvent( source, "onGameTimeRecieve", source, { getTime() }, getWeather() )
end
addEvent( "onGameTimeRequest", true )
addEventHandler( "onGameTimeRequest", root, onGameTimeRequest_handler )


function UpdateWeather()
    local weather = WEATHER_CYCLE_LIST[ math.random( 1, #WEATHER_CYCLE_LIST ) ]

    local _, is_blending = getWeather()
    if not is_blending then
        setWeatherBlended( weather )
    end
end
addEvent( "onTimecycleFullday", true )
addEventHandler( "onTimecycleFullday", root, UpdateWeather )

setTimer( CheckTimeOfDay, 1000, 0 )
CheckTimeOfDay()
resetTimeOfDay()
UpdateWeather()