loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

function onPlayerCasesOfferB_handler( end_time )
    DestroyWindow( )
    showCursor( true )

    UI.black_bg = ibCreateBackground( _, _, true ):ibData( "alpha", 0 )
    UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/group_b/bg.png", UI.black_bg ):ibSetRealSize():center( )

    ibCreateButton( 971, 28, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            DestroyWindow( )
        end, false )

	do
		ibCreateButton( 447, 695, 130, 42, UI.bg, "img/group_b/take.png", "img/group_b/take_h.png" )
			:ibOnClick( function( key, state ) 
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				triggerServerEvent( "onCasesOffersRequestBronze", resourceRoot )
				DestroyWindow( )
			end )
		
		UI.black_bg:ibAlphaTo( 255 )
    end
end

function DestroyWindow( )
    if isElement( UI.black_bg ) then destroyElement( UI.black_bg ) end
    showCursor( false )
end

addEvent( "onPlayerCasesOfferB", true )
addEventHandler( "onPlayerCasesOfferB", resourceRoot, onPlayerCasesOfferB_handler )