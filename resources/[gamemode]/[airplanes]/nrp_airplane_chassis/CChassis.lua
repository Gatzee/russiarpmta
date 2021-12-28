toggleControl( "sub_mission", false )

bindKey( "h", "both", function ( )
    setControlState( "sub_mission", not getControlState( "sub_mission" ) )
end )

addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function ( _, seat )
    if seat ~= 0 then
        return
    end

    setControlState( "sub_mission", false )
end )