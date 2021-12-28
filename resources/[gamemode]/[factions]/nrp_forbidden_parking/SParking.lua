loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "SPlayer" )

addEvent( "onServerPlayerLeftVehicleInForbiddenZone", true )
addEventHandler("onServerPlayerLeftVehicleInForbiddenZone", root, function ()
    client:AddFine( 11 )
end )




