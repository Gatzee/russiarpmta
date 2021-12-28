PPS_MURDER_DATA = {
	[1] = {
		position = Vector3( -920.79999, -1808.70001, 20.9 );
		ped_position = Vector3( -926.5, -1801.59998, 21 );
		evidence = {
			Vector3( -921.09998, -1800.09998, 21 );
			Vector3( -925.79999, -1797.5, 25.2 );
			Vector3( -927.59998, -1805.29999, 21 );
		};
	};
	[2] = {
		position = Vector3( -1182.9, -1736.59998, 21 );
		ped_position = Vector3( -1182.4, -1730.90002, 21 );
		evidence = {
			Vector3( -1177.7, -1728.90002, 21.2 );
			Vector3( -1181.3, -1740, 21 );
			Vector3( -1183.7, -1726.59998, 21 );
		};
	};
	[3] = {
		position = Vector3( -911, -1518.5, 20.8 );
		ped_position = Vector3( -887.5, -1513.29999, 21 );
		evidence = {
			Vector3( -885.70001, -1514.09998, 21 );
			Vector3( -882.40002, -1511.79999, 21 );
			Vector3( -889.20001, -1504.09998, 21.1 );
		};
	};
	[4] = {
		position = Vector3( 598.09998, -1917, 21 );
		ped_position = Vector3( 604.20001, -1910.6, 21 );
		evidence = {
			Vector3( 598.09998, -1911.9, 21 );
			Vector3( 613.79999, -1906.2, 21 );
			Vector3( 611.79999, -1916.7, 20.8 );
		};
	};
}

CONST_COUNT_POINTS = #PPS_MURDER_DATA

QUEST_DATA = {
	training_id = "murder_nsk";
	training_role = "pps";
	
	--replay_timeout = 10800;

	title = "Расследование убийства";
	role_name = "Сотрудник ППС";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 14, {
						{
							text = [[— Здравия желаю! Поступило сообщение
									о трупе в городе. ДПС и Мед.служба уже
									предупреждены и выезжают на место.]];
						};
						{
							text = [[Тебе необходимо прибыть на указанную точку,
									осмотреть место преступление и тело, после
									чего привези в участок все найденные улики.
									Запрещено осматривать место и тело до того,
									пока ДПС не поставит заграждения.]];
							info = true;
						};
						{
							text = [[Ты являешься одним из ключевых игроков
									данного учения. Если ты погибнешь или выйдешь
									из игры, то учение будет провалено!]];
							info = true;
						};
					}, "training_murder_nsk_pps_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( PPS_MURDER_DATA[ number ].position, "training_murder_nsk_pps_end_step_2", _, _, 0, 0 )
				end;
			};
		};
		[3] = {
			name = "Осмотри место преступления";
			requests = {
				{ "dps", 3 };
			};

			Setup = {
				client = function( data )
					addEvent( "training_murder_nsk_CreatePointToEvidence", true )
					addEventHandler( "training_murder_nsk_CreatePointToEvidence", resourceRoot, Client_CreatePointToEvidence )

					local number = data.random_number % CONST_COUNT_POINTS + 1
					Client_CreatePointToEvidence( number, 1 )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "training_murder_nsk_CreatePointToEvidence", resourceRoot, Client_CreatePointToEvidence )
				end;
			}
		};
		[4] = {
			name = "Осмотри тело";
			requests = {
				{ "medic", 3 };
			};

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( PPS_MURDER_DATA[ number ].ped_position, function()
						CEs.marker:destroy()
				
						setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )
				
						triggerServerEvent( "training_murder_nsk_pps_end_step_4", localPlayer )
					end, _, 1.5, 0, 0 )
				end;
			};
		};
		[5] = {
			name = "Доставь улики в участок";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( -355.704, -1672.095, 20.852 ), "training_murder_nsk_pps_end_step_5", _, _, 0, 0 )
				end;
			};
		};
	};

	rewards = {
		faction_exp = 300;
	};

	success_text = "Задача выполнена! Вы получили +300 очков ранга";
}


function Client_CreatePointToEvidence( number, evidence_index )
	CreateQuestPoint( PPS_MURDER_DATA[ number ].evidence[ evidence_index ], function()
		CEs.marker:destroy()

		setPedAnimation( localPlayer, "bomber", "bom_plant_loop", -1, false, false, false, false )

		if evidence_index == #PPS_MURDER_DATA[ number ].evidence then
			triggerServerEvent( "training_murder_nsk_pps_end_step_3", localPlayer )
		else
			Client_CreatePointToEvidence( number, evidence_index + 1 )
		end
	end, _, 2, 0, 0 )
end