TABS_CONF.leaderboard = {
    fn_create = function( self, parent )
        local season_data = CLAN_DATA.season_data
        if season_data.locked then
            ShowSeasonResults( parent )
            return
        end

        local area = ibCreateArea( 0, -10, parent:ibData( "sx" ), parent:ibData( "sy" ) + 10, parent )
        local bg = ibCreateImage( 0, 30, 1024, 300, "img/leaderboard/bg.png", area )

        local text = "СЕЗОН " .. ( season_data.season or 1 )
        ibCreateLabel( 0, 49, 0, 0, text, area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_14 )
            :center_x( )
    
        ibCreateLabel( 0, 89, 0, 0, "", area, 0x99FFFFFF, 1, 1, "center", "top", ibFonts.regular_12 )
            :center_x( )
            :ibTimer( function( self )
                local current_date = getRealTimestamp( )
                local time_left = season_data.end_date - current_date
                if season_data.start_date > current_date then
                    self:ibData( "text", "Сезон начнётся через " .. getTimerString( season_data.start_date, true ) )
                elseif season_data.locked then
                    self:ibData( "text", "Новый сезон через " .. getTimerString( season_data.start_date, true ) )
                elseif time_left < 24 * 60 * 60 then
                    self:ibData( "text", "До окончания сезона " .. getTimerString( time_left, true ) )
                else
                    local dt = convertUnixToDate( season_data.end_date or 0, true )
                    self:ibData( "text", ( "Сезон заканчивается %02d.%02d.%d" ):format( dt.day, dt.month, dt.year ) )
                end
            end, 1000, 0 )
    
        local cartel_1 = season_data.cartels[ 1 ] or { }
        ibCreateImage( 40, 166, 52, 52, ":nrp_clans/img/tags/band/" .. ( cartel_1[ LB_CLAN_TAG ] or -2 ) .. ".png", bg )
        ibCreateLabel( 102, 174, 0, 0, "Картель", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
        ibCreateLabel( 172, 175, 0, 0, "[", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
        ibCreateLabel( 178, 178, 0, 0, "Запад", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_11 )
        ibCreateLabel( 214, 175, 0, 0, "]", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
        ibCreateLabel( 102, 195, 0, 0, GetClanName( cartel_1[ LB_CLAN_ID ] ) or "", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_13 )
        ibCreateLabel( 0, 144, 0, 0, cartel_1[ LB_CLAN_MONEY ] or 0, area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            :center_x( -164 )
        ibCreateLabel( 0, 192, 0, 0, cartel_1[ LB_CLAN_HONOR ] or 0, area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            :center_x( -164 )
        ibCreateLabel( 0, 234, 0, 0, cartel_1[ LB_CLAN_SCORE ] or 0, area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            :center_x( -164 )

        local cartel_2 = season_data.cartels[ 2 ] or { }
        ibCreateImage( 764, 166, 52, 52, ":nrp_clans/img/tags/band/" .. ( cartel_2[ LB_CLAN_TAG ] or -2 ) .. ".png", bg )
        ibCreateLabel( 826, 174, 0, 0, "Картель", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
        ibCreateLabel( 896, 175, 0, 0, "[", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
        ibCreateLabel( 902, 178, 0, 0, "Восток", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_11 )
        ibCreateLabel( 943, 175, 0, 0, "]", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
        ibCreateLabel( 826, 195, 0, 0, GetClanName( cartel_2[ LB_CLAN_ID ] ) or "", bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_13 )
        ibCreateLabel( 0, 144, 0, 0, cartel_2[ LB_CLAN_MONEY ] or 0, area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            :center_x( 164 )
        ibCreateLabel( 0, 192, 0, 0, cartel_2[ LB_CLAN_HONOR ] or 0, area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            :center_x( 164 )
        ibCreateLabel( 0, 234, 0, 0, cartel_2[ LB_CLAN_SCORE ] or 0, area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            :center_x( 164 )

        local leaderboard_columns = {
            {
                title = "Топ",
                sx = 75,
                get_value = function( k, v )
                    return k
                end,
            },
            {
                title = "Клан",
                sx = 245,
                get_value = function( k, v )
                    return GetClanName( v[ LB_CLAN_ID ] )
                end,
            },
            {
                title = "Очки",
                sx = 192,
                get_value = function( k, v )
                    return format_price( v[ LB_CLAN_SCORE ] or 0 )
                end,
            },
            {
                title = "Общак",
                sx = 167,
                get_value = function( k, v )
                    return format_price( v[ LB_CLAN_MONEY ] )
                end,
            },
            {
                title = "Честь",
                sx = 152,
                get_value = function( k, v )
                    return format_price( v[ LB_CLAN_HONOR ] )
                end,
            },
            {
                title = "Кол-во человек",
                sx = 85,
                get_value = function( k, v )
                    return v[ LB_CLAN_MEMBERS_COUNT ] .. "/" .. v[ LB_CLAN_SLOTS ]
                end,
            },
        }

        local bg_table_header = ibCreateImage( 0, bg:ibGetAfterY( ), UI.bg:ibData( "sx" ), 32, _, area, 0xFF586c80 )
        local col_px = 30
        for i, col in pairs( leaderboard_columns ) do
            ibCreateLabel( col_px, 0, 0, 32, col.title, bg_table_header, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "center", ibFonts.regular_12 )
            col_px = col_px + col.sx
        end
        
        local scrollpane, scrollbar = ibCreateScrollpane( 0, bg_table_header:ibGetAfterY( ), 
            area:ibData( "sx" ), area:ibData( "sy" ) - bg_table_header:ibGetAfterY( ), 
            area, { scroll_px = -20 }
        )
        scrollbar:ibSetStyle( "slim_nobg" )
        
        local row_sy = 46
        for k, v in pairs( season_data.leaderboard ) do
            col_px = 30
            local bg_row = ibCreateImage( 0, ( k - 1 ) * row_sy, area:ibData( "sx" ), row_sy, _, scrollpane, 0xFF41546a * ( k % 2 ) )
            for col_i, col in pairs( leaderboard_columns ) do
                local value = col.get_value( k, v ) or ""
                ibCreateLabel( col_px, 0, 0, row_sy, value, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                col_px = col_px + col.sx
            end
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end,
}

function ShowSeasonResults( parent )
    local scrollpane, scrollbar = ibCreateScrollpane( 0, 0, 
        parent:ibData( "sx" ), parent:ibData( "sy" ), 
        parent, { scroll_px = -20 }
    )
    scrollbar:ibSetStyle( "slim_nobg" )

    local season_data = CLAN_DATA.season_data
    ibCreateLabel( 0, 14, 0, 20, "Итоги сезона №" .. ( season_data.season or 1 ), scrollpane, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_18 )
        :center_x( )
    ibCreateLabel( 0, 44, 0, 20, "", scrollpane, ibApplyAlpha( COLOR_WHITE, 60 ), 1, 1, "center", "top", ibFonts.regular_12 )
        :center_x( )
        :ibTimer( function( self )
            self:ibData( "text", "Следующий сезон через: " .. getTimerString( season_data.start_date, true ) )
        end, 1000, 0 )

    local bg = ibCreateImage( 0, 0, 1024, 426, "img/rewards/bg.png", scrollpane )

    local positions_grid = {
        {
            px = 190,
            py = 324,
            position = 2,
        },
        {
            px = 516,
            py = 324,
            position = 1,
        },
        {
            px = 837,
            py = 324,
            position = 3,
        },
    }

    local leaderboard = season_data.leaderboard
    for col_i, col in pairs( positions_grid ) do
        local px, py = col.px, 0
        local v = leaderboard[ col.position ]

        if v then
            local bg = ibCreateImage( px - 334 / 2, 274, 334, 199, "img/leaderboard/bg_position_big.png", scrollpane )

            local area = ibCreateArea( 0, 0, 0, 68, bg )
            ibCreateImage( 0, 0, 64, 64, ":nrp_clans/img/tags/band/" .. ( v[ LB_CLAN_TAG ] or -2 ) .. ".png", area )
                :center_y( )
            local lbl = ibCreateLabel( 74, 0, 0, 0, GetClanName( v[ LB_CLAN_ID ] ) or "", area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )
                :center_y( )
            area:ibData( "sx", lbl:ibGetAfterX( 20 ) ):center_x( )

            ibCreateLabel( 175, 88, 0, 0, format_price( v[ LB_CLAN_SCORE ] or 0 ), bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )
            ibCreateLabel( 178, 133, 0, 0, format_price( v[ LB_CLAN_HONOR ] or 0 ), bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )
            ibCreateLabel( 186, 178, 0, 0, format_price( v[ LB_CLAN_MONEY ] or 0 ), bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )
        
            if col_i ~= 1 then
                local px = 30 + ( col_i - 1 ) * ( scrollpane:width( ) - 60 ) / 3
                ibCreateImage( px, 64, 1, 409, _, scrollpane, ibApplyAlpha( COLOR_WHITE, 10 ) )
            end
        end
    end

    ROMAN_NUMBERS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII" }

    local area_other_positions = ibCreateArea( 0, 525, 0, 330, scrollpane )
    local col_px = 0
    local col_sx = 200
    for col_i = 4, 8 do
        local v = leaderboard[ col_i ]

        if v then
            local bg = ibCreateImage( col_px, 0, 222, 297, "img/leaderboard/bg_position.png", area_other_positions )

            ibCreateLabel( 112, 48, 0, 0, ROMAN_NUMBERS[ col_i ], bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_26 )

            local area = ibCreateArea( 0, 128, 0, 48, bg )
            local area_sx = col_sx - 40
            local tag_sx = 48
            ibCreateImage( 0, 0, tag_sx, tag_sx, ":nrp_clans/img/tags/band/" .. ( v[ LB_CLAN_TAG ] or -2 ) .. ".png", area )
                :center_y( )
            local lbl = ibCreateLabel( tag_sx + 8, 0, area_sx - tag_sx - 8, 48, GetClanName( v[ LB_CLAN_ID ] ) or "", area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                :ibData( "wordbreak", true )
                :center_y( )
            local area_new_sx = lbl:ibGetAfterX( )
            area:ibData( "sx", area_new_sx > area_sx and area_sx or area_new_sx ):center_x( )

            ibCreateLabel( 116, 194, 0, 0, format_price( v[ LB_CLAN_SCORE ] or 0 ), bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_14 )
            ibCreateLabel( 119, 237, 0, 0, format_price( v[ LB_CLAN_HONOR ] or 0 ), bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_14 )
            ibCreateLabel( 126, 278, 0, 0, format_price( v[ LB_CLAN_MONEY ] or 0 ), bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_14 )
        
            if col_i ~= 4 then
                ibCreateImage( bg:ibGetCenterX( -col_sx / 2 ), 0, 1, 297, _, area_other_positions, ibApplyAlpha( COLOR_WHITE, 10 ) )
            end

            col_px = col_px + col_sx
        else
            break
        end
    end
    area_other_positions:ibData( "sx", col_px ):center_x( )
    
    scrollpane:AdaptHeightToContents( )
    scrollbar:UpdateScrollbarVisibility( scrollpane ) 
end