loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

TIMERS = { }
CONST_TICK_FREQ = 60

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source

    onPlayerPreLogout_handler( player )

    TIMERS[ player ] = setTimer( TickTimer, CONST_TICK_FREQ * 1000, 0, player )
    triggerEvent( "onPlayerPlaytimeUpdate", player, player:GetPermanentData( "playing_time" ) )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function onResourceStart_handler()
    for i, v in pairs( getElementsByType( "player" ) ) do
        if v:IsInGame() then
            onPlayerCompleteLogin_handler( v )
        end
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function TickTimer( player )
    if not isElement( player ) then
        if isTimer( TIMERS[ player ] ) then killTimer( TIMERS[ player ] ) end
        TIMERS[ player ] = nil
        return
    end

    local new_playtime = ( player:GetPermanentData( "playing_time" ) or 0 ) + CONST_TICK_FREQ
    player:SetPermanentData( "playing_time", new_playtime )

    triggerEvent( "onPlayerPlaytimeUpdate", player, new_playtime )
end

function onPlayerPreLogout_handler( player )
    local player = isElement( player ) and player or source

    if isTimer( TIMERS[ player ] ) then killTimer( TIMERS[ player ] ) end
    TIMERS[ player ] = nil
    triggerEvent( "onPlayerPlaytimeUpdate", player, nil )
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )