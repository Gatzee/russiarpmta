QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Жека", voice_line = "Jeka_3", text = [[Привет "Спиди", ты вовремя, у меня заезд на носу, нужна твоя помощь,
но учти, ставки высокие. Есть один мудак местный, который себя ставит выше всех.]] },
			{ name = "Жека", text = [[Надо его проучить, забрать тачку, победив в заезде!
Прыгай в машину и поспеши, гонка скоро начнётся! ]] },
		},
		help = {
			{ name = "Сотрудник ДПС", voice_line = "Cop_2_1", text = "У тебя нет выбора! Тебе придется нам помочь! Когды будешь нужен(-а), тебя вызовут!" }
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
		vehicle_main_spawn = Vector3( 1805.453, -697.147, 60.383 ),
		vehicle_main_spawn_rotation = Vector3( 359.244, 0.050, 24.633 ),

		race_start_point = Vector3( 2177.3203125, -1581.22387695313, 60.546463012695 ),

		player_start = Vector3( 2176.8198242188, -1579.07440185547, 60.27091217041 ),
		player_start_rotation = Vector3( 359.40286254883, 0.000274658203125, 310.748046875 ),

		enemy_start = Vector3( 2179.2663574219, -1581.92749023438, 60.270179748535 ),
		enemy_start_rotation = Vector3( 359.39883422852, 0.000152587890625, 310.25546264648 ),
	},
}

GEs = { }

QUEST_DATA = {
	id = "jeka_race",
	is_company_quest = true,

	title = "Заезд",
	description = "Жеке нужна помощь в гонке. Главное не проиграть, чтобы не остаться в должниках.",
	--replay_timeout = 5; 

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1775.1571, -695.9771, 60.6470 ),

	quests_request = { "jeka_testdrive" },
	level_request = 4,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			if player.interior ~= 0 then
				player.interior = 0
				player.position = Vector3( 2179.760, -692.095, 60.386 ):AddRandomRange( 3 )
			end
			ExitLocalDimension( player )
		end,
		client = function()
			localPlayer:setData( "blocked_change_camera", false, false ) 
		end,
	},

	tasks = {
		{
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
								CEs.dialog:next( )
								setTimerDialog( function( )
									triggerServerEvent( "jeka_race_step_1", localPlayer )
								end, 8500, 1 )
							end, 8800, 1 )
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

			event_end_name = "jeka_race_step_1",
		},

		{
			name = "Доехать до старта",
			Setup = {
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 436, positions.vehicle_main_spawn, positions.vehicle_main_spawn_rotation )
					local parts = exports.nrp_tuning_internal_parts:getTuningPartsIDByParams( { type = 1, category = 5, subtype = 1 } )

					player:SetPrivateData( "temp_vehicle", vehicle )

					vehicle:SetNumberPlate( "1:o745oo177" )
					vehicle:SetExternalTuning( QUEST_CONF.tuning.external_params.parts )
					vehicle:SetColor( unpack( QUEST_CONF.tuning.external_params.color ) )
					vehicle:SetHeadlightsColor( unpack( QUEST_CONF.tuning.external_params.color ) )
					vehicle:SetWindowsColor( unpack( QUEST_CONF.tuning.external_params.windows ) )
					vehicle:SetWheels( QUEST_CONF.tuning.external_params.wheels )

					for _, id in pairs( parts ) do
						vehicle:ApplyPermanentPart( id )
					end

					triggerEvent( "jeka_race_step_vehicle", player )
				end,
			},
			event_end_name = "jeka_race_step_vehicle",
		},

		{
			name = "Доехать до старта",

			Setup = {
				client = function( )
					triggerEvent( "ToggleDisableFirstPerson", localPlayer )
					localPlayer:setData( "blocked_change_camera", true, false ) 

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
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

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть в Civic",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return not localPlayer.vehicle and isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					CreateQuestPoint( QUEST_CONF.positions.race_start_point, function( self, player )
						CEs.marker.destroy( )

						triggerServerEvent( "jeka_race_step_2", localPlayer )
					end,
					_, _, _, localPlayer:GetUniqueDimension( ),
					function( )
						iprint( getTickCount( ), "hit", localPlayer.vehicle )
						if not localPlayer.vehicle then
							return false, "Пешком собрался гонять?"
						end
						return true
					end )
				end,
			},

			event_end_name = "jeka_race_step_2",
		},

		{
			name = "Выиграть гонку",

			Setup = {
				client = function( )
					FadeBlink( 1.0 )
					StartQuestTimerFail( 3 * 60 * 1000, "Выиграть гонку", "Противник выиграл заезд!" )

					localPlayer.vehicle.rotation = Vector3( 359.395, 0.001, 187.829 )
					localPlayer.vehicle.frozen = true
					triggerEvent( "ShowStartSequence", localPlayer, 256 )
					
					local positions = QUEST_CONF.positions
					local path = TRACK.markers

					localPlayer.vehicle.position = positions.player_start
					localPlayer.vehicle.rotation = positions.player_start_rotation

					GEs.bot = CreateAIPed( 17, positions.enemy_start )
					LocalizeQuestElement( GEs.bot )
					SetUndamagable( GEs.bot, true )

					GEs.vehicle = createVehicle( 600, positions.enemy_start )
					GEs.vehicle.rotation = positions.enemy_start_rotation
					LocalizeQuestElement( GEs.vehicle )
					SetUndamagable( GEs.vehicle, true )
					setVehicleParameters( GEs.vehicle, 100, 100, 50 )

					GEs.vehicle_blip = createBlipAttachedTo( GEs.vehicle, 0, 2, 255, 0, 0, 255 )
					triggerEvent( "RefreshRadarBlips", localPlayer )

					warpPedIntoVehicle( GEs.bot, GEs.vehicle )
					ResetAIPedPattern( GEs.bot )

					local laps = 2
					local n, i = 0, 0
					local finish_i = 34 --laps * #path

					for i, v in pairs( path ) do
						v.speed_limit = 500
						v.distance = 20
					end
					--path[ 13 ].speed_limit = 10
					path[ 12 ].speed_limit = 15
					path[ 11 ].speed_limit = 30
					for i = 1, laps do
						for n = 1, #path do
							table.insert( path, path[ n ] )
						end
					end

					CEs.timer = setTimer( function( )
						localPlayer.vehicle.frozen = false
						SetAIPedMoveByRoute( GEs.bot, path, false )
					end, 5000, 1 )

					local t = { }
					t.CreateNextPath = function( )
						n = n + 1
						i = i + 1

						if n > #path then n = 1 end

						local v = path[ n ]

						if v then
							CEs.marker = createMarker( v.x, v.y, v.z, "checkpoint", 12, 255, 0, 0, 150 )
							LocalizeQuestElement( CEs.marker )

							addEventHandler( "onClientMarkerHit", CEs.marker, function( )
								CEs.marker:destroy( )

								iprint( n .. "/" .. finish_i )

								if i == finish_i then
									triggerServerEvent( "jeka_race_step_3", localPlayer )
								else
									t.CreateNextPath( )
								end

								
							end )
						end

					end

					t.CreateNextPath( )
				end,
			},

			event_end_name = "jeka_race_step_3",
		},

		{
			name = "Что-то странное...",

			Setup = {
				client = function( )
					StartQuestCutscene( )
					setCameraMatrix( 2041.4814453125, -197.40118408203, 68.044486999512, 1990.7268066406, -116.19543457031, 38.106910705566, 0, 70 )

					-- Статичная тачка
					CEs.car_1 = createVehicle( 580, Vector3( 2021.8740234375, -183.8095703125, 60.262104034424 ) )
					CEs.car_1.paintjob = 0
					CEs.car_1:setColor( 255, 255, 255 )
					CEs.car_1.rotation = Vector3( 359.93060302734, 0.039886474609375, 331.88046264648 )
					LocalizeQuestElement( CEs.car_1 )
					CEs.car_1:SetExternalTuningValue( TUNING_SIREN , 2 )

					-- Подвижная тачка
					CEs.car_2 = createVehicle( 580, Vector3( 2001.8452148438, -170.18286132813, 60.262714385986 ) )
					CEs.car_2.paintjob = 0
					CEs.car_2:setColor( 255, 255, 255 )
					CEs.car_2.rotation = Vector3( 359.93161010742, 0.050689697265625, 270.88726806641 )
					LocalizeQuestElement( CEs.car_2 )
					CEs.car_2:SetExternalTuningValue( TUNING_SIREN , 2 )

					CEs.bot_drive = CreateAIPed( 17, CEs.car_2.position )
					warpPedIntoVehicle( CEs.bot_drive, CEs.car_2 )
					ResetAIPedPattern( CEs.bot_drive )
					SetAIPedMoveByRoute( CEs.bot_drive, { { x = 2030.1104736328, y = -173.31756591797, z = 60.315204620361, speed_limit = 100 } }, false )

					-- Противник
					CEs.enemy_car = createVehicle( 600, Vector3( 2058.5666503906, -205.74676513672, 60.261951446533 ) )
					CEs.enemy_car.rotation = Vector3( 359.91195678711, 0.01434326171875, 44.943328857422 )
					LocalizeQuestElement( CEs.enemy_car )
					CEs.enemy_car.velocity = Vector3( -0.25, 0.25, 0 ) * 2

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					temp_vehicle.health = 1000
					temp_vehicle.position = Vector3(  2097.2023925781, -266.53839111328, 60.26388168335 )
					temp_vehicle.rotation = Vector3( 358.7265625, 4.1052856445313, 34.483703613281 )
					temp_vehicle.velocity = Vector3( -0.86494892835617, 1.2770793437958, 0.0006041040760465 )

					--outputConsole( "VELOCITY: " .. table.concat( { getElementVelocity( localPlayer.vehicle ) }, ", " ) )
					--outputConsole( "POSITION: " .. table.concat( { getElementPosition( localPlayer.vehicle ) }, ", " ) )
					--outputConsole( "ROTATION: " .. table.concat( { getElementRotation( localPlayer.vehicle ) }, ", " ) )
					CEs.slowdown_timer = setTimer( function( )
						setGameSpeed( 0.25 )
						CEs.slowdown_timer = setTimer( function( )
							setGameSpeed( 1 )
						end, 2000, 1 )
					end, 2500, 1 )

					CEs.bot_getaway = CreateAIPed( 17, CEs.enemy_car.position )
					warpPedIntoVehicle( CEs.bot_getaway, CEs.enemy_car )
					ResetAIPedPattern( CEs.bot_getaway )
					SetAIPedMoveByRoute( CEs.bot_getaway, {
						{ x = 2039.039, y = 673.239 - 860, z = 60.159, speed_limit = 1000, distance = 10 },
						{ x = 2028.156, y = 693.245 - 860, z = 60.091, speed_limit = 1000, distance = 10 },
						{ x = 2035.968, y = 722.057 - 860, z = 58.944, speed_limit = 1000, distance = 10 },
					}, false )

					-- Шипы
					CEs.stinger = createObject( 2899, Vector3( 2024.439, -177.564, 59.643 ),  Vector3( 0.000, 0.000, 335.000 ) )
					LocalizeQuestElement( CEs.stinger )

					-- Локальная тачка
					local vehicle = localPlayer.vehicle
					vehicle.position = Vector3( 2072.5886230469, -228.33813476563, 60.263160705566 )
					vehicle.rotation = Vector3( 359.93096923828, 0.02490234375, 31.902465820313 )
					vehicle.velocity = Vector3( -0.1, 0.25, 0 ) * 2
					setVehicleWheelStates( vehicle, 0, 0, 0, 0 )
					CreateAIPed( localPlayer )
					SetAIPedMoveByRoute( localPlayer, LoadPathIntoArray( "paths/path_crash.txt", 10, 10, 1000 ), false )

					CEs.colshape = ColShape.Sphere( Vector3( 2023.1604003906, -177.96295166016, 60.144123077393 ), 3 )
					addEventHandler( "onClientColShapeHit", CEs.colshape, function( element, dimension )
						if element == vehicle then
							setVehicleTurnVelocity( vehicle, 0, 0, 0.03 )
							setVehicleWheelStates( vehicle, 1, 1, 1, 1 )
						end
					end )
					
					CEs.timer = setTimer( function( )
						setCameraMatrix( 2016.9759521484, -169.28973388672, 60.088695526123, 1930.1394042969, -219.71813964844, 58.651908874512, 0, 70 )
						CEs.timer = setTimer( function( )
							fadeCamera( false, 2.0 )
							CEs.timer = setTimer( function( )
								triggerServerEvent( "jeka_race_step_4", localPlayer )
							end, 3000, 1 )
						end, 2000, 1 )
					end, 7500, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "jeka_race_step_4",
		},

		{
			name = "Что-то странное...",

			Setup = {
				server = function( player )
					removePedFromVehicle( player )
					triggerEvent( "jeka_race_step_5", player )
				end,
			},

			event_end_name = "jeka_race_step_5",
		},

		{
			name = "Что-то странное...",

			Setup = {
				client = function( )
					fadeCamera( false, 0.0 )
					StartQuestCutscene( { dialog = QUEST_CONF.dialogs.help } )
					setTimer( fadeCamera, 50, 1, true, 3.0 )
					CEs.dialog:next( )
					localPlayer.interior = 1
					localPlayer.position = Vector3( 2213.0246582031, 231.92813110352, 601.00189208984 )
					localPlayer.rotation = Vector3( 0, 0, 90.350677490234 )

					local bots = {
						{
							position = Vector3( 2210.884765625, 231.8717956543, 601.00189208984 ),
							rotation = Vector3( 0, 0, 277.38906860352 ),
							model = 254,
						},

						{
							position = Vector3( 2210.9897460938, 233.58050537109, 601.00189208984 ),
							rotation = Vector3( 0, 0, 236.67877197266 ),
							model = 144,
						},

						{
							position = Vector3( 2214.6640625, 233.00437927246, 601.00189208984 ),
							rotation = Vector3( 0, 0, 115.80346679688 ),
							model = 233,
						},
					}

					for i, v in pairs( bots ) do
						local bot = createPed( v.model, v.position )
						bot.rotation = v.rotation
						LocalizeQuestElement( bot )

						CEs[ "scene_bot_" .. i ] = bot
					end

					local from = { 2216.8562011719, 230.47811889648, 603.62670898438, 2135.08203125, 262.00927734375, 555.47296142578, 0, 70 }
					local to = { 2213.7604980469, 230.43719482422, 602.26281738281, 2145.724609375, 292.65170288086, 563.52703857422, 0, 70 }
					CEs.move = CameraFromTo( from, to, 8000 )

					CEs.timer = setTimer( function( )
						fadeCamera( false )
						CEs.timer = setTimer( function( )
							CEs.move:destroy( )
							FinishQuestCutscene( )
							triggerServerEvent( "jeka_race_step_6", localPlayer )
						end, 2000, 1 )
					end, 5000, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "jeka_race_step_6",
		},

		{
			name = "Что-то странное...",

			Setup = {
				client = function( )
					localPlayer.interior = 1
				end,
				server = function( player )
					player.interior = 1
					removePedFromVehicle( player )
					triggerEvent( "jeka_race_step_7", player )
				end,
			},

			event_end_name = "jeka_race_step_7",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Неизвестный номер", msg = "Приходи в отедление. Тебя ждут." },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "jeka_capture" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				money = 500,
				exp = 1000,
			}
		} )
	end,

	rewards = {
		money = 500,
		exp = 1000,
	},

	no_show_rewards = true,
}

--[[function CreateSmartDriver( ped )
	if not isPedInVehicle( ped ) then
		outputDebugString( "No ped specified for smart driver" )
		return
	end

	local self = { }

	local raycasts = { }
	local colors = { 0xffff0000, 0xff00ff00, 0xff0000ff, 0xffffff00, 0xffff00ff, 0xffffff00 }

	local function GetRelativeVector( element, vector )
		local matrix = getElementMatrix( element )

		return Vector3(
			vector.x * matrix[ 1 ][ 1 ] + vector.y * matrix[ 2 ][ 1 ] + vector.z * matrix[ 3 ][ 1 ],
			vector.x * matrix[ 1 ][ 2 ] + vector.y * matrix[ 2 ][ 2 ] + vector.z * matrix[ 3 ][ 2 ],
			vector.x * matrix[ 1 ][ 3 ] + vector.y * matrix[ 2 ][ 3 ] + vector.z * matrix[ 3 ][ 3 ]
		)
	end

	local function RaycastRelative( element, vector, distance )
		local distance = distance or 1
		local vector_normalized = GetRelativeVector( element, vector ):getNormalized( )
		local raycast_vector = vector_normalized * distance

		table.insert( raycasts, { element = element, vector = raycast_vector } )
	end

	local function GetGroundRay( vector, y_height, ignored_element )
		local px, py, pz = vector.x, vector.y, vector.z
		local hit, npx, npy, npz = processLineOfSight(
			px, py, pz + y_height,
			px, py, pz - 20,
			true, 
			true, 
			true, 
			true, 
			true, 
			false, 
			false, 
			false, 
			ignored_element,
			false,
			false
		)

		if hit then
			return Vector3( npx, npy, npz + ( y_height or 0 ) ), true
		else
			return Vector3( px, py, pz ), false
		end
	end

	local precision_points = 180
	local precision_step = 360 / precision_points
	local function GetHorizontalRays( vertical_offset )
		local rays = { }
		for i = 1, precision_points do
			local angle = math.rad( ( i - 1 ) * precision_step )
			local sin, cos = math.sin( angle ), math.cos( angle )

			--if cos > 0 then
				table.insert( rays, { ray = Vector3( sin, cos, vertical_offset or 0 ), distance = math.abs( cos ) } )
			--end
		end
		return rays
	end


	local required_rays = 6
	local function GetRaycastDirections( )
		local rays = { }
		for i, v in pairs( raycasts ) do
			local ray_point, ray_ground_casted = GetGroundRay( v.element.position + v.vector, 0.5, v.element )
			local hit = not isLineOfSightClear(
				v.element.position.x, v.element.position.y, v.element.position.z,
				ray_point.x, ray_point.y, ray_point.z,
				true,
				true,
				true,
				true,
				true,
				false,
				false,
				v.element
			)

			if not hit then
				v.ray_point = ray_point
				rays[ i ] = v
			end
		end

		local rays_filtered = { }
		local half = math.floor( required_rays / 2 )
		for i, v in pairs( rays ) do
			local empty = false
			for n = -half, half, 1 do
				if not rays[ i + n ] then
					empty = true
				end
			end
			if not empty then
				table.insert( rays_filtered, v )
			end
		end

		return rays_filtered
	end

	self.reset_raycasts = function( )
		raycasts = { }
	end

	self.draw_raycasts = function( )
		for i, v in pairs( GetRaycastDirections( ) ) do
			--if v.current then
				dxDrawLine3D( v.element.position, v.ray_point, v.color or 0x55ffffff, 2, true )
			--end
		end
	end
	addEventHandler( "onClientRender", root, self.draw_raycasts )

	self.destroy = function( )
		DestroyTableElements( self )
		setmetatable( self, nil )
	end

	self.follow = function( self, point )
		self.follow_point = point
	end

	self.check_follow = function( )
		if not isElement( ped ) then
			self:destroy( )
			return
		end

		if not self.follow_point then return end

		local vehicle = ped.vehicle
		if not vehicle then return end

		self:reset_raycasts( )

		for i, v in pairs( GetHorizontalRays( 0.1 ) ) do
			local ray = v.ray
			local distance = v.distance
			--RaycastRelative( vehicle, v, vehicle.velocity.length ^ 0.5 * 10 )
			RaycastRelative( vehicle, ray, 100  )
		end

		local vec_vehicle = vehicle.position
		local vec_direction = self.follow_point - vec_vehicle

		dxDrawLine3D( vehicle.position, self.follow_point, 0xffff0000, 2, true )

		local rays = GetRaycastDirections( )

		local function GetAngle( px, py )
			local angle = math.deg( math.atan2( py, px ) ) - 90
			if angle < 0 then angle = 360 + angle end
			return angle
		end

		local function GetRayRot( ray )
			return GetAngle( ray.x, ray.y )
		end

		local vehicle_rot = GetAngle( vec_direction.x, vec_direction.y )

		table.sort( rays, function( a, b )
			local rot_point_a = GetRayRot( a.ray_point - vec_vehicle )
			local rot_point_b = GetRayRot( b.ray_point - vec_vehicle )

			a.rot = rot_point_a
			b.rot = rot_point_b

			return math.abs( vehicle_rot - rot_point_a ) < math.abs( vehicle_rot - rot_point_b )
		end )

		for i, v in pairs( rays ) do
			v.color = tocolor( 255, 255, 255, ( #rays - i + 1 ) / #rays * 255 )
		end

		local ray = rays[ 1 ]

		local final_point = ray.ray_point

		ray.color = 0xff00ff00
		ray.current = true
		if vec_direction.length < 20 then
			final_point = self.follow_point
			ray.color = 0xff0000ff
		end

		setPedVehicleDriveTo( ped, vehicle, final_point.x, final_point.y, final_point.z, 50, 0, -1, 10, 0 )
		collectgarbage( )
	end

	self.timer = setTimer( self.check_follow, 500, 0 )

	return self
end]]