TABS_CONF.info = {
    fn_create = function( self, parent )
        ibCreateLabel( 0, 0, parent:width( ), 80, "Правила сбора налога Картелем у кланов", parent, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
        
        local pane_head_bg = ibCreateImage( 0, 80, parent:width( ), 40, _, parent, 0xff3f5266 )
        ibCreateLabel( 0, 0, 44, 40, "№", pane_head_bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.regular_12 )
        ibCreateLabel( 60, 0, 0, 40, "Описание правил", pane_head_bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_12 )
        
        ibCreateImage( 0, 120, parent:ibData( "sx" ), parent:ibData( "sy" ) - 120, _, parent, 0xff1f2934 )
        local scrollpane, scrollbar = ibCreateScrollpane( 0, 120, 
            parent:ibData( "sx" ), parent:ibData( "sy" ) - 120, 
            parent, { scroll_px = -20 }
        )
        scrollbar:ibSetStyle( "slim_nobg" )
    
        local row_sx = parent:width( )
        local row_sy = 50
        for i, text in pairs( exports.nrp_clans_ui_cartel_tax:GetTaxRules( ) or { } ) do
            local bg_row = ibCreateImage( 0, ( i - 1 ) * row_sy, row_sx, row_sy, _, scrollpane, 0x40314050 * ( ( i - 1 ) % 2 ) )
            ibCreateLabel( 0, 0, 44, row_sy, i, bg_row, _, 1, 1, "center", "center", ibFonts.regular_14 )
            ibCreateLabel( 60, 0, row_sx - 60 - 30, row_sy, text, bg_row, _, 1, 1, "left", "center", ibFonts.regular_14 )
                :ibData( "wordbreak", true )
        end
    
        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
}