loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ib" )
ibUseRealFonts( true )

function ShowBonusUI( state )
    if state then
        ShowBonusUI( false )

        UI_elements = { }
        local x, y = guiGetScreenSize()

        UI_elements.black_bg    = ibCreateBackground( _, _, 0xaa000000 )
        UI_elements.bg_texture  = dxCreateTexture( "img/bg.png" )

        local sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2

        local elastic_duration  = 2200
        local alpha_duration    = 700

        UI_elements.bg
            = ibCreateImage( px, py + 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg )
            :ibData( "alpha", 0 )
            :ibMoveTo( px, py, elastic_duration, "OutElastic" )
            :ibAlphaTo( 255, alpha_duration )

        UI_elements.button_close
            = ibCreateButton(   sx - 24 - 26, 26, 24, 24, UI_elements.bg,
                                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowBonusUI( false )
            end )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        UI_elements = nil
        showCursor( false )
    end
end

function Show6SBonusUI_handler( )
    ShowBonusUI( true )
end
addEvent( "Show6SBonusUI", true )
addEventHandler( "Show6SBonusUI", root, Show6SBonusUI_handler )