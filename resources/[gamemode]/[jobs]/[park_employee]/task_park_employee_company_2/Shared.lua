QUEST_DATA = {
	id = "task_park_employee_company_2";

	title = "Поливальщик";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_PARK_EMPLOYEE
	end;

	replay_timeout = 0;

	tasks = 
	{
		[1] = 
		{
            name = "Отправляйся к своему участку";

            Setup = {
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					if not CHECK_POS_TIMER then
						addEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle ) 
						StartCheckPosition( Vector3(1864.9016, 1073.3876, 16.3221) )
					end
					CUR_AREA_ID = GetFreeArea( CUR_AREA_ID )
					CreateQuestPoint(AREAS[CUR_AREA_ID].start, 
						function()
							if not localPlayer:getOccupiedVehicle() then
								localPlayer:ShowInfo("Неее, без поливалки не пойдет...")
								return
							end
							triggerServerEvent( "PlayerAction_Task_Park_Employee_2_step_1", localPlayer )
						end
					,_, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
                end
            },

            event_end_name = "PlayerAction_Task_Park_Employee_2_step_1";
		};

		[2] = 
		{
			name = "Включи поливалку";

			Setup = {
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					CURRENT_GAME = ibCreateMouseKeyPress({
						texture = "img/hint1.png",
						callback = function()
							SOUND_WATER = Sound( "sfx/water_on1.mp3", true )
							SOUND_WATER:setEffectEnabled( "echo", true )
							SOUND_WATER:setVolume( 0.1 )
							CURRENT_GAME = nil
							triggerServerEvent( "PlayerAction_Task_Park_Employee_2_step_2", localPlayer )
						end,
						check = function()
							if localPlayer:getOccupiedVehicle() then
								return true
							else
								localPlayer:ShowInfo("Неее, без поливалки не пойдет...")
							end
						end,
						key = "h"
					})
				end,
			},

			event_end_name = "PlayerAction_Task_Park_Employee_2_step_2";
		};

		[3] =
		{
			name = "Полей участок";

			Setup = {

				client = function()
					local vehicle = localPlayer:getOccupiedVehicle()
					if vehicle then
						vehicle:ping( )
					end

					function OnSound()
						SOUND_WATER:setVolume( 0.1 )
					end
					addEventHandler( "onClientVehicleEnter", vehicle, OnSound )

					function OffSound()
						SOUND_WATER:setVolume( 0.0 )
					end
					addEventHandler( "onClientVehicleExit", vehicle, OffSound )
					

					CURRENT_GAME = CreateSurfacePaint({
						center_area = AREAS[ CUR_AREA_ID ].center,
						area_size = AREAS[ CUR_AREA_ID ].area_size,
						check = function()
							return localPlayer:isInVehicle()
						end,
						callback = function()
							SOUND_WATER:stop( )
							triggerServerEvent( "PlayerAction_Task_Park_Employee_2_step_3", localPlayer )
						end
					})
				end;

				server = function( player, data )
					local vehicle = player:getOccupiedVehicle()
					vehicle:setVelocity( 0, 0, 0 )
					setVehicleParameters( vehicle, 0, 0, 0 )
				end;
			};

			CleanUp = {

				client = function()
					local vehicle = localPlayer:getOccupiedVehicle()
					if not vehicle then return end
					removeEventHandler( "onClientVehicleEnter", vehicle, OnSound )
					removeEventHandler( "onClientVehicleExit", vehicle, OffSound )
				end;
				
				server = function( player, data )
					local vehicle = player:getOccupiedVehicle()
					if not vehicle then return end

					setVehicleParameters( vehicle, 0, 0, 0 )
				end;
			};

			event_end_name = "PlayerAction_Task_Park_Employee_2_step_3";
		};
	};
	
	GiveReward = function( player )
		triggerEvent( "onParkEmployeeFinishedWatering", resourceRoot, player )
		StartAgain( player )
	end;

	no_show_rewards = true;
	no_show_success = true;
}


function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 100, 1 )
end