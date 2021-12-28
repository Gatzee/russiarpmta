
TIMEOUT_SEND_INVITE = 30

LOBBY_LIST = { }

function CreateLobby( conf )
	local self = conf or { }
	for i = os.time( ), math.huge do
		if not LOBBY_LIST[ i ] then
			self.lobby_id = i
			break
		end
	end

	-- Считывание данных квеста
	local QUEST_DATA = exports[ JOB_DATA[ self.job_class ].task_resource ]:GetQuestData( )
	for k, v in pairs( QUEST_DATA ) do
		if k ~= "tasks" then
			self[ k ] = v
		end
	end

	self.participants = { }
	self.elements = { }
	self.invites_times = { }
	self.lobby_state = LOBBY_STATE_WAIT_PLAYERS
	self.search_state = SEARCH_STATE_WAIT
	self.search_start_timestamp = 0
	self.reward_bonus = 0
	self.coop_reward_bonus_mul = JOB_DATA[ self.job_class ].coop_mul or 1
	self.search_timeout = 0

	self.CalculationRewardBonus = function( self )
		local old_reward_bonus = self.reward_bonus
		if #self.participants == 1 then
			self.reward_bonus = 0
		else
			self.reward_bonus = math.round( (( 25 / self.max_players ) * #self.participants) * self.coop_reward_bonus_mul, 2 )
		end
		triggerEvent( "onServerCoopJobDataChange", resourceRoot, self.lobby_id, "reward_bonus", old_reward_bonus, self.reward_bonus )
	end

	self.ChangeRole = function( self, player, role_id )
		local fail_text = "Лобби заполнено"
		if role_id then
			if self.roles[ role_id ].license and not player:HasLicense( self.roles[ role_id ].license ) then
				self.owner:ShowError( GetHintAboutLackLicense( self.roles[ role_id ].license, self.owner == player ) )
				return false
			end
			
			player:SetJobRole( role_id, self.lobby_id )
			self:UpdateInterfacerPlayersList()
            return role_id
		else
            for k, v in pairs( self.roles ) do
                local count_players_role = self:GetCountPlayersRole( k )
				if count_players_role < v.max_count and (not v.license or player:HasLicense( v.license )) then
					player:SetJobRole( k, self.lobby_id )
					self:UpdateInterfacerPlayersList()
					return k
				elseif count_players_role < v.max_count and (v.license and not player:HasLicense( v.license )) then
					fail_text = GetHintAboutLackLicense( v.license, true )
                end
			end
		end

		return false, fail_text
	end
	
	self.GetCountPlayersRole = function( self, role_id )
        local count = 0
        for _, participant in pairs( self.participants ) do
            if participant.role == role_id then
                count = count + 1
            end
        end
        return count
	end
	
	-- Обновление списка игроков в лобби
	self.UpdateInterfacerPlayersList = function( self )
		triggerClientEvent( self.owner, "onClientUpdatePlayersCoopJobUI", resourceRoot, 
		{
			owner = self.owner,
			participants = self.participants,
			reward_bonus = self.reward_bonus,
			lobby_state  = self.lobby_state,
			search_state = self.search_state,
		} )
	end

	-- Обновление состояния кнопок приглашения, поиска..
	self.UpdateJobInterfaceButtons = function( self )
		self:RefreshCanStart()

		triggerClientEvent( self.owner, "onClientUpdateButtonsCoopJobUI", resourceRoot, 
		{
			lobby_state = self.lobby_state,
			search_state = self.search_state,
			search_start_timestamp = self.search_start_timestamp,
			is_owner = true,
			can_start = self.can_start,
		} )
	end

	self.RefreshCanStart = function( self )
		for k, v in pairs( self.roles ) do
            local count_players_role = self:GetCountPlayersRole( k )
			if count_players_role < v.min_count then
                self.can_start = false
                return false
			elseif count_players_role > v.max_count then
				self.can_start = false
				return false
            end
		end
		
		for k, v in pairs( self.participants ) do
			local can_join, text = self:IsCanJoin( v.player, true )
			if not can_join then
				self.can_start = false
				return false
			end
		end

		self.can_start = true
	end

	-----------------------------------------------------------------------------
	-- Вход/выход игрока
	-----------------------------------------------------------------------------

	self.IsCanJoin = function( self, player, is_start, show_player )
        if not is_start and (player:GetCoopJobLobbyId() or player:getData( "onshift" )) then
            return false, (show_player and "Ты" or "Игрок") .. " уже на смене"
		end
		
		local available_job_level = GetAvailableJobId( player, self.job_class )
		if not is_start and not available_job_level then
			return false, (show_player and "Тебе" or "Игроку") .. " недоступна работа"
		end

		if player:GetShiftRemainingTime() <= 0 then
			return false, (show_player and "Для тебя" or "Для игрока ") .. " нет больше работы на сегодня"
		end

		if player.dimension ~= 0 or player.interior ~= 0 then
			return false, (show_player and "Ты не можешь" or "Игрок не может") .. " принять участие из интерьера"
		end

		if player:getData( "registered_in_clan_event" ) then
			return false, (show_player and "Ты участвуешь" or "Игрок участвует") .. " в войне кланов!"
		end

		if player:getData( "jailed" ) then
			return false, (show_player and "Ты" or "Игрок") .. " в заключении"
		end

		if player:getData( "is_handcuffed" ) then
			return false, (show_player and "Ты" or "Игрок") .. " в наручниках!"
		end

		if player:getData( "in_race" ) then
			return false, (show_player and "Ты участвуешь" or "Игрок участвует") .. " в гонке!"
		end

		if player:getData( "current_event" ) or player:getData( "is_on_event" ) then
			return false, (show_player and "Ты" or "Игрок") .. " на эвенте"
		end

		if player:getData( "prewanted" ) then
			return false, (show_player and "Ты" or "Игрок") .. " в розыске"
		end

		if player:getData( "current_quest" ) then
			return false, (show_player and "Ты выполняешь" or "Игрок выполняет") .. " другую задачу!"
		end

		if player:getData( "in_clan_event_lobby" ) then
			return false, (show_player and "Ты не можешь" or "Игрок не может") .. " принять участие в данный момент"
		end

		if player:IsInFaction( ) and not player:IsOnFactionDayOff( ) then
			return false, (show_player and "Ты находишься" or "Игрок находится") .. " в фракции"
		end

		if player:getData( "tutorial" ) then
			return false, (show_player and "Ты проходишь" or "Игрок проходит") .. " обучение"
		end

		if JOB_DATA[ self.job_class ].job_join_condition then
			local result, fail_text = JOB_DATA[ self.job_class ].job_join_condition( self, player, is_start, show_player )
			if not result then
				return false, fail_text
			end
		end

        return true
	end

	self.IsSearchTimeOut = function( self )
		local timestamp = getRealTimestamp()
		if self.search_timeout > timestamp then
			return true
		end
	
		self.search_timeout = timestamp + SEARCH_TIMEOUT_TIME
		return false
	end

	self.PlayerJoin = function( self, player )
		if self.lobby_state ~= LOBBY_STATE_WAIT_PLAYERS then return false end
		
		self:CheckNewShiftDay( player )

		local can_join, error_text = self:IsCanJoin( player, false, true )
		if not can_join then
			player:ShowError( error_text )
			return false
		end
		
		local available_job_level = GetAvailableJobId( player, self.job_class )
		if not available_job_level then 
			player:ShowError( "Низкий уровень для данной работы" )
			return false 
		end

        if #self.participants == self.max_players then
            player:ShowError( "Лобби заполнено" )
			return false
		end
		
		local role, fail_text = self:ChangeRole( player )
		if not role then
			player:ShowError( fail_text ) 
			return false 
		end

		table.insert( self.participants,
		{
			player = player,
			role = role,
		} )

		player:ResetMoneyTaskEarned()
		player:SetJobClass( self.job_class )

		player:SetPrivateData( "work_lobby_id", self.lobby_id )

		self:CalculationRewardBonus( )

		if player == self.owner then
			self:UpdateJobInterfaceButtons()
		else
			triggerClientEvent( player, "OnClientReceivePhoneNotification", root, 
			{
				title   = self.title,
				special = "coop_job_leave",
				args    = { id = self.lobby_id, trigger = "onServerLeaveCoopJobLobby", owner = self.owner:GetNickName(), job_class = self.job_class },
			} )
		end

		if #self.participants == self.max_players then
			if self.start_search_time then
				self.players_search_duration = getRealTimestamp() - self.start_search_time
			end
			self.search_state = SEARCH_STATE_END
			self:DeleteInviteAllPlayers( false )
		end

		self:UpdateJobInterfaceButtons()
		self:UpdateInterfacerPlayersList()

		addEventHandler( "onPlayerPreLogout", player, onPlayerPreLogoutWaiting_handler )

		return true
	end

	self.PlayerLeave = function( self, player, reason_data )
		reason_data = reason_data or { }
		player:ResetMoneyTaskEarned()
		
		player:SetJobClass()

		if player == self.owner and self.lobby_state ~= LOBBY_STATE_START_WORK then
			reason_data.fail_type = "owner_leave_wait"
			reason_data.target_player = player
			self:Destroy( false, reason_data )
			return true
		end
		
		local player_role = player:GetJobRole()
		if not player_role then return end
		
		local count_players_role = self:GetCountPlayersRole( player_role )
		if count_players_role > self.roles[ player_role ].min_count or self.lobby_state ~= LOBBY_STATE_START_WORK then
			for k, v in pairs( self.participants ) do
				if v.player == player then
					triggerEvent( "onServerPlayerLeaveLobbyCoopQuest", resourceRoot, self.lobby_id, player, reason_data )
					removeEventHandler( "onPlayerPreLogout", player, onPlayerPreLogoutWaiting_handler )
					
					local old_participants = table.copy( self.participants )
					table.remove( self.participants, k )
					
					local removed_data = { "job_vehicle", "coop_job_role_id", "work_lobby_id" }
					for _, data_name in pairs( removed_data ) do
						player:removeData( data_name )
					end

					player:EndShift( )
					
					self:CalculationRewardBonus( )
					triggerClientEvent( player, "RC:NotificationExpired", root, self.lobby_id )
					
					if self.lobby_state == LOBBY_STATE_WAIT_PLAYERS then self:UpdateInterfacerPlayersList() end
					triggerEvent( "onServerCoopJobDataChange", resourceRoot, self.lobby_id, "participants", old_participants, self.participants )
					
					if self.lobby_state ~= LOBBY_STATE_START_WORK then
						self:UpdateJobInterfaceButtons()
					end

					break
				end
			end
		else
			reason_data.fail_type = reason_data.fail_type or "player_quit"
			reason_data.target_player = player
			self:Destroy( false, reason_data )
			return true
		end
	end

	self.PreStartWork = function( self )
		self.search_state = SEARCH_STATE_END
		self:DeleteInviteAllPlayers( false )

        for k, v in pairs( self.roles ) do
            local count_players_role = self:GetCountPlayersRole( k )
            if count_players_role < v.min_count then
                self.owner:ShowError( "Обязательные роли не заполнены" )
                return false
			elseif count_players_role > v.max_count then
				self.owner:ShowError( "Переполнение роли '" .. v.name .. "'" )
				return false
            end
		end
		
		for k, v in pairs( self.participants ) do
			local can_join, text = self:IsCanJoin( v.player, true )
			if not can_join then
				self.owner:ShowError( "Игрок \"" .. v.player:GetNickName() .. "\" не может начать смену" )
				return false
			end
		end

		if self.players_search_duration == 0 then
			local timestamp = getRealTimestamp()
			self.players_search_duration = timestamp - (self.start_search_time or timestamp)
		end

		self:StartWork()
		
		return true
	end

	self.StartWork = function( self )
		self.lobby_state = LOBBY_STATE_START_WORK

		local role_date = { }
		local function GetJobRoleStringId( role_id, player )
			if self.roles[ role_id ].divide_analytics and self.roles[ role_id ].max_count > 1 then
				role_date[ role_id ] = ( role_date[ role_id ] or 0 ) + 1
				return self.roles[ role_id ].id .. "_" .. role_date[ role_id ]
			end
			return self.roles[ role_id ].id
		end

		for k, v in pairs( self.participants ) do
			v.player:StartShift( self.city )
			v.player:SyncShift()
			v.player:HideJobUI()
			onJobStarted( v.player, self.lobby_id, GetJobRoleStringId( v.player:GetJobRole() ), v.player == self.owner, #self.participants, self.players_search_duration )
			removeEventHandler( "onPlayerPreLogout", v.player, onPlayerPreLogoutWaiting_handler )

			triggerEvent( "onPlayerSomeDo", v.player, "start_coop_work" ) -- achievements
		end

		if JOB_DATA[ self.job_class ].vehicle_data then
			CreateJobVehicle( self )
		end

		triggerEvent( JOB_DATA[ self.job_class ].onStartWork, resourceRoot, self )
		triggerEvent( "PlayeStartCoopQuest_" .. self.id, resourceRoot, self.lobby_id )
	end

	self.EndWork = function( self, reason_data )
		triggerEvent( JOB_DATA[ self.job_class ].onEndWork, resourceRoot, self.lobby_id, reason_data )
		triggerEvent( "PlayeStopCoopQuest_" .. self.id, resourceRoot, self.lobby_id, reason_data )
	end

	self.Destroy = function( self, is_show_ui, reason_data )
		if isTimer( self.send_invite_tmr ) then
			killTimer( self.send_invite_tmr )
		end

		self:EndWork( reason_data )
		
		for k, v in ipairs( self.participants ) do
			if isElement( v.player ) then
				v.player:EndShift()
				v.player:removeData( "work_lobby_id" )
				v.player:removeData( "coop_job_role_id" )
				removeEventHandler( "onPlayerPreLogout", v.player, onPlayerPreLogoutWaiting_handler )

				if not is_show_ui then
					v.player:HideJobUI()
				end
			end
		end
		self:DeleteInviteAllPlayers( true, true )

		DestroyTableElements( LOBBY_LIST[ self.lobby_id ] )
        LOBBY_LIST[ self.lobby_id ] = nil
	end
	
	self.SendInviteAllPlayers = function ( self )
		self:DeleteInviteAllPlayers( false, true )
		self.search_state = SEARCH_STATE_START
		self.search_start_timestamp = getRealTimestamp( )
		
		self:UpdateJobInterfaceButtons()
		
		self.send_invite_players = {}
		self:SendInvitePlayers()
		self.send_invite_tmr = setTimer( function()
			self:SendInvitePlayers()
		end, 5000, 0 )
	end

	self.SendInvitePlayers = function( self )
		local target_players = {}
		for k, v in ipairs( GetPlayersInGame( ) ) do
			if v ~= self.owner and not self.send_invite_players[ v ] then
				local can_join, error_text = self:IsCanJoin( v )
				if can_join then
					table.insert( target_players, v )
					self.send_invite_players[ v ] = true
				end
			end
		end

		if #target_players == 0 then return end
		self:SendInvite( target_players )
	end

	self.UpdateSuccessInvite = function( self )
		triggerClientEvent( self.owner, "onClientShowCoopJobSuccessInvite", resourceRoot, true, true )
	end

	self.SendInviteTargetPlayer = function ( self, lobby_owner, player )
		local can_join, error_text = self:IsCanJoin( player )
		if not can_join then
			if isElement( lobby_owner ) then lobby_owner:ShowError( error_text ) end
			return false
		end

		if isElement( lobby_owner ) then
			if self.invites_times[ player ] then
				if getRealTimestamp( ) - self.invites_times[ player ] < TIMEOUT_SEND_INVITE then
					lobby_owner:ShowError( "Ты уже отправил приглашение этому игроку" )
					return
				else
					triggerClientEvent( player, "RC:NotificationExpired", root, self.lobby_id )
				end
			end
			self.invites_times[ player ] = getRealTimestamp( )
			self:UpdateSuccessInvite( self.owner )
		end
		
		if not self.send_invite_players then
			self.send_invite_players = {}
		end
		self.send_invite_players[ player ] = true
		
		self:SendInvite( player )
	end

	self.SendInvite = function( self, target )
		triggerClientEvent( target, "OnClientReceivePhoneNotification", root, 
		{
			title = self.title,
			special = "coop_job_invite",
			args = { id = self.lobby_id, trigger = "onServerJoinCoopJobLobby", owner = self.owner:GetNickName(), job_class = self.job_class },
		} )
	end

	self.DeleteInviteAllPlayers = function( self, all_players, ignore_update_ui )
		
		self.send_invite_players = nil
		if isTimer( self.send_invite_tmr ) then
			killTimer( self.send_invite_tmr )
		end
		
		self.search_state = SEARCH_STATE_WAIT
		

		if not ignore_update_ui then
			self:UpdateJobInterfaceButtons()
		end

		if all_players then
			triggerClientEvent( "RC:NotificationExpired", root, self.lobby_id )
			return true
		end

		local target_players = GetPlayersInGame( )
		for i, player in ipairs( target_players ) do
			for k, v in ipairs( self.participants ) do
				if player == v.player then
					target_players[ i ] = nil
					break
				end
			end
		end
		triggerClientEvent( target_players, "RC:NotificationExpired", root, self.lobby_id ) 
	end

	self.AddJobVehicle = function( self, vehicle )
		self.job_vehicle = vehicle
		self.job_vehicle:setData( "work_lobby_id", self.lobby_id, false )
	end

	self.CheckNewShiftDay = function( self, player )
		if player:IsNewShiftDay( ) then
			player:ResetShift( )
			player:ResetEarnedToday( )
		end
	end

	self:CheckNewShiftDay( self.owner )

	local can_join, error_text = self:IsCanJoin( self.owner, false, true )
	if not can_join then
		self.owner:ShowError( error_text )
		return false
	end

	local role_id, fail_text = self:ChangeRole( self.owner )
	if not role_id then
		self.owner:ShowError( fail_text )
		return false
	end

	-----------------------------------------------------------------------------
	
	LOBBY_LIST[ self.lobby_id ] = self
	self:PlayerJoin( self.owner )
	
	return self
end

function onPlayerPreLogoutWaiting_handler()
	local lobby = GetLobbyFromElement( source )
	if not lobby then return end

	lobby:PlayerLeave( source )
end

function onServerSetJobVehicle_handler( lobby_id, job_vehicle )
	local lobby = LOBBY_LIST[ lobby_id ]
	if not lobby then return end
	
	lobby:AddJobVehicle( job_vehicle )
end
addEvent( "onServerSetJobVehicle" )
addEventHandler( "onServerSetJobVehicle", root, onServerSetJobVehicle_handler )

function PlayerFailStopCoopQuest_handler( lobby_id, fail_text, fail_type )
	local lobby = LOBBY_LIST[ lobby_id ]
	if not lobby then return end
	
	lobby:Destroy( true,
	{
		failed = true,
		fail_text = fail_text,
		fail_type = fail_type,
	} )
end
addEvent( "PlayerFailStopCoopQuest" )
addEventHandler( "PlayerFailStopCoopQuest", root, PlayerFailStopCoopQuest_handler )

function onServerStopCoopJobShift_handler( lobby_id, failed, fail_text, fail_type )
	local lobby = LOBBY_LIST[ lobby_id ]
	if not lobby then return end
	
	lobby:Destroy( true,
	{
		failed = failed,
		fail_text = fail_text,
		fail_type = fail_type,
	} )
end
addEvent( "onServerStopCoopJobShift" )
addEventHandler( "onServerStopCoopJobShift", root, onServerStopCoopJobShift_handler )

function onServerPlayerFailCoopQuest_handler( fail_text, fail_type )
	local lobby = GetLobbyFromElement( source )
    if not lobby then return false end

	lobby:PlayerLeave( source,
	{
		failed = true,
		fail_text = "Ключевой участник " .. fail_text,
		fail_type = fail_type,
	} )
	source:HideJobUI()
	
	source:ShowError( "Ты " .. fail_text )
end
addEvent( "onServerPlayerFailCoopQuest", true )
addEventHandler( "onServerPlayerFailCoopQuest", root, onServerPlayerFailCoopQuest_handler )

function onPlayerGotHandcuffed_handler( leader )
	local lobby = GetLobbyFromElement( source )
    if not lobby then return false end

	lobby:PlayerLeave( source,
	{
		failed = true,
		fail_text = "Ключевой участник был заключен в наручники",
		fail_type = "jail",
	} )
	
	source:HideJobUI()
end
addEvent( "onPlayerGotHandcuffed" )
addEventHandler( "onPlayerGotHandcuffed", root, onPlayerGotHandcuffed_handler )

function OnPlayerJailed_handler( )
	local lobby = GetLobbyFromElement( source )
    if not lobby then return false end

	lobby:PlayerLeave( source,
	{
		failed = true,
		fail_text = "Ключевой участник был заключен в тюрьму",
		fail_type = "jail",
	} )
	
	source:HideJobUI()
end
addEvent( "OnPlayerJailed" )
addEventHandler( "OnPlayerJailed", root, OnPlayerJailed_handler )
addEvent( "OnPlayerPrisoned" )
addEventHandler( "OnPlayerPrisoned", root, OnPlayerJailed_handler )

-----------------------------------------------------------------------------
-- Вспомогательный функционал
-----------------------------------------------------------------------------

function Player.SetJobRole( self, role_id, lobby_id )
	if not lobby_id then
		lobby_id = self:GetCoopJobLobbyId()
	end
	
	local lobby = LOBBY_LIST[ lobby_id ]
	if not lobby then return false end
	
	self:SetPrivateData( "coop_job_role_id", role_id )

	for _, v in ipairs( lobby.participants ) do
		if v.player == self then
			v.role = role_id
			return role_id
		end
	end

	return true
end

function Player.GetJobRole( self )
	local lobby_id = self:getData( "work_lobby_id" )
	local lobby = LOBBY_LIST[ lobby_id ]
    if not lobby then return false end

	for _, v in ipairs( lobby.participants ) do
		if v.player == self then
			return v.role
		end
	end

	return false
end

function GetLobbyFromElement( element, check_owner )
	local lobby_id = element:getData( "work_lobby_id" )
	local lobby = LOBBY_LIST[ lobby_id ]
    if not lobby then return false end

    if check_owner then
        if element == lobby.owner then
            return lobby
        else
            return false
		end
    end

	return lobby
end

function math.round( num, idp )
	local mult = 10 ^ ( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult
  end