QUEST_DATA = {
	id = "task_park_employee_company_3";

	title = "Ремонтник";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_PARK_EMPLOYEE
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
            name = "Отправляйся к сломанной детали";

            Setup = {
				client = function()
					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end

					if not CHECK_POS_TIMER then
						addEventHandler( "onClientVehicleEnter", root, onFailQuestEnterInVehicle ) 
						StartCheckPosition( CENTER_PARK_POINT )
					end
					
					CURRENT_AREA_ID = GetFreeArea( CURRENT_AREA_ID )

					local mini_game = false
                    CreateQuestPoint( AREAS[ CURRENT_AREA_ID ],
			function( )
							if mini_game then return end

							if localPlayer:getOccupiedVehicle( ) then
								localPlayer:ShowInfo("Ты чего? Собрался ремонтировать прямо из машины?")
								return
							end

							mini_game = true

							CURRENT_UI_ELEMENT = ibCreateMouseKeyPress({
								texture = "img/hint1.png",
								callback = function()
									localPlayer:setPosition(localPlayer:getPosition())
									localPlayer:setAnimation( "bd_fire", "wash_up", -1, true, false, false, false )
									setTimer(triggerServerEvent, 3050, 1, "PlayerAction_Task_Park_Employee_3_step_1", localPlayer)
									CURRENT_UI_ELEMENT:destroy()
									CEs.marker.marker:destroy()
								end,
								key = "lalt",
								check = function()
									local player_vehicle = localPlayer:getOccupiedVehicle()
									if isElementWithinMarker( localPlayer, CEs.marker.marker ) and not player_vehicle then
										return true
									elseif player_vehicle then
										localPlayer:ShowInfo("Ты чего? Собрался ремонтировать прямо из машины?")
									else
										localPlayer:ShowInfo("Вернись к поломке для осмотра!")
									end
								end,
								hide = true
							})
						end
					,_, 1.5, 0, 0, false, false, false, "cylinder", 30, 160, 60, 50 )
                end
            },

            event_end_name = "PlayerAction_Task_Park_Employee_3_step_1";
		};
		[2] =
		{
			name = "Замени сломанную деталь",

			Setup = {
				client = function()

					local playerVehicle = localPlayer:getData("job_vehicle") 
					if playerVehicle then
						playerVehicle:ping( )
					end
					
					local mini_game = false
					createMiniGame({
						[1] = 
						{
							--Добраться до поломки
							action = function()
								if mini_game then return end
								mini_game = true

								local element = ibCreateMouseKeyStroke({
									texture = "img/hint2.png",
									callback = function()
										mini_game = false
										createNextGameStep()
									end,
									key = "mouse2"
								})
								return element
							end
						},
						[2] = 
						{
							--Снять крышку
							action = function()
								if mini_game then return end
								mini_game = true

								local element = ibCreateMouseKeyPress({
									texture = "img/hint3.png",
									callback = function()
										mini_game = false
										local sound = Sound( "sfx/remove_cover.mp3" )
										sound:setVolume( 0.3 )
										createNextGameStep()
									end,
									key = "mouse1"
								})
								return element
							end
						},
						[3] =
						{
							--Заменить соединение
							action = function()
								if mini_game then return end
								mini_game = true
								
								local element = ibCreatePressInCircleRegion({
									texture = "img/hint_4.png",
									callback = function()
										mini_game = false
										createNextGameStep()
										localPlayer:setAnimation()
										createNextGameStep()
										triggerServerEvent( "PlayerAction_Task_Park_Employee_3_step_2", localPlayer )
									end,
									key = "mouse2"
								})
								return element
							end
						}
					})
				end
			},

			event_end_name = "PlayerAction_Task_Park_Employee_3_step_2";
		}
		
	};
	
	GiveReward = function( player )
		triggerEvent( "onParkEmployeeFinishedRepair", resourceRoot, player )
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