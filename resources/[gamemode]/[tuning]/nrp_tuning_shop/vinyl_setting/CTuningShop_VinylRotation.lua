
local scale = nil

function CreateVinylsSettingRotation( data )
    
    if isElement( UI_elements.bg_setting_rotation ) then return end
    
    if QUEST_RECOLOR then
        if QUEST_HINT then QUEST_HINT:destroy() end

        local ticks = getTickCount()
        QUEST_HINT = CreateSutiationalHint( {
			text = "Здесь изменяется поворот винила",
			condition = function( )
				return getTickCount() - ticks < 10000
			end
		} )
    end

    UI_elements.bg_setting_rotation = ibCreateImage( wSettingRotation.px, wSettingRotation.py, wSettingRotation.sx, wSettingRotation.sy, "img/vinyl_setting/bg_setting_rotation.png" )
    
    local size_scroll = ibScrollbarH( { px = 55, py = 92, sx = 156, sy = 3, parent = UI_elements.bg_setting_rotation } )
    :ibSetStyle( "tuning" ):ibData( "position", data.rotation / 360 )
    addEventHandler( "ibOnElementDataChange", size_scroll, function( key, value )
        if key == "position" then
            local rotation = value * 360
            CURRENT_VYNYL_LAYER_DATA.rotation = rotation
            RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
        end
    end )

    UI_elements.bg_setting_rotation_min = ibCreateImage( 10, 82, 30, 20, _, UI_elements.bg_setting_rotation, 0xFF3F5368 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        local value = size_scroll:ibData( "position" )
        value = math.max( 0, value - 0.0025 )
        size_scroll:ibData( "position", value )
        local rotation = value * 360
        CURRENT_VYNYL_LAYER_DATA.rotation = rotation
        RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
    end )
    :ibOnHover( function( )
        UI_elements.bg_setting_rotation_min:ibData( "color", 0xFF5D7B99 )
    end )
    :ibOnLeave( function( )
        UI_elements.bg_setting_rotation_min:ibData( "color", 0xFF3F5368 )
    end )

    ibCreateLabel( 0, 0, 30, 20, "-", UI_elements.bg_setting_rotation_min, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 ):ibData( "disabled", true )

    UI_elements.bg_setting_rotation_plus = ibCreateImage( 226, 82, 30, 20, _, UI_elements.bg_setting_rotation, 0xFF3F5368 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        local value = size_scroll:ibData( "position" )
        value = math.max( 0, value + 0.0025 )
        size_scroll:ibData( "position", value )
        local rotation = value * 360
        CURRENT_VYNYL_LAYER_DATA.rotation = rotation
        RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
    end )
    :ibOnHover( function( )
        UI_elements.bg_setting_rotation_plus:ibData( "color", 0xFF5D7B99 )
    end )
    :ibOnLeave( function( )
        UI_elements.bg_setting_rotation_plus:ibData( "color", 0xFF3F5368 )
    end )
    ibCreateLabel( 0, 0, 30, 20, "+", UI_elements.bg_setting_rotation_plus, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 ):ibData( "disabled", true )

    -- Сброс
    ibCreateButton( 0, 125, 111, 45, UI_elements.bg_setting_rotation,
        "img/btn_reset.png", "img/btn_reset.png", "img/btn_reset.png",
        0xAAFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF )
        :center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            
            CURRENT_VYNYL_LAYER_DATA.rotation = CURRENT_VYNYL_LAYER_OLD_DATA.rotation
            RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
        end )
end

function ShowVinylsSettingRotation( instant )
    if not isElement( UI_elements.bg_setting_rotation ) then return end
    if instant then
        UI_elements.bg_setting_rotation:ibBatchData(
            {
                px = wSettingRotation.px + wSettingRotation.sx + 94 * wSettingRotation.scale,
                py = wSettingRotation.py
            }
        )
    else
        UI_elements.bg_setting_rotation:ibMoveTo( wSettingRotation.px, wSettingRotation.py, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideVinylsSettingRotation( instant )
    if not isElement( UI_elements.bg_setting_rotation ) then return end
    if instant then
        UI_elements.bg_setting_rotation:ibBatchData(
            {
                px = wSettingRotation.px + wSettingRotation.sx + 94 * wSettingRotation.scale, 
                py = wSettingRotation.py,
            }
        )
    else
        UI_elements.bg_setting_rotation:ibMoveTo( wSettingRotation.px + wSettingRotation.sx + 94 * wSettingRotation.scale, wSettingRotation.py, 150 * ANIM_MUL, "OutQuad" )
    end
end