function ShowVehiclePassportUI( state, source, ... )
    triggerEvent( "onVehiclePassportShow", source, state, ... )
end

addEvent( "ShowVehiclePassportUI", true )
addEventHandler( "ShowVehiclePassportUI", root, onDocumentPreShow )