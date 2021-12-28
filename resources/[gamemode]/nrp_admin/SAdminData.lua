local ADMIN_DATA = { }

Player.GetAdminData = function( self, key )
	return ( ADMIN_DATA[ self ] or { } )[ key ]
end

Player.SetAdminData = function( self, key, value )
	ADMIN_DATA[ self ][ key ] = value
	self:SetPermanentData( "admin_data", ADMIN_DATA[ self ] )
end

function onPlayerCompleteLogin_dataHandler( player )
    local player = isElement( player ) and player or source
    ADMIN_DATA[ player ] = player:GetPermanentData( "admin_data" ) or { }
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_dataHandler, true, "high+100" )

function onResourceStart_dataHandler()
    for i, v in pairs( GetPlayersInGame( ) ) do
        onPlayerCompleteLogin_dataHandler( v )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_dataHandler, true, "high+100" )

function onPlayerPreLogout_dataHandler( )
    ADMIN_DATA[ source ] = nil
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_dataHandler, true, "low-100" )