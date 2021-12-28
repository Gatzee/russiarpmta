CONST_MAYOR_RATING_REWARD = 25
CONST_MAYOR_RATING_FAILED = -50

CONST_CITY_ROUTE = {
	Vector3( 2200.816, -1236.111 + 860, 60.66 );
	Vector3( 2493.479, -1734.092 + 860, 73.922 );
	Vector3( 2303.822, -2349.203 + 860, 21.29 );
	Vector3( 1574.856, -1516.896 + 860, 29.504 );
	Vector3( 1825.838, -873.171 + 860, 60.699 );
	Vector3( 1939.289, -739.506 + 860, 60.777 );
	Vector3( 1917.735, -512.534 + 860, 60.717 );
	Vector3( 1635.283, -322.885 + 860, 27.661 );
	Vector3( 2195.359, -652.69 + 860, 60.716 );
	Vector3( 2423.475, -605.793 + 860, 60.767 );
	Vector3( 2416.132, -968.319 + 860, 60.552 );
	Vector3( 2244.52, -980.095 + 860, 60.66 );
}

QUEST_DATA = {
	training_id = "cityhall_rating_gorki";
	training_role = "mayor";

	title = "Объезд владений (Горки)";
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
					}, "training_cityhall_rating_gorki_mayor_end_step_1", _, true )
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
							triggerServerEvent( "training_cityhall_rating_gorki_mayor_end_step_2", localPlayer )
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