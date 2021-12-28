TABS_CONF.edit = {
    fn_create = function( self, parent )
        local btn_select_clan_tag = ibCreateImage( 30, 20, 256, 289, _, parent, 0x19FFFFFF )
        local clan_tag = ibCreateImage( 0, 0, 200, 200, ":nrp_clans/img/tags/band/" .. CLAN_DATA.tag .. ".png", btn_select_clan_tag )
            :ibData( "disabled", true )
            :center( )
            

        local bg_border = ibCreateImage( btn_select_clan_tag:ibGetAfterX( ), 20, 710, 289, _, parent, ibApplyAlpha( COLOR_WHITE, 10 ) )
        local bg_memo_motd = ibCreateImage( 1, 1, 710 - 2, 289 - 2, _, bg_border, 0xFF405469 )
        local bg_memo_motd_focused = ibCreateImage( 0, 0, 710 - 2, 289 - 2, _, bg_memo_motd, 0xFF394a5e )
            :ibData( "alpha", 0 )
        ibCreateLabel( 30, 30, 0, 0, "Сообщение дня", bg_memo_motd, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_15 )

        local lbl_motd = ibCreateLabel( 30, 60, 710 - 60, 289 - 90, CLAN_DATA.motd or "", bg_memo_motd, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_15 ):ibData( "clip", true ):ibData( "wordbreak", true )
        local memo_motd
        ibCreateButton( bg_memo_motd:width( ) - 20 - 20, 20, 20, 20, bg_memo_motd, "img/editing/btn_edit.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                if memo_motd then
                    local new_value = memo_motd:ibData( "text" )

                    local prev_pos = 0
                    for pos, codepoint in utf8.next, new_value .. " " do
                        if pos - prev_pos > 3 then
                            localPlayer:ShowError( "Сообщение дня содержит недопустимые символы!" )
                            return
                        end
                        prev_pos = pos
                    end

                    if new_value ~= ( CLAN_DATA.motd or "" ) then
                        CLAN_DATA.motd = new_value
                        triggerServerEvent( "onClanMotdChangeRequest", localPlayer, new_value )
                    end
                else
                    lbl_motd:destroy( )
                    memo_motd = ibCreateWebMemo( 30, 60, 710 - 60, 289 - 90, CLAN_DATA.motd or "", bg_memo_motd )
                        :ibBatchData( { 
                            font = "regular_15", 
                            max_length = 150, 
                            placeholder = "Введите сообщение дня...", 
                            placeholder_color = ibApplyAlpha( COLOR_WHITE, 80 ),
                            bg_color = 0,
                        } )
                        :ibOnFocusChange( function( focused )
                            bg_memo_motd_focused:ibAlphaTo( focused and 255 or 0, 100 )
                        end )

                    source:ibBatchData( {
                        texture         = "img/editing/btn_save.png",
                        texture_hover   = "img/editing/btn_save.png",
                        texture_click   = "img/editing/btn_save.png",
                    } )
                end
            end )

        ----------------

        local bg_border = ibCreateImage( 30, btn_select_clan_tag:ibGetAfterY( 30 ), 964, 175, _, parent, ibApplyAlpha( COLOR_WHITE, 10 ) )
        local bg_status = ibCreateImage( 1, 1, 256 - 1, 175 - 2, _, bg_border, 0xFF405469 )
        ibCreateLabel( 0, 20, 0, 0, "Статус клана", bg_status, 0xFF8b97a3, 1, 1, "center", "top", ibFonts.regular_16 )
            :center_x( )
        local lbl_status = ibCreateLabel( 0, 0, 0, 0, "", bg_status, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_16 )
            :center( )
        local lbl_status_info = ibCreateLabel( 0, bg_status:height( ) - 20, 0, 0, "", bg_status, COLOR_WHITE, 1, 1, "center", "bottom", ibFonts.regular_14 )
            :center_x( )
        local function update_status_labels( )
            lbl_status:ibData( "text", CLAN_DATA.is_closed and "Закрытый" or "Открытый" )
            lbl_status_info:ibData( "text", CLAN_DATA.is_closed and "Только по приглашению" or "Любой игрок может \nвступить в клан" )
        end
        update_status_labels( )
        ibCreateButton( 0, 0, 19, 21, bg_status, "img/editing/btn_arrow.png", _, _, 0x6FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibData( "rotation", 180 )
            :center( -75, 0 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if ( CLICK_TIMEOUT or 0 ) > getTickCount() then return end
                CLICK_TIMEOUT = getTickCount() + 1000
                ibClick( )
                triggerServerEvent( "onPlayerWantSetClanClosed", localPlayer, not CLAN_DATA.is_closed )
                CLAN_DATA.is_closed = not CLAN_DATA.is_closed
                update_status_labels( )
            end )
        ibCreateButton( 0, 0, 19, 21, bg_status, "img/editing/btn_arrow.png", _, _, 0x6FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :center( 75, 0 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if ( CLICK_TIMEOUT or 0 ) > getTickCount() then return end
                CLICK_TIMEOUT = getTickCount() + 1000
                ibClick( )
                triggerServerEvent( "onPlayerWantSetClanClosed", localPlayer, not CLAN_DATA.is_closed )
                CLAN_DATA.is_closed = not CLAN_DATA.is_closed
                update_status_labels( )
            end )

        ---------------------

        local bg_memo_desc = ibCreateImage( bg_status:ibGetAfterX( 1 ), 1, 710 - 2, 175 - 2, _, bg_border, 0xFF405469 )
        local bg_memo_desc_focused = ibCreateImage( 0, 0, 710 - 2, 175 - 2, _, bg_memo_desc, 0xFF394a5e )
            :ibData( "alpha", 0 )
        ibCreateLabel( 30, 30, 0, 0, "Информация о клане", bg_memo_desc, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_15 )

        local lbl_desc = ibCreateLabel( 30, 60, 710 - 60, 100, CLAN_DATA.desc or "", bg_memo_desc, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_15 ):ibData( "clip", true ):ibData( "wordbreak", true )
        local memo_desc
        ibCreateButton( bg_memo_desc:width( ) - 20 - 20, 20, 20, 20, bg_memo_desc, "img/editing/btn_edit.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
             :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                if memo_desc then
                    local new_value = memo_desc:ibData( "text" )

                    local prev_pos = 0
                    for pos, codepoint in utf8.next, new_value .. " " do
                        if pos - prev_pos > 3 then
                            localPlayer:ShowError( "Информация о клане содержит недопустимые символы!" )
                            return
                        end
                        prev_pos = pos
                    end

                    if new_value ~= ( CLAN_DATA.desc or "" ) then
                        CLAN_DATA.desc = new_value
                        triggerServerEvent( "onClanDescChangeRequest", localPlayer, new_value )
                    end

                else
                    lbl_desc:destroy( )
                    memo_desc = ibCreateWebMemo( 30, 60, 710 - 60, 100, CLAN_DATA.desc or "", bg_memo_desc )
                        :ibBatchData( { 
                            font = "regular_15", 
                            max_length = 400, 
                            placeholder = "Введите информацию о клане...", 
                            placeholder_color = ibApplyAlpha( COLOR_WHITE, 80 ),
                            bg_color = 0,
                        } )
                        :ibOnFocusChange( function( focused )
                            bg_memo_desc_focused:ibAlphaTo( focused and 255 or 0, 100 )
                        end )

                    source:ibBatchData( {
                        texture         = "img/editing/btn_save.png",
                        texture_hover   = "img/editing/btn_save.png",
                        texture_click   = "img/editing/btn_save.png",
                    } )
                end
            end )

        local btn_upgrade_slots

        function UpdateClanSlotsUpgrade( )
            if isElement( btn_upgrade_slots ) then
                btn_upgrade_slots:destroy( )
            end
            local upgrade_conf = CLAN_UPGRADES_LIST[ CLAN_UPGRADE_SLOTS ]
            local upgrade_next_level = ( CLAN_DATA.upgrades[ CLAN_UPGRADE_SLOTS ] or 0 ) + 1
            local upgrade = upgrade_conf[ upgrade_next_level ]
            if upgrade then
                btn_upgrade_slots = ibCreateButton( 0, parent:height( ) - 30 - 42, 327, 42, parent, "img/editing/bg_btn.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                    :center_x( )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ibConfirm(
                            {
                                title = "РАСШИРЕНИЕ КЛАНА", 
                                text = "Ты точно хочешь расширить клан до " .. ( CLAN_DATA.slots + 25 ) .. " слотов \nза " .. format_price( upgrade.cost ) .. "р.?" ,
                                fn = function( self )
                                    triggerServerEvent( "onPlayerRequestClanUpgrade", localPlayer, CLAN_UPGRADE_SLOTS )
                                    self:destroy()
                                end,
                                escape_close = true,
                            }
                        )
                    end )
                ibCreateLabel( 0, 0, 0, 0, "РАСШИРИТЬ КЛАН ДО " .. ( CLAN_DATA.slots + 25 ) .. " СЛОТОВ", btn_upgrade_slots, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_16 )
                    :center( )
            end
        end
        UpdateClanSlotsUpgrade( )
        UPDATE_UI_HANDLERS.slots = UpdateClanSlotsUpgrade

        local btn
        function UpdateClanDeleteDate( )
            if isElement( btn ) then
                btn:destroy( )
            end
            if CLAN_DATA.delete_date then
                btn = ibCreateButton( parent:width( ) - 30 - 148, -36, 148, 22, parent, 
                        "img/editing/btn_cancel_delete_clan.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        ibConfirm(
                            {
                                title = "РОСПУСК КЛАНА", 
                                text = "Ты точно отменить удаление клан?",
                                fn = function( self )
                                    triggerServerEvent( "onPlayerWantCancelDeleteClan", localPlayer )
                                    self:destroy()
                                end,
                                escape_close = true,
                            }
                        )
                    end )
            else
                btn = ibCreateButton( parent:width( ) - 30 - 125, -36, 125, 22, parent, 
                        "img/editing/btn_delete_clan.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        ibConfirm(
                            {
                                title = "РОСПУСК КЛАНА", 
                                text = "Ты точно хочешь удалить клан?",
                                fn = function( self )
                                    triggerServerEvent( "onPlayerWantDeleteClan", localPlayer )
                                    self:destroy()
                                end,
                                escape_close = true,
                            }
                        )
                    end )
            end
        end
        UpdateClanDeleteDate( )
        UPDATE_UI_HANDLERS.delete_date = UpdateClanDeleteDate
    end,
}