S_DPS_MURDER_DATA = {
	[1] = Vector3( -920.79999, -1808.70001, 20.9 );
	[2] = Vector3( -1182.9, -1736.59998, 21 );
	[3] = Vector3( -911, -1518.5, 20.8 );
	[4] = Vector3( 598.09998, -1917, 21 );
}

CONST_COUNT_POINTS = #S_DPS_MURDER_DATA

QUEST_DATA = {
	training_id = "murder_nsk";
	training_role = "s_dps";
	training_parent = "pps";
	
	training_uncritical = true;
	
	--replay_timeout = 10800;

	title = "Расследование убийства";
	role_name = "Сотрудник ДПС";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 18, {
						{
							text = [[— Здравия желаю! От ППС пришел запрос
									о необходимости отцепить место преступления.
									Бери служебный автомобиль и отправляйся на
									помощь нашим сотрудникам.]];
						};
						{
							text = [[Тебе необходимо прибыть на место преступления
									и помочь нашему сотруднику не допустить
									проникновение гражданских через ограждения.]];
							info = true;
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на процесс учений.]];
							info = true;
						};
					}, "training_murder_nsk_s_dps_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( S_DPS_MURDER_DATA[ number ], "training_murder_nsk_s_dps_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Вернись на базу";
			requests = {
				{ "dps", 4 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 339.552, -2065.946, 20.763 ), "training_murder_nsk_s_dps_end_step_3", _, _, 0, 0 )
				end;
			};
		};
	};

	rewards = {
		faction_exp = 150;
	};

	success_text = "Задача выполнена! Вы получили +150 очков ранга";
}