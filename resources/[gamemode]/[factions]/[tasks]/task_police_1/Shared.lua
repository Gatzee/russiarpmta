CONST_NEED_COUNT_DOCUMENTS = 20

addEvent( "PlayerAction_PassportShowSuccess", true )
addEvent( "PlayerAction_JailedSuccess", true )

QUEST_DATA = {
	id = "task_police_1";

	title = "Проверка документов";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с лейтенантом";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Здравия желаю! Сегодня пришла новая пачка
									ориентировок. Вот держи, внимательно изучи их.]];
						};
						{
							text = [[— Отправляйся в город и проверяй документы у всех,
									кто подходит под ориенторовки. План на сегодня:
									проверить или задержать ]].. CONST_NEED_COUNT_DOCUMENTS ..[[ человек.]];
						};
						{
							text = [[— Требуй на проверку документы у всех
									подозреваемых, используя радиальное меню на “TAB”.
									При неоднократном отказе, игрок автоматически
									получит розыск. Если у игрока имеется розык или
									он совершит преступление на твоих глаза, то над
									его ником появится соответствующая надпись.]];
							info = true;
						};
					}, "PlayerAction_Task_Police_1_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_Police_1_step_1";
		};
		[2] = {
			name = "Выполни план";

			Setup = {
				client = function()
					local count_checked = CONST_NEED_COUNT_DOCUMENTS

					CEs.func_handler_stream_in = function()
						if getElementType( source ) ~= "player" then return end
						if source == localPlayer then return end
						if not source:IsInGame() then return end
						if source:IsInFaction() then return end
						if source:IsInFaction() then return end
						if source:getData( "wanted_data" ) then return end

						if math.random(1, 3) == 1 then
							local wanted_check_timeout = source:getData( "wanted_check_timeout" )
							if not wanted_check_timeout or wanted_check_timeout < getRealTime().timestamp then
								source:setData( "wanted_check", true, false )
								source:setData( "wanted_check_timeout", getRealTime().timestamp + 120, false )
							end
						end
					end
					addEventHandler( "onClientElementStreamIn", root, CEs.func_handler_stream_in )

					CEs.func_handler_stream_out = function()
						if getElementType( source ) ~= "player" then return end

						source:setData( "wanted_check", nil, false )

						local wanted_check_timeout = source:getData( "wanted_check_timeout" )
						if wanted_check_timeout and wanted_check_timeout < getRealTime().timestamp then
							source:setData( "wanted_check_timeout", nil, false )
						end
					end
					addEventHandler( "onClientElementStreamOut", root, CEs.func_handler_stream_out )

					CEs.func_handler_action = function( failed )
						source:setData( "wanted_check", nil, false )
						source:setData( "wanted_check_timeout", getRealTime().timestamp + 120, false )

						if not failed then
							count_checked = count_checked - 1
							if count_checked == 0 then
								triggerServerEvent( "PlayerAction_Task_Police_1_step_2", localPlayer )
								localPlayer:CompleteDailyQuest( "dps_verify_documents" )
								localPlayer:CompleteDailyQuest( "pps_verify_documents" )
							else
								localPlayer:ShowInfo( "По плану осталось еще ".. count_checked .." чел." )
							end
						end
					end
					addEventHandler( "PlayerAction_PassportShowSuccess", root, CEs.func_handler_action )
					addEventHandler( "PlayerAction_JailedSuccess", root, CEs.func_handler_action )
				end;
			};

			CleanUp = {
				client = function()
					removeEventHandler( "onClientElementStreamIn", root, CEs.func_handler_stream_in )
					removeEventHandler( "onClientElementStreamOut", root, CEs.func_handler_stream_out )
					removeEventHandler( "PlayerAction_PassportShowSuccess", root, CEs.func_handler_action )
					removeEventHandler( "PlayerAction_JailedSuccess", root, CEs.func_handler_action )

					CEs.func_handler_stream_in = nil
					CEs.func_handler_stream_out = nil
					CEs.func_handler_action = nil

					for _, player in pairs(getElementsByType("player")) do
						player:setData( "wanted_check", nil, false )
						player:setData( "wanted_check_timeout", nil, false )
					end
				end;
			};

			event_end_name = "PlayerAction_Task_Police_1_step_2";
		};
	};

	GiveReward = function( player )
		player:CompleteDailyQuest( "dps_watch_posts" )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_police_1", 300 )
	end;
	success_text = "Задача выполнена! Вы получили +300 очков";

	rewards = {
		faction_exp = 300;
	};
}