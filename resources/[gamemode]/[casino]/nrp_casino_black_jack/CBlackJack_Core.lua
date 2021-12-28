Extend( "ib" )
Extend( "CUI" )
Extend( "CPlayer" )

ibUseRealFonts( true )

BLACK_JACK_DATA = nil
BACKGROUND_SOUND = nil

function CreateBlackJackGame( game_data )
    BLACK_JACK_DATA = 
    {
        casino_id     = game_data.casino_id,
        timeout       = getTickCount(),
        current_state = game_data.current_state,
        rates         = {},
        summ_rate     = 0,
        top_list      = game_data.winners_list,
        dealer_cards  = game_data.dealer_cards,
        player_data_cards = game_data.player_data_cards,
    }

    DisableControls()
    
    CreateBlackJackUI()
    
    BACKGROUND_SOUND = playSound( "sfx/bg_game.ogg", true )
    BACKGROUND_SOUND.volume = 0.35
    
    localPlayer:setData( "hide_wanted", true, false )
    triggerEvent( "onClientSetChatState", root, true )

    if game_data.current_state == BLACK_JACK_STATE_RATE and game_data.remaining_time > 2000 then
        ShowRateMenu( { type = game_data.current_state, remaining_time = game_data.remaining_time } )
    end

    removeWorldModel( 19468, 200, -87, -470, 914, localPlayer.interior )

    BLACK_JACK_DATA.show_ui_tmr = setTimer( setCameraMatrix, 150, 1, unpack( CAMERA_POSITION[ game_data.casino_id ] ) )
end

function DestroyBlackJackGame( is_forced )   
    localPlayer:setData( "hide_wanted", false, false )
    if isElement( BACKGROUND_SOUND ) then
        destroyElement( BACKGROUND_SOUND )
        BACKGROUND_SOUND = nil
    end

    if isTimer( BLACK_JACK_DATA and BLACK_JACK_DATA.show_ui_tmr ) then killTimer( BLACK_JACK_DATA.show_ui_tmr ) end

    EnableControls()
    DestroyBlackJackUI()
    
    DestroyTableElements( BLACK_JACK_DATA )
    BLACK_JACK_DATA = nil
    
    if not is_forced then
        fadeCamera( false, 0 )
        setTimer(function()
	    	fadeCamera( true, 1 )
	    	setCameraTarget( localPlayer )
        end, 300, 1)
    end

    restoreWorldModel( 19468, 200, -87, -470, 914, localPlayer.interior )
end

function OnTryLeftGame()
    if UI_elements.confirmation then UI_elements.confirmation:destroy() end
    UI_elements.confirmation = ibConfirm( {
        title = "ВЫХОД ИЗ ИГРЫ", 
        text = "Ты точно хочешь выйти из игры?\n" .. (next( BLACK_JACK_DATA.rates or {} ) and "Твоя ставка будет утеряна!" or ""),
        fn = function( self ) 
            self:destroy()
            triggerServerEvent( "onBlackJackTableLeaveRequest", localPlayer, _, _, "exit" )
        end,
        escape_close = true,
        priority = 100,
    } )
end

function OnTryActionCard( action_id )
    if BLACK_JACK_DATA.current_state ~= BLACK_JACK_STATE_ACTION_CARD then return end
    triggerServerEvent( "onServerPlayerActionCard", resourceRoot, action_id )
end

function OnTryAddRate( chip )    
    if BLACK_JACK_DATA.timeout > getTickCount() or BLACK_JACK_DATA.current_state ~= BLACK_JACK_STATE_RATE then return end
    BLACK_JACK_DATA.timeout = getTickCount() + TIMEOUT_TIME

    local rate_value = RATES_VALUES[ BLACK_JACK_DATA.casino_id ][ chip ]
    if rate_value and not localPlayer:HasMoney( rate_value ) then
        localPlayer:ShowError( "У Вас недостаточно средств для ставки!" )
        return
    end
    
    local cur_sum = BLACK_JACK_DATA.summ_rate + rate_value
    if cur_sum <= MAX_RATES[ BLACK_JACK_DATA.casino_id ] then
        triggerServerEvent( "onServerPlayerTryAddRateBlackJack", resourceRoot, chip )
    else
        localPlayer:ShowError( "Максимальная ставка " .. MAX_RATES[ BLACK_JACK_DATA.casino_id ] .. "р." )
    end
end

function OnTryRemoveRate( chip )
    if BLACK_JACK_DATA.timeout > getTickCount() or BLACK_JACK_DATA.current_state ~= BLACK_JACK_STATE_RATE then return end
    BLACK_JACK_DATA.timeout = getTickCount() + TIMEOUT_TIME

    local chip_exist = false
    for k, v in ipairs( BLACK_JACK_DATA.rates ) do
        if v == chip then
            chip_exist = true
            break
        end
    end

    if chip_exist then
        triggerServerEvent( "onServerPlayerTryRemoveRateBlackJack", resourceRoot, chip )
    end
end

function AddRate( chip )
    table.insert( BLACK_JACK_DATA.rates, chip )
    
    BLACK_JACK_DATA.summ_rate = (BLACK_JACK_DATA.summ_rate or 0 ) + RATES_VALUES[ BLACK_JACK_DATA.casino_id ][ chip ]
    ChangeCurrentSummUI( BLACK_JACK_DATA.summ_rate )
    OnAddRemoveRateRefreshChipsUI()
    soundChip()
end

function RemoveRate( chip )
    for k, v in pairs( BLACK_JACK_DATA.rates ) do
        if v == chip then
            table.remove( BLACK_JACK_DATA.rates, k )
            break
        end
    end

    BLACK_JACK_DATA.summ_rate = BLACK_JACK_DATA.summ_rate - RATES_VALUES[ BLACK_JACK_DATA.casino_id ][ chip ]
    ChangeCurrentSummUI( BLACK_JACK_DATA.summ_rate )
    OnAddRemoveRateRefreshChipsUI()
    soundChip()
end

addEventHandler( "onClientResourceStop", resourceRoot, function()
    if BLACK_JACK_DATA then
        DestroyBlackJackGame( true )
        fadeCamera( true, 1 )
        setCameraTarget( localPlayer )
    end
end )