SWITCH_TIMEOUT = 120
SWITCH_DURATION = 5

STATE_ENABLED = 1
STATE_DISABLED = 2

function onClientPlayerEnableNodamage_handler( time_nodamage_ends )
    if not _MODULES_LOADED then
        loadstring( exports.interfacer:extend( "Interfacer" ) )( )
        Extend( "ib" )
        Extend( "CPlayer" )
        Extend( "ShUtils" )
        _MODULES_LOADED = true
    end

    local ts = getRealTimestamp( )

    if time_nodamage_ends - ts <= 0 then return end

    DURATION_LEFT = time_nodamage_ends - ts

    bindKey( "n", "both", SwitchKeyController )
    triggerEvent( "onNodamageStart", localPlayer )
    SetEnabled( )

    DISABLE_TIMER = setTimer( onClientPlayerDisableNodamage_handler, DURATION_LEFT * 1000, 1 )
end
addEvent( "onClientPlayerEnableNodamage", true )
addEventHandler( "onClientPlayerEnableNodamage", root, onClientPlayerEnableNodamage_handler )

function SetEnabled( )
    CURRENT_STATE = STATE_ENABLED
    Enable( )
    UpdateState( { style = "keyhelp", key = "N", main_text = "Защита от игроков на 1 час", text = "Чтобы снять защиту, зажми" } )
end

function SetDisabled( )
    Disable( )
    CURRENT_STATE = STATE_DISABLED
    SWITCHON_LAST_TICK = getTickCount( )
    UpdateState( { style = "timeout", main_text = "Защита отключена", text = "Можно включить через", timeout_duration = SWITCH_TIMEOUT } )

    HOLD_TIMER = setTimer( function( )
        SWITCHON_LAST_TICK = nil
        UpdateState( { style = "keyhelp", key = "N", main_text = "Защита отключена", text = "Чтобы включить защиту, зажми" } )
    end, SWITCH_TIMEOUT * 1000, 1 )
end

function onClientPlayerDisableNodamage_handler( )
    Disable( )
    unbindKey( "n", "both", SwitchKeyController )

    DURATION_LEFT = nil
    CURRENT_STATE = nil
    if isTimer( HOLD_TIMER ) then killTimer( HOLD_TIMER ) end
    if isTimer( DISABLE_TIMER ) then killTimer( DISABLE_TIMER ) end

    triggerEvent( "onNodamageStop", localPlayer )
end
addEvent( "onClientPlayerDisableNodamage", true )
addEventHandler( "onClientPlayerDisableNodamage", root, onClientPlayerDisableNodamage_handler )

function SwitchKeyController( key, state )
    if CURRENT_STATE == STATE_DISABLED then
        -- Начинать полосу
        if state == "down" then
            if SWITCHON_LAST_TICK and getTickCount( ) - SWITCHON_LAST_TICK <= SWITCH_TIMEOUT * 1000 then return end

            KEY_STATE_PRESSED_DOWN = true

            HOLD_TIMER = setTimer( function( )
                if isTimer( HOLD_TIMER ) then killTimer( HOLD_TIMER ) end
                SwitchKeyController( key, state == "down" and "up" or "down" )
            end, SWITCH_DURATION * 1000, 1 )

            UpdateState( { style = "progress", from = 0, to = 1, duration = SWITCH_DURATION * 1000, text = "Защита включается..." } )
        -- Заканчивать полосу и решать переключать или нет
        elseif state == "up" then
            if not KEY_STATE_PRESSED_DOWN then return end

            KEY_STATE_PRESSED_DOWN = nil
            if isTimer( HOLD_TIMER ) then
                killTimer( HOLD_TIMER )
                HOLD_TIMER = nil
                UpdateState( { style = "keyhelp", key = "N", main_text = "Защита отключена", text = "Чтобы включить защиту, зажми" } )
            else
                SetEnabled( )
            end
        end
    elseif CURRENT_STATE == STATE_ENABLED then
        -- Начинать полосу
        if state == "down" then
            KEY_STATE_PRESSED_DOWN = true

            HOLD_TIMER = setTimer( function( )
                if isTimer( HOLD_TIMER ) then killTimer( HOLD_TIMER ) end
                SwitchKeyController( key, state == "down" and "up" or "down" )
            end, SWITCH_DURATION * 1000, 1 )
            UpdateState( { style = "progress", from = 1, to = 0, duration = SWITCH_DURATION * 1000, text = "Защита отключается..." } )
        -- Заканчивать полосу и решать переключать или нет
        elseif state == "up" then
            if not KEY_STATE_PRESSED_DOWN then return end

            KEY_STATE_PRESSED_DOWN = nil
            if isTimer( HOLD_TIMER ) then
                killTimer( HOLD_TIMER )
                HOLD_TIMER = nil
                UpdateState( { style = "keyhelp", key = "N", main_text = "Защита от игроков на 1 час", text = "Чтобы снять защиту, зажми" } )
            else
                SetDisabled( )
            end
        end
    end
end

function UpdateState( data )
    triggerEvent( "onNodamageUpdateState", localPlayer, data )
end

function CheckHandlePlayer( )
    return localPlayer.dimension <= 1 and localPlayer.interior <= 1
end

function HandleDamage( attacker, loss )
    if isElement( attacker ) and getElementType( attacker ) == "player" and attacker ~= localPlayer and CheckHandlePlayer( ) then
        cancelEvent( )
    end
end

function HandleFight( key, state )
    if not CheckHandlePlayer( ) or localPlayer:getData( "photo_mode" ) then return end

    local fight_controls = { "fire" }
    local blocked_keys = { }
    for i, v in pairs( fight_controls ) do
        local keys = getBoundKeys( v )
        for n, t in pairs( keys ) do
            blocked_keys[ n ] = true
        end
    end

    if blocked_keys[ key ] then cancelEvent( ) end
end

function Enable( )
    Disable( )

    addEventHandler( "onClientPlayerDamage", localPlayer, HandleDamage )
    addEventHandler( "onClientKey", root, HandleFight )
end

function Disable( )
    removeEventHandler( "onClientPlayerDamage", localPlayer, HandleDamage )
    removeEventHandler( "onClientKey", root, HandleFight )
end