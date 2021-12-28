CONST_REWARD_EXP = 400

QUEST_DATA = {
	training_id = "ambassador_delivery_gorki";
	training_role = "s_armed";
	training_parent = "driver";
	
	training_uncritical = true;

	title = "Сопровождение посла (Горки)";
	role_name = "Сопровождение";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 19, {
						{
							text = [[— Здравия желаю! Наша задача сопроводить посла,
									в целости и сохранности. Есть вероятность
									нападения со стороны преступных группировок.]];
						};
						{
							text = [[Твоя задача в случае нападения помочь водителю
									в защите автомобиля с послом. В сопровождении
									будет присутствовать подставной автомобиль,
									идентичный транспорту с послом, за исключением
									номерных знаков.]];
							info = true;
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на процесс учений, но если
									посол или водитель будут убиты, то учение
									будет автоматически провалено!]];
							info = true;
						};
					}, "training_ambassador_delivery_gorki_s_armed_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Сопроводи посла по городу";
			requests = {
				{ "driver", 2 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1525.846, -898.747, 32.063 ), "training_ambassador_delivery_gorki_s_armed_end_step_2", _, 20, 0, 0, CheckPlayerQuestVehicle )
				end;
			};
		};
		[3] = {
			name = "Сопроводи посла до аэропорта";
			requests = {
				{ "driver", 3 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 2302.209, -2348.731, 21.380 ), "training_ambassador_delivery_gorki_s_armed_end_step_3", _, 20, 0, 0, CheckPlayerQuestVehicle )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}