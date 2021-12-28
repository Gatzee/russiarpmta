QUEST_CONF = {
	dialogs = {
		alexander_start = {
			{ name = "Александр", voice_line = "Alexandr_beginning_proceedings_01", text = [[Здарова Старина. Давно не виделись.
Помнишь про ограбления моего офиса?
Так вот, я вышел на серьёзных людей, которые могут помочь в этом вопросе.]] },
			{ name = "Александр", text = [[И уже договорился о встрече. Тебе нужно будет встретиться с главой охраны Кремля.
Он все детали тебе растолкует!]] },
		},
		head_security = {

			{ name = "Глава охраны", voice_line = "Glava_ohrani_beginning_proceedings", text = [[Здравствуйте, я так понимаю вы от Александра?
Вам надо встретиться с моим доверенным лицом. Он передаст вам кейс.]] },
			{ name = "Глава охраны", text = [[Вскрыть не пытайтесь, там кодовый замок. 
Пароль знает только Александр. Поторопитесь, время деньги!]] },
		},
		investigator = {
			{ name = "Следователь", voice_line = "Sledovatel_beginning_proceedings", text = [[Здравствуйте. Я ждал вас.
Вот кейс.
Удачи!]] },
		},
		alexander_finish = {
			{ name = "Александр", voice_line = "Alexandr_beginning_proceedings_02", text = [[О, а ты быстро! Давай кейс, сейчас узнаем какая сволочь меня ограбила!]] },
			{ name = "Александр", text = [[Да епт... Здесь нет конкретики, только наводки. Черт! 
Ладно, хоть зацепки есть, будем разбираться дальше. Будь на связи, Я наберу!]] }
		},
	},

	positions = {
		office_outer = { pos = Vector3( 2190.03, 2637.9, 8.07 ), rot = Vector3( 0, 0, 180 ), cz = 188 },
		office_inner = { pos = Vector3( -103.4286, -2463.6701, 4406.6485 ), rot = Vector3( 0, 0, 180 ), cz = 180 },

		alexander_start_spawn = { pos = Vector3( -96.28, -2486.39, 4406.26 ), rot = Vector3( 0, 0, 7 ) },
		alexander_start_talk  = { pos = Vector3( -96.3391, -2485.6921, 4406.2646 ), rot = Vector3( 0, 0, 182 ) },
		alexander_start_talk_matrix = { -95.773292541504, -2484.7658691406, 4407.21875, -128.85969543457, -2577.0932617188, 4387.701171875, 0, 70 },
		
		kremlin_outer = { pos = Vector3( -118.1, 2118.18, 21.61 ), rot = Vector3( 0, 0, 276 ), cz = 280 },
		kremlin_inner = { pos = Vector3( 1340.25, 2403.45, 2285.55 ), rot = Vector3( 0, 0, 2 ), cz = 0 },

		head_security_spawn = { pos = Vector3( 1323.0570, 2451.3857, 2292.5558 ), rot = Vector3( 0, 0, 90 ) },
		head_security_talk =  { pos = Vector3( 1322.3577, 2451.3476, 2292.5558 ), rot = Vector3( 0, 0, 273 ) },
		head_security_talk_matrix = { 1321.4488525391, 2451.6938476563, 2293.40625, 1418.8771972656, 2436.3151855469, 2276.9375, 0, 70 },

		investigator_spawn = { pos = Vector3( 833.38, 2040.54, 31.8 ), rot = Vector3( 0, 0, 70 ) },
		investigator_talk = { pos = Vector3( 832.4426, 2040.6701, 32.7994 ), rot = Vector3( 0, 0, 251 ) },
		investigator_talk_matrix = { 831.94500732422, 2041.166015625, 33.627716064453, 916.07684326172, 1990.7321777344, 14.178611755371, 0, 70 },
		
		secretary_spawn = { pos = Vector3( -102.6267, -2478.8190, 4406.2646 ), rot = Vector3( 0, 0, 0 ) },

		alexander_finish_spawn = { pos = Vector3( -92.61, -2481.62, 4406.27 ), rot = Vector3( 0, 0, 88 ) },
		alexander_finish_talk  = { pos = Vector3( -93.3110, -2481.6186, 4406.2719 ), rot = Vector3( 0, 0, 267 ) },
		alexander_finish_talk_matrix = { -94.287017822266, -2481.2607421875, 4407.2412109375, -0.59301334619522, -2506.3601074219, 4382.9213867188, 0, 70 },
		
		restore_fail_mission = { pos = Vector3( 2188.09, 2625.83, 8.07 ), rot = Vector3( 0, 0, 122 ), cz = 130 },
	},
}

GEs = { }

QUEST_DATA = {
	id = "beginning_proceedings",
	is_company_quest = true,

	title = "Начало разбирательства",
	description = "Нужно узнать, что задумал Александр. Главное помешать ему выйти на мой след!",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 2182.6801, 2630.6242, 8.0721 ),

	quests_request = { "unconscious_betrayal" },
	level_request = 18,

	OnAnyFinish = {
		client = function()
			fadeCamera( true, 0.5 )
		end,
		server = function( player, reason, reason_data )
			if player.interior ~= 0 and player.dimension == player:GetUniqueDimension() then
				player.interior = 0
				player.position = QUEST_CONF.positions.restore_fail_mission.pos:AddRandomRange( 3 )
				player.rotation = QUEST_CONF.positions.restore_fail_mission.rot
			end

			player:InventoryRemoveItem( IN_QUEST_CASE )

			ExitLocalDimension( player )
			DisableQuestEvacuation( player )	
		end
	},

	tasks = {
		{
			name = "Отправляйся в офис",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.func_ignore_check_veh = function()
						if localPlayer.vehicle then
							return false, "Для продолжения покинь транспорт"
						end
						return true
					end

					CreateQuestPoint( positions.office_outer.pos, function( self, player )
						CEs.marker.destroy( )
						
						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( function()
							EnterLocalDimension( )
							triggerServerEvent( "beginning_proceedings_step_1", localPlayer )
						end, 500, 1 )						
					end, _, 1, _, _, GEs.func_ignore_check_veh )
				end,
			},

			event_end_name = "beginning_proceedings_step_1",
		},

		{
			name = "Поговори с Александром",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					localPlayer.position = positions.office_inner.pos
					localPlayer.rotation = positions.office_inner.rot
					setPedCameraRotation( localPlayer, positions.office_inner.cz )
					fadeCamera( true, 0.5 )

					GEs.alexander_bot = CreateAIPed( FindQuestNPC( "alexander" ).ped.model, positions.alexander_start_spawn.pos, positions.alexander_start_spawn.rot.z )
					LocalizeQuestElement( GEs.alexander_bot )
					SetUndamagable( GEs.alexander_bot, true )
					GEs.alexander_bot.interior = 1
					
					GEs.secretary_bot = CreateAIPed( 178, positions.secretary_spawn.pos, positions.secretary_spawn.rot.z )
					LocalizeQuestElement( GEs.secretary_bot )
					SetUndamagable( GEs.secretary_bot, true )
					GEs.secretary_bot.interior = 1

					CreateQuestPoint( positions.alexander_start_talk.pos, function( self, player )
						CEs.marker.destroy( )

						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.alexander_start } )
						
						setCameraMatrix( unpack( positions.alexander_start_talk_matrix ) )
						localPlayer.position = positions.alexander_start_talk.pos
						localPlayer.rotation = positions.alexander_start_talk.rot

						CEs.dialog:next( )
						StartPedTalk( GEs.alexander_bot, nil, true )

						setTimerDialog( function() 
							CEs.dialog:next( )

							setTimerDialog( function() 
								triggerServerEvent( "beginning_proceedings_step_2", localPlayer )
							end, 7000 )
						end, 7200 )
					end, _, 1, 1 )
				end,
				server = function( player )
					player.interior = 1
					EnableQuestEvacuation( player )
					EnterLocalDimensionForVehicles( player )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.alexander_bot )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "beginning_proceedings_step_2",
		},

		{
			name = "Покинь офис",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CreateQuestPoint( positions.office_inner.pos, function( self, player )
						CEs.marker.destroy( )

						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( function()
							triggerServerEvent( "beginning_proceedings_step_3", localPlayer )
						end, 500, 1 )	
					end, _, 1, 1 )
				end,
				server = function( player )
					
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if isElement( GEs.alexander_bot ) then
						destroyElement( GEs.alexander_bot )
					end
				end,
				server = function( player )
					player.interior = 0
				end,
			},
			
			event_end_name = "beginning_proceedings_step_3",
		},

		{
			name = "Отправляйся в Кремль",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					localPlayer.position = positions.office_outer.pos
					localPlayer.rotation = positions.office_outer.rot
					setPedCameraRotation( localPlayer, positions.office_outer.cz )
					fadeCamera( true, 0.5 )

					CreateQuestPoint( positions.kremlin_outer.pos, function( self, player )
						CEs.marker.destroy( )
						
						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( function()
							triggerServerEvent( "beginning_proceedings_step_4", localPlayer )
						end, 500, 1 )				
					end, _, 1, 0, _, GEs.func_ignore_check_veh )
				end,
			},
			
			event_end_name = "beginning_proceedings_step_4",
		},

		{
			name = "Найти главу охраны",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					localPlayer.position = positions.kremlin_inner.pos
					localPlayer.rotation = positions.kremlin_inner.rot
					setPedCameraRotation( localPlayer, positions.kremlin_inner.cz )
					fadeCamera( true, 0.5 )

					GEs.head_security_bot = CreateAIPed( 26, positions.head_security_spawn.pos, positions.head_security_spawn.rot.z )
					LocalizeQuestElement( GEs.head_security_bot )
					SetUndamagable( GEs.head_security_bot, true )
					GEs.head_security_bot.interior = 3

					CreateQuestPoint( positions.head_security_talk.pos, function( self, player )
						CEs.marker.destroy( )

						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.head_security } )
						
						setCameraMatrix( unpack( positions.head_security_talk_matrix ) )
						localPlayer.position = positions.head_security_talk.pos
						localPlayer.rotation = positions.head_security_talk.rot

						CEs.dialog:next( )
						StartPedTalk( GEs.head_security_bot, nil, true )

						setTimerDialog( function() 
							CEs.dialog:next( )

							setTimerDialog( function() 
								triggerServerEvent( "beginning_proceedings_step_5", localPlayer )
							end, 6200 )
						end, 5000 )
					end, _, 1, 3 )
				end,
				server = function( player )
					player.interior = 3
				end,
			},
			
			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.head_security_bot )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "beginning_proceedings_step_5",
		},

		{
			name = "Покинь Кремль",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CreateQuestPoint( positions.kremlin_inner.pos, function( self, player )
						CEs.marker.destroy( )

						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( function()
							triggerServerEvent( "beginning_proceedings_step_6", localPlayer )
						end, 500, 1 )	
					end, _, 1, 3 )
				end,
				server = function( player )
					
				end,
			},
			
			CleanUp = {
				client = function( data, failed )
					if isElement( GEs.head_security_bot ) then
						destroyElement( GEs.head_security_bot )
					end
				end,
				server = function( player )
					player.interior = 0
				end,
			},

			event_end_name = "beginning_proceedings_step_6",
		},

		{
			name = "Встреться с следователем",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					localPlayer.position = positions.kremlin_outer.pos
					localPlayer.rotation = positions.kremlin_outer.rot
					setPedCameraRotation( localPlayer, positions.kremlin_outer.cz )
					fadeCamera( true, 0.5 )

					GEs.investigator_bot = CreateAIPed( 238, positions.investigator_spawn.pos, positions.investigator_spawn.rot.z )
					LocalizeQuestElement( GEs.investigator_bot )
					SetUndamagable( GEs.investigator_bot, true )

					CreateQuestPoint( positions.investigator_talk.pos, function( self, player )
						CEs.marker.destroy( )

						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.investigator } )
						
						setCameraMatrix( unpack( positions.investigator_talk_matrix ) )
						localPlayer.position = positions.investigator_talk.pos
						localPlayer.rotation = positions.investigator_talk.rot

						CEs.dialog:next( )
						StartPedTalk( GEs.investigator_bot, nil, true )

						setTimerDialog( function() 
							triggerServerEvent( "beginning_proceedings_step_7", localPlayer )
						end, 3200 )
					end, _, 1, _, _, GEs.func_ignore_check_veh )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.investigator_bot )
					FinishQuestCutscene( )
				end,
			},
			
			event_end_name = "beginning_proceedings_step_7",
		},

		{
			name = "Отправляйся к Александру",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					CreateQuestPoint( positions.office_outer.pos, function( self, player )
						CEs.marker.destroy( )
						
						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( function()
							triggerServerEvent( "beginning_proceedings_step_8", localPlayer )
						end, 500, 1 )						
					end, _, 1, _, _, GEs.func_ignore_check_veh )
				end,
				server = function( player )
					player:InventoryAddItem( IN_QUEST_CASE, nil, 1 )
				end,
			},
			
			event_end_name = "beginning_proceedings_step_8",
		},

		{
			name = "Поговори с Александром",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					localPlayer.position = positions.office_inner.pos
					localPlayer.rotation = positions.office_inner.rot
					setPedCameraRotation( localPlayer, positions.office_inner.cz )
					fadeCamera( true, 0.5 )

					GEs.alexander_bot = CreateAIPed( FindQuestNPC( "alexander" ).ped.model, positions.alexander_finish_spawn.pos, positions.alexander_finish_spawn.rot.z )
					LocalizeQuestElement( GEs.alexander_bot )
					SetUndamagable( GEs.alexander_bot, true )
					GEs.alexander_bot.interior = 1

					CreateQuestPoint( positions.alexander_finish_talk.pos, function( self, player )
						CEs.marker.destroy( )

						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.alexander_finish } )
						
						setCameraMatrix( unpack( positions.alexander_finish_talk_matrix ) )
						localPlayer.position = positions.alexander_finish_talk.pos
						localPlayer.rotation = positions.alexander_finish_talk.rot

						CEs.dialog:next( )
						StartPedTalk( GEs.alexander_bot, nil, true )

						setTimerDialog( function()
							CEs.dialog:next( )

							setTimerDialog( function() 
								triggerServerEvent( "beginning_proceedings_step_9", localPlayer )
							end, 10100 )
						end, 4000 )
					end, _, 1, 1 )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.alexander_bot )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "beginning_proceedings_step_9",
		},
		
		{
			name = "Покинь офис",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CreateQuestPoint( positions.office_inner.pos, function( self, player )
						CEs.marker.destroy( )

						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( function()
							triggerServerEvent( "beginning_proceedings_step_10", localPlayer )
						end, 500, 1 )	
					end, _, 1, 1 )
				end,
				server = function( player )
					player:InventoryRemoveItem( IN_QUEST_CASE )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					fadeCamera( true, 0.5 )
					setPedCameraRotation( localPlayer,  QUEST_CONF.positions.restore_fail_mission.cz )
				end,
				server = function( player )
					player.interior = 0
					player.position = QUEST_CONF.positions.restore_fail_mission.pos:AddRandomRange( 3 )
					player.rotation = QUEST_CONF.positions.restore_fail_mission.rot
				end,
			},
			
			event_end_name = "beginning_proceedings_step_10",
		},

	},

	GiveReward = function( player )
		player:SituationalPhoneNotification( { title = "Роман", msg = "Привет, помнишь про свой долг? Ты мне нужен. Приезжай!" },
		{
			condition = function( self, player, data, config )
				local current_quest = player:getData( "current_quest" )
				if current_quest and current_quest.id == "real_initiative" then
					return "cancel"
				end
				return getRealTime( ).timestamp - self.ts >= 60
			end,
			save_offline = true,
		} )

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )
	end,

	rewards = {
		money = 6500,
		exp = 5000,
	},
	no_show_rewards = true,
}
