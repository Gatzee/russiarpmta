loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "ShTimelib" )

LOBBY_LIST = { }
DELAY_BETWEEN_TRAINING = 3600 * 12

DELAY_TRAININGS = {
	cityhall_rating 	  = 3600 * 3,
	cityhall_rating_gorki = 3600 * 3,
	cityhall_rating_msk   = 3600 * 3,
}

FACTIONS_TRAININGS_DAILY_LIMITS = {
	military_delivery = 2,
	ambassador_delivery = 2,
	ambassador_delivery_gorki = 2,
}

TODAY_STARTED_TRAININGS_COUNTS = { }

function ResetDailyCounts( )
    TODAY_STARTED_TRAININGS_COUNTS = { }
    setTimer( ResetDailyCounts, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", ResetDailyCounts )

function PlayerRequestLobbyList()
	if not client then return end

	triggerClientEvent( client, "ShowUITrainingList", resourceRoot, LOBBY_LIST )
end
addEvent( "PlayerRequestLobbyList", true )
addEventHandler( "PlayerRequestLobbyList", resourceRoot, PlayerRequestLobbyList )

function CanPlayerJoinToTraining( player, trainig_name )
	local current_time = getRealTimestamp( )
	local training_counter = player:GetPermanentData( "training_counter" ) or 0
	if training_counter >= 3 then
		local delay_time = DELAY_TRAININGS[ trainig_name ] or DELAY_BETWEEN_TRAINING
		local training_last_time = player:GetPermanentData( "training_last_time" ) or 0
		if current_time < training_last_time + delay_time then
			player:ShowError( "Вы пока не можете принимать участие. Оставшееся время: " .. getHumanTimeString( training_last_time + delay_time, true ) )
			return false
		else
			player:SetPermanentData( "training_counter", 0 )
		end
	end

	return true
end

function PlayerWantCreateLobby( trainig_name )
	if not client then return end
	if not CanPlayerJoinToTraining( client, trainig_name ) then return end

	if LOBBY_LIST[ trainig_name ] then
		-- Если создатель на сервере значит событие скорее всего ещё активно
		if isElement( LOBBY_LIST[ trainig_name ].creator ) then
			client:ShowError( "Кто-то уже начал эти учения" )
			return
			-- Если это игрок, который может начать данное учение и предыдущего создателя нет, то кидаем логи и сбрасываем лобби, чтобы избежать блока
		elseif CheckPlayerCanEnterOnTrainingSlot( client, trainig_name, 1 ) and not isElement( LOBBY_LIST[ trainig_name ].creator ) then
			local v = LOBBY_LIST[ trainig_name ]
			local str = string.format("training: %s, creator: %s, create_time: %s, started: %s, start_time: %s, members: %s", trainig_name, tostring( v.creator ), tostring( v.create_time ), tostring( v.started ), tostring( v.start_time ), #v.members )
			WriteLog( "failed_mayor_training", "mayor %s try start traing, details:%s", client, str )

			LOBBY_LIST[ trainig_name ] = nil
		end
	end

	if not REGISTERED_FACTIONS_TRAINING[ trainig_name ] then
		client:ShowError( "GM_ERR: Выбранные учения не зарегистрированы! " )
		iprint( "Выбранные учения не зарегистрированы", trainig_name )
		return
	end

	if not CheckPlayerCanEnterOnTrainingSlot( client, trainig_name, 1 ) then
		client:ShowError( "Вам недоступно создание данного учения" )
		return
	end

	local daily_limit = FACTIONS_TRAININGS_DAILY_LIMITS[ trainig_name ]
	if daily_limit and ( TODAY_STARTED_TRAININGS_COUNTS[ trainig_name ] or 0 ) > daily_limit then
		client:ShowError( "Достигнут дневной лимит на проведение данного учения" )
		return
	end

	LOBBY_LIST[ trainig_name ] = {
		creator = client;
		create_time = getRealTime().timestamp;

		started = false;
		start_time = nil;

		members = {
			client
		};

		members_ready = { true };

		client_members_list = { };
	}

	client:setData( "current_training_lobby", trainig_name, false )
	addEventHandler( "onPlayerQuit", client, onPlayerQuit_handler )

	UpdateClientLobbyMembersList( trainig_name )
	triggerClientEvent( client, "ShowUITrainingLobby", resourceRoot, trainig_name, LOBBY_LIST[ trainig_name ].client_members_list, 1 )
end
addEvent( "PlayerWantCreateLobby", true )
addEventHandler( "PlayerWantCreateLobby", resourceRoot, PlayerWantCreateLobby )

function PlayerWantEnterLobby( trainig_name, slot, prev_slot )
	if not client then return end
	
	local lobby_info = LOBBY_LIST[ trainig_name ]
	if not lobby_info then return end
	if lobby_info.started then return end
	if not isElement( lobby_info.creator ) then return end
	if not CanPlayerJoinToTraining( client, trainig_name ) then return end

	if slot then
		if not CheckPlayerCanEnterOnTrainingSlot( client, trainig_name, slot ) then
			client:ShowError( "Вам недоступен этот слот" )
			return
		end

		if lobby_info.members[ slot ] and isElement( lobby_info.members[ slot ] ) then
			client:ShowError( "Этот слот уже кто-то занял" )
			triggerClientEvent( client, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list )
			return
		end

		if prev_slot and lobby_info.members[ prev_slot ] == client then
			lobby_info.members[ prev_slot ] = nil
		end

		lobby_info.members[ slot ] = client
		lobby_info.members_ready[ slot ] = false

		client:setData( "current_training_lobby", trainig_name, false )
		addEventHandler( "onPlayerQuit", client, onPlayerQuit_handler )

		UpdateClientLobbyMembersList( trainig_name )

		for i, member in pairs( lobby_info.members ) do
			triggerClientEvent( member, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list, i )
		end
	else
		triggerClientEvent( client, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list )
	end
end
addEvent( "PlayerWantEnterLobby", true )
addEventHandler( "PlayerWantEnterLobby", resourceRoot, PlayerWantEnterLobby )

function PlayerWantLeaveLobby( trainig_name, slot )
	if not client then return end
	
	RemovePlayerFromLobby( client, trainig_name, slot )
end
addEvent( "PlayerWantLeaveLobby", true )
addEventHandler( "PlayerWantLeaveLobby", resourceRoot, PlayerWantLeaveLobby )

function onPlayerQuit_handler( )
	trainig_name = source:getData( "current_training_lobby" )
	RemovePlayerFromLobby( source, trainig_name )
end

function RemovePlayerFromLobby( player, trainig_name, slot )
	player:setData( "current_training_lobby", false, false )
	removeEventHandler( "onPlayerQuit", player, onPlayerQuit_handler )

	local lobby_info = LOBBY_LIST[ trainig_name ]
	if not lobby_info then return end
	if lobby_info.started then return end

	if slot and lobby_info.members[ slot ] == player then
		lobby_info.members[ slot ] = nil
	else
		for i, member in pairs( lobby_info.members ) do
			if member == player then
				lobby_info.members[ i ] = nil

				if i == 1 then
					local save_members = lobby_info.members
					LOBBY_LIST[ trainig_name ] = nil

					for i, member in pairs( save_members ) do
						if isElement( member ) then
							triggerClientEvent( member, "ShowUITrainingList", resourceRoot, LOBBY_LIST )
							member:ShowInfo( "Создатель учений покинул лобби" )
						end
					end

					return
				end

				break
			end
		end
	end
	
	UpdateClientLobbyMembersList( trainig_name )
	
	for i, member in pairs( lobby_info.members ) do
		triggerClientEvent( member, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list, i )
	end
end

function PlayerChgReadyState( trainig_name, slot )
	if not client then return end
	
	local lobby_info = LOBBY_LIST[ trainig_name ]
	if not lobby_info then return end
	if lobby_info.started then return end
	if not slot or lobby_info.members[ slot ] ~= client then return end

	lobby_info.members_ready[ slot ] = not lobby_info.members_ready[ slot ]
	
	UpdateClientLobbyMembersList( trainig_name )
	
	for i, member in pairs( lobby_info.members ) do
		triggerClientEvent( member, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list, i )
	end
end
addEvent( "PlayerChgReadyState", true )
addEventHandler( "PlayerChgReadyState", resourceRoot, PlayerChgReadyState )

function PlayerWantKickPlayerFromSlot( trainig_name, slot )
	if not client then return end

	local lobby_info = LOBBY_LIST[ trainig_name ]
	if not lobby_info then return end
	if lobby_info.started then return end
	if lobby_info.members[ 1 ] ~= client then return end

	local member = lobby_info.members[ slot ]
	if member and isElement( member ) then
		triggerClientEvent( member, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list )
		member:ShowInfo( "Создатель лобби исключил вас" )

		member:setData( "current_training_lobby", false, false )
		removeEventHandler( "onPlayerQuit", member, onPlayerQuit_handler )
	end
	
	lobby_info.members[ slot ] = nil
	
	UpdateClientLobbyMembersList( trainig_name )
	
	for i, member in pairs( lobby_info.members ) do
		triggerClientEvent( member, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list, i )
	end
end
addEvent( "PlayerWantKickPlayerFromSlot", true )
addEventHandler( "PlayerWantKickPlayerFromSlot", resourceRoot, PlayerWantKickPlayerFromSlot )

function PlayerWantStartTraining( trainig_name )
	if not client then return end

	local lobby_info = LOBBY_LIST[ trainig_name ]
	if not lobby_info then return end
	if lobby_info.started then return end
	if lobby_info.members[ 1 ] ~= client then return end
	

	UpdateClientLobbyMembersList( trainig_name )
	local started, error_msg = StartTraining( trainig_name )
	
	if not started then
		client:ShowError( error_msg )

		for i, member in pairs( lobby_info.members ) do
			triggerClientEvent( member, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list, i )
		end
	end
end
addEvent( "PlayerWantStartTraining", true )
addEventHandler( "PlayerWantStartTraining", resourceRoot, PlayerWantStartTraining )


function CheckPlayerCanEnterOnTrainingSlot( player, trainig_name, slot )
	local training_slot_info = REGISTERED_FACTIONS_TRAINING[ trainig_name ][ slot ]
	return player:GetFaction() == training_slot_info[ 2 ] and player:GetFactionLevel() >= training_slot_info[ 3 ]
end

function StartTraining( trainig_name )
	local lobby_info = LOBBY_LIST[ trainig_name ]
	if not lobby_info then return end

	for i, slot_info in ipairs( REGISTERED_FACTIONS_TRAINING[ trainig_name ] ) do
		if slot_info[ 4 ] then
			if lobby_info.members[ i ] and not lobby_info.members_ready[ i ] then
				return false, "Не все участники готовы"
			end
		else
			local member = lobby_info.members[ i ]
			if not member or not isElement( member ) then
				return false, "Не все обязательные слоты заняты (".. i .." слот)"
			elseif not lobby_info.members_ready[ i ] then
				return false, "Не все участники готовы (".. i .." слот)"
			else
				local current_quest = member:getData( "current_quest" )
				if current_quest then
					return false, member:GetNickName() .." начал выполнять какую-то задачу"
				end

				if not member:IsOnFactionDuty() then
					return false, member:GetNickName() .." не на смене"
				end
			end
		end
	end

	local current_time = getRealTimestamp( )
	local random_number = math.random( 1, 5000 )

	for i, slot_info in ipairs( REGISTERED_FACTIONS_TRAINING[ trainig_name ] ) do
		local member = lobby_info.members[ i ]
		if isElement( member ) then
			triggerEvent( "PlayeStartQuest_training_".. trainig_name .."_".. slot_info[ 1 ], member, { slot = i, members = lobby_info.members, random_number = random_number } )
			triggerClientEvent( member, "HideTrainingLobbyUI", resourceRoot )

			member:ShowInfo( "Учение началось!" )
			member:setData( "current_training_lobby", false, false )
			member:SetPermanentData( "training_counter", ( member:GetPermanentData( "training_counter" ) or 0 ) + 1 )
			member:SetPermanentData( "training_last_time", current_time )

			removeEventHandler( "onPlayerQuit", member, onPlayerQuit_handler )
		end
	end

	lobby_info.started = true
	lobby_info.start_time = current_time

	TODAY_STARTED_TRAININGS_COUNTS[ trainig_name ] = ( TODAY_STARTED_TRAININGS_COUNTS[ trainig_name ] or 0 ) + 1

	return true
end

function onPlayerTrainingComplete_handler( trainig_name, faction_exp )
	local lobby_info = LOBBY_LIST[ trainig_name ]
	if not lobby_info then return end

	local count = 0
	for slot, member in pairs( lobby_info.members ) do
		if member == source then
			lobby_info.members_ready[ slot ] = nil
			triggerEvent( "onServerCompleteShiftPlan", member, member, "participation_study", trainig_name, faction_exp )
			member:CompleteDailyQuest( "participation_study" )
		elseif lobby_info.members_ready[ slot ] and not REGISTERED_FACTIONS_TRAINING[ trainig_name ][ slot ][ 4 ] then
			count = count + 1
		end
	end

	if count == 0 then
		LOBBY_LIST[ trainig_name ] = nil
	end
end
addEvent( "onPlayerTrainingComplete" )
addEventHandler( "onPlayerTrainingComplete", root, onPlayerTrainingComplete_handler )

function onPlayerTrainingFailed_handler( trainig_name )
	if not LOBBY_LIST[ trainig_name ] then return end

	LOBBY_LIST[ trainig_name ] = nil
end
addEvent( "onPlayerTrainingFailed" )
addEventHandler( "onPlayerTrainingFailed", root, onPlayerTrainingFailed_handler )

function UpdateClientLobbyMembersList( trainig_name )
	local lobby_info = LOBBY_LIST[ trainig_name ]
	local members_ready = lobby_info.members_ready
	
	local lobby_list = { }

	for slot, member in pairs( lobby_info.members ) do
		if isElement( member ) then
			lobby_list[ slot ] = {
				name = member:GetNickName();
				faction = member:GetFaction();
				level = member:GetFactionLevel();
				ready = members_ready[ slot ] or slot == 1;
			}
		else
			lobby_info.members[ slot ] = nil
		end
	end

	lobby_info.client_members_list = lobby_list
end

addEventHandler( "onResourceStop", resourceRoot, function()
	for trainig_name, lobby_info in pairs( LOBBY_LIST ) do
		if lobby_info.started then
			for slot, ready in pairs( lobby_info.members_ready ) do
				if ready and isElement( lobby_info.members[ slot ] ) then
					triggerEvent( "PlayerFailStopQuest", lobby_info.members[ slot ], { type = "quest_fail", fail_text = "Учения были перезапущены сервером!" } )
					break
				end
			end
		end
	end
end )






--[[
function PlayerWantEnterLobby( trainig_name, slot, prev_slot )
	if not client then return end
	
	local lobby = LOBBY_LIST[ trainig_name ]
	if not lobby then
		client:ShowError( "GM_ERR! Training not found" )
		outputDebugString( "GM_ERR! Training (".. type( trainig_name ) ..":".. tostring( trainig_name ) ..") not found", 1 )
		return
	end

	if slot then
		local result, err = lobby:func_PlayerEnter( player, slot, prev_slot )
		if not result then
			client:ShowError( err )
			return
		end
		
		triggerClientEvent( lobby.members, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby.client_members_list, i )
	else
		triggerClientEvent( client, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby.client_members_list )
	end
end
addEvent( "PlayerWantEnterLobby", true )
addEventHandler( "PlayerWantEnterLobby", resourceRoot, PlayerWantEnterLobby )

function PlayerWantLeaveLobby( trainig_name, slot )
	if not client then return end
	
	local lobby = LOBBY_LIST[ trainig_name ]
	if not lobby then
		client:ShowError( "GM_ERR! Training not found" )
		outputDebugString( "GM_ERR! Training (".. type( trainig_name ) ..":".. tostring( trainig_name ) ..") not found", 1 )
		return
	end

	if slot and lobby_info.members[ slot ] == client then
		lobby_info.members[ slot ] = nil
	else
		for i, member in pairs( lobby_info.members ) do
			if member == client then
				lobby_info.members[ i ] = nil

				if i == 1 then
					local save_members = lobby_info.members
					LOBBY_LIST[ trainig_name ] = nil

					for i, member in pairs( save_members ) do
						triggerClientEvent( member, "ShowUITrainingList", resourceRoot, LOBBY_LIST )
						member:ShowInfo( "Создатель учений покинул лобби" )
					end

					return
				end

				break
			end
		end
	end
	
	
	UpdateClientLobbyMembersList( trainig_name )
	triggerClientEvent( lobby_info.members, "ShowUITrainingLobby", resourceRoot, trainig_name, lobby_info.client_members_list, i )
end
addEvent( "PlayerWantLeaveLobby", true )
addEventHandler( "PlayerWantLeaveLobby", resourceRoot, PlayerWantLeaveLobby )

function CreateLobby( trainig_name, creator )
	return {
		id = trainig_name;
		creator = creator;

		create_time = getRealTime().timestamp;

		started = false;
		start_time = false;

		members = { };
		members_ready = { };
		client_cache_members = { };



		func_CheckPlayerEnter = function( self, player, slot )
			local training_slot_info = REGISTERED_FACTIONS_TRAINING[ self.id ][ slot ]
			if not training_slot_info then return end

			if self.started then
				return false, "Учения уже начались"
			end
			if self.members[ slot ] then
				return false, "Слот уже кем-то занят"
			end
			if not isElement( self.creator ) then
				return false, "Создатель покинул лобби"
			end

			return player:GetFaction() == training_slot_info[ 2 ] and player:GetFactionLevel() >= training_slot_info[ 3 ]
		end;

		func_UpdateMembersList = function()
			for slot, member in pairs( self.members ) do
				if isElement( member ) then
					self.client_cache_members[ slot ] = {
						name = member:GetNickName();
						faction = member:GetFaction();
						level = member:GetFactionLevel();
						ready = self.members_ready[ slot ] or slot == 1;
					}
				else
					self:func_PlayerLeave( member, slot )
				end
			end
		end;

		func_PlayerEnter = function( self, player, slot, prev_slot )
			local result, err = self:func_CheckPlayerEnter( player, slot )
			if not result then
				return false, err
			end
	
			self:func_PlayerLeave( player, prev_slot )
	
			self.members[ slot ] = client
			self.members_ready[ slot ] = false
	
			addEventHandler( "OnPlayerQuit", player, self.func_PlayerQuit )

			self:func_UpdateMembersList()

			return true
		end;

		func_PlayerLeave = function( self, player, slot )
			if self.started then return end

			if slot then
				if not self.members[ slot ] then return end
				if self.members[ slot ] ~= player then return end
			else
				for slot, member in pairs( self.members ) do
					if member == source then
						self:func_PlayerLeave( source, slot )
						
						return
					end
				end
			end

			self.members[ slot ] = nil
			self.client_cache_members[ slot ] = nil
			self.members_ready[ slot ] = nil

			removeEventHandler( "OnPlayerQuit", player, self.func_PlayerQuit )
		end;

		func_PlayerQuit = function()
			local self = LOBBY_LIST[ trainig_name ]
			if not self then return end

			for slot, member in pairs( self.members ) do
				if member == source then
					self:func_PlayerLeave( source, slot )
					
					return
				end
			end
		end;
	}
end
]]