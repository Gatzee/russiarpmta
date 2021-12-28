TABS_CONF.members = {
    fn_create = function( self, parent )
        table.sort( CLAN_DATA.members, function( a, b )
            return ( a.role or 1 ) == ( b.role or 1 ) and ( a.rank or 0 ) > ( b.rank or 0 ) or ( a.role or 0 ) > ( b.role or 0 )
        end )

        for i, data in pairs( CLAN_DATA.members ) do
            if data.user_id == localPlayer:GetUserID( ) then
                data.role = localPlayer:GetClanRole( )
            end
        end
        
        local bg_edit = ibCreateImage( 30, 20, 851, 30, "img/members/bg_edit_search.png", parent )
            :ibData( "alpha", 255 * 0.6 )
        local edit_search = ibCreateEdit( 35, -5, bg_edit:width( ) - 35 - 10, 40, "", bg_edit, COLOR_WHITE, 0, COLOR_WHITE )
            :ibBatchData( {
                font = ibFonts.regular_14,
            } )
            :ibOnFocusChange( function( focused )
                bg_edit:ibAlphaTo( focused and 255 or 255 * 0.6, 100 )
            end )

        local btn_search = ibCreateButton( bg_edit:ibGetAfterX( 20 ), 20, 93, 31, parent, 
                "img/members/btn_search.png", "img/members/btn_search_hover.png", "img/members/btn_search_hover.png", _, _, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                UpdateMembersList( )
            end )
        
        local scrollpane, scrollbar

        local col_px = 0
        local row_sy = 52
        local bg_row, dropdown
        local members_columns = {
            {
                title = "Имя",
                sx = 326,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, v.name, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_15 )
                end,
            },
            {
                title = "Роль",
                sx = 313,
                fn_create = function( self, k, v )
                    local lbl = ibCreateLabel( col_px, 0, 0, row_sy, CLAN_ROLES_NAMES[ v.role or 1 ], bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_15 )

                    if localPlayer:GetClanRole( ) < CLAN_ROLE_MODERATOR or ( v.role or 1 ) >= localPlayer:GetClanRole( ) then return end

                    local btn = ibCreateArea( lbl:ibGetAfterX( 20 ), 0, 18, 26, bg_row )
                        :center_y( )
                        :ibData( "alpha", 120 )
                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) source:ibAlphaTo( 120, 200 ) end )
                    btn :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )

                            if CLAN_ROLE_CHANGE_HANDLER then
                                return
                            end

                            if dropdown then
                                dropdown.parent:ibData( "priority", 0 )
                                dropdown:destroy( )
                            end

                            local available_roles = { }
                            local role_ids_by_name = { }
                            for role_id, role_name in ipairs( CLAN_ROLES_NAMES ) do
                                if role_id >= localPlayer:GetClanRole( ) then
                                    break 
                                end
                                if role_id ~= v.role then
                                    table.insert( available_roles, role_name )
                                    role_ids_by_name[ role_name ] = role_id
                                end
                            end
                            if localPlayer:GetClanRole( ) == CLAN_ROLE_LEADER and v.role == CLAN_ROLE_MODERATOR then
                                table.insert( available_roles, "Передать лидера" )
                                role_ids_by_name[ "Передать лидера" ] = CLAN_ROLE_LEADER
                            end

                            local py = source:ibData( "py" ) + 20
                            local sy = #CLAN_ROLES_NAMES * 45
                            if source.parent:ibData( "py" ) + py + sy > scrollpane:ibData( "sy" ) then
                                py = source:ibData( "py" ) - 5 - sy
                            end

                            dropdown = ibCreateDropdown( {
                                parent = source.parent,
                                px = source:ibData( "px" ) - 5,
                                py = py,
                                items = available_roles,
                                triangle_px = 10,
                                triangle_py = source:ibData( "py" ) > py and sy + 5,
                                fn_click = function( self_dropdown, selected_item_id )
                                    local selected_role_id = role_ids_by_name[ available_roles[ selected_item_id ] ]

                                    local function RequestClanRoleChange( )
                                        triggerServerEvent( "onPlayerWantChangeClanRole", localPlayer, v.user_id, selected_role_id )

                                        CLAN_ROLE_CHANGE_HANDLER = function( )
                                            if not isElement( lbl ) then return end
                                            v.role = selected_role_id
                                            lbl:ibData( "text", CLAN_ROLES_NAMES[ selected_role_id ] )
                                            btn:ibData( "px", lbl:ibGetAfterX( 20 ) )
                                        end
                                    end

                                    if selected_role_id == CLAN_ROLE_LEADER then
                                        ibConfirm(
                                            {
                                                title = "ИЗМЕНЕНИЕ РОЛИ", 
                                                text = "Вы точно хотите передать свои права лидера игроку " .. v.name .. "? После подтверждения вы станете модератором.",
                                                fn = function( self ) 
                                                    self:destroy()
                                                    RequestClanRoleChange( )
                                                end,
                                                escape_close = true,
                                            }
                                        )
                                    else
                                        RequestClanRoleChange( )
                                    end
                                end,
                            } )
                            dropdown.parent:ibData( "priority", 1 )
                            dropdown:SetVisible( true )
                        end )

                    ibCreateImage( 0, 10, 18, 6, ":nrp_shared/img/btn_dropdown.png", btn )
                        :center( )
                        :ibData( "disabled", true )
                end,
            },
            {
                title = "Онлайн",
                sx = 283,
                fn_create = function( self, k, v )
                    local online = v.last_date == true
                    local lbl = ibCreateLabel( col_px, 0, 0, row_sy, online and "В сети" or "Оффлайн", bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_15 )
                    ibCreateImage( lbl:ibGetAfterX( 20 ), 0, 23, 23, "img/members/icon_indicator.png", bg_row )
                        :center_y( )
                        :ibData( "color", online and 0xFF38c175 or 0xFFff4e4e )
                end,
            },
        }

        col_px = 30
        for i, col in pairs( members_columns ) do
            ibCreateLabel( col_px, 70, 0, 0, col.title, parent, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "top", ibFonts.regular_12 )
            col_px = col_px + col.sx
        end

        function UpdateMembersList( )
            local old_scroll_pos = scrollbar and scrollbar:ibData( "position" ) or 0
            if isElement( scrollpane ) then
                scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
                scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            scrollpane, scrollbar = ibCreateScrollpane( 0, 90, 
                parent:ibData( "sx" ), parent:ibData( "sy" ) - 90, 
                parent, { scroll_px = -20 }
            )
            scrollbar:ibSetStyle( "slim_nobg" )

            local search_name = edit_search:ibData( "text" )
            
            local i = 0
            for k, v in pairs( CLAN_DATA.members ) do
                if search_name == "" or utf8.find( utf8.lower( v.name ), utf8.lower( search_name ), 1, true ) then
                    i = i + 1
                    bg_row = ibCreateImage( 0, ( i - 1 ) * row_sy, parent:ibData( "sx" ), row_sy, _, scrollpane, 0xFF41546a * ( i % 2 ) )
                    col_px = 30
                    for col_i, col in pairs( members_columns ) do
                        col:fn_create( k, v )
                        col_px = col_px + col.sx
                    end

                    if localPlayer:GetClanRole( ) >= CLAN_ROLE_MODERATOR and v.role < localPlayer:GetClanRole( ) then
                        ibCreateButton( bg_row:width( ) - 60 - 14, 0, 14, 18, bg_row, "img/members/btn_delete.png", _, _, 0x6FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                            :center_y( )
                            :ibOnClick( function( key, state )
                                if key ~= "left" or state ~= "up" then return end
                                ibClick( )
                                ibConfirm(
                                    {
                                        title = "ВЫГНАТЬ ИЗ КЛАНА", 
                                        text = "Ты точно хочешь выгнать из клана " .. v.name .. "?",
                                        fn = function( self ) 
                                            self:destroy()
                                            triggerServerEvent( "onClanKickRequest", localPlayer, v.user_id )
                                        end,
                                        escape_close = true,
                                    }
                                )
                            end )
                    end
                end
            end
            scrollpane
                :AdaptHeightToContents( )
                :ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
            scrollbar
                :UpdateScrollbarVisibility( scrollpane )
                :ibData( "position", old_scroll_pos )
        end
        UpdateMembersList( )
        UPDATE_UI_HANDLERS.members = UpdateMembersList

        local area_navbar_btns = ibCreateArea( 0, -44, 0, 33, parent )

        local btn_invite
        if localPlayer:GetClanRole( ) >= CLAN_ROLE_SENIOR then
            btn_invite = ibCreateButton( 0, 0, 111, 21, area_navbar_btns, "img/members/btn_invite.png", _, _, 0x6FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                :center_y( )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowInviteOverlay( parent )
                end )

            ibCreateLine( btn_invite:ibGetAfterX( 20 ), 0, _, 33, ibApplyAlpha( COLOR_WHITE, 10 ), 1, area_navbar_btns )
        end

        local btn_leave = ibCreateButton( btn_invite and btn_invite:ibGetAfterX( 40 ) or 0, 0, 134, 22, area_navbar_btns, 
                "img/members/btn_leave.png", _, _, 0x6FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :center_y( )
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
        
        area_navbar_btns:ibData( "px", parent:width( ) - 30 - btn_leave:ibGetAfterX( ) )
    end,
}

function ShowInviteOverlay( parent )
    if isElement( UI.bg_overlay ) then
        UI.bg_overlay
            :ibMoveTo( _, UI.bg_overlay:height( ), 200 )
            :ibTimer( destroyElement, 200, 1 )
    end
    if not parent then return end

    ibOverlaySound( )
    
    local navbar_sy = UI.tab_panel.navbar.sy
    local bg_overlay = ibCreateImage( 0, parent:height( ) + navbar_sy, parent:width( ), parent:height( ) + navbar_sy, _, parent, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "priority", 2 )
        :ibMoveTo( 0, -navbar_sy, 250 )
    UI.bg_overlay = bg_overlay

    ibCreateLabel( 0, 207, 0, 0, "Добавление участника", bg_overlay, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_20 )
        :center_x( )

    
    local bg_edit = ibCreateImage( 0, 259, 575, 58, "img/members/bg_edit_add.png", bg_overlay )
        :ibData( "alpha", 255 * 0.88 )
        :center_x( )
    local edit_name = ibCreateEdit( bg_edit:ibData( "px" ) + 20, 259, bg_edit:width( ) - 30, bg_edit:height( ), "", bg_overlay, COLOR_WHITE )
        :ibBatchData( {
            font = ibFonts.regular_16,
            caret_color = ibApplyAlpha( COLOR_WHITE, 70 ),
            bg_color = 0,
            align_x = "center",
        } )
        :ibOnFocusChange( function( focused )
            bg_edit:ibAlphaTo( focused and 255 or 255 * 0.88, 100 )
        end )

    local btn_add = ibCreateButton( 0, 355, 156, 49, bg_overlay, 
            "img/members/btn_add.png", "img/members/btn_add_hover.png", "img/members/btn_add_hover.png", _, _, 0xFFAAAAAA )
        :center_x( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            if ( CLICK_TIMEOUT or 0 ) > getTickCount() then return end
            CLICK_TIMEOUT = getTickCount() + 1000
            ibClick( )

            local name = edit_name:ibData( "text" )
            if not name or name == "" then
                localPlayer:ShowError( "Введите имя" )
                return
            end

            for i, player in pairs( getElementsByType( "player" ) ) do
                if player:IsInGame( ) and utf8.lower( player:GetNickName( ) ) == utf8.lower( name ) then
                    if player:IsInClan( ) then
                        localPlayer:ShowError( "Этот игрок уже состоит в клане" )
                        return
                    end
        
                    triggerServerEvent( "onClanInvitationRequest", localPlayer, player )
                    return
                end
            end

            localPlayer:ShowError( "Игрока не существует или он не в сети" )
        end )

    local btn_hide = ibCreateButton( 0, bg_overlay:height( ) - 30 - 42, 108, 42, bg_overlay, 
            "img/members/btn_hide.png", "img/members/btn_hide_hover.png", "img/members/btn_hide_hover.png", _, _, 0xFFAAAAAA )
        :center_x( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowInviteOverlay( false )
        end )
end

addEvent( "onClientUpdateClanUIMembersData", true )
addEventHandler( "onClientUpdateClanUIMembersData", root, function( result, error )
    if result then
        if CLAN_ROLE_CHANGE_HANDLER then
            CLAN_ROLE_CHANGE_HANDLER( )
        end
    else
        localPlayer:ShowError( error )
    end
    CLAN_ROLE_CHANGE_HANDLER = nil
end )