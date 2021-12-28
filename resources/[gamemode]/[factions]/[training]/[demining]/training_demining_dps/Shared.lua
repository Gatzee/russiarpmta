CONST_REWARD_EXP = 600

CONST_DPS_DATA = {
	[1] = {
		position = Vector3( -1067.6, -1675.5, 21.2 );
		objects = {
			{
				model = 1228;
				position = Vector3( -1105, -1683.20001, 20.2 );
				rotation = Vector3( 0, 0, 90 );
			};
			{
				model = 1228;
				position = Vector3( -1099.8, -1683.40002, 20.2 );
				rotation = Vector3( 0, 0, 90 );
			};
			{
				model = 1238;
				position = Vector3( -1106.7, -1683.20001, 20.1 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( -1102.6, -1683.29999, 20.1 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( -1097.9, -1683.40002, 20.1 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( -1041.8, -1683.20001, 20.1 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1228;
				position = Vector3( -1039.6, -1683.40002, 20.2 );
				rotation = Vector3( 0, 0, 90 );
			};
			{
				model = 1228;
				position = Vector3( -1034.8, -1683.5, 20.2 );
				rotation = Vector3( 0, 0, 90 );
			};
			{
				model = 1238;
				position = Vector3( -1037.4, -1683.29999, 20.1 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 1238;
				position = Vector3( -1033.1, -1683.29999, 20.1 );
				rotation = Vector3( 0, 0, 0 );
			};
		};
	};
}

CONST_COUNT_POINTS = #CONST_DPS_DATA


QUEST_DATA = {
	training_id = "demining";
	training_role = "dps";
	training_parent = "army";

	title = "Разминирование бомбы";
	role_name = "Сотрудник ДПС";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 18, {
						{
							text = [[— Здравия желаю! Получили данные о взрыве,
									есть жертвы. Также, возможно, есть еще
									заминированные машины.]];
						};
						{
							text = [[Твоя задача оцепить периметр! Чтобы еще ни
									одна душа не пострадала от подобного
									происшествия.]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь или выйдешь
									из игры, то учение будет провалено!]];
							info = true;
						};
					}, "training_demining_dps_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_DPS_DATA[ number ].position, "training_demining_dps_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Расставь ограждения";

			Setup = {
				client = function( data )
					addEvent( "training_demining_CreatePointToPutBarrier", true )
					addEventHandler( "training_demining_CreatePointToPutBarrier", resourceRoot, Client_CreatePointToPutBarrier )

					local number = data.random_number % CONST_COUNT_POINTS + 1
					Client_CreatePointToPutBarrier( number, 1 )
				end;

				server = function( player, data )
					addEvent( "training_demining_CreateObjectBarrier", true )
					addEventHandler( "training_demining_CreateObjectBarrier", resourceRoot, Server_CreateObjectBarrier )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "training_demining_CreatePointToPutBarrier", resourceRoot, Client_CreatePointToPutBarrier )
				end;

				server = function( player, data )
					removeEventHandler( "training_demining_CreateObjectBarrier", resourceRoot, Server_CreateObjectBarrier )
				end;
			};
		};
		[4] = {
			name = "Убери ограждения";
			requests = {
				{ "army", 3 };
			};

			Setup = {
				client = function( data )
					addEvent( "training_demining_CreatePointToPickupBarrier", true )
					addEventHandler( "training_demining_CreatePointToPickupBarrier", resourceRoot, Client_CreatePointToPickupBarrier )

					local number = data.random_number % CONST_COUNT_POINTS + 1
					Client_CreatePointToPickupBarrier( number, #CONST_DPS_DATA[ number ].objects )
				end;

				server = function( player, data )
					addEvent( "training_demining_DeleteObjectBarrier", true )
					addEventHandler( "training_demining_DeleteObjectBarrier", resourceRoot, Server_DeleteObjectBarrier )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "training_demining_CreatePointToPickupBarrier", resourceRoot, Client_CreatePointToPickupBarrier )
				end;

				server = function( player, data )
					removeEventHandler( "training_demining_DeleteObjectBarrier", resourceRoot, Server_DeleteObjectBarrier )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}



function Client_CreatePointToPutBarrier( number, barrier_index )
	CreateQuestPoint( CONST_DPS_DATA[ number ].objects[ barrier_index ].position, function()
		CEs.marker:destroy()
		triggerServerEvent( "training_demining_CreateObjectBarrier", resourceRoot, number, barrier_index )
	end, _, 2, 0, 0 )
end

function Server_CreateObjectBarrier( number, barrier_index )
	if not client then return end

	local barrier_info = CONST_DPS_DATA[ number ].objects[ barrier_index ]

	local world_object = Object( barrier_info.model, barrier_info.position, barrier_info.rotation )
	world_object.frozen = true
	AddQuestElement( client, "world_object_".. barrier_index, world_object )

	setPedAnimation( client, "bomber", "bom_plant_loop", -1, false, false, false, false )

	if barrier_index == #CONST_DPS_DATA[ number ].objects then
		triggerEvent( "training_demining_dps_end_step_3", client )
	else
		triggerClientEvent( client, "training_demining_CreatePointToPutBarrier", resourceRoot, number, barrier_index + 1 )
	end
end


function Client_CreatePointToPickupBarrier( number, barrier_index )
	CreateQuestPoint( CONST_DPS_DATA[ number ].objects[ barrier_index ].position, function()
		CEs.marker:destroy()
		triggerServerEvent( "training_demining_DeleteObjectBarrier", resourceRoot, number, barrier_index )
	end, _, 2, 0, 0 )
end

function Server_DeleteObjectBarrier( number, barrier_index )
	if not client then return end

	DeleteQuestElement( client, "world_object_".. barrier_index )

	setPedAnimation( client, "bomber", "bom_plant_loop", -1, false, false, false, false )

	if barrier_index == 1 then
		triggerEvent( "training_demining_dps_end_step_4", client )
	else
		triggerClientEvent( client, "training_demining_CreatePointToPickupBarrier", resourceRoot, number, barrier_index - 1 )
	end
end