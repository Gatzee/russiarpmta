QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Анжела", voice_line = "Angela_19", text = 'Привет, у нас тут "денежный мешок" попался, хорошие бонусы готов заплатить.\n Надо ему машину пригнать, но быстро.\n Она, буквально только что, прибыла в порт Новороссийска.' },
			{ name = "Анжела", text = 'Доставь ее в Московский салон, заказчик там ждать будет.\n И запомни главное это время и ее состояние!' },
		},
	},

	positions = {
		angela_position = Vector3( -860.8, 2385.45, 18.64 ),
		angela_rotation = 150,

		matrix_start = { -861.1455078125, 2383.357421875, 19.430393218994, -853.779296875, 2481.291015625, 0.59733134508133, 0, 70 },
		talk_position = Vector3( -861.625, 2384.764, 18.645 ),
		talk_rotation = Vector3( 0, 0, 313 ),

		vehicle_marker_position = Vector3( -682.141, -1305.519, 18.165 ),
		vehicle_spawn_position = Vector3( -702.1, -1250.13, 15.78 ),
		vehicle_spawn_rotation = Vector3( 0, 0, 0 ),
		vehicle_parking_position = Vector3( 1195.97, 2458.34, 10.05 ),
	},

	vehicle_id = 6612
}

GEs = { }

QUEST_DATA = {
	id = "fast_delivery",
	is_company_quest = true,

	title = "Скорая доставка",
	description = "Анжела предлагает заработать неплохие деньги, после прошлых событий, явно стоит снять стресс!",

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end
		return true
	end,

	restart_position = Vector3( -864.4427, 2373.7390, 18.6447 ),

	quests_request = { "rescue_operation" },
	level_request = 10,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
		end,
	},

	tasks = {
		{
			name = "Поговорить с Анжелой",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					setElementFrozen( localPlayer, false )

					GEs.bot = CreateAIPed( 131, Vector3( positions.angela_position ), positions.angela_rotation )
					LocalizeQuestElement( GEs.bot )
					GEs.bot:setFrozen( true )

					CreateQuestPoint( positions.angela_position, function( )
						CEs.marker.destroy( )

						localPlayer.position = positions.talk_position
						localPlayer.rotation = positions.talk_rotation

						StartQuestCutscene( {
							dialog = QUEST_CONF.dialogs.main,
						} )
						CEs.dialog:next( )
						StartPedTalk( GEs.bot, nil, true )

						setCameraMatrix( unpack( positions.matrix_start ) )

						setTimerDialog( function( )
							CEs.dialog:next( )
							setTimerDialog( function( )
								triggerServerEvent( "fast_delivery_step_1", localPlayer )
							end, 8000 )
						end, 10000 )
					end, nil, nil, nil, nil, function( )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта"
						end
						return true
					end )
				end,

				server = function( player )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.bot )
				end,
			},

			event_end_name = "fast_delivery_step_1",
		},

		{
			name = "Забери документы",
	
			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CreateQuestPoint( positions.vehicle_marker_position, function( )
						CEs.marker.destroy( )
						triggerServerEvent( "fast_delivery_step_2", localPlayer )
					end )
				end,
	
				server = function( player )
				end
			},
	
			CleanUp = {
				client = function( )
				end,

				server = function( player )
					EnterLocalDimension( player )
				end;
			},
	
			event_end_name = "fast_delivery_step_2",
		},

		{
			name = "Сядь в транспорт",
	
			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					LocalizeQuestElement( GEs.bot )

					CreateQuestPoint( positions.vehicle_spawn_position, function( self, player )
						CEs.marker.destroy( )
					end )
					
					OnEnter = function( vehicle, seat )
						if vehicle ~= localPlayer:getData( "temp_vehicle" ) then return end
						
						removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, OnEnter )
						triggerServerEvent( "fast_delivery_step_3", localPlayer )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, OnEnter )
				end,
	
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, QUEST_CONF.vehicle_id, positions.vehicle_spawn_position, positions.vehicle_spawn_rotation )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 255, 255, 255 )
				end
			},
	
			CleanUp = {
				client = function( )
				end,
			},
	
			event_end_name = "fast_delivery_step_3",
		},

		{
			name = "Доставь транспорт в автосалон",
	
			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 500 or self.element.inWater then
								FailCurrentQuest( "Машина Анжелы уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					StartQuestTimerFail( 300 * 1000, "Доставь транспорт", "Слишком медленно!" )

					CreateQuestPoint( positions.vehicle_parking_position, function( )
							CEs.marker.destroy( )
							triggerServerEvent( "fast_delivery_step_4", localPlayer )
					end, nil, nil, nil, nil, function( )
						if not localPlayer.vehicle then
							return false, "Ты без необходимого транспорта"
						end
						return true
					end )
				end,
	
				server = function( player )
				end
			},
	
			CleanUp = {
				client = function( )
				end,

				server = function ( player )
					player:PhoneNotification( { title = "Анжела", msg = "Мне передали, что доставка прошла успешно, благодарю тебя!" } )
				end,
			},
	
			event_end_name = "fast_delivery_step_4",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Ксюша", msg = "Привет, у меня серьёзные проблемы, приезжай ко мне, пожалуйста!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "unconscious_betrayal" then
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
		player:SetQuestEnabled( "fast_delivery", nil )
	end,

	rewards = {
		money = 7000,
		exp = 4500,
	},

	no_show_rewards = true,
}