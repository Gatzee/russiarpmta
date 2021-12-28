loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "ShSkin" )

CONST_REWARD_EXP = 800

CONST_MEDIC_DATA = {
	[1] = {
		position = Vector3( -1015.7, -1683.09998, 21 );
		ped_positions = {
			Vector3( -1033.9, -1699.29999, 20.8 );
			Vector3( -1065.3, -1717.59998, 20.8 );
			Vector3( -1091, -1707.09998, 20.8 );
		};
	};
}

COST_COLORS_LIST = { "Черный", "Белый", "Голубой", "Красный", "Серый", "Розовый", "Желтый" }

CONST_COUNT_POINTS = #CONST_MEDIC_DATA

QUEST_DATA = {
	training_id = "demining";
	training_role = "medic";
	training_parent = "army";

	training_critical_last_task = 3;

	title = "Разминирование бомбы";
	role_name = "Врач";
	
	tasks = {
		[1] = {
			name = "Поговори с доктором";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 16, {
						{
							text = [[— Добрый день! У нас чрезвычайная ситуация,
									отправляйтесь по вызову! Есть пострадавший!]];
						};
						{
							text = [[Ваша задача спасти раненного. Для
									реанимирования необходимо в нужный момент
									нажать ЛКМ. После чего, срочно доставить
									пострадавшего в больницу]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь или выйдешь
									из игры, то учение будет провалено! Если
									пострадавший не будет спасен, то учения
									будут провалены.]];
							info = true;
						};
					}, "training_demining_medic_end_step_1", _, true )
				end;

				server = function( player, data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					local death_ped = createPed( BOUTIQUE_LIST[ math.random( 1, #BOUTIQUE_LIST ) ].id, CONST_MEDIC_DATA[ number ].ped_positions[ data.random_number % #CONST_MEDIC_DATA[ number ].ped_positions + 1 ], math.random( 0, 360 ), false )
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
					CreateQuestPoint( CONST_MEDIC_DATA[ number ].position, "training_demining_medic_end_step_2", _, _, 0, 0 )
				end;

				server = function( player, data )
					local vehicle = CreateTemporaryQuestVehicle( player, 416, 476.107, -2458.755, 21.214, 0, 0, 0 )
					vehicle:SetFuel("full")
					vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )

					addEventHandler("onVehicleDamage", vehicle, function()
						if vehicle.health <= 400 then
							triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Вы не повредили автомобиль" } )
						end
					end)

					player.interior = 0
					player.dimension = 0
					player:warpIntoVehicle(vehicle)
				end;
			};
		};
		[3] = {
			name = "Окажи первую помощь";
			requests = {
				{ "pps", 3 };
			};

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_MEDIC_DATA[ number ].ped_positions[ data.random_number % #CONST_MEDIC_DATA[ number ].ped_positions + 1 ], function()
						CEs.marker:destroy()

						triggerEvent( "StartPlayerReanimation", resourceRoot, "DeminingMedicReanimationSuccess", "DeminingMedicReanimationFailed" )
						setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, true, false, false, false )

						CEs.DeminingMedicReanimationSuccess_handler = function()
							triggerServerEvent( "training_demining_medic_end_step_3", localPlayer )
						end
						addEvent( "DeminingMedicReanimationSuccess" )
						addEventHandler( "DeminingMedicReanimationSuccess", root, CEs.DeminingMedicReanimationSuccess_handler )
						
						CEs.DeminingMedicReanimationFailed_handler = function()
							triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Вы не смогли провести реанимацию" } )
						end
						addEvent( "DeminingMedicReanimationFailed" )
						addEventHandler( "DeminingMedicReanimationFailed", root, CEs.DeminingMedicReanimationFailed_handler )
					end, _, 1.5, 0, 0 )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					vehicle:SetStatic( true )
				end;
			};

			CleanUp = {
				client = function( data, failed )
					if failed then
						triggerEvent( "StopPlayerReanimation", resourceRoot )
					end
					
					removeEventHandler( "DeminingMedicReanimationSuccess", resourceRoot, CEs.DeminingMedicReanimationSuccess_handler )
					removeEventHandler( "DeminingMedicReanimationFailed", resourceRoot, CEs.DeminingMedicReanimationFailed_handler )

					CEs.DeminingMedicReanimationSuccess_handler = nil
					CEs.DeminingMedicReanimationFailed_handler = nil

					setPedAnimation( localPlayer )
				end;
			};
		};
		[4] = {
			name = "Загрузи тело в машину";

			Setup = {
				client = function( data )
					local vehicle = localPlayer:getData( "quest_vehicle" )
					CreateQuestPoint( vehicle.position, "training_demining_medic_end_step_4", _, _, 0, 0 )
				end;
			};

			CleanUp = {
				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					vehicle:SetStatic( false )

					DeleteQuestElement( player, "death_ped" )
				end;
			}
		};
		[5] = {
			name = "Вернись на базу";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 432.161, -2476.533, 21.223 ), "training_demining_medic_end_step_5" )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}