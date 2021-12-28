CONST_START_VEH_POSITION = {
	Vector3( 402.526, -2541.502, 21.222 ),
	Vector3( 1914.849, -561.802, 61.018 ),
	Vector3( 1256.0161132813, 2760.5087890625, 10.287155151367 )
}
CONST_LOADING_POSITION = {
	Vector3( 421.830, -2477.696, 22.479 ),
	Vector3( 1909.574, -521.774, 61.020 ),
	Vector3( 1243.9731445313, 2745.0681152344, 9.946629524231 )
}
CONST_AFTER_LOADING_VEH_POSITION = {
	Vector3( 442.365, -2483.769, 21.218 ),
	Vector3( 1910.242, -510.629, 60.903 ),
	Vector3( 1290.6416015625, 2755.0981445313, 9.9520416259766 ),
}
CONST_UNLOADING_POSITION = Vector3( -1895.986, -1409.181, 21.653 )
CONST_AFTER_UNLOADING_VEH_POSITION = Vector3( -1894.321, -541.674, 21.877 )
CONST_END_POSITION = {
	Vector3( 483.684, -2439.419, 20.990 ),
	Vector3( 1917.486, -499.416, 60.856 ),
	Vector3( 1234.7757568359, 2760.7658691406, 9.9029302597046 )
}
CONST_COUNT_DEATH = 15
CONST_TIMEOUT = 300000
CONST_WARN_EXP = 30
QUEST_PEDS = {
	16, -- NSK
	17, -- GRK
	27, -- MSK
}

QUEST_DATA = {
	id = "task_medic_2";

	title = "Переполнение морга";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 120;
	failed_timeout = 60;

	tasks = {
		[1] = {
			name = "Поговори с доктором";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( QUEST_PEDS[ localPlayer:GetFactionDutyCity( ) ], {
						{
							text = [[— Приветствую. В морге накопилось достаточно
									много трупов. Держи ключи от машины, загрузись
									и отвези их на кладбище.]];
						};
						{
							text = [[— После загрузки у тебя в багажнике будет
									]].. CONST_COUNT_DEATH ..[[ тел. При каждом повреждении транспорта,
									ты будешь терять по 1 трупу и ]].. CONST_WARN_EXP ..[[ оч. опыта]];
							info = true;
						};
					}, "PlayerAction_Task_Medic_2_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_2_step_1";
		};
		[2] = {
			name = "Загрузи трупы";

			Setup = {
				client = function()
					localPlayer.interior = 0
					localPlayer.dimension = 0
					StartQuestTimerFail( 30000, "Загрузи тела", "Слишком медленно!" )
					CreateQuestPoint( CONST_LOADING_POSITION[ localPlayer:GetFactionDutyCity() ], function()
						if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
							triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Ты не в выданном транспорте" } )
							return
						end

						CEs.marker.destroy()

						if isTimer( CEs.timer ) then
							killTimer( CEs.timer )
						end

						fadeCamera( false, 1 )
						CEs.timer = Timer( triggerServerEvent, 2000, 1, "PlayerAction_Task_Medic_2_step_2", localPlayer )
					end )
				end;

				server = function( player )
					local city = player:GetFactionDutyCity()
					local vehicle = CreateTemporaryQuestVehicle( player, 416, CONST_START_VEH_POSITION[ city ].x, CONST_START_VEH_POSITION[ city ].y, CONST_START_VEH_POSITION[ city ].z, 0, 0, 329 )
					vehicle:SetFuel( "full" )
					player.interior = 0
					player.dimension = 0
					player:warpIntoVehicle( vehicle )

					addEventHandler("onVehicleStartEnter", vehicle, function( enter_player, seat )
						if seat == 0 and enter_player ~= player then
							cancelEvent()
						end
					end)
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_2_step_2";
		};
		[3] = {
			name = "Доставь трупы на кладбище";

			Setup = {
				client = function()
					fadeCamera( true, 1 )

					--StartQuestTimerFail( CONST_TIMEOUT, "Доставь тела", "Трупы прогнили, пока ты тащился до кладбища!" )
					CreateQuestPoint( CONST_UNLOADING_POSITION, function()
						if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
							localPlayer:ShowError( "Ты не в выданном транспорте" )
							triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Ты не в выданном транспорте" } )
							return
						end

						CEs.marker.destroy()

						if isTimer( CEs.timer ) then
							killTimer( CEs.timer )
						end

						fadeCamera( false, 1 )
						CEs.timer = Timer( triggerServerEvent, 2000, 1, "PlayerAction_Task_Medic_2_step_3", localPlayer )
					end )
				end;

				server = function( player )
					local city = player:GetFactionDutyCity()
					local vehicle = player:getData( "quest_vehicle" )
					vehicle:setData( "death_count", CONST_COUNT_DEATH, false )

					addEventHandler( "onVehicleDamage", vehicle, DeathVehicleDamage_handler )
				end;
			};

			CleanUp = {
				server = function( player )
					local vehicle = player:getData( "quest_vehicle" )
					removeEventHandler( "onVehicleDamage", vehicle, DeathVehicleDamage_handler )
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_2_step_3";
		};
		[4] = {
			name = "Верни транспорт на парковку";

			Setup = {
				client = function()
					fadeCamera( true, 1 )

					CreateQuestPoint( CONST_END_POSITION[ localPlayer:GetFactionDutyCity() ], function()
						if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
							triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Ты не в выданном транспорте" } )
							return
						end

						CEs.marker.destroy()
						localPlayer:CompleteDailyQuest( "medic_overflow_morgue" )
						triggerServerEvent( "PlayerAction_Task_Medic_2_step_4", localPlayer )
					end )
				end;

				server = function( player )
					local vehicle = player:getData( "quest_vehicle" )

					addEventHandler( "onVehicleDamage", vehicle, function()
						if not isElement( player ) then
							destroyElement( source )
							return
						end
						
						if source.health <= 700 then
							triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Вы повредили автомобиль" } )
						end
					end )
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_2_step_4";
		};
	};

	GiveReward = function( player ) 
		player:CompleteDailyQuest( "dps_watch_posts" ) 
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_medic_2", 150 ) 
	end; 
	success_text = "Задача выполнена! Вы получили +150 очков";

	rewards = {
		faction_exp = 150;
	};
}

function AssignMedicVehicle( vehicle )
	local function onVehicleStartEnter( player, seat )
		if seat == 0 then
			if player:GetFaction( ) ~= F_MEDIC then
				player:ShowError( "Данный транспорт принадлежит медикам" )
				cancelEvent( )
			end
		end
	end
	addEventHandler( "onVehicleStartEnter", vehicle, onVehicleStartEnter )
end


function DeathVehicleDamage_handler()
	local death_count = source:getData( "death_count" )
	if not death_count then
		triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Автомобиль поврежден" } )
		return
	end

	death_count = death_count - 1
	source:setData( "death_count", death_count, false )

	if death_count == 0 then
		triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Ты растерял все трупы" } )
	else
		player:ShowInfo( "Ты потерял 1 тело, осталось еще ".. death_count .."!" )
		-- todo
		--player:TakeFactionExp( CONST_WARN_EXP, "Quest.task_medic_2" )
	end
end