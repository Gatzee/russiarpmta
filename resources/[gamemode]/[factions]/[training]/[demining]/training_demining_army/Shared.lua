CONST_REWARD_EXP = 800

CONST_ARMY_DATA = {
	[1] = {
		position = Vector3( -1101.8, -1676.59998, 20.8 );
		vehicles = {
			{
				model = 516;
				position = Vector3( -1082.3, -1708.59998, 20.6 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 516;
				position = Vector3( -1071.7, -1708.70001, 20.6 );
				rotation = Vector3( 0, 0, 180 );
			};
			{
				model = 516;
				position = Vector3( -1058.3, -1725.5, 20.6 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 516;
				position = Vector3( -1050.4, -1708.59998, 20.6 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 516;
				position = Vector3( -1105.7, -1710.20001, 20.7 );
				rotation = Vector3( 0, 0, 90 );
			};
			{
				model = 415;
				position = Vector3( -1057.5, -1708.79999, 20.5 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 585;
				position = Vector3( -1065.5, -1725.20001, 20.7 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 585;
				position = Vector3( -1079.7, -1725.70001, 20.7 );
				rotation = Vector3( 0, 0, 180 );
			};
			{
				model = 585;
				position = Vector3( -1022.3, -1694.70001, 20.7 );
				rotation = Vector3( 0, 0, 0 );
			};
			{
				model = 549;
				position = Vector3( -1015.1, -1694.79999, 20.5 );
				rotation = Vector3( 0, 0, 180 );
			};
			{
				model = 549;
				position = Vector3( -1069, -1725.5, 20.5 );
				rotation = Vector3( 0, 0, 180 );
			};
		};
	};
}

CONST_COUNT_POINTS = #CONST_ARMY_DATA

COST_COLORS_LIST = { { 5, 5, 5 }, { 255, 255, 255 }, { 16, 80, 130 }, { 200, 20, 20 }, { 50, 50, 50 }, { 200, 0, 200 }, { 200, 200, 20 } }
-- "Черный", "Белый", "Голубой", "Красный", "Серый", "Розовый", "Желтый"

QUEST_DATA = {
	training_id = "demining";
	training_role = "army";

	title = "Разминирование бомбы";
	role_name = "Военный сапер";
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 20, {
						{
							text = [[— Здравия желаю! Получили данные о взрыве,
									есть жертвы. Также, возможно, есть еще
									заминированные машины.]];
						};
						{
							text = [[Твоя задача, боец, разминировать машину с
									помощью нашего отечественного устройства!
									На полигоне ты мог ознакомится с принципом
									его действия и явно проходил подготовку. Но я
									напомню, необходимо подключаться к портам бомбы,
									в любом порядке, и подобрать необходимую цифру
									для обезвреживания.]];
						};
						{
							text = [[Нужная тебе цифры выделяется звуком, но так как
									это отечественное устройство, возможны ложные
									срабатывания. После подбора шифра, нажимай
									применить, если он будет верный то разминирование
									пройдет удачно. И запомни у тебя только 3 попытки!]];
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь или выйдешь
									из игры, то учение будет провалено!]];
							info = true;
						};
					}, "training_demining_army_end_step_1", _, true )
				end;

				server = function( player, data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					local bomb_number = data.random_number % #CONST_ARMY_DATA[ number ].vehicles + 1
					local info = CONST_ARMY_DATA[ number ].vehicles[ bomb_number ]

					local vehicle = Vehicle.CreateTemporary( info.model, info.position.x, info.position.y, info.position.z, info.rotation.x, info.rotation.y, info.rotation.z )
					vehicle:SetStatic( true )
					vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )

					local bomb_color = data.random_number % #COST_COLORS_LIST + 1
					vehicle:SetColor( unpack( COST_COLORS_LIST[ bomb_color ] ) )

					AddQuestElement( player, "bomb_vehicle", vehicle )

					addEventHandler( "onVehicleDamage", vehicle, function( )
						source.health = 1000
					end )

					addEventHandler( "onVehicleStartEnter", vehicle, function( )
						cancelEvent()
					end )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( CONST_ARMY_DATA[ number ].position, "training_demining_army_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Деактивируй бомбу";
			requests = {
				{ "pps", 4 };
			};

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					local bomb_number = data.random_number % #CONST_ARMY_DATA[ number ].vehicles + 1

					StartQuestTimerFail( 5 * 60 * 1000, "До взрыва осталось", "Вы не успели обезвредить бомбу!", function( )
						createExplosion( CONST_ARMY_DATA[ number ].vehicles[ bomb_number ].position, 7 )
					end )

					CreateQuestPoint( CONST_ARMY_DATA[ number ].vehicles[ bomb_number ].position, function()
						CEs.marker.destroy()

						setPedAnimation( localPlayer, "bomber", "bom_plant_loop", 10 * 1000, true, false, false, false )
						
						triggerEvent( "StartPlayerDemining", resourceRoot, "DeminingArmySuccess", "DeminingArmyFailed" )
						setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, true, false, false, false )

						CEs.DeminingArmySuccess_handler = function()
							triggerServerEvent( "training_demining_army_end_step_3", localPlayer )
						end
						addEvent( "DeminingArmySuccess" )
						addEventHandler( "DeminingArmySuccess", resourceRoot, CEs.DeminingArmySuccess_handler )
						
						CEs.DeminingArmyFailed_handler = function()
							triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Вы не смогли подобрать код" } )
							createExplosion( CONST_ARMY_DATA[ number ].vehicles[ bomb_number ].position, 7 )
						end
						addEvent( "DeminingArmyFailed" )
						addEventHandler( "DeminingArmyFailed", resourceRoot, CEs.DeminingArmyFailed_handler )
					end, _, _, 0, 0 )
				end;
			};

			CleanUp = {
				client = function( data, failed )
					if failed then
						triggerEvent( "StopPlayerDemining", resourceRoot )
					end

					if CEs.DeminingArmySuccess_handler then
						removeEventHandler( "DeminingArmySuccess", resourceRoot, CEs.DeminingArmySuccess_handler )
					end

					if CEs.DeminingArmyFailed_handler then
						removeEventHandler( "DeminingArmyFailed", resourceRoot, CEs.DeminingArmyFailed_handler )
					end

					CEs.DeminingArmySuccess_handler = nil
					CEs.DeminingArmyFailed_handler = nil

					setPedAnimation( localPlayer )
				end;
			};
		};
	};

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}