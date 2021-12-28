

function GenerateQuestList( quests_info )

    LIST = 
    {
        active = { };
        available = { };
        daily = { };
        completed = { };
		blocked = { };
		all = {}
	}

	for i, quest_name in ipairs( REGISTERED_QUESTS ) do
		local resource = getResourceFromName( "quest_".. quest_name )
		if resource and getResourceState( resource ) == "running" then
			local quest = exports[ "quest_".. quest_name ]:GetQuestInfo( false, true )

			if quest then
				local current_quest = localPlayer:getData( "current_quest" )
				local quest_data = {
					id = quest_name;

					name = quest.title;
					description = quest.description;

					completed = quests_info.completed[ quest_name ];
					failed = quests_info.failed[ quest_name ];
					current = current_quest and current_quest.id == quest_name;

					count_failed = quests_info.count_failed and quests_info.count_failed[ quest_name ] or 0;
					count_completed = quests_info.count_completed and quests_info.count_completed[ quest_name ] or 0;

					replay_timeout = quest.replay_timeout;
					failed_timeout = quest.failed_timeout;

					level_request = quest.level_request or 1;

					tutorial = quest.tutorial;

					steps = quest.steps or 1;
					current_step = quests_info.completed[ quest_name ] and (quest.steps or 1) or (quest.step and quest.step  or 0);

					rewards = quest.rewards;
				}

				for k, v in pairs( quest_data.rewards ) do
					if k == "money_hard_test" then
						if localPlayer:getData( "economy_hard_test" ) then
							quest_data.rewards[ "money" ] = nil
						else
							quest_data.rewards[ "money_hard_test" ] = nil
						end
						break
					end
				end

				if quest_data.completed and not quest_data.replay_timeout then
					if not quest_data.tutorial then
						table.insert( LIST.completed, 1, quest_data )
					end
                elseif quest_data.current then
					table.insert( LIST.active, 1, quest_data )
					table.insert( LIST.available, 1, quest_data )
				else
					if localPlayer:GetLevel() >= quest_data.level_request then
						if quest.quests_request and not localPlayer:getData( "ignore_quests_request" ) then
							local completed = quests_info.completed or { }
							for _, quest_name in pairs( quest.quests_request ) do
								if type( quest_name ) == "table" then
									local found_any_quest = false
									for i, v in pairs( quest_name ) do
										if completed[ v ] then
											found_any_quest = true
											break
										end
									end
									if not found_any_quest then
										quest_data.quests_request = true
									end
								elseif not completed[ quest_name ] then
									quest_data.quests_request = true
									break
								end
							end
						end

						if quest_data.quests_request then
							table.insert( LIST.blocked, quest_data )
						else
							table.insert( LIST.active, quest_data )
							table.insert( LIST.available, quest_data )
						end
					else
						table.insert( LIST.blocked, quest_data )
					end
				end
				table.insert( LIST.all, quest_data )
			end
		end
	end
    table.sort( LIST.blocked, function ( a, b ) return ( a.level_request < b.level_request ) end )

	local econom_test = localPlayer:getData( "economy_hard_test" )
	local questList = localPlayer:getData("cur_daily_quests") or {}
    for _, v in pairs( questList ) do

		local rewards = {}
		if v.id then
			local reward = DAILY_QUEST_LIST[ v.id ].rewards
			rewards[ reward.type ] = (econom_test and reward.value_econom_test) and (reward.value_econom_test) or (v.first_exec and reward.first_value or reward.value)
		end
        local quest_data = {
            id = v.id or false;

            daily = true;
			is_new = v.is_new or false;

            name = (v.id and DAILY_QUEST_LIST[ v.id ]) and DAILY_QUEST_LIST[ v.id ].name or false;
            description = "Ежедневное задание, успей выполнить задание и получи награду!";

            completed = false;
            failed = false;
            current = true;

            count_failed = 0;
            count_completed = 0;

            replay_timeout = 0;
            failed_timeout = 0;

            level_request = 1;

            tutorial = false;

			steps = (v.id and DAILY_QUEST_LIST[ v.id ]) and DAILY_QUEST_LIST[ v.id ].steps  or 1;
			current_step = v.step or 0;

			time_left = v.time_left;

            rewards = rewards;
		}
		if v.id then
			table.insert( LIST.daily, 1, quest_data )
		else
			table.insert( LIST.daily, quest_data )
		end
	end

	table.sort( LIST.daily, function( a, b )
        if not a.id and not b.id and (a.time_left < b.time_left)  then
            return true
        elseif not a.id then
            return false
        elseif (a.id and not b.id) or (a.time_left < b.time_left) then
            return true
        end
    end )

end

function GetQuestInfo( )
	GenerateQuestList( localPlayer:GetQuestsData( ) )

	local list_kv = { }
	for i, v in pairs( LIST ) do
		list_kv[ i ] = { }
		for k, n in pairs( v ) do
			list_kv[ i ][ n.id ] = true
		end
	end

	return list_kv
end