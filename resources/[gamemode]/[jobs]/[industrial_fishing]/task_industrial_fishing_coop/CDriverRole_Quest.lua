local driver_keys = { "h", "k", }
local driver_controls = { "accelerate", "brake_reverse", }

function CreateDriverActionController()
    if GEs.action_controller then 
        return GEs.action_controller, false
    end

    GEs.action_controller = {
        init = function( self )
            DisableJobKeys( true )
            toggleControl( "enter_exit", false )
        end,
        toggle_controls = function( self, state )
            if state then ChangeBindsState( driver_keys, false, DriverKeyHandler ) end
            ChangeBindsState( driver_keys, state, DriverKeyHandler )
            ShowInfoControls( state )
        end,
        destroy = function( self )
            ChangeBindsState( driver_keys, false, DriverKeyHandler )
            
            DisableJobKeys( false )
            toggleControl( "enter_exit", true )

            setmetatable( self, nil )
        end,
    }

    GEs.action_controller:init()

    return GEs.action_controller, true
end

function DriverKeyHandler( key, state )
    local vehicle = localPlayer.vehicle
    if not vehicle or CEs.is_repair_boat_game_active then return end
    
    if key == "h" and state == "down" then
        if isElement( GEs.anchor_sound ) then return end

        if vehicle.engineState then
            localPlayer:ShowError( "Заглуши двигатель" )
            return
        elseif (Vector3( getElementVelocity( vehicle ) ) * 111.84681456).length > 5 then
            localPlayer:ShowError( "Судно находится в движении" )
            return
        end

        GEs.anchor_sound = playSound( "sfx/anchor.ogg" )
        GEs.anchor_sound.volume = 0.3
        triggerServerEvent( "onServerChangeStateAnchor", resourceRoot )
    elseif key == "k" and state == "down" then
        if not GEs.anchor_step_complete then return end
        
        if vehicle.frozen then
            localPlayer:ShowError( "Подними якорь" )
            return
        end
        triggerServerEvent( "onServerChangeStateEngine", resourceRoot )
    end
end

function OnStartDriverEngineGame( lobby_data )
    CEs.minigame = {}
    CEs.minigame[ 1 ] = function()
        CEs.game = PressKeyHandler( {
            key = "k",
            key_handler = function()
                if math.random( 1, 100 ) >= 95 then
                    CEs.minigame[ 2 ]( )
                else
                    triggerServerEvent( lobby_data.end_step, localPlayer )
                end
            end,
        } )  
    end

    CEs.minigame[ 2 ] = function(  )
        CEs.game = ibInfoPressKey( {
            do_text = "Удерживай",
            text = "чтобы прогреть двигатель",
            key = "lalt",
            hold = true,
            black_bg = 0x00000000,
            key_handler = function( )
                DriverKeyHandler( "k", "down" )
                triggerServerEvent( lobby_data.end_step, localPlayer )
            end,
        } )
    end

    CEs.minigame[ 1 ]( )
end

function OnStartDriverServiceGame( lobby_data )
    CEs.cur_fuel = lobby_data.job_vehicle:GetFuel()
    CEs.max_fuel = lobby_data.job_vehicle:GetMaxFuel()

    CEs.click_count = 0
    CEs.click_refull_count = 10
    CEs.fuel_step = (CEs.max_fuel - CEs.cur_fuel) / CEs.click_refull_count
    
    CEs.minigame = {}
    
    CEs.minigame[ 1 ] = function()
        CEs.game = ibInfoPressKeyProgress( {
            do_text = "Нажимай",
            text = "чтобы заправить корабль",
            key = "lalt",
            click_count = CEs.click_refull_count,
            black_bg = 0x00000000,
            click_handler = function( )
                CEs.click_count = CEs.click_count + 1
                CEs.cur_fuel = CEs.cur_fuel + CEs.fuel_step
                lobby_data.job_vehicle:SetFuel( CEs.cur_fuel )
            end,
            end_handler = CEs.minigame[ 2 ],
        } )
    end

    CEs.minigame[ 2 ] = function()
        CEs.game = ibInfoPressKey( {
            do_text = "Удерживай",
            text = "чтобы диагностировать корабль",
            key = "mouse1",
            hold = true,
            hold_time = 5000,
            black_bg = 0x80495f76,
            key_handler = function()
                CEs._next_minigame_step_tmr = setTimer( CEs.minigame[ 3 ], 5000, 1 ) 
            end,
        } )
    end

    CEs.minigame[ 3 ] = function()
        CEs.game = ibInfoPressKey( {
            do_text = "Нажми",
            text = "чтобы включить насосы",
            key = "mouse2",
            key_text = "ПКМ",
            black_bg = 0x80495f76,
            key_handler = CEs.minigame[ 4 ],
        } )
    end

    CEs.minigame[ 4 ] = function()
        CEs.game = ibInfoPressKey( {
            do_text = "Нажми",
            text = "чтобы продуть корпус",
            key = "h",
            key_text = "H",
            black_bg = 0x80495f76,
            key_handler = CEs.minigame[ 5 ],
        } )
    end

    CEs.minigame[ 5 ] = function()
        CEs.game = ibInfoPressKey( {
            do_text = "Нажми",
            text = "чтобы выключить насосы",
            key = "mouse2",
            key_text = "ПКМ",
            black_bg = 0x80495f76,
            key_handler = CEs.minigame[ 6 ],
        } )
    end

    CEs.minigame[ 6 ] = function()
        CEs.game = ibInfoPressKey( {
            do_text = "Нажми",
            text = "чтобы закончить заправку",
            key = "lalt",
            key_text = "ALT",
            black_bg = 0x80495f76,
            key_handler = function( )
                CEs.is_repair_boat_game_active = false
                triggerServerEvent( lobby_data.end_step, localPlayer )
            end,
        } )
    end

    CEs.minigame[ 1 ]( )
    CEs.is_repair_boat_game_active = true
end
