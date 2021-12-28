
QUEST_DATA = 
{
	id = "task_industrial_fishing_coop";
	title = "Промышленная рыбалка";
    description = "Ловля рыбы";
    job_class = JOB_CLASS_INDUSTRIAL_FISHING,

    await_destroy_quest_veh = true,
    voice_chat = true,

    roles =
    {
        [ DRIVER ] =
        {
            name = "Штурман";
            id = "pilot",
            max_count = 1;
            min_count = 1;
			license = LICENSE_TYPE_BOAT;
        };

        [ FISHERMAN ] =
        {
            divide_analytics = true,
            name = "Рыболов";
            id = "fisherman",
            max_count = 2;
			min_count = 2;
        };
        
        [ COORDINATOR ] =
        {
            name = "Координатор";
            id = "coordinator",
            max_count = 1;
            min_count = 1;
		};
    };

    OnAnyFinish = 
    {
        server = function( lobby_id, finish_state, lap_complete )
            if lap_complete then return end
            OnServerAnyFinish( lobby_id )
        end,
        
        client = function( reason_data, lobby_data )
            UnblockAllKeys()
            DisableJobControls( false )
            DisableJobKeys( false )
            removeEventHandler( "onClientRender", root, onSyncManipulatorRender )

            local func_show_camera = function()
                fadeCamera( true, 1 )
                setCameraTarget( localPlayer )
            end

            if reason_data and not reason_data.failed then
                fadeCamera( false, 1 )
                setTimer( func_show_camera, 5000, 1 )
            else
                func_show_camera()
            end

            triggerEvent( "onClientDestroyIndustrialFishingInfo", resourceRoot )

            DestroyTableElements( CONTAINERS_STATIC_OBJECTS )
            CONTAINERS_STATIC_OBJECTS = {}
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
                    [ DRIVER ] = 
                    { 
                        name = "Поднимите якорь"; 
                        fn = function( lobby_data )
                            BlockAllKeys()
                            triggerEvent( "ShowUIInventory", root, false )

                            fadeCamera( false, 0 )
                            setPedWeaponSlot( localPlayer, 0 )
                            
                            CEs.show_action_tmr = setTimer( function()
                                DisableJobControls( true )
                                fadeCamera( true, 1 )
                                
                                local controller, initialization = CreateDriverActionController()
                                ResetManipulator( false, lobby_data.job_vehicle )

                                triggerEvent( "onClientCreateIndustrialFishingInfo", localPlayer, DRIVER )  

                                CEs.current_action = PressKeyHandler( {
                                    key = "h",
                                    key_handler = function()
                                        CEs.next_step_tmr = setTimer( function()
                                            GEs.anchor_step_complete = true
                                            triggerServerEvent( lobby_data.end_step, localPlayer ) 
                                        end, 1500, 1 )
                                    end,
                                } )

                                GEs.action_controller:toggle_controls( true )
                                UnblockAllKeys()
                            end, 2100, 1 )
                        end;
                    },

                    [ FISHERMAN ] = 
                    { 
                        name = "Дождитесь прибытия на место"; 
                        fn = function( lobby_data )
                            fadeCamera( false, 0 )
                            setPedWeaponSlot( localPlayer, 0 )
                            DisableJobKeys( true )
                            triggerEvent( "ShowUIInventory", root, false )

                            CEs.show_action_tmr = setTimer( function()
                                DisableJobControls( true )

                                fadeCamera( true, 1 )
                                ResetManipulator( false, lobby_data.job_vehicle )
                                triggerEvent( "onClientCreateIndustrialFishingInfo", localPlayer, FISHERMAN )
                            end, 2100, 1 )
                        end;
                        skip = true,
                    },

                    [ COORDINATOR ] = 
                    { 
                        name = "Дождитесь движения корабля"; 
                        fn = function( lobby_data )
                            fadeCamera( false, 0 )
                            setPedWeaponSlot( localPlayer, 0 )
                            DisableJobKeys( true )
                            triggerEvent( "ShowUIInventory", root, false )


                            CEs.show_action_tmr = setTimer( function()
                                DisableJobControls( true )

                                fadeCamera( true, 1 )
                                ResetManipulator( false, lobby_data.job_vehicle )

                                local controller, initialization = CreateCoordinatorActionController( 1 )

                                GEs.sonar_depth = 1
                                triggerEvent( "onClientUpdateSonar", localPlayer, { ship = lobby_data.job_vehicle } )
                            end, 2100, 1 )
                        end;
                        skip = true,
                    },
                };
            
                server = function( lobby_data, data )
                    lobby_data.hold = {
                        all = 0,
                        side = { 0, 0 }
                    }

                    lobby_data.container_unload_quantity = 0
                    lobby_data.port_index = math.random( 1, #PORT_POINTS )

                    for k, v in pairs( GetLobbyPlayersByRole( lobby_data.lobby_id, FISHERMAN ) ) do
                        v:SetPrivateData( "fisherman_index", k )
                    end

                    lobby_data.pre_spawn_veh_tmr = setTimer( function()
                        SetPlayerStartPositon( lobby_data )

                        lobby_data.job_vehicle.frozen = true
                        lobby_data.job_vehicle.engineState = false
                    end, 2000, 1 )

                    lobby_data.route_id = TARGET_ROUTE_ID or math.random( 1, #FISHING_ROUTES )
                    lobby_data.current_fishing_area_id = 1
                end;
            };
        };

        [ 2 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ DRIVER ] = 
                    { 
                        name = "Запустите двитель"; 
                        fn = function( lobby_data )
                            OnStartDriverEngineGame( lobby_data )
                        end;
                    },

                    [ FISHERMAN ]   = 
                    { 
                        name = "Дождитесь прибытия на место"; 
                        fn = function( lobby_data )
                            CreateFishermanActionController( localPlayer:getData( "fisherman_index" ), lobby_data.job_vehicle )
                        end;
                        skip = true;
                    };
                    [ COORDINATOR ] = { name = "Дождитесь прибытия на место";  };
                };
            
                server = function( lobby_data, data ) end;
            };
        };

        [ 3 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ DRIVER ]    = 
                    { 
                        name = "Следуйте указаниям координатора";
                        fn = function( lobby_data )
                            GEs.action_controller:toggle_controls( true )
                        end,
                        skip = true,
                    };
                    [ FISHERMAN ] = 
                    { 
                        name = "Дождитесь прибытия на место";
                        fn = function( lobby_data )
                            GEs.action_controller:toggle_controls( false, lobby_data.job_vehicle )
                        end,
                        skip = true,
                    };

                    [ COORDINATOR ] = 
                    { 
                        name = "Направляйте корабль к месту ловли"; 
                        fn = function( lobby_data )
                            CreateFishingArea( lobby_data )
                            triggerEvent( "RefreshRadarBlips", localPlayer )
                            GEs.action_controller:toggle_controls( true )
                        end;
                    };
                };
            
                server = function( lobby_data, data )
                    lobby_data.fish_side_loaded = {}
                    lobby_data.hold.side = { 0, 0 }
                end;
            };
        };

        [ 4 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ DRIVER ] = 
                    {  
                        name = "Двигайтесь на низкой скорости!"; 
                        fn = function( lobby_data )
                            localPlayer:ShowInfo( "Вы прибыли на место ловли")
                        end;
                        skip = true;
                    };

                    [ FISHERMAN ] = 
                    { 
                        name = "Опустите сети на необходимую глубину";
                        fn = function( lobby_data )
                            GEs.action_controller:toggle_controls( true, lobby_data.job_vehicle )
                            localPlayer:ShowInfo( "Нажмите H, чтобы активировать манипулятор")
                        end;
                        skip = true;
                    };

                    [ COORDINATOR ] = 
                    { 
                        name = "Направляйте рыболовов по эхолокатору"; 
                        fn = function( lobby_data )
                            CreateFishPoints( lobby_data )
                        end;
                    };
                };
            
                server = function( lobby_data, data )
                end;
            };

            condition_next_step =
            {
                server = function( lobby_data )
                    if lobby_data.hold.all < SIZE_HOLD then
                        lobby_data.current_fishing_area_id = lobby_data.current_fishing_area_id + 1
                        return 3
                    end
                end,
            };
        };

        [ 5 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ DRIVER ]    = 
                    { 
                        name = "Следуйте в порт на разгрузку";
                        fn = function( lobby_data )
                            CreateQuestPoint( PORT_POINTS[ lobby_data.port_index ].position, function( )
                                CEs.marker:destroy()
                                triggerServerEvent( lobby_data.end_step, localPlayer )
                            end, _, 10, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20 )
                        end;
                    },
                    [ FISHERMAN ]   = 
                    { 
                        name = "Дождитесь прибытия в порт";
                        fn = function( lobby_data )
                            GEs.action_controller:toggle_controls( false, lobby_data.job_vehicle )
                        end;
                        skip = true; 
                    },
                    [ COORDINATOR ] = 
                    { 
                        name = "Дождитесь прибытия в порт";
                        fn = function( lobby_data )
                            DestroyFishingArea()
                            triggerEvent( "RefreshRadarBlips", localPlayer )
                            GEs.action_controller:toggle_controls( false )
                            if GEs.action_controller.is_show_sonar then
                                CoordinatorKeyHandler( "k", "down" )
                            end
                        end;
                        skip = true; 
                    },
                };
            
                server = function( lobby_data, data )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, 10 * 60 * 1000, nil, "Штурман не прибыл в порт в заданное время", _, function()
                        return false
                    end )
                end;
            };
        };

        [ 6 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ DRIVER ] = 
                    { 
                        name = "Обслужите корабль"; 
                        fn = function( lobby_data )
                            GEs.action_controller:toggle_controls( false )
                            OnStartDriverServiceGame( lobby_data )
                        end;
                    },

                    [ FISHERMAN ] = 
                    {
                        name = "Разгрузите 6 контейнеров"; 
                        fn = function( lobby_data )
                            GEs.action_controller:toggle_controls( true, lobby_data.job_vehicle )
                            OnStartFisherManGame( lobby_data )
                        end;
                    },

                    [ COORDINATOR ] = { name = "Дождитесь разгрузки корабля"; },
                };
            
                server = function( lobby_data, data )
                    local port = PORT_POINTS[ lobby_data.port_index ]

                    lobby_data.job_vehicle:setPosition( port.position )
                    lobby_data.job_vehicle:setRotation( port.rotation + Vector3( 0, 0, 180 ) )
                        
                    lobby_data.job_vehicle.frozen = true
                    lobby_data.job_vehicle.engineState = false

                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, 5 * 60 * 1000, nil, "Слишком долгая разгрузка", _, function()
                        return false
                    end )
                end;
            };

            CleanUp = 
            {
                client = function( reason_data )
                    if reason_data and not reason_data.failed then
                        fadeCamera( false, 1 )
                    end
                end,
            };
        };

    };

    one_shift = true,
}

function GetQuestData( )
	return QUEST_DATA
end