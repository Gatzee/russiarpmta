loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

TIMERS = { }

function StartPlayerGiftWait( player, id, data )
    local gift = GIFTS[ id ]
    if not gift then return end

    local gifts = player:GetPermanentData( "gifts" ) or { }
    local duration

    if not data then
        duration = gift.default_wait
        gifts[ id ] = { finish_time = getRealTime( ).timestamp + duration }
        player:SetPermanentData( "gifts", gifts )
    else
        duration = gifts[ id ].finish_time - getRealTime( ).timestamp
    end

    if duration and duration > 0 then
        TIMERS[ player ] = TIMERS[ player ] or { }
        if isTimer( TIMERS[ player ][ id ] ) then killTimer( TIMERS[ player ][ id ] ) end
        TIMERS[ player ][ id ] = setTimer( FinishPlayerGiftWait, duration * 1000, 1, player, id )

        if gift.onstart then
            if gift.onstart.server then
                gift.onstart.server( gift, player, gifts[ id ] )
            end
            if gift.onstart.client then
                triggerClientEvent( player, "onClientPlayerGiftStart", resourceRoot, id, gifts[ id ] )
            end
        end
    else
        FinishPlayerGiftWait( player, id )
    end
end
addEvent( "StartPlayerGiftWait" )
addEventHandler( "StartPlayerGiftWait", root, StartPlayerGiftWait )

function ClearPlayerGiftWait( player, id )
    local gifts = player:GetPermanentData( "gifts" ) or { }
    gifts[ id ] = nil
    player:SetPermanentData( "gifts", gifts )
end

function FinishPlayerGiftWait( player, id )
    if not isElement( player ) then return end
    local gift = GIFTS[ id ]
    if not gift then
        ClearPlayerGiftWait( player, id )
        return
    end

    local gifts = player:GetPermanentData( "gifts" ) or { }
    local data = gifts[ id ]

    if gift.ontimer then
        if gift.ontimer.server then
            gift.ontimer.server( gift, player, gifts[ id ] )
        end
        if gift.ontimer.client then
            triggerClientEvent( player, "onClientPlayerGiftFinishWait", resourceRoot, id, gifts[ id ] )
        end
    end
end

function GivePlayerGift( player, id )
    local player = player or client

    local gift = GIFTS[ id ]
    if not gift then
        ClearPlayerGiftWait( player, id )
        return
    end

    local gifts = player:GetPermanentData( "gifts" ) or { }
    local data = gifts[ id ]

    if not data then return end

    if gift.ondone then
        if gift.ondone.server then
            gift.ondone.server( gift, player, gifts[ id ] )
        end
        if gift.ondone.client then
            triggerClientEvent( player, "onClientPlayerGiftGiven", resourceRoot, id, gifts[ id ] )
        end
    end

    ClearPlayerGiftWait( player, id )
end
addEvent( "GivePlayerGift", true )
addEventHandler( "GivePlayerGift", root, GivePlayerGift )

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source

    local gifts = player:GetPermanentData( "gifts" ) or { }
    if next( gifts ) then
        for i, v in pairs( gifts ) do
            StartPlayerGiftWait( player, i, v )
        end
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function onResourceStart_handler( )
    setTimer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            onPlayerReadyToPlay_handler( v )
        end
    end, 2000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onPlayerPreLogout_handler( )
    if TIMERS[ source ] then
        for i, v in pairs( TIMERS[ source ] ) do
            if isTimer( TIMERS[ source ] ) then killTimer( TIMERS[ source ] ) end
        end
        TIMERS[ source ] = nil
    end
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )