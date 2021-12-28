CONST_REWARD_EXP = 200

CONST_S_DPS_DATA = {
	[1] = Vector3( -1067.6, -1675.5, 21.2 );
}

CONST_COUNT_POINTS = #CONST_S_DPS_DATA

QUEST_DATA = {
	training_id = "demining";
	training_role = "s_dps";
	training_parent = "army";

	training_uncritical = true;

	title = "Разминирование бомбы";
	role_name = "Сотрудник ДПС";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 18, {
						{
							text = [[— Здравия желаю! Получили данные о взрыве,
									есть жертвы. Также, возможно, есть еще
									заминированные машины.]];
						};
						{
							text = [[Твоя задача оцепить периметр! Чтобы еще ни
									одна душа не пострадала от подобного
									происшествия.]];
							info = true;
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на ход учения!]];
							info = true;
						};
					}, "training_demining_s_dps_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_S_DPS_DATA[ number ].position, "training_demining_s_dps_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "...";
			requests = {
				{ "dps", 4 };
			};

			Setup = {
				server = function( player, data )
					triggerEvent( "training_demining_s_dps_end_step_3", player )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}