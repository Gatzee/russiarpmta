
local UI_elements = nil
local cfX, cfY = _SCREEN_X / 1920 * 1.1, _SCREEN_Y / 1080 * 1.1
local BACKGROUND_SOUND = nil

local player_positions = 
{
    { px = cfX * 766, py = cfY * 232 },
    { px = cfX * 590, py = cfY * 437 },
    { px = cfX * 242, py = cfY * 437 },
    { px = cfX * 40,  py = cfY * 232 },
}

-- CONFIG
local CAMERA_POSITION = { 2441.7714, -1314.6571, 2800.9121, 2436.5829, -1220.3734, 2767.6652, 0, 70 }

enum "eBlackJackGameState" {
    "BLACK_JACK_STATE_RATE",
    "BLACK_JACK_STATE_ACTION_CARD",
}

local DURATION_ACTION = 
{
    [ BLACK_JACK_STATE_RATE ] = 12,
    [ BLACK_JACK_STATE_ACTION_CARD ] = 10,
}

local BLACK_JACK_STATE_WAIT = 5

enum "eBlackJackCardActions" {
    "BLACK_JACK_ACTION_CARD_TAKE",
    "BLACK_JACK_ACTION_CARD_PASS",
}

enum "eBlackJackGameResult" {
    "BLACK_JACK_RESULT_WIN",
    "BLACK_JACK_RESULT_LOSE",
    "BLACK_JACK_RESULT_DRAW",
    "BLACK_JACK_RESULT_AFK",
}

local TIMEOUT_TIME = 200
local MAX_AFK_ROUNDS = 6


local MIN_RATE = 5000
local MAX_RATE = 150000

enum "eBlackJackRates" {
    "BLACK_JACK_RATE_1",
    "BLACK_JACK_RATE_2",
    "BLACK_JACK_RATE_3",
    "BLACK_JACK_RATE_4",
    "BLACK_JACK_RATE_5",
    "BLACK_JACK_RATE_6",
}

local RATES_VALUES =
{
    [ BLACK_JACK_RATE_1 ] = 5000,
    [ BLACK_JACK_RATE_2 ] = 10000,
    [ BLACK_JACK_RATE_3 ] = 20000,
    [ BLACK_JACK_RATE_4 ] = 30000,
    [ BLACK_JACK_RATE_5 ] = 40000,
    [ BLACK_JACK_RATE_6 ] = 50000,
}

enum "eCardsSuits" {
    "CARD_SUIT_SPADE",
    "CARD_SUIT_HEART",
    "CARD_SUIT_DIAMOND",
    "CARD_SUIT_CLUB",
}

local CARD_NAMES = 
{
    [ CARD_SUIT_SPADE ]   = "Пики",
    [ CARD_SUIT_HEART ]   = "Черви",
    [ CARD_SUIT_DIAMOND ] = "Бубны",
    [ CARD_SUIT_CLUB ]    = "Трефы",
}

local MAX_WIN_CARD_SUMM = 21

local CARDS_DATA =
{
    [ -1 ] = { name = "back",   weight = 0   },
    [ 2 ]  = { name = "2",      weight = 2,  },
    [ 3 ]  = { name = "3",      weight = 3,  },
    [ 4 ]  = { name = "4",      weight = 4,  },
    [ 5 ]  = { name = "5",      weight = 5,  },
    [ 6 ]  = { name = "6",      weight = 6,  },
    [ 7 ]  = { name = "7",      weight = 7,  },
    [ 8 ]  = { name = "8",      weight = 8,  },
    [ 9 ]  = { name = "9",      weight = 9,  },
    [ 10 ] = { name = "10",     weight = 10, },
    [ 11 ] = { name = "Валет",  weight = 10, },
    [ 12 ] = { name = "Дама",   weight = 10, },
    [ 13 ] = { name = "Король", weight = 10, },
    [ 14 ] = { name = "Туз",    weight = 11, },
}

--------------------------------------------------------
-- Utils
--------------------------------------------------------

local blocked_controls = { "forwards", "backwards", "right", "left", "jump", "fire", "crouch", }
local locked_keys = { [ "tab" ] = true,[ "q" ]   = true, }

function DisableControls()
    for k,v in pairs( blocked_controls ) do
		toggleControl( v, false )
	end

    addEventHandler( "onClientKey", root, OnClientKey_handler )
end

function EnableControls()
    for k,v in pairs( blocked_controls ) do
		toggleControl( v, true )
    end
    
    removeEventHandler( "onClientKey", root, OnClientKey_handler )
end

function soundChip()
	local sound = playSound( ":nrp_casino_black_jack/sfx/chip_sound.ogg" )
    sound.volume = 0.5
end

function soundCard()
	local sound = playSound( ":nrp_casino_black_jack/sfx/card_sound.mp3" )
    sound.volume = 0.5
end

function OnClientKey_handler( key, state )
	if locked_keys[ key ] then 
		cancelEvent()
		return
	end
    
	if key == "space" and isElement( UI_elements and UI_elements.black_bg_result ) then
		destroyElement( UI_elements.black_bg_result )
	end
end

function CalculateCardSumm( cards )
    local summ = 0
    
    local aces = {}
    for k, v in pairs( cards ) do
        if CARDS_DATA[ v[ 1 ] ].weight == 11 then
            table.insert( aces, v[ 1 ] )
        else
            summ = summ + CARDS_DATA[ v[ 1 ] ].weight
        end
    end

    for k, v in pairs( aces ) do
        if summ + CARDS_DATA[ v ].weight <= MAX_WIN_CARD_SUMM then
            summ = summ + CARDS_DATA[ v ].weight
        else
            summ = summ + 1
        end
    end

    return summ
end

--------------------------------------------------------
-- Entry point
--------------------------------------------------------

local GAME_CALLBACK

function CreateBlackJackGame( callback )
    GAME_CALLBACK = callback
    BLACK_JACK_DATA = { iter_count = 1 }

    DisableControls()
    setCameraMatrix( unpack( CAMERA_POSITION ) )
    fadeCamera( true, 0.5 )

    StartNewRoundGame()
    CreateBlackJackUI()
    
    BACKGROUND_SOUND = playSound( ":nrp_casino_black_jack/sfx/bg_game.ogg", true )
    BACKGROUND_SOUND.volume = 0.35
    
    localPlayer:setData( "hide_wanted", true, false )
    triggerEvent( "onClientSetChatState", root, true )
    removeWorldModel( 19468, 200, -87, -470, 914, localPlayer.interior )

    ShowRateMenu( { type = BLACK_JACK_DATA.current_state, remaining_time = BLACK_JACK_DATA.remaining_time } )
end

function DestroyBlackJackGame( success )   
    localPlayer:setData( "hide_wanted", false, false )
    if isElement( BACKGROUND_SOUND ) then
        destroyElement( BACKGROUND_SOUND )
        BACKGROUND_SOUND = nil
    end

    EnableControls()
    DestroyBlackJackUI()
    
    DestroyTableElements( BLACK_JACK_DATA )
    BLACK_JACK_DATA = nil
    
    if GAME_CALLBACK then
        fadeCamera( false, 0.5 )
        setTimer(function()
            if success then GAME_CALLBACK() end
            GAME_CALLBACK = nil

            setCameraTarget( localPlayer )
            fadeCamera( true, 0.5 )
        end, 500, 1)
    end

    restoreWorldModel( 19468, 200, -87, -470, 914, localPlayer.interior )
end

--------------------------------------------------------
-- UI
--------------------------------------------------------

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

    UI_elements.help_cur_lbl = ibCreateLabel( cfX * 20, _SCREEN_Y - cfY * 181, 0, 0, "сделанная ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.cur_lbl = ibCreateLabel( cfX * 20, _SCREEN_Y - cfY * 165, 0, 0, "0", false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.cur_soft_img = ibCreateImage( UI_elements.cur_lbl:ibGetAfterX() + 10, _SCREEN_Y - 160 * cfY, 23 * cfX, 20 * cfY, ":nrp_casino_black_jack/img/soft.png" )
    
    UI_elements.line_rate = ibCreateImage( 20 * cfX, _SCREEN_Y - 128 * cfY, 104 * cfX, 1, _, _, 0x16FFFFFF )

    local min_price = format_price( MIN_RATE )
    UI_elements.help_min_lbl = ibCreateLabel( cfX * 20, _SCREEN_Y - 118 * cfY, 0, 0, "мин.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.min_lbl = ibCreateLabel( cfX * 20, _SCREEN_Y - 103 * cfY, 0, 0, min_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.min_soft_img = ibCreateImage( UI_elements.min_lbl:ibGetAfterX() + 10, _SCREEN_Y - 99 * cfY, 23 * cfX, 20 * cfY, ":nrp_casino_black_jack/img/soft.png" )
    
    local max_price = format_price( MAX_RATE )
    UI_elements.help_max_lbl = ibCreateLabel( cfX * 20, _SCREEN_Y - 78 * cfY, 0, 0, "макс.ставка:", false, 0xFF8A8C8F, _, _, "left", "top", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
    UI_elements.max_lbl = ibCreateLabel( cfX * 20, _SCREEN_Y - 63 * cfY, 0, 0, max_price, false, 0xFFFFFFFF, _, _, "left", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    UI_elements.max_soft_img = ibCreateImage( UI_elements.max_lbl:ibGetAfterX() + 10, _SCREEN_Y - 59 * cfY, 23 * cfX, 20 * cfY, ":nrp_casino_black_jack/img/soft.png" )

    UI_elements.bg_table = ibCreateImage( 0, 0, cfX * 1024, cfY * 523, ":nrp_casino_black_jack/img/bg_table.png" ):center()

    UI_elements.rate_size = ibCreateImage( _SCREEN_X - 276 * cfX, _SCREEN_Y - 203 * cfY, 256 * cfX, 103 * cfY, ":nrp_casino_black_jack/img/bg_reward_info.png" )
    UI_elements.btn_help = ibCreateButton( _SCREEN_X - cfX * 232, _SCREEN_Y - cfY * 80, cfX * 176, cfY * 60, nil, ":nrp_casino_black_jack/img/btn_help.png", ":nrp_casino_black_jack/img/btn_help_hovered.png", ":nrp_casino_black_jack/img/btn_help_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" or isElement( UI_elements.bg_help ) then return end
            ibClick()
            ibOverlaySound()

            UI_elements.bg_help = ibCreateImage( 0, 0, cfX * 1024, cfY * 769, ":nrp_casino_black_jack/img/bg_help.png", UI_elements.black_bg ):center_x():ibData( "alpha", 0 ):ibMoveTo( _, (_SCREEN_Y - cfX * 769) / 2 , 500 ):ibAlphaTo( 255, 400 )

            ibCreateButton(	cfX * 970, cfY * 32, cfX * 22, cfY * 22, UI_elements.bg_help, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    ibClick()
                    ibOverlaySound()
                    destroyElement( UI_elements.bg_help )
                end )
         end )
     
    RefreshTable()

    showCursor( true )
end

function DestroyBlackJackUI()
    DestroyTableElements( UI_elements )
    UI_elements = nil
    showCursor( false )
end

function StartNewRoundGame( is_show_rate_menu )
    BLACK_JACK_DATA.current_state = BLACK_JACK_STATE_RATE
    BLACK_JACK_DATA.rates = {}
    BLACK_JACK_DATA.summ_rate = 0
    BLACK_JACK_DATA.player_data_cards = { { nickname = "Анжела", cards = {}, }, { nickname = localPlayer:GetNickName(), cards = {}, } }
    BLACK_JACK_DATA.remaining_time = DURATION_ACTION[ BLACK_JACK_STATE_RATE ] * 1000
    BLACK_JACK_DATA.used_cards = {}
    BLACK_JACK_DATA.dealer_cards = {}
    
    if is_show_rate_menu then
        DestroyTableElements( UI_elements.player_rates )
        RefreshTable()
        ChangeCurrentSummUI( 0 )
        SetCurrentActivePlayer()

        ShowRateMenu( { type = BLACK_JACK_DATA.current_state, remaining_time = BLACK_JACK_DATA.remaining_time } )
    end
end

function GenerateDealerCards( remove_dummy )
    local card_id, card_suit = nil, nil
    if remove_dummy then
        table.remove( BLACK_JACK_DATA.dealer_cards, 1 )
        card_id, card_suit = 14, 3
        table.insert( BLACK_JACK_DATA.dealer_cards, 1, { card_id, card_suit } )
    else
        card_id, card_suit = math.random( 10, 13 ), 2
        BLACK_JACK_DATA.dealer_cards = { { -1, 0 }, { card_id, card_suit } }
    end
    BLACK_JACK_DATA.used_cards[ card_id .. card_suit ] = true
end

function GeneratePlayersCards()
    local players_cards = {}
    local variants = { 
        { 
            [ 1 ] = {  { 11, 1 }, { 9, 1 } },
            [ 2 ] = {  { 11, 3 }, { 14, 2 } },
        },
        { 
            [ 1 ] = {  { 8, 2 }, { 7, 3 } },
            [ 2 ] = {  { 14, 1 }, { 10, 4 } },
        },
    }
    local variant = math.random(1, #variants)
    for i = 1, 2 do
        if i == 1 or BLACK_JACK_DATA.summ_rate > 0 then
            BLACK_JACK_DATA.player_data_cards[ i ].cards = variants[ variant ][ i ]
        end
    end
end

function ShowRateMenu( data )
    if isElement( UI_elements.bg_action_area ) then
        destroyElement( UI_elements.bg_action_area )
    end

    UI_elements.bg_action_area = ibCreateArea( 0, _SCREEN_Y - cfY * 227, cfX * 464, cfY * 227 ):center_x():ibData( "priority", -1 )

    ibCreateImage( cfX * 8, 0, cfX * 20, cfY * 22, ":nrp_casino_black_jack/img/timer_icon.png", UI_elements.bg_action_area )
    UI_elements.bg_progress_bar = ibCreateImage( cfX * 44, cfY * 5, cfX * 408, cfY * 16, ":nrp_casino_black_jack/img/bg_progress_bar.png", UI_elements.bg_action_area )
    UI_elements.progress_bar = ibCreateImage( 0, 0, 0, cfY * 16, _, UI_elements.bg_progress_bar, 0xFFFFDE96 )
    
    UI_elements.size_x   = cfX * 408
    UI_elements.dur_time = DURATION_ACTION[ data.type ] * 1000
    UI_elements.start_sx = (UI_elements.dur_time - data.remaining_time) / UI_elements.dur_time  * UI_elements.size_x
    UI_elements.size_x   = UI_elements.size_x - UI_elements.start_sx

    UI_elements.progress_bar:ibInterpolate( function( self )
        if not isElement( self.element ) then return end
        
        self.element:ibData( "sx", UI_elements.start_sx + UI_elements.size_x * self.progress )
        if self.progress >= 1 then
            DestroyActionMenu()
        end
    end, data.remaining_time, "Linear" )

    ibCreateImage( 0, cfY * 15, cfX * 265, cfY * 93, ":nrp_casino_black_jack/img/text_rate.png", UI_elements.bg_action_area ):center_x( 10 )

    UI_elements.angela_rate_tmr = setTimer( RefreshPlayerRate, 3000, 1, 1, MAX_RATE )
    UI_elements.dealer_cards_tmr = setTimer( function()
        BLACK_JACK_DATA.current_state = -1
        GenerateDealerCards()
        GeneratePlayersCards()
        RefreshTable()

        SetCurrentActivePlayer( 1 )
        UI_elements.player_active = setTimer( function()
            local angela_fucking_card = math.random( 1, 2 ) == 1 and true or false
            if angela_fucking_card then
                OnPlayerTakeCard( 1 )
            end

            if BLACK_JACK_DATA.summ_rate > 0 then
                SetCurrentActivePlayer( 2 )
                ShowCardActionMenu()
            else
                ShowResult()
            end
        end, math.random( 2000, 5000 ), 1 )

    end, DURATION_ACTION[ BLACK_JACK_STATE_RATE ] * 1000, 1 )

    RefreshCurrentChipRates()
end

function ShowCardActionMenu()
    if isElement( UI_elements.bg_action_area ) then
        destroyElement( UI_elements.bg_action_area )
    end

    UI_elements.bg_action_area = ibCreateArea( 0, _SCREEN_Y - cfY * 227, cfX * 464, cfY * 227 ):center_x():ibData( "priority", -1 )

    ibCreateImage( cfX * 8, 0, cfX * 20, cfY * 22, ":nrp_casino_black_jack/img/timer_icon.png", UI_elements.bg_action_area )
    UI_elements.bg_progress_bar = ibCreateImage( cfX * 44, cfY * 5, cfX * 408, cfY * 16, ":nrp_casino_black_jack/img/bg_progress_bar.png", UI_elements.bg_action_area )
    UI_elements.progress_bar = ibCreateImage( 0, 0, 0, cfY * 16, _, UI_elements.bg_progress_bar, 0xFFFFDE96 )

    UI_elements.size_x   = cfX * 408
    UI_elements.dur_time = DURATION_ACTION[ BLACK_JACK_STATE_ACTION_CARD ] * 1000
    UI_elements.start_sx = (UI_elements.dur_time - DURATION_ACTION[ BLACK_JACK_STATE_ACTION_CARD ] * 1000) / UI_elements.dur_time  * UI_elements.size_x
    UI_elements.size_x   = UI_elements.size_x - UI_elements.start_sx 

    UI_elements.progress_bar:ibInterpolate( function( self )
        if not isElement( self.element ) then return end
        self.element:ibData( "sx", UI_elements.start_sx + UI_elements.size_x * self.progress )
        if self.progress >= 1 then
            DestroyActionMenu( true )
        end
    end, DURATION_ACTION[ BLACK_JACK_STATE_ACTION_CARD ] * 1000, "Linear" )
    
    local bg_actions = ibCreateImage( 0, cfY * 111, cfX * 494, cfY * 32, ":nrp_casino_black_jack/img/bg_actions.png", UI_elements.bg_action_area )
    ibCreateButton( cfX * 161 - cfX * 20, cfY * -38, 99 * cfX, 99 * cfY, bg_actions, ":nrp_casino_black_jack/img/btn_take.png", ":nrp_casino_black_jack/img/btn_take_hovered.png", ":nrp_casino_black_jack/img/btn_take_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            OnPlayerTakeCard( 2 )
            DestroyActionMenu( true )
        end )
    ibCreateLabel( cfX * 161 - cfX * 20, cfY * 168, 99 * cfX, 0, "Взять карту", UI_elements.bg_action_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "regular_" .. math.ceil( 16 * cfY ) ] )
    
    ibCreateButton( cfX * 296 - cfX * 20, cfY * -38, 99 * cfX, 99 * cfY, bg_actions, ":nrp_casino_black_jack/img/btn_pass.png", ":nrp_casino_black_jack/img/btn_pass_hovered.png", ":nrp_casino_black_jack/img/btn_pass_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            DestroyActionMenu( true )
        end )

    ibCreateLabel( cfX * 296 - cfX * 20, cfY * 168, 99 * cfX, 0, "Оставить", UI_elements.bg_action_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "regular_" .. math.ceil( 16 * cfY ) ] )
    ibCreateImage( 0, cfY * 15, cfX * 265, cfY * 93, ":nrp_casino_black_jack/img/text_decide.png", UI_elements.bg_action_area ):center_x( 10 )

    soundCard()
end

function DestroyActionMenu( is_card_action )
    if not isElement( UI_elements.bg_action_area ) then return end
    
    UI_elements.bg_action_area:ibAlphaTo( 0, 200 )
    UI_elements.bg_action_area:ibTimer( function()
        if isElement( UI_elements.bg_action_area ) then
            destroyElement( UI_elements.bg_action_area )
            UI_elements.chips = nil
        end
    end, 255, 1 )
    
    BLACK_JACK_DATA.current_state = -1
    if is_card_action then
        ShowResult()
    end
end

function RefreshCurrentChipRates()
    DestroyTableElements( UI_elements.chips )

    local active_chip_font = ibFonts[ "bold_" .. math.ceil( 13 * cfY ) ]
    local passive_chip_font = ibFonts[ "bold_" .. math.ceil( 12 * cfY ) ]

    local px = 0
    UI_elements.chips = {}
    for k, v in ipairs( RATES_VALUES ) do
        if not isElement( UI_elements.chips[ k ] ) then
            UI_elements.chips[ k ] = ibCreateImage( cfX * px, cfY * 119, cfX * 60, cfY * 59, ":nrp_casino_black_jack/img/chips/chip_" .. k .. ".png", UI_elements.bg_action_area )
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

            UI_elements.chips[ k .. "lbl" ] = ibCreateLabel( 0, 0, 60 * cfX, 59 * cfX, v / 1000 .. "K", UI_elements.chips[ k ], 0xFFFFFFFF, _, _, "center", "center", passive_chip_font )
            :ibData( "disabled", true )

            UI_elements.chips[ k .. "_count" ] = ibCreateLabel( cfX * px, cfY * 119 - cfY * 36, cfX * 60, 0, "", UI_elements.bg_action_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 13 * cfY ) ] )
            UI_elements.chips[ k .. "_remove" ] = ibCreateImage( cfX * px, cfY * 119, cfX * 60, cfY * 59, ":nrp_casino_black_jack/img/chips/chip_" .. k .. ".png", UI_elements.bg_action_area )
            ibCreateImage( cfX * 26, cfY * 51, cfX * 8, cfY * 8, ":nrp_casino_black_jack/img/btn_close.png", UI_elements.chips[ k .. "_remove" ] )
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
    
    for k, v in ipairs( RATES_VALUES ) do
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

function OnTryAddRate( chip )    
    local cur_sum = BLACK_JACK_DATA.summ_rate + RATES_VALUES[ chip ]
    if cur_sum <= MAX_RATE then
        AddRate( chip )
    else
        localPlayer:ShowError( "Максимальная ставка " .. MAX_RATE .. "р." )
    end
end

function OnTryRemoveRate( chip )
    local chip_exist = false
    for k, v in ipairs( BLACK_JACK_DATA.rates ) do
        if v == chip then
            chip_exist = true
            break
        end
    end

    if chip_exist then
        RemoveRate( chip )
    end
end

function AddRate( chip )
    table.insert( BLACK_JACK_DATA.rates, chip )
    
    BLACK_JACK_DATA.summ_rate = (BLACK_JACK_DATA.summ_rate or 0 ) + RATES_VALUES[ chip ]
    ChangeCurrentSummUI( BLACK_JACK_DATA.summ_rate )
    OnAddRemoveRateRefreshChipsUI()
    RefreshPlayerRate( 2, BLACK_JACK_DATA.summ_rate )
    soundChip()
end

function RemoveRate( chip )
    for k, v in pairs( BLACK_JACK_DATA.rates ) do
        if v == chip then
            table.remove( BLACK_JACK_DATA.rates, k )
            break
        end
    end

    BLACK_JACK_DATA.summ_rate = BLACK_JACK_DATA.summ_rate - RATES_VALUES[ chip ]
    ChangeCurrentSummUI( BLACK_JACK_DATA.summ_rate )
    OnAddRemoveRateRefreshChipsUI()
    RefreshPlayerRate( 2, BLACK_JACK_DATA.summ_rate )
    soundChip()
end

function RefreshPlayerRate( place_id, rate )
    if not isElement( UI_elements.player_rates[ place_id ] ) then
        local position = player_positions[ place_id ]
        UI_elements.player_rates[ place_id ] = ibCreateImage( position.px + cfX * 40, position.py + cfY * 17, cfX * 145, cfY * 24, ":nrp_casino_black_jack/img/bg_rate_player.png", UI_elements.bg_table )
        UI_elements.player_rates[ place_id .. "_l" ] = ibCreateLabel( 0, 0, cfX * 135, cfY * 24, format_price( rate ), UI_elements.player_rates[ place_id ], 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 14 * cfY ) ] )
        UI_elements.player_rates[ place_id .. "_i" ] = ibCreateImage( UI_elements.player_rates[ place_id .. "_l" ]:ibGetAfterX( cfX * 70 ), cfY * 4, cfX * 17, cfY * 15, ":nrp_casino_black_jack/img/soft_small.png", UI_elements.player_rates[ place_id ] )

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

function ChangeCurrentSummUI( summ )
    local text_summ = format_price( summ ) 
    UI_elements.cur_lbl:ibData( "text", text_summ )
    UI_elements.cur_soft_img:ibData( "px", UI_elements.cur_lbl:ibGetAfterX() + 7 )
end

function RefreshTable()
    DestroyTableElements( UI_elements.player_cards )
    DestroyTableElements( UI_elements.dealer_cards )
    UI_elements.player_cards = {}
    
    RefreshDealerCards()
    for k, v in pairs( player_positions ) do
        local position_data = BLACK_JACK_DATA.player_data_cards[ k ]
        if isElement( UI_elements.player_bg[ k ] ) then
            UI_elements.player_names[ k ]:ibData( "text", position_data and position_data.nickname or "Место свободно" )
            UI_elements.player_cards_summ[ k ]:ibData( "text", position_data and CalculateCardSumm( position_data.cards ) or "-" )
        else
            UI_elements.player_bg[ k ] = ibCreateImage( v.px - 25 * cfX, v.py, cfX * 240, cfY * 44, ":nrp_casino_black_jack/img/bg_stat_player.png", UI_elements.bg_table )
            UI_elements.player_names[ k ] = ibCreateLabel( cfX * 66, 0, cfX * 140, cfY * 40, position_data and position_data.nickname or "Место свободно", UI_elements.player_bg[ k ], 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "regular_" .. math.ceil( 12 * cfY ) ] )
            UI_elements.player_cards_summ[ k ] = ibCreateLabel( cfX * 207, 0, cfX * 30, cfY * 41, position_data and CalculateCardSumm( position_data.cards ) or "-", UI_elements.player_bg[ k ], 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 14 * cfY ) ] )
        end

        if position_data then
            UI_elements.player_cards[ k ] = {}
            local px, py = v.px, v.py - cfY * 140
            for _, card in pairs( position_data.cards ) do
                UI_elements.player_cards[ k ][ card ] = ibCreateImage( px, py, cfX * 87, cfY * 131, ":nrp_casino_black_jack/img/cards/" .. (card[1] .. "_" .. card[2]) ..  ".png", UI_elements.bg_table )
                px = px + cfX * 35
            end
            if position_data.rate and position_data.rate > 0 then
                RefreshPlayerRate( k, position_data.rate )
            end
        else
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
        UI_elements.dealer_bg = ibCreateImage( cfX * 417, cfY * 161, cfX * 145, cfY * 42, ":nrp_casino_black_jack/img/bg_stat_dealer.png", UI_elements.bg_table )
        UI_elements.dealer_card_summ = ibCreateLabel( cfX * 113, 0, cfX * 30, cfY * 40, CalculateCardSumm( BLACK_JACK_DATA.dealer_cards ), UI_elements.dealer_bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 14 * cfY ) ] )
        UI_elements.deck_of_cards = ibCreateImage( cfX * 574, cfY * 40, cfX * 86, cfY * 114, ":nrp_casino_black_jack/img/cards/deck_of_cards.png", UI_elements.bg_table )
        :ibData( "priority", -5 )
    end

    local count_cards = 0
    local px, py = cfX * 417, cfY * 25
    for k, v in pairs( BLACK_JACK_DATA.dealer_cards ) do
        local card_texture_name = v[ 1 ] ~= -1 and (v[ 1 ] .. "_" .. v[ 2 ]) or "cardback"
        if isElement( UI_elements.dealer_cards[ k ] ) then
            UI_elements.dealer_cards[ k ]:ibData( "texture", ":nrp_casino_black_jack/img/cards/" .. card_texture_name ..  ".png" )
        else
            UI_elements.dealer_cards[ k ] = ibCreateImage( cfX * 574, cfY * 40, cfX * 87, cfY * 131, ":nrp_casino_black_jack/img/cards/cardback.png", UI_elements.bg_table )
            UI_elements.dealer_cards[ k ]:ibData( "px_v", px )
            UI_elements.dealer_cards[ k ]:ibData( "py_v", py )
            UI_elements.dealer_cards[ k ]:ibData( "texture_v", card_texture_name )
            UI_elements.dealer_cards[ k ]
            :ibTimer( function()
                UI_elements.dealer_cards[ k ]:ibMoveTo( UI_elements.dealer_cards[ k ]:ibData( "px_v" ), UI_elements.dealer_cards[ k ]:ibData( "py_v" ), 350 )
                :ibTimer( function()
                    UI_elements.dealer_cards[ k ]
                    :ibData( "texture", ":nrp_casino_black_jack/img/cards/" .. (UI_elements.dealer_cards[ k ]:ibData( "texture_v" )) ..  ".png" )
                    soundCard()
                end, 400, 1 )

            end, 50 + 400 * count_cards, 1 )
            count_cards = count_cards + 1
        end
        px = px + cfX * 45
    end
    if next( BLACK_JACK_DATA.dealer_cards ) then
        soundCard()
    end
end

function OnPlayerTakeCard( place_id )
    table.insert( BLACK_JACK_DATA.player_data_cards[ place_id ].cards, { math.random( 2, 4 ), math.random(1, 4) } )

    local player_cards = BLACK_JACK_DATA.player_data_cards[ place_id ].cards
    local card_num = #player_cards
    local card_data = player_cards[ card_num ]
    local position = player_positions[ place_id ]

    UI_elements.player_cards[ place_id ][ card_num ] = ibCreateImage( cfX * 574, cfY * 40, cfX * 87, cfY * 131, ":nrp_casino_black_jack/img/cards/cardback.png", UI_elements.bg_table )
        :ibMoveTo( position.px + ( card_num - 1 ) * (cfX * 35), position.py - cfY * 140, 350 )
   
    UI_elements.player_cards_summ[ place_id ]:ibData( "text", CalculateCardSumm( player_cards ) )
    
    UI_elements.player_cards[ place_id ][ card_num ]
        :ibTimer( function()
            UI_elements.player_cards[ place_id ][ card_num ]
            :ibData( "texture", ":nrp_casino_black_jack/img/cards/" .. (card_data[1] .. "_" .. card_data[2]) ..  ".png" )
            soundCard()
        end, 400, 1 )
end

function SetCurrentActivePlayer( place_id )
    for k, v in pairs( UI_elements.player_bg ) do
        if k == place_id then
            UI_elements.player_bg[ k ]:ibBatchData({ texture = ":nrp_casino_black_jack/img/bg_stat_player_active.png", priority = 2 })
            UI_elements.player_rates[ k ]:ibBatchData({ texture = ":nrp_casino_black_jack/img/bg_rate_player_active.png", priority = 3 })
        else
            UI_elements.player_bg[ k ]:ibBatchData({ texture = ":nrp_casino_black_jack/img/bg_stat_player.png", priority = 2 })
            if isElement( UI_elements.player_rates[ k ] ) then
                UI_elements.player_rates[ k ]:ibBatchData({ texture = ":nrp_casino_black_jack/img/bg_rate_player.png", priority = 3 })
            end
        end
    end
end

--------------------------------------------------------
-- Result
--------------------------------------------------------

function ShowResult()
    GenerateDealerCards( true )
    RefreshDealerCards()
    
    UI_elements.show_result_tmr = setTimer( function()
        if BLACK_JACK_DATA.summ_rate > 0 then
            local card_sum = CalculateCardSumm( BLACK_JACK_DATA.player_data_cards[ 2 ].cards )
            ShowResultRate( { game_result = (card_sum == 21 or card_sum == 0) and BLACK_JACK_RESULT_DRAW or BLACK_JACK_RESULT_LOSE, game_rate_result = BLACK_JACK_DATA.summ_rate } )
            UI_elements.finish_tmr = setTimer( FinishGame, 3000, 1 )
        else
            UI_elements.finish_tmr = setTimer( FinishGame, 2000, 1 )
        end
    end, 1000, 1 )
end

function FinishGame()
    BLACK_JACK_DATA.iter_count = BLACK_JACK_DATA.iter_count + 1
    if BLACK_JACK_DATA.iter_count > 2 then
        DestroyBlackJackGame( true )
    else
        StartNewRoundGame( true )
    end
end

function ShowDrawRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end
    
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    
    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, ":nrp_casino_black_jack/img/reward/bg_yellow.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfX, _SCREEN_X, 26 * cfY, ":nrp_casino_black_jack/img/reward/yellow_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, _SCREEN_X, 18 * cfY, "НИЧЬЯ", UI_elements.text_effect_result, 0xFFFFD854, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    UI_elements.bg_reward_text = ibCreateImage( (_SCREEN_X - 939 * cfX) / 2, _SCREEN_Y - 500 * cfY, 939 * cfX, 416 * cfY, ":nrp_casino_black_jack/img/reward/reward_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, 939 * cfX, 416 * cfY, "ВАШ ВЫИГРЫШ:", UI_elements.bg_reward_text, 0xFFFFD339, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 21 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (_SCREEN_X - 120 * cfX) / 2, _SCREEN_Y - 235 * cfY, 120 * cfX, 120 * cfX, ":nrp_casino_black_jack/img/reward/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, ":nrp_casino_black_jack/img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate.game_rate_result or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
end

function ShowFailRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end
    
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    
    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, ":nrp_casino_black_jack/img/reward/bg_red.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfX, _SCREEN_X, 26 * cfY, ":nrp_casino_black_jack/img/reward/red_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, _SCREEN_X, 18 * cfY, "ВЫ ПРОИГРАЛИ", UI_elements.text_effect_result, 0xFFD42D2D, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (_SCREEN_X - 120 * cfX) / 2, _SCREEN_Y - 235 * cfY, 120 * cfX, 120 * cfX, ":nrp_casino_black_jack/img/reward/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, ":nrp_casino_black_jack/img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate.game_rate_result or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
end

function ShowResultRate( result_rate )
    if not UI_elements then return end

    if result_rate.game_result == BLACK_JACK_RESULT_DRAW then
        ShowDrawRate( result_rate )
    elseif result_rate.game_result == BLACK_JACK_RESULT_LOSE then
        ShowFailRate( result_rate )
    end

    UI_elements.show_result_tmr = setTimer( function() 
        if not isElement( UI_elements and UI_elements.black_bg_result ) then return end
        UI_elements.black_bg_result:ibAlphaTo( 0, 250 )
        setTimer( function()
            if not isElement( UI_elements and UI_elements.black_bg_result ) then return end
            destroyElement( UI_elements.black_bg_result )
        end, 250, 1 )
    end, 3000, 1 )
end