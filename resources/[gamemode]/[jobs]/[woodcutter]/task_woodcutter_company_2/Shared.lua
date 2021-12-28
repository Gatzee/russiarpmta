QUEST_DATA = {
	id = "task_woodcutter_company_2";

	title = "Доставка древесины";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_WOODCUTTER
	end;

	replay_timeout = 0;

	tasks = {
		[1] = 
		{
            name = "Отправляйся к участку";

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
					SetControlState( false )
					
					local bunch_id = nil
					repeat
						bunch_id = math.random( 1, #BUNCH_TREES )
					until bunch_id ~= CURRENT_BUNCH_ID
					CURRENT_BUNCH_ID = bunch_id

					CreateQuestPoint( BUNCH_TREES[ CURRENT_BUNCH_ID ].position, function()
						CEs.marker:destroy()
						triggerServerEvent( "PlayerAction_Task_Woodcutter_2_step_1", localPlayer )
					end, _, 50, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					CEs.marker.accepted_elements = { vehicle = true }
					CEs.marker.slowdown_coefficient = nil
                end
            },

            event_end_name = "PlayerAction_Task_Woodcutter_2_step_1";
		},

		[2] = 
		{
			name = "Подготовь и загрузи древесину";

			Setup = 
			{
				
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					local count_woods = 0
					local start_operation = false

					--Взять дерево
					function GetWood()
						CreateQuestPoint(  BUNCH_TREES[ CURRENT_BUNCH_ID ].position, function()
							if start_operation then return end
							start_operation = true
							
							createMiniGame({
								[ 1 ] = 
								{
									action = function()
										local element = ibCreateMouseKeyPress({
											texture = "img/hint6.png",
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
											stock_name = BUNCH_TREES[ CURRENT_BUNCH_ID ].name,
											callback = function()
												triggerServerEvent( "onWoodcutterGetFromStock", localPlayer, BUNCH_TREES[ CURRENT_BUNCH_ID ].name, 1 )
												start_operation = false
												CEs.marker:destroy()
												PlaceWood()
												SetCarryingState( true )
												createNextGameStep()
											end,
											check = function()
												if STOCKS[ BUNCH_TREES[ CURRENT_BUNCH_ID ].name ] == 0 then
													localPlayer:ShowInfo("В куче недостаточно древесины!")
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
								}
							})
							
						end, _, 10, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
						CEs.marker.accepted_elements = { player = true }
					end

					--Положить дерево
					function PlaceWood()
						local place_id = math.random( 1, #BUNCH_TREES[ CURRENT_BUNCH_ID ].places )
						local wood_position = BUNCH_TREES[ CURRENT_BUNCH_ID ].places[ place_id ]
						CreateQuestPoint(  wood_position, function()
							if start_operation then return end
							start_operation = true

							createMiniGame({
								[1] =
								{
									action = function()
										local element = ibCreateMouseKeyPress({
											texture = "img/hint2.png",
											key = "lalt",
											callback = function()
												start_operation = false
												CEs.marker:destroy()
												WOOD_PROCESS = createObject( 781, wood_position.x, wood_position.y, wood_position.z - 1, Vector3( 82, 0, localPlayer.rotation.z + 180 ) )
												ProcessWood()
												createNextGameStep()
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

						end,_, 2, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
						CEs.marker.accepted_elements = { player = true }
					end

					--Обработать дерево, срубить ветки
					function ProcessWood()
						local count_process_wood_operation = 0
						local wood_pos = WOOD_PROCESS:getPosition()
						local wood_rot = WOOD_PROCESS:getRotation().z - 90

						function createNextPoint()
							local wood_position = getPointInFrontOfPoint( wood_pos, wood_rot, (count_process_wood_operation + 1) * 2.5 )
							CreateQuestPoint( wood_position, function()
								if start_operation then return end
								start_operation = true

								createMiniGame({
									[1] =
									{
										action = function()
											local element = ibCreateMouseKeyPress({
												texture = "img/hint3.png",
												key = "mouse1",
												callback = function()
													CEs.marker:destroy()
													count_process_wood_operation = count_process_wood_operation + 1
													if count_process_wood_operation >= 3 then
														TakeWood( WOOD_PROCESS:getPosition() )
													else
														createNextPoint()
													end
													start_operation = false
												end,
												check = function()
													if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
														localPlayer:setWeaponSlot( 10 )
														localPlayer:setAnimation( "baseball", "bat_4", -1, false, false, false, false )
														setTimer( function() 
															local sound = playSound( "sfx/hit_blow.mp3" )
															sound:setVolume( 0.3 )
														end, 250, 1 )
														return true
													else
														localPlayer:ShowInfo("Вернись к точке, чтобы срубить ветку!")
													end
												end
											})
											return element
										end
									},
								})

							end, _, 2, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
							CEs.marker.accepted_elements = { player = true }
						end
						createNextPoint()
					end

					function TakeWood( wood_position )
						CreateQuestPoint( wood_position, function()
							if start_operation then return end
							start_operation = true

							createMiniGame({
								[1] =
								{
									action = function()
										local element = ibCreateMouseKeyPress({
											texture = "img/hint1.png",
											key = "lalt",
											callback = function()
												WOOD_PROCESS:destroy()
												WOOD_PROCESS = nil
												CEs.marker:destroy()
												LoadWoodToVehicle()
												SetCarryingState( true )
												start_operation = false
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

						end, _, 2, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					end

					--Загрузить дерево в лесовоз
					function LoadWoodToVehicle()
						local player_vehicle = localPlayer:getData("job_vehicle")
						local vehicle_pos = player_vehicle:getPosition() + Vector3( math.random( -1, 1 ), math.random( -1, 1 ), 0 )
						CreateQuestPoint( Vector3(vehicle_pos.x, vehicle_pos.y, vehicle_pos.z - 1), function()
								if start_operation then return end
								start_operation = true

								createMiniGame({
									[1] =
									{
										action = function()
											local element = ibCreateMouseKeyPress({
												texture = "img/hint4.png",
												key = "lalt",
												callback = function()
													CEs.marker:destroy()
													count_woods = count_woods + 1
													if count_woods >= 5 then
														triggerServerEvent( "PlayerAction_Task_Woodcutter_2_step_2", localPlayer )
													else
														GetWood()
													end
													SetCarryingState( false )
													start_operation = false
												end,
												check = function()
													if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
														return true
													else
														localPlayer:ShowInfo("Вернись к точке, чтобы загрузить древесину!")
													end
												end
											})
											return element
										end
									},
								})

							end, _, 5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
							CEs.marker.accepted_elements = { player = true }
					end

					GetWood()
				end;

				server = function( player )
					player:GiveWeapon( 15, 1, true, true )
				end

			};

			CleanUp = {

				client = function()
					SetCarryingState( false )
				end;

				server = function( player, data )
					player:TakeWeapon( 15 )
					local playerVehicle = player:getData( "job_vehicle" )
					if playerVehicle and isElement( playerVehicle ) then
						player:warpIntoVehicle( playerVehicle )
					end
				end;

			};

			event_end_name = "PlayerAction_Task_Woodcutter_2_step_2";
		};

		[3] = {
            name = "Отвези древесину на лесопилку";

            Setup = {
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end
					
					local bunch_stock_id = nil
					repeat
						bunch_stock_id = math.random( 1, #STOCK_BUNCH )
					until bunch_stock_id ~= CURRENT_BUNCH_ID
					CURRENT_STOCK_BUNCH_ID = bunch_stock_id

					CreateQuestPoint( STOCK_BUNCH[ CURRENT_STOCK_BUNCH_ID ].position, function()
						local pvehicle = localPlayer:getOccupiedVehicle()
						if not pvehicle then
							localPlayer:ShowInfo("А где лесовоз? Возвращайся на лесовозе")
							return
						end
						CEs.marker:destroy()
						triggerServerEvent( "onWoodcutterAddStockValue", localPlayer, STOCK_BUNCH[ CURRENT_STOCK_BUNCH_ID ].name, 5 )
						triggerServerEvent( "PlayerAction_Task_Woodcutter_2_step_3", localPlayer )
					end, _, 25, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					CEs.marker.slowdown_coefficient = nil
				end,
				
				server = function( player, data )
					player:TakeWeapon( 15 )
				end
            },

            event_end_name = "PlayerAction_Task_Woodcutter_2_step_3";
		},
		
	};
	
	GiveReward = function( player )
		triggerEvent( "onWoodcutterFinishedMoveWood", resourceRoot, player )
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
