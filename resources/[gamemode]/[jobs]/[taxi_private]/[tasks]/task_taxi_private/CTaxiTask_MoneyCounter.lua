COUNTER = { }

function onTaxiStartCounting_handler( per_100m )
    onTaxiStopCounting_handler( )

    COUNTER = { distance = 0, temp_distance = 0, money = 0, last_position = localPlayer.position, per_100m = per_100m, timer = setTimer( PulseCounter, 500, 0 ) }

    -- Включаем счетчик в телефоне
    triggerEvent( "onPhoneTaxiSetCounterState", localPlayer, true )
end
addEvent( "onTaxiStartCounting", true )
addEventHandler( "onTaxiStartCounting", root, onTaxiStartCounting_handler )

function onTaxiStopCounting_handler( )
    if COUNTER then
        if isTimer( COUNTER.timer ) then killTimer( COUNTER.timer ) end
        COUNTER = nil

        -- Отключаем счетчик в телефоне
        triggerEvent( "onPhoneTaxiSetCounterState", localPlayer, false )
    end
end
addEvent( "onTaxiStopCounting", true )
addEventHandler( "onTaxiStopCounting", root, onTaxiStopCounting_handler )

function PulseCounter( )
    local new_position = localPlayer.position
    local distance = ( new_position - COUNTER.last_position ).length

    COUNTER.temp_distance = COUNTER.temp_distance + distance
    COUNTER.last_position = new_position

    if COUNTER.temp_distance >= 100 then
        local additional_distance = 100 --math.floor( COUNTER.temp_distance )
        COUNTER.distance = COUNTER.distance + additional_distance

        local per_100m = COUNTER.per_100m
        COUNTER.money = COUNTER.money + math.floor( additional_distance * per_100m / 100 )
        
        COUNTER.temp_distance = 0

        triggerServerEvent( "onTaxiPlayerDistancePulse", localPlayer, additional_distance, { new_position.x, new_position.y, new_position.z } )
        triggerEvent( "onPhoneTaxiUpdateCounter", localPlayer, COUNTER )
    end
end