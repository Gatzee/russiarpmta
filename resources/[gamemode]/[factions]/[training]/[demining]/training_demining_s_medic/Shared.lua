CONST_REWARD_EXP = 200

CONST_S_MEDIC_DATA = {
	[1] = Vector3( -1015.7, -1683.09998, 21 );
}

CONST_COUNT_POINTS = #CONST_S_MEDIC_DATA

QUEST_DATA = {
	training_id = "demining";
	training_role = "s_medic";
	training_parent = "army";

	training_uncritical = true;

	title = "Разминирование бомбы";
	role_name = "Санитар";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 16, {
						{
							text = [[— Добрый день! У нас чрезвычайная ситуация,
									отправляйтесь по вызову! Есть пострадавший!]];
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на ход учения!]];
							info = true;
						};
					}, "training_demining_s_medic_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_S_MEDIC_DATA[ number ].position, "training_demining_s_medic_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Вернись на базу";
			requests = {
				{ "medic", 4 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 432.161, -2476.533, 21.223 ), "training_demining_s_medic_end_step_3" )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}