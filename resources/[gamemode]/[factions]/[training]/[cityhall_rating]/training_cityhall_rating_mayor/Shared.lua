CONST_MAYOR_RATING_REWARD = 25
CONST_MAYOR_RATING_FAILED = -50

CONST_CITY_ROUTE = {
	Vector3( -1487.706, -1492.367 + 860, 21.016 );
	Vector3( -811.66, -1156.844 + 860, 15.785 );
	Vector3( -612.982, -1925.995 + 860, 20.789 );
	Vector3( -259.156, -1523.644 + 860, 20.81 );
	Vector3( -54.504, -1345.114 + 860, 20.597 );
	Vector3( 428.796, -1532.875 + 860, 20.975 );
	Vector3( 682.331, -1881.367 + 860, 20.963 );
	Vector3( 179.951, -1706.324 + 860, 21.022 );
	Vector3( -101.215, -1982.028 + 860, 20.802 );
	Vector3( 304.035, -2775.103 + 860, 20.602 );
	Vector3( -5.377, -1695.628 + 860, 20.813 );
}

QUEST_DATA = {
	training_id = "cityhall_rating";
	training_role = "mayor";

	title = "Объезд владений (НСК)";
	role_name = "Мэр";

	tasks = {
		[1] = {
			name = "Поговори с клерком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Добрый день! Для поднятия рейтинга власти
									среди народа, требуется выполнить объезд по
									основным точкам города.]];
						};
						{
							text = [[Если во времы выполнения данного задания
									вас убьют бандиты или сотрудники фракции,
									то рейтинг власти упадет на 50%. Но при
									успешно завершении задания, в зависимости
									от вашего финансирования “Агитация власти”,
									рейтинг власти будет увеличен.]];
							info = true;
						};
					}, "training_cityhall_rating_mayor_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Проследуй по маршруту";

			Setup = {
				client = function( data )
					local route_current_index = 0

					CEs.func_next_point = function()
						if CEs.marker and isElement( CEs.marker.colshape ) then
							if localPlayer.vehicle then
								localPlayer:ShowError( "Сначала покиньте транспорт" )
								return
							end

							CEs.marker.destroy()
						end

						route_current_index = route_current_index + 1

						if CONST_CITY_ROUTE[ route_current_index ] then
							CreateQuestPoint( CONST_CITY_ROUTE[ route_current_index ], CEs.func_next_point, _, 10, 0, 0 )
							CEs.marker.slowdown_coefficient = nil
							CEs.marker.allow_passenger = true
						else
							triggerServerEvent( "training_cityhall_rating_mayor_end_step_2", localPlayer )
						end
					end

					CEs.func_next_point()
				end;

				server = function( player )
					player.armor = 100
				end;
			};

			CleanUp = {
				client = function( data, failed )
					CEs.func_next_point = nil
				end;

				server = function( player, data, failed_data )
					if not failed_data or failed_data.type ~= "wasted" then return end

					local killer = failed_data.attacker
					if not isElement( killer ) or killer == player then return end

					if killer:IsInFaction( ) then
						if not killer:IsOnFactionDuty( ) then return end

						local killer_faction = killer:GetFaction()
						if FACTIONS_BY_CITYHALL[ killer_faction ] == killer_faction then return end

						local killer_faction_level = killer:GetFactionLevel()
						if killer_faction_level < 2 then return end

					elseif not killer:IsInClan( ) then
						return
					end

					local player_faction = player:GetFaction( )
					exports.nrp_factions_gov_voting:UpdateCityMayorRating( player_faction, CONST_MAYOR_RATING_FAILED )

					player:PhoneNotification( {
						title = FACTIONS_NAMES[ player_faction ];
						msg_short = "Рейтинг власти упал на ".. math.floor( CONST_MAYOR_RATING_FAILED ) .."%";
						msg = "Задание провалено. Рейтинг власти упал на ".. math.floor( CONST_MAYOR_RATING_FAILED ) .."%";
					} )
				end;
			};
		};
	};

	GiveReward = function( player )
		local player_faction = player:GetFaction( )
		if player_faction > 0 then
			local percent = exports.nrp_factions_gov_ui_control:GetMayorRatingEconomyPercent( player_faction )
			local chg_rating = CONST_MAYOR_RATING_REWARD * percent

			exports.nrp_factions_gov_voting:UpdateCityMayorRating( player_faction, chg_rating )

			player:PhoneNotification( {
				title = FACTIONS_NAMES[ player_faction ];
				msg_short = "Рейтинг власти вырос на ".. math.floor( chg_rating ) .."%";
				msg = "Задание выполнено. Вы повысили рейтинг власти на ".. math.floor( chg_rating ) .."%";
			} )
		end
	end;
}