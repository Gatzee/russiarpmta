local STATE, PREV_SPEED, TIME, TICK, MAX_SPEED

function RenderAcceleration( )
    local vehicle = localPlayer.vehicle

    if not vehicle then return end

    local speed = math.floor( vehicle:getVelocity( ).length * 180 )
    if PREV_SPEED then
        -- Если начал движение, сбрасываем
        if PREV_SPEED <= 0 and speed > 0 then
            TICK = getTickCount( )
            MAX_SPEED = 0

        elseif PREV_SPEED < 100 and speed >= 100 and TICK then
            TIME = getTickCount( ) - TICK
            TICK = nil
            
        elseif PREV_SPEED > 0 and speed <= 0 then
            TICK = nil
            
        end

    end
    PREV_SPEED = speed

    MAX_SPEED = math.max( speed, MAX_SPEED or 0 )

    local str = [[Текущая скорость: ]] .. speed .. [[ км/ч
Макс. скорость: ]] .. MAX_SPEED .. [[ км/ч

Текущее время 0-100: ]] .. ( getTickCount( ) - ( TICK or getTickCount( ) ) ) .. [[ мс
Фиксированное 0-100: ]] .. math.floor( ( TIME or 0 ) / 10 ) / 100 .. [[ сек.
    ]]

    dxDrawText( str, 10, 450, 0, 0, 0xffffffff, 1, 1, "default-bold" )
end

function ToggleAcceleration( )
    STATE = not STATE

    if STATE then
        addEventHandler( "onClientRender", root, RenderAcceleration )
        outputChatBox( "Замер ускорения включен", 0, 255, 0 )
    else
        PREV_VELOCITY = nil
        removeEventHandler( "onClientRender", root, RenderAcceleration )
        outputChatBox( "Замер ускорения отключен", 255, 0, 0 )
    end
end
addCommandHandler( "accel", ToggleAcceleration )