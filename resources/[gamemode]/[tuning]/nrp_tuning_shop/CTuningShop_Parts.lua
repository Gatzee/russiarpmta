function CreatePartsMenu( )
    if isElement( UI_elements.area_parts ) then destroyElement( UI_elements.area_parts ) end
    UI_elements.area_parts = ibCreateArea( wParts.px, wParts.py, wParts.sx, wParts.sy )

    addEventHandler( "onClientElementDestroy", UI_elements.area_parts, function( )
        removeEventHandler( "onClientCursorMove", root, RenderMovePartHint )
    end )

    UpdatePartsMenu( )
end

function ShowPartsMenu( instant )
    if instant then
        UI_elements.area_parts:ibBatchData( { px = wParts.px, py = wParts.py } )
    else
        UI_elements.area_parts:ibMoveTo( wParts.px, wParts.py, 150, "OutQuad" )
    end
end

function HidePartsMenu( instant )
    if not isElement( UI_elements.area_parts ) then return end
    if instant then
        UI_elements.area_parts:ibBatchData( { px = -wParts.sx, py = wParts.py } )
    else
        UI_elements.area_parts:ibMoveTo( -wParts.sx, wParts.py, 150, "OutQuad" )
    end

    DATA.preview_parts = { }
    RefreshBottomBar( )
end

function CreatePartElement( px, py, part, parent, alphaOfIcon, amount )
    local real_parent = UI_elements.area_parts
    if parent == false then real_parent = false end

    local section_sx, section_sy = wParts.section_sx, wParts.section_sy
    local texturePath = part and ( ":nrp_tuning_internal_parts/img/bg_part_" .. part.category .. ".png" ) or "img/bg_part.png"

    if not UI_elements[ texturePath ] then UI_elements[ texturePath ] = dxCreateTexture( texturePath, "dxt5" ) end

    local bg = ibCreateImage( px, py, section_sx, section_sy, UI_elements[ texturePath ], real_parent )

    if part then
        ibUseRealFonts( true )

        local texturePath = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. ".png"
        local texturePathForMoto = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. "_m.png"

        if DATA.current_tier == 6 and fileExists( texturePathForMoto ) then
            texturePath = texturePathForMoto
        end

        if not UI_elements[ texturePath ] then
            UI_elements[ texturePath ] = dxCreateTexture( texturePath, "dxt5" )
        end

        ibCreateImage( 5, 0, 80, 80, UI_elements[ texturePath ], bg ):ibData( "alpha", alphaOfIcon and alphaOfIcon or 255 )
        ibCreateLabel( 13, 80, 0, 0, ("TYPE"):gsub( ".", "%1 "):sub( 1, - 2 ), bg, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_8 )

        local charOfType = INTERNAL_PARTS_NAMES_TYPES[ part.subtype ]
        ibCreateLabel( 70, 69, 0, 0, charOfType, bg, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_14 )

        if parent then
            ibCreateLabel( 126, 16, 0, 0, part.name .. " (" .. PARTS_TIER_NAMES[ part.category ] .. ")", parent, nil, nil, nil, nil, nil, ibFonts.semibold_15 )
            ibCreateLabel( 150, 44, 0, 0, part.controllability, parent, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_14 )
            ibCreateLabel( 150, 63, 0, 0, part.clutch, parent, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_14 )
            ibCreateLabel( 150, 84, 0, 0, part.slip, parent, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_14 )
            ibCreateLabel( 214, 51, 0, 0, part.speed, parent, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_14 )
            ibCreateLabel( 214, 74, 0, 0, part.acceleration, parent, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_14 )

            if amount and amount > 1 then
                local bg_amount = ibCreateImage( 58, 2, 30, 20, nil, bg, 0x55000000 )
                ibCreateLabel( 0, 0, 30, 20, "x" .. amount, bg_amount, ibApplyAlpha( 0xffffffff, 75 ), nil, nil, "center", "center", ibFonts.oxaniumregular_11 )
            end
        end

        ibUseRealFonts( false )
    end

    return bg
end

function UpdatePartsMenu( )
    local parts = DATA.installed_parts or DATA.parts
    local preview_parts = DATA.preview_parts or { }

    local npx, npy = 10, 0

    for i = 1, wParts.sections do
        local element_id = "part_section_" .. i
        if isElement( UI_elements[ element_id ] ) then destroyElement( UI_elements[ element_id ] ) end

        local partData = parts[ i ]
        local partID = ( partData and partData.id ) or preview_parts[ i ]
        local damaged = ( partData and partData.damaged ) or 0
        local part = getTuningPartByID( partID, DATA.vehicle:GetTier( ) )
        local bg = CreatePartElement( npx, npy, part, nil, ( preview_parts[ i ] or damaged >= 1 ) and 125 or nil )

        if part then
            part.damaged = partData and partData.damaged
        end

        ibCreateLabel( wParts.section_sx + 20, wParts.section_sy / 2, 0, 0, PARTS_NAMES[ i ], bg ):ibBatchData( { align_y = "center", font = ibFonts.regular_12, color = 0xfffefefe } )
        local area = ibCreateArea( 0, 0, wParts.section_sx, wParts.section_sy, bg )

        addEventHandler( "ibOnElementMouseEnter", area, function( )
            -- bg:ibData( "texture", "img/bg_part_hover.png" )

            if part and not IsFloatingPartVisible( ) then
                CreatePartHint( part )
            end
        end, false )

        addEventHandler( "ibOnElementMouseLeave", area, function( )
            -- bg:ibData( "texture", "img/bg_part.png" )

            DestroyPartHint( )
        end, false )

        addEventHandler( "ibOnElementMouseClick", area, function( key, state )
            if key == "left" and state == "down" then
                CreateFloatingPart( part, DRAG_TYPE_FROM_VEHICLE )
            elseif key == "left" and state == "up" then
                local part = GetFloatingPart( )

                if part then
                    local tier = DATA.vehicle:GetTier( )
                    if DATA.current_tier ~= tier then
                        localPlayer:ErrorWindow( "Эта деталь не подходит для данного транспорта" )
                        return
                    end

                    if part.type ~= i then
                        localPlayer:ErrorWindow( "Каждая деталь должна быть установлена в свой слот" )
                        return
                    else
                        if parts[ i ] then
                            localPlayer:ErrorWindow( "Чтоб поставить другую деталь,\nнужно сначала освободить слот!" )
                            return
                        end

                        if confirmation then
                            confirmation:destroy( )
                        end

                        addPartForPreview( part.id, i )
                    end
                end

                ResetFloatingPart( )
            elseif key == "right" and state == "up" then
                if preview_parts[ i ] then
                    CreateFloatingPart( part, DRAG_TYPE_FROM_VEHICLE )
                    removePartFromPreview( )

                elseif parts[ i ] then
                    triggerServerEvent( "onPartSellFromVehicleAttempt", resourceRoot, part.id )
                end
            end
        end, false )

        UI_elements[ element_id ] = bg

        npy = npy + wParts.section_sy + wParts.gap
    end

    if next( preview_parts ) and not isElement( UI_elements.install_parts ) then
        UI_elements.install_parts = ibCreateButton( npx, npy, wParts.save_sx, wParts.save_sy, UI_elements.area_parts,
    "img/save.png", "img/save_hover.png", "img/save_hover.png" )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibConfirm( {
                title = "УСТАНОВКА ДЕТАЛЕЙ",
                text = "Ты точно хочешь установить данные детали?\nИх снятие станет возможным только через продажу",
                fn = function( self )
                    self:destroy()
                    DATA.preview_parts = { }
                    triggerServerEvent( "onPartInstallAttempt", resourceRoot, preview_parts )
                end,
                escape_close = true,
            } )
        end )
    elseif not next( preview_parts ) and isElement( UI_elements.install_parts ) then
        UI_elements.install_parts:destroy( )
        UI_elements.install_parts = nil
    end
end

function CreatePartHint( part )
    DestroyPartHint( )

    local cx, cy = getCursorPosition( )
    cx, cy = cx * x, cy * y

    local hint_sx, hint_sy = 200, 117
    local bg = ibCreateImage( cx + 10, cy + 10, hint_sx, hint_sy, "img/bg_hint.png", _, 0xffffffff ):ibBatchData( { alpha = 0, disabled = true } )
    bg:ibAlphaTo( 255, 150, "OutQuad" )

    ibCreateLabel( 20, 10, 0, 0, PARTS_NAMES[ part.type ] .. " - " .. part.name .. " (" .. PARTS_TIER_NAMES[ part.category ] .. ")", bg )
    :ibBatchData( { font = ibFonts.bold_10, color = 0xffffffff } )

    local value_positions = {
        { 42, 43 },
        { 42, 65 },
        { 42, 87 },
        { 130, 53 },
        { 130, 76 },
    }

    local values = {
        part.controllability, part.clutch, part.slip, part.speed, part.acceleration
    }

    for i, v in pairs( values ) do
        local width = dxGetTextWidth( math.abs( v ), 1, ibFonts.regular_12 )

        local px, py = unpack( value_positions[ i ] )
        local is_changed = v ~= 0
        ibCreateLabel( px + 4, py, 0, 0, math.abs( v ), bg ):ibBatchData( { font = ibFonts.oxaniumbold_10, color = v < 0 and 0xffff3a3a or v > 0 and 0xff00ff63 or 0xffffffff } )

        if is_changed then
            local icon_texture = v < 0 and "img/icon_arrowdown_red.png" or v > 0 and "img/icon_arrowup_green.png"
            local icon_px, icon_py = px + 5 + width, py + 1
            local icon_sx, icon_sy = 27 * 0.6, 24 * 0.6
            ibCreateImage( icon_px, icon_py, icon_sx, icon_sy, icon_texture, bg )
        end
    end

    if ( part.damaged or 0 ) >= 1 then
        ibCreateLabel( 105, 95, 0, 0, "Изношена", bg ):ibBatchData( { font = ibFonts.oxaniumbold_9, color = 0xffff3a3a } )
    end

    UI_elements.part_hint = bg
    addEventHandler( "onClientCursorMove", root, RenderMovePartHint )
end

function DestroyPartHint( )
    removeEventHandler( "onClientCursorMove", root, RenderMovePartHint )
    if isElement( UI_elements.part_hint ) then destroyElement( UI_elements.part_hint ) end
end

function RenderMovePartHint( _, _, ax, ay )
    UI_elements.part_hint:ibBatchData( { px = ax + 10, py = ay + 10 } )
end

function removePartFromPreview( )
    local part = GetFloatingPart( )

    if part and GetFloatingPartDragType( ) == DRAG_TYPE_FROM_VEHICLE then
        for idx, id in pairs( DATA.preview_parts or { } ) do
            if id == part.id then
                DATA.preview_parts[ idx ] = nil
                break
            end
        end

        DestroyFloatingPart( )
        ResetFloatingPart( )
        UpdatePartsMenu( )
        RefreshBottomBar( )
    end
end

function addPartForPreview( partID, slot )
    if not DATA.preview_parts then
        DATA.preview_parts = { }
    end

    DATA.preview_parts[ slot ] = partID

    UpdatePartsMenu( )
    RefreshBottomBar( )
end

function onPartsListUpdate_handler( parts, new_stats )
    DATA.installed_parts = parts
    DATA.new_stats = new_stats
    
    UpdatePartsMenu( )
    RefreshBottomBar( )
end
addEvent( "onPartsListUpdate", true )
addEventHandler( "onPartsListUpdate", root, onPartsListUpdate_handler )