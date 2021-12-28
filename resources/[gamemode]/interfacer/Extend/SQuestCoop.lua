QUEST_FINISH_FAIL = 1
QUEST_FINISH_SUCCESS = 2
QUEST_FINISH_RESOURCE_STOP = 3

function SQuestCoop( data )
	local self = data

	self.SetupTask = function( self, task )
		local event_end_name = self.id .. "_end_step_" .. task.id
		addEvent( event_end_name, true )
		addEventHandler( event_end_name, root, function( ... )
			local player = client or source
			local current_quest = player:getData( "current_quest" )
			iprint( event_end_name )
			if not current_quest or current_quest.id ~= self.id or current_quest.task ~= task.id then 
				return false
			end

			local lobby_id = player:GetCoopJobLobbyId()
			local role_id = player:getData( "coop_job_role_id" )
			local lobby_data = GetLobbyDataById( lobby_id )
			if not lobby_id or not role_id or not lobby_data or not lobby_data.roles_data[ role_id ] then
				return false
			end

			if not self:CompleteRoleTask( lobby_id, role_id ) then
				return false
			end

			if not self:CheckReadyAllRolesToNextTask( lobby_id ) then
				return false
			end

			local next_task_id = current_quest.task + 1

			if self.tasks[ current_quest.task ].condition_next_step then
				local result = self.tasks[ current_quest.task ].condition_next_step.server( lobby_data )
				next_task_id = result and result or next_task_id
			end

			if self.tasks[ current_quest.task ].CleanUp and self.tasks[ current_quest.task ].CleanUp.server then
				self.tasks[ current_quest.task ].CleanUp.server( lobby_data )
			end

			if isTimer( lobby_data._timer ) then  killTimer( lobby_data._timer ) end
			for k, v in pairs( lobby_data.participants ) do
				v.player:SetPrivateData( "CoopQuestTimerFail", nil, false )
				v.player:triggerEvent( self.id .. "_" .. current_quest.task .. "_CleanUpClient", resourceRoot )
			end

			lobby_data.task_id = next_task_id
			
			if self.tasks[ lobby_data.task_id ] then
				lobby_data.end_step = self.id .. "_end_step_" .. lobby_data.task_id
				self:StartServerTask( lobby_id, lobby_data.task_id )
			else
				
				lobby_data.lap_duration = getRealTimestamp() - ( lobby_data.last_lap_complete or lobby_data.job_start )
				lobby_data.last_lap_complete = getRealTimestamp()

				if self.OnAnyFinish and self.OnAnyFinish.server then
					self.OnAnyFinish.server( lobby_id, QUEST_FINISH_SUCCESS, true )
				end
				if not self.await_destroy_quest_veh then
					DestroyTemporaryQuestVehicle( lobby_id )
				end

				-- Одноразовый рейс
				lobby_data.restart_tmr = setTimer( function()
					if self.await_destroy_quest_veh then
						DestroyTemporaryQuestVehicle( lobby_id )
					end
					
					if self.one_shift then
						triggerEvent( "onServerStopCoopJobShift", root, lobby_data.lobby_id, false, nil, "success" )
					else
						triggerEvent( "PlayeStartCoopQuest_" .. QUEST_DATA.id, resourceRoot, lobby_id )
					end
				end, 3000, 1 )
			end

			for k, v in pairs( lobby_data.participants ) do
				self:PlayerCompleteTask( v.player, lobby_data )
			end
			
			if not self.tasks[ lobby_data.task_id ] then
				lobby_data.fine_tmr = setTimer( function()
					triggerEvent( "onServerCoopQuestCompleted", resourceRoot, lobby_id, lobby_data.inner_quest_vehicle_health )
				end, 3000, 1 )
			end

			self:ResetRolesData( lobby_id, lobby_data.task_id )
		end )
	end

	self.PlayerStartTask = function( self, player, task_id )
		local task = self.tasks[ task_id ]
		if not task then return false end

		local current_quest = player:getData( "current_quest" ) or { }
		current_quest.id = self.id
		current_quest.task = task.id

		local quests_data = player:GetQuestsData()
		if task_id == 1 then
			current_quest.start_time = getRealTime().timestamp

			if not quests_data.completed then 
				quests_data.completed = { } 
			end
			quests_data.completed[ self.id ] = nil
		end

		player:SetQuestsData( quests_data )
		player:SetPrivateData( "current_quest", current_quest )

		if task.Setup then
			if task.Setup.client then
				local lobby_id = player:GetCoopJobLobbyId()
				local lobby_data = GetLobbyDataById( lobby_id )
				player:triggerEvent( self.id .."_".. task.id .."_SetupClient", resourceRoot, lobby_data )
			end
		end

		return true
	end

	self.StartServerTask = function( self, lobby_id, task_id )
		local task = self.tasks[ task_id ]
		if not task then return false end
		
		local lobby_data = GetLobbyDataById( lobby_id )
		if task.Setup.server then
			task.Setup.server( lobby_data )
		end

		if isElement( lobby_data.job_vehicle ) then
			triggerEvent( "PingVehicle", lobby_data.job_vehicle )
		end
	end

	self.PlayerCompleteTask = function( self, player, lobby_data )
		local current_quest = player:getData( "current_quest" )
		if not current_quest or current_quest.id ~= self.id then
			iprint( "Ошибка завершения этапа квеста. Несоответствие идентификаторов квестов.", current_quest.id, self.id )
			return false
		end

		local task = self.tasks[ current_quest.task ]
		if not task then
			iprint( "Ошибка завершения этапа квеста. Выполняемый этап не найден.", self.id, current_quest.task )
			return false
		end

		local next_task_id = lobby_data.task_id
		if self.tasks[ next_task_id ] then
			self:PlayerStartTask( player, next_task_id )

		else
			local quests_data = player:GetQuestsData()
			if not quests_data.completed then
				quests_data.completed = { }
			end

			quests_data.completed[ self.id ] = getRealTime().timestamp

			if quests_data.failed and quests_data.failed[ self.id ] then
				quests_data.failed[ self.id ] = nil
			end

			quests_data.start, quests_data.task = nil, nil

			if not quests_data.count_completed then quests_data.count_completed = { } end
			quests_data.count_completed[ self.id ] = ( quests_data.count_completed[ self.id ] or 0 ) + 1

			player:SetQuestsData( quests_data )

			if quests_data.count_failed then
				triggerEvent( "onPlayerQuestComplete", player, self, ( quests_data.count_failed[ self.id ] or 0 ), current_quest )
			end
			
			triggerClientEvent( player, self.id .."_OnAnyFinish", resourceRoot, { success = true }, lobby_data )

			local money, exp = GiveCoopJobReward( player, lobby_data )
			triggerEvent( "onCoopJobCompletedLap", resourceRoot, player, lobby_data.lobby_id, money, exp )
			
			triggerClientEvent( player, "ShowPlayerUIQuestSuccess", root )
		end
	end

	self.StopPlayer = function( self, player, reason_data, lobby_id, is_destroy )
		local current_quest = player:getData( "current_quest" )
		local lobby_data = GetLobbyDataById( lobby_id )
		if not current_quest or current_quest.id ~= self.id then return end

		local task = self.tasks[ current_quest.task ]
		if not task then
			iprint( "Ошибка завершения квеста. Выполняемый этап не найден.", self.id, current_quest.task )
			return
		end

		if self.voice_chat then
			if not is_destroy then
				triggerEvent( "onRemoveStationSubscriber", player, lobby_id )
			end
			player:SetFactionVoiceChannel( false )
		end

		triggerClientEvent( player, "onClientRemoveChatChannelClient", player, { CHAT_TYPE_JOB } ) 
		RestorePlayerWeapon( player, lobby_id )

		triggerClientEvent( player, self.id .."_".. task.id .."_CleanUpClient", resourceRoot, reason_data )
		triggerClientEvent( player, self.id .."_OnAnyFinish", resourceRoot, reason_data, lobby_data )

		player:SetPrivateData( "current_quest", nil )
		player:SetPrivateData( "CoopQuestTimerFail", nil, false )

		if reason_data and reason_data.failed then
			local quests_data = player:GetQuestsData()
			
			if not quests_data.failed then quests_data.failed = { } end
			quests_data.failed[ self.id ] = getRealTime().timestamp

			if not quests_data.count_failed then quests_data.count_failed = { } end
			quests_data.count_failed[ self.id ] = ( quests_data.count_failed[ self.id ] or 0 ) + 1

			triggerEvent( "onPlayerQuestFail", player, self, quests_data.count_failed[ self.id ], is_crash, current_quest )

			quests_data.start = nil
			quests_data.task = nil

			player:SetQuestsData( quests_data )
		end

		player:SetBlockInteriorInteraction( false )
	end

	self.CompleteRoleTask = function( self, lobby_id, role_id )
		local lobby_data = GetLobbyDataById( lobby_id )
		if lobby_data.roles_data[ role_id ].completed_task then
			return false
		end

		if lobby_data.roles_data[ role_id ] then
			lobby_data.roles_data[ role_id ].completed_task = true
			return true
		end
		return false
	end

	self.CheckReadyAllRolesToNextTask = function( self, lobby_id )
		local lobby_data = GetLobbyDataById( lobby_id )
		for k, v in pairs( lobby_data.roles_data ) do
			if not v.completed_task then
				return false
			end
		end
		return true
	end

	self.ResetRolesData = function( self, lobby_id, task_id )
		local lobby_data = GetLobbyDataById( lobby_id )
		lobby_data.roles_data = {}
		
		if self.tasks[ task_id ] then
			for k, v in pairs( self.roles ) do
				if #GetLobbyPlayersByRole( lobby_id, k ) > 0 then
					lobby_data.roles_data[ k ] = {}
					
					if not self.tasks[ task_id ].Setup.client[ k ].fn or self.tasks[ task_id ].Setup.client[ k ].skip then
						lobby_data.roles_data[ k ].completed_task = true
					end
				end
			end
		else
			for k, v in pairs( self.roles ) do
				if #GetLobbyPlayersByRole( lobby_id, k ) > 0 then
					lobby_data.roles_data[ k ] = {}
				end
			end
		end
	end
	
	addEvent( "PlayeStartCoopQuest_" .. self.id )
	addEventHandler( "PlayeStartCoopQuest_" .. self.id, root, function( lobby_id )
		self:ResetRolesData( lobby_id, 1 )

		local lobby_data = GetLobbyDataById( lobby_id )
		lobby_data.end_step = self.id .. "_end_step_" .. 1

		self:StartServerTask( lobby_id, 1 )

		for k, v in pairs( lobby_data.participants ) do
			local current_quest = v.player:getData( "current_quest" ) or { }
			v.player:SetPrivateData( "current_quest", current_quest )
			v.player:SetBlockInteriorInteraction( true )

			self:PlayerStartTask( v.player, 1 )
			if not lobby_data.initialized then
				triggerClientEvent( v.player, "onClientAddChatChannelClient", v.player, { CHAT_TYPE_JOB }, true )
			end
		end

		if not lobby_data.initialized then
			if self.voice_chat then
				triggerEvent( "onTryCreateStation", root, lobby_id, lobby_data.owner, "Рабочий", GetLobbyPlayersByLobbyId( lobby_id ), true )
			end
		end

		lobby_data.task_id = 1
		lobby_data.initialized = true
	end )

	addEvent( "PlayeStopCoopQuest_" .. self.id, true )
	addEventHandler( "PlayeStopCoopQuest_" .. self.id, root, function( lobby_id, reason_data )
		if self.OnAnyFinish and self.OnAnyFinish.server then
			self.OnAnyFinish.server( lobby_id, QUEST_FINISH_SUCCESS )
		end
		
		if self.voice_chat then
			triggerEvent( "onTryRemoveStation", root, lobby_id )
		end
		
		DestroyTemporaryQuestVehicle( lobby_id )

		local lobby_data = GetLobbyDataById( lobby_id )
		if lobby_data then
			for k, v in pairs( lobby_data.participants ) do
				if isElement( v.player ) then
					self:StopPlayer( v.player, reason_data, lobby_id, true )
				end
			end
			DestroyLobbyData( lobby_id )
		end
	end )

	function onServerPlayerLeaveLobbyCoopQuest_handler( lobby_id, player )
		local lobby_data = GetLobbyDataById( lobby_id )
		if not lobby_data then return end
	
		self:StopPlayer( player, nil, lobby_id )
	end
	addEvent( "onServerPlayerLeaveLobbyCoopQuest" )
	addEventHandler( "onServerPlayerLeaveLobbyCoopQuest", root, onServerPlayerLeaveLobbyCoopQuest_handler )

	self.OnResourceStop = function()
		for k, v in pairs( LOBBY_DATA ) do
			if self.OnAnyFinish and self.OnAnyFinish.server then
				self.OnAnyFinish.server( k, QUEST_FINISH_RESOURCE_STOP )
			end
			DestroyTemporaryQuestVehicle( k )
			DestroyLobbyData( k )
		end

		for k, v in ipairs( getElementsByType( "player" ) ) do
			if v:IsInGame() then
				local current_quest = v:getData( "current_quest" )
				if current_quest and current_quest.id == self.id then
					local task = self.tasks[ current_quest.task ]
					if not task then return end

					v:SetPrivateData( "current_quest", nil )
					v:ShowInfo( "Приносим свои извинения, задача была перезапущена сервером" )
				end
			end
		end

	end
	addEventHandler( "onResourceStop", resourceRoot, self.OnResourceStop )
	
	for i, task in pairs( self.tasks ) do
		task.id = i
		self:SetupTask( task )
	end

	local max_players = 0
	for k, v in pairs( QUEST_DATA.roles ) do
	    max_players = max_players + v.max_count
	end

	QUEST_DATA.max_players = max_players

	return self
end

function GiveCoopJobReward( player, lobby_data )
	local job_class, job_level = player:GetJobClass(), exports.nrp_job_coop_controller:GetAvailableJobId( player, lobby_data.job_class )
	if job_class ~= lobby_data.job_class then return false end

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_level )
	money = math.floor( money * player:GetJobMoneyBonusMultiplier( ) * ( player:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( player:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( player:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )
	
	local rewards = {}
	local coop_coefficient = 1 + tonumber( string.format("%." .. 3 .. "f", lobby_data.reward_bonus / 100) )
	if exp and exp > 0 then
		exp = player:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		
		exp = math.floor( exp * coop_coefficient * (lobby_data.percent_increase_reward_for_job_conditions or 1) ) 
		
		exp = player:GiveExp( exp, JOB_ID[ job_class ] .. "_" .. job_level )
		table.insert(rewards, { type = "exp", value = exp })
	end
	
	if money and money > 0 then 
		local money_with_gov, money_real, money_gov = 0, 0, 0
		if not QUEST_DATA.ignore_increase_mayor then
			money_with_gov, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetJobGovEconomyPercent( player:GetShiftCity(), money )
		end
		
		money = math.floor( money * coop_coefficient * (lobby_data.percent_increase_reward_for_job_conditions or 1) ) + money_gov

		player:GiveMoney( money, "job_salary", JOB_ID[ job_class ] )
		table.insert( rewards, { type = "soft", value = money } )

		triggerEvent( "onJobEarnMoney", player, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onCoopJobEarnMoney", player, money )
	end
	
	if #rewards > 0 then
		player:PlaySound( SOUND_TYPE_2D, ":nrp_shop/sfx/reward_small.mp3" )
		player:ShowRewards( unpack( rewards ) )
	end

	if not lobby_data.sum_data then lobby_data.sum_data = {} end
	if not lobby_data.sum_data[ player ] then lobby_data.sum_data[ player ] = {} end

	lobby_data.sum_data[ player ].receive_sum = (lobby_data.sum_data[ player ].receive_sum or 0) + (money or 0)
	lobby_data.sum_data[ player ].exp_sum     = (lobby_data.sum_data[ player ].exp_sum or 0) + (exp or 0)

	return money, exp
end

---------------------------------------------------------------------------------

LOBBY_DATA = {}

function CreateLobbyData( lobby_id, conf )
	LOBBY_DATA[ lobby_id ] = conf or {}
	LOBBY_DATA[ lobby_id ].job_start = getRealTimestamp()
	SavePlayersWeapon( lobby_id )
	return LOBBY_DATA[ lobby_id ]
end

function DestroyLobbyData( lobby_id )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end
	
	DestroyTableElements( lobby_data )
	LOBBY_DATA[ lobby_id ] = nil
end

-- Получить лобби по ID
function GetLobbyDataById( lobby_id )
	return LOBBY_DATA[ lobby_id ]
end

-- Получить лобби по игроку
function GetLobbyDataByPlayer( player )
	if not isElement( player ) then return false end

	local lobby_id = player:GetCoopJobLobbyId()
	if not lobby_id then return false end

	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return false end

	return lobby_data
end

-- Получить игроков по id лобби
function GetLobbyPlayersByLobbyId( lobby_id )
	local players = {}
	if not LOBBY_DATA[ lobby_id ] then return end

	for k, v in pairs( LOBBY_DATA[ lobby_id ].participants ) do
		table.insert( players, v.player )
	end

	return players
end

-- Получить игроков из лобби по их роли
function GetLobbyPlayersByRole( lobby_id, role, is_single )
	if not LOBBY_DATA[ lobby_id ] then return end

	local players = {}
	for k, v in pairs( LOBBY_DATA[ lobby_id ].participants ) do
		if v.role == role then
			if is_single then return v.player end
			table.insert( players, v.player )
		end
	end

	return players
end

function GetPlayerData( lobby_id, player )
	if not LOBBY_DATA[ lobby_id ] then return end

	for k, v in pairs( LOBBY_DATA[ lobby_id ].participants ) do
		if v.player == player then
			return v
		end
	end

	return false
end

-- TODO: Переместить конфиг оружия в роли квеста
function SavePlayersWeapon( lobby_id )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data or not lobby_data.job_weapon then return end

	lobby_data.armor = {}
	lobby_data.weapons = {}

	for k, v in pairs( lobby_data.participants ) do
		lobby_data.armor[ v.player ] = v.player.armor
		
		lobby_data.weapons[ v.player ] = {}

		local player_role = v.player:GetCoopJobRole()
		local role_weapon = lobby_data.job_weapon[ player_role ]

		if role_weapon then
			for _, weapon_data in pairs( role_weapon ) do
				local slot_id = getSlotFromWeapon( weapon_data[ 1 ] )
				local weapon = getPedWeapon( v.player, slot_id )
				if weapon ~= 0 then
					local ammo = getPedTotalAmmo( v.player, slot_id )
					table.insert( lobby_data.weapons[ v.player ], { weapon, ammo } )
				end
			end
		end
	end
end

function RestorePlayerWeapon( player, lobby_id )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data or not lobby_data.job_weapon then return end

	player.armor = lobby_data.armor[ player ]

	local player_role = player:GetCoopJobRole()
	TakeWeaponsFromTable( player, lobby_data.job_weapon[ player_role ] )
	GiveWeaponsFromTable( player, lobby_data.weapons[ player ], false, "restore_weapon" )
	
	lobby_data.armor[ player ] = nil
	lobby_data.weapons[ player ]= nil
end

function GiveWeaponsFromTable( player, weapon_table, temporary, reason )
	if not weapon_table or #weapon_table == 0 then return end
	
	for k,v in pairs( weapon_table ) do
		player:GiveWeapon( v[ 1 ], v[ 2 ] or 1, true, temporary, reason )
	end
end

function TakeWeaponsFromTable( player, weapon_table )
	if not weapon_table or #weapon_table == 0 then return end
	
	for k,v in pairs( weapon_table ) do
		player:TakeWeapon( v[ 1 ] )
	end
end

function onServerCoopJobDataChange_handler( lobby_id, key, old_data, new_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	lobby_data[ key ] = new_data
end
addEvent( "onServerCoopJobDataChange" )
addEventHandler( "onServerCoopJobDataChange", root, onServerCoopJobDataChange_handler )


-----------------------------------------------------------------------------
-- Вспомогательный функционал
-----------------------------------------------------------------------------

-- Показать сообщение всем игрокам лобби
function ShowInfoMessageQuestPlayers( lobby_id, role, func_condition, msg )
	if not lobby_id then return false end

	local players = role and GetLobbyPlayersByLobbyId( lobby_id ) or GetLobbyPlayersByRole( lobby_id, role )
	for k, v in pairs( players ) do
		if func_condition( v ) then
			v:ShowInfo( msg )
		end
	end
end

-- Запуск общего таймера для всех игроков
function StartCoopQuestTimerWait( players, lobby_id, time, name, fail_text, event_to_end, func_succ )
	if not players or #players == 0 or not lobby_id or time < 50 then
		return false
	end

	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return false end

	if isTimer( lobby_data._timer ) then 
		killTimer( lobby_data._timer ) 
	end
	
	lobby_data._timer = Timer( function( )
		if not lobby_data then return false end

		local success = true
		if func_succ then success = func_succ( ) end

		if success and event_to_end then
			for k, v in pairs( players ) do
				if isElement( v ) and v:GetCoopJobLobbyId() == lobby_id then
					v:SetPrivateData( "CoopQuestTimerFail", false )
				end
			end
			
			local completed_roles = {}
			for k, v in pairs( players ) do
				if isElement( v ) and v:GetCoopJobLobbyId() == lobby_id then
					local role_id = v:getData( "coop_job_role_id" )
					if not completed_roles[ role_id ] then
						completed_roles[ role_id ] = true
						triggerEvent( event_to_end, v )
					end
				end
			end
		else
			for k, v in pairs( players ) do
				if isElement( v ) and v:GetCoopJobLobbyId() == lobby_id then
					v:SetPrivateData( "CoopQuestTimerFail", false )
				end
			end
			triggerEvent( "PlayerFailStopCoopQuest", resourceRoot, lobby_data.lobby_id, fail_text or "Вы не успели за отведенное время", "time_out" )
		end
	end, time, 1 )

	local unique_name = not name and true or false
	for k, v in pairs( players ) do
		if v:GetCoopJobLobbyId() == lobby_id then
			if unique_name then
				local role_id = v:getData( "coop_job_role_id" )
				name = QUEST_DATA.tasks[ lobby_data.task_id ].Setup.client[ role_id ].name or "Тра-та-та-там"
			end
			v:SetPrivateData( "CoopQuestTimerFail", { name, math.floor( time / 1000 ) } )
		end
	end

end

-- Создать временное авто в лобби
function CreateTemporaryQuestVehicle( lobby_id, vehicle_id, vehicle_pos, vehicle_rot )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then 
		return false
	end

	local vehicle = Vehicle.CreateTemporary( vehicle_id, vehicle_pos.x, vehicle_pos.y, vehicle_pos.z, vehicle_rot.x, vehicle_rot.y, vehicle_rot.z )

	if not lobby_data.quest_vehicles then
		lobby_data.quest_vehicles = {}
	end
	table.insert( lobby_data.quest_vehicles, vehicle )

	vehicle:setData( "quest_vehicle", true, false )
	vehicle:setData( "work_lobby_id", lobby_id, false )

	return vehicle
end

-- Уничтожения все временные авто
function DestroyTemporaryQuestVehicle( lobby_id )
	
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data or not lobby_data.quest_vehicles then return false end

	for k, v in pairs( lobby_data.quest_vehicles ) do
		if isElement( v ) then
			Vehicle.DestroyTemporary( v )
		end
	end
end