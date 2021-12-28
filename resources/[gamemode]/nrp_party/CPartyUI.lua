Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true ) -- use real fonts as PS

local CURRENT_PARTY = { }
local helpers_ui = { }
local ui = { }
local syncData = { }
local texs = { }

local COMPONENTS = {
    bg = {
        watch = PARTY_MAIN,
        create = function ( _, is_owner, is_client, time_start )
            CURRENT_PARTY.is_owner = is_owner
            CURRENT_PARTY.is_client = is_client
            CURRENT_PARTY.time_start = time_start

            if not next( helpers_ui ) then
                showCursor( true )
            end

            ui.bg = ibCreateBackground( nil, function ( )
                setStateComponent( "bg", false )
            end, true, true )
            :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

            -- init multi textures
            texs.bg_prize = dxCreateTexture( "img/bg_prize.png" )

            -- init window
            setStateComponent( "window", true )

            -- set state window on server side
            triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_WINDOW_STATE, { CURRENT_PARTY.id, true } )
        end,
        destroy = function ( )
            -- set state window on server side
            triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_WINDOW_STATE, { CURRENT_PARTY.id, false } )

            if not next( helpers_ui ) then
                showCursor( false )
            end

            ui = { }
            syncData = { }

            for _, tex in pairs( texs ) do
                if isElement( tex ) then
                    tex:destroy( )
                end
            end
        end,
    },

    window = {
        create = function ( )
            ui.window = ibCreateImage( 0, 0, 1024, 770, "img/bg.png", ui.bg ):center( )
            ui.window_rt = ibCreateRenderTarget( 0, 0, 1024, 770, ui.window )

            -- header
            ibCreateLabel( 30, 0, 0, 80, "Тусовка", ui.window, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_20 )

            -- timer
            if CURRENT_PARTY.time_start then
                local time = CURRENT_PARTY.time_start

                ibCreateImage( 500, 29, 17, 20, "img/icon_timer.png", ui.window )
                ibCreateLabel( 525, 40, 0, 0, "Время начала тусовки по МСК:", ui.window, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_14 )
                ibCreateLabel( 745, 39, 0, 0, ( "%02d:%02d" ):format( time[ 1 ], time[ 2 ] ), ui.window, nil, nil, nil, nil, "center", ibFonts.bold_16 )
            end

            -- close button
            ibCreateButton( 972, 29, 22, 22, ui.window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                setStateComponent( "bg", false )
            end )

            -- info bar
            ibCreateButton( 805, 24, 137, 31, ui.window, "img/btn_info", true )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                setStateComponent( "info", true )
            end )

            -- init menu
            setStateComponent( "menu", true )
        end,
    },

    menu = {
        create = function ( )
            ui.menu = ibCreateArea( 0, 140, 0, 0, ui.window_rt )

            local shadow = ibCreateImage( 30, - 3, 4, 4, nil, ui.menu, 0xffff965d )
            local buttons = {
                { href = "tab_main",    name = "Главная",    selected = true    },
                { href = "tab_play",    name = "Розыгрыш"                       },
            }
            local selectedTab = 2

            local function setStateTab( name, is_active, aOffset )
                ui[ name ]:ibMoveTo( is_active and 0 or aOffset, nil, 250 )
                ui[ name ]:ibAlphaTo( is_active and 255 or 0, 150 )
                ui[ name ]:ibBatchData( { priority = is_active and 0 or -1 } )
            end

            local function clickNav( idx )
                local x = buttons[ idx - 1 ] and buttons[ idx - 1 ].element:ibGetAfterX( ) + 30 or 30
                local width = dxGetTextWidth( buttons[ idx ].name, 1, ibFonts.bold_16 )

                for buttonNum, button in ipairs( buttons ) do
                    button.selected = buttonNum == idx and true or false
                    button.element:ibAlphaTo( button.selected and 255 or 100, 50 )

                    if not button.selected then
                        setStateTab( button.href, false, selectedTab > idx and 150 or -150 ) -- hide tab
                    end
                end

                shadow:ibMoveTo( x, nil, 200 )
                shadow:ibResizeTo( width, 4, 200 )

                setStateTab( buttons[ idx ].href, true, selectedTab < idx and 150 or -150 ) -- show tab
                selectedTab = idx
            end

            for idx, button in ipairs( buttons ) do
                local x = buttons[ idx - 1 ] and buttons[ idx - 1 ].element:ibGetAfterX( ) + 30 or 30
                local width = dxGetTextWidth( button.name, 1, ibFonts.bold_16 )

                button.element = ibCreateLabel( x, - 50, width, 50, button.name, ui.menu, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_16 )
                :ibData( "alpha", button.selected and 255 or 100 )
                :ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    if selectedTab == idx then return end

                    clickNav( idx )
                    ibClick( )
                end )

                if button.selected then
                    shadow:ibData( "sx", width )
                    shadow:ibMoveTo( x, nil, 200 )
                end
            end

            ibCreateImage( 30, 0, 964, 1, nil, ui.menu, 0x22ffffff )

            -- init tabs
            setStateComponent( "tab_main", true )
            setStateComponent( "tab_play", true )

            -- select 1st tab
            clickNav( 1 )

            -- invite
            if CURRENT_PARTY.is_owner then
                ui.btn_invite = ibCreateButton( 840, 100, 160, 30, ui.window_rt, "img/btn_invite.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
                :ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end

                    setStateComponent( "invite", true )
                    ibClick( )
                end )
            else
                local img = CURRENT_PARTY.is_client and "img/btn_leave_party" or "img/btn_send_request"
                ui.btn_invite = ibCreateButton( 852, 102, 142, 22, ui.window_rt, img, true )
                :ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end

                    triggerServerEvent( "onPartyActionRequest", resourceRoot, CURRENT_PARTY.is_client and PARTY_LEAVE or PARTY_SEND_REQUEST, CURRENT_PARTY.id )
                    ibClick( )
                end )
            end
        end,
    },

    info = {
        create = function ( )
            ui.info = ibCreateImage( 0, 690, 1024, 690, nil, ui.window_rt, ibApplyAlpha( 0xff1f2934, 95 ) )
            :ibMoveTo( 0, 80, 250 )

            ibCreateLabel( 512, 40, 0, 0, "Информация", ui.info, nil, nil, nil, "center", "center", ibFonts.bold_20 )
            ibCreateImage( 0, 0, 811, 507, "img/overlay_info.png", ui.info ):center( 0, - 10 )

            ibCreateButton( 0, 615, 108, 42, ui.info, "img/btn_hide", true ):center_x( )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                setStateComponent( "info", false )
                ibClick( )
            end )

            ibOverlaySound( )
        end,
    },

    invite = {
        create = function ( )
            ui.invite = ibCreateImage( 0, 690, 1024, 690, nil, ui.window_rt, ibApplyAlpha( 0xff1f2934, 95 ) )
            :ibMoveTo( 0, 80, 250 )

            ibCreateLabel( 512, 260, 0, 0, "Пригласить игрока", ui.invite, nil, nil, nil, "center", "center", ibFonts.bold_20 )

            local edit_bg = ibCreateImage( 225, 300, 575, 58, "img/edit_bg2.png", ui.invite )
            local edit = ibCreateWebEdit( 0, 0, 575, 58, "", edit_bg, 0x80ffffff, 0 )
            edit:ibBatchData( { max_length = 48, placeholder = "Введите имя игрока", font = "regular_12_200", text_align = "center" } )

            local lbl_result = ibCreateLabel( 0, 375, 1024, 0, "", ui.invite,nil, nil, nil, "center", "top", ibFonts.regular_14 )
            table.insert( syncData, {
                watch = PARTY_INVITE_RESULT,
                handler = function ( _, result, message )
                    lbl_result:ibBatchData( { text = message, color = result and "0xffffde9e" or "0xffab464b" } )
                end,
            } )

            ibCreateButton( 0, 415, 177, 49, ui.invite, "img/btn_send_invite", true ):center_x( )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                local nickname = edit:ibData( "text" )
                if utf8.gsub( nickname, " ", "" ) == "" then
                    localPlayer:ShowError( "Введите ник игрока" )
                    return
                end

                triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_INVITE_MEMBER, nickname )
                ibClick( )
            end )

            ibCreateButton( 0, 615, 108, 42, ui.invite, "img/btn_hide", true ):center_x( )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                setStateComponent( "invite", false )
                ibClick( )
            end )

            ibOverlaySound( )
        end,
    },

    tab_main = {
        create = function ( )
            ui.tab_main = ibCreateArea( 0, 140, 1024, 630, ui.window_rt ):ibData( "alpha", 0 )

            -- name of party
            local title = ibCreateLabel( 30, 40, 0, 0, "Название тусовки:", ui.tab_main, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_14 )
            local name = ibCreateLabel( 167, 39, 0, 0, CURRENT_PARTY.name, ui.tab_main, nil, nil, nil, nil, "center", ibFonts.bold_16 )

            if CURRENT_PARTY.is_owner then
                local edit_bg = ibCreateImage( 30, 25, 708, 30, "img/edit_bg.png", ui.tab_main )
                local edit = ibCreateWebEdit( 10, 0, 688, 30, CURRENT_PARTY.name, edit_bg, 0xffffffff, 0 )
                :ibBatchData( { alpha = 0, priority = -1, max_length = 32, placeholder = "Введите название тусовки", font = "regular_10_600", placeholder_color = "0xff9da4ad" } )

                local function revert( active )
                    edit:ibBatchData( { alpha = active and 0 or 255, priority = active and -1 or 1 } )
                    edit_bg:ibBatchData( { alpha = active and 0 or 255, priority = active and -1 or 1 } )
                    ui.btn_save_edit_name:ibBatchData( { alpha = active and 0 or 255, priority = active and -1 or 1 } )

                    ui.btn_edit_name:ibBatchData( { alpha = active and 255 or 0, priority = active and 1 or -1 } )
                    title:ibBatchData( { alpha = active and 255 or 0, priority = active and 1 or -1 } )
                    name:ibBatchData( { alpha = active and 255 or 0, priority = active and 1 or -1 } )
                end

                ui.btn_edit_name = ibCreateButton( 40 + title:width( ) + name:width( ), 25, 30, 30, ui.tab_main, "img/btn_rename.png", nil, nil, 0x55ffffff, 0xaaffffff, 0xaaffffff )
                :ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end

                    revert( false )
                    ibClick( )
                end )

                ui.btn_save_edit_name = ibCreateButton( 700, 25, 30, 30, ui.tab_main, "img/btn_save.png", nil, nil, 0x55ffffff, 0xaaffffff, 0xaaffffff )
                :ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end

                    revert( true )
                    ibClick( )

                    name:ibData( "text", edit:ibData( "text" ) )
                    ui.btn_edit_name:ibData( "px", 40 + title:width( ) + name:width( ) )
                    triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_RENAME, edit:ibData( "text" ) )
                end )

                revert( true )
            end

            -- members list request
            requestData( PARTY_MEMBERS )

            -- top list request
            requestData( PARTY_TOP_LIST )
        end,
    },

    members_list = {
        watch = PARTY_MEMBERS,
        create = function ( _, members )
            local is_owner = CURRENT_PARTY.is_owner
            local x_pos_clm_online = is_owner and 425 or 770

            ui.members_list = ibCreateImage( 0, 70, 1024, 27, nil, ui.tab_main, 0xff586c80 )
            ibCreateLabel( 30, 0, 0, 27, "Ник игрока", ui.members_list, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_12 )
            ibCreateLabel( x_pos_clm_online, 0, 0, 27, "В сети", ui.members_list, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_12 )

            if is_owner then
                ibCreateLabel( 770, 0, 0, 27, "Заявка", ui.members_list, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_12 )
                ui.btn_accept_all = ibCreateButton( 830, 8, 98, 14, ui.members_list, "img/btn_accept_all", true )
                :ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end

                    ibClick( )
                    ibConfirm( {
                        title = "ЗАЯКИ",
                        text = "Одобрить все заявки, на вступление в тусовку?",
                        fn = function( self )
                            self:destroy( )
                            triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_ACCEPT_MEMBER_ALL )
                        end,
                        escape_close = true,
                    } )
                end ):ibBatchData( { disabled = true, alpha = 0 } )
            end

            local scrollpane, scrollbar = ibCreateScrollpane( 0, 27, 1024, 266, ui.members_list, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
            scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )

            local online_counter = 0
            local total_counter = 0

            for idx, member in pairs( members or { } ) do
                local is_member = member.party_role >= PARTY_ROLE_MEMBER

                if is_owner or is_member then
                    local row = is_owner and idx or total_counter + 1
                    local is_online = GetPlayer( member.id )
                    local bg = ibCreateImage( 0, ( row - 1 ) * 38, 1024, 38, nil, scrollpane, ( row % 2 == 0 ) and 0x00000000 or 0x33314050 )

                    ibCreateLabel( 30, 0, 0, 38, member.nickname, bg, nil, nil, nil, nil, "center", ibFonts.bold_14 )
                    ibCreateLabel( x_pos_clm_online, 0, 0, 38, is_online and "В сети" or "Оффлайн", bg, nil, nil, nil, nil, "center", ibFonts.bold_14 )
                    ibCreateImage( x_pos_clm_online + 100, 13, 11, 11, is_online and "img/on.png" or "img/off.png", bg )

                    if is_owner and member.party_role == PARTY_ROLE_REQUEST then
                        ui.btn_accept_all:ibBatchData( { disabled = false, alpha = 255 } )

                        ibCreateButton( 770, 6, 71, 25, bg, "img/btn_accept.png", "img/btn_accept_hover.png", nil )
                        :ibOnClick( function ( key, state )
                            if key ~= "left" or state ~= "up" then return end

                            ibClick( )
                            ibConfirm( {
                                title = "ЗАЯКА",
                                text = "Одобрить заявку игрока\n" .. member.nickname .. ", на вступление в тусовку?",
                                fn = function( self )
                                    CURRENT_PARTY.saved_scroll_position = scrollbar:ibData( "position" )
                                    self:destroy( )
                                    triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_ACCEPT_MEMBER, member )
                                end,
                                escape_close = true,
                            } )
                        end )

                        ibCreateButton( 855, 6, 71, 25, bg, "img/btn_decline.png", "img/btn_decline_hover.png", nil )
                        :ibOnClick( function ( key, state )
                            if key ~= "left" or state ~= "up" then return end

                            ibClick( )
                            ibConfirm( {
                                title = "ЗАЯКА",
                                text = "Отклонить заявку игрока\n" .. member.nickname .. ", на вступление в тусовку?",
                                fn = function( self )
                                    CURRENT_PARTY.saved_scroll_position = scrollbar:ibData( "position" )
                                    self:destroy( )
                                    triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_DECLINE_MEMBER, member )
                                end,
                                escape_close = true,
                            } )
                        end )

                        ibCreateButton( 970, 4, 30, 30, bg, "img/btn_delete.png" ):ibData( "alpha", 50 )
                    elseif is_owner and member.id ~= localPlayer:GetID( ) then
                        ibCreateButton( 970, 4, 30, 30, bg, "img/btn_delete.png", nil, nil, 0x99ffffff, 0xffffffff )
                        :ibOnClick( function ( key, state )
                            if key ~= "left" or state ~= "up" then return end

                            ibClick( )
                            ibConfirm( {
                                title = "ИСКЛЮЧЕНИЕ ИГРОКА",
                                text = "Вы точно хотите исключить игрока\n" .. member.nickname .. " из тусовки?",
                                fn = function( self )
                                    CURRENT_PARTY.saved_scroll_position = scrollbar:ibData( "position" )
                                    self:destroy( )
                                    triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_DELETE_MEMBER, member )
                                    requestData( PARTY_MEMBERS )
                                end,
                                escape_close = true,
                            } )
                        end )
                    end

                    if is_member then
                        total_counter = total_counter + 1

                        if is_online then
                            online_counter = online_counter + 1
                        end
                    end
                end
            end

            scrollpane:AdaptHeightToContents( )
            scrollbar:UpdateScrollbarVisibility( scrollpane )
            scrollbar:ibData( "position", CURRENT_PARTY.saved_scroll_position or 0 )

            -- players online
            local lbl_total = ibCreateLabel( 994, -30, 0, 0, "/" .. total_counter, ui.members_list, 0x77ffffff, nil, nil, "right", "center", ibFonts.bold_14 )
            local lbl_online = ibCreateLabel( 994 - lbl_total:width( ) - 2, -30, 0, 0, online_counter, ui.members_list, nil, nil, nil, "right", "center", ibFonts.bold_16 )
            ibCreateLabel( 994 - lbl_total:width( ) - lbl_online:width( ) - 10, -30, 0, 0, "Количество игроков онлайн:", ui.members_list, 0x77ffffff, nil, nil, "right", "center", ibFonts.regular_12 )
        end,
    },

    top_list = {
        watch = PARTY_TOP_LIST,
        create = function ( _, top_list )
            ibCreateImage( 27, 376, 380, 25, "img/top_title.png", ui.tab_main )

            local hdr_top = ibCreateImage( 0, 415, 1024, 27, nil, ui.tab_main, 0xff586c80 )
            ibCreateLabel( 30, 0, 0, 27, "Ник игрока", hdr_top, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_12 )
            ibCreateLabel( 770, 0, 0, 27, "Награда", hdr_top, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_12 )

            local scrollpane_top, scrollbar_top = ibCreateScrollpane( 0, 442, 1024, 188, ui.tab_main, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
            scrollbar_top:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )

            for idx, data in ipairs( top_list ) do
                local bg = ibCreateImage( 0, ( idx - 1 ) * 38, 1024, 38, nil, scrollpane_top, ( idx % 2 == 1 ) and 0x33314050 or 0x00000000 )
                ibCreateLabel( 30, 0, 0, 38, data.nickname, bg, nil, nil, nil, nil, "center", ibFonts.bold_14 )
                ibCreateLabel( 770, 0, 0, 38, data.reward_name, bg, nil, nil, nil, nil, "center", ibFonts.bold_14 )
            end

            scrollpane_top:AdaptHeightToContents( )
            scrollbar_top:UpdateScrollbarVisibility( scrollpane_top )
        end,
    },

    tab_play = {
        create = function ( )
            ui.tab_play = ibCreateArea( 0, 140, 1024, 630, ui.window_rt )

            -- request num of reward list
            requestData( PARTY_REWARD_RESULT )

            -- timer of update reward list
            requestData( PARTY_UP_TIMER )

            if not CURRENT_PARTY.is_owner then return end

            -- buttons
            local bg_bottom = ibCreateImage( 0, 540, 1024, 90, "img/bg_bottom.png", ui.tab_play )

            ibCreateButton( 30, 23, 262, 44, bg_bottom, "img/btn_send_noti", true )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                setStateComponent( "notification", true )
                ibClick( )
            end )

            ibCreateButton( 322, 23, 153, 44, bg_bottom, "img/btn_start_party", true )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibConfirm( {
                    title = "НАЧАЛО ТУСОВКИ",
                    text = "Начинаем тусовку?",
                    fn = function( self )
                        self:destroy( )
                        triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_START )
                    end,
                    escape_close = true,
                } )
                ibClick( )
            end )

            ibCreateButton( 506, 23, 242, 44, bg_bottom, "img/btn_start_play", true )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibConfirm( {
                    title = "НАЧАЛО РОЗЫГРЫША",
                    text = "Начинаем розыгрыш?",
                    fn = function( self )
                        self:destroy( )
                        triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_START_DRAW )
                    end,
                    escape_close = true,
                } )
                ibClick( )
            end )

            ibCreateButton( 780, 23, 216, 44, bg_bottom, "img/btn_party_end", true )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibConfirm( {
                    title = "ЗАВЕРШЕНИЕ СБОРА",
                    text = "Завершить сбор прямо сейчас?",
                    fn = function( self )
                        self:destroy( )
                        triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_END )
                    end,
                    escape_close = true,
                } )
                ibClick( )
            end )
        end,
    },

    up_timer = {
        watch = PARTY_UP_TIMER,
        create = function ( _, time )

            ui.up_timer = ibCreateLabel( 994, 35, 0, 0, "", ui.tab_play, nil, nil, nil, "right", "center", ibFonts.bold_16 )
            local info = ibCreateLabel( 0, 1, 0, 0, "", ui.up_timer, 0x77ffffff, nil, nil, "right", "center", ibFonts.regular_14 )
            local icon = ibCreateImage( 0, -10, 17, 20, "img/icon_timer.png", ui.up_timer ):ibData( "alpha", 0 )

            ui.up_timer:ibTimer( function ( self )
                time = time - 1

                if time == 0 then
                    setStateComponent( "up_timer", false )

                    -- request num of reward list
                    requestData( PARTY_REWARD_RESULT )
                    return
                end

                local t = ConvertSecondsToTime( time )
                t.hour = string.format( "%02d", t.hour )
                t.minute = string.format( "%02d", t.minute )
                t.second = string.format( "%02d", t.second )

                self:ibData( "text", ( t.monthday > 0 and t.monthday .. " д. " or "" ) .. "" .. t.hour .. ":" .. t.minute .. ":" .. t.second )
                info:ibBatchData( { px = - 5 - ui.up_timer:width( ), text = "Обновление наград через:" } )
                icon:ibBatchData( { px = - 27 - ui.up_timer:width( ) - info:width( ), alpha = 150 } )
            end, 1000, 0 )
        end,
    },

    reward_list = {
        watch = PARTY_REWARD_RESULT,
        create = function ( _, pack_id, result )
            ui.reward_list = ibCreateImage( 30, 18, 160, 35, "img/prize_title.png", ui.tab_play )

            local height = 200 + ( CURRENT_PARTY.is_owner and 0 or 90 )
            local scrollpane_pr, scrollbar_pr = ibCreateScrollpane( 0, 47, 964, height, ui.reward_list, { scroll_px = 10, bg_color = 0x00FFFFFF  } )
            scrollbar_pr:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )

            local pos = 1

            for _, reward in ipairs( REWARDS_LIST[ pack_id ].rewards ) do
                for place = reward.places[ 2 ], reward.places[ 1 ], -1 do
                    local name = reward.type == "vehicle" and VEHICLE_CONFIG[ reward.id ].model or reward.name

                    local row = math.ceil( pos / 4 )

                    local bg = ibCreateArea( ( pos - 1 ) * 245 - ( 4 * 245 * ( row - 1 ) ), ( row - 1 ) * 174, 228, 156, scrollpane_pr )
                    ibCreateImage( 0, 0, 228, 156, texs.bg_prize, bg ):ibData( "alpha", 50 )
                    ibCreateLabel( 110, 107, 0, 0, name, bg, nil, nil, nil, "center", "center", ibFonts.bold_12 )

                    local px, sx = 0, 90
                    if reward.type == "case" then px, sx = -20, 130 end

                    ibCreateContentImage( 68 + px, 0, sx, 90, reward.type, reward.id, bg )

                    if result and result[ place ] then
                        ibCreateLabel( 114, 130, 0, 0, "Разыграно", bg, 0xff1fd064, nil, nil, "center", "center", ibFonts.regular_12 )
                    else
                        local lbl_result = ibCreateLabel( 114, 130, 0, 0, "Ждет розыгрыша", bg, 0x55ffffff, nil, nil, "center", "center", ibFonts.regular_12 )

                        if CURRENT_PARTY.is_owner then
                            lbl_result:ibData( "alpha", 0 )

                            ui[ "draw_" .. place ] = ibCreateButton( 73, 120, 81, 25, bg, "img/btn_play.png", "img/btn_play_hover.png", "img/btn_play_hover.png" )
                                    :ibOnClick( function ( key, state )
                                if key ~= "left" or state ~= "up" then return end

                                triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_DRAW_POS, place )
                            end )
                        end

                        table.insert( syncData, {
                            watch = PARTY_REWARD_POS,
                            handler = function ( _, pos )
                                if pos == place then
                                    lbl_result:ibBatchData( { text = "Разыграно", color = 0xff1fd064, alpha = 255 } )

                                    if ui[ "draw_" .. place ] then
                                        ui[ "draw_" .. place ]:destroy( )
                                        ui[ "draw_" .. place ] = nil
                                    end
                                end
                            end,
                        } )
                    end

                    pos = pos + 1
                end
            end

            scrollpane_pr:AdaptHeightToContents( )
            scrollbar_pr:UpdateScrollbarVisibility( scrollpane_pr )
        end,
    },

    top_current = {
        watch = PARTY_REWARD_RESULT,
        create = function ( _, pack_id, _, result )
            ui.top_current = ibCreateImage( 30, CURRENT_PARTY.is_owner and 280 or 370, 145, 35, "img/winners_title.png", ui.tab_play )

            local hdr_top = ibCreateImage( -30, 45, 1024, 27, nil, ui.top_current, 0xff586c80 )
            ibCreateLabel( 30, 0, 0, 27, "Ник игрока", hdr_top, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_12 )
            ibCreateLabel( 770, 0, 0, 27, "Награда", hdr_top, 0x55ffffff, nil, nil, nil, "center", ibFonts.regular_12 )

            local scrollpane_top, scrollbar_top = ibCreateScrollpane( -30, 72, 1024, 188, ui.top_current, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
            scrollbar_top:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )

            scrollpane_top:AdaptHeightToContents( )
            scrollbar_top:UpdateScrollbarVisibility( scrollpane_top )

            local idx = 1
            local function addRow( pos, winner_name )
                local reward = getRewardByPosition( pack_id, pos )
                local name = reward.type == "vehicle" and VEHICLE_CONFIG[ reward.id ].model or reward.name
                local bg = ibCreateImage( 0, ( idx - 1 ) * 38, 1024, 38, nil, scrollpane_top, ( idx % 2 == 1 ) and 0x33314050 or 0x00000000 )

                ibCreateLabel( 30, 0, 0, 38, winner_name, bg, nil, nil, nil, nil, "center", ibFonts.bold_14 )
                ibCreateLabel( 770, 0, 0, 38, name, bg, nil, nil, nil, nil, "center", ibFonts.bold_14 )

                scrollpane_top:AdaptHeightToContents( )
                scrollbar_top:UpdateScrollbarVisibility( scrollpane_top )

                idx = idx + 1
            end

            for pos, winner_name in pairs( result ) do
                addRow( pos, winner_name )
            end

            table.insert( syncData, {
                watch = PARTY_REWARD_POS,
                handler = function ( _, pos, winner_name )
                    addRow( pos, winner_name )
                end,
            } )
        end,
    },

    notification = {
        create = function ( )
            ui.notification = ibCreateImage( 0, 690, 1024, 690, nil, ui.window_rt, ibApplyAlpha( 0xff1f2934, 95 ) )
            :ibMoveTo( 0, 80, 250 )

            ibCreateLabel( 512, 255, 0, 0, "Отправка уведомления", ui.notification, nil, nil, nil, "center", "center", ibFonts.bold_20 )
            ibCreateLabel( 512, 285, 0, 0, "Установите время тусовки, чтобы разослать всем уведомление о начале", ui.notification, 0x55ffffff, nil, nil, "center", "center", ibFonts.regular_14 )

            local edit_bg_h = ibCreateImage( 330, 307, 107, 56, "img/edit_bg3.png", ui.notification )
            local edit_h = ibCreateWebEdit( 10, 0, 87, 56, "", edit_bg_h, 0x80ffffff, 0 )
            :ibBatchData( { max_length = 2, font = "regular_12_200", text_align = "center", placeholder = "12" } )
            ibCreateLabel( 452, 335, 0, 0, "часов", ui.notification, nil, nil, nil, nil, "center", ibFonts.regular_16 )

            local edit_bg_m = ibCreateImage( 525, 307, 107, 56, "img/edit_bg3.png", ui.notification )
            local edit_m = ibCreateWebEdit( 10, 0, 87, 56, "", edit_bg_m, 0x80ffffff, 0 )
            :ibBatchData( { max_length = 2, font = "regular_12_200", text_align = "center", placeholder = "00" } )
            ibCreateLabel( 650, 335, 0, 0, "минут", ui.notification, nil, nil, nil, nil, "center", ibFonts.regular_16 )

            local function event( )
                edit_h:ibData( "text", edit_h:ibData( "text" ):match( "%d+" ) or "" )
                edit_m:ibData( "text", edit_m:ibData( "text" ):match( "%d+" ) or "" )
            end
            addEventHandler( "onClientKey", root, event )
            ui.notification:ibOnDestroy( function ( ) removeEventHandler( "onClientKey", root, event ) end )

            ibCreateButton( 0, 385, 177, 49, ui.notification, "img/btn_send", true ):center_x( )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                local hours, minutes = tonumber( edit_h:ibData( "text" ) ), tonumber( edit_m:ibData( "text" ) )

                triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_SEND_NOTIFICATION, { hours, minutes } )
                ibClick( )
            end )

            ibCreateButton( 0, 615, 108, 42, ui.notification, "img/btn_hide", true ):center_x( )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                setStateComponent( "notification", false )
                ibClick( )
            end )

            ibOverlaySound( )
        end,
    }
}

function setStateComponent( name, state, ... )
    local currentState = isElement( ui[ name ] )

    if currentState and not state then
        ui[ name ]:destroy( )

        if COMPONENTS[ name ].destroy then
            COMPONENTS[ name ]:destroy( )
        end

        return true
    elseif not currentState and state then
        COMPONENTS[ name ]:create( ... )
        return true
    end
end

function requestData( data_id )
    triggerServerEvent( "onPartyDataRequest", resourceRoot, CURRENT_PARTY.id, data_id )
end

addEvent( "onPartyDataResponse", true )
addEventHandler( "onPartyDataResponse", resourceRoot, function ( action, ... )
    if not ui.bg and action ~= PARTY_MAIN then -- got data, but UI was destroyed
        triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_WINDOW_STATE, { "all", false } )
        return
    end

    for _, data in pairs( syncData ) do
        if data.watch == action then
            data:handler( ... )
        end
    end

    for component_name, data in pairs( COMPONENTS ) do
        if data.watch == action then
            setStateComponent( component_name, false )
            setStateComponent( component_name, true, ... )
        end
    end
end )

addEvent( "onClientShowPartyUI", false )
addEventHandler( "onClientShowPartyUI", localPlayer, function ( party )
    if ui.bg then return end

    CURRENT_PARTY = party
    requestData( PARTY_MAIN )
end )

addEvent( "onClientShowPartyInvite", true )
addEventHandler( "onClientShowPartyInvite", resourceRoot, function ( id, name )
    if helpers_ui.confirm then return end
    if not ui.bg then showCursor( true ) end

    helpers_ui.confirm = true
    ibConfirm( {
        title = "ПРИГЛАШЕНИЕ НА ТУСОВКУ",
        text = 'Вы уверены, что хотите вступить в тусовку "' .. tostring( name ) .. '"? Вступление в другую тусовку будет ограничено в течении 72 часов',
        fn = function( self )
            if not ui.bg then showCursor( false ) end
            helpers_ui.confirm = nil
            self:destroy( )
            triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_ACCEPT_INVITE, { tonumber( id ) or 0, true } )
        end,
        fn_cancel = function( )
            if not ui.bg then showCursor( false ) end
            triggerServerEvent( "onPartyActionRequest", resourceRoot, PARTY_ACCEPT_INVITE, { tonumber( id ) or 0, false } )
            helpers_ui.confirm = nil
        end,
        escape_close = true,
    } )
end )

addEvent( "onClientShowPartyInfo", true )
addEventHandler( "onClientShowPartyInfo", resourceRoot, function ( )
    if helpers_ui.info then return end
    if not ui.bg then showCursor( true ) end

    helpers_ui.info = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, nil, nil, ibApplyAlpha( 0xff344554, 95 ) )
    ibCreateImage( 0, 0, 369, 414, "img/info_radial.png", helpers_ui.info ):center( 0, -40 )

    ibCreateButton( 0, 0, 120, 44, helpers_ui.info, "img/btn_close", true ):center( 0, 220 )
    :ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end

        if not ui.bg then showCursor( false ) end

        helpers_ui.info:destroy( )
        helpers_ui.info = nil
        ibClick( )
    end )
end )

addEvent( "onClientShowPartyCreation", true )
addEventHandler( "onClientShowPartyCreation", root, function ( )
    if helpers_ui.info then return end
    if not ui.bg then showCursor( true ) end

    local onClose = function ( )
        if not ui.bg then showCursor( false ) end

        helpers_ui.bg_creation:destroy( )
        helpers_ui.bg_creation = nil
    end

    helpers_ui.bg_creation = ibCreateBackground( nil, function ( )
        onClose( )
    end, true, true )
    :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

    local bg = ibCreateImage( 0, 0, 600, 400, "img/bg_creation.png", helpers_ui.bg_creation ):center( )

    -- close button
    ibCreateButton( 548, 29, 22, 22, bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end
        onClose( )
        ibClick( )
    end )

    ibCreateButton( 0, 328, 202, 42, bg, "img/btn_create_party", true ):center_x( )
    :ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end
        onClose( )
        ibClick( )

        triggerServerEvent( "onPlayerRequestCreateParty", resourceRoot )
    end )
end )