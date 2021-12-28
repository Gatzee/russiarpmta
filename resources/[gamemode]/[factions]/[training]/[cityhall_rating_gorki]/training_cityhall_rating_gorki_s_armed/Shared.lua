CONST_REWARD_EXP = 300

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
	training_role = "s_armed";
	training_parent = "mayor";

	training_uncritical = true;

	title = "Объезд владений (Горки)";
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
					}, "training_cityhall_rating_gorki_s_armed_end_step_1", _, true )
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
							triggerServerEvent( "training_cityhall_rating_gorki_s_armed_end_step_2", localPlayer )
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

				server = function( player )
					player:TakeWeapon( 29 )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}