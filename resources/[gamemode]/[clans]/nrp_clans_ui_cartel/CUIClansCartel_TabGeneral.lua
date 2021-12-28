TAX_STATUS_TEXTS = {
    [ 0 ] = "Клан слишком мелкий",
    [ CARTEL_TAX_NOT_REQUESTED ] = "Налог не запрошен",
    [ CARTEL_TAX_WAITING ] = "Ожидание ответа",
    [ CARTEL_TAX_OTHER_WAITING ] = "Другой картель запросил налог",
    [ CARTEL_TAX_REFUSED ] = "Отказ платить",
    [ CARTEL_TAX_PAYED ] = "Оплачено",
    [ CARTEL_TAX_SAVED ] = "Клан отбился от налога",
    [ CARTEL_TAX_TAKEN ] = "Ограблен",
    [ CARTEL_TAX_FIGHT ] = "Вы объявили войну",
    [ CARTEL_TAX_OTHER_FIGHT ] = "Другой картель объявил войну",
}

NO_ACTION_TAXES = {
    [ 0 ] = "Клан слишком мелкий",
    [ CARTEL_TAX_OTHER_WAITING ] = "Другой картель запросил налог",
    [ CARTEL_TAX_PAYED ] = "Оплачено",
    [ CARTEL_TAX_SAVED ] = "Клан отбился от налога",
    [ CARTEL_TAX_TAKEN ] = "Ограблен",
    [ CARTEL_TAX_FIGHT ] = "Вы объявили войну",
    [ CARTEL_TAX_OTHER_FIGHT ] = "Другой картель объявил войну",
}

TABS_CONF.general = {
    fn_create = function( self, parent )
        local col_px = 0
        local row_sy = 50
        local bg_row
        local columns = {
            {
                title = "Клан",
                sx = 200,
                fn_create = function( self, k, v )
                    local clan_name = GetClanName( v[ CT_CLAN_ID ] ) or ""
                    ibCreateLabel( col_px, 0, self.sx - 20, row_sy, clan_name, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                        :ibData( "clip", true )
                end,
            },
            {
                title = "Участников",
                sx = 143,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, v[ CT_CLAN_MEMBERS_COUNT ] .. "#afb5bc/" .. v[ CT_CLAN_SLOTS ], bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                        :ibData( "colored", true )
                end,
            },
            {
                title = "Общак",
                sx = 180,
                fn_create = function( self, k, v )
                    local lbl = ibCreateLabel( col_px, 0, 0, row_sy, format_price( v[ CT_CLAN_MONEY ] ), bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )
                    ibCreateImage( lbl:ibGetAfterX( 5 ), 0, 22, 22, ":nrp_shared/img/money_icon.png", bg_row )
                        :center_y( )
                end,
            },
            {
                title = "Статус налога",
                sx = 283,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, TAX_STATUS_TEXTS[ v[ CT_CLAN_TAX_STATUS ] or 0 ], bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                end,
            },
            {
                title = "Действие",
                sx = 150,
                fn_create = function( self, k, v )
                    if v[ CT_CLAN_TAX_STATUS ] == CARTEL_TAX_WAITING then
                        ibCreateLabel( col_px, 0, 0, row_sy, getTimerString( v[ CT_CLAN_TAX_WAIT_UNTIL_DATE ], true ), bg_row, _, 1, 1, "left", "center", ibFonts.bold_14 )
                            :ibTimer( function( self )
                                self:ibData( "text", getTimerString( v[ CT_CLAN_TAX_WAIT_UNTIL_DATE ], true ) )
                            end, 1000, 0 )

                    elseif v[ CT_CLAN_TAX_STATUS ] == CARTEL_TAX_NOT_REQUESTED and CLAN_DATA.can_request_tax then -- налог не запрашивался
                        ibCreateButton( col_px, 0, 142, 32, bg_row, 
                                "img/btn_request_tax.png", "img/btn_request_tax_hover.png", "img/btn_request_tax_hover.png", _, _, 0xFFAAAAAA )
                            :center_y( )
                            :ibOnClick( function( key, state )
                                if key ~= "left" or state ~= "up" then return end
                                ibClick( )

                                if localPlayer:GetClanRole( ) < CLAN_ROLE_MODERATOR then
                                    localPlayer:ShowError( "Только лидер и модераторы могут запросить налог!" )
                                    return
                                end

                                ibConfirm(
                                    {
                                        title = "НАЛОГ", 
                                        text = "Вы точно хотите запросить налог у клана '" .. ( GetClanName( v[ CT_CLAN_ID ] ) or "" ) .. "'?",
                                        fn = function( self ) 
                                            self:destroy()
                                            triggerServerEvent( "onCartelRequestTaxFromClan", localPlayer, v[ CT_CLAN_ID ] )
                                        end,
                                        escape_close = true,
                                    }
                                )
                            end )
                    elseif v[ CT_CLAN_TAX_STATUS ] == CARTEL_TAX_REFUSED and CLAN_DATA.can_declare_war then -- отказ платить
                        ibCreateButton( col_px, 0, 142, 32, bg_row, 
                                "img/btn_declare_war.png", "img/btn_declare_war_hover.png", "img/btn_declare_war_hover.png", _, _, 0xFFAAAAAA )
                            :center_y( )
                            :ibOnClick( function( key, state )
                                if key ~= "left" or state ~= "up" then return end
                                ibClick( )

                                if localPlayer:GetClanRole( ) < CLAN_ROLE_MODERATOR then
                                    localPlayer:ShowError( "Только лидер и модераторы могут объявить войну!" )
                                    return
                                end

                                ibConfirm(
                                    {
                                        title = "ВОЙНА КЛАНОВ", 
                                        text = "Вы точно хотите объявить войну клану '" .. ( GetClanName( v[ CT_CLAN_ID ] ) or "" )  .. "'?",
                                        fn = function( self ) 
                                            self:destroy()
                                            triggerServerEvent( "onCartelDeclaredWarOnClan", localPlayer, v[ CT_CLAN_ID ] )
                                        end,
                                        escape_close = true,
                                    }
                                )
                            end )
                    else
                        ibCreateLabel( col_px, 0, 0, row_sy, "Недоступно", bg_row, 0xFFb3575f, 1, 1, "left", "center", ibFonts.regular_14 )
                    end
                end,
            },
        }

        col_px = 30
        for i, col in pairs( columns ) do
            ibCreateLabel( col_px, 20, 0, 0, col.title, parent, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "top", ibFonts.regular_12 )
            col_px = col_px + col.sx
        end
        
        local scrollpane, scrollbar

        function UpdateClansList( )
            table.sort( CLAN_DATA.clans_list, function( a, b ) return a[ CT_CLAN_SCORE ] > b[ CT_CLAN_SCORE ] end )
    
            local old_scroll_pos = scrollbar and scrollbar:ibData( "position" ) or 0
            if isElement( scrollpane ) then
                scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
                scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            scrollpane, scrollbar = ibCreateScrollpane( 0, 40, 
                parent:ibData( "sx" ), parent:ibData( "sy" ) - 40, 
                parent, { scroll_px = -20 }
            )
            scrollbar:ibSetStyle( "slim_nobg" )
            
            for k, v in pairs( CLAN_DATA.clans_list or { } ) do
                bg_row = ibCreateImage( 0, ( k - 1 ) * row_sy, parent:ibData( "sx" ), row_sy, _, scrollpane, 0xFF41546a * ( k % 2 ) )
                col_px = 30
                for col_i, col in pairs( columns ) do
                    col:fn_create( k, v )
                    col_px = col_px + col.sx
                end
            end

            scrollpane
                :AdaptHeightToContents( )
                :ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
            scrollbar
                :UpdateScrollbarVisibility( scrollpane )
                :ibData( "position", old_scroll_pos )
        end
        UpdateClansList(  )
        UPDATE_UI_HANDLERS.clans_list = UpdateClansList
        
        if CLAN_DATA.next_tax_request_date then
            local lbl_time = ibCreateLabel( parent:width( ) - 30, -41, 0, 0, getHumanTimeString( CLAN_DATA.next_tax_request_date, true ) or 0, parent, COLOR_WHITE, 1, 1, "right", "top", ibFonts.bold_16 )
            ibCreateLabel( lbl_time:ibGetBeforeX( -5 ), -39, 0, 0, "До следующего запроса налогов: ", parent, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "right", "top", ibFonts.regular_14 )
        end
    end,
}