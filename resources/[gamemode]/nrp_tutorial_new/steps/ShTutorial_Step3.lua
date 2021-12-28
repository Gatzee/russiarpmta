local id = "go_home"
local function GetSelf( ) return TUTORIAL_STEPS[ id ] end

TUTORIAL_STEPS[ id ] = {
    entrypoint = function( self )
        BlockAllKeys( { "enter", "f" } )
        fadeCamera( false, 0 )

        triggerEvent( "ShowUIInventory", root, false )

        setElementPosition( localPlayer, 1788.973, -627.175+860, 60.809 )
        setElementRotation( localPlayer, 0, 0, 284 )

        setWeather( 0 )
        setTime( 21, 0 )

        setTimer( function( )
            setCameraTarget( localPlayer )
            fadeCamera( true, 1.0 )
        end, 50, 1, localPlayer )

        self.tip_enter = CreateTip( "enter" )

        local timer = setTimer( function( ) SetTipImportant( self.tip_enter ) end, 10000, 1 )
        local vehicle = getElementData( localPlayer, "tutorial_vehicle" )

        local t = { }
        t.CheckEnter = function( player )
            if player ~= localPlayer then return end
            BlockAllKeys( )

            DestroyTip( self.tip_enter )

            removeEventHandler( "onClientVehicleStartEnter", vehicle, t.CheckEnter )
            addEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.CheckFinishEnter )
        end
        addEventHandler( "onClientVehicleStartEnter", vehicle, t.CheckEnter )

        t.CheckFinishEnter = function( attempted_vehicle )
            if attempted_vehicle ~= vehicle then return end
            removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.CheckFinishEnter )

            -- Шаг 16 - Посадка в гелик после катсцены
            triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 15, getRealTimestamp( ) - TUTORIAL_START_TICK )

            setTimer( self.client_start_navigation_to_home, 2000, 1 )
        end
    end,

    client_start_navigation_to_home = function( )
        local self = GetSelf( )
        BACKGROUND_SOUND = playSound( "sfx/ambient.wav" )
        BACKGROUND_SOUND.volume = 0.3
        localPlayer:setData( "block_radio", true, false )

        -- Всё что нужно для базового движения
        BlockAllKeys( { "w", "a", "s", "d", "space", "f11", "m", "tab", "escape" } )

        self.tip_sleep = CreateTip( "sleep" )
        self.tip_sleep_timer = setTimer( DestroyTip, 15000, 1, self.tip_sleep )

        self.direction_marker = DirectToPoint( {
            position = { x = 310.093, y = -1404.068, z = 23.528 },
        } )
        
        self.client_start_wait_for_cutscene( )
    end,

    client_start_wait_for_cutscene = function( )
        local self = GetSelf( )

        local tick = getTickCount( )

        local last_pos = localPlayer.vehicle.position
        local total_dist = 0
        
        self.tick_timer = setTimer( function( )
            total_dist = total_dist + ( localPlayer.vehicle.position - last_pos ).length
            last_pos = localPlayer.vehicle.position

            iprint( math.floor( ( getTickCount( ) - tick ) / 1000 ), total_dist, total_dist )

            if getTickCount( ) - tick >= 70 * 1000 or total_dist >= 780 then
                DestroyTableElements( { self.direction_marker, self.tip_sleep, self.tip_sleep_timer, self.tick_timer } )
                fadeCamera( false, 2.0 )

                setTimer( function( )
                    self.direction_marker:destroy( )
                    CallServerStepFunction( id, "server_destroy_player_vehicle" )
                end, 3000, 1 )
            end

        end, 1000, 0 )
    end,

    server_destroy_player_vehicle = function( self, player )
        DestroyTutorialVehicle( player )

        player.position = player.position + Vector3( 0, 0, 30 )
        player.frozen = true

        CallClientStepFunction( player, id, "client_finish_destroy" )
    end,

    client_finish_destroy = function( self )
        setTimer( StartTutorialStep, 100, 1, "hospital_scene", false )
    end,
}