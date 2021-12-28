PPS_MURDER_DATA = {
	[1] = {
		position = Vector3( 1922.7, -774.6, 60.7 );
		ped_position = Vector3( 1903.4, -781.2, 60.7 );
		evidence = {
			Vector3( 1895.2, -778.8, 61.5 );
			Vector3( 1903.4, -774.2, 60.7 );
			Vector3( 1901.3, -784, 60.7 );
		};
	};
	[2] = {
		position = Vector3( 2151.5, -1144.5, 60.7 );
		ped_position = Vector3( 2140.8, -1141.60001, 60.7 );
		evidence = {
			Vector3( 2145.3, -1152.29999, 60.7 );
			Vector3( 2136.8, -1134.29999, 60.7 );
			Vector3( 2143.7, -1128.20001, 61.1 );
		};
	};
	[3] = {
		position = Vector3( 1577.8, -420.29999, 36.7 );
		ped_position = Vector3( 1549.25, -430.82, 36.8 );
		evidence = {
			Vector3( 1554.73, -414.321, 36.8 );
			Vector3( 1564.92, -413.795, 36.8 );
			Vector3( 1544.54, -450.22, 36.8 );
		};
	};
}

CONST_COUNT_POINTS = #PPS_MURDER_DATA

QUEST_DATA = {
	training_id = "murder_gorki";
	training_role = "pps";
	
	--replay_timeout = 10800;

	title = "Расследование убийства\n(Горки)";
	role_name = "Сотрудник ППС";
	
	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function( data )
					CreateQuestPointToNPCWithDialog( 15, {
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
					}, "training_murder_gorki_pps_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Доберись до точки";

			Setup = {
				client = function( data )
					local number = data.random_number % CONST_COUNT_POINTS + 1
					CreateQuestPoint( PPS_MURDER_DATA[ number ].position, "training_murder_gorki_pps_end_step_2", _, _, 0, 0 )
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
					addEvent( "training_murder_gorki_CreatePointToEvidence", true )
					addEventHandler( "training_murder_gorki_CreatePointToEvidence", resourceRoot, Client_CreatePointToEvidence )

					local number = data.random_number % CONST_COUNT_POINTS + 1
					Client_CreatePointToEvidence( number, 1 )
				end;
			};

			CleanUp = {
				client = function( data )
					removeEventHandler( "training_murder_gorki_CreatePointToEvidence", resourceRoot, Client_CreatePointToEvidence )
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
				
						triggerServerEvent( "training_murder_gorki_pps_end_step_4", localPlayer )
					end, _, 1.5, 0, 0 )
				end;
			};
		};
		[5] = {
			name = "Доставь улики в участок";

			Setup = {
				client = function( data )
					CreateQuestPoint( Vector3( 1941.436, -738.283, 60.777 ), "training_murder_gorki_pps_end_step_5", _, _, 0, 0 )
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
			triggerServerEvent( "training_murder_gorki_pps_end_step_3", localPlayer )
		else
			Client_CreatePointToEvidence( number, evidence_index + 1 )
		end
	end, _, 2, 0, 0 )
end