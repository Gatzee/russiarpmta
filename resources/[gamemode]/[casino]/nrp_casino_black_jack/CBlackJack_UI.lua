
UI_elements = nil
scX, scY = guiGetScreenSize()
cfX, cfY = scX / 1920, scY / 1080
cfX = cfX + math.abs( cfX - cfY )

local player_positions = 
{
    { px = cfX * 766, py = cfY * 232 },
    { px = cfX * 590, py = cfY * 437 },
    { px = cfX * 242, py = cfY * 437 },
    { px = cfX * 40,  py = cfY * 232 },
}

function CreateBlackJackUI()
    DestroyBlackJackUI()
    UI_elements = {
        dealer_cards = {},
        player_bg = {},
        player_names = {},
        player_cards = {},
        player_cards_summ = {},
        player_rates = {},
    }

    UI_elements.bg_top = ibCreateImage( cfX * 20, scY - cfY * 324, cfX * 255, cfY * 304, "img/bg_top.png" )
    
    UI_elements.key_action_close = ibAddKeyAction( _, _, UI_elements.bg_top, function()
        OnTryLeftGame()
    end )

    UI_elements.help_cur_lbl = ibCreateLabel( cfX * 305, scY - cfY * 181, 0, 0, "сделанная ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.cur_lbl = ibCreateLabel( cfX * 305, scY - cfY * 165, 0, 0, "0", false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.cur_soft_img = ibCreateImage( cfX * 311 + dxGetTextWidth( "0", 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), scY - 160 * cfY, 23 * cfX, 20 * cfY, "img/soft.png" )
    
    UI_elements.line_rate = ibCreateImage( 305 * cfX, scY - 128 * cfY, 104 * cfX, 1, _, _, 0x16FFFFFF )

    local min_price = format_price( MIN_RATES[ BLACK_JACK_DATA.casino_id ] )
    UI_elements.help_min_lbl = ibCreateLabel( cfX * 305, scY - 118 * cfY, 0, 0, "мин.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.min_lbl = ibCreateLabel( cfX * 305, scY - 105 * cfY, 0, 0, min_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.min_soft_img = ibCreateImage( cfX * 311 + dxGetTextWidth( min_price, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), scY - 101 * cfY, 23 * cfX, 20 * cfY, "img/soft.png" )
    
    local max_price = format_price( MAX_RATES[ BLACK_JACK_DATA.casino_id ] )
    UI_elements.help_max_lbl = ibCreateLabel( cfX * 305, scY - 78 * cfY, 0, 0, "макс.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.max_lbl = ibCreateLabel( cfX * 305, scY - 65 * cfY, 0, 0, max_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.max_soft_img = ibCreateImage( cfX * 311 + dxGetTextWidth( max_price, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ), scY - 61 * cfY, 23 * cfX, 20 * cfY, "img/soft.png" )

    UI_elements.bg_table = ibCreateImage( 0, 0, cfX * 1024, cfY * 523, "img/bg_table.png" )
    :center()

    UI_elements.rate_size = ibCreateImage( scX - 276 * cfX, scY - 203 * cfY, 256 * cfX, 103 * cfY, "img/bg_reward_info.png" )
    UI_elements.btn_help = ibCreateButton( scX - cfX * 276, scY - cfY * 80, cfX * 176, cfY * 60, nil, "img/btn_help.png", "img/btn_help_hovered.png", "img/btn_help_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "down" or isElement( UI_elements.bg_help ) then return end
        ibClick()

        UI_elements.bg_help = ibCreateImage( 0, 0, cfX * 1024, cfY * 769, "img/bg_help.png", UI_elements.black_bg )
        :center_x()
        :ibData( "alpha", 0 )
        :ibMoveTo( _, (scY - cfX * 769) / 2 , 500 )
        :ibAlphaTo( 255, 400 )

        ibCreateButton(	cfX * 970, cfY * 32, cfX * 22, cfY * 22, UI_elements.bg_help, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            destroyElement( UI_elements.bg_help )
        end )
     end )
     
     UI_elements.btn_exit = ibCreateButton( scX - 80 * cfX, scY - 80 * cfY, 60 * cfX, 60 * cfY, nil, "img/btn_exit.png", "img/btn_exit_hovered.png", "img/btn_exit_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "down" then return end
        ibClick()
        OnTryLeftGame()
    end )

    RefreshTable()
    RefreshTopUI()

    showCursor( true )
end

function RefreshTable()
    DestroyTableElements( UI_elements.player_cards )
    DestroyTableElements( UI_elements.dealer_cards )
    UI_elements.player_cards = {}
    
    if not BLACK_JACK_DATA then return end
    
    RefreshDealerCards()
    for k, v in pairs( player_positions ) do
        local position_data = BLACK_JACK_DATA.player_data_cards[ k ]
        if isElement( UI_elements.player_bg[ k ] ) then
            UI_elements.player_names[ k ]:ibData( "text", position_data and position_data.player:GetNickName() or "Место свободно" )
            UI_elements.player_cards_summ[ k ]:ibData( "text", position_data and CalculateCardSumm( position_data.cards ) or "-" )
        else
            UI_elements.player_bg[ k ] = ibCreateImage( v.px - 25 * cfX, v.py, cfX * 240, cfY * 44, "img/bg_stat_player.png", UI_elements.bg_table )
            UI_elements.player_names[ k ] = ibCreateLabel( cfX * 66, 0, cfX * 140, cfY * 40, position_data and position_data.player:GetNickName() or "Место свободно", UI_elements.player_bg[ k ], 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
            UI_elements.player_cards_summ[ k ] = ibCreateLabel( cfX * 207, 0, cfX * 30, cfY * 41, position_data and CalculateCardSumm( position_data.cards ) or "-", UI_elements.player_bg[ k ], 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 14 * cfY ) ] )
        end

        if position_data then
            UI_elements.player_cards[ k ] = {}
            local px, py = v.px, v.py - cfY * 140
            for _, card in pairs( position_data.cards ) do
                UI_elements.player_cards[ k ][ card ] = ibCreateImage( px, py, cfX * 87, cfY * 131, "img/cards/" .. (card[1] .. "_" .. card[2]) ..  ".png", UI_elements.bg_table )
                px = px + cfX * 35
            end
            if position_data.rate and position_data.rate > 0 then
                RefreshPlayerRate( k, position_data.rate )
            end
        end

        if not position_data then
            UI_elements.player_bg[ k ]:ibData( "color", 0xFFCCCCCC )
            UI_elements.player_names[ k ]:ibData( "color", 0xFFCCCCCC )
            UI_elements.player_cards_summ[ k ]:ibData( "color", 0xFFCCCCCC )
        end
    end
end

function RefreshDealerCards()
    if isElement( UI_elements.dealer_bg ) then
        UI_elements.dealer_card_summ:ibData( "text", CalculateCardSumm( BLACK_JACK_DATA.dealer_cards ) )
    else
        UI_elements.dealer_bg = ibCreateImage( cfX * 417, cfY * 161, cfX * 145, cfY * 42, "img/bg_stat_dealer.png", UI_elements.bg_table )
        UI_elements.dealer_card_summ = ibCreateLabel( cfX * 113, 0, cfX * 30, cfY * 40, CalculateCardSumm( BLACK_JACK_DATA.dealer_cards ), UI_elements.dealer_bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 14 * cfY ) ] )
        UI_elements.deck_of_cards = ibCreateImage( cfX * 574, cfY * 40, cfX * 86, cfY * 114, "img/cards/deck_of_cards.png", UI_elements.bg_table )
        :ibData( "priority", -5 )
    end

    local count_cards = 0
    local px, py = cfX * 417, cfY * 25
    for k, v in pairs( BLACK_JACK_DATA.dealer_cards ) do
        local card_texture_name = v[ 1 ] ~= -1 and (v[ 1 ] .. "_" .. v[ 2 ]) or "cardback"
        if isElement( UI_elements.dealer_cards[ k ] ) then
            UI_elements.dealer_cards[ k ]:ibData( "texture", "img/cards/" .. card_texture_name ..  ".png" )
        else
            UI_elements.dealer_cards[ k ] = ibCreateImage( cfX * 574, cfY * 40, cfX * 87, cfY * 131, "img/cards/cardback.png", UI_elements.bg_table )
            UI_elements.dealer_cards[ k ]:ibData( "px_v", px )
            UI_elements.dealer_cards[ k ]:ibData( "py_v", py )
            UI_elements.dealer_cards[ k ]:ibData( "texture_v", card_texture_name )
            UI_elements.dealer_cards[ k ]
            :ibTimer( function()
                UI_elements.dealer_cards[ k ]:ibMoveTo( UI_elements.dealer_cards[ k ]:ibData( "px_v" ), UI_elements.dealer_cards[ k ]:ibData( "py_v" ), 350 )
                :ibTimer( function()
                    UI_elements.dealer_cards[ k ]
                    :ibData( "texture", "img/cards/" .. (UI_elements.dealer_cards[ k ]:ibData( "texture_v" )) ..  ".png" )
                    soundCard()
                end, 400, 1 )

            end, 50 + 400 * count_cards, 1 )
            count_cards = count_cards + 1
        end
        px = px + cfX * 45
    end
    soundCard()
end

function ShowCardActionMenu( data )
    if isElement( UI_elements.bg_action_area ) then
        destroyElement( UI_elements.bg_action_area )
    end

    UI_elements.bg_action_area = ibCreateArea( 0, scY - cfY * 227, cfX * 464, cfY * 227 )
    :center_x()
    :ibData( "priority", -1 )

    ibCreateImage( cfX * 8, 0, cfX * 20, cfY * 22, "img/timer_icon.png", UI_elements.bg_action_area )
    UI_elements.bg_progress_bar = ibCreateImage( cfX * 44, cfY * 5, cfX * 408, cfY * 16, "img/bg_progress_bar.png", UI_elements.bg_action_area )
    UI_elements.progress_bar = ibCreateImage( 0, 0, 0, cfY * 16, _, UI_elements.bg_progress_bar, 0xFFFFDE96 )

    UI_elements.size_x   = cfX * 408
    UI_elements.dur_time = DURATION_ACTION[ data.type ] * 1000
    UI_elements.start_sx = (UI_elements.dur_time - data.remaining_time) / UI_elements.dur_time  * UI_elements.size_x
    UI_elements.size_x   = UI_elements.size_x - UI_elements.start_sx 

    UI_elements.progress_bar
    :ibInterpolate( function( self )
        if not isElement( self.element ) then return end
        self.element:ibData( "sx", UI_elements.start_sx + UI_elements.size_x * self.progress )
        if self.progress >= 1 then
            DestroyActionMenu()
        end
    end, data.remaining_time, "Linear" )
    
    local bg_actions = ibCreateImage( 0, cfY * 111, cfX * 494, cfY * 32, "img/bg_actions.png", UI_elements.bg_action_area )
    ibCreateButton( cfX * 161 - cfX * 20, cfY * -38, 99 * cfX, 99 * cfY, bg_actions, "img/btn_take.png", "img/btn_take_hovered.png", "img/btn_take_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "down" then return end
        OnTryActionCard( BLACK_JACK_ACTION_CARD_TAKE )
    end )
    ibCreateLabel( cfX * 161 - cfX * 20, cfY * 168, 99 * cfX, 0, "Взять карту", UI_elements.bg_action_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "regular_" .. math.ceil( 16 * cfY ) ] )
    
    ibCreateButton( cfX * 296 - cfX * 20, cfY * -38, 99 * cfX, 99 * cfY, bg_actions, "img/btn_pass.png", "img/btn_pass_hovered.png", "img/btn_pass_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
    :ibOnClick( function( button, state )
        if button ~= "left" or state ~= "down" then return end
        OnTryActionCard( BLACK_JACK_ACTION_CARD_PASS )
        DestroyActionMenu()
    end )
    ibCreateLabel( cfX * 296 - cfX * 20, cfY * 168, 99 * cfX, 0, "Оставить", UI_elements.bg_action_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "regular_" .. math.ceil( 16 * cfY ) ] )
    ibCreateImage( 0, cfY * 15, cfX * 265, cfY * 93, "img/text_decide.png", UI_elements.bg_action_area )
    :center_x( 10 )

    soundCard()
end

function ShowRateMenu( data )
    if isElement( UI_elements.bg_action_area ) then
        destroyElement( UI_elements.bg_action_area )
    end

    UI_elements.bg_action_area = ibCreateArea( 0, scY - cfY * 227, cfX * 464, cfY * 227 )
    :center_x()
    :ibData( "priority", -1 )

    ibCreateImage( cfX * 8, 0, cfX * 20, cfY * 22, "img/timer_icon.png", UI_elements.bg_action_area )
    UI_elements.bg_progress_bar = ibCreateImage( cfX * 44, cfY * 5, cfX * 408, cfY * 16, "img/bg_progress_bar.png", UI_elements.bg_action_area )
    UI_elements.progress_bar = ibCreateImage( 0, 0, 0, cfY * 16, _, UI_elements.bg_progress_bar, 0xFFFFDE96 )
    
    UI_elements.size_x   = cfX * 408
    UI_elements.dur_time = DURATION_ACTION[ data.type ] * 1000
    UI_elements.start_sx = (UI_elements.dur_time - data.remaining_time) / UI_elements.dur_time  * UI_elements.size_x
    UI_elements.size_x   = UI_elements.size_x - UI_elements.start_sx

    UI_elements.progress_bar
    :ibInterpolate( function( self )
        if not isElement( self.element ) then return end
        self.element:ibData( "sx", UI_elements.start_sx + UI_elements.size_x * self.progress )
        if self.progress >= 1 then
            DestroyActionMenu()
        end
    end, data.remaining_time, "Linear" )

    RefreshCurrentChipRates()
    ibCreateImage( 0, cfY * 15, cfX * 265, cfY * 93, "img/text_rate.png", UI_elements.bg_action_area )
    :center_x( 10 )
end

function RefreshCurrentChipRates()
    DestroyTableElements( UI_elements.chips )

    local active_chip_font = ibFonts[ "bold_" .. math.ceil( 13 * cfY ) ]
    local passive_chip_font = ibFonts[ "bold_" .. math.ceil( 12 * cfY ) ]

    local px = 0
    UI_elements.chips = {}
    for k, v in ipairs( RATES_VALUES[ BLACK_JACK_DATA.casino_id ] ) do
        if not isElement( UI_elements.chips[ k ] ) then
            UI_elements.chips[ k ] = ibCreateImage( cfX * px, cfY * 119, cfX * 60, cfY * 59, "img/chips/chip_" .. k .. ".png", UI_elements.bg_action_area )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    OnTryAddRate( k )
                end )
                :ibOnHover( function( )
                    local px, py = UI_elements.chips[ k ]:ibData( "px" ), UI_elements.chips[ k ]:ibData( "py" )
                    local sx, sy = cfX * 70, cfY * 69
                    UI_elements.chips[ k ]:ibBatchData( { px = px - 5 * cfX, py = py - 5 * cfY, sx = sx, sy = sy } )
                    UI_elements.chips[ k .. "lbl" ]:ibBatchData( { sx = sx, sy = sy, font = active_chip_font } )
                end )
                :ibOnLeave( function( )
                    local px, py = UI_elements.chips[ k ]:ibData( "px" ), UI_elements.chips[ k ]:ibData( "py" )
                    local sx, sy = cfX * 60, cfY * 59
                    UI_elements.chips[ k ]:ibBatchData( { px = px + 5 * cfX, py = py + 5 * cfY, sx = sx, sy = sy } )
                    UI_elements.chips[ k .. "lbl" ]:ibBatchData( { sx = sx, sy = sy, font = passive_chip_font } )
                end )

            UI_elements.chips[ k .. "lbl" ] = ibCreateLabel( 0, 0, 60 * cfX, 59 * cfX, BLACK_JACK_DATA.casino_id == CASINO_MOSCOW and (v / 1000 .. "K") or v, UI_elements.chips[ k ], 0xFFFFFFFF, _, _, "center", "center", passive_chip_font )
            :ibData( "disabled", true )

            UI_elements.chips[ k .. "_count" ] = ibCreateLabel( cfX * px, cfY * 119 - cfY * 36, cfX * 60, 0, "", UI_elements.bg_action_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 13 * cfY ) ] )
            UI_elements.chips[ k .. "_remove" ] = ibCreateImage( cfX * px, cfY * 119, cfX * 60, cfY * 59, "img/chips/chip_" .. k .. ".png", UI_elements.bg_action_area )
            ibCreateImage( cfX * 26, cfY * 51, cfX * 8, cfY * 8, "img/btn_close.png", UI_elements.chips[ k .. "_remove" ] )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    OnTryRemoveRate( k )
                end )
        else
            UI_elements.chips[ k ]:ibBatchData({ px = cfX * px, py = cfY * 119 })
        end
        UI_elements.chips[ k .. "_remove" ]:ibBatchData( { color = 0x00000000, disabled = true, priority = -1 } )
        UI_elements.chips[ k .. "_count" ]:ibData( "text", "" )

        px = px + 81
    end
end

function OnAddRemoveRateRefreshChipsUI()
    local chips_count = {}
    for k, v in pairs( BLACK_JACK_DATA.rates ) do
        chips_count[ v ] = (chips_count[ v ] or 0) + 1
    end
    
    for k, v in ipairs( RATES_VALUES[ BLACK_JACK_DATA.casino_id ] ) do
        if chips_count[ k ] and chips_count[ k ] > 0 then
            UI_elements.chips[ k .. "_count" ]:ibData( "text", "x" .. chips_count[ k ] )
            UI_elements.chips[ k ]:ibBatchData( { py =  cfY * 90 } )
            UI_elements.chips[ k .. "_remove" ]:ibBatchData( { color = 0xFF474747, disabled = false } )
        else
            UI_elements.chips[ k ]:ibBatchData( { py = cfY * 119 } )
            UI_elements.chips[ k .. "_remove" ]:ibBatchData( { color = 0x00000000, disabled = true } )
            UI_elements.chips[ k .. "_count" ]:ibData( "text", "" )
        end
    end
end

function DestroyActionMenu()
    if isElement( UI_elements.bg_action_area ) then
        UI_elements.bg_action_area:ibAlphaTo( 0, 200 )
        UI_elements.bg_action_area:ibTimer( function()
            if isElement( UI_elements.bg_action_area ) then
                destroyElement( UI_elements.bg_action_area )
                UI_elements.chips = nil
            end
        end, 255, 1 )
        BLACK_JACK_DATA.current_state = -1
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
        ibCreateLabel( 0, 0, 40 * cfX, 50 * cfY, BLACK_JACK_DATA.top_list[ i ] and i or "-", UI_elements.top_elements[ i ], 0xFFFF965D, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 24 * cfY ) ] )
        ibCreateLabel( 82 * cfX, 6 * cfY, 0, 0, BLACK_JACK_DATA.top_list[ i ] and BLACK_JACK_DATA.top_list[ i ].nickname or "", UI_elements.top_elements[ i ], 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
        ibCreateLabel( 165 * cfX, 23 * cfY, 0, 0, BLACK_JACK_DATA.top_list[ i ] and format_price( BLACK_JACK_DATA.top_list[ i ].total_win ) or "", UI_elements.top_elements[ i ], 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 14 * cfY ) ] )
        py = py + 51 * cfY
    end
end

function DestroyBlackJackUI()
    if UI_elements then
        DestroyTableElements( UI_elements )
        UI_elements = nil
    end
    showCursor( false )
end

function RefreshPlayerRate( place_id, rate )
    if not isElement( UI_elements.player_rates[ place_id ] ) then
        local position = player_positions[ place_id ]
        UI_elements.player_rates[ place_id ] = ibCreateImage( position.px + cfX * 40, position.py + cfY * 17, cfX * 145, cfY * 24, "img/bg_rate_player.png", UI_elements.bg_table )
        UI_elements.player_rates[ place_id .. "_l" ] = ibCreateLabel( 0, 0, cfX * 135, cfY * 24, format_price( rate ), UI_elements.player_rates[ place_id ], 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 14 * cfY ) ] )
        UI_elements.player_rates[ place_id .. "_i" ] = ibCreateImage( UI_elements.player_rates[ place_id .. "_l" ]:ibGetAfterX( cfX * 70 ), cfY * 4, cfX * 17, cfY * 15, "img/soft_small.png", UI_elements.player_rates[ place_id ] )

        UI_elements.player_rates[ place_id ]:ibData( "priority", -20 )
        UI_elements.player_rates[ place_id ]:ibMoveTo( _, position.py + cfY * 44, 500 )
    else
        if rate == 0 then
            destroyElement( UI_elements.player_rates[ place_id ] )
            return
        end

        UI_elements.player_rates[ place_id .. "_l" ]:ibData( "text", format_price( rate ) )
        UI_elements.player_rates[ place_id .. "_i" ]:ibData( "px", UI_elements.player_rates[ place_id .. "_l" ]:ibGetAfterX( cfX * 77 ) )
    end
end

function OnPlayerTakeCard( place_id )
    local player_cards = BLACK_JACK_DATA.player_data_cards[ place_id ].cards
    local card_num = #player_cards
    local card_data = player_cards[ card_num ]
    local position = player_positions[ place_id ]

    UI_elements.player_cards[ place_id ][ card_num ] = ibCreateImage( cfX * 574, cfY * 40, cfX * 87, cfY * 131, "img/cards/cardback.png", UI_elements.bg_table )
    :ibMoveTo( position.px + ( card_num - 1 ) * (cfX * 35), position.py - cfY * 140, 350 )
    UI_elements.player_cards_summ[ place_id ]:ibData( "text", CalculateCardSumm( player_cards ) )
    
    UI_elements.player_cards[ place_id ][ card_num ]
    :ibTimer( function()
        UI_elements.player_cards[ place_id ][ card_num ]
        :ibData( "texture", "img/cards/" .. (card_data[1] .. "_" .. card_data[2]) ..  ".png" )
        soundCard()
    end, 400, 1 )
end

function OnPlayerJoinGame( place_id )
    local player_data = BLACK_JACK_DATA.player_data_cards[ place_id ]
    UI_elements.player_names[ place_id ]:ibData( "text", player_data.player:GetNickName() )
    UI_elements.player_cards_summ[ place_id ]:ibData( "text", CalculateCardSumm( player_data.cards  ) )

    UI_elements.player_cards[ place_id ] = {}
    local position = player_positions[ place_id ]
    local px, py = position.px, position.py - cfY * 140
    for _, card in pairs( player_data.cards  ) do
        UI_elements.player_cards[ place_id ][ card ] = ibCreateImage( px, py, cfX * 87, cfY * 131, "img/cards/" .. (card[1] .. "_" .. card[2]) ..  ".png", UI_elements.bg_table )
        px = px + cfX * 35
    end

    UI_elements.player_bg[ place_id ]:ibData( "color", 0xFFFFFFFF )
    UI_elements.player_names[ place_id ]:ibData( "color", 0xFFFFFFFF )
    UI_elements.player_cards_summ[ place_id ]:ibData( "color", 0xFFFFFFFF )
end

function OnPlayerLeaveGame( place_id )
    if isElement( UI_elements.player_rates[ place_id ]  ) then
        destroyElement( UI_elements.player_rates[ place_id ]  )
    end

    DestroyTableElements( UI_elements.player_cards[ place_id ] )
    UI_elements.player_bg[ place_id ]:ibData( "texture", "img/bg_stat_player.png" )
    UI_elements.player_names[ place_id ]:ibData( "text", "Место свободно" )
    UI_elements.player_cards_summ[ place_id ]:ibData( "text", "-" )

    UI_elements.player_bg[ place_id ]:ibData( "color", 0xFFCCCCCC )
    UI_elements.player_names[ place_id ]:ibData( "color", 0xFFCCCCCC )
    UI_elements.player_cards_summ[ place_id ]:ibData( "color", 0xFFCCCCCC )
end

function OnStartNewRound()
    DestroyTableElements( UI_elements.player_rates )
    RefreshTable()
    RefreshTopUI()
    ChangeCurrentSummUI( 0 )
    SetCurrentActivePlayer()
end

function SetCurrentActivePlayer( place_id )
    for k, v in pairs( UI_elements.player_bg ) do
        if k == place_id then
            UI_elements.player_bg[ k ]:ibBatchData({ texture = "img/bg_stat_player_active.png", priority = 2 })
            UI_elements.player_rates[ k ]:ibBatchData({ texture = "img/bg_rate_player_active.png", priority = 3 })
        else
            UI_elements.player_bg[ k ]:ibBatchData({ texture = "img/bg_stat_player.png", priority = 2 })
            if isElement( UI_elements.player_rates[ k ] ) then
                UI_elements.player_rates[ k ]:ibBatchData({ texture = "img/bg_rate_player.png", priority = 3 })
            end
        end
    end
end

function ChangeCurrentSummUI( summ )
    local text_summ = format_price( summ ) 
    UI_elements.cur_lbl:ibData( "text", text_summ )
    UI_elements.cur_soft_img:ibData( "px", cfX * 311 + dxGetTextWidth( text_summ, 1, ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] ) )
end