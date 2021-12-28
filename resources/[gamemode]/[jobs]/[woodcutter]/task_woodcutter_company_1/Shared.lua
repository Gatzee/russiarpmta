
QUEST_DATA = {
	id = "task_woodcutter_company_1";

	title = "Заготовка древесина";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_WOODCUTTER
	end;

	replay_timeout = 0;

	tasks = {
		
		[1] = {
            name = "Отправляйся к участку";

            Setup = {
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					if not CHECK_POS_TIMER then
						addEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle ) 
						StartCheckPosition( CENTER_WOOD_POINT )
					end
					if #RESTORE_TREES > 0 then
						RestorePrevTrees()
					end
					SetControlState( false )
					
					local bunch_id = nil
					repeat
						bunch_id = math.random( 1, #BUNCH_TREES )
					until bunch_id ~= CURRENT_BUNCH_ID
					CURRENT_BUNCH_ID = bunch_id

					CreateQuestPoint( BUNCH_TREES[ CURRENT_BUNCH_ID ].position, function()
						triggerServerEvent( "PlayerAction_Task_Woodcutter_1_step_1", localPlayer )
					end, _, 50, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
					CEs.marker.slowdown_coefficient = nil
				end,
				
				server = function( player )
					player:GiveWeapon( 15, 1, true, true )
				end
            },

            event_end_name = "PlayerAction_Task_Woodcutter_1_step_1";
		},

		[2] = {
			name = "Сруби и сложи 5 деревьев",

			Setup = {
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end
					
					local start_cut = false
					local start_move = false
					local start_place = false
					local count_cut_trees = 0

					--Рубить дерево
					function StartCutTree()
						
						local wood_id = nil
						CURRENT_WOOD_ID = nil
						repeat
							wood_id = math.random( 1, #BUNCH_TREES[ CURRENT_BUNCH_ID ].woods )
							if PROXY_TREES[ CURRENT_BUNCH_ID .. wood_id ]:getAlpha() == 0 then
								wood_id = nil
							end
						until wood_id ~= CURRENT_WOOD_ID
						CURRENT_WOOD_ID = wood_id

						local current_position = BUNCH_TREES[ CURRENT_BUNCH_ID ].woods[ CURRENT_WOOD_ID ]
						
						CreateQuestPoint( Vector3( current_position.x + 1.8, current_position.y, current_position.z - 0.3 ), 
							function()
								if start_cut then return end
								start_cut = true

								createMiniGame({
									[1] =
									{
										--Срубить дерево
										action = function()

											local element = ibCreateMouseKeyStroke({
												
												texture = "img/hint1.png";
												
												callback = function()
													localPlayer:setFrozen( false )
													toggleControl( 'jump', true )
													PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ]:setRotation( 0, 0, localPlayer.rotation.z + 180 )
													moveObject( 
														PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ], 
														6000, 
														BUNCH_TREES[ CURRENT_BUNCH_ID ].woods[ CURRENT_WOOD_ID ].x, 
														BUNCH_TREES[ CURRENT_BUNCH_ID ].woods[ CURRENT_WOOD_ID ].y, 
														BUNCH_TREES[ CURRENT_BUNCH_ID ].woods[ CURRENT_WOOD_ID ].z - 1, 
														82, 0, 0,
														"OutBounce", nil, 0.1, 0.1
													)
													local sound = Sound("sfx/falling_tree3.mp3")
													sound:setVolume( 0.1 )
													CEs.marker:destroy()
													setTimer( function()
														StartMoveTree()
													end, 2100, 1 )
													table.insert( RESTORE_TREES, PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ] )
												end;

												check = function()
													if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
														
														localPlayer:setRotation( 0,  0, 
															FindRotation( 
																localPlayer.position.x, 
																localPlayer.position.y, 
																PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ].position.x, 
																PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ].position.y 
														) )
														
														localPlayer:setPosition(localPlayer:getPosition())
														localPlayer:setFrozen( true )
														toggleControl( 'jump', false )
														return true
													else
														localPlayer:ShowInfo("Вернись к дереву, чтобы его срубить!")
													end
												end;

												click_action = function()
													localPlayer:setWeaponSlot( 10 )
													localPlayer:setAnimation( "sword", "sword_3", -1, false, false, false, false )
													setTimer( function() 
														local sound = playSound( "sfx/hit_blow.mp3" )
														sound:setVolume( 0.3 )
													end, 200, 1 )
												end;
												timeout = 800;
											})

											return element
											
										end
									}
								})

							end
						,_, 1.3, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
						CEs.marker.accepted_elements = { player = true }
						CEs.marker.slowdown_coefficient = nil
						
					end

					--Взять дерево
					function StartMoveTree()
						CreateQuestPoint(  PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ]:getPosition(), 
							function()
								if start_move then return end
								start_move = true

								createMiniGame({
									[1] =
									{
										action = function()

											local element = ibCreateMouseKeyPress({
												texture = "img/hint2.png",
												key = "lalt",
												callback = function()
													PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ]:setAlpha( 0 )
													PROXY_TREES[ CURRENT_BUNCH_ID .. CURRENT_WOOD_ID ]:setCollisionsEnabled( false )
													createNextGameStep()
													CEs.marker:destroy()
													SetCarryingState( true )
													PlaceTree()
												end,
												check = function()
													if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
														return true
													else
														localPlayer:ShowInfo("Вернись к дереву, чтобы взять его!")
													end
												end
											})
											return element

										end
									},
								})

							end
						,_, 2, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
						CEs.marker.accepted_elements = { player = true }
					end

					--Положить дерево
					function PlaceTree()
						CreateQuestPoint(  BUNCH_TREES[ CURRENT_BUNCH_ID ].position, 
							function()
								if start_place then return end
								start_place = true

								createMiniGame({
									[1] =
									{
										action = function()
											local element = ibCreateMouseKeyPress({
												texture = "img/hint3.png",
												key = "lalt",
												callback = function()
													CEs.marker:destroy()
													count_cut_trees = count_cut_trees + 1
													if count_cut_trees == 5 then
														triggerServerEvent( "PlayerAction_Task_Woodcutter_1_step_2", localPlayer )
													else
														start_cut = false
														start_move = false
														start_place = false
														StartCutTree()
													end
													--Добавляем дерево на склад
													triggerServerEvent( "onWoodcutterAddStockValue", localPlayer, BUNCH_TREES[ CURRENT_BUNCH_ID ].name, 1 )
													SetCarryingState( false )
												end,
												check = function()
													if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
														return true
													else
														localPlayer:ShowInfo("Вернись к куче, чтобы положить дерево!")
													end
												end
											})
											return element
										end
									}
								})
							end
						,_, 10, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
						CEs.marker.accepted_elements = { player = true }
					end

					StartCutTree()
				end
			},

			CleanUp = {

				client = function()
					SetCarryingState( false )
					toggleControl( 'jump', true )
				end;

				server = function( player, data )
					player:TakeWeapon( 15 )

					local playerVehicle = player:getData( "job_vehicle" )
					if playerVehicle and isElement( playerVehicle ) then
						player:warpIntoVehicle( playerVehicle )
					end
				end;

			};

			event_end_name = "PlayerAction_Task_Woodcutter_1_step_2";
		}
		
	};
	
	GiveReward = function( player )
		triggerEvent( "onWoodcutterFinishedCutting", resourceRoot, player )
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
