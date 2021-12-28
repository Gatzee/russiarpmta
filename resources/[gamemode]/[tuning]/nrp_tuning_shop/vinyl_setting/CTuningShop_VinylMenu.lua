
VINYL_SETTING_COLOR = 1
VINYL_SETTING_ROTATION = 2
VINYL_SETTING_POSITION = 3
VINYL_SETTING_MIRROR = 4
VINYL_SETTING_SIZE = 5

ACTIVE_MENU_SETTING_ID = nil
CURRENT_VINYL_LIST_VINYL_MENU = nil
CURRENT_VINYL_ID = nil
CURRENT_VYNYL_LAYER_DATA = nil
CURRENT_VYNYL_LAYER_OLD_DATA = nil

-- При добавлении новых пунктов, необходимо включить ф-ю скрытия в ф-ю HideSubMenu
MENU_SETTING_STRUCTURE =
{
    [ VINYL_SETTING_COLOR ] =
    {
        name = "color",
        callback = function( data, reshow )
            CreateVinylColorpicker( data, {
                selected_color = CURRENT_VYNYL_LAYER_DATA.color,
                OnChange = function( r, g, b )
                    CURRENT_VYNYL_LAYER_DATA.color = tocolor( r, g, b, 255 )
                    RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
                end,
                OnReset = function( r, g, b )
                    CURRENT_VYNYL_LAYER_DATA.color = CURRENT_VYNYL_LAYER_OLD_DATA.color
                    RefreshVehicleVinyl( CURRENT_VINYL_LIST )
                end,
            })
            if reshow then
                HideVinylColorpicker( true )
                ShowVinylColorpicker( )
            end
        end,

    },
    [ VINYL_SETTING_ROTATION ] =
    {
        name = "rotation",
        callback = function( data, reshow )
            
            CreateVinylsSettingRotation( data )
            if reshow then
                HideVinylsSettingRotation( true )
                ShowVinylsSettingRotation( )
            end
        end,
    },
    [ VINYL_SETTING_POSITION ] =
    {
        name = "position",
        callback = function( data, reshow )
            CreateVinylsSettingPosition( data )
            if reshow then
                HideVinylsSettingPosition( true )
                ShowVinylsSettingPosition( )
            end
        end,
    },
    [ VINYL_SETTING_MIRROR ] = 
    {
        name = "mirror",
        callback = function( data, reshow )
            CURRENT_VYNYL_LAYER_DATA.mirror = not CURRENT_VYNYL_LAYER_DATA.mirror
            RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )
        end,
    },
    [ VINYL_SETTING_SIZE ] =
    {
        name = "size",
        callback = function( data, reshow )
            CreateVinylsSettingSize( data )
            if reshow then
                HideVinylsSettingSize( true )
                ShowVinylsSettingSize( )
            end
        end,
    },
}


function CreateVinylsSettingMenu( data )
     
    CURRENT_VINYL_ID = data.current_vinyl_id
    CURRENT_VINYL_LIST_VINYL_MENU = table.copy( DATA.installed_vinyls )
    CURRENT_VYNYL_LAYER_DATA = CURRENT_VINYL_LIST_VINYL_MENU[ CURRENT_VINYL_ID ][ P_LAYER_DATA ]
    CURRENT_VYNYL_LAYER_OLD_DATA = table.copy( CURRENT_VYNYL_LAYER_DATA )
    
    HideVinylsSell()
    RefreshVehicleVinyl( CURRENT_VINYL_LIST_VINYL_MENU )

    if isElement( UI_elements.bg_setting_menu ) then return end
    UI_elements.bg_setting_menu = ibCreateArea( wSetttingMenu.px, wSetttingMenu.py, wSetttingMenu.sx, wSetttingMenu.sy ):ibData("priority", 10 )
    
    for k, v in pairs( MENU_SETTING_STRUCTURE ) do
        ibCreateButton( 0, 67 * (k - 1), 60, 60, UI_elements.bg_setting_menu,
            "img/vinyl_setting/btn_" .. v.name .. ".png", "img/vinyl_setting/btn_" .. v.name .. "_hovered.png", "img/vinyl_setting/btn_" .. v.name .. "_hovered.png",
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            local reshow = ACTIVE_MENU_SETTING_ID ~= k
            if k == VINYL_SETTING_MIRROR then
                ibClick()
                MENU_SETTING_STRUCTURE[ k ].callback( _, reshow )
                return
            end
            
            if reshow then
                ibClick()
                HideSubMenu( )
            end
            ACTIVE_MENU_SETTING_ID = k
            UI_elements.bg_setting_active_setting:ibBatchData( { alpha = 255, py = (k - 1) * 67 + 24 } )
            local current_vinyl = CURRENT_VINYL_LIST_VINYL_MENU[ CURRENT_VINYL_ID ]
            v.callback( current_vinyl[ P_LAYER_DATA], reshow )
        end )
    end

    -- Сохранить
    local btn_save = ibCreateButton( 0, (#MENU_SETTING_STRUCTURE + 1) * 67, 60, 60, UI_elements.bg_setting_menu,
        "img/vinyl_setting/btn_save.png", "img/vinyl_setting/btn_save_hovered.png", "img/vinyl_setting/btn_save_hovered.png",
        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()

            DATA.installed_vinyls = CURRENT_VINYL_LIST_VINYL_MENU
            triggerServerEvent( "onServerApplyVinylSetting", resourceRoot, DATA.installed_vinyls )
            CloseVinylsSettingMenu( data )
        end )

    -- Назад
    local btn_back = ibCreateButton( 0, (#MENU_SETTING_STRUCTURE + 2) * 67, 60, 60, UI_elements.bg_setting_menu,
        "img/vinyl_setting/btn_exit.png", "img/vinyl_setting/btn_exit_hovered.png", "img/vinyl_setting/btn_exit_hovered.png",
        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()

            if not table.compare( CURRENT_VYNYL_LAYER_DATA, CURRENT_VYNYL_LAYER_OLD_DATA ) then
                ibConfirm(
                    {
                        title = "СБРОС ИЗМЕНЕНИЙ", 
                        text = "Вы уверены, что хотите сбросить изменения?" ,
                        fn = function( self )
                            CloseVinylsSettingMenu( data )
                            self:destroy()
                        end,
                        escape_close = true,
                    }
                )
            else
                CloseVinylsSettingMenu( data )
            end
        end )

end

function CloseVinylsSettingMenu( data )
    if data.back_button_callback then
        data.back_button_callback( )
    else
        HideSubMenu( )
        ShowBackButton( )
        HideVinylsSettingMenu()
        ShowVinylInventory()
        ShowVinylCases( )
        ShowVinylsSell()
        ResetActiveButton()
        ACTIVE_MENU_SETTING_ID = nil
        CURRENT_VINYL_ID = nil
        CURRENT_VINYL_LIST_VINYL_MENU = nil
        CURRENT_VYNYL_LAYER_DATA = nil
        CURRENT_VYNYL_LAYER_OLD_DATA = nil
    end
end

function ShowVinylsSettingMenu( instant )
    if not isElement( UI_elements.bg_setting_menu ) then return end
    if instant then
        UI_elements.bg_setting_menu:ibBatchData(
            {
                px = wSetttingMenu.px + wSetttingMenu.sx + 20 * wSetttingMenu.scale,
                py = wSetttingMenu.py
            }
        )
    else
        UI_elements.bg_setting_menu:ibMoveTo( wSetttingMenu.px, wSetttingMenu.py, 150 * ANIM_MUL, "OutQuad" )
    end
    HideVinylCases( true )
    HideVinylInventory()
    HideBackButton( true )
    
    ACTIVE_MENU_SETTING_ID = 1
    
    local current_vinyl = CURRENT_VINYL_LIST_VINYL_MENU[ CURRENT_VINYL_ID ]
    if current_vinyl then
        MENU_SETTING_STRUCTURE[ ACTIVE_MENU_SETTING_ID ].callback( current_vinyl[ P_LAYER_DATA], true )
    
        if not isElement( UI_elements.bg_setting_active_setting ) then
            UI_elements.bg_setting_active_setting = ibCreateImage( -9, (ACTIVE_MENU_SETTING_ID - 1) * 67 + 24, 9, 13, "img/vinyl_setting/active_btn.png", UI_elements.bg_setting_menu )
        else
            UI_elements.bg_setting_active_setting:ibBatchData( { alpha = 255, py = (ACTIVE_MENU_SETTING_ID - 1) * 67 + 24 } )
        end
    end
end

function HideVinylsSettingMenu( instant )
    if not isElement( UI_elements.bg_setting_menu ) then return end
    RefreshVehicleVinyl( DATA.installed_vinyls )
    HideSubMenu()
    if instant then
        UI_elements.bg_setting_menu:ibBatchData(
            {
                px = wSetttingMenu.px, 
                py = wSetttingMenu.py,
            }
        )
    else
        UI_elements.bg_setting_menu:ibMoveTo( wSetttingMenu.px + wSetttingMenu.sx + 20 * wSetttingMenu.scale, wSetttingMenu.py, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideSubMenu()
    HideVinylsSettingPosition()
    HideVinylsSettingRotation()
    HideVinylsSettingSize()
    HideVinylColorpicker()
end