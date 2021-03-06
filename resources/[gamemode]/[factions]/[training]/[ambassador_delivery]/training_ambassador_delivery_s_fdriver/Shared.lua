CONST_REWARD_EXP = 300

CONST_DAMAGE_ARMOR = 1000

QUEST_DATA = {
	training_id = "ambassador_delivery";
	training_role = "s_fdriver";
	training_parent = "driver";
	
	training_uncritical = true;

	title = "Сопровождение посла";
	role_name = "Подставной водитель";
	
	OnAnyFinish = {
		client = function( )
			removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
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
							text = [[Твоя задача сопроводить транспорт с послом до
									аэропорта и всеми силами его защищать.
									Тебе будет выдан подставной автомобиль,
									идентичный транспорту с послом, за исключением
									номерных знаков.]];
							info = true;
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на процесс учений, но если
									посол или водитель будут убиты, то учение
									будет автоматически провалено!]];
							info = true;
						};
					}, "training_ambassador_delivery_s_fdriver_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Забери автомобиль";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 495.055, -2365.123, 20.800 ), "training_ambassador_delivery_s_fdriver_end_step_2", _, 2, 0, 0, CheckPlayerMilitaryVehicle )
				end;
			};
		};
		[3] = {
			name = "Покинь город";

			Setup = {
				client = function( data )
					addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
					
					CreateQuestPoint( Vector3( -833.669, -1685.583, 20.867 ), "training_ambassador_delivery_s_fdriver_end_step_3", _, 10, 0, 0, CheckPlayerMilitaryVehicle )
				end;

				server = function( player, data )
					local vehicle = CreateTemporaryQuestVehicle( player, 445,  499.012, -2376.463, 20.832, 0, 0, 0 )
					vehicle:SetFuel("full")
					vehicle:SetWindowsColor(0, 0, 0, 230)
					vehicle:SetColor(0, 3, 0, 0)

					local number = data.random_number % 8 + 1 + ( data.random_number % 2 * 2 - 1 )
					vehicle:SetNumberPlate( "6:а90".. number .."099" )
					
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
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						player:SetPrivateData( "all_damage", false )
					end
				end;
			};
		};
		[4] = {
			name = "Доберись до аэропорта";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2481.924, 361.143, 15.389 ), "training_ambassador_delivery_s_fdriver_end_step_4", _, 10, 0, 0, CheckPlayerQuestVehicle )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					player:SetPrivateData( "all_damage", false )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}