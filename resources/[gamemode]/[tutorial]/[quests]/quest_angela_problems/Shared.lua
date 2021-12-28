QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Аня", voice_line = "Anna_monolog_7", text = [[Привет солнце,
ты от Анжелы, ведь? Она сейчас в участке, у нас тут такое было... 
Это просто капец. Поехали к ней скорее!]] },
		},
		main_1 = {
			{ name = "Анжела",  	voice_line = "Angela_problems_monolog_8", text = "Я вам уже в 10 раз бл.." },
			{ name = "Адвокат", 	voice_line = "Lawyer_problems_monolog_8", text = "Мой клиент уже Вам все рассказал.\nДополнительную информацию можете получить у новых свидетелей." },
			{ name = "Следователь", voice_line = "Inspector_problems_monolog_8", text = "Хорошо, хорошо. Протокол составлен.\nПозовите следующего свидетеля!" },
		},
		main_2 = {

			{ name = "Аня", 		voice_line = "Anna_monolog_9a", text = "Я хочу воспользоваться 51 статьей." },
			{ name = "Следователь", voice_line = "Inspector_problems_monolog_9", text = "51 значит?  Анжела кто тебе?\nСестра? Еще раз подумай! Пойдешь как соучастница! " },
			{ name = "Аня", 		voice_line = "Anna_monolog_9b", text = "Я хочу воспользоваться 51 статьей." },
		},
		finish = {
			{ name = "Анжела", voice_line = "Angela_problems_monolog_10", text = [[Господи я так устала воевать с этими проклятыми ментами!!!! 
Спасибо тебе... Всегда радуюсь, когда есть на кого опереться.
Кстати тут на днях появилась Ксюша и вспоминала о тебе! Жди ее звонка.]] },
		},
	},

	positions = {
		
		strip_club_outer = { pos = Vector3( 194.43, -333.95, 21.11 ), rot = Vector3( 0, 0, 90 ), cz = 90 },
		stri_club_inner  = { pos = Vector3( -47.67, -119.11, 1372.0 ), rot = Vector3( 0, 0, 0 ), cz = 0 },

		bot_anna_spawn = { pos = Vector3( -45.2, -92.91, 1372.00 ), rot = 177 },
		bot_anna_dialog_position = { pos = Vector3( -45.08044052124, -94.808715820313, 1372.6600341797 ), rot = Vector3( 0, 0, 0 ) },
		bot_anna_dialog_matrix = { -45.775798797607, -95.474380493164, 1373.7053222656, -8.7873182296753, -5.5767154693604, 1350.2476806641, 0, 70 },

		start_move_bot_anna = { pos = Vector3( -50.8238, -93.5885, 1372.6600 ), rot = Vector3( 0, 0, 190) }, 

		pps_moscow = { pos = Vector3( 1222.6712, 2200.3925, 8.2133 ), rot = Vector3( 0, 0, 0 ) },
		pps_outer  = { pos = Vector3( 1228.7200, 2193.7700, 9.4185 ), rot = Vector3( 0, 0, 0), cz = 180 },
		pps_inner  = { pos = Vector3( -363.45745849609, -796.07006835938, 1061.4239501953 ), rot = Vector3( 0, 0, 0 ), cz = 0 },

		pps_dialog_matrix =   { -349.35260009766, -790.263671875, 1062.5246582031, -404.13146972656, -711.37847900391, 1034.6606445313, 0, 70 },
		
		pps_bot_investigator_spawn = { pos = Vector3( -350.7838, -787.4243, 1061.4200 ), rot = 178 },
		pps_bot_angela_spawn = { pos = Vector3( -350.3760, -789.1736, 1061.4200 ), rot = 9 },
		pps_bot_lawyer_spawn = { pos = Vector3( -351.3193, -789.0997, 1061.4200 ), rot = 344 },

		vehicle_angela_spawn = { pos = Vector3( 1242.6131, 2200.5723, 8.5098850250244 ), rot = Vector3( 0, 0, 181.40315246582 ), cz = 177.03015136719 },

		anna_end_point = { pos = Vector3( 189.61, -333.95, 19.7 ), },
		bot_angela_end_point = { pos = Vector3( 671.55, -92.1, 19.78 ), },
		
		bot_angela_house_point = { pos = Vector3( 672.88, -79.2, 20.34 ), rot = Vector3( 0, 0, 180) },
		bot_angela_dialog_position = { pos = Vector3( 672.8636, -79.8998, 20.9353 ), rot = Vector3( 0, 0, 0 ) },
		bot_angela_dialog_matrix = { 672.51715087891, -80.445114135742, 21.721920013428, 699.34741210938, 13.762264251709, 1.5946607589722, 0, 70 },
	},
}

GEs = { }

QUEST_DATA = {
	id = "angela_problems",
	is_company_quest = true,

	title = "Проблемы Анжелы",
	description = "С Анжелой всегда приятно провести время или помочь ей, она в долгу не останется!",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 185.8861, -310.6238, 20.7010 ),

	quests_request = { "protection" },
	level_request = 10,

	OnAnyFinish = {
		client = function()
			fadeCamera( true, 0.5 )
			DestroyWaitresses()
			DestroyTvPayLeaders()
		end,
		server = function( player, reason, reason_data )
			DestroyAllTemporaryVehicles( player )

			if player.dimension == player:GetUniqueDimension() then 
				if player.interior ~= 0 then
					player.interior = 0
					player.position = Vector3( 191.21260070801, -334.18768310547, 20.703575134277 )
				end
				ExitLocalDimension( player )
			end			
		end
	},

	tasks = {
		{
			name = "Отправляйся в стрип бар",

			Setup = {
				client = function( )
					GEs.handlers = {}
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.strip_club_outer.pos, function( self, player )
						CEs.marker.destroy( )

						EnterLocalDimension()
						fadeCamera( false, 0.5)
						
						CEs.timer = setTimer( triggerServerEvent, 500, 1, "angela_problems_step_1", localPlayer )
					end, _, 1, _, _, function( self, player )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта чтобы войти"
						end
						return true
					end )
				end,
				server = function( player )

				end,
			},

			event_end_name = "angela_problems_step_1",
		},

		{
			name = "Поговори с барменом",

			Setup = {
				client = function( )
					HideNPCs()
					
					GEs.sound = playSound( ":nrp_strip_club/files/sfx/music_striptease_2.ogg", true )
					GEs.sound.volume = 0.5

					local positions = QUEST_CONF.positions

					localPlayer.interior = 1
					localPlayer.position = positions.stri_club_inner.pos
					localPlayer.rotation = positions.stri_club_inner.rot
					setPedCameraRotation( localPlayer, positions.stri_club_inner.cz )

					GEs.bot_anna = CreateAIPed( 304, positions.bot_anna_spawn.pos, positions.bot_anna_spawn.rot )
					GEs.bot_anna.interior = 1

					LocalizeQuestElement( GEs.bot_anna )
					SetUndamagable( GEs.bot_anna, true )

					CreateQuestPoint( positions.bot_anna_dialog_position.pos, function( self, player )
						CEs.marker.destroy( )

						GEs.sound.volume = 0.15

						localPlayer.position = positions.bot_anna_dialog_position.pos
						localPlayer.rotation = positions.bot_anna_dialog_position.rot

						setCameraMatrix( unpack( positions.bot_anna_dialog_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.start } )
						StartPedTalk( GEs.bot_anna, nil, true )
						
						CEs.dialog:next( )

						setTimerDialog( function()
							fadeCamera( false, 0.5 )
							CEs.timer = setTimer( function()
								triggerServerEvent( "angela_problems_step_2", localPlayer )
							end, 500, 1 )
						end, 9000 )

					end, _, 1, 1 )

					InitWaitresses()
					CreateTvPayLeaders()

					CEs.timer = setTimer( fadeCamera, 1500, 1, true, 0.5 )
				end,
				server = function( player )
					player.interior = 1
					EnableQuestEvacuation( player )
					EnterLocalDimensionForVehicles( player )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.bot_anna )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_problems_step_2",
		},

		{
			name = "Покинь стрип бар",

			Setup = {
				client = function( )
					GEs.sound.volume = 0.5
					
					local positions = QUEST_CONF.positions
					CreateFollowInterface()

					local t = positions.start_move_bot_anna.pos
					SetAIPedMoveByRoute( GEs.bot_anna, {
						{ x = t.x, y = t.y, z = t.z }
					}, false, function()
						GEs.StartFolowPedToPlayer( GEs.bot_anna )
					end )

					CreateQuestPoint( positions.stri_club_inner.pos, function( self, player )
						CEs.marker.destroy( )
						if isElement( GEs.sound ) then stopSound( GEs.sound ) end
						
						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( triggerServerEvent, 500, 1, "angela_problems_step_3", localPlayer )
					end, _, 1, 1 )
					fadeCamera( true, 0.5 )
				end,
				server = function( player )

				end,
			},

			event_end_name = "angela_problems_step_3",
		},

		{
			name = "Отправляйся в полицейский участок",

			Setup = {
				client = function( )
					DestroyTvPayLeaders()
					DestroyWaitresses()
					ResetAIPedPattern( GEs.bot_anna )

					local positions = QUEST_CONF.positions
					localPlayer.interior = 0
					localPlayer.position = positions.strip_club_outer.pos + Vector3( 0, 1, 0 )
					localPlayer.rotation = positions.strip_club_outer.rot
					setPedCameraRotation( localPlayer, positions.strip_club_outer.cz )

					GEs.bot_anna.interior = 0
					GEs.bot_anna.position = positions.strip_club_outer.pos
					GEs.bot_anna.rotation = positions.strip_club_outer.rot

					CreateFollowHandlers( { GEs.bot_anna } )

					GEs.CheckAnnaTimer = setTimer( function()
						local dist = (GEs.bot_anna.position - localPlayer.position).length
						if dist > 50 then
							local ticks = getTickCount()
							if not START_LOST_ANNA_TICKS then START_LOST_ANNA_TICKS = ticks end
							if ticks - START_LOST_ANNA_TICKS > 5000 then
								FailCurrentQuest( "Ты оставил Анну одну!" )
							end
						else
							START_LOST_ANNA_TICKS = nil
							if dist > 20 then localPlayer:ShowError( "Ты куда без Анны собрался?" ) end
						end
					end, 1000, 0 )

					local t = {}
					
					t.CreateOuterPPSPoint = function()
						CreateQuestPoint( positions.pps_moscow.pos, function( self, player )
							CEs.marker.destroy( )
							t.CreateInteriorEnterPoint()
						end, _, 5 )
					end

					t.CreateInteriorEnterPoint = function()
						CreateQuestPoint( positions.pps_outer.pos, function( self, player )
							CEs.marker.destroy( )
							if isTimer( GEs.CheckAnnaTimer ) then killTimer( GEs.CheckAnnaTimer ) end

							fadeCamera( false, 0 )
							DestroyFollowHandlers()

							localPlayer.interior = 1
							localPlayer.position = positions.pps_inner.pos
							localPlayer.rotation = positions.pps_inner.rot

							GEs.bot_anna.position = positions.pps_inner.pos
							GEs.bot_anna.rotation = positions.pps_inner.rot							
							
							triggerServerEvent( "angela_problems_step_4", localPlayer )
						end, _, 1, _, _, function( self, player )
							if localPlayer.vehicle then
								return false, "Выйди из транспорта чтобы войти"
							end
							return true
						end )
					end

					t.CreateOuterPPSPoint()
					fadeCamera( true, 0.5 )
				end,
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 6537, positions.vehicle_angela_spawn.pos, positions.vehicle_angela_spawn.rot )
					vehicle:SetColor( 255, 0, 0 )
					vehicle:SetNumberPlate( "1:o746oo178" )
					player:SetPrivateData( "temp_vehicle", vehicle )
					player.interior = 0
				end,
			},

			event_end_name = "angela_problems_step_4",
		},

		{
			name = "Разговор...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					GEs.bot_angela = CreateAIPed( 131, positions.pps_bot_angela_spawn.pos, positions.pps_bot_angela_spawn.rot )
					GEs.bot_investigator = CreateAIPed( 40, positions.pps_bot_investigator_spawn.pos, positions.pps_bot_investigator_spawn.rot )
					GEs.bot_lawyer = CreateAIPed( 199, positions.pps_bot_lawyer_spawn.pos, positions.pps_bot_lawyer_spawn.rot )
					
					for k, v in pairs( { GEs.bot_angela, GEs.bot_investigator, GEs.bot_lawyer, GEs.bot_anna } ) do
						LocalizeQuestElement( v )
						SetUndamagable( v, true )
					end

					local t = {}

					-- Анжела
					t.dialog_main_1_1 = function()
						setCameraMatrix( unpack( positions.pps_dialog_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.main_1 } )
						CEs.dialog:next( )

						StartPedTalk( GEs.bot_angela, nil, true )
						setTimerDialog( t.dialog_main_1_2, 2600 )
					end

					-- Адвокат
					t.dialog_main_1_2 = function()
						StopPedTalk( GEs.bot_angela )
						StartPedTalk( GEs.bot_lawyer, nil, true )
						CEs.dialog:next( )
						setTimerDialog( t.dialog_main_1_3, 6200 )
					end

					-- Следователь
					t.dialog_main_1_3 = function()
						StopPedTalk( GEs.bot_lawyer )
						StartPedTalk( GEs.bot_investigator, nil, true )
						CEs.dialog:next( )
						setTimerDialog( t.next_dialog, 4200 )
					end
					
					t.next_dialog = function()
						StopPedTalk( GEs.bot_investigator )
						fadeCamera( false, 2 )
						setTimerDialog( t.dialog_main_2_pre_start, 2100 )
					end

					t.dialog_main_2_pre_start = function()
						destroyElement( GEs.bot_lawyer )

						GEs.bot_angela.position = Vector3( 0, 0, 0 )

						GEs.bot_anna.position = positions.pps_bot_lawyer_spawn.pos
						GEs.bot_anna.rotation.z = positions.pps_bot_lawyer_spawn.rot

						t.dialog_main_2_1()
					end
					
					-- Аня
					t.dialog_main_2_1 = function()
						StartPedTalk( GEs.bot_anna, nil, true )
						
						setCameraMatrix( unpack( positions.pps_dialog_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.main_2 } )
						CEs.dialog:next( )
						setTimerDialog( t.dialog_main_2_2, 2700 )
					end

					-- Следователь
					t.dialog_main_2_2 = function()
						StopPedTalk( GEs.bot_anna )
						StartPedTalk( GEs.bot_investigator, nil, true )
						CEs.dialog:next( )
						setTimerDialog( t.dialog_main_2_3, 5900 )
					end

					-- Аня
					t.dialog_main_2_3 = function()
						StopPedTalk( GEs.bot_investigator )
						StartPedTalk( GEs.bot_anna, nil, true )
						CEs.dialog:next( )
						setTimerDialog( t.end_dialog, 3400 )
					end

					t.end_dialog = function()
						StopPedTalk( GEs.bot_anna )

						fadeCamera( false, 1 )
						CEs.timer = setTimer( function()

							localPlayer.position = positions.pps_outer.pos
							localPlayer.rotation = positions.pps_outer.rot
							localPlayer.interior = 0

							GEs.bot_anna.position = Vector3( 1227.85, 2193.55, 9 )
							GEs.bot_anna.rotation = positions.pps_outer.rot
							GEs.bot_anna.interior = 0
							
							GEs.bot_angela.position = Vector3( 1229.52, 2193.81, 9 )
							GEs.bot_angela.rotation = positions.pps_outer.rot
							GEs.bot_angela.interior = 0

							triggerServerEvent( "angela_problems_step_5", localPlayer )
						end, 1000, 1 )
					end

					CEs.timer = setTimer( t.dialog_main_1_1, 1500, 1 )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene()
				end,
			},

			event_end_name = "angela_problems_step_5",
		},

		{
			name = "Садись в Машину Анжелы",

			Setup = {
				client = function( )
					fadeCamera( false, 0 )
					CEs.timer_fade = setTimer( fadeCamera, 1000, 1, true, 1 ) 
					
					for k, v in pairs( { GEs.bot_anna, GEs.bot_angela } ) do
						GEs.StartFolowPedToPlayer( v)
					end

					local positions = QUEST_CONF.positions
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return not localPlayer.vehicle and isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					CreateQuestPoint( temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )

					CreateFollowHandlers( { GEs.bot_anna, GEs.bot_angela } )

					GEs.handlers.CheckBotsTimer = setTimer( function()
						if isElement( GEs.bot_anna ) then
							local dist_anna = (GEs.bot_anna.position - localPlayer.position).length
							if dist_anna > 50 then
								local ticks = getTickCount()
								if not START_LOST_ANNA_TICKS then START_LOST_ANNA_TICKS = ticks end
								if ticks - START_LOST_ANNA_TICKS > 5000 then
									FailCurrentQuest( "Ты оставил Анну одну!" )
								end
							else
								START_LOST_ANNA_TICKS = nil
								if dist_anna > 20 then localPlayer:ShowError( "Ты куда без Анны собрался?" ) end
							end
						end

						if isElement( GEs.bot_angela ) then
							local dist_angela = (GEs.bot_angela.position - localPlayer.position).length
							if dist_angela > 50 then
								local ticks = getTickCount()
								if not START_LOST_ANGELA_TICKS then START_LOST_ANGELA_TICKS = ticks end

								if ticks - START_LOST_ANGELA_TICKS > 5000 then
									FailCurrentQuest( "Ты оставил Анжелу одну!" )
								end
							else
								START_LOST_ANGELA_TICKS = nil
								if dist_angela > 20 then localPlayer:ShowError( "Ты куда без Анжелы собрался?" ) end
							end
						end
					end, 1000, 0 )

					GEs.handlers.OnClientVehicleStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if source ~= localPlayer:getData( "temp_vehicle" ) then
							localPlayer:ShowError( "Садись в машину Анжелы" )
							cancelEvent()
						elseif seat ~= 0 then
							localPlayer:ShowError( "Садись на водительское место" )
							cancelEvent()
						end
					end
					addEventHandler( "onClientVehicleStartEnter", root, GEs.handlers.OnClientVehicleStartEnter )
					
					GEs.handlers.OnPlayerVehicleEnter = function()
						CEs.hint:destroy()

						removeEventHandler( "onClientVehicleStartEnter", root, GEs.handlers.OnClientVehicleStartEnter )
						removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnPlayerVehicleEnter )	
						triggerServerEvent( "angela_problems_step_6", localPlayer )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnPlayerVehicleEnter )					
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.frozen = true

					player.interior = 0
				end,
			},

			CleanUp = {
				client = function()
					removeEventHandler( "onClientVehicleStartEnter", root, GEs.handlers.OnClientVehicleStartEnter )
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnPlayerVehicleEnter )
				end
			},

			event_end_name = "angela_problems_step_6",
		},

		{
			name = "Подвези Аню на работу",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.anna_end_point.pos, function( self, player )
						CEs.marker.destroy( )
						local player_vehicle = localPlayer.vehicle
						player_vehicle.frozen = true

						AddAIPedPatternInQueue( GEs.bot_anna, AI_PED_PATTERN_VEHICLE_EXIT, {
							end_callback = {
								func = function()
									SetAIPedMoveByRoute( GEs.bot_anna, {
										{ x = 196.05015563965, y = -333.95001220703, z = 21.112693786621 },
									}, false, function()
										destroyElement( GEs.bot_anna )
									end )

									player_vehicle.frozen = false
									triggerServerEvent( "angela_problems_step_7", localPlayer )
								end,
								args = { },
							}
						} )
					end, _, 3, _, _, function( self, player )
						if not localPlayer.vehicle then
							return false, "А где машина?"
						end
						return true
					end )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.frozen = false
				end,
			},

			event_end_name = "angela_problems_step_7",
		},

		{
			name = "Подвези Анжелу домой",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.bot_angela_end_point.pos, function( self, player )
						CEs.marker.destroy( )
						localPlayer.vehicle.frozen = true
						
						CreateAIPed( localPlayer )
						for i, v in pairs( { localPlayer, GEs.bot_angela } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
						end

						GEs.handlers.onStartEnter = function( player, seat, door )
							localPlayer:ShowError( "Может быть проведёшь Анжелу домой?")
							cancelEvent()
						end
						addEventHandler( "onClientVehicleStartEnter", localPlayer.vehicle, GEs.handlers.onStartEnter )

						triggerServerEvent( "angela_problems_step_8", localPlayer )
					end, _, 5, _, _, function( self, player )
						if not localPlayer.vehicle then
							return false, "А где машина?"
						end
						return true
					end )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					if isElement( temp_vehicle ) then
						removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.handlers.onStartEnter )
					end
				end
			},

			event_end_name = "angela_problems_step_8",
		},

		{
			name = "Проводи Анжелу до дома",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					GEs.handlers.onStartEnter = function( player, seat, door )
						localPlayer:ShowError( "Может быть проведёшь Анжелу домой?")
						cancelEvent()
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.handlers.onStartEnter )

					CreateQuestPoint( positions.bot_angela_house_point.pos, function( self, player )
						CEs.marker.destroy( )
						DestroyFollowHandlers()
						if isTimer( GEs.handlers.CheckBotsTimer ) then killTimer( GEs.handlers.CheckBotsTimer ) end
						
						triggerServerEvent( "angela_problems_step_9", localPlayer )
					end, _, 1, _, _, function( self, player )
						if localPlayer.vehicle then
							return false, "Воу-воу, полегче, выйди из машины.."
						end
						return true
					end, _ )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					if isElement( temp_vehicle ) then
						removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.handlers.onStartEnter )
					end
				end
			},

			event_end_name = "angela_problems_step_9",
		},

		{
			name = "Разговор...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					GEs.bot_angela.position = positions.bot_angela_house_point.pos
					GEs.bot_angela.rotation = positions.bot_angela_house_point.rot

					localPlayer.position = positions.bot_angela_dialog_position.pos
					localPlayer.rotation = positions.bot_angela_dialog_position.rot

					StartPedTalk( GEs.bot_angela, nil, true )

					setCameraMatrix( unpack( positions.bot_angela_dialog_matrix ) )
					StartQuestCutscene( { dialog = QUEST_CONF.dialogs.finish } )
					CEs.dialog:next( )
						
					setTimerDialog( function()
						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( triggerServerEvent, 500, 1, "angela_problems_step_10", localPlayer )
					end, 13000, 1 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_problems_step_10",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Ксюша", msg = "Привет, давно не виделись. У меня появилось время, давай встретимся!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "long_awaited_meeting" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )
	end,

	rewards = {
		money = 2500,
		exp = 2500,
	},
	no_show_rewards = true,
}
