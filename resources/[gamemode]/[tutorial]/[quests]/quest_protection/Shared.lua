QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Охранник", voice_line = "Guard_monolog_4", text = [[Ооо, бродяга, а ты, я смотрю, не особо торопился!
Аккуратнее тут, у нас пунктуальность ценится наравне с деньгами! ]] },
			{ name = "Охранник", text = [[Давай к делу. У нас тут проблемы серьёзные намечаются.
Я деталей не знаю. Тебе все приближенный расскажет, проходи!]]}
		},
		cartel = {
			{ name = "Приближенный", voice_line = "Closeman_monolog_5", text = [[Вечер в хату.
Слухами мир полнится, и до нас шепот доходит о тебе. Думаю сработаемся.
Помнишь документы? Мы в твое дело впишемся, но с тебя плату возьмем.]] },
			{ name = "Приближенный", text = [[Сейчас маза есть, надо защитить барыгу. Он под нами ходит, а лишние руки
на дороге не валяются. Успешно выполнишь работу, тогда и поговорим!]]}
		},
		finish = {
			{ name = "Приближенный", voice_line = "Closeman_monolog_6", text = [[А ты боец! Неплохо вышло. Ладно, можешь на нас рассчитывать,
но учти это не вечно!]] },
		},
	},

	positions = {
		guard_spawn = { pos = Vector3( -1942.9030, 680.8471, 18.3314 ), rot = 280 },

		west_gates = { pos = Vector3( -1942.0588134766, 663.52799072266, 18.485349655151 ), rot = Vector3( 0, 0, 10 ) },

		west_guards = {
			{ pos = Vector3( -1979.7105, 647.6136, 21.9808 ), rot = 281 },
			{ pos = Vector3( -1982.8135, 665.4837, 21.9808 ), rot = 279 },
			{ pos = Vector3( -1980.9775, 656.4002, 21.9808 ), rot = 279 },
			{ pos = Vector3( -1983.9226, 642.6508, 18.4853 ), rot = 279 },
			{ pos = Vector3( -1988.4256, 668.7527, 18.4928 ), rot = 277 },
			{ pos = Vector3( -1969.7747, 670.2835, 18.4853 ), rot = 220 },
			{ pos = Vector3( -1966.3282, 640.1213, 18.7040 ), rot = 326 },
			{ pos = Vector3( -1951.5627, 652.9140, 18.4853 ), rot = 5   },
			{ pos = Vector3( -1999.3021, 628.7557, 18.4853 ), rot = 297 },
			{ pos = Vector3( -2006.0462, 673.8437, 18.4853 ), rot = 276 },
			{ pos = Vector3( -1998.5227, 662.1861, 18.4928 ), rot = 18  },
			{ pos = Vector3( -1995.8953, 645.4427, 18.4853 ), rot = 190 },
		},

		west_guards_interior = {
			{ pos = Vector3( 457.8113, -1206.2603, 1096.0899 ), rot = 1   },
			{ pos = Vector3( 452.2679, -1206.4005, 1096.0899 ), rot = 1   },
			{ pos = Vector3( 457.9622, -1196.5179, 1096.0899 ), rot = 184 },
			{ pos = Vector3( 452.1653, -1196.6474, 1096.0899 ), rot = 181 },
			{ pos = Vector3( 438.7445, -1202.9569, 1099.0474 ), rot = 269 },
			{ pos = Vector3( 439.4834, -1200.1868, 1099.0406 ), rot = 268 },
			{ pos = Vector3( 446.0445, -1196.9859, 1101.2745 ), rot = 73  },
			{ pos = Vector3( 445.9247, -1205.8033, 1101.2593 ), rot = 116 },
			{ pos = Vector3( 461.5321, -1201.4687, 1100.0971 ), rot = 89  },
		},

		outer_kartel_house_position = { pos = Vector3( -1984.2077, 657.1320, 18.4928 ), rot = Vector3( 0, 0, 101 ) },
		inner_kartel_house_position = { pos = Vector3( 461.5176, -1201.4753, 1096.0899 ), rot = Vector3( 0, 0, 90 ) },

		close_man_spawn =  { pos = Vector3( 451.26,-1201.63, 1095.59 ), rot = 280 },
		close_man_dialog_position = { pos = Vector3( 451.9605, -1201.6372, 1096.0899 ), rot = Vector3( 0, 0, 92.599914550781 ) },
		close_man_dialog_matrix =  { 452.6829, -1202.0314, 1096.9965, 358.7288, -1172.4531, 1079.7412, 0, 70 },

		western_cartel_veh_1_spawn = { pos = Vector3( -1961.3199, 660.1699, 18.5699 ), rot = Vector3( 0, 0, 280 ) },
		western_cartel_veh_2_spawn = { pos = Vector3( -1948.7399, 662.6202, 18.5705 ), rot = Vector3( 0, 0, 280 ) },

		west_cartel_huckster = { pos = Vector3( -1429.7998, 207.5901, 18.9970 ) },
		
		bandit_path_to_huckster = {
			{ x = -1935.2032, y = 666.4099, z = 17.6956, speed_limit = 30, distance = 10 },
			{ x = -1895.1690, y = 617.3696, z = 17.3411, speed_limit = 30, distance = 10 },
			{ x = -1900.1868, y = 556.8809, z = 18.6203, speed_limit = 30, distance = 10 },
			{ x = -1805.5345, y = 555.1739, z = 18.6412, speed_limit = 50, distance = 10 },
			{ x = -1755.5133, y = 535.4610, z = 19.2621, speed_limit = 50, distance = 10 },
			{ x = -1736.2092, y = 520.2364, z = 19.2748, speed_limit = 50, distance = 10 },
			{ x = -1707.2093, y = 429.3886, z = 18.6409, speed_limit = 50, distance = 10 },
			{ x = -1678.4012, y = 293.9350, z = 18.6379, speed_limit = 50, distance = 10 },
			{ x = -1646.7005, y = 247.8480, z = 18.6388, speed_limit = 50, distance = 10 },
			{ x = -1513.8841, y = 172.5349, z = 21.3924, speed_limit = 40, distance = 10 },
			{ x = -1474.8813, y = 136.3825, z = 21.9296, speed_limit = 30, distance = 10 },
			{ x = -1454.8742, y = 146.4487, z = 21.9248, speed_limit = 20, distance = 10 },
			{ x = -1446.0384, y = 190.7826, z = 20.1361, speed_limit = 20, distance = 10 },
		},

		friend_bots_1_attack_path = 
		{
			{
				{ x = -1431.5761, y = 198.1391, z = 19.5578 },
				{ x = -1412.7281, y = 187.2491, z = 18.9970 },
				{ x = -1387.7471, y = 175.5854, z = 19.0291 },
			},
			{
				{ x = -1431.5761, y = 198.1391, z = 19.5578 },
				{ x = -1412.7281, y = 187.2491, z = 18.9970 },
				{ x = -1388.8394, y = 176.7712, z = 19.0806 },
			},
			{
				{ x = -1431.5761, y = 198.1391, z = 19.5578 },
				{ x = -1412.7281, y = 187.2491, z = 18.9970 },
				{ x = -1389.9354, y = 177.9566, z = 19.1018 },
			},
			{
				{ x = -1431.5761, y = 198.1391, z = 19.5578 },
				{ x = -1412.7281, y = 187.2491, z = 18.9970 },
				{ x = -1390.8702, y = 179.0669, z = 19.0582 },
			},
			{
				{ x = -1428.3690, y = 196.3302, z = 19.4758 },
				{ x = -1412.3793, y = 188.1104, z = 18.9970 },
				{ x = -1401.2467, y = 189.1922, z = 19.0800 },
			},
			{
				{ x = -1428.3690, y = 196.3302, z = 19.4758 },
				{ x = -1412.3793, y = 188.1104, z = 18.9970 },
				{ x = -1399.7973, y = 187.6408, z = 19.1529 },
			},
			{
				{ x = -1428.3690, y = 196.3302, z = 19.4758 },
				{ x = -1412.3793, y = 188.1104, z = 18.9970 },
				{ x = -1398.4442, y = 186.2651, z = 18.9240 },
			},
		},

		hide_corpses_path = {
			{ x = -1398.9652099609, y = 180.27944946289, z = 18.997741699219 },
			{ x = -1373.8530273438, y = 204.00645446777, z = 18.983386993408 },
		},

		leave_path = {
			{ x = -1409.1018066406, y = 191.85876464844, z = 18.996017456055 },
			{ x = -1425.2078857422, y = 200.79388427734, z = 19.082765579224 },
			{ x = -1485.6801757813, y = 230.50485229492, z = 18.997037887573 },
			{ x = -1487.2510986328, y = 232.45709228516, z = 18.997037887573 },
		},

		leave_friends_vehicle_path = {
			{ x = -1544.5091, y = 252.2193, z = 17.9018, speed_limit = 100, distance = 10 },
			{ x = -1631.5820, y = 369.7723, z = 19.0276, speed_limit = 100, distance = 10 },
			{ x = -1718.2672, y = 555.2678, z = 19.0569, speed_limit = 100, distance = 10 },
		},

		east_cartel_veh_1_spawn = { pos = Vector3( -1379.7199, 203.2969, 19.0465 ), rot = Vector3( 0, 0, 230 ) },
		
		members_east_1_spawns = {
			{ pos = Vector3( -1374.9759, 204.8523, 18.9833 ), rot = 5    },
			{ pos = Vector3( -1374.6733, 207.3920, 18.9833 ), rot = 115  },
			{ pos = Vector3( -1377.2418, 206.5884, 18.9833 ), rot = 290  },
			{ pos = Vector3( -1377.4895, 209.2281, 18.9833 ), rot = 230  },
		},

		enemy_bots_1_attack_path = 
		{
			{ x = -1381.0378, y = 206.2811, z = 18.9833 },
			{ x = -1379.7424, y = 208.2191, z = 18.9833 },
			{ x = -1376.8311, y = 202.5480, z = 18.9833 },
			{ x = -1375.0560, y = 202.5350, z = 18.9833 },
		},

		east_attack_point = { pos = Vector3( -1390.8455, 192.4506, 18.9833 ) },

		camera_east_cartel_veh_move_1 = {
			from = { -1480.0565185547, 134.26052856445, 33.977230072021, -1396.7575683594, 174.03904724121, -4.4799790382385, 0, 70 },
			to   = { -1431.0983886719, 154.9751739502, 28.876300811768, -1358.5747070313, 207.52056884766, -15.612949371338, 0, 70 },
		},

		camera_east_cartel_veh_move_2 = {
			to = { -1400.9451904297, 177.51908874512, 26.649522781372, -1326.474609375, 237.66033935547, -2.2841849327087, 0, 70 },
		},

		east_cartel_veh_2_spawn = {
			{ pos = Vector3( -1489.9431152344, 129.51612854004, 22.50689125061 ), rot = Vector3( 0.72515869140625, 359.67007446289, 293.30728149414 ), cz = 68.012451171875 },
			{ pos = Vector3( -1474.1051025391, 138.18055725098, 22.619968414307 ), rot = Vector3( 359.609375, 359.84146118164, 294.12869262695 ), cz = 70.774658203125 },
		},

		east_cartel_veh_2_path = {
			{
				{ x = -1440.0012, y = 153.3440, z = 21.9087, speed_limit = 30, distance = 10 },
				{ x = -1401.0792, y = 177.9412, z = 19.0212, speed_limit = 30, distance = 10 },
				{ x = -1393.5805, y = 184.7112, z = 18.9892, speed_limit = 30, distance = 10 },
				{ x = -1357.9929, y = 199.6553, z = 19.0082, speed_limit = 30, distance = 10 },
			},
			{
				{ x = -1440.0012, y = 153.3440, z = 21.9087, speed_limit = 30, distance = 10 },
				{ x = -1401.0792, y = 177.9412, z = 19.0212, speed_limit = 30, distance = 10 },
				{ x = -1353.4797, y = 209.9580, z = 19.0081, speed_limit = 30, distance = 10 },
			},
		},

		friend_bots_2_attack_path = {
			[ 1 ] = { x = -1380.0194, y = 201.3421, z = 18.9833 },
			[ 2 ] = { x = -1382.3166, y = 205.9775, z = 18.9833 },
			[ 3 ] = { x = -1381.6466, y = 201.1395, z = 18.9833 },
		},

		enemy_bots_2_talk_path = 
		{
			[ 1 ]  = { x = -1363.5936, y = 197.9524, z = 18.9833 },
			[ 2 ]  = { x = -1368.8519, y = 197.8842, z = 18.9833 },
			[ 3 ]  = { x = -1370.2690, y = 200.0027, z = 18.9833 },
			[ 0 ]  = { x = -1365.0985, y = 206.8455, z = 18.9833 },
			[ 10 ] = { x = -1362.1470, y = 199.6935, z = 18.9833 },
			[ 20 ] = { x = -1363.5651, y = 205.2790, z = 18.9833 },
			[ 30 ] = { x = -1362.9111, y = 201.8514, z = 18.9833 },
		},

		enemy_bots_center_talk = { pos = Vector3( -1367.3947, 201.3685, 18.9833 ), },

		laeve_camera_matrix = { -1337.5515136719, 204.83044433594, 27.81210899353, -1433.7733154297, 195.35108947754, 2.2876064777374, 0, 70 },
		leave_enemy_path = {
			{ x = -1344.9782, y = 207.5493, z = 19.0073, speed_limit = 30, distance = 10 },
			{ x = -1355.2686, y = 219.9141, z = 19.0074, speed_limit = 30, distance = 10 },
			{ x = -1378.4418, y = 191.2619, z = 19.0119, speed_limit = 30, distance = 10 },
			{ x = -1414.3969, y = 168.0950, z = 19.2782, speed_limit = 30, distance = 10 },
			{ x = -1476.8322, y = 135.8742, z = 22.5757, speed_limit = 30, distance = 10 },
		},

		cartel_finish = { pos = Vector3( -1961.73, 659.93, 17.49 ), rot = Vector3( 0, 0, 0 ) },
		
		cartel_path_to_house = {
			{ x = -1978.3886, y = 655.7207, z = 18.4853 },
			{ x = -1984.7165, y = 654.9727, z = 18.4853 },
		},

		close_man_outer = { pos = Vector3( -1968.62, 660.72, 18.4 ), rot = Vector3( 0, 0, 278 ) },
		close_man_outer_dialog_position = { pos = Vector3( -1968.0120849609, 660.85363769531, 18.492805480957 ), rot = Vector3( 0, 0, 99.953765869141 ) },
		close_man_outer_dialog_matrix = { -1966.7844238281, 660.47698974609, 19.512237548828, -2062.6101074219, 671.51678466797, -6.8614001274109, 0, 70 },

		finish_mission_point = { pos = Vector3( -1938.2119, 656.1923, 18.4057 ) },
	},
}

GEs = { }

QUEST_DATA = {
	id = "protection",
	is_company_quest = true,

	title = "Защита",
	description = "Придется доделать начатое, иначе я так и не узнаю, где сейчас Александр.",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( -1925.2247, 681.5946, 18.6618 ),

	quests_request = { "return_of_history" },
	level_request = 10,

	OnAnyFinish = {
		client = function()
			localPlayer.frozen = false
			toggleControl( "enter_exit", true )
			triggerEvent( "SwitchRadioEnabled", root, true )
		end,
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			player:TakeAllWeapons( true )	

			if player.dimension == player:GetUniqueDimension() then 
				ExitLocalDimension( player )
			end
			
			if player.interior ~= 0 or (isElementWithinColShape( player, WEST_CARTEL_ZONE ) and not player.dead) then
				removePedFromVehicle( player )
				player.interior = 0
				player.position = Vector3( -1940.3150, 681.3649, 18.7260 )
			end
		end
	},

	tasks = {

		{
			name = "Отправляйся на встречу",

			Setup = {
				client = function( )
					GEs.handlers = {}

					CreateMarkerToCutsceneNPC( {
						id = "west_cartel_guard",
						dialog = QUEST_CONF.dialogs.start,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "west_cartel_guard" ).ped, nil, true )

							local t = {}

							t.NextDialog = function()
								CEs.dialog:next( )
								setTimerDialog( t.EndDialog, 9000 )
							end

							t.EndDialog = function()
								triggerEvent( "SwitchRadioEnabled", root, false )
								triggerServerEvent( "protection_step_1", localPlayer )
							end

							setTimerDialog( t.NextDialog, 7000 )
						end
					} )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( FindQuestNPC( "west_cartel_guard" ).ped )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "protection_step_1",
		},

		{
			name = "Зайди в здание картеля",

			Setup = {
				client = function( )
					HideNPCs( )

					local positions = QUEST_CONF.positions

					GEs.guard_bot = CreateAIPed( 259, positions.guard_spawn.pos, positions.guard_spawn.rot )
					givePedWeapon( GEs.guard_bot, 29, 1000, true )
					setPedStat( GEs.guard_bot, 76, 1000 )
					setPedStat( GEs.guard_bot, 22, 1000 )

					LocalizeQuestElement( GEs.guard_bot )
					SetUndamagable( GEs.guard_bot, true )

					local t = {}

					t.OnAttackPed = function()
						if t.on_attack_trigger then return end
						CEs.timer = setTimer( function()
							localPlayer.health = math.max(0, localPlayer.health - 15)
						end, 500, 0 )
						t.on_attack_trigger = true
						for k, v in pairs( GEs.west_guards ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_ATTACK_PED, {
								target_ped = localPlayer;
							} )
						end

						GEs.follow:destroy( )
						AddAIPedPatternInQueue( GEs.guard_bot, AI_PED_PATTERN_ATTACK_PED, {
							target_ped = localPlayer;
						} )
					end

					t.CreateWestCartelGuard = function()
						GEs.west_guards = {}

						for _, guard_data in pairs( { { positions.west_guards, 0 }, { positions.west_guards_interior, 1 } } ) do
							for k, v in pairs( guard_data[ 1 ] ) do
								local ped = CreateAIPed( math.random( 0, 1 ) == 1 and 257 or 258, v.pos, v.rot )
								addEventHandler( "onClientPedDamage", ped, t.OnAttackPed )

								ped.interior = guard_data[ 2 ]
								ped.dimension = localPlayer.dimension
								SetUndamagable( ped, true )
	
								givePedWeapon( ped, 29, 1000, true )
								setPedStat( ped, 76, 1000 )
								setPedStat( ped, 22, 1000 )

								table.insert( GEs.west_guards, ped )
							end
						end
					end
					t.CreateWestCartelGuard()

					t.CreateStaticObjects = function()
						GEs.dummy_veh_west = createVehicle( 415, Vector3( -1947.5682, 656.4798, 18.1279 ), Vector3( 0, 0, 10 ) )
						GEs.dummy_veh_west:setColor( 0, 0, 0 )
						GEs.dummy_veh_west:SetNumberPlate( "1:o777oo077" )
						GEs.dummy_veh_west:SetWindowsColor( 0, 0, 0, 255 )
						LocalizeQuestElement( GEs.dummy_veh_west  )
					end
					t.CreateStaticObjects()
					
					t.CreateGates = function()
						CreateGates( positions )
						CEs.timer = setTimer( GEs.OpenGate, 300, 1 )

						CEs.colshape_close_gate = createColPolygon( -1950, 628, -1962, 694, -1974, 691, -1962, 625, -1950, 628 )
						CEs.OnHit = function( element )
							if element == localPlayer and GEs.gate_state then
								destroyElement( CEs.colshape_close_gate )
								GEs.CloseGate()
							end
						end
						addEventHandler( "onClientColShapeHit", CEs.colshape_close_gate, CEs.OnHit )
					end
					t.CreateGates()

					t.CreateCloseMan = function()
						GEs.close_man = CreateAIPed( 260, positions.close_man_spawn.pos, positions.close_man_spawn.rot )
						
						GEs.close_man.interior = 1
						GEs.close_man.dimension = localPlayer.dimension

						SetUndamagable( GEs.close_man, true )
					end
					t.CreateCloseMan()
					
					CreateQuestPoint( positions.outer_kartel_house_position.pos, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 0.5 )

						CEs.timer = setTimer( function()
							GEs.follow:destroy( )
							
							triggerServerEvent( "protection_step_2", localPlayer )
						end, 500, 1 )						
					end, _, 1, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Покинь транспортное средство"
						end
						return true
					end )	

					LocalizeQuestElement( GEs.guard_bot )
					
					GEs.follow = CreatePedFollow( GEs.guard_bot )
					GEs.follow:start( localPlayer )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				server = function( player )
					
				end
			},

			event_end_name = "protection_step_2",
		},

		{
			name = "Поговори с приближенным",

			Setup = {
				client = function( )
					fadeCamera( true, 0.5 )
					
					local positions = QUEST_CONF.positions

					GEs.guard_bot.position = positions.guard_spawn.pos
					GEs.guard_bot.rotation = Vector3( 0, 0, positions.guard_spawn.rot )

					localPlayer.interior = 1
					localPlayer.position = positions.inner_kartel_house_position.pos
					localPlayer.rotation = positions.inner_kartel_house_position.rot

					CreateQuestPoint( positions.close_man_dialog_position.pos, function( self, player )
						CEs.marker.destroy( )

						local t = { }
						
						t.OnStartDialog = function()
							localPlayer.position = positions.close_man_dialog_position.pos
							localPlayer.rotation = positions.close_man_dialog_position.rot

							setCameraMatrix( unpack( positions.close_man_dialog_matrix ) )
							StartQuestCutscene( { dialog = QUEST_CONF.dialogs.cartel } )
							StartPedTalk( GEs.close_man, nil, true )
							CEs.dialog:next( )
							
							setTimerDialog( t.NextDialog, 13000 )
						end

						t.NextDialog = function()
							CEs.dialog:next( )
							setTimerDialog( t.OnEndDialog, 14000 )
						end

						t.OnEndDialog = function()
							FinishQuestCutscene( )
							setCameraMatrix( unpack( positions.close_man_dialog_matrix ) )

							CreateAIPed( localPlayer )
							for k, v in pairs( { GEs.close_man, localPlayer } ) do
								
								SetAIPedMoveByRoute( v, {
									{ x = 439.45626831055, y = -1201.4503173828, z = 1099.0474853516, move_type = 4 },
								}, false )
							end							
							CEs.timer = setTimer( t.FadeCamera, 2000, 1 )
						end

						t.FadeCamera = function()
							fadeCamera( false, 2.0 )
							CEs.timer = setTimer( t.OnEndScene, 2000, 1 )
						end

						t.OnEndScene = function()
							for k, v in pairs( { GEs.guard_bot, GEs.close_man, localPlayer } ) do
								ResetAIPedPattern( v )
							end

							triggerServerEvent( "protection_step_3", localPlayer ) 
						end
						
						t.OnStartDialog()
					end, _, 1, 1 )
				end,
				server = function( player )
					player.interior = 1
					
					local vehicle = CreateTemporaryVehicle( player, 6527, QUEST_CONF.positions.western_cartel_veh_1_spawn.pos, QUEST_CONF.positions.western_cartel_veh_1_spawn.rot )
					vehicle:SetColor( 0, 0, 0 )
					vehicle:SetNumberPlate( "1:o111oo011" )
					vehicle:SetWindowsColor( 0, 0, 0, 255 )

					player:SetPrivateData( "temp_vehicle", vehicle )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if failed then FinishQuestCutscene( ) end
				end,
			},

			event_end_name = "protection_step_3",
		},

		{
			name = "Отправляйся на встречу",

			Setup = {
				client = function( )
					EnableCheckQuestDimension( true )
					
					local positions = QUEST_CONF.positions
					localPlayer.interior = 0

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					AddCheckVehicleCondition( temp_vehicle )

					local t = { }

					t.CreateFriendBots = function()
						GEs.friend_bot_vehicle = createVehicle( 6527, positions.western_cartel_veh_2_spawn.pos, positions.western_cartel_veh_2_spawn.rot )
						GEs.friend_bot_vehicle:SetWindowsColor( 0, 0, 0, 255 )
						AddCheckVehicleCondition( GEs.friend_bot_vehicle )

						LocalizeQuestElement( GEs.friend_bot_vehicle )
						GEs.friend_bot_vehicle:SetColor( 0, 0, 0 )
						GEs.friend_bot_vehicle:SetNumberPlate( "1:o666oo099" )

						GEs.friend_bots = {}
						for i = 1, 7 do
							local friend_bot = CreateAIPed( 257, Vector3( 0, 0, 0 ) )
							LocalizeQuestElement( friend_bot  )
							SetUndamagable( friend_bot, true )
							
							local target_vehicle = i > 3 and GEs.friend_bot_vehicle or temp_vehicle
							warpPedIntoVehicle( friend_bot, target_vehicle, target_vehicle == temp_vehicle and i or i - 4 )
							
							givePedWeapon( friend_bot, 29, 1000, true )
							setPedStat( friend_bot, 76, 1000 )
							setPedStat( friend_bot, 22, 1000 )
							table.insert( GEs.friend_bots, friend_bot )
						end
					end
					
					t.CreateEnemyBots = function()
						GEs.east_cartel_veh_1 = createVehicle( 445, positions.east_cartel_veh_1_spawn.pos, positions.east_cartel_veh_1_spawn.rot )
						GEs.east_cartel_veh_1:SetWindowsColor( 0, 0, 0, 255 )
						LocalizeQuestElement( GEs.east_cartel_veh_1 )
						GEs.east_cartel_veh_1:SetColor( 0, 0, 0 )
						GEs.east_cartel_veh_1:SetNumberPlate( "1:o227oo001" )

						GEs.enemy_bots = {}
						for k, v in pairs( positions.members_east_1_spawns ) do
							local enemy_bot = CreateAIPed( math.random( 0, 1 ) == 1 and 21 or 22, v.pos, v.rot )
							LocalizeQuestElement( enemy_bot )
							givePedWeapon( enemy_bot, 29, 1000, true )
							setPedStat( enemy_bot, 76, 1000 )
							setPedStat( enemy_bot, 22, 1000 )
							table.insert( GEs.enemy_bots, enemy_bot )
						end
					end
					
					t.OpenGate = function()
						GEs.OpenGate()
						GEs.ChangeCanOpenGate( false )
						CEs.open_door_tmr = setTimer( function()
							SetAIPedMoveByRoute( GEs.friend_bot_vehicle.occupants[ 0 ], positions.bandit_path_to_huckster, false )
						end, 1000, 1 )

						fadeCamera( true, 1 )
					end
								
					CreateQuestPoint( positions.west_cartel_huckster.pos, function( self, player )
						FadeBlink()
						CEs.marker.destroy( )

						for k, v in pairs( { temp_vehicle, GEs.friend_bot_vehicle } ) do
							v.locked =  true
							v.frozen =  true
						end
						CEs.timer_frozen = setTimer( setElementFrozen, 150, 1, GEs.friend_bot_vehicle, false )
						GEs.friend_bot_vehicle.locked = false

						local end_position = positions.bandit_path_to_huckster[ #positions.bandit_path_to_huckster ]
						GEs.friend_bot_vehicle.position = Vector3( end_position.x, end_position.y, end_position.z )
						
						for i, v in pairs( GEs.friend_bots ) do
							CleanupAIPedPatternQueue( v )
							removePedTask( v )
							ResetAIPedPattern( v )

							AddExitVehiclePattern( v )
						end

						CreateAIPed( localPlayer )
						AddExitVehiclePattern( localPlayer )
						
						CEs.timer = setTimer( triggerServerEvent, 1800, 1, "protection_step_4", localPlayer )
					end,  _, 5, _, _, function( self, player )
						if not localPlayer.vehicle then
							return false, "Один будешь кипишь вывозить?"
						end
						return true
					end )

					t.CreateFriendBots()
					t.CreateEnemyBots()
					
					CEs.open_gate_tmr = setTimer( t.OpenGate, 200, 1 )
				end,
				server = function( player )
					player.interior = 0

					local vehicle = GetTemporaryVehicle( player )
					warpPedIntoVehicle( player, vehicle )
					setCameraTarget( player, player )

					player:GiveWeapon( 29, 1000, false, true )
				end,
			},

			CleanUp = {
				server = function( player )
					
				end
			},

			event_end_name = "protection_step_4",
		},

		{
			name = "Расправься с бойцами восточного картеля",

			Setup = {
				client = function( )
					InitAttackedInterface( "protection_step_5", 4 )

					local positions = QUEST_CONF.positions

					GEs.start_attack = false
					local StartEnemyAttack = function()
						if GEs.start_attack then return end
						GEs.start_attack = true

						for k, v in pairs( GEs.enemy_bots ) do
							SetAIPedMoveByRoute( v, { positions.enemy_bots_1_attack_path[ k ] }, false, function()
								GEs.interface_attacked.attackEnemy( v, GEs.friend_targets )	
							end )
						end
					end

					for k, v in pairs( GEs.friend_bots ) do
						SetUndamagable( v, false )

						SetAIPedMoveByRoute( v, positions.friend_bots_1_attack_path[ k ], false, function()
							if not GEs.start_attack then StartEnemyAttack() end
							if not GEs.interface_attacked then return end
							GEs.interface_attacked.attackEnemy( v, GEs.enemy_targets )	
						end )
					end
							
					CreateQuestPoint( positions.east_attack_point.pos, function( self, player )
						CEs.marker.destroy()
						StartEnemyAttack()
					end, _, 20 )

				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					DestroyAttackedInterface()
				end,
				server = function( player )

				end
			},

			event_end_name = "protection_step_5",
		},

		{
			name = "Спрячь трупы",

			Setup = {
				client = function( )
					destroyElement( GEs.east_cartel_veh_1 )

					local positions = QUEST_CONF.positions
					CEs.timers = { }

					local t = { }
					t.hide_corpses = 0
	
					t.HideCorpse = function( ped, corpse )
						setPedAnimation( ped, "bomber", "bom_plant_loop", 2000, true, false, false, false )
						if not CEs.timers then return end
						CEs.timers[ ped ] = setTimer( function()
							t.hide_corpses = t.hide_corpses + 1
							destroyElement( corpse )
							t.CheckCorpses()
						end, 2000, 1 )
					end

					t.CheckCorpses = function()
						if t.hide_corpses == 4 then
							GEs.enemy_bots = {}
							triggerServerEvent( "protection_step_6", localPlayer )
						end
					end

					GEs.DestroyFriendsBots = function()
						if isElement( GEs.friend_bot_vehicle ) then
							for k, v in pairs( GEs.friend_bot_vehicle.occupants ) do
								ResetAIPedPattern( v )
								destroyElement( v )
							end
							for k, v in pairs( GEs.leave_bots ) do
								if isElement( v ) then
									destroyElement( v )
								end
							end
							destroyElement( GEs.friend_bot_vehicle )
						end
					end

					
					t.GetCountOccupantsVehicle = function( vehicle )
						local counter = 0
						for k, v in pairs( vehicle.occupants ) do
							counter = counter + 1
						end
						return counter
					end

					CEs.seat = 0
					GEs.leave_bots = {}
					t.LeaveFriendsBotOnVehicle = function( v )
						ResetAIPedPattern( v )
						SetUndamagable( v, true )

						SetAIPedMoveByRoute( v, { { x = -1415.5688476563, y = 185.68835449219, z = 18.997037887573 } }, false, function()
							CleanupAIPedPatternQueue( v )
							removePedTask( v )
							ResetAIPedPattern( v )
							
							AddEnterVehiclePattern( v, GEs.friend_bot_vehicle, CEs.seat, function()
								if GEs.count_leave_bots == t.GetCountOccupantsVehicle( GEs.friend_bot_vehicle ) then
									SetAIPedMoveByRoute( GEs.friend_bot_vehicle.occupants[ 0 ], positions.leave_friends_vehicle_path, false, function()
										GEs.DestroyFriendsBots()
									end )
								end
							end )

							table.insert( GEs.leave_bots, v )
							CEs.seat = CEs.seat + 1 
						end )
					end

					local alive_friends_bots = table.copy( GEs.friend_bots  )

					GEs.count_leave_bots = 0
					GEs.friend_bots = {}
					for k, v in pairs( alive_friends_bots ) do
						SetUndamagable( v, true )
						if not v.dead then							
							if #GEs.friend_bots >= 3 then
								t.LeaveFriendsBotOnVehicle( v )
								GEs.count_leave_bots = GEs.count_leave_bots + 1
							else
								table.insert( GEs.friend_bots, v )
							end
						else
							destroyElement( v )
						end
					end

					-- Игрок убирает только часть трупов, при живых ботах
					local count_alive_bots = #GEs.friend_bots
					for i = 1, 4 - count_alive_bots do
						CreateQuestPoint( GEs.enemy_bots[ i ].position, function( self, player )
							CEs[ i .. "marker" ].destroy( )
							t.HideCorpse( localPlayer, GEs.enemy_bots[ i ] )
						end, i .. "marker", 1 )
					end

					-- Если количество мертвых ботов > 0, то убираем часть трупов
					if count_alive_bots > 0 then
						CEs.timer_hide = {}
						for i = (4 - count_alive_bots) + 1, count_alive_bots + 1 do

							local cur_friend_bot = GEs.friend_bots[ i - 1 ]
							local end_position = GEs.enemy_bots[ i ].position

							local callback_func = function()
								if cur_friend_bot:getData( "hide" ) then return end
								cur_friend_bot:setData( "hide", true, false )

								if isTimer( CEs.timer_hide[ cur_friend_bot ] ) then
									killTimer( CEs.timer_hide[ cur_friend_bot ] )
								end

								cur_friend_bot.position = end_position
								CEs.timer_hide[ cur_friend_bot ] = setTimer( function()
									t.HideCorpse( cur_friend_bot, GEs.enemy_bots[ i ] )
								end, 150, 1 )
							end
							
							SetAIPedMoveByRoute( cur_friend_bot, positions.hide_corpses_path, false, function()
								SetAIPedMoveByRoute( cur_friend_bot, { { x = end_position.x, y = end_position.y, z = end_position.z, move_type = 7 }, }, false, callback_func )
							end )

							CEs.timer_hide[ cur_friend_bot ] = setTimer( callback_func, 14000, 1 )
						end
					end
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					DestroyTemporaryVehicle( player, vehicle )

					local vehicle = CreateTemporaryVehicle( player, 445, QUEST_CONF.positions.east_cartel_veh_1_spawn.pos, QUEST_CONF.positions.east_cartel_veh_1_spawn.rot )
					vehicle:SetColor( 0, 0, 0 )
					vehicle:SetNumberPlate( "1:o333oo077" )
					vehicle:SetWindowsColor( 0, 0, 0, 255 )
					vehicle.frozen = true
					vehicle.locked = true

					player:SetPrivateData( "temp_vehicle", vehicle )
					
					GEs.cancel_dmg = function()
						cancelEvent()
					end
					addEventHandler( "onVehicleDamage", vehicle, GEs.cancel_dmg )
				end,
			},

			CleanUp = {
				server = function( player )

				end
			},

			event_end_name = "protection_step_6",
		},

		{
			name = "Садись в машину восточного картеля",

			Setup = {
				client = function( )

					if isElement( GEs.friend_bot_vehicle ) then
						GEs.DestroyFriendsBots()
					end

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					temp_vehicle.frozen = true

					AddCheckVehicleCondition( temp_vehicle )
					
					CEs.handlers = {}
					CEs.handlers.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							localPlayer:ShowError( "Садись на водительское место" )
							cancelEvent( )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, CEs.handlers.OnStartEnter )
					
					CEs.handlers.CheckAllTargetsInVehicle = function()
						if not localPlayer.vehicle then return end

						for k, v in pairs( GEs.friend_bots ) do
							if not v.vehicle then return end
						end
						
						fadeCamera( false, 0.5 )
						toggleControl( "enter_exit", false )
						CEs.timer = setTimer( function()
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, CEs.handlers.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )
							triggerServerEvent( "protection_step_7", localPlayer )
						end, 500, 1 )
					end

					GEs.BlockExit = function( player )
						cancelEvent()
					end

					GEs.handlers.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CEs.hint:destroy()

						addEventHandler( "onClientVehicleStartExit", temp_vehicle, GEs.BlockExit )
						CEs.handlers.CheckAllTargetsInVehicle()
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )

					for k, v in pairs( GEs.friend_bots ) do
						AddEnterVehiclePattern( v, temp_vehicle, k, CEs.handlers.CheckAllTargetsInVehicle )
					end

					CreateQuestPoint( QUEST_CONF.positions.east_cartel_veh_1_spawn.pos, function( self, player )
						CEs.marker.destroy( )
					end,  _, 5 )
					CreateEnterVehicleHint()
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.locked = false
				end,
			},

			CleanUp = {
				client = function()
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )
				end,
				server = function( player )

				end
			},

			event_end_name = "protection_step_7",
		},

		{
			name = "Бандиты...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					local t = {}

					t.CreateEastMembmers = function()
						GEs.east_vehs = {}
						GEs.enemy_bots = {}
						
						for k, v in pairs( positions.east_cartel_veh_2_spawn ) do
							GEs.east_vehs[ k ] = createVehicle( 445, v.pos, v.rot )
							GEs.east_vehs[ k ]:SetWindowsColor( 0, 0, 0, 255 )
							LocalizeQuestElement( GEs.east_vehs[ k ]  )
							GEs.east_vehs[ k ]:setColor( 0, 0, 0 )
							GEs.east_vehs[ k ]:SetNumberPlate( "1:o" .. math.random(111, 999) .. "oo077" )
						
							for i = 1, 4 do
								local enemy_bot = CreateAIPed( math.random( 0, 1 ) == 1 and 21 or 22, Vector3( 0, 0, 0 ), 0 )
								warpPedIntoVehicle( enemy_bot, GEs.east_vehs[ k ], i - 1 )
							
								LocalizeQuestElement( enemy_bot  )
								givePedWeapon( enemy_bot, 29, 1000, true )
								setPedStat( enemy_bot, 76, 1000 )
								setPedStat( enemy_bot, 22, 1000 )
							end
						end
					end
					t.CreateEastMembmers()

					t.setPedRotationToTarget = function( ped, target )
						setElementRotation( ped, 0,  0, FindRotation( ped.position.x, ped.position.y, target.x, target.y ) )
					end

					t.StartMoveEastMembmers = function()
						StartQuestCutscene()

						local path_id = 1
						GEs.path_id = {}
						for vehicle_id, vehicle in pairs( GEs.east_vehs ) do
							GEs.path_id[ vehicle ] = path_id

							SetAIPedMoveByRoute( vehicle.occupants[ 0 ], positions.east_cartel_veh_2_path[ vehicle_id ], false, function()
								vehicle.frozen = true
								for k, v in pairs( vehicle.occupants ) do
									if vehicle_id == 1 and k == 0 then
										setPedWeaponSlot( v, 0 )
										vehicle.frozen = false
										GEs.east_leave_member = v
										SetUndamagable( v, false )
									else
										AddExitVehiclePattern( v, function()
											SetAIPedMoveByRoute( v, { positions.enemy_bots_2_talk_path[ k * GEs.path_id[ vehicle ] ] }, false, function()
												t.setPedRotationToTarget( v, positions.enemy_bots_center_talk.pos )
												StartPedTalk( v, _, true )
											end )
										end )
										table.insert( GEs.enemy_bots, v )
									end
								end
							end )
							path_id = path_id + 9
						end

						CEs.camera_move = CameraFromTo( positions.camera_east_cartel_veh_move_1.from, positions.camera_east_cartel_veh_move_1.to, 7000, "Linear" )
						CEs.timer = setTimer( t.StartMove2Camera, 7000, 1 )
					end

					t.StartMove2Camera = function()
						CEs.camera_move = CameraFromTo( positions.camera_east_cartel_veh_move_2.from, positions.camera_east_cartel_veh_move_2.to, 5000, "Linear" )
						CEs.timer = setTimer( t.OnEndStep, 5000, 1 )
					end

					t.OnEndStep = function()
						triggerServerEvent( "protection_step_8", localPlayer )
					end

					CEs.timer = setTimer( t.StartMoveEastMembmers, 500, 1 )
				end,
				server = function( player )
					local vehicle = player:getData( "temp_vehicle" )
					if vehicle then
						vehicle.frozen = true
					end
				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
				end,
				server = function( player )
					
				end
			},

			event_end_name = "protection_step_8",
		},

		{
			name = "Расправься с бойцами восточного картеля",

			Setup = {
				client = function( )
					localPlayer.health = 100
					toggleControl( "enter_exit", true )

					InitAttackedInterface( "protection_step_9", 7 )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					removeEventHandler( "onClientVehicleStartExit", temp_vehicle, GEs.BlockExit )

					local t = {}
					local positions = QUEST_CONF.positions

					t.StartEnemyBotAttack = function()
						for k, v in pairs( GEs.enemy_bots ) do
							StopPedTalk( v )
							GEs.interface_attacked.attackEnemy( v, GEs.friend_targets )	
						end
					end

					GEs.handlers.OnStartExitVehicle = function()
						removeEventHandler( "onClientVehicleStartExit", temp_vehicle, GEs.handlers.OnStartExitVehicle )
						CEs.timer = setTimer( t.StartEnemyBotAttack, 1500, 1 )

						for k, v in pairs( GEs.friend_bots ) do
							v.health = 100
							SetUndamagable( v, false )

							local seat = getPedOccupiedVehicleSeat( v )
							AddExitVehiclePattern( v, function()
								SetAIPedMoveByRoute( v, { positions.friend_bots_2_attack_path[ seat ] }, false, function()
									GEs.interface_attacked.attackEnemy( v, GEs.enemy_targets )	
								end )
							end )
						end
					end
					addEventHandler( "onClientVehicleStartExit", temp_vehicle, GEs.handlers.OnStartExitVehicle )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					DestroyAttackedInterface()
				end,
				server = function( player )

				end
			},

			event_end_name = "protection_step_9",
		},

		{
			name = "Побег...",

			Setup = {
				client = function( )
					StartQuestCutscene()
					localPlayer.position = Vector3( -1368.4221, 218.2139, 18.9833 )
					
					CreateAIPed( localPlayer )
					AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_ATTACK_PED, {
						target_ped = GEs.east_leave_member;
					} )

					for k, v in pairs( GEs.friend_bots ) do
						AddAIPedPatternInQueue( v, AI_PED_PATTERN_ATTACK_PED, {
							target_ped = GEs.east_leave_member;
						} )
					end

					local positions = QUEST_CONF.positions
					setCameraMatrix( unpack( positions.laeve_camera_matrix ) )
					SetAIPedMoveByRoute( GEs.east_leave_member, positions.leave_enemy_path, false )

					CEs.timer_end = setTimer( function()
						fadeCamera( false, 0.5 )
						CEs.timer_end = setTimer( function()
							ResetAIPedPattern( localPlayer )
							for k, v in pairs( GEs.friend_bots ) do
								ResetAIPedPattern( v )
							end

							ResetAIPedPattern( GEs.east_leave_member )
							destroyElement( GEs.east_leave_member.vehicle )
							destroyElement( GEs.east_leave_member )

							triggerServerEvent( "protection_step_10", localPlayer )
						end, 500, 1 )
					end, 7000, 1 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					FinishQuestCutscene( )
				end,
				server = function( player )

				end
			},

			event_end_name = "protection_step_10",
		},

		{
			name = "Садись в машину восточного картеля",

			Setup = {
				client = function( )
					fadeCamera( true, 0.5 )					
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					local handlers = {}
					handlers.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							localPlayer:ShowError( "Садись на водительское место" )
							cancelEvent( )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
					
					handlers.CheckAllTargetsInVehicle = function()
						if not localPlayer.vehicle then return end

						for k, v in pairs( GEs.friend_bots ) do
							if not v.dead and not v.vehicle then return end
						end
						
						CEs.timer = setTimer( function()
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )
							triggerServerEvent( "protection_step_11", localPlayer )
						end, 500, 1 )
					end

					GEs.handlers.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CEs.hint:destroy()

						handlers.CheckAllTargetsInVehicle()
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )

					for k, v in pairs( GEs.friend_bots ) do
						AddEnterVehiclePattern( v, temp_vehicle, k, handlers.CheckAllTargetsInVehicle )
					end

					CreateQuestPoint( QUEST_CONF.positions.east_cartel_veh_1_spawn.pos, function( self, player )
						CEs.marker.destroy( )
					end,  _, 5 )
					CreateEnterVehicleHint()
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )
				end,
				server = function( player )

				end
			},

			event_end_name = "protection_step_11",
		},

		{
			name = "Отправляйся в западный картель",

			Setup = {
				client = function( )
					GEs.ChangeCanOpenGate( true )

					local positions = QUEST_CONF.positions

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					temp_vehicle.frozen = false
					
					GEs.close_man.interior = 0
					GEs.close_man.position = positions.close_man_outer.pos
					GEs.close_man.rotation = Vector3( 0, 0, positions.close_man_outer.rot.z )

					CreateQuestPoint( positions.cartel_finish.pos, function( self, player )
						CEs.marker.destroy( )

						localPlayer.vehicle.frozen = true
						localPlayer.vehicle.engineState = false
						localPlayer:ShowError( "Покиньте транспорт, чтобы продолжить" )
						
						GEs.handlers.OnExit = function( player, seat )
							removeEventHandler( "onClientPlayerVehicleExit", localPlayer, GEs.handlers.OnExit )
							triggerServerEvent( "protection_step_12", localPlayer )
						end
						addEventHandler( "onClientPlayerVehicleExit", localPlayer, GEs.handlers.OnExit )

						for k, v in pairs( GEs.friend_bots ) do
							AddExitVehiclePattern( v, function()
								SetAIPedMoveByRoute( v, positions.cartel_path_to_house, false, function()
									destroyElement( v )
								end )
							end )
						end
					end, _, _, _, _, function( )
						if localPlayer.vehicle ~= temp_vehicle then
							return false, "Вернись за машиной картеля"
						end
						return true
					end )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.frozen = false
				end,
			},

			CleanUp = {
				client = function()
					if GEs.handlers.OnExit then
						removeEventHandler( "onClientPlayerVehicleExit", localPlayer, GEs.handlers.OnExit )
					end
				end,
			},

			event_end_name = "protection_step_12",
		},

		{
			name = "Поговори с приближенным",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.close_man_outer_dialog_position.pos, function( self, player )
						CEs.marker.destroy( )

						setCameraMatrix( unpack( positions.close_man_outer_dialog_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.finish } )
						
						StartPedTalk( GEs.close_man, nil, true )
						localPlayer.position = positions.close_man_outer_dialog_position.pos
						localPlayer.rotation = positions.close_man_outer_dialog_position.rot

						CEs.dialog:next( )

						setTimerDialog( function() 
							triggerServerEvent( "protection_step_13", localPlayer )
						end, 11500 )
					end, _, 1, _, _, function( self, player )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта чтобы начать диалог"
						end
						return true
					end )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.frozen = true
					vehicle.locked = true
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.close_man )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "protection_step_13",
		},

		{
			name = "Покинь картель",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.finish_mission_point.pos, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "protection_step_14", localPlayer )					
					end, _, 1, _, _ )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				server = function( player )

				end
			},

			event_end_name = "protection_step_14",
		},

	},

	GiveReward = function( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )

		player:SituationalPhoneNotification(
			{ title = "Анжела", msg = "Привет, мне нужна твоя помощь, забери мою сотрудницу и привези её ко мне. Срочно!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "angela_problems" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)
	end,

	rewards = {
		money = 4000,
		exp = 3000,
	},
	no_show_rewards = true,
}
