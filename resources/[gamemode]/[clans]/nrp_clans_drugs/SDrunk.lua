loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

local DRUNK_TIMER = { }

function SetDrunk( player, alco_quality, duration )
    local alco_conf = ALCOHOLS[ alco_quality ]
    player:SetBuff( "max_health", alco_conf.add_health, "alco" )

    if DRUNK_TIMER[ player ] then DRUNK_TIMER[ player ]:destroy( ) end
    DRUNK_TIMER[ player ] = setTimer( onDrunkTimerExpired, ( duration or alco_conf.duration ) * 1000, 1, player )

    if not duration then
        player:SetPermanentData( "drunk_data", {
            alco_quality = alco_quality,
            finish_ts = getRealTimestamp( ) + alco_conf.duration,
        } )
    end
end

function onDrunkTimerExpired( player )
    player:SetBuff( "max_health", nil, "alco" )
    DRUNK_TIMER[ player ] = nil
end

addEvent( "onPlayerCompleteLogin" )
addEventHandler( "onPlayerCompleteLogin", root, function( )
    local player = source
    local drunk_data = player:GetPermanentData( "drunk_data" )
    if drunk_data then
        local remaining_time = drunk_data.finish_ts - getRealTimestamp( )
        if remaining_time > 0 then
            SetDrunk( player, drunk_data.alco_quality, remaining_time )
            triggerClientEvent( player, "SyncDrunkState", resourceRoot, drunk_data.alco_quality, remaining_time )
        else
            player:SetPermanentData( "drunk_data", nil )
        end
    end
end )

addEventHandler( "onPlayerPreLogout", root, function( )
    local player = source
    if DRUNK_TIMER[ player ] then
        DRUNK_TIMER[ player ]:destroy( )
        DRUNK_TIMER[ player ] = nil
    end
end )