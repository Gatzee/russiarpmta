QUEST_CONF = {
	dialogs = {
		roman_start = {
			{ name = "Роман", voice_line = "Roman_murderous_setup_03", text = [[Привет! Сегодня придется пострелять.
Держи автомат и прыгай в тачку. Сейчас проходит праздник у восточных "шакалов".
Их нужно перебить как свиней. Погнали!]] },
		},
		roman_finish = {

			{ name = "Роман", voice_line = "Roman_murderous_setup_04", text = [[Дааа!!! Мы сделали это! Прошло все четко по плану!
Теперь эти имбецилы друг друга съедят! Долг твой оплачен. 
Будет работа, под твои навыки, наберу!]] },
		},
	},

	positions = {
		armor_veh_spawn = { pos = Vector3( 553.1550, -516.6599, 20.9968 ), rot = Vector3( 0, 0, 0 ) },

		start_attack = { pos = Vector3( 230.55, -1346.23, 19.6 ) },
		center_attack = Vector3( 113.4559, -1352.3771, 20.80 ),

		close_man_spawn = { pos = Vector3( 107.97, -1353.3, 20.81 ), rot = Vector3( 0, 0, 0 ) },

		east_cartel_bot_spawns =
		{
			{ pos = Vector3( 108.8675, -1349.8728, 20.8076 ), rot = Vector3( 0, 0, 4 ),   id = 21 },
			{ pos = Vector3( 100.5347, -1341.9591, 20.5967 ), rot = Vector3( 0, 0, 322 ), id = 22 },
			{ pos = Vector3( 117.5324, -1347.0068, 20.5967 ), rot = Vector3( 0, 0, 17 ),  id = 21 },
			{ pos = Vector3( 117.6560, -1343.7088, 20.5967 ), rot = Vector3( 0, 0, 166 ), id = 23 },
			{ pos = Vector3( 112.8656, -1350.0135, 20.8076 ), rot = Vector3( 0, 0, 354 ), id = 22 },
		},
		east_cartel_veh_spawns =
		{
			{ pos = Vector3( 122.3989, -1345.0678, 20.5967 ), rot = Vector3( 0, 0, 150 ) },
			{ pos = Vector3( 100.5158, -1345.0393, 20.5967 ), rot = Vector3( 0, 0, 215 ) },
		},

		hide_away = { pos = Vector3( 489.7728, -1216.7196, 20.6588 ) },

		roman_veh_spawn = { pos = Vector3( 1263.3436, -1155.8117, 11.8841 ), rot = Vector3( 0, 0, 103 ) },
		
		destroy_veh = { pos = Vector3( 1278.7539, -1158.5476, 11.7909 ), rot = Vector3( 0, 0, 235 ) },
		
		blow_matrix = { 1243.6081542969, -1168.1159667969, 19.06395149231, 1329.5435791016, -1134.9499511719, -19.860412597656, 0, 70 },
		blow_veh_path = 
		{
			{ x = 1257.2061767578, y = -1160.3702392578, z = 11.773348808289 },
			{ x = 1246.3592529297, y = -1171.2563476563, z = 11.972466468811 },
			{ x = 1234.3607177734, y = -1181.7625732422, z = 13.899678230286 },
		},

		pps_bot_spawns =
		{
			{ pos = Vector3( 429.0830, -1218.1967, 20.5956 ), rot = Vector3( 0, 0, 265 ), id = 125 },
			{ pos = Vector3( 428.7686, -1215.4296, 20.5918 ), rot = Vector3( 0, 0, 265 ), id = 125 },
			{ pos = Vector3( 449.4387, -1231.9617, 20.5918 ), rot = Vector3( 0, 0, 0 ),   id = 125 },
			{ pos = Vector3( 446.8167, -1231.8620, 20.5956 ), rot = Vector3( 0, 0, 0 ),   id = 125 },
		},

		pps_veh_spawns = 
		{
			{ pos = Vector3( 453.3502, -1231.7829, 20.3939 ), rot = Vector3( 0, 0, 67  ) },
			{ pos = Vector3( 442.5213, -1231.1960, 20.3941 ), rot = Vector3( 0, 0, 125 ) },
			{ pos = Vector3( 430.4119, -1222.0644, 20.3931 ), rot = Vector3( 0, 0, 32  ) },
			{ pos = Vector3( 429.8648, -1211.7440, 20.3894 ), rot = Vector3( 0, 0, 326 ) },
		},

		finish_veh_parking = { pos = Vector3( 551.21, -522.42, 20.93 ) },

		roman_finish_path = {
			{ x = 550.5914, y = -519.9331, z = 20.9336 },
			{ x = 550.9904, y = -517.0303, z = 20.9336 },
			{ x = 552.0971, y = -516.3531, z = 20.9336 },
		},

		finish_talk_matrix = { 553.38909912109, -517.71405029297, 21.96117401123, 483.99856567383, -450.69155883789, -4.3625588417053, 0, 70 },
		finish_talk_roman  = { pos = Vector3( 552.0971, -516.3531, 20.9336 ), rot = Vector3( 0, 0, 226 ) },
		finish_talk_player = { pos = Vector3( 552.6202, -516.7187, 20.9336 ), rot = Vector3( 0, 0, 55 ) },
	},
}

GEs = { }

QUEST_DATA = {
	id = "murderous_setup",
	is_company_quest = true,

	title = "Убийственная подстава",
	description = "Опять... но лучше по-хорошему, чем по-плохому. Пока точно не стоит портить с Романом отношения.",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 556.4246, -496.3263, 20.9102 ),

	quests_request = { "good_game" },
	level_request = 18,

	OnAnyFinish = {
		client = function()
			toggleControl( "enter_exit", true )
			fadeCamera( true, 0.5 )
			DestroyFollowHandlers()

			if localPlayer:getData( "not_close_cutscene" ) then
				FinishQuestCutscene()
				localPlayer:setData( "not_close_cutscene", false, false )
			end
		end,
		server = function( player, reason, reason_data )
			DestroyAllTemporaryVehicles( player )

            player:TakeAllWeapons( true )
			ExitLocalDimension( player )
		end
	},

	tasks = {
		{
			name = "Встреться с Романом",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "roman_near_house",
						dialog = QUEST_CONF.dialogs.roman_start,
						radius = 1,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )

							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "roman_near_house" ).ped, nil, true )

							setTimerDialog( function()
								triggerServerEvent( "murderous_setup_step_1", localPlayer )
							end, 11200 )
						end
					} )
				end,
				server = function( player )
					local vehicle = CreateTemporaryVehicle( player, 6527, QUEST_CONF.positions.armor_veh_spawn.pos, QUEST_CONF.positions.armor_veh_spawn.rot )
					vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )
					vehicle:SetWindowsColor( 0, 0, 0, 255 )
					vehicle:SetColor( 0, 0, 0 )			

					player:SetPrivateData( "temp_vehicle", vehicle )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( FindQuestNPC( "roman_near_house" ).ped )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "murderous_setup_step_1",
		},

		{
			name = "Садись в машину",

			Setup = {
				client = function( )
					HideNPCs()
					EnableCheckQuestDimension( true )

					local positions = QUEST_CONF.positions
					
					local fake_npc_roman = FindQuestNPC( "roman_near_house" )
					GEs.roman_bot = CreateAIPed( fake_npc_roman.model, fake_npc_roman.position, fake_npc_roman.rotation )
					LocalizeQuestElement( GEs.roman_bot )
					SetUndamagable( GEs.roman_bot, true )
					setPedStat( GEs.roman_bot, 76, 1000 )
					setPedStat( GEs.roman_bot, 22, 1000 )
					givePedWeapon( GEs.roman_bot, 29, 3000, true )

					CreateFollowHandlers( { GEs.roman_bot } )
					GEs.check_roman_dist = setTimer( function()
						local distance = (localPlayer.position - GEs.roman_bot.position).length
						if distance > 150 then
							FailCurrentQuest( "Ты оставил Романа одного!" )
						elseif distance > 50 then
							localPlayer:ShowError( "Вернись за Романом!" )
						end
					end, 2000, 0 )
					
					-- veh init
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					GEs.vehicle_armor = 4000
					GEs.OnClientVehicleDamage_handler = function( _,_, loss )
						local diff = GEs.vehicle_armor - loss
						if diff > 0 then
							GEs.vehicle_armor = diff
							cancelEvent()
						elseif temp_vehicle.health < 400 then
							FailCurrentQuest( "Машина Романа уничтожена!", "fail_destroy_vehicle" )
						end
					end
					addEventHandler( "onClientVehicleDamage", temp_vehicle, GEs.OnClientVehicleDamage_handler )

					GEs.check_roman_veh = setTimer( function()
						if isElementInWater( temp_vehicle ) then
							FailCurrentQuest( "Машина Романа уничтожена!", "fail_destroy_vehicle" )
						end
					end, 2000, 0 )

					-- quest init
					CreateQuestPoint( temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )
					
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							return isElement( temp_vehicle ) and ( localPlayer.position - temp_vehicle.position ).length <= 4
						end
					} )

					GEs.OnClientVehicleStartEnter_handler = function( player, seat )
						if (player == localPlayer and seat ~= 0) or GEs.blowed then
							cancelEvent( )
							localPlayer:ShowError( "Садись за руль" )
						elseif player == localPlayer and CEs.hint then
							CEs.hint:destroy()
							CEs.hint = nil
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.OnClientVehicleStartEnter_handler )

					CEs.OnClientVehicleEnter_handler = function( ped )
						if localPlayer.vehicle == temp_vehicle and GEs.roman_bot.vehicle == temp_vehicle then
							removeEventHandler( "onClientVehicleEnter", temp_vehicle, CEs.OnClientVehicleEnter_handler )
							triggerServerEvent( "murderous_setup_step_2", localPlayer )
						end
					end
					addEventHandler( "onClientVehicleEnter", temp_vehicle, CEs.OnClientVehicleEnter_handler )
				end,
				server = function( player )
					player:GiveWeapon( 29, 999, true, true, "quest_murderous_setup" )
				end,
			},

			event_end_name = "murderous_setup_step_2",
		},

		{
			name = "Прибыть на место",

			Setup = {
				client = function( )
					toggleControl( "enter_exit", false )

					local positions = QUEST_CONF.positions

					GEs.enemy_bots = {}
					local anims = { "shift", "shldr", "stretch", "strleg", "time" }
					for k, v in ipairs( positions.east_cartel_bot_spawns ) do
						GEs.enemy_bots[ k ] = CreateAIPed( v.id, v.pos, v.rot.z )
						GEs.enemy_bots[ k ].health = 50
						LocalizeQuestElement( GEs.enemy_bots[ k ] )
						givePedWeapon( GEs.enemy_bots[ k ], 29, 3000, true )
						setPedAnimation( GEs.enemy_bots[ k ], "playidles", anims[ math.random(1, #anims) ] )
					end

					GEs.dummy_vehicles = {}
					for k, v in ipairs( positions.east_cartel_veh_spawns ) do
						GEs.dummy_vehicles[ k ] = createVehicle( 445, v.pos, v.rot )
						LocalizeQuestElement( GEs.dummy_vehicles[ k ] )
						GEs.dummy_vehicles[ k ]:SetNumberPlate( "1:o" .. math.random( 111, 999 ) .. "oo" .. math.random( 10, 99 ) )
						GEs.dummy_vehicles[ k ]:SetWindowsColor( 0, 0, 0, 255 )
						GEs.dummy_vehicles[ k ]:SetColor( 0, 0, 0 )	
					end

					CreateQuestPoint( positions.start_attack.pos, function( self, player )
						CEs.marker.destroy( )
						removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
						triggerServerEvent( "murderous_setup_step_3", localPlayer )
					end, _, 5 )

					CEs.DamagePedHandler = function()
						for k, v in pairs( GEs.enemy_bots ) do
							if source == v then
								GEs.attacked = true
								removeEventHandler( "onClientColShapeHit", CEs.colshape_attack, CEs.HandlerColshape )
								removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
								triggerServerEvent( "murderous_setup_step_3", localPlayer )
								break
							end
						end
					end
					addEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )

					CEs.colshape_attack = createColTube( positions.center_attack, 45, 35 )
					LocalizeQuestElement( CEs.colshape_attack )
					CEs.HandlerColshape = function( element )
						if element == localPlayer then
							GEs.attacked = true
							removeEventHandler( "onClientColShapeHit", CEs.colshape_attack, CEs.HandlerColshape )
							removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
							triggerServerEvent( "murderous_setup_step_3", localPlayer )
						end
					end
					addEventHandler( "onClientColShapeHit", CEs.colshape_attack, CEs.HandlerColshape )
				end,
				server = function( player )
					player.vehicle.locked = true
				end,
			},

			CleanUp = {
				client = function( data, failed )
					removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
				end,
			},

			event_end_name = "murderous_setup_step_3",
		},

		{
			name = "Расправься с бандитами",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					CEs.count_wasted = 0
					CEs.enemy_blips = {}
					for k, v in pairs( GEs.enemy_bots ) do
						CEs.enemy_blips[ v ] = createBlipAttachedTo( v, 0, 1 )
						addEventHandler( "onClientPedWasted", v, function()
							CEs.OnWasted( v )
						end )
					end

					CEs.OnWasted = function( ped )
						if not isElement( CEs.enemy_blips[ ped ]) then return end

						destroyElement( CEs.enemy_blips[ ped ] )
						CEs.count_wasted = CEs.count_wasted + 1
						if CEs.count_wasted == #positions.east_cartel_bot_spawns then
							localPlayer:ShowInfo( "Убей приближенного" )
							CEs.GoCloseMan()
						end
					end

					CEs.GoCloseMan = function()
						GEs.close_man_bot = CreateAIPed( 20, positions.close_man_spawn.pos, positions.close_man_spawn.rot.z )
						LocalizeQuestElement( GEs.close_man_bot )
						setPedStat( GEs.close_man_bot, 76, 1000 )
						setPedStat( GEs.close_man_bot, 22, 1000 )
						givePedWeapon( GEs.close_man_bot, 29, 3000, true )
						
						AddAIPedPatternInQueue( GEs.close_man_bot, AI_PED_PATTERN_ATTACK_PED, {
							target_ped = localPlayer;
						} )

						CEs.close_man_blip = createBlipAttachedTo( GEs.close_man_bot, 0, 2 )

						addEventHandler( "onClientPedWasted", GEs.close_man_bot, function()
							BlockAllKeys( )

							StartQuestCutscene()
							setCameraMatrix( localPlayer.position + Vector3( 0, 0, 3.4), GEs.close_man_bot.position )
							
							setGameSpeed( 0.3 )
							CEs.ending_tmr = setTimer( function()
								setPedWeaponSlot( GEs.roman_bot, 0 )
								setPedDoingGangDriveby( GEs.roman_bot, false )
								setPedControlState( GEs.roman_bot, "vehicle_fire", false )

								triggerServerEvent( "murderous_setup_step_4", localPlayer )
							end, 5000, 1 )
						end )

						killTimer( CEs.refresh_roman_bot_target_tmr )
						setPedAimTarget( GEs.roman_bot, GEs.close_man_bot.position )
					end

					CEs.StartAttackEnemy = function()
						CEs.StartAttackFriend()

						for k, v in pairs( GEs.enemy_bots ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_ATTACK_PED, {
								target_ped = localPlayer;
							} )
						end
					end

					CEs.StartAttackFriend = function()
						setPedWeaponSlot( GEs.roman_bot, 4 )
						setPedDoingGangDriveby( GEs.roman_bot, true )
						setPedControlState( GEs.roman_bot, "vehicle_fire", true )

						CEs.RefreshTarget = function()
							local near_bot = nil
							local distance = math.huge
							for k, v in pairs( GEs.enemy_bots ) do
								local distance_to_bot = (v.position - GEs.roman_bot.position).length
								if not v.dead and distance_to_bot < distance then
									near_bot = v
									distance = distance_to_bot
								end

								if not isPedOnGround( v ) then
									v.position = v.position + Vector3( 2 * (math.random( 0, 1 ) == 0 and 1 or -1), 0, -1 )
									v.health = 0
									
									CEs.OnWasted( v )
								end
							end

							if near_bot then
								setPedWeaponSlot( GEs.roman_bot, 4 )
								setPedAimTarget( GEs.roman_bot, near_bot.position )
							end
						end
						CEs.refresh_roman_bot_target_tmr = setTimer( CEs.RefreshTarget, 500, 0 )
					end

					if GEs.attacked then
						CEs.StartAttackEnemy()
					else
						CEs.DamagePedHandler = function()
							for k, v in pairs( GEs.enemy_bots ) do
								if source == v then
									removeEventHandler( "onClientColShapeHit", CEs.colshape_attack, CEs.HandlerColshape )
									removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
									CEs.StartAttackEnemy()
									break
								end
							end
						end
						addEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )

						CEs.colshape_attack = createColTube( positions.center_attack, 45, 35 )
						LocalizeQuestElement( CEs.colshape_attack )
						CEs.HandlerColshape = function( element )
							if element == localPlayer then
								removeEventHandler( "onClientColShapeHit", CEs.colshape_attack, CEs.HandlerColshape )
								removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
								CEs.StartAttackEnemy()
							end
						end
						addEventHandler( "onClientColShapeHit", CEs.colshape_attack, CEs.HandlerColshape )
					end

					CEs.check_attack_dist = setTimer( function()
						local distance = (localPlayer.position - positions.center_attack).length
						if distance > 400 then
							FailCurrentQuest( "Ты покинул место перестрелки!" )
						elseif distance > 300 then
							localPlayer:ShowError( "Вернись к месту разборок!" )
						end
					end, 2000, 0 )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=ПКМ чтобы высунуться из окна",
						condition = function( )
							return isElement( temp_vehicle ) and ( localPlayer.position - temp_vehicle.position ).length <= 4
						end
					} )

					local VEHICLE_WINDOW_BY_SEAT = { [ 0 ] = 4,  [ 1 ] = 2, [ 2 ] = 5,  [ 3 ] = 3, }

					CEs.ToggleDriveby = function( key, state )
						if CEs.hint then 
							CEs.hint:destroy()
							CEs.hint = nil
						end

						local vehicle = localPlayer.vehicle
						if state == "up" then
							if isPedDoingGangDriveby( localPlayer ) then
								setPedDoingGangDriveby( localPlayer, false )
								setVehicleWindowOpen ( vehicle, VEHICLE_WINDOW_BY_SEAT[ localPlayer.vehicleSeat ], false )
							end
						else
							setPedWeaponSlot( localPlayer, 4 )
							setPedDoingGangDriveby( localPlayer, true )
							setVehicleWindowOpen ( vehicle, VEHICLE_WINDOW_BY_SEAT[ localPlayer.vehicleSeat ], true )
						end
					end
					bindKey( "mouse2", "both", CEs.ToggleDriveby )
				end,
				server = function( player )
					
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if CEs.DamagePedHandler then
						removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
					end
					setGameSpeed( 1 )
					FinishQuestCutscene( )
					unbindKey( "mouse2", "both", CEs.ToggleDriveby )
				end,
			},

			event_end_name = "murderous_setup_step_4",
		},

		{
			name = "Скройся с места преступления",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					setPedWeaponSlot( GEs.roman_bot, 0 )
					StartQuestTimerFail( 0.5 * 60 * 1000, "Скройся с места преступления", "Слишком медленно!" )
					CreateQuestPoint( positions.hide_away.pos, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "murderous_setup_step_5", localPlayer )
					end, _, 10 )
					CEs.marker.slowdown_coefficient = nil
				end,
				server = function( player )

				end,
			},

			event_end_name = "murderous_setup_step_5",
		},

		{
			name = "Избавься от автомобиля",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					setPedWeaponSlot( GEs.roman_bot, 0 )
					CreateQuestPoint( positions.destroy_veh.pos, function( self, player )
						CEs.marker.destroy( )
						player.vehicle.frozen = true
						triggerServerEvent( "murderous_setup_step_6", localPlayer )
					end, _, 4 )
				end,
				server = function( player )
					local vehicle = CreateTemporaryVehicle( player, 6539, QUEST_CONF.positions.roman_veh_spawn.pos, QUEST_CONF.positions.roman_veh_spawn.rot )
					vehicle:SetNumberPlate( "1:o" .. math.random( 111, 999 ) .. "oo" .. math.random( 10, 99 ) )
					vehicle:SetColor( 0, 0, 0 )
					
					player:SetPrivateData( "roman_vehicle", vehicle )
				end,
			},

			event_end_name = "murderous_setup_step_6",
		},

		{
			name = "Садись в машину Романа",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.blowed = true
					killTimer( GEs.check_roman_veh )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					removeEventHandler( "onClientVehicleDamage", temp_vehicle, GEs.OnClientVehicleDamage_handler )
					toggleControl( "enter_exit", true )

					local roman_vehicle = localPlayer:getData( "roman_vehicle" )
					GEs.OnClientVehicleDamage_handler = function( _,_, loss )
						if roman_vehicle.health < 400 then
							FailCurrentQuest( "Машина Романа уничтожена!", "fail_destroy_vehicle" )
						end
					end
					addEventHandler( "onClientVehicleDamage", roman_vehicle, GEs.OnClientVehicleDamage_handler )

					GEs.check_roman_veh = setTimer( function()
						if isElementInWater( roman_vehicle ) then
							FailCurrentQuest( "Машина Романа уничтожена!", "fail_destroy_vehicle" )
						end
					end, 2000, 0 )

					CEs.StartScene = function()
						StartQuestCutscene()
						localPlayer:setData( "not_close_cutscene", true, false )
						setCameraMatrix( unpack( positions.blow_matrix ) )

						CreateAIPed( localPlayer )
						SetAIPedMoveByRoute( localPlayer, positions.blow_veh_path, false )

						CEs.blow_tmr = setTimer( function()
							setGameSpeed( 0.4 )
							createExplosion( temp_vehicle.position, 4, true,  -1, false )
							createExplosion( temp_vehicle.position, 11, true,  -1, false )
							createExplosion( temp_vehicle.position + Vector3( 0, 2, 0 ), 11, true,  -1, false )
							setElementVelocity( temp_vehicle, 0, 0, 0.13 )
							CEs.remove_det_tmr = setTimer( function()
								setElementVelocity( temp_vehicle, 0, 0, 0.02 )
								for k, v in pairs( { "bonnet_dummy", "door_lr_dummy", "door_rr_dummy", "door_lf_dummy", "door_rf_dummy", "boot_dummy" } ) do
									setVehicleComponentVisible( temp_vehicle, v, false )
								end
								GEs.effects = {}
								GEs.effects[ 1 ] = createEffect( "fire", temp_vehicle.position + Vector3( -1.5, 0, 0.1 ), Vector3( 270, 0, 0) )
								GEs.effects[ 2 ] = createEffect( "fire", temp_vehicle.position + Vector3( 1.5, 0, 0.1 ), Vector3( 270, 0, 0) )
								GEs.effects[ 3 ] = createEffect( "fire", temp_vehicle.position + Vector3( 0, 0, 0.1 ), Vector3( 270, 0, 0) )
								GEs.effects[ 4 ] = createEffect( "smoke30m", temp_vehicle.position + Vector3( 0, 2, 0 ), Vector3( 270, 0, 0) )
							end, 150, 1 )
					
							CEs.ending_tmr = setTimer( function()
								fadeCamera( false, 0.5 )
								CEs.next_step_tmr = setTimer( function()
									triggerServerEvent( "murderous_setup_step_7", localPlayer )
								end, 600, 1 )
							end, 1800, 1 )
						end, 1500, 1 )
					end

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							return isElement( roman_vehicle ) and ( localPlayer.position - roman_vehicle.position ).length <= 4
						end
					} )

					CreateQuestPoint( roman_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )

					CEs.OnClientVehicleStartEnter_handler = function( player, seat )
						if GEs.completed then cancelEvent() end

						if player == localPlayer and seat ~= 0 then
							cancelEvent( )
							localPlayer:ShowError( "Садись за руль" )
						elseif player == localPlayer and CEs.hint then
							CEs.hint:destroy()
							CEs.hint = nil
						end
					end
					addEventHandler( "onClientVehicleStartEnter", roman_vehicle, CEs.OnClientVehicleStartEnter_handler )

					CEs.OnClientVehicleEnter_handler = function( ped )
						if localPlayer.vehicle == roman_vehicle and GEs.roman_bot.vehicle == roman_vehicle then
							removeEventHandler( "onClientVehicleEnter", roman_vehicle, CEs.OnClientVehicleEnter_handler )
							CEs.StartScene()
						elseif localPlayer.vehicle then
							toggleAllControls( false )
						end
					end
					addEventHandler( "onClientVehicleEnter", roman_vehicle, CEs.OnClientVehicleEnter_handler )
				end,
				server = function( player )
					player:TakeWeapon( 29, 999 )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					ClearAIPed( localPlayer )
					DestroyFollowHandlers()
				end,
			},

			event_end_name = "murderous_setup_step_7",
		},

		{
			name = "Привези Романа домой",

			Setup = {
				client = function( )
					CEs.show_screen_tmr = setTimer( function()
						setGameSpeed( 1 )
						FinishQuestCutscene( { ignore_fade_blink = true } )
						fadeCamera( true, 0.5 )

						localPlayer:setData( "not_close_cutscene", false, false )
					end, 1100, 1 )

					local positions = QUEST_CONF.positions

					CleanupAIPedPatternQueue( localPlayer )
					removePedTask( localPlayer )
					ClearAIPed( localPlayer )

					toggleAllControls( true )

					GEs.pps_bots = {}
					for k, v in ipairs( positions.pps_bot_spawns ) do
						GEs.pps_bots[ k ] = createPed( v.id, v.pos, v.rot.z )
						GEs.pps_bots[ k ].frozen = true

						LocalizeQuestElement( GEs.pps_bots[ k ] )
						givePedWeapon( GEs.pps_bots[ k ], 30, 3000, true )
					end

					CEs.DamagePedHandler = function()
						for k, v in pairs( GEs.pps_bots ) do
							if source == v then
								FailCurrentQuest( "Ты привлек слишком много внимания!" )
								removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
								break
							end
						end
					end
					addEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
					
					GEs.pps_vehs = {}
					for k, v in ipairs( positions.pps_veh_spawns ) do
						GEs.pps_vehs[ k ] = createVehicle( 426, v.pos, v.rot )
						LocalizeQuestElement( GEs.pps_vehs[ k ] )
						GEs.pps_vehs[ k ]:SetNumberPlate( "6:А" .. math.random( 111, 999 ) .. math.random( 10, 99 ) )
						GEs.pps_vehs[ k ]:SetColor( 255, 255, 255 )
						setVehiclePaintjob( GEs.pps_vehs[ k ], 1 )	
					end

					CreateQuestPoint( positions.finish_veh_parking.pos, function( self, player )
						CEs.marker.destroy( )
						GEs.completed = true
						localPlayer.vehicle.frozen = true
						
						CreateAIPed( localPlayer )
						for k, v in pairs( { localPlayer, GEs.roman_bot } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, {} )
						end

						triggerServerEvent( "murderous_setup_step_8", localPlayer )
					end, _, 1.8 )
				end,
				server = function( player )
					removePedFromVehicle( player )
					warpPedIntoVehicle( player, player:getData( "roman_vehicle") )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					removeEventHandler( "onClientPedDamage", root, CEs.DamagePedHandler )
				end,
			},

			event_end_name = "murderous_setup_step_8",
		},

		{
			name = "Поговори с Романом",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CEs.TryStartDialog = function()
						if CEs.roman_ready and CEs.player_ready then

							setCameraMatrix( unpack( positions.finish_talk_matrix ) )
							StartQuestCutscene( { dialog = QUEST_CONF.dialogs.roman_finish } )

							setPedWeaponSlot( GEs.roman_bot, 0 )
							GEs.roman_bot.position = positions.finish_talk_roman.pos
							GEs.roman_bot.rotation = positions.finish_talk_roman.rot

							localPlayer.position = positions.finish_talk_player.pos
							localPlayer.rotation = positions.finish_talk_player.rot
							
							CEs.dialog:next( )
							StartPedTalk( GEs.roman_bot, nil, true )

							setTimerDialog( function()
								triggerServerEvent( "murderous_setup_step_9", localPlayer )
							end, 12000 )
						end
					end

					CEs.RomanReady = function()
						if CEs.roman_ready then return end
						if isTimer( CEs.roman_ready_tmr ) then killTimer( CEs.roman_ready_tmr ) end
						
						GEs.roman_bot.position = positions.finish_talk_roman.pos
						GEs.roman_bot.rotation = positions.finish_talk_roman.rot

						CEs.roman_ready = true
						CEs.TryStartDialog()
					end

					SetAIPedMoveByRoute( GEs.roman_bot, positions.roman_finish_path, false, CEs.RomanReady )
					CEs.roman_ready_tmr = setTimer( CEs.RomanReady, 5000, 1 )

					CreateQuestPoint( positions.finish_talk_player.pos, function( self, player )
						CEs.marker.destroy( )
						CEs.player_ready = true						
						CEs.TryStartDialog()
					end, _, 1.5 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "murderous_setup_step_9",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification( { title = "Анжела", msg = "Привет, Солнце. Приезжай ко мне в клуб, повеселимся!" },
		{
			condition = function( self, player, data, config )
				local current_quest = player:getData( "current_quest" )
				if current_quest and current_quest.id == "crazy_vacation" then
					return "cancel"
				end
				return getRealTime( ).timestamp - self.ts >= 60
			end,
			save_offline = true,
		} )

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp, firstaid = QUEST_DATA.rewards.firstaid, repairbox = QUEST_DATA.rewards.repairbox }
		} )
	end,

	rewards = {
		money = 10000,
		exp = 10000,
		firstaid = 1,
		repairbox = 1,
	},
	no_show_rewards = true,
}
