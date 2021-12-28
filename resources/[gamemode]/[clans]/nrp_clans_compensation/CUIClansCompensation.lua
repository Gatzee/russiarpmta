loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ib" )

UI = { }

function ShowClansCompensationUI( state )
    if state then
        ShowClansCompensationUI( false )
        ibInterfaceSound( )
        showCursor( true )

        UI.black_bg = ibCreateBackground( 0xBF1D252E, function()
            ShowClansCompensationUI( false )
        end, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 769, "img/bg.png", UI.black_bg, COLOR_WHITE ):center( )
        
        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.bg, 
                ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClansCompensationUI( false )
            end )

        UI.btn_take = ibCreateImage( 0, UI.bg:height( ) - 90, 145, 78, "img/btn_take_hover.png", UI.bg )
            :center_x( 1 )
            :ibData( "alpha", 0 )

        ibCreateArea( 0, UI.bg:height( ) - 72, 111, 42, UI.bg )
            :center_x( )
            :ibOnHover( function( ) UI.btn_take:ibAlphaTo( 255 ) end )
            :ibOnLeave( function( ) UI.btn_take:ibAlphaTo( 0 ) end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClansCompensationUI( false )
            end )

        local py = UI.bg:ibData( "py" )
        UI.bg:ibBatchData( { py = py - 100, alpha = 0 } )
            :ibAlphaTo( 255, 500 )
            :ibMoveTo( _, py, 500 )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "ShowClansCompensationUI", true )
addEventHandler( "ShowClansCompensationUI", root, ShowClansCompensationUI )