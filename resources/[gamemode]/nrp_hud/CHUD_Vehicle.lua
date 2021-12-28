local fonts =
{
	a_LCDNova14 = dxCreateFont( "files/a_LCDNova.ttf", 10 ),
	a_LCDNova24	= dxCreateFont( "files/a_LCDNova.ttf", 24 ),
}

local speed_position = {
    { x = 81, y = 229 },
    { x = 75, y = 187 },
    { x = 78, y = 145 },
    { x = 98, y = 106 },
    { x = 134, y = 77 },
    { x = 179, y = 68 },
    { x = 224, y = 77 },
    { x = 259, y = 106 },
    { x = 275, y = 145 },
    { x = 276, y = 187 },
    { x = 268, y = 229 },
}

local update_speedometer_step = false

HUD_CONFIGS.vehicle = {
    elements = { },
    independent = true, -- Не управлять позицией худа
    create = function( self )
        local vehicle = getPedOccupiedVehicle( localPlayer )
        local vehicle_model = vehicle.model
        local vehicle_config = VEHICLE_CONFIG[ vehicle_model ] or { }
        local is_electric = vehicle_config.is_electric
        local vehicle_type
        local variant, max_speed, step, speed_coeff, max_height
        
        local bg = ibCreateArea( 0, 0, 0, 0 )
        self.elements.bg = bg

        -- Фон топлива
        self.elements.fuel_line_texture = dxCreateTexture( "img/circle_line.png" )
        self.elements.fuel_line = ibCreateImage( _SCREEN_X - 507, _SCREEN_Y - 139, 139, 139, self.elements.fuel_line_texture, bg, 0x00FFFF )

        self.elements.fuel_bg_texture = dxCreateTexture( "img/circle_bg.png" )
        self.elements.fuel_bg = ibCreateImage( _SCREEN_X - 507, _SCREEN_Y - 147, 139, 154, self.elements.fuel_bg_texture, bg, 0xFFFFFFFF )

        -- Топливо
        self.elements.fuel_shader = dxCreateShader( "fx/circle_radial.fx" )
        dxSetShaderValue( self.elements.fuel_shader, "tex", self.elements.fuel_line_texture )
        self.elements.fuel = ibCreateImage( 0, 0, 139, 139, self.elements.fuel_shader, self.elements.fuel_line )

        -- Иконки
        self.elements.icon_fuel = ibCreateImage( _SCREEN_X - 456, _SCREEN_Y - 54, 39, 44, is_electric and "img/fuel_icon_e.png" or "img/fuel_icon.png", bg )

        if vehicle_config.is_boat or vehicle_config.is_airplane then
            self.elements.icon_fuel:ibData( "px", _SCREEN_X - ( vehicle_config.is_boat and 218 or 262 ) )
            self.elements.fuel_line:ibData( "px", _SCREEN_X - ( vehicle_config.is_boat and 270 or 316 ) )
            self.elements.fuel_bg:ibData( "px", _SCREEN_X - ( vehicle_config.is_boat and 270 or 316 ) )

            -- Иконки
            self.elements.icon_engine = ibCreateImage( _SCREEN_X - ( vehicle_config.is_boat and 94 or 138 ), _SCREEN_Y - 53, 45, 44, "img/engine_icon_rot.png", bg )

            -- Фон жизней
            self.elements.health_texture = dxCreateTexture( "img/circle_line.png" )
            self.elements.bg_health = ibCreateImage( _SCREEN_X - ( vehicle_config.is_boat and 142 or 188 ), _SCREEN_Y - 148, 139, 139, self.elements.health_texture, bg, 0x00FFFF )

            self.elements.health_bg_texture = dxCreateTexture( "img/circle_bg.png" )
            self.elements.health_bg = ibCreateImage( _SCREEN_X - ( vehicle_config.is_boat and 142 or 188 ), _SCREEN_Y - 156, 139, 154, self.elements.health_bg_texture, bg, 0xFFFFFFFF )

            -- Жизни
            self.elements.health_shader = dxCreateShader( "fx/circle_radial.fx" )
            dxSetShaderValue( self.elements.health_shader, "tex", self.elements.health_texture )
            self.elements.health = ibCreateImage( 0, 0, 139, 139, self.elements.health_shader, self.elements.bg_health )

            -- Высота
            if vehicle_config.is_airplane then
                max_height = getAircraftMaxHeight( vehicle )
                self.elements.height_texture = dxCreateTexture( "img/height_bg.png" )
                self.elements.bg_height = ibCreateImage( _SCREEN_X - 55, _SCREEN_Y - 176, 44, 173, self.elements.height_texture, bg, 0xFFFFFFFF )

                self.elements.height_line = ibCreateImage( 13, 0, 18, 1, "img/height_line.png", self.elements.bg_height )
                self.elements.height = ibCreateLabel( 23, 6, 0, 0, "0", self.elements.bg_height, 0xffffffff, _, _, "center", "center", fonts.oxaniumbold_10 )
            end

        elseif vehicle_model == 432 then
            self.elements.icon_fuel:ibData( "px", _SCREEN_X - ( vehicle_config.is_boat and 218 or 262 ) )
            self.elements.fuel_line:ibData( "px", _SCREEN_X - ( vehicle_config.is_boat and 270 or 316 ) )
            self.elements.fuel_bg:ibData( "px", _SCREEN_X - ( vehicle_config.is_boat and 270 or 316 ) )

            -- Иконки
            self.elements.icon_engine = ibCreateImage( _SCREEN_X - ( vehicle_config.is_boat and 94 or 138 ), _SCREEN_Y - 53, 45, 44, "img/engine_icon_rot.png", bg )

            -- Фон жизней
            self.elements.health_texture = dxCreateTexture( "img/circle_line.png" )
            self.elements.bg_health = ibCreateImage( _SCREEN_X - ( vehicle_config.is_boat and 142 or 188 ), _SCREEN_Y - 148, 139, 139, self.elements.health_texture, bg, 0x00FFFF )

            self.elements.health_bg_texture = dxCreateTexture( "img/circle_bg.png" )
            self.elements.health_bg = ibCreateImage( _SCREEN_X - ( vehicle_config.is_boat and 142 or 188 ), _SCREEN_Y - 156, 139, 154, self.elements.health_bg_texture, bg, 0xFFFFFFFF )

            -- Жизни
            self.elements.health_shader = dxCreateShader( "fx/circle_radial.fx" )
            dxSetShaderValue( self.elements.health_shader, "tex", self.elements.health_texture )
            self.elements.health = ibCreateImage( 0, 0, 139, 139, self.elements.health_shader, self.elements.bg_health )
        else
            vehicle_type = "car"

            -- Фон жизней
            self.elements.health_texture = dxCreateTexture( "img/speed_engine.png" )
            self.elements.bg_health = ibCreateImage( _SCREEN_X - 408, _SCREEN_Y - 267, 390, 390, self.elements.health_texture, bg, 0x00FFFFFF )

            -- Жизни машины
            self.elements.health_shader = dxCreateShader( "fx/circle.fx" )
            dxSetShaderValue( self.elements.health_shader, "tex", self.elements.health_texture )
            dxSetShaderValue( self.elements.health_shader, "angle", -1 )
            self.elements.health = ibCreateImage( _SCREEN_X - 408, _SCREEN_Y - 267, 390, 390, self.elements.health_shader, bg )
            
            -- Иконки
            self.elements.icon_engine = ibCreateImage( _SCREEN_X - 75, _SCREEN_Y - 172, 29, 51, "img/engine_icon.png", bg )

            -- Поворотники
            self.elements.signal_outline_l = ibCreateImage( _SCREEN_X - 224, _SCREEN_Y - 212, 39, 39, "img/signal_outline.png", bg ):ibData( "color", 0x55ffffff )
            self.elements.signal_outline_r = ibCreateImage( _SCREEN_X - 261, _SCREEN_Y - 212, 39, 39, "img/signal_outline.png", bg ):ibBatchData( { rotation = 180, color = 0x55ffffff } )
            self.elements.signal_l = ibCreateImage( 0, 0, 39, 39, "img/signal.png", self.elements.signal_outline_l ):ibData( "alpha", 0 )
            self.elements.signal_r = ibCreateImage( 0, 0, 39, 39, "img/signal.png", self.elements.signal_outline_r ):ibBatchData( { rotation = 180, alpha = 0 } )
            
            -- Круиз
            local cruise_state = localPlayer:getData( "cruise_state" )
            self.elements.icon_cruise_disabled = ibCreateImage( _SCREEN_X - 328, _SCREEN_Y - 88, 178, 84, "img/cruise_disabled.png", bg ):ibData("alpha", cruise_state and 0 or 255 )
            self.elements.icon_cruise_enabled = ibCreateImage( _SCREEN_X - 328, _SCREEN_Y - 88, 178, 84, "img/cruise_enabled.png", bg ):ibData("alpha", cruise_state and 255 or 0 )

            self.elements.speed_bg = ibCreateImage( _SCREEN_X - 401, _SCREEN_Y - 313, 408, 311, "img/speed_bg.png", bg, 0xFFFFFFFF )

            -- Скорость
            for i = 1, 3 do
                local lbl = ibCreateLabel( _SCREEN_X - 240 + ( i - 1 ) * 27, _SCREEN_Y - 44, 0, 0, "0", bg, 0xffffffff, _, _, "right", "center", fonts.a_LCDNova24 )
                self.elements[ "lbl_symbol_" .. i ] = lbl
            end

            self.elements.speed_line = ibCreateImage( _SCREEN_X - 361, _SCREEN_Y - 191, 193, 109, "img/speed_line.png",  bg )
                :ibData( "rotation_offset_x", 42 )
                :ibData( "rotation_offset_y", 0 )

            self.elements.gear = ibCreateLabel( _SCREEN_X - 216, _SCREEN_Y - 94, 0, 0, "0", bg, 0xffffffff, _, _, "right", "center", ibFonts.oxaniumbold_22 )

            -- Пробег
            self.elements.lbl_mileage = ibCreateLabel( _SCREEN_X - 145, _SCREEN_Y - 31, 0, 0, "км/ч", bg, 0xFFFFFFFF, _, _, "left", "center", fonts.a_LCDNova14 )
        end

        self.elements.fn_render = function( )
            local vehicle = getPedOccupiedVehicle( localPlayer )
            
            if not vehicle or vehicle.occupants[ 0 ] ~= localPlayer then
                RemoveHUDBlock( "vehicle" )
                localPlayer:setData( "vehicle_max_speed", false, false )
                return
            end

            local max_fuel, fuel = vehicle:GetMaxFuel( ), vehicle:GetFuel( )            

            local fuel_percent = fuel > 10 and ( fuel + 1 ) / max_fuel or fuel / max_fuel
            dxSetShaderValue( self.elements.fuel_shader, "progress", fuel_percent )

            local fuel_color = fuel_percent > 0.17 and { 255, 255, 255, 255 } or { 255, 50, 65, 255 }
            dxSetShaderValue( self.elements.fuel_shader, "rgba", fuel_color )

            local fuel_icon_color = fuel_percent > 0.17 and 0xffffffff or 0xffff3241
            self.elements.icon_fuel:ibData( "color", fuel_icon_color )

            local health_color = vehicle.health <= 370 and { 255, 50, 65, 255 } or { 255, 255, 255, 255 }
            dxSetShaderValue( self.elements.health_shader, "rgba", health_color )

            local health_icon_color = vehicle.health <= 370 and 0xffff3241 or 0xffffffff
            self.elements.icon_engine:ibData( "color", health_icon_color )

            if vehicle_config.is_airplane then
                local height = math.round( vehicle.position.z - getGroundPosition( vehicle.position ) )
                self.elements.height_line:ibData( "py", math.max( 13, 144 - ( height * 131 / max_height ) ) )
                self.elements.height:ibData( "text", height )
            end

            if vehicle_type == "car" then
                local max_speed = localPlayer:getData( "vehicle_max_speed" ) or 0
                local step = math.ceil( max_speed / 100 ) * 10
                local speed_coeff = 23.8 / step

                if max_speed then
                    CreateSpeedometerStep( self, step, update_speedometer_step )
                end

                local mileage = string.format( "%06d", math.min( math.floor( vehicle:GetMileage( ) ), 999999 ) )
                self.elements.lbl_mileage:ibData( "text", mileage )

                local speed_real = math.floor( vehicle:getVelocity( ).length * 180 )
                local speed = string.format( "%03d", speed_real )

                local i = 1
                local alpha = 50
                for letter in string.gmatch( speed, "." ) do
                    alpha = math.max( alpha, tonumber( letter ) == 0 and 50 or 255 )
                    self.elements[ "lbl_symbol_" .. i ]:ibBatchData( { text = letter, alpha = alpha } )
                    i = i + 1
                end

                local signal = getElementData( vehicle, "signals" ) or 0
                local is_signal_both = signal == 3
                local alpha = math.abs( math.sin( getTickCount( ) / 250 ) ) * 255
                self.elements.signal_l:ibData( "alpha", ( signal == 2 or is_signal_both ) and alpha or 0 )
                self.elements.signal_r:ibData( "alpha", ( signal == 1 or is_signal_both ) and alpha or 0 )

                local gear = vehicle:getData( "custom_gear" ) or getVehicleCurrentGear( vehicle )
                self.elements.gear:ibBatchData( { text = speed == 0 and "N" or gear == 0 and "R" or vehicle.health <= 360 and "1" or gear } )

                self.elements.speed_line:ibData( "rotation", math.min( 208, math.round( speed_real * speed_coeff - 30, 1 ) ) )

                local health_coeff = 0.5

                if vehicle.health < 400 then
                    health_coeff = 0.6
                elseif vehicle.health < 500 then
                    health_coeff = 0.55
                end

                local health_percent = health_coeff + ( 0.5 * ( 1 - ( vehicle.health - 300 ) / 700 ) )
                dxSetShaderValue( self.elements.health_shader, "dg", health_percent )
            else
                local health_percent = ( vehicle.health - 300 ) / 690
                dxSetShaderValue( self.elements.health_shader, "progress", health_percent )
            end
        end
        addEventHandler( "onClientRender", root, self.elements.fn_render )

        return bg
    end,

    destroy = function( self )
        removeEventHandler( "onClientRender", root, self.elements.fn_render )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function CreateSpeedometerStep( self, step, destroy )
    if destroy then
        DestroyTableElements( self.elements.steps )
        self.elements.steps = nil
        update_speedometer_step = false
    end

    if self.elements.steps then return end

    self.elements.steps = { }
    for k, v in ipairs( speed_position ) do
        self.elements.steps[ k ] = ibCreateLabel( 0 + v.x, 0 + v.y, 0, 0, step * ( k - 1 ), self.elements.speed_bg, 0xffffffff, _, _, "center", "center", ibFonts.oxaniumbold_11 )
    end
end

function UpdateSpedometerMaxSpeed( key, old, new )
    if ( getElementType( source ) == "player" ) and ( key == "vehicle_max_speed" ) then
        update_speedometer_step = true
    end
end
addEventHandler( "onClientElementDataChange", root, UpdateSpedometerMaxSpeed )

function EnterVehicle_handler( vehicle, seat )
    if seat == 0 then
        AddHUDBlock( "vehicle" )
    end
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, EnterVehicle_handler )

function ExitVehicle_handler( vehicle, seat )
    RemoveHUDBlock( "vehicle" )
    localPlayer:setData( "vehicle_max_speed", false, false )
end
addEventHandler( "onClientPlayerVehicleExit", localPlayer, ExitVehicle_handler )

function VEHICLE_onStart( )
    local vehicle = localPlayer.vehicle
    EnterVehicle_handler( vehicle, vehicle and vehicle.occupants[ 0 ] == localPlayer and 0 )
end
addEventHandler( "onClientResourceStart", resourceRoot, VEHICLE_onStart )

function OnClientSpeedLimiterSwitched( state )

    if HUD_CONFIGS.vehicle.elements.icon_cruise_enabled then
        if state then
            HUD_CONFIGS.vehicle.elements.icon_cruise_enabled:ibData("alpha", 255)
            HUD_CONFIGS.vehicle.elements.icon_cruise_disabled:ibData("alpha", 0)
        else
            HUD_CONFIGS.vehicle.elements.icon_cruise_enabled:ibData("alpha", 0)
            HUD_CONFIGS.vehicle.elements.icon_cruise_disabled:ibData("alpha", 255)
        end
    end

    localPlayer:setData( "cruise_state", state, false )
end
addEvent("OnClientSpeedLimiterSwitched", true)
addEventHandler("OnClientSpeedLimiterSwitched", root, OnClientSpeedLimiterSwitched)