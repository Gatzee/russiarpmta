QUEST_DATA = {
	training_id = "military_delivery";
	training_role = "driver";
	training_parent = "pilot";
	
	--replay_timeout = 43200;

	title = "Поставка вооружения";
	role_name = "Водитель";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Здравия желаю! На складах МВД постепенно
									начинают заканчиваться боеприпасы. Твоя задача
									заключается в управлении тяжелым грузовиком и
									доставке патронов до участков ППС и ДПС.
									В сопровождении старшего по званию]];
						};
						{
							text = [[Тебе необходимо развести боеприпасы по
									4-м точкам, из которых две в Новороссийске и
									две в Горки-город. Учти, что по пути из одного
									города в другой на грузовик могут напасть
									бандиты и ограбить его!]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь, выйдешь из
									игры или твой грузовик будет сильно поврежден,
									то учение будет автоматически провалено!]];
							info = true;
						};
					}, "training_military_delivery_driver_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Прибудь к складу";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2427.204, -251.69, 20.706 ), "training_military_delivery_driver_end_step_2", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
				end;

				server = function( player, data )
					local vehicle = CreateTemporaryQuestVehicle( player, 433, -2416.278, -17.867, 20.699, 0, 0, 89.362 )
					vehicle:SetFuel( "full" )
					vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_ARMY ) )
					vehicle:setVariant( 1, 0 )
					vehicle:setData( "can_damage", false, false )

					addEventHandler( "onVehicleDamage", vehicle, function( loss )
						if vehicle:getData( "can_damage" ) then
							if loss > 5 then
								local all_damage = source:getData( "all_damage" ) or 0
								source:setData( "all_damage", all_damage + loss, false )

								if all_damage >= 1200 then
									triggerEvent( "PlayerFailStopQuest", player, { type = "quest_fail", fail_text = "Бандиты смогли захватить груз" } )
								end
							end
						else
							vehicle.health = 1000
						end

						vehicle:setWheelStates( 0, 0, 0, 0 )
					end )

					addEventHandler( "onVehicleStartEnter", vehicle, function( enter_player, seat )
						if enter_player:GetFaction() ~= F_ARMY or ( seat == 0 and enter_player ~= player ) then
							cancelEvent()
						end
					end )

					player:warpIntoVehicle(vehicle)
				end;
			};
		};
		[3] = {
			name = "Загрузи 40 ящиков";

			Setup = {
				server = function( player, data )
					CreateAmmoBoxTask( player, false, 40, Vector3( -2406.232, -252.212, 20.105 ), Vector3( -2416.191, -251.961, 20.105 ), 25, 3 )
				end;
			};

			CleanUp = {
				server = function( player )
					DeleteAmmoBoxTask( player )
				end;
			};
		};
		[4] = {
			name = "Покинь территорию части";
			requests = {
				{ "pilot", 2 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2284.648, -18.218, 20.695 ), "training_military_delivery_driver_end_step_4", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
				end;
			};
		};
		[5] = {
			name = "Разгрузись в ППС";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -375.747, -1672.428, 21.107 ), "training_military_delivery_driver_end_step_5", _, 2, 0, 0, CheckPlayerMilitaryVehicle )

					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[6] = {
			name = "Разгрузи 10 ящиков";

			Setup = {
				server = function( player, data )
					CreateAmmoBoxTask( player, true, 10, Vector3( -362.873, -1665.364, 22.379 ), Vector3( -367.511, -1668.229, 20.852 ), 22, 6 )
				end;
			};

			CleanUp = {
				server = function( player )
					DeleteAmmoBoxTask( player )
				end;
			};
		};
		[7] = {
			name = "Разгрузись в ДПС";
			requests = {
				{ "pilot", 4 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 330.328, -2020.938, 21.570 ), "training_military_delivery_driver_end_step_7", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
					
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[8] = {
			name = "Разгрузи 10 ящиков";

			Setup = {
				server = function( player, data )
					CreateAmmoBoxTask( player, true, 10, Vector3( 317.559, -2034.848, 21.819 ), Vector3( 323.090, -2029.005, 20.972 ), 25, 8 )
				end;
			};

			CleanUp = {
				server = function( player )
					DeleteAmmoBoxTask( player )
				end;
			};
		};
		[9] = {
			name = "Покинь Новороссийск";
			requests = {
				{ "pilot", 6 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 539.927, -1222.431, 21.110 ), "training_military_delivery_driver_end_step_9", "marker_way_1", _, 0, 0, CheckPlayerMilitaryVehicle )
					CreateQuestPoint( Vector3( 842.294, -1931.299, 21.430 ), "training_military_delivery_driver_end_step_9", "marker_way_2", _, 0, 0, CheckPlayerMilitaryVehicle )
					CEs.marker_way_1.slowdown_coefficient = nil
					CEs.marker_way_2.slowdown_coefficient = nil
					
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;

				server = function( player, data )
					AlertAllClans( "Военный грузовик с боеприпасами скоро проедет через канал!" )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[10] = {
			name = "Проследуй в Горки-город";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1550.146, -669.573, 41.541 ), "training_military_delivery_driver_end_step_10", "marker_way_1", _, 0, 0, CheckPlayerMilitaryVehicle )
					CreateQuestPoint( Vector3( 1718.604, -1320.749, 34.930 ), "training_military_delivery_driver_end_step_10", "marker_way_2", _, 0, 0, CheckPlayerMilitaryVehicle )
					CEs.marker_way_1.slowdown_coefficient = nil
					CEs.marker_way_2.slowdown_coefficient = nil
					
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					vehicle:setData( "can_damage", true, false )

					addEventHandler( "OnPlayerFailedQuest", player, OnPlayerFailedQuest_CreateTruckCrate )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;

				server = function( player )
					removeEventHandler( "OnPlayerFailedQuest", player, OnPlayerFailedQuest_CreateTruckCrate )
				end;
			};
		};
		[11] = {
			name = "Разгрузись в ДПС";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 2191.393, -616.025, 61.309 ), "training_military_delivery_driver_end_step_11", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
					
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;

				server = function( player, data )
					local vehicle = player:getData( "quest_vehicle" )
					vehicle:setData( "can_damage", false, false )

					AlertAllClans( "Военный грузовик с боеприпасами скрылся", "error" )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[12] = {
			name = "Разгрузи 10 ящиков";

			Setup = {
				server = function( player, data )
					CreateAmmoBoxTask( player, true, 10, Vector3( 2207.380, -605.714, 61.584 ), Vector3( 2201.002, -612.917, 60.824 ), 25, 12 )
				end;
			};

			CleanUp = {
				server = function( player )
					DeleteAmmoBoxTask( player )
				end;
			};
		};
		[13] = {
			name = "Разгрузись в ППС";
			requests = {
				{ "pilot", 8 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1945.128, -704.913, 61.379 ), "training_military_delivery_driver_end_step_13", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
					
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};
		};
		[14] = {
			name = "Разгрузи 10 ящиков";

			Setup = {
				server = function( player, data )
					CreateAmmoBoxTask( player, true, 10, Vector3( 1956.341, -725.912, 61.470 ), Vector3( 1951.696, -716.113, 60.784 ), 20, 14 )
				end;
			};

			CleanUp = {
				server = function( player )
					DeleteAmmoBoxTask( player )
				end;
			};
		};
		[15] = {
			name = "Возвращайся в часть";
			requests = {
				{ "pilot", 10 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2284.648, -18.218, 20.695 ), "training_military_delivery_driver_end_step_15", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
					
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInMilitaryVehicleDamage )
				end;

				server = function( player )
					DestroyTemporaryQuestVehicle( player )
				end;
			};
		};
	};

	rewards = {
		faction_exp = 600;
	};

	success_text = "Задача выполнена! Вы получили +600 очков ранга";
}

function CheckPlayerMilitaryVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
		localPlayer:ShowError( "Ты не в грузовике" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель" )
		return false
	end

	return true
end

function CreateAmmoBoxTask( task_player, to_stock, count, marker_position, area_position, area_size, step )
	local ammo_box_index = 1
	local count_ammo_box = count

	local vehicle = task_player:getData( "quest_vehicle" )
	vehicle:SetStatic( true )

	local stock_marker_position = marker_position + Vector3( 0, 0, -1 )
	local vehicle_marker_position = vehicle.position

	if to_stock then
		local temp = stock_marker_position
		stock_marker_position = vehicle_marker_position
		vehicle_marker_position = temp
	end

	local stock_marker = createMarker( stock_marker_position, "cylinder", 1.5, 100, 250, 100, 150 )
	AddQuestElement( task_player, "stock_marker", stock_marker )
	
	local vehicle_marker = createMarker( vehicle_marker_position, "cylinder", 1.5, 100, 250, 100, 150 )
	AddQuestElement( task_player, "vehicle_marker", vehicle_marker )

	if to_stock then
		attachElements( stock_marker, vehicle, 0, -5.5, -1.4 )
	else
		attachElements( vehicle_marker, vehicle, 0, -5.5, -1.4 )
	end

	addEventHandler( "onMarkerHit", stock_marker, function( player, dim )
		if not dim then return end
		if getElementType( player ) ~= "player" then return end
		if player.vehicle then return end
		if player:GetFaction() ~= F_ARMY then return end
		if count_ammo_box == 0 then
			return
		end

		if player:getData( "training_military_ammo_box" ) then return end

		local object = Object( 3052, player.position )
		AddQuestElement( player, "ammo_box_".. ammo_box_index, object )
		
		exports.bone_attach:attachElementToBone( object, player, 8, 0.1, 0.3, 0.3, 25, 180, 25 )
		player:setData( "training_military_ammo_box", ammo_box_index, false )

		ammo_box_index = ammo_box_index + 1

		setPedAnimation( player, "CARRY", "crry_prtial", 0, true, true, false, true )
		
		toggleControl( player, "fire", false )
		toggleControl( player, "jump", false )
		toggleControl( player, "sprint", false )
		toggleControl( player, "crouch", false )
		toggleControl( player, "enter_exit", false )
		toggleControl( player, "next_weapon", false )
		toggleControl( player, "previous_weapon", false )
		toggleControl( player, "aim_weapon", false )

		if to_stock then
			player:ShowInfo( "Отнеси ящик на склад" )
		else
			player:ShowInfo( "Отнеси ящик в грузовик" )
		end
	end )

	addEventHandler( "onMarkerHit", vehicle_marker, function( player, dim )
		if not dim then return end
		if getElementType( player ) ~= "player" then return end
		if player.vehicle then return end
		if not isElement( task_player ) then return end

		local ammo_box_index = player:getData( "training_military_ammo_box" )
		if not ammo_box_index then return end

		DeleteAmmoBoxFromPlayer( player, ammo_box_index )

		count_ammo_box = count_ammo_box - 1
		if count_ammo_box == 0 then
			triggerEvent( "training_military_delivery_driver_end_step_".. step, task_player )
			return
		end

		player:ShowInfo( "Осталось перенести еще ".. count_ammo_box .." шт." )
	end )

	local shape = createColSphere( area_position, area_size )
	AddQuestElement( task_player, "box_area_shape", shape )
	addEventHandler( "onColShapeLeave", shape, function( player, dim )
		if not dim then return end
		if getElementType( player ) ~= "player" then return end

		local ammo_box_index = player:getData( "training_military_ammo_box" )
		if not ammo_box_index then return end

		DeleteAmmoBoxFromPlayer( player, ammo_box_index )
	end )
end

function DeleteAmmoBoxFromPlayer( player, ammo_box_index )
	DeleteQuestElement( player, "ammo_box_".. ammo_box_index )
	player:setData( "training_military_ammo_box", false, false )

	setPedAnimation( player, "CARRY", "liftup", 0, false, false, false, false )
	
	toggleControl( player, "fire", true )
	toggleControl( player, "jump", true )
	toggleControl( player, "sprint", true )
	toggleControl( player, "crouch", true )
	toggleControl( player, "enter_exit", true )
	toggleControl( player, "next_weapon", true )
	toggleControl( player, "previous_weapon", true )
	toggleControl( player, "aim_weapon", true )
end

function DeleteAmmoBoxTask( player )
	local vehicle = player:getData( "quest_vehicle" )
	vehicle:SetStatic( false )

	local quest_elements = player:getData( "quest_elements" ) or { }
	local shape = quest_elements[ "box_area_shape" ]
	if isElement( shape ) then
		local elements = getElementsWithinColShape( shape, "player" )
		for _, player in pairs( elements ) do
			local ammo_box_index = player:getData( "training_military_ammo_box" )
			if ammo_box_index then
				DeleteAmmoBoxFromPlayer( player, ammo_box_index )
			end
		end
	end

	CleanUpQuestElements( player )
end

function OnPlayerFailedQuest_CreateTruckCrate()
	player = source

	local vehicle = player:getData( "quest_vehicle" )
	if not isElement( vehicle ) then
		return
	end

	triggerEvent( "CreateTruckCrate", root, {
		x = vehicle.position.x;
		y = vehicle.position.y;
		z = vehicle.position.z - 1.5;
		radius = 15;

		duration = 120;
		freq = 10;
		points = 25;
		money = 1000;
	} )
	
	createExplosion( vehicle.position, 7 )
end

function Client_CancelPlayerInMilitaryVehicleDamage()
	if not source.vehicle then return end
	if source.vehicle.model ~= 433 then return end
	
	cancelEvent()
end