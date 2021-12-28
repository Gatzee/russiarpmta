QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Олег", voice_line = "Oleg_5", text = "Привет, ты во время прыгай в машину, здесь недалеко!" },
		},
		finish = {
			{ name = "Олег", voice_line = "Oleg_6", text = "Отлично справил(-а)ся. Из тебя хороший работник выходит.\nА кстати, я твой номер передал своему товарищу, ему тоже\nтакая помощь не помешает. За нее достойно заплатит." },
		},
	},

	positions = {
		vehicle_main_spawn = Vector3( 1917.2459716797, -779.826057434, 60.811634063721 ),
		vehicle_main_spawn_rotation = Vector3( 359.48794555664, 359.70602416992, 124.20220947266 ),

		path_drive = {
			{ x = 1908.651, y = 80.527 - 860, z = 60.707, speed_limit = 100 },
			{ x = 1911.166, y = 91.219 - 860, z = 60.707, speed_limit = 100 },
			{ x = 1921.526, y = 92.532 - 860, z = 60.683, speed_limit = 100 },
			{ x = 1930.250, y = 86.318 - 860, z = 60.557, speed_limit = 100 },
		},
		matrix_drive = { 1906.3588867188, -792.883621216, 65.571723937988, 1956.3343505859, -710.44972229, 38.9801902771, 0, 70 },

		vehicle_spawn = Vector3( 2098.5192871094, 974.8966064453, 16.265073776245 ),
		vehicle_spawn_rotation = Vector3( 359.50750732422, 359.83358764648, 112.541015625 ),

		path_come = {
			{ x = 2073.446, y = 1823.715 - 860, z = 16.381, speed_limit = 100 },
			{ x = 2054.894, y = 1813.073 - 860, z = 16.371, speed_limit = 100 },
			{ x = 2058.084, y = 1793.461 - 860, z = 16.387, speed_limit = 100 },
			{ x = 2067.956, y = 1783.489 - 860, z = 16.586, speed_limit = 100 },
			{ x = 2098.582, y = 1793.487 - 860, z = 16.615, speed_limit = 100 },
		},

		job_marker = Vector3( 2105.8503417969, 927.6124267578, 16.387012481689 ),

		mower_spawn = Vector3( 2093.3969726563, 923.6712646484, 15.828537940979 ),
		mower_spawn_rotation = Vector3( 1.0174865722656, 359.99923706055, 20.559753417969 ),

		oleg_position = Vector3( 2105.966796875, 929.7824707031, 16.387012481689 ),
		oleg_rotation = Vector3( 0, 0, 110.99209594727 ),

		player_oleg_position = Vector3( 2104.4025878906, 929.17578125, 16.387012481689 ),
		player_oleg_rotation = Vector3( 0, 0, 290.56488037109 ),
		oleg_matrix = { 2103.4331054688, 929.6341552734, 17.178993225098, 2200.9421386719, 912.5317382813, 3.0539662837982, 0, 70 },

		vehicle_final_spawn = Vector3( 2090.1293945313, 929.8520507813, 16.488439559937 ),
		vehicle_final_spawn_rotation = Vector3( 359.72012329102, 359.93161010742, 114.32452392578 ),

		path_final_drive = {
			{ x = 2076.3962402344, y =  1784.6368408203 - 860, z = 16.494207382202, speed_limit = 100 },
			{ x = 2069.0185546875, y =  1783.2213134766 - 860, z = 16.49076461792, speed_limit = 100 },
			{ x = 2060.3542480469, y =  1787.8374023438 - 860, z = 16.265396118164, speed_limit = 100 },
			{ x = 2054.7211914063, y =  1801.4288330078 - 860, z = 16.263422012329, speed_limit = 100 },
			{ x = 2053.7043457031, y =  1810.9047851563 - 860, z = 16.277437210083, speed_limit = 100 },
			{ x = 2059.8679199219, y =  1818.4248046875 - 860, z = 16.270984649658, speed_limit = 100 },
		},
		matrix_final_drive = { 2103.6369628906, 916.0986328125, 27.933206558228, 2029.6678466797, 964.3083496094, -19.017728805542, 0, 70 },

		vehicle_final_come_position = Vector3( 1925.8343505859, -768.38079071, 60.712940216064 ),
		vehicle_final_come_rotation = Vector3( 2.5334777832031, 359.59442138672, 120.759765625 ),
		path_final_come = {
			{ x = 1916.7713623047, y = 85.870658874512 - 860, z = 60.810836791992, speed_limit = 100, },
			{ x = 1912.0003662109, y = 82.825462341309 - 860, z = 60.822265625, speed_limit = 100, },
			{ x = 1909.6756591797, y = 74.896423339844 - 860, z = 60.820781707764, speed_limit = 100, },
			{ x = 1913.6450195313, y = 62.867500305176 - 860, z = 60.770641326904, speed_limit = 100, },
		},
	},
}

GEs = { }

QUEST_DATA = {
	id = "oleg_parkemployee",
	is_company_quest = true,

	title = "Сотрудник парка",
	description = "Помощь Олегу не прошла даром, теперь заказ на работу будет значительно лучше.",
	--replay_timeout = 5; 

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1897.0811, -791.2454, 60.7066 ),

	quests_request = { "oleg_govhelp" },
	level_request = 4,

	OnAnyFinish = {
		client = function()
			SetStateCanEnterExitVehicle( true )
		end,
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
		end,
	},

	tasks = {
		{
			name = "Поговорить с Олегом",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "oleg",
						dialog = QUEST_CONF.dialogs.main,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "oleg" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "oleg_parkemployee_step_1", localPlayer )
							end, 5000, 1 )
						end
					} )
				end,
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 400, positions.vehicle_main_spawn, positions.vehicle_main_spawn_rotation )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetNumberPlate( "1:с425км178" )
					vehicle:SetColor( 0, 200, 0 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "oleg" ).ped )
				end,
			},

			event_end_name = "oleg_parkemployee_step_1",
		},

		{
			name = "Сесть в машину Олега",

			Setup = {
				client = function( )
					HideNPCs( )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Машина Олега уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть на пассажирское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					GEs.bot = CreateAIPed( 154, localPlayer.position + Vector3( 0, 1, 0 ) )
					LocalizeQuestElement( GEs.bot )
					SetUndamagable( GEs.bot, true )

					local t = { }

					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.bot.vehicle then
							SetStateCanEnterExitVehicle( false )

							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
							triggerServerEvent( "oleg_parkemployee_step_2", localPlayer )
						end
					end

					AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
						vehicle = temp_vehicle;
						seat = 0;
						end_callback = {
							func = CheckBothInVehicle,
							args = { },
						}
					} )

					t.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat == 0 then
							cancelEvent( )
							localPlayer:ShowError( "Олег сам тебя отвезёт" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )

					t.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CheckBothInVehicle( )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
				end,
			},

			event_end_name = "oleg_parkemployee_step_2",
		},

		{
			name = "Отбытие...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					StartQuestCutscene( )
					setCameraMatrix( unpack( positions.matrix_drive ) )
					ResetAIPedPattern( GEs.bot )
					SetAIPedMoveByRoute( GEs.bot, positions.path_drive, false )

					CEs.timer = setTimer( function( )
						fadeCamera( false, 2 )
						CEs.timer = setTimer( function( )
							triggerServerEvent( "oleg_parkemployee_step_3", localPlayer )
						end, 3000, 1 )
					end, 2000, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "oleg_parkemployee_step_3",
		},

		{
			name = "Прибытие...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CleanupAIPedPatternQueue( GEs.bot )
					setCameraMatrix( 2063.2209472656, 897.3951416016, 26.719612121582, 2100.3212890625, 983.951171875, -6.9199562072754, 0, 70 )
					StartQuestCutscene( )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					temp_vehicle.position = positions.vehicle_spawn
					temp_vehicle.rotation = positions.vehicle_spawn_rotation

					local finish_func = function( is_timer )
						if isTimer( CEs.timer ) then killTimer( CEs.timer ) end

						CleanupAIPedPatternQueue( GEs.bot )
						removePedTask( GEs.bot )
						ResetAIPedPattern( GEs.bot )

						if is_timer then
							local temp_vehicle = localPlayer:getData( "temp_vehicle" )
							temp_vehicle.position = Vector3( 2095.4133, 929.7348, 16.3870 )
							temp_vehicle.rotation = Vector3( 0, 0, 292 )
						end

						CreateAIPed( localPlayer )
						for i, v in pairs( { localPlayer, GEs.bot } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
						end
						triggerServerEvent( "oleg_parkemployee_step_4", localPlayer )
					end

					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					ResetAIPedPattern( GEs.bot )
					SetAIPedMoveByRoute( GEs.bot, positions.path_come, false, finish_func )
					CEs.timer = setTimer( finish_func, 13000, 0, true )
				end,
			},

			CleanUp = {
				client = function( )
					SetStateCanEnterExitVehicle( true )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "oleg_parkemployee_step_4",
		},

		{
			name = "Устроиться на работу",

			Setup = {
				client = function( )
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					local t = {}
					t.OnStartEnter = function( player, seat )
						cancelEvent( )
						localPlayer:ShowError( "Устройся на работу, Олег уже договорился..." )
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )

					local positions = QUEST_CONF.positions

					if not localPlayer.vehicle then
						localPlayer.position = Vector3( { x = 2098.473, y = 935.271, z = 16.387 } )
					end

					CreateQuestPoint( positions.job_marker, function( self, player )
						CEs.marker.destroy( )
						removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
						ShowJobUI( true )
					end,
					_, _, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Ты собираешься устраиваться на работу на машине?"
						end
						return true
					end )
				end,
			},

			event_end_name = "oleg_parkemployee_step_5",
		},

		{
            name = "Отправляйся к своему участку";

            Setup = {
				server = function( player )
					DestroyAllTemporaryVehicles( player )

					local positions = QUEST_CONF.positions

					local vehicle = CreateTemporaryVehicle( player, 572, positions.mower_spawn )
					vehicle.rotation = positions.mower_spawn_rotation
					player:SetPrivateData( "temp_vehicle", vehicle )
					warpPedIntoVehicle( player, vehicle )
					triggerEvent( "oleg_parkemployee_step_create_mower", player )
				end
            },

            event_end_name = "oleg_parkemployee_step_create_mower",
		},

		{
            name = "Отправляйся к своему участку";

            Setup = {
				client = function()
					GEs.bot:destroy( )
					setCameraTarget( localPlayer )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Газонокосилка уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					CreateQuestPoint( AREAS[ 1 ].start,
						function()
							if not localPlayer:getOccupiedVehicle( ) then
								localPlayer:ShowInfo( "Неее, без газонокосилки не пойдет..." )
								return
							end
							triggerServerEvent( "oleg_parkemployee_step_6", localPlayer )
						end
					,_, 1.5, _, _, false, false, false, "cylinder", 30, 160, 60, 50 )
				end,
            },

            event_end_name = "oleg_parkemployee_step_6",
		},
		
		{
			name = "Включи газонокосилку";

			Setup = {
				client = function()
					local playerVehicle = localPlayer:getData( "temp_vehicle" ) 

					CURRENT_GAME = ibCreateMouseKeyPress( {
						texture = ":task_park_employee_company_1/img/hint1.png",
						callback = function()
							SOUND_SAW = Sound( ":task_park_employee_company_1/sfx/lawn_mower_on1.mp3", true )
							LocalizeQuestElement( SOUND_SAW )
							SOUND_SAW:setEffectEnabled( "echo", true )
							SOUND_SAW:setVolume( 0.3 )
							triggerServerEvent( "oleg_parkemployee_step_7", localPlayer )
						end,
						check = function()
							if localPlayer:getOccupiedVehicle() then
								return true
							else
								localPlayer:ShowInfo( "Неее, без газонокосилки не пойдет..." )
							end
						end,
						key = "h"
					} )
				end,
			},

			event_end_name = "oleg_parkemployee_step_7";
		};

		{
			name = "Очисти участок";

			Setup = {
				client = function()
					local vehicle = localPlayer:getOccupiedVehicle( )
					function OnSound()
						SOUND_SAW:setVolume( 0.3 )
					end
					addEventHandler( "onClientVehicleEnter", vehicle, OnSound )

					function OffSound()
						SOUND_SAW:setVolume( 0.0 )
					end
					addEventHandler( "onClientVehicleExit", vehicle, OffSound )

					CURRENT_GAME = CreateSurfacePaint( {
						center_area = AREAS[ 1 ].center,
						
						check = function()
							return localPlayer:isInVehicle()
						end,
						callback = function()
							SOUND_SAW:stop( )
							triggerServerEvent( "oleg_parkemployee_step_8", localPlayer )
						end
					} )
				end,

				server = function( player, data )
					local vehicle = player:getOccupiedVehicle()

					if vehicle then
						vehicle:setVelocity( 0, 0, 0 )

						--before = getVehicleHandling ( vehicle, "maxVelocity" ) 
						--setVehicleHandling ( vehicle, "maxVelocity",  18 ) 
						--vehicle:setData( "before_velocity", before["maxVelocity"], false )
					end
				end;
			};

			CleanUp = {

				client = function()
					local vehicle = localPlayer:getOccupiedVehicle( )
					if not vehicle then return end
					removeEventHandler( "onClientVehicleEnter", vehicle, OnSound )
					removeEventHandler( "onClientVehicleExit", vehicle, OffSound )
				end;

				server = function( player, data )
					local vehicle = player:getOccupiedVehicle( )
					if not vehicle then return end

					--local before_velocity = vehicle:getData( "before_velocity" )
					--setVehicleHandling ( vehicle, "maxVelocity",  before_velocity ) 
					--vehicle:setData( "before_velocity", nil, false )
				end;

			};

			event_end_name = "oleg_parkemployee_step_8";
		},

		{
			name = "Поговорить с Олегом",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.bot = CreateAIPed( 154, positions.oleg_position )
					GEs.bot.rotation = positions.oleg_rotation
					LocalizeQuestElement( GEs.bot )

					local t = { }
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					CreateQuestPoint( positions.oleg_position, function( self, player )
						CEs.marker.destroy( )

						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.finish } )

						localPlayer:Teleport( positions.player_oleg_position )
						localPlayer.rotation = positions.player_oleg_rotation

						setCameraMatrix( unpack( positions.oleg_matrix ) )
						CEs.dialog:next( )
						StartPedTalk( GEs.bot, nil, true )
						setTimerDialog( function( )
							triggerServerEvent( "oleg_parkemployee_step_9", localPlayer )
						end, 11000, 1 )
					end,
					_, _, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Выйди из машины чтобы поговорить с Олегом"
						end
						return true
					end )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 400, positions.vehicle_final_spawn, positions.vehicle_final_spawn_rotation )
					player:SetPrivateData( "temp_vehicle", vehicle )

					vehicle:SetNumberPlate( "1:с425км178" )
					vehicle:SetColor( 0, 200, 0 )
					vehicle.frozen = true
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.bot )
				end,

				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle:destroy()
				end
			},

			event_end_name = "oleg_parkemployee_step_9",
		},

		{
			name = "Сесть в машину Олега",

			Setup = {
				client = function( )
					HideNPCs( )
					SetStateCanEnterExitVehicle( true )
					
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть на пассажирское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					local t = { }

					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.bot.vehicle then
							SetStateCanEnterExitVehicle( false )

							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
							triggerServerEvent( "oleg_parkemployee_step_10", localPlayer )
						end
					end

					AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
						vehicle = temp_vehicle;
						seat = 0;
						end_callback = {
							func = CheckBothInVehicle,
							args = { },
						}
					} )

					t.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat == 0 then
							cancelEvent( )
							localPlayer:ShowError( "Олег сам тебя отвезёт" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )

					t.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CheckBothInVehicle( )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
				end,
			},

			event_end_name = "oleg_parkemployee_step_10",
		},

		{
			name = "Отбытие...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					StartQuestCutscene( )
					setCameraMatrix( unpack( positions.matrix_final_drive ) )
					removePedTask( GEs.bot )
					ResetAIPedPattern( GEs.bot )
					SetAIPedMoveByRoute( GEs.bot, positions.path_final_drive, false )

					CEs.timer = setTimer( function( )
						fadeCamera( false, 2 )
						CEs.timer = setTimer( function( )
							triggerServerEvent( "oleg_parkemployee_step_11", localPlayer )
						end, 3000, 1 )
					end, 2000, 1 )
				end,
				server = function( player )
					local mower = GetTemporaryVehicle( player )
					if isElement( mower ) then destroyElement( mower ) end
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "oleg_parkemployee_step_11",
		},

		{
			name = "Прибытие...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					setCameraMatrix( 1910.5646972656, -745.15697479248, 66.500122070313, 1929.5046386719, -842.532991409302, 49.033489227295, 0, 70 )

					StartQuestCutscene( )
					localPlayer.vehicle.position = positions.vehicle_final_come_position
					localPlayer.vehicle.rotation = positions.vehicle_final_come_rotation

					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					ResetAIPedPattern( GEs.bot )

					local finish_func = function( is_timer )
						CleanupAIPedPatternQueue( GEs.bot )
						removePedTask( GEs.bot )
						ResetAIPedPattern( GEs.bot )

						if is_timer then
							local temp_vehicle = localPlayer:getData( "temp_vehicle" )
							temp_vehicle.position = Vector3( 1905.6346, -785.7265, 60.7101 )
							temp_vehicle.rotation = Vector3( 0, 0, 167 )
						end

						CreateAIPed( localPlayer )
						for i, v in pairs( { localPlayer, GEs.bot } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
						end
						CEs.timer_delay = setTimer( function( )
							triggerServerEvent( "oleg_parkemployee_step_12", localPlayer )
						end, 1000, 1 )
					end

					SetAIPedMoveByRoute( GEs.bot, positions.path_final_come, false, finish_func )
					CEs.timer = setTimer( finish_func, 5500, 0, true )
				end,
			},

			CleanUp = {
				client = function( )
					SetStateCanEnterExitVehicle( true )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "oleg_parkemployee_step_12",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Незнакомый номер", msg = "Привет, это Жека, знакомый Олега, мне помощь нужна в одном деле, приезжай. Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "jeka_testdrive" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		player:GiveCase( "platinum", 1 )
		triggerClientEvent( player, "onClientShowFreeCaseMenu", root, { case_id = "platinum" } )

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				money = 500,
				exp = 900,
			}
		} )
	end,

	rewards = {
		money = 500,
		exp = 900,
	},

	no_show_rewards = true,
}