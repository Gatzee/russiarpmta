
QUEST_DATA = {
	id = "task_woodcutter_company_3";

	title = "Обработать древесину";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_WOODCUTTER
	end;

	replay_timeout = 0;

	tasks = {
		
		[1] =
		{
			name = "Отправляйся на склад древесины";

			Setup = 
			{
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					if not CHECK_POS_TIMER then
						addEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle ) 
						StartCheckPosition( CENTER_WOOD_POINT )
					end

					local stock_id = nil
					repeat
						stock_id = math.random( 1, #STOCK )
					until stock_id ~= STOCK_ID
					STOCK_ID = stock_id

					CreateQuestPoint( STOCK[ STOCK_ID ].position, function()
						CEs.marker:destroy()
						triggerServerEvent( "PlayerAction_Task_Woodcutter_3_step_1", localPlayer )
					end, _, 35, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					CEs.marker.slowdown_coefficient = nil
				end
			};
			
			event_end_name = "PlayerAction_Task_Woodcutter_3_step_1";

		};

		[2] = 
		{
			name = "Возьми древесину";

			Setup =
			{
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					local start_operation = false
					
					local take_position = STOCK[ STOCK_ID ].take_position[ math.random(1, #STOCK[ STOCK_ID ].take_position) ]
					CreateQuestPoint( take_position, function()
						if start_operation then return end
						start_operation = true

						createMiniGame({

							[ 1 ] = 
							{
								action = function()
									local element = ibCreateKeyPress({
										texture = "img/hint8.png",
										key = "lalt",
										callback = function()
											CEs.marker.marker:setColor( 30, 160, 60, 0 )
											createNextGameStep()
										end,
										check = function()
											if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
												return true
											else
												localPlayer:ShowInfo("Вернись к точке, чтобы открыть склад!")
											end
										end,
									})
									return element
								end
							},

							[ 2 ] =
							{
								action = function()
									local element = createStockView({
										stock_name = STOCK[ STOCK_ID ].name,
										callback = function()
											start_operation = false
											CEs.marker:destroy()
											triggerServerEvent( "onWoodcutterGetFromStock", localPlayer, STOCK[ STOCK_ID ].name, 2 )	
											triggerServerEvent( "PlayerAction_Task_Woodcutter_3_step_2", localPlayer )
											createNextGameStep()
											
										end,
										check = function()
											if not isElementWithinMarker( localPlayer, CEs.marker.marker ) then
												localPlayer:ShowInfo("Вернись к складу, чтобы взять дерево!")
											elseif STOCKS[STOCK[ STOCK_ID ].name] < 2 then
												localPlayer:ShowInfo("На складе недостаточно древесины!")
											else
												return true
											end
										end,
										dest = function()
											CEs.marker.marker:setColor( 30, 160, 60, 50 )
											start_operation = false
										end
									})
									return element
								end
							},
						})
					end, _, 2, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					CEs.marker.slowdown_coefficient = nil
					CEs.marker.accepted_elements = { player = true }

				end;
			};

			event_end_name = "PlayerAction_Task_Woodcutter_3_step_2";
		};
		
		[3] = 
		{
            name = "Отправляйся к цеху";

			Setup = 
			{
				client = function()
					SetCarryingState( true )

					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					local sawmill_id = nil
					repeat
						sawmill_id = math.random( 1, #SAWMILL )
					until sawmill_id ~= SAWMILL_ID
					SAWMILL_ID = sawmill_id

					local stock_position = Vector3( SAWMILL[ SAWMILL_ID ].position.x, SAWMILL[ SAWMILL_ID ].position.y, SAWMILL[ SAWMILL_ID ].position.z - 1)
					CreateQuestPoint( stock_position, function()
						triggerServerEvent( "PlayerAction_Task_Woodcutter_3_step_3", localPlayer )
					end, _, 50, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					CEs.marker.slowdown_coefficient = nil
                end
            },

            event_end_name = "PlayerAction_Task_Woodcutter_3_step_3";
		};

		[4] =
		{
			name = "Положи древесину на склад пилорамы",

			Setup = 
			{
				client = function()
					local start_operation = false

					CreateQuestPoint( SAWMILL[ SAWMILL_ID ].stock_sawmill, function()
						if start_operation then return end
						start_operation = true

						createMiniGame({
							[ 1 ] = 
							{
								action = function()
									local element = ibCreateKeyPress({
										texture = "img/hint3.png",
										key = "lalt",
										callback = function()
											CEs.marker:destroy()
											createNextGameStep()
											triggerServerEvent( "PlayerAction_Task_Woodcutter_3_step_4", localPlayer )
										end,
										check = function()
											if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
												return true
											else
												localPlayer:ShowInfo("Вернись к точке, чтобы положить древесину на склад!")
											end
										end,
									})
									return element
								end
							}
						})
					end, _, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )

					CEs.marker.accepted_elements = { player = true }
					CEs.marker.slowdown_coefficient = nil

				end

			},

			event_end_name = "PlayerAction_Task_Woodcutter_3_step_4",

		};

		[5] =
		{
			name = "Обработай древесину";

			Setup = 
			{
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					local count_woods = 0
					local start_operation = false

					function createProcessMarker()
						
						CreateQuestPoint( SAWMILL[ SAWMILL_ID ].process_position, function()
							if start_operation then return end
							start_operation = true
	
							createMiniGame({
								[1] =
								{
									action = function()

										local element = ibCreateKeyPress({
											texture = "img/hint2.png",
											key = "lalt",
											callback = function()
												start_operation = false
												CEs.marker:destroy()
												
												if not SAWMILL_PLAYER_DIMENSION then
													SAWMILL_PLAYER_DIMENSION = localPlayer:GetUniqueDimension( 1000 )
												end
												localPlayer:setDimension( SAWMILL_PLAYER_DIMENSION )

												createMiniGame({
													[1] =
													{
														action = function()
															local parent = nil
															CURRENT_UI_DESK, parent = ibCreateSawmillDesk()
															local element = ibCreateSamwillDeskGame( {
																callback = function()
																	CURRENT_UI_DESK:destroy()
																	start_operation = false
																	localPlayer:setDimension( 0 )
																	createPlaceMarker()
																end,
																count_log = 1,
															}, CURRENT_UI_DESK, parent )
															return element
														end
													}
												})
												
												
											end,
											check = function()
												if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
													return true
												else
													localPlayer:ShowInfo("Вернись к в цех, чтобы начать обработку!")
												end
											end
										})
										return element
									end
								},
							})
							
						end, _, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
						CEs.marker.slowdown_coefficient = nil
						CEs.marker.accepted_elements = { player = true }
					end
					

					function createTakeMarker()

						CreateQuestPoint( SAWMILL[ SAWMILL_ID ].stock_sawmill, function()
							if start_operation then return end
							start_operation = true

							createMiniGame({
								[1] =
								{
									action = function()

										local element = ibCreateKeyPress({
											texture = "img/hint1.png",
											key = "lalt",
											callback = function()
												CEs.marker:destroy()
												start_operation = false
												createProcessMarker()
											end,
											check = function()
												if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
													return true
												else
													localPlayer:ShowInfo("Вернись к точке, чтобы взять древесину!")
												end
											end
										})
										return element
									end
								},
							})
						end, _, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					end
					

					function createPlaceMarker()
						count_woods = count_woods + 1
						if count_woods == 2 then
							triggerServerEvent( "PlayerAction_Task_Woodcutter_3_step_5", localPlayer )
						else
							CreateQuestPoint( SAWMILL[ SAWMILL_ID ].stock_sawmill, function()
								if start_operation then return end
								start_operation = true

								createMiniGame({
									[1] =
									{
										action = function()
	
											local element = ibCreateKeyPress({
												texture = "img/hint3.png",
												key = "lalt",
												callback = function()
													CEs.marker:destroy()
													start_operation = false
													createProcessMarker()
												end,
												check = function()
													if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
														return true
													else
														localPlayer:ShowInfo("Вернись к точке, чтобы положить древесину!")
													end
												end
											})
											return element
										end
									},
								})
							end, _, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
						end	
					end

					createProcessMarker()
				end;
			};

			CleanUp = {
				
				client = function()
					localPlayer:setDimension( 0 )
				end;
				
			};

			event_end_name = "PlayerAction_Task_Woodcutter_3_step_5";
		};

		[6] = 
		{
			name = "Забери обработанную древесину";

			Setup =
			{
				client = function()
					local start_operation = false

					CreateQuestPoint( SAWMILL[ SAWMILL_ID ].stock_sawmill, function()
						if start_operation then return end
						start_operation = true

						createMiniGame({
							[ 1 ] = 
							{
								action = function()
									local element = ibCreateKeyPress({
										texture = "img/hint1.png",
										key = "lalt",
										callback = function()
											CEs.marker:destroy()
											createNextGameStep()
											triggerServerEvent( "PlayerAction_Task_Woodcutter_3_step_6", localPlayer )
										end,
										check = function()
											if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
												return true
											else
												localPlayer:ShowInfo("Вернись к точке, чтобы взять древесину со склад!")
											end
										end,
									})
									return element
								end
							}
						})
					end, _, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )

					CEs.marker.accepted_elements = { player = true }
					CEs.marker.slowdown_coefficient = nil

				end
			};

			CleanUp = {
				server = function( player, data )
					local playerVehicle = player:getData( "job_vehicle" )
					if playerVehicle and isElement( playerVehicle ) then
						player:warpIntoVehicle( playerVehicle )
					end
				end;
			};

			event_end_name = "PlayerAction_Task_Woodcutter_3_step_6";
		};

		[7] =
		{
			name = "Отвези обработанную древесину на склад";

			Setup = 
			{
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					local start_operation = false

					CreateQuestPoint( SAWMILL[ SAWMILL_ID ].stock_result, function()
						if start_operation then return end
						start_operation = true

						createMiniGame({
							[1] =
							{
								action = function()
									local element = ibCreateKeyPress({
										texture = "img/hint3.png",
										key = "lalt",
										callback = function()
											start_operation = false
											CEs.marker:destroy()
											triggerServerEvent( "PlayerAction_Task_Woodcutter_3_step_7", localPlayer )
											SetCarryingState( false )
										end,
										check = function()
											if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
												return true
											else
												localPlayer:ShowInfo("Вернись к складу, чтобы положить дерево!")
											end
										end
									})
									return element
								end
							},
						})

					end, _, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					CEs.marker.slowdown_coefficient = nil
					CEs.marker.accepted_elements = { player = true }
				end;
			};

			event_end_name = "PlayerAction_Task_Woodcutter_3_step_7";
		};
		
	};
	
	GiveReward = function( player )
		triggerEvent( "onWoodcutterFinishedProcessWood", resourceRoot, player )
		StartAgain( player )
	end;

	no_show_rewards = true;
	no_show_success = true;
}	


function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 100, 1 )
end
