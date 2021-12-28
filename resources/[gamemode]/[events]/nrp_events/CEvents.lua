Extend( "CPlayer" )
Extend( "CInterior" )

CURRENT_EVENT_LOBBY_ID = 0
CURRENT_EVENT_ID = nil

function OnPlayerStartEvent_handler( event_id, lobby_id, players, vehicles )
	if not REGISTERED_EVENTS[ event_id ] then return end

	CURRENT_EVENT_ID = event_id
	CURRENT_EVENT_LOBBY_ID = lobby_id

	triggerEvent( "ShowPhoneUI", localPlayer, false )

	REGISTERED_EVENTS[ event_id ].Setup_C_handler( players, vehicles )

	if REGISTERED_EVENTS[ event_id ].scoreboard_text_point then
		CreateScoreboard( REGISTERED_EVENTS[ event_id ].scoreboard_text_point, players, REGISTERED_EVENTS[ event_id ].count_markers )
	end

	triggerEvent( "SwitchRadioEnabled", root, true )
	triggerServerEvent( "PlayerClientEventReady", resourceRoot )

	triggerEvent( "ShowUIInventory", root, false )
	StartDetectPlayerEventAFK( )

	localPlayer:setData( "is_on_event", event_id, false )
	localPlayer:setData( "block_inventory", true, false )

	addEventHandler( "onClientRender", root, DetectPlayerActions )
end
addEvent( "OnPlayerStartEvent", true )
addEventHandler( "OnPlayerStartEvent", resourceRoot, OnPlayerStartEvent_handler )


function OnPlayerExitEvent_handler( player, event_id )
	if not CURRENT_EVENT_ID then return end
	if CURRENT_EVENT_ID ~= event_id then return end
	if not REGISTERED_EVENTS[ CURRENT_EVENT_ID ] then return end

	if player == localPlayer then
		triggerEvent( "SwitchRadioEnabled", root, false )
		triggerEvent( "SwitchRadioEnabled", root, true )
		StopDetectPlayerEventAFK( )
		
		localPlayer:setData( "is_on_event", false, false )
		localPlayer:setData( "block_inventory", false, false )

		DestroyTableElements( UIe )

		REGISTERED_EVENTS[ CURRENT_EVENT_ID ].Cleanup_C_handler( )
	else
		UpdateScoreboard( player )
	end

	removeEventHandler( "onClientRender", root, DetectPlayerActions )
end
addEvent( "OnPlayerExitEvent", true )
addEventHandler( "OnPlayerExitEvent", resourceRoot, OnPlayerExitEvent_handler )


function GetEventListByGroup( group )
	local events = { }
	for id, info in pairs( REGISTERED_EVENTS ) do
		local insert = false
		if group then
			insert = info.group and info.group == group

		elseif group == false then
			insert = not info.group

		else
			insert = true
		end

		if insert then
			table.insert( events, {
				id = id;
				name = info.name;
			} )
		end
	end

	return events
end


local AFK_CHECKER_TIMER = nil
local AFK_KICK_TIMER = nil
local AFK_LAST_TICK_KEY_PRESS = 0
local AFK_KEY_PRESS_TIME = 30 * 1000
local AFK_TIME_TO_KICK_UI = 10
local AFK_DETECT_KEY_LIST = {
	w = true,
	a = true,
	s = true,
	d = true,
	space = true,
	mouse1 = true,
	mouse2 = true,
}

function StartDetectPlayerEventAFK( )
	addEventHandler( "onClientKey", root, onClientKey_handler )

	AFK_LAST_TICK_KEY_PRESS = getTickCount( )

	AFK_CHECKER_TIMER = Timer( function( )
		if isTimer( AFK_KICK_TIMER ) then return end

		if ( getTickCount( ) - AFK_LAST_TICK_KEY_PRESS ) > AFK_KEY_PRESS_TIME then
			CreateUIZoneExit( AFK_TIME_TO_KICK_UI )

			AFK_KICK_TIMER = Timer( function( )
				killTimer( AFK_CHECKER_TIMER )
				triggerServerEvent( "PlayerQuitAfk", resourceRoot )
				localPlayer:InfoWindow( "Исключен за бездействие" )

				triggerEvent( "OnClientReceivePhoneNotification", root, {
					title = "Майский ивент",
					msg = "Ты был исключен за бездействие",
				} )
			end, AFK_TIME_TO_KICK_UI * 1000, 1 )
		end
	end, 1000, 0 )
end

function StopDetectPlayerEventAFK( )
	removeEventHandler( "onClientKey", root, onClientKey_handler )

	if isTimer( AFK_CHECKER_TIMER ) then
		killTimer( AFK_CHECKER_TIMER )
	end

	if isTimer( AFK_KICK_TIMER ) then
		killTimer( AFK_KICK_TIMER )
	end
end

function onClientKey_handler( button, pressOrRelease )
	local disabled_keys = { p = true, tab = true, m = true, t = true }
	if disabled_keys[ button ] then
		cancelEvent()
	elseif tonumber( button ) then
		cancelEvent()
	end


	if not AFK_DETECT_KEY_LIST[ button ] then return end

	if isTimer( AFK_KICK_TIMER ) then
		killTimer( AFK_KICK_TIMER )
		DeleteUIZoneExit( )
	end

	AFK_LAST_TICK_KEY_PRESS = getTickCount( )
end