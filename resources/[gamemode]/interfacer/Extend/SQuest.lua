-- SQuest.lua
Import( "SPlayer" )
Import( "SVehicle" )
Import( "ShVehicleConfig" )

REGISTERED_QUESTS_REVERSE = {}

CONST_TIMEOUT_START_QUEST_SEC = 5

for k, v in pairs( REGISTERED_QUESTS ) do
	REGISTERED_QUESTS_REVERSE[ v ] = true
end

function SQuest( data )
	local self = data

	if self.training_id then
		self.id = "training_".. self.training_id .."_".. self.training_role
	end

	self.SetupTask = function( self, task )
		local event_end_name = task.event_end_name or ( self.id .."_end_step_".. task.id )
		addEvent( event_end_name, true )
		addEventHandler( event_end_name, root, function( ... )
			player = client or source
			if not isElement(player) then return end


			local current_quest = player:getData( "current_quest" )
			if not current_quest or current_quest.id ~= self.id or current_quest.task ~= task.id then return end

			if task.event_end_handler and not task.event_end_handler( player, ... ) then return end

			self:PlayerEndTask( player )
		end)

		if task.requests then
			for _, info in ipairs( task.requests ) do
				local request_name = "requests_training_".. self.training_id .."_".. info[ 1 ] .."_end_step_".. info[ 2 ]

				addEvent( request_name )
				addEventHandler( request_name, root, function()
					player = source
					if not isElement(player) then return end

					local current_quest = player:getData( "current_quest" )
					if not current_quest or current_quest.id ~= self.id then return end

					if not current_quest.requests_received then
						current_quest.requests_received = {}
					end

					local request_name = info[ 1 ] .."_".. info[ 2 ]
					if not current_quest.requests_received[ request_name ] then
						current_quest.requests_received[ request_name ] = true

						player:SetPrivateData( "current_quest", current_quest )

						if current_quest.task == task.id then
							self:PlayerStartTask( player, task.id )
						end
					end
				end)
			end
		end
	end

	self.isFactionTask = function ( self, player )
		local faction_id = player:GetFaction( )
		for i, id in pairs( REGISTERED_FACTIONS_TASKS[ faction_id ] or { } ) do
			if "task_" .. id == self.id then
				return true, faction_id
			end
		end

		return false
	end

	self.PlayerStartTask = function( self, player, task_id )
		local task = self.tasks[ task_id ]
		if not task then return false end

		local current_quest = player:getData( "current_quest" ) or { }
		current_quest.id = self.id
		current_quest.task = task.id
		current_quest.is_company_quest = self.is_company_quest

		local quests_data = player:GetQuestsData()

		if self.tutorial then
			quests_data.start = self.id
			quests_data.task = task_id
		end

		if task_id == 1 then
			current_quest.start_time = getRealTimestamp( )

			if not quests_data.completed then quests_data.completed = { } end
			quests_data.completed[ self.id ] = nil
		end

		player:SetQuestsData( quests_data )

		if self:PlayerCheckTaskRequests( player, task, current_quest ) then
			--current_quest.requests_received = nil
			player:SetPrivateData( "current_quest", current_quest )

			if task.Setup then
				if task.Setup.client then
					player:triggerEvent( self.id .."_".. task.id .."_SetupClient", resourceRoot, current_quest.custom_data )
				end

				if task.Setup.server then
					task.Setup.server( player, current_quest.custom_data )
				end
			end
		else
			current_quest.wait_requests = true
			player:SetPrivateData( "current_quest", current_quest )
		end

		-- analytics
		local is_faction_quest, faction_id = self:isFactionTask( player )
		if is_faction_quest then
			SendElasticGameEvent( player:GetClientID( ), "faction_quest_take", {
				faction_id = FACTIONS_ENG_NAMES[ faction_id ],
				quest_id = self.id,
				rank_num = player:GetFactionLevel( ),
			} )
		end

		return true
	end

	self.PlayerCheckTaskRequests = function( self, player, task, current_quest )
		local continue = true

		if task.requests then
			if current_quest.requests_received then
				for _, info in ipairs( task.requests ) do
					local request_name = info[ 1 ] .."_".. info[ 2 ]
					if not current_quest.requests_received[ request_name ] then
						continue = false
						break
					end
				end
			else
				continue = false
			end
		end

		return continue
	end

	self.CheckPlayerCanStart = function( self, player )
		local quest_start_timeout_ts = player:getData( "quest_start_timeout_ts" ) or 0
		if self.is_company_quest and quest_start_timeout_ts > getRealTimestamp() then
			return false
		end

		if player:GetOnShift() and REGISTERED_QUESTS_REVERSE[ self.id ] then
			return false, "Ты находишься на смене"
		end

		if self.is_company_quest and (player:getData( "jailed" ) or player:getData( "is_handcuffed" )) then
			return false, "Ты находишься в заключении"
		end

		local current_quest = player:getData( "current_quest" )
		if current_quest then
			return false, "Ты уже выполняешь другой квест"
		end

		local quests_data = player:GetQuestsData()
		if quests_data.completed and quests_data.completed[ self.id ] then
			if self.replay_timeout then
				if ( quests_data.completed[ self.id ] + self.replay_timeout ) > getRealTimestamp( ) then
					return false, "Подожди немного, чтобы начать этот квест снова"
				end
			elseif not self.training_id then
				return false, "Ты уже выполнил этот квест"
			end
		end

		if quests_data.failed and quests_data.failed[ self.id ] and self.failed_timeout then
			if ( quests_data.failed[ self.id ] + self.failed_timeout ) > getRealTimestamp( ) then
				return false, "Подожди немного, чтобы начать этот квест снова"
			end
		end

		if self.level_request and self.level_request > player:GetLevel( ) then
			return false, "Требуется ".. self.level_request .." уровень"
		end

		if self.quests_request and not player:getData( "ignore_quests_request" ) then
			local completed = quests_data.completed or { }
			for _, quest_name in pairs( self.quests_request ) do
				-- Завершение одного из двух квестов (для сегментации)
				if type( quest_name ) == "table" then
					local found_any_quest = false
					for i, v in pairs( quest_name ) do
						if completed[ v ] then
							found_any_quest = true
							break
						end
					end
					if not found_any_quest then
						return false, "Сначала выполни другие доступные квесты"
					end
				-- Завершение конкретного квеста
				elseif not ( completed[ quest_name ] ) then
					return false, "Сначала выполни другие доступные квесты"
				end
			end
		end

		if self.CheckToStart then
			return self.CheckToStart( player )
		end

		return true
	end

	self.PlayerEndTask = function( self, player )
		local current_quest = player:getData( "current_quest" )
		if not current_quest or current_quest.id ~= self.id then
			iprint("Ошибка завершения этапа квеста. Несоответствие идентификаторов квестов.", current_quest.id, self.id)
			return
		end

		local task = self.tasks[ current_quest.task ]
		if not task then
			iprint("Ошибка завершения этапа квеста. Выполняемый этап не найден.", self.id, current_quest.task)
			return
		end

		if not self.tasks[ current_quest.task + 1 ] then
			local last_end_tasks = player:getData( "last_end_tasks" ) or { }
			local timestamp = getRealTimestamp()
			if last_end_tasks[ self.id ] then
				if timestamp - last_end_tasks[ self.id ] < 5 then
					triggerEvent( "DetectPlayerAC", player, "69" )
					return
				end
			end

			last_end_tasks[ self.id ] = timestamp
			player:setData( "last_end_tasks", last_end_tasks, false )
		end

		local save_dimension = player:getData( "quest_save_dim" )
		if save_dimension then
			player.dimension = save_dimension
			player:setData( "quest_save_dim", false, false )
		end

		if task.CleanUp and task.CleanUp.server then
			local success, err = pcall( task.CleanUp.server, player, current_quest.custom_data )
			if not success then
				outputDebugString( "Error in Quest CleanUp.server: " .. tostring( err ), 1 )
			end
		end

		player:triggerEvent( self.id .."_".. task.id .."_CleanUpClient", resourceRoot, current_quest.custom_data )

		local training_members = player:getData( "training_members" )
		if self.training_id and training_members then
			for slot, member in pairs( training_members ) do
				if isElement( member ) then
					triggerEvent( "requests_".. self.id .."_end_step_".. task.id, member )
				else
					training_members[ slot ] = nil
				end
			end
			player:setData( "training_members", training_members, false )
		end

		if self.tasks[ current_quest.task + 1 ] then
			self:PlayerStartTask( player, current_quest.task + 1 )

		else
			self:RemovePlayerQuestHandlers( player )
			
			local quests_data = player:GetQuestsData()
			if not quests_data.completed then
				quests_data.completed = { }
			end

			if self.training_id and training_members then
				for _, member in pairs( training_members ) do
					if isElement( member ) then
						local member_training_members = member:getData( "training_members" )
						if member_training_members then
							member_training_members[ current_quest.custom_data.slot ] = nil
							member:setData( "training_members", member_training_members, false )
						end
					end
				end
			end

			player:setData( "training_members", false, false )

			quests_data.completed[ self.id ] = getRealTimestamp( )

			if quests_data.failed and quests_data.failed[ self.id ] then
				quests_data.failed[ self.id ] = nil
			end

			quests_data.start = nil
			quests_data.task = nil

			if not quests_data.count_completed then quests_data.count_completed = { } end
			quests_data.count_completed[ self.id ] = ( quests_data.count_completed[ self.id ] or 0 ) + 1

			player:SetQuestsData( quests_data )
			player:SetPrivateData( "current_quest", nil )

			if quests_data.count_failed then
				if self.is_company_quest then
					self:SendCompanyQuestAnalytics( player, quests_data.count_failed[ self.id ], "complete", "Завершён" )
				end
				triggerEvent( "onPlayerQuestComplete", player, self, ( quests_data.count_failed[ self.id ] or 0 ), current_quest )
			end
			
			if self.show_new_rewards  then
				triggerClientEvent( player, "ShowPlayerUIQuestSuccess", root, self.id )
			elseif not self.no_show_success then
				triggerClientEvent( player, "ShowPlayerUIQuestSuccess", root )
			end

			DestroyTemporaryQuestVehicle( player )
			CleanUpQuestElements( player )

			if self.is_company_quest then
				player:SetBlockInteriorInteraction( false )
			end

			local faction_exp = 0
			if self.rewards then
				local rewards = { }

				for name, value in pairs( self.rewards ) do
					if type( value ) == "function" then
						value = value( player )
					end

					-- source_class: GiveMoney&GiveDonate "quest_complete" to company_quest
					if (not player:getData( "economy_hard_test" ) and name == "money") or (player:getData( "economy_hard_test" ) and name == "money_hard_test") then
						value = player:IsPremiumActive() and PREMIUM_SETTINGS.fQuestsMoneyMul * value or value
						player:GiveMoney( value, "quest_complete", self.id )
					
					
					elseif name == "donate" then
						player:GiveDonate( value, "quest_complete", self.id )

					elseif name == "exp" then
						value = player:IsPremiumActive() and PREMIUM_SETTINGS.fQuestsExpMul * value or value
						player:GiveExp( value, "Quests.".. self.id )

					elseif name == "military_exp" then
						player:GiveMilitaryExp( value, "Quests.".. self.id )

					elseif name == "faction_exp" then
						value = player:IsPremiumActive( ) and PREMIUM_SETTINGS.fFactionExpMul * value or value
						player:GiveFactionExp( value, "Quests.".. self.id )
					elseif name == "wof_coin_gold" then
						client:GiveCoins( value, "gold", "Quests.".. self.id, "NRPDszx5x" )
					elseif name == "firstaid" then
						player:InventoryAddItem( IN_FIRSTAID, nil, value )
					elseif name == "repairbox" then
						player:InventoryAddItem( IN_REPAIRBOX, nil, value )
					end

					if not self.no_show_rewards then
						table.insert( rewards, { type = name, value = value } )
					end
				end
				
				if #rewards > 0 and not self.show_new_rewards then
					player:ShowRewards( unpack( rewards ) )
				end
			end

			if self.GiveReward then
				self.GiveReward( player )
			end

			if self.OnAnyFinish and self.OnAnyFinish.server then
				self.OnAnyFinish.server( player, "fail", reason_data, reason_data and reason_data.fail_text )
			end

			triggerClientEvent( player, self.id .."_OnAnyFinish", resourceRoot, "fail", reason_data, reason_data and reason_data.fail_text )

			if self.training_id and not self.training_uncritical then
				triggerEvent( "onPlayerTrainingComplete", player, self.training_id, faction_exp )
			end

			-- analytics
			local is_faction_quest, faction_id = self:isFactionTask( player )
			if is_faction_quest then
				SendElasticGameEvent( player:GetClientID( ), "faction_quest_finish", {
					faction_id = FACTIONS_ENG_NAMES[ faction_id ],
					quest_id = self.id,
					rank_num = player:GetFactionLevel( ),
					exp_sum = faction_exp,
					is_complete = "true",
				} )
			end

			triggerEvent( "onPlayerSomeDo", player, "finish_task" ) -- achievements
		end
	end

	self.SendCompanyQuestAnalytics = function( self, player, try_num, finish_reason, finish_reason_text )
		local rewards = self.rewards or {}
			
		local reward_id = nil
		for k, v in pairs( rewards ) do
			if k ~= "money" and k ~= "exp" and k ~= "donate" then
				reward_id = k
				break
			end
		end
			
		local try_num = try_num or 0
		
		local time_to_finish = getRealTimestamp( ) - (getElementData(source, "quest_start_date") or 0)
		triggerEvent( "onPlayerQuestFinish", player, self, reward_id, rewards.money, rewards.donate, rewards.exp, try_num, time_to_finish, finish_reason, finish_reason_text )
	end

	self.HanderEventStopPlayer = function( reason )
		local sessions_is_crash = {
			[ "Timed out" ] = true,
			[ "Bad Connection" ] = true,
		}

		self:StopPlayer( source, { type = sessions_is_crash[ reason ] and "crash" or "logout" }, sessions_is_crash[ reason ] or false )
	end

	self.HanderEventPlayerFailStopQuest = function( reason_data )
		if type( reason_data ) == "string" then
			reason_data = { fail_text = reason_data, type = "quest_fail" }
		end

		self:StopPlayer( source, reason_data or { type = "quest_fail" } )
	end

	self.HanderEventPlayerWasted = function( ammo, attacker, weapon, bodypart )
		self:StopPlayer( source, {
			type = "fail_wasted";

			ammo = ammo;
			attacker = attacker;
			weapon = weapon;
			bodypart = bodypart;

			fail_text = "Вы погибли";
		} )
	end

	addEvent( "PlayerFailStopQuest", true )
	addEvent( "OnPlayerFailedQuest" )

	self.AddPlayerQuestHandlers = function( self, player )
		self:RemovePlayerQuestHandlers( player )

		addEventHandler( "PlayerFailStopQuest", player, self.HanderEventPlayerFailStopQuest )
		addEventHandler( "onPlayerPreLogout", player, self.HanderEventStopPlayer )

		if not self.tutorial then
			addEventHandler( "onPlayerWasted", player, self.HanderEventPlayerWasted )
		end
	end

	self.RemovePlayerQuestHandlers = function( self, player )
		removeEventHandler( "PlayerFailStopQuest", player, self.HanderEventPlayerFailStopQuest )
		removeEventHandler( "onPlayerPreLogout", player, self.HanderEventStopPlayer )

		if not self.tutorial then
			removeEventHandler( "onPlayerWasted", player, self.HanderEventPlayerWasted )
		end
	end

	self.StopPlayer = function( self, player, reason_data, is_crash_ )
		local current_quest = player:getData( "current_quest" )
		if not current_quest or current_quest.id ~= self.id then return end

		local task = self.tasks[ current_quest.task ]
		if not task then
			iprint("Ошибка завершения квеста. Выполняемый этап не найден.", self.id, current_quest.task)
			return
		end

		local quests_data = player:GetQuestsData()
		if self.is_company_quest then
			self:SendCompanyQuestAnalytics( player, quests_data.count_failed[ self.id ], tostring( reason_data and reason_data.type ), tostring( reason_data and reason_data.fail_text ) )
		end

		local training_members = player:getData( "training_members" )
		local training_failed = self.training_id and not self.training_uncritical and training_members and ( not self.training_critical_last_task or current_quest.task <= self.training_critical_last_task )
		triggerEvent( "OnPlayerFailedQuest", player, training_failed )
		
		player:SetBlockInteriorInteraction( false )
		player:SetBlockCleanupMemory( false )
		self:RemovePlayerQuestHandlers( player )

		local current_quest = player:getData( "current_quest" ) or { }

		player:triggerEvent( self.id .."_".. task.id .."_CleanUpClient", resourceRoot, current_quest.custom_data, reason_data )

		if not current_quest.wait_requests then
			local save_dimension = player:getData( "quest_save_dim" )
			if save_dimension then
				player.dimension = save_dimension
				player:setData( "quest_save_dim", false, false )
			end

			if task.CleanUp and task.CleanUp.server then
				task.CleanUp.server( player, current_quest.custom_data, reason_data )
			end
		end

		if self.OnAnyFinish and self.OnAnyFinish.server then
			iprint( "REASON DATA", reason_data )
			self.OnAnyFinish.server( player, "success", reason_data, reason_data.fail_text )
		end
		triggerClientEvent( player, self.id .."_OnAnyFinish", resourceRoot, "success", reason_data, reason_data.fail_text )

		DestroyTemporaryQuestVehicle( player )
		CleanUpQuestElements( player )
		
		player:SetPrivateData( "current_quest", nil )

		if self.tutorial then
			return
		end

		if training_failed then
			triggerEvent( "onPlayerTrainingFailed", root, self.training_id )

			for _, member in pairs( training_members ) do
				if isElement( member ) then
					member:setData( "training_members", false, false )
					triggerEvent( "PlayerFailStopQuest", member, { type = "quest_fail", fail_text = "Кто-то из участников не справился со своей задачей" } )
				end
			end
		end

		player:setData( "training_members", false, false )

		if not quests_data.failed then quests_data.failed = { } end
		quests_data.failed[ self.id ] = getRealTimestamp( )

		if not quests_data.count_failed then quests_data.count_failed = { } end
		quests_data.count_failed[ self.id ] = ( quests_data.count_failed[ self.id ] or 0 ) + 1

		triggerEvent( "onPlayerQuestFail", player, self, quests_data.count_failed[ self.id ], is_crash, current_quest )

		quests_data.start = nil
		quests_data.task = nil

		player:SetQuestsData( quests_data )
		player:SetPrivateData( "current_quest" )

		if self.self_restart then
			setTimer(function( id, player )
				if not isElement(player) then return end
				triggerEvent( "PlayeStartQuest_"..id, player )
			end, 10000, 1, self.id, player)
		end

		-- analytics
		local is_faction_quest, faction_id = self:isFactionTask( player )
		if is_faction_quest then
			SendElasticGameEvent( player:GetClientID( ), "faction_quest_finish", {
				faction_id = FACTIONS_ENG_NAMES[ faction_id ],
				quest_id = self.id,
				rank_num = player:GetFactionLevel( ),
				exp_sum = 0,
				is_complete = "false",
			} )
		end
	end

	for i, task in pairs( self.tasks ) do
		task.id = i

		self:SetupTask( task )
	end

	addEvent( "PlayeStartTaskQuest_".. self.id )
	addEventHandler( "PlayeStartTaskQuest_".. self.id, root, function( task_id )
		local started = self:PlayerStartTask( source, task_id )

		if started then
			self:AddPlayerQuestHandlers( source )
		end
	end )

	addEvent( "PlayeStartQuest_".. self.id, true )
	addEventHandler( "PlayeStartQuest_".. self.id, root, function( custom_data, is_restart )
		--if not client then return end
		local player = client or source

		local check, result = self:CheckPlayerCanStart( player, 1 )
		if not check then
			if result then
				player:ShowError( result )
			end

			return
		end

		if is_restart and self.restart_position then
			player:removeFromVehicle()
			local spawn__position = self.restart_position + Vector3(math.random(-2, 2), math.random(-2, 2), 0) 
			player:setPosition( spawn__position, true )
		end

		if self.is_company_quest then
			player:SetBlockInteriorInteraction( true )
			player:SetBlockCleanupMemory( true )
		end

		if self.training_id then
			custom_data.members[ custom_data.slot ] = nil
			player:setData( "training_members", custom_data.members, false )
			custom_data.members = nil

			triggerEvent( "onPlayerFactionTrainingStart", player, self.training_id )
		end

		local current_quest = player:getData( "current_quest" ) or { }
		current_quest.custom_data = custom_data
		current_quest.is_company_quest = self.is_company_quest
		player:SetPrivateData( "current_quest", current_quest )

		local started = self:PlayerStartTask( player, 1 )
		local quests_data = player:GetQuestsData()
		if started then
			self:AddPlayerQuestHandlers( player )
			if self.is_company_quest then
				triggerEvent( "onPlayerQuestStart", player, self, ( quests_data.count_failed[ self.id ] or 0 ) + 1 )
			end
			if self.is_company_quest then
				player:setData( "quest_start_timeout_ts", getRealTimestamp() + CONST_TIMEOUT_START_QUEST_SEC, false )
			end
		end
	end )

	addEvent( "PlayeStopQuest_".. self.id, true )
	addEventHandler( "PlayeStopQuest_".. self.id, root, function()
		--if not client then return end
		local player = client or source

		self:StopPlayer( player, { type = "quest_stop", fail_text = "Квест остановлен" } )
	end )

	if self.tutorial then
		Timer( function()
			local players = getElementsByType( "player" )
			for _, player in ipairs( players ) do
				if player:IsInGame() then
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == self.id then
						local started = self:PlayerStartTask( player, current_quest.task or 1 )

						if started then
							self:AddPlayerQuestHandlers( player )
						end
					end
				end
			end
		end, 4000, 1 )

		addEvent( "onPlayerVehiclesLoad", true )
		addEventHandler( "onPlayerVehiclesLoad", root, function()
			local current_quest = source:getData( "current_quest" )
			if current_quest then return end

			local quests_data = source:GetQuestsData()
			if type( quests_data ) == "table" and quests_data.start and quests_data.start == self.id then
				triggerEvent( "PlayeStartTaskQuest_" .. quests_data.start, source, quests_data.task )
				return
			end
		end )
	end

	addEventHandler( "onResourceStop", resourceRoot, function()
		local players = getElementsByType( "player" )
		for _, player in ipairs( players ) do
			if player:IsInGame() then
				local current_quest = player:getData( "current_quest" )
				if current_quest and current_quest.id == self.id then
					local task = self.tasks[ current_quest.task ]
					if not task then return end

					local current_quest = player:getData( "current_quest" )
					if not current_quest.wait_requests then
						local save_dimension = player:getData( "quest_save_dim" )
						if save_dimension then
							player.dimension = save_dimension
							player:setData( "quest_save_dim", false, false )
						end

						if task.CleanUp and task.CleanUp.server then
							task.CleanUp.server( player, current_quest.custom_data, { type = "resource" } )
						end
					end

					if self.OnAnyFinish and self.OnAnyFinish.server then
						self.OnAnyFinish.server( player, true, "resource_stop" )
					end

					DestroyTemporaryQuestVehicle( player )
					CleanUpQuestElements( player )

					player:SetPrivateData( "current_quest", nil )

					if not self.tutorial then
						local training_members = player:getData( "training_members" )
						if self.training_id and not self.training_uncritical and training_members and ( not self.training_critical_last_task or current_quest.task <= self.training_critical_last_task ) then
							triggerEvent( "onPlayerTrainingFailed", player, self.training_id )

							for _, member in pairs( training_members ) do
								if isElement( member ) then
									member:setData( "training_members", false, false )
									triggerEvent( "PlayerFailStopQuest", member, { type = "quest_fail", fail_text = "Кто-то из участников не справился со своей задачей" } )
								end
							end
						end

						player:setData( "training_members", false, false )

						player:SetPrivateData( "current_quest" )

						player:ShowInfo("Приносим свои извинения, задача была перезапущена сервером. Начните её заново")
					end
				end
			end
		end
	end )

	return self
end


function CreateTemporaryQuestVehicle( player, ... )
	local vehicle = Vehicle.CreateTemporary( ... )
	player:SetPrivateData("quest_vehicle", vehicle)
	vehicle:setData("quest_vehicle", true, false)

	return vehicle
end

function DestroyTemporaryQuestVehicle( player )
	local quest_vehicle = player:getData( "quest_vehicle" )
	if quest_vehicle then
		if isElement( quest_vehicle ) then
			Vehicle.DestroyTemporary( quest_vehicle )
		end

		player:SetPrivateData( "quest_vehicle", false )
	end
end

function AddQuestElement( player, name, element )
	local quest_elements = player:getData( "quest_elements" ) or { }
	quest_elements[ name ] = element
	player:SetPrivateData( "quest_elements", quest_elements )
end

function DeleteQuestElement( player, name )
	local quest_elements = player:getData( "quest_elements" )
	if quest_elements then
		local element = quest_elements[ name ]

		if isElement( element ) then
			destroyElement( element )
		elseif isTimer( element ) then
			killTimer( element )
		end

		quest_elements[ name ] = nil

		player:SetPrivateData( "quest_elements", quest_elements )
	end
end

function CleanUpQuestElements( player )
	local quest_elements = player:getData( "quest_elements" )
	if quest_elements then
		for _, element in pairs( quest_elements ) do
			if isElement( element ) then
				destroyElement( element )
			elseif isTimer( element ) then
				killTimer( element )
			end
		end

		player:SetPrivateData( "quest_elements", false )
	end
end

function FindQuestNPC( id )
    for i, v in pairs( QUESTS_NPC ) do
        if v.id == id then
            return v
        end
    end
end

if _G.EnterLocalDimension_fromClient then
	removeEventHandler( "EnterLocalDimension", resourceRoot, _G.EnterLocalDimension_fromClient )
end
function EnterLocalDimension_fromClient( )
	EnterLocalDimension( client, true )
end
addEvent( "EnterLocalDimension", true )
addEventHandler( "EnterLocalDimension", resourceRoot, EnterLocalDimension_fromClient )