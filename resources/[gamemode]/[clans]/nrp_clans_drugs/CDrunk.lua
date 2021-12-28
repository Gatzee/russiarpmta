loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "Globals" )

local DRUNK_TIMER

function SetDrunk( alco_quality, duration )
    if isTimer( DRUNK_TIMER ) then
        localPlayer:ShowError( "Куда столько-то" )
        return
    end

    local alco_conf = ALCOHOLS[ alco_quality ]
    localPlayer:SetBuff( "max_health", alco_conf.add_health, "alco" )

    DRUNK_TIMER = setTimer( onDrunkTimerExpired, ( duration or alco_conf.duration ) * 1000, 1 )

    return true
end

function onDrunkTimerExpired( )
    localPlayer:SetBuff( "max_health", nil, "alco" )
    DRUNK_TIMER[ player ] = nil
end

addEvent( "SyncDrunkState", true )
addEventHandler( "SyncDrunkState", resourceRoot, SetDrunk )