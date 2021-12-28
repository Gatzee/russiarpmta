QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Анжела", voice_line = "Angela_1", text = "Привет, как ты?! Слышала про твою трагедию.\nЛучше потом расскажешь. Кстати, у нас в кинотеатре\nхороший ролик сейчас крутят. Пойдем сходим!" },
		},
		finish = {
			{ name = "Анжела", voice_line = "Angela_2", text = "А кстати, у меня подруга есть. По уши влюблена в тебя и жаждет встречи.\nЯ ей оставлю твой номер. Завтра тебе позвонит,\nзовут Ксюша. Вот кстати ее фотография." },
		},
	},

	positions = {
		vehicle_main_spawn = Vector3( 1959.6339111328, 604.90740966797, 60.404251098633 ),
		vehicle_main_spawn_rotation = Vector3( 0, 0, 226.5 ),

		cinema_target = Vector3( 2243.080, -511.017 +860, 61.274 ),
		cinema_inside = Vector3( -288.731, -357.419 +860, 1353.688 ),
		cinema_inside_angela = Vector3( -289.731, -357.419 +860, 1353.688 ),
		cinema_room_entrance = Vector3( -298.187, -399.641 +860, 1353.649 ),

		vehicle_spawn = Vector3( 1959.6339111328, 604.90740966797, 60.404251098633 ),
		vehicle_spawn_rotation = Vector3( 0, 0, 44 ),

		comeback_target = Vector3( 1955.665, -254.842 +860, 60.148 ),
		home_target = Vector3( 1966.096, -245.963 +860, 60.439 ),

		path = {
			{ x = -298.719, y = -399.635 +860, z = 1353.649, move_type = 4, },
			{ x = -303.672, y = -399.513 +860, z = 1353.531, move_type = 4, },
			{ x = -306.490, y = -396.224 +860, z = 1353.531, move_type = 4, },
			{ x = -306.571, y = -390.561 +860, z = 1355.166, move_type = 4, },
		}
	},
}

GEs = { }

QUEST_DATA = {
	id = "angela_cinema",
	is_company_quest = true,

	title = "Новый фильм",
	description = "Анжела всегда умела хорошо развлекаться. Нужно встретиться с ней и отвлечься.",
	--replay_timeout = 5;

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1951.2601, -249.4949 +860, 60.4046 ),

	quests_request = { "oleg_courier" },
	level_request = 2,

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
								triggerServerEvent( "angela_cinema_step_1", localPlayer )
							end, 9000, 1 )
						end
					} )
				end,
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 541, positions.vehicle_main_spawn, positions.vehicle_main_spawn_rotation )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 255, 0, 0 )
					vehicle:SetNumberPlate( "1:o746oo178" )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "angela" ).ped )
				end,
			},

			event_end_name = "angela_cinema_step_1",
		},

		{
			name = "Сесть в машину Анжелы",

			Setup = {
				client = function( )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть на водительское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return not localPlayer.vehicle and isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					HideNPCs( )

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


					local t = { }

					local function CheckBothInVehicle( )
						--iprint( "Check both in vehicle", localPlayer.vehicle, GEs.bot.vehicle )

						if localPlayer.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
							triggerServerEvent( "angela_cinema_step_2", localPlayer )
						end
					end

					AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
						vehicle = temp_vehicle;
						seat = 1;
						end_callback = {
							func = CheckBothInVehicle,
							args = { },
						}
					} )
						
					--GEs.follow = CreatePedFollow( GEs.bot )
					--GEs.follow:follow( localPlayer )

					t.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							cancelEvent( )
							localPlayer:ShowError( localPlayer:GetGender( ) == 0 and "Ты ж джентельмен, сам отвези девушку" or "Ты ж джентельбаба, сама отвези девушку" )
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

			event_end_name = "angela_cinema_step_2",
		},

		{
			name = "Доехать до кинотеатра",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.cinema_target, function( self, player )
						CEs.marker.destroy( )
						localPlayer.vehicle.engineState = false
						localPlayer.vehicle.frozen = true

						CreateAIPed( localPlayer )
						for i, v in pairs( { localPlayer, GEs.bot } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
						end

						CEs.fade_timer = setTimer( function( )
							fadeCamera( false, 2.0 )
						end, 1000, 1 )

						CEs.timer = setTimer( function( )
							triggerServerEvent( "angela_cinema_step_3", localPlayer )
						end, 4000, 1 )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Машину где забыл?"
						end
						return true
					end )
				end,
			},

			CleanUp = {
				client = function( )
					ClearAIPed( localPlayer )
				end,
			},

			event_end_name = "angela_cinema_step_3",
		},

		{
			name = "Зайти в кинозал",

			Setup = {
				client = function( )
					triggerEvent( "onPlayerRequestLoadCinemaTextures", localPlayer )
					local positions = QUEST_CONF.positions
					localPlayer.position = positions.cinema_inside
					localPlayer.interior = 1
					fadeCamera( true, 1.0 )

					GEs.bot.position = positions.cinema_inside_angela
					GEs.bot.interior = 1

					local follow = CreatePedFollow( GEs.bot )
					follow:start( localPlayer )

					CreateQuestPoint( positions.cinema_room_entrance, function( self, player )
						CEs.marker.destroy( )
						follow:destroy( )
						ClearAIPed( localPlayer )
						triggerServerEvent( "angela_cinema_step_4", localPlayer )
					end,
					_, _, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта"
						end
						return true
					end )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function( )
					triggerEvent( "onPlayerRequestUnloadCinemaTextures", localPlayer )
				end,
			},

			event_end_name = "angela_cinema_step_4",
		},

		{
			name = "Просмотри фильм",

			Setup = {
				client = function( )
					triggerEvent( "onPlayerRequestLoadCinemaTextures", localPlayer )
					StartCutscene( )
					localPlayer:setData( "block_phone", true, false )
					localPlayer:setData( "block_inventory", true, false )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.position = Vector3( 1961.3009033203, 607.72375488281, 60.404624938965 )
					vehicle.rotation = Vector3( 0, 0, 46 )
				end,
			},

			CleanUp = {
				client = function( )
					localPlayer.frozen = false
					GEs.bot.frozen = false
					triggerEvent( "onPlayerRequestUnloadCinemaTextures", localPlayer )
					localPlayer:setData( "block_phone", false, false )
					localPlayer:setData( "block_inventory", false, false )
				end,
			},

			event_end_name = "angela_cinema_step_5",
		},

		{
			name = "Отвези Анжелу домой",

			Setup = {
				client = function( )
					localPlayer.interior = 0
					GEs.bot.interior = 0

					local vehicle = localPlayer:getData( "temp_vehicle" )
					warpPedIntoVehicle( GEs.bot, vehicle, 1 )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.comeback_target, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "angela_cinema_step_6", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Где Анжела?"
						end
						return true
					end )
				end,
				server = function( player )
					player.interior = 0
					warpPedIntoVehicle( player, GetTemporaryVehicle( player ) )
					setCameraTarget( player, player )
				end,
			},

			CleanUp = {
				server = function( player )
					removePedFromVehicle( player )
				end,
			},

			event_end_name = "angela_cinema_step_6",
		},

		{
			name = "Поговорить с Анжелой",

			Setup = {
				client = function( )
					ShowNPCs( )
					StartQuestCutscene( {
						id = "angela",
						dialog = QUEST_CONF.dialogs.finish,
						local_dimension = true,
					} )
					CEs.dialog:next( )
					StartPedTalk( FindQuestNPC( "angela" ).ped, nil, true )

					setTimerDialog( function()
						showCursor( true )
						CEs.dialog:destroy_with_animation( )

						local bg = ibCreateBackground( _, _, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 750 )
						local img = ibCreateImage( 0, 0, 0, 0, "img/phone_ksusha.png", bg ):ibSetRealSize( ):center( )
						
						CEs.btn_close = ibCreateButton(	img:ibGetAfterX( 20 ), img:ibGetBeforeY( ), 24, 24, bg,
                                                    	":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    	0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick()
								showCursor( false )
								bg:ibAlphaTo( 0, 750 ):ibTimer( function( self )
									destroyElement( self )
									triggerServerEvent( "angela_cinema_step_7", localPlayer )
								end, 750, 1 )
							end )
					end, 11000, 1 )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "angela" ).ped )
				end,
			},

			event_end_name = "angela_cinema_step_7",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Александр", msg = "Привет, у меня еще одна проблема осталась. Приезжай скорее. Открыть журнал квестов F2." },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "alexander_debt" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)
		player:SituationalPhoneNotification(
			{ title = "Колесо фортуны", msg = "Ты получил жетон для колеса фортуны!", special = "roulette_spin_earned" },
			{
				condition = function( self, player, data, config )
					return getRealTime( ).timestamp - self.ts >= 10
				end,
				save_offline = true,
			}
		)
		player:GiveCoins( 1, "default", "QUEST_COIN", "NRPDszx5x" )

		player:GiveCase( player:GetGender( ) == 0 and "gold_a" or "gold_b", 1 )
		triggerClientEvent( player, "ShowFirstCaseGift", player )

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				exp = 1500,
			}
		} )
		

		triggerEvent( "StartPlayerGiftWait", player, player, 1 )
	end,

	rewards = {
		exp = 1500,
	},
	no_show_rewards = true,
}

VIDEO_ID = "wKbYYUfU2yk"
VIDEO_DURATION = ( 4 * 60 + 45 ) * 1000 + 3 * 1000

function StartCutscene( )
	FadeBlink( 1.0 )

	local position = QUEST_CONF.positions.path[ 1 ]
	local position_vec = Vector3( position.x, position.y, position.z )

	local stripes = CreateBlackStripes( )
	stripes:show( )
	DisableHUD( true )

	localPlayer.position = position_vec
	CreateAIPed( localPlayer )

	GEs.bot.position = position_vec
	LocalizeQuestElement( GEs.bot )

	setCameraMatrix( -311.90234375, -392.67691040039, 1354.6540527344, -258.69509887695, -477.05075073242, 1347.580078125, 0, 70 )
	local to = { -313.59683227539, -394.56491088867, 1354.6540527344, -228.04699707031, -445.90600585938, 1347.9222412109, 0, 70 }
	local camera_move = CameraFromTo( _, to, 20000 )
	setTimer( function( )
		triggerEvent( "CreateCinemaDimmer", localPlayer )
	end, 6000, 1 )

	SetAIPedMoveByRoute( GEs.bot, QUEST_CONF.positions.path, false )
	SetAIPedMoveByRoute( localPlayer, QUEST_CONF.positions.path, false )
	
	setTimer( function( )
		fadeCamera( false, 1.0 )
		setTimer( function( )
			stripes:destroy_with_animation( )
			camera_move:destroy( )

			ApplyBrowserToScreens( VIDEO_ID )
			setCameraMatrix( -308.98547363281, -392.31085205078, 1356.6986083984, -315.88513183594, -492.06411743164, 1357.9943847656, 0, 70 )
			fadeCamera( true, 1.0 )
			setTimer( FinishCutscene, VIDEO_DURATION, 1 )
			localPlayer.frozen = true
			GEs.bot.frozen = true
		end, 2000, 1 )
	end, 8000, 1 )
end

function FinishCutscene( )
	fadeCamera( false, 2.0 )
	setTimer( function( )
		local stripes = CreateBlackStripes( )
		stripes:show( )
		DisableHUD( true )
		localPlayer.interior = 0
		fadeCamera( true, 2.0 )

		local from = { 2253.876953125, -521.07537841797, 99.47346496582, 2275.0749511719, -426.31079101563, 121.40201568604, 0, 70 }
		local to = { 2259.0266113281, -525.01232910156, 60.773296356201, 2185.7966308594, -458.68997192383, 68.329925537109, 0, 70 }

		local camera_move = CameraFromTo( from, to, 9000, "InOutQuad", function( )
			stripes:destroy_with_animation( )
			FadeBlink( 1.0 )
			DisableHUD( false )
			triggerServerEvent( "angela_cinema_step_5", localPlayer )
		end )
	end, 4000, 1 )
end

local SHADER_CODE = [[
	texture gTexture;

	technique TexReplace
	{
		pass P0
		{
			Texture[0] = gTexture;
		}
	}
]]

function ApplyBrowserToScreens( link )
	GEs.browser = createBrowser( 1920, 1080, false )

	addEventHandler( "onClientBrowserCreated", GEs.browser, function( )
		GEs.shader = dxCreateShader( SHADER_CODE, 1, 40 )
    	dxSetShaderValue( GEs.shader, "gTexture", GEs.browser )
		engineApplyShaderToWorldTexture( GEs.shader, "k_teatr20" )

		GEs.timer = setTimer( function( ) setBrowserVolume( GEs.browser, 1.0 ) end, 500, 0 )

		local url = URLAppendParameters( "http://ytscraper.gamecluster.nextrp.ru/proxy", {
            url = link,
			start = 0,
		} )
		loadBrowserURL( GEs.browser, url )
	end )

    return GEs.shader
end

function RemoveBrowserFromScreens( )
    DestroyTableElements( { GEs.browser, GEs.shader, GEs.timer } )
    GEs.browser, GEs.shader, GEs.timer = nil, nil, nil
end

function URLAppendParameters( url, parameters )
    local get_str = ""

    local n = 1
    for i, v in pairs( parameters ) do
        local i, v = tostring( i ), tostring( v )
        if n ~= 1 then
            get_str = get_str .. "&"
        else
            get_str = get_str .. "?"
        end
        get_str = get_str .. urlencode( i ) .. "=" .. urlencode( v )
        n = n + 1
    end

    return url .. get_str
end

local char_to_hex = function( c )
    return string.format( "%%%02X", utf8.byte( c ) )
end
function urlencode( url )
    if url == nil then return end
    url = url:gsub( "\n", "\r\n" )
    url = url:gsub( "([^%w ])", char_to_hex )
    url = url:gsub( " ", "+" )
    return url
end