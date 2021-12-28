local UI = { }

function ShowClanJoinUI( state, season_data )
    if state then
        ShowClanJoinUI( false )
        ibInterfaceSound()

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowClanJoinUI, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 95 ) ):center( )

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 90, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
        UI.head_lbl = ibCreateLabel( 0, 0, UI.head_bg:ibData( "sx" ), UI.head_bg:ibData( "sy" ), "Вступить в клан", UI.head_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
        UI.btn_back = ibCreateButton( 30, 0, 110, 17, UI.head_bg, "img/btn_back.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :center_y( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanJoinUI( false )
                ShowClanCreateOrJoinUI( true )
            end )
        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanJoinUI( false )
            end )

        ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )

        UI.body = ibCreateArea( 0, UI.head_bg:ibGetAfterY( ), UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" ) - UI.head_bg:ibData( "sy" ), UI.bg )
        
        UI.loading = ibLoading( { parent = UI.body } )

        triggerServerEvent( "onPlayerShowLeaderboardRequest", localPlayer, true )
        
        UI.bg:ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
        
        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end

function ShowClansLeaderboard( season_data )
    if not isElement( UI.body ) then return end

    local leaderboard = season_data.leaderboard or { }
    season_data.cartels = { }

    for i = #leaderboard, 1, -1 do
        local clan_id = leaderboard[ i ][ LB_CLAN_ID ]
        local clan_team = GetClanTeam( clan_id )
        -- Если клан был удален (такое может быть, когда лидерборд заморожен в межсезонье)
        if not clan_team then
            table.remove( leaderboard, i )
        elseif clan_team:getData( "cartel" ) then
            season_data.cartels[ clan_team:getData( "cartel" ) ] = table.remove( leaderboard, i )
        end
    end
    table.sort( leaderboard, function( a, b ) return a[ LB_CLAN_SCORE ] > b[ LB_CLAN_SCORE ] end )

    UI.area = ibCreateArea( 0, 0, UI.body:ibData( "sx" ), UI.body:ibData( "sy" ), UI.body )
    UI.bg_leaderboard = ibCreateImage( 0, 30, 1024, 300, ":nrp_clans_ui_main/img/leaderboard/bg.png", UI.area )

    local text = "СЕЗОН " .. ( season_data.season or 1 )
    ibCreateLabel( 0, 49, 0, 0, text, UI.area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_14 )
        :center_x( )
    
    local function UpdateSeasonEndLabel( self )
        local current_date = getRealTimestamp( )
        local time_left = season_data.end_date - current_date
        if season_data.start_date > current_date then
            self:ibData( "text", "Сезон начнётся через " .. getTimerString( season_data.start_date, true ) )
        elseif time_left > 0 and time_left < 24 * 60 * 60 then
            self:ibData( "text", "До окончания сезона " .. getTimerString( time_left, true ) )
        elseif time_left < 0 then
            local time_left = season_data.end_date + 32 * 60 * 60 - current_date
            self:ibData( "text", "Новый сезон через " .. getTimerString( time_left, true ) )
        else
            local dt = convertUnixToDate( season_data.end_date or 0, true )
            self:ibData( "text", ( "Сезон заканчивается %02d.%02d.%d" ):format( dt.day, dt.month, dt.year ) )
        end
    end

    local lbl_season_end = ibCreateLabel( 0, 89, 0, 0, "", UI.area, 0x99FFFFFF, 1, 1, "center", "top", ibFonts.regular_12 )
        :center_x( )
        :ibTimer( UpdateSeasonEndLabel, 1000, 0 )
        
    UpdateSeasonEndLabel( lbl_season_end )
    
    local cartel_1 = season_data.cartels[ 1 ] or { }
    ibCreateImage( 40, 166, 52, 52, ":nrp_clans/img/tags/band/" .. ( cartel_1[ LB_CLAN_TAG ] or -2 ) .. ".png", UI.bg_leaderboard )
    ibCreateLabel( 102, 174, 0, 0, "Картель", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
    ibCreateLabel( 172, 175, 0, 0, "[", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
    ibCreateLabel( 178, 178, 0, 0, "Запад", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_11 )
    ibCreateLabel( 214, 175, 0, 0, "]", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
    ibCreateLabel( 102, 195, 0, 0, GetClanName( cartel_1[ LB_CLAN_ID ] ) or "", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_13 )
    ibCreateLabel( 0, 144, 0, 0, cartel_1[ LB_CLAN_MONEY ] or 0, UI.area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
        :center_x( -164 )
    ibCreateLabel( 0, 192, 0, 0, cartel_1[ LB_CLAN_HONOR ] or 0, UI.area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
        :center_x( -164 )
    ibCreateLabel( 0, 234, 0, 0, cartel_1[ LB_CLAN_SCORE ] or 0, UI.area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
        :center_x( -164 )

    local cartel_2 = season_data.cartels[ 2 ] or { }
    ibCreateImage( 764, 166, 52, 52, ":nrp_clans/img/tags/band/" .. ( cartel_2[ LB_CLAN_TAG ] or -2 ) .. ".png", UI.bg_leaderboard )
    ibCreateLabel( 826, 174, 0, 0, "Картель", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
    ibCreateLabel( 896, 175, 0, 0, "[", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
    ibCreateLabel( 902, 178, 0, 0, "Восток", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_11 )
    ibCreateLabel( 943, 175, 0, 0, "]", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_15 )
    ibCreateLabel( 826, 195, 0, 0, GetClanName( cartel_2[ LB_CLAN_ID ] ) or "", UI.bg_leaderboard, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_13 )
    ibCreateLabel( 0, 144, 0, 0, cartel_2[ LB_CLAN_MONEY ] or 0, UI.area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
        :center_x( 164 )
    ibCreateLabel( 0, 192, 0, 0, cartel_2[ LB_CLAN_HONOR ] or 0, UI.area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
        :center_x( 164 )
    ibCreateLabel( 0, 234, 0, 0, cartel_2[ LB_CLAN_SCORE ] or 0, UI.area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
        :center_x( 164 )
    
    local bg_edit = ibCreateImage( 30, UI.bg_leaderboard:ibGetAfterY( ), 851, 30, ":nrp_clans_ui_manage/img/members/bg_edit_search.png", UI.area )
        :ibData( "alpha", 255 * 0.6 )
    local edit_search = ibCreateWebEdit( 35, -5, bg_edit:width( ) - 35 - 10, 40, "", bg_edit, COLOR_WHITE )
        :ibBatchData( {
            font = "regular_12",
            placeholder = "Введите название клана",
            placeholder_color = ibApplyAlpha( COLOR_WHITE, 80 ),
            bg_color = 0,
        } )
        :ibOnFocusChange( function( focused )
            bg_edit:ibAlphaTo( focused and 255 or 255 * 0.6, 100 )
        end )

    local btn_search = ibCreateButton( bg_edit:ibGetAfterX( 20 ), UI.bg_leaderboard:ibGetAfterY( ), 93, 31, UI.area, ":nrp_clans_ui_manage/img/members/btn_search.png", ":nrp_clans_ui_manage/img/members/btn_search_hover.png", ":nrp_clans_ui_manage/img/members/btn_search_hover.png", _, _, 0xFFAAAAAA )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            UpdateClansList( )
        end )

    local COLUMNS = {
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
                return format_price( v[ LB_CLAN_SCORE ] )
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
            title = "Участники",
            sx = 85,
            get_value = function( k, v )
                return v[ LB_CLAN_MEMBERS_COUNT ] .. "/" .. v[ LB_CLAN_SLOTS ]
            end,
        },
    }

    local bg_table_header = ibCreateImage( 0, bg_edit:ibGetAfterY( 20 ), UI.area:ibData( "sx" ), 32, _, UI.area, 0xFF586c80 )
    local col_px = 30
    for i, col in pairs( COLUMNS ) do
        ibCreateLabel( col_px, 0, 0, 32, col.title, bg_table_header, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "center", ibFonts.regular_12 )
        col_px = col_px + col.sx
    end
    
    function UpdateClansList( )
        if isElement( UI.scrollpane ) then
            UI.scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            UI.scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        end

        UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 0, bg_table_header:ibGetAfterY( ), 
            UI.area:ibData( "sx" ), UI.area:ibData( "sy" ) - bg_table_header:ibGetAfterY( ), 
            UI.area, { scroll_px = -20 }
        )
        UI.scrollbar:ibSetStyle( "slim_nobg" )

        local search_name = utf8.lower( edit_search:ibData( "text" ) )
        
        local row_sy = 46
        local i = 0
        for k, v in pairs( season_data.leaderboard ) do
            if search_name == "" or utf8.find( utf8.lower( GetClanName( v[ LB_CLAN_ID ] ) or "" ), search_name, 1, true ) then
                i = i + 1
                local col_px = 30
                local bg_row = ibCreateImage( 0, ( i - 1 ) * row_sy, UI.area:ibData( "sx" ), row_sy, _, UI.scrollpane, 0xFF41546a * ( i % 2 ) )
                for col_i, col in pairs( COLUMNS ) do
                    local value = col.get_value( k, v ) or ""
                    ibCreateLabel( col_px, 0, 0, row_sy, value, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                    col_px = col_px + col.sx
                end

                if v[ LB_CLAN_IS_CLOSED ] then
                    ibCreateImage( col_px, 0, row_sy, row_sy, "img/icon_lock.png", bg_row )
                elseif v[ LB_CLAN_MEMBERS_COUNT ] == v[ LB_CLAN_SLOTS ] then
                    ibCreateImage( col_px, 0, row_sy, row_sy, "img/icon_max.png", bg_row )
                else
                    ibCreateImage( col_px, 0, row_sy, row_sy, "img/icon_enter.png", bg_row )
                    ibCreateButton( col_px, 0, row_sy, row_sy, bg_row, _, _, _, 0, 0x40FFFFFF, 0x40000000 )
                        :ibOnClick( function( button, state )
                            if button ~= "left" or state ~= "up" then return end
                            ibClick( )
                            triggerServerEvent( "onPlayerWantJoinClan", localPlayer, v[ LB_CLAN_ID ] )
                        end )
                end
            end
        end

        UI.scrollpane:AdaptHeightToContents( )
        UI.scrollbar:UpdateScrollbarVisibility( UI.scrollpane )
    end
    UpdateClansList( )

    UI.area:ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
    UI.loading:ibAlphaTo( 0, 500 )
end
addEvent( "ShowClansLeaderboard", true )
addEventHandler( "ShowClansLeaderboard", root, ShowClansLeaderboard )

function ShowClanMainUI_handler( state, clan_data )
    if isElement( UI.bg ) then
        ShowClanJoinUI( false )
        localPlayer:ShowSuccess( "Вы успешно вступили в клан '" .. clan_data.name .. "'!" )
    end
end
addEvent( "ShowClanMainUI", true )
addEventHandler( "ShowClanMainUI", root, ShowClanMainUI_handler )