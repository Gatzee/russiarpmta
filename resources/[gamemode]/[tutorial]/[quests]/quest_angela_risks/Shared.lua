QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Анжела", voice_line = "Angela_6", text = "Приветики, любишь рисковать?! Поехали, покажу тебе головокружительное место.\nГде ты можешь не только развлечься, но и много заработать." },
		},
		finish = {
			{ name = "Анжела", voice_line = "Angela_7", text = "Потом сможешь продолжить, а сейчас нам пора." },
		},
	},

	positions = {
		vehicle_main_spawn = Vector3( 1956.734, -254.075, 60.149 ),
		vehicle_main_spawn_rotation = Vector3( 0, 0, 226.5 ),

		matrix_start = { 1939.1590576172, -255.81024169922, 65.812721252441, 2033.4298095703, -269.2041015625, 35.8180809021, 0, 70 },
		drive_start = {
			{ x = 2017.529, y = -311.514, z = 60.404 },
		},

		vehicle_spawn_casino = Vector3( 668.92199707031, -205.18743896484, 20.444929122925 ),
		vehicle_spawn_casino_rotation = Vector3( 359.68188476563, 359.97805786133, 5.715087890625 ),
		drive_casino = {
			{ x = 668.92199707031, y = -205.18743896484, z = 20.444929122925, distance = 10 },
			{ x = 666.75860595703, y = -182.04516601563, z = 20.444717407227, distance = 10 },
		},
		matrix_drive = { 662.92272949219, -193.56420898438, 20.187994003296, 701.84051513672, -101.62231445313, 23.46054649353, 0, 70 },

		casino_enter_position = Vector3( 706.88140869141, -209.21179199219, 21.055219650269 ),

		in_casino_position = Vector3( -88.744888305664, -501.36547851563, 913.97216796875 ),
		casino_slotmachine_position = Vector3( -45.6720, -482.9287, 913.97216796875 ),
		casino_roulette_position = Vector3( -82.590103149414, -478.93374633789, 913.97216796875 ),

		angela_position = Vector3( -90.511985778809, -490.54840087891, 913.97216796875 ),
		angela_rotation = Vector3( 0, 0, 268.51663208008 ),

		talk_position = Vector3( -89.4404296875, -490.53619384766, 913.97216796875 ),
		talk_rotation = Vector3( 0, 0, 89.558898925781 ),
		matrix_talk = { -88.650482177734, -491.43023681641, 914.70397949219, -170.93975830078, -436.03228759766, 902.07299804688, 0, 70 },

		vehicle_spawn = Vector3( 667.12127685547, -188.84759521484, 20.443935394287 ),
		vehicle_spawn_rotation = Vector3( 0.065155029296875, 359.97821044922, 8.2885131835938 ),

		drive_leave = {
			{ x = 664.13116455078, y = 730.27221679688 - 860, z = 20.442741394043 },
			{ x = 663.64855957031, y = 749.53137207031 - 860, z = 20.444856643677 },
			{ x = 637.45965576172, y = 763.15081787109 - 860, z = 20.443895339966 },
		},
		matrix_leave = { 660.74090576172, -192.52032470703, 24.671644210815, 675.67834472656, -95.76135253906, 6.7536864280701, 0, 70 },

		path_to_vehicle =
		{
			{ x = 697.366, y = -198.110, z = 20.939 },
			{ x = 683.709, y = -199.708, z = 20.939 },
			{ x = 681.454, y = -180.987, z = 20.939 },
			{ x = 664.373, y = -185.656, z = 20.701 },
			{ x = 665.377, y = -189.120, z = 20.701 },
		},

		drive_comeback = {
			{ x = 1956.734, y = -254.075, z = 60.149, speed_limit = 20 },
		},
		vehicle_comeback_spawn = Vector3( 1991.7973632813, -287.31634521484, 60.145313262939 ),
		vehicle_comeback_spawn_rotation = Vector3( 0.065460205078125, 359.97814941406, 45.77099609375 ),
		matrix_comeback = { 1963.0852050781, -268.92114257813, 60.063022613525, 1933.9438476563, -172.52746582031, 63.25857925415, 0, 70 },
	},
}

GEs = { }

QUEST_DATA = {
	id = "angela_risks",
	is_company_quest = true,

	title = "Голые риски",
	description = "Наконец то можно развеяться, Анжела хочет показать интересное место. То что нужно, чтобы расслабиться.",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1951.2601, -249.4949, 60.4046 ),

	quests_request = { "alexander_talks" },
	level_request = 3,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			if player.interior ~= 0 then
				player.interior = 0
				local quest_npc = FindQuestNPC( "angela" )
				if quest_npc then
					player.position = quest_npc.player_position
				end
			end
			ExitLocalDimension( player )
		end,
	},

	tasks = {
		{
			name = "Поговорить с Анжелой",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "angela",
						dialog = QUEST_CONF.dialogs.main,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "angela" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "angela_risks_step_1", localPlayer )
							end, 9000, 1 )
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
					StopPedTalk( FindQuestNPC( "angela" ).ped )
				end,
			},

			event_end_name = "angela_risks_step_1",
		},

		{
			name = "Сесть в машину на пассажирское место",

			Setup = {
				client = function( )
					HideNPCs( )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть на пассажирское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return not localPlayer.vehicle and isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Машина Анжелы уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					GEs.bot = CreateAIPed( 131, Vector3( 1961.3009033203, -250.86895751953, 60.419208526611 ) )
					LocalizeQuestElement( GEs.bot )
					SetUndamagable( GEs.bot, true )

					local t = { }
					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.bot.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )

							StartQuestCutscene( )

							local positions = QUEST_CONF.positions
							SetAIPedMoveByRoute( GEs.bot, positions.drive_start, false )
							setCameraMatrix( unpack( positions.matrix_start ) )

							CEs.timer = setTimer( function( )
								fadeCamera( false, 1.0 )
								CEs.timer = setTimer( function( )
									triggerServerEvent( "angela_risks_step_2", localPlayer )
								end, 2000, 1 )
							end, 3000, 1 )
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
							localPlayer:ShowError( "Сядь на пассажирское место, сегодня Анжела тебя повезёт" )
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

			CleanUp = {
				client = function( )
					CleanupAIPedPatternQueue( GEs.bot )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_risks_step_2",
		},

		{
			name = "Прибытие...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					setCameraMatrix( unpack( positions.matrix_drive ) )
					fadeCamera( true )

					StartQuestCutscene( )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					temp_vehicle.velocity = Vector3( )
					temp_vehicle.turnVelocity = Vector3( )

					local pos = positions.drive_casino[ 1 ]
					temp_vehicle.position = positions.vehicle_spawn_casino
					temp_vehicle.rotation = positions.vehicle_spawn_casino_rotation

					SetAIPedMoveByRoute( GEs.bot, positions.drive_casino, false, function( )
						CEs.timer = setTimer( function( )
							if temp_vehicle.velocity.length <= 0 then
								CreateAIPed( localPlayer )
								for i, v in pairs( { localPlayer, GEs.bot } ) do
									AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
								end
								triggerServerEvent( "angela_risks_step_3", localPlayer )
							end
						end, 500, 0 )
					end )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					local positions = QUEST_CONF.positions
					vehicle.position = positions.vehicle_spawn_casino
					vehicle.rotation = positions.vehicle_spawn_casino_rotation
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_risks_step_3",
		},

		{
			name = "Зайти в казино с Анжелой",

			Setup = {
				client = function( )
					CEs.timer = setTimer( function( )
						if not GEs.bot.vehicle then
							killTimer( sourceTimer )
							CEs.follow = CreatePedFollow( GEs.bot )
							CEs.follow:start( localPlayer )
						end
					end, 500, 0 )

					CreateQuestPoint( QUEST_CONF.positions.casino_enter_position, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "angela_risks_step_4", localPlayer )
					end,
					_, _, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Боюсь что на машине в казино не пустят"
						end
						return true
					end )
				end,
			},

			CleanUp = {
				client = function( )
					CEs.follow:destroy( )
				end,
			},

			event_end_name = "angela_risks_step_4",
		},

		{
			name = "Сыграть в слот-машины \"Вальхалла\"",

			Setup = {
				client = function( )
					FadeBlink( )
					
					local positions = QUEST_CONF.positions
					localPlayer.position = positions.in_casino_position
					localPlayer.interior = 1

					local position = QUEST_CONF.positions
					GEs.bot.position = positions.angela_position
					GEs.bot.rotation = positions.angela_rotation
					GEs.bot.interior = 1

					CreateQuestPoint( QUEST_CONF.positions.casino_slotmachine_position, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "angela_risks_step_5", localPlayer )
					end )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			event_end_name = "angela_risks_step_5",
		},

		{
			name = "Попытай удачу",

			Setup = {
				client = function( )
					CreateFakeSlotmachineGame( )
					BlockMovement( )
					localPlayer.frozen = true
				end,
			},

			CleanUp = {
				client = function( )
					UnblockMovement( )
					localPlayer.frozen = false
				end,
			},

			event_end_name = "angela_risks_step_6",
		},

		{
			name = "Начать игру в Рулетку",

			Setup = {
				client = function( )
					localPlayer:ShowInfo( "В следующий раз повезет" )
					CreateQuestPoint( QUEST_CONF.positions.casino_roulette_position, function( self, player )
						CEs.marker.destroy( )

						triggerServerEvent( "angela_risks_step_7", localPlayer )
					end )
				end,
			},

			event_end_name = "angela_risks_step_7",
		},

		{
			name = "Выиграть раунд",

			Setup = {
				client = function( )
					StartFakeRouletteGame( )
					BlockMovement( )
					localPlayer.frozen = true
				end,
			},

			CleanUp = {
				client = function( )
					FinishFakeRouletteGame( )
					UnblockMovement( )
					localPlayer.frozen = false
				end,
			},

			event_end_name = "angela_risks_step_8",
		},

		{
			name = "Поговори с Анжелой",

			Setup = {
				client = function( )
					localPlayer:ShowInfo( "Победа!" )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.angela_position, function( self, player )
						CEs.marker.destroy( )

						localPlayer.position = positions.talk_position
						localPlayer.rotation = positions.talk_rotation

						StartQuestCutscene( {
							dialog = QUEST_CONF.dialogs.finish,
						} )
						CEs.dialog:next( )
						StartPedTalk( GEs.bot, nil, true )

						setCameraMatrix( unpack( positions.matrix_talk ) )

						setTimerDialog( function( )
							triggerServerEvent( "angela_risks_step_9", localPlayer )
						end, 4000, 1 )
					end )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.bot )
				end,
			},

			event_end_name = "angela_risks_step_9",
		},

		{
			name = "Покинь казино",

			Setup = {
				client = function( )
					CEs.follow = CreatePedFollow( GEs.bot )
					CEs.follow:start( localPlayer )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.in_casino_position, function( self, player )
						CEs.marker.destroy( )
						CEs.follow:destroy( )
						triggerServerEvent( "angela_risks_step_10", localPlayer )
					end )
				end,
				server = function( player )
					DestroyAllTemporaryVehicles( player )

					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 6537, Vector3( 665.840, -172.975, 20.402 ), Vector3( 0, 0, 0 ) )
					vehicle:SetColor( 255, 0, 0 )
					vehicle:SetNumberPlate( "1:o746oo178" )
					player:SetPrivateData( "temp_vehicle", vehicle )
				end,
			},

			event_end_name = "angela_risks_step_10",
		},

		{
			name = "Сядь в машину пассажиром",

			Setup = {
				client = function( )
					HideNPCs( )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть на пассажирское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return not localPlayer.vehicle and isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local positions = QUEST_CONF.positions

					localPlayer.position = positions.casino_enter_position
					localPlayer.interior = 0
					
					GEs.bot.position = localPlayer.position + Vector3( 1, 1, 0 )
					GEs.bot.interior = localPlayer.interior

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					temp_vehicle.position = positions.vehicle_spawn
					temp_vehicle.rotation = positions.vehicle_spawn_rotation

					local t = { }
					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.bot.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )

							StartQuestCutscene( )

							local positions = QUEST_CONF.positions
							removePedTask( GEs.bot )
							ResetAIPedPattern( GEs.bot )
							SetAIPedMoveByRoute( GEs.bot, positions.drive_leave, false )
							setCameraMatrix( unpack( positions.matrix_leave ) )

							CEs.timer = setTimer( function( )
								fadeCamera( false, 1.0 )
								CEs.timer = setTimer( function( )
									triggerServerEvent( "angela_risks_step_11", localPlayer )
								end, 2000, 1 )
							end, 3000, 1 )
						end
					end

					SetAIPedMoveByRoute( GEs.bot, positions.path_to_vehicle, false, function( )
						AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
							vehicle = temp_vehicle;
							seat = 0;
							end_callback = {
								func = CheckBothInVehicle,
								args = { },
							}
						} )
					end )

					t.OnStartEnter = function( player, seat )
						if player == localPlayer and seat == 0 then
							cancelEvent( )
							localPlayer:ShowError( "Сядь на пассажирское место, Анжела тебя отвезёт" )
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
					player.interior = 0
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_risks_step_11",
		},

		{
			name = "Прибытие...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					removePedTask( GEs.bot )
					ResetAIPedPattern( GEs.bot )

					setCameraMatrix( unpack( positions.matrix_comeback ) )
					fadeCamera( true )

					StartQuestCutscene( )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					temp_vehicle.position = positions.vehicle_comeback_spawn
					temp_vehicle.rotation = positions.vehicle_comeback_spawn_rotation
					temp_vehicle.velocity = Vector3( )
					temp_vehicle.turnVelocity = Vector3( )

					local counter = 0

					SetAIPedMoveByRoute( GEs.bot, positions.drive_comeback, false, function( )
						CEs.timer = setTimer( function( )
							if temp_vehicle.velocity.length <= 0 or counter >= 12 then
								killTimer( sourceTimer )
								CreateAIPed( localPlayer )
								AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_VEHICLE_EXIT, {
									end_callback = {
										func = function( )
											triggerServerEvent( "angela_risks_step_12", localPlayer )
										end,
										args = { },
									}
								} )
							end

							counter = counter + 1
						end, 500, 0 )
					end )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					local positions = QUEST_CONF.positions
					vehicle.position = positions.vehicle_comeback_spawn
					vehicle.rotation = positions.vehicle_comeback_spawn_rotation
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_risks_step_12",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Олег", msg = "Приветствую это Олег беспокоит, у меня проблемы с полицией нужна твоя помощь. Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "oleg_govhelp" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				exp = 900,
				money = 500,
			}
		} )

		player:AddDailyQuest( "play_casino", true )
	end,

	rewards = {
		exp = 900,
		money = 500,
	},
	
	no_show_rewards = true,
}

do
	local controls = {
		"fire", "forwards", "backwards", "left", "right", "jump", "crouch"
	}
	function BlockMovement( )
		for i, v in pairs( controls ) do
			toggleControl( v, false )
		end
	end

	function UnblockMovement( )
		for i, v in pairs( controls ) do
			toggleControl( v, true )
		end
	end
end