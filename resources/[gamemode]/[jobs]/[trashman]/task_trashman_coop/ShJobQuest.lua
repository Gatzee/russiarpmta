loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

enum "eCoopJobRoles"
{
    "JOB_ROLE_DRIVER",
}

QUEST_DATA =
{
	id = "task_trashman_coop";
	title = "Мусорщик";
    description = "Сбор мусора и перевозка его на свалку";
    job_class = JOB_CLASS_TRASHMAN,

    roles =
    {
        [ JOB_ROLE_DRIVER ] =
        {
            id = "specialist",
            name = "Специалист";
            max_count = 2;
            min_count = 2;
            is_driver = true;
			-- license = LICENSE_TYPE_TRUCK;
        };
    };

    OnAnyFinish =
    {
        client = function()
            StopCheckDistanceTimer()
            SetCarrying( false )
        end,
        server = function( lobby_id, finish_state )
            onAnyFinishTrashman( lobby_id, finish_state )
		end,
	},

    tasks =
    {
        -- [ 1 ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Приехать к точке сбора мусора";
                        fn = function( lobby_data )
                            TryStartCheckDistanceElementTimer()

                            if ( lobby_data.current_point or 0 ) == 0 then
                                triggerEvent( "onClientShowTrashmanHUD", localPlayer )
                                if not lobby_data.lap_completed then
                                    addEventHandler( "onClientVehicleStartEnter", lobby_data.job_vehicle, cancelPartnerJacking )
                                end
                            end
                        end,
                    },
                };

                server = function( lobby_data, data )
                    lobby_data.taken_bags = false
                    if not lobby_data.current_point then
                        lobby_data.current_point = 0
                        lobby_data.count_vehicle_bags = 0
                        lobby_data.quest_bags_count = QUEST_BAGS_COUNT

                        lobby_data.trash_point_id = math.random( 1, #TRASH_POINTS )
                        CreateDriverParkingPoint( lobby_data )

                        if lobby_data.lap_completed then
                            triggerClientEvent( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), "onClientUpdateTrashTruckFull", resourceRoot, 0 )
                        end
                    else
                        local function GetRandomPoint( lobby_data )
                            repeat
                                local bank_id = math.random( 1, #TRASH_POINTS )
                                local distance = getDistanceBetweenPoints3D( TRASH_POINTS[ lobby_data.trash_point_id ].parking, TRASH_POINTS[ bank_id ].parking )
                                if distance > TRASH_POINT_MIN_DISTANCE and distance < TRASH_POINT_MAX_DISTANCE then
                                    return bank_id
                                end
                            until false
                        end
                        lobby_data.trash_point_id = GetRandomPoint( lobby_data )
                        CreateDriverParkingPoint( lobby_data )
                    end
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.taken_bags = 0
                    lobby_data.current_point = lobby_data.current_point + 1
                end,
            };
        };

        -- [ 2 ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Припарковаться нужным образом";
                        fn = function( lobby_data )
                            WAS_LOCAL_PLAYER_DRIVER = lobby_data.job_vehicle:getOccupant( 0 ) == localPlayer
                            local point = TRASH_POINTS[ lobby_data.trash_point_id ]
                            local position = point.parking -- + Vector3( 0, 0, 1.05 )
                            local parking_rz = point.parking_rz or FindRotation( point.collect.x, point.collect.y, point.parking.x, point.parking.y )
                            CreateParkingDummyVehicle( lobby_data, position, parking_rz )
                        end;
                    },
                };

                server = function( lobby_data )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    SetTrashTruckParked( lobby_data, true )
                end,
            };
        };

        -- [ 3 ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Открыть кузов";
                        fn = function( lobby_data )
                            ShowInfoOpenBody( )
                        end;
                    },
                };

                server = function( lobby_data )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                end,
            };
        };

        -- [ 4 ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Загрузите мешки с мусором в машину";
                        fn = function( lobby_data )
                            if isPedInVehicle( localPlayer ) then
                                localPlayer:ShowInfo( "Нажмите F чтобы выйти из машины" )
                            end
                            CreateTrashPickupPoint( lobby_data.trash_point_id, lobby_data.job_vehicle )
                        end;
                    },
                };

                server = function( lobby_data )
                    -- if isTimer( lobby_data.end_shift_tmr ) then killTimer( lobby_data.end_shift_tmr ) end
                    -- local target_players = GetLobbyPlayersByLobbyId( lobby_data.lobby_id )
                    -- StartCoopQuestTimerWait( target_players, lobby_data.lobby_id, CONST_LOAD_VEHICLE_TIME * 1000, "Загрузите мешки с мусором", "Слишком медленная погрузка мешков с мусором", _, function()
                    --     return false
                    -- end )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.taken_bags = false
                end,
            };
        };

        -- [ 5 ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Сесть в машину";
                        fn = function( lobby_data )
                            CreateMarkerToJobVehicle( lobby_data, WAS_LOCAL_PLAYER_DRIVER )
                        end;
                    },
                };

                server = function( lobby_data )
                    -- if isTimer( lobby_data.end_shift_tmr ) then killTimer( lobby_data.end_shift_tmr ) end
                    -- local target_players = GetLobbyPlayersByLobbyId( lobby_data.lobby_id )
                    -- StartCoopQuestTimerWait( target_players, lobby_data.lobby_id, CONST_LOAD_VEHICLE_TIME * 1000, "Загрузите мешки с мусором", "Слишком медленная погрузка мешков с мусором", _, function()
                    --     return false
                    -- end )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                end,
            };
        };

        -- [ 6 ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Закрыть кузов";
                        fn = function( lobby_data )
                            ShowInfoCloseBody( )
                        end;
                    },
                };

                server = function( lobby_data )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    SetTrashTruckParked( lobby_data, false )
                end,
            };
        };

        -- [ ?? ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Приехать на точку выгрузки мусора";
                        fn = function( lobby_data )
                            
                        end,
                    };
                };

                server = function( lobby_data )
                    triggerClientEvent( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), "CreateTrashUnloadPoint", resourceRoot, math.random( 1, #TRASH_UNLOAD_POINTS_VEHICLE ) )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                end,
            };
        };
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Припарковаться нужным образом";
                        fn = function( lobby_data )
                            local position = GEs.current_point.position -- + Vector3( 0, 0, 1.05 )
                            local parking_rz = GEs.current_point.rz
                            CreateParkingDummyVehicle( lobby_data, position, parking_rz )
                        end;
                    },
                };

                server = function( lobby_data )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    SetTrashTruckParked( lobby_data, true )
                end,
            };
        };

        -- [ ?? ] =
        {
            Setup =
            {
                client =
                {
                    [ JOB_ROLE_DRIVER ] =
                    {
                        name = "Выгрузить мусор";
                        fn = function( lobby_data )
                            StartTrashUnloading( lobby_data )
                        end;
                    };
                };

                server = function( lobby_data )
                    lobby_data.taken_bags = true
                    lobby_data.count_unload_bags = 0

                    local target_players = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_DRIVER )
                    StartCoopQuestTimerWait( target_players, lobby_data.lobby_id, CONST_LOAD_VEHICLE_TIME * 1000, "Выгрузите мусор", "Слишком медленная выгрузка мусора", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.current_point = nil
                    lobby_data.lap_completed = true
                    SetTrashTruckParked( lobby_data, false )
                end,
            };
        };
    };

    GiveReward = function( player, lobby_data )
        triggerEvent( "onCoopJobCompletedLap", resourceRoot, player, lobby_data.lobby_id )
	end;
}

for new_steps_count = 1, 4 do
    for i = 6, 1, -1 do
        table.insert( QUEST_DATA.tasks, 7, table.copy( QUEST_DATA.tasks[ i ] ) )
    end
end

function GetQuestData( )
	return QUEST_DATA
end