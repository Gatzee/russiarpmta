UPGRADE_ID_TO_MSG_TEXT = {
    [ CLAN_UPGRADE_SLOTS ] = "Расширение клана",
    [ CLAN_UPGRADE_STORAGE ] = "Покупка хранилища",
    [ CLAN_UPGRADE_ALCO_FACTORY ] = "Улучшение Алко-Цеха",
    [ CLAN_UPGRADE_HASH_FACTORY ] = "Улучшение Цех-Петрушки",
}

LOG_TYPE_TO_TEXT = {
    [ CLAN_LOG_ADD_MONEY ] = function( params ) return "Пополнение общака" end,
    [ CLAN_LOG_UPGRADE ] = function( params ) return UPGRADE_ID_TO_MSG_TEXT[ params.id ] or "Улучшение клана" end,
    [ CLAN_LOG_ITEMS_PURCHASE ] = function( params ) return "Закупка предметов" end,
    [ CLAN_LOG_CHANGE_WAY ] = function( params ) return "Смена пути развития" end,
}

TABS_CONF.logs = {
    fn_create = function( self, parent )
        local col_px = 0
        local row_sy = 50
        local bg_row
        local columns = {
            {
                title = "Номер",
                sx = 90,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, k, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                end,
            },
            {
                title = "Имя",
                sx = 230,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, v.name, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                end,
            },
            {
                title = "Статус",
                sx = 320,
                fn_create = function( self, k, v )
                    local lbl = ibCreateLabel( col_px, 0, 0, row_sy, LOG_TYPE_TO_TEXT[ v.type or 1 ]( v.params ), bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                end,
            },
            {
                title = "Сумма",
                sx = 200,
                fn_create = function( self, k, v )
                    local lbl = ibCreateLabel( col_px, 0, 0, row_sy, format_price( v.value or 0 ), bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                    ibCreateImage( lbl:ibGetAfterX( 5 ), 0, 22, 22, ":nrp_shared/img/money_icon.png", bg_row )
                        :center_y( )
                end,
            },
            {
                title = "Дата",
                sx = 100,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, os.date( "%d/%m/%Y %H:%M", v.date ), bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                end,
            },
        }

        col_px = 30
        for i, col in pairs( columns ) do
            ibCreateLabel( col_px, 20, 0, 0, col.title, parent, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "top", ibFonts.regular_12 )
            col_px = col_px + col.sx
        end
        
        local scrollpane, scrollbar

        function UpdateLastDepositsLog( )
            if isElement( scrollpane ) then
                scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
                scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            scrollpane, scrollbar = ibCreateScrollpane( 0, 40, 
                parent:ibData( "sx" ), parent:ibData( "sy" ) - 40, 
                parent, { scroll_px = -20 }
            )
            scrollbar:ibSetStyle( "slim_nobg" )
            
            for k, v in pairs( CLAN_DATA.money_log or { } ) do
                local v = CLAN_DATA.money_log[ #CLAN_DATA.money_log + 1 - k ]
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
        UpdateLastDepositsLog(  )
        UPDATE_UI_HANDLERS.money_log = UpdateLastDepositsLog
    end,
}