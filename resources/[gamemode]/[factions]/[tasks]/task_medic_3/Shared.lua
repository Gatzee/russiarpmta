CONST_NEED_COUNT_BOX = 40
QUEST_PEDS = {
	16, -- NSK
	17, -- GRK
	27, -- MSK
}

CONST_POINTS = {
	[1] = {
		Vector3( 397.944, -2481.443 + 860, 21.056 );
		Vector3( 417.284, -2471.807 + 860, 23.705 );
	};
	[2] = {
		Vector3( 1938.688, -569.299 + 860, 60.791 );
		Vector3( 1932.535, -586.958 + 860, 61.152 );
	};
	[3] = {
		Vector3( 1244.5224609375, 2744.6433105469 + 860, 9.9490146636963 );
		Vector3( 1291.7811279297, 2750.4938964844 + 860, 10.908500671387 );
	};
}

CARRYING_CONTROLS = { "jump", "sprint", "fire", "crouch", "aim_weapon", "enter_exit", "next_weapon", "previous_weapon", "enter_passenger" }

QUEST_DATA = {
	id = "task_medic_3";

	title = "Разгрузка медикаментов";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с доктором";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( QUEST_PEDS[ localPlayer:GetFactionDutyCity( ) ], {
						{
							text = [[— Приветствую. В палатах много больных, а
									медикаменты постепенно кончаются. Выходи на
									задний двор, там приехала машина с новой партией
									припаратов, разгрузи её и побыстрее.]];
						};
					}, "PlayerAction_Task_Medic_3_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_3_step_1";
		};
		[2] = {
			name = "Разгрузи медикаменты";

			Setup = {
				client = function()
					local duty_city = localPlayer:GetFactionDutyCity()
					local count_box = CONST_NEED_COUNT_BOX
					local current_index = 0

					CEs.func_create_start = function( )
						if CEs.marker and isElement( CEs.marker.colshape ) then
							if localPlayer.vehicle then return end
							
							CEs.marker.destroy()
						end

						if isElement( CEs.object ) then
							for k, v in pairs( CARRYING_CONTROLS ) do
								toggleControl( v, true )
							end
							triggerEvent( "onClientUpdateDiseasesMoveHandler", root, true )

							destroyElement( CEs.object )
							setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
							
							count_box = count_box - 1

							if count_box == 0 then
								triggerServerEvent( "PlayerAction_Task_Medic_3_step_2", localPlayer )
								localPlayer:CompleteDailyQuest( "medic_unload_medicines" )
								return
							else
								localPlayer:ShowInfo( "Осталось перенести еще ".. count_box .." шт." )
							end
						end

						current_index = current_index % 2 + 1
						CreateQuestPoint( CONST_POINTS[ duty_city ][ current_index ], CEs.func_create_end_point, _, 2, 0, 0 )
					end

					CEs.func_create_end_point = function( )
						if localPlayer.vehicle then return end

						CEs.marker.destroy()

						CEs.object = Object( 1271, localPlayer.position )
						CEs.object.scale = 0.5
						exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.15, 0.4, 0.2, 0, 180, 0 )
						setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
						localPlayer.weaponSlot = 0

						triggerEvent( "onClientUpdateDiseasesMoveHandler", root, false )
						for k, v in pairs( CARRYING_CONTROLS ) do
							toggleControl( v, false )
						end
						
						current_index = current_index % 2 + 1
						CreateQuestPoint( CONST_POINTS[ duty_city ][ current_index ], CEs.func_create_start, _, 2, 0, 0 )
					end

					CEs.func_create_start()
				end;
			};

			CleanUp = {
				client = function()
					CEs.func_create_start = nil
					CEs.func_create_end_point = nil

					for k, v in pairs( CARRYING_CONTROLS ) do
						toggleControl( v, true )
					end
					triggerEvent( "onClientUpdateDiseasesMoveHandler", root, true )

					setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
				end;
			};

			event_end_name = "PlayerAction_Task_Medic_3_step_2";
		};
	};


	GiveReward = function( player )
		player:CompleteDailyQuest( "dps_watch_posts" )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_medic_3", 250 )
	end;
	success_text = "Задача выполнена! Вы получили +250 очков";

	rewards = {
		faction_exp = 250;
	};
}