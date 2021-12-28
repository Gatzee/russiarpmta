local WHEELS_SETTINGS = {
    { key = "width" , name = "Ширина" , fn_get = "GetWheelsWidth"  , fn_set = "SetWheelsWidth"  },
    { key = "offset", name = "Вылет"  , fn_get = "GetWheelsOffset" , fn_set = "SetWheelsOffset" },
    { key = "camber", name = "Развал" , fn_get = "GetWheelsCamber" , fn_set = "SetWheelsCamber" },
}

local VEHICLE_MAX_VALUES = {
	[ 6605 ] = {
        [ 1 ] = { }, -- передние колеса
        [ 2 ] = { width = 5, offset = 5, }, -- задние
    },
    [ 438 ] = {
        [ 1 ] = { }, -- передние колеса
        [ 2 ] = { width = 20, offset = 30, }, -- задние
    },
    [ 536 ] = {
        [ 1 ] = { }, -- передние колеса
        [ 2 ] = { width = 30, offset = 30, }, -- задние
    },
    [ 6550 ] = {
        [ 1 ] = { }, -- передние колеса
        [ 2 ] = { width = 5, offset = 5, }, -- задние
    },
    [ 6596 ] = {
        [ 1 ] = { }, -- передние колеса
        [ 2 ] = { width = 5, offset = 5, }, -- задние
    },
}

function CreateWheelsEditor( )
    if isElement( UI_elements.bg_wheels ) then destroyElement( UI_elements.bg_wheels ) end
    UI_elements.bg_wheels = ibCreateImage( wSide.px, wSide.py, wSide.sx, wSide.sy, _, _, 0xf1475d75 )

    ibUseRealFonts( true )

    -- Заголовок
    UI_elements.img_wheels_header = ibCreateImage( 0, 0, wSide.sx, 56, _, UI_elements.bg_wheels, 0x2595caff )
    ibCreateLabel( 20, 0, 0, 50, "Изменение колес", UI_elements.img_wheels_header ):ibBatchData( { align_y = "center", font = ibFonts.bold_16 } )

    UI_elements.wheels_rt, UI_elements.wheels_sc = ibCreateScrollpane( 0, 56, 340, wSide.sy - 56, UI_elements.bg_wheels, {
        scroll_px = -15,
        bg_sx = 0,
        handle_sy = 40,
        handle_sx = 10,
        handle_texture = "img/scroll.png",
        handle_upper_limit = -40 - 20,
        handle_lower_limit = 20,
    } )

    for i, setting in pairs( WHEELS_SETTINGS ) do
        setting.values = { UI_elements.vehicle[ setting.fn_get ]( UI_elements.vehicle ) }
    end

    local function is_any_value_changed( )
        for i, setting in pairs( WHEELS_SETTINGS ) do
            if not table.compare( setting.values, { DATA.vehicle[ setting.fn_get ]( DATA.vehicle ) } ) then
                return true
            end
        end
        return false
    end

    function CreateSliderItem( item, py )
        ibCreateImage( 0, py, wSide.sx, 44, _, UI_elements.wheels_rt, 0xFF5a7189 )
        ibCreateImage( 0, py + 1, wSide.sx, 42, _, UI_elements.wheels_rt, 0xFF506882 )
        ibCreateLabel( 20, py, 0, 44, item.name, UI_elements.wheels_rt ):ibBatchData( { align_y = "center", font = ibFonts.bold_14 } )

        local area_scroll = ibCreateArea( 0, py + 44, wSide.sx, 80, UI_elements.wheels_rt )
        local scroll = ibScrollbarH( { px = 20, py = 0, sx = 252, sy = 3, parent = area_scroll } )
            :center_y( )
            :ibSetStyle( "tuning" ):ibData( "position", item.value or 0 )
        
        local bg_edit = ibCreateImage( wSide.sx - 20 - 40, 0, 40, 40, _, area_scroll, 0xFF50657c ):center_y( )
        ibCreateImage( 1, 1, 38, 38, _, bg_edit, 0xFF3b4e62 )

        local lbl_value = ibCreateLabel( 0, 0, 40, 40, math.ceil( 100 * item.value or 0 ), bg_edit )
            :ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.regular_14 } )

        scroll:ibOnDataChange( function( key, value )
            if key == "position" then
                lbl_value:ibData( "text", math.ceil( 100 * ( value ) ) )

                CartRemove( TUNING_TASK_WHEELS_EDIT, nil, true )
                if is_any_value_changed( ) then
                    local values = { }
                    for i, setting in pairs( WHEELS_SETTINGS ) do
                        values[ setting.key ] = setting.values
                    end
                    CartAdd( TUNING_TASK_WHEELS_EDIT, values )
                end

                if item.OnChange then
                    item:OnChange( value )
                end
            end
        end )
    end

    local vehicle_max_values = VEHICLE_MAX_VALUES[ DATA.vehicle.model ] or { { }, { } }

    local py = 0
    for pair_id, pair_name in ipairs( { "Передние колеса", "Задние колеса" } ) do
        ibCreateImage( 0, py, wSide.sx, 44, _, UI_elements.wheels_rt, 0xFF7b95ae )
        ibCreateImage( 0, py + 1, wSide.sx, 42, _, UI_elements.wheels_rt, 0xFF6482a0 )
        ibCreateLabel( 20, py, 0, 44, pair_name, UI_elements.wheels_rt ):ibBatchData( { align_y = "center", font = ibFonts.bold_14 } )
        py = py + 44

        for i, setting in ipairs( WHEELS_SETTINGS ) do
            local max_value = vehicle_max_values[ pair_id ][ setting.key ] or 100
            CreateSliderItem( {
                name = setting.name, 
                value = max_value >= setting.values[ pair_id ] and setting.values[ pair_id ] / max_value or 1,
                OnChange = function( self, new_value )
                    setting.values[ pair_id ] = math.ceil( new_value * max_value )
                    UI_elements.vehicle[ setting.fn_set ]( UI_elements.vehicle, unpack( setting.values ) )
                    exports.nrp_vehicle_wheels:UpdateVehicleWheelsStuff( )
                end,
            }, py )
            py = py + 124
        end
    end

    UI_elements.wheels_rt:AdaptHeightToContents( )
    UI_elements.wheels_sc:ibData( "sensivity", 124 / UI_elements.wheels_rt:ibData( "sy" ) )
    UI_elements.wheels_sc:ibData( "position", 0 )

    ibUseRealFonts( false )
end

function ShowWheelsEditor( instant )
    if instant then
        UI_elements.bg_wheels:ibBatchData(
            {
                px = wSide.px, py = wSide.py
            }
        )
        UI_elements.bg_wheels:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.bg_wheels:ibMoveTo( wSide.px, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.bg_wheels:ibBatchData( { disabled = false } )
        UI_elements.bg_wheels:ibAlphaTo( 255, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideWheelsEditor( instant )
    if not isElement( UI_elements.bg_wheels ) then return end
    if instant then
        UI_elements.bg_wheels:ibBatchData(
            {
                px = x, py = wSide.py
            }
        )
        UI_elements.bg_wheels:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.bg_wheels:ibMoveTo( x, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.bg_wheels:ibBatchData( { disabled = true } )
        UI_elements.bg_wheels:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end
end