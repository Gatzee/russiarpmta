function RequestShowGunLicenseUI( state, source, ... )
	triggerEvent( "ShowGunLicenseUI", source, state, ... )
end
addEvent( "RequestShowGunLicenseUI", true )
addEventHandler( "RequestShowGunLicenseUI", root, onDocumentPreShow )