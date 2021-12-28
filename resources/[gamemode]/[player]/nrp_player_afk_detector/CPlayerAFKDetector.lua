local AFK_CHECK_INTERVAL = 1 * 1000

local IS_AFK = localPlayer:getData( "afk_start_tick" ) and true
local LAST_ACTIVITY_TICK = 0

function SetAFKState( state )
	triggerServerEvent( "onPlayerAFKStateChange", localPlayer, state )
	localPlayer:setData( "afk_start_tick", state and LAST_ACTIVITY_TICK, false )
	IS_AFK = state
end

function CheckAFK( )
	if not IS_AFK and getTickCount( ) - LAST_ACTIVITY_TICK >= AFK_THRESHOLD then
		SetAFKState( true )
	end
end

function onClientKey_handler( key, state )
	if IS_AFK then
		SetAFKState( false )
	end
	
	LAST_ACTIVITY_TICK = getTickCount( )
end

function onClientResourceStart_handler( )
	LAST_ACTIVITY_TICK = getTickCount( )
	setTimer( CheckAFK, AFK_CHECK_INTERVAL, 0 )
	addEventHandler( "onClientKey", root, onClientKey_handler )
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )