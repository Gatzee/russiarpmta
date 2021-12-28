loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

enum "eCoopJobRoles" 
{
	"SPECIALIST",
}

CONST_WAIT_TIME = 2 * 60 * 1000
CONST_LOAD_VEHICLE_TIME = 2  * 60 * 1000
CONST_TAKE_VEHICLE_TIME = 10 * 60 * 1000
CONST_DELLIVERY_VEHICLE_TIME = 10 * 60 * 1000

QUEST_DATA = 
{
	id = "task_towtrucker_coop";
	title = "Эвакуаторщик";
    description = "Эвакуация транспорта";
    job_class = JOB_CLASS_TOWTRUCKER,

    roles =
    {
        [ SPECIALIST ] =
        {
            id   = "specialist";
            name = "Cпециалист";
            max_count = 2;
			min_count = 1;
			license = LICENSE_TYPE_TRUCK;
		};
    };

    OnAnyFinish = 
    {
		client = function( lobby_id, finish_state )
            StopCheckDistanceTimer()
		end,

		server = function( lobby_id, finish_state )
            DestroyVehicleData( lobby_id, finish_state )
		end,
	},

    tasks = 
    {
        [ 1 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ SPECIALIST ] = 
                    { 
                        name = "Ожидай заказа"; 
                        fn = function( lobby_data )
                            TryStartCheckDistanceElementTimer( _, 50 )
                        end;
                    },
                };
            
                server = function( lobby_data, data )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_WAIT_TIME, "Ожидайте заказ", _, lobby_data.end_step, function()
                        GenerateEvacuatedVehicleData( lobby_data.lobby_id )
                        return true
                    end )
                end;
            };
        };
        
        [ 2 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ SPECIALIST ] = 
                    {
                        name = "Доберитесь до авто";
                        fn = function( lobby_data )
                            CreateQuestPoint( lobby_data.evacuated_vehicle_pos, function()
							    CEs.marker:destroy()
                                triggerServerEvent( lobby_data.end_step, localPlayer )
						    end, _, 15, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20 )
                        end;
                    };
                };
            
                server = function( lobby_data )
                    CreateEvacuatedVehicle( lobby_data.lobby_id )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_TAKE_VEHICLE_TIME, "Доберитесь до авто", "Слишком медленно", _, function()
                        return false
                    end )
                end;
            };
        };

        [ 3 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ SPECIALIST ] = 
                    {
                        name = "Погрузите авто";
                        fn = function( lobby_data )
                            CreateManipulatorHint() 
                            setHintState( localPlayer.vehicle and localPlayer:getOccupiedVehicleSeat() == 1 )
                        end;
                    },
                };
            
                server = function( lobby_data )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_LOAD_VEHICLE_TIME, "Погрузите авто", "Слишком медленная погрузка авто", _, function()
                        return false
                    end )
                end;
            };
        };

        [ 4 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ SPECIALIST ] = 
                    {
                        name = "Доставьте автомобиль на стоянку";
                        fn = function( lobby_data )
                            local return_points = RETURN_TARGETS[ lobby_data.city ]
					        local return_point = return_points[ math.random( 1, #return_points ) ]
					        CreateQuestPoint( return_point, function()
							    CEs.marker:destroy()
                                if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
							    triggerServerEvent( lobby_data.end_step, localPlayer )
						    end, _, 13, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20 )
                        end;
                    },
                };
            
                server = function( lobby_data )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_DELLIVERY_VEHICLE_TIME, "Доставьте автомобиль на стоянку", "Слишком медленно", _, function()
                        return false
                    end )
                end;
            };
            CleanUp = 
            {
                server = function( lobby_data )
                    lobby_data.cars_num = (lobby_data.cars_num or 0) + 1
                end,
            }
        };	
    };
    
    GiveReward = function( player, lobby_data )
        triggerEvent( "onCoopJobCompletedLap", resourceRoot, player, lobby_data.lobby_id )
	end;
}

function GetQuestData( )
	return QUEST_DATA
end