CONST_REWARD_EXP = 800

CONST_PPS_DATA = {
	[1] = {
		position = Vector3( -1023.4, -1678.5, 21 );
		ped_positions = {
			Vector3( -1033.9, -1699.29999, 20.8 );
			Vector3( -1065.3, -1717.59998, 20.8 );
			Vector3( -1091, -1707.09998, 20.8 );
		};
		vehicles = {
			{
				model = 516;
				position = Vector3( -1082.3, -1708.59998, 20.6 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 516;
				position = Vector3( -1071.7, -1708.70001, 20.6 );
				rotation = Vector3( 0, 0, 180 );
			};
			{
				model = 516;
				position = Vector3( -1058.3, -1725.5, 20.6 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 516;
				position = Vector3( -1050.4, -1708.59998, 20.6 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 516;
				position = Vector3( -1105.7, -1710.20001, 20.7 );
				rotation = Vector3( 0, 0, 90 );
			};
			{
				model = 415;
				position = Vector3( -1057.5, -1708.79999, 20.5 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 585;
				position = Vector3( -1065.5, -1725.20001, 20.7 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 585;
				position = Vector3( -1079.7, -1725.70001, 20.7 );
				rotation = Vector3( 0, 0, 180 );
			};
			{
				model = 585;
				position = Vector3( -1022.3, -1694.70001, 20.7 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 549;
				position = Vector3( -1015.1, -1694.79999, 20.5 );
				rotation = Vector3( 0, 0, 180 );
			};
			{
				model = 549;
				position = Vector3( -1069, -1725.5, 20.5 );
				rotation = Vector3( 0, 0, 180 );
			};
		};
	};
}

CONST_COUNT_POINTS = #CONST_PPS_DATA

COST_COLORS_LIST = { "Черный", "Белый", "Голубой", "Красный", "Серый", "Розовый", "Желтый" }

QUEST_DATA = {
	training_id = "demining";
	training_role = "pps";
	training_parent = "army";

	title = "Разминирование бомбы";
	role_name = "Следователь";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 14, {
						{
							text = [[— Здравия желаю! Получили данные о взрыве,
									есть жертвы. Также, возможно, есть еще
									заминированные машины.]];
						};
						{
							text = [[Твоя задача, осмотреть место взрыва и убедится,
									что нет заминированных машин. Если найдешь хоть
									одну такую машину, то сообщи о ней саперам.]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь или выйдешь
									из игры, то учение будет провалено!]];
							info = true;
						};
					}, "training_demining_pps_end_step_1", _, true )
				end;

				server = function( player, data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					local bomb_number = data.random_number % #CONST_PPS_DATA[ number ].vehicles + 1

					for i, info in pairs( CONST_PPS_DATA[ number ].vehicles ) do
						if i ~= bomb_number then
							local vehicle = Vehicle.CreateTemporary( info.model, info.position.x, info.position.y, info.position.z, info.rotation.x, info.rotation.y, info.rotation.z )
							vehicle:SetStatic( true )
							vehicle:setColor( math.random( 255 ), math.random( 255 ), math.random( 255 ) )
							vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )

							AddQuestElement( player, "vehicle_".. i, vehicle )

							addEventHandler( "onVehicleDamage", vehicle, function( )
								source.health = 1000
							end )

							addEventHandler( "onVehicleStartEnter", vehicle, function( )
								cancelEvent()
							end )
						end
					end
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_PPS_DATA[ number ].position, "training_demining_pps_end_step_2", _, _, 0, 0 )
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
					CreateQuestPoint( CONST_PPS_DATA[ number ].ped_positions[ data.random_number % #CONST_PPS_DATA[ number ].ped_positions + 1 ], function()
						CEs.marker:destroy()
				
						setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )
				
						triggerServerEvent( "training_demining_pps_end_step_3", localPlayer )
					end, _, 1.5, 0, 0 )
				end;
			};

			CleanUp = {
				client = function( data, failed )
					setPedAnimation( localPlayer )
				end;
			};
		};
		[4] = {
			name = "Найди автомобиль с бомбой";
			requests = {
				{ "medic", 3 };
			};

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					local bomb_number = data.random_number % #CONST_PPS_DATA[ number ].vehicles + 1

					local bomb_color = data.random_number % #COST_COLORS_LIST + 1
					localPlayer:ShowInfo( "Автомобиль с бомбой имеет “".. COST_COLORS_LIST[ bomb_color ] .."” цвет" )

					StartQuestTimerFail( 2 * 60 * 1000, "До взрыва осталось", "Вы не успели найти автомобиль с бомбой!", function( )
						createExplosion( CONST_PPS_DATA[ number ].vehicles[ bomb_number ].position, 7 )
					end )

					for i, info in pairs( CONST_PPS_DATA[ number ].vehicles ) do
						CreateQuestPoint( info.position, function()
							CEs["veh_marker_".. i].destroy()

							setPedAnimation( localPlayer, "bomber", "bom_plant_loop", 10000, true, false, false, false )

							if i == bomb_number then
								triggerServerEvent( "training_demining_pps_end_step_4", localPlayer )
								localPlayer:ShowInfo( "Вы нашли автомобиль с бомбой!" )
							else
								localPlayer:ShowInfo( "Это не тот автомобиль!" )
							end
						end, "veh_marker_".. i, 3, 0, 0 )
					end
				end;
			};

			CleanUp = {
				client = function( data, failed )
					setPedAnimation( localPlayer )
				end;
			};
		};
		[5] = {
			name = "...";
			requests = {
				{ "army", 3 };
			};

			Setup = {
				server = function( player, data )
					triggerEvent( "training_demining_pps_end_step_5", player )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}