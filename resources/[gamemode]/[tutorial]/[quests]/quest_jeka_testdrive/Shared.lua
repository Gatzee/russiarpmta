QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Жека", voice_line = "Jeka_1", text = "Приветствую тебя, у меня тут гонки на носу. \nИ новый тюнинг должен помочь, но надо его проверить. \nСначала замерим время без него, а потом с ним!" },
		},
		finish = {
			{ name = "Жека", voice_line = "Jeka_2", text = "Вау! Такого я точно не ожидал. Знаешь, думаю мы сработаемся. \nЕсть у меня для тебя работенка. Как будет время заходи." },
		},
	},

	tuning = {
		external_params = {
			parts = {
				[ TUNING_REAR_BUMP ]  = 5,
				[ TUNING_FRONT_BUMP ] = 1,
				[ TUNING_SKIRT ]      = 3,
				[ TUNING_BONNET ]     = 1,
				[ TUNING_SPOILER ]    = 3,
			},
			windows = { 0, 0, 0, 200 },
			color = { 100, 0, 0 },
			lights_color = { 200, 0, 0 },
			wheels = 1082,
		}
	},

	positions = {
		repair = Vector3( 1783.910, -702.957, 60.669 ),

		player_spawn = Vector3( 1804.011, -699.890, 60.665 ),
		player_spawn_rotation = Vector3( 0, 0, 6 ),

		vehicle_spawn = Vector3( 1805.453, -697.147, 60.383 ),
		vehicle_spawn_rotation = Vector3( 359.244, 0.050, 24.633 ),

		track_start = Vector3( 1712.569, -668.404, 60.265 ),
		track_end = Vector3( 1821.203, -1000.745, 60.267 ),

		tuning_enter = Vector3( 1810.314, -700.536, 60.396 ),
	}
}

QUEST_DATA = {
	id = "jeka_testdrive",
	is_company_quest = true,

	title = "Тест драйв",
	description = "Человек, который увлечен машинами, всегда нужен, особенно после разборок с бандой. Нужно помочь ему. Жека явно будет полезен.",
	--replay_timeout = 5;

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1775.1571, -695.9771, 60.6470 ),

	quests_request = { "oleg_parkemployee" },
	level_request = 4,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
		end,
		client = function( )
			localPlayer:setData( "hud_counter", false, false )
		end,
	},

	tasks = {
		[ 1 ] = {
			name = "Поговорить с Жекой",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "jeka",
						dialog = QUEST_CONF.dialogs.main,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "jeka" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "jeka_testdrive_step_1", localPlayer )
							end, 10000, 1 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "jeka" ).ped )
				end,
			},

			event_end_name = "jeka_testdrive_step_1",
		},

		[ 2 ] = {
			name = "Сесть в Civic",

			Setup = {
				client = function( )
					localPlayer.position = QUEST_CONF.positions.player_spawn
					localPlayer.rotation = QUEST_CONF.positions.player_spawn_rotation
					setCameraTarget( localPlayer )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть в Civic",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local t = { }
					t.OnEnter = function( )
						removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
						triggerServerEvent( "jeka_testdrive_step_2", localPlayer )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
				end,
				server = function( player )
					local vehicle = CreateTemporaryVehicle( player, 436, QUEST_CONF.positions.vehicle_spawn, QUEST_CONF.positions.vehicle_spawn_rotation )
					vehicle:SetNumberPlate( "1:o745oo177" )

					player:SetPrivateData( "temp_vehicle", vehicle )
				end
			},

			event_end_name = "jeka_testdrive_step_2",
		},

		[ 3 ] = {
			name = "Доехать до старта",

			Setup = {
				client = function( )
					table.insert( GEs, WatchElementCondition( localPlayer.vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Машина уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					CreateQuestPoint( QUEST_CONF.positions.track_start, function( self, player )
						CEs.marker.destroy( )

						triggerServerEvent( "jeka_testdrive_step_3", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Пешком собрался машину проверять?"
						end
						return true
					end )
				end,
			},

			event_end_name = "jeka_testdrive_step_3",
		},

		[ 4 ] = {
			name = "Доехать до финиша",

			Setup = {
				client = function( )
					FadeBlink( )

					GEs.drag_interface = CreateDragInterface()

					localPlayer.vehicle.rotation = Vector3( 359.395, 0.001, 187.829 )
					localPlayer.vehicle.frozen = true
					triggerEvent( "ShowStartSequence", localPlayer, 256 )

					CEs.timer = setTimer( function( )
						localPlayer.vehicle.frozen = false
						GEs.drag_interface:start()
					end, 3000, 1 )

					CreateQuestPoint( QUEST_CONF.positions.track_end, function( self, player )
						CEs.marker.destroy( )

						GEs.left_text_hud_counter = "Время 1 заезда"
						GEs.right_text_hud_counter = GEs.drag_interface:stop()

						localPlayer:setData( "hud_counter", { left = GEs.left_text_hud_counter, right = GEs.right_text_hud_counter }, false )
						triggerServerEvent( "jeka_testdrive_step_4", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Пешком собрался машину проверять?"
						end
						return true
					end )
				end,
			},

			event_end_name = "jeka_testdrive_step_4",
		},

		[ 5 ] = {
			name = "Заедь в тюнинг",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.tuning_enter, function( self, player )
						CEs.marker.destroy( )

						triggerServerEvent( "jeka_testdrive_step_5", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Ноги тюнинговать собрался?"
						end
						return true
					end )
				end,
			},

			event_end_name = "jeka_testdrive_step_5",
		},

		[ 6 ] = {
			name = "Тюним...",

			Setup = {
				client = function()
					localPlayer.vehicle:setData( "tuning_external", QUEST_CONF.tuning.external_params.parts, false )
					localPlayer.vehicle:SetColor( unpack( QUEST_CONF.tuning.external_params.color ) )
					localPlayer.vehicle:SetHeadlightsColor( unpack( QUEST_CONF.tuning.external_params.color ) )
					localPlayer.vehicle:SetWindowsColor( unpack( QUEST_CONF.tuning.external_params.windows ) )
					localPlayer.vehicle:SetWheels( QUEST_CONF.tuning.external_params.wheels )

					triggerEvent( "onTuningPreviewStart", localPlayer, localPlayer.vehicle )
				end;
			},

			CleanUp = {
				client = function()
					triggerEvent( "onTuningPreviewStop", localPlayer )
				end;
			};

			event_end_name = "jeka_testdrive_step_6",
		},

		[ 7 ] = {
			name = "Доехать до старта",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.track_start, function( self, player )
						CEs.marker.destroy( )

						triggerServerEvent( "jeka_testdrive_step_7", localPlayer )
					end,
					_, _, _, localPlayer:GetUniqueDimension( ),
					function( )
						if not localPlayer.vehicle then
							return false, "Пешком собрался машину проверять?"
						end
						return true
					end )
				end,
				server = function( player )
					EnterLocalDimension( player )
					local vehicle = GetTemporaryVehicle( player )
					local parts = exports.nrp_tuning_internal_parts:getTuningPartsIDByParams( { category = 4, subtype = 1 } )

					if vehicle then
						for _, id in pairs( parts ) do
							vehicle:ApplyPermanentPart( id )
						end
					end

					removePedFromVehicle( player )
					warpPedIntoVehicle( player, vehicle, 0 )
				end,
			},

			event_end_name = "jeka_testdrive_step_7",
		},

		[ 8 ] = {
			name = "Доехать до финиша",

			Setup = {
				client = function( )
					FadeBlink( )
					localPlayer.vehicle.rotation = Vector3( 359.395, 0.001, 187.829 )
					localPlayer.vehicle.frozen = true
					triggerEvent( "ShowStartSequence", localPlayer, 256 )

					GEs.drag_interface:show( true )
					CEs.timer = setTimer( function( )
						localPlayer.vehicle.frozen = false
						GEs.drag_interface:start()
					end, 3000, 1 )
					
					CreateQuestPoint( QUEST_CONF.positions.track_end, function( self, player )
						CEs.marker.destroy( )

						GEs.left_text_hud_counter = GEs.left_text_hud_counter .. "\nВремя 2 заезда"
						GEs.right_text_hud_counter = GEs.right_text_hud_counter .. "\n" .. GEs.drag_interface:stop()

						localPlayer:setData( "hud_counter", { left = GEs.left_text_hud_counter, right = GEs.right_text_hud_counter, bg_sy = 50 }, false )

						triggerServerEvent( "jeka_testdrive_step_8", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Пешком собрался машину проверять?"
						end
						return true
					end )
				end,
			},

			event_end_name = "jeka_testdrive_step_8",
		},

		[ 9 ] = {
			name = "Поговорить с Жекой",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "jeka",
						dialog = QUEST_CONF.dialogs.finish,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "jeka" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "jeka_testdrive_step_9", localPlayer )
							end, 12000, 1 )
						end
					} )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "jeka" ).ped )
				end,
			},
			event_end_name = "jeka_testdrive_step_9",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Жека", msg = "Нужная твоя помощь приезжай, обсудим. Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "jeka_race" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		local vehicles = player:GetVehicles( true )
		local unparked_vehicles = { }
		for _, v in pairs( vehicles ) do
			if not v:GetParked( ) then
				table.insert( unparked_vehicles, v )
			end
		end
		table.sort( unparked_vehicles, function( a, b ) return a:GetTier( ) > b:GetTier( ) end )

		local selected_vehicle = unparked_vehicles[ 1 ]
		local tier = ( not selected_vehicle or selected_vehicle.model == 468 ) and 1 or selected_vehicle:GetTier( )

		local parts = exports.nrp_tuning_internal_parts:getTuningPartsIDByParams( { category = 2 } )
		local partID = parts[ math.random( 1, #parts ) ]
		local part = getTuningPartByID( partID, tier )

		player:GiveTuningPart( tier, partID )

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				exp = 700,
				money = 500,
				tuning_internal = part,
			}
		} )
	end,

	rewards = {
		money = 500,
		exp = 700,
		rand_tuning = "Тюнинг-деталь",
	},

	no_show_rewards = true,
}