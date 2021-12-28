loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("SDB")
Extend("ShVehicleConfig")
Extend("ShTimelib")

MIN_WEIGHT = -3
MAX_WEIGHT = 1

SECONDS_24h = 24 * 60 * 60
SECONDS_5m = 5 * 60

DAILY_TIMERS = {}

RESET_TIME     = "20:00"
ADD_TIME       = "12:00"
REMAINDER_TIME = "19:00"

--Инициализация базы данных
function InitializeDataBase()

    ExecAtTime( ADD_TIME, function()
        RefreshDailyTasks( ADD_TIME )
        DAILY_TIMERS[ ADD_TIME ] = setTimer( RefreshDailyTasks, SECONDS_24h * 1000, 0, ADD_TIME )
    end )

    ExecAtTime( RESET_TIME, function()
        RefreshDailyTasks( RESET_TIME )
        DAILY_TIMERS[ RESET_TIME ] = setTimer( RefreshDailyTasks, SECONDS_24h * 1000, 0, RESET_TIME )
        
    end )

    ExecAtTime( REMAINDER_TIME, function()
        SendPlayersReminderMessage()
        DAILY_TIMERS[ REMAINDER_TIME ] = setTimer( SendPlayersReminderMessage, SECONDS_24h * 1000, 0 )
    end )
	
	for _, player in pairs( GetPlayersInGame() ) do
		OnPlayerFinishTutorial_handler( player )
	end

end
addEventHandler( "onResourceStart", resourceRoot, InitializeDataBase )

function OnPlayerFinishTutorial_handler( player, is_tutorial_complete )
    local player = player or source
    if not player:HasFinishedBasicTutorial() and not is_tutorial_complete then return end
    if player:GetLevel() < 2 then return end

	local is_opened_access_to_daily = false
    local daily_quest_list = player:GetPermanentData( "daily_quest_list" )
	if not daily_quest_list or #daily_quest_list == 0 then
        daily_quest_list = {}
        for _, v in pairs( QUEST_NAMES ) do
            table.insert( daily_quest_list, 
            {
                id = v,
                count_exec = 0,
                weight = 0.5,
            } )
        end
		player:SetPermanentData( "daily_quest_list", daily_quest_list )
		is_opened_access_to_daily = true
	end

	---- если в табл. DAILY_QUEST_LIST было добавлено новое ежедневное задание или наоборот удалено,
	---- то учитываем эти изменения в одноименном поле из бд
	local is_quest_list_changed = false
	
	local current_list_of_ids = {}
	for i = #daily_quest_list, 1, -1 do
		local v = daily_quest_list[ i ]
		current_list_of_ids[ v.id ] = true
		if not DAILY_QUEST_LIST[ v.id ] then
			table.remove( daily_quest_list, i )
			is_quest_list_changed = true
		end
	end

	for k, _ in pairs( DAILY_QUEST_LIST ) do
		if not current_list_of_ids [ k ] then
			is_quest_list_changed = true
			table.insert( daily_quest_list,
			{
				id = k,
				count_exec = 0,
				weight = 0.5,
			} )
			--WriteLog( "nrp_quest", " %s. Добавлен новый квест: %s.", player, k )
		end
	end

	if is_quest_list_changed then
		player:SetPermanentData( "daily_quest_list", daily_quest_list )
	end
	--

	local current_timestamp = getRealTimestamp()
	
	local current_reset_timestamp = getCurrentDayTimestamp( RESET_TIME )
	local real_reset_timestamp = current_timestamp + SECONDS_5m > current_reset_timestamp and current_reset_timestamp + SECONDS_24h or current_reset_timestamp

	local current_add_timestamp = getCurrentDayTimestamp( ADD_TIME )
	
	local last_dailys_data = player:GetPermanentData( "last_dailys_data" )
	if not last_dailys_data or not last_dailys_data.add_date then
		last_dailys_data = {
			reset_date = current_reset_timestamp - SECONDS_24h,
			add_date = current_add_timestamp - SECONDS_24h,
			is_add = false
		}
		player:SetPermanentData( "last_dailys_data", last_dailys_data )
		player:SetPermanentData( "cur_daily_quests", {} )
	end

	-- Если реальный сброс( с учетом 20:00-00:00) больше предыдущего(или время с последнего больше 24 часов) и временной промежуток от 20:00 - 12:00 выдаем дейлики
	if ( ((real_reset_timestamp > last_dailys_data.reset_date) or (current_timestamp - last_dailys_data.reset_date + SECONDS_5m > SECONDS_24h )) and (current_timestamp <= current_add_timestamp or current_timestamp >= current_reset_timestamp)) or last_dailys_data.is_reset_refresh then
		--iprint("RESET_DAILY")
		local current_daily_quests = player:GetPermanentData( "cur_daily_quests" ) or {}
		local current_daily_quests_reverse = {}
		for k, v in ipairs( current_daily_quests ) do
			current_daily_quests_reverse[ v.id or -1 ] = k
		end

		for _, v in pairs( daily_quest_list ) do
			if current_daily_quests_reverse[ v.id ] then
				v.weight = math.max( MIN_WEIGHT, v.weight - 1 )
			else
				v.weight = math.max( MAX_WEIGHT, v.weight + 0.05 )
			end
		end
		
		player:SetPermanentData( "cur_daily_quests", nil )
		player:SetPermanentData( "daily_quest_list", daily_quest_list )
		
        current_daily_quests = GenerateQuestsByTimer( player, 3, RESET_TIME )
		player:AddDailyQuestList( current_daily_quests )

	-- Если текущее время добавления больше предыдущего и временной промежуток от 12:00 до 20:00, то выдаем дейлики
	elseif (current_add_timestamp > last_dailys_data.add_date and (current_timestamp >= current_add_timestamp and current_timestamp <= current_reset_timestamp)) or last_dailys_data.is_add_refresh then
		--iprint("ADD_DAILY")
		local current_daily_quests = player:GetPermanentData( "cur_daily_quests" ) or {}
		if #current_daily_quests == 0 or (current_timestamp - last_dailys_data.reset_date + SECONDS_5m) >= SECONDS_24h then
			current_daily_quests = GenerateQuestsByTimer( player, 3, RESET_TIME )
			player:AddDailyQuestList( current_daily_quests )
		end

		current_daily_quests = GenerateQuestsByTimer( player, 2, ADD_TIME )
		player:AddDailyQuestList( current_daily_quests )
	
		-- Иначе просто подгружаем
	else
		--iprint("LOAD_DAILY")
		current_daily_quests = player:GetPermanentData( "cur_daily_quests" ) or {}
		player:SetPrivateData( "cur_daily_quests", current_daily_quests )
		
		for k, v in pairs( current_daily_quests ) do
			v.is_new = false
		end
		player:SetPermanentData( "cur_daily_quests", current_daily_quests )
    end

	-- Событие выдачи первых дейликов, необходимо для тестов, аналитики
	if is_opened_access_to_daily then
		triggerEvent( "onPlayerOpenedAccessToDailyQuests", player )
	end

	return true
end
addEvent( "onPlayerCompleteTutorial", true )
addEventHandler( "onPlayerCompleteTutorial", root, OnPlayerFinishTutorial_handler )

addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerFinishTutorial_handler, true, "low-99999999" )

function GenerateQuestsByTimer( player, count_add_quests, target_time )

	if target_time == RESET_TIME then
		player:SetPermanentData( "cur_daily_quests", {} )
		player:SetPrivateData( "cur_daily_quests", {} )
	else
		-- Удаляем пустые таймеры ожидания
		local result = {}
		local current_daily_quests = player:GetPermanentData( "cur_daily_quests" ) or {}	
		for k, v in pairs( current_daily_quests ) do
			if v.id or v.completed then
				table.insert( result, v )
			end
		end
		player:SetPermanentData( "cur_daily_quests", result )
	end

	local result = {}
    local daily_quest_list = player:GetPermanentData( "daily_quest_list" )
	local current_daily_quests = player:GetPermanentData( "cur_daily_quests" ) or {}	
	
	-- Ищем доступные квесты
	local availabels_quests = {}
	for k, v in pairs( daily_quest_list ) do
		local quest = DAILY_QUEST_LIST[ v.id ]
		if quest and quest.condition( player ) and ( not quest.max_execution or quest.max_execution > v.count_exec ) and not quest.only_forced then
			table.insert( availabels_quests, v )
		end
	end

	local current_daily_quests_reverse = {}
	for k, v in ipairs( current_daily_quests ) do
		if v.id then
			current_daily_quests_reverse[ v.id ] = k
		end
	end
	
	-- Сортируем по весу
    table.sort( availabels_quests, function( a, b ) 
        return a.weight > b.weight 
    end )
	
	-- Добавляем новые дейлики
	local current_timestamp = getRealTimestamp()
    local target_reset_time = getCurrentDayTimestamp( RESET_TIME )
    local time_left = current_timestamp > target_reset_time and target_reset_time + SECONDS_24h or target_reset_time
    for k, v in ipairs( availabels_quests ) do
        if not current_daily_quests_reverse[ v.id ] then
            table.insert( result, 
            {
                id = v.id,
				time_left = time_left,
				step = 0,
				steps = DAILY_QUEST_LIST[ v.id ].steps or 1,
				is_new = true,
				first_exec = v.exec == 0 and true or false,
            })
			current_daily_quests_reverse[ v.id ] = true
			count_add_quests = count_add_quests - 1
        	if count_add_quests == 0 then break end
        end
        
    end
	
	-- Исключаем повторение текущих квестов на следующий день
	for _, cdaily in pairs( result ) do
		for _, ldaily in pairs( daily_quest_list ) do
			if cdaily.id == ldaily.id then
				ldaily.weight = math.min( MIN_WEIGHT, ldaily.weight - MIN_WEIGHT / 2 )
				break
			end
		end
	end
	player:SetPermanentData( "daily_quest_list", daily_quest_list )
	
	-- Добавляем таймеры для ожидания следующих тасок
    if target_time == RESET_TIME then
        local target_add_time = getCurrentDayTimestamp( ADD_TIME )
        local time_left_add = current_timestamp > target_add_time and target_add_time + SECONDS_24h or target_add_time
        for i = 1, 2 do
            table.insert( result, { time_left = time_left_add } )
		end

		local data = player:GetPermanentData( "last_dailys_data" ) or {}
		data.reset_date = time_left
		data.add_date = data.add_date
		data.is_reset_refresh = nil
		player:SetPermanentData( "last_dailys_data", data )
	elseif target_time == ADD_TIME then
		if #current_daily_quests == 0 then
			for i = 1, 3 do
        	    table.insert( result, { time_left = time_left } )
			end
		end

		local data = player:GetPermanentData( "last_dailys_data" ) or {}
		data.reset_date = data.reset_date or 0
		data.add_date = getCurrentDayTimestamp( ADD_TIME )
		data.is_add_refresh = nil
		player:SetPermanentData( "last_dailys_data", data )
    end

    return result
end

function SendPlayersReminderMessage()
	local target_players = {}
	for _, v in pairs( GetPlayersInGame() ) do
		if v:IsInGame() then
			for _, quest in pairs( v:getData( "cur_daily_quests" ) or {} ) do
				if quest.id then
					table.insert( target_players, v )
					break
				end
			end
		end
	end

    triggerClientEvent( target_players, "OnClientReceivePhoneNotification", root, 
    {
		title = "Ежедневные задачи",
		msg = "У вас есть ещё незавершенные задачи. Успейте выполнить задачи, остался всего час",
	})
end

function RefreshDailyTasks( target_time )
	Async:foreach( GetPlayersInGame(), function( player )
		if isElement( player ) then
			OnPlayerFinishTutorial_handler( player )
		end
	end )
end

function onServerCompleteQuest_handler( player, quest_id )
	local completed_quest = nil
	local current_daily_quests = player:getData( "cur_daily_quests" ) or {}
    
    local target_time = getCurrentDayTimestamp( RESET_TIME )
    local time_left = getRealTimestamp() > target_time and target_time + SECONDS_24h or target_time
    
    for k, v in pairs( current_daily_quests  ) do
		if quest_id == v.id then
			completed_quest = table.copy( current_daily_quests[ k ] )

			-- Если были выданы дополнительные задачи, то стираем их из отображения
			if #current_daily_quests <= 5 then
				current_daily_quests[ k ] = { time_left = time_left, completed = true }
			else
				table.remove( current_daily_quests, k )
			end
            break
		end
	end

	if not completed_quest then return end

	-- Выполненные квесты вниз
	local daily_quest_list = player:GetPermanentData( "daily_quest_list" )
	for k, v in pairs( daily_quest_list ) do
		if v.id == completed_quest.id then
			v.weight = MIN_WEIGHT
			v.count_exec = v.count_exec + 1
		else
			v.weight = v.weight + 0.1
		end
		v.is_new = false
	end

	player:SetPermanentData( "daily_quest_list", daily_quest_list )

	player:SetPermanentData( "cur_daily_quests", current_daily_quests )
	player:SetPrivateData( "cur_daily_quests", current_daily_quests )

	GiveRewardForDailyQuest( player, completed_quest )

	local quest_data = DAILY_QUEST_LIST[ quest_id ]
	if quest_data.on_completed then
		quest_data.on_completed( player )
	end

    -- Аналитика:- "Выполнен квест"
	triggerEvent( "onDailyQuestCompleted", player, DAILY_QUEST_LIST[ quest_id ].id, DAILY_QUEST_LIST[ quest_id ].name, DAILY_QUEST_LIST[ quest_id ].rewards )
end
addEvent( "onServerCompleteQuest", true )
addEventHandler( "onServerCompleteQuest", root, onServerCompleteQuest_handler )

function GiveRewardForDailyQuest( player, completed_quest )
	local reward = DAILY_QUEST_LIST[ completed_quest.id ].rewards
	local is_econom_test_active = player:getData( "economy_hard_test") and reward.value_econom_test
	local reward_value = is_econom_test_active and reward.value_econom_test or (reward.first_value and ( completed_quest.first_exec == true and reward.first_value or reward.value  ) or reward.value)

	if isElement( player ) then
		if reward.type == "soft" then
			player:GiveMoney( reward_value, "daily_quest_reward", "daily_quest" )
		elseif reward.type == "hard" then
			player:GiveDonate( reward_value, "daily_quest_reward", "daily_quest" )
		end
		completed_quest.rewards = { [ reward.type ] = reward_value }
		completed_quest.is_daily = true
		completed_quest.name = DAILY_QUEST_LIST[ completed_quest.id ].name
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, completed_quest )
	else
		local player_id = player:GetUserID()
		if reward.type == "soft" then
			player_id:GiveMoney( reward_value, "daily_quest_reward", "daily_quest" )
		elseif reward.type == "hard" then
			player_id:GiveDonate( reward_value, "daily_quest_reward", "daily_quest" )
		end
	end
end