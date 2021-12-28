QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Ксюша", voice_line = "Ksenia_1", text = "Привет, прости, что заставила ждать. Но работа, есть работа.\nХочу тебе показать свой отель." },
		},
		finish = {
			{ name = "Ксюша", voice_line = "Ksenia_2", text = "Благодарю, мы хорошо провели время. Когда буду свободна, напишу. Встретимся!" },
		},
	},

	positions = {
		vehicle_main_spawn = Vector3( 1956.734, -254.075, 60.149 ),
		vehicle_main_spawn_rotation = Vector3( 0, 0, 226.5 ),

		hotel_target = Vector3( 2489.048, -768.184, 60.614 ),

		vehicle_spawn = Vector3( 2491.324, -784.712, 60.356 ),
		vehicle_spawn_rotation = Vector3( 0, 0, 156 ),

		comeback_target = Vector3( 1955.665, -254.842, 60.148 ),
		home_target = Vector3( 1966.096, -245.963, 60.439 ),

		path_main = {
			{ x = 2496.863, y = 83.388 - 860, z = 60.763, move_type = 4, },
			{ x = 2500.249, y = 83.814 - 860, z = 62.261, move_type = 4, },
			{ x = 2503.923, y = 84.459 - 860, z = 63.270, move_type = 4, },
		},

		path_bot = {
			{ x = 2495.972, y = 80.888 - 860, z = 60.763, move_type = 4, },
			{ x = 2500.296, y = 82.010 - 860, z = 62.299, move_type = 4, },
			{ x = 2504.386, y = 83.177 - 860, z = 63.270, move_type = 4, },
		},
	},
}

GEs = { }

QUEST_DATA = {
	id = "ksusha_hotel",
	is_company_quest = true,

	title = "Незнакомка",
	description = "Новые знакомства всегда разгружают. Нужно встретиться с Ксенией и посмотреть, что из этого выйдет.",
	--replay_timeout = 5;

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end

		local quests_enabled = player:getData( "quests_enabled" ) or { }
		if not quests_enabled.ksusha_hotel then
			return false, "Ксюша еще не готова встретиться! Следи за сообщениями в телефоне"
		end
		return true
	end,

	restart_position = Vector3( 1951.2601, -249.4949, 60.4046 ),

	quests_request = { "angela_cinema" },

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
		end,
	},

	tasks = {
		[ 1 ] = {
			name = "Поговорить с Ксюшей у Анжелы",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "ksusha",
						dialog = QUEST_CONF.dialogs.main,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "ksusha" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "ksusha_hotel_step_1", localPlayer )
							end, 7000, 1 )
						end
					} )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 6537, positions.vehicle_main_spawn, positions.vehicle_main_spawn_rotation )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetNumberPlate( "1:o746oo178" )
					vehicle:SetColor( 255, 0, 0 )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "ksusha" ).ped )
				end,
			},

			event_end_name = "ksusha_hotel_step_1",
		},

		[ 2 ] = {
			name = "Сесть в машину Анжелы",

			Setup = {
				client = function( )
					HideNPCs( )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть на водительское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Анжела будет недовольна, что ты уничтожен её машину!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					GEs.bot = CreateAIPed( 80, Vector3( 1961.3009033203, -250.86895751953, 60.419208526611 ) )
					LocalizeQuestElement( GEs.bot )
					SetUndamagable( GEs.bot, true )

					local t = { }

					local function CheckBothInVehicle( )
						iprint( "Check both in vehicle", localPlayer.vehicle, GEs.bot.vehicle )

						if localPlayer.vehicle and GEs.bot.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
							triggerServerEvent( "ksusha_hotel_step_2", localPlayer )
						end
					end

					AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
						vehicle = temp_vehicle;
						seat = 1;
						end_callback = {
							func = CheckBothInVehicle,
							args = { },
						}
					} )

					t.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							cancelEvent( )
							localPlayer:ShowError( localPlayer:GetGender( ) == 0 and "Ты ж джентельмен, сам отвези девушку" or "Ты ж джентельбаба, сама отвези девушку" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )

					t.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CheckBothInVehicle( )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
				end,

				server = function( player )
					
				end,
			},

			event_end_name = "ksusha_hotel_step_2",
		},

		[ 3 ] = {
			name = "Доехать до отеля",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.hotel_target, function( self, player )
						CEs.marker.destroy( )
						localPlayer.vehicle.engineState = false
						localPlayer.vehicle.frozen = true

						CreateAIPed( localPlayer )
						for i, v in pairs( { localPlayer, GEs.bot } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
						end

						CEs.fade_timer = setTimer( function( )
							fadeCamera( false, 2.0 )
						end, 1000, 1 )

						CEs.timer = setTimer( function( )
							triggerServerEvent( "ksusha_hotel_step_3", localPlayer )
						end, 4000, 1 )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Машину где забыл?"
						end
						return true
					end )
				end,
			},

			CleanUp = {
				client = function( )
					ClearAIPed( localPlayer )
				end,
				server = function( player )
					removePedFromVehicle( player )

					local vehicle = GetTemporaryVehicle( player )
					local positions = QUEST_CONF.positions
					vehicle.position = positions.vehicle_spawn
					vehicle.rotation = positions.vehicle_spawn_rotation
				end,
			},

			event_end_name = "ksusha_hotel_step_3",
		},

		[ 4 ] = {
			name = "Шпили-вили",

			Setup = {
				client = function( )
					local stripes = CreateBlackStripes( )
					stripes:show( )
					DisableHUD( true )

					fadeCamera( true, 1.0 )
					local from = { 2493.8386230469, -789.192863464355, 60.692951202393, 2544.5834960938, -706.38389587402, 83.147422790527, 0, 70 }
					local to = { 2493.0437011719, -788.941184997559, 68.137512207031, 2546.9943847656, -710.04302978516, 101.96995544434, 0, 70 }
					CameraFromTo( from, to, 10000, "InOutQuad", function( )
						local left = { 2491.2001953125, -786.23120880127, 68.137512207031, 2545.1540527344, -709.33120727539, 101.96922302246, 0, 70 }
						local right = { 2492.0612792969, -787.629173278809, 68.137512207031, 2546.0151367188, -710.72917175293, 101.96922302246, 0, 70 }
						
						local speed = 1000
						local seq = { }
						for i = 1, 20 do
							local n = i % 2 == 1 and left or right
							table.insert( seq, { _, n, speed } )
						end

						CameraFromToSequence( seq, function( )
							iprint( "Done", math.random( 1, 100 ) )
							fadeCamera( false, 2.0 )
							setTimer( function( )
								stripes:destroy( )
								DisableHUD( false )
								triggerServerEvent( "ksusha_hotel_step_4", localPlayer )
							end, 3000, 1 )
						end )
					end )

					CreateAIPed( localPlayer )
					local pos = QUEST_CONF.positions.path_main[ 1 ]
					localPlayer.position = Vector3( pos.x, pos.y, pos.z )

					local pos = QUEST_CONF.positions.path_bot[ 1 ]
					GEs.bot.position = Vector3( pos.x, pos.y, pos.z )
					LocalizeQuestElement( GEs.bot )

					for i, v in pairs( {
						[ localPlayer ] = QUEST_CONF.positions.path_main,
						[ GEs.bot ] = QUEST_CONF.positions.path_bot,
					} ) do
						SetAIPedMoveByRoute( i, v, false )
					end
				end,
			},

			event_end_name = "ksusha_hotel_step_4",
		},

		[ 5 ] = {
			name = "Отвези Ксюшу к Анжеле",

			Setup = {
				client = function( )
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					warpPedIntoVehicle( GEs.bot, temp_vehicle, 1 )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.comeback_target, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "ksusha_hotel_step_5", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Где Ксюша?"
						end
						return true
					end )
					fadeCamera( true, 1.0 )
				end,
				server = function( player )
					warpPedIntoVehicle( player, GetTemporaryVehicle( player ) )
					setCameraTarget( player, player )
				end,
			},

			CleanUp = {
				server = function( player )
					removePedFromVehicle( player )
				end,
			},

			event_end_name = "ksusha_hotel_step_5",
		},

		[ 6 ] = {
			name = "Поговорить с Ксюшей",

			Setup = {
				client = function( )
					ShowNPCs( )
					StartQuestCutscene( {
						id = "ksusha",
						dialog = QUEST_CONF.dialogs.finish,
						local_dimension = true,
					} )
					CEs.dialog:next( )
					StartPedTalk( FindQuestNPC( "ksusha" ).ped, nil, true )

					setTimerDialog( function( )
						CEs.dialog:destroy_with_animation( )
						triggerServerEvent( "ksusha_hotel_step_6", localPlayer )
					end, 6000, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "ksusha" ).ped )
				end,
			},

			event_end_name = "ksusha_hotel_step_6",
		},
	},

	GiveReward = function( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				exp = 1000,
			}
		} )
		player:SetQuestEnabled( "ksusha_hotel", nil )
	end,

	rewards = {
		exp = 1000,
	},

	no_show_rewards = true,
}