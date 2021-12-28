
-- Таймаут на перемещение
local CURRENT_TIMEOUT = 0
local TIMEOUT = 10

-- Текущее направление перемещения 
DIRECTION_DATA = nil
DIRECTION_KEYS = {  "arrow_l", "arrow_r", "arrow_d", "arrow_u" }
DIRECTION_BUTTONS = {}
DIRECTION_BUTTONS_PROPERTY =
{
    { 73,  129,  0  },
    { 153, 129, 180 },
    { 113, 169, 270 },
    { 113, 86,  90  },
}
COUNT_DIRECTION = 0
CURRENT_DIRECTIONS = {}

OLD_VINYL_LAYER_DATA = { }

function CreateVinylsSettingPosition( data )
    
    if isElement( UI_elements.bg_setting_position ) then return end
    
    if QUEST_RECOLOR then
        if QUEST_HINT then QUEST_HINT:destroy() end

        local ticks = getTickCount()
        QUEST_HINT = CreateSutiationalHint( {
			text = "Клавишами вверх/вних, влево/право можно изменить расположение винила",
			condition = function( )
				return getTickCount() - ticks < 10000
			end
		} )
    end

    UI_elements.bg_setting_position = ibCreateImage( wSettingPosition.px, wSettingPosition.py, wSettingPosition.sx, wSettingPosition.sy, "img/vinyl_setting/bg_setting_position.png" )
    UI_elements.bg_help_info = ibCreateImage( wSettingHelpPosition.px, wSettingHelpPosition.py, wSettingHelpPosition.sx, wSettingHelpPosition.sy, "img/vinyl_setting/bottom_help_info.png" )
    
    for k, v in pairs( DIRECTION_BUTTONS_PROPERTY ) do
        local is_button_pressed = false

        DIRECTION_BUTTONS[ k ] = ibCreateButton( v[ 1 ], v[ 2 ], 40, 36, UI_elements.bg_setting_position,
            "img/vinyl_setting/btn_arrow.png", "img/vinyl_setting/btn_arrow.png", "img/vinyl_setting/btn_arrow.png",
            0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" then return end
                COUNT_DIRECTION = 0
                CURRENT_DIRECTIONS = nil
                CURRENT_DIRECTIONS = {}
                StartMovement( key, state, k )
                is_button_pressed = state == "down"
            end )
            :ibOnLeave( function( )
                if is_button_pressed then
                    StartMovement( "left", "up", k )
                    is_button_pressed = false
                end
            end )
            :ibData( "rotation", v[ 3 ] )

        unbindKey( DIRECTION_KEYS[ k ], "both", StartMovement )
        bindKey( DIRECTION_KEYS[ k ], "both", StartMovement, k )

    end

    -- Сброс
    ibCreateButton( 0, 230, 111, 45, UI_elements.bg_setting_position,
        "img/btn_reset.png", "img/btn_reset.png", "img/btn_reset.png",
        -- "img/vinyl_setting/btn_apply.png", "img/vinyl_setting/btn_apply_hovered.png", "img/vinyl_setting/btn_apply_hovered.png",
        0xAAFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF )
        :center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            
            CURRENT_VYNYL_LAYER_DATA.x = CURRENT_VYNYL_LAYER_OLD_DATA.x
            CURRENT_VYNYL_LAYER_DATA.y = CURRENT_VYNYL_LAYER_OLD_DATA.y
            RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
        end )
end

function ShowVinylsSettingPosition( instant )
    if not isElement( UI_elements.bg_setting_position ) then return end
    for k, v in pairs( DIRECTION_BUTTONS_PROPERTY ) do
        bindKey( DIRECTION_KEYS[ k ], "both", StartMovement, k )
    end
    if instant then
        UI_elements.bg_setting_position:ibBatchData(
            {
                px = wSettingPosition.px + wSettingPosition.sx + 94 * wSettingPosition.scale,
                py = wSettingPosition.py
            }
        )
        UI_elements.bg_help_info:ibBatchData(
            {
                px = wSettingHelpPosition.px,
                py = wSettingHelpPosition.py
            }
        )
    else
        UI_elements.bg_setting_position:ibMoveTo( wSettingPosition.px, wSettingPosition.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.bg_help_info:ibMoveTo( wSettingHelpPosition.px, wSettingHelpPosition.py, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideVinylsSettingPosition( instant )
    if not isElement( UI_elements.bg_setting_position ) then return end
    for k, v in pairs( DIRECTION_BUTTONS_PROPERTY ) do
        unbindKey( DIRECTION_KEYS[ k ], "both", StartMovement )
    end
    if instant then
        UI_elements.bg_setting_position:ibBatchData(
            {
                px = wSettingPosition.px + wSettingPosition.sx + 94 * wSettingPosition.scale, 
                py = wSettingPosition.py,
            }
        )
        UI_elements.bg_help_info:ibBatchData(
            {
                px = wSettingHelpPosition.px,
                py = wSettingHelpPosition.py + wSettingHelpPosition.sy,
            }
        )
    else
        UI_elements.bg_setting_position:ibMoveTo( wSettingPosition.px + wSettingPosition.sx + 94 * wSettingPosition.scale, wSettingPosition.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.bg_help_info:ibMoveTo( wSettingHelpPosition.px, wSettingHelpPosition.py + wSettingHelpPosition.sy, 150 * ANIM_MUL, "OutQuad" )
    end
end

function StartMovement( key, key_state, direction_id )
    if key_state == "down" and COUNT_DIRECTION == 2 then
        return
    elseif key_state == "up" and CURRENT_DIRECTIONS[ direction_id ] then
        COUNT_DIRECTION = COUNT_DIRECTION - 1
        CURRENT_DIRECTIONS[ direction_id ] = nil
        if COUNT_DIRECTION == 0 then
            removeEventHandler( "onClientRender", root, onMoveVinyl )
        end
    end

    if key_state == "down" and #CURRENT_DIRECTIONS < 2 then
        DIRECTION_BUTTONS[ direction_id ]:ibData( "color", 0xFFFFFFFF )
        CURRENT_DIRECTIONS[ direction_id ] = true
        COUNT_DIRECTION = COUNT_DIRECTION + 1

        GetMoveDirection()
        removeEventHandler( "onClientRender", root, onMoveVinyl )
        addEventHandler( "onClientRender", root, onMoveVinyl )        
    end

    for k, v in pairs( DIRECTION_BUTTONS ) do
        if not CURRENT_DIRECTIONS[ k ] then
            v:ibData( "color", 0xAAFFFFFF )
        end
    end
end

function onMoveVinyl()
    local ticks = getTickCount()
    if ticks > CURRENT_TIMEOUT and COUNT_DIRECTION > 0 then
        CURRENT_TIMEOUT = ticks + TIMEOUT
        ChangeVinylPosition()
    end
end

function ChangeVinylPosition()
    local temp_x = CURRENT_VYNYL_LAYER_DATA.x
    local temp_y = CURRENT_VYNYL_LAYER_DATA.y
    for k, v in pairs( CURRENT_DIRECTIONS ) do
        temp_x = temp_x + DIRECTION_DATA[ k ].x
        temp_y = temp_y + DIRECTION_DATA[ k ].y
    end
    
    if temp_x > DEFAULT_VINYL_SIZE or temp_y > DEFAULT_VINYL_SIZE or temp_x < 0 or temp_y < 0 then
        return
    end
    CURRENT_VYNYL_LAYER_DATA.x = temp_x
    CURRENT_VYNYL_LAYER_DATA.y = temp_y
    RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
end

function GetMoveDirection()
    local cur_rot = getCameraRotation() - 45
    if cur_rot > 330 or cur_rot < 125 then
        DIRECTION_DATA = { { x = -1, y = 0 }, { x = 1, y = 0 }, { x = 0, y = 1 }, { x = 0, y = -1 } }
    elseif cur_rot > 125 and cur_rot < 170 then
        DIRECTION_DATA = { { x = 0, y = 1 }, { x = 0, y = -1 }, { x = 1, y = 0 }, { x = -1, y = 0 } }
    elseif cur_rot > 170 and cur_rot < 300 then
        DIRECTION_DATA = { { x = 1, y = 0 }, { x = -1, y = 0 }, { x = 0, y = -1 }, { x = 0, y = 1 } }
    elseif cur_rot > 295 and cur_rot < 335 then
        DIRECTION_DATA = { { x = 0, y = -1 }, { x = 0, y = 1 }, { x = -1, y = 0 }, { x = 1, y = 0 } }
    end
end

function getCameraRotation()
    local camX, camY, _, lookAtX, lookAtY = getCameraMatrix()
    local camRotZ = math.atan2 ( ( lookAtX - camX ), ( lookAtY - camY ) )
    camRotZ = -math.deg( camRotZ )
    camRotZ = camRotZ < 0 and camRotZ + 360 or camRotZ
    return camRotZ
end