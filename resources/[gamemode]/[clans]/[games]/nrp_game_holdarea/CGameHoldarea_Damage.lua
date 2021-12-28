-- Размер эффекта на экране
x, y    = guiGetScreenSize()
sx, sy  = 640, 480
scale   = x / sx * 1.2
sx, sy  = sx * scale, sy * scale
px, py  = math.floor( x / 2 - sx / 2 ), math.floor( y / 2 - sy / 2 )

-- Эффект на экране
SHOWUP_DURATION   = 100
KEEP_DURATION     = 250
GODOWN_DURATION   = 400

ALPHA       = 0
MAX_ALPHA   = 170

TURN_TYPE_SHOWUP    = 1
TURN_TYPE_KEEP      = 2
TURN_TYPE_GODOWN    = 3

-- Отключение движения
DAMAGE_NEW_TIME = 1000
DAMAGE_ADD_TIME = 500
DAMAGE_CONTROLS_DISABLE = { "forwards", "backwards", "left", "right", "sprint", "jump", "fire" }
DAMAGE_ALLOWED_SLOTS = {
    [ 2 ] = true,
    [ 3 ] = true,
    [ 4 ] = true,
    [ 5 ] = true,
    [ 6 ] = true,
    [ 7 ] = true,
}

-- Отрисовка эффекта
function RenderDamage()
    local tick = getTickCount()

    if TURN == TURN_TYPE_SHOWUP then
        local progress = 1 - ( TURN_SWITCH_TICK - tick ) / SHOWUP_DURATION
        if progress > 1 then
            progress = 1

            TURN = TURN_TYPE_KEEP
            TURN_SWITCH_TICK = tick + KEEP_DURATION

            TURN_SWITCH_ALPHA = MAX_ALPHA
        end

        ALPHA = interpolateBetween( TURN_SWITCH_ALPHA, 0, 0, MAX_ALPHA, 0, 0, progress, "InOutQuad" )

    elseif TURN == TURN_TYPE_KEEP then
        local progress = 1 - ( TURN_SWITCH_TICK - tick ) / KEEP_DURATION
        if progress > 1 then

            TURN = TURN_TYPE_GODOWN
            TURN_SWITCH_TICK = tick + GODOWN_DURATION

            TURN_SWITCH_ALPHA = MAX_ALPHA
        end

        ALPHA = TURN_SWITCH_ALPHA

    elseif TURN == TURN_TYPE_GODOWN then
        local progress = 1 - ( TURN_SWITCH_TICK - tick ) / GODOWN_DURATION
        if progress > 1 then
            progress = 1

            TURN = false
            TURN_SWITCH_TICK = 0
            TURN_SWITCH_ALPHA = 0
            removeEventHandler( "onClientRender", root, RenderDamage )
        end

        ALPHA = interpolateBetween( TURN_SWITCH_ALPHA, 0, 0, 0, 0, 0, progress, "InOutQuad" )

    end
    dxDrawImage( px, py, sx, sy, "files/img/damage.png", 0, 0, 0, tocolor( 255, 0, 0, ALPHA ) )
end

-- Создание эффекта на экране
function DamageEffect( )
    removeEventHandler( "onClientRender", root, RenderDamage )
    addEventHandler( "onClientRender", root, RenderDamage )

    TURN = TURN_TYPE_SHOWUP
    TURN_SWITCH_TICK = getTickCount() + SHOWUP_DURATION
    TURN_SWITCH_ALPHA = ALPHA
end

-- Обработка попадания огнестрелом
function onClientPlayerDamage_handler( attacker, weapon, bodypart, loss )
    local tick = getTickCount()

    if DEATH_LAST_TIME and tick - DEATH_LAST_TIME <= 5000 then cancelEvent() return end
    if not attacker or attacker == localPlayer then return end
    if attacker:GetClanID() == localPlayer:GetClanID() then cancelEvent() return end
    
    local slot = weapon and getSlotFromWeapon( weapon )
    if not ( slot and DAMAGE_ALLOWED_SLOTS[ slot ] ) then return end

    if isTimer( DAMAGE_TIMER ) then killTimer( DAMAGE_TIMER ) end

    local time_left_to_end = DAMAGE_TICK and DAMAGE_TICK - tick
    if time_left_to_end and time_left_to_end > 0 then
        DAMAGE_TICK = DAMAGE_TICK + DAMAGE_ADD_TIME
    else
        DAMAGE_TICK = math.min( tick + DAMAGE_NEW_TIME )
    end

    if DAMAGE_TICK - tick > 2000 then
        DAMAGE_TICK = tick + 2000
    end
    local time_left = DAMAGE_TICK - tick

    for i, v in pairs( DAMAGE_CONTROLS_DISABLE ) do
        setControlState( v, false )
        toggleControl( v, false )
    end

    DAMAGE_TIMER = setTimer( onClientPlayerWasted_handler, math.max( 50, time_left ), 1 )

    DamageEffect( )
end

function onClientPlayerWasted_handler( )
    for i, v in pairs( DAMAGE_CONTROLS_DISABLE ) do
        toggleControl( v, true )
    end
end