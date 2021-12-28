local bg_img

function ShowArmyfreeUI( state, source, info )
    if not localPlayer:SetStateShowDocuments( state, source ) then return end

    if state then
        showCursor( true )

        local bg_sx, bg_sy = 483, 261
        bg_img = ibCreateImage( 0, 0, bg_sx, bg_sy, "img/armyfree_bg.png" )
            :center():ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

        ibCreateLabel( 30, 40, 0, 0, "Увольнительная", bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_19 )

        ibCreateLabel( 30, 90, 0, 0, "Увольнительная выдана:", bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.regular_16 )

        ibCreateLabel( 232, 90, 0, 0, info.name, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_16 )
				
		info.date = info.date - getRealTimestamp( )
		local time_data = ConvertSecondsToTime( info.date )		
		local text = info.date > 0 and ( "Действительна ".. ( time_data.hour > 0 and ( time_data.hour .." ч. " ) or "" ) .. time_data.minute .." мин." ) or "Просрочена"
        ibCreateLabel( 30, 115, 0, 0, text, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_16 )

        local text = "В случае если Вы не вернетесь в указанные сроки\nобратно на службу, вы будете объявлены в розыск\nвоенной полицией"
        ibCreateLabel( 30, 190, 0, 0, text, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.regular_16 )

	    ibCreateButton( bg_sx - 24, -24 - 6, 24, 24, bg_img, 
                        "img/button_close.png", "img/button_close.png", "img/button_close.png",
                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowArmyfreeUI( false )
            end )
    else
        if isElement( bg_img ) then
            destroyElement( bg_img )
        end
        showCursor( false )
    end
end

addEvent( "ShowArmyfreeUI", true )
addEventHandler( "ShowArmyfreeUI", root, onDocumentPreShow )