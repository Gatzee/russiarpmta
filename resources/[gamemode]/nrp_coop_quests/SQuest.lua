local QUESTS_LIST = { }
local QUESTS_BY_ID = { }
local QUESTS_BY_PLAYER = { }

local LAST_QUEST_ID = 1

local QuestHandler = 
{
	id = -1,
	stage = 1,
	dimension = 100,
	started = false,

	quest_type = QUEST_TYPE_DATA_COLLECTION,

	Init = function( self )
		self.teams = { { }, { } }
		self.team_data = { { }, { } }
		self.players_list = { }
		self.players_data = { }
		self.quest_data = { }
		self.quest_elements = { }
		self.stage_elements = { }
		self.synced_elements = { }
		self.dimension = self.id + 1346
	end,

	AddPlayer = function( self, player, lobby_data )
		table.insert( self.players_list, player )

		self.players_data[ player ] = 
		{
			element = player,
			team = lobby_data.team,
			start_location = lobby_data.start_location,

			deaths = 0,
			kills = 0,

			last_position = player.position,
			last_dimension = player.dimension,
			last_interior = player.interior,
			last_health = player.health,
			last_armor = player.armor,
			last_immortal = player:IsImmortal(),
		}

		if not self:GetTeamData( lobby_data.team, "start_location" ) then
			local location_id = lobby_data.start_location or 1

			local is_location_used = self:GetTeamData( lobby_data.team == 1 and 2 or 1, "start_location" ) == location_id
			if is_location_used then
				local unused_locations = { }
				for i = 1, #QUEST_START_LOCATIONS do
					if i ~= location_id then
						table.insert( unused_locations, i )
					end
				end

				location_id = unused_locations[ math.random( 1, #unused_locations ) ]
			end

			self:SetTeamData( lobby_data.team, "start_location", location_id )
		end

		table.insert( self.teams[ lobby_data.team ], self.players_data[ player ] )

		QUESTS_BY_PLAYER[ player ] = self

		player:SetPrivateData( "in_coop_quest", true )

		addEventHandler( "onPlayerPreLogout", player, OnPlayerQuestPreLogout_handler )
		addEventHandler( "onPlayerPreWasted", player, OnPlayerPreWasted_handler )
		addEventHandler( "onPlayerWasted", player, OnPlayerWasted_handler )

		triggerClientEvent( player, "OnClientJoinedCoopQuest", resourceRoot, { team_id = lobby_data.team } )
	end,

	RemovePlayer = function( self, player )
		local player_data = self.players_data[ player ]

		if not self.finished then
			player:TakeCoopQuestAttempts( 1 )
			self.failed = true
			triggerClientEvent( player, "OnCoopQuestStageFinished", resourceRoot )
			triggerClientEvent( player, "OnCoopQuestFinished", resourceRoot )
		end

		player:SetPrivateData( "current_daily_coop_quest", false )

		if isTimer( player_data.respawn_timer ) then
			killTimer( player_data.respawn_timer )
		end

		if isPedDead( player ) then
			player:spawn( player_data.last_position, 0, player.model, 0, player_data.last_dimension )
			player.health = player_data.last_health
		end

		if isPedInVehicle( player ) then
			removePedFromVehicle( player )
		end

		player.position = player_data.last_position
		player.interior = player_data.last_interior
		player.dimension = player_data.last_dimension
		player.health = player_data.last_health
		player.armor = player_data.last_armor
		player.frozen = false
		toggleAllControls( player, true )
		player:SetImmortal( player_data.last_immortal )
		player:SetPrivateData( "realdriveby_disabled", false )

		triggerEvent( "OnPlayerForceSwitchTeam", player, player, true )

		SendElasticGameEvent( player:GetClientID( ), "coop_quest_complete", {
	        id          = tostring( self.quest_type ),
	        is_afk      = self.failed and "true" or "false",
	        is_win      = self.team_won == player_data.team and "true" or "false",
	        is_draw     = ( not self.team_won or self.team_won == -1 ) and "true" or "false",
	        reward_sum  = self.team_won == player_data.team and 2 or 1,
	        currency    = "key",
	        death_sum   = player_data.deaths,
	        kill_sum    = player_data.kills,
	    } )

		for k,v in pairs( self.players_list ) do
			if v == player then
				table.remove( self.players_list, k )
				break
			end
		end

		for k,v in pairs( self.teams[ player_data.team ] ) do
			if v.element == player then
				v = nil
			end
		end

		self.players_data[ player ] = nil

		QUESTS_BY_PLAYER[ player ] = nil

		if not self.destroyed then
			self:FinishStage( true )
			self:FinishQuest( true )
		end

		player:SetPrivateData( "in_coop_quest", false )

		removeEventHandler( "onPlayerPreLogout", player, OnPlayerQuestPreLogout_handler )
		removeEventHandler( "onPlayerPreWasted", player, OnPlayerPreWasted_handler )
		removeEventHandler( "onPlayerWasted", player, OnPlayerWasted_handler )
	end,

	SetQuestData = function( self, key, value, sync )
		self.quest_data[ key ] = value

		if sync then
			triggerClientEvent( self.players_list, "OnCoopQuestSyncedDataChanged", resourceRoot, key, value )
		end
	end,

	GetQuestData = function( self, key )
		return self.quest_data[ key ]
	end,

	SetTeamData = function( self, team, key, value )
		if not team or not key then return end
		if not self.team_data[ team ] then return end

		self.team_data[ team ][ key ] = value

		if self.started then
			local stage_conf = self.quest_conf.stages[ self.stage ].global

			if stage_conf.OnTeamDataChanged then
				stage_conf:OnTeamDataChanged( self, team, key, value )
			end
		end
	end,

	GetTeamData = function( self, team, key )
		if not team or not key then return end

		return self.team_data[ team ] and self.team_data[ team ][ key ]
	end,

	SetPlayerData = function( self, player, key, value )
		if not player or not key then return end
		if not self.players_data[ player ] then return end

		self.players_data[ player ][ key ] = value
	end,

	GetPlayerData = function( self, player, key )
		return self.players_data[ player ] and self.players_data[ player ][ key ]
	end,

	GetPlayerTeam = function( self, player )
		return self.players_data[ player ] and self.players_data[ player ].team
	end,

	ToggleImmortality = function( self, state )
		for k,v in pairs( self.players_list ) do
			v:SetImmortal( state )
		end
	end,

	SyncElement = function( self, element )
		for k,v in pairs( self.quest_elements ) do
			if v == element then
				self.synced_elements[ k ] = element
				triggerClientEvent( self.players_list, "OnCoopQuestElementSynced", resourceRoot, k, element )
				break
			end
		end
	end,

	PinElementToStage = function( self, element )
		table.insert( self.stage_elements, element )
	end,

	StartQuest = function( self )
		self.started = true
		self.quest_conf = table.copy( COOP_QUESTS_CONFIG[ self.quest_type ] )

		local teams = { {}, {} }

		for player, data in pairs( self.players_data ) do
			local team = data.team

			if isPedInVehicle( player ) then
				removePedFromVehicle( player )
			end

			player.position = Vector3( QUEST_START_LOCATIONS[ self:GetTeamData( team, "start_location" ) ].spawn_conf ):AddRandomRange( 2, 2 )
			player.dimension = self.dimension
			player.interior = 0
			player:SetHP( 1000 )
			
			triggerEvent( "OnPlayerForceSwitchTeam", player, player, false )

			table.insert( teams[team], player )
		end

		self.quest_conf:OnStarted( self )

		local client_data = 
		{
			quest_data = { stage = 1, quest_type = self.quest_type },
			elements = self.synced_elements,
			teams = teams,
		}

		triggerClientEvent( self.players_list, "OnCoopQuestStarted", resourceRoot, client_data )

		self:ToggleImmortality( true )

		self:StartStage( )
	end,

	FinishQuest = function( self, is_forced )
		self.finished = true
		self.quest_conf:OnFinished( self )

		if not self.team_won then
			for k,v in pairs( self.players_list ) do
				v:ShowError( "Задание отменено. Один из игроков покинул лобби" )
			end
		end

		triggerClientEvent( self.players_list, "OnCoopQuestFinished", resourceRoot )

		self:destroy( )
	end,

	StartStage = function( self )
		local stage_conf = self.quest_conf.stages[ self.stage ]

		stage_conf.global:OnStarted( self )

		local is_mirrored = stage_conf.is_mirrored

		for k, v in pairs( self.teams ) do
			stage_conf.teams[ is_mirrored and 1 or k ]:OnStarted( self, k )

			if stage_conf.teams[ is_mirrored and 1 or k ].task_name then
				self:SetTeamTask( k, _, stage_conf.teams[ is_mirrored and 1 or k ].task_name )
			end
		end

		triggerClientEvent( self.players_list, "OnCoopQuestStageStarted", resourceRoot, self.stage )
	end,

	FinishStage = function( self, ignore_next )
		self.quest_conf.stages[ self.stage ].global:OnFinished( self )

		for k,v in pairs( self.stage_elements ) do
			if isElement( v ) then
				destroyElement( v )
			elseif v and v.destroy then
				v:destroy( )
			end
		end

		local is_mirrored = self.quest_conf.stages[ self.stage ].is_mirrored

		for k, v in pairs( self.teams ) do
			self.quest_conf.stages[ self.stage ].teams[ is_mirrored and 1 or k ]:OnFinished( self, k )
		end

		triggerClientEvent( self.players_list, "OnCoopQuestStageFinished", resourceRoot, self.stage )

		self.stage = self.stage + 1

		if self.quest_conf.stages[ self.stage ] then
			if not ignore_next then
				self:StartStage( )
			end
		end
	end,

	OnTeamWon = function( self, team_won )
		self.finished = true
		self.team_won = team_won

		for k,v in pairs( self.players_list ) do
			local team = self.players_data[ v ].team
			v:TakeCoopQuestAttempts( 1 )

			if not self.ignore_rewards then
				v:GiveCoopQuestKeys( team == team_won and 2 or 1 )
			end

			if team == team_won then
				v:MissionCompleted( "Победа" )
			else
				v:MissionFailed( "Поражение" )
			end
		end

		self:FinishStage( )
		self:FinishQuest( )
	end,

	OnPlayerWasted = function( self, player, killer, weapon )
		local stage_conf = self.quest_conf.stages[ self.stage ]

		if isElement( killer ) and getElementType( killer ) == "player" then
			local kills = self:GetPlayerData( killer, "kills" )
			if kills then
				self:SetPlayerData( killer, "kills", kills + 1 )
			end
		end

		local deaths = self:GetPlayerData( player, "deaths" )
		self:SetPlayerData( player, "deaths", deaths + 1 )

		if stage_conf.global.OnPlayerWasted then
			stage_conf.global:OnPlayerWasted( self, player, killer, weapon )
		end

		local team_id = self:GetPlayerTeam( player )
		local current_ts = getRealTimestamp( )

		local last_respawn = self:GetTeamData( team_id, "last_respawn" )
		if last_respawn and current_ts - last_respawn <= 60 then
			if self:GetQuestData( "vehicle_respawns_enabled" ) then
				self:RespawnVehicle( self.quest_elements["start_vehicle"..team_id], team_id )
			end
		end

		self:SetTeamData( team_id, "last_respawn", current_ts )

		if self:GetQuestData( "respawns_enabled" ) then
			triggerClientEvent( player, "OnClientPlayerWasted", resourceRoot )
			self:RespawnPlayer( player )
		else
			self:RemovePlayer( player )
		end
	end,

	GetRespawnPosition = function( self, team )
		if self.quest_conf.GetRespawnPosition then
			return self.quest_conf:GetRespawnPosition( self, team ):AddRandomRange( 2, 2 )
		else
			return Vector3( self.quest_conf.respawn_positions[ team ] ):AddRandomRange( 2, 2 )
		end
	end,

	RespawnPlayer = function( self, player )
		if not GetPlayerQuestHandler( player ) then return end
		local team = self.players_data[ player ].team

		local respawn_position = self:GetRespawnPosition( team )

		if isTimer( self.players_data[player].respawn_timer ) then
			killTimer( self.players_data[player].respawn_timer )
		end

		self.players_data[player].respawn_timer = setTimer(function( player )
			if not isElement( player ) then return end

			player:spawn( respawn_position, 0, player.model, 0, self.dimension )
			player.health = 100

			player:SetImmortal( true )

			setTimer(function( player )
				if not isElement( player ) then return end
				player:SetImmortal( false )
			end, 10000, 1, player)
			
		end, 10000, 1, player)
	end,

	GetVehicleRespawnPosition = function( self, team )
		if self.quest_conf.GetVehicleRespawnPosition then
			return self.quest_conf:GetVehicleRespawnPosition( self, team )
		else
			return self.quest_conf.vehicle_respawn_positions[ team ]
		end
	end,

	RespawnVehicle = function( self, vehicle, team )
		if not isElement( vehicle ) then return end
		local respawn_pos = self:GetVehicleRespawnPosition( team )

		for k,v in pairs( getVehicleOccupants( vehicle ) ) do
			removePedFromVehicle( v )
		end

		vehicle:Fix( )
		setElementPosition( vehicle, respawn_pos.x, respawn_pos.y, respawn_pos.z )
		setElementRotation( vehicle, 0, 0, respawn_pos.rz or 0 )
	end,

	GetTeamMembers = function( self, team )
		local players = { }

		for k,v in pairs( self.teams[team] ) do
			table.insert( players, v.element )
		end

		return players
	end,

	SetTask = function( self, task_title, task_name )
		triggerClientEvent( self.players_list, "OnCoopQuestTaskUpdated", resourceRoot, task_title, task_name )
	end,

	SetTeamTask = function( self, team, task_title, task_name )
		local team_members = self:GetTeamMembers( team )
		triggerClientEvent( team_members, "OnCoopQuestTaskUpdated", resourceRoot, task_title, task_name )
	end,

	SetPlayerTask = function( self, player, task_title, task_name )
		triggerClientEvent( player, "OnCoopQuestTaskUpdated", resourceRoot, task_title, task_name )
	end,

	SetTaskTimer = function( self, time, callback_func, ... )
		if isTimer( self.task_timer ) then
			killTimer( self.task_timer )
		end

		if time > 0 and callback_func then
			self.task_timer = setTimer( callback_func, time*1000, 1, ... )
		end

		triggerClientEvent( self.players_list, "OnCoopQuestTaskTimerUpdated", resourceRoot, time )
	end,

	ToggleDriveBy = function( self, state )
		for k,v in pairs( self.players_list ) do
			v:SetPrivateData( "realdriveby_disabled", not state )
		end
	end,

	destroy = function( self )
		if self.destroyed then return end

		self.destroyed = true

		if isTimer( self.task_timer ) then
			killTimer( self.task_timer )
		end

		if #self.players_list >= 1 then
			repeat
				self:RemovePlayer( self.players_list[1] )
			until 
				not next( self.players_list )
		end

		for k,v in pairs( self.quest_elements ) do
			if isElement( v ) then
				destroyElement( v )
			elseif v and v.destroy then
				v:destroy( )
			end
		end

		QUESTS_BY_ID[ self.id ] = nil

		for k,v in pairs( QUESTS_LIST ) do
			if v == self then
				table.remove( QUESTS_LIST, k )
				break
			end
		end

		setmetatable( self, nil )

		self = nil

		return true
	end,
} 

QuestHandler.__index = QuestHandler

function CreateQuestHandler( conf )
	local conf = conf or { }

	local self = setmetatable( {}, QuestHandler )
	self.id = LAST_QUEST_ID
	self:Init( )
	table.insert( QUESTS_LIST, self )
	QUESTS_BY_ID[ LAST_QUEST_ID ] = self

	LAST_QUEST_ID = ( LAST_QUEST_ID + 1 ) % 1000

	for k,v in pairs( conf ) do
		self[ k ] = v
	end

	return self
end

function GetPlayerQuestHandler( player )
	return QUESTS_BY_PLAYER[ player ]
end

function GetQuestQuestHandler( id )
	return QUESTS_BY_ID[ id ]
end

function OnPlayerQuestPreLogout_handler( )
	local quest = GetPlayerQuestHandler( source )

	if quest then
		quest:RemovePlayer( source )
	end
end

addEventHandler("onResourceStop", resourceRoot, function()
	for k,v in pairs( QUESTS_LIST ) do
		v:destroy( )
	end
end)

function OnPlayerRequestChangeTeamData( key, value, sync )
	local quest = GetPlayerQuestHandler( client )
	if quest then
		quest:SetTeamData( quest:GetPlayerTeam( client ), key, value, sync )
	end
end
addEvent( "OnPlayerRequestChangeTeamData", true )
addEventHandler( "OnPlayerRequestChangeTeamData", resourceRoot, OnPlayerRequestChangeTeamData )

function OnPlayerRequestChangeCoopQuestData( key, value )
	local quest = GetPlayerQuestHandler( client )
	if quest then
		quest:SetQuestData( quest:GetPlayerTeam( client ), key, value, sync )
	end
end
addEvent( "OnPlayerRequestChangeCoopQuestData", true )
addEventHandler( "OnPlayerRequestChangeCoopQuestData", resourceRoot, OnPlayerRequestChangeCoopQuestData )

function OnPlayerPreWasted_handler( )
	local quest = GetPlayerQuestHandler( source )

	if quest and quest:GetQuestData( "respawns_enabled" ) then
		cancelEvent( )
	end
end

function OnPlayerWasted_handler( ammo, killer, weapon )
	local quest = GetPlayerQuestHandler( source )

	if quest then
		quest:OnPlayerWasted( source, killer, weapon )
	end
end