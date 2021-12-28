Extend( "ib" )
Extend( "ib/tabPanel" )
Extend( "rewards/Client" )
ibUseRealFonts( true )

UI = { }

TABS = {
    {
        name = "Награды",
        key  = "rewards",
    },
    {
        name = "Задачи",
        key  = "tasks",
    },
    {
        name = "Усиления",
        key  = "boosters",
    },
}

TABS_CONF = { }
DATA = { }

local _showCursor = showCursor
local active_bgs = { }
function showCursor( state, ui_bg )
    if state and ui_bg then
        active_bgs[ ui_bg ] = true
        ui_bg:ibOnDestroy( function( )
            active_bgs[ ui_bg ] = nil
        end )
    end
    setTimer( function( )
        _showCursor( state or next( active_bgs ) and true or false )
    end, 0, 1 )
end

function ShowBattlePassUI( state, data )
    if state then
        ShowBattlePassUI( false )
        ibInterfaceSound()

        DATA = data
        UI = { }

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowBattlePassUI, true, true )
            :ibData( "alpha", 0 ):ibAlphaTo( 255, 400 )
        UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", UI.black_bg ):center( )

        showCursor( true, UI.black_bg )

        -------------------------------------------------------------------
        -- Header 

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 92, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
        
        UI.img_logo = ibCreateImage( 30, 0, 0, 0, "img/logo.png", UI.head_bg ):ibSetRealSize( ):center_y( )
        UI.lbl_head = ibCreateLabel( 100, 0, 0, 0, "Сезонные награды", UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 ):center_y( )
        
        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowBattlePassUI( false )
            end )

        UI.booster_area = ibCreateArea( 784, 0, 0, 0, UI.head_bg )
        ibCreateImage( 0, 29, 37, 37, "img/icon_booster.png", UI.booster_area )
        UI.booster_text_lbl = ibCreateLabel( 47, 38, 0, 0, "Время усиления:", UI.booster_area, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "left", "center", ibFonts.regular_14 )
        
        local function UpdateBoosterInfo( )
            if isElement( UI.booster_ui_element ) then UI.booster_ui_element:destroy( ) end
            if DATA.booster_end_ts and DATA.booster_end_ts > getRealTimestamp( ) then
                UI.booster_ui_element = ibCreateLabel( 47, 55, 0, 0, getHumanTimeString( DATA.booster_end_ts ), UI.booster_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                    :ibTimer( function( self )
                        if DATA.booster_end_ts > getRealTimestamp( ) then
                            self:ibData( "text", getHumanTimeString( DATA.booster_end_ts ) )
                        else
                            UpdateBoosterInfo( )
                        end
                    end, 1000, 0 )
            else
                UI.booster_ui_element = ibCreateImage( 47, 51, 54, 12, "img/btn_buy_booster.png", UI.booster_area )
                    :ibData( "alpha", 150 )
                ibCreateArea( -4, -4, 54 + 8, 12 + 8, UI.booster_ui_element )
                    :ibOnHover( function( ) UI.booster_ui_element:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) UI.booster_ui_element:ibAlphaTo( 150, 200 ) end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick( )
                        UI.tab_panel:SwitchTab( "boosters" )
                    end )
            end
        end
        UpdateBoosterInfo( )
        AddUpdateEventHandler( "booster_end_ts", "booster_info", UpdateBoosterInfo )

        UI.season_timer_area = ibCreateArea( 0, 37, 0, 0, UI.head_bg )
        ibCreateImage( 0, 0, 16, 18, "img/icon_timer.png", UI.season_timer_area )
        UI.season_timer_text_lbl = ibCreateLabel( 26, 0, 0, 18, "До окончания сезона:", UI.season_timer_area, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_14 )
        UI.season_timer_lbl = ibCreateLabel( UI.season_timer_text_lbl:ibGetAfterX( 6 ), 0, 0, 17, "", UI.season_timer_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )
        local function UpdateSeasonTimer( )
            UI.season_timer_lbl:ibData( "text", ( getHumanTimeString( BP_CURRENT_SEASON_END_TS ) or "0 с" ):match( "%d+ ?[^%s]*" ) )
            UI.season_timer_area:ibData( "px", UI.booster_area:ibGetBeforeX( -20 - UI.season_timer_lbl:ibGetAfterX( ) ) )
        end
        UpdateSeasonTimer( )
        UI.season_timer_lbl:ibTimer( UpdateSeasonTimer, 1000, 0 )

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
addEvent( "BP:ShowUI", true )
addEventHandler( "BP:ShowUI", resourceRoot, ShowBattlePassUI )

function CreateLevelProgressBar( tab_name, sx, parent )
    sx = sx - 20 - 160
    local bg_level = ibCreateImage( 30, 10, 106, 40, "img/bg_level.png", parent )
    local lbl_level = ibCreateLabel( 20, 20, 0, 0, DATA.level or 0, bg_level, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 )

    local need_exp = BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) + 1 ] or BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) ]
    local current_exp = BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) + 1 ] and ( DATA.exp or 0 ) or need_exp
    local bg_progressbar_level = ibCreateImage( 46, 27, sx, 12, _, bg_level, ibApplyAlpha( COLOR_WHITE, 10 ) )
    local progressbar_level = ibCreateImage( 46, 27, sx * current_exp / need_exp, 12, _, bg_level, 0xFF6cb5ff )

    local exp_text = current_exp ..  " / " .. need_exp
    local lbl_exp = ibCreateLabel( 46 + sx, 12, 0, 0, exp_text, bg_level, COLOR_WHITE, 1, 1, "right", "center", ibFonts.regular_14 )
    local icon_exp = ibCreateImage( lbl_exp:ibGetBeforeX( -16 -6 ), 4, 16, 16, "img/icon_exp.png", bg_level )

    local btn_buy_level = ibCreateButton( sx + 20, -20, 160, 32, bg_progressbar_level, 
            "img/btn_buy_level.png", "img/btn_buy_level_h.png", "img/btn_buy_level_h.png", 
            0xFFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
        :ibData( "color_disabled", 0x80FFFFFF )
        :ibData( "disabled", not BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) + 1 ] )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            ConfirmLevelPurchase()
        end )  

    AddUpdateEventHandler( "exp", "level_progressbar_" .. tab_name, function( old_data )
        local need_exp = BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) + 1 ] or BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) ]
        local current_exp = BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) + 1 ] and ( DATA.exp or 0 ) or need_exp
        local progress = need_exp and current_exp / need_exp or 1

        lbl_level:ibData( "text", DATA.level or 0 )
        lbl_exp:ibData( "text", current_exp ..  " / " .. need_exp )
        icon_exp:ibData( "px", lbl_exp:ibGetBeforeX( -16 -6 ) )

        if old_data.level < ( DATA.level or 0 ) then
            progressbar_level
                :ibResizeTo( sx, _, 200 )
                :ibTimer( progressbar_level.ibResizeTo, 250, 1, 0, _ )
                :ibTimer( progressbar_level.ibResizeTo, 500, 1, sx * progress, _ )
        else
            progressbar_level:ibResizeTo( sx * progress, 12 )
        end

        if not BP_LEVELS_NEED_EXP[ ( DATA.level or 0 ) + 1 ] then
            btn_buy_level:ibData( "disabled", true )
        end
    end )
end

function ConfirmLevelPurchase( level )
    level = level or ( DATA.level or 0 ) + 1
    ibConfirm( {
        title = "ПОДТВЕРЖДЕНИЕ", 
        text = "Ты хочешь приобрести повышение до " .. level .. " уровня за",
        cost = GetBattlePassLevelCost( level, DATA.level or 0 ),
        cost_is_soft = false,
        fn = function( self ) 
            self:destroy()
            triggerServerEvent( "BP:onPlayerWantBuyLevel", resourceRoot, level )
        end,
        escape_close = true,
    } )
end

function AddUpdateEventHandler( data_key, unique_key, fn_handler )
    if not UI.update_handlers then
        UI.update_handlers = { }
    end
    if not UI.update_handlers[ data_key ] then
        UI.update_handlers[ data_key ] = { }
    end
    UI.update_handlers[ data_key ][ unique_key ] = fn_handler
end

function UpdateUI( data )
    if not isElement( UI.bg ) or not UI.update_handlers then return end
    
    local old_data = table.copy( DATA )
    for k, v in pairs( data ) do
        DATA[ k ] = data[ k ]
    end
    
    for k, v in pairs( data ) do
        if UI.update_handlers[ k ] then
            for unique_key, fn_handler in pairs( UI.update_handlers[ k ] ) do
                fn_handler( old_data )
            end
        end
    end
end
addEvent( "BP:UpdateUI", true )
addEventHandler( "BP:UpdateUI", resourceRoot, UpdateUI )

addEvent( "BP:onClientRewardTake", true )
addEventHandler( "BP:onClientRewardTake", resourceRoot, function( level, is_premium )
    if not isElement( UI.bg ) then return end

    local type = is_premium and "premium" or "free"
    local rewards = table.copy( DATA.rewards or { } )
    if not rewards[ type ] then rewards[ type ] = { } end
    rewards[ type ][ level ] = true
    
    UpdateUI( { rewards = rewards } )
end, false, "high" )