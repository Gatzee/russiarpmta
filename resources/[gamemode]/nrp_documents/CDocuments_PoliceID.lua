local bg_img

function ShowUI_PoliceID( state, source, data )
	if not localPlayer:SetStateShowDocuments( state, source ) then return end

	if state then
		showCursor( true )

        local bg_sx, bg_sy = 800, 250
		bg_img = ibCreateImage( 0, 0, bg_sx, bg_sy, "img/policeid_bg.png" )
            :center():ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
		
		ibCreateButton( bg_sx - 24, -26, 24, 24, bg_img, 
						"img/button_close.png", "img/button_close.png", "img/button_close.png", 
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( btn, state )
				if btn == "left" and state == "down" then
					ShowUI_PoliceID( false )
				end 
			end)


		ibCreateLabel( 490, 98, 0, 0, data.name, bg_img, 0xff000000, _, _, _, _, ibFonts.bold_18 )
		ibCreateLabel( 515, 132, 0, 0, FACTIONS_LEVEL_NAMES[ data.faction ][ data.faction_rank ], bg_img, 0xff000000, _, _, _, _, ibFonts.bold_18 )
		ibCreateLabel( 585, 164, 0, 0, FACTIONS_SHORT_NAMES[ data.faction ] or "", bg_img, 0xff000000, _, _, _, _, ibFonts.bold_18 )
	else
        if isElement( bg_img ) then
            destroyElement( bg_img )
        end
		showCursor( false )
	end
end

addEvent( "ShowUI_PoliceID", true )
addEventHandler( "ShowUI_PoliceID", root, onDocumentPreShow )