loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

enum "eCoopJobRoles" 
{
    "JOB_ROLE_DRIVER",
    "JOB_ROLE_COORDINATOR",
}

QUEST_DATA = 
{
	id = "task_delivery_cars_coop";
	title = "Доставка транспорта";
    description = "Доставка транспорта";
    job_class = JOB_CLASS_TRANSPORT_DELIVERY,
    
    await_destroy_quest_veh = true,
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
        };

        [ JOB_ROLE_COORDINATOR ] =
        {
            id   = "coordinator";
            name = "Координатор";
            max_count = 1;
            min_count = 1;
            license = LICENSE_TYPE_HELICOPTER;
		};
    };

    OnAnyFinish = 
    {
        client = function( reason_data )
            localPlayer.frozen = false
            if not reason_data.success then 
                fadeCamera( true, 1 ) 
            end
            RemoveExitWarningHandler()
            RemoveDeliveryVehicleHandlers()

            if GEs.onPlayerVehicleEnter then
                removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.onPlayerVehicleEnter )
            end
        end,
        server = function( lobby_id, finish_state )
            local lobby_data = GetLobbyDataById( lobby_id )
            if not lobby_data then return end

            local spawn_id = math.random( 1, #SPAWN_ZONES_OF_PLAEYRS )
            local coordinator = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_COORDINATOR, true )
            if isElement( coordinator ) then
                if (not coordinator.vehicle and coordinator:getData( "in_heli_enter" )) or (isElement( coordinator.vehicle ) and coordinator.vehicle ~= lobby_data.heli_vehicle) then return end
                
                removePedFromVehicle( coordinator )
                coordinator.position = SPAWN_ZONES_OF_PLAEYRS[ spawn_id ]:AddRandomRange( 3 )
                coordinator:setData( "in_heli_enter", false, false  )
                coordinator.frozen = false    
            end

            local driver = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_DRIVER, true )
            if isElement( driver ) then
                if isElement( driver.vehicle ) and driver.vehicle == lobby_data.heli_vehicle then 
                    removePedFromVehicle( driver )
                    driver.position = SPAWN_ZONES_OF_PLAEYRS[ spawn_id ]:AddRandomRange( 3 )
                end
                driver.frozen = false
            end

            DestroyBlipDeliveredVehicle( lobby_data )
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
                    [ JOB_ROLE_DRIVER ] =  { name = "Ожидайте заказа транспорта"; };
                    [ JOB_ROLE_COORDINATOR ] = { 
                        name = "Отправляйся в пункт координации";
                        fn = function( lobby_data )
                            CreateQuestPoint( COORDINATION_CENTER_POSITION, function()
                                CEs.marker:destroy()
                                
                                fadeCamera( false, 1 )
                                CEs.tmr = setTimer( function()
                                    triggerServerEvent( lobby_data.end_step, localPlayer )
                                end, 1000, 1 )
                            end, _, 1, 0, 0, CheckFailIfVehicle, _, _, _, 0, 255, 0, 20, 3 )
                        end;
                    };
                };
            
                server = function( lobby_data, data )
                    if not lobby_data.delivery_vehicle then
                        -- Первичный старт
                        lobby_data.fade_tmr = {}
                        local spawn_id = math.random( 1, #SPAWN_ZONES_OF_PLAEYRS )
                        for k, v in pairs( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ) ) do
                            fadeCamera( v, false, 1 )
                            
                            lobby_data.fade_tmr[ v ] = setTimer( function()
                                removePedFromVehicle( v )
                                v.position = SPAWN_ZONES_OF_PLAEYRS[ spawn_id ]:AddRandomRange( 3 )
                                fadeCamera( v, true, 1 )
                            end, 1100, 1 )
                        end
                    end

                    lobby_data.create_veh_tmr = setTimer( function()
                        lobby_data.vehicle_spawn_id = GetFreeVehicleSpawnId()
                        lobby_data.route_id = math.random( 1, #CAR_ROUTES )
                        
                        lobby_data.vehicle_id = CAR_DELIVERY_ID[ math.random( 1, #CAR_DELIVERY_ID ) ]
                        lobby_data.color_id = math.random( 1, #CAR_DELIVERY_COLORS )

                        if isElement( lobby_data.delivery_vehicle ) then lobby_data.delivery_vehicle:destroy() end
                        if isElement( lobby_data.heli_vehicle ) then lobby_data.heli_vehicle:destroy() end

                        lobby_data.delivery_vehicle = CreateTemporaryQuestVehicle( lobby_data.lobby_id, lobby_data.vehicle_id, SPAWN_ZONES_OF_CARS[ lobby_data.vehicle_spawn_id ].pos, SPAWN_ZONES_OF_CARS[ lobby_data.vehicle_spawn_id ].rot )
                        lobby_data.job_vehicle = lobby_data.delivery_vehicle
                        
                        triggerEvent( "onServerSetJobVehicle", root, lobby_data.lobby_id, lobby_data.delivery_vehicle )

                        lobby_data.delivery_vehicle:setData( "ignore_removal", true, false )
                        lobby_data.delivery_vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )
                        lobby_data.delivery_vehicle:setData( "block_repair", true, false )

                        lobby_data.delivery_vehicle:setColor( unpack( CAR_DELIVERY_COLORS[ lobby_data.color_id ] ) )
                        lobby_data.delivery_vehicle.dimension = 2020
                        lobby_data.vehicle_class = lobby_data.delivery_vehicle:GetTier()

                        lobby_data.heli_vehicle = CreateTemporaryQuestVehicle( lobby_data.lobby_id, HELI_ID, ZONE_SPAWN_OF_HELI[ math.random( 1, #ZONE_SPAWN_OF_HELI ) ], Vector3( 0, 0, 0 ) )
                        lobby_data.heli_vehicle:setData( "ignore_removal", true, false )

                        local coordinator = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_COORDINATOR, true )
                        lobby_data.heli_vehicle.dimension = coordinator:GetUniqueDimension()

                        addEventHandler( "onVehicleStartEnter", lobby_data.heli_vehicle, function( player, seat )
                            if player ~= coordinator and seat == 0 then cancelEvent() end
                        end )
                    end, 1200, 1 )
                end;
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
                        name = "Следуй указанием координатора";
                        fn = function( lobby_data )
                            localPlayer:ShowInfo( "Заказ готов к доставке!" )

                            CreateQuestPoint( lobby_data.delivery_vehicle.position, function()
                                CEs.marker:destroy()
                            end, _, 5, 0, 0, CheckFailIfVehicle, _, _, _, 0, 255, 0, 20, 3 )

                            AddDeliveryVehicleHandlers( lobby_data.delivery_vehicle )
                            AddExitWarningHandler( lobby_data.delivery_vehicle, FAIL_EXIT_VEHICLE_TIME_MS, "Вернись к заказаному транспорту", "удалился от авто" )

                            GEs.delivery_vehicle = lobby_data.delivery_vehicle
                            GEs.OnEnterVehicle_handler = function( player, seat )
                                ShowStationHint()
                                removeEventHandler( "onClientVehicleEnter", lobby_data.delivery_vehicle, GEs.OnEnterVehicle_handler )
                            end
                            addEventHandler( "onClientVehicleEnter", lobby_data.delivery_vehicle, GEs.OnEnterVehicle_handler )

                            CEs.col_path_interface = CreateColshapePathInterface( {
                                route_id = lobby_data.route_id;
                                target_player = GetLobbyPlayersByRole( lobby_data, JOB_ROLE_DRIVER, true );
                                target_vehicle = lobby_data.delivery_vehicle;
                                callback = function()
                                    triggerServerEvent( lobby_data.end_step, localPlayer )
                                end;
                            } )
                        end,
                    };

                    [ JOB_ROLE_COORDINATOR ] = 
                    { 
                        name = "Координируй напарника";
                        fn = function( lobby_data )
                            AddHeliHandlers( lobby_data.heli_vehicle )
                            AddExitWarningHandler( lobby_data.heli_vehicle, FAIL_EXIT_VEHICLE_TIME_MS, "Вернись в вертолет", "удалился от службного вертолета" )
                            
                            fadeCamera( true, 1 )
                            ShowStationHint()
                            CreateBlipDeliveredVehicle( lobby_data )
                            CEs.blip_path_interface = CreateMarkerPathInterface( {
                                route_id = lobby_data.route_id;
                                target_player = GetLobbyPlayersByRole( lobby_data, JOB_ROLE_DRIVER, true );
                                target_vehicle = lobby_data.delivery_vehicle;
                            } )
                        end;
                        skip = true,
                    };
                }; 
            
                server = function( lobby_data, data )
                    local coordinator = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_COORDINATOR, true )

                    lobby_data.heli_vehicle.dimension = 0
                    warpPedIntoVehicle( coordinator, lobby_data.heli_vehicle )
                    coordinator:setData( "in_heli_enter", true, false )

                    lobby_data.review_vehicle = false
                    lobby_data.delivery_vehicle.dimension = 0
                    local driver = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_DRIVER, true )
                    addEventHandler( "onVehicleStartEnter", lobby_data.delivery_vehicle, function( player, seat, jacked, door )
                        if player ~= driver or seat ~= 0 or lobby_data.review_vehicle then cancelEvent() end
                    end )

                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, FAIL_DELIVERY_TIME_MS, nil, "Слишком медленная доставка", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                client = function( lobby_data )
                    removeEventHandler( "onClientKey", root, onClientKeyHint_handler )

                    if GEs.OnEnterVehicle_handler and isElement( GEs.delivery_vehicle ) then
                        removeEventHandler( "onClientVehicleEnter", GEs.delivery_vehicle, GEs.OnEnterVehicle_handler )
                    end
                    if CEs.gps_marker then CEs.gps_marker:destroy() end
                    RemoveExitWarningHandler()
                    RemoveDeliveryVehicleHandlers()
                end,
                server = function( lobby_data )
                    DestroyBlipDeliveredVehicle( lobby_data )
                    lobby_data.start_step = getRealTimestamp()
                    lobby_data.review_vehicle = true
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
                        name = "Проверь транспортное средство";
                        fn = function( lobby_data )
                            lobby_data.delivery_vehicle.frozen = true
                            lobby_data.delivery_vehicle.locked = true

                            TryStartCheckDistanceElementTimer( lobby_data.delivery_vehicle, TAKE_DRIVER_ZONE_SIZE, FAIL_LEAVE_WAIT_ZONE_TIME_MS, "Вернись к заказаному транспорту", "удалился от авто" )

                            CEs.minigame = 
                            {
                                detail = { },
                                detail_id = 0,
                                review_details = { },
                                anim_duration = REVIEW_CAR_TIME_MS,
                            }

                            for k, v in ipairs( { "bonnet_dummy", "wheel_rf_dummy", "wheel_rb_dummy", "wheel_lb_dummy", "wheel_lf_dummy", "boot_dummy" } ) do
                                local wx, wy, wz = lobby_data.delivery_vehicle:getComponentPosition( v, "world" )
					        	if v == "bonnet_dummy" or v == "boot_dummy" then
                                    table.insert( CEs.minigame.review_details, { name = v, position = Vector3( wx, wy, wz ), marker_position = lobby_data.delivery_vehicle:calculateFBPosition( 1, 2.5 * (v == "bonnet_dummy" and 1 or -1) ) } )
					        	else					        		
					        		local rx, ry = lobby_data.delivery_vehicle:getComponentPosition( v, "root" )
					        		table.insert( CEs.minigame.review_details, { name = v, position = Vector3( wx, wy, wz ), marker_position = lobby_data.delivery_vehicle:getMatrix():transformPosition( rx * 2, ry, 0 ) } )
					        	end
                            end

                            CEs.minigame.SetAnimationByDetail = function( anim_duration )
                                if CEs.minigame.detail.name == "bonnet_dummy" or CEs.minigame.detail.name == "boot_dummy" then								    		
                                    localPlayer:setAnimation( "bd_fire", "wash_up", anim_duration, true, false, false, false )
                                else
                                    localPlayer:setAnimation( "bomber", "bom_plant_loop", anim_duration, true, false, false, false )
                                end
                            end

                            CEs.minigame[ 1 ] = function()
                                CEs.off_block_anim = setTimer( function()
                                    toggleControl( "fire", true )
                                end, 3000, 1 )

                                localPlayer:setAnimation()
                                localPlayer.frozen = false

                                CEs.minigame.detail_id = CEs.minigame.detail_id + 1
                                CEs.minigame.detail = CEs.minigame.review_details[ CEs.minigame.detail_id ]

                                if CEs.minigame.detail then
                                    CreateQuestPoint( CEs.minigame.detail.marker_position, function()
								    	CEs.marker:destroy()

                                        localPlayer:RotateToTarget( CEs.minigame.detail.position )
                                        localPlayer.position = localPlayer.position
                                        localPlayer.frozen = true
                                        toggleControl( "fire", false )

                                        CEs.minigame.SetAnimationByDetail( CEs.minigame.anim_duration )
                                        CEs.process_tmr = setTimer( CEs.minigame[ 2 ], CEs.minigame.anim_duration + 50, 1 )
                                    end, _, 1.5, 0, 0, false, "lalt", "Нажми 'Левый ALT' чтобы осмотреть", "cylinder", 0, 100, 230, 50 )
                                else
                                    local lost_time = ((lobby_data.start_step + FAIL_TAKE_DRIVER_TIME_MS / 1000) - getRealTimestamp()) * 1000
                                    StartQuestTimerWait( lost_time, "Ожидай напарника" )
                                    triggerServerEvent( lobby_data.end_step, localPlayer )
                                end
                            end

                            CEs.minigame[ 2 ] = function()
                                CEs.game = ibInfoPressKey( {
                                    do_text = "Нажми",
                                    text = "чтобы взять тряпку",
                                    key = "lalt",
                                    key_text = "ALT",
                                    black_bg = 0x00000000,
                                    key_handler = CEs.minigame[ 3 ],
                                } )
                            end

                            CEs.minigame[ 3 ] = function()
                                CEs.minigame.SetAnimationByDetail( CEs.minigame.anim_duration * 100000 )
                                CEs.game = ibInfoPressKeyProgress( {
                                    do_text = "Нажимай",
                                    text = "чтобы протереть",
                                    key = "mouse2",
                                    black_bg = 0x00000000,
                                    click_count = 10,
                                    end_handler = CEs.minigame[ 1 ],
                                } )
                            end

                            CEs.minigame[ 1 ]()
                        end;
                    };

                    [ JOB_ROLE_COORDINATOR ] = 
                    { 
                        name = "Забери напарника";
                        fn = function( lobby_data )                            
                            CreateQuestPoint( CAR_ROUTES[ lobby_data.route_id ][ #CAR_ROUTES[ lobby_data.route_id ] ], function()
                                CEs.marker:destroy()
                                triggerServerEvent( lobby_data.end_step, localPlayer )
                            end, _, 20, 0, 0, CheckFailNotVehicle, _, _, _, 0, 255, 0, 20, 3 )
                        end;
                    };
                };

                server = function( lobby_data, data )
                    local coordinator = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_COORDINATOR, true )
                    StartCoopQuestTimerWait( { coordinator }, lobby_data.lobby_id, FAIL_TAKE_DRIVER_TIME_MS, nil, "Координатор не успел забрать водителя", _, function()
                        return false
                    end )

                    lobby_data.delivery_vehicle.frozen = true
                    lobby_data.delivery_vehicle.locked = true
                end;
            };

            CleanUp =
            {
                client = function()
                    StopCheckDistanceTimer() 
                    localPlayer.frozen = false
                    localPlayer:setAnimation()
                    toggleControl( "fire", true )
                end;
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
                        name = "Садись в вертолёт";
                        fn = function( lobby_data )
                            GEs.onPlayerVehicleEnter = function( vehicle )
                                if vehicle == lobby_data.heli_vehicle then
                                    ShowEnterHeliHint( false )
                                    AddExitWarningHandler( lobby_data.heli_vehicle, FAIL_EXIT_VEHICLE_TIME_MS, "Вернись в вертолет", "удалился от службного вертолета" )
                                    triggerServerEvent( lobby_data.end_step, localPlayer )
                                end
                            end
                            addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.onPlayerVehicleEnter )
                            ShowEnterHeliHint( true, lobby_data )
                        end;
                    };
                    [ JOB_ROLE_COORDINATOR ] = { name = "Ожидай напарника"; };
                };
            
                server = function( lobby_data, data )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, FAIL_ENTER_HELI_TIME_MS, nil, "Водитель не успел сесть в вертолёт", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                client = function()
                    if GEs.onPlayerVehicleEnter then
                        removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.onPlayerVehicleEnter )
                    end
                end,
                server = function( lobby_data )
                    lobby_data.start_step = getRealTimestamp()
                    lobby_data.end_point_id = math.random( 1, #ZONE_SPAWN_OF_HELI )
                end;
            };
        };

        [ 5 ] =
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = { name = "Ожидай прибытия на базу"; };
                    [ JOB_ROLE_COORDINATOR ] = 
                    { 
                        name = "Отправляйся на базу";
                        fn = function( lobby_data )
                            local driver = GetLobbyPlayersByRole( lobby_data, JOB_ROLE_DRIVER, true )
                            CreateQuestPoint( ZONE_SPAWN_OF_HELI[ lobby_data.end_point_id ], function()
                                if driver.vehicle ~= lobby_data.heli_vehicle then
                                    localPlayer:ShowError( "Напарник должен находиться в вертолете" )
                                    return false
                                end

                                CEs.marker:destroy()
                                triggerServerEvent( lobby_data.end_step, localPlayer )
                            end, _, 20, 0, 0, CheckFailNotVehicle, _, _, _, 0, 255, 0, 20, 3 )
                        end;
                    };
                };
            
                server = function( lobby_data, data )
                    StartCoopQuestTimerWait( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), lobby_data.lobby_id, FAIL_RETURN_BASE_TIME_MS, nil, "Вы не успели добраться до базы", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                client = function()
                    DestroyBlipDliveredVehicle( )
                end,
                server = function( lobby_data )
                    
                    local coordinator = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_COORDINATOR, true )
                    if isElement( coordinator ) then
                        coordinator:setData( "in_heli_enter", false, false )
                    end
                    
                    lobby_data.vehicle_count = (lobby_data.vehicle_count or 0) + 1
                    
                    local spawn_id = math.random( 1, #SPAWN_ZONES_OF_PLAEYRS )

                    lobby_data.remove_veh_tmr = {}
                    lobby_data.fade_tmr = {} 
                    for k, v in pairs( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ) ) do
                        fadeCamera( v, false, 0.5 )
                        lobby_data.remove_veh_tmr[ v ] = setTimer( function()
                            if isElement( v ) then
                                v.frozen = true
                                removePedFromVehicle( v )
                            end
                        end, 600, 1 )

                        lobby_data.fade_tmr[ v ] = setTimer( function()
                            if isElement( v ) then
                                v.position = SPAWN_ZONES_OF_PLAEYRS[ spawn_id ]:AddRandomRange( 3 )
                                v.frozen = false
                                fadeCamera( v, true, 1 )
                            end
                        end, 1000, 1 )
                    end

                    lobby_data.destroy_heli = setTimer( function()
                        if isElement( lobby_data.heli_vehicle ) then
                            destroyElement( lobby_data.heli_vehicle )
                        end
                    end, 1000, 1 )
                end;
            };
        };

    };
}

function GetQuestData( )
	return QUEST_DATA
end