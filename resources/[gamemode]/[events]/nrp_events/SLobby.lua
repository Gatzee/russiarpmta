CONST_TIME_TO_EVENT_APPLY = 45

EVENTS_REGISTERED_PLAYERS = { }
EVENTS_PLAYERS_PRIORITY = { }
EVENTS_LOBBY = { }
EVENTS_LOBBY_REGISTERED_PLAYERS = { }

function RegisterPlayerOnEvent( player, event_id )
	if not REGISTERED_EVENTS[ event_id ] then return end

	EVENTS_REGISTERED_PLAYERS[ player ] = event_id
	player:SetPrivateData( "event_id", event_id )

	if not EVENTS_PLAYERS_PRIORITY[ event_id ] then
		EVENTS_PLAYERS_PRIORITY[ event_id ] = { }
	end

	table.insert( EVENTS_PLAYERS_PRIORITY[ event_id ], {
		player = player;
		priority = 0;
	} )

	local event_lobby_data = {
		players = #EVENTS_PLAYERS_PRIORITY[ event_id ];
		max_players = REGISTERED_EVENTS[ event_id ].count_players;
		start = getRealTimestamp( );
	}
	player:SetPrivateData( "event_lobby_data", event_lobby_data )

	for i, data in pairs( EVENTS_PLAYERS_PRIORITY[ event_id ] ) do
		if isElement( data.player ) then
			local player_event_lobby_data = data.player:getData( "event_lobby_data" )
			if player_event_lobby_data then
				player_event_lobby_data.players = event_lobby_data.players
				data.player:SetPrivateData( "event_lobby_data", player_event_lobby_data )
				triggerClientEvent( data.player, "onEventsUpdatePhoneListCallback", root )
			end
		end
	end

	addEventHandler( "onPlayerQuit", player, onPlayerQuit_EventRegistered_handler )

	PreStartLobby( event_id )
end

function PlayerWantRegisterOnEvent_handler( event_id )
	if not client then return end
	if not REGISTERED_EVENTS[ event_id ] then return end

	if EVENTS_REGISTERED_PLAYERS[ client ] then
		client:ShowError( "Ты уже зарегистрировался на эвент" )
		return
	end

	if EVENTS_LOBBY_REGISTERED_PLAYERS[ client ] then
		client:ShowError( "Твоё лобби уже собрано на другом эвенте" )
		return
	end

	local msg_err = CheckPlayerCanEnterOnEvent( client, event_id )
	if msg_err then
		client:ShowError( msg_err )
		return
	end

	RegisterPlayerOnEvent( client, event_id )

	triggerClientEvent( client, "onEventsUpdatePhoneListCallback", root )
end
addEvent( "PlayerWantRegisterOnEvent", true )
addEventHandler( "PlayerWantRegisterOnEvent", root, PlayerWantRegisterOnEvent_handler )

function PlayerWantCancelRegisterOnEvent_handler( event_id )
	if not client then return end

	local event_id = EVENTS_REGISTERED_PLAYERS[ client ]
	if not event_id then return end
	if not REGISTERED_EVENTS[ event_id ] then return end

	if EVENTS_LOBBY_REGISTERED_PLAYERS[ client ] then
		client:ShowError( "Твоё лобби уже собрано" )
		return
	end

	RemovePlayerFromEventRegistration( client )

	triggerClientEvent( client, "onEventsUpdatePhoneListCallback", root )
end
addEvent( "PlayerWantCancelRegisterOnEvent", true )
addEventHandler( "PlayerWantCancelRegisterOnEvent", root, PlayerWantCancelRegisterOnEvent_handler )

function CheckPlayerCanEnterOnEvent( player, event_id )
	local state, reason = player:CanJoinToEvent({ event_type = "nrp_events_" .. event_id  })
	if not state then
		return reason
	end

	if player.health < 50 or player:getData( "_healing" ) then
		return "Для начала подлечись"
	end

	local events_timeout = player:GetPermanentData( "events_timeout" ) or { }
	if events_timeout[ event_id ] and events_timeout[ event_id ] > getRealTimestamp( ) then
		return "Подожди ".. getHumanTimeString( events_timeout[ event_id ], true ) .." прежде чем начать этот эвент снова"
	end
end

function onPlayerQuit_EventRegistered_handler( )
	RemovePlayerFromEventRegistration( source )
end

function RemovePlayerFromEventRegistration( player )
	local event_id = EVENTS_REGISTERED_PLAYERS[ player ]
	if not event_id then return end
	if not EVENTS_PLAYERS_PRIORITY[ event_id ] then return end

	EVENTS_REGISTERED_PLAYERS[ player ] = nil
	player:SetPrivateData( "event_id", nil )
	player:SetPrivateData( "event_lobby_data", nil )

	triggerClientEvent( player, "onEventsUpdatePhoneListCallback", root )

	for i, info in pairs( EVENTS_PLAYERS_PRIORITY[ event_id ] ) do
		if info.player == player then
			table.remove( EVENTS_PLAYERS_PRIORITY[ event_id ], i )
			break
		end
	end

	if EVENTS_LOBBY_REGISTERED_PLAYERS[ player ] then
		EVENTS_LOBBY_REGISTERED_PLAYERS[ player ] = nil
		player:SetPrivateData( "lobby_id", nil )
	end

	removeEventHandler( "onPlayerQuit", player, onPlayerQuit_EventRegistered_handler )

	return true
end

function PreStartLobby( event_id )
	local events_players_priority = EVENTS_PLAYERS_PRIORITY[ event_id ]
	if #events_players_priority >= REGISTERED_EVENTS[ event_id ].count_players then
		table.sort( events_players_priority, function( a, b )
			return a.priority > b.priority
		end )

		local players = { }
		for i = 1, REGISTERED_EVENTS[ event_id ].count_players do
			local player = events_players_priority[ 1 ].player
			players[ player ] = false
			table.remove( events_players_priority, 1 )
		end

		StartLobby( event_id, players )
	end
end

function StartLobby( event_id, players )
	local lobby_id = getTickCount( )
	EVENTS_LOBBY[ lobby_id ] = {
		lobby_id = lobby_id;
		event_id = event_id;
		players = players;

		func_PreStartEvent = function( self )
			local not_ready_players = { }
			for player, ready in pairs( self.players ) do
				if not isElement( player ) or not ready or CheckPlayerCanEnterOnEvent( player, event_id ) then
					not_ready_players[ player ] = true
				end
			end

			if next( not_ready_players ) then
				StopLobby( self.lobby_id, not_ready_players )
			else
				for player in pairs( self.players ) do
					triggerClientEvent( player, "OnEventsNotificationExpired", player )

					EVENTS_REGISTERED_PLAYERS[ player ] = nil
					player:SetPrivateData( "event_id", nil )
					player:SetPrivateData( "event_lobby_data", nil )

					EVENTS_LOBBY_REGISTERED_PLAYERS[ player ] = nil
					player:SetPrivateData( "lobby_id", nil )

					removeEventHandler( "onPlayerQuit", player, onPlayerQuit_EventRegistered_handler )
					triggerClientEvent( player, "onEventsUpdatePhoneListCallback", root )
				end

				StartEvent( self.event_id, self.lobby_id, self.players )
				EVENTS_LOBBY[ self.lobby_id ] = nil
			end
		end
	}

	EVENTS_LOBBY[ lobby_id ].timer = Timer( function( lobby_id )
		EVENTS_LOBBY[ lobby_id ]:func_PreStartEvent()
	end, CONST_TIME_TO_EVENT_APPLY * 1000, 1, lobby_id )

	for player in pairs( players ) do
		EVENTS_LOBBY_REGISTERED_PLAYERS[ player ] = lobby_id
		player:SetPrivateData( "lobby_id", lobby_id )

		player:PhoneNotification( {
			title = "Лобби собрано",
			special = "events_lobby_created",
			args = {
				timeout = getRealTimestamp( ) + CONST_TIME_TO_EVENT_APPLY;
			}
		} )

		local event_lobby_data = {
			players = 0;
			max_players = REGISTERED_EVENTS[ event_id ].count_players;
			start = getRealTimestamp( ) + CONST_TIME_TO_EVENT_APPLY;
			not_ready = true;
		}
		player:SetPrivateData( "event_lobby_data", event_lobby_data )

		triggerClientEvent( player, "onEventsUpdatePhoneListCallback", root )
	end
end

function LobbyPlayerReady( )
	if not client then return end

	local lobby_id = EVENTS_LOBBY_REGISTERED_PLAYERS[ client ]
	if not lobby_id then return end

	local lobby = EVENTS_LOBBY[ lobby_id ]
	if not lobby then return end

	local msg_err = CheckPlayerCanEnterOnEvent( client, lobby.event_id )
	if msg_err then
		client:ShowError( msg_err )
		return
	end

	lobby.players[ client ] = true
	triggerClientEvent( client, "OnEventsNotificationExpired", client )

	local count_players_ready = 0
	for player, ready in pairs( lobby.players ) do
		if ready then
			count_players_ready = count_players_ready + 1
		end
	end

	for player, ready in pairs( lobby.players ) do
		if isElement( player ) then
			local player_event_lobby_data = player:getData( "event_lobby_data" )
			if player_event_lobby_data then
				player_event_lobby_data.players = count_players_ready
				if player == client then
					player_event_lobby_data.not_ready = nil
				end
				player:SetPrivateData( "event_lobby_data", player_event_lobby_data )
				triggerClientEvent( player, "onEventsUpdatePhoneListCallback", root )
			end
		end
	end

	local all_ready = true
	for player, ready in pairs( lobby.players ) do
		if not isElement( player ) or not ready then
			all_ready = false
			return
		end
	end

	if all_ready then
		if not isTimer( lobby.timer ) then return end

		killTimer( lobby.timer )
		lobby:func_PreStartEvent( )
	end
end
addEvent( "LobbyEventPlayerReady", true )
addEventHandler( "LobbyEventPlayerReady", root, LobbyPlayerReady )

function StopLobby( lobby_id, not_ready_players )
	local lobby = EVENTS_LOBBY[ lobby_id ]
	if not lobby then return end

	if isTimer( lobby.timer ) then
		killTimer( lobby.timer )
	end

	for player, ready in pairs( lobby.players ) do
		if isElement( player ) then
			triggerClientEvent( player, "OnEventsNotificationExpired", player )

			EVENTS_LOBBY_REGISTERED_PLAYERS[ player ] = nil
			player:SetPrivateData( "lobby_id", nil )

			table.insert( EVENTS_PLAYERS_PRIORITY[ lobby.event_id ], {
				player = player;
				priority = not_ready_players[ player ] and -1 or 1;
			} )

			local msg_err = CheckPlayerCanEnterOnEvent( player, lobby.event_id )
			if not_ready_players[ player ] or msg_err then
				RemovePlayerFromEventRegistration( player )

				if msg_err then
					player:ShowError( "Удален из лобби: ".. msg_err )
				else
					player:ShowError( "Удален из лобби: Ты не принял приглашение" )
				end
			else
				player:ShowError( "Не все участники приняли приглашение. Приоритет очереди повышен!" )
			end
		end
	end

	EVENTS_LOBBY[ lobby_id ] = nil

	Timer( function( )
		PreStartLobby( lobby.event_id )
	end, 3000, 1 )
end

addEventHandler( "onResourceStop", resourceRoot, function( )
	for player in pairs( EVENTS_REGISTERED_PLAYERS ) do
		player:SetPrivateData( "event_id", nil )
		player:SetPrivateData( "event_lobby_data", nil )
	end

	for player in pairs( EVENTS_LOBBY_REGISTERED_PLAYERS ) do
		player:SetPrivateData( "lobby_id", nil )
	end
end )