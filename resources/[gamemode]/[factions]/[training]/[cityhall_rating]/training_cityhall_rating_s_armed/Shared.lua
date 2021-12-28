CONST_REWARD_EXP = 300

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
	training_role = "s_armed";
	training_parent = "mayor";

	training_uncritical = true;

	title = "Объезд владений (НСК)";
	role_name = "Сопровождение";

	OnAnyFinish = {
		server = function( player )
			player:TakeWeapon( 29 )
		end,
	},

	tasks = {
		[1] = {
			name = "Поговори с клерком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Добрый день! Ваша задача охранять жизнь
									мэра города, и подчинятся приказам его
									и начальника охраны.]];
						};
						{
							text = [[Если во времы выполнения данного задания
									мэра убьют бандиты или сотрудники фракции,
									то рейтинг власти упадет на 50%. Но при
									успешно завершении задания, в зависимости
									от финансирования мэром “Агитация власти”,
									рейтинг власти будет увеличен.]];
							info = true;
						};
					}, "training_cityhall_rating_s_armed_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Проследуй по маршруту";

			requests = {
				{ "mayor", 1 };
			};

			Setup = {
				client = function( data )
					local route_current_index = 0

					CEs.func_next_point = function()
						if CEs.marker and isElement( CEs.marker.colshape ) then
							CEs.marker.destroy()
						end

						route_current_index = route_current_index + 1

						if CONST_CITY_ROUTE[ route_current_index ] then
							CreateQuestPoint( CONST_CITY_ROUTE[ route_current_index ], CEs.func_next_point, _, 10, 0, 0 )
							CEs.marker.slowdown_coefficient = nil
							CEs.marker.allow_passenger = true
						else
							triggerServerEvent( "training_cityhall_rating_s_armed_end_step_2", localPlayer )
						end
					end

					CEs.func_next_point()
				end;

				server = function( player )
					player.armor = 100
					player:GiveWeapon( 29, 180, true, true )
				end;
			};

			CleanUp = {
				client = function( data, failed )
					CEs.func_next_point = nil
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}