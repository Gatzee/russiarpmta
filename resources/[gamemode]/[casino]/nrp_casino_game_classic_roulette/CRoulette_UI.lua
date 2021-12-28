
UI_elements = nil
scX, scY = guiGetScreenSize()
cfX, cfY = scX / 1920, scY / 1080
cfX = cfX + math.abs( cfX - cfY )

RATE_DURATION = nil

-------------------------------------------------
-- Функционал отображения UI
-------------------------------------------------

function CreateRoulleteUI()
    DestroyRouletteUI()
    UI_elements = {}
    
    RATE_DURATION = DURATION_STATE[ CR_STATE_RATE ] * 1000
    UI_elements.game_logo = ibCreateImage( 20 * cfX, 20 * cfY, 0, 0, ":nrp_casino_lobby/img/icons/icon_game_" .. ROULETTE_DATA.game .. ".png" ):ibSetRealSize()
    UI_elements.game_logo:ibBatchData( { sx = UI_elements.game_logo:ibData( "sx" ) * cfX, sy = UI_elements.game_logo:ibData( "sy" ) * cfY } )
    
    UI_elements.bg_top = ibCreateImage( cfX * 20, scY - cfY * 324, cfX * 255, cfY * 304, "img/bg_top.png" )
    UI_elements.key_action_close = ibAddKeyAction( _, _, UI_elements.bg_top, function()
        OnTryLeftGame()
    end )

    local balance = format_price( ROULETTE_DATA.game == CASINO_GAME_CLASSIC_ROULETTE and localPlayer:GetMoney() or localPlayer:GetDonate() )
    UI_elements.bg_balance = ibCreateImage( _SCREEN_X - 276 * cfX, 20 * cfY, 256 * cfX, 115 * cfY, "img/bg_balance.png" )
    UI_elements.lbl_balance = ibCreateLabel( 20 * cfX, 60 * cfY, 0, 0, balance, UI_elements.bg_balance, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "oxaniumbold_" .. math.ceil( 21 * cfY ) ] )
    UI_elements.icon_balance = ibCreateImage( UI_elements.lbl_balance:ibGetAfterX(10 * cfX), 61 * cfY, 28 * cfX, 24 * cfY, "img/" .. ROULETTE_DATA.currency .. ".png", UI_elements.bg_balance )
    ibCreateButton( 20 * cfX, 92 * cfY, 112 * cfX, 10 * cfY, UI_elements.bg_balance, "img/btn_top_up_balance.png", "img/btn_top_up_balance.png", "img/btn_top_up_balance.png", 0xCCFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ibClick()
            
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "classic_roulette_vip" )
        end )
    addEventHandler( "onClientElementDataChange", localPlayer, onClientElementDataChange_handler )

    UI_elements.help_cur_lbl = ibCreateLabel( cfX * 345, scY - cfY * 152, 0, 0, "сделанная ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.cur_lbl = ibCreateLabel( cfX * 345, scY - cfY * 135, 0, 0, "0", false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "oxaniumbold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.cur_soft_img = ibCreateImage( cfX * 351 + dxGetTextWidth( "0", 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), scY - 130 * cfY, 23 * cfX, 20 * cfY, "img/" .. ROULETTE_DATA.currency .. ".png" )
    
    UI_elements.line_rate = ibCreateImage( 345 * cfX, scY - 105 * cfY, 104 * cfX, 1, _, _, 0x16FFFFFF )

    local min_price = format_price( MIN_RATES[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.game ] )
    UI_elements.help_min_lbl = ibCreateLabel( cfX * 345, scY - 100 * cfY, 0, 0, "мин.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.min_lbl = ibCreateLabel( cfX * 345, scY - 85 * cfY, 0, 0, min_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "oxaniumbold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.min_soft_img = ibCreateImage( cfX * 351 + dxGetTextWidth( min_price, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), scY - 80 * cfY, 23 * cfX, 20 * cfY, "img/" .. ROULETTE_DATA.currency .. ".png" )
    
    local max_price = format_price( MAX_RATES[ ROULETTE_DATA.casino_id ][ ROULETTE_DATA.game ] )
    UI_elements.help_max_lbl = ibCreateLabel( cfX * 345, scY - 58 * cfY, 0, 0, "макс.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.max_lbl = ibCreateLabel( cfX * 345, scY - 45 * cfY, 0, 0, max_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "oxaniumbold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.max_soft_img = ibCreateImage( cfX * 351 + dxGetTextWidth( max_price, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), scY - 40 * cfY, 23 * cfX, 20 * cfY, "img/" .. ROULETTE_DATA.currency .. ".png" )
    
    local px = (scX - 695 * cfX) / 2
    UI_elements.bg_progress_bar = ibCreateImage( px, scY - 199 * cfY, 695 * cfX, 20 * cfY, "img/bg_progress_bar.png" )
    UI_elements.progress_bar = ibCreateImage( 0, 0, 695 * cfX, 20 * cfY, _, UI_elements.bg_progress_bar, 0xFFFFDE96 )
    UI_elements.progress_bar_caret = ibCreateImage( 0, 0, 2 * cfX, 20 * cfY, _, UI_elements.bg_progress_bar, 0xFF9E9395 )
        :ibOnRender( function()
            if not ROULETTE_DATA.time_left_iteration or ROULETTE_DATA.current_state ~= CR_STATE_RATE then return end
        
            local fProgress = (ROULETTE_DATA.time_left_iteration - getTickCount()) / RATE_DURATION
            if fProgress <= 1 then
                local size_x = interpolateBetween( 0, 0, 0, 695 * cfX, 0, 0, fProgress, "Linear" )
                UI_elements.progress_bar_caret:ibBatchData( {
                    px = 696 * cfX - size_x,
                })
                UI_elements.progress_bar:ibBatchData( {
                    px = 696 * cfX - size_x,
                    sx = size_x,
                })
            end
        end )
    UI_elements.timer_icon = ibCreateImage( px - 44 * cfX, scY - 205 * cfY, 24 * cfX, 28 * cfY, "img/timer_icon.png")

    UI_elements.rate_size = ibCreateImage( scX - 276 * cfX, scY - 239 * cfY, 256 * cfX, 139 * cfY, "img/bg_reward_size.png" )
    UI_elements.btn_exit = ibCreateButton( scX - 80 * cfX, scY - 80 * cfY, 60 * cfX, 60 * cfY, nil, "img/btn_exit.png", "img/btn_exit_hovered.png", "img/btn_exit_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            OnTryLeftGame()
        end )

    UI_elements.info_access = ibCreateImage( (scX - 263 * cfX) / 2, 25 * cfY, 263 * cfX, 95 * cfY, "img/text_rate_on.png" ):ibSetRealSize()

    local active_chip_font = ibFonts[ "oxaniumbold_" .. math.ceil( 20 * cfY ) ]
    local passive_chip_font = ibFonts[ "oxaniumbold_" .. math.ceil( 19 * cfY ) ]

    UI_elements.rates = {}
    UI_elements.bg_rate_area = ibCreateArea( 0, scY - 140 * cfY, (6 * 121) * cfX, 100 * cfY ):center_x()
    
    local px = 0
    for k, v in ipairs( RATES_VALUES[ ROULETTE_DATA.casino_id  ][ ROULETTE_DATA.game ] ) do
        local cur_px = px
        UI_elements.rates[ k ] = ibCreateImage( px, 0, 90 * cfX, 90 * cfX, "img/chip_" .. ROULETTE_DATA.currency .. "_" .. k .. ".png", UI_elements.bg_rate_area  ):center_y()
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()

                if ROULETTE_DATA.current_state ~= CR_STATE_RATE then return end

                local size_coeff = 0
                if k == ROULETTE_DATA.current_chip then
                    ROULETTE_DATA.current_chip = nil
                else
                    if ROULETTE_DATA.current_chip then
                        UI_elements.rates[ ROULETTE_DATA.current_chip ]:ibBatchData({ 
                            sx = 90 * cfX, sy = 90 * cfX,
                            texture = "img/chip_" .. ROULETTE_DATA.currency .. "_" .. ROULETTE_DATA.current_chip .. ".png",
                        })
                        local sx, sy = 90 * cfX + size_coeff, 90 * cfX + size_coeff
                        UI_elements.rates[ ROULETTE_DATA.current_chip .. "lbl" ]:ibBatchData({ sx = sx, sy = sy, font = ROULETTE_DATA.current_chip and active_chip_font or passive_chip_font })
                    end

                    ROULETTE_DATA.current_chip = k
                    size_coeff = 10 * cfX
                end

                if not fileExists( CASINO_GAME_CLASSIC_ROULETTE ) then
                    if UI_elements.hint then
                        UI_elements.hint:destroy()
                    end

                    UI_elements.hint = CreateSutiationalHint({
                        py = scY - 250 * cfY,
                        text = "Нажми key=ЛКМ для выбора на какое число поставить",
                        condition = function()
                            return true
                        end,
                    })
                end

                local sx, sy = 90 * cfX + size_coeff, 90 * cfX + size_coeff
                UI_elements.rates[ k .. "lbl" ]:ibBatchData({ sx = sx, sy = sy, font = ROULETTE_DATA.current_chip and active_chip_font or passive_chip_font })
                UI_elements.rates[ k ]
                    :ibBatchData( { 
                        px = cur_px - size_coeff / 2, sx = sx, sy = sy,
                        texture = ROULETTE_DATA.current_chip and ("img/chip_" .. ROULETTE_DATA.currency .. "_" .. k .. "_active.png") or ("img/chip_" .. ROULETTE_DATA.currency .. "_" .. k .. ".png"),
                    } )
                    :center_y()
            end )
        
        local rate_value = (ROULETTE_DATA.casino_id == CASINO_MOSCOW and ROULETTE_DATA.game == CASINO_GAME_CLASSIC_ROULETTE) and (v / 1000 .. "K") or v
        UI_elements.rates[ k .. "lbl" ] = ibCreateLabel( 0, 0, 90 * cfX, 90 * cfX, rate_value, UI_elements.rates[ k ], 0xFFFFFFFF, _, _, "center", "center", passive_chip_font )
            :ibData( "disabled", true )
        
        px = px + 121 * cfX
     end
     
     showCursor( true )
end

function ChangeCurrentSummUI( summ )
    local rate = format_price ( summ )
    UI_elements.cur_lbl:ibData( "text", rate )
    UI_elements.cur_soft_img:ibData( "px", cfX * 351 + dxGetTextWidth( rate, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ) )
end

function FixProgressBar()
    UI_elements.progress_bar_caret:ibBatchData( {
        px = 0,
    })
    UI_elements.progress_bar:ibBatchData( {
        px = 0,
        sx = 696,
    })
end

function ChangeUIAccess()
    if UI_elements then
        UI_elements.info_access:ibData( "texture", ROULETTE_DATA.current_state == CR_STATE_RATE and "img/text_rate_on.png" or "img/text_rate_off.png" )
        UI_elements.bg_progress_bar:ibData( "alpha", ROULETTE_DATA.current_state == CR_STATE_RATE and 255 or 0 )
        UI_elements.timer_icon:ibData( "alpha", ROULETTE_DATA.current_state == CR_STATE_RATE and 255 or 0 )
    end
end

function RefreshTopUI()
    if UI_elements.top_elements then
        DestroyTableElements( UI_elements.top_elements )
    end

    UI_elements.top_elements = {}
    local py = 50 * cfY
    for i = 1, 5 do
        UI_elements.top_elements[ i ] = ibCreateArea( 0, py, 255 * cfX, 50 * cfY, UI_elements.bg_top )
        ibCreateLabel( 0, 0, 40 * cfX, 50 * cfY, ROULETTE_DATA.top_list[ i ] and i or "-", UI_elements.top_elements[ i ], 0xFFFF965D, _, _, "center", "center", ibFonts[ "oxaniumbold_" .. math.ceil( 24 * cfY ) ] )
        ibCreateLabel( 82 * cfX, 6 * cfY, 0, 0, ROULETTE_DATA.top_list[ i ] and ROULETTE_DATA.top_list[ i ].nickname or "", UI_elements.top_elements[ i ], 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
        ibCreateLabel( 165 * cfX, 23 * cfY, 0, 0, ROULETTE_DATA.top_list[ i ] and format_price( ROULETTE_DATA.top_list[ i ].total_win ) or "", UI_elements.top_elements[ i ], 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "oxaniumbold_" .. math.ceil( 14 * cfY ) ] )
        py = py + 51 * cfY
    end
end

function onClientElementDataChange_handler( key, old )
    local currency_key = ROULETTE_DATA.game == CASINO_GAME_CLASSIC_ROULETTE and "money" or "donate"
    if not old or key ~= currency_key then return end

    local money = getElementData( localPlayer, currency_key ) or 0
    UI_elements.lbl_balance:ibData( "text", format_price( money ) ):ibAlphaTo( 0, 100 )

    local diff = money - old
    local diff = diff > 0 and "+" .. format_price( diff ) or format_price( diff )
    if isElement( UI_elements.lbl_balance_change ) then destroyElement( UI_elements.lbl_balance_change ) end

    UI_elements.lbl_balance_change = ibCreateLabel( 20 * cfX, 60 * cfY, 0, 0, diff, UI_elements.bg_balance, money > old and 0xFFB6F4B6 or 0xFFF4B6B6, nil, nil, "left", "top", ibFonts[ "oxaniumbold_" .. math.ceil( 20 * cfY ) ] ):ibData( "alpha", 0 )
    UI_elements.icon_balance:ibData( "px", UI_elements.lbl_balance_change:ibGetAfterX(10 * cfX) )

    UI_elements.lbl_balance_change:ibAlphaTo( 255, 100 )

    if isTimer( UI_elements.money_timer ) then killTimer( UI_elements.money_timer ) end
            
    UI_elements.money_timer = setTimer( function( )
        UI_elements.icon_balance:ibData( "px", UI_elements.lbl_balance:ibGetAfterX(10 * cfX) )
        UI_elements.lbl_balance_change:ibAlphaTo( 0, 100 )
        UI_elements.lbl_balance:ibAlphaTo( 255, 100 )
        
        UI_elements.money_timer = setTimer( function( )
            UI_elements.lbl_balance_change:destroy( )
        end, 100, 1 )
    end, 1000, 1 )
end

function DestroyRouletteUI()
    removeEventHandler( "onClientElementDataChange", localPlayer, onClientElementDataChange_handler )
    if UI_elements then
        DestroyTableElements( UI_elements )
        UI_elements = nil
    end
    showCursor( false )
end

-------------------------------------------------
-- Обработчики отображения результата ставки
-------------------------------------------------

function ShowSuccessRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end

    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    ibCreateImage( 0, 0, scX, scY, "img/bg_green.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfY, scX, 26 * cfY, "img/green_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, scX, 26 * cfY, "ВЫ ПОБЕДИЛИ", UI_elements.text_effect_result, 0xFF54FF68, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    UI_elements.bg_reward_text = ibCreateImage( (scX - 939 * cfX) / 2, scY - 500 * cfY, 939 * cfX, 416 * cfY, "img/reward_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, 939 * cfX, 416 * cfY, "ПОЗДРАВЛЯЕМ! ВАШ ВЫИГРЫШ:", UI_elements.bg_reward_text, 0xFFFFD339, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 21 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (scX - 120 * cfX) / 2, scY - 235 * cfY, 120 * cfX, 120 * cfX, "img/block_reward.png", UI_elements.black_bg_result )
    
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, "img/big_" .. ROULETTE_DATA.currency .. ".png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate.win_amount ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "oxaniumbold_" .. math.ceil( 20 * cfY ) ] )
    
    ibCreateButton( (scX - 100 * cfX) / 2, scY - 95 * cfY, 100 * cfX, 54 * cfY, UI_elements.black_bg_result, "img/btn_ok.png", "img/btn_ok_hovered.png", "img/btn_ok_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            destroyElement( UI_elements.black_bg_result )
        end )

    ShowLastWinFields( result_rate.win_field, result_rate.last_win_fields, UI_elements.black_bg_result )
    UI_elements.info_access:ibData( "alpha", 0 )
    ibGetRewardSound()
end

function ShowFailRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end
    
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    
    ibCreateImage( 0, 0, scX, scY, "img/bg_red.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfX, scX, 26 * cfY, "img/red_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, scX, 26 * cfY, "ВЫ ПРОИГРАЛИ", UI_elements.text_effect_result, 0xFFD42D2D, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    ibCreateButton( (scX - 100 * cfX) / 2, scY - 95 * cfY, 100 * cfX, 54 * cfY, UI_elements.black_bg_result, "img/btn_ok.png", "img/btn_ok_hovered.png", "img/btn_ok_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            destroyElement( UI_elements.black_bg_result )
        end )

    ShowLastWinFields( result_rate.win_field, result_rate.last_win_fields, UI_elements.black_bg_result )
    UI_elements.info_access:ibData( "alpha", 0 )
end

function ShowLastWinFields( win_field, win_fields, parent )
    ibCreateLabel( 0, 195 * cfX, scX, 0, "Выпал номер:", parent, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 24 * cfY ) ] )

    UI_elements.cur_win_field = ibCreateImage( (scX - 84 * cfX) / 2, 239 * cfX, 84 * cfX, 104 * cfY, "img/" .. COLOR_NAMES[ ROULETTE_FIELDS[ win_field ].type ] .. "_cell.png", parent )
    ibCreateLabel( 0, 0, 84 * cfX, 104 * cfY, ROULETTE_FIELDS[ win_field ].value, UI_elements.cur_win_field, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 46 * cfY ) ] )

    if #win_fields > 0 then
        ibCreateLabel( 0, 380 * cfY, scX, 0, #win_fields == 1 and "Последний выпавший номер:" or "Последние выпавшие номера:", parent, 0xFFA5A4A3, _, _, "center", "top", ibFonts[ "regular_" .. math.ceil( 20 * cfY ) ] )

        local sx = #win_fields * (84 * cfX) + (#win_fields - 1) * (28 * cfY)
        local win_fields_area = ibCreateArea( (scX - sx) / 2, 417 * cfY, sx, 104 * cfY, parent )
        local px = 0
        for i = #win_fields, 1, -1 do
            local container = ibCreateImage( 0, 0, 84 * cfX, 104 * cfY, "img/" .. COLOR_NAMES[ ROULETTE_FIELDS[ win_fields[ i ] ].type ] .. "_cell.png", win_fields_area, 0xFFA5A4A3 ):ibMoveTo( px, _, 500 )
            ibCreateLabel( 0, 0, 84 * cfX, 104 * cfY, ROULETTE_FIELDS[ win_fields[ i ] ].value, container, 0xFFA5A4A3, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 46 * cfY ) ] )
            px = px + 112 * cfX
        end
    end
end

addEvent( "onClientPlayerShowResultRate", true )
addEventHandler( "onClientPlayerShowResultRate", resourceRoot, function( result_rate )
    if result_rate.is_win then
        ShowSuccessRate( result_rate )
    elseif not result_rate.is_win then
        ShowFailRate( result_rate )
    end
end )