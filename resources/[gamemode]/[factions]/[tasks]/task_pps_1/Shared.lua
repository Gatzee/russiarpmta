CONST_END_POINT = {
	Vector3( -356.093, -1676.635 + 860, 20.735 ),
	Vector3( 1937.110, -742.365 + 860, 60.5 ),
	Vector3( 1228.8823242188, 2200.5634765625 + 860, 8.8098850250244 ),
}
CONST_PED_POSITIONS = { }

QUEST_DATA = {
	id = "task_pps_1";

	title = "Зачистка города";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 1800;

	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Здравия желаю! С высока снова пришел приказ
									почистить город от бездомных. По их словам они
									создают плохой образ для нашего города.]];
						};
						{
							text = [[— Вот тебе место, откуда нужно забрать одного
									бездомного. Бери ключи от автомобиля и вези его
									сюда, будем с ним тут уже разбираться.]];
						};
					}, "PlayerAction_Task_PPS_1_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_PPS_1_step_1";
		};
		[2] = {
			name = "Получи рабочий транспорт";

			Setup = {
				client = function()
					local get_vehicle_position = exports.nrp_faction_vehicles:GetVehicleMarkerPositionByFaction( localPlayer:GetFactionDutyCity( ) - 1, localPlayer:GetFaction() )
					if get_vehicle_position then
						CreateQuestPoint( get_vehicle_position, function ( )
							CEs.marker.destroy( )
						end, nil, 5, 0, 0 )
					end
					
					CEs.timer = Timer( function ( )
						if localPlayer.vehicle and localPlayer.vehicle:GetFaction( ) == localPlayer:GetFaction( ) then
							triggerServerEvent( "PlayerAction_Task_PPS_1_step_2", localPlayer )
							killTimer( CEs.timer )
						end
					end, 500, 0 )
				end;
			};

			event_end_name = "PlayerAction_Task_PPS_1_step_2";
		};
		[3] = {
			name = "Доберись до бездомного";

			Setup = {
				client = function()
					local city = localPlayer:GetFactionDutyCity()
					-- Чтение точек из мап файла
					if not CONST_PED_POSITIONS[ city ] then
						local targets = LoadXMLIntoVector3Positions( "map/peds_" .. city .. ".map" )
						if targets then CONST_PED_POSITIONS[ city ] = targets end
					end
					
					if not CONST_PED_POSITIONS[ city ] then
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Системная ошибка инициализации бомжа" } )
					end

					-- Если в интерьере, отсчитываем относительно ближайшего фракционного выхода
					local position = localPlayer.position
					if localPlayer.interior > 0 then
						table.sort( FACTIONS_INTERIORS, function( a, b ) return ( localPlayer.position - a.inside ).length < ( localPlayer.position - b.inside ).length end )
						position = FACTIONS_INTERIORS[ 1 ].outside
					end

					-- Выбираем только ближайшие
					local locations = { }
					for i, v in pairs( CONST_PED_POSITIONS[ city ] ) do
						if ( position - v ).length <= 600 then
							table.insert( locations, v )
						end
					end

					if #locations <= 0 then
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "SYSTEM ERROR, бомж свалил!" } )
					end
					
					local index = math.random( 1, #locations )
					CEs.ped = createPed( 6726, locations[ index ], math.random(0, 360) )
					setPedAnimation( CEs.ped,  "crack", "crckidle"..math.random(1,4), -1, true, false, false, false )
					addEventHandler("onClientPedDamage", CEs.ped, cancelEvent)

					CreateQuestPoint( locations[ index ], function()
						if not isElement( localPlayer.vehicle ) or localPlayer.vehicle:GetFaction() ~= localPlayer:GetFaction() then
							localPlayer:ShowError( "Ты не в полицейской машине" )
							return
						end

						if localPlayer.vehicleSeat > 1 then
							localPlayer:ShowError( "Ты не водитель или не на переднем сиденье" )
							return
						end

						CEs.marker.destroy()
						triggerServerEvent( "PlayerAction_Task_PPS_1_step_3", localPlayer )
					end, _, _, 0, 0 )
				end;
			};

			CleanUp = {
				client = function()
				end;
			};

			event_end_name = "PlayerAction_Task_PPS_1_step_3";
		};
		[4] = {
			name = "Доставь бездомного в участок";

			Setup = {
				client = function()
					CreateQuestPoint( CONST_END_POINT[ localPlayer:GetFactionDutyCity() ], "PlayerAction_Task_PPS_1_step_4", _, _, 0, 0 )
				end;

				server = function( player )
					if not isElement( player.vehicle ) or player.vehicle:GetFaction() ~= player:GetFaction( ) then
						triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Ты не в полицейской машине" } )
						return
					end

					local ped = createPed( 6726, player.position, 0 )
					player:SetPrivateData( "quest_ped", ped )

					ped:warpIntoVehicle( player.vehicle, 1 )
				end;
			};

			CleanUp = {
				server = function( player )
					local ped = player:getData( "quest_ped" )
					player:SetPrivateData( "quest_ped", nil )
					if isElement(ped) then
						destroyElement(ped)
					end
				end;
			};

			event_end_name = "PlayerAction_Task_PPS_1_step_4";
		};
	};

	GiveReward = function( player )
		player:CompleteDailyQuest( "pps_sweep_city" )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_pps_1", 100 )
	end;
	success_text = "Задача выполнена! Вы получили +100 очков";

	rewards = {
		faction_exp = 100;
	};
}