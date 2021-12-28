CONST_REWARD_EXP = 400

CONST_START_POINT = {
	{
		Vector3( 28.352, -1619.958, 20.413 );
		Vector3( 0, 0, 0 );
	};
	{
		Vector3( 2297.382, -1007.844, 60.478 );
		Vector3( 0, 0, 119 );
	};
	{
		Vector3( -247.4417, 2115.3039, 21.4061 );
		Vector3( 0, 0, 119 );
	};
}

CONST_ROUTE_CHECKPOINTS = {
	{
		Vector3( -55.097, -1344.413, 20.414 );
		Vector3( 540.123, -1654.97, 20.565 );
		Vector3( 243.846, -1954.434, 20.515 );
		Vector3( 338.601, -2102.67, 20.568 );
		Vector3( 398.363, -2425.386, 20.403 );
		Vector3( 241.171, -2214.976, 20.42 );
		Vector3( 306.29, -2824.067, 20.376 );
		Vector3( -100.961, -1988.932, 20.716 );
		Vector3( -329.725, -1690.761, 20.62 );
		Vector3( -808.026, -1190.758, 15.605 );
		Vector3( -1459.901, -1597.381, 20.845 );
	};
	{
		Vector3( 2250.347, -1132.675, 60.277 );
		Vector3( 2395, -814.176, 60.386 );
		Vector3( 2306.131, -571.405, 61.093 );
		Vector3( 1646.008, -322.05, 28.369 );
		Vector3( 1953.116, -250.807, 60.223 );
		Vector3( 1918.308, -512.648, 60.53 );
		Vector3( 1931.335, -746.28, 60.428 );
		Vector3( 2022.095, -777.654, 60.466 );
		Vector3( 2164.594, -885.288, 60.371 );
		Vector3( 2199.731, -1233.237, 60.48 );
	};
	{
		Vector3( 593.82, 2588.9, 11.92 ),
		Vector3( 496.69, 2659.45, 14.29 ),
		Vector3( 429.34, 2692.64, 16.01 ),
		Vector3( 71.08, 2645.17, 20.17 ),
		Vector3( 357.38, 2191.87, 14.42 ),
		Vector3( 28.94, 2560.99, 20.61 ),
		Vector3( -145.81, 2349.02, 20.6 ),
		Vector3( -499.72, 1966.54, 12.54 ),
		Vector3( 1504.64, 2211.66, 8.53 ),
		Vector3( 1320.74, 2671.15, 8.97 ),
		Vector3( 924.53, 2738.33, 6.96 ),
		Vector3( 19.64, 2793.41, 14.44 ),
		Vector3( -406.05, 2656.98, 15.37 ),
		Vector3( -444.55, 2575.31, 16.28 ),
		Vector3( -556.32, 2536.38, 16.24 ),
		Vector3( -715.84, 2368.7, 17.87 ),
		Vector3( -680.29, 2287.13, 18.57 ),
		Vector3( -691.17, 2164.24, 18.57 ),
		Vector3( -626.92, 2026.29, 14.64 ),
		Vector3( -596.02, 1851.9, 7.3 ),
		Vector3( -727.84, 1774.72, 9.25 ),
		Vector3( -846.27, 1812.78, 8.88 ),
		Vector3( -814.91, 2065.05, 11.87 ),
		Vector3( -817.34, 2335.47, 17.81 ),
		Vector3( -960.24, 2377.89, 16.96 ),
		Vector3( -583.48, 2466.6, 15.94 ),
		Vector3( -1125.59, 2740.06, 14.31 ),
		Vector3( -1458.49, 2406.48, 9.51 ),
		Vector3( -1066.78, 2198.91, 11.25 ),
		Vector3( -668.34, 1850.94, 10.21 ),
		Vector3( -533.34, 2208.66, 14.62 ),
		Vector3( -343.74, 2724.01, 13.93 ),
	};
}

QUEST_DATA = {
	id = "task_mayor_2";

	title = "Агитация власти";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 120;

	tasks = {
		[1] = {
			name = "Поговори с клерком";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Здравствуйте, рейтинг власти в глазах народа
									стал резко снижаться. Необходимо провести
									агитационные акции в городе, во избежание
									эксцессов.]];
						};
						{
							text = [[На карте отмечены точки, по которым необходимо
									проехать на специализированном транспорте.]];
							info = true;
						};
					}, "task_mayor_2_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Проследуй по маршруту";

			Setup = {
				client = function()
					local route_current_index = 0

					CEs.func_next_point = function()
						if CEs.marker and isElement( CEs.marker.colshape ) then	
							local vehicle = localPlayer:getData( "quest_vehicle" )						
							if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= vehicle then
								triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Ты не в выданной машине" } )
								return
							end

							CEs.marker.destroy()

							triggerServerEvent( "onRequestStartPlayAgitationSpeech", resourceRoot, vehicle )
						end

						route_current_index = route_current_index + 1

						if CONST_ROUTE_CHECKPOINTS[ localPlayer:GetFactionDutyCity() ][ route_current_index ] then
							CreateQuestPoint( CONST_ROUTE_CHECKPOINTS[ localPlayer:GetFactionDutyCity() ][ route_current_index ], CEs.func_next_point, _, 10, 0, 0 )
							CEs.marker.slowdown_coefficient = nil
							CEs.marker.allow_passenger = true
						else
							localPlayer:ShowSuccess( "Возвращайтесь в мэрию" )
							triggerServerEvent( "task_mayor_2_end_step_2", localPlayer )
						end
					end

					CEs.func_on_vehicle_exit = function( vehicle, seat )
						local quest_vehicle = localPlayer:getData( "quest_vehicle" )	
						if quest_vehicle and vehicle == quest_vehicle then
							if isTimer( CEs.veh_fail_timer ) then killTimer( CEs.veh_fail_timer ) end

							localPlayer:ShowError( "Квест будет провален, если вы не вернётесь в выданный автомобиль" )
							
							CEs.veh_fail_timer = setTimer( function()
								triggerServerEvent( "PlayerFailStopQuest", localPlayer, "Ты покинул выданный автомобиль" )
							end, 60000, 1 )
						end
					end
					addEventHandler( "onClientPlayerVehicleExit", localPlayer, CEs.func_on_vehicle_exit)

					CEs.func_on_vehicle_enter = function( vehicle, seat )
						local quest_vehicle = localPlayer:getData( "quest_vehicle" )	
						if quest_vehicle then
							if vehicle == quest_vehicle then
								if isTimer( CEs.veh_fail_timer ) then killTimer( CEs.veh_fail_timer ) end
							else
								triggerServerEvent( "PlayerFailStopQuest", localPlayer, "Ты сменил автомобиль" )
							end
						end
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, CEs.func_on_vehicle_enter )

					CEs.func_next_point()
				end;

				server = function( player )
					player.interior = 0
					player.dimension = 0

					local vehicle_id_by_faction =
					{
						[ F_GOVERNMENT_MSK ] = 6589,
					}

					local faction_id = player:GetFaction()
					local vehicle = CreateTemporaryQuestVehicle( player, vehicle_id_by_faction[ faction_id ] or 540, CONST_START_POINT[ player:GetFactionDutyCity() ][ 1 ], CONST_START_POINT[ player:GetFactionDutyCity() ][ 2 ] )
					vehicle:SetFuel( "full" )
					vehicle:SetWindowsColor( 0, 0, 0, 190 )
					vehicle:SetColor( 0, 0, 0, 0 )

					local number = math.random( 1, 10 ) % 10
					vehicle:SetNumberPlate( "1:а4".. number .. ( ( number + 5) % 10 ) .."мр97" )

					warpPedIntoVehicle( player, vehicle )

					addEventHandler( "onVehicleStartEnter", vehicle, function( enter_player, seat )
						if seat == 0 and enter_player ~= player then
							local faction = enter_player:GetFaction()

							if not FACTION_RIGHTS.ECONOMY[ faction ] or not enter_player:IsOnFactionDuty() then
								cancelEvent( )
							end
						end
					end )

					addEventHandler( "onVehicleDamage", vehicle, function( )
						if source.health < 800 then
							triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Ты разбил автомобиль" } )
						end
					end )
				end;
			};

			CleanUp = {
				client = function()
					CEs.func_next_point = nil

					removeEventHandler( "onClientPlayerVehicleExit", localPlayer, CEs.func_on_vehicle_exit )
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, CEs.func_on_vehicle_enter )

					CEs.func_on_vehicle_exit = nil
					CEs.func_on_vehicle_enter = nil

					if isTimer( CEs.veh_fail_timer ) then killTimer( CEs.veh_fail_timer ) end
				end;
			};
		};
		[3] = {
			name = "Вернись в мэрию";

			Setup = {
				client = function()
					CreateQuestPoint( CONST_START_POINT[ localPlayer:GetFactionDutyCity() ][ 1 ], "task_mayor_2_end_step_3" )
				end;
			};

			CleanUp = {
				server = function( player )
					player:CompleteDailyQuest( "mayor_agitation" )
				end;
			};
		};
	};
	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_mayor_2", CONST_REWARD_EXP )
	end;
	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}