CONST_REWARD_EXP = 400

CONST_START_POINTS = {
	Vector3( -2555.406, 426.377, 16.944 );
	Vector3( -2528.498, 474.942, 16.891 );
}

CONST_PICKUP_POINTS = {
	Vector3( 1110.313, -2710.396, 21.845 );
	Vector3( 1073.104, -2720.818, 21.136 );
}


QUEST_DATA = {
	training_id = "military_skydiving";
	training_role = "heli";
	training_parent = "aircraft";

	title = "Прыжки с парашютом";
	role_name = "Пилот вертолёта";
	
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
							text = [[Твоя задача забрать бойцов из точки высадки и 
									вернуться в аэропорт. Учти, что максимальная
									загрузка твоего вертолета 10 человек.]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь, выйдешь из
									игры или твой вертолёт будет поврежден, то
									учение будет автоматически провалено!]];
							info = true;
						};
					}, "training_military_skydiving_heli_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Прибудь в аэропорт";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2510.885, 334.642, 16.023 ), "training_military_skydiving_heli_end_step_2", _, 2, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Прибудь на место высадки";

			Setup = {
				client = function( data )
					CreateQuestPoint( CONST_PICKUP_POINTS[ data.slot % #CONST_PICKUP_POINTS + 1 ], "training_military_skydiving_heli_end_step_3", _, 3, 0, 0, CheckPlayerInHeli )
				end;

				server = function( player, data )
					local position = CONST_START_POINTS[ data.slot % #CONST_START_POINTS + 1 ]
					local vehicle = CreateTemporaryQuestVehicle( player, 548, position.x, position.y, position.z, 0, 0, 58 )
					vehicle:SetFuel("full")
					player:warpIntoVehicle( vehicle )

					addEventHandler("onVehicleDamage", vehicle, function()
						if vehicle.health < 700 then
							triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Вы повредили вертолёт" } )
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

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						player.position = Vector3( -2500.613, 328.088, 15.303 ) + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )
					end
				end;
			};
		};
		[4] = {
			name = "Дождись окончания загрузки десанта";
			requests = {
				{ "aircraft", 8 };
			};

			Setup = {
				client = function( data )
					local timer_check_ramp_state = Timer( function()
						local vehicle = localPlayer:getData( "quest_vehicle" )
						if not isElement( vehicle ) then return end
						
						if vehicle.position.z > CONST_PICKUP_POINTS[ data.slot % #CONST_PICKUP_POINTS + 1 ].z + 6 then
							triggerServerEvent( "training_military_skydiving_heli_end_step_4", localPlayer )
						end
					end, 250, 0 )
					AddCustomTimer( timer_check_ramp_state )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					if not isElement( vehicle ) then return end

					local enter_marker = createMarker( vehicle.position, "cylinder", 2, 100, 250, 100, 150 )
					AddQuestElement( player, "ramp_enter_marker", enter_marker )
					attachElements( enter_marker, vehicle, 0, -4, -2.5 )

					local skydivers_count = 0
		
					addEventHandler( "onMarkerHit", enter_marker, function( player, dim )
						if not dim then return end
						if getElementType( player ) ~= "player" then return end
						if player.vehicle then return end
						if player:GetFaction() ~= F_ARMY then return end

						if skydivers_count == 10 then
							player:ShowError( "В вертолёте нет свободных мест, садитесь в другой" )
							return
						end
		
						local current_quest = player:getData( "current_quest" )
						if not current_quest or current_quest.id ~= "training_military_skydiving_s_skydiver" then return end
		
		
						local skydivers = vehicle:getData( "skydivers" ) or { }
						skydivers[ player ] = true
						vehicle:setData( "skydivers", skydivers, false )

						skydivers_count = skydivers_count + 1
		
						player:setData( "in_helicopter", vehicle, false )
						attachElements( player, vehicle, 0, 0, -1 )
						toggleAllControls( player, false, true, false )
						setCameraTarget( player, vehicle.controller )
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
		[5] = {
			name = "Посади вертолёт в аэропорту";

			Setup = {
				client = function( data )
					CreateQuestPoint( CONST_START_POINTS[ data.slot % #CONST_START_POINTS + 1 ], "training_military_skydiving_heli_end_step_5", _, 2, 0, 0, CheckPlayerInHeli )
				end;

				server = function( player, data )
					DeleteQuestElement( player, "ramp_enter_marker" )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						player.position = Vector3( -2500.613, 328.088, 15.303 ) + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )
					else
						local vehicle = player:getData( "quest_vehicle" )
						if not isElement( vehicle ) then return end

						local skydivers = vehicle:getData( "skydivers" ) or { }
						for skydiver, _ in pairs( skydivers ) do
							if isElement( skydiver ) and skydiver:getData( "in_helicopter" ) then
								detachElements( skydiver )
								toggleAllControls( skydiver, true )
								skydiver.position = vehicle.position + Vector3( math.random( -10, -5 ), math.random( -10, -5 ), 0 )
								setCameraTarget( skydiver )
								skydiver:setData( "in_helicopter", false, false )
							end
						end

						vehicle:setData( "skydivers", false, false )
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

function CheckPlayerInHeli()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
		localPlayer:ShowError( "Ты не в вертолёте" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не пилот" )
		return false
	end

	return true
end