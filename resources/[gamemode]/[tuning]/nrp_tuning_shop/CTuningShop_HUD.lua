function CreateHUD( data )
    if isElement( UI_elements.bg_hud ) then destroyElement( UI_elements.bg_hud ) end
    UI_elements.bg_hud = ibCreateImage( wHUD.px, wHUD.py, wHUD.sx, wHUD.sy, "img/bg_money.png" )

    RefreshHUD( )

    addEventHandler( "onClientElementDataChange", localPlayer, ParsePlayerEData )

    addEventHandler( "onClientElementDestroy", UI_elements.bg_hud, function()
        removeEventHandler( "onClientElementDataChange", localPlayer, ParsePlayerEData )
    end, false )
end

function ParsePlayerEData( key )
    if key == "money" then
        RefreshHUD( )
    end
end

function RefreshHUD( )
    if isElement( UI_elements.hud_label ) then destroyElement( UI_elements.hud_label ) end
    if isElement( UI_elements.hud_icon ) then destroyElement( UI_elements.hud_icon ) end

    ibUseRealFonts( true )

    local money = format_price( localPlayer:GetMoney( ) or 0 )
    local width = dxGetTextWidth( money, 1, ibFonts.oxaniumbold_20 )

    UI_elements.hud_label = ibCreateLabel( 325, wHUD.sy / 2, 0, 0, money, UI_elements.bg_hud ):ibBatchData( { align_x = "right", align_y = "center", font = ibFonts.oxaniumbold_20 } )
    UI_elements.hud_icon = ibCreateImage( 325 - width - 14 - 24, wHUD.sy / 2 - 21 / 2, 24, 21, "img/icon_soft.png", UI_elements.bg_hud )

    ibUseRealFonts( false )
end

function ShowHUD( instant )
    if not isElement( UI_elements.bg_hud ) then return end
    if instant then
        UI_elements.bg_hud:ibBatchData(
            {
                px = wHUD.px, py = wHUD.py
            }
        )

    else
        UI_elements.bg_hud:ibMoveTo( wHUD.px, wHUD.py, 150 * ANIM_MUL, "OutQuad" )

    end
end

function HideHUD( instant )
    if not isElement( UI_elements.bg_hud ) then return end
    if instant then
        UI_elements.bg_hud:ibBatchData(
            {
                px = wHUD.px, py = -wHUD.sy
            }
        )

    else
        UI_elements.bg_hud:ibMoveTo( wHUD.px, -wHUD.sy, 150 * ANIM_MUL, "OutQuad" )

    end
end