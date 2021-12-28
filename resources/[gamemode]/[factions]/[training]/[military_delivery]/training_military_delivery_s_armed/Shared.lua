QUEST_DATA = {
	training_id = "military_delivery";
	training_role = "s_armed";
	training_parent = "pilot";
	
	training_uncritical = true;
	
	--replay_timeout = 43200;

	title = "Поставка вооружения";
	role_name = "Сопровождение";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Здравия желаю! На складах МВД постепенно
									начинают заканчиваться боеприпасы. Твоя задача
									заключается в сопровождении груза и помощь
									в загрузке и разгрузке боеприпасов.]];
						};
						{
							text = [[Необходимо доставить боеприпасы по 4-м точкам,
									из которых две в Новороссийске и две в
									Горки-город. Учти, что по пути из одного
									города в другой на грузовик могут напасть
									бандиты и ограбить его!]];
							info = true;
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на процесс учений, но если
									грузовик будет сильно поврежден, то учение
									будет автоматически провалено!]];
							info = true;
						};
					}, "training_military_delivery_s_armed_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Загрузи грузовик";
			requests = {
				{ "driver", 1 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2427.204, -251.69, 20.706 ), "training_military_delivery_s_armed_end_step_2", _, 8, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Разгрузи грузовик в ППС";
			requests = {
				{ "driver", 3 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -375.747, -1672.428, 21.107 ), "training_military_delivery_s_armed_end_step_3", _, 8, 0, 0 )
				end;
			};
		};
		[4] = {
			name = "Разгрузи грузовик в ДПС";
			requests = {
				{ "driver", 6 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 330.328, -2020.938, 21.570 ), "training_military_delivery_s_armed_end_step_4", _, 8, 0, 0 )
				end;
			};
		};
		[5] = {
			name = "Разгрузи грузовик в ДПС";
			requests = {
				{ "driver", 8 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 2191.393, -616.025, 61.309 ), "training_military_delivery_s_armed_end_step_5", _, 8, 0, 0 )
				end;
			};
		};
		[6] = {
			name = "Разгрузи грузовик в ППС";
			requests = {
				{ "driver", 12 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1956.341, -725.912, 61.470 ), "training_military_delivery_s_armed_end_step_6", _, 8, 0, 0 )
				end;
			};
		};
		[7] = {
			name = "Возвращайся в часть";
			requests = {
				{ "driver", 14 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2284.648, -18.218, 20.695 ), "training_military_delivery_s_armed_end_step_7", _, 8, 0, 0 )
				end;
			};
		};
	};

	rewards = {
		faction_exp = 300;
	};

	success_text = "Задача выполнена! Вы получили +300 очков ранга";
}