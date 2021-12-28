
function CreateVinylsSettingSize( data )

    if isElement( UI_elements.bg_setting_size ) then 
        UI_elements.scroll_size:ibData( "position", data.size / 3 )
        return 
    end
    
    if QUEST_RECOLOR then
        if QUEST_HINT then QUEST_HINT:destroy() end

        local ticks = getTickCount()
        QUEST_HINT = CreateSutiationalHint( {
			text = "Здесь изменяется масштаб винила",
			condition = function( )
				return getTickCount() - ticks < 10000
			end
		} )
    end

    UI_elements.bg_setting_size = ibCreateImage( wSettingSize.px, wSettingSize.py, wSettingSize.sx, wSettingSize.sy, "img/vinyl_setting/bg_setting_size.png" )
    
    UI_elements.scroll_size = ibScrollbarH( { px = 55, py = 92, sx = 156, sy = 3, parent = UI_elements.bg_setting_size } )
    :ibSetStyle( "tuning" ):ibData( "position", data.size / 3 )
    addEventHandler( "ibOnElementDataChange", UI_elements.scroll_size, function( key, value )
        if key == "position" then
            CURRENT_VYNYL_LAYER_DATA.size = value * 3
            RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
        end
    end )

    UI_elements.bg_setting_size_min = ibCreateImage( 10, 82, 30, 20, _, UI_elements.bg_setting_size, 0xFF3F5368 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        
        local value = UI_elements.scroll_size :ibData( "position" )
        value = math.max( 0, value - 0.0025 )
        UI_elements.scroll_size :ibData( "position", value )
        
        local size = value * 3
        CURRENT_VYNYL_LAYER_DATA.size = size
        RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
    end )
    :ibOnHover( function( )
        UI_elements.bg_setting_size_min:ibData( "color", 0xFF5D7B99 )
    end )
    :ibOnLeave( function( )
        UI_elements.bg_setting_size_min:ibData( "color", 0xFF3F5368 )
    end )

    ibCreateLabel( 0, 0, 30, 20, "-", UI_elements.bg_setting_size_min, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 ):ibData( "disabled", true )

    UI_elements.bg_setting_size_plus = ibCreateImage( 226, 82, 30, 20, _, UI_elements.bg_setting_size, 0xFF3F5368 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        local value = UI_elements.scroll_size :ibData( "position" )
        value = math.max( 0, value + 0.0025 )
        UI_elements.scroll_size :ibData( "position", value )
        local size = value * 3
        CURRENT_VYNYL_LAYER_DATA.size = size
        RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
    end )
    :ibOnHover( function( )
        UI_elements.bg_setting_size_plus:ibData( "color", 0xFF5D7B99 )
    end )
    :ibOnLeave( function( )
        UI_elements.bg_setting_size_plus:ibData( "color", 0xFF3F5368 )
    end )
    ibCreateLabel( 0, 0, 30, 20, "+", UI_elements.bg_setting_size_plus, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 ):ibData( "disabled", true )

    -- Сброс
    ibCreateButton( 0, 125, 111, 45, UI_elements.bg_setting_size,
        "img/btn_reset.png", "img/btn_reset.png", "img/btn_reset.png",
        0xAAFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF )
        :center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            
            CURRENT_VYNYL_LAYER_DATA.size = CURRENT_VYNYL_LAYER_OLD_DATA.size
            RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
        end )
end

function ShowVinylsSettingSize( instant )
    if not isElement( UI_elements.bg_setting_size ) then return end
    if instant then
        UI_elements.bg_setting_size:ibBatchData(
            {
                px = wSettingSize.px + wSettingSize.sx + 94 * wSettingSize.scale,
                py = wSettingSize.py
            }
        )
    else
        UI_elements.bg_setting_size:ibMoveTo( wSettingSize.px, wSettingSize.py, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideVinylsSettingSize( instant )
    if not isElement( UI_elements.bg_setting_size ) then return end
    if instant then
        UI_elements.bg_setting_size:ibBatchData(
            {
                px = wSettingSize.px + wSettingSize.sx + 94 * wSettingSize.scale, 
                py = wSettingSize.py,
            }
        )
    else
        UI_elements.bg_setting_size:ibMoveTo( wSettingSize.px + wSettingSize.sx + 94 * wSettingSize.scale, wSettingSize.py, 150 * ANIM_MUL, "OutQuad" )
    end
end