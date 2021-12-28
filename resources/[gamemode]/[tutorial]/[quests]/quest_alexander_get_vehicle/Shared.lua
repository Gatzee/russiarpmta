QUEST_CONF = {
	dialogs = {
		main = {               
			{ name = "Александр", voice_line = "Alexandr_3", text = "Здравствуй. Я слышал про твои проблемы.\nЛадно не будем о грустном, у меня возможно есть новости, которые тебе могут помочь.\nНо прежде купи себе машину. У меня сейчас как раз\nвесь ассортимент в наличии, а это редкость в наше время." },
		},
		finish = {
			{ name = "Александр", voice_line = "Alexandr_4", text = "Не плохой выбор, осталось забрать временные права.\nУчти они действуют только 7 дней." },
		},
	},

	positions = {
		carsell = Vector3( 1781.888, -629.177, 60.871 ),

		--[[bike_spawn = Vector3( 1782.516, 162.466, 60.330 ),
		bike_spawn_rotation = Vector3( 0, 0, 322 ),

		player_spawn_near = Vector3( 1783.961, 158.806, 60.669 ),
		player_spawn_near_rotation = Vector3( 0, 0, 23 ),

		bike_direction = Vector3( 1811.900, 237.539, 60.668 ),]]
	}
}

QUEST_DATA = {
	id = "alexander_get_vehicle",
	is_company_quest = true,

	title = "Получить транспорт [Машину]",
	description = "Александр может владеть информацией, надо узнать кто мог такое провернуть.",
	--replay_timeout = 5;

	-- TODO: Не забыть о блокировке старых игроков
	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1774.9056, -637.4530, 60.8555 ),

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
		end,
	},

	tasks = {
		[ 1 ] = {
			name = "Поговорить с Александром",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "alexander",
						dialog = QUEST_CONF.dialogs.main,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )

							setTimerDialog( function( )
								triggerServerEvent( "alexander_get_vehicle_step_1", localPlayer )
							end, 16000, 1 )
						end
					} )
				end,

				server = function( player )
					player.vehicle = nil
					EnterLocalDimension( player )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "alexander_get_vehicle_step_1",
		},

		[ 2 ] = {
			name = "Купить себе машину",

			Setup = {
				client = function( )
					local t = { }
					t.PurchaseVehicle = function( vehicle )
						removeEventHandler( "onClientPlayerBuyQuestVehicle", root, t.PurchaseVehicle )
						triggerServerEvent( "alexander_get_vehicle_step_2", localPlayer )
					end
					addEvent( "onClientPlayerBuyQuestVehicle", true )
					addEventHandler( "onClientPlayerBuyQuestVehicle", root, t.PurchaseVehicle )

					CreateQuestPoint( QUEST_CONF.positions.carsell, function( self, player )
						triggerEvent( "Carsell_ShowTutorialUI", localPlayer )
					end, _, _, _, _, _, "lalt", "Нажми Alt чтобы просмотреть ассортимент" )
				end,
			},

			event_end_name = "alexander_get_vehicle_step_2",
		},

		[ 3 ] = {
			name = "Поговорить с Александром",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "finish",
						dialog = QUEST_CONF.dialogs.finish,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )

							setTimerDialog( function( )
								triggerServerEvent( "alexander_get_vehicle_step_3", localPlayer )
							end, 16000, 1 )
						end
					} )
				end,
			},

			event_end_name = "alexander_get_vehicle_step_3",
		},

		[ 4 ] = {
			name = "Получить временные права",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.bike_direction, function( self, player )
						CEs.marker.destroy( )

						triggerServerEvent( "alexander_get_vehicle_step_4", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle or localPlayer.vehicle.model ~= 468 then
							return false, "Александру нужен мопед, ало!"
						end
						return true
					end )
				end,
			},

			CleanUp = {
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					if vehicle then
						vehicle:SetStatic( true )
						vehicle.engineState = false
					end
				end,
			},

			event_end_name = "alexander_get_vehicle_step_4",
		},

		[ 5 ] = {
			name = "Поговорить с Александром",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "alexander",
						dialog = QUEST_CONF.dialogs.finish,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )

							setTimerDialog( function( )
								triggerServerEvent( "alexander_get_vehicle_step_5", localPlayer )
							end, 8000, 1 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "alexander_get_vehicle_step_5",
		},
	},

	rewards = {
		donate = 10,
		exp = 2000,
	},
}