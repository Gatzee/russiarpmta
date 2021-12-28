QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Анжела", voice_line = "Angela_8", text = [[Привет, слушай у меня классный тренер есть по танцам, заедь к нему в школу.
А и возьми более подходящий костюм в магазине. О деньгах не переживай я договорилась.]] },
		},
		angela_dance = {
			{ name = "Анжела", voice_line = "Angela_9", text = "О, хорошо выглядишь, посмотрим, что ты умеешь?" }
		},
		boyfriend = {
			{ name = "Мужик", voice_line = "Ex", text = "Эй ты! Какого хрена ты танцуешь с моей девушкой! Пойдем отойдем на ринг! " }
		},
		angela_finish = {
			{ name = "Анжела", voice_line = "Angela_10", text = [[Ты как? Прости, это старый мудак, бывший. После такого, он точно больше
не будет меня беспокоить, спасибо тебе!]] }
		},
	},

	positions = {
		dance_school_enter = Vector3( 2430.908203125, -606.33576965332, 62.007789611816 ),
		dance_school_leave = Vector3( -227.77281188965, -389.76080322266, 1338.6201171875 ),
		dance_shop = Vector3( -228.42765808105, -383.99075317383, 1338.6201171875 ),

		cloth_shop_enter = Vector3( 2315.3615722656, -565.69290161133, 62.415336608887 ),
		cloth_shop_leave = Vector3( -230.2956237793, -389.32064819336, 1360.3433837891 ),
		cloth_shop = Vector3( -228.35597229004, -383.72491455078, 1360.3433837891 ),

		fight_club_vehicle = Vector3( 37.79137802124, -2150.9688720703, 20.597436904907 ),

		dance_peds =
		{
			{ id = 12,  position = Vector3( 22.635108947754, -1264.8406982422 - 860, 20.597436904907 ), rotation = 200, anim = "dnce_m_c" },
			{ id = 62,  position = Vector3( 26.644411087036, -1265.1676025391 - 860, 20.597436904907 ), rotation = 90,  anim = "dnce_m_a" },
			{ id = 22,  position = Vector3( 24.125837326052, -1264.7266845703 - 860, 20.597436904907 ), rotation = 90,  anim = "dnce_m_d" },
			{ id = 92,  position = Vector3( 20.146911621094, -1267.9121093752 - 860, 20.597436904907 ), rotation = 270, anim = "dnce_m_c" },
			{ id = 113, position = Vector3( 21.954875946045, -1270.2711181641 - 860, 20.597436904907 ), rotation = 0,   anim = "dnce_m_a" },
			{ id = 23,  position = Vector3( 27.353809356689, -1267.2620849609 - 860, 20.597436904907 ), rotation = 120, anim = "dnce_m_b" },
			{ id = 78,  position = Vector3( 20.205429077148, -1269.6875323232 - 860, 20.597436904907 ), rotation = 0,   anim = "dnce_m_d" },
		},
		parking_vehicles = 
		{
			{ id = 411,  position = Vector3( 33.159568786621, -1291.1092529297 - 860, 20.172185897827 ), rotation = Vector3( 0, 0, 358.56298828125 ) },
			{ id = 496,  position = Vector3( 25.381473541262, -1291.2408447266 - 860, 19.984586715698 ), rotation = Vector3( 0, 0, 179.68843078613 ) },
			{ id = 526,  position = Vector3( 13.210976600647, -1292.4616699219 - 860, 20.242231369019 ), rotation = Vector3( 0, 0, 89.551795959473 ) },
			{ id = 534,  position = Vector3( 13.953777313232, -1274.4290771484 - 860, 20.181859970093 ), rotation = Vector3( 0, 0, 269.10324096682 ) },
			{ id = 535,  position = Vector3( 12.819675445557, -1271.1284179688 - 860, 20.664882659912 ), rotation = Vector3( 0, 0, 269.10324096682 ) },
			{ id = 562,  position = Vector3( 13.521671295166, -1266.0560302734 - 860, 20.476373672485 ), rotation = Vector3( 0, 0, 269.10324096682 ) },
			{ id = 596,  position = Vector3( 13.672152519226, -1257.1322021484 - 860, 20.184152603149 ), rotation = Vector3( 0, 0, 269.10324096682 ) },
		},

		angela_dance_club = { position = Vector3( 24.502443313599, -2127.0943603516, 20.597436904907 ), rotation = 195 },

		angela_talk = { position = Vector3( 24.512340545654, -2128.2414550781, 20.597436904907 ), talk_pos = Vector3( 24.709, -2127.775, 20.597 ), rotation = Vector3( 0, 0, 11 ) },
		angela_talk_camera = { 24.587713241577, -2128.3098144531, 21.392877578735, 9.8092832565308, -2031.16015625, 2.8579897880554, 0, 70 },

		boyfriend = { position = Vector3( 19.754549026489, -2126.1055908203, 20.597436904907 ), rotation = 248 },
		
		boyfriend_talk_position = Vector3( 24.582440545654, -2128.0158550781, 20.597436904907 ),
		boyfriend_talk_rotation = Vector3( 0, 0, 53.655609130859 ),
		boyfriend_talk_camera = { 28.2630443573, -2133.5777587891, 23.674098968506, -26.54771232605, -2059.5013427734, -15.164848327637, 0, 70 },

		fight_club_enter = Vector3( 35.359680175781, -2130.2644042969, 20.597436904907 ),
		fight_club_leave = Vector3( -2121.4919433594, 244.8959960938, 665.09204101563 ),

		fight_club_ring_enter = Vector3( -2077.8037109375, 247.7354736328, 665.08862304688 ),

		fight_club_ring_1 = { position = Vector3( -2072.5327148438, 247.5893554688, 666.42547607422 ), rotation = Vector3( 0, 0, 267 ) },
		fight_club_ring_2 = { position = Vector3( -2063.4355468752, 247.3558349609, 666.42547607422 ), rotation = Vector3( 0, 0, 87  ) },
		
		dance_sky_camera_from = { 23.581661224365, -2129.1568603516, 22.040216445923, 70.189277648926, -2057.4504394531, -29.785705566406, 0, 70 },
		dance_sky_camera_to = { 19.23416519165, -2137.0609130859, 27.419111251831, 60.639404296875, -2061.8190917969, -23.80860710144, 0, 70 },

		finish_camera = { 44.249221801758, -2147.4962158203, 22.109813690186, 125.54724884033, -2091.3271484375, 6.7583570480347, 0, 70 },

		finish_positions = {
			Vector3( 51.274215698242, -2142.7313232422, 20.597436904907 ),
			Vector3( 56.449230194092, -2142.8081054688, 20.597436904907 ),
			Vector3( 62.407402038574, -2142.5979003906, 20.597436904907 ),
			Vector3( 67.030693054199, -2142.4355468752, 20.597436904907 ),
			Vector3( 55.841514587402, -2144.7391357422, 20.597436904907 ),
		}
	}
}

GEs = { }

QUEST_DATA = {
	id = "angela_dance_school",
	is_company_quest = true,

	title = "Уроки танцев",
	description = "После прошлых событий надо освежить голову. Как раз Анжела знает толк в тусовках.",
	--replay_timeout = 5; 

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1951.2601, -249.4949, 60.4046 ),

	quests_request = { "jeka_capture" },
	level_request = 4,

	OnAnyFinish = {
		client = function( )
			OnFightFinished()

			local iDance = -1
			local dances = exports.nrp_dancing_school:GetDancesList()
			for k, v in pairs( dances ) do
				if v.name == "Танец 4" then
					iDance = k
					break
				end
			end

			if iDance ~= -1 then
				local pUserPreset = localPlayer:getData( "animations_preset" ) or {}
				for k, v in pairs( pUserPreset ) do
					if v == iDance then
						pUserPreset[ k ] = nil
					end
				end
				localPlayer:setData( "animations_preset", pUserPreset, false )
				exports.nrp_dancing_school:SaveUserPreset()
			end

			local pSkinModel = localPlayer:getData( "quest_skin" )
			if pSkinModel then
				localPlayer.model = pSkinModel
				localPlayer:setData( "quest_skin", nil, false )
			end

			localPlayer:setData( "is_dance_school_quest", nil, false )
		end,
		
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
			

			local iDance = -1
			local dances = exports.nrp_dancing_school:GetDancesList()
			for k, v in pairs( dances ) do
				if v.name == "Танец 4" then
					iDance = k
					break
				end
			end

			if iDance ~= -1 and not player:getData( "dance_exist" ) then
				player:RemoveDance( iDance )
			end

			player:setData( "dance_exist", nil, false )
		end,
	},

	tasks = {
		{
			name = "Поговорить с Анжелой",

			Setup = {
				client = function( )
					
					localPlayer:setData( "quest_skin", localPlayer.model, false )
					localPlayer:setData( "is_dance_school_quest", true, false )

					CreateMarkerToCutsceneNPC( {
						id = "angela",
						dialog = QUEST_CONF.dialogs.start,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							StartPedTalk( FindQuestNPC( "angela" ).ped, nil, true )
							CEs.dialog:next( )

							setTimerDialog( function( )
								triggerServerEvent( "angela_dance_school_step_1", localPlayer )
							end, 12000, 1 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "angela" ).ped )
				end,
			},

			event_end_name = "angela_dance_school_step_1",
		},

		{
			name = "Отправляйся в школу танцев",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.dance_school_enter, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 1 )
						CEs.timer = setTimer( function()
							fadeCamera( true, 1 )
							triggerServerEvent( "angela_dance_school_step_2", localPlayer )
						end, 1250, 1 )
					end, _, 1, 0, localPlayer:GetUniqueDimension(),
					function( )
						if localPlayer.vehicle then
							return false, "Вряд ли в школу танцев можно заехать на машине"
						end
						return true
					end )
				end,
				server = function( player )
					local iDance = -1
					local dances = exports.nrp_dancing_school:GetDancesList()

					for k, v in pairs( dances ) do
						if v.name == "Танец 4" then
							iDance = k
							break
						end
					end

					local has_dance = player:HasDance( iDance )
					if iDance ~= -1 and not has_dance then
						player:AddDance( iDance )
					elseif has_dance then
						player:setData( "dance_exist", true, false )
					end

					player:SetPrivateData( "unlocked_animations", player:GetPermanentData( "unlocked_animations" ) or {} )

					EnableQuestEvacuation( player )
					EnterLocalDimensionForVehicles( player )
				end,
			},

			event_end_name = "angela_dance_school_step_2",
		},

		{
			name = "Научись движению",

			Setup = {
				client = function( )
					localPlayer.position = QUEST_CONF.positions.dance_school_leave
					localPlayer.interior = 1

					-- Вход в меню школы танцев
					CreateQuestPoint( QUEST_CONF.positions.dance_shop, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 1 )

						CEs.timer = setTimer( function()
							fadeCamera( true, 1 )
							triggerEvent( "DS:ShowUI", localPlayer, true )
						end, 1250, 1 )
					end, _, 1 )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			event_end_name = "angela_dance_school_step_3",
		},

		{
			name = "Покинь Школу Танцев",

			Setup = {
				client = function( )
					localPlayer.position = Vector3( -228.826, -384.518, 1338.620 )
					CreateQuestPoint( QUEST_CONF.positions.dance_school_leave, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 0 )
						triggerServerEvent( "angela_dance_school_step_4", localPlayer )
					end, _, 1 )
				end,
			},

			event_end_name = "angela_dance_school_step_4",
		},

		{
			name = "Отправляйся в магазин одежды",

			Setup = {
				client = function( )
					localPlayer.interior = 0
					localPlayer.position = QUEST_CONF.positions.dance_school_enter
					fadeCamera( true, 1 )

					CreateQuestPoint( QUEST_CONF.positions.cloth_shop_enter, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 1 )

						CEs.timer = setTimer( function()
							localPlayer.interior = 1
							localPlayer.position = QUEST_CONF.positions.cloth_shop_leave
							fadeCamera( true, 1 )
							triggerServerEvent( "angela_dance_school_step_5", localPlayer )
						end, 1250, 1 )
					end, _, 1 )
				end,
				server = function( player )
					player.interior = 0
				end,
			},

			event_end_name = "angela_dance_school_step_5",
		},

		{
			name = "Переоденься",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.cloth_shop, function( self, player )
						CEs.marker.destroy( )

						local ped_id = 76
						if localPlayer:GetGender() ~= 0 then
							ped_id = 130
						end

						localPlayer.model = ped_id
						localPlayer:ShowInfo( "Думаю такой прикид гораздо круче!")
						triggerServerEvent( "ClientRequestDataAndShowUIShop", localPlayer )
						triggerServerEvent( "angela_dance_school_step_6", localPlayer )
					end, _, 1 )
				end,
			},

			event_end_name = "angela_dance_school_step_6",
		},

		{
			name = "Отправляйся на вечеринку",

			Setup = {
				client = function( )

					GEs.vehicles = {}
					for k, v in pairs( QUEST_CONF.positions.parking_vehicles ) do
						GEs.vehicles[ k ] = createVehicle( v.id, v.position, v.rotation )
						GEs.vehicles[ k ].dimension = localPlayer.dimension
					end

					GEs.peds = {}
					for k, v in pairs( QUEST_CONF.positions.dance_peds ) do
						GEs.peds[ k ] = createPed( v.id, v.position, v.rotation )
						GEs.peds[ k ].dimension = localPlayer.dimension
						GEs.peds[ k ]:setAnimation( "dancing", v.anim, -1, true, false, false, false )
						addEventHandler( "onClientPedDamage", GEs.peds[ k ], cancelEvent )
					end

					GEs.dance_music = playSound3D( "sfx/dance_music.wav", 23.631, -2127.802, 0.597, true )
					setSoundMaxDistance( GEs.dance_music, 80 )
					GEs.dance_music.dimension = localPlayer.dimension
					GEs.dance_music.volume = 1.0

					GEs.ped_angela = createPed( 131, QUEST_CONF.positions.angela_dance_club.position, QUEST_CONF.positions.angela_dance_club.rotation )
					GEs.ped_angela.dimension = localPlayer.dimension
					GEs.ped_angela:setAnimation( "dancing", "dance_loop", -1, true, false, false, false )
					GEs.ped_angela.frozen = true
					addEventHandler( "onClientPedDamage", GEs.ped_angela, cancelEvent )

					GEs.boyfriend = CreateAIPed( 90, QUEST_CONF.positions.boyfriend.position, QUEST_CONF.positions.boyfriend.rotation )
					GEs.boyfriend.dimension = localPlayer.dimension
					GEs.boyfriend:setAnimation( "dancing", "dnce_m_b", -1, true, false, false, false )
					GEs.boyfriend.frozen = true
					addEventHandler( "onClientPedDamage", GEs.boyfriend, cancelEvent )

					CreateQuestPoint( QUEST_CONF.positions.cloth_shop_leave, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 1 )

						CEs.timer = setTimer( function()
							
							localPlayer.interior = 0
							localPlayer.position = QUEST_CONF.positions.cloth_shop_enter
							fadeCamera( true, 1 )

							CreateQuestPoint( QUEST_CONF.positions.fight_club_vehicle, function( self, player )
								CEs.marker.destroy( )
								triggerServerEvent( "angela_dance_school_step_7", localPlayer )		
							end, _, 1 )
						end, 1250, 1 )
					end, _, 1 )
				end,
			},

			event_end_name = "angela_dance_school_step_7",
		},

		{
			name = "Поговори с Анжелой",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.angela_talk.position, function( self, player )
						CEs.marker.destroy( )
						
						localPlayer.position = QUEST_CONF.positions.angela_talk.talk_pos
						localPlayer.rotation = QUEST_CONF.positions.angela_talk.rotation
						
						setCameraMatrix( unpack( QUEST_CONF.positions.angela_talk_camera ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.angela_dance } )
						GEs.ped_angela:setAnimation( nil, nil )
						CEs.dialog:next( )
						StartPedTalk( GEs.ped_angela, nil, true )

						setTimerDialog( function( )
							triggerServerEvent( "angela_dance_school_step_8", localPlayer )
						end, 3100, 1 )
					end, _, 1, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Ты чего творишь? Выйди из машины, чтобы поговорить с Анжелой"
						end
						return true
					end )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.ped_angela )
				end,
			},

			event_end_name = "angela_dance_school_step_8",
		},

		{
			name = "Потанцуй с Анжелой",

			Setup = {
				client = function( )
					localPlayer:setData( "is_dance_school_quest", "angela_dance_school_step_9", false )
					GEs.ped_angela:setAnimation( "dancing", "dance_loop", -1, true, false, false, false )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=TAB + key=E чтобы начать танцевать",
						condition = function( )
							return (localPlayer.position - QUEST_CONF.positions.angela_dance_club.position).length <= 4
						end
					} )
					
				end,
			},

			event_end_name = "angela_dance_school_step_9",
		},

		{
			name = "Потанцуй с Анжелой",

			Setup = {
				client = function( )
					CEs.timer = setTimer( function( )
						setCameraMatrix( unpack( QUEST_CONF.positions.boyfriend_talk_camera ) )

						localPlayer.position = QUEST_CONF.positions.boyfriend_talk_position
						localPlayer.rotation = QUEST_CONF.positions.boyfriend_talk_rotation
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.boyfriend } )
						
						GEs.boyfriend.frozen = false
						GEs.boyfriend:setAnimation( nil, nil )
						
						ResetAIPedPattern( GEs.boyfriend )
						
						SetAIPedMoveByRoute( GEs.boyfriend, { { x = 23.671094894402, y = -2127.881958007, z = 20.597436904907, distance = 0.1 } }, false, function( )
							GEs.boyfriend.frozen = true
							CleanupAIPedPatternQueue( GEs.boyfriend )
							ResetAIPedPattern( GEs.boyfriend )
							setPedControlState( GEs.boyfriend, "fire", true )
							CEs.timer = setTimer( function()
								CEs.dialog:next( )
								setTimerDialog( function( )
									triggerServerEvent( "angela_dance_school_step_10", localPlayer )
								end, 5100, 1 )
							end, 150, 1 )
						end )

						
					end, 4000, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_dance_school_step_10",
		},

		{
			name = "Выйди на ринг",

			Setup = {
				client = function( )
					GEs.boyfriend.frozen = false

					GEs.follow = CreatePedFollow( localPlayer )
					GEs.follow:start( GEs.boyfriend )

					local pos = QUEST_CONF.positions.fight_club_enter
					SetAIPedMoveByRoute( GEs.boyfriend, { { x = pos.x, y = pos.y, z = pos.z, distance = 0.1 } }, false, function( )
						fadeCamera( false, 1 )
						
						CleanupAIPedPatternQueue( GEs.boyfriend )
						ResetAIPedPattern( GEs.boyfriend )
						GEs.follow:destroy()
						ClearAIPed( localPlayer )

						CEs.timer = setTimer( function()
							fadeCamera( true, 1 )
							triggerServerEvent( "angela_dance_school_step_11", localPlayer )
						end, 1250, 1 )
					end )
				end,
			},

			event_end_name = "angela_dance_school_step_11",
		},

		{
			name = "Выйди на ринг",

			Setup = {
				client = function( )
					GEs.boyfriend.position = QUEST_CONF.positions.fight_club_leave

					localPlayer.interior = 1
					localPlayer.position = QUEST_CONF.positions.fight_club_leave
					LocalizeQuestElement( GEs.boyfriend )

					GEs.follow = CreatePedFollow( localPlayer )
					GEs.follow:start( GEs.boyfriend )
					
					local pos = QUEST_CONF.positions.fight_club_ring_enter
					SetAIPedMoveByRoute( GEs.boyfriend, {
						{ x = -2114.3383789063, y = 1108.0821533203 - 860, z = 665.09204101563, distance = 0.1 },
						{ x = pos.x, y = pos.y, z = pos.z, distance = 0.1 },
					}, false, function( )
						ResetAIPedPattern( GEs.boyfriend )
						CleanupAIPedPatternQueue( GEs.boyfriend )
						
						GEs.follow:destroy()
						ClearAIPed( localPlayer )

						fadeCamera( false, 1 )
						CEs.timer = setTimer( function()
							GEs.boyfriend.position = QUEST_CONF.positions.fight_club_ring_2.position
							GEs.boyfriend.rotation = QUEST_CONF.positions.fight_club_ring_2.rotation
							
							localPlayer.position = QUEST_CONF.positions.fight_club_ring_1.position
							localPlayer.rotation = QUEST_CONF.positions.fight_club_ring_1.rotation
							fadeCamera( true, 1 )
							triggerServerEvent( "angela_dance_school_step_12", localPlayer )
						end, 2250, 1 )
					end )
				end,
				server = function( player )
					player.interior = 1
				end
			},

			event_end_name = "angela_dance_school_step_12",
		},

		{
			name = "Победи соперника",

			Setup = {
				client = function( )
					setPedWeaponSlot( localPlayer, 0 )
					toggleControl( "next_weapon", false )
					toggleControl( "previous_weapon", false )

					removeEventHandler( "onClientPedDamage", GEs.boyfriend, cancelEvent )
					
					AddAIPedPatternInQueue( GEs.boyfriend, AI_PED_PATTERN_ATTACK_PED, {
						target_ped = localPlayer;
					} )

					CEs.hint = CreateSutiationalHint( {
						text = "Удерживай key=ПКМ чтобы перейти в режим боя",
						condition = function( )
							return true
						end
					} )

					GEs.onKeyHandler = function( key, state )
						if not state then return end
						local jump_key = next( getBoundKeys( "jump" ) )

						if key == "mouse2" and CEs.hint then
							CEs.hint:destroy_with_animation()
							CEs.hint = nil
							CEs.hint_1 = CreateSutiationalHint( {
								text = "Нажми key=ЛКМ для лёгкого удара\n",
								condition = function( )
									return true
								end
							} )
						elseif key == "mouse1" and CEs.hint_1 then
							CEs.hint_1:destroy_with_animation()
							CEs.hint_1 = nil
						elseif key == "f" and CEs.hint_2 then
							CEs.hint_2:destroy_with_animation()
							CEs.hint_2 = nil

							local keys = {
								space = "ПРОБЕЛ",
								shift = "SHIFT"
							}
							CEs.hint_3 = CreateSutiationalHint( {
								text = "Используй key=ПКМ + key=" .. ( jump_key and keys[ jump_key ] or tostring( jump_key ) ) .. " для блока",
								condition = function( )
									return true
								end
							} )
						elseif key == jump_key and getKeyState( "mouse2" ) and CEs.hint_3 then
							CEs.hint_3:destroy_with_animation()
							CEs.hint_3 = nil
						end
					end
					addEventHandler( "onClientKey", root, GEs.onKeyHandler )

					StartFight( GEs.boyfriend )
					GEs.boyfriend.health = 40
				end,
				server = function( player )
					player.health = 100
				end
			},

			CleanUp = {
				client = function( )
					OnFightFinished()
					removeEventHandler( "onClientKey", root, GEs.onKeyHandler )
				end,
			},

			event_end_name = "angela_dance_school_step_13",
		},

		{
			name = "Покинь Бойцовский Клуб",

			Setup = {
				client = function( )
					GEs.ped_angela:setAnimation( nil, nil )
					GEs.boyfriend:destroy()

					CreateQuestPoint( QUEST_CONF.positions.fight_club_leave, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 1 )
						triggerServerEvent( "angela_dance_school_step_14", localPlayer )
					end, _, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_dance_school_step_14",
		},

		{
			name = "Поговори с Анжелой",

			Setup = {
				client = function( )
					localPlayer.interior = 0
					localPlayer.position = QUEST_CONF.positions.fight_club_enter
					fadeCamera( true, 1 )
					
					CreateQuestPoint( QUEST_CONF.positions.angela_talk.position, function( self, player )
						CEs.marker.destroy( )
						
						localPlayer.position = QUEST_CONF.positions.angela_talk.position
						localPlayer.rotation = QUEST_CONF.positions.angela_talk.rotation
						
						setCameraMatrix( unpack( QUEST_CONF.positions.angela_talk_camera ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.angela_finish } )
						CEs.dialog:next( )
						StartPedTalk( GEs.ped_angela, nil, true )

						setTimerDialog( function( )
							triggerServerEvent( "angela_dance_school_step_15", localPlayer )
						end, 7100, 1 )
					end, _, 1 )
				end,
				server = function( player )
					player.interior = 0
				end
			},

			CleanUp = {
				client = function( )
					StopPedTalk( GEs.ped_angela )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "angela_dance_school_step_15",
		},

		{
			name = "Отрывайся",

			Setup = {
				client = function( )
					localPlayer:setData( "is_dance_school_quest", "angela_dance_school_step_16", false )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=TAB + key=E чтобы начать танцевать",
						condition = function( )
							return (localPlayer.position - QUEST_CONF.positions.angela_dance_club.position).length <= 4
						end
					} )
				end,
			},

			event_end_name = "angela_dance_school_step_16",
		},

		{
			name = "Отрывайся",

			Setup = {
				client = function( )
					
					GEs.ped_angela:setAnimation( "dancing", "dance_loop", -1, true, false, false, false )
					CameraFromTo( QUEST_CONF.positions.dance_sky_camera_from, QUEST_CONF.positions.dance_sky_camera_to, 6000, "Linear" )
					fadeCamera( false, 6 )

					CEs.timer = setTimer( function( )
						for k, v in pairs( GEs.peds ) do
							v:destroy()
						end
					
						for k, v in pairs( GEs.vehicles ) do
							v:destroy()
						end
					
						GEs.ped_angela:destroy()
					
						local pSkinModel = localPlayer:getData( "quest_skin" )
						localPlayer:setData( "quest_skin", nil, false )
						localPlayer.model = pSkinModel
						
						localPlayer:setAnimation( nil, nil )
						localPlayer.position = QUEST_CONF.positions.finish_positions[ math.random(1, #QUEST_CONF.positions.finish_positions)]
						setCameraTarget( localPlayer )
						local plr_rotation = localPlayer.rotation
						setPedCameraRotation( localPlayer, plr_rotation.z )
						toggleAllControls( false )

						localPlayer:setAnimation( "sunbathe", "sbathe_f_lieb2sit", -1, false, false, false, true )
						CEs.timer = setTimer( function()
							fadeCamera( true, 1 )
							CEs.timer = setTimer( function() 
								localPlayer:setAnimation( "sunbathe", "sbathe_f_out", -1, false, false, false, false )
								CEs.timer = setTimer( function()
									triggerServerEvent( "angela_dance_school_step_17", localPlayer )
								end, 2000, 1 )
							end, 2200, 1 )
						end, 200, 1 )
					end, 8000, 1 )

				end,
			},

			CleanUp = {
				client = function( )
					toggleAllControls( true )
				end,
			},

			event_end_name = "angela_dance_school_step_17",
		},

	},

	GiveReward = function( player )
		SendQuest2Invite( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				money = 600,
				exp = 1300,
			}
		} )
	end,

	rewards = {
		money = 600,
		exp = 1300,
	},

	no_show_rewards = true,
}