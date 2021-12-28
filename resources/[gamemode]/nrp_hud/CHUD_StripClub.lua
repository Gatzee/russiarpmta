HUD_CONFIGS.strip_club = {
    elements = { },

    create = function( self, help_info )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_strip_club.png", bg )
        self.elements.bg = bg
        
        ibCreateImage( 10, 7, 52, 66, ":nrp_strip_club/files/img/hud_icon.png", bg )
        ibCreateLabel( 70, 0, 0, 80, help_info, bg, 0xFFFFFFFF, _, _, _, "center", ibFonts.regular_11 )
        
        return bg
    end,

    destroy = function( self )
        local to_destroy = { self.elements.bg }
        DestroyTableElements( to_destroy )
        
        self.elements = { }
    end,
}

function ShowStripClubInfo_handler( help_info )
	AddHUDBlock( "strip_club", help_info )
end
addEvent( "ShowStripClubInfo", true )
addEventHandler( "ShowStripClubInfo", root, ShowStripClubInfo_handler )

function HideStripClubInfo_handler( )
    RemoveHUDBlock( "strip_club" )
end
addEvent( "HideStripClubInfo", true )
addEventHandler( "HideStripClubInfo", root, HideStripClubInfo_handler )