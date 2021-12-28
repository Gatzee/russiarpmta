CONST_PICKUP_TIME = 7 * 60 * 1000
CONST_DELIVER_TIME = 10 * 60 * 1000

addEvent( "onTaxiEarnMoney", true )

QUEST_DATA = {
	id = "task_taxi_company";

	title = "Таксист";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_TAXI
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Забери клиента";

			Setup = {
				client = function()
					THIS_POSITION = localPlayer.position

					local required_pickup_distance = 600
					local randomness = 20
					local position = localPlayer.position
					table.sort( PEDS,
						function( a, b ) 
							return math.abs( ( a - position ).length - required_pickup_distance ) < math.abs( ( b - position ).length - required_pickup_distance )
						end
					)
					local pickup_point = PEDS[ math.random( 1, math.min( randomness, #PEDS ) ) ]

					local ped_model = 90 --peds[ math.random( #peds ) ]

					CEs.ped = createPed( ped_model, pickup_point )

					local function onPedIssue( attacker ) 
						if ( attacker == localPlayer or attacker == localPlayer.vehicle ) and source.health <= 95 then
							triggerServerEvent( "onTaxiKillPed", localPlayer )
						end
					end
					addEventHandler( "onClientPedDamage", CEs.ped, onPedIssue )
					addEventHandler( "onClientPedWasted", CEs.ped, onPedIssue )

					CEs.ped.frozen = true
					setPedAnimation( CEs.ped, "ped", "idle_taxi", -1, false )

					CLIENT_POSITION = pickup_point

					CEs.func_render_ped = function( )
						local position = CEs.ped.position
						local rotation = FindRotation( position.x, position.y, localPlayer.position.x, localPlayer.position.y )
						setPedRotation( CEs.ped, rotation )
					end
					addEventHandler( "onClientPreRender", root, CEs.func_render_ped )

					CreateQuestPoint( pickup_point, 
						function()
							removeEventHandler( "onClientPreRender", root, CEs.func_render_ped )
							CEs.ped:destroy( )
							CEs.marker:destroy( )
							triggerServerEvent( "PlayerAction_Task_Taxi_1_step_1", localPlayer )
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
						end
					, _, 5, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 0, 255, 0, 10 )
					CEs.marker.slowdown_coefficient = nil
					CEs.marker.PreJoinContinuous = function( self, player )
						return player.vehicle and player.vehicle.velocity.length < 0.01
					end

				end;
			};
			CleanUp = {
				client = function( )
					removeEventHandler( "onClientPreRender", root, CEs.func_render_ped )
				end
			};
			event_end_name = "PlayerAction_Task_Taxi_1_step_1";
			
		};

		[2] = {
			name = "Отвези пассажира по GPS";

			Setup = {
				server = function( player )
					local ped_model = 90 --peds[ math.random( #peds ) ]

					local ped = createPed( ped_model, Vector3( ) )
					warpPedIntoVehicle( ped, player.vehicle, 1 )

					player:setData( "quest_ped", ped, false )
				end;
				client = function()
					local required_pickup_distance = 1400
					local randomness = 20
					local position = localPlayer.position
					table.sort( DIRECTIONS,
						function( a, b ) 
							return math.abs( ( a - position ).length - required_pickup_distance ) < math.abs( ( b - position ).length - required_pickup_distance )
						end
					)
					local target_point = DIRECTIONS[ math.random( 1, math.min( randomness, #DIRECTIONS ) ) ]

					DELIVERY_POSITION = target_point
					
					CreateQuestPoint( target_point, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "onTaxiDeliveryPass", resourceRoot, math.floor( ( THIS_POSITION - CLIENT_POSITION ).length ), math.floor( ( CLIENT_POSITION - DELIVERY_POSITION ).length ) )
							triggerServerEvent( "PlayerAction_Task_Taxi_1_step_2", localPlayer )
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
						end
					, _, 5, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 255, 100, 255, 20 )
					CEs.marker.slowdown_coefficient = nil
					CEs.marker.PreJoinContinuous = function( self, player )
						return player.vehicle and player.vehicle.velocity.length < 0.01
					end
				end;
			};
			CleanUp = {
				server = function( player )
					local ped = player:getData( "quest_ped" )
					if isElement( ped ) then destroyElement( ped ) end
				end
			};

			event_end_name = "PlayerAction_Task_Taxi_1_step_2";
		};
	};

	GiveReward = function( player )
		StartAgain( player )
	end;

	no_show_rewards = true;
	no_show_success = true;
}

function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 50, 1 )
end

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		localPlayer:ShowError( "Ты не в автомобиле Таксиста" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель автомобиля Таксиста" )
		return false
	end

	return true
end