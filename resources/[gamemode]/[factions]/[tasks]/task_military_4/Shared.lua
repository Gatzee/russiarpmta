CONST_TIME_TO_END = 600000
CONST_REWARD_EXP = 150

CONST_MILITARY_CHECKPOINTS = {
	Vector3( -2294.635, -4.706 + 860, 20 );
}

QUEST_DATA = {
	id = "task_military_4";

	title = "Наряд на АКПП";
	description = "";

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Бегом на Автотранспортный КПП сменять
									предыдущий наряд.]];
						};
						{
							text = [[Отправляйся на один из АКПП и не покидай
									его до окончания указанного времени.]];
							info = true;
						};
					}, "task_military_4_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Заступи на пост";

			Setup = {
				client = function()
					for i, position in pairs( CONST_MILITARY_CHECKPOINTS ) do
						CreateQuestPoint( position, "task_military_4_end_step_2", "marker_checkpoint_".. i, 1.5, 0, 0 )
					end
				end;
			};
		};
		[3] = {
			name = "Неси службу бодро";

			Setup = {
				client = function()
					StartQuestTimerWait( CONST_TIME_TO_END, "Не спи, боец", _, "task_military_4_end_step_3" )

					CEs.shape = createColSphere( localPlayer.position, 15 )
					addEventHandler("onClientColShapeLeave", CEs.shape, function( player )
						if localPlayer ~= player then return end
						
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Задача провалена, т.к вы покинули пост" } )
					end)
				end;
			};

			CleanUp = 
			{
				server = function( player )
					player:CompleteDailyQuest( "army_outfit_akpp" )
				end
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};
	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_military_4", CONST_REWARD_EXP )
	end;

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}