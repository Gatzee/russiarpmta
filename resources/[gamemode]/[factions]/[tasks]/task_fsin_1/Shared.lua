CONST_TIME_TO_END = 15 * 60 * 1000
CONST_REWARD_EXP = 200

CONST_FSIN_CHECKPOINTS = 
{
	--На территории тюрьмы
	Vector3( -2654.6193, 1561.2695 + 860, 14.086 );
	Vector3( -2866.5341, 1847.0717 + 860, 14.0874 );
	Vector3( -2812.862, 1626.1801 + 860, 14.1251 );
	Vector3( -2801.3627, 1924.8312 + 860, 14.098 );
	Vector3( -2651.206, 1920.7575 + 860, 14.0844 );
	Vector3( -2457.7734, 1621.7331 + 860, 14.0858 );
	Vector3( -2493.6213, 1855.2893 + 860, 14.0847 );

	--Вышки
	Vector3( -2769.3271, 1542.9038 + 860, 20.1873 );
	Vector3( -2928.0307, 1630.4555 + 860, 20.1272 );
	Vector3( -2957.1806, 1871.9636 + 860, 20.1272 );
	Vector3( -2788.111, 1989.2587 + 860, 20.2063 );
	Vector3( -2558.0642, 1959.9262 + 860, 20.2063 );
	Vector3( -2373.8542, 1872.2048 + 860, 20.2063 );
	Vector3( -2292.5812, 1663.0571 + 860, 20.2063 );
	Vector3( -2516.2897, 1550.4956 + 860, 20.1901 );
}

QUEST_DATA = {
	id = "task_fsin_1";

	title = "Дежурство на постах";
	description = "";

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[Здравия желаю. Тебе предстоит выполнить основную 
							свою обязанность. Сохранить порядок на территории 
							тюрьмы и не допустить как проникновение
							на территорию части, так и выход за территорию 
							тюрьмы заключенными. Для этого необходимо занять
							точку и следить за порядком ]];
						};
						{
							text = [[Для успешного завершения задачи не покидай
									пост до окончания указанного времени.]];
							info = true;
						};
					}, "task_fsin_1_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Заступи на пост";

			Setup = {
				client = function()
					for i, position in pairs( CONST_FSIN_CHECKPOINTS ) do
						CreateQuestPoint( position, "task_fsin_1_end_step_2", "marker_checkpoint_".. i, 1.5, 0, 0 )
					end
				end;
			};
		};
		[3] = {
			name = "Следи за заключенными";

			Setup = {
				client = function()
					StartQuestTimerWait( CONST_TIME_TO_END, "Дежурство", _, "task_fsin_1_end_step_3" )

					CEs.shape = createColSphere( localPlayer.position, 40 )
					addEventHandler("onClientColShapeLeave", CEs.shape, function( player )
						if localPlayer ~= player then return end

						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Вы покинули пост" } )
					end)
				end;
			};

		};
	};
	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_fsin_1", CONST_REWARD_EXP )
	end;

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}