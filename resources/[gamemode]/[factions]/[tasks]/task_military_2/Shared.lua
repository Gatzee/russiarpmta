CONST_NEED_COUNT_BOX = 15

CONST_AMMO_POINTS = {
	[1] = {
		text = "Перенеси ящик со склада в\n1-ый грузовик";
		position = Vector3( -2405.885, -252.198 + 860, 20.249 );
		next_index = 2;
	};
	[2] = {
		text = "Перенеси ящик из 1-го грузовика во 2-ой";
		position = Vector3( -2414.783, -243.342 + 860, 20.105 );
		next_index = 3;
	};
	[3] = {
		text = "Перенеси ящик из 2-го грузовика на склад";
		position = Vector3( -2414.882, -260.517 + 860, 20.105 );
		next_index = 1;
	};
	[4] = {
		text = "Перенеси ящик со склада во\n2-ой грузовик";
		position = Vector3( -2405.885, -252.198 + 860, 20.249 );
		next_index = 3;
	};
	[5] = {
		text = "Перенеси ящик из 1-го грузовика на склад";
		position = Vector3( -2414.783, -243.342 + 860, 20.105 );
		next_index = 1;
	};
}

QUEST_DATA = {
	id = "task_military_2";

	title = "Склад вооружения";
	description = "";

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( localPlayer:IsOnUrgentMilitary() and 13 or 20, {
						{
							text = [[— Для тебя есть полезная и важная задача.
									Нужно потаскать коробки с боеприпасами.]];
						};
						{
							text = [[— Отправляйся на склад вооружения, там тебе
									может быть всё объяснят. Что ждешь? Бегом боец!]];
						};
					}, "PlayerAction_Task_Militaty_2_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_2_step_1";
		};
		[2] = {
			name = "Разгрузи боеприпасы";

			Setup = {
				client = function()
					local count_box = CONST_NEED_COUNT_BOX
					local current_index = 0

					toggleControl( "fire", false )
					toggleControl( "jump", false )
					toggleControl( "sprint", false )
					toggleControl( "crouch", false )
					toggleControl( "enter_exit", false )
					toggleControl( "next_weapon", false )
					toggleControl( "previous_weapon", false )
					toggleControl( "aim_weapon", false )

					setPedWeaponSlot( localPlayer, 0 )

					CEs.func_create_start = function()
						if CEs.marker and isElement( CEs.marker.colshape ) then
							CEs.marker.destroy()
						end

						if isElement( CEs.object ) then
							destroyElement( CEs.object )
							setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
							toggleControl( "fire", false )
							count_box = count_box - 1

							if count_box == 0 then
								triggerServerEvent( "PlayerAction_Task_Militaty_2_step_2", localPlayer )
								return
							end
						end

						current_index = current_index % #CONST_AMMO_POINTS + 1

						localPlayer:ShowInfo( CONST_AMMO_POINTS[ current_index ].text )
						CreateQuestPoint( CONST_AMMO_POINTS[ current_index ].position, CEs.func_create_end_point, _, 2 )
					end

					CEs.func_create_end_point = function()
						triggerServerEvent( "Task_Militaty_2_Remove_Vehicle", localPlayer )
						CEs.marker.destroy()

						if math.random( 1, 10 ) == 1 then
							CEs.object = Object( 1518, localPlayer.position )
							exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.1, 0.40, 0.2, 25, 180, 25 )
						else
							CEs.object = Object( 3052, localPlayer.position )
							exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.1, 0.3, 0.3, 25, 180, 25 )
						end

						CEs.object.dimension = localPlayer.dimension

						setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
						toggleControl( "fire", false )
						localPlayer:ShowInfo( "Осталось перенести еще ".. count_box .." шт." )

						local next_index = CONST_AMMO_POINTS[ current_index ].next_index
						CreateQuestPoint( CONST_AMMO_POINTS[ next_index ].position, CEs.func_create_start, _, 2 )

						current_index = current_index % #CONST_AMMO_POINTS + 1
					end

					CEs.func_create_start()
				end;
			};

			CleanUp = {
				client = function()
					CEs.func_create_start = nil
					CEs.func_create_end_point = nil

					toggleControl( "fire", true )
					toggleControl( "jump", true )
					toggleControl( "sprint", true )
					toggleControl( "crouch", true )
					toggleControl( "enter_exit", true )
					toggleControl( "next_weapon", true )
					toggleControl( "previous_weapon", true )
					toggleControl( "aim_weapon", true )

					setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_2_step_2";
		};
	};

	rewards = {
		faction_exp = 30;
		military_exp = 600;
	};

	GiveReward = function( player )
		local rewards = player:IsOnUrgentMilitary( ) and { type = "military_exp", value = 600 } or { type = "faction_exp", value = 30 }
		player:ShowRewards( rewards )
		player:CompleteDailyQuest( "army_weapons_depot" )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_military_2", 30 )
	end;

	no_show_rewards = true,
	success_text = "Задача выполнена! Вы получили +30 очков ранга";
}