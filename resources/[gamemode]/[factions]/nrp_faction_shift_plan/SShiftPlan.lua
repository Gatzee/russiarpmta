PLAYERS_SHIFT_PLAN = {}

addEvent( "onServerCompleteShiftPlan", true )
addEventHandler( "onServerCompleteShiftPlan", root, function( player, id, task_id, task_faction_exp )
	--task_faction_exp пока не используется
	if not SHIFT_PLAN_TASKS[ id ] then return end
	local player_faction = player:GetFaction()
	if not SHIFT_PLAN_TASKS[ id ].factions[ player_faction ] then return end
	if not PLAYERS_SHIFT_PLAN[ player ] then
		PLAYERS_SHIFT_PLAN[ player ] = {}
	end
	if not PLAYERS_SHIFT_PLAN[ player ][ id ] then
		PLAYERS_SHIFT_PLAN[ player ][ id ] = {}
		PLAYERS_SHIFT_PLAN[ player ][ id ].execution = 0
	end
	PLAYERS_SHIFT_PLAN[ player ][ id ].execution = PLAYERS_SHIFT_PLAN[ player ][ id ].execution + 1
	--Сохраняем временные данные по списку выполненных квестов и т.д.
	if id == "complete_quest" or id == "participation_study" then
		if task_id then
			if not PLAYERS_SHIFT_PLAN[ player ][ id ].last_tasks then
				PLAYERS_SHIFT_PLAN[ player ][ id ].last_tasks = {}
			end
			table.insert( PLAYERS_SHIFT_PLAN[ player ][ id ].last_tasks, 1, task_id )
		end
	end
	if PLAYERS_SHIFT_PLAN[ player ][ id ].execution == SHIFT_PLAN_TASKS[ id ].need_number_exec then
		player:ShowInfo( "Вы выполнили задачу " .. SHIFT_PLAN_TASKS[ id ].text .. ", награда " .. SHIFT_PLAN_TASKS[ id ].reward .. "р." )
		player:GiveMoney( SHIFT_PLAN_TASKS[ id ].reward, "faction_shift_plan_complete", SHIFT_PLAN_TASKS[ id ].id )
		PLAYERS_SHIFT_PLAN[ player ][ id ].execution = 0
		triggerEvent( "onPlayerShiftPlanComplete_" .. id, player, id, PLAYERS_SHIFT_PLAN[ player ][ id ].last_tasks, SHIFT_PLAN_TASKS[ id ].reward, 0 ) --soft/exp reward
		triggerEvent( "onPlayerShiftPlanTaskComplete", player, id )
		player:CompleteDailyQuest( "faction_shift_complite" )
	else
		if id == "shift_call" then
			triggerEvent( "onFactionCallRide", player, task_faction_exp or 0 )
		end
		player:ShowInfo( PLAYERS_SHIFT_PLAN[ player ][ id ].execution .. "/" .. SHIFT_PLAN_TASKS[ id ].text .. "(" .. SHIFT_PLAN_TASKS[ id ].reward .. "р.)" )
	end
end )

function onServerResetShiftPlan()
	PLAYERS_SHIFT_PLAN = nil
	PLAYERS_SHIFT_PLAN = {}
end

function GetShiftPlanData( player )
	return PLAYERS_SHIFT_PLAN[ player ] or {}
end


addEventHandler( "onPlayerQuit", root, function()
	if PLAYERS_SHIFT_PLAN[ source ] then
		PLAYERS_SHIFT_PLAN[ source ] = nil
	end
end )
