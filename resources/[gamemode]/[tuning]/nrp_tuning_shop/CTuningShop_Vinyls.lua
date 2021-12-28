function CreateVinylsMenu( )
    if isElement( UI_elements.area_vinyls ) then destroyElement( UI_elements.area_vinyls ) end
    UI_elements.area_vinyls = ibCreateArea( wVinyls.px, wVinyls.py, wVinyls.sx, wVinyls.sy )
    UI_elements.vinyls_rt, UI_elements.vinyls_sc = ibCreateScrollpane( 0, 0, wVinyls.sx, wVinyls.sy, UI_elements.area_vinyls,
        {
            scroll_px = -wVinyls.sx + 10,
        }
    )
    UI_elements.vinyls_sc:ibSetStyle( "slim_small_nobg" )
    UpdateVinylsMenu( )
end

function ShowVinylsMenu( instant )
    UpdateVinylsMenu( )
    if instant then
        UI_elements.area_vinyls:ibBatchData(
            {
                px = wVinyls.px, py = wVinyls.py
            }
        )

    else
        UI_elements.area_vinyls:ibMoveTo( wVinyls.px, wVinyls.py, 150, "OutQuad" )

    end
end

function HideVinylsMenu( instant )
    if not isElement( UI_elements.area_vinyls ) then return end
    if instant then
        UI_elements.area_vinyls:ibBatchData(
            {
                px = -wVinyls.sx, py = wVinyls.py
            }
        )
    else
        UI_elements.area_vinyls:ibMoveTo( -wVinyls.sx, wVinyls.py, 150, "OutQuad" )
    end
end

function CreateVinylItem( px, py, sx, sy, vinyl, parent, hide_class )
    local real_parent = UI_elements.vinyls_rt
    if parent == false then real_parent = false end
    
    local icon_x, icon_y = sx - 6, sy - 6
    if not sx or not sy then
        sx, sy = wVinyls.section_sx, wVinyls.section_sy
        icon_x, icon_y = 60, 60
    end

    local bg
    if vinyl and vinyl.blocked then
        bg = ibCreateImage( px, py, sx, sy, "img/bg_part_locked.png", real_parent )
    elseif vinyl then
        bg = ibCreateImage( px, py, sx, sy, "img/bg_part.png", real_parent )
        ibCreateContentImage( 0, 0, 300, 160, "vinyl", vinyl[ P_IMAGE ], bg )
        :ibSetInBoundSize( icon_x, icon_y ):center( )

        if not hide_class then
            ibCreateImage( sx - 32, sy - 16, 30, 14, "img/bg_part_class.png", bg )
            local class = VEHICLE_CLASSES_NAMES[ vinyl[ P_CLASS ] ]
            ibCreateLabel( sx - 15, sy - 8, 0, 0, class, bg, _, _, _, "center", "center", ibFonts.semibold_12 )
        end
    else
        bg = ibCreateImage( px, py, sx, sy, "img/bg_part.png", real_parent )
    end

    return bg
end

function RefreshLayers( old_layer, new_layer )
    if ACTIVE_MENU_SETTING_ID then
        localPlayer:ShowError( "Перемещение во время настройки недоступно" )
        return
    end

    triggerServerEvent( "onServerRefreshVinylLayers", localPlayer, old_layer, new_layer )
    ResetFloatingVinyl( )
end

function UpdateVinylsMenu( )
    local vinyls = DATA.installed_vinyls
    local npx, npy = 60, 96 * VINYL_SLOTS_COUNT - 86
    
    for i = 1, VINYL_SLOTS_COUNT do
        local element_id = "vinyl_section_" .. i
        if isElement( UI_elements[ element_id ] ) then destroyElement( UI_elements[ element_id ] ) end
        
        local original_vinyl
        local vinyl = vinyls[ i ] or {}
        -- Доступен слой и в нем есть винил
        if vinyls[ i ] then
            original_vinyl = vinyl
            UI_elements[ element_id ] = CreateVinylItem( npx, npy, 86, 86, vinyl, nil, true )
        -- Слой доступен и пустой
        else
            vinyl.free = true
            UI_elements[ element_id ] = CreateVinylItem( npx, npy, 86, 86 )
        end

        UI_elements[ element_id .. "_arrow_u" ] = ibCreateImage( -30, 12, 20, 24, "img/vinyl_setting/arrow.png", UI_elements[ element_id ] )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()
                if not vinyls[ i ] then
                    localPlayer:ShowError( "Слот пуст" )
                    return
                end
                RefreshLayers( i, i + 1 )
            end )
            :ibBatchData( { rotation = 180, priority = 10, alpha = 150 })
            :ibOnHover( function( )
                source:ibAlphaTo( 255, 100 )
            end )
            :ibOnLeave( function( )
                source:ibAlphaTo( 150, 100 )
            end )

        UI_elements[ element_id .. "_arrow_d" ] = ibCreateImage( -30, 50, 20, 24, "img/vinyl_setting/arrow.png", UI_elements[ element_id ] )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()
                --Если слой настраивается, то блочим нахуй перемещение
                if not vinyls[ i ] then
                    localPlayer:ShowError( "Слот пуст" )
                    return
                end

                RefreshLayers( i, i - 1 )
            end )
            :ibBatchData( { priority = 10, alpha = 150 })
            :ibOnHover( function( )
                source:ibAlphaTo( 255, 100 )
            end )
            :ibOnLeave( function( )
                source:ibAlphaTo( 150, 100 )
            end )

        if i == 1 then
            UI_elements[ element_id .. "_arrow_d" ] :ibBatchData( { disabled = true, alpha =  50 } )
        elseif i == VINYL_SLOTS_COUNT then
            UI_elements[ element_id .. "_arrow_u" ]:ibBatchData( { disabled = true, alpha = 50 } )
        end
        
        ibCreateLabel( wVinyls.section_sx + 20, wVinyls.section_sy / 2, 0, 0, "Слой " .. i, UI_elements[ element_id ] )
            :ibBatchData( { align_y = "center", font = ibFonts.regular_12, color = 0xFFFEFEFE } )

        local area = ibCreateArea( 0, 0, wVinyls.section_sx, wVinyls.section_sy, UI_elements[ element_id ] )

        if not vinyl.blocked then
            addEventHandler( "ibOnElementMouseEnter", area, function( )
                if UI_elements[ element_id ]:ibData( "texture") ~= "img/bg_part_current.png" then
                    UI_elements[ element_id ]:ibData( "texture", "img/bg_part_hover.png" )
                end
            end, false )

            addEventHandler( "ibOnElementMouseLeave", area, function( )
                if UI_elements[ element_id ]:ibData( "texture") ~= "img/bg_part_current.png" then
                    UI_elements[ element_id ]:ibData( "texture", "img/bg_part.png" )
                end
            end, false )

            addEventHandler( "ibOnElementMouseClick", area, function( key, state )
                if key ~= "left" then 
                    return
                elseif state == "up" and vinyl.blocked then
                    return
                end

                if state == "down" and not vinyl.free and not vinyl.blocked then
                    CreateFloatingVinyl( vinyl, DRAG_TYPE_FROM_VEHICLE )
                elseif state == "up" and GetFloatingVinylDragType() ~= DRAG_TYPE_FROM_VEHICLE then
                    local vinyl = GetFloatingVinyl( )
                    if vinyl then
                        if original_vinyl then
                            localPlayer:ErrorWindow( "Чтобы нанести новый винил нужно удалить старый", "Этот слой уже занят!" )
                            return
                        end

                        if confirmation then 
                            confirmation:destroy() 
                        end

                        if UI_elements.is_style then
                            -- TODO: INSTALL_STYLE
                        else
                            local confirm_text = ""
                            if vinyl[ P_PRICE_TYPE ] == "soft" then
								confirm_text = "Винил привязывается к машине.\nСнятие винила происходит только через его продажу."
                            elseif vinyl[ P_PRICE_TYPE ] == "hard" then
                                confirm_text = "Винил не привязывается к машине.\nПосле снятия винила, его можно положить в инвентарь."
                            elseif vinyl[ P_PRICE_TYPE ] == "race" then
                                confirm_text = "Винил не привязывается к машине.\nПосле снятия винила, его можно положить в инвентарь."
							end

                            confirmation = ibConfirm(
                                {
                                    title = "УСТАНОВКА ВИНИЛА", 
                                    text = confirm_text,
                                    fn = function( self ) 
                                        self:destroy()
                                        vinyl[ P_LAYER ] = i
                                        triggerServerEvent( "onVinylInstallAttempt", resourceRoot, vinyl )
                                    end,
                                    escape_close = true,
                                }
                            )
                        end

                        ResetFloatingVinyl( )
                    end
                elseif not vinyl.free and not vinyl.blocked and state == "up" and GetFloatingVinylDragType() == DRAG_TYPE_FROM_VEHICLE and vinyls[ i ] and i ~= CURRENT_VINYL_ID then
                    ResetActiveButton()
                    CreateVinylsSettingMenu( { current_vinyl_id = i } )
                    HideVinylsSettingMenu( true )
                    ShowVinylsSettingMenu( )
                    UI_elements[ element_id ]:ibData( "texture", "img/bg_part_current.png" )
                end
            end, false )
        end

        npy = npy - 96

    end

    UI_elements.vinyls_rt:AdaptHeightToContents( )
end

function ResetActiveButton()
    for id = 1, VINYL_SLOTS_COUNT do
        local element_id = "vinyl_section_" .. id
        local src_img = UI_elements[ element_id ]:ibData( "texture" )
        if src_img == "img/bg_part_current.png" then
            UI_elements[ element_id ]:ibData( "texture", "img/bg_part.png" )
        end
    end
end

function onVinylsListUpdate_handler( vinyls, color, vinyls_inventory )
    DATA.color = color
    DATA.installed_vinyls = vinyls

    if isElement( UI_elements[ "vinyl_section_1" ] ) then
        UpdateVinylsMenu( )
    end

    if next( DATA.installed_vinyls ) then
        UI_elements.vehicle:SetColor( 255, 255, 255 )
        RefreshVehicleVinyl( DATA.installed_vinyls )
        local color_in_cart = false
        for k, v in pairs( UI_elements.cart or { } ) do
            if v[ 1 ] == TUNING_TASK_COLOR then
                color_in_cart = true
                break
            end
        end
        if not color_in_cart then
            RefreshDefaultColor( DATA.color )
        end
    else
        UI_elements.vehicle:SetColor( DEFAULT_COLOR[ 1 ], DEFAULT_COLOR[ 2 ], DEFAULT_COLOR[ 3 ] )
        RefreshVehicleVinyl({})
    end

    if vinyls_inventory then
        onVinylsInventoryUpdate_handler( vinyls_inventory )
    end

    local current_quest = localPlayer:getData( "current_quest" )
    if current_quest and current_quest.id == "alexander_talks" then
        localPlayer:ShowInfo( "Покраска помогла скрыться, можем ехать дальше" )
    end
end
addEvent( "onVinylsListUpdate", true )
addEventHandler( "onVinylsListUpdate", root, onVinylsListUpdate_handler )