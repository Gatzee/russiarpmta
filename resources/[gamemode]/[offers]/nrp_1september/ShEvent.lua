EVENT_STARTS = 1567134000
EVENT_ENDS = 1567814400

CONST_TIME_TO_LEFT_REWARD = 12 * 60

EVENT_TASKS = 
{
	{
		visible_name = "Собрать 7 роз",
		progress_max = 7,
		progress_value = "роз",
		get_progress = function( player )
			local count = player:InventoryGetItemCount( IN_1SEPTEMBER_FLOWER )

			return player:GetPermanentData( "1september_flowers_collected" ) and 7 or count
		end,
	},
	{
		visible_name = "Отыграть 12 часов",
		progress_max = 12,
		progress_value = "ч",
		get_progress = function( player )
			local time_passed = 0
			if player:GetPermanentData( "1september_quest" ) then
				time_passed = player:GetPermanentData( "1september_quest_timer" ) or 12*60
			end

			local hours = math.floor( time_passed / 60 )

			return hours or 0
		end,

		on_start = function( player )
			if not player:GetPermanentData( "1september_flowers_collected" ) then
				triggerClientEvent( player, "CreateQuestMarker", resourceRoot, { x = 189.782, y = -906.513, z = 20.983 })
			else
				local time_passed = player:GetPermanentData( "1september_quest_timer" )
				if not time_passed then return end
				
				local iTimeLeft = CONST_TIME_TO_LEFT_REWARD - time_passed - 1
				triggerClientEvent( player, "Show1SeptemberTimer", resourceRoot, true, iTimeLeft )
			end
		end,

		on_complete = function( player )
			triggerClientEvent( player, "Show1SeptemberTimer", resourceRoot, true, 0 )
		end,
	},
	{
		visible_name = "Сделать букет из роз",
		progress_max = 1,
		get_progress = function( player )
			return player:GetPermanentData( "1september_flowers_received" ) and 1 or 0
		end,

		on_start = function( player )
			triggerClientEvent( player, "CreateQuestMarker", resourceRoot, { x = 189.782, y = -906.513, z = 20.983 })
			triggerClientEvent( player, "Show1SeptemberTimer", resourceRoot, true, 0 )
		end,

		on_complete = function( player )
			triggerClientEvent( player, "Show1SeptemberTimer", resourceRoot, false )
		end,
	},
	{
		visible_name = "Подарить букет учительнице",
		progress_max = 1,
		get_progress = function( player )
			return player:GetPermanentData( "1september_quest_completed" ) and 1 or 0
		end,
		on_start = function( player )
			triggerClientEvent( player, "CreateQuestMarker", resourceRoot, { x = -101.259, y = -1128.895, z = 20.802 })
		end,
	},
}

function IsEventActive()
	local iTime = getRealTime().timestamp
	return iTime > EVENT_STARTS and iTime < EVENT_ENDS
end