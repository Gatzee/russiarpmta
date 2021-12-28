local UI = { }

function ShowClanCreateUI( state )
    if state then
        ShowClanCreateOrJoinUI( false )
        ShowClanJoinUI( false )
        ShowClanCreateUI( false )
        ibInterfaceSound()

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowClanCreateUI, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 100 ) ):center( )

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 90, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
        UI.head_lbl = ibCreateLabel( 0, 0, UI.head_bg:ibData( "sx" ), UI.head_bg:ibData( "sy" ), "Создать клан", UI.head_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
        UI.btn_back = ibCreateButton( 30, 0, 110, 17, UI.head_bg, "img/btn_back.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :center_y( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                if UI.current_step == 2 then
                    ShowClanCreatingEnterNameStep( )
                else
                    ShowClanCreateUI( false )
                    ShowClanCreateOrJoinUI( true )
                end
            end )
        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanCreateUI( false )
            end )

        UI.balance_area = ibCreateArea( 0, 5, 100, UI.head_bg:ibData( "sy" ), UI.head_bg )
        -- UI.account_img = ibCreateImage( 0, 0, 41, 40, "images/icon_account.png", UI.balance_area ):center_y( )
        UI.balance_text_lbl = ibCreateLabel( 55, 20, 0, 0, "Ваш баланс:", UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
        UI.balance_lbl = ibCreateLabel( UI.balance_text_lbl:ibGetAfterX( 8 ), 16, 0, 0, format_price( localPlayer:GetMoney( ) ), UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
        UI.balance_money_img = ibCreateImage( UI.balance_lbl:ibGetAfterX( 8 ), 16, 24, 24, ":nrp_shared/img/money_icon.png", UI.balance_area )
        UI.btn_recharge = ibCreateButton( -5, 22, 136, 20, UI.balance_text_lbl, "img/btn_recharge.png", _, _, 0x6FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
                ShowClanCreateUI( false )
            end )
        local function UpdateBalance( )
            UI.balance_lbl:ibData( "text", format_price( localPlayer:GetMoney( ) ) )
            UI.balance_money_img:ibData( "px", UI.balance_lbl:ibGetAfterX( 8 ) )
            UI.balance_area:ibData( "px", UI.btn_close:ibGetBeforeX( -30 - UI.balance_money_img:ibGetAfterX( ) ) )
        end
        UpdateBalance( )
        UI.balance_area:ibTimer( UpdateBalance, 1000, 0 )

        ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )

        ShowClanCreatingEnterNameStep( )

        UI.bg:ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
        
        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "ShowClanCreateUI", true )
addEventHandler( "ShowClanCreateUI", root, ShowClanCreateUI )

function ShowClanCreatingEnterNameStep( )
    if isElement( UI.body ) then
        UI.body:ibAlphaTo( 0, 500 ):ibTimer( destroyElement, 500, 1 )
    elseif not isElement( UI.bg ) then
        ShowClanCreateUI( true )
    end

    UI.current_step = 1

    UI.body = ibCreateArea( 0, UI.head_bg:ibGetAfterY( ), UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" ) - UI.head_bg:ibData( "sy" ), UI.bg )

    SELECTED_CLAN_TAG = SELECTED_CLAN_TAG or math.random( CLANTAGS_AMOUNT )
    UI.btn_select_clan_tag = ibCreateButton( 30, 30, 256, 293, UI.body, _, _, _, 0x19FFFFFF, 0x33FFFFFF, 0x40000000 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowClanTagSelector( )
        end )
    UI.clan_tag = ibCreateImage( 0, 0, 192, 192, ":nrp_clans/img/tags/band/" .. SELECTED_CLAN_TAG .. ".png", UI.btn_select_clan_tag ):ibData( "disabled", true )
        :center( 0, -10 )
    ibCreateLabel( 0, 0, 0, 0, "Выбрать изображение", UI.btn_select_clan_tag, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "center", "top", ibFonts.regular_12 )
        :center( 0, 78 )

    function ShowClanTagSelector( )
        if isElement( UI.bg_select_clan_tag ) then
            UI.bg_select_clan_tag:ibData( "visible", not UI.bg_select_clan_tag:ibData( "visible" ) )
            return
        end

        local col_sx = 162
        local col_count = 2
        local hovered = false
        UI.bg_select_clan_tag = ibCreateImage( 308, 30, col_sx * col_count + 1, 410, _, UI.body, 0xFF697a8c )
            :ibOnHover( function( )
                repeat
                    if source == this then
                        hovered = true
                        return
                    end
                    source = source.parent
                until not source
            end, true )
            :ibOnLeave( function( )
                repeat
                    if source == this then
                        hovered = false
                        return
                    end
                    source = source.parent
                until not source
            end, true )
            :ibOnAnyClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if not UI.bg_select_clan_tag:ibData( "visible" ) or hovered then return end
                UI.bg_select_clan_tag:ibTimer( UI.bg_select_clan_tag.ibData, 50, 1, "visible", false )
            end )

        ibCreateImage( -10, col_sx / 2 - 10, 10, 21, "img/triangle.png", UI.bg_select_clan_tag )

        UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 0, 0, col_sx * col_count + 1, 410, UI.bg_select_clan_tag, { scroll_px = -15 } )
        UI.scrollbar:ibSetStyle( "slim_small_nobg" )
        
        for i = 1, CLANTAGS_AMOUNT do
            local row = math.floor( ( i - 1 ) / col_count )
            local col = ( i - 1 ) % col_count
            local url = ":nrp_clans/img/tags/band/" .. i .. ".png"
            local btn = ibCreateButton( col * ( col_sx + 1 ), row * ( col_sx + 1 ), col_sx, col_sx, UI.scrollpane, _, _, _, 0xFF586b80, 0x33FFFFFF, 0x40000000 )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ibClick( )
                    SELECTED_CLAN_TAG = i
                    UI.clan_tag:ibData( "texture", url )
                    UI.bg_select_clan_tag:ibData( "visible", false )
                end )
            
            ibCreateImage( 0, 0, 128, 128, url, btn ):ibData( "disabled", true )
                :center( )
        end

        UI.scrollpane:AdaptHeightToContents( )
        UI.scrollbar:UpdateScrollbarVisibility( UI.scrollpane )
    end

    local cost = ( localPlayer:getData( "offer_clan" ) or { } ).new_price
    if not cost or ( ( localPlayer:getData( "offer_clan" ) or { } ).time_to or 0 ) <= getRealTimestamp( ) then
        cost = CLAN_CREATION_COST
    end
    
    ibCreateLabel( 316, 83, 0, 0, "Стоимость создания клана:", UI.body, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "left", "top", ibFonts.regular_15 )
    UI.lbl_price = ibCreateLabel( 316, 121, 0, 0, format_price( cost ), UI.body, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_21 )
    ibCreateImage( UI.lbl_price:width( ) + 10, 0, 28, 28, ":nrp_shared/img/money_icon.png", UI.lbl_price )

    UI.edit_name = ibCreateWebEdit( 316, 175, 644, 51, SELECTED_CLAN_NAME or "", UI.body, COLOR_WHITE )
        :ibBatchData( {
            font = "regular_12",
            max_length = 12,
            placeholder = "Введите название клана",
            placeholder_color = ibApplyAlpha( COLOR_WHITE, 20 ),
            bg_color = 0xFF3e5065,
            bg_color_focused = 0xFF2c3a49,
        } )

    if localPlayer:GetMoney( ) < cost then
        UI.lbl_recharge = ibCreateLabel( 316, 250, 0, 0, "На вашем счете недостаточно средств - ", UI.body, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "left", "top", ibFonts.regular_15 )
        UI.btn_recharge = ibCreateButton( UI.lbl_recharge:width( ) - 3, 1, 136, 20, UI.lbl_recharge, "img/btn_recharge.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
                ShowClanCreateUI( false )
            end )
    end

    UI.btn_create = ibCreateButton( 0, UI.body:ibData( "sy" ) - 30 - 53, 178, 53, UI.body, 
            "img/btn_create_green.png", "img/btn_create_green_hover.png", "img/btn_create_green_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
        :center_x( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            SELECTED_CLAN_NAME = UI.edit_name:ibData( "text" )

            if not SELECTED_CLAN_NAME or SELECTED_CLAN_NAME == "" then
                localPlayer:ShowError( "Введите название клана" )
                return
            end

            if utf8.len( SELECTED_CLAN_NAME ) < 3 or utf8.len( SELECTED_CLAN_NAME ) > 12 then
                localPlayer:ShowError( "Название должно содержать от 3 до 12 символов" )
                return
            end

            if not utf8.find( SELECTED_CLAN_NAME, "^[a-zA-Zа-яА-Я0-9\-]+$" ) then
                localPlayer:ShowError( "Название может содержать только цифры, буквы и дефис" )
                return
            end

            if utf8.find( SELECTED_CLAN_NAME, "^-" ) or utf8.find( SELECTED_CLAN_NAME, "-$" ) then
                localPlayer:ShowError( "Название не может начинаться или заканчиваться дефисом" )
                return
            end

            ShowClanCreatingSelectWayStep( )
        end )
end

function ShowClanCreatingSelectWayStep( )
    if isElement( UI.body ) then
        UI.body:ibAlphaTo( 0, 500 ):ibTimer( destroyElement, 500, 1 )
    elseif not isElement( UI.bg ) then
        ShowClanCreateUI( true )
    end

    UI.current_step = 2

    UI.body = ibCreateArea( 0, UI.head_bg:ibGetAfterY( ), UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" ) - UI.head_bg:ibData( "sy" ), UI.bg )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )

    UI.bg_select_way = ibCreateImage( 30, 30, 964, 616, "img/bg_select_way.png", UI.body )
    
    local col_sx, col_sy = 308, 558
    for i = 1, 3 do
        local bg_hover = ibCreateArea( 0, 88, col_sx, col_sy, UI.body )
            :center_x( 328 * ( i - 2 ) )
            :ibData( "alpha", 0 )
            :ibOnHover( function() source:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnLeave( function() source:ibAlphaTo( 0, 500, "OutQuad" ) end)
        ibCreateImage( 0, 0, col_sx, 2, _, bg_hover, 0xFF6996c7 )
        ibCreateImage( 0, 2, 2, col_sy - 2, _, bg_hover, 0xFF6996c7 )
        ibCreateImage( col_sx, 2, -2, col_sy - 2, _, bg_hover, 0xFF6996c7 )
        ibCreateImage( 2, col_sy, col_sx - 4, -2, _, bg_hover, 0xFF6996c7 )

        ibCreateButton( 0, col_sy - 30 - 42, 138, 42, bg_hover, 
                "img/btn_select.png", _, _, 0, 0xFFFFFFFF, 0xFFAAAAAA )
            :center_x( )
            :ibOnHover( function() bg_hover:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                if ( CLICK_TIMEOUT or 0 ) > getTickCount( ) then return end
                CLICK_TIMEOUT = getTickCount( ) + 1000
                ibClick( )

                SELECTED_CLAN_WAY = i
                triggerServerEvent( "onPlayerWantCreateClan", localPlayer, SELECTED_CLAN_NAME, SELECTED_CLAN_TAG, SELECTED_CLAN_WAY, SELECTED_BASE_ID )

                UI.loading = ibLoading( { text = "Создание\nклана...", priority = 999999 } )
            end )
    end
end

addEvent( "onClientClanCreateResponse", true )
addEventHandler( "onClientClanCreateResponse", root, function( status )
    if status == true then
        ShowClanCreateUI( false )
    else
        if isElement( UI.loading ) then
            UI.loading:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        end
        if status then
            localPlayer:ShowError( status )
        end
        if error == "Это название уже занято" then
            ShowClanCreatingEnterNameStep( )
        end
    end
end )