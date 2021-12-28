loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ShClans" )
Extend( "ShBounty" )
Extend( "ib" )
Extend( "ib/tabPanel" )

ibUseRealFonts( true )

UI = { }
CLAN_DATA = { }

TABS = {
    {
        name = "Состав",
        key  = "members",
    },
    {
        name = "Магазин",
        key  = "shop",
    },
    {
        name = "Развитие",
        key  = "upgrades",
    },
    {
        name = "Редактирование",
        key  = "edit",
        fn_check = function( ) 
            return localPlayer:GetClanRole( ) == CLAN_ROLE_LEADER
        end,
    },
    {
        name = "Журнал",
        key  = "logs",
    },
    {
        name = "Охота",
        key  = "hunting",
    },
}

TABS_CONF = { }

function ShowClanManageUI( state, data )
    if state then
        DestroyClanManageUI( )
        ibInterfaceSound()
        showCursor( true )

        CLAN_DATA = data

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowClanManageUI, true, true )
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
                ShowClanManageUI( false )
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
        if isTimer( UI.destroy_timer ) then return end
        UI.destroy_timer = setTimer( DestroyClanManageUI, 0, 1 )
    end
end
addEvent( "ShowClanManageUI", true )
addEventHandler( "ShowClanManageUI", root, ShowClanManageUI )

function DestroyClanManageUI( )
    DestroyTableElements( UI )
    UI = { }
    showCursor( false )
end
addEvent( "HideAllClanUI", true )
addEventHandler( "HideAllClanUI", root, DestroyClanManageUI )

UPDATE_UI_HANDLERS = {
    clan_role = function( )
        ShowClanManageUI( true, CLAN_DATA )
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