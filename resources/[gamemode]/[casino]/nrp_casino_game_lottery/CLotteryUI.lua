Extend( "ib" )
ibUseRealFonts( true )

UI = { }
DATA = { }

local CLIENT_CONST_CHECK_TIME_REVEALED_AREA_IN_MS = 500

local LOTTERY_ITEMS_INFO = {
    { lottery_variant = 5 },
    { lottery_variant = 4 },
    { lottery_variant = 3 },
    { lottery_variant = 2 },
    { lottery_variant = 1, text = "Стандартные шансы" },
}

-- Длительность + задержки анимаций (херня, ну ок)
UI_ANIMS = {
    select = {
        hide_old = 300,
        hide_old_random = 200,
        
        move_new_delay = 200,
        move_new = 300,
    }
}
UI_ANIMS.select.total = UI_ANIMS.select.hide_old + UI_ANIMS.select.hide_old_random

function ShowLotteryMainUI( state, data )
    if state then
        DATA = data

		ShowLotteryMainUI( false )
        showCursor( true )
        
        UI.black_bg	= ibCreateBackground( _, CloseLotteryUI, true, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 400 )

        local sx, sy = 1600, 900
        local scale = math.max( _SCREEN_X / sx, _SCREEN_Y / sy )
        UI.bg = ibCreateImage( 0, 0, sx * scale, sy * scale, "img/bg.png", UI.black_bg ):center( )

        UI.area = ibCreateArea( 0, 0, 1024, 768, UI.bg ):center( )

        UI.header = ibCreateArea( 0, 13, 1024, 173, UI.area )
        
        UI.main_header = ibCreateArea( 0, 0, 1024, 173, UI.header )
        
        ibCreateImage( 0, UI.area:ibData( "py" ) + 13, 73, 46, "img/logo.png", UI.black_bg ):center_x( )
            :ibData( "priority", 1 )
        UI.lbl_title = ibCreateLabel( 0, UI.area:ibData( "py" ) + 59, 0, 0, "Лотерея “Три топора”", UI.black_bg, _, _, _, "center", _, ibFonts.regular_25 )
            :center_x( )
            :ibData( "priority", 1 )
        
        ibCreateImage( 0, 83, 1002, 48, "img/bg_label.png", UI.main_header ):center_x( )
        ibCreateLabel( 0, 93, 0, 0, "Испытай свою удачу", UI.main_header, _, _, _, "center", _, ibFonts.regular_20 ):center_x( )
        
        UI.lbl_balance_text = ibCreateLabel( 1, 32, 0, 0, "баланс", UI.header, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, _, _, ibFonts.regular_12 )
        UI.lbl_balance = ibCreateLabel( 0, 15, 0, 0, format_price( localPlayer:GetMoney( ) ), UI.lbl_balance_text, _, _, _, _, _, ibFonts.bold_21 )
        UI.img_balance = ibCreateImage( UI.lbl_balance:ibGetAfterX( 8 ), 0, 28, 28, ":nrp_shared/img/money_icon.png", UI.lbl_balance )
        UI.lbl_balance:ibTimer( function( )
            UI.lbl_balance:ibData( "text", format_price( localPlayer:GetMoney( ) ) )
            UI.img_balance:ibData( "px", UI.lbl_balance:ibGetAfterX( 8 ) )
            UI.btn_players_top:ibData( "px", UI.img_balance:ibGetAfterX( 30 ) )
        end, 1000, 0 )

        UI.btn_players_top = ibCreateButton( UI.img_balance:ibGetAfterX( 30 ), 51, 120, 22, UI.header, "img/btn_players_top.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowLotteryInfoUI( true, 2 )
            end )
        
        ibCreateLine( -15, -4, _, -4 + 33, ibApplyAlpha( COLOR_WHITE, 10 ), _, UI.btn_players_top )

        UI.btn_exit = ibCreateButton( UI.header:ibData( "sx" ) - 78, 52, 78, 21, UI.header, "img/btn_exit.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                CloseLotteryUI( false )
            end )

        UI.btn_rewards_list = ibCreateButton( UI.btn_exit:ibGetBeforeX( -30 - 135 ), 51, 135, 22, UI.header, "img/btn_rewards_list.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowLotteryInfoUI( true, 1 )
            end )
        
        ibCreateLine( UI.btn_rewards_list:width( ) + 15, -5, _, -5 + 33, ibApplyAlpha( COLOR_WHITE, 10 ), _, UI.btn_rewards_list )

        ShowLotteryTypeSelectUI( )

        if DATA.old_reward then
            ShowLotteryReward( DATA.old_reward )
        end
    else
        DestroyTableElements( UI )
        showCursor( false )
    end
end
addEvent( "ShowLotteryMainUI", true )
addEventHandler( "ShowLotteryMainUI", resourceRoot, ShowLotteryMainUI )

function CloseLotteryUI( )
    if not isElement( UI.black_bg ) then return end
    
    ShowLotteryMainUI( false )
    triggerServerEvent( "onPlayerLotteryPlayStop", resourceRoot )
end
        
function ShowLotteryTypeSelectUI( is_return )
    if isElement( UI.body ) then
        if isElement( UI.black_bg_next_action ) then destroyElement( UI.black_bg_next_action ) end
        UI.body:ibTimer( ibAlphaTo, UI_ANIMS.select.total, 1, 0, 200 ):ibTimer( destroyElement, UI_ANIMS.select.total + 200, 1 )
    end

    UI.lbl_title:ibData( "text", "Лотерея “Три топора”" )
    UI.btn_players_top:ibData( "disabled", true ):ibAlphaTo( 0 )
    UI.btn_rewards_list:ibData( "disabled", true ):ibAlphaTo( 0 )

    UI.body = ibCreateArea( 0, UI.header:ibData( "py" ) + 152, 1024, 0, UI.area ):ibData( "priority", 1 )
    
    UI.main_header:ibData( "alpha", 255 )
    if is_return then UI.bg_rewards:ibData( "alpha", 0 ) end

    local items_list = { }
    local target_lottery = { "classic", "gold" }

    local ignore_lottery = { classic = true, gold = true }
    for id, tickets in pairs( DATA.purchased_tickets ) do
        if not ignore_lottery[ id ] then
            for _, count_tickets in pairs( tickets ) do
                if count_tickets > 0 then
                    table.insert( target_lottery, 2, id )
                    break
                end
            end
        end
    end
    
    -- Если остались билеты с прошлой тематической лотереи
    if #target_lottery > 2 then
        for i, target_lottery_id in pairs( target_lottery ) do
            for lottery_id, lottery in pairs( LOTTERIES_INFO ) do
                if lottery_id == target_lottery_id then
                    table.insert( items_list, lottery )
                    break
                end
            end
        end
    else
        -- Иначе ищем текущую
        for i, lottery_type in pairs( { "classic", "theme", "donate", } ) do
            for lottery_id, lottery in pairs( LOTTERIES_INFO ) do
                if lottery.type == lottery_type and ( not lottery.IsActive or lottery:IsActive( ) ) then
                    table.insert( items_list, lottery )
                    break
                end
            end
        end
    end

    local area_sx, area_sy = 328, 410
    local gap = 20
    local img_sx, img_sy = 362, 452
    local img_opx, img_opy = 0, -3

    UI.lottery_areas = { }

    for i, lottery_info in ipairs( items_list ) do
        local item_info = items_list[ i ]

        local area_item = ibCreateArea( ( i - 1 ) * ( area_sx + gap ), 0, area_sx, area_sy, UI.body )
        UI.lottery_areas[ lottery_info.id ] = area_item

        if is_return then
            area_item
                :ibData( "py", _SCREEN_Y )
                :ibTimer( function( self )
                    self:ibMoveTo( _, 0, UI_ANIMS.select.hide_old + math.random( UI_ANIMS.select.hide_old ) )
                end, UI_ANIMS.select.move_new_delay, 1 )
        end

        -- Тень при ховере
        local bg_item_hover = ibCreateImage( -172, -164, 706, 788, "img/lottery/bg_hover.png", area_item )
            :center( )
            :ibBatchData( { disabled = true, alpha = 0 } )

        -- Усиление свечения при ховере
        ibCreateImage( 172, 165, img_sx, img_sy, "img/lottery/types/" .. lottery_info.id .. "/main.png", bg_item_hover )
            :ibData( "disabled", true )

        local bg_item = ibCreateImage(  img_opx + ( area_sx - img_sx ) * 0.5, img_opy + ( area_sy - img_sy ) * 0.5,  img_sx, img_sy, "img/lottery/types/" .. lottery_info.id .. "/main.png", area_item )
            :ibData( "disabled", true )

        area_item
            :ibOnHover( function( ) area_item:ibData( "priority", 1 ); bg_item_hover:ibAlphaTo( 255, 300 ) end )
            :ibOnLeave( function( ) area_item:ibData( "priority", 0 ); bg_item_hover:ibAlphaTo( 0, 300 ) end )
        
        local area_info = ibCreateArea( 0, 0, area_sx, area_sy, area_item ):ibData( "disabled", true )
            :ibData( "alpha", 0 ):ibTimer( ibAlphaTo, UI_ANIMS.select.total, 1, 255 )
        
        if lottery_info.finish_ts then
            local ts = getRealTimestamp()
            if not lottery_info:IsActive() then
                ibCreateLabel( 0, 90, area_sx, 0, "Открой билеты\nпрошлого сезона!", area_info, _, _, _, "center", "center", ibFonts.bold_18 )
            else
                ibCreateLabel( 0, 57, area_sx, 0, "Спешите принять участие!", area_info, _, _, _, "center", "center", ibFonts.bold_18 )
                ibCreateImage( 37, 70, 30, 32, ":nrp_shared/img/icon_timer.png", area_info, ibApplyAlpha( COLOR_WHITE, 75 ) ):ibData( "disabled", true )
                ibCreateLabel( 70, 84, 0, 0, "До конца розыгрыша осталось:", area_info, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
                ibCreateLabel( 0, 107, area_sx, 0, getHumanTimeString( lottery_info.finish_ts ) or "0 с", area_info, 0xFFcccccc, _, _, "center", "center", ibFonts.bold_18 )
                    :ibData( "outline", 1 )
                    :ibTimer( function( self )
                        self:ibData( "text", getHumanTimeString( lottery_info.finish_ts ) or "0 с" )
                    end, 1000, 0 )
            end
        end
        
        ibCreateButton( 77, 337, 174, 66, area_info, "img/btn_play_h.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
            :ibOnHover( function( ) area_item:ibData( "priority", 1 ); bg_item_hover:ibAlphaTo( 255, 300 ) end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                if ( LAST_CLICK_TICK or 0 ) + 500 > getTickCount( ) then return end
                LAST_CLICK_TICK = getTickCount( )
                ibClick( )

                UI.body:ibDeepSet( "disabled", true )
                for i, other_lottery_info in ipairs( items_list ) do
                    UI.lottery_areas[ other_lottery_info.id ]:ibMoveTo( _, _SCREEN_Y, UI_ANIMS.select.hide_old + math.random( UI_ANIMS.select.hide_old_random ), "OutQuad" )
                end
                area_item:ibMoveTo( _, _SCREEN_Y, UI_ANIMS.select.hide_old + UI_ANIMS.select.hide_old_random, "InQuad" )

                SELECTED_LOTTERY_INFO = lottery_info
                ShowLotteryPurchaseUI( lottery_info, area_item:ibData( "px" ) )
            end )
    end

    -- Последние победители
    function UpdateLastWinners( init )
        if isElement( UI.bg_last_winners ) then
            UI.bg_last_winners:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        end

        UI.bg_last_winners = ibCreateImage( 0, 420, 1045, 149, "img/bg_last_winners.png", UI.body )
            :center_x( )
            :ibData( "priority", -1 )

        if init then
            UI.bg_last_winners:ibData( "alpha", 0 ):ibTimer( ibAlphaTo, UI_ANIMS.select.total, 1, 255 )
        end
        
        local ox = 10
        local center_px = { 167, 514, 865 }
        local start_py = 43
        
        for i, lottery_info in ipairs( items_list ) do
            local rewards = lottery_info.variants[ 1 ].items
            local px = center_px[ i ]
            for winner_i, winner in ipairs( DATA.last_winners[ lottery_info.id ] or { } ) do
                local py = start_py + 30 * ( winner_i - 1 )
                ibCreateLabel( px - ox, py, 0, 0, winner.name, UI.bg_last_winners, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "right", "center", ibFonts.regular_12 )
                
                local reward = rewards[ winner.reward_id ]
                local reward_info = REGISTERED_ITEMS[ reward.type ].uiGetDescriptionData_func( reward.type, reward.params )
                ibCreateLabel( px + ox + 1, py, 0, 0, reward_info.title, UI.bg_last_winners, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_12 )
            end
        end
    end
    UpdateLastWinners( true )
end

addEvent( "onClientUpdateLotteryLastWinners", true )
addEventHandler( "onClientUpdateLotteryLastWinners", resourceRoot, function( lottery_id, last_winners )
    DATA.last_winners[ lottery_id ] = last_winners
    if not isElement( UI.bg_last_winners ) then return end
    UpdateLastWinners( )
end )

function onClientUpdateLotteryData_handler( lottery_variant, points, purchased_tickets, received_awards, progression_reward, discount )
    DATA.points = points
    DATA.purchased_tickets = purchased_tickets
    
    if discount then DATA.discount = discount end

    local func_update = function()
        if UI.lottery_update_info[ lottery_variant ] then
            UI.lottery_update_info[ lottery_variant ]( true )
            UI.update_progress_points()
        end
        if UI.lottery_update_info_action then
            UI.lottery_update_info_action( true )
        end
    end

    if progression_reward then
        DATA.received_awards = received_awards
        ShowLotteryReward( progression_reward, true, func_update )
    else
        func_update()
    end
end
addEvent( "onClientUpdateLotteryData", true )
addEventHandler( "onClientUpdateLotteryData", resourceRoot, onClientUpdateLotteryData_handler )
        
function ShowLotteryPurchaseUI( lottery_info, anim_start_px )
    if isElement( UI.body ) then
        UI.body:ibTimer( ibAlphaTo, UI_ANIMS.select.total, 1, 0, 200 ):ibTimer( destroyElement, UI_ANIMS.select.total + 200, 1 )
    end

    UI.lbl_title:ibData( "text", "Лотерея “" .. lottery_info.name .. "”" )
    UI.btn_players_top:ibData( "disabled", false ):ibAlphaTo( 255, 300 )
    UI.btn_rewards_list:ibData( "disabled", false ):ibAlphaTo( 255, 300 )

    UI.body = ibCreateArea( 0, UI.header:ibData( "py" ) + 82, 1024, 0, UI.area )
    UI.main_header:ibData( "alpha", 0 )
    UI.bg_last_winners:ibData( "alpha", 0 )
    
    local params = SELECTED_LOTTERY_INFO.variants[ 1 ].items[ 1 ].params
    local is_has_premium = localPlayer:IsPremiumActive()

    UI.update_progress_points = function()
        if not isElement( UI.body ) then return end

        if isElement( UI.bg_rewards ) then destroyElement( UI.bg_rewards ) end
        UI.bg_rewards = ibCreateImage( 0, 0, 1013, 160, "img/bg_rewards.png", UI.body )
            :center_x( )
            :ibData( "priority", -1 )

        local points = DATA.points[ lottery_info.id ] or 0
        local cur_reward_id = GetLotteryRewardIdByPoints( points )
        local progress_bar_setting = { [ 0 ] = { px = 0, sx = 30 }, [ 1 ] = { px = 122, sx = 45 }, [ 2 ] = { px = 257, sx = 45 }, [ 3 ] = { px = 392, sx = 45 }, [ 4 ] = { px = 527, sx = 45 }, [ 5 ] = { px = 660, sx = 0 }, }
        
        local cur_v_index = points < CONST_PROGRESSION_POINTS[ 1 ] and 0 or cur_reward_id
        local next_v_index = points < CONST_PROGRESSION_POINTS[ 1 ] and 1 or math.min( #CONST_PROGRESSION_POINTS, cur_reward_id + 1 )

        local real_points_level = math.abs((CONST_PROGRESSION_POINTS[ cur_v_index ] or 0) - points)
        local points_level = math.max( 1, CONST_PROGRESSION_POINTS[ next_v_index ] - (CONST_PROGRESSION_POINTS[ cur_v_index ] or 0) )
        
        local progress = real_points_level /  points_level
        ibCreateImage( 51, 89, progress_bar_setting[ cur_v_index ].px + (progress_bar_setting[ cur_v_index ].sx * progress), 16, nil, UI.bg_rewards, 0xFF6CB5FF )
        
        local bg_pr_bar = ibCreateImage( -12, 54, 84, 84, "img/bg_pr_bar.png", UI.bg_rewards )
        ibCreateLabel( 0, 24, 84, 84, points, bg_pr_bar, nil, nil, nil, "center", "top", ibFonts.oxaniumbold_16 )

        local px = 65
        local cur_progression_rewards = GetLotteryProgressionRewards( lottery_info.id, localPlayer:IsPremiumActive() )
        for k, v in ipairs( CONST_PROGRESSION_POINTS ) do
            local index_img = k == 5 and 3 or k == 4 and 2 or 1
            local is_received_reward = DATA.received_awards[ lottery_info.id ] and (DATA.received_awards[ lottery_info.id ][ "Premium" ][ k ] or DATA.received_awards[ lottery_info.id ][ "Common" ][ k ])
            
            local block_reward = ibCreateImage( px, 36, 126, 126, "img/bg_block_pr_" .. index_img .. ".png", UI.bg_rewards )
            local reward = cur_progression_rewards[ k ]

            local item_class = REGISTERED_ITEMS[ reward.type ]
            local conent_img = item_class.uiCreateProgressionRewardItem_func( reward.type, reward.params, block_reward )
            
            local reward_info = REGISTERED_ITEMS[ reward.type ].uiGetDescriptionData_func( reward.type, reward.params )
            conent_img:ibAttachTooltip( reward_info.title .. (reward_info.description and "\n" .. reward_info.description or "") )

            if is_received_reward then
                conent_img:ibData( "alpha", 50 )
                ibCreateImage( 0, 0, 24, 20, "img/icon_arrow.png", block_reward ):center( 0, -9 )
                ibCreateLabel( 0, 69, 126, 0, "Получено", block_reward, nil, nil, nil, "center", "top", ibFonts.regular_12 )
            else
                ibCreateImage( 18, 0, 90, 35, "img/bg_block_pr_header.png", block_reward )
                    :ibAttachTooltip( "Наберите " .. CONST_PROGRESSION_POINTS[ k ] .. " очков для получения награды" )
                ibCreateLabel( 0, 0, 126, 35, v, block_reward, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_14 ):ibBatchData( { outline = 1, disabled = true } )
            end
            
            px = px + 135
        end

        ibCreateContentImage( 785, 35, 300, 160, "vehicle", params.model .. ( params.color and "_" .. params.color or "" ), UI.bg_rewards )
            :ibBatchData( { sx = 220, sy = 120 } )
    end
    UI.update_progress_points()

    ibCreateButton( 0, -85, 110, 21, UI.body, "img/btn_back.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            UI.lottery_update_info = nil
            UI.lottery_blocks = nil
            
            UI.scrollbar:ibScrollTo( 0, 250, "Linear" )
            UI.body:ibDeepSet( "disabled", true )
            for i = 1, 5 do
                UI.lottery_areas[ LOTTERY_ITEMS_INFO[ i ].lottery_variant ]:ibMoveTo( anim_start_px, _, UI_ANIMS.select.move_new_duration )
            end

            ShowLotteryTypeSelectUI( true )
        end )

    local area_sx, area_sy = 342, 451
    local img_sx, img_sy = 308, 417

    ibCreateButton( 0, 390, 14, 24, UI.body, "img/btn_arrow.png", nil, nil, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            UI.scrollbar:ibScrollTo( 0, 250, "Linear" )
        end )

    ibCreateButton( area_sx * 3 - 13, 390, 14, 24, UI.body, "img/btn_arrow.png", nil, nil, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibData( "rotation", 180 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            UI.scrollbar:ibScrollTo( 0.91, 250, "Linear" )
        end )

    local function center_shadow( element, parent )
        element:ibBatchData( { px = parent:ibData( "px" ) - 167 - ((UI.scrollbar:ibData( "position" ) > 0 and parent:ibData( "index" ) >= 3) and 658 or 0), py = parent:ibData( "py" ) + 11 } )
    end

    UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 14, 179, area_sx * 3 - 40, 451, UI.body, { horizontal = true } )

    UI.lottery_areas = { }
    UI.lottery_update_info = {}
    UI.lottery_blocks = {}

    for i = 1, #LOTTERY_ITEMS_INFO do
        local item_info = LOTTERY_ITEMS_INFO[ i ]
        local variant_data = lottery_info.variants[ item_info.lottery_variant ]

        local area_item = ibCreateArea( anim_start_px, 0, area_sx, area_sy, UI.scrollpane )
            :ibTimer( function( self )
                self:ibMoveTo( ( i - 1 ) * area_sx - (i > 1 and (i - 1) * 13 or 0), _, UI_ANIMS.select.move_new_duration )
            end, UI_ANIMS.select.move_new_delay, 1 )
        UI.lottery_areas[ item_info.lottery_variant ] = area_item
        UI.lottery_areas[ item_info.lottery_variant ]:ibData( "index", i )
        
        if not isElement( UI.bg_hover ) then
            UI.bg_hover = ibCreateImage( 0, 0, 706, 788, "img/lottery/bg_hover.png", UI.body )
                :ibBatchData( { disabled = true, alpha = 0, priority = -1 } )

            center_shadow( UI.bg_hover, area_item )
        end

        local img_path = "img/lottery/types/" .. lottery_info.id .. "/variants/main"
        if not fileExists( img_path .. ".png" ) then
            img_path = "img/lottery/variants/" .. item_info.lottery_variant .. "/main"
        end
        local bg_item = ibCreateImage( ( area_sx - img_sx ) * 0.5, ( area_sy - img_sy ) * 0.5, img_sx, img_sy, img_path .. ".png", area_item )
            :ibData( "disabled", true )

        local bg_item_hover = ibCreateImage( 0, 0, area_sx, area_sy, "img/lottery/variants/" .. item_info.lottery_variant .. "/main_hover.png", area_item )
            :center()
            :ibBatchData( { disabled = true, alpha = 128 } )

        local reward_img_path = "img/lottery/types/" .. lottery_info.id .. "/rewards.png"
        if not fileExists( reward_img_path ) then
            reward_img_path = "img/lottery/types/" .. lottery_info.id .. "/rewards" .. item_info.lottery_variant .. ".png"
        end
        if fileExists( reward_img_path ) then
            ibCreateImage( 0, 2, 0, 0, reward_img_path, bg_item ):ibSetRealSize( ):center_x():ibData( "disabled", true )
        end

        local bg_circle_pp = ibCreateImage( 0, 167, 84, 84, "img/lottery/bg_circle_pp.png", bg_item ):center_x():ibData( "disabled", true )
        ibCreateLabel( 38, 23, 0, 0, CONST_PROGRESSION_POINTS_FOR_LOTTERY_VARIANT[ item_info.lottery_variant ], bg_circle_pp, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_18 )

        local bg_item_header = ibCreateImage( 0, -8, 244, 103, "img/lottery/variants/" .. item_info.lottery_variant .. "/header.png", area_item )
            :center_x()
            :ibBatchData( { disabled = true, priority = 2 } )

        area_item:ibTimer( function( self )
            self
                :ibOnHover( function( ) area_item:ibData( "priority", 1 ); UI.bg_hover:ibAlphaTo( 255, 300 ); center_shadow( UI.bg_hover, area_item ); bg_item_hover:ibAlphaTo( 255, 300 ) end )
                :ibOnLeave( function( ) area_item:ibData( "priority", 0 ); UI.bg_hover:ibAlphaTo( 0, 300 ); center_shadow( UI.bg_hover, area_item ); bg_item_hover:ibAlphaTo( 128, 300 ) end )
        end, UI_ANIMS.select.total, 1 )

        UI.lottery_update_info[ item_info.lottery_variant ] = function( ignore_anim )
            local area_info = UI.lottery_update_info[ item_info.lottery_variant .. "_area_info" ]
            if isElement( area_info ) then destroyElement( area_info ) end

            area_info = ibCreateArea( 0, 0, area_sx, area_sy, area_item ):ibData( "disabled", true )
            if not ignore_anim then
                area_info
                    :ibData( "alpha", 0 ):ibTimer( ibAlphaTo, UI_ANIMS.select.total, 1, 255 )
            end
            UI.lottery_update_info[ item_info.lottery_variant .. "_area_info" ] = area_info

            local text = item_info.text
            if text then
                ibCreateLabel( 0, 267, 0, 0, text, area_info, _, 1, 1, "center", "center", ibFonts.bold_18 )
                    :center_x( )
            else
                local chance_color = { [ 2 ] = 0xFF491EF8, [ 2.5 ] = 0xFF491EF8, [ 3 ] = 0xFFDEBF27, [ 3.5 ] = 0xFFDEBF27, }
                local chance_area = ibCreateArea( 0, 255, 0, 0, area_info )
                local lbl_text = ibCreateLabel( 0, 2, 0, 0, "Шансы в", chance_area, _, _, _, _, _, ibFonts.bold_16 )
                local lbl_chance = ibCreateLabel( lbl_text:ibGetAfterX( 5 ), 0, 0, 0, variant_data.chance_coef, chance_area, chance_color[ variant_data.chance_coef ], _, _, _, _, ibFonts.oxaniumbold_18 )
                local lbl_finish_text = ibCreateLabel( lbl_chance:ibGetAfterX( 5 ), 2, 0, 0, "раза выше", chance_area, _, _, _, _, _, ibFonts.bold_16 )
                chance_area:ibData( "sx", lbl_finish_text:ibGetAfterX() ):center_x()
            end

            if IfHasNextPurchasedVariantTicket( lottery_info.id, item_info.lottery_variant ) then
                ibCreateLabel( 0, 291, area_sx, 0, "Осталось открыть:", area_info, _, _, _, "center", "top", ibFonts.regular_18 )
                ibCreateLabel( 0, 313, area_sx, 0, DATA.purchased_tickets[ lottery_info.id ][ item_info.lottery_variant ], area_info, _, _, _, "center", "top", ibFonts.oxaniumbold_22 )

                ibCreateButton( 72, 351, 178, 66, area_info, "img/btn_open_h.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
                    :ibOnHover( function( ) area_item:ibData( "priority", 1 ); UI.bg_hover:ibAlphaTo( 255, 300 ); center_shadow( UI.bg_hover, area_item ); bg_item_hover:ibAlphaTo( 255, 300 ) end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        if ( LAST_CLICK_TICK_OPEN or 0 ) + 500 > getTickCount( ) then return end
                        LAST_CLICK_TICK_OPEN = getTickCount( )
                        ibClick( )

                        UI.bg_hover:ibData( "alpha", 0 )
                        triggerServerEvent( "onPlayerWantOpenLottery", resourceRoot, _, lottery_info.id, item_info.lottery_variant )
                    end )
                    :center_x()
            else
                local cost_area = ibCreateArea( 0, 282, 0, 0, area_info )
                local lbl_text = ibCreateLabel( 0, 2, 0, 0, "Цена:", cost_area, _, _, _, _, _, ibFonts.regular_16 )
                local lbl_cost = ibCreateLabel( lbl_text:ibGetAfterX( 5 ), 0, 0, 0, format_price( variant_data.cost ), cost_area, _, _, _, _, _, ibFonts.oxaniumbold_18 )
                local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), -4, 28, 28, ":nrp_shared/img/".. ( lottery_info.cost_is_hard and "hard_" or "" ) .."money_icon.png", cost_area ):ibData( "disabled", true )
                cost_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )

                local count_area = ibCreateArea( 0, 316, 0, 0, area_info )
                local btn_minus = ibCreateButton( 0, 0, 31, 30, count_area, "img/btn_minus.png", nil, nil, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                    :ibOnClick( function( button, state ) 
                        if button ~= "left" or state ~= "up" then return end
                        ibClick( )
                        local lbl_count = count_area:ibData( "count_lbl" )
                        local prev_number = tonumber( lbl_count:ibData( "text" ) ) - 1
                        lbl_count:ibData( "text", prev_number == 0 and 20 or prev_number )
                    end )
                
                local bg_count_stroke = ibCreateImage( btn_minus:ibGetAfterX( 6 ), 0, 48, 30, "img/bg_count_stroke.png", count_area )
                local lbl_count = ibCreateLabel( 0, 0, 48, 30, "1", bg_count_stroke, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_18 )
                
                local btn_plus = ibCreateButton( bg_count_stroke:ibGetAfterX( 6 ), 0, 31, 30, count_area, "img/btn_plus.png", nil, nil, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                    :ibOnClick( function( button, state ) 
                        if button ~= "left" or state ~= "up" then return end
                        ibClick( )
                        local lbl_count = count_area:ibData( "count_lbl" )
                        local next_number = tonumber(lbl_count:ibData( "text" ) ) + 1
                        lbl_count:ibData( "text", math.min( 20, next_number <= 20 and next_number or 1 ) )
                    end )
                count_area:ibData( "count_lbl", lbl_count )
                count_area:ibData( "sx", btn_plus:ibGetAfterX() ):center_x()
                
                ibCreateButton( 72, 351, 178, 66, area_info, "img/btn_buy_h.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
                    :ibOnHover( function( ) area_item:ibData( "priority", 1 ); UI.bg_hover:ibAlphaTo( 255, 300 ); center_shadow( UI.bg_hover, area_item ); bg_item_hover:ibAlphaTo( 255, 300 ) end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        if ( LAST_CLICK_TICK or 0 ) + 500 > getTickCount( ) then return end
                        LAST_CLICK_TICK = getTickCount( )
                        ibClick( )

                        triggerServerEvent( "onPlayerWantBuyLottery", resourceRoot, _, lottery_info.id, item_info.lottery_variant, tonumber( count_area:ibData( "count_lbl" ):ibData( "text" ) ) )
                    end )
                    :center_x()
            end
        end
        UI.lottery_update_info[ item_info.lottery_variant ]()

        if not is_has_premium and item_info.lottery_variant > 3 then
            UI.lottery_blocks[ item_info.lottery_variant ] = ibCreateImage( 0, 0, 308, 417, "img/lottery/variants/" .. item_info.lottery_variant .. "/block.png", area_item )
                :center()

            ibCreateButton( 72, 371, 125, 20, UI.lottery_blocks[ item_info.lottery_variant ], "img/btn_buy_premium.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, 4 )
                end )
                :center_x()
        end
    end

    UI.scrollpane:ibBatchData( { sx = area_sx * 5 } )
    UI.scrollbar:ibBatchData( { position = 0, visible = false, sensivity = 0     } )
end

function onClientPlayerPremium_handler()
    if not UI or not UI.lottery_blocks then return end

    for k, v in pairs( UI.lottery_blocks or {} ) do
        if isElement( v ) then
            destroyElement( v )
        end
    end
    UI.update_progress_points()
end
addEvent( "onClientPlayerPremium", true )
addEventHandler( "onClientPlayerPremium", root, onClientPlayerPremium_handler )

function ShowLotteryNextLotteryAction( id, lottery_variant )
    if isElement( UI.black_bg_next_action ) then return end
    UI.black_bg:ibData( "can_destroy", false )

    UI.black_bg_next_action = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, _, UI.black_bg, 0xBF1D252E )

    local lottery_info = LOTTERIES_INFO[ id ]
    local item_info = LOTTERY_ITEMS_INFO[ lottery_variant ]
    local variant_data = lottery_info.variants[ lottery_variant ]

    local area_sx, area_sy = 342, 451
    local img_sx, img_sy = 308, 417
    
    local area_next_action = ibCreateArea( 0, 0, 1024, 768, UI.black_bg_next_action )
        :center( )

    UI.bg_discount = ibCreateImage( 0, 107, 1024, 52, "img/bg_discount.png", area_next_action )
        :ibData( "alpha", 0 )
    UI.bg_discount_lbl = ibCreateLabel( 0, 0, 1024, 38, "", UI.bg_discount, nil, nil, nil, "center", "center", ibFonts.bold_14 )

    local img_path = "img/lottery/types/" .. id .. "/variants/main"
    if not fileExists( img_path .. ".png" ) then
        img_path = "img/lottery/variants/" .. lottery_variant .. "/main"
    end
    local bg_item = ibCreateImage( 0, 0, img_sx, img_sy, img_path .. ".png", area_next_action )
        :center()
        :ibData( "disabled", true )
    
    local bg_item_hover = ibCreateImage( 0, 0, area_sx, area_sy, "img/lottery/variants/" .. lottery_variant .. "/main_hover.png", area_next_action )
        :center()
        :ibBatchData( { disabled = true } )
    
    local reward_img_path = "img/lottery/types/" .. id .. "/rewards.png"
    if not fileExists( reward_img_path ) then
        reward_img_path = "img/lottery/types/" .. id .. "/rewards" .. lottery_variant .. ".png"
    end
    if fileExists( reward_img_path ) then
        ibCreateImage( 0, 2, 0, 0, reward_img_path, bg_item ):ibSetRealSize( ):center_x():ibData( "disabled", true )
    end
    
    local bg_circle_pp = ibCreateImage( 0, 167, 84, 84, "img/lottery/bg_circle_pp.png", bg_item ):center_x():ibData( "disabled", true )
    ibCreateLabel( 38, 23, 0, 0, CONST_PROGRESSION_POINTS_FOR_LOTTERY_VARIANT[ lottery_variant ], bg_circle_pp, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_18 )
    
    local bg_item_header = ibCreateImage( 0, 150, 244, 103, "img/lottery/variants/" .. lottery_variant .. "/header.png", area_next_action )
        :center_x()
        :ibBatchData( { disabled = true, priority = 2 } )

    ibCreateButton( 0, 679, 148, 60, area_next_action, "img/btn_close_h.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :center_x()
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            destroyElement( UI.black_bg_next_action )
        end )

    UI.lottery_update_info_action = function( is_update )        
        if isElement( UI.lottery_update_info_action_area ) then destroyElement( UI.lottery_update_info_action_area ) end
        
        if DATA.discount then
            UI.bg_discount:ibData( "alpha", 255 )
            UI.bg_discount_lbl:ibData( "text", string.format( "Купи билет прямо сейчас с дополнительной скидкой в %s%s", math.floor( DATA.discount * 100 ), "%" ) )
        end

        local area_info = ibCreateArea( 0, 0, area_sx, area_sy, bg_item_hover )
            :center_x()
            :ibData( "disabled", true )
        UI.lottery_update_info_action_area = area_info

        local text = item_info.text
        if text then
            ibCreateLabel( 0, 267, 0, 0, text, area_info, _, 1, 1, "center", "center", ibFonts.bold_18 )
                :center_x( )
        else
            local chance_color = { [ 2 ] = 0xFF491EF8, [ 2.5 ] = 0xFF491EF8, [ 3 ] = 0xFFDEBF27, [ 3.5 ] = 0xFFDEBF27, }
            local chance_area = ibCreateArea( 0, 255, 0, 0, area_info )
            local lbl_text = ibCreateLabel( 0, 2, 0, 0, "Шансы в", chance_area, _, _, _, _, _, ibFonts.bold_16 )
            local lbl_chance = ibCreateLabel( lbl_text:ibGetAfterX( 5 ), 0, 0, 0, variant_data.chance_coef, chance_area, chance_color[ variant_data.chance_coef ], _, _, _, _, ibFonts.oxaniumbold_18 )
            local lbl_finish_text = ibCreateLabel( lbl_chance:ibGetAfterX( 5 ), 2, 0, 0, "раза выше", chance_area, _, _, _, _, _, ibFonts.bold_16 )
            chance_area:ibData( "sx", lbl_finish_text:ibGetAfterX() ):center_x()
        end

        if IfHasNextPurchasedVariantTicket( lottery_info.id, lottery_variant ) then
            ibCreateLabel( 0, 291, area_sx, 0, "Осталось открыть:", area_info, _, _, _, "center", "top", ibFonts.regular_18 )
            ibCreateLabel( 0, 313, area_sx, 0, DATA.purchased_tickets[ lottery_info.id ][ lottery_variant ], area_info, _, _, _, "center", "top", ibFonts.oxaniumbold_22 )
            
            ibCreateButton( 72, 351, 178, 66, area_info, "img/btn_open_h.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    if ( LAST_CLICK_TICK_OPEN or 0 ) + 500 > getTickCount( ) then return end
                    LAST_CLICK_TICK_OPEN = getTickCount( )
                    ibClick( )

                    triggerServerEvent( "onPlayerWantOpenLottery", resourceRoot, _, lottery_info.id, lottery_variant )
                end )
                :center_x()
        else
            if DATA.discount then
                local cost_area = ibCreateArea( 0, 293, 0, 0, area_info )
                local lbl_text = ibCreateLabel( 0, 4, 0, 0, "Цена со скидкой:", cost_area, _, _, _, _, _, ibFonts.regular_14 )
                local lbl_cost = ibCreateLabel( lbl_text:ibGetAfterX( 5 ), 0, 0, 0, format_price( math.floor( variant_data.cost * (1 - DATA.discount) ) ), cost_area, _, _, _, _, _, ibFonts.oxaniumbold_18 )
                local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), 0, 24, 24, ":nrp_shared/img/".. ( lottery_info.cost_is_hard and "hard_" or "" ) .."money_icon.png", cost_area ):ibData( "disabled", true )
                cost_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( 3 )
                
                local original_cost_area = ibCreateArea( 0, 317, 0, 0, area_info )
                local lbl_text = ibCreateLabel( 0, 4, 0, 0, "Цена без скидки:", original_cost_area, _, _, _, _, _, ibFonts.regular_14 )
                local lbl_cost = ibCreateLabel( lbl_text:ibGetAfterX( 5 ), 1, 0, 0, format_price( variant_data.cost ), original_cost_area, _, _, _, _, _, ibFonts.oxaniumbold_16 )
                local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), 1, 21, 21, ":nrp_shared/img/".. ( lottery_info.cost_is_hard and "hard_" or "" ) .."money_icon.png", original_cost_area ):ibData( "disabled", true )
                local sx = icon_money:ibGetAfterX( )
                original_cost_area:ibData( "sx", sx ):center_x( )
                ibCreateImage( 118, 12, sx - 112, 1, nil, original_cost_area, 0xFFFFFFFF )
            else
                local cost_area = ibCreateArea( 0, 282, 0, 0, area_info )
                local lbl_text = ibCreateLabel( 0, 2, 0, 0, "Цена:", cost_area, _, _, _, _, _, ibFonts.regular_16 )
                local lbl_cost = ibCreateLabel( lbl_text:ibGetAfterX( 5 ), 0, 0, 0, format_price( variant_data.cost ), cost_area, _, _, _, _, _, ibFonts.oxaniumbold_18 )
                local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), -4, 28, 28, ":nrp_shared/img/".. ( lottery_info.cost_is_hard and "hard_" or "" ) .."money_icon.png", cost_area ):ibData( "disabled", true )
                cost_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )
            end
            
            ibCreateButton( 72, 351, 178, 66, area_info, "img/btn_buy_h.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    if ( LAST_CLICK_TICK or 0 ) + 500 > getTickCount( ) then return end
                    LAST_CLICK_TICK = getTickCount( )
                    ibClick( )
                    
                    triggerServerEvent( "onPlayerWantBuyLottery", resourceRoot, _, lottery_info.id, lottery_variant, 1 )
                end )
                :center_x()
        end
    end
    UI.lottery_update_info_action()

    UI.black_bg_next_action:ibOnDestroy( function( )
        
        DATA.discount = nil
        UI.lottery_update_info_action = nil
        triggerServerEvent( "onServerResetPlayerQueuePurchaseLotteryTicket", resourceRoot )

        UI.black_bg:ibData( "can_destroy", true )
        
        if isElement( UI.lottery_to_restore and UI.lottery_areas[ UI.lottery_to_restore.lottery_variant ] ) then
            UI.lottery_areas[ UI.lottery_to_restore.lottery_variant ]
                :ibData( "py", -_SCREEN_Y )
                :ibTimer( ibMoveTo, 200, 1, _, 0, 300 )
        end
    end )

    showCursor( true )
end

function ShowLotteryScratchRewardUI( lottery_variant, reward, points, purchased_tickets )
    if isElement( UI.black_bg_scratch ) then return end

    UI.black_bg:ibData( "can_destroy", false )
    onClientUpdateLotteryData_handler( lottery_variant, points, purchased_tickets )

    local anim_hide_duration = 300
    local anim_show_duration = 300
    local anim_total_duration = anim_hide_duration + anim_show_duration
    UI.lottery_areas[ lottery_variant ]
        :ibMoveTo( _, _SCREEN_Y, anim_hide_duration )
    
    UI.black_bg_scratch = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, _, UI.black_bg, 0xBF1D252E )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 400 )

    local area_scratch = ibCreateArea( 0, 0, 1024, 768, UI.black_bg_scratch )
        :center( )
    
    local img_path = "img/lottery/types/" .. SELECTED_LOTTERY_INFO.id .. "/variants/main.png"
    if not fileExists( img_path ) then
        img_path = "img/lottery/variants/" .. lottery_variant .. "/main.png"
    end
    local bg_lottery = ibCreateImage( 0, _SCREEN_Y, 381, 551, img_path, area_scratch )
        :center_x( )
        :ibTimer( ibMoveTo, anim_hide_duration, 1, _, ( area_scratch:height( ) - 535 ) / 2, anim_show_duration )

    ibCreateLabel( 0, 510, 381, 0, "Сотри защиту и получи приз", bg_lottery, nil, nil, nil, "center", "top", ibFonts.regular_16 )
        :ibData( "priority", 10 )

    local bg_item_hover = ibCreateImage( 0, 0, 422, 595, "img/lottery/variants/" .. lottery_variant .. "/main_hover.png", bg_lottery )
        :center()
        :ibData( "disabled", true )

    local bg_item_header = ibCreateImage( 0, -5, 244, 103, "img/lottery/variants/" .. lottery_variant .. "/header.png", bg_item_hover )
        :center_x()
        :ibData( "disabled", true )

    local reward_img_path = "img/lottery/types/" .. SELECTED_LOTTERY_INFO.id .. "/rewards.png"
    if not fileExists( reward_img_path ) then
        reward_img_path = "img/lottery/types/" .. SELECTED_LOTTERY_INFO.id .. "/rewards" .. lottery_variant .. ".png"
    end
    if fileExists( reward_img_path ) then
        ibCreateImage( 0, 36, 328, 280, reward_img_path, bg_lottery ):ibSetRealSize( ):center_x()
    end

    local canvas_sx, canvas_sy = 323, 239
    local canvas = ibCreateArea( 0, 262, canvas_sx, canvas_sy, bg_lottery ):center_x( )
    local bg_scratch_layer = ibCreateImage( 0, 0, canvas_sx, canvas_sy, "img/bg_scratch_layer.png", canvas )

    local area_reward = ibCreateArea( 0, 0, canvas_sx, canvas_sy, canvas )
        if reward.type == "vehicle" then
            ibCreateImage( 0, 0, canvas_sx, canvas_sy, "img/bg_reward_veh.png", area_reward )
        end
        local item_class = REGISTERED_ITEMS[ reward.type ]
        local item_info = item_class.uiGetDescriptionData_func( reward.type, reward.params )
        if item_class.uiCreateScratchItem_func then
            item_class.uiCreateScratchItem_func( reward.type, reward.params, area_reward )
        else
            local img_reward = ibCreateImage( 0, 0, 0, 0, item_info.img, area_reward )
                :ibSetRealSize( )
            if img_reward:ibData( "sy" ) > canvas_sy - 40 then
                img_reward:ibSetInBoundSize( canvas_sx - 40, canvas_sy - 40 )
            end
            img_reward:center( 0, -10 )
        end
        ibCreateLabel( 0, canvas_sy - 20, 0, 0, item_info.title, area_reward, _, 1, 1, "center", "center", ibFonts.regular_16 )
            :center_x( )
    area_reward:ibData( "alpha", 0 ):ibTimer( area_reward.ibData, 500, 1, "alpha", 255 )

    local scratch_layer = ibCreateImage( 0, 0, canvas_sx, canvas_sy, shader, canvas )
    
    local shader = dxCreateShader( [[

        texture layer_tex;
        texture rt_scratch;

        float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
        
        sampler SamplerTex = sampler_state
        {
            Texture = (layer_tex);
        };

        sampler SamplerRT = sampler_state
        {
            Texture = (rt_scratch);
        };

        struct VSInput
        {
            float3 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };

        struct PSInput
        {
            float4 Position : POSITION0;
            float2 TexCoord : TEXCOORD0;
            float4 Diffuse : COLOR0;
        };

        PSInput VertexShaderFunction(VSInput VS)
        {
            PSInput PS = (PSInput)0;
            PS.Position = mul(float4(VS.Position.xyz, 1), gWorldViewProjection);
            PS.TexCoord = VS.TexCoord;
            PS.Diffuse = VS.Diffuse;

            return PS;
        }


        float4 PixelShaderFunction(PSInput PS) : COLOR
        {
            float4 tex_color = tex2D( SamplerTex, PS.TexCoord );
            float4 rt_color = tex2D( SamplerRT, PS.TexCoord );
            tex_color.a *= 1 - rt_color.r;
            tex_color.a *= PS.Diffuse.a;
            return tex_color;
        }

        technique blend
        {
            pass P0
            {
                VertexShader = compile vs_3_0 VertexShaderFunction();
                PixelShader  = compile ps_3_0 PixelShaderFunction();
            }
        } 

        // Fallback
        technique fallback
        {
            pass P0
            {
                // Just draw normally
            }
        }
        
    ]] )

    local rt_scratch = dxCreateRenderTarget( canvas_sx, canvas_sy )
    local layer_tex = dxCreateTexture( "img/scratch_layer.png" )
    local pattern_tex = dxCreateTexture( "img/scratch_pattern.png" )
    shader:setValue( "rt_scratch", rt_scratch )
    shader:setValue( "layer_tex", layer_tex )
    scratch_layer:ibData( "texture", shader )

    local pattern_sx = 24
    local min_dist = pattern_sx / 2
    local old_cpx, old_cpy = 0, 0
    local canvas_px, canvas_py = 0, 0

    scratch_layer:ibTimer( function( )
        local parent = scratch_layer
        repeat
            canvas_px, canvas_py = canvas_px + parent:ibData( "px" ), canvas_py + parent:ibData( "py" )
            parent = parent.parent
        until not parent or parent:isibRoot( )
    end, anim_total_duration, 1 )

    local function onClientCursorMove_scratch( _, _, cpx, cpy )
        dxSetRenderTarget( rt_scratch )
        dxSetBlendMode( "add" )
            local dx = old_cpx - cpx
            local dy = old_cpy - cpy
            local dist = math.sqrt( dx*dx + dy*dy )
            local segments = math.ceil( dist / min_dist )
            dx = dx / segments
            dy = dy / segments
            for i = segments, 1, -1 do
                local px = cpx - canvas_px - pattern_sx / 2 + i * dx
                local py = cpy - canvas_py - pattern_sx / 2 + i * dy
                dxDrawImage( px, py, pattern_sx, pattern_sx, pattern_tex )
            end
            old_cpx, old_cpy = cpx, cpy
        dxSetBlendMode( "blend" )
        dxSetRenderTarget( )
    end

    local is_revealed = false
    local reveal_threshold = 0.5
    local precision = math.ceil( pattern_sx / 2 )
    local total = math.ceil( canvas_sx / precision ) * math.ceil( canvas_sy / precision )

    local function complete_reveal( )
        is_revealed = true
        scratch_layer:ibAlphaTo( 0, 500 )
        UI.lottery_to_restore = { id = SELECTED_LOTTERY_INFO.id, lottery_variant = lottery_variant }

        setTimer( ShowLotteryReward, 800, 1, reward, true, nil )
        UI.black_bg_scratch:ibTimer( ibAlphaTo, 1000, 1, 0, 1000 )
        UI.black_bg_scratch:ibTimer( destroyElement, 2000, 1 )
        return is_revealed
    end

    local function check_revealed_area( )
        if is_revealed then return end
        local pixels = rt_scratch:getPixels( )
        local revealed = 0
        for i = precision, canvas_sx - 1, precision do
            for j = precision, canvas_sy - 1, precision do
                if dxGetPixelColor( pixels, i, j ) > 128 then
                    revealed = revealed + 1
                end
            end
        end
        if revealed / total > reveal_threshold then
            return complete_reveal( )
        end
        return false
    end

    scratch_layer
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            old_cpx, old_cpy = getCursorPosition( )
            old_cpx, old_cpy = old_cpx * _SCREEN_X, old_cpy * _SCREEN_Y
            addEventHandler( "onClientCursorMove", root, onClientCursorMove_scratch )
        end )
        :ibOnAnyClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            removeEventHandler( "onClientCursorMove", root, onClientCursorMove_scratch )
            check_revealed_area( )
        end )

    setCursorAlpha( 0 )
    local img_scratch_cursor = ibCreateImage( 0, 0, 64, 64, "img/scratch_cursor.png", UI.black_bg_scratch )
        :ibData( "disabled", true )
        :ibOnRender( function( )
            local cpx, cpy = getCursorPosition( )
            cpx, cpy = cpx * _SCREEN_X, cpy * _SCREEN_Y
            this:ibBatchData( { px = cpx - 12, py = cpy - 48 })
        end )

    UI.black_bg_scratch:ibOnDestroy( function( )
        rt_scratch:destroy( )
        layer_tex:destroy( )
        pattern_tex:destroy( )
        shader:destroy( )
        removeEventHandler( "onClientCursorMove", root, onClientCursorMove_scratch )
        setCursorAlpha( 255 )
    end )

    UI.func_tmr_check_revealed_area = function( self )
        if check_revealed_area() then return end
        
        self.black_bg:ibTimer( function()
            if is_revealed then return end
            
            self:func_tmr_check_revealed_area()
        end, CLIENT_CONST_CHECK_TIME_REVEALED_AREA_IN_MS, 1 )
    end
    UI:func_tmr_check_revealed_area()

    -- Для теста
    if localPlayer:getData( "__lottery_reward_id" ) then
        complete_reveal( )
    end
end
addEvent( "ShowLotteryScratchRewardUI", true )
addEventHandler( "ShowLotteryScratchRewardUI", resourceRoot, ShowLotteryScratchRewardUI )

function ShowLotteryReward( item, after_scratching, callback )
    if not isElement( UI.bg ) then return end
    setCursorAlpha( 255 )

    local reward_element = ibCreateDummy( UI.bg )
    
    if item.type == "tuning_case" or item.type == "vinyl_case" then
        item.params.id = (item.type == "tuning_case" and "tuning_" or "vinyl_") .. item.params.id
    end

    triggerEvent( "ShowTakeReward", reward_element, UI.black_bg, item.type, item )

    addEventHandler( "ShowTakeReward_callback", reward_element, function( data )
        if callback then callback() end

        triggerServerEvent( "onPlayerWantTakeLotteryReward", resourceRoot, data )
        reward_element:destroy( )
        
        if UI.lottery_to_restore and not item.is_progression_reward then
            local id, variant = UI.lottery_to_restore.id, UI.lottery_to_restore.lottery_variant
            if isElement( UI.lottery_areas[ variant ] ) and IfLastPurchasedVariantTicket( id, variant ) then
                
                if not LOTTERIES_INFO[ id ]:IsActive() and IfLastPurchasedVariantTicket( id, variant ) then
                    ShowLotteryTypeSelectUI( true )
                else
                    UI.lottery_areas[ variant ]
                        :ibData( "py", -_SCREEN_Y )
                        :ibTimer( ibMoveTo, 200, 1, _, 0, 300 )
                end
            else
                ShowLotteryNextLotteryAction( id, variant )
            end
        end
    end )
end
addEvent( "ShowLotteryReward", true )
addEventHandler( "ShowLotteryReward", resourceRoot, ShowLotteryReward )

function IfHasNextPurchasedVariantTicket( id, variant )
    return (DATA.purchased_tickets[ id ] and DATA.purchased_tickets[ id ][ variant ] or 0) > 0
end

function IfLastPurchasedVariantTicket( id, variant )
    return LOTTERIES_INFO[ id ].IsActive and not LOTTERIES_INFO[ id ]:IsActive() and (DATA.purchased_tickets[ id ] and DATA.purchased_tickets[ id ][ variant ] or 0) == 0
end