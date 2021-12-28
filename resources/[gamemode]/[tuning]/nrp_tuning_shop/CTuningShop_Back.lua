function GoBack( )
    LAST_MENU_TASK = nil
    if type( UI_elements.back_fn ) == "function" then
        UI_elements.back_fn( unpack( UI_elements.back_args ) )
    end
end

function CreateBackButton( )
    ResetBackButton( )

    UI_elements.bg_back            = ibCreateImage( wSide.px, wSide.py + wSide.sy, wSide.sx, wSide.back_sy, _, _, 0xf03e5165 )
    UI_elements.bg_back_icon       = ibCreateImage( 15, wSide.back_sy / 2 - 10, 18, 20, "img/icon_exit.png", UI_elements.bg_back )
    UI_elements.bg_back_label_exit = ibCreateLabel( 45, wSide.back_sy / 2, 0, 0, "Выйти", UI_elements.bg_back ):ibBatchData( { align_y = "center", font = ibFonts.semibold_12 } )
    UI_elements.bg_back_label_back = ibCreateLabel( 15, wSide.back_sy / 2, 0, 0, "Назад", UI_elements.bg_back ):ibBatchData( { align_y = "center", font = ibFonts.semibold_12, alpha = 0 } )
    UI_elements.bg_back_btn        = ibCreateArea( 0, 0, wSide.sx, wSide.back_sy, UI_elements.bg_back )

    addEventHandler( "ibOnElementMouseClick", UI_elements.bg_back_btn, function( key, state )
        if key ~= "left" or state ~= "up" then return end

        if ( UI_elements.bg_back_icon:ibData( 'alpha' ) > 0 and #CartGet( ) > 0 ) or next( DATA.preview_parts or { } ) then
            if confirmation_back then confirmation_back:destroy() end

            confirmation_back = ibConfirm( {
                title = "ПОДТВЕРЖДЕНИЕ ВЫХОДА",
                text =  #CartGet() > 0 and "Ваша корзина не пуста\nВы действительно хотите выйти?" or "Установленные детали в состоянии \"примерки\".\nВы действительно хотите выйти?",
                black_bg = 0xaa000000,
                priority = 10,
                fn = function( self )
                    self:destroy()
                    ibClick()
                    GoBack( )
                end,
                escape_close = true,
            } )
        else
            ibClick()
            GoBack( )
        end
    end, false )

    addEventHandler( "ibOnElementMouseEnter", UI_elements.bg_back_btn, function( )
        UI_elements.bg_back:ibData( "color", 0xff334050 )
    end )

    addEventHandler( "ibOnElementMouseLeave", UI_elements.bg_back_btn, function( )
        UI_elements.bg_back:ibData( "color", 0xff404f64 )
    end )
end

BACK_STYLE_EXIT = 1
BACK_STYLE_BACK = 2

function SetBackStyle( style )
    if not isElement( UI_elements.bg_back ) then return end

    if style == BACK_STYLE_EXIT then
        UI_elements.bg_back_icon:ibAlphaTo( 255, 200 )
        UI_elements.bg_back_label_exit:ibAlphaTo( 255, 200 )
        UI_elements.bg_back_label_back:ibAlphaTo( 0, 200 )

    elseif style == BACK_STYLE_BACK then
        UI_elements.bg_back_icon:ibAlphaTo( 0, 200 )
        UI_elements.bg_back_label_exit:ibAlphaTo( 0, 200 )
        UI_elements.bg_back_label_back:ibAlphaTo( 255, 200 )

    end
end

function SetBackButtonGoHome( )
    UI_elements.back_fn       = function()
        DestroyColorpicker( )
        DestroyColorlist( )

        HideInventory( )
        HidePartsSell( )
        HidePartsMenu( )
        HideNumbersList( )

        RegenerateMenuTree( true )
        ShowSidebar( )
        
        HideCases( )

        HideVinylCases()
        HideVinylsMenu()
        HideVinylsSell()

        HideWheelsEditor( )
        HideNeonsList( )
        
        ResetBackButton( )

        ShowBottombar( )
    end
    UI_elements.back_args     = { }
    SetBackStyle( BACK_STYLE_BACK )
end

function SetBackButtonFunction( fn, ... )
    UI_elements.back_fn = fn
    UI_elements.back_args = { ... }

    SetBackStyle( BACK_STYLE_BACK )
end

function ResetBackButton( )
    UI_elements.back_fn       = function()
        if next( DATA.installed_vinyls ) then
            triggerServerEvent( "onServerCompleteApplyVinyls", resourceRoot, DATA.installed_vinyls )
        end
        triggerServerEvent( "onTuningShopLeaveRequest", resourceRoot )
    end
    UI_elements.back_args     = { }
    UI_elements.back_menu     = nil

    SetBackStyle( BACK_STYLE_EXIT )
end

function ShowBackButton( instant )
    if instant then
        UI_elements.bg_back:ibBatchData(
            {
                px = wSide.px, py = wSide.py + wSide.sy
            }
        )

    else
        UI_elements.bg_back:ibMoveTo( wSide.px, wSide.py + wSide.sy, 150 * ANIM_MUL, "OutQuad" )

    end
end

function HideBackButton( instant )
    if instant then
        UI_elements.bg_back:ibBatchData(
            {
                px = x, py = wSide.py + wSide.sy
            }
        )
    else
        UI_elements.bg_back:ibMoveTo( x, wSide.py, 150 * ANIM_MUL, "OutQuad" )

    end
end
