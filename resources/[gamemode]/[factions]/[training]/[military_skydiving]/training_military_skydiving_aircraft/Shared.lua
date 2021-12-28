CONST_REWARD_EXP = 400

QUEST_DATA = {
	training_id = "military_skydiving";
	training_role = "aircraft";

	title = "Прыжки с парашютом";
	role_name = "Пилот самолёта";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Здравия желаю! Мы получили разрешение на
									отработку прыжков с парашютом. Сейчас самое время
									для их выполнения, пока ветер не усилился.]];
						};
						{
							text = [[Твоя задача забрать бойцов и добраться до
									точки высадки, отмеченной на карте областью
									синего цвета. Успей вовремя открыть и
									закрыть рампу!]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь, выйдешь из
									игры или твой самолёт будет поврежден, то
									учение будет автоматически провалено!]];
							info = true;
						};
					}, "training_military_skydiving_aircraft_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Прибудь в аэропорт";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2510.885, 334.642, 16.023 ), "training_military_skydiving_aircraft_end_step_2", _, 2, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Получи самолёт";

			Setup = {
				client = function( data )
					ShowDialogMessage( 14, {
						{
							text = [[Открой рампу, используя “Num 2”, чтобы
									бойцы могли начать загрузку в самолёт.]];
							info = true;
						};
					}, "training_military_skydiving_aircraft_end_step_3" )
				end;

				server = function( player, data )
					local vehicle = CreateTemporaryQuestVehicle( player, 592, -2586.595, 380.538, 16.480, 0, 0, 58 )
					vehicle:SetFuel("full")
					player:warpIntoVehicle( vehicle )

					addEventHandler("onVehicleDamage", vehicle, function()
						if vehicle.health < 900 then
							triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Вы повредили самолёт" } )
						end
					end)

					addEventHandler("onVehicleStartEnter", vehicle, function( enter_player )
						if enter_player ~= player then
							cancelEvent()
						end
					end)

					addEventHandler("onVehicleStartExit", vehicle, function( exit_player, seat )
						if exit_player == player and seat == 0 then
							cancelEvent()
						end
					end)

					player:GiveWeapon( 46, 1, true, true )
				end;
			};
		};
		[4] = {
			name = "Открой рампу";

			Setup = {
				client = function( data )
					local vehicle = localPlayer:getData( "quest_vehicle" )
					if not isElement( vehicle ) then return end

					local timer_check_ramp_state = Timer( function()
						if not isElement( vehicle ) then return end
						
						if getVehicleAdjustableProperty( vehicle ) >= 2500 then
							ShowDialogMessage( 14, {
								{
									text = [[Дождись пока все бойцы загрузятся и только
											потом закрывай рампу, используя клавишу “Num 8”.]];
									info = true;
								};
							}, "training_military_skydiving_aircraft_end_step_4" )
							killTimer( sourceTimer )
						end
					end, 250, 0 )
					AddCustomTimer( timer_check_ramp_state )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					if not isElement( vehicle ) then return end

					vehicle:SetStatic( true )
				end;
			};
		};
		[5] = {
			name = "Дождись окончания загрузки десанта";

			Setup = {
				client = function( data )
					local timer_check_ramp_state = Timer( function()
						local vehicle = localPlayer:getData( "quest_vehicle" )
						if not isElement( vehicle ) then return end
						
						if getVehicleAdjustableProperty( vehicle ) < 2300 then
							triggerServerEvent( "training_military_skydiving_aircraft_end_step_5", localPlayer )
						end
					end, 250, 0 )
					AddCustomTimer( timer_check_ramp_state )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					if not isElement( vehicle ) then return end

					local enter_marker = createMarker( Vector3( -2570.113, 370.167, 14.304 ), "cylinder", 1.5, 100, 250, 100, 150 )
					AddQuestElement( player, "ramp_enter_marker", enter_marker )
					--attachElements( enter_marker, vehicle, 0, -20, -1.8 )
		
					addEventHandler( "onMarkerHit", enter_marker, function( player, dim )
						if not dim then return end
						if getElementType( player ) ~= "player" then return end
						if player.vehicle then return end
						if player:GetFaction() ~= F_ARMY then return end
		
						local current_quest = player:getData( "current_quest" )
						if not current_quest or current_quest.id ~= "training_military_skydiving_s_skydiver" then return end
		
		
						local skydivers = vehicle:getData( "skydivers" ) or { }
						skydivers[ player ] = true
						vehicle:setData( "skydivers", skydivers, false )
		
						player:setData( "in_aircraft", vehicle, false )
						attachElements( player, vehicle, 0, 0, 0 )
						toggleAllControls( player, false, true, false )
						setCameraTarget( player, vehicle.controller )
					end )
				end;
			};
		};
		[6] = {
			name = "Закрой рампу полностью";

			Setup = {
				client = function( data )
					local timer_check_ramp_state = Timer( function()
						local vehicle = localPlayer:getData( "quest_vehicle" )
						if not isElement( vehicle ) then return end
						
						if getVehicleAdjustableProperty( vehicle ) == 0 then
							triggerServerEvent( "training_military_skydiving_aircraft_end_step_6", localPlayer )
						end
					end, 250, 0 )
					AddCustomTimer( timer_check_ramp_state )
				end;

				server = function( player, data )
					DeleteQuestElement( player, "ramp_enter_marker" )
				end;
			};

			CleanUp = {
				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					if not isElement( vehicle ) then return end

					vehicle:SetStatic( false )
				end;
			}
		};
		[7] = {
			name = "Проследуй до точки десантирования";

			Setup = {
				client = function( data )
					CEs.checkpoint = TeleportPoint( { x = 318.751, y = -2587.506, z = 600, radius = 30, gps = true, keypress = false } )
					CEs.checkpoint.accepted_elements = { player = true, vehicle = true }
					CEs.checkpoint.marker.markerType = "ring"
					CEs.checkpoint.marker:setColor(100, 100, 250, 150)
					CEs.checkpoint.marker:setTarget(338.751, -2587.506, 600)
					CEs.checkpoint.slowdown_coefficient = nil
					CEs.checkpoint.elements = {}
					CEs.checkpoint.elements.blip = createBlipAttachedTo(CEs.checkpoint.marker, 0, 5, 100, 100, 255)

					CEs.checkpoint.PostJoin = function()
						if CheckPlayerInAircraft() then
							CEs.checkpoint.destroy()
							triggerServerEvent( "training_military_skydiving_aircraft_end_step_7", localPlayer )
						end
					end

					CEs.radar_area = createRadarArea( 0, -2687.506, 1600, 200, 100, 100, 250, 150 )
					CEs.radar_area:setFlashing( true )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						player.position = Vector3( -2500.613, 328.088, 15.303 ) + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )
					end
				end;
			};
		};
		[8] = {
			name = "Выгрузи десант";

			Setup = {
				client = function( data )
					local vehicle = localPlayer:getData( "quest_vehicle" )
					setVehicleAdjustableProperty( vehicle, 0 )

					CEs.radar_area = createRadarArea( 0, -2687.506, 1600, 200, 100, 100, 250, 150 )
					CEs.radar_area:setFlashing( true )

					StartQuestTimerWait( 10000, "Открой рампу. До высадки:", "Ты не успел открыть рампу!", "training_military_skydiving_aircraft_end_step_8", function()
						local vehicle = localPlayer:getData( "quest_vehicle" )
						if not isElement( vehicle ) then return false end
						
						return getVehicleAdjustableProperty( vehicle ) >= 2000
					end )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						player.position = Vector3( -2500.613, 328.088, 15.303 ) + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )
					end
				end;
			};
		};
		[9] = {
			name = "Посади самолет в аэропорту";

			Setup = {
				client = function( data )
					StartQuestTimerWait( 10000, "Закрой рампу", "Ты не успел закрыть рампу!", _, function()
						local vehicle = localPlayer:getData( "quest_vehicle" )
						if not isElement( vehicle ) then return false end
						
						return getVehicleAdjustableProperty( vehicle ) <= 600
					end )

					CreateQuestPoint( Vector3( -2586.595, 380.538, 16.480 ), "training_military_skydiving_aircraft_end_step_9", _, 6, 0, 0, CheckPlayerInAircraft )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					if not isElement( vehicle ) then return end

					local skydivers = vehicle:getData( "skydivers" ) or { }
					for skydiver, _ in pairs( skydivers ) do
						if isElement( skydiver ) and skydiver:getData( "in_aircraft" ) then
							detachElements( skydiver )
							toggleAllControls( skydiver, true )
							skydiver.position = vehicle.position + Vector3( math.random( -15, -10 ), math.random( 2, 5 ), -2 )
							setCameraTarget( skydiver )
							skydiver:setData( "in_aircraft", false, false )
						end
					end

					vehicle:setData( "skydivers", false, false )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						player.position = Vector3( -2500.613, 328.088, 15.303 ) + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )
					end
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}

function CheckPlayerInAircraft()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
		localPlayer:ShowError( "Ты не в самолёте" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не пилот" )
		return false
	end

	return true
end