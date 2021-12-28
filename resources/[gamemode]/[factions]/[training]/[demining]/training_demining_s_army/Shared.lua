CONST_REWARD_EXP = 200

CONST_S_ARMY_DATA = {
	[1] = Vector3( -1101.8, -1676.59998, 20.8 );
}

CONST_COUNT_POINTS = #CONST_S_ARMY_DATA

QUEST_DATA = {
	training_id = "demining";
	training_role = "s_army";
	training_parent = "army";

	training_uncritical = true;

	title = "Разминирование бомбы";
	role_name = "Помощник сапера";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Здравия желаю! Получили данные о взрыве,
									есть жертвы. Также, возможно, есть еще
									заминированные машины.]];
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на ход учения!]];
							info = true;
						};
					}, "training_demining_s_army_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_S_ARMY_DATA[ number ].position, "training_demining_s_army_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "...";
			requests = {
				{ "army", 3 };
			};

			Setup = {
				server = function( player, data )
					triggerEvent( "training_demining_s_army_end_step_3", player )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}