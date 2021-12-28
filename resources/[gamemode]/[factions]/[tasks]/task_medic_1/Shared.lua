CONST_NEED_COUNT_HEAL = 20
QUEST_PEDS = {
	16, -- NSK
	17, -- GRK
	27, -- MSK
}

addEvent( "PlayerAction_HealSuccess", true )

QUEST_DATA = {
	id = "task_medic_1";

	title = "Дежурство";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с доктором";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( QUEST_PEDS[ localPlayer:GetFactionDutyCity( ) ], {
						{
							text = [[— Приветсвую. В больнице много больных,
									которые нуждаются в нашей помощи. Сегодня план на
									твое время дежурства, это вылечить ]].. CONST_NEED_COUNT_HEAL ..[[ человек.]];
						};
					}, "PlayerAction_Task_Medic_1_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_1_step_1";
		};
		[2] = {
			name = "Выполни план";

			Setup = {
				client = function()
					local count_heal = CONST_NEED_COUNT_HEAL

					CEs.func_handler_action = function(healedPlayerFaction)
						--Если медики лечат медиков, абузят опыт
						if healedPlayerFaction == F_MEDIC then return  end
						count_heal = count_heal - 1
						if count_heal == 0 then
							localPlayer:CompleteDailyQuest( "medic_watch" )
							triggerServerEvent( "PlayerAction_Task_Medic_1_step_2", localPlayer )
						else
							localPlayer:ShowInfo( "По плану осталось еще ".. count_heal .." чел." )
						end
					end
					addEventHandler( "PlayerAction_HealSuccess", root, CEs.func_handler_action )
				end;
			};

			CleanUp = {
				client = function()
					removeEventHandler( "PlayerAction_HealSuccess", root, CEs.func_handler_action )

					CEs.func_handler_action = nil
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_1_step_2";
		};
	};

	GiveReward = function( player )
		player:CompleteDailyQuest( "dps_watch_posts" )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_medic_1", 440 )
	end;
	success_text = "Задача выполнена! Вы получили +440 очков";

	rewards = {
		faction_exp = 440;
	};
}