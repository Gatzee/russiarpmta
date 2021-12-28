TABS_CONF.cartel_info = {
    fn_create = function( self, parent )
        local scrollpane, scrollbar = ibCreateScrollpane( 0, 0, 
            parent:ibData( "sx" ), parent:ibData( "sy" ), 
            parent, { scroll_px = -20 }
        )
        scrollbar:ibSetStyle( "slim_nobg" )

        ibCreateImage( 0, 0, 0, 0, "img/cartel_info/info.png", scrollpane )
        :ibSetRealSize( )

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
}