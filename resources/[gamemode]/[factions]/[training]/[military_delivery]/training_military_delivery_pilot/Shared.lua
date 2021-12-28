QUEST_DATA = {
	training_id = "military_delivery";
	training_role = "pilot";
	
	--replay_timeout = 43200;

	title = "Поставка вооружения";
	role_name = "Ответственный";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Здравия желаю! На складах МВД постепенно
									начинают заканчиваться боеприпасы. Ваша задача
									заключается в руководстве всей операцией
									по доставке вооружения на слады МВД.]];
						};
						{
							text = [[Тебе необходимо доставить боеприпасы по
									4-м точкам, из которых две в Новороссийске и
									две в Горки-город. Учти, что по пути из одного
									города в другой на грузовик могут напасть
									бандиты и ограбить его!]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь, выйдешь из
									игры или грузовик будет сильно поврежден,
									то учение будет автоматически провалено!]];
							info = true;
						};
					}, "training_military_delivery_pilot_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Получи документы на складе";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2376.738, -243.317, 20.249 ), function()
						CEs.marker:destroy()

						ShowDialogMessage( 20, {
							{
								text = [[Документы у тебя. Теперь садись в грузовик
										на пассажирское и дождись окончания загрузки.]];
								info = true;
							};
						}, "training_military_delivery_pilot_end_step_2" )
					end, _, 2, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Разгрузись в ППС";
			requests = {
				{ "driver", 3 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -375.747, -1672.428, 21.107 ), "training_military_delivery_pilot_end_step_3", _, 4, 0, 0 )

					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[4] = {
			name = "Передай накладные в ППС";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -354.786, -1665.647, 22.379 ), function()
						CEs.marker:destroy()

						ShowDialogMessage( 14, {
							{
								text = [[С документами все хорошо. Теперь вернись в
										грузовик на пассажирское и дождись
										разгрузки боеприпасов.]];
								info = true;
							};
						}, "training_military_delivery_pilot_end_step_4" )
					end, _, 2, 0, 0 )
				end;
			};
		};
		[5] = {
			name = "Разгрузись в ДПС";
			requests = {
				{ "driver", 6 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 330.328, -2020.938, 21.570 ), "training_military_delivery_pilot_end_step_5", _, 4, 0, 0 )

					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[6] = {
			name = "Передай накладные в ДПС";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 338.013, -2039.714, 21.819 ), function()
						CEs.marker:destroy()

						ShowDialogMessage( 14, {
							{
								text = [[С документами все хорошо. Теперь вернись в
										грузовик на пассажирское и дождись
										разгрузки боеприпасов.]];
								info = true;
							};
						}, "training_military_delivery_pilot_end_step_6" )
					end, _, 2, 0, 0 )
				end;
			};
		};
		[7] = {
			name = "Разгрузись в ДПС";
			requests = {
				{ "driver", 8 };
			};

			Setup = {
				client = function( data )
					localPlayer:ShowInfo( "Сообщение от агента: Преступным группировкам стало известно о грузовике" )
					CreateQuestPoint( Vector3( 2191.393, -616.025, 61.309 ), "training_military_delivery_pilot_end_step_7", _, 4, 0, 0 )

					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[8] = {
			name = "Передай накладные в ДПС";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 2204.945, -602.827, 61.590 ), function()
						CEs.marker:destroy()

						ShowDialogMessage( 14, {
							{
								text = [[С документами все хорошо. Теперь вернись в
										грузовик на пассажирское и дождись
										разгрузки боеприпасов.]];
								info = true;
							};
						}, "training_military_delivery_pilot_end_step_8" )
					end, _, 2, 0, 0 )
				end;
			};
		};
		[9] = {
			name = "Разгрузись в ППС";
			requests = {
				{ "driver", 12 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1945.128, -704.913, 61.379 ), "training_military_delivery_pilot_end_step_9", _, 4, 0, 0 )

					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[10] = {
			name = "Передай накладные в ППС";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1958.176, -728.031, 61.267 ), function()
						CEs.marker:destroy()

						ShowDialogMessage( 14, {
							{
								text = [[С документами все хорошо. Теперь вернись в
										грузовик на пассажирское и дождись
										разгрузки боеприпасов.]];
								info = true;
							};
						}, "training_military_delivery_pilot_end_step_10" )
					end, _, 2, 0, 0 )
				end;
			};
		};
		[11] = {
			name = "Возвращайся в часть";
			requests = {
				{ "driver", 14 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2284.648, -18.218, 20.695 ), "training_military_delivery_pilot_end_step_11", _, 4, 0, 0, CheckPlayerMilitaryVehicle )

					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
	};

	rewards = {
		faction_exp = 600;
	};

	success_text = "Задача выполнена! Вы получили +600 очков ранга";
}


function Client_CancelPlayerInMilitaryVehicleDamage()
	if not source.vehicle then return end
	if source.vehicle.model ~= 433 then return end
	
	cancelEvent()
end