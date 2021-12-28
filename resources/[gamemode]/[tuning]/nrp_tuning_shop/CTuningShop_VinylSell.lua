function CreateVinylsSell( data )

    if isElement( UI_elements.bg_vinyl_sell ) then return end
    UI_elements.bg_vinyl_sell = ibCreateImage( wBottomVinylSell.px, wBottomVinylSell.py, 86, 86, "img/bg_part.png" )

    UI_elements.bg_vinyl_sell_text = ibCreateLabel( 0, 0, 86, 86, "Снять\nвинил", UI_elements.bg_vinyl_sell, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_13 )
    :ibBatchData( { disabled = true, alpha = 180 } )

    addEventHandler( "ibOnElementMouseEnter", UI_elements.bg_vinyl_sell, function( )
        UI_elements.bg_vinyl_sell:ibData( "texture", "img/bg_part_hover.png" )
        UI_elements.bg_vinyl_sell_text:ibData( "alpha", 255 )
    end, false )

    addEventHandler( "ibOnElementMouseLeave", UI_elements.bg_vinyl_sell, function( )
        UI_elements.bg_vinyl_sell:ibData( "texture", "img/bg_part.png" )
        UI_elements.bg_vinyl_sell_text:ibData( "alpha", 180 )
    end, false )

    addEventHandler( "ibOnElementMouseClick", UI_elements.bg_vinyl_sell, function( key, state )
        if key ~= "left" or state ~= "up" then return end
        local vinyl = GetFloatingVinyl( )
        local drag_type = GetFloatingVinylDragType( )

        if (drag_type ~= DRAG_TYPE_FROM_INVENTORY and drag_type ~= DRAG_TYPE_FROM_VEHICLE) or not vinyl then
            return
        end
        
        if drag_type == DRAG_TYPE_FROM_INVENTORY then
            triggerServerEvent( "onVinylSellAttempt", resourceRoot, vinyl )
        elseif drag_type == DRAG_TYPE_FROM_VEHICLE then
            triggerServerEvent( "onVinylSellFromVehicleAttempt", resourceRoot, vinyl )
        else
            localPlayer:ErrorWindow( "Эту винил невозможно продать" )
            return
        end
    
    end, false )
end

function ShowVinylsSell( instant )
    if not isElement( UI_elements.bg_vinyl_sell ) then return end
    if instant then
        UI_elements.bg_vinyl_sell:ibBatchData(
            {
                px = wBottomVinylSell.px, py = wBottomVinylSell.py
            }
        )
    else
        UI_elements.bg_vinyl_sell:ibMoveTo( wBottomVinylSell.px, wBottomVinylSell.py, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideVinylsSell( instant )
    if not isElement( UI_elements.bg_vinyl_sell ) then return end
    if instant then
        UI_elements.bg_vinyl_sell:ibBatchData(
            {
                px = wBottomVinylSell.px, py = y
            }
        )
    else
        UI_elements.bg_vinyl_sell:ibMoveTo( wBottomVinylSell.px, y, 150 * ANIM_MUL, "OutQuad" )
    end
end

function onVinylSellAttemptCallback_handler( vinyl, price )
    if confirmation then confirmation:destroy() end
    confirmation = ibConfirm(
        {
            title = "ПРОДАЖА ВИНИЛА", 
            text = "Ты точно хочешь продать винил " .. " за " .. price .. "р. ?" ,
            fn = function( self ) 
                self:destroy()
                triggerServerEvent( "onVinylSellConfirm", resourceRoot, vinyl )
            end,
            escape_close = true,
        }
    )
end
addEvent( "onVinylSellAttemptCallback", true )
addEventHandler( "onVinylSellAttemptCallback", root, onVinylSellAttemptCallback_handler )

function onVinylSellFromVehicleAttemptCallback_handler( vinyl, price )
    if confirmation then confirmation:destroy() end
    local type_operation_text = (vinyl[ P_PRICE_TYPE ] == "soft" or vinyl[ P_SALE_NUMBER ] == 2) and ("и продать винил за " .. price .. "р. ?") or (" винил?")
    confirmation = ibConfirm(
        {
            title = vinyl[ P_PRICE_TYPE ] == "soft" and "ПРОДАЖА ВИНИЛА" or "СНЯТИЕ ВИНИЛА",
            text = "Ты точно хочешь снять с машины\n" .. type_operation_text,
            fn = function( self ) 
                self:destroy()
                triggerServerEvent( "onVinylSellFromVehicleConfirm", resourceRoot, vinyl )
            end,
            escape_close = true,
        }
    )
end
addEvent( "onVinylSellFromVehicleAttemptCallback", true )
addEventHandler( "onVinylSellFromVehicleAttemptCallback", root, onVinylSellFromVehicleAttemptCallback_handler )
