loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ShClans" )
Extend( "ib" )
Extend( "ib/tabPanel" )

ibUseRealFonts( true )

UI = { }

TABS = {
    {
        name = "Хранилище",
        key  = "storage",
    },
}
TABS_CONF = { }

CLAN_DATA = { }

for i, data in pairs( WEAPONS_LIST ) do
    data.name = data.Name
end

local TYPE_TO_STR = {
    [ IN_WEAPON ] = "weapon",
    [ IN_DRUGS ] = "drugs",
}

local ITEMS_INFO = {
    [ IN_WEAPON ] = WEAPONS_LIST,
    [ IN_DRUGS ] = DRUGS,
}

function ShowClanStorageUI( state, data )
    if state then
        ShowClanStorageUI( false )
        ibInterfaceSound()
        showCursor( true )

        CLAN_DATA = data

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowClanStorageUI, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 95 ) ):center( )

        -------------------------------------------------------------------
        -- Header 

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 92, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
        
        UI.img_clan_tag = ibCreateImage( 25, 30, 64, 64, ":nrp_clans/img/tags/band/" .. CLAN_DATA.tag .. ".png", UI.head_bg )
            :center_y( )
        UI.lbl_clan_name = ibCreateLabel( 107, 24, 0, 0, CLAN_DATA.name, UI.head_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_20 )

        local next_rank_conf = CLAN_RANKS[ CLAN_DATA.rank + 1 ]
        local required_exp = next_rank_conf and next_rank_conf.required_exp
        local progress = required_exp and CLAN_DATA.exp / required_exp or 1
        UI.lvl_progress_bar_bg = ibCreateImage( 107, 54, 114, 12, _, UI.head_bg, ibApplyAlpha( COLOR_BLACK, 25 ) )
        UI.lvl_progress_bar = ibCreateImage( 107, 54, 114 * progress, 12, _, UI.head_bg, 0xFF47afff )
        UI.lbl_clan_rank = ibCreateLabel( UI.lvl_progress_bar_bg:ibGetAfterX( 10 ), 48, 0, 0, CLAN_DATA.rank .. " уровень", UI.head_bg, ibApplyAlpha( COLOR_WHITE, 60 ), 1, 1, "left", "top", ibFonts.bold_15 )

        function UpdateLevelProgressBar( old_data )
            UI.lbl_clan_rank:ibData( "text", CLAN_DATA.rank .. " уровень" )
            local next_rank_conf = CLAN_RANKS[ CLAN_DATA.rank + 1 ]
            local required_exp = next_rank_conf and next_rank_conf.required_exp
            local progress = required_exp and CLAN_DATA.exp / required_exp or 1
            if old_data.rank < CLAN_DATA.rank then
                UI.lvl_progress_bar
                    :ibResizeTo( 114, 12, 200 )
                    :ibTimer( UI.lvl_progress_bar.ibResizeTo, 250, 1, 0, 12 )
                    :ibTimer( UI.lvl_progress_bar.ibResizeTo, 500, 1, 114 * progress, 12 )
            else
                UI.lvl_progress_bar:ibResizeTo( 114 * progress, 12 )
            end
        end
        UPDATE_UI_HANDLERS.exp = UpdateLevelProgressBar

        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanStorageUI( false )
            end )

        UI.btn_recharge = ibCreateButton( -30 - 140, -3, 140, 31, UI.btn_close, ":nrp_clans_ui_main/img/btn_donate.png", _, _, 0x9FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ibInput(
                    {
                        title = "Общак клана", 
                        text = "",
                        edit_text = "Введите сумму для пожертвования",
                        btn_text = "ОК",
                        fn = function( self, text )
                            local amount = tonumber( text )
                            if not amount or amount <= 0 or amount ~= math.floor( amount ) then
                                localPlayer:ErrorWindow( "Неверная сумма для пополнения!" )
                                return
                            end

                            triggerServerEvent( "onPlayerWantAddClanMoney", localPlayer, amount )
                            self:destroy()
                        end
                    }
                )
            end )
        
        UI.balance_area = ibCreateArea( 0, 0, 0, 0, UI.btn_recharge ):center_y( )
        UI.balance_text_lbl = ibCreateLabel( 0, 2, 0, 0, "Общак клана:", UI.balance_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_14 )
        UI.balance_lbl = ibCreateLabel( UI.balance_text_lbl:ibGetAfterX( 8 ), 1, 0, 0, format_price( CLAN_DATA.money ), UI.balance_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
        UI.balance_money_img = ibCreateImage( UI.balance_lbl:ibGetAfterX( 8 ), 28, 24, 24, ":nrp_shared/img/money_icon.png", UI.balance_area ):center_y( )

        function UpdateClanMoneyLabel( )
            if not isElement( UI.balance_lbl ) then return end
            UI.balance_lbl:ibData( "text", format_price( CLAN_DATA.money ) )
            UI.balance_money_img:ibData( "px", UI.balance_lbl:ibGetAfterX( 8 ) )
            UI.balance_area:ibData( "px", -30 - UI.balance_money_img:ibGetAfterX( ) )
        end
        UpdateClanMoneyLabel( )
        UPDATE_UI_HANDLERS.money = UpdateClanMoneyLabel

        ibCreateLine( 0, UI.head_bg:height( ) - 1, UI.head_bg:ibData( "sx" ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, UI.head_bg )

        -------------------------------------------------------------------
        
        UI.tab_panel = ibCreateTabPanel( {
            px = 0,
            py = UI.head_bg:ibGetAfterY( ),
            sx = UI.bg:ibData( "sx" ),
            sy = UI.bg:ibData( "sy" ) - UI.head_bg:ibGetAfterY( ),
            parent = UI.bg,
            tabs = TABS,
            tabs_conf = TABS_CONF,
            current = current or 1,
            precreate_all_tabs_content = true,
            create_tab_area_under_navbar = true,
            navbar_conf = {
                sy = 63,
                font = ibFonts.bold_16,
            },
        } )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "ShowClanStorageUI", true )
addEventHandler( "ShowClanStorageUI", root, ShowClanStorageUI )

TABS_CONF.storage = {
    fn_create = function( self, parent )
        local scrollpane, scrollbar = ibCreateScrollpane( 30, 0, parent:width( ) - 60, parent:height( ), parent, { scroll_px = 10 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local area_items

        function UpdateStorageItemsPane( )
            if isElement( area_items ) then
                area_items:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            if not next( CLAN_DATA.storage ) then
                ibCreateLabel( 0, 0, 0, 0, "В хранилище пусто. Вы можете купить предметы у Барыги", scrollpane, ibApplyAlpha( COLOR_WHITE, 80 ), 1, 1, "center", "center", ibFonts.regular_22 )
                    :center( )
            end

            area_items = ibCreateArea( 0, 20, 0, 0, scrollpane )

            local col_count = 3
            local col_sx = 309
            local gap = 20
            local npx, npy = 0, 0
            for i, item in pairs( CLAN_DATA.storage ) do
                if i > 1 and i % col_count == 1 then
                    npx = 0
                    npy = npy + col_sx + gap
                elseif i > 1 then
                    npx = npx + col_sx + gap
                end
                
                local bg_item = ibCreateImage( npx, npy, col_sx, col_sx, ":nrp_clans_ui_manage/img/shop/bg_item.png", area_items )
                local bg_item_hover = ibCreateImage( 0, 0, col_sx, col_sx, ":nrp_clans_ui_manage/img/shop/bg_item_hover.png", bg_item )
                    :ibData( "disabled", true )
                    :ibData( "alpha", 0 )
                    
                bg_item:ibOnHover( function( ) bg_item_hover:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) bg_item_hover:ibAlphaTo( 0, 200 ) end )

                ibCreateLabel( 0, 20, 0, 0, ITEMS_INFO[ item.type ][ item.id ].name, bg_item, COLOR_WHITE, 1, 1, "center", "top", ibFonts.regular_16 )
                    :center_x( )

                ibCreateLabel( 0, 40, 0, 0, item.count .. " шт.", bg_item, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "center", "top", ibFonts.regular_12 )
                    :center_x( )

                ibCreateImage( 0, 0, 0, 0, ":nrp_clans_ui_manage/img/shop/items/" .. TYPE_TO_STR[ item.type ] .. "_" .. item.id .. ".png", bg_item )
                    :ibData( "disabled", true )
                    :ibSetRealSize( )
                    :center(  )

                if localPlayer:GetClanRole( ) >= CLAN_ROLE_MODERATOR then
                    ibCreateButton( 0, col_sx - 20 - 34, 93, 34, bg_item, 
                            "img/btn_give.png", "img/btn_give_hover.png", "img/btn_give_hover.png", _, _, 0xFFAAAAAA )
                        :center_x( )
                        :ibOnHover( function( ) bg_item_hover:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) bg_item_hover:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowGiveItemOverlay( item )
                        end )
                end
            end

            area_items:ibData( "sy", npy + col_sx + 20 )
            scrollpane:AdaptHeightToContents( )
            scrollbar:UpdateScrollbarVisibility( scrollpane )
        end
        UpdateStorageItemsPane( )
    end,
}

function ShowGiveItemOverlay( item )
    if isElement( UI.bg_overlay ) then
        UI.bg_overlay
            :ibMoveTo( _, UI.bg_overlay:height( ), 200 )
            :ibTimer( destroyElement, 200, 1 )
    end
    if not item then return end

    ibOverlaySound( )

    local parent = UI.tab_panel.elements.rt

    local bg_overlay = ibCreateImage( 0, parent:height( ), parent:width( ), parent:height( ), _, parent, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "priority", 2 )
        :ibMoveTo( 0, 0, 200 )
    UI.bg_overlay = bg_overlay

    local footer_sy = 202

    local scrollpane, scrollbar = ibCreateScrollpane( 0, 83, 
        bg_overlay:width( ), bg_overlay:height( ) - 83 - footer_sy, 
        bg_overlay, { scroll_px = -20 } 
    )
    scrollbar:ibSetStyle( "slim_nobg" )

    local row_sx = scrollpane:ibData( "sx" )
    local row_sy = 52

    local players = { }
    table.insert( players, localPlayer )
    for k, member in pairs( localPlayer:GetClanTeam( ).players ) do
        if member ~= localPlayer and member.dimension == localPlayer.dimension then
            table.insert( players, member )
        end
    end

    for i, member in pairs( players ) do
        local item_bg = ibCreateImage( 0, row_sy * ( i - 1 ), row_sx, row_sy, _, scrollpane, ibApplyAlpha( 0xFF314050, ( i % 2 ) * 25 ) )

        local px = 30
        local lbl_i = ibCreateLabel( px, 0, 0, row_sy, i, item_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_15 )

        px = px + 89
        local lbl_name = ibCreateLabel( px, 0, 0, row_sy, member:GetNickName( ), item_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_15 )

        px = px + 390
        local count = 0
        local num_bg = ibCreateImage( px + 32, 0, 42, 26, ":nrp_clans_ui_manage/img/shop/num_bg.png", item_bg ):center_y( )
        local lbl_num = ibCreateLabel( 0, 0, num_bg:width( ), num_bg:height( ), count, num_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
        ibCreateButton( px, 0, 25, 25, item_bg, ":nrp_clans_ui_manage/img/shop/num_btn_minus.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
            :center_y( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end                    
                ibClick( )
                count = math.max( 0, math.min( item.count, count - 1 ) )
                lbl_num:ibData( "text", count )
            end )
        ibCreateButton( px + 80, 0, 25, 25, item_bg, ":nrp_clans_ui_manage/img/shop/num_btn_plus.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
            :center_y( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end                    
                ibClick( )
                count = math.max( 0, math.min( item.count, count + 1 ) )
                lbl_num:ibData( "text", count )
            end )

        px = item_bg:width( ) - 30 - 100
        local btn_give = ibCreateButton( px, 0, 100, 34, item_bg, 
                "img/btn_give.png", "img/btn_give_hover.png", "img/btn_give_hover.png", _, _, 0xFFAAAAAA )
            :center_y( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
            
                if not count or count <= 0 then
                    localPlayer:ShowError( "Укажите необходимое количество!" )
                    return
                end
    
                if item.count < count then
                    localPlayer:ShowError( "В наличии только " .. item.count .. " шт." )
                    return
                end

                if not isElement( member ) then
                    localPlayer:ShowError( "Этот игрок вышел из игры" )
                    return
                end

                if member.dimension ~= localPlayer.dimension then
                    localPlayer:ShowError( "Игрок должен быть в подвале клана" )
                    return
                end
    
                triggerServerEvent( "onPlayerWantGiveItemFromClanStorage", localPlayer, item, count, { member } )
            end )
    end
	scrollpane:AdaptHeightToContents( )
    scrollbar:UpdateScrollbarVisibility( scrollpane )



    local footer_bg = ibCreateImage( 0, bg_overlay:height( ) - footer_sy, bg_overlay:width( ), 100, _, bg_overlay, ibApplyAlpha( COLOR_WHITE, 10 ) )
    ibCreateLine( 0, 0, footer_bg:width( ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, footer_bg )

    local area_givetoall = ibCreateArea( 0, 0, 0, 0, footer_bg )
        :center_y( )
    local img_weapon = ibCreateImage( 0, 0, 0, 0, ":nrp_clans_ui_manage/img/shop/items/" .. TYPE_TO_STR[ item.type ] .. "_" .. item.id .. ".png", area_givetoall )
        :ibSetRealSize( )
        :ibSetInBoundSize( 118, 48 )
        :center_y( )
    local lbl_left_count = ibCreateLabel( img_weapon:ibGetAfterX( 8 ), 0, 0, 0, "В наличии: " .. item.count .. " шт.", area_givetoall, ibApplyAlpha( COLOR_WHITE, 60 ), 1, 1, "left", "center", ibFonts.regular_14 ) 

    function UpdateGivenItemCount( )
        for i, new_item in pairs( CLAN_DATA.storage ) do
            if item.type == new_item.type and item.id == new_item.id then
                item = new_item
                lbl_left_count:ibData( "text", "В наличии: " .. item.count .. " шт." )
                return true
            end
        end
        ShowGiveItemOverlay( false )
    end

    local bg_edit = ibCreateImage( 0, 0, 205, 38, "img/bg_input.png", footer_bg )
        :ibData( "alpha", 255 * 0.7 )
        :center( )
    local edit_count = ibCreateWebEdit( bg_edit:ibData( "px" ) + 5, bg_edit:ibData( "py" ), bg_edit:width( ) - 10, 35, "", footer_bg, COLOR_WHITE )
        :ibBatchData( {
            font = "regular_12",
            max_length = 4,
            placeholder = "Введите количество",
            placeholder_color = ibApplyAlpha( COLOR_WHITE, 50 ),
            bg_color = 0,
        } )
        :ibOnFocusChange( function( focused )
            bg_edit:ibAlphaTo( focused and 255 or 255 * 0.7, 100 )
        end )
    
    area_givetoall:ibData( "px", bg_edit:ibData( "px" ) - 15 - lbl_left_count:ibGetAfterX( ) )

    local btn_givetoall = ibCreateButton( bg_edit:ibGetAfterX( 15 ), 0, 164, 38, footer_bg, 
            "img/btn_givetoall.png", "img/btn_givetoall_hover.png", "img/btn_givetoall_hover.png", _, _, 0xFFAAAAAA )
        :center_y( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            
            local count = tonumber( edit_count:ibData( "text" ) )
            if not count or count <= 0 then
                localPlayer:ShowError( "Введите количество!" )
                return
            end

            if item.count < count then
                localPlayer:ShowError( "В наличии только " .. item.count .. " шт." )
                return
            end

            local near_clan_players = { }

            for i, member in pairs( localPlayer:GetClanTeam( ).players ) do
                if member.dimension == localPlayer.dimension then
                    table.insert( near_clan_players, member )
                end
            end

            triggerServerEvent( "onPlayerWantGiveItemFromClanStorage", localPlayer, item, count, near_clan_players )
        end )



    local btn_hide = ibCreateButton( 0, bg_overlay:height( ) - 30 - 42, 108, 42, bg_overlay, 
            "img/btn_hide.png", "img/btn_hide_hover.png", "img/btn_hide_hover.png", _, _, 0xFFAAAAAA )
        :center_x( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowGiveItemOverlay( false )
        end )
end

function HideClanStorageUI( )
    ShowClanStorageUI( false )
end
addEvent( "HideAllClanUI", true )
addEventHandler( "HideAllClanUI", root, HideClanStorageUI )

UPDATE_UI_HANDLERS = {
    storage = function( )
        UpdateStorageItemsPane( )
        UpdateGivenItemCount( )
    end,
    clan_role = function( )
        ShowClanStorageUI( true, CLAN_DATA )
    end,
}

addEvent( "onClientUpdateClanUI", true )
addEventHandler( "onClientUpdateClanUI", root, function( data )
    if not isElement( UI.bg ) then return end

    local old_data = table.copy( CLAN_DATA )
    for k, v in pairs( data ) do
        CLAN_DATA[ k ] = data[ k ]
    end
    for k, v in pairs( data ) do
        if UPDATE_UI_HANDLERS[ k ] then
            UPDATE_UI_HANDLERS[ k ]( old_data )
        end
    end
end )