CONST_REWARD_EXP = 150

CONST_START_POINT = {
	Vector3( 337.640, -2086.603, 20.888 ),
	Vector3( 2172.877, -645.879, 60.512 ),
	Vector3( -1502.6960449219, 2487.5295410156, 10.50456237793 )
}

QUEST_DATA = {
	id = "task_dps_1";

	title = "Патрулирование улиц";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 120;

	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Здравия желаю! На улицах города развелось
									много нарушетей. Бери автомобиль и отправляйся
									в патруль. Можешь взять кого-нибудь в напарники.]];
						};
						{
							text = [[— Ты можешь начать один маршрут со своим другом,
									если он возьмет это задание и на момент выезда
									с парковки будет находиться в твоей машине
									на переднем сиденье.]];
							info = true;
						};
					}, "PlayerAction_Task_DPS_1_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_DPS_1_step_1";
		};
		[2] = {
			name = "Покинь парковку";

			Setup = {
				client = function()
					local get_vehicle_position = exports.nrp_faction_vehicles:GetVehicleMarkerPositionByFaction( localPlayer:GetFactionDutyCity() - 1, localPlayer:GetFaction() )
					if get_vehicle_position then
						CreateQuestPoint( get_vehicle_position, function ( )
							CEs.get_veh_point.destroy( )
						end, "get_veh_point", 5, 0, 0 )
					end

					CreateQuestPoint( CONST_START_POINT[ localPlayer:GetFactionDutyCity() ], function()						
						if not isElement( localPlayer.vehicle ) or localPlayer.vehicle:GetFaction() ~= localPlayer:GetFaction() then
							localPlayer:ShowError( "Ты не в машине ДПС" )
							return
						end

						if localPlayer.vehicleSeat > 1 then
							localPlayer:ShowError( "Ты не водитель или не на переднем сиденье" )
							return
						end	
						CEs.marker.slowdown_coefficient = nil
						CEs.marker.allow_passenger = true		
						CEs.marker.destroy()
						
						triggerServerEvent( "PlayerAction_Task_DPS_1_step_2", localPlayer )
					end, _, _, 0, 0 )	
				end;
			};

			event_end_name = "PlayerAction_Task_DPS_1_step_2";
		};
		[3] = {
			name = "Проследуй по маршруту";

			Setup = {
				client = function()
					if not isElement( localPlayer.vehicle ) or localPlayer.vehicle:GetFaction() ~= localPlayer:GetFaction() then
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Ты не в машине ДПС" } )
						return
					end

					local server_timestamp = getRealTimestamp()
					local seed = localPlayer.vehicle:GetID() + localPlayer.vehicle:getOccupant( 0 ):GetID() + math.floor( server_timestamp / 100 )
					
					local generated_route = exports.nrp_route_constructor:GetRandomRoute( localPlayer.position.x, localPlayer.position.y, localPlayer.position.z, 4000, seed )
					
					local vecRouteStart = generated_route[#generated_route]
					local vecRouteEnd = CONST_START_POINT[ localPlayer:GetFactionDutyCity() ]
					local route_part_2 = exports.nrp_route_constructor:GetRoute( vecRouteStart.x, vecRouteStart.y, vecRouteStart.z, vecRouteEnd.x, vecRouteEnd.y, vecRouteEnd.z )
					
					for k,v in pairs(route_part_2) do
						if k < #route_part_2 then
							table.insert(generated_route, v)
						end
					end

					local route_current_index = 0

					CEs.func_next_point = function()
						if not isElement( localPlayer.vehicle ) or localPlayer.vehicle:GetFaction() ~= localPlayer:GetFaction() then
							localPlayer:ShowError( "Ты не в машине ДПС" )
							return
						end

						if CEs.marker and isElement( CEs.marker.colshape ) then
							CEs.marker.destroy()
						end

						route_current_index = route_current_index + 1

						if generated_route[ route_current_index ] then
							CreateQuestPoint( generated_route[ route_current_index ], CEs.func_next_point, _, 20, 0, 0 )
							CEs.marker.slowdown_coefficient = nil
							CEs.marker.allow_passenger = true
						else
							localPlayer:ShowSuccess( "Возвращайтесь в участок" )
							triggerServerEvent( "PlayerAction_Task_DPS_1_step_3", localPlayer )
						end
					end

					CEs.func_next_point()
				end;
			};

			CleanUp = {
				client = function()
					CEs.func_next_point = nil
				end;
			};

			event_end_name = "PlayerAction_Task_DPS_1_step_3";
		};
		[4] = {
			name = "Вернись в участок";

			Setup = {
				client = function()
					CreateQuestPoint( CONST_START_POINT[ localPlayer:GetFactionDutyCity() ], "PlayerAction_Task_DPS_1_step_4" )
				end;
			};

			event_end_name = "PlayerAction_Task_DPS_1_step_4";
		};
	};

	GiveReward = function( player )
		player:CompleteDailyQuest( "dps_watch_posts" )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_dps_1", CONST_REWARD_EXP )
	end;
	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}