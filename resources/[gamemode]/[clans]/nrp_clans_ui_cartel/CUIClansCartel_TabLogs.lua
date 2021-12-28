TAX_STATUS_IMGS = {
    [ CARTEL_TAX_PAYED ] = "img/status_1.png",
    [ CARTEL_TAX_SAVED ] = "img/status_2.png",
    [ CARTEL_TAX_TAKEN ] = "img/status_3.png",
}

TABS_CONF.logs = {
    fn_create = function( self, parent )

        local col_px = 0
        local row_sy = 50
        local bg_row
        local columns = {
            {
                title = "Клан",
                sx = 250,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, v[ CT_LOG_CLAN_NAME ], bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                end,
            },
            {
                title = "Дата",
                sx = 250,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, os.date( "%d/%m/%Y %H:%M", v[ CT_LOG_DATE ] ), bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                end,
            },
            {
                title = "Сумма",
                sx = 220,
                fn_create = function( self, k, v )
                    local lbl = ibCreateLabel( col_px, 0, 0, row_sy, format_price( v[ CT_LOG_VALUE ] or 0 ), bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )
                    ibCreateImage( lbl:width( ) + 5, 0, 22, 22, ":nrp_shared/img/money_icon.png", lbl )
                        :center_y( )
                end,
            },
            {
                title = "Статус",
                sx = 200,
                fn_create = function( self, k, v )
                    ibCreateImage( col_px, 0, 0, 0, TAX_STATUS_IMGS[ v[ CT_LOG_TAX_STATUS ] ], bg_row )
                        :ibSetRealSize( )
                        :center_y( )
                end,
            },
        }

        col_px = 30
        for i, col in pairs( columns ) do
            ibCreateLabel( col_px, 20, 0, 0, col.title, parent, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "top", ibFonts.regular_12 )
            col_px = col_px + col.sx
        end
        
        local scrollpane, scrollbar

        function UpdateCartelTaxLog( )
            if isElement( scrollpane ) then
                scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
                scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            scrollpane, scrollbar = ibCreateScrollpane( 0, 40, 
                parent:ibData( "sx" ), parent:ibData( "sy" ) - 40, 
                parent, { scroll_px = -20 }
            )
            scrollbar:ibSetStyle( "slim_nobg" )
            
            for k, v in pairs( CLAN_DATA.tax_log or { } ) do
                local v = CLAN_DATA.tax_log[ #CLAN_DATA.tax_log + 1 - k ]
                bg_row = ibCreateImage( 0, ( k - 1 ) * row_sy, parent:ibData( "sx" ), row_sy, _, scrollpane, 0xFF41546a * ( k % 2 ) )
                col_px = 30
                for col_i, col in pairs( columns ) do
                    col:fn_create( k, v )
                    col_px = col_px + col.sx
                end
            end

            scrollpane:AdaptHeightToContents( )
            scrollbar:UpdateScrollbarVisibility( scrollpane )
        end
        UpdateCartelTaxLog(  )
        UPDATE_UI_HANDLERS.tax_log = UpdateCartelTaxLog
    end,
}