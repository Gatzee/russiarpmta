QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Александр", voice_line = "Alexandr_5", text = "Здравствуй, у меня одна проблема осталась. Нужно забрать долг у бизнесмена.\nОх, уж эти любители пассивного дохода вечно деловые, а про долги вечно забывают" },
			{ name = "Александр", text = "Кстати, если есть желание быстро подняться, приобретай новый бизнес,\nих по городу много продают, а если нужен рабочий, то загляни на биржу.\nИ все же ты аккуратнее с должником, я его плохо знаю." },
		},
		finish = {
			{ name = "Александр", voice_line = "Alexandr_6_1", text = "Привет, как прошло?" },
			{ text = "Нажми Q чтобы открыть инвентарь и перетащи кошелёк с деньгами на Александра" },
			{ name = "Александр", voice_line = "Alexandr_6_2", text = "Ага. Я знал что ты справишься и подготовил почву для разговора.\nКак будет время, приходи. Но не затягивай!" },
		},
	},

	positions = {
		shop_target = Vector3( 2187.1452636719, -1199.53207397461, 60.6565284729 ),

		path = {
			{ x = 2168.142, y = -336.244 - 860, z = 61.148 },
			{ x = 2170.928, y = -334.583 - 860, z = 60.674 },
			{ x = 2166.484, y = -324.017 - 860, z = 60.674 },
			{ x = 2156.695, y = -317.238 - 860, z = 60.682 },
			{ x = 2130.468, y = -297.648 - 860, z = 60.682 },
			{ x = 2111.200, y = -282.401 - 860, z = 60.680 },
			{ x = 2102.837, y = -276.863 - 860, z = 60.680 },
			{ x = 2090.971, y = -281.059 - 860, z = 60.680 },
		},

		kick_position = Vector3( 2176.4909667969, -1215.62756347656, 60.681526184082 ),
		kick_rotation = Vector3( 0, 0, 62.077392578125 ),

		after_cutscene_position = Vector3( 2165.876953125, -1184.6142578125, 60.673713684082 ),
		after_cutscene_rotation = Vector3( 0, 0, 54.933410644531 ),
	},
}

GEs = { }

QUEST_DATA = {
	id = "alexander_debt",
	is_company_quest = true,

	title = "Забрать долг",
	description = "Александр в своем репертуаре и за бесплатно не поможет, придется выполнить еще одно его поручение и вспомнить прошлое, забрав деньги у его должника.",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1774.9056, -637.4530, 60.8555 ),

	quests_request = { "angela_cinema" },
	level_request = 3,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			local vehicles_parked = ExitLocalDimension( player )
			if vehicles_parked then
				player:PhoneNotification( { title = "Эвакуация", msg = "Тебе доступна бесплатная эвакуация использованного в квесте транспорта!" } )
			end
			DisableQuestEvacuation( player )
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
						radius = 1,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							StartPedTalk( FindQuestNPC( "alexander" ).ped, nil, true )
							CEs.dialog:next( )

							setTimerDialog( function( )
								CEs.dialog:next( )
								setTimerDialog( function( )
									triggerServerEvent( "alexander_debt_step_1", localPlayer )
								end, 13000, 1 )
							end, 10500, 1 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "alexander" ).ped )
				end,
			},

			event_end_name = "alexander_debt_step_1",
		},

		[ 2 ] = {
			name = "Добраться до должника",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.kick_position, function( self, player )
						CEs.marker.destroy( )

						localPlayer.position = positions.kick_position
						localPlayer.rotation = positions.kick_rotation
						setPedAnimation( localPlayer, "fight_e", "fightkick_b", -1, false )
						CEs.timer = setTimer( function( )
							fadeCamera( false, 1.0 )
							CEs.timer = setTimer( function( )
								triggerServerEvent( "alexander_debt_step_2", localPlayer )
							end, 2000, 1 )
						end, 1000, 1 )
					end, _, 1, _, localPlayer:GetUniqueDimension( ), function( self, player )
						if localPlayer.vehicle then
							return false, "Выйди из машины чтоб постучаться"
						end
						return true
					end )
				end,
				server = function( player )
					EnableQuestEvacuation( player )
					local vehicles = EnterLocalDimensionForVehicles( player )

					local current_vehicle = player.vehicle
					if not vehicles or not current_vehicle or not vehicles[ current_vehicle ] then
						removePedFromVehicle( player )
					end
				end,
			},

			event_end_name = "alexander_debt_step_2",
		},

		[ 3 ] = {
			name = "Выбить долг из должника",

			Setup = {
				client = function( )
					local stripes = CreateBlackStripes( )
					stripes:show( )
					DisableHUD( true )
					fadeCamera( true, 1.0 )

					local positions = QUEST_CONF.positions

					local from = { 2174.5812988281, -1198.03726196289, 60.215755462646, 2087.0473632813, -1149.73684692383, 58.007881164551, 0, 70 }
					local to = { 2170.67578125, -1186.47311401367, 65.54793548584, 2087.5688476563, -1132.41690063477, 52.464641571045, 0, 70 }
					CameraFromTo( from, to, 10000, "InOutQuad", function( )
						localPlayer.position = positions.after_cutscene_position
						localPlayer.rotation = positions.after_cutscene_rotation

						stripes:destroy_with_animation( )
						MoveCameraToLocalPlayer( 1.0, function( )
							FadeBlink( 1.0 )
							setCameraTarget( localPlayer )
							DisableHUD( false )
						end )
					end )

					local pos = positions.path[ 1 ]
					GEs.bot = CreateAIPed( 115, Vector3( pos.x, pos.y, pos.z ) )
					LocalizeQuestElement( GEs.bot )
					GEs.bot.health = 1
					
					SetAIPedMoveByRoute( GEs.bot, positions.path, false, function( )
						CreateQuestPoint( GEs.bot.position, function( self, player )
							CEs.marker.destroy( )
						end )
					end )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=ЛКМ чтобы ударить должника",
						condition = function( )
							return ( localPlayer.position - GEs.bot.position ).length <= 5
						end,
					} )

					local t = { }
					t.OnWasted = function( )
						removeEventHandler( "onClientPedWasted", GEs.bot, t.OnWasted )
						triggerServerEvent( "alexander_debt_step_3", localPlayer )
					end
					addEventHandler( "onClientPedWasted", GEs.bot, t.OnWasted )
				end,
			},

			event_end_name = "alexander_debt_step_3",
		},

		[ 4 ] = {
			name = "Забери ключ-код",

			Setup = {
				client = function( )
					CEs.timer = setTimer( function( )
						local added_handler = false
						CreateQuestPoint( GEs.bot.position, function( self, player )
							if added_handler then return end
							added_handler = true

							local function IsNearBot( )
								return ( localPlayer.position - GEs.bot.position ).length <= 2
							end
							CEs.hint = CreateSutiationalHint( {
								text = "Нажми key=Alt чтобы забрать ключ-код",
								condition = IsNearBot,
							} )

							local t = { }
							t.OnAlt = function( )
								if not IsNearBot( ) then return end
								CEs.hint:destroy_with_animation( )
								setPedAnimation( localPlayer, "bomber", "bom_plant", 1000, true, false, false, false )

								unbindKey( "lalt", "down", t.OnAlt )
								triggerServerEvent( "alexander_debt_step_4", localPlayer )
							end
							bindKey( "lalt", "down", t.OnAlt )
						end, _, 1, _, _ )
					end, 1000, 1 )
				end,
			},

			event_end_name = "alexander_debt_step_4",
		},

		[ 5 ] = {
			name = "Сними деньги со счета бизнеса",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.kick_position, function( self, player )
						CEs.marker.destroy( )
						function IsNearBusiness( )
							return ( localPlayer.position - positions.kick_position ).length <= 5
						end

						CEs.hint = CreateSutiationalHint( {
							text = "Нажми key=Alt чтобы открыть интерфейс бизнеса",
							condition = IsNearBusiness,
						} )

						local t = { }
						t.OnAlt = function( )
							if not IsNearBusiness( ) then return end
							CEs.hint:destroy_with_animation( )

							UnblockAllKeys( )
							unbindKey( "lalt", "down", t.OnAlt )
							ShowBusinessUI( true )
						end
						bindKey( "lalt", "down", t.OnAlt )
					end, _, 3, _, _, function( self, player )
						if localPlayer.vehicle then
							return false, "Выйди из машины чтоб продолжить"
						end
						return true
					end )

				end,
			},

			CleanUp = {
				client = function( )
					ShowBusinessUI( false )
				end
			},

			event_end_name = "alexander_debt_step_5",
		},

		[ 6 ] = {
			name = "Вернуть деньги Александру",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "alexander",
						dialog = QUEST_CONF.dialogs.finish,
						radius = 1,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							StartPedTalk( FindQuestNPC( "alexander" ).ped, nil, true )
							CEs.dialog:next( )

							CEs.next_step_tmr = setTimer( function( )
								CEs.dialog:next( )

								BlockAllKeys( { "q" } )
								local t = { }
								function t.OnGiveMoney( )
									removeEventHandler( "onPlayerGiveQuestMoney", localPlayer, t.OnGiveMoney )
									CEs.dialog:next( )
									BlockAllKeys( )
									setTimerDialog( function( )
										triggerServerEvent( "alexander_debt_step_6", localPlayer )
									end, 10000, 1 )
								end
								addEventHandler( "onPlayerGiveQuestMoney", localPlayer, t.OnGiveMoney )
							end, 3000, 1 )
							
						end
					} )
				end,
				server = function( player )
        			player:InventoryAddItem( IN_QUEST_MONEY, nil, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "alexander" ).ped )
				end,
				server = function( )
					player:InventoryRemoveItem( IN_QUEST_MONEY )
				end,
			},

			event_end_name = "alexander_debt_step_6",
		},
	},

	GiveReward = function( player )
		if player:GetPermanentData( "reg_date" ) >= NEW_TUTORIAL_RELEASE_DATE then
			player:GiveAllVehiclesDiscount( 24 * 60 * 60, 25 )
			triggerEvent( "onCarOffer25ShowFirst", player )
		end
		
		player:SituationalPhoneNotification(
			{ title = "Александр", msg = "Привет, я договорился о встрече! Как будет время приезжай ко мне. Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "alexander_talks" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				exp = 800,
				money = 500,
			}
		} )
	end,

	rewards = {
		exp = 800,
		money = 500,
	},

	no_show_rewards = true,
}

addEvent( "onPlayerGiveQuestMoney", true )