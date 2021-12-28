CONST_TIME_TO_END = 900000
CONST_REWARD_EXP = 225

CONST_TOWERS_POSITIONS =
{
	Vector3( -2610.784, -84.489 + 860, 26.143 );
	Vector3( -2472.859, -82.068 + 860, 26.143 );
	Vector3( -2446.532, 91.191 + 860, 26.143 );
	Vector3( -2311.319, 92.459 + 860, 26.143 );
	Vector3( -2310.753, -94.399 + 860, 26.14 );
	Vector3( -2311.094, -349.737 + 860, 26.143 );
	Vector3( -2611.113, -347.063 + 860, 26.143 );
}

CONST_TELEPORT_BACK_POSITION = Vector3( -2372.944, -113.476 + 860, 21 )

QUEST_DATA = {
	id = "task_military_5";

	title = "Караул";
	description = "";

	replay_timeout = 180;
	failed_timeout = 180;
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Караул - это очень ответсвенная задача!
									Внимательно следи за постом и никого
									не пускай на территорию части. Можешь
									открывать огонь на поражение по нарушителям.
									А теперь мигом на пост сменять караульного!]];
						};
					}, "task_military_5_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Заступи на свободный пост";

			Setup = {
				client = function()
					for i, position in pairs( CONST_TOWERS_POSITIONS ) do
						CreateQuestPoint( position, "task_military_5_end_step_2", "marker_checkpoint_".. i, 1, 0, 0 )
					end
				end;
			};
		};
		[3] = {
			name = "Неси службу бодро";

			Setup = {
				client = function()
					StartQuestTimerWait( CONST_TIME_TO_END, "Не спи, боец", _, "task_military_5_end_step_3" )
					
					CEs.shape = createColSphere( localPlayer.position, 5 )
					addEventHandler("onClientColShapeLeave", CEs.shape, function(player, dim)
						if localPlayer ~= player then return end

						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Задача провалена, т.к вы покинули пост" } )
					end)
				end;
			};

			CleanUp = 
			{
				server = function( player )
					player:CompleteDailyQuest( "army_guard" )
				end
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};
	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_military_5", CONST_REWARD_EXP )
	end;

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}