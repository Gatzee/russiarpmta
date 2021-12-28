CONST_REWARD_EXP = 200

CONST_START_POINTS = {
	Vector3( -2555.406, 426.377, 16.944 );
	Vector3( -2528.498, 474.942, 16.891 );
}

CONST_PICKUP_POINTS = {
	Vector3( 1133.390, -2680.655, 21.671 );
	Vector3( 1096.529, -2716.177, 21.410 );
}

QUEST_DATA = {
	training_id = "military_skydiving";
	training_role = "s_skydiver";
	training_parent = "aircraft";
	
	training_uncritical = true;

	title = "Прыжки с парашютом";
	role_name = "Десантник";

	OnAnyFinish = {
		server = function( player )
			setCameraTarget( player )
		end,
	},
	
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
							text = [[Твоя задача приземлится в отмеченные координаты,
									где будут ждать вертолеты. Сейчас доберись до
									аэропорта и сядь в самолет через маркер.
									Во время свободного падения используй ЛКМ для
									открытия парашюта.]];
							info = true;
						};
						{
							text = [[Ты не являешься ключевых игроком данного
									учения. Твоя смерть или выход из игры
									не повлияют на процесс учений.]];
							info = true;
						};
					}, "training_military_skydiving_s_skydiver_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Прибудь в аэропорт";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2510.885, 334.642, 16.023 ), "training_military_skydiving_s_skydiver_end_step_2", _, 2, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Загрузись в самолёт";
			requests = {
				{ "aircraft", 2 };
			};

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2586.595, 380.538, 16.480 ), "training_military_skydiving_s_skydiver_end_step_3", _, 35, 0, 0 )
				end;

				server = function( player, data )
					player:GiveWeapon( 46, 1, true, true )
				end;
			};
		};
		[4] = {
			name = "Десантируйся на точку";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1051.762, -2556.875, 31.581 ), "training_military_skydiving_s_skydiver_end_step_4", _, 10, 0, 0 )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						local vehicle = player:getData( "in_aircraft" )
						if vehicle then
							player:setData( "in_aircraft", false, false )

							detachElements( player )
							toggleAllControls( player, true )
							setCameraTarget( player )

							player.position = Vector3( -2500.613, 328.088, 15.303 ) + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )
						end
					end
				end;
			};
		};
		[5] = {
			name = "Загрузись в свободный вертолёт";
			requests = {
				{ "heli", 3 };
			};

			Setup = {
				client = function( data )
					if not CEs.marker_checkpoint_1 then
						for i, position in pairs( CONST_PICKUP_POINTS ) do
							CreateQuestPoint( position, "training_military_skydiving_s_skydiver_end_step_5", "marker_checkpoint_".. i, 15, 0, 0 )
						end
					end
				end;
			};
		};
		[6] = {
			name = "Вернись в аэропорт";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -2512.993, 441.878, 15.304 ), "training_military_skydiving_s_skydiver_end_step_6", _, 2, 0, 0 )
				end;
			};

			CleanUp = {
				server = function( player, data, failed )
					if failed then
						local vehicle = player:getData( "in_helicopter" )
						if vehicle then
							player:setData( "in_helicopter", false, false )

							detachElements( player )
							toggleAllControls( player, true )
							setCameraTarget( player )

							player.position = Vector3( -2500.613, 328.088, 15.303 ) + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )
						end
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