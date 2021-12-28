QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Роман", voice_line = "Roman_monolog14", text = "И снова здравствуйте, а ты и вправду умеешь договариваться с бандитами.\nНо у Александра есть еще одна просьба. После неё я организую встречу." },
		  	{ name = "Роман", text = "У меня фургон в гараже, его к тем же ребятам надо доставить.\nУверен ты справишься, да и дело простое, главное фургон в целостности доставь!" },
		},
		finish = {
			{ name = "Охранник", voice_line = "Ohrannik_monolog15", text = "И снова ты! Уже на фургоне, хех, да ты растешь, смотрю!\nТебя наш главный звал, ты это, не тормози только. Он ждать не любит!" },
		},
	},

	positions = {
		house_enter = Vector3( 559.19, -521.12, 20.77 ),
		house_exit = Vector3( -110.014, -1778.811, 3936.981 ),
	},

	rewards = {
		money = 2500,
		exp = 2500,
	},
}

GEs = { }

-- iexe nrp_player GetPlayer(7):setData("quests",{})
-- triggerServerEvent("PlayeStartQuest_delivery_of_goods",root)

QUEST_DATA = {
	id = "delivery_of_goods",
	is_company_quest = true,

	title = "Доставка товара",
	description = "Услуга была выполнена, надеюсь Роман сдержит своё слово!",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 556.4246, -496.3263, 20.9102 ),

	quests_request = { "long_awaited_meeting" },
	level_request = 10,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
			player.interior = 0
		end,
		client = function ( )
			local ped = FindQuestNPC( "roman_in_house" ).ped
			ped.interior = 2
			localPlayer.frozen = false
		end
	},

	tasks = {
		{
			name = "Встретиться с Романом",

			Setup = {
				client = function( )
					local ped = FindQuestNPC( "roman_in_house" ).ped
					ped.interior = 1

					CreateQuestPoint( QUEST_CONF.positions.house_enter, function( self )
						self:destroy( )

						fadeCamera( false, 0 )
						EnterLocalDimension( )
						ped.dimension = localPlayer:GetUniqueDimension( )

						localPlayer.position = QUEST_CONF.positions.house_exit
						localPlayer.rotation = Vector3( 0, 0, -90 )
						localPlayer.interior = 1

						GEs.fade_timer = Timer( function ( )
							FadeBlink( 2.0 )
						end, 2000, 1 )

						CreateMarkerToCutsceneNPC( {
							id = "roman_in_house",
							radius = 1,
							local_dimension = true,
							dialog = QUEST_CONF.dialogs.start,
							callback = function( )
								CEs.marker.destroy( )
								CEs.dialog:next( )

								StartPedTalk( ped, nil, true )

								setTimerDialog( function( )
									CEs.dialog:next( )
									setTimerDialog( function( )
										triggerServerEvent( "delivery_of_goods_step_1", localPlayer )
									end, 10500 )
								end, 10500 )
							end
						} )
					end )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "roman_in_house" ).ped )
				end,
			},

			event_end_name = "delivery_of_goods_step_1",
		},

		{
			name = "Садись в фургон",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.house_exit, function( self )
						self:destroy( )

						fadeCamera( false, 0 )

						localPlayer.position = QUEST_CONF.positions.house_enter
						localPlayer.interior = 0

						GEs.fade_timer = Timer( function ( )
							FadeBlink( 2.0 )
							triggerServerEvent( "delivery_of_goods_step_2", localPlayer )
						end, 2000, 1 )
					end, nil, 1 )
				end,
			},

			event_end_name = "delivery_of_goods_step_2",
		},

		{
			name = "Садись в фургон",

			Setup = {
				client = function( )
					FadeBlink( )

					localPlayer.position = QUEST_CONF.positions.house_enter
					localPlayer.rotation = Vector3( 0, 0, 0 )
					localPlayer.interior = 0

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть в фургон",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					CEs.onEnterInDPSVehicle = function( theVehicle, seat )
						if theVehicle == localPlayer:getData( "temp_vehicle" ) and seat == 0 then
							removeEventHandler( "onClientPlayerVehicleEnter", root, CEs.onEnterInDPSVehicle )
							triggerServerEvent( "delivery_of_goods_step_3", localPlayer )
						end
					end
					addEventHandler( "onClientPlayerVehicleEnter", root, CEs.onEnterInDPSVehicle )
				end,
				server = function( player )
					local vehicle = CreateTemporaryVehicle( player, 459, Vector3( 553.01, -518.58, 20.5 ), Vector3( 0, 0, 0 ) )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetNumberPlate( "1:к039ен39" )
					vehicle:SetColor( 0, 0, 0 )
				end,
			},

			event_end_name = "delivery_of_goods_step_3",
		},

		{
			name = "Доставь товар",

			Setup = {
				client = function( )
					local vehicle = localPlayer:getData( "temp_vehicle" )

					table.insert( GEs, WatchElementCondition( vehicle, {
						condition = function( self, conf )
							if self.element.health <= 770 or self.element.inWater then
								FailCurrentQuest( "Фургон с товаром сильно повреждены!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					CreateQuestPoint( Vector3( -1936.04, 665.19, 17.8 ), function( )
						CEs.marker.destroy( )
						setPedControlState( localPlayer, "enter_exit", true )
						addEventHandler( "onClientVehicleStartEnter", vehicle, cancelEvent )
						triggerServerEvent( "delivery_of_goods_step_4", localPlayer )

					end, nil, nil, nil, nil, function ( )
						return localPlayer.vehicle == vehicle
					end )
				end,
			},

			event_end_name = "delivery_of_goods_step_4",
		},

		{
			name = "Поговори с охранником",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "west_cartel_guard",
						dialog = QUEST_CONF.dialogs.finish,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )

							StartPedTalk( FindQuestNPC( "west_cartel_guard" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "delivery_of_goods_step_5", localPlayer )
							end, 11000 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "west_cartel_guard" ).ped )
				end,
			},

			event_end_name = "delivery_of_goods_step_5",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Охранник", msg = "Это Западный картель. У нас есть нерешенный вопрос. Подъезжай! Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "rescue_operation" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = QUEST_CONF.rewards
		} )
	end,

	rewards = QUEST_CONF.rewards,
	no_show_rewards = true,
}