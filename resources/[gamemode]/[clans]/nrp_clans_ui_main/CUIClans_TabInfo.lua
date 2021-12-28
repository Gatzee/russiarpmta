TABS_CONF.info = {
    fn_create = function( self, parent )
        local bg_logo = ibCreateImage( 30, 20, 228, 261, _, parent, ibApplyAlpha( COLOR_WHITE, 10 ) )
        local logo = ibCreateImage( 0, 0, 200, 200, ":nrp_clans/img/tags/band/" .. CLAN_DATA.tag .. ".png", bg_logo )
            :center( )

        local bg_info = ibCreateImage( bg_logo:ibGetAfterX( ), 20, parent:ibData( "sx" ) - 60 - 228, 261, _, parent, 0xFF586b7f )
        ibCreateImage( 1, 1, 736 - 2, 261 - 2, _, bg_info, 0xFF405469 )
        
        ibCreateLabel( 30, 30, 0, 0, "Имя клана", bg_info, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_16 )
        ibCreateLabel( 30, 50, 0, 0, CLAN_DATA.name, bg_info, 0xFFff5252, 1, 1, "left", "top", ibFonts.bold_18 )

        ibCreateLabel( 248, 30, 0, 0, "Членов клана", bg_info, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_16 )
        ibCreateLabel( 248, 51, 0, 0, CLAN_DATA.members_count .. "/" .. CLAN_DATA.slots, bg_info, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_15 )
        
        ibCreateLabel( 30, 80, 0, 0, "Тип клана", bg_info, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_16 )
        ibCreateLabel( 30, 100, 0, 0, CLAN_WAY_NAMES[ CLAN_DATA.way ], bg_info, 0xFFff5252, 1, 1, "left", "top", ibFonts.bold_18 )
        
        ibCreateLabel( 30, 152, 0, 0, "Очков " .. CLAN_DATA.score, bg_info, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
        ibCreateLabel( 30, 173, 0, 0, "(Позиция в таблице: " .. ( CLAN_DATA.leaderboard_position or "?" ) .. ")", bg_info, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_18 )

        local btn_show_table = ibCreateButton( 30, 210, 165, 14, bg_info, "img/info/btn_show_table.png", _, _, 0x6FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                UI.tab_panel:SwitchTab( "leaderboard" )
            end )

        ibCreateImage( 397, 12, 1, 236, _, bg_info, 0xFF495b6e )

        local logo = ibCreateImage( 443, 0, 400, 400, ":nrp_clans/img/tags/band/" .. CLAN_DATA.tag .. ".png", bg_info )
            :ibData( "alpha", 10 )
            :ibData( "section", { px = 0, py = 0, sx = 292, sy = 260 } )

        ibCreateLabel( 427, 30, 0, 0, "Сообщение дня", bg_info, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_16 )
        ibCreateLabel( 427, 55, 278, 180, CLAN_DATA.motd or "", bg_info, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_15 )
            :ibData( "wordbreak", true )
            :ibData( "clip", true )
        
        local bg_desc = ibCreateImage( 30, bg_info:ibGetAfterY( 20 ), parent:ibData( "sx" ) - 60, 208, _, parent, 0xFF586b7f )
        ibCreateImage( 1, 1, bg_desc:width( ) - 2, bg_desc:height( ) - 2, _, bg_desc, 0xFF405366 )
        
        ibCreateLabel( 30, 30, 0, 0, "Информация о клане", bg_desc, 0xFF8b97a3, 1, 1, "left", "top", ibFonts.regular_15 )
        ibCreateLabel( 30, 55, bg_desc:width( ) - 60, bg_desc:height( ) - 80, CLAN_DATA.desc or "", bg_desc, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_15 )
            :ibData( "wordbreak", true )
            :ibData( "clip", true )

        local btn_leave = ibCreateButton( 30, parent:height( ) - 30 - 44, 247, 44, parent, 
                "img/info/btn_leave.png", "img/info/btn_leave_hover.png", "img/info/btn_leave_hover.png", _, _, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                if localPlayer:GetClanRole( ) == CLAN_ROLE_LEADER then
                    localPlayer:ShowError( "Вы не можете покинуть собственный клан!" )
                    return
                end

                ibConfirm(
                    {
                        title = "ПОКИНУТЬ КЛАН", 
                        text = "Ты точно хочешь покинуть клан?",
                        fn = function( self ) 
                            self:destroy()
                            triggerServerEvent( "onPlayerWantLeaveClan", localPlayer )
                        end,
                        escape_close = true,
                    }
                )
            end )

        local btn_marker = ibCreateButton( parent:width( ) - 30 - 193, parent:height( ) - 30 - 44, 193, 44, parent, 
                "img/info/btn_marker.png", "img/info/btn_marker_hover.png", "img/info/btn_marker_hover.png", _, _, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                local cartel_id = localPlayer:GetClanCartelID( )
                local base_id = cartel_id and ( cartel_id + 3 ) or CLAN_DATA.base_id or 1
                local position = Vector3( CLAN_BASEMENT_MARKER_CONFIGS[ base_id ] )
                triggerEvent( "ToggleGPS", localPlayer, position )
            end )
    end,
}