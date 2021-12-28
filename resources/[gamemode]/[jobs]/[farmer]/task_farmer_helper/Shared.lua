SHIT_POSITIONS = {
	[ 0 ] = {
		Vector3( -1304.7, -229.29999 + 860, 28.1 ),
		Vector3( -1492.2, -415.10001 + 860, 20.1 ),
		Vector3( -1288.4, -289.90002 + 860, 26.3 ),
	},
	[ 1 ] ={
		Vector3( -1293, -624.39999 + 860, 20.7 ),
		Vector3( -1316.1, -459.79999 + 860, 20.3 ),
	},
}

BASE_POSITIONS = {
	[ 0 ] = {
		Vector3( -1281.5, -288.40002 + 860, 25.8 ),
		Vector3( -1297, -235.79999 + 860, 28.4 ),
		Vector3( -1483.7, -419.89999 + 860, 20.3 ),
	},
	[ 1 ] = {
		Vector3( -1276.6, -626.3 + 860, 20.5 ),
		Vector3( -1310, -616.39999 + 860, 20.9 ),
		Vector3( -1301.4, -458.29999 + 860, 20 ),
	},
}

OBJECT_HEIGHTS = {
	[ 630 ] = 0.5,
	[ 628 ] = 1,

	[ 635 ] = 0.3,
	[ 633 ] = 0.55,

	[ 632 ] = 0.3,
	[ 631 ] = 0.55,
}

CONST_WAIT_TIME = 0.5 * 60 * 1000

addEvent( "onFarmerEarnMoney", true )

QUEST_DATA = {
	id = "task_farmer_helper";

	title = "Ферма";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_FARMER
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Посади растения";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )

					local lines = LINES[ city ]

					LINE_NUMBER = math.random( 1, #lines )
					local line = lines[ LINE_NUMBER ]

					OBJECTS = { }

					local plant_position = 0
					local last_finished = 0
					local function CreateNextPlantMarker( )
						plant_position = plant_position + 1
						if line[ plant_position ] then
							local vec3 = Vector3( line[ plant_position ].x, line[ plant_position ].y, line[ plant_position ].z )
							CreateQuestPoint( vec3, 
								function()
									if getTickCount( ) - last_finished <= 1000 then
										return
									end
									last_finished = getTickCount( )
									CEs.marker:destroy()
									local models = {
										635, 632, 630
									}
									local model = models[ math.random( 1, #models ) ]
									local object = createObject( model, vec3 + Vector3( 0, 0, OBJECT_HEIGHTS[ model ] ), Vector3( 0, 0, math.random( 0, 360 ) ) )
									setElementCollisionsEnabled( object, false )

									table.insert( OBJECTS, object )

									setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )

									CreateNextPlantMarker( )
									
									triggerServerEvent( "FarmerDaily_AddPutPlant", localPlayer )
								end
							, _, 2, 0, 0, false, "lalt", plant_position == 1 and "Нажми 'Левый Alt' чтобы посадить растение" or false, "cylinder", 0, 255, 0, 20, true )
							CEs.marker.accepted_elements = { player = true }
						else
							triggerServerEvent( "PlayerAction_Task_Farmer_1_step_1", localPlayer )
						end

					end
					CreateNextPlantMarker( )

				end;
			};

			event_end_name = "PlayerAction_Task_Farmer_1_step_1";
		};
		[2] = {
			name = "Возьми удобрения";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )

					local shit_positions = SHIT_POSITIONS[ city ]
					for i, v in pairs( shit_positions ) do
						CreateQuestPoint( v, 
							function()
								for i = 1, #shit_positions do
									CEs[ "shit_" .. i ]:destroy( )
								end
								setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )
								triggerServerEvent( "PlayerAction_Task_Farmer_1_step_2", localPlayer )
							end
						, "shit_" .. i, 4, 0, 0, false, "lalt", "Нажми 'Левый Alt' чтобы взять удобрения", "cylinder", 255, 100, 0, 40, true )
						CEs[ "shit_" .. i ].accepted_elements = { player = true }
					end
				end;
			};

			event_end_name = "PlayerAction_Task_Farmer_1_step_2";
		};
		[3] = {
			name = "Удобри почву";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )

					local line = LINES[ city ][ LINE_NUMBER ]
					local plant_position = #OBJECTS
					local last_finished = 0
					local function CreateNextPlantMarker( )
						if line[ plant_position ] then
							local vec3 = Vector3( line[ plant_position ].x, line[ plant_position ].y, line[ plant_position ].z )
							CreateQuestPoint( vec3, 
								function()
									if getTickCount( ) - last_finished <= 1000 then
										return
									end
									last_finished = getTickCount( )
									CEs.marker:destroy()
									plant_position = plant_position - 1
									setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )
									CreateNextPlantMarker( )
								end
							, _, 2, 0, 0, false, "lalt", plant_position == #OBJECTS and "Нажми 'Левый Alt' чтобы удобрить растение" or false, "cylinder", 200, 200, 0, 20, true )
							CEs.marker.accepted_elements = { player = true }
						else
							triggerServerEvent( "PlayerAction_Task_Farmer_1_step_3", localPlayer )

						end
					end
					CreateNextPlantMarker( )

				end;
				CleanUp = function()

				end;
			};

			event_end_name = "PlayerAction_Task_Farmer_1_step_3";
		};
		[4] = {
			name = "Ожидай пока всё подрастёт...";
			Setup = {
				client = function()
					StartQuestTimerWait( CONST_WAIT_TIME, "Ждем пока всё подрастёт", _, "PlayerAction_Task_Farmer_1_step_4" )
				end;
			};
			event_end_name = "PlayerAction_Task_Farmer_1_step_4";
		},
		[5] = {
			name = "Собери растения";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )

					local line = LINES[ city ][ LINE_NUMBER ]

					local new_model_list = {
						[ 630 ] = 628,
						[ 632 ] = 631,
						[ 635 ] = 633
					}
					for i, v in pairs( OBJECTS ) do
						local new_model = new_model_list[ v.model ]
						v.model = new_model
						local vec3 = Vector3( line[ i ].x, line[ i ].y, line[ i ].z )
						v.position = vec3 + Vector3( 0, 0, OBJECT_HEIGHTS[ new_model ] )
					end

					local last_finished = 0
					local plant_position = 1
					local function CreateNextPlantMarker( )
						if line[ plant_position ] then
							local vec3 = Vector3( line[ plant_position ].x, line[ plant_position ].y, line[ plant_position ].z )
							CreateQuestPoint( vec3, 
								function()
									if getTickCount( ) - last_finished <= 1000 then
										return
									end
									last_finished = getTickCount( )
									CEs.marker:destroy()
									OBJECTS[ plant_position ]:destroy()
									setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )
									plant_position = plant_position + 1
									triggerServerEvent( "FarmerDaily_AddPlant", localPlayer )
									CreateNextPlantMarker( )
								end
							, _, 2, 0, 0, false, "lalt", plant_position == 1 and "Нажми 'Левый Alt' чтобы выкопать растение" or false, "cylinder", 0, 100, 255, 20, true )
							CEs.marker.accepted_elements = { player = true }
						else
							triggerServerEvent( "PlayerAction_Task_Farmer_1_step_5", localPlayer )

						end
					end
					CreateNextPlantMarker( )

				end;
			};

			event_end_name = "PlayerAction_Task_Farmer_1_step_5";
		};

		[6] = {
			name = "Отнеси растения в ящик";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )

					local line = LINES[ city ][ LINE_NUMBER ]
					local box_position = line[ math.random( #line - 4, #line - 2 ) ]
					local vec3 = Vector3( box_position.x, box_position.y, box_position.z )

					CEs.object = createObject( 627, vec3 + Vector3( 0, 0, 0.2 ), Vector3( 0, 0, math.random( 0, 360 ) ) )

					CreateQuestPoint( vec3,
						function()
							CEs.object:destroy()
							CEs.marker:destroy()
							setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )
							triggerServerEvent( "PlayerAction_Task_Farmer_1_step_6", localPlayer )
						end
					, _, 2, 0, 0, false, "lalt", "Нажми 'Левый Alt' чтобы сложить растения в ящик и взять его в руки", "cylinder", 255, 255, 255, 20, true )
					CEs.marker.accepted_elements = { player = true }
				end;
			};

			event_end_name = "PlayerAction_Task_Farmer_1_step_6";
		};

		[7] = {
			name = "Отнеси ящик";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local targets = BASE_POSITIONS[ city ]

					StartCarrying( { model = 627, offset_y = 0.4, rx = 0, ry = 140, rz = 90 } )

					for i, v in pairs( targets ) do
						CreateQuestPoint( v, 
							function()
								for i = 1, #targets do
									CEs[ "base_" .. i ]:destroy( )
								end
								triggerServerEvent( "PlayerAction_Task_Farmer_1_step_7", localPlayer )
							end
						, "base_" .. i, 2, 0, 0, false, "lalt", "Нажми 'Левый Alt' чтобы положить ящик на место", "cylinder", 255, 20, 0, 20, true )
						CEs[ "base_" .. i ].accepted_elements = { player = true }
					end
				end
			};
			CleanUp = {
				client = function()
					StopCarrying( )
					triggerServerEvent( "FarmerDaily_AddBox", localPlayer )
				end;
			};
			event_end_name = "PlayerAction_Task_Farmer_1_step_7";
		};
	};

	GiveReward = function( player )
		local ids = {
			farmer_company_1 = true,
			farmer_company_2 = true,
			farmer_company_3 = true,
		}
		local job_id = player:GetJobID( )
		if not ids[ job_id ] then
			onFarmerBoxPass_handler( player )
			StartAgain( player )

		else
			setTimer( function()
				if not isElement( player ) then return end
				triggerEvent( "onFarmerEndHelperQuest", player, player )
				triggerEvent( "PlayeStartQuest_task_farmer_company", player )
			end, 250, 1 )
		end
	end;

	no_show_rewards = true;
	no_show_success = true;
}

function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 5000, 1 )
end