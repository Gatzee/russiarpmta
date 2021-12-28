IS_HOME_MENU = false

function CreateBottombar( )
    ibUseRealFonts( true )

    UI_elements.bg_bottom = ibCreateImage( wBottom.px, wBottom.py, wBottom.sx, wBottom.sy, "img/bg_bottom.png" )

    UI_elements.lbl_speed = ibCreateLabel( 363, 36, 0, 0, "Максимальная скорость:", UI_elements.bg_bottom ):ibBatchData( { font = ibFonts.regular_14, color = 0xaaffffff } )
    UI_elements.lbl_acceleration = ibCreateLabel( 363, 92, 0, 0, "Ускорение:", UI_elements.bg_bottom ):ibBatchData( { font = ibFonts.regular_14, color = 0xaaffffff } )

    UI_elements.lbl_speed_stat = ibCreateLabel( 590, 36, 0, 0, "000", UI_elements.bg_bottom ):ibBatchData( { font = ibFonts.regular_14, align_x = "right" } )
    UI_elements.lbl_acceleration_stat = ibCreateLabel( 590, 92, 0, 0, "000", UI_elements.bg_bottom ):ibBatchData( { font = ibFonts.regular_14, align_x = "right" } )

    UI_elements.icon_speed = ibCreateImage( 320, 48, 30, 30, "img/icon_speed.png", UI_elements.bg_bottom )
    UI_elements.icon_next = ibCreateImage( 320, 108, 30, 30, "img/icon_next.png", UI_elements.bg_bottom )

    UI_elements.bg_speed = ibCreateImage( 363, 58, 228, 17, nil, UI_elements.bg_bottom, 0xFF3e5266 )
    UI_elements.bg_acceleration = ibCreateImage( 363, 114, 228, 17, nil, UI_elements.bg_bottom, 0xFF3e5266 )

    UI_elements.bg_speed_stat_preview = ibCreateImage( 0, 0, 128, 17, nil, UI_elements.bg_speed, 0x88ff965d )
    UI_elements.bg_acceleration_stat_preview = ibCreateImage( 0, 0, 50, 17, nil, UI_elements.bg_acceleration, 0x88ff965d )

    UI_elements.bg_speed_stat = ibCreateImage( 0, 0, 128, 17, nil, UI_elements.bg_speed, 0xFFff965d )
    UI_elements.bg_acceleration_stat = ibCreateImage( 0, 0, 50, 17, nil, UI_elements.bg_acceleration, 0xFFff965d )

    ibUseRealFonts( false )

    RefreshBottomBar( )
end

function ShowBottombar( instant, cartIsActive )
    if cartIsActive == nil then
        local py = UI_elements.bg_bottom_cart and UI_elements.bg_bottom_cart:ibData( "py" ) or 0
        cartIsActive = wBottomCart.py == py
    end

    if instant then
        UI_elements.bg_bottom:ibBatchData( { px = wBottom.px, py = wBottom.py - ( cartIsActive and 90 or 0 ) } )
    else
        UI_elements.bg_bottom:ibMoveTo( wBottom.px, wBottom.py - ( cartIsActive and 90 or 0 ), 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideBottombar( instant )
    if instant then
        UI_elements.bg_bottom:ibBatchData( { px = wBottom.px, py = y } )
    else
        UI_elements.bg_bottom:ibMoveTo( wBottom.px, y, 150 * ANIM_MUL, "OutQuad" )
    end
end

function RefreshBottomBar( )
    local maxSpeed, maxAcceleration = 400, 400
    local speed, acceleration, controllability, clutch, slip = unpack( ( DATA.new_stats or DATA.now_stats ) or { 0, 0, 0, 0, 0 } )
    local oControllability, oClutch, oSlip = 100, 100, 100
    local pSpeed, pAcceleration, pControllability, pClutch, pSlip = DATA.vehicle:GetStats( DATA.preview_parts or { }, true )

    controllability = controllability + oControllability
 --   clutch = clutch + oClutch
    clutch = 100
 --   slip = slip + oSlip
    slip = 100

    UI_elements.lbl_speed_stat:ibData( "text", speed )
    UI_elements.lbl_acceleration_stat:ibData( "text", acceleration )

    local maxSpeedV = math.floor( speed / maxSpeed * 228 )
    local accelerationV = math.floor( acceleration / maxAcceleration * 228 )

    UI_elements.bg_speed_stat:ibResizeTo( maxSpeedV > 228 and 228 or maxSpeedV, 17, 500, "InOutQuad" )
    UI_elements.bg_acceleration_stat:ibResizeTo( accelerationV > 228 and 228 or accelerationV, 17, 500, "InOutQuad" )

    local maxSpeedPreviewV = math.floor( ( speed + pSpeed ) / maxSpeed * 228 )
    local accelerationPreviewV = math.floor( ( acceleration + pAcceleration ) / maxAcceleration * 228 )

    UI_elements.bg_speed_stat_preview:ibResizeTo( maxSpeedPreviewV > 228 and 228 or maxSpeedPreviewV, 17, 250, "InOutQuad" )
    UI_elements.bg_acceleration_stat_preview:ibResizeTo( accelerationPreviewV > 228 and 228 or accelerationPreviewV, 17, 250, "InOutQuad" )

    if isElement( UI_elements.triangle ) then UI_elements.triangle:destroy( ) end

   -- UI_elements.triangle = generateTriangleTexture( 140, 41, UI_elements.bg_bottom, controllability, clutch, slip,
  --  controllability + pControllability, clutch + pClutch, slip + pSlip )
end