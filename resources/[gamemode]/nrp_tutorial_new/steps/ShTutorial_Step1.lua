local id = "drive_to_carsell"
local function GetSelf( ) return TUTORIAL_STEPS[ id ] end

TUTORIAL_STEPS[ id ] = {
    entrypoint = function( self, is_blend )
        addEventHandler( "onClientPlayerDamage", localPlayer, onClientPlayerDamage_handler )

        BlockAllKeys( )

        DisableHUD( true )

        setTime( 7, 30 )
        setWeather( 5 )

        setTimer( function( )
            self.weeks_tip = CreateTip( "onceuponatime" )
            SetTipImportant( self.weeks_tip )

            setTimer( function( )
                DestroyTip( self.weeks_tip )
                setTimer( function( )
                    CallServerStepFunction( id, "server_create_vehicle" )
                end, 1000, 1 )
            end, 5000, 1 )
            
        end, 1000, 1 )
    end,

    server_create_vehicle = function( self, player )
        player.dimension = player:GetUniqueDimension( )
        CreateTutorialVehicleForPlayer( player, Vector3( 2027.347534179688, -353.8124694824219+860, 60.62541961669922 ), Vector3( 0, 0, 183 ) )
        CallClientStepFunction( player, id, "client_start_action" )
    end,

    client_start_action = function( self )
        setCameraTarget( localPlayer )
        fadeCamera( true, 3 )

        DisableHUD( false )

        self:client_start_route_vehicle( )
    end,

    client_start_route_vehicle = function( self )
        self.bot_vehicle, self.bot_record_id = exports.nrp_vehicle_record:PlayRecord( "tutorial_basedrive", 0, localPlayer.dimension + 1 )

        addEventHandler( "onClientRender", root, self.client_render_follow_route )
        self.start_render_route = getTickCount( )

        setTimer( self.client_start_waiting_for_keys, 3000, 1 )
    end,

    client_start_waiting_for_keys = function( )
        local self = GetSelf( )

        self.tip_wasd = CreateTip( "wasd" )

        BlockAllKeys( { "w", "a", "s", "d" } )
        addEventHandler( "onClientKey", root, self.client_handle_keys, true, "low" )

        -- Шаг 3 - Подсказка о WASD
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 2, getRealTimestamp( ) - TUTORIAL_START_TICK )
    end,

    client_handle_keys = function( button, press )
        AddRestoreVehiclePostion()

        local buttons = {
            w = true,
            a = true,
            s = true,
            d = true,
        }

        local is_allowed_key = buttons[ string.lower( button ) ]

        local function Parse( )
            if not press then return end

            if is_allowed_key then
                local self = GetSelf( )

                self.wasd_press = ( self.wasd_press or 0 ) + 1

                if self.wasd_press >= 4 then
                    local self = GetSelf( )
                    self:client_stop_route_vehicle( )
                end
            end
        end
        
        if not is_allowed_key then
            cancelEvent( )
        end

        Parse( )
    end,

    client_render_follow_route = function( )
        local self = GetSelf( )

        if getTickCount( ) - self.start_render_route >= 7000 and getGameSpeed( ) >= 1 then
            removeEventHandler( "onClientRender", root, self.client_render_follow_route )
            setGameSpeed( 0.05 )
            SetTipImportant( self.tip_wasd )
        end

        if isElement( self.bot_vehicle ) then
            localPlayer.vehicle.rotation = Vector3( localPlayer.vehicle.rotation.x, localPlayer.vehicle.rotation.y, self.bot_vehicle.rotation.z )
            localPlayer.vehicle.velocity = self.bot_vehicle.velocity
            localPlayer.vehicle.turnVelocity = self.bot_vehicle.turnVelocity
        end
    end,
    
    client_stop_route_vehicle = function( self )
        -- Шаг 4 - Окончание подсказки о WASD
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 3, getRealTimestamp( ) - TUTORIAL_START_TICK )
        
        removeEventHandler( "onClientRender", root, self.client_render_follow_route )
        removeEventHandler( "onClientKey", root, self.client_handle_keys )
        setGameSpeed( 1 )
        DestroyTip( self.tip_wasd )
        exports.nrp_vehicle_record:StopRecord( self.bot_record_id )

        BlockAllKeys( { "w", "a", "s", "d" } )
        setTimer( self.client_ring_mobile, 2000, 1 )
    end,

    client_ring_mobile = function( self )
        local self = GetSelf( )

        -- Шаг 5 - Подсказка по СМС
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 4, getRealTimestamp( ) - TUTORIAL_START_TICK )

        self.tip_stop = CreateTip( "stop" )

        local time_start = getTickCount( )

        local t = { }
        t.timer_check_stop = setTimer( function( )
            if localPlayer.vehicle.velocity.length <= 0.05 then
                if isTimer( t.timer_check_stop ) then killTimer( t.timer_check_stop ) end
                self.client_stop_vehicle( )
            else
                if getTickCount( ) - time_start >= 4000 then
                    localPlayer.vehicle.velocity = localPlayer.vehicle.velocity / 1.2
                    localPlayer.vehicle.engineState = false
                end
            end
        end, 50, 0 )
    end,

    client_stop_vehicle = function( )
        local self = GetSelf( )

        DestroyTip( self.tip_stop )
        self.tip_phone = CreateTip( "phone" )

        localPlayer.vehicle.engineState = false

        triggerEvent( "onPhoneDirectlyOpenNotifications", localPlayer, true )
        triggerEvent( "OnClientReceivePhoneNotification", localPlayer, { title = "Бизнес", msg = "Эй, Босс, у нас новый завоз в автосалоне, приезжай принять товар! Можешь найти на карте, нажми M", is_quest_msg = true } )

        BlockAllKeys( { "p" } )
        bindKey( "p", "down", self.client_open_mobile )
    end,

    client_open_mobile = function( )
        local self = GetSelf( )

        unbindKey( "p", "down", self.client_open_mobile )

        -- Шаг 6 - Открытие телефона
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 5, getRealTimestamp( ) - TUTORIAL_START_TICK )

        triggerEvent( "onPhoneDirectlyOpenNotifications", localPlayer, false )
        DestroyTip( self.tip_phone )

        BlockAllKeys( { "f11", "m" } )

        bindKey( "f11", "down", self.client_open_map )
        bindKey( "m", "down", self.client_open_map )

        -- Шаг 7 - Подсказка про карту
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 6, getRealTimestamp( ) - TUTORIAL_START_TICK )

        self.timer_show_map = setTimer( function( )
            self.tip_map = CreateTip( "showmap" )
            SetTipImportant( self.tip_map )
        end, 5000, 1 )
    end,

    client_open_map = function( )
        local self = GetSelf( )

        unbindKey( "f11", "down", self.client_open_map )
        unbindKey( "m", "down", self.client_open_map )

        -- Шаг 8 - Открытие карты
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 7, getRealTimestamp( ) - TUTORIAL_START_TICK )

        self.direction_marker = DirectToPoint( {
            position = { x = 1800.127, y = -624.057, z = 60.699 },
            callback = self.client_start_exit,
        } )

        triggerEvent( "SetHUDMapState", localPlayer, true, true )
        triggerEvent( "SetHUDMapFollowSelf", localPlayer )

        if isTimer( self.timer_show_map ) then killTimer( self.timer_show_map ) end
        DestroyTip( self.tip_map )

        triggerEvent( "ShowPhoneUI", localPlayer, false )
        triggerEvent( "SetMapIgnoreKeypress", localPlayer, true )

        BlockAllKeys( { "f11", "m", "n" } )
        self.tip_map = CreateTip( "map" ):ibData( "priority", 100 ):ibDeepSet( "disabled", true )
        self.timer_close_map = setTimer( function( )
            SetTipImportant( self.tip_map )
        end, 15000, 1 )

        bindKey( "f11", "down", self.client_close_map )
        bindKey( "m", "down", self.client_close_map )

        addEventHandler( "onClientKey", root, onPlayerKey )
    end,

    client_close_map = function( )
        local self = GetSelf( )

        unbindKey( "f11", "down", self.client_close_map )
        unbindKey( "m", "down", self.client_close_map )

        removeEventHandler( "onClientKey", root, onPlayerKey )

        -- Шаг 9 - Закрытие карты
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 8, getRealTimestamp( ) - TUTORIAL_START_TICK )

        BlockAllKeys( )
        localPlayer.vehicle.frozen = true

        if isTimer( self.timer_close_map ) then killTimer( self.timer_close_map ) end
        DestroyTip( self.tip_map )

        triggerEvent( "SetHUDMapState", localPlayer, false )
        triggerEvent( "SetMapIgnoreKeypress", localPlayer, false )

        -- Задержка после нажатия М
        setTimer( function( )
            -- Затухание
            fadeCamera( false, 1 )
            setTimer( function( )
                DisableHUD( true )
                -- Камера на салон
                setCameraMatrix( 1809.5186767578, -596.42700195313+860, 68.569602966309, 1763.6663818359, -682.28594970703+860, 46.722808837891 )
                MoveCameraToLocalPlayer( 6000, self.client_start_radial_suggestion )
                fadeCamera( true, 1.0 )
            end, 2000, 1 )
        end, 1000, 1 )
    end,

    client_start_radial_suggestion = function( )
        local self = GetSelf( )

        -- Шаг 10 - Показ подсказки про радиалку
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 9, getRealTimestamp( ) - TUTORIAL_START_TICK )

        DisableHUD( false )

        BlockAllKeys( { "tab" } )

        setCameraTarget( localPlayer )

        self.tip_radial = CreateTip( "radial" )
        SetTipImportant( self.tip_radial )
        
        local fn = function( key, state )
            self.tip_radial:ibAlphaTo( state == "down" and 0 or 255 , 200 )
        end
        bindKey( "tab", "both", fn )
        self.tip_radial:ibOnDestroy( function( )
            unbindKey( "tab", "both", fn )
        end )

        CallServerStepFunction( id, "server_start_wait_for_engine" )
    end,

    server_start_wait_for_engine = function( self, player )
        local t = { }
        t.CheckEngine = function( vehicle )
            if vehicle.engineState then
                removeEventHandler( "PlayerAction_VehicleToggleEngine", player, t.CheckEngine )
                CallClientStepFunction( player, id, "client_start_navigation" )
            end
        end
        addEventHandler( "PlayerAction_VehicleToggleEngine", player, t.CheckEngine )
    end,

    client_start_navigation = function( )
        local self = GetSelf( )

        -- Шаг 11 - Завершение про радиалку
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 10, getRealTimestamp( ) - TUTORIAL_START_TICK )

        self.tip_radial:destroy( )
        BlockAllKeys( { "w", "a", "s", "d", "space" } )
        localPlayer.vehicle.frozen = false

        self.skip_timer = setTimer( function( )
            localPlayer.vehicle.position = Vector3( 1794.201, -602.569, 60.564 )
            localPlayer.vehicle.rotation = Vector3( 0, 0, 195 )
            setCameraTarget( localPlayer )
            localPlayer:ShowInfo( "Припаркуйся на маркере для продолжения" )
        end, 90 * 1000, 0 )
    end,

    client_start_exit = function( )
        removeRestoreVehiclePostion()
        
        local self = GetSelf( )
        self.direction_marker:destroy( )

        -- Шаг 12 - Подсказка про выход из машины
        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 11, getRealTimestamp( ) - TUTORIAL_START_TICK )

        if isTimer( self.skip_timer ) then killTimer( self.skip_timer ) end

        BlockAllKeys( { "f", "enter" } )
        localPlayer.vehicle.engineState = false

        self.tip_exit = CreateTip( "exit" )

        local t = { }
        t.HandleExit = function( )
            removeEventHandler( "onClientPlayerVehicleExit", localPlayer, t.HandleExit )
            DestroyTip( self.tip_exit )

            BlockAllKeys( )
            setTimer( StartTutorialStep, 1000, 1, "talk_to_npc", false )

            -- Шаг 13 - Выход из машины
            triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 12, getRealTimestamp( ) - TUTORIAL_START_TICK )
        end
        addEventHandler( "onClientPlayerVehicleExit", localPlayer, t.HandleExit )
    end,
}

addEvent( "PlayerAction_VehicleToggleEngine", true )

function onPlayerKey( button, pressed )
    if pressed and button == "escape" then
        triggerEvent( "SetHUDMapState", localPlayer, false )
        GetSelf( ):client_close_map( )
    end
end