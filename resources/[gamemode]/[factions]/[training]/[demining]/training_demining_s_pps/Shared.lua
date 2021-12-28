CONST_REWARD_EXP = 200

CONST_S_PPS_DATA = {
	[1] = Vector3( -1023.4, -1678.5, 21 );
}

CONST_COUNT_POINTS = #CONST_S_PPS_DATA

QUEST_DATA = {
	training_id = "demining";
	training_role = "s_pps";
	training_parent = "army";

	training_uncritical = true;

	title = "Разминирование бомбы";
	role_name = "Помощник следователя";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 14, {
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
					}, "training_demining_s_pps_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_S_PPS_DATA[ number ].position, "training_demining_s_pps_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "...";
			requests = {
				{ "pps", 5 };
			};

			Setup = {
				server = function( player, data )
					triggerEvent( "training_demining_s_pps_end_step_3", player )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}