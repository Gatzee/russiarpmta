QUEST_CONF = {
    dialogs = {
        start = {
            { name = "Охранник", voice_line = "Ohrannik_monolog16", text = "Главный ждет, проходи!" },
        },
        start_info = {
            { name = "Глава западного картеля", voice_line = "Glava_Zapadnogo_Kartelya_monolog17", text = "Вы че там совсем охамели?! Слушай сюда мразь!\nМы свою часть выполнили! Если твой босс хочет работать дальше,\nто тебе придется заплатить." },
            { name = "Глава западного картеля", text = "Для вашего дела один человек нужен он на зоне застрял...\nНадо его вытаскивать! Иди бери снаряжение,\nснаружи тебя вертолет уже ждет!" },
            { name = "Глава западного картеля", text = "Вернешь его, тогда и посмотрим.\nСтоит ли с вами работать!" },
        },
        finish = {
            { name = "Роман", voice_line = "Roman_monolog18", text = "Вот же... Твоё спасение стоило недешево. С тебя будет спрос!" },
            { name = "Роман", text = "Ты главное духом не падай. Я свои активы берегу.\nКогда понадобишься я наберу, а сейчас проваливай отсюда!" },
        },
    },

    positions = {
        enter_to_prison = Vector3( -2394.85, 1738.41, 15.71 ),
        exit_from_prison = Vector3( -2689.060, 2620.716, 1618.426 ),

        guard_spawn = { pos = Vector3( -1940.8408, 667.1517, 18.4057 ), rot = 280 },

        west_guards = {
            { pos = Vector3( -1979.7105, 647.6136, 21.9808 ), rot = 281 },
            { pos = Vector3( -1982.8135, 665.4837, 21.9808 ), rot = 279 },
            { pos = Vector3( -1980.9775, 656.4002, 21.9808 ), rot = 279 },
            { pos = Vector3( -1983.9226, 642.6508, 18.4853 ), rot = 279 },
            { pos = Vector3( -1988.4256, 668.7527, 18.4928 ), rot = 277 },
            { pos = Vector3( -1969.7747, 670.2835, 18.4853 ), rot = 220 },
            { pos = Vector3( -1966.3282, 640.1213, 18.7040 ), rot = 326 },
            { pos = Vector3( -1951.5627, 652.9140, 18.4853 ), rot = 5   },
            { pos = Vector3( -1999.3021, 628.7557, 18.4853 ), rot = 297 },
            { pos = Vector3( -2006.0462, 673.8437, 18.4853 ), rot = 276 },
            { pos = Vector3( -1998.5227, 662.1861, 18.4928 ), rot = 18  },
            { pos = Vector3( -1995.8953, 645.4427, 18.4853 ), rot = 190 },
        },

        west_guards_interior = {
            { pos = Vector3( 457.8113, -1206.2603, 1096.0899 ), rot = 1   },
            { pos = Vector3( 452.2679, -1206.4005, 1096.0899 ), rot = 1   },
            { pos = Vector3( 457.9622, -1196.5179, 1096.0899 ), rot = 184 },
            { pos = Vector3( 452.1653, -1196.6474, 1096.0899 ), rot = 181 },
            { pos = Vector3( 438.7445, -1202.9569, 1099.0474 ), rot = 269 },
            { pos = Vector3( 439.4834, -1200.1868, 1099.0406 ), rot = 268 },
            { pos = Vector3( 446.0445, -1196.9859, 1101.2745 ), rot = 73  },
            { pos = Vector3( 461.5321, -1201.4687, 1100.0971 ), rot = 89  },
        },
    },

    rewards = {
        money = 6000,
        exp = 5000,
    },
}

GEs = { }

-- iexe nrp_player GetPlayer(7):setData("quests",{})
-- crun triggerServerEvent("PlayeStartQuest_rescue_operation",root)

QUEST_DATA = {
    id = "rescue_operation",
    is_company_quest = true,

    title = "Операция спасения",
    description = "Опять работа с бандитами, к сожалению других вариантов просто нет...",

    CheckToStart = function( player )
        return player.interior == 0 and player.dimension == 0
    end,

    restart_position = Vector3( -1925.2247, 681.5946, 18.6618 ),

    quests_request = { "delivery_of_goods" },
    level_request = 10,

    OnAnyFinish = {
        server = function( player )
            if player.interior ~= 0 then
                player.interior = 0
                player.position = Vector3( -1937.668, 664.321, 18.323 )
            end

            DestroyAllTemporaryVehicles( player )
            ExitLocalDimension( player )

            player:TakeAllWeapons( true )

            local data = player:getData( "save_pre_quest_data" )
            if data then
                player.armor = data.armor

                if player:InventoryGetItemCount( IN_DRUGS, { 3 } ) > data.drugs then -- more than before start quest
                    player:InventoryRemoveItem( IN_DRUGS, { 3 }, 1 )
                end

                player:setData( "save_pre_quest_data", false, false )
            end
        end,

    },

    tasks = {
        {
            name = "Подойди к охраннику",

            Setup = {
                client = function( )
                    CreateMarkerToCutsceneNPC( {
                        id = "west_cartel_guard",
                        dialog = QUEST_CONF.dialogs.start,
                        callback = function( )
                            EnterLocalDimension( )

                            CEs.marker.destroy( )
                            CEs.dialog:next( )

                            StartPedTalk( FindQuestNPC( "west_cartel_guard" ).ped, nil, true )

                            setTimerDialog( function( )
                                FinishQuestCutscene( )
                                triggerServerEvent( "rescue_operation_step_1", localPlayer )
                            end, 3500 )
                        end
                    } )
                end,
                server = function ( player )
                    local vehicle = CreateTemporaryVehicle( player, 469, Vector3( -1947.02, 639.72, 19 ), Vector3( 0, 0, 0 ) )
                    player:SetPrivateData( "temp_vehicle", vehicle )
                    vehicle:SetColor( 0, 0, 0 )
                end,
            },

            CleanUp = {
                client = function( data, failed )
                    FinishQuestCutscene( )
                    StopPedTalk( FindQuestNPC( "west_cartel_guard" ).ped )
                end,
            },

            event_end_name = "rescue_operation_step_1",
        },

        {
            name = "Пройди в здание картеля",

            Setup = {
                client = function( )
                    local positions = QUEST_CONF.positions
                    GEs.west_guards = {}

                    for _, guard_data in pairs( { { positions.west_guards, 0 }, { positions.west_guards_interior, 1 } } ) do
                        for k, v in pairs( guard_data[ 1 ] ) do
                            local ped = CreateAIPed( math.random( 0, 1 ) == 1 and 257 or 258, v.pos, v.rot )

                            ped.interior = guard_data[ 2 ]
                            ped.dimension = localPlayer.dimension
                            SetUndamagable( ped, true )

                            givePedWeapon( ped, 29, 1000, true )
                            setPedStat( ped, 76, 1000 )
                            setPedStat( ped, 22, 1000 )

                            table.insert( GEs.west_guards, ped )
                        end
                    end

                    CreateQuestPoint( Vector3( -1979.671, 656.846, 18.485 ), function( )
                        CEs.marker.destroy( )

                        fadeCamera( false, 0 )

                        localPlayer:Teleport( Vector3( 461.234, -1201.424, 1096.090 ), nil, 1 )
                        localPlayer.rotation = Vector3( 0, 0, 90 )

                        GEs.fade_timer = Timer( function ( )
                            FadeBlink( 2.0 )
                            triggerServerEvent( "rescue_operation_step_2", localPlayer )
                        end, 1000, 1 )
                    end )
                end,
            },

            event_end_name = "rescue_operation_step_2",
        },

        {
            name = "Поговори с главой картеля",

            Setup = {
                client = function( )
                    CreateMarkerToCutsceneNPC( {
                        radius = 1,
                        id = "head_western_cartel",
                        dialog = QUEST_CONF.dialogs.start_info,
                        callback = function( )
                            CEs.marker.destroy( )
                            CEs.dialog:next( )

                            StartPedTalk( FindQuestNPC( "head_western_cartel" ).ped, nil, true )

                            local t = {}

                            t.dialog_1 = function()
                                setTimerDialog( function( )
                                    CEs.dialog:next( )
                                    t.dialog_2()
                                end, 9000 )
                            end

                            t.dialog_2 = function()
                                setTimerDialog( function( )
                                    CEs.dialog:next( )
                                    t.dialog_3()
                                end, 10250 )
                            end

                            t.dialog_3 = function()
                                setTimerDialog( function( )
                                    triggerServerEvent( "rescue_operation_step_3", localPlayer )
                                end, 4500 )
                            end

                            t.dialog_1()
                        end
                    } )
                end,
            },

            CleanUp = {
                client = function( data, failed )
                    FinishQuestCutscene( )
                    StopPedTalk( FindQuestNPC( "head_western_cartel" ).ped )
                end,
            },

            event_end_name = "rescue_operation_step_3",
        },

        {
            name = "Получить снаряжение",

            Setup = {
                client = function( )
                    CreateQuestPoint( Vector3( 439.382, -1196.263, 1096.090 ), function( )
                        CEs.marker.destroy( )
                        setPedAnimation( localPlayer, "rob_bank", "cat_safe_rob", 4000, true, false, false, false )

                        GEs.timer_weapon = setTimer( function ( )
                            setPedAnimation( localPlayer, "rob_bank", "cat_safe_end", -1, false, true, false, false )
                            triggerServerEvent( "rescue_operation_step_4", localPlayer )
                        end, 4100, 1 )
                    end, nil, 0.5, 1 )
                end,
            },

            event_end_name = "rescue_operation_step_4",
        },

        {
            name = "Проследовать в вертолёт",

            Setup = {
                client = function( )
                    EnableCheckQuestDimension( true )
                    toggleControl( "jump", false )

                    CreateQuestPoint( Vector3( 461.68, -1201.58, 1095.09 ), function( )
                        CEs.marker.destroy( )
                        triggerServerEvent( "rescue_operation_step_5", localPlayer )
                    end, nil, nil, 1 )
                end,
                server = function( player )
                    player:setData( "save_pre_quest_data", {
                        armor = player.armor,
                        drugs = player:InventoryGetItemCount( IN_DRUGS, { 3 } )
                    }, false )

                    player:GiveWeapon( 30, 300, false, true )
                    player:GiveWeapon( 22, 100, false, true )
                    player:GiveWeapon( 46, 1, false, true )

                    player.armor = 100
                    player:InventoryAddItem( IN_DRUGS, { 3 }, 1 )

                    player.weaponSlot = 5 -- switch ak-47
                end
            },

            CleanUp = {
                client = function ( )
                    toggleControl( "jump", true )
                end,
            },

            event_end_name = "rescue_operation_step_5",
        },

        {
            name = "Проследовать в вертолёт",

            Setup = {
                client = function( )
                    FadeBlink( 2.0 )
                    StartQuestCutscene( )

                    localPlayer.frozen = false
                    localPlayer:Teleport( Vector3( -1977.09, 657.06, 18.485 ), nil, 0 )
                    localPlayer.rotation = Vector3( 0, 0, -90 )

                    local route = {
                        { x = -1955.361, y = 660.266, z = 18.485, move_type = 6, distance = 0 },
                        { x = -1952.385, y = 644.551, z = 18.485, move_type = 6, distance = 0 }
                    }

                    GEs.bot_pilot = CreateAIPed( 54, Vector3( -1978.09, 658.06, 18.485 ) )
                    GEs.bot = CreateAIPed( localPlayer )

                    GEs.bot_pilot.dimension = localPlayer:GetUniqueDimension( )

                    local vehicle = localPlayer:getData( "temp_vehicle" )
                    warpPedIntoVehicle( GEs.bot_pilot, vehicle )

                    addEventHandler( "onClientVehicleStartEnter", vehicle, function ( )
                        cancelEvent( )
                    end )

                    SetAIPedMoveByRoute( GEs.bot, route, false )

                    setCameraMatrix( -1956.2009277344, 678.59033203125, 34.180080413818, -1985.0939941406, 601.04107666016, -21.956348419189 )

                    CEs.timer_forwards = setTimer( function ( )
                        local from = { -1955.0123291016, 659.82073974609, 18.5, -1920.892578125, 565.87091064453, 18.5, 0, 70 }
                        local to = { -1949.9230957031, 647.39178466797, 18.5, -1909.6424560547, 555.88507080078, 18.5, 0, 70 }

                        GEs.move = CameraFromTo( from, to, 5000, "Linear", function ( )
                            setCameraMatrix( -1922.4996337891, 626.05584716797, 38.813129425049, -1997.7145996094, 661.85125732422, -16.51681137085 )

                            GEs.heli_up = setTimer( function ( )
                                vehicle.velocity = Vector3( 0, 0, vehicle.velocity.z + 0.013 )
                            end, 50, 50 )

                            GEs.heli_0 = setTimer( function ( )
                                vehicle.velocity = Vector3( 0, 0, 0 )

                                fadeCamera( false, 1 )
                                GEs.fade_timer = Timer( function ( )
                                    triggerServerEvent( "rescue_operation_step_6", localPlayer )
                                end, 1000, 1 )
                            end, 2500, 1 )
                        end )
                    end, 7500, 1 )
                end,
                server = function ( player )
                    GEs.timer_warp = setTimer( function ( )
                        local vehicle = player:getData( "temp_vehicle" )
                        warpPedIntoVehicle( player, vehicle, 1 )
                        vehicle.frozen = false
                    end, 7500 + 5000, 1 )
                end,
            },

            CleanUp = {
                client = function( data, failed )
                    detachElements( getCamera( ), localPlayer )
                end,
            },

            event_end_name = "rescue_operation_step_6",
        },

        {
            name = "...",

            Setup = {
                client = function( )
                    local vehicle = localPlayer:getData( "temp_vehicle" )
                    vehicle.rotation = Vector3( -30, 0, 0 )

                    FadeBlink( 2.0 )

                    local from = { -2400.8107910156, 1796.6330566406, 490.85165405273, -2408.8728027344, 1700.7380371094, 463.66415405273, 0, 70 }
                    local to = { -2403.3596191406, 1757.9987792969, 480.03515625, -2409.4118652344, 1661.9560546875, 452.84765625, 0, 70 }

                    GEs.move = CameraFromTo( from, to, 2555, "Linear", function ( )
                        FinishQuestCutscene( )
                        triggerServerEvent( "rescue_operation_step_7", localPlayer )
                    end )

                    local objects = {
                        { model = 2973, position = Vector3( { x = -2413, y = 1695, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 296 } ) },
                        { model = 2973, position = Vector3( { x = -2412, y = 1721.4, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 296 } ) },
                        { model = 2973, position = Vector3( { x = -2417.3, y = 1715.3, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 295.999 } ) },
                        { model = 2973, position = Vector3( { x = -2409.4, y = 1712.7, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 295.999 } ) },
                        { model = 2973, position = Vector3( { x = -2412.4, y = 1704.7, z = 13.1 } ), rotation = Vector3( { x = 0, y = 0, z = 295.999 } ) },
                        { model = 2991, position = Vector3( { x = -2407.6001, y = 1691.4, z = 13.7 } ), rotation = Vector3( { x = 0, y = 0, z = 26 } ) },
                        { model = 1299, position = Vector3( { x = -2405.8, y = 1703.5, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 226 } ) },
                        { model = 1217, position = Vector3( { x = -2401.3999, y = 1688.1, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1217, position = Vector3( { x = -2398.5, y = 1685.8, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1217, position = Vector3( { x = -2398.8999, y = 1689, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1218, position = Vector3( { x = -2400.7, y = 1686.4, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1218, position = Vector3( { x = -2399.1001, y = 1687, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1218, position = Vector3( { x = -2397.5, y = 1686.7, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1218, position = Vector3( { x = -2396.8999, y = 1685, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1217, position = Vector3( { x = -2397.3, y = 1688.7, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1217, position = Vector3( { x = -2401.3, y = 1689.9, z = 13.5 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1217, position = Vector3( { x = -2399.7, y = 1684.8, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                        { model = 1218, position = Vector3( { x = -2398.5, y = 1684.1, z = 13.6 } ), rotation = Vector3( { x = 0, y = 0, z = 0 } ) },
                    }

                    for idx, obj in pairs( objects ) do
                        GEs[ "object_" .. idx ] = createObject( obj.model, obj.position )
                        GEs[ "object_" .. idx ].rotation = obj.rotation
                        GEs[ "object_" .. idx ].dimension = localPlayer:GetUniqueDimension( )
                    end
                end,
                server = function( player )
                    local vehicle = player:getData( "temp_vehicle" )

                    vehicle.position = Vector3( -2407.803, 1756.344, 481.555 )
                    vehicle.frozen = true
                end,
            },

            event_end_name = "rescue_operation_step_7",
        },

        {
            name = "Приземлись с парашютом",

            Setup = {
                client = function( )
                    local vehicle = localPlayer:getData( "temp_vehicle" )
                    vehicle.rotation = Vector3( 0, 0, 0 )

                    FadeBlink( 2.0 )

                    GEs.exit_detect = function ( )
                        localPlayer.weaponSlot = 11 -- switch parachute
                        removeEventHandler( "onClientVehicleStartExit", vehicle, GEs.exit_detect )
                        triggerServerEvent( "rescue_operation_step_6", localPlayer )
                    end
                    addEventHandler( "onClientVehicleStartExit", vehicle, GEs.exit_detect )

                    CEs.hint = CreateSutiationalHint( {
                        text = "Нажми key=F или key=ENTER чтобы выпрыгнуть",
                        condition = function( )
                            return localPlayer.vehicle
                        end
                    } )

                    StartQuestTimerWait( 60000, 'Призмелись с парашютом', "Вас заметили сотрудники ФСИН", "rescue_operation_step_8" )

                    CEs.colshape = createColCuboid( -2511.249, 1579.385, 14.086, 200, 200, 2 )
                    addEventHandler( "onClientColShapeHit", CEs.colshape, function( element )
                        if element == localPlayer then
                            source:destroy( )
                            triggerServerEvent( "rescue_operation_step_8", localPlayer )
                        end
                    end )
                end,
            },

            event_end_name = "rescue_operation_step_8",
        },

        {
            name = "Зайди в тюрьму",

            Setup = {
                client = function( )
                    CreateQuestPoint( QUEST_CONF.positions.enter_to_prison, function( )
                        CEs.marker.destroy( )

                        localPlayer:Teleport( QUEST_CONF.positions.exit_from_prison, nil, 1 )
                        fadeCamera( false, 0 )

                        GEs.fade_timer = Timer( function ( )
                            triggerServerEvent( "rescue_operation_step_9", localPlayer )
                        end, 1000, 1 )
                    end, nil, 1 )
                end,
                server = function ( )
                    local vehicle = player:getData( "temp_vehicle" )

                    if isElement( vehicle ) then
                        vehicle:destroy( )
                    end
                end,
            },

            event_end_name = "rescue_operation_step_9",
        },

        {
            name = 'Найди "Широкого"',

            Setup = {
                client = function( )
                    FadeBlink( 2.0 )

                    GEs.object = createObject( 6282, -2690.738, 2622.710, 1622.058 )
                    GEs.object.interior = 1
                    GEs.object.dimension = localPlayer.dimension

                    local passed = 0
                    local markers = {
                        Vector3( { x = -2683.64, y = 2623.85, z = 1621.93 } ),
                        Vector3( { x = -2657.53, y = 2624.01, z = 1621.94 } ),
                        Vector3( { x = -2656.53, y = 2623.84, z = 1618.43 } ),
                        Vector3( { x = -2683.45, y = 2624.09, z = 1618.43 } ),
                    }

                    for idx, position in pairs( markers ) do
                        CreateQuestPoint( position, function( self )
                            self:destroy( )

                            passed = passed + 1
                            if passed == #markers then
                                triggerServerEvent( "rescue_operation_step_10", localPlayer )
                            end
                        end, nil, 1 )
                    end
                end,
            },

            event_end_name = "rescue_operation_step_10",
        },

        {
            name = 'Покинь тюрьму',

            Setup = {
                client = function( )
                    localPlayer:PhoneNotification( { title = "Роман", msg = "Это подстава, держись, скоро тебя заберем!" } )

                    CreateQuestPoint( QUEST_CONF.positions.exit_from_prison, function( )
                        CEs.marker.destroy( )

                        localPlayer:Teleport( QUEST_CONF.positions.enter_to_prison, nil, 0 )

                        triggerServerEvent( "rescue_operation_step_11", localPlayer )
                    end, nil, 1, 1 )
                end,
                server = function( )
                    local fsin_cars = {
                        { model = 579, position = Vector3( -2440.89, 1736.41, 14 ), rotation = 230 },
                        { model = 579, position = Vector3( -2436.04, 1690.90, 14 ), rotation = 250 },
                        { model = 579, position = Vector3( -2423.32, 1672.14, 14 ), rotation = 280 },
                    }

                    for _, data in pairs( fsin_cars ) do
                        local fsin_car = CreateTemporaryVehicle( player, data.model, data.position, Vector3( 0, 0, data.rotation ) )
                        fsin_car.locked = true
                        fsin_car.paintjob = 0
                        fsin_car:setColor( 255, 255, 255 )
                    end
                end,
            },

            event_end_name = "rescue_operation_step_11",
        },

        {
            name = 'Продержись до приезда Романа',

            Setup = {
                client = function( )
                    FadeBlink( 2.0 )

                    local respwans_pos = {
                        Vector3( -2439.508, 1738.622, 14.080 ),
                        Vector3( -2435.588, 1693.283, 14.080 ),
                        Vector3( -2423.266, 1675.122, 14.080 ),
                    }

                    GEs.fsin_bots = {
                        Vector3( -2439.508, 1738.622, 14.080 ),
                        Vector3( -2435.588, 1693.283, 14.080 ),
                        Vector3( -2423.266, 1675.122, 14.080 ),
                    }

                    local function loadBot( idx, pos_id )
                        GEs[ "bot_fsin_" .. idx ] = CreateAIPed( 201, pos_id and respwans_pos[ pos_id ] or GEs.fsin_bots[ idx ] )
                        GEs[ "bot_fsin_" .. idx ].dimension = localPlayer:GetUniqueDimension( )
                        
                        givePedWeapon( GEs[ "bot_fsin_" .. idx ], 30, 999999, true )
                        AddAIPedPatternInQueue( GEs[ "bot_fsin_" .. idx ], AI_PED_PATTERN_ATTACK_PED, {
                            target_ped = localPlayer,
                        } )

                        addEventHandler( "onClientPedWasted", GEs[ "bot_fsin_" .. idx ], function ( )
                            GEs[ "reload_fsin_bot" .. idx ] = setTimer( function ( source )
                                if isElement( source ) then
                                    source:destroy( )
                                    loadBot( idx, math.random( #respwans_pos ) )
                                end
                            end, 15000, 1, source )
                        end )
                    end

                    for idx, _ in pairs( GEs.fsin_bots ) do
                        loadBot( idx )
                    end

                    GEs.shoots = {}
                    GEs.check_bots = function ( )
                        local pos = localPlayer:getBonePosition( 6 )
                        for idx in pairs( GEs.fsin_bots ) do
                            local ped = GEs[ "bot_fsin_" .. idx ]
                            
                            local pedpos = ped.position
                            local dist = (pos - pedpos).length
                            
                            if isLineOfSightClear( pos.x, pos.y, pos.z, pedpos.x, pedpos.y, pedpos.z, nil, false, false ) or dist < 8 then                            
                                if not GEs.shoots[ ped ] then
                                    CleanupAIPedPatternQueue( ped )
			                        removePedTask( ped )
                                    ResetAIPedPattern( ped )

                                    local shoot = CreatePedShoot( ped, true )
				                    shoot.speed_spread = { 2.5, 4.5 }
				                    shoot.distance_no_spread = 0
                                    shoot:start( localPlayer )

                                    GEs.shoots[ ped ] = shoot
                                end
                            else
                                if GEs.shoots[ ped ] then 
                                    GEs.shoots[ ped ]:destroy() 
                                    GEs.shoots[ ped ] = nil
                                end

                                SetAIPedPattern( ped, AI_PED_PATTERN_MOVE_TO_POINT, {
                                    x = pos.x, y = pos.y, z = pos.z, move_type = 6
                                } )
                            end
                        end
                    end
                    CEs.check_timer = setTimer( GEs.check_bots, 1000, 0 )

                    StartQuestTimerWait( 180000, "Продержись до приезда Романа", nil, "rescue_operation_step_12" )
                end,
            },

            event_end_name = "rescue_operation_step_12",
        },

        {
            name = '---',

            Setup = {
                client = function( )
                    for idx in pairs( GEs.fsin_bots ) do
                        local ped = GEs[ "bot_fsin_" .. idx ]
                        if isElement( ped ) then
                            if GEs.shoots[ ped ] then GEs.shoots[ ped ]:destroy() end
                            destroyElement( ped )
                        end
                    end

                    FadeBlink( 2.0 )
                    StartQuestCutscene( )

                    localPlayer.position = Vector3( { x = -2388.527, y = 1666.367, z = 14.086 } )
                    localPlayer.weaponSlot = 5 -- switch AK-47
                    localPlayer.frozen = false

                    GEs.run_bot = CreateAIPed( localPlayer )
                    GEs.run_bot.dimension = localPlayer:GetUniqueDimension( )
                    givePedWeapon( GEs.run_bot, 30, 1, true )

                    SetAIPedMoveByRoute( GEs.run_bot, {
                        { x = -2388.527, y = 1666.367, z = 14.086, move_type = 6, distance = 0 },
                        { x = -2403.304, y = 1636.390, z = 14.180, move_type = 6, distance = 0 }
                    }, false )

                    GEs.bot_guard_pilot = CreateAIPed( 33, Vector3( 0, 0, 0 ) )
                    GEs.bot_guard_pilot.dimension = localPlayer:GetUniqueDimension( )

                    GEs.guard = CreateAIPed( 33, Vector3( { x = -2407.451, y = 1637.547, z = 14.174 } ) )
                    GEs.guard.rotation = Vector3( 0, 0, -45 )
                    GEs.guard.dimension = localPlayer:GetUniqueDimension( )
                    givePedWeapon( GEs.guard, 30, 1, true )

                    GEs.timer_guard_anim = setTimer( function ( )
                        setPedAnimation( GEs.guard, "swat", "swt_breach_01" ,-1, false, true, true, true )
                    end, 1000, 1 )

                    local from = { -2391.7905273438, 1643.5029296875, 17.651647567749, -2405.9899902344, 1740.3975830078, -2.5921583175659, 0, 70 }
                    local to = { -2408.4416503906, 1624.0474853516, 19.386199951172, -2414.6176757813, 1718.5791015625, -12.639133453369, 0, 70 }

                    GEs.move = CameraFromTo( from, to, 5000, "InQuad" )

                    GEs.safety_process_timer = setTimer( function ( )
                        GEs.guard:destroy( )

                        triggerServerEvent( "rescue_operation_step_13", localPlayer )
                    end, 7000, 1 )

                    GEs.timer_bot_in_heli = Timer( function ( )
                        local vehicle = localPlayer:getData( "temp_vehicle_safe" )
                        warpPedIntoVehicle( GEs.bot_guard_pilot, vehicle )
                        vehicle.frozen = false
                    end, 1000, 1 )
                end,
                server = function ( )
                    local safety_helicopter = CreateTemporaryVehicle( player, 563, Vector3( { x = -2405.704, y = 1637.197, z = 15.023 } ), Vector3( 0, 0, 160 ) )
                    player:SetPrivateData( "temp_vehicle_safe", safety_helicopter )
                    safety_helicopter:SetColor( 0, 0, 0 )
                    safety_helicopter.frozen = true

                    player:GiveWeapon( 30, 10, false, true )

                    GEs.timer_warp_2 = setTimer( function ( )
                        warpPedIntoVehicle( player, safety_helicopter, 1 )
                    end, 7000, 1 )
                end,
            },

            event_end_name = "rescue_operation_step_13",
        },

        {
            name = '...',

            Setup = {
                client = function( )
                    FadeBlink( 2.0 )

                    setCameraMatrix( -2397.9814453125, 1622.3839111328, 21.631399154663, -2398.427734375, 1623.2340087891, 21.351810455322 )

                    local vehicle = localPlayer:getData( "temp_vehicle_safe" )

                    GEs.heli_up_2 = setTimer( function ( )
                        vehicle.velocity = Vector3( 0, 0, vehicle.velocity.z + 0.012 )
                    end, 50, 50 )

                    GEs.heli_1 = setTimer( function ( )
                        vehicle.velocity = Vector3( 0, 0, 0 )
                        vehicle.frozen = true
                        triggerServerEvent( "rescue_operation_step_14", localPlayer )
                    end, 2500, 1 )
                end,
            },

            event_end_name = "rescue_operation_step_14",
        },

        {
            name = '...', -- roman's scene 'to home'

            Setup = {
                client = function( )
                    FindQuestNPC( "roman_near_house" ).ped.dimension = 0

                    setCameraMatrix( 587.25921630859, -493.70791625977, 28.736486434937, 500.82952880859, -538.21575927734, 5.306613445282 )

                    fadeCamera( false, 0 )
                    GEs.fade_timer = Timer( function ( )
                        triggerServerEvent( "rescue_operation_step_15", localPlayer )
                        FadeBlink( 2.0 )
                    end, 3000, 1 )
                end,
                server = function ( player )
                    local vehicle = player:getData( "temp_vehicle" )

                    if isElement( vehicle ) then
                        vehicle:destroy( )
                    end

                    local romans_vehicle = CreateTemporaryVehicle( player, 6539, Vector3( 477.168, -507.185, 20.381 ), Vector3( 0, 0, -90 ) )
                    player:SetPrivateData( "temp_romans_vehicle", romans_vehicle)
                    romans_vehicle:SetNumberPlate( "1:м421кр178" )
                    romans_vehicle:SetColor( 0, 0, 0 )
                    warpPedIntoVehicle( player, romans_vehicle, 1 )
                end,
            },

            event_end_name = "rescue_operation_step_15",
        },

        {
            name = '...', -- roman's scene 'to home'

            Setup = {
                client = function( )
                    -- roman's analog
                    GEs.roman_bot = CreateAIPed( 6733, Vector3( 477.168, -507.185, 20.381 ) )
                    local vehicle = localPlayer:getData( "temp_romans_vehicle" )
                    warpPedIntoVehicle( GEs.roman_bot, vehicle )

                    SetAIPedMoveByRoute( GEs.roman_bot, {
                        { x = 477, y = -507.185, z = 20.381, speed_limit = 30, distance = 5 },
                        { x = 549, y = -507.185, z = 20.381, speed_limit = 30, distance = 5 },
                    }, false, function ( )
                        triggerServerEvent( "rescue_operation_step_16", localPlayer )
                    end )
                end,
            },

            CleanUp = {
                client = function( data, failed )
                    FinishQuestCutscene( )
                end,
            },

            event_end_name = "rescue_operation_step_16",
        },

        {
            name = 'Зайдите в дом Романа',

            Setup = {
                client = function( )
                    GEs.finish_timer = setTimer( function ( )
                        removePedFromVehicle( GEs.roman_bot )
                        GEs.roman_bot.position = Vector3( 550.908, -509.836, 20.810 )
                        SetAIPedMoveByRoute( GEs.roman_bot, {
                            { x = 550.908, y = -509.836, z = 20.810, move_type = 6, distance = 0 },
                            { x = 559.256, y = -517.715, z = 21.208, move_type = 6, distance = 0 }
                        }, false, function()
                            GEs.roman_bot.interior = 1
                        end )

                        setPedControlState( localPlayer, "enter_exit", true )
                    end, 1500, 1 )

                    CreateQuestPoint( Vector3( 559.19, -521.12, 21.71 ), function( )
                        CEs.marker.destroy( )

                        localPlayer:Teleport( Vector3( -110.014, -1778.811, 3936.981 ), nil, 1 )
                        localPlayer.rotation = Vector3( 0, 0, -90 )

                        fadeCamera( false, 0 )
                        GEs.fade_timer = Timer( function ( )
                            FadeBlink( 2.0 )
                            triggerServerEvent( "rescue_operation_step_17", localPlayer )
                        end, 2000, 1 )
                    end, _, 1 )
                end,
            },

            event_end_name = "rescue_operation_step_17",
        },

        {
            name = 'Поговорите с Романом',

            Setup = {
                client = function( )
                    FindQuestNPC( "roman_in_house" ).ped.interior = 1
                    CreateMarkerToCutsceneNPC( {
                        id = "roman_in_house",
                        radius = 1,
                        local_dimension = true,
                        dialog = QUEST_CONF.dialogs.finish,
                        callback = function( )
                            CEs.marker.destroy( )
                            CEs.dialog:next( )

                            StartPedTalk( FindQuestNPC( "roman_in_house" ).ped, nil, true )

                            setTimerDialog( function( )
                                CEs.dialog:next( )
                                setTimerDialog( function( )
                                    triggerServerEvent( "rescue_operation_step_18", localPlayer )
                                end, 9000, 1 )
                            end, 5500, 1 )
                        end
                    } )
                end,
            },

            CleanUp = {
                client = function( )
                    local ped = FindQuestNPC( "roman_in_house" ).ped
                    ped.interior = 2

                    StopPedTalk( ped )
                    FinishQuestCutscene( )
                end,
                server = function( player )
                    player:Teleport( Vector3( 559.19, -521.12, 20.77 ), nil, 0 )
                end,
            },

            event_end_name = "rescue_operation_step_18",
        },
    },

    GiveReward = function( player )
        player:SituationalPhoneNotification(
                { title = "Анжела", msg = "Привет, у меня есть подработка для тебя, приезжай, расскажу детали. Журнал квестов F2" },
                {
                    condition = function( self, player, data, config )
                        local current_quest = player:getData( "current_quest" )
                        if current_quest and current_quest.id == "fast_delivery" then
                            return "cancel"
                        end
                        return getRealTime( ).timestamp - self.ts >= 60
                    end,
                    save_offline = true,
                }
        )

        triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
            rewards = QUEST_CONF.rewards
        } )
    end,

    rewards = QUEST_CONF.rewards,
    no_show_rewards = true,
}