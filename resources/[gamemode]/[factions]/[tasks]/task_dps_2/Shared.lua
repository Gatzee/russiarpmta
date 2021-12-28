CONST_TIME_TO_END = 20 * 60 * 1000
CONST_REWARD_EXP = 300

CONST_DPS_CHECKPOINTS = {
	{
		Vector3( -1088.970, -1192.622 + 860, 23.002 );
		Vector3( -1101.562, -825.781 + 860, 22.983 );
		Vector3( 1434.039, -1752.997 + 860, 20.712 );
		Vector3( 1279.110, -1171.640 + 860, 19.930 );
		Vector3( -2677.233, -822.486 + 860, 19.375 );
		Vector3( 271.639, 367.67 + 860, 21.148 );
		Vector3( 291.922, -1760.448 + 860, 19.75 );
	};
	{
		Vector3( 1545.681, -1733.739 + 860, 20.531 );
		Vector3( 1302.398, -1060.729 + 860, 20.179 );
		Vector3( 1715.881, -1314.822 + 860, 34.882 );
		Vector3( 867.779, 256.702 + 860, 21.027 );
	};
	{
		Vector3( { x = -1274.74, y = 2456.91 + 860, z = 12.68 } );
		Vector3( { x = -967.37, y = 2305.68 + 860, z = 17.22 } );
		Vector3( { x = -745.76, y = 2542.79 + 860, z = 18.11 } );
		Vector3( { x = -284.55, y = 2609.38 + 860, z = 15.11 } );
		Vector3( { x = -110.7, y = 2799.62 + 860, z = 15.32 } );
		Vector3( { x = -551.34, y = 2031.54 + 860, z = 15.4 } );
		Vector3( { x = 431.56, y = 1982.14 + 860, z = 8.3 } );
		Vector3( { x = 342.68, y = 2359.33 + 860, z = 19.63 } );
		Vector3( { x = 1160.64, y = 2628.05 + 860, z = 9.8 } );
		Vector3( { x = 1714.43, y = 2616.04 + 860, z = 8.35 } );
		Vector3( { x = 1750.61, y = 2398.59 + 860, z = 8.07 } );
		Vector3( { x = 1462.59, y = 2161.9 + 860, z = 8.65 } );
		Vector3( { x = 1445.25, y = 2616.84 + 860, z = 10.14 } );
		Vector3( { x = 1446.54, y = 2425.49 + 860, z = 10.24 } );
		Vector3( { x = 1082.61, y = 2150.62 + 860, z = 8.5 } );
		Vector3( { x = 1057.94, y = 1731.35 + 860, z = 13.2 } );
		Vector3( { x = 814.82, y = 1880.11 + 860, z = 8.5 } );
		Vector3( { x = -39.2, y = 1963.54 + 860, z = 8.5 } );
		Vector3( { x = -699.99, y = 1697.34 + 860, z = 8.5 } );
		Vector3( { x = -1141.72, y = 2014.28 + 860, z = 8.49 } );
		Vector3( { x = 2415.32, y = 2635.97 + 860, z = 8.08 } );
		Vector3( { x = 2023.82, y = 2641.54 + 860, z = 8.07 } );
		Vector3( { x = 2557.61, y = 2436.96 + 860, z = 8.08 } );
		Vector3( { x = 1269.8, y = 2309.71 + 860, z = 9.69 } );
	};
}

QUEST_DATA = {
	id = "task_dps_2";

	title = "Дежурство на постах";
	description = "";

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Здравия желаю! На улицах города развелось
									много нарушитей. Бери автомобиль и отправляйся
									дежурить на один из постов. На посту останавливай
									для проверки автомобили, а при возникновении
									конфликтных ситуаций вызывай на помощь ППС.]];
						};
						{
							text = [[Для успешного завершения задачи не покидай
									пост до окончания указанного времени.]];
							info = true;
						};
					}, "task_dps_2_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Возьми служебную машину";

			Setup = {
				client = function()
					local get_vehicle_position = exports.nrp_faction_vehicles:GetVehicleMarkerPositionByFaction( localPlayer:GetFactionDutyCity( ) - 1, localPlayer:GetFaction() )
					iprint( get_vehicle_position )
					if get_vehicle_position then
						CreateQuestPoint( get_vehicle_position, function ( )
							CEs.get_veh_point.destroy( )
						end, "get_veh_point", 5, 0, 0 )
					end

					CEs.timer = Timer( function ( )
						if localPlayer.vehicle and localPlayer.vehicle:GetFaction( ) == localPlayer:GetFaction( ) then
							triggerServerEvent( "task_dps_2_end_step_2", localPlayer )
							killTimer( CEs.timer )
						end
					end, 500, 0 )
				end;
			};
		};
		[3] = {
			name = "Заступи на пост";

			Setup = {
				client = function()
					for i, position in pairs( CONST_DPS_CHECKPOINTS[ localPlayer:GetFactionDutyCity() ] ) do
						CreateQuestPoint( position, "task_dps_2_end_step_3", "marker_checkpoint_".. i, 1.5, 0, 0 )
					end
				end;
			};
		};
		[4] = {
			name = "Не забывай проверять граждан";

			Setup = {
				client = function()
					StartQuestTimerWait( CONST_TIME_TO_END, "Дежурство", _, "task_dps_2_end_step_4" )

					localPlayer:setData("on_police_post", true, false)

					CEs.shape = createColSphere( localPlayer.position, 60 )
					addEventHandler("onClientColShapeLeave", CEs.shape, function( player )
						if localPlayer ~= player then return end
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Ты покинул пост" } )
					end)
				end;
			};

			CleanUp = {
				client = function()
					localPlayer:setData("on_police_post", false, false)
				end;
			};
		};
	};

	GiveReward = function( player )
		player:CompleteDailyQuest( "dps_watch_posts" )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_dps_2", CONST_REWARD_EXP )
	end;
	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}