local bg_img

function ShowPassportUI( state, source, info )
    if not localPlayer:SetStateShowDocuments( state, source ) then return end

    if state then
        showCursor( true )

        local bg_sx, bg_sy = 575, 460
        bg_img = ibCreateImage( 0, 0, bg_sx, bg_sy, "img/passport_bg.png" )
            :center():ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

        local first_name, last_name = unpack( split( info.name, " " ) )

        ibCreateLabel( 528, 105, 0, 0, last_name, bg_img, 
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )
        
        ibCreateLabel( 528, 152, 0, 0, first_name, bg_img, 
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )

        local birthday_time = getRealTime( info.birthday )
        birthday_time.month = birthday_time.month + 1
        local day = ( birthday_time.monthday < 10 and "0" or "" ) .. birthday_time.monthday
        local month = ( birthday_time.month < 10 and "0" or "" ) .. birthday_time.month
        local year =  1900 + birthday_time.year
        ibCreateLabel( 452, 202, 0, 0, day, bg_img, 
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )
        
        ibCreateLabel( 474, 202, 0, 0, month, bg_img, 
                       0xFF000000, 1, 1, "center", "center", ibFonts.bold_17 )

        ibCreateLabel( 496, 202, 0, 0, year, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_17 )

        local sex = info.gender == 0 and "Муж." or "Жен."
        ibCreateLabel( 245, 202, 0, 0, sex, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_17 )

        local city = info.start_city == 0 and "Новороссийск" or "Горки-Город"
        ibCreateLabel( 528, 252, 0, 0, city, bg_img,
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )

        local military = info.military >= 4 and "Имеется" or "Нет"
        ibCreateLabel( 528, 300, 0, 0, military, bg_img, 
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )

        local time = getRealTime( info.reg_date )
        time.month = time.month + 1
        local reg_date = ( time.monthday < 10 and "0" or "" ) .. time.monthday 
            .."/".. ( time.month < 10 and "0" or "" ) .. time.month .."/".. ( 1900 + time.year )
        ibCreateLabel( 45, 320, 0, 0, reg_date, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_17 )

        ibCreateContentImage( 46, 82, 130, 160, "skin", info.skin or 1, bg_img )

	    ibCreateButton( bg_sx - 24, -24 - 6, 24, 24, bg_img, 
                        "img/button_close.png", "img/button_close.png", "img/button_close.png",
                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowPassportUI( false )
            end )
    else
        if isElement( bg_img ) then
            destroyElement( bg_img )
        end
        showCursor( false )
    end
end

addEvent( "ShowPassportUI", true )
addEventHandler( "ShowPassportUI", root, onDocumentPreShow )