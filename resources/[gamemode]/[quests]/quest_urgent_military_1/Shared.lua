QUEST_DATA = {
	id = "urgent_military_1";

	title = "Начало срочной службы";
	description = "";

	replay_timeout = 0;

	CheckToStart = function(player)
		return true
	end;

	tasks = {
		[1] = {
			name = "Прибытие в часть";

			Setup = {
				client = function()
					fadeCamera( false, 1 )

					CEs.timer = Timer(function()
						DisableHUD( true )
						fadeCamera( true, 1 )

						local BUS_VEHICLE_START_POSITION = Vector3( -1099.427, -1140.697 + 860, 22.341 )

						local timer_sound = Timer( function()
							CEs.sound = playSound( "files/intro.ogg" )
							CEs.sound.volume = 0.2
						end, 1000, 1 )

						CEs.bus_vehicle = Vehicle( 437, BUS_VEHICLE_START_POSITION )
						CEs.bus_vehicle.dimension = URGENT_MILITARY_DIMENSION
						CEs.bus_vehicle:setColor( 64, 120, 64, 40, 90, 40, 64, 120, 64, 40, 90, 40 )

						CEs.bus_driver = Ped( 95, BUS_VEHICLE_START_POSITION )
						CEs.bus_driver.dimension = URGENT_MILITARY_DIMENSION
						CEs.bus_driver:warpIntoVehicle( CEs.bus_vehicle )

						CEs.bus_driver:setControlState( "accelerate", true )
						CEs.bus_vehicle.velocity = Vector3( 0, 0.15, 0 )

						CEs.timer = Timer( function()
							fadeCamera( false, 3 )

							CEs.timer = Timer( function()
								triggerServerEvent( "PlayerAction_Urgent_Militaty_step_1", localPlayer )
							end, 3000, 1 )
						end, 8000, 1 )

						smoothMoveCamera( -1106.9327, -1132.8616 + 860, 22.6843, -1083.8087, -1037.3599 + 860, 4.1182, -1107.9615, -1138.8707 + 860, 50.3679, -1102.1030, -1046.0890 + 860, 30.5272, 9000 )
					end, 3000, 1)
				end;

				server = function( player )
					player.frozen = true
					player:setData( "quest_save_dim", player.dimension, false )
					player.dimension = URGENT_MILITARY_DIMENSION

					triggerEvent( "onPlayerUrgentMilitaryJoin", player )
				end;
			};

			CleanUp = {
				client = function()
					DisableHUD( false )
					setCameraTarget( localPlayer )
				end;

				server = function( player )
					player.frozen = false
				end;
			};

			event_end_name = "PlayerAction_Urgent_Militaty_step_1";
		};
		[2] = {
			name = "Курс молодого бойца";

			Setup = {
				client = function()
					DisableHUD( true )
					fadeCamera( true, 2 )

					setCameraMatrix( -2329.2792, 35.7236 + 860, 24.0339, -2367.8576, -54.2521 + 860, 3.6362 )

					local dialogs_data = {
						{
							title = "Теперь ты в армии, на...";
							text = [[Ты попал на срочную службу.
									Тут ты должен выполнять задачи, поставленные
									твоим руководителем - прапорщиком Заёпкиным]];
						};
						{
							title = "Система званий";
							text = nil;
						};
						{
							title = "Система званий";
							text = [[Звание можно повысить с помощью выполнения
									специальных задач в пределах части.
									Взять задачу ты можешь на маркере рядом
									с одной из казарм.]];
						};
						{
							title = "Выход в город";
							text = [[Ты можешь покинуть часть в любой момент
									и пойти заниматься своими делами.
									На срочной службе тебя никто в этом
									не ограничивает, но...]];
						};
						{
							title = "Выход в город";
							text = [[Когда ты покидаешь часть, тебе выдают
									увольнительную на 2 часа. По истечению времени
									её действия, ты обязан вернуться в в/ч.
									После возврата в часть, новую увольнительную
									можно получить только через 20 минут.
									Получить увольнительную можно в Штабе.]];
						};
						{
							title = "Выход в город";
							text = [[В городе работает военная полиция,
									которая ловит срочников с просроченными
									увольнительными и принудительно возвращает
									нарушителей в войсковую часть.]];
						};
						{
							title = "Военный билет";
							text = [[Достигнув звания “Сержант“, ты автоматически
									закончишь срочную службу и получишь военный
									билет. Также ты всегда можешь купить его
									через меню “F4“ в разделе “Услуги“.]];
						};
					}

					CEs.button_next_idle_texture = dxCreateTexture( "files/button_next_idle.png" )
					CEs.button_next_hover_texture = dxCreateTexture( "files/button_next_hover.png" )
					CEs.button_next_click_texture = dxCreateTexture( "files/button_next_click.png" )

					local func_create = nil
					func_create = function( index )
						if isElement( CEs.black_bg ) then
							CEs.bg_img:ibAlphaTo( 0, 500, "Linear")
							CEs.timer = Timer( function()
								if isElement( CEs.black_bg ) then
									destroyElement( CEs.black_bg )
									func_create( index )
								end
							end, 500, 1 )

							return
						end

						showCursor( true )
						
						CEs.black_bg = ibCreateImage( 0, 0, scX, scY, _, _, 0x80495F76 )

						CEs.bg_img = ibCreateImage( (scX - 500) / 2, (scY - 340) / 2, 500, 340, "files/bg.png", CEs.black_bg )
						:ibData( "alpha", 0 )
						:ibAlphaTo( 255, 500, "Linear" )

						CEs.title = ibCreateLabel( 30, 38, 0, 0, dialogs_data[ index ].title, CEs.bg_img, 0xFFFFEE8F, 1, 1, "left", "center", ibFonts.semibold_15 )
						
						if dialogs_data[ index ].text then

							CEs.text = ibCreateLabel( 250, 160, 0, 0, dialogs_data[ index ].text, CEs.bg_img, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_13 )

						else
							CEs.text = ibCreateImage( 46, 112, 408, 95, "files/soctil_text.png", CEs.bg_img )
						end
						
						CEs.button_next = ibCreateButton( 	170, 240, 160, 56, CEs.bg_img, "files/button_next_idle.png", "files/button_next_hover.png", "files/button_next_click.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )
						:ibOnClick( function( button, state )
							if button ~= "left" or state ~= "up" then return end

							if dialogs_data[ index + 1 ] then
								func_create( index + 1 )
							else
								showCursor( false )
								triggerServerEvent( "PlayerAction_Urgent_Militaty_step_2", localPlayer )
							end
						end )
					end

					func_create( 1 )
				end;

				server = function( player )
					player.frozen = true
					player:setData( "quest_save_dim", player.dimension, false )
					player.dimension = URGENT_MILITARY_DIMENSION
				end;
			};

			CleanUp = {
				client = function()
					DisableHUD( false )
					setCameraTarget( localPlayer )
				end;

				server = function( player )
					player.frozen = false
				end;
			};

			event_end_name = "PlayerAction_Urgent_Militaty_step_2";
		};
	};

	GiveReward = function( player )
		player:StartUrgentMilitary()
		player:ParkedVehicles()

		triggerEvent( "PlayeStartQuest_urgent_military_2", player )
	end;
}