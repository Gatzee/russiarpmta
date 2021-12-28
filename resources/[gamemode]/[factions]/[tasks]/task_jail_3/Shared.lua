
ASSEMBLY_POINTS =
{
	--Точки от входа
	Vector3( -2669.8500, 2925.1557, 1571.4427 );
	Vector3( -2666.9577, 2925.1557, 1571.4427 );
	Vector3( -2661.8715, 2925.1557, 1571.4427 );
	Vector3( -2658.3269, 2925.1557, 1571.4427 );

	--Точки по центру
	Vector3( -2669.8500, 2927.7341, 1571.4427 );
	Vector3( -2666.9577, 2927.7341, 1571.4427 );
	Vector3( -2661.8715, 2927.7341, 1571.4427 );
	Vector3( -2658.3269, 2927.7341, 1571.4427 );

	--Точки с краю
	Vector3( -2669.8500, 2930.3579, 1571.4427 );
	Vector3( -2666.9577, 2930.3579, 1571.4427 );
	Vector3( -2661.8715, 2930.3579, 1571.4427 );
	Vector3( -2658.3269, 2930.3579, 1571.4427 );
}

QUEST_DATA = {
	id = "task_jail_3";

	title = "Сборка";
	description = "";

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Подойди к верстаку";

			Setup = {
				client = function()

					local position = ASSEMBLY_POINTS[ math.random( 1, #ASSEMBLY_POINTS ) ]
					CreateQuestPoint( position, "task_jail_3_end_step_1", _, 1, localPlayer:getInterior(), localPlayer:getDimension(), false, _, _, "cylinder" )
				end;
			};
		};
		[2] = {
			name = "Собери 5 деталей";

			Setup = {
				client = function()
					createAssemblyMinigame({
						success_callback = function()
							CONST_ASSEMBLY_DETAILS = CONST_ASSEMBLY_DETAILS + 1
							if CONST_ASSEMBLY_DETAILS >= 5 then
								destroyMinigame()
								triggerServerEvent( "task_jail_3_end_step_2", localPlayer )
								triggerEvent( "onClientCreateJobMarkers", localPlayer )

								triggerServerEvent( "onPlayerCompleteJailQuest", localPlayer )
							else
								createNextDetailAssembly()
							end
						end;
						fail_callback = function()
							destroyMinigame()
							triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Вы не собрали электрическую цепь" } )
							triggerEvent( "onClientCreateJobMarkers", localPlayer )

							triggerServerEvent( "onPlayerFailJailQuest", localPlayer, QUEST_DATA.id )
						end;
					})
				end;
			};
			CleanUp =
			{
				client = function()
					if isElement( UI_elements.blackBg ) then
						destroyMinigame()
					end
				end;
			}
		};

	};

	GiveReward = function( player )
		player:GiveMoney( 333, "job_salary", QUEST_DATA.id )
	end;

}