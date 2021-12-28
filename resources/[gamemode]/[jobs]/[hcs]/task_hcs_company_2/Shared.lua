CONST_BASE_POSITIONS = {
	[ 0 ] = Vector3( 353.148, -1627.886 + 860, 20.788 );
	[ 1 ] = Vector3( 2269.980, -1134.943 + 860, 60.761 );
}

CONST_HOUSES_POSITIONS = {
	[ 0 ] = {
		{
			Vector3( 97.985, -1565.266 + 860, 21.887 ),
			Vector3( 142.274, -1565.298 + 860, 21.887 ),
			Vector3( 185.102, -1521.446 + 860, 21.887 ),
			Vector3( 98.1, -1543.348 + 860, 21.887 ),
			Vector3( 142.294, -1521.477 + 860, 21.887 ),
			Vector3( 142.318, -1543.408 + 860, 21.887 ),
			Vector3( 98.232, -1521.467 + 860, 21.887 ),
			Vector3( 184.986, -1543.339 + 860, 21.887 ),
			Vector3( 185.074, -1565.254 + 860, 21.887 ),
		};
		{
			Vector3( 23.281, -1869.616 + 860, 21.971 ),
			Vector3( -52.931, -1869.157 + 860, 21.986 ),
			Vector3( 12.787, -1896.1 + 860, 21.971 ),
			Vector3( 26.815, -1789.174 + 860, 21.969 ),
			Vector3( -53.075, -1896.589 + 860, 21.986 ),
			Vector3( -52.817, -1794.901 + 860, 21.986 ),
		};
		{
			Vector3( -53.829, -1274.582 + 860, 20.63 ),
			Vector3( -172.903, -1285.269 + 860, 20.598 ),
			Vector3( -162.786, -1275.316 + 860, 20.598 ),
			Vector3( -83.716, -1293.593 + 860, 20.651 ),
			Vector3( -211.837, -1279.808 + 860, 20.948 ),
			Vector3( -53.762, -1293.541 + 860, 20.639 ),
			Vector3( -41.223, -1293.518 + 860, 20.639 ),
			Vector3( -184.032, -1283.645 + 860, 20.942 ),
			Vector3( -83.848, -1274.572 + 860, 20.637 ),
			Vector3( -239.527, -1283.67 + 860, 20.942 ),
		};
	};
	[ 1 ] = {
		{
			Vector3( 1954.257, -1133.489 + 860, 62.435 ),
			Vector3( 2035.847, -1032.046 + 860, 62.43 ),
			Vector3( 1990.31, -934.464 + 860, 62.427 ),
			Vector3( 2012.267, -1106.405 + 860, 62.435 ),
			Vector3( 1907.087, -931.721 + 860, 62.371 ),
			Vector3( 2059.274, -1081.863 + 860, 62.431 ),
			Vector3( 1937.388, -1093.104 + 860, 62.427 ),
		};
		{
			Vector3( 1878.942, -425.907 + 860, 61.026 ),
			Vector3( 1831.915, -414.883 + 860, 61.04 ),
			Vector3( 1814.768, -461.427 + 860, 61.07 ),
			Vector3( 1832.01, -476.573 + 860, 61.07 ),
			Vector3( 1862.059, -410.485 + 860, 61.026 ),
			Vector3( 1816.595, -431.897 + 860, 61.04 ),
		};
		{
			Vector3{ x = 2404.786, y = -804.345 + 860, z = 60.820 },
			Vector3{ x = 2385.432, y = -742.636 + 860, z = 60.820 },
			Vector3{ x = 2391.462, y = -761.351 + 860, z = 60.820 },
			Vector3{ x = 2377.664, y = -716.770 + 860, z = 60.820 },
			Vector3{ x = 2379.369, y = -649.513 + 860, z = 60.827 },
			Vector3{ x = 2385.405, y = -669.016 + 860, z = 61.555 },
			Vector3{ x = 2371.997, y = -698.071 + 860, z = 60.827 },
			Vector3{ x = 2358.796, y = -655.905 + 860, z = 60.820 },
			Vector3{ x = 2392.264, y = -691.718 + 860, z = 60.820 },
		};
	};
}

CONST_HOUSES_EXIT_POSITIONS = {
	[ 1 ] = Vector3( 192.567, -414.86, 514.542 );
	[ 2 ] = Vector3( 243.563, -348.405, 456.434 );
	[ 3 ] = Vector3( 250.789, -459.086, 465.054 );
}

CONST_HOUSES_FIX_POSITIONS = {
	[ 1 ] = {
		Vector3( 197.772, -413.632, 514.542 );
	};
	[ 2 ] = {
		Vector3( 256.120, -348.536, 456.427 );
	};
	[ 3 ] = {
		Vector3( 249.413, -454.548, 468.547 );
		Vector3( 253.814, -456.255, 465.047 );
	};
}

CONST_MARKERS_COUNT = 5

QUEST_DATA = {
	id = "task_hcs_company_2";

	title = "Ремонт зданий";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_HCS
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
            name = "Выполни ремонт в квартирах";

            Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local level = math.random( 1, #CONST_HOUSES_POSITIONS[ city ] )
					local points = CONST_HOUSES_POSITIONS[ city ][ level ]
					local offset = math.random( 1, #points )
					for i = 1, CONST_MARKERS_COUNT do
						CreateQuestPoint( points[ ( offset + i ) % #points + 1 ], function( )
							if isElement( localPlayer.vehicle ) then
								localPlayer:ShowError( "Сначала покинь транспортное средство" )
								return
							end

							localPlayer:Teleport( CONST_HOUSES_EXIT_POSITIONS[ level ], localPlayer:GetUniqueDimension( ), 1, 50 )

							do
								local j = math.random( 1, #CONST_HOUSES_FIX_POSITIONS[ level ] )
								local position = CONST_HOUSES_FIX_POSITIONS[ level ][ j ]
								CreateQuestPoint( position, function( )
									if isElement( localPlayer.vehicle ) then
										localPlayer:ShowError( "Сначала покинь транспортное средство" )
										return
									end
	
									createMiniGame( {
										[1] = {
											--осмотреть повреждения
											action = function()
												return ibCreateMouseKeyPress( {
													texture = "img/hint1.png",
													key = "lalt",
													callback = function()
														playSound( "sounds/idle_".. math.random( 1, 2 ) ..".wav" ).volume = 0.5
														localPlayer:setFrozen( true )
														localPlayer:setAnimation( "bomber", "bom_plant_loop", -1, true, false, false, false )
														createNextGameStep()
													end,
													check = function()
														if isElementWithinMarker( localPlayer, CEs[ "apart_marker_" .. j ].marker ) then
															return true
														else
															localPlayer:ShowInfo("Вернись к точке!")
														end
													end,

													click_action = function()
														localPlayer:setAnimation( "sword", "sword_3", -1, false, false, false, false )
													end;
													timeout = 5000;
												} )
											end
										};
										[2] = {
											action = function()
												local rand = math.random( 1, 4 )
												if rand == 1 then
													return ibCreateMouseKeyStrokeTimeout({
														texture = "img/hint3_1.png";
														key = "mouse2";

														check = function()
															if isElementWithinMarker( localPlayer, CEs[ "apart_marker_" .. j ].marker ) then
																return true
															else
																localPlayer:ShowInfo("Вернись к точке!")
															end
														end;

														callback = function()
															playSound( "sounds/drill_".. math.random( 1, 2 ) ..".wav" ).volume = 0.5
															createNextGameStep()
														end;
													})
												elseif rand == 2 then
													return ibCreatePressInCircleRegion({
														texture = "img/hint3_2.png";
														key = "mouse2";

														check = function()
															if isElementWithinMarker( localPlayer, CEs[ "apart_marker_" .. j ].marker ) then
																return true
															else
																localPlayer:ShowInfo("Вернись к точке!")
															end
														end;

														callback = function()
															playSound( "sounds/drill_".. math.random( 1, 2 ) ..".wav" ).volume = 0.5
															createNextGameStep()
														end;
													})
												elseif rand == 3 then
													return ibCreateMouseKeyStroke({
														texture = "img/hint3_3.png";
														key = "mouse1";

														check = function()
															if isElementWithinMarker( localPlayer, CEs[ "apart_marker_" .. j ].marker ) then
																return true
															else
																localPlayer:ShowInfo("Вернись к точке!")
															end
														end;

														callback = function()
															playSound( "sounds/drill_".. math.random( 1, 2 ) ..".wav" ).volume = 0.5
															createNextGameStep()
														end;
													})
												else
													return ibCreatePressInCircleRegion({
														texture = "img/hint3_4.png";
														key = "mouse1";

														check = function()
															if isElementWithinMarker( localPlayer, CEs[ "apart_marker_" .. j ].marker ) then
																return true
															else
																localPlayer:ShowInfo("Вернись к точке!")
															end
														end;

														callback = function()
															playSound( "sounds/idle_".. math.random( 1, 2 ) ..".wav" ).volume = 0.5
															createNextGameStep()
														end;
													})
												end
											end
										};
										[3] = {
											action = function()
												return ibCreateMouseKeyHold({
													sx = 440,
													sy = 34,
													rect_x = 123,
													rect_y = 0,
													rect_size = 85,
													hold_time = 1900,
													count_hold = 1,
													texture = "img/hint5.png",
													key = "mouse1",

													callback = function()
														playSound( "sounds/drill_".. math.random( 1, 2 ) ..".wav" ).volume = 0.5
														createNextGameStep()													end;

													check = function()
														if isElementWithinMarker( localPlayer, CEs[ "apart_marker_" .. j ].marker ) then
															return true
														else
															localPlayer:ShowInfo("Вернись к точке!")
														end
													end;
												} )
											end
										};
										[4] = {
											action = function()
												CEs[ "apart_marker_" .. j ]:destroy()
												CEs[ "marker_" .. i ]:destroy()

												localPlayer:setFrozen( false )
												localPlayer:setAnimation( )

												playSound( "sounds/tool_box.wav" ).volume = 0.5
												createNextGameStep()

												return CreateQuestPoint( CONST_HOUSES_EXIT_POSITIONS[ level ], function()
													CEs[ "apart_marker_exit" .. j ]:destroy()

													for i = 1, #CONST_HOUSES_FIX_POSITIONS[ level ] do
														if CEs[ "apart_marker_" .. i ] and isElement( CEs[ "apart_marker_" .. i ].marker ) then
															return
														end
													end

													localPlayer:Teleport( points[ ( offset + i ) % #points + 1 ], 0, 0, 50 )

													for i = 1, CONST_MARKERS_COUNT do
														if isElement( CEs[ "marker_" .. i ].marker ) then
															return
														end
													end

													triggerServerEvent( "PlayerAction_Task_Hcs_2_step_1", localPlayer )
												end, "apart_marker_exit".. j, 1, 1, localPlayer.dimension, _, _, _, "cylinder", 230, 230, 0, 100 )
											end,
										};
									} )
								end, "apart_marker_".. j, 1, 1, localPlayer.dimension, _, _, _, "cylinder", 230, 230, 0, 100 )
							end
						end, "marker_" .. i, 2, 0, 0, _, _, _, "cylinder", 230, 230, 0, 100 )
					end
				end
			},
			
			CleanUp = {
				client = function( )
					if localPlayer.interior ~= 0 then
						localPlayer:setAnimation( )
						localPlayer:Teleport( CONST_BASE_POSITIONS[ localPlayer:GetShiftCity( ) ], 0, 0, 50 )
					end
				end;
			},

            event_end_name = "PlayerAction_Task_Hcs_2_step_1";
		},

		[2] = {
            name = "Вернись в офис";

            Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					CreateQuestPoint( CONST_BASE_POSITIONS[ city ], function()
						if isElement( localPlayer.vehicle ) then
							localPlayer:ShowError( "Сначала покинь транспортное средство" )
							return
						end

						CEs.marker:destroy()
						triggerServerEvent( "PlayerAction_Task_Hcs_2_step_2", localPlayer )
					end, _, 10, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
				end,
				server = function( player )
					triggerEvent( "onHcsFinishedCutting", player )
				end,
            },

            event_end_name = "PlayerAction_Task_Hcs_2_step_2";
		},
	};

	GiveReward = function( player )
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
