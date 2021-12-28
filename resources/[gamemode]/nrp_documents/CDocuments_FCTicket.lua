local bg_img

function ShowFCTicketUI( state, source, data )
    if not localPlayer:SetStateShowDocuments( state, source ) then return end

	if state then
		showCursor( true )

        local bg_sx, bg_sy = 800, 580
        bg_img = ibCreateImage( 0, 0, bg_sx, bg_sy, "img/fcticket_bg.png" )
            :center( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )

		ibCreateLabel( 38, 172, 0, 0, data.name, bg_img,
                       0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_19 )

		local days = math.ceil( data.time_left / 60 / 60 / 24 )
		ibCreateLabel( 38, 300, 0, 0, days .. plural( days, " день", " дня", " дней" ), bg_img,
                       0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_19 )

	    ibCreateButton( bg_sx - 24, -24 - 6, 24, 24, bg_img, 
                        "img/button_close.png", "img/button_close.png", "img/button_close.png",
                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowFCTicketUI( false )
            end )
    else
        if isElement( bg_img ) then
            destroyElement( bg_img )
        end
		showCursor( false )
	end
end

addEvent( "ShowFCTicketUI", true )
addEventHandler( "ShowFCTicketUI", root, onDocumentPreShow )