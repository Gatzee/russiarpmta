local bg_img

function ShowMilitaryUI( state, source, info )
    if not localPlayer:SetStateShowDocuments( state, source ) then return end

    if state then
        showCursor( true )

        local bg_sx, bg_sy = 483, 360
        bg_img = ibCreateImage( 0, 0, bg_sx, bg_sy, "img/military_bg.png" )
            :center():ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

        local doc_name = info.faction > 0 and "Служебное удостоверение №" or "Военное удостоверение №"
        ibCreateLabel( 30, 40, 0, 0, doc_name .. info.userid, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_19 )

        local first_name, last_name = unpack( split( info.name, " " ) )
        ibCreateLabel( 455, 152, 0, 0, first_name, bg_img, 
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )        
        ibCreateLabel( 455, 100, 0, 0, last_name, bg_img, 
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )

        local faction_date = getRealTime( info.faction_date )
        faction_date.month = faction_date.month + 1
        local day = ( faction_date.monthday < 10 and "0" or "" ) .. faction_date.monthday
        local month = ( faction_date.month < 10 and "0" or "" ) .. faction_date.month
        local year = 1900 + faction_date.year

        local faction_date_str = day .. "/" .. month .. "/" .. year

        ibCreateLabel( 27, 320, 0, 0, faction_date_str, bg_img, 
                       0xFF000000, 1, 1, "left", "center", ibFonts.bold_17 )

        local faction = info.faction_name or FACTIONS_SHORT_NAMES[ info.faction ] or ( info.faction_rank < 4 and "Срочник" or "В запасе" )
        ibCreateLabel( 455, 200, 0, 0, faction, bg_img,
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )

        local city = HOMETOWNS[ tonumber( info.on_duty ) or 1 ] or FACTION_HOMETOWN[ info.faction ]
        ibCreateLabel( 455, 252, 0, 0, city, bg_img,
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )

        local rank = FACTIONS_NAMES[ info.faction ] and FACTIONS_LEVEL_NAMES[ info.faction ][ info.faction_rank ] or MILITARY_LEVEL_NAMES[ info.faction_rank ]
        ibCreateLabel( 455, 300, 0, 0, rank, bg_img, 
                       0xFF000000, 1, 1, "right", "center", ibFonts.bold_17 )

        ibCreateContentImage( 31, 72, 130, 160, "skin", info.skin.s1 or 1, bg_img )
		local militaryPath = ""
		if faction == "Срочник" or faction == "В запасе" then militaryPath = "military/" end
		local img = ":nrp_factions_ui_info/images/ranks/".. FACTIONS_LEVEL_ICONS[ info.faction > 0 and info.faction or F_ARMY ] .."/"..militaryPath..info.faction_rank..".png"
		ibCreateImage( 163 - 38, 230 - 47, 38, 47, img, bg_img )

	    ibCreateButton( bg_sx - 24, -24 - 6, 24, 24, bg_img, 
                        "img/button_close.png", "img/button_close.png", "img/button_close.png",
                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowMilitaryUI( false )
            end )
    else
        if isElement( bg_img ) then
            destroyElement( bg_img )
        end
        showCursor( false )
    end
end

addEvent( "ShowMilitaryUI", true )
addEventHandler( "ShowMilitaryUI", root, onDocumentPreShow )