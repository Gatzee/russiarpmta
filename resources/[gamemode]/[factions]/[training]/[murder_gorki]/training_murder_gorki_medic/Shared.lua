loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "ShSkin" )

MEDIC_MURDER_DATA = {
	[1] = {
		position = Vector3( 1903.4, -774.2, 60.7 );
		ped_position = Vector3( 1903.4, -781.2, 60.7 );
	};
	[2] = {
		position = Vector3( 2153.2, -1138, 60.7 );
		ped_position = Vector3( 2140.8, -1141.60001, 60.7 );
	};
	[3] = {
		position = Vector3( 1545.5, -432.10001, 36.8 );
		ped_position = Vector3( 1558, -439.79999, 36.8 );
	};
}

CONST_COUNT_POINTS = #MEDIC_MURDER_DATA

QUEST_DATA = {
	training_id = "murder_gorki";
	training_role = "medic";
	training_parent = "pps";
	
	--replay_timeout = 10800;

	title = "Расследование убийства\n(Горки)";
	role_name = "Сотрудник Мед.службы";
	
	tasks = {
		[1] = {
			name = "Поговори с доктором";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 16, {
						{
							text = [[— Добрый день. Нам пришел запрос из МВД
									об убийстве и найденном трупе. Возьмите
									служебный автомобиль и доставьте тело сюда.]];
						};
						{
							text = [[Тебе необходимо прибыть на указанную точку,
									осмотреть тело, упаковать его и после
									чего привези в морг его с образцами.
									Запрещено осматривать тело до того момента,
									пока ДПС не поставит заграждения.]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь или выйдешь
									из игры, то учение будет провалено!]];
							info = true;
						};
					}, "training_murder_gorki_medic_end_step_1", _, true )
				end;

				server = function( player, data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					local death_ped = createPed( BOUTIQUE_LIST[ math.random( 1, #BOUTIQUE_LIST ) ].id, MEDIC_MURDER_DATA[ number ].ped_position, math.random( 0, 360 ), false )
					death_ped:kill()
					death_ped.frozen = true
					AddQuestElement( player, "death_ped", death_ped )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( MEDIC_MURDER_DATA[ number ].position, "training_murder_gorki_medic_end_step_2", _, _, 0, 0 )
				end;

				server = function( player, data )
					local vehicle = CreateTemporaryQuestVehicle( player, 416, 476.107, -2458.755, 21.214, 0, 0, 0 )
					vehicle:SetFuel("full")
					vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )

					addEventHandler("onVehicleDamage", vehicle, function()
						if vehicle.health <= 400 then
							triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Вы повредили автомобиль" } )
						end
					end)

					player.interior = 0
					player.dimension = 0
					player:warpIntoVehicle(vehicle)
				end;
			};
		};
		[3] = {
			name = "Осмотри тело";
			requests = {
				{ "dps", 3 };
			};

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( MEDIC_MURDER_DATA[ number ].ped_position, function()
						CEs.marker:destroy()
				
						setPedAnimation( localPlayer, "bomber", "bom_plant_loop", 5000, true, false, false, false )
				
						triggerServerEvent( "training_murder_gorki_medic_end_step_3", localPlayer )
					end, _, 1.5, 0, 0 )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					vehicle:SetStatic( true )
				end;
			};
		};
		[4] = {
			name = "Положи образцы в автомобиль";

			Setup = {
				client = function( data )
					local vehicle = localPlayer:getData( "quest_vehicle" )
					CreateQuestPoint( vehicle.position, "training_murder_gorki_medic_end_step_4", _, _, 0, 0 )
				end;
			};
		};
		[5] = {
			name = "Упакуй тело";
			requests = {
				{ "pps", 4 };
			};

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( MEDIC_MURDER_DATA[ number ].ped_position, function()
						CEs.marker:destroy()
				
						setPedAnimation( localPlayer, "bomber", "bom_plant_loop", 5000, true, false, false, false )
				
						triggerServerEvent( "training_murder_gorki_medic_end_step_5", localPlayer )
					end, _, 1.5, 0, 0 )
				end;
			};

			CleanUp = {
				server = function( player, data )
					DeleteQuestElement( player, "death_ped" )
				end;
			}
		};
		[6] = {
			name = "Загрузи тело в машину";

			Setup = {
				client = function( data )
					local vehicle = localPlayer:getData( "quest_vehicle" )
					CreateQuestPoint( vehicle.position, "training_murder_gorki_medic_end_step_6", _, _, 0, 0 )
				end;
			};

			CleanUp = {
				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					vehicle:SetStatic( false )
				end;
			}
		};
		[7] = {
			name = "Вернись на базу";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 432.161, -2476.533, 21.223 ), "training_murder_gorki_medic_end_step_7" )
				end;
			};
		};
	};

	rewards = {
		faction_exp = 300;
	};

	success_text = "Задача выполнена! Вы получили +300 очков ранга";
}