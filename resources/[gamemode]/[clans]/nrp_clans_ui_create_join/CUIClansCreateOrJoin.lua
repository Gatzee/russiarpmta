Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

function ShowClanCreateOrJoinUI( state, base_id )
    if state then
        ShowClanCreateOrJoinUI( false )
        ShowClanCreateUI( false )
        ShowClanJoinUI( false )
        ibInterfaceSound()

        SELECTED_BASE_ID = base_id or SELECTED_BASE_ID

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowClanCreateOrJoinUI, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 95 ) ):center( )

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 90, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                      ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
        UI.head_lbl = ibCreateLabel( 30, 0, 0, UI.head_bg:ibData( "sy" ), "Стань частью бандитского мира", UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
        
        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanCreateOrJoinUI( false )
            end )

        UI.body = ibCreateArea( 0, UI.head_bg:ibGetAfterY( ), 0, 0, UI.bg )
        
        UI.bg_create = ibCreateImage( 28, 28, 475, 620, "img/bg_panel.png", UI.body )
        UI.bg_create_hover = ibCreateImage( 0, 0, 475, 620, "img/bg_panel_hover.png", UI.bg_create ):ibData( "alpha", 0 )
            :ibOnHover( function() source:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnLeave( function() source:ibAlphaTo( 0, 500, "OutQuad" ) end)
        
        UI.bg_join = ibCreateImage( UI.bg_create:ibGetAfterX( 18 ), 28, 475, 620, "img/bg_panel.png", UI.body )
        UI.bg_join_hover = ibCreateImage( 0, 0, 475, 620, "img/bg_panel_hover.png", UI.bg_join ):ibData( "alpha", 0 )
            :ibOnHover( function() source:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnLeave( function() source:ibAlphaTo( 0, 500, "OutQuad" ) end)

        ibCreateImage( 30, 30, 964, 509, "img/panels.png", UI.body ):ibData( "disabled", true )

        UI.btn_create = ibCreateButton( UI.bg_create:ibGetCenterX( -182 / 2 ), UI.bg_create:ibGetAfterY( -2 - 30 - 45 ), 182, 45, UI.body, 
                "img/btn_create.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnHover( function() UI.bg_create_hover:ibAlphaTo( 255, 500, "OutQuad" ) end)
            -- :ibOnLeave( function() UI.bg_create_hover:ibAlphaTo( 0, 500, "OutQuad" ) end)
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanCreateOrJoinUI( false )
                ShowClanCreateUI( true )
            end )

        UI.btn_join = ibCreateButton( UI.bg_join:ibGetCenterX( -182 / 2 ), UI.bg_join:ibGetAfterY( -2 - 30 - 45 ), 182, 45, UI.body, 
                "img/btn_join.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnHover( function() UI.bg_join_hover:ibAlphaTo( 255, 500, "OutQuad" ) end)
            -- :ibOnLeave( function() UI.bg_join_hover:ibAlphaTo( 0, 500, "OutQuad" ) end)
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanCreateOrJoinUI( false )
                ShowClanJoinUI( true )
            end )

        local py = UI.bg:ibData( "py" )
        UI.bg:ibBatchData( { py = py - 100, alpha = 0 } )
            :ibAlphaTo( 255, 500 )
            :ibMoveTo( _, py, 500 )
        
        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "ShowClanCreateOrJoinUI", true )
addEventHandler( "ShowClanCreateOrJoinUI", root, ShowClanCreateOrJoinUI )