loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

enum "eCoopJobRoles" 
{
    "JOB_ROLE_DRIVER",
    "JOB_ROLE_MASTER",
}

QUEST_DATA = 
{
	id = "task_hijack_cars_coop";
    title = "Угон авто";
    job_class = JOB_CLASS_HIJACK_CARS;

    ignore_increase_mayor = true,
    voice_chat = true,

    roles =
    {
        [ JOB_ROLE_DRIVER ] =
        {
            id   = "driver";
            name = "Водитель";
            max_count = 1;
			min_count = 1;
			license = LICENSE_TYPE_AUTO;
            priority_seat = 0;
        };

        [ JOB_ROLE_MASTER ] =
        {
            id   = "master";
            name = "Мастер";
            max_count = 1;
			min_count = 1;
            license = LICENSE_TYPE_AUTO;
            priority_seat = 1;
		};
    };

    OnAnyFinish = 
    {
        client = function()
            toggleControl( "enter_exit", true )
            localPlayer:setData( "hud_counter", false, false )
        end,
        server = function( lobby_id, finish_state )

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
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Сесть в рабочую машину водителем";
                        fn = function( lobby_data )
                            local func_hint = function()
                                localPlayer:ShowInfo( "Садись на водительское место" )
                            end
                            
                            if not lobby_data.vehicle_count or lobby_data.vehicle_count > 0 then func_hint() end

                            CEs.on_client_vehicle_enter_handler = function( ped, seat )
                                if seat ~= 0 and ped == localPlayer then 
                                    func_hint()
                                    cancelEvent() 
                                end

                                local occupants = getVehicleOccupants( lobby_data.job_vehicle )
                                if occupants[ 0 ] and occupants[ 1 ] then
                                    triggerServerEvent( lobby_data.end_step, localPlayer )
                                    return
                                else
                                    CEs.show_hint_tmr = setTimer( function()
                                        if localPlayer == ped then localPlayer:ShowInfo( "Ожидай напарника" ) end
                                    end, 1500, 1 )
                                end                                
                            end
                            addEventHandler( "onClientVehicleEnter", lobby_data.job_vehicle, CEs.on_client_vehicle_enter_handler )
                            
                            for k, v in pairs( lobby_data.participants ) do
                                if v.player ~= localPlayer then
                                    AddCheckDistanceBetweenElements( localPlayer, v.player, CONST_MAX_DISTANCE_BETWEEN_PLAYERS, CONST_FAILURE_TIME_ON_DISTANCE_PLAYERS_IN_MS, "Вернись к напарнику", "бросил напарника" )
                                end
                            end
                        end;
                    },
                    [ JOB_ROLE_MASTER ] = 
                    { 
                        name = "Сесть в рабочую машину пассажиром";
                        fn = function( lobby_data )
                            local func_hint = function()
                                localPlayer:ShowInfo( "Садись на пассажирское место" )
                            end
                            
                            if not lobby_data.vehicle_count or lobby_data.vehicle_count > 0 then func_hint() end

                            CEs.on_client_vehicle_enter_handler = function( ped, seat )
                                if ped ~= localPlayer and isTimer( CEs.show_hint_tmr ) then killTimer( CEs.show_hint_tmr ) end

                                if seat ~= 1 and ped == localPlayer then 
                                    func_hint()
                                    cancelEvent() 
                                end

                                CEs.show_hint_tmr = setTimer( function()
                                    if localPlayer == ped then localPlayer:ShowInfo( "Ожидай напарника" ) end
                                end, 1500, 1 )
                            end
                            addEventHandler( "onClientVehicleEnter", lobby_data.job_vehicle, CEs.on_client_vehicle_enter_handler )

                            for k, v in pairs( lobby_data.participants ) do
                                if v.player ~= localPlayer then
                                    AddCheckDistanceBetweenElements( localPlayer, v.player, CONST_MAX_DISTANCE_BETWEEN_PLAYERS, CONST_FAILURE_TIME_ON_DISTANCE_PLAYERS_IN_MS, "Вернись к напарнику", "бросил напарника" )
                                end
                            end
                        end;
                        skip = true;
                    },  
                };
            
                server = function( lobby_data )
                    lobby_data.hijacked_vehicle = nil
                    lobby_data.is_success_hacked = false
                end;
            };

            CleanUp =
            {
                client = function( lobby_data )
                    if isElement( LOBBY_DATA and LOBBY_DATA.job_vehicle ) then
                        removeEventHandler( "onClientVehicleEnter", LOBBY_DATA.job_vehicle, CEs.on_client_vehicle_enter_handler )
                    end
                end,
            };
        };

        [ 2 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Приехать на парковку";
                        fn = function( lobby_data )
                            SetEnabledCheckDistanceTimer( false )

                            CreateQuestPoint( POSITIONS_HIJACKED_CARS[ lobby_data.hijack_point_id ].break_in + Vector3( 0, 0, 1.5 ), function()
                                if not CheckAllPlayersInVehicle( lobby_data ) then
                                    localPlayer:ShowError( "Для начала угона все участники должны быть в машине")
                                    return false
                                end

                                if CEs.is_condition_created then return end

                                CEs.is_condition_created = true
                                table.insert( CEs, WatchElementCondition( localPlayer.vehicle, {
                                    condition = function( self )
                                        if self.element.velocity.length == 0 then
                                            CEs.marker:destroy()
                                            triggerServerEvent( lobby_data.end_step, localPlayer )
                                            return true
                                        else
                                            localPlayer:ShowInfo( "Останови транспорт" )
                                        end
                                    end,
                                } ) )
                            end, _, 5, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20, 3 )
                            CEs.marker.slowdown_coefficient = nil
                        end;
                    },
                    [ JOB_ROLE_MASTER ] = 
                    { 
                        name = "Ожидай прибытия на парковку";
                        fn = function( lobby_data )
                            SetEnabledCheckDistanceTimer( false )
                        end;
                        skip = true;
                    },  
                };
            
                server = function( lobby_data )
                    GenerateHijackedVehiclePassword( lobby_data )
                    
                    lobby_data.prev_hijacked_vehicle = lobby_data.hijacked_vehicle
                    
                    lobby_data.hijack_point_id = GenerateHijackPoint( lobby_data )
                    lobby_data.hijacked_vehicle = CreateHijackedVehicle( lobby_data )
                    lobby_data.inner_quest_vehicle = lobby_data.hijacked_vehicle

                    lobby_data.hijacked_vehicle_id = lobby_data.hijacked_vehicle.model
                    lobby_data.hijacked_vehicle_name = VEHICLE_CONFIG[ lobby_data.hijacked_vehicle_id ].model
                    lobby_data.hijacked_vehicle_tier = lobby_data.hijacked_vehicle:GetTier()

                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_DELIVERY_HIJACK_CAR_TIME_IN_MS, nil, "Слишком медленно", _, function()
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
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Ожидать мастера";
                        fn = function( lobby_data )
                            SetWaitingControlsState( true )
                            SetEnabledCheckDistanceTimer( true, lobby_data.hijacked_vehicle.position, CONST_MAX_DISTANCE_FROM_HIJACK_CAR, CONST_FAILURE_TIME_AT_DISTANCE_FROM_CAR_IN_MS, "Вернись к точке угона", "покинул точку угона" )
                        end;
                        skip = true;
                    },
                    [ JOB_ROLE_MASTER ] = { 
                        name = "Взломать машину";
                        fn = function( lobby_data )
                            SetEnabledCheckDistanceTimer( true, lobby_data.hijacked_vehicle.position, CONST_MAX_DISTANCE_FROM_HIJACK_CAR, CONST_FAILURE_TIME_AT_DISTANCE_FROM_CAR_IN_MS, "Вернись к точке угона", "покинул точку угона" )
                            toggleControl( "enter_exit", false )
                            lobby_data.success_callback = function()
                                triggerServerEvent( "onServerMasterHackedCar", resourceRoot )
                                ToggleMinigameMaster( false )
                            end
                            lobby_data.fail_callback = function()
                                triggerServerEvent( lobby_data.end_step, localPlayer )
                                ToggleMinigameMaster( false )
                            end

                            ToggleMinigameMaster( true, lobby_data )
                        end;
                    },  
                };
            
                server = function( lobby_data )
                    lobby_data.job_vehicle.frozen = true
                    if isElement( lobby_data.prev_hijacked_vehicle ) then
                        destroyElement( lobby_data.prev_hijacked_vehicle )
                        lobby_data.prev_hijacked_vehicle = nil
                    end
                end;
            };

            CleanUp =
            {
                client = function( lobby_data )
                    SetWaitingControlsState( false )
                end,
            };

            condition_next_step =
            {
                server = function( lobby_data )
                    if not lobby_data.is_success_hacked then
                        for k, v in pairs( lobby_data.participants ) do
                            v.player:ShowInfo( "Взлома провален.\nНаправляйся к другой наводке" )
                        end

                        lobby_data.job_vehicle.frozen = false
                        return 2
                    end
                end,
            };
        };

        [ 4 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Сесть в угоняемую машину";
                        fn = function( lobby_data )
                            localPlayer:ShowInfo( "Машина взломана, действуй!" )
                            lobby_data.hijacked_vehicle:setData( "off_brake_reverse", true, false )

                            CreateQuestPoint( lobby_data.hijacked_vehicle.position, function()
                                CEs.marker:destroy()
                            end, _, 6, 0, 0, nil, _, _, _, 0, 255, 0, 20, 3 )
                            CEs.marker.slowdown_coefficient = nil

                            CEs.on_client_hijacked_vehicle_enter_handler = function( ped, seat )
                                if seat ~= 0 then 
                                    localPlayer:ShowInfo( "Садись на водительское место" )
                                    cancelEvent() 
                                end

                                SetWaitingControlsState( true )
                                toggleControl( "enter_exit", false )
                                triggerServerEvent( lobby_data.end_step, localPlayer )
                            end
                            addEventHandler( "onClientVehicleEnter", lobby_data.hijacked_vehicle, CEs.on_client_hijacked_vehicle_enter_handler )
                        end;
                    },
                    [ JOB_ROLE_MASTER ] = 
                    { 
                        name = "Пересесть на водительское место";
                        fn = function( lobby_data )
                            CEs.on_client_job_vehicle_enter_handler = function( ped, seat )
                                if seat == 0 then
                                    toggleControl( "enter_exit", false )
                                    triggerServerEvent( lobby_data.end_step, localPlayer )
                                else 
                                    localPlayer:ShowInfo( "Садись на водительское место" )
                                    cancelEvent() 
                                end
                            end
                            addEventHandler( "onClientVehicleEnter", lobby_data.job_vehicle, CEs.on_client_job_vehicle_enter_handler )
                        end;
                    },  
                };
            
                server = function( lobby_data )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_ENTER_HIJACK_CAR_TIME_IN_MS, nil, "Слишком медленный угон", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                client = function( lobby_data )
                    SetWaitingControlsState( false )

                    if isElement( LOBBY_DATA and LOBBY_DATA.hijacked_vehicle ) and CEs.on_client_hijacked_vehicle_enter_handler then
                        LOBBY_DATA.hijacked_vehicle:setData( "off_brake_reverse", false, false )
                        removeEventHandler( "onClientVehicleEnter", LOBBY_DATA.hijacked_vehicle, CEs.on_client_hijacked_vehicle_enter_handler )
                    end

                    if isElement( LOBBY_DATA and LOBBY_DATA.job_vehicle ) and CEs.on_client_job_vehicle_enter_handler then
                        removeEventHandler( "onClientVehicleEnter", LOBBY_DATA.job_vehicle, CEs.on_client_job_vehicle_enter_handler )
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
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Заведи машину";
                        fn = function( lobby_data )
                            lobby_data.success_callback = function()
                                triggerServerEvent( "onServerDriverHackedCar", resourceRoot )
                            end
                            ToggleMinigameDriver( true, lobby_data )
                        end;
                    },
                    [ JOB_ROLE_MASTER ] = 
                    { 
                        name = "Передай водителю пароль"; 
                        fn = function( lobby_data )
                            localPlayer:setData( "hud_counter", { left = "Пароль", right = lobby_data.password }, false )
                        end;
                        skip = true;
                    },  
                };
            
                server = function( lobby_data )
                    lobby_data.hijacked_vehicle:setEngineState( false )
                    lobby_data.sump_point_id = math.random( 1, #POSITIONS_SUMP_CARS )

                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_DELIVERY_HIJACK_CAR_TIME_IN_MS, nil, "Слишком медленный угон", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                client = function( lobby_data )
                    localPlayer:setData( "hud_counter", false, false )
                    toggleControl( "enter_exit", true )
                end,
            };
        };

        [ 6 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Доставь машину";
                        fn = function( lobby_data )
                            SetEnabledCheckDistanceTimer( false )

                            WatchVehicleHealth( lobby_data.hijacked_vehicle )
                            AddInteractionVehicleHandlers( lobby_data.hijacked_vehicle, CONST_FAILURE_TIME_EXIT_HICJAK_CAR_IN_MS, "Вернись в угоняемый транспорт", "бросил угоняемый транспорт" )

                            CreateQuestPoint( POSITIONS_SUMP_CARS[ lobby_data.sump_point_id ], function()
                                if CEs.is_condition_created then return end
                                
                                CEs.is_condition_created = true
                                table.insert( CEs, WatchElementCondition( localPlayer.vehicle, {
                                    condition = function( self )
                                        if self.element.velocity.length == 0 then
                                            if not CEs.marker then return end
                                            CEs.marker:destroy()
                                            CEs.marker = nil

                                            CEs.interface_interaction_car:destroy()
                                            lobby_data.hijacked_vehicle.frozen = true
                                            toggleControl( "enter_exit", true )
                                            localPlayer:ShowInfo( "Выйди из машины" )
                                            
                                            addEventHandler( "onClientVehicleExit", lobby_data.hijacked_vehicle, function()
                                                toggleControl( "enter_exit", false )
                                                triggerServerEvent( lobby_data.end_step, localPlayer )
                                            end )

                                            return true
                                        else
                                            localPlayer:ShowInfo( "Останови транспорт" )
                                        end
                                    end,
                                } ) )
                            end, _, 15, 0, 0, function()
                               if localPlayer.vehicle ~= lobby_data.hijacked_vehicle then
                                    localPlayer:ShowInfo( "А где машина?" )
                                    return false
                               end
                               return true
                            end, _, _, _, 0, 255, 0, 20, 3 )
                            CEs.marker.slowdown_coefficient = nil
                        end;
                    },
                    [ JOB_ROLE_MASTER ] = 
                    {  
                        name = "Сопроводи водителя";
                        fn = function( lobby_data )
                            SetEnabledCheckDistanceTimer( false )

                            CEs.func_check_distance = function()
                                if (POSITIONS_SUMP_CARS[ lobby_data.sump_point_id ] - localPlayer.position).length < CONST_DISTANCE_CREATE_MASTER_SUMP_POINT then
                                    CEs.check_dist_tmr = setTimer( CEs.func_check_distance, 1000, 1 )
                                    return false
                                end

                                CreateQuestPoint( POSITIONS_SUMP_CARS[ lobby_data.sump_point_id ], function()
                                    if CEs.is_condition_created then return end
                                
                                    CEs.is_condition_created = true
                                    table.insert( CEs, WatchElementCondition( localPlayer.vehicle, {
                                        condition = function( self )
                                            if self.element.velocity.length == 0 then
                                                if not CEs.marker then return end
                                                CEs.marker:destroy()
                                                CEs.marker = nil

                                                lobby_data.job_vehicle.frozen = true
                                                toggleControl( "enter_exit", true )
                                                localPlayer:ShowInfo( "Выйди из машины" )
                                                
                                                CEs.on_client_job_vehicle_exit_handler = function()
                                                    toggleControl( "enter_exit", false )
                                                    triggerServerEvent( lobby_data.end_step, localPlayer )
                                                end
                                                addEventHandler( "onClientVehicleExit", lobby_data.job_vehicle, CEs.on_client_job_vehicle_exit_handler )

                                                return true
                                            else
                                                localPlayer:ShowInfo( "Останови транспорт" )
                                            end
                                        end,
                                    } ) )
                                end, _, 15, 0, 0, function()
                                   if localPlayer.vehicle ~= lobby_data.job_vehicle then
                                        localPlayer:ShowInfo( "А где машина?" )
                                        return false
                                   end
                                   return true
                                end, _, _, _, 0, 255, 0, 20, 3 )
                                CEs.marker.slowdown_coefficient = nil
                            end
                            CEs.check_dist_tmr = setTimer( CEs.func_check_distance, 1000, 1 )
                        end;
                    },  
                };
            
                server = function( lobby_data )
                    lobby_data.job_vehicle.frozen = false

                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, CONST_DELIVERY_HIJACK_CAR_TIME_IN_MS, nil, "Слишком медленный угон", _, function()
                        return false
                    end )

                    lobby_data.cur_percent_id = 0
                    lobby_data.percentages = {
                        { time_in_sec = -1,  visible_percent = "10%", percent = 1.1  },
                        { time_in_sec = 120, visible_percent = "7%",  percent = 1.07 },
                        { time_in_sec = 60,  visible_percent = "5%",  percent = 1.05 },
                        { time_in_sec = 60,  visible_percent = "0%",  percent = 1    },
                    }
                    
                    lobby_data.func_create_next_percent = function()
                        if isTimer( lobby_data.change_percent_tmr ) then killTimer( lobby_data.change_percent_tmr ) end

                        lobby_data.cur_percent_id = lobby_data.cur_percent_id + 1
                        lobby_data.percent_increase_reward_for_job_conditions = lobby_data.percentages[ lobby_data.cur_percent_id ].percent

                        for k, v in pairs( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ) ) do
                            v:SetPrivateData( "hud_counter", { left = "Надбавка за скорость: ", right = lobby_data.percentages[ lobby_data.cur_percent_id ].visible_percent }, false )
                        end

                        local next_percent_id = lobby_data.cur_percent_id + 1
                        if lobby_data.percentages[ next_percent_id ] then
                            lobby_data.change_percent_tmr = setTimer( lobby_data.func_create_next_percent, lobby_data.percentages[ next_percent_id ].time_in_sec * 1000, 1 )
                        end
                    end

                    lobby_data.func_create_next_percent()
                end;
            };

            CleanUp =
            {
                client = function()
                    if isElement( LOBBY_DATA and LOBBY_DATA.job_vehicle ) and CEs.on_client_job_vehicle_exit_handler then
                        removeEventHandler( "onClientVehicleExit", LOBBY_DATA.job_vehicle, CEs.on_client_job_vehicle_exit_handler )
                    end

                    if not localPlayer.vehicle or localPlayer.vehicle == LOBBY_DATA.hijacked_vehicle then return end
                    toggleControl( "enter_exit", true )
                end;
                server = function( lobby_data )
                    if isTimer( lobby_data.change_percent_tmr ) then killTimer( lobby_data.change_percent_tmr ) end
                    lobby_data.inner_quest_vehicle_health = lobby_data.inner_quest_vehicle and lobby_data.inner_quest_vehicle.health

                    lobby_data.vehicle_count = (lobby_data.vehicle_count or 0) + 1
                end,
            };
        };
        
    };
    
    GiveReward = function( player, lobby_data )
        triggerEvent( "onCoopJobCompletedLap", resourceRoot, player, lobby_data.lobby_id )
	end;
}

function GetQuestData( )
	return QUEST_DATA
end