CONST_REWARD_EXP = 600

CONST_DAMAGE_ARMOR = 1000

CONST_CITY_ROUTE = {
	Vector3( 496.846, -2336.58, 20.836 ),
	Vector3( 482.93, -2319.658, 20.839 ),
	Vector3( 248.346, -2319.729, 20.845 ),
	Vector3( 232.777, -2291.964, 20.833 ),
	Vector3( 249.813, -1954.224, 20.836 ),
	Vector3( 223.596, -1925.122, 20.837 ),
	Vector3( -851.615, -1944.681, 20.871 ),
	Vector3( -868.299, -1927.634, 20.878 ),
	Vector3( -833.669, -1685.583, 20.867 ),
}

QUEST_DATA = {
	training_id = "ambassador_delivery";
	training_role = "driver";

	title = "Сопровождение посла";
	role_name = "Водитель";
	
	OnAnyFinish = {
		client = function( )
			removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
			removeEventHandler( "onClientPedDamage", root, Client_CancelPedInVehicleDamage )
		end,
		server = function ( player )

		end,
	},

	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 18, {
						{
							text = [[— Здравия желаю! Наша задача сопроводить посла,
									в целости и сохранности. Есть вероятность
									нападения со стороны преступных группировок.]];
						};
						{
							text = [[Твоя задача дождаться когда дорога будет
									свободной и доставить посла в аэропорт.
									Если хватит людей, в помощь тебе предоставят
									подставной автомобиль. Безопасное прибытие посла
									полностью на твоей ответственности.]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь, выйдешь из
									игры или посол будет убит, то учение будет
									автоматически провалено!]];
							info = true;
						};
					}, "training_ambassador_delivery_driver_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Забери посла";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 495.055, -2365.123, 20.800 ), "training_ambassador_delivery_driver_end_step_2", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
				end;
			};
		};
		[3] = {
			name = "Покинь город";

			Setup = {
				client = function( data )
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
					addEventHandler( "onClientPedDamage", root, Client_CancelPedInVehicleDamage )

					local route_current_index = 0

					CEs.func_next_point = function()
						if CEs.marker and isElement( CEs.marker.colshape ) then
							if not CheckPlayerQuestVehicle() then return end

							CEs.marker.destroy()
						end

						route_current_index = route_current_index + 1

						if route_current_index == 5 then
							localPlayer:ShowInfo( "Сообщение от агента: Преступным группировкам стало известно о после" )
						end

						if CONST_CITY_ROUTE[ route_current_index ] then
							CreateQuestPoint( CONST_CITY_ROUTE[ route_current_index ], CEs.func_next_point, _, 10, 0, 0 )
							CEs.marker.slowdown_coefficient = nil
							
							if CONST_CITY_ROUTE[ route_current_index + 1 ] then
								CEs.marker.marker:setTarget( CONST_CITY_ROUTE[ route_current_index + 1 ] )
							end
						else
							triggerServerEvent( "training_ambassador_delivery_driver_end_step_3", localPlayer )
						end
					end

					CEs.init_tmr = setTimer( function()
						table.insert( GEs, WatchElementCondition( localPlayer:getData( "quest_vehicle" ), {
							condition = function( self, conf )
								if self.element.health <= 370 or self.element.inWater then
									FailCurrentQuest( "Машина посла уничтожена!" )
									return true
								elseif self.element:GetFuel( ) <= 0 then
									FailCurrentQuest( "В машине посла закончилось топливо!" )
									return true
								end
							end,
						} ) )

						CEs.func_next_point()
					end, 2000, 1 )
				end;

				server = function( player, data )
					local vehicle = CreateTemporaryQuestVehicle( player, 445, 498.998, -2364.863, 20.832, 0, 0, 0 )
					vehicle:SetFuel("full")
					vehicle:SetWindowsColor(0, 0, 0, 230)
					vehicle:SetColor(0, 3, 0, 0)

					local number = data.random_number % 8 + 1
					vehicle:SetNumberPlate( "6:а90".. number .."099" )
					vehicle:setData( "secret_number", number, false )

					player:SetPrivateData( "all_damage", 0 )

					addVehicleSirens( vehicle, 2, 4, false, true, true, true )
					setVehicleSirens( vehicle, 1, -0.3, 2.7, 0, 255, 0, 0 )
					setVehicleSirens( vehicle, 2, 0.3, 2.7, 0, 0, 0, 255 )
					setVehicleSirensOn( vehicle, true )

					addEventHandler("onVehicleDamage", vehicle, function( loss )
						local all_damage = player:getData( "all_damage" ) or 0
						if loss > 5 then
							player:SetPrivateData( "all_damage", all_damage + loss )
						end

						if all_damage < CONST_DAMAGE_ARMOR then
							vehicle:setWheelStates( 0, 0, 0, 0 )
							vehicle.health = 1000
						end
					end)

					addEventHandler("onVehicleStartEnter", vehicle, function( enter_player, seat )
						if seat == 3 or isElement( jacked ) or enter_player:GetFaction() ~= F_POLICE_DPS_NSK or ( seat == 0 and enter_player ~= player ) then
							cancelEvent()
						end
					end)

					addEventHandler("onVehicleStartExit", vehicle, function( exit_player, seat )
						if exit_player == player and seat == 0 then
							cancelEvent()
						end
					end)

					player:warpIntoVehicle( vehicle )

					local ped = createPed( 194, 503.346, -2365.329, 21.326 )
					AddQuestElement( player, "ambassador_quest_ped", ped )
					setElementSyncer( ped, player )
					ped:warpIntoVehicle( vehicle, 3 )

					addEventHandler( "onPedWasted", ped, function()
						triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Посол погиб" } )
					end )

					player:SetPrivateData( "ambassador_quest_ped", ped )

					AlertAllClans( "Обнаружен автомобиль с послом, который следует из Новороссийска в аэропорт!" )
				end;
			};

			CleanUp = {
				client = function( data, failed )
					CEs.func_next_point = nil
				end;

				server = function( player, data, failed )
					if failed then
						player:SetPrivateData( "all_damage", false )
						player:SetPrivateData( "ambassador_quest_ped", false )
					end
				end;
			};
		};
		[4] = {
			name = "Доставь посла в аэропорт";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2481.924, 361.143, 15.389 ), "training_ambassador_delivery_driver_end_step_4", _, 10, 0, 0, CheckPlayerQuestVehicle )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					if isElement( vehicle ) then
						local secret_number = vehicle:getData( "secret_number" )
						AlertAllClans( "В номерном знаке автомобиля с послом присутствует цифра ".. secret_number .."!" )
					end

					addEventHandler( "OnPlayerFailedQuest", player, FailCreateGameAmbassador )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					player:SetPrivateData( "all_damage", false )
					player:SetPrivateData( "ambassador_quest_ped", false )
					
					removeEventHandler( "OnPlayerFailedQuest", player, FailCreateGameAmbassador )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}