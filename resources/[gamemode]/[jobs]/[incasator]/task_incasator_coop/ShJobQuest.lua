loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

enum "eCoopJobRoles" 
{
    "JOB_ROLE_DRIVER",
    "JOB_ROLE_GUARD",
}

QUEST_DATA = 
{
	id = "task_incasator_coop";
	title = "Инкассатор";
    description = "Перевозка денежных средств";
    job_class = JOB_CLASS_INKASSATOR,

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

        [ JOB_ROLE_GUARD ] =
        {
            id   = "protector";
            name = "Охранник";
            max_count = 3;
			min_count = 1;
		};
    };

    OnAnyFinish = 
    {
        client = function()
            StopCheckDistanceTimer()
        end,
        server = function( lobby_id, finish_state )
            onAnyFinishIncasator( lobby_id, finish_state )
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
                        name = "Отправляйся к точке инкассации";
                        fn = function( lobby_data )
                            TryStartCheckDistanceElementTimer( _, 300 )
                            if not lobby_data.lap_completed then addEventHandler("onClientVehicleStartExit", lobby_data.job_vehicle, onDriverTryExitFromVehicle ) end
                            for k, v in pairs( lobby_data.participants ) do
                                if isElement( v.player ) then
                                    v.player:setData( "work_lobby_id", lobby_data.lobby_id, false )
                                end
                            end
                            triggerEvent( "onClientCreateIncasatorInfo", localPlayer )
                        end,
                    },
                    [ JOB_ROLE_GUARD ] = { 
                        name = "Ожидай прибытия на точку инкассации";
                        fn = function( lobby_data )
                            TryStartCheckDistanceElementTimer( _, 300 )
                            if lobby_data.lap_completed then
                                CEs.vehicle_blip = createBlipAttachedTo( lobby_data.job_vehicle, 0, 2 )
                                addEventHandler( "onClientVehicleEnter", lobby_data.job_vehicle, onReturnVehicleGuard )
                            end
                        end,
                        skip = true,
                    },  
                };
            
                server = function( lobby_data, data )
                    lobby_data.process_bags = false
                    lobby_data.current_point = 0
                    lobby_data.count_vehicle_bags = 0
                    lobby_data.quest_bags_count = QUEST_BAGS_COUNT

                    lobby_data.job_vehicle:setData( "all_damage", 0, false )
                    lobby_data.bank_point_id = math.random( 1, #BANK_LOAD_POINT )
                    CreateDriverBusinessPoint( lobby_data, true )


                    for k, v in pairs( GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_GUARD ) ) do
                        v.armor = 100
                        TakeWeaponsFromTable( v, INCASATOR_WEAPONS_DATA[ JOB_ROLE_GUARD ] )
                        GiveWeaponsFromTable( v, INCASATOR_WEAPONS_DATA[ JOB_ROLE_GUARD ], true, "incasator_weapon" )
                    end
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.process_bags = 0
                    lobby_data.current_point = lobby_data.current_point + 1
                    ParkingIncasatorVehicle( lobby_data, true )
                end,
            };
        };
        
        [ 2 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = { name = "Ожидайте погрузки мешков с деньгами"; };
                    [ JOB_ROLE_GUARD ] = 
                    { 
                        name = "Загрузите мешки с деньгами в машину";
                        fn = function( lobby_data )
                            if isPedInVehicle( localPlayer ) then
                                localPlayer:ShowInfo( "Нажмите G чтобы выйти из машины" )
                            end
                            CreateTakeBussinessPoint( lobby_data.bank_point_id, lobby_data.job_vehicle )
                        end;
                    },
                };
            
                server = function( lobby_data )
                    if isTimer( lobby_data.end_shift_tmr ) then killTimer( lobby_data.end_shift_tmr ) end
                    local target_players = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_GUARD )
                    StartCoopQuestTimerWait( target_players, lobby_data.lobby_id, CONST_LOAD_VEHICLE_TIME * 1000, "Загрузите мешки с деньгами", "Слишком медленная погрузка мешков с деньгами", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.process_bags = false
                    ParkingIncasatorVehicle( lobby_data, false )
                end,
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
                        name = "Отправляйся к точке инкассации";
                        fn = function( lobby_data ) end;
                    },
                    [ JOB_ROLE_GUARD ] = { name = "Ожидай прибытия на точку инкассации"; },
                };
            
                server = function( lobby_data )

                    local function GetBusinessPoint( lobby_data )
                        repeat
                            local bank_id = math.random( 1, #BANK_LOAD_POINT )
                            local distance = getDistanceBetweenPoints3D( BANK_LOAD_POINT[ lobby_data.bank_point_id ].parking, BANK_LOAD_POINT[ bank_id ].parking )
                            if distance > BANK_LOAD_POINT_MIN_DISTANCE and distance < BANK_LOAD_POINT_MAX_DISTANCE then
                                return bank_id
                            end
                        until false
                    end
                    
                    lobby_data.bank_point_id = GetBusinessPoint( lobby_data )
                    CreateDriverBusinessPoint( lobby_data )

                    ShowInfoMessageQuestPlayers( lobby_data.lobby_id, JOB_ROLE_GUARD, function( player )
                        return not isPedInVehicle( player )
                    end, "Подойдите к машине и нажмите G для того чтобы отправиться на точку разгрузки" )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.process_bags = 0
                    lobby_data.current_point = lobby_data.current_point + 1
                    ParkingIncasatorVehicle( lobby_data, true )
                end,
            };
        };

        [ 4 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = { name = "Ожидайте погрузки мешков с деньгами"; };
                    [ JOB_ROLE_GUARD ] = 
                    { 
                        name = "Загрузите мешки с деньгами в машину";
                        fn = function( lobby_data )
                            if isPedInVehicle( localPlayer ) then
                                localPlayer:ShowInfo( "Нажмите G чтобы выйти из машины" )
                            end
                            CreateTakeBussinessPoint( lobby_data.bank_point_id, lobby_data.job_vehicle )
                        end;
                    },
                };
            
                server = function( lobby_data )
                    local target_players = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_GUARD )
                    StartCoopQuestTimerWait( target_players, lobby_data.lobby_id, CONST_LOAD_VEHICLE_TIME * 1000, "Загрузите мешки с деньгами", "Слишком медленная погрузка мешков с деньгами", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.process_bags = false
                    ParkingIncasatorVehicle( lobby_data, false )
                end,
            };
        };
        
        [ 11 ] = 
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Отправляйся на точку разгрузки";
                        fn = function( lobby_data )
                            CreateUnloadVehiclePoint( lobby_data )
                        end;
                    };
                    [ JOB_ROLE_GUARD ] = { name = "Ожидайте прибытия на точку разгрузки";},
                };
            
                server = function( lobby_data )
                    ShowInfoMessageQuestPlayers( lobby_data.lobby_id, JOB_ROLE_GUARD, function( player )
                        return not isPedInVehicle( player )
                    end, "Подойдите к машине и нажмите G для того чтобы отправиться на точку разгрузки" )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    ParkingIncasatorVehicle( lobby_data, true )
                end,
            };
        };

        [ 12 ] =
        {
            Setup = 
            {
                client = 
                {
                    [ JOB_ROLE_DRIVER ] = 
                    { 
                        name = "Ожидайте разгрузки мешков с деньгами";
                    };
                    [ JOB_ROLE_GUARD ] = 
                    { 
                        name = "Разгрузите мешки с деньгами";
                        fn = function( lobby_data )
                            if isPedInVehicle( localPlayer ) then
                                localPlayer:ShowInfo( "Нажмите G чтобы выйти из машины" )
                            end
                            CreateTakeVehiclePoint( lobby_data.job_vehicle )
                        end;
                    },
                };
            
                server = function( lobby_data )
                    lobby_data.process_bags = true
                    lobby_data.count_unload_bags = 0
                    
                    local target_players = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_GUARD )
                    StartCoopQuestTimerWait( target_players, lobby_data.lobby_id, CONST_LOAD_VEHICLE_TIME * 1000, "Разгрузите мешки", "Слишком медленная разгрузка мешков с деньгами", _, function()
                        return false
                    end )
                end;
            };

            CleanUp =
            {
                server = function( lobby_data )
                    lobby_data.lap_completed = true
                    ParkingIncasatorVehicle( lobby_data, false )
                end,
            };
        };
    };
    
    GiveReward = function( player, lobby_data )
        triggerEvent( "onCoopJobCompletedLap", resourceRoot, player, lobby_data.lobby_id )
	end;
}

QUEST_DATA.tasks[ 5 ] = table.copy( QUEST_DATA.tasks[ 3 ] )
QUEST_DATA.tasks[ 6 ] = table.copy( QUEST_DATA.tasks[ 4 ] )

QUEST_DATA.tasks[ 7 ] = table.copy( QUEST_DATA.tasks[ 3 ] )
QUEST_DATA.tasks[ 8 ] = table.copy( QUEST_DATA.tasks[ 4 ] )

QUEST_DATA.tasks[ 9 ]  = table.copy( QUEST_DATA.tasks[ 3 ] )
QUEST_DATA.tasks[ 10 ] = table.copy( QUEST_DATA.tasks[ 4 ] )

function GetQuestData( )
	return QUEST_DATA
end