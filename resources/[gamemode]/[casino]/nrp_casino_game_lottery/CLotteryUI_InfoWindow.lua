Extend( "ib/tabPanel" )

TABS = {
    {
        name = "Лучшие награды",
        key  = "best_rewards",
    },
    {
        name = "Топ игроков",
        key  = "players_top",
    },
}

TABS_CONF = { }

function ShowLotteryInfoUI( state, selected_tab )
    if state then
        ShowLotteryInfoUI( false )
        ibInterfaceSound()

        UI.info = { }

        UI.info.black_bg = ibCreateBackground( 0xBF1D252E, ShowLotteryInfoUI, true, true )
        UI.info.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.info.black_bg, ibApplyAlpha( 0xFF475d75, 95 ) ):center( )

        -------------------------------------------------------------------
        -- Header 

        UI.info.head_bg  = ibCreateImage( 0, 0, UI.info.bg:ibData( "sx" ), 92, _, UI.info.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
        
        UI.info.img_logo = ibCreateImage( 30, 0, 63, 39, "img/logo.png", UI.info.head_bg ):center_y( )
        UI.info.lbl_head = ibCreateLabel( 113, 0, 0, 0, "Лотерея “" .. SELECTED_LOTTERY_INFO.name .. "”", UI.info.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 ):center_y( )
        
        UI.info.btn_close = ibCreateButton( UI.info.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.info.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowLotteryInfoUI( false )
            end )

        ibCreateLine( 0, UI.info.head_bg:height( ) - 1, UI.info.head_bg:ibData( "sx" ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, UI.info.head_bg )

        -------------------------------------------------------------------
        
        UI.info.tab_panel = ibCreateTabPanel( {
            px = 0,
            py = UI.info.head_bg:ibGetAfterY( ),
            sx = UI.info.bg:ibData( "sx" ),
            sy = UI.info.bg:ibData( "sy" ) - UI.info.head_bg:ibGetAfterY( ),
            parent = UI.info.bg,
            tabs = TABS,
            tabs_conf = TABS_CONF,
            current = selected_tab or 1,
            precreate_all_tabs_content = true,
            create_tab_area_under_navbar = true,
            navbar_conf = {
                sy = 50,
                font = ibFonts.bold_16,
            },
        } )
    else
        DestroyTableElements( UI.info )
        UI.info = { }
    end
end

TABS_CONF.best_rewards = {
    fn_create = function( self, parent )
        local rewards = SELECTED_LOTTERY_INFO.variants[ 1 ].items

        ibCreateImage( 30, 20, 965, 537 , "img/bg_best_rewards.png", parent )
        
        local params = rewards[ 1 ].params
        ibCreateContentImage( 363, 49, 300, 160, "vehicle", params.model .. ( params.color and "_" .. params.color or "" ), parent )

        local rare_rewards = {}
        local soft_rewards = { }
        for i = 2, #rewards do
            local reward = rewards[ i ]
            if reward.type == "soft" then
                table.insert( soft_rewards, reward.params.count )
            elseif reward.type ~= "premium" and reward.type ~= "box" then
                table.insert( rare_rewards, reward )
            end
        end
        
        for i, px in pairs( { 30, 358, 686 } ) do
            local reward = rare_rewards[ i ]
            -- local py = reward.id == "skin" and 176 or 235
            -- ibCreateContentImage( px + 5, py, 300, 280, reward.id, reward.params.id or reward.params.model, parent )
            local area_item = ibCreateArea( px - 8, 176 + 24, 300, 160, parent )
            local item_class = REGISTERED_ITEMS[ reward.type ]
            local item_info = item_class.uiGetDescriptionData_func( reward.type, reward.params )
            item_class.uiCreateScratchItem_func( reward.type, reward.params, area_item )
            ibCreateLabel( px + 154, 404, 0, 0, item_info.title, parent, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_14 )
        end

        for i, px in pairs( { 102, 266, 430, 594 } ) do
            ibCreateLabel( px, 539, 0, 0, format_price( soft_rewards[ 5 - i ] ), parent, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_14 )
        end
    end,
}

TABS_CONF.players_top = {
    fn_create = function( self, parent )
        local col_px = 0
        local row_sy = 53
        local bg_row
        local columns = {
            {
                title = "Место",
                sx = 110,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, k, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
                end,
            },
            {
                title = "Ник игрока",
                sx = 400,
                fn_create = function( self, k, v )
                    ibCreateLabel( col_px, 0, 0, row_sy, v[ LTP_PLAYER_NAME ], bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_18 )
                end,
            },
            {
                title = "Приз",
                sx = 300,
                fn_create = function( self, k, v )
                    local item_class = REGISTERED_ITEMS[ v[ LTP_REWARD_TYPE ] ]
                    if item_class.uiCreatePlayersTopItem_func then
                        local area_item = ibCreateArea( col_px, 0, 0, row_sy, bg_row )
                        item_class.uiCreatePlayersTopItem_func( v[ LTP_REWARD_TYPE ], v[ LTP_REWARD_PARAMS ], area_item )
                    else
                        local item_info = item_class.uiGetDescriptionData_func( v[ LTP_REWARD_TYPE ], v[ LTP_REWARD_PARAMS ] )
                        ibCreateLabel( col_px, 0, 0, row_sy, item_info.title, bg_row, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
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

        function UpdatePlayersTop( data )
            if isElement( scrollpane ) then
                scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
                scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            scrollpane, scrollbar = ibCreateScrollpane( 0, 40, 
                parent:ibData( "sx" ), parent:ibData( "sy" ) - 40, 
                parent, { scroll_px = -20 }
            )
            scrollbar:ibSetStyle( "slim_nobg" )
            
            for k, v in pairs( data or { } ) do
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
        
        UI.players_top_loading = ibLoading( { parent = parent } )
        
        triggerServerEvent( "onPlayerRequestLotteryPlayersTop", resourceRoot, SELECTED_LOTTERY_INFO.id )
    end,
}

addEvent( "onClientUpdateLotteryPlayersTop", true )
addEventHandler( "onClientUpdateLotteryPlayersTop", resourceRoot, function( data )
    TOP_PLAYERS = data
    if isElement( UI.players_top_loading ) then
        UI.players_top_loading:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        UpdatePlayersTop( data )
    end
end )