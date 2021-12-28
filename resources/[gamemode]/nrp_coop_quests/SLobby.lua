local LOBBIES_LIST = { }
local LOBBIES_BY_ID = { }
local LOBBIES_BY_PLAYER = { }

local FORCED_QUEST_TYPE = false
FORCED_QUEST_LOCATION = false

local LAST_LOBBY_ID = 1

local QuestLobby = 
{
	id = -1,
	is_searching = false,
	is_started = false,
	is_merged = false,
	is_team_found = false,
	is_team_ready = false,

	Init = function( self )
		self.teams = { { }, { } }
		self.players_list = { }
		self.players_data = { }
		self.last_synced_data = { }
	end,

	AddPlayer = function( self, player, team, location_id )
		table.insert( self.players_list, player )

		self.players_data[ player ] = 
		{
			leader = #self.teams[ team ] <= 0,
			ready = false,
			element = player,
			team = team,
			start_location = location_id,
		}

		table.insert( self.teams[ team ], self.players_data[ player ] )

		LOBBIES_BY_PLAYER[ player ] = self

		if not self.is_merged then
			if #self.players_list >= 2 then
				self.is_team_found = true
			end
		end

		self:Sync( )
		self:SyncTeams( )

		local join_data = 
		{
			is_leader = self.players_data[ player ].leader,
			team = team,
			is_searching = false,
			team_found = self.is_team_found,
		}

		triggerClientEvent( player, "OnClientLobbyJoined", resourceRoot, join_data )

		addEventHandler( "onPlayerPreLogout", player, OnPlayerLobbyPreLogout_handler )
	end,

	RemovePlayer = function( self, player )
		local player_data = self.players_data[ player ]

		for k,v in pairs( self.players_list ) do
			if v == player then
				table.remove( self.players_list, k )
				break
			end
		end

		for k,v in pairs( self.teams[ player_data.team ] ) do
			if v.element == player then
				table.remove( self.teams[ player_data.team ], k )
				break
			end
		end

		self.players_data[ player ] = nil

		LOBBIES_BY_PLAYER[ player ] = nil

		if not not self.is_merging then
			self:Sync( )
			self:SyncTeams( )
		end

		if not self.is_merged and not self.is_merging then
			if #self.players_list <= 1 then
				for k,v in pairs( self.players_list ) do
					v:ShowError( "Поиск отменён. Один из игроков покинул лобби" )
				end

				self:destroy( )
			end
		end

		if not self.is_merging and not self.destroyed and #self.players_list <= 0 then
			self:destroy( )
		end

		if self.is_starting and not self.is_started then
			for k,v in pairs( self.players_list ) do
				v:ShowError( "Запуск отменён. Один из игроков покинул лобби" )
			end

			self:destroy( )
		end

		removeEventHandler( "onPlayerPreLogout", player, OnPlayerLobbyPreLogout_handler )
		triggerClientEvent( player, "OnClientLobbyLeft", resourceRoot )
	end,

	ChangePlayerReadyState = function( self, player )
		if self.is_searching then return end
		if self.is_merged then return end
		if self.is_started then return end

		local player_data = self.players_data[ player ]

		player_data.ready = not player_data.ready
		self.is_team_ready = self.teams[1][1].ready and self.teams[1][2].ready or false

		if self.is_team_ready then
			self:FindOpponents( )
		else
			self:Sync( )
		end

		self:SyncTeams( )
	end,

	ToggleSearch = function( self )
		self.is_searching = not self.is_searching
		self:Sync( )
	end,

	FindOpponents = function( self )
		self.is_searching = true

		self:Sync( )

		for k,v in pairs( LOBBIES_LIST ) do
			if v.id ~= self.id and not v.is_merged and v.is_team_found and v.is_team_ready and v.is_searching then
				self:Merge( v )
				break
			end
		end
	end,

	Merge = function( self, found_lobby )
		found_lobby.is_merging = true

		repeat
			local player = found_lobby.players_list[1]
			local player_data = table.copy( found_lobby.players_data[ player ] )
			found_lobby:RemovePlayer( player )
			self:AddPlayer( player, 2, player_data.start_location )
		until
			not next( found_lobby.players_list )

		found_lobby:destroy( )

		self.is_merged = true
		self.is_searching = false
		self.is_starting = true

		for k, v in pairs( self.players_data ) do
			v.ready = true
		end

		self:Sync( )
		self:SyncTeams( )

		self.start_quest_timer = setTimer(function()
			self:StartQuest( )
		end, 5000, 1)
	end,

	Split = function( self )
		local new_lobby = CreateQuestLobby( )

		for player, data in pairs( self.teams[2] ) do
			self:RemovePlayer( player )
			new_lobby:AddPlayer( player )
		end

		self.is_merged = false
		self.is_searching = false
	end,

	StartQuest = function( self )
		local is_players_allowed = true

		for k, v in pairs( self.players_list ) do
			local is_allowed, reason = CanPlayerJoinCoopQuest( v )
			if not is_allowed then
				if reason then
					v:ShowError( reason )
				end

				is_players_allowed = false
				break
			end
		end

		if not is_players_allowed then
			self:destroy( )
			return
		end

		local quest = CreateQuestHandler(  )

		quest.quest_type = FORCED_QUEST_TYPE or math.random( 1, 3 )

		for k,v in pairs( self.players_list ) do
			local data = self.players_data[ v ]

			local lobby_data = 
			{
				leader = data.leader,
				start_location = data.start_location,
				team = data.team,
			}

			quest:AddPlayer( v, lobby_data )
		end

		self.start_quest_timer = setTimer(function()
			quest:StartQuest( )
			self.is_started = true
			self:destroy( )
		end, 1000, 1)
	end,

	Sync = function( self )
		local data = 
		{ 
			opponents_found = self.is_merged,
			team_found = self.is_team_found,
			is_searching = self.is_searching,
		}

		if self.last_synced_data then
			for k,v in pairs( data ) do
				if self.last_synced_data[ k ] == v then
					data[k] = nil
				end
			end
		end

		self.last_synced_data = data

		for k,v in pairs( self.players_list ) do
			data.is_leader = self.players_data[ v ].leader
			data.team = self.players_data[ v ].team

			triggerClientEvent( v, "OnClientLobbyDataSynced", resourceRoot, data )
		end
	end,

	SyncTeams = function( self )
		triggerClientEvent( self.players_list, "OnClientTeamsDataSynced", resourceRoot, self.teams )
	end,

	destroy = function( self )
		if self.destroyed then return end

		self.destroyed = true

		if #self.players_list >= 1 then
			repeat
				self:RemovePlayer( self.players_list[1] )
			until 
				not next( self.players_list )
		end

		LOBBIES_BY_ID[ self.id ] = nil

		for k,v in pairs( LOBBIES_LIST ) do
			if v == self then
				table.remove( LOBBIES_LIST, k )
				break
			end
		end

		if isTimer( self.start_quest_timer ) then
			killTimer( self.start_quest_timer )
		end

		iprint( "DESTROYED LOBBY", self.id )

		setmetatable( self, nil )

		self = nil

		return true
	end,
}

QuestLobby.__index = QuestLobby

function GetPlayerLobby( player )
	return LOBBIES_BY_PLAYER[ player ]
end

function GetQuestLobby( id )
	return LOBBIES_BY_ID[ id ]
end

function CreateQuestLobby( conf )
	local conf = conf or { }

	local self = setmetatable( {}, QuestLobby )
	self:Init( )
	table.insert( LOBBIES_LIST, self )

	self.id = LAST_LOBBY_ID
	LOBBIES_BY_ID[ LAST_LOBBY_ID ] = self

	LAST_LOBBY_ID = ( LAST_LOBBY_ID + 1 ) % 1000

	for k,v in pairs( conf ) do
		self[ k ] = v
	end

	iprint("CREATED LOBBY", self.id)

	return self
end

function OnPlayerLobbyPreLogout_handler( )
	local lobby = GetPlayerLobby( source )

	if lobby then
		lobby:RemovePlayer( source )
	end
end

function OnPlayerRequestLeaveLobby( )
	local lobby = GetPlayerLobby( client )

	if lobby then
		lobby:RemovePlayer( client )
	end
end
addEvent( "OnPlayerRequestLeaveLobby", true )
addEventHandler( "OnPlayerRequestLeaveLobby", resourceRoot, OnPlayerRequestLeaveLobby )

function OnPlayerRequestToggleReady( )
	local lobby = GetPlayerLobby( client )

	if lobby then
		lobby:ChangePlayerReadyState( client )
	end
end
addEvent( "OnPlayerRequestToggleReady", true )
addEventHandler( "OnPlayerRequestToggleReady", resourceRoot, OnPlayerRequestToggleReady )

function OnPlayerRequestStart( )
	local lobby = GetPlayerLobby( client )

	if lobby then
		lobby:FindOpponents( )
	end
end
addEvent( "OnPlayerRequestStart", true )
addEventHandler( "OnPlayerRequestStart", resourceRoot, OnPlayerRequestStart )

function OnPlayerTryInviteAnotherPlayer( target_player )
	if target_player == client then return end

	if not isElement( target_player ) then
		client:ShowError( "Игрок не найден" )
		return 
	end

	if target_player:GetLevel( ) < REQUIRED_PLAYER_LEVEL then
		client:ShowError( "Игроки ниже "..REQUIRED_PLAYER_LEVEL.." уровня не могут принимать участие" )
		return
	end

	if not target_player:HasLicense( LICENSE_TYPE_AUTO ) then
	    client:ShowError( "Данный игрок не может принять ваше приглашение" )
	    return false
	end

	if target_player:getData( "current_quest" ) then
		client:ShowError( "Данный игрок не может принять ваше приглашение" )
		return false
	end

	if not target_player:CanJoinToEvent( ) then
		client:ShowError( "Данный игрок не может принять ваше приглашение" )
	    return false
	end

	if client:GetCoopQuestAttempts( ) <= 0 then
		client:ShowError( "Вы исчерпали свой лимит заданий на сегодня" )
		return
	end

	local pNotification = 
    {
        title = "Кооперативный квест",
        msg = "Приглашение в кооперативный квест",
        special = "coop_quest_invite",
        player = client,
        args = {},
    }

    target_player:PhoneNotification( pNotification )
end
addEvent( "OnPlayerTryInviteAnotherPlayer", true )
addEventHandler( "OnPlayerTryInviteAnotherPlayer", root, OnPlayerTryInviteAnotherPlayer )

function OnPlayerCoopQuestInviteAccepted( invited_player )
	if not isElement( invited_player ) then
		client:ShowError( "Игрок не найден" )
		return 
	end

	local lobby = GetPlayerLobby( invited_player )
	if lobby then
		client:ShowError( "Лобби уже собрано" )
		return 
	end

	local is_allowed, reason = CanPlayerJoinCoopQuest( client )
	if not is_allowed then
		client:ShowError( reason )
		invited_player:ShowNotification( "Игрок "..client:GetNickName( ).." не смог принять ваше приглашение" )
		return
	end

	invited_player:ShowNotification( "Игрок "..client:GetNickName( ).." принял ваше приглашение" )

	OnPlayerRequestToggleSearch( client, true )
	OnPlayerRequestToggleSearch( invited_player, true )

	local new_lobby = CreateQuestLobby( )
	new_lobby:AddPlayer( invited_player, 1, 1 )
	new_lobby:AddPlayer( client, 1, 1 )
end
addEvent( "OnPlayerCoopQuestInviteAccepted", true )
addEventHandler( "OnPlayerCoopQuestInviteAccepted", root, OnPlayerCoopQuestInviteAccepted )

function OnPlayerCoopQuestInviteDeclined( invited_player )
	if not isElement( invited_player ) then return end
	invited_player:ShowNotification( "Игрок "..client:GetNickName( ).." отклонил ваше приглашение" )
end
addEvent( "OnPlayerCoopQuestInviteDeclined", true )
addEventHandler( "OnPlayerCoopQuestInviteDeclined", root, OnPlayerCoopQuestInviteDeclined )

-- TESTS
if SERVER_NUMBER > 100 then
	addCommandHandler( "set_coop_quest_type", function( ply, cmd, num, location_num )
        if not ply:IsAdmin( ) then return end

        local id = tonumber( num )
        local location_id = tonumber( location_num )

        if not id then
        	FORCED_QUEST_TYPE = false
        else
        	FORCED_QUEST_TYPE = id
        end

        if not location_id then
        	FORCED_QUEST_LOCATION = false
        else
        	FORCED_QUEST_LOCATION = location_id
        end

        outputChatBox( "Выбранный режим: ".. ( FORCED_QUEST_TYPE and COOP_QUESTS_CONFIG[ FORCED_QUEST_TYPE ].name or "Случайный" ), ply, 200, 200, 200 )
    end) 

    addCommandHandler( "reset_coop_quest_attempts", function( ply )
        if not ply:IsAdmin( ) then return end

        ply:SetCoopQuestAttempts( 2 )
    end)

    addCommandHandler( "g_reset_coop_quest_attempts", function( ply )
        if not ply:IsAdmin( ) then return end

        for k,v in pairs( GetPlayersInGame( ) ) do
        	v:SetCoopQuestAttempts( 2 )
        end
    end)

    addCommandHandler( "ignore_coop_quest_attempts", function( ply )
        if not ply:IsAdmin( ) then return end

        COOP_QUEST_ATTEMPTS_IGNORED = not COOP_QUEST_ATTEMPTS_IGNORED

        outputChatBox( "Бесконечные входы в квесты: ".. ( COOP_QUEST_ATTEMPTS_IGNORED and "ВКЛ" or "ВЫКЛ" ), ply, 200, 200, 200 )
    end)
end