function onPlayerAFKStateChange_handler( state )
	source:setData( "afk_start_tick", state and getTickCount( ) - AFK_THRESHOLD, false )
end
addEvent( "onPlayerAFKStateChange", true )
addEventHandler( "onPlayerAFKStateChange", root, onPlayerAFKStateChange_handler )