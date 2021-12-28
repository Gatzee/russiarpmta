TABS_CONF.rewards = {
    fn_create = function( self, parent )
        -- Забрать все призы
        ibCreateButton( parent:width( ) -30 - 173, -34, 173, 17, parent, "img/rewards/btn_take_all.png", _, _, 0x9FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                
                TakeNextAvaliableReward( )
            end )

        CreateLevelProgressBar( "rewards", 753, parent )

        local area = ibCreateArea( 30, 63, 0, 0, parent )

        -- Левая часть
        local function CreateLeftSide( )
            local animated = false
            if isElement( UI.bg_rewards_left_side ) then
                UI.bg_rewards_left_side:ibTimer( destroyElement, 200, 1 )
                animated = true
            end
            if DATA.is_premium_active then
                UI.bg_rewards_left_side = ibCreateImage( 0, 0, 150, 520, "img/rewards/bg_left_premium.png", area )
            else
                UI.bg_rewards_left_side = ibCreateImage( 0, 0, 150, 520, "img/rewards/bg_left.png", area )
                ibCreateLabel( 93, 435, 0, 0, GetBattlePassPremuimCost( ), UI.bg_rewards_left_side, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )
                
                local btn_buy_premium = ibCreateButton( 30, 456, 90, 30, UI.bg_rewards_left_side, 
                        "img/rewards/btn_buy.png", "img/rewards/btn_buy_h.png", "img/rewards/btn_buy_h.png", 
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick( )
                        
                        ShowOverlay( OVERLAY_PREMIUM_PURCHASE )
                    end )
            end
            ibCreateImage( 0, 0, 0, 0, "img/logo.png", UI.bg_rewards_left_side )
                :ibSetRealSize( ):center( 0, -20 )

            if animated then
                UI.bg_rewards_left_side
                    :ibData( "blend_mode", "modulate_add" )
                    :ibData( "blend_mode_after", "blend" )
                    :ibData( "alpha", 0 )
                    :ibAlphaTo( 255, 200 )
            end
        end
        CreateLeftSide( )
        AddUpdateEventHandler( "is_premium_active", "btn_buy_premium", CreateLeftSide )

        -- Награды
        local scrollpane, scrollbar = ibCreateScrollpane( 150, 0, 654, 520, area, { horizontal = true } )
        scrollbar:ibSetStyle( "slim_nobg" ):ibBatchData( { handle_px = 0, handle_lower_limit = 5, handle_upper_limit = -105 } )
    
        local col_sx = 150
        local col_sy = 500
        local gap = 5
        local pane_sx = gap

        local function CreateLevelPurchaseInfo( level, bg_purchase )
            local text = "Ты можешь приобрести повышение до этого уровня"
            local area = ibCreateArea( 0, 0, 0, 0, bg_purchase )
            ibCreateLabel( 15, 15, col_sx - 30, 0, text, area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.regular_14 )
                :ibData( "wordbreak", true )

            ibCreateLabel( 0, 128, col_sx, 0, "Стоимость:", area, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.regular_14 )
            local cost_area = ibCreateArea( 0, 150, 0, 0, area )
            local lbl_cost = ibCreateLabel( 0, 0, 0, 0, format_price( GetBattlePassLevelCost( level, DATA.level or 0 ) ), cost_area, _, _, _, _, "center", ibFonts.bold_20 )
            local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), -14, 28, 28, ":nrp_shared/img/hard_money_icon.png", cost_area ):ibData( "disabled", true )
            cost_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( col_sx / 2 )

            ibCreateButton( 30, 171, 90, 30, area, 
                    "img/rewards/btn_buy.png", "img/rewards/btn_buy_h.png", "img/rewards/btn_buy_h.png", 
                    0xFFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ibClick( )

                    ConfirmLevelPurchase( level )
                end )

            return area
        end

        local function CreateRewardItem( level, type, py, sy, bg_col, area_col )
            local reward = BP_LEVELS_REWARDS[ type ][ level ]
            if not reward then return end

            local area_item = ibCreateArea( 75, py + 110, 0, 0, bg_col )
            local info = reward.uiGetDescriptionData( reward.type, reward )
            ibCreateLabel( 15, py + 15, col_sx - 30, 0, info.title, bg_col, _, 1, 1, "center", "top", ibFonts.regular_14 )
                :ibData( "wordbreak", true )

            ibCreateRewardImage( 0, 0, reward.type == "case" and 130 or 100, 100, reward, area_item ):center()

            local btn_take
            local is_reward_already_taken = DATA.rewards and DATA.rewards[ type ] and DATA.rewards[ type ][ level ]
            local is_reward_unlocked = ( DATA.level or 0 ) >= level
            if is_reward_already_taken then
                ibCreateLabel( 0, py + 185, col_sx, 0, "Получено", bg_col, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.regular_16 )
            else
                btn_take = ibCreateButton( 25, py + 171, 100, 30, bg_col, 
                        "img/rewards/btn_take.png", "img/rewards/btn_take_h.png", "img/rewards/btn_take_h.png", 
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                    :ibData( "disabled", not is_reward_unlocked )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick( )

                        if ( type == "premium" and not DATA.is_premium_active ) then
                            ShowPremiumOffer( false, true )
                            return
                        end
                        
                        if reward.TakeReward_client then
                            reward:TakeReward_client( level, type )
                        else
                            ShowReward( level, type )
                        end
                    end )
            end

            local bg_purchase, area_purchase
            if not is_reward_unlocked then
                bg_purchase = ibCreateImage( 0, py, col_sx, sy, _, area_col, ibApplyAlpha( 0xFF1f2934, 90 ) )
                    :ibData( "alpha", 1 )
                    :ibOnHover( function()
                        repeat
                            if source == this then
                                area_purchase = area_purchase or CreateLevelPurchaseInfo( level, bg_purchase )
                                bg_purchase:ibAlphaTo( 255 )
                                return
                            end
                            source = source.parent
                        until not source
                    end, true )
                    :ibOnLeave( function()
                        bg_purchase:ibAlphaTo( 1 )
                    end, true )
            end
            
            AddUpdateEventHandler( "level", "reward_" .. type .. level, function( )
                if is_reward_already_taken or is_reward_unlocked then return end
                if DATA.level >= level then
                    bg_col:ibAlphaTo( 255 )
                    btn_take:ibData( "disabled", false )
                    bg_purchase:destroy()
                    is_reward_unlocked = true
                elseif area_purchase then
                    area_purchase:destroy()
                    area_purchase = nil
                end
            end )

            AddUpdateEventHandler( "rewards", "reward_take" .. type .. level, function( )
                if is_reward_already_taken then return end
                local is_reward_taken = DATA.rewards and DATA.rewards[ type ] and DATA.rewards[ type ][ level ]
                if is_reward_taken then
                    is_reward_already_taken = true
                    btn_take:destroy( )
                    ibCreateLabel( 0, py + 185, col_sx, 0, "Получено", bg_col, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.regular_16 )
                end
            end )
        end
        
        local levels_count = #BP_LEVELS_NEED_EXP
        for level = 1, levels_count do
            local area_col = ibCreateArea( pane_sx, 0, col_sx, col_sy, scrollpane )

            local bg_col = ibCreateImage( 0, 0, col_sx, col_sy, "img/rewards/bg_item.png", area_col )
                :ibData( "alpha", ( DATA.level or 0 ) >= level and 255 or 128 )

            CreateRewardItem( level, "free", 0, 220, bg_col, area_col )

            ibCreateLabel( 0, 241, col_sx, 0, "Уровень " .. level, bg_col, _, 1, 1, "center", "center", ibFonts.bold_14 )

            CreateRewardItem( level, "premium", 260, 240, bg_col, area_col )

            pane_sx = pane_sx + col_sx + gap
        end
        
        scrollpane:ibData( "sx", pane_sx )
        -- scrollpane:AdaptHeightToContents( )
        -- scrollbar:UpdateScrollbarVisibility( scrollpane )

        local left_gradient = ibCreateImage( 150 + 27, 0, -27, col_sy, "img/rewards/gradient.png", area )
            :ibData( "blend_mode", "modulate_add" )
            :ibData( "blend_mode_after", "blend" )
        local right_gradient = ibCreateImage( 804 - 27, 0, 27, col_sy, "img/rewards/gradient.png", area )
            :ibData( "blend_mode", "modulate_add" )
            :ibData( "blend_mode_after", "blend" )

        local threshold = ( col_sx * 1 ) / pane_sx
        scrollbar:ibOnRender( function( )
            left_gradient:ibData( "alpha", ( 1 - ( 1 - ( 1 / threshold ) * math.min( threshold, scrollbar:ibData( "position" ) ) ) ^ 10 ) * 255  )
            right_gradient:ibData( "alpha", ( 1 - ( 1 - ( 1 / threshold ) * math.min( threshold, 1 - scrollbar:ibData( "position" ) ) ) ^ 10 ) * 255  )
        end )
        
        -- Правая часть (награда за пороговый уровень)
        local bg_right = ibCreateImage( 834, 23, 160, 560, "img/rewards/bg_right.png", parent )

        local current_threshold_level = BP_THRESHOLD_LEVELS[ 1 ]
        local lbl_threshold_level = ibCreateLabel( 82, 30, 0, 0, current_threshold_level, bg_right, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_26 )
        
        local function CreateThresholdLevelReward( level, type, py, bg )
            local reward = BP_LEVELS_REWARDS[ type ][ level ]
            if not reward then return end

            local area_reward = ibCreateArea( bg_right:width( )* 0.5, 0, 0, 0, bg )
            local info = reward.uiGetDescriptionData( reward.type, reward )
            local sx = bg_right:width( ) - 20
            local text_sx, text_sy, text = dxGetTextSize( info.title, sx, 1, ibFonts.regular_14, true )
            ibCreateLabel( 0, 0, 0, 0, text, area_reward, _, 1, 1, "center", "top", ibFonts.regular_14 )
            
            local area_item, img_item = ibCreateRewardImage( 0, 0, reward.type == "case" and 130 or 100, 100, reward, area_reward )
            area_item:center_x()
            img_sy = img_sy or img_item:height( )
            area_item:ibData( "py", text_sy + 5 )
            area_reward:ibData( "py", py - ( text_sy + 5 + img_sy ) * 0.5 )
        end

        local area_threshold_level_rewards
        local function UpdateThresholdLevelRewards( )
            if isElement( area_threshold_level_rewards ) then
                area_threshold_level_rewards:destroy( )
            end
            area_threshold_level_rewards = ibCreateArea( 0, 0, 0, 0, bg_right )
            CreateThresholdLevelReward( current_threshold_level, "free", 170, area_threshold_level_rewards )
            CreateThresholdLevelReward( current_threshold_level, "premium", 420, area_threshold_level_rewards )
        end
        UpdateThresholdLevelRewards( )

        scrollbar:ibOnRender( function( )
            local position = scrollbar:ibData( "position" )
            local viewport_sx = scrollpane:ibData( "viewport_sx" )
            local last_visible_level = math.ceil( ( ( pane_sx - viewport_sx ) * position + viewport_sx - col_sx * 0.5 ) / ( col_sx + gap ) )
            local new_threshold_level = BP_THRESHOLD_LEVELS[ #BP_THRESHOLD_LEVELS ]
            for i, threshold_level in pairs( BP_THRESHOLD_LEVELS ) do
                if threshold_level > last_visible_level and BP_LEVELS_NEED_EXP[ threshold_level ] then
                    new_threshold_level = threshold_level
                    break
                end
            end
            if current_threshold_level ~= new_threshold_level then
                current_threshold_level = new_threshold_level
                lbl_threshold_level:ibData( "text", current_threshold_level )
                UpdateThresholdLevelRewards( )
            end
        end )
    end,
}

function ShowReward( level, type )
    local item = BP_LEVELS_REWARDS[ type ][ level ]
    ShowTakeReward( UI.black_bg, item, function( args )
        triggerServerEvent( "BP:onPlayerWantTakeReward", resourceRoot, level, type == "premium", args )
    end )
end

addEventHandler( "BP:onClientRewardTake", resourceRoot, function( level, is_premium )
    if not IS_TAKING_ALL_REWARDS then
        local item = BP_LEVELS_REWARDS[ is_premium and "premium" or "free" ][ level ]
        if item.type == "case" and item.id:find( "bp_season" ) then
            triggerEvent( "onClientSeasonCasesInfo", localPlayer )
        end
    end
end, true, "low-2" )