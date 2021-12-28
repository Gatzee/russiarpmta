towers_data = {
	{
		point_position = Vector3( -2610.784, -84.489 + 860, 26.143 );
		npc_position = Vector3( -2609.847, -64.708 + 860,  20.260  );
		npc_rotation = 227;
	};
	{
		point_position = Vector3( -2472.859, -82.068 + 860, 26.143 );
		npc_position = Vector3( -2468.324, 793.270 + 860, 20.095 );
		npc_rotation = 300;
	};
	{
		point_position = Vector3( -2446.532, 91.191 + 860, 26.143 );
		npc_position = Vector3( -2446.386,  106.307 + 860, 19.900 );
		npc_rotation = 24;
	};
	{
		point_position = Vector3( -2311.319, 92.459 + 860, 26.143 );
		npc_position = Vector3(  -2297.803, 99.233 + 860, 20.098 );
		npc_rotation = 117;
	};
	{
		point_position = Vector3( -2310.753, -94.399 + 860, 26.14 );
		npc_position = Vector3( -2296.124, -93.921 + 860, 20.102 );
		npc_rotation = 158;
	};
	{
		point_position = Vector3( -2311.094, -349.737 + 860, 26.143 );
		npc_position = Vector3( -2295.932, -351.105 + 860, 20.101 );
		npc_rotation = 232;
	};
	{
		point_position = Vector3( -2611.113, -347.063 + 860, 26.143 );
		npc_position = Vector3( -2628.091, -346.09 + 860, 20.634 );
		npc_rotation = 265;
	};
}

CONST_TIME_TO_END = 900000
CONST_TIME_MIN_START_ENEMY = 550000
CONST_TIME_MAX_START_ENEMY = 750000

CONST_TELEPORT_BACK_POSITION = Vector3( -2372.944, -113.476 + 860, 21 )

QUEST_DATA = {
	id = "task_military_1";

	title = "Караул";
	description = "";

	replay_timeout = 180;
	failed_timeout = 180;
	
	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( 13, {
						{
							text = [[— Караул - это очень ответсвенная задача!
									Внимательно следи за постом и никого
									не пускай на территорию части. Можешь
									открывать огонь на поражение по нарушителям.]];
						};
						{
							text = [[— Вот держи карточку, без неё оружие не получить.
									А теперь ступай на склад, получи вооружение и
									мигом шуруй на пост сменять караульного!]];
						};
					}, "PlayerAction_Task_Militaty_1_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_1_step_1";
		};
		[2] = {
			name = "Получи вооружение";

			Setup = {
				client = function()
					CreateQuestPoint( Vector3( -2406.948, -252.055 + 860, 20.105 ), "PlayerAction_Task_Militaty_1_step_2" )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_1_step_2";
		};
		[3] = {
			name = "Заступи на пост";

			Setup = {
				client = function()
					CEs.object = Object(355, localPlayer.position)
					CEs.object.interior = localPlayer.interior
					CEs.object.dimension = localPlayer.dimension
					exports.bone_attach:attachElementToBone(CEs.object, localPlayer, 2, 0.2, -0.15, -0.38, 0, -90, 0)

					local random_tower_number = math.random(1, #towers_data)
					localPlayer:setData( "quest_random_tower_number", random_tower_number, false )

					CreateQuestPoint( towers_data[ random_tower_number ].point_position, "PlayerAction_Task_Militaty_1_step_3", _, 3.5 )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_1_step_3";
		};
		[4] = {
			name = "Неси службу бодро";

			Setup = {
				client = function()
					StartQuestTimerWait( CONST_TIME_TO_END, "Не спи, боец", "Через твой пост на территорию части проник враг!", "PlayerAction_Task_Militaty_1_step_4", function()
						return not ( isElement( CEs.enemy_ped ) and not isPedDead( CEs.enemy_ped ) )
					end )
					
					local random_tower_number = localPlayer:getData( "quest_random_tower_number" )

					CEs.shape = createColSphere( towers_data[ random_tower_number ].point_position, 4.5 )
					CEs.shape.interior = localPlayer.interior
					CEs.shape.dimension = localPlayer.dimension
					addEventHandler("onClientColShapeLeave", CEs.shape, function(player, dim)
						if localPlayer ~= player or not dim then return end

						localPlayer.position = CONST_TELEPORT_BACK_POSITION + Vector3( math.random( -3, 3 ), math.random( -3, 3 ), 0 )
						
						-- СЮДА БЛЯТЬ
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Куда с оружием пошел, дезертир?!" } )
					end)

					CEs.event_func = function( weapon )
						if weapon == 30 then
							if not isElement( CEs.enemy_ped ) then
								-- И СЮДА БЛЯТЬ
								triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Ты не в тире, сынок, а на посту" } )
							end
						end
					end
					addEventHandler( "onClientPlayerWeaponFire", localPlayer, CEs.event_func )
					
					local enemy_timer = Timer(function()
						CEs.enemy_ped = createPed( 15, towers_data[ random_tower_number ].npc_position, towers_data[ random_tower_number ].npc_rotation )
						CEs.enemy_ped.interior = localPlayer.interior
						CEs.enemy_ped.dimension = localPlayer.dimension

						CEs.enemy_ped_marker = createMarker( towers_data[ random_tower_number ].npc_position, "arrow", 1, 255, 0, 0 )
						CEs.enemy_ped_marker.interior = localPlayer.interior
						CEs.enemy_ped_marker.dimension = localPlayer.dimension
						CEs.enemy_ped_marker:setParent( CEs.enemy_ped )
						attachElements( CEs.enemy_ped_marker, CEs.enemy_ped, 0, 0, 2.5 )

						setPedControlState( CEs.enemy_ped, "forwards", true )
						givePedWeapon( CEs.enemy_ped, 25, 9999, true )

						local timer_enemy_attack = nil

						local timer_enemy_fail = Timer( function()
							if isElement( CEs.enemy_ped ) and not isPedDead( CEs.enemy_ped ) then
								if isTimer(timer_enemy_attack) then
									resetTimer( sourceTimer )
								else
									triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Через твой пост на территорию части проник враг" } )
								end
							end
						end, 5000, 1 )

						AddCustomTimer( timer_enemy_fail )

						addEventHandler( "onClientPedDamage", CEs.enemy_ped, function( attacker, weapon )
							if attacker ~= localPlayer or weapon ~= 30 then
								cancelEvent()
								return
							end

							setPedControlState( CEs.enemy_ped, "forwards", false )
							setPedControlState( CEs.enemy_ped, "aim_weapon", true )
							setPedControlState( CEs.enemy_ped, "fire", true )
							setPedAimTarget( CEs.enemy_ped, localPlayer.position )

							if not isTimer( timer_enemy_attack ) then
								timer_enemy_attack = Timer( function()
									if isElement( CEs.enemy_ped ) and not isPedDead( CEs.enemy_ped ) then
										CEs.enemy_ped.rotation = Vector3( 0, 0, FindRotation( CEs.enemy_ped.position.x, CEs.enemy_ped.position.y, localPlayer.position.x, localPlayer.position.y ) )
										
										setPedAimTarget( CEs.enemy_ped, localPlayer.position )
									else
										killTimer( sourceTimer )
									end
								end, 800, 0 )

								AddCustomTimer( timer_enemy_attack )
							end
						end )

						addEventHandler( "onClientPedWasted", CEs.enemy_ped, function()
							local enemy_alpha_timer = Timer( function()
								if isElement( CEs.enemy_ped ) then
									CEs.enemy_ped.alpha = math.max( 0, CEs.enemy_ped.alpha - 7 )

									if CEs.enemy_ped.alpha <= 5 then
										destroyElement( CEs.enemy_ped )
										killTimer( sourceTimer )

										if isTimer( timer_enemy_fail ) then
											killTimer( timer_enemy_fail )
										end

										if isTimer( timer_enemy_attack ) then
											killTimer( timer_enemy_attack )
										end
									end
								else
									killTimer( sourceTimer )
								end
							end, 50, 40 )

							AddCustomTimer( enemy_alpha_timer )
						end)
					end, math.random(CONST_TIME_MIN_START_ENEMY, CONST_TIME_MAX_START_ENEMY), 1)

					AddCustomTimer( enemy_timer )
				end;

				server = function(player)
					player:GiveWeapon(30, 120, true, true)
				end;
			};

			CleanUp = {
				client = function()
					removeEventHandler( "onClientPlayerWeaponFire", localPlayer, CEs.event_func )
					CEs.event_func = nil
				end;

				server = function(player)
					player:TakeWeapon(30)
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_1_step_4";
		};
		[5] = {
			name = "Сдай оружие";

			Setup = {
				client = function()
					CEs.object = Object(355, localPlayer.position)
					CEs.object.interior = localPlayer.interior
					CEs.object.dimension = localPlayer.dimension
					exports.bone_attach:attachElementToBone(CEs.object, localPlayer, 2, 0.2, -0.15, -0.38, 0, -90, 0)

					CreateQuestPoint( Vector3( -2406.948, -252.055 + 860, 20.105 ), "PlayerAction_Task_Militaty_1_step_5" )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_1_step_5";
		};
	};

	rewards = {
		faction_exp = 225;
		military_exp = 225;
	};

	GiveReward = function( player )
		player:ShowRewards( { type = player:IsOnUrgentMilitary( ) and "military_exp" or "faction_exp", value = 225 } )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_military_1", 225 )
	end;

	no_show_rewards = true;

	success_text = "Задача выполнена! Вы получили +225 очков ранга";
}