local UIe = { }
local CURRENT_TAB = 1

function CreateUI_MainOffer(  )
	UIe.black_bg = ibCreateBackground( _, DestroyUI_MainOffer )
	UIe.bg = ibCreateImage( 0, 0, 1024, 720, "images/" .. CURRENT_EVENT .. "/bg_main_offer.png", UIe.black_bg ):center( )

	ibCreateButton(	964, 30, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
		end, false )

	ibCreateButton(	402, 646, 222, 44, UIe.bg, "images/btn_gps", true )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )

			triggerEvent( "ToggleGPS", localPlayer, {
				{ x = 742.594, y = -159.5, z = 20.903 },
				{ x = 2027.349, y = -784.454, z = 60.641 },
				{ x = -100.885, y = -1985.183, z = 20.802 },
				{ x = -54.55, y = 2253.6, z = 21.61 },
			} )
		end, false )

	showCursor( true )
end
addEvent( "ShowEventUIMainOffer" )
addEventHandler( "ShowEventUIMainOffer", resourceRoot, CreateUI_MainOffer )

function DestroyUI_MainOffer( )
	showCursor( false )
end