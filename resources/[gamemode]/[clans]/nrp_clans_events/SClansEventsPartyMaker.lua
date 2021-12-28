EVENTS_REGISTERED_CLANS = { }
REGISTERED_PLAYERS_DATA = { }
PREPARATION_LOBBIES_BY_CLAN_ID = { }

addEventHandler( "onResourceStart", resourceRoot, function( )
	for event_id in pairs( CLAN_EVENT_CONFIG ) do
		EVENTS_REGISTERED_CLANS[ event_id ] = { }
	end
end )

function onPlayerWantRegisterOnClanEvent_handler( event_id, lobby_id )
	local player = client or source

	if not player:CanJoinToEventLobby( ) then
		return
	end
	
	local clan_id = player:GetClanID( )
	local players = EVENTS_REGISTERED_CLANS[ event_id ][ clan_id ]
	if not players then
		players = { }
		EVENTS_REGISTERED_CLANS[ event_id ][ clan_id ] = players
	end

	if CallClanFunction( clan_id, "IsMoneyLocked" ) then
		player:ShowError( "Вы не можете участвовать в войне кланов, пока ваш общак заблокирован на время уплаты налога картелю!" )
		return
	end

	local event_conf = CLAN_EVENT_CONFIG[ event_id ]

	if event_conf.rewards and GetClanMoney( clan_id ) < ( event_conf.rewards.clan_money or 0 ) then
		player:ShowError( "Недостаточно денег в общаке клана, необходимо 5 000р." )
		return
	end

	if event_conf.rewards and GetClanHonor( clan_id ) < ( event_conf.rewards.clan_honor or 0 ) then
		player:ShowError( "Недостаточно очков чести у вашего клана, необходимо " .. event_conf.rewards.clan_honor )
		return
	end
	
	if #players >= event_conf.players_count_per_clan then
		player:ShowError( "Необходимое количество игроков из вашего клана уже набрано" )
		return
	end
	
	table.insert( players, player )
	REGISTERED_PLAYERS_DATA[ player ] = {
		event_id = event_id,
		clan_id = clan_id,
		team_players = players,
		date = os.time( ),
	}
	player:setData( "last_reg_in_clan_event", os.time( ), false )
	player:setData( "registered_in_clan_event", true, false )

	triggerClientEvent( players, "CEV:OnClientUpdatePhoneUI", player, event_id, #players )

	addEventHandler( "onPlayerLeaveClan", player, onPlayerWantCancelRegisterOnClanEvent_handler )
	addEventHandler( "onPlayerPreLogout", player, onPlayerWantCancelRegisterOnClanEvent_handler )
	addEventHandler( "onPlayerWasted", player, onPlayerWantCancelRegisterOnClanEvent_handler )

	if #players >= event_conf.players_count_per_clan then
		-- find enemy team
		local registered_clans = EVENTS_REGISTERED_CLANS[ event_id ]
		for other_clan_id, other_players in pairs( registered_clans ) do
			if clan_id ~= other_clan_id and #other_players >= event_conf.players_count_per_clan then
				if event_conf.rewards and GetClanMoney( other_clan_id ) < ( event_conf.rewards.clan_money or 0 ) then
					for i, player in pairs( other_players ) do
						player:ShowError( "Недостаточно денег в общаке клана для участия в войне кланов, необходимо 5 000р." )
					end
				else
					local lobby = CreateLobby( event_id )
					for i, player in pairs( players ) do
						player:ClearRegisterData( )
						lobby:OnPlayerJoin( player )
					end
					for i, player in pairs( other_players ) do
						player:ClearRegisterData( )
						lobby:OnPlayerJoin( player )
					end
					lobby:OnCreated( )
					registered_clans[ clan_id ] = nil
					registered_clans[ other_clan_id ] = nil
				end
			end
		end
	end
end
addEvent( "onPlayerWantRegisterOnClanEvent", true )
addEventHandler( "onPlayerWantRegisterOnClanEvent", root, onPlayerWantRegisterOnClanEvent_handler )

Player.ClearRegisterData = function( player )
	REGISTERED_PLAYERS_DATA[ player ] = nil
	player:setData( "registered_in_clan_event", false, false )

	removeEventHandler( "onPlayerLeaveClan", player, onPlayerWantCancelRegisterOnClanEvent_handler )
	removeEventHandler( "onPlayerPreLogout", player, onPlayerWantCancelRegisterOnClanEvent_handler )
	removeEventHandler( "onPlayerWasted", player, onPlayerWantCancelRegisterOnClanEvent_handler )
end

function onPlayerWantCancelRegisterOnClanEvent_handler( )
	local player = client or source
	local data = REGISTERED_PLAYERS_DATA[ player ]
	if not data then return end

	local players = data.team_players
	if not players then return end

	for i = 1, #players do
		if players[ i ] == player then
			table.remove( players, i )
			break
		end
	end
	player:ClearRegisterData( )

	if #players > 0 then
		triggerClientEvent( players, "CEV:OnClientUpdatePhoneUI", resourceRoot, data.event_id, #players )
	else
		EVENTS_REGISTERED_CLANS[ data.event_id ][ data.clan_id ] = nil
	end
	if eventName ~= "onPlayerPreLogout" then
		triggerClientEvent( player, "CEV:OnClientUpdatePhoneUI", player, false )
		if eventName ~= "onPlayerWasted" then
			player:SetPermanentData( "clan_event_reg_cancels", ( player:GetPermanentData( "clan_event_reg_cancels" ) or 0 ) + 1 )
		end
	end
end
addEvent( "onPlayerWantCancelRegisterOnClanEvent", true )
addEventHandler( "onPlayerWantCancelRegisterOnClanEvent", root, onPlayerWantCancelRegisterOnClanEvent_handler )

function onResourceStop_handler( )
	local players = { }
	for player in pairs( REGISTERED_PLAYERS_DATA ) do
		player:setData( "registered_in_clan_event", false, false )
		table.insert( players, player )
	end
	triggerClientEvent( players, "CEV:OnClientUpdatePhoneUI", resourceRoot, false )
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )



if SERVER_NUMBER > 100 then

	addCommandHandler( "creatematch", function( player, cmd, user_id )
		local clan_id = player:GetClanID( )

		local reg_data = REGISTERED_PLAYERS_DATA[ player ]
		if not reg_data then
			outputConsole( "ОШИБКА: Вы не зареганы на участие" )
			return
		end

		local event_id = reg_data.event_id

		if user_id and user_id ~= "" then
			local other_player = GetPlayer( tonumber( user_id ) )
			if not other_player then
				outputConsole( "ОШИБКА: Игрок с таким user_id не найден" )
				return
			end
			if other_player:GetClanID( ) == clan_id then
				outputConsole( "ОШИБКА: Этот игрок должен быть в другом клане" )
				return
			end
			triggerEvent( "onPlayerWantRegisterOnClanEvent", other_player, event_id )
		end

		local players = EVENTS_REGISTERED_CLANS[ event_id ][ clan_id ]
		local event_conf = CLAN_EVENT_CONFIG[ event_id ]
		local registered_clans = EVENTS_REGISTERED_CLANS[ event_id ]

		for other_clan_id, other_players in pairs( registered_clans ) do
			if clan_id ~= other_clan_id then
				local lobby = CreateLobby( event_id )
				for i, player in pairs( players ) do
					player:ClearRegisterData( )
					lobby:OnPlayerJoin( player )
				end
				registered_clans[ clan_id ] = nil
				for i, player in pairs( other_players ) do
					player:ClearRegisterData( )
					lobby:OnPlayerJoin( player )
				end
				registered_clans[ other_clan_id ] = nil

				lobby:OnCreated( )
				return
			end
		end

		outputConsole( "ОШИБКА: Другой клан не зареган для участия" )
	end )

end