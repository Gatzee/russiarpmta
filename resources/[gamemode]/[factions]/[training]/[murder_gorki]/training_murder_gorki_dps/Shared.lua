DPS_MURDER_DATA = {
	[1] = {
		position = Vector3( 1925.4, -778.6, 60.7 );
		objects = {
			{
				model = 1228;
				position = Vector3( 1916.7, -773.4, 60.1 );
				rotation = Vector3( 0, 0, 56 );
			};
			{
				model = 1228;
				position = Vector3( 1911.9, -771.8, 60.1 );
				rotation = Vector3( 0, 0, 80 );
			};
			{
				model = 1228;
				position = Vector3( 1907.3, -771.2, 60.1 );
				rotation = Vector3( 0, 0, 84 );
			};
			{
				model = 1238;
				position = Vector3( 1918.4, -774.8, 60 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( 1914.3, -772.4, 60 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( 1909.5, -771.5, 60 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( 1905.3, -771.1, 60 );
				rotation = Vector3( 0, 0, 0 );
			};
		};
	};
	[2] = {
		position = Vector3( 2156.3, -1145.39999, 60.7 );
		objects = {
			{
				model = 1228;
				position = Vector3( 2143.8, -1121.39999, 60.1 );
				rotation = Vector3( 0, 0, 288 );
			};
			{
				model = 1228;
				position = Vector3( 2147.8999, -1122.60001, 60 );
				rotation = Vector3( 0, 0, 243.996 );
			};
			{
				model = 1228;
				position = Vector3( 2135.3, -1127.39999, 60.1 );
				rotation = Vector3( 0, 0, 303.995 );
			};
			{
				model = 1228;
				position = Vector3( 2131.3, -1133.79999, 60.1 );
				rotation = Vector3( 0, 0, 345.992 );
			};
			{
				model = 1228;
				position = Vector3( 2147.3999, -1154.89999, 61.2 );
				rotation = Vector3( 0, 0, 115.987 );
			};
			{
				model = 1228;
				position = Vector3( 2138.8999, -1153.29999, 60.1 );
				rotation = Vector3( 0, 0, 61.983 );
			};
			{
				model = 1228;
				position = Vector3( 2133.8, -1144.60001, 60.1 );
				rotation = Vector3( 0, 0, 23.979 );
			};
			{
				model = 1228;
				position = Vector3( 2158.3, -1151.5, 60.1 );
				rotation = Vector3( 0, 0, 113.978 );
			};
			{
				model = 1238;
				position = Vector3( 2145.8999, -1121.60001, 59.9 );
				rotation = Vector3( 0, 0, 210 );
			};
			{
				model = 1238;
				position = Vector3( 2150.6001, -1126.20001, 59.9 );
				rotation = Vector3( 0, 0, 209.998 );
			};
			{
				model = 1238;
				position = Vector3( 2153.1001, -1130, 59.9 );
				rotation = Vector3( 0, 0, 209.998 );
			};
			{
				model = 1238;
				position = Vector3( 2138.1001, -1125.60001, 60 );
				rotation = Vector3( 0, 0, 209.998 );
			};
			{
				model = 1238;
				position = Vector3( 2133, -1130, 60 );
				rotation = Vector3( 0, 0, 209.998 );
			};
			{
				model = 1238;
				position = Vector3( 2132, -1139.79999, 60 );
				rotation = Vector3( 0, 0, 209.998 );
			};
			{
				model = 1238;
				position = Vector3( 2135.7, -1148.70001, 60 );
				rotation = Vector3( 0, 0, 209.998 );
			};
			{
				model = 1238;
				position = Vector3( 2152.8999, -1154.39999, 60 );
				rotation = Vector3( 0, 0, 209.998 );
			};
			{
				model = 1238;
				position = Vector3( 2161.1001, -1150.10001, 59.9 );
				rotation = Vector3( 0, 0, 209.998 );
			};
		};
	};
	[3] = {
		position = Vector3( 1577, -413.5, 36.9 );
		objects = {
			{
				model = 1228;
				position = Vector3( 1602.8, -416, 36.6 );
				rotation = Vector3( 0, 0, 314 );
			};
			{
				model = 1238;
				position = Vector3( 1604.8, -414.20001, 36.6 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( 1600.9, -417.79999, 36.5 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1228;
				position = Vector3( 1568.4, -473.10001, 36.6 );
				rotation = Vector3( 0, 0, 340 );
			};
			{
				model = 1238;
				position = Vector3( 1569.5, -470.20001, 36.5 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( 1567.5, -476.10001, 36.5 );
				rotation = Vector3( 0, 0, 0 );
			};
		};
	};
}

CONST_COUNT_POINTS = #DPS_MURDER_DATA


QUEST_DATA = {
	training_id = "murder_gorki";
	training_role = "dps";
	training_parent = "pps";
	
	--replay_timeout = 10800;

	title = "Расследование убийства\n(Горки)";
	role_name = "Сотрудник ДПС";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 19, {
						{
							text = [[— Здравия желаю! От ППС пришел запрос
									о необходимости отцепить место преступления.
									Бери служебный автомобиль с инвентарем и
									отправляйся расставлять ограждения.]];
						};
						{
							text = [[Тебе необходимо прибыть на место преступления,
									оградить его спец.инвентарем и не допустить
									проникновение гражданских через ограждения.]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь или выйдешь
									из игры, то учение будет провалено!]];
							info = true;
						};
					}, "training_murder_gorki_dps_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( DPS_MURDER_DATA[ number ].position, "training_murder_gorki_dps_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Расставь ограждения";

			Setup = {
				client = function( data )
					addEvent( "training_murder_gorki_CreatePointToPutBarrier", true )
					addEventHandler( "training_murder_gorki_CreatePointToPutBarrier", resourceRoot, Client_CreatePointToPutBarrier )

					local number = data.random_number % CONST_COUNT_POINTS + 1
					Client_CreatePointToPutBarrier( number, 1 )
				end;

				server = function( player, data )
					addEvent( "training_murder_gorki_CreateObjectBarrier", true )
					addEventHandler( "training_murder_gorki_CreateObjectBarrier", resourceRoot, Server_CreateObjectBarrier )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "training_murder_gorki_CreatePointToPutBarrier", resourceRoot, Client_CreatePointToPutBarrier )
				end;

				server = function( player, data )
					removeEventHandler( "training_murder_gorki_CreateObjectBarrier", resourceRoot, Server_CreateObjectBarrier )
				end;
			};
		};
		[4] = {
			name = "Убери ограждения";
			requests = {
				{ "medic", 5 };
			};

			Setup = {
				client = function( data )
					addEvent( "training_murder_gorki_CreatePointToPickupBarrier", true )
					addEventHandler( "training_murder_gorki_CreatePointToPickupBarrier", resourceRoot, Client_CreatePointToPickupBarrier )

					local number = data.random_number % CONST_COUNT_POINTS + 1
					Client_CreatePointToPickupBarrier( number, #DPS_MURDER_DATA[ number ].objects )
				end;

				server = function( player, data )
					addEvent( "training_murder_gorki_DeleteObjectBarrier", true )
					addEventHandler( "training_murder_gorki_DeleteObjectBarrier", resourceRoot, Server_DeleteObjectBarrier )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "training_murder_gorki_CreatePointToPickupBarrier", resourceRoot, Client_CreatePointToPickupBarrier )
				end;

				server = function( player, data )
					removeEventHandler( "training_murder_gorki_DeleteObjectBarrier", resourceRoot, Server_DeleteObjectBarrier )
				end;
			};
		};
		[5] = {
			name = "Вернись на базу";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 2190.830, -656.057, 60.676 ), "training_murder_gorki_dps_end_step_5", _, _, 0, 0 )
				end;
			};
		};
	};

	rewards = {
		faction_exp = 400;
	};

	success_text = "Задача выполнена! Вы получили +400 очков ранга";
}



function Client_CreatePointToPutBarrier( number, barrier_index )
	CreateQuestPoint( DPS_MURDER_DATA[ number ].objects[ barrier_index ].position, function()
		CEs.marker:destroy()
		triggerServerEvent( "training_murder_gorki_CreateObjectBarrier", resourceRoot, number, barrier_index )
	end, _, 2, 0, 0 )
end

function Server_CreateObjectBarrier( number, barrier_index )
	if not client then return end

	local barrier_info = DPS_MURDER_DATA[ number ].objects[ barrier_index ]

	local world_object = Object( barrier_info.model, barrier_info.position, barrier_info.rotation )
	world_object.frozen = true
	AddQuestElement( client, "world_object_".. barrier_index, world_object )

	setPedAnimation( client, "bomber", "bom_plant_loop", -1, false, false, false, false )

	if barrier_index == #DPS_MURDER_DATA[ number ].objects then
		triggerEvent( "training_murder_gorki_dps_end_step_3", client )
	else
		triggerClientEvent( client, "training_murder_gorki_CreatePointToPutBarrier", resourceRoot, number, barrier_index + 1 )
	end
end


function Client_CreatePointToPickupBarrier( number, barrier_index )
	CreateQuestPoint( DPS_MURDER_DATA[ number ].objects[ barrier_index ].position, function()
		CEs.marker:destroy()
		triggerServerEvent( "training_murder_gorki_DeleteObjectBarrier", resourceRoot, number, barrier_index )
	end, _, 2, 0, 0 )
end

function Server_DeleteObjectBarrier( number, barrier_index )
	if not client then return end

	DeleteQuestElement( client, "world_object_".. barrier_index )

	setPedAnimation( client, "bomber", "bom_plant_loop", -1, false, false, false, false )

	if barrier_index == 1 then
		triggerEvent( "training_murder_gorki_dps_end_step_4", client )
	else
		triggerClientEvent( client, "training_murder_gorki_CreatePointToPickupBarrier", resourceRoot, number, barrier_index - 1 )
	end
end