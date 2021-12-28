loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "ShTimelib" )
Extend( "SClans" )

LOBBIES_BY_ID = { }
LAST_ID = 0
BUSY_DIMENSIONS = { }

PLAYER_LOBBY = { }
PLAYER_WEAPONS = { }

function CreateLobby( event_id, teams_clans )
	local self = { }

	self.id = LAST_ID + 1
	self.event_id = event_id
	self.state = LOBBY_STATE_PREPARATION
	self.conf = CLAN_EVENT_CONFIG[ event_id ]
	self.participants = { }
	self.participants_data = { }
	self.teams = { }
	self.players_teams = { }
	self.clans_players = { }
	self.team_by_clan_id = { }

	self.analytics_data = {
		clans = { }
	}

	if teams_clans then
		for i, clan_id in pairs( teams_clans ) do
			self.clans_players[ clan_id ] = { }
			local team = {
				clan_id = clan_id,
				players = self.clans_players[ clan_id ],
				kills = 0,
				deaths = 0,
				outmap_deaths = 0,
			}
			table.insert( self.teams, team )
			self.team_by_clan_id[ clan_id ] = team
		end
	end
	
	self.starts_in = os.time( ) + self.conf.preparation_duration
	self.ends_in = self.starts_in + self.conf.game_duration

	for i = 1, 10000 do
		local dimension = EVENT_DIMENSION + i
		if not BUSY_DIMENSIONS[ dimension ] then
			BUSY_DIMENSIONS[ dimension ] = true
			self.dimension = dimension
			break
		end
	end

	self.resource_root = getResourceRootElement( getResourceFromName( self.conf.resource_name ) )
	self.elements = { }

	if not self.resource_root then
		iprint( "ОШИБКА СОЗДАНИЯ ЛОББИ: РЕСУРС", self.conf.resource_name, "НЕ ЗАПУЩЕН" )

		return false
	end

	self.OnCreated = function( self )
		triggerEvent( "CEV:OnLobbyCreated", self.resource_root, self )
	end

	if self.conf.create_lobby_on_first_register then
		self:OnCreated( )
	end

	self.OnPlayerRequestJoin = function( self, player )
		if not player:CanJoinToEventLobby( ) then return end

		if self.state ~= LOBBY_STATE_PREPARATION then
			player:ShowError( "Регистрация закрыта" )
			return
		end

		local clan_players = self.clans_players[ player:GetClanID( ) ]
		if clan_players and #clan_players >= self.conf.players_count_per_clan then
			local was_other_player_kicked = false
			local player_clan_role = player:GetClanRole( )
			if player_clan_role >= CLAN_ROLE_MODERATOR then
				for i, other_player in pairs( clan_players ) do
					if other_player:GetClanRole( ) < player_clan_role then
						self:OnPlayerLeave( other_player )
						other_player:ShowInfo( "Вы были кикнуты из лобби" )
						was_other_player_kicked = true
						break
					end
				end
			end
			if not was_other_player_kicked then
				player:ShowError( "Необходимое количество игроков из вашего клана уже набрано" )
				return
			end
		end

		self:OnPlayerJoin( player )
	end

	self.OnPlayerJoin = function( self, player )
		triggerEvent( "CEV:OnPlayerLobbyPreJoin", player )

		PLAYER_LOBBY[ player ] = self

		local clan_id = player:GetClanID( )
		local clan_players = self.clans_players[ clan_id ]
		if not clan_players then
			clan_players = { }
			self.clans_players[ clan_id ] = clan_players
			local team = {
				clan_id = clan_id,
				players = clan_players,
				kills = 0,
				deaths = 0,
				outmap_deaths = 0,
			}
			table.insert( self.teams, team )
			self.team_by_clan_id[ clan_id ] = team
		elseif self.conf.is_lobby_managment_available then
			triggerClientEvent( clan_players, "CEV:OnClientOtherPlayerLobbyJoin", player, player:GetClanRole( ) )
		end
		table.insert( clan_players, player )
		self.players_teams[ player ] = self.team_by_clan_id[ clan_id ]
		
		table.insert( self.participants, player )

		self.participants_data[ player ] = {
			team_players = clan_players,
			clan_id = clan_id,
			uid = player:GetID( ),
			name = player:GetNickName( ),
			hp = player.health,
			armor = player.armor,
			position = player.position,
			dimension = player.dimension,
			interior = player.interior,
		}
		PLAYER_WEAPONS[ player ] = GetWeaponsTable( player )

		player:setData( "in_clan_event_lobby", true, false )

		addEventHandler( "onPlayerPreLogout", player, OnPlayerQuit )
		addEventHandler( "onPlayerLeaveClan", player, OnPlayerQuit )

		addEventHandler( "onPlayerWasted", player, self.OnPlayerWasted )
		addEventHandler( "onPlayerWastedOutGameZone", player, self.OnPlayerWastedOutMap )
		addEventHandler( "onPlayerSpawn", player, self.OnPlayerSpawn )

		if isPedInVehicle( player ) then
			removePedFromVehicle( player )
		end

		triggerEvent( "CEV:OnPlayerLobbyJoin", self.resource_root, self.id, player )

		-- prep phase
		local pDataToSend = 
		{
			lobby_state = self.state,
			event_id = self.event_id,
			max_count = self.conf.players_count_per_clan,
		}

		if self.state == LOBBY_STATE_PREPARATION then
			pDataToSend.time_left = self.starts_in - getRealTime( ).timestamp
		end

		if self.conf.is_lobby_managment_available then
			local list = { }
			for i, player in pairs( clan_players ) do
				list[ i ] = {
					player = player,
					name = player:GetNickName( ),
					role = player:GetClanRole( ),
				}
			end
			pDataToSend.players = list
		end

		triggerClientEvent( player, "CEV:OnClientPlayerLobbyJoin", self.resource_root, pDataToSend )

		triggerEvent( "onClanEventJoin", player, player:GetClanID( ), self.conf.name )
		return true
	end

	self.ClearPlayerData = function( self, player )
		for k,v in pairs( self.participants ) do
			if v == player then
				table.remove( self.participants, k )
				break
			end
		end

		local data = self.participants_data[ player ]
		if not data then return end

		self.participants_data[ player ] = nil
		PLAYER_WEAPONS[ player ] = nil

		local team_players = data.team_players
		for k, v in pairs( team_players ) do
			if v == player then
				table.remove( team_players, k )
				break
			end
		end

		if #team_players == 0 then
			if self.state == LOBBY_STATE_STARTED then
				self:SetState( LOBBY_STATE_FINISHED )
			-- elseif self.state == LOBBY_STATE_PREPARATION then
			-- 	self:destroy( )
			end
		end
	end

	self.OnPlayerRequestLeave = function( self, player )
		fadeCamera( player, false, 1 )
		setTimer( function( player )
			if not isElement( player ) then return end
			self:OnPlayerLeave( player )

			setTimer( function( player )
				if not isElement( player ) then return end
				fadeCamera( player, true, 1 )
			end, 2000, 1, player )
		end, 1200, 1, player )
	end

	self.OnPlayerLeave = function( self, player, on_resource_stop )
		PLAYER_LOBBY[ player ] = nil

		if not isElement( player ) then
			self:ClearPlayerData( player )
			return 
		end

		local data = self.participants_data[ player ]
		if not data then return end

		player:setData( "in_clan_event_lobby", false, false )

		if isPedInVehicle( player ) then
			removePedFromVehicle( player )
		end

		triggerClientEvent( player, "CEV:OnClientPlayerLobbyLeave", self.resource_root )

		if isPedDead( player ) then
			player:spawn( data.position, 0, player.model, data.interior, data.dimension )
		else
			player:Teleport( data.position, data.dimension, data.interior )
		end
		player.health = data.hp
		player.armor = data.armor
		if not on_resource_stop then
			player.frozen = true
			setTimer( function( player )
				if not isElement( player ) then return end
				player.frozen = false
			end, 2000, 1, player )
		end

		triggerEvent( "CEV:OnPlayerLobbyLeave", self.resource_root, self.id, player )

		self:ClearPlayerData( player )

		if self.conf.is_lobby_managment_available then
			triggerClientEvent( data.team_players, "CEV:OnClientOtherPlayerLobbyLeave", player )
		end

		removeEventHandler( "onPlayerWasted", player, self.OnPlayerWasted )
		removeEventHandler( "onPlayerWastedOutGameZone", player, self.OnPlayerWastedOutMap )
		removeEventHandler( "onPlayerSpawn", player, self.OnPlayerSpawn )

		removeEventHandler( "onPlayerPreLogout", player, OnPlayerQuit )
		removeEventHandler( "onPlayerLeaveClan", player, OnPlayerQuit )
	end

	self.OnPlayerWasted = function( __, killer )
		local player = source
		PLAYER_WEAPONS[ player ] = GetWeaponsTable( player )

		local player_team = self.players_teams[ player ]
		player_team.deaths = player_team.deaths + 1

		if isElement( killer ) and getElementType( killer ) == "player" then
			local killer_team = self.players_teams[ killer ]
			if killer_team then
				killer_team.kills = killer_team.kills + 1
			end
		end
	end

	self.OnPlayerWastedOutMap = function( )
		local player = client or source
		local player_team = self.players_teams[ player ]
		player_team.outmap_deaths = player_team.outmap_deaths + 1
	end
	
	self.OnPlayerSpawn = function( )
		local player = source
		player:TakeAllWeapons( )
		GiveWeaponsFromTable( player, PLAYER_WEAPONS[ player ] or { } )
	end

	self.SetState = function( self, new_state )
		if self.state == new_state then return end

		if new_state == LOBBY_STATE_STARTED then
			self.timestamp_start = getRealTime( ).timestamp

			for i, team in pairs( self.teams ) do
				if self.conf.rewards and self.conf.rewards.clan_money then
					TakeClanMoney( team.clan_id, self.conf.rewards.clan_money )
				end

				team.players_count_at_start = #team.players

				if self.conf.rewards and self.conf.rewards.clan_honor then
					local clan_id = team.clan_id
					local clan_analytics_data = {
						name = GetClanName( clan_id ),
						members_count = GetClanData( clan_id, "members_count" ),
						players_data = { },
					}
					self.analytics_data.clans[ clan_id ] = clan_analytics_data

					for i, player in pairs( team.players ) do
						local player_data = self.participants_data[ player ]
						SendElasticGameEvent( player:GetClientID( ), "clan_event_start", {
							clan_id = clan_id,
							clan_name = clan_analytics_data.name,
							clan_members_count = clan_analytics_data.members_count,
							teleported_from = player_data.interior ~= 0 and 1 or player_data.dimension ~= 0 and 2 or 0,
							reg_duration = os.time( ) - ( player:getData( "last_reg_in_clan_event" ) or os.time( ) ),
							reg_cancel_count = player:GetPermanentData( "clan_event_reg_cancels" ) or 0,
						} )
						table.insert( clan_analytics_data.players_data, {
							element = player,
							client_id = player:GetClientID( ),
							clan_rank = player:GetClanRank( ),
						} )
					end
				end
				
				if team.players_count_at_start == 0 then
					new_state = LOBBY_STATE_FINISHED
				end
			end

		elseif new_state == LOBBY_STATE_PREPARATION then
			-- local event_name = CLAN_EVENT_CONFIG[ self.event_id ].name
			-- local pNotification =
			-- {
			-- 	title = event_name,
			-- 	msg = "Принять участие в \"" .. event_name .. "\"",
			-- 	special = "clan_event_join",
			-- }
			-- triggerClientEvent( self.participants, "OnClientReceivePhoneNotification", root, pNotification )
		end

		self.state = new_state

		triggerEvent( "CEV:OnLobbyStateChanged", self.resource_root, self.id, new_state )
	end

	self.OnFinished = function( self, results )
		self.finished = true
		self:SetState( LOBBY_STATE_FINISHED )

		if results then
			triggerClientEvent( self.participants, "CEV:OnClientGameFinished", resourceRoot, {
				event_id = self.event_id,
				scores = results.scores,
				winner_clan_id = results.winner_clan_id,
			} )

			local duration = getRealTime( ).timestamp - ( self.timestamp_start or 0 )

			if self.conf.rewards and next( self.conf.rewards ) then
				-- Выдача наград игрокам
				for i, player in pairs( results.players or self.participants ) do
					if isElement( player ) then
						local won = self.participants_data[ player ] and self.participants_data[ player ].clan_id == results.winner_clan_id
						if won then
							self:GivePlayerRewards( player )
						end
					end
				end

				if self.conf.rewards.clan_honor then
					local clans_data = self.analytics_data.clans
					GiveClanHonor( results.winner_clan_id, self.conf.rewards.clan_honor, self.conf.analytics_key, clans_data[ results.winner_clan_id ].players_data, self.conf.rewards.player.clan_exp )
					TakeClanHonor( results.loser_clan_id, self.conf.loser_clan_honor_loss, self.conf.analytics_key, clans_data[ results.loser_clan_id ].players_data, 0 )

					local score_key = self.conf.key .. "_score"
					SetClanData( results.winner_clan_id, score_key, ( GetClanData( winner_clan_id, score_key ) or 0 ) + ( self.conf.rewards.clan_honor or 0 ) )
				end

				if self.conf.rewards.clan_money then
					GiveClanMoney( results.winner_clan_id, self.conf.rewards.clan_money * 2 )
				end

				for i, team in pairs( self.teams ) do
					local clan_id = team.clan_id
					local is_winner = results.winner_clan_id == clan_id
					local player = team.players[ 1 ]
					SendElasticGameEvent( nil, "clan_match_end", {
						match_type = self.conf.analytics_key,
						clan_id = clan_id,
						clan_name = GetClanName( clan_id ),
						clan_money_reward = ( is_winner and 1 or -1 ) * self.conf.rewards.clan_money,
						clan_honor_reward = ( is_winner and self.conf.rewards.clan_honor or -self.conf.loser_clan_honor_loss ),
						match_win = is_winner and "true" or "false",
						clan_kill_count = team.kills,
						clan_death_count = team.deaths,
						match_duration = duration,
						leave_count = team.players_count_at_start - #team.players,
						outmap_death = team.outmap_deaths,
					} )
				end
			end

			if self.conf.fn_finish then
				results.duration = duration
				results.leave_count = 0
				results.clans_reg_count = { }
				for i, team in pairs( self.teams ) do
					results.leave_count = results.leave_count + team.players_count_at_start - #team.players
					results.clans_reg_count[ team.clan_id ] = team.players_count_at_start
				end
				self.conf.fn_finish( results )
			end
		end

		setTimer( function( lobby_id )
			if LOBBIES_BY_ID[ lobby_id ] then
				LOBBIES_BY_ID[ lobby_id ]:destroy( )
			end
		end, 10000, 1, self.id )
	end

	self.GivePlayerRewards = function( self, player )
		if isElement( player ) then
			local pRewardsList = self.conf.rewards.player

			local iMoney = 0

			if pRewardsList then
				for k, v in pairs( pRewardsList ) do
					if k == "money" then
						player:GiveMoney( v, "band_event_reward" )
						iMoney = iMoney + v
					elseif k == "exp" then
						player:GiveExp( v, "CLAN_EVENT_WON" )
					elseif k == "clan_exp" then
						player:GiveClanEXP( v )
					elseif k == "custom_func" then
						v( player )
					end
				end
			end

			local iDuration = getRealTime( ).timestamp - self.starts_in
			triggerEvent( "onClanEventWon", player, player:GetClanID( ), iMoney, iDuration, self.conf.name )
		end
	end

	self.destroy = function( self, on_resource_stop )
		self.state = LOBBY_STATE_DESTROYED

		for i = 1, #self.participants do
			local player = self.participants[ 1 ]
			self:OnPlayerLeave( player, on_resource_stop )
			if on_resource_stop then
				player:ShowInfo( self.conf.name .. " был принудительно завершен" )
			end
		end

		DestroyTableElements( self.elements )
		
		triggerEvent( "CEV:OnLobbyDestroyed", self.resource_root, self.id )

		LOBBIES_BY_ID[ self.id ] = nil
		BUSY_DIMENSIONS[ self.dimension ] = nil
		setmetatable( self, nil )
	end

	self.elements.timer_start = setTimer( function( lobby_id )
		local lobby = LOBBIES_BY_ID[ lobby_id ]

		if lobby then
			lobby:SetState( LOBBY_STATE_STARTED )
		end
	end, self.conf.preparation_duration * 1000, 1, self.id )

	self.elements.timer_finish = setTimer( function( lobby_id )
		local lobby = LOBBIES_BY_ID[ lobby_id ]

		if lobby then
			lobby:SetState( LOBBY_STATE_FINISHED )
		end
	end, ( self.conf.preparation_duration + self.conf.game_duration ) * 1000, 1, self.id )

	addEventHandler( "onResourceStop", self.resource_root, function( )
		self:destroy( true )
	end )

	triggerEvent( "CEV:OnGameLobbyCreated", self.resource_root, self )

	LOBBIES_BY_ID[ self.id ] = self
	LAST_ID = self.id

	return self
end

function OnPlayerQuit( )
	local player = client or source

	local lobby = player:GetLobby( )
	if lobby then
		lobby:OnPlayerLeave( player, true )
	end
end
addEvent( "onPlayerLeaveClan" )
addEvent( "onPlayerWastedOutGameZone", true )

function OnGameFinished_handler( lobby_id, results )
	local lobby = LOBBIES_BY_ID[ lobby_id ]
	if lobby then
		lobby:OnFinished( results )
	end
end
addEvent( "CEV:OnGameFinished", true )
addEventHandler( "CEV:OnGameFinished", root, OnGameFinished_handler )

function OnPlayerRequestEventJoin( lobby_id )
	local player = client or source

	local lobby = LOBBIES_BY_ID[ lobby_id ]
	if lobby then
		lobby:OnPlayerRequestJoin( player )
	end
end
addEvent( "CEV:OnPlayerRequestEventJoin", true )
addEventHandler( "CEV:OnPlayerRequestEventJoin", root, OnPlayerRequestEventJoin )

function OnPlayerRequestEventLeave( )
	local player = client or source

	local lobby = player:GetLobby( )
	if lobby then
		lobby:OnPlayerRequestLeave( player )
	end
end
addEvent( "CEV:OnPlayerRequestEventLeave", true )
addEventHandler( "CEV:OnPlayerRequestEventLeave", root, OnPlayerRequestEventLeave )

function OnPlayerRequestKickOther( other_player )
	if not isElement( other_player ) then return end

	local player = client or source

	local lobby = player:GetLobby( )
	if lobby then
		lobby:OnPlayerRequestLeave( other_player )
		other_player:ShowError( "Вы были кикнуты из лобби" )
	end
end
addEvent( "CEV:OnPlayerRequestKickOther", true )
addEventHandler( "CEV:OnPlayerRequestKickOther", root, OnPlayerRequestKickOther )

function OnResourceStop_handler( )
	for k,v in pairs( LOBBIES_BY_ID ) do
		v:destroy( true )
	end
end
addEventHandler( "onResourceStop", resourceRoot, OnResourceStop_handler )

Player.GetLobby = function( self )
	return PLAYER_LOBBY[ self ]
end

Player.CanJoinToEventLobby = function( self, lobby )
	if REGISTERED_PLAYERS_DATA[ self ] then
		self:ShowError( "Ты уже зарегистрирован" )
		return
	end

	if self:GetLobby( ) then
		self:ShowError( "Ты уже участвуешь" )
		return
	end

	local clan_id = self:GetClanID( )
	if not clan_id then
		self:ShowError( "Ты не состоишь в клане" )
		return
	end

	local can_join, msg = self:CanJoinToEvent( { event_type = "clan_event_register" } )
	if not can_join then
		self:ShowError( msg )
		return
	end

	return true
end




if SERVER_NUMBER > 100 then

	function ForceStartGame( player )
		local lobby = player:GetLobby( )
		if lobby then
			lobby:SetState( LOBBY_STATE_STARTED )
			if isTimer( lobby.elements.timer_start ) then
				killTimer( lobby.elements.timer_start )
			end
			outputConsole( "Вы успешно запустили матч" )
		else
			outputConsole( "Вы сейчас не участвуете в матче" )
		end
	end

	addCommandHandler( "startclangame", ForceStartGame )
	addCommandHandler( "startclanevent", ForceStartGame )
	addCommandHandler( "startclanmatch", ForceStartGame )
	addCommandHandler( "start_clan_game", ForceStartGame )
	addCommandHandler( "start_clan_match", ForceStartGame )
	addCommandHandler( "start_clan_event", ForceStartGame )

	function ForceFinishGame( player )
		local lobby = player:GetLobby( )
		if lobby then
			lobby:SetState( LOBBY_STATE_FINISHED )
			if isTimer( lobby.elements.timer_finish ) then
				killTimer( lobby.elements.timer_finish )
			end
			outputConsole( "Вы успешно завершили матч" )
		else
			outputConsole( "Вы сейчас не участвуете в матче" )
		end
	end

	addCommandHandler( "finishclangame", ForceFinishGame )
	addCommandHandler( "finishclanevent", ForceFinishGame )
	addCommandHandler( "finishclanmatch", ForceFinishGame )
	addCommandHandler( "finish_clan_game", ForceFinishGame )
	addCommandHandler( "finish_clan_match", ForceFinishGame )
	addCommandHandler( "finish_clan_event", ForceFinishGame )
	addCommandHandler( "stopclangame", ForceFinishGame )
	addCommandHandler( "stopclanevent", ForceFinishGame )
	addCommandHandler( "stopclanmatch", ForceFinishGame )
	addCommandHandler( "stop_clan_game", ForceFinishGame )
	addCommandHandler( "stop_clan_match", ForceFinishGame )
	addCommandHandler( "stop_clan_event", ForceFinishGame )

	addEvent( "SetSeasonSettings", true )
	addEventHandler( "SetSeasonSettings", root, function( data )
		for var, value in pairs( data ) do
			_G[ var ] = value
		end
		CLAN_EVENT_CONFIG[ CLAN_EVENT_CARTEL_CAPTURE ].preparation_duration = data.REGISTER_AVAILABLE_DURATION
		CLAN_EVENT_CONFIG[ CLAN_EVENT_CARTEL_TAX_WAR ].preparation_duration = data.REGISTER_AVAILABLE_DURATION
	end )

end