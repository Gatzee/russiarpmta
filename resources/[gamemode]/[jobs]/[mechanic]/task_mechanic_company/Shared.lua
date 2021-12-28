QUEST_DATA = {
	id = "task_mechanic_company";

	title = "Автомеханик";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_MECHANIC
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Осмотри автомобиль";

			Setup = {
				client = function()

					--Поиск следующего гаража, не совпадающего с текущим
					local iter = 0
					local garage_id
					repeat
						garage_id = math.random( 1, #GARAGE_DATA )
						iter = iter + 1
						if iter > 256 then break end
					until garage_id ~= CUREENT_GARAGE_ID
					CUREENT_GARAGE_ID = garage_id

					--Поиск следующей машины, не совпадающей с текущей
					iter = 0
					local vehicle_id
					repeat
						vehicle_id = math.random( 1, #GARAGE_DATA[ CUREENT_GARAGE_ID ].vehice_data )
						iter = iter + 1
						if iter > 256 then break end
					until vehicle_id ~= CUREENT_VEHICLE_ID
					CUREENT_VEHICLE_ID = vehicle_id


					--Задание новой модели для машины
					REPAIR_VEHICLE.vehicle_id = math.random( 1, #VEHICLES )
					REPAIR_VEHICLE.viewDirection = VEHICLES[ REPAIR_VEHICLE.vehicle_id ].forward and 1 or 2
					REPAIR_VEHICLE.vehicle = PROXY_VEHICLES[ CUREENT_GARAGE_ID .. CUREENT_VEHICLE_ID ]
					
					--Задаем случайную модель, для имитации уникальности машин
					setElementFrozen( REPAIR_VEHICLE.vehicle, false )
					setElementModel( REPAIR_VEHICLE.vehicle, VEHICLES[ REPAIR_VEHICLE.vehicle_id ].model )

					local vehpos = REPAIR_VEHICLE.vehicle:getPosition()
					REPAIR_VEHICLE.vehicle:setPosition( vehpos.x, vehpos.y, VEHICLES[ REPAIR_VEHICLE.vehicle_id ].z )

					REPAIR_VEHICLE.vehicle:setVelocity( 0, 0, 0.04 )
					setTimer( setElementFrozen, 10000, 1, REPAIR_VEHICLE.vehicle, true )

					triggerEvent( "onVehicleRequestTuningRefresh", REPAIR_VEHICLE.vehicle )

					--Задаем колеса
					CURRENT_WHEEL_ID = math.random( 1, #WHEEL_MODELS )
					REPAIR_VEHICLE.vehicle:addUpgrade( WHEEL_MODELS[ CURRENT_WHEEL_ID ] )

					--Считывание позиции деталей машины
					REPAIR_VEHICLE.details = {}
					for k, v in pairs( VERIFIABLE_VEHICLE_DETAILS[ REPAIR_VEHICLE.viewDirection ] ) do

						if v == "bonnet_dummy" then
							local vx, vy, vz = REPAIR_VEHICLE.vehicle:getComponentPosition( v, "world" )
							local x, y, z = GetForwardBackwardElementPosition( REPAIR_VEHICLE.vehicle, REPAIR_VEHICLE.viewDirection - 1, 2.5 )
							REPAIR_VEHICLE.details[ k ] =  { name = v, position = Vector3( vx, vy, vz ), mrkPosition = Vector3( x, y, z ) }
						else
							local x, y, z = REPAIR_VEHICLE.vehicle:getComponentPosition( v, "world" )
							
							local r_com_x, r_com_y = REPAIR_VEHICLE.vehicle:getComponentPosition( v, "root" )
							local component = getPositionFromMatrixOffset( REPAIR_VEHICLE.vehicle, r_com_x * 2, r_com_y, 0)
				
							REPAIR_VEHICLE.details[ k ] =  { name = v, position = Vector3( x, y, z ), mrkPosition = Vector3( component.x, component.y, component.z ) }
						end
						
					end	
					
					--Открытие капота у машин с двигателем спереди
					if VEHICLES[ REPAIR_VEHICLE.vehicle_id ].forward then
						REPAIR_VEHICLE.vehicle:setComponentRotation( "bonnet_dummy", 45, 0, 0 )
						REPAIR_VEHICLE.vehicle:setComponentRotation( "rpb_bonnet_dummy", 45, 0, 0 )
					end

					--Создаем таймер для проверки позиции игрока,
					-- на случай если игрок хочет убежать от точки ремонта
					if not isTimer( CHECK_POS_TIMER ) then
						StartCheckPosition( GARAGE_DATA[ CUREENT_GARAGE_ID ].vehice_data[ CUREENT_VEHICLE_ID ].position )
					end

					local vehiclePartId = 0
					function CreateNextViewMarker()
						
						vehiclePartId = vehiclePartId + 1
						--Все детали были осмотрены?
						if VERIFIABLE_VEHICLE_DETAILS[ REPAIR_VEHICLE.viewDirection ][ vehiclePartId ] then
							
							CreateQuestPoint( REPAIR_VEHICLE.details[ vehiclePartId ].mrkPosition, 
								function()
									setRotationToTarget( localPlayer, REPAIR_VEHICLE.details[ vehiclePartId ].position )
									CEs.marker:destroy()
									
									if VERIFIABLE_VEHICLE_DETAILS[ REPAIR_VEHICLE.viewDirection ][ vehiclePartId ] == "bonnet_dummy" then
										localPlayer:setPosition( getElementPosition( localPlayer ) )
										localPlayer:setAnimation( "bd_fire", "wash_up", 1000, false, false, false, false )
									else
										localPlayer:setAnimation( "bd_fire", "wash_up", 1, false, false, true, false )	
										localPlayer:setAnimation( "bomber", "bom_plant_loop", 2000, false, false, false, false )
									end
									CreateNextViewMarker()
								end
							,_, 1.5, 0, 0, CheckingPlayerVehicle, "lalt", vehiclePartId < #VERIFIABLE_VEHICLE_DETAILS[ REPAIR_VEHICLE.viewDirection ] and "Нажми 'Левый Alt' чтобы осмотреть" or false, "cylinder", 0, 100, 230, 50 )
						
						else
							--все детали осмотрели, переходим к следующему этапу
							local temp = REPAIR_VEHICLE.details
							REPAIR_VEHICLE.details = nil
							REPAIR_VEHICLE.details = {}
							for k, v in ipairs( getUniqueQueue(#VERIFIABLE_VEHICLE_DETAILS[ REPAIR_VEHICLE.viewDirection ], math.random( 2, 5 ) )) do
								table.insert( REPAIR_VEHICLE.details, temp[ v ] )
							end

							triggerServerEvent( "PlayerAction_Task_Mechanic_1_step_1", localPlayer )
						end
					end
					
					if NEED_TIMER then
						StartQuestTimerWait( CONST_WAIT_TIME, "Ожидай следующую машину", _, _, function()
							CreateNextViewMarker()
							return true
						end )
					else
						CreateNextViewMarker()
						NEED_TIMER = true
					end
				end;
			};
			event_end_name = "PlayerAction_Task_Mechanic_1_step_1";
			
		};

		[2] = {
			name = "Замени детали";
			
			Setup = {
				client = function()
					CEs.count_details = #REPAIR_VEHICLE.details

					function createNextReplaceDetail()
						--Все детали были заменены?
						if #REPAIR_VEHICLE.details ~= 0 then
							
							local detail = REPAIR_VEHICLE.details[ #REPAIR_VEHICLE.details ]
							local isWheelDetail = detail.name:find("wheel") and true or false

							CreateQuestPoint( GARAGE_DATA[ CUREENT_GARAGE_ID ][ isWheelDetail and "wheel_marker" or "oil_marker" ],
								function()
									CEs.marker:destroy()
									localPlayer:setAnimation( "bomber", "bom_plant_loop", 1, false, false, true, false )
									--Аттач колеса / масла к руке
									if isWheelDetail then
										StartMechanicCarrying({
											model = WHEEL_MODELS[ CURRENT_WHEEL_ID ],
											scale = 0.8,
											bone = 12,
											offset_x = 0, offset_y = 0, offset_z = 0.4,
											rx = 0, ry = 20, rz = -90
										})
									else
										CEs.object = Object( 1544, localPlayer.position )
										exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 12, 0.1, 0.03, 0.06, 150, -90, -10 )
									end									
									createNextReplacePoint()
								end
							,_, 1.3, 0, 0, CheckingPlayerVehicle, "lalt", "Нажми 'Левый Alt' чтобы взять " .. (isWheelDetail and "колесо" or "масло"), "cylinder", 0, 100, 230, 50 )
							
						else
							--Все детали замены, переходим к следующей машине => StartAgain
							REPAIR_VEHICLE.vehicle:setComponentRotation( "bonnet_dummy", 0, 0, 0 )
							REPAIR_VEHICLE.vehicle:setComponentRotation( "rpb_bonnet_dummy", 0, 0, 0 )

							triggerServerEvent( "MechanicDaily_AddDetails", root, CEs.count_details )
							triggerServerEvent( "PlayerAction_Task_Mechanic_1_step_2", localPlayer )
						end
					end

					function createNextReplacePoint()
						
						local detail = REPAIR_VEHICLE.details[ #REPAIR_VEHICLE.details ]
						local isWheelDetail = detail.name:find( "wheel" ) and true or false
						local game_start = false

						CreateQuestPoint( detail.mrkPosition, function()
							
							if not game_start then
								game_start = true
								if isWheelDetail then
									createMiniGame({
										 
										[1] = 
										{
											--Положить колесо
											action = function()	
												local element = ibCreateMouseKeyPress({
													sx = 380,
													sy = 40,
													texture = "img/hint1.png",
													callback = function()
														localPlayer:setPosition( getElementPosition( localPlayer ) )
														setRotationToTarget( localPlayer, detail.position )
														StopMechanicCarrying()
														local forwardPosition = localPlayer.position:offset(0.8, 0)
														CEs.object = Object( WHEEL_MODELS[ CURRENT_WHEEL_ID ], forwardPosition.x, forwardPosition.y, forwardPosition.z - 0.9 )
														CEs.object:setRotation(0, -90, 0)
														CEs.object:setScale(0.8)
														createNextGameStep()
													end,
													check = function()
														if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
															return true
														else
															localPlayer:ShowInfo("Вернись к машине, для установки колеса!")
														end
													end
												})
												return element
											end
										},

										[2] = 
										{
											--Открутить болты
											action = function()
												localPlayer:setAnimation( "bomber", "bom_plant_loop", -1, true, false, false, false )
												local element = ibCreateMouseKeyHold({
													sx = 407,
													sy = 34,
													rect_x = 121,
													rect_y = 0,
													rect_size = 85,
													hold_time = 1900,
													count_hold = 4,
													texture = "img/hint2.png",
													callback = function()
														createNextGameStep()
													end,
													sound_path = "sfx/remove_wheel.mp3"
												})
												return element
											end
										},

										[3] =
										{
											--Снять колесо
											action = function()
												local element = ibCreateMouseKeyStroke({
													sx = 360,
													sy = 34,
													texture = "img/hint3.png",
													callback = function()
														REPAIR_VEHICLE.vehicle:setComponentVisible(detail.name, false)
														local sound = playSound( "sfx/wheel_op.mp3" )
														setSoundVolume( sound, 0.5 )
														createNextGameStep()
													end
												})
												return element
											end
											
										},

										[4] =
										{
											--Одеть колесо
											action = function()

												--Берём в руки колесо с земли
												CEs.object:destroy()
												CEs.object = Object( WHEEL_MODELS[ CURRENT_WHEEL_ID ], localPlayer.position )
												CEs.object:setScale(0.8)
												exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 12, 0, 0, 0.4, 0, 20, -90 )
												
												local element = ibCreateMouseKeyStroke({
													sx = 398,
													sy = 34,
													texture = "img/hint4.png",
													callback = function()
														CEs.object:destroy()
														REPAIR_VEHICLE.vehicle:setComponentVisible(detail.name, true)
														local sound = playSound( "sfx/wheel_op.mp3" )
														setSoundVolume( sound, 0.5 )
														createNextGameStep()
													end
												})
												return element
											end
										},

										[5] =
										{
											--Закрутить болты
											action = function()
												local element = ibCreateMouseKeyHold({
													sx = 407,
													sy = 34,
													rect_x = 121,
													rect_y = 0,
													rect_size = 85,
													hold_time = 1500,
													count_hold = 4,
													texture = "img/hint5.png",
													callback = function()
														CEs.marker:destroy()
														localPlayer:setAnimation( "bomber", "bom_plant_loop", 1, false, false, true, false )
														--Переходим к следующей детали для замены
														createNextReplaceDetail()
													end,
													sound_path = "sfx/install_wheel.mp3",
												})
												return element
											end
										},
										
									})

								else
									createMiniGame({
										[1] =
										{
											--Начать заливать масло
											action = function()

												local element = ibCreateMouseKeyPress({
													sx = 421,
													sy = 34,
													texture = "img/hint6.png",
													callback = function()
														localPlayer:setPosition( getElementPosition( localPlayer ) )
														localPlayer:setAnimation( "bd_fire", "wash_up", -1, true, false, false, false )
														createNextGameStep()
													end,
													check = function()
														if isElementWithinMarker( localPlayer, CEs.marker.marker ) then
															return true
														else
															localPlayer:ShowInfo("Вернись к машине, для заливки масла!")
														end
													end
												})
												return element
											end
										},

										[2] = 
										{
											--Заливка масла
											action = function()
												local element = ibCreateMouseKeyHoldInRegion({
													callback = function()
														CEs.marker:destroy()
														CEs.object:destroy()
														localPlayer:setAnimation( "bd_fire", "wash_up", 1, false, false, true, false )
														--Переходим к следующей детали для замены
														createNextReplaceDetail()
													end,
													sound_path = "sfx/oil.mp3"
												})
												return element
											end
										},
									})

								end
							elseif CURRENT_UI_ELEMENT and CURRENT_UI_ELEMENT.refresh then
								CURRENT_UI_ELEMENT.refresh()
							end
							
						end
						,_, 1.3, 0, 0, CheckingPlayerVehicle, _, _, "cylinder", 0, 100, 200, 50 )
						table.remove(REPAIR_VEHICLE.details, #REPAIR_VEHICLE.details)

					end

					--Все данные готовы, начинаем замену
					createNextReplaceDetail()
				end;
			};

			event_end_name = "PlayerAction_Task_Mechanic_1_step_2";
		};
		

	};

	GiveReward = function( player )
		triggerEvent( "onMechanicCompletedRepairLap", resourceRoot, player )
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

function CheckingPlayerVehicle( )
	if localPlayer.vehicle then return false end
	return true
end
