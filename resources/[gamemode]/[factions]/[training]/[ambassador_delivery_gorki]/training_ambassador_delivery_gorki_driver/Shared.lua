CONST_REWARD_EXP = 600

CONST_DAMAGE_ARMOR = 1000

CONST_CITY_ROUTE = {
	Vector3( 2457.868, -834.044, 60.585 ),
	Vector3( 2388.383, -839.19, 60.612 ),
	Vector3( 2334.529, -668.824, 60.623 ),
	Vector3( 2201.221, -496.706, 60.632 ),
	Vector3( 2083.561, -238.342, 60.622 ),
	Vector3( 2010.363, -176.046, 60.631 ),
	Vector3( 1931.78, -212.438, 60.638 ),
	Vector3( 1768.119, -392.17, 60.624 ),
	Vector3( 1717.516, -520.069, 60.632 ),
	Vector3( 1705.753, -594.807, 60.624 ),
	Vector3( 1599.548, -643.613, 46.884 ),
	Vector3( 1512.88, -686.376, 37.609 ),
	Vector3( 1511.033, -724.715, 36.992 ),
	Vector3( 1525.846, -898.747, 32.063 ),
}

QUEST_DATA = {
	training_id = "ambassador_delivery_gorki";
	training_role = "driver";

	title = "Сопровождение посла (Горки)";
	role_name = "Водитель";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 19, {
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
					}, "training_ambassador_delivery_gorki_driver_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Забери посла";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 2491.845, -783.965, 60.614 ), "training_ambassador_delivery_gorki_driver_end_step_2", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
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
							triggerServerEvent( "training_ambassador_delivery_gorki_driver_end_step_3", localPlayer )
						end
					end

					CEs.func_next_point()
				end;

				server = function( player, data )
					local vehicle = CreateTemporaryQuestVehicle( player, 445, 2486.343, -787.374, 60.682, 0, 0, 0 )
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
					if failed then
						removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
						removeEventHandler( "onClientPedDamage", root, Client_CancelPedInVehicleDamage )
					end

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
					CreateQuestPoint( Vector3( 2302.209, -2348.731, 21.380 ), "training_ambassador_delivery_gorki_driver_end_step_4", _, 10, 0, 0, CheckPlayerQuestVehicle )
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
				client = function( data, failed )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
					removeEventHandler( "onClientPedDamage", root, Client_CancelPedInVehicleDamage )
				end;

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

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
		localPlayer:ShowError( "Ты не в джипе" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель" )
		return false
	end

	return true
end

function Client_CancelPlayerInVehicleDamage()
	local all_damage = localPlayer:getData( "all_damage" )
	if not all_damage then return end

	if all_damage < CONST_DAMAGE_ARMOR then
		cancelEvent()
	end
end

function Client_CancelPedInVehicleDamage()
	local ped = localPlayer:getData( "ambassador_quest_ped" )
	if source ~= ped then return end

	local vehicle = localPlayer:getData( "quest_vehicle" )
	if not vehicle then return end

	local all_damage = localPlayer:getData( "all_damage" )
	if not all_damage then return end

	if all_damage < CONST_DAMAGE_ARMOR then
		cancelEvent()
	end
end

function FailCreateGameAmbassador( training_failed )
	if training_failed then
		return
	end
	
	player = source

	local vehicle = player:getData( "quest_vehicle" )
	if not isElement( vehicle ) then
		return
	end

	triggerEvent( "CreateAmbassador", root, {
		model = vehicle.model;

		position_x = vehicle.position.x;
		position_y = vehicle.position.y;
		position_z = vehicle.position.z;

		rotation_x = vehicle.rotation.x;
		rotation_y = vehicle.rotation.y;
		rotation_z = vehicle.rotation.z;

		health = vehicle.health;
		wheel_states = { vehicle:getWheelStates() };
		number_plate = vehicle:GetNumberPlate();

		duration = 10 * 60;
		points = 400;
		money = 25000;
	} )
end