CONST_REQUEST_TIMER = 5000
CONST_REWARD_EXP = 500

CONST_PPS_POINTS = {
	[ 1 ] = Vector3( -338.8296, -1671.2895 + 860, 20.7561 );
	[ 2 ] = Vector3( 1929.3632, -716.3528 + 860, 60.7831 );
	[ 3 ] = Vector3( 1220.387, 2201.056 + 860, 8.810 );
}

CONST_PRISON_POINT = {
	[ 1 ] = Vector3( -2495.3583, 1854.9687 + 860, 14.0858 );
	[ 2 ] = Vector3( -2395.7385, 1724.07 + 860, 14.0858 );
	[ 3 ] = Vector3( -2460.163, 1624.9587 + 860, 14.0858 );
}

QUEST_DATA = {
	id = "task_fsin_2";

	title = "Перевозка заключенных";
	description = "";

	replay_timeout = 0;

	tasks = {
		[1] =
		{
			name = "Поговори с лейтенантом";

			Setup =
			{
				client = function()

					CURRENT_JAILED_PLAYERS = nil
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Здравия желаю. Твоя задача перевезти заключенных
							из КПЗ в основную тюрьму, не допустив их побега.
							Бери служебный микроавтобус и забери заключенных. ]];
						};
					}, "task_fsin_2_end_step_1", _, true )

				end;
			};
		};
		[2] =
		{
			name = "Садись в микроавтобус ФСИН";

			Setup =
			{
				server = function( player )
					TARGET_GET_JAIL_ID[ player ] = nil
					removeEventHandler( "onPlayerVehicleEnter", player, onPlayerVehicleEnter_handler )
					addEventHandler( "onPlayerVehicleEnter", player, onPlayerVehicleEnter_handler )
				end;
			};
			CleanUp =
			{
				server = function( player )
					removeEventHandler( "onPlayerVehicleEnter", player, onPlayerVehicleEnter_handler )
				end;
			};
		};
		[3] =
		{
			name = "Отправляйся за заключенными";

			Setup =
			{
				client = function( data )
					CreateQuestPoint( CONST_PPS_POINTS[ TARGET_GET_JAIL_ID ], "task_fsin_2_end_step_3", _, 4, 0, 0, checkPlayerFactionVehicle )
					CEs.marker.allow_passenger = true
				end;
			};
		};
		[4] =
		{
			name = "Ожидай погрузки заключенных в машине";

			Setup =
			{
				client = function()

					WAIT_GET_PLAYERS_TIMER = setTimer( function()
						if CURRENT_JAILED_PLAYERS then
							killTimer( WAIT_GET_PLAYERS_TIMER )
							CEs.shape:destroy()
							triggerServerEvent( "task_fsin_2_end_step_4", localPlayer )
						end
					end, CONST_REQUEST_TIMER + 1000, 0 )

					CEs.shape = createColSphere( localPlayer.position, 40 )
					addEventHandler( "onClientColShapeLeave", CEs.shape, function( player )
						if localPlayer ~= player then return end
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Вы покинули зону ожидания" } )
					end )

				end;

				server = function( player )

					TIMER_REQUEST_JAIL[ player ] = setTimer( function( player )

						local jailedData, targetPlayers  = getAvailableJailedPlayersToPrison( TARGET_GET_JAIL_ID[ player ] )
						if #jailedData > 0 then

							if not isElement( player ) or not FSIN_QUEST_PLAYERS[ player ] then
								killTimer( TIMER_REQUEST_JAIL[ player ] )
								onBasedPlayerLeaveQuest( player )
								TIMER_REQUEST_JAIL[ player ] = nil
								TIMER_REQUEST_JAIL[ player ] = nil
								TARGET_GET_JAIL_ID[ player ] = nil
								FSIN_QUEST_PLAYERS[ player ] = nil
								return
							end

							local vehicle = getPedOccupiedVehicle( player )
							local ownerVehicle = exports.nrp_faction_vehicles:GetVehicleOwner( vehicle )
							
							if player == ownerVehicle and checkPlayerFactionVehicle( player, vehicle ) then
								
								--Вешаем обработчик на случай выхода/смерти игрока, за которым зарегана машина
								addEventHandler( "onPlayerWasted", player, onBasedPlayerLeaveQuest )
								addEventHandler( "onPlayerQuit", player, onBasedPlayerLeaveQuest )

								for _, v in pairs( FSIN_QUEST_PLAYERS[ player ] ) do
									if isTimer( TIMER_REQUEST_JAIL[ v ] ) then
										killTimer( TIMER_REQUEST_JAIL[ v ] )
									end
								end

								local targetJailId = math.random( 1, 3 )
								TARGET_TO_PLAYERS_JAIL_ID[ player ] = targetJailId

								local seatId = 2
								local target_jailed_players = {}
								
								triggerClientEvent( targetPlayers, "onPlayerWarpIntoFsinVehicle", player )
								
								for k, v in pairs( jailedData ) do
									
									if v.player:getData( "jailed" ) == true then
										exports.nrp_jail:ReleasePlayer( false, v.player, "Транспортировка в тюрьму", true, true )
										jailedData[ k ].data.jail_id = targetJailId

										fadeCamera( v.player, false, 0 )
										setTimer( fadeCamera, 50, 1, v.player, true, 1 )

										v.player:warpIntoVehicle( vehicle, seatId > 3 and math.random( 2, 3 ) or seatId )
										v.player:setDimension( 0 )
										v.player:setInterior( 0 )

										table.insert( target_jailed_players, jailedData[ k ] )
										
										seatId = seatId + 1

									end
									
								end

								for k, v in pairs( FSIN_QUEST_PLAYERS[ player ] ) do
									v:SetPrivateData( "fsin_quest_vehicle", vehicle )
								end


								FSIN_JAILED_PLAYERS[ player ] = target_jailed_players
								
								--Учитываем тот случай, что игроки могут выйти во время перевозки, сразу сажаем в тюрьму
								triggerEvent( "onServerImrisonJailedPlayers", player, FSIN_JAILED_PLAYERS[ player ] )

								--Сообщаем сотрудникам ФСИН о том, что есть доступные игроки для перевозки
								triggerClientEvent( FSIN_QUEST_PLAYERS[ player ], "onClientQuestFsin_1TargetJailPlayers", player,
									TARGET_TO_PLAYERS_JAIL_ID[ player ], FSIN_JAILED_PLAYERS[ player ], FSIN_QUEST_PLAYERS[ player ] )
								
							end

						end

					end, CONST_REQUEST_TIMER, 0, player )

				end;
			};

			CleanUp =
			{
				--Если квест был провален, то уничтожаем таймеры, зануляем данные
				client = function()
					if isTimer( WAIT_GET_PLAYERS_TIMER ) then
						killTimer( WAIT_GET_PLAYERS_TIMER )
						WAIT_GET_PLAYERS_TIMER = nil
					end
				end;
				server = function( player )

					removeEventHandler( "onPlayerWasted", player, onBasedPlayerLeaveQuest )
					removeEventHandler( "onPlayerQuit", player, onBasedPlayerLeaveQuest )

					if isTimer( TIMER_REQUEST_JAIL[ player ] ) then
						killTimer( TIMER_REQUEST_JAIL[ player ] )

						TIMER_REQUEST_JAIL[ player ] = nil
						TARGET_GET_JAIL_ID[ player ] = nil
						FSIN_QUEST_PLAYERS[ player ] = nil
					end
				end;
			};
		};
		[5] =
		{
			name = "Отвези заключенных в тюрьму";

			Setup =
			{
				client = function()

					for k, v in pairs( CURRENT_JAILED_PLAYERS ) do
						removeEventHandler( "onPlayerWasted", v.player, onJailedPlayerLeaved )
						removeEventHandler( "onPlayerQuit", v.player, onJailedPlayerLeaved )
						addEventHandler( "onClientPlayerWasted", v.player, onJailedPlayerLeaved )
						addEventHandler( "onClientPlayerQuit", v.player, onJailedPlayerLeaved )
					end

					StartQuestTimerFail( 10 * 60 * 1000, "Доставь заключенных", "Слишком медленно!" )
					CreateQuestPoint( CONST_PRISON_POINT[ TARGET_TO_JAIL_ID ], function()
						local vehicle = getPedOccupiedVehicle( localPlayer ) 
						if vehicle == localPlayer:getData( "fsin_quest_vehicle" ) then
							triggerServerEvent( "task_fsin_2_end_step_5", localPlayer )
							localPlayer:setData( "fsin_quest_vehicle", nil, false )
						end
					end, _, 4, 0, 0, checkPlayerFactionVehicleWithoutCount )
					CEs.marker.allow_passenger = true

				end;
			};

			CleanUp =
			{
				client = function()

					for k, v in pairs( CURRENT_JAILED_PLAYERS ) do
						removeEventHandler( "onClientPlayerWasted", v.player, onJailedPlayerLeaved )
						removeEventHandler( "onClientPlayerQuit", v.player, onJailedPlayerLeaved )
					end

					TARGET_GET_JAIL_ID = 1
					TARGET_TO_JAIL_ID = 1
					WAIT_GET_PLAYERS_TIMER = nil
					CURRENT_FSIN_PLAYERS = nil
					CURRENT_JAILED_PLAYERS = nil

				end;
				server = function( player )

					removeEventHandler( "onPlayerWasted", player, onBasedPlayerLeaveQuest )
					removeEventHandler( "onPlayerQuit", player, onBasedPlayerLeaveQuest )
					
					if FSIN_JAILED_PLAYERS[ player ] then
						triggerEvent( "onServerJailedPlayerDeliveredToPrison", player, FSIN_JAILED_PLAYERS[ player ] )
					end

					FSIN_QUEST_PLAYERS[ player ] = nil
					FSIN_JAILED_PLAYERS[ player ] = nil
					TARGET_TO_PLAYERS_JAIL_ID[ player ] = nil
					TARGET_GET_JAIL_ID[ player ] = nil

				end;
			};
		}
	};
	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_fsin_2", CONST_REWARD_EXP )
	end;
	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}

