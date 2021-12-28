function CreatePartsSell( )
    UI_elements.bg_sell = ibCreateImage( wSide.px - 120, wBottomCart.py, 100, 70, "img/bg_sell.png" )
        :ibOnHover( function( ) 
            source:ibData( "texture", "img/bg_sell_hover.png" ) 
        end )
	    :ibOnLeave( function( ) 
            source:ibData( "texture", "img/bg_sell.png" ) 
        end )
        
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            if next( DATA.preview_parts ) then
                localPlayer:ErrorWindow( "Нельзя продавать детали, во время режима \"примерки\"" )
                return
            end

            local part = GetFloatingPart( )
            local drag_type = GetFloatingPartDragType( )

            if not part or ( drag_type ~= DRAG_TYPE_FROM_INVENTORY and drag_type ~= DRAG_TYPE_FROM_VEHICLE ) then
                localPlayer:ErrorWindow( "Эту деталь невозможно продать" )
                return
            end

            if drag_type == DRAG_TYPE_FROM_INVENTORY then
                onPartSellAttempt( part.id )

            elseif drag_type == DRAG_TYPE_FROM_VEHICLE then
                triggerServerEvent( "onPartSellFromVehicleAttempt", resourceRoot, part.id )

            else
                localPlayer:ErrorWindow( "Эту деталь невозможно продать" )
            end
        end )
end

function ShowPartsSell( instant )
    if not isElement( UI_elements.bg_sell ) then return end

    if instant then
        UI_elements.bg_sell:ibBatchData( { px = wSide.px - 120, py = wBottomCart.py } )
    else
        UI_elements.bg_sell:ibMoveTo( wSide.px - 120, wBottomCart.py, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HidePartsSell( instant )
    if not isElement( UI_elements.bg_sell ) then return end
    
    if instant then
        UI_elements.bg_sell:ibBatchData( { px = wSide.px - 120, py = y } )
    else
        UI_elements.bg_sell:ibMoveTo( wSide.px - 120, y, 150 * ANIM_MUL, "OutQuad" )
    end
end

function onPartSellAttempt( partID )
    if confirmation then confirmation:destroy( ) end

    local part = getTuningPartByID( partID, DATA.current_tier )
    if not part then
        return
    end

    local price = getSellPriceOfPart( part )

    confirmation = ibConfirm( {
        title = "ПРОДАЖА ДЕТАЛИ",
        text = "Ты точно хочешь продать\n" .. PARTS_NAMES[ part.type ] .. " - " .. part.name .. " (" .. PARTS_TIER_NAMES[ part.category ] .. ") за " .. format_price( price ) .. " рублей?" ,
        fn = function( self )
            self:destroy( )
            triggerServerEvent( "onPartSellConfirm", resourceRoot, DATA.current_tier, part.id )
        end,
        escape_close = true,
    } )
end

function onPartSellFromVehicleAttemptCallback_handler( partID, price )
    if confirmation then confirmation:destroy( ) end

    local part = getTuningPartByID( partID, DATA.vehicle:GetTier( ) )
    if not part then
        return
    end

    confirmation = ibConfirm( {
        title = "ПРОДАЖА ДЕТАЛИ",
        text = "Ты точно хочешь снять и продать\n" .. PARTS_NAMES[ part.type ] .. " - " .. part.name .. " (" .. PARTS_TIER_NAMES[ part.category ] .. ") за " .. format_price( price ) .. " рублей?" ,
        fn = function( self )
            self:destroy()
            triggerServerEvent( "onPartSellFromVehicleConfirm", resourceRoot, part.id )
        end,
        escape_close = true,
    } )
end
addEvent( "onPartSellFromVehicleAttemptCallback", true )
addEventHandler( "onPartSellFromVehicleAttemptCallback", resourceRoot, onPartSellFromVehicleAttemptCallback_handler )