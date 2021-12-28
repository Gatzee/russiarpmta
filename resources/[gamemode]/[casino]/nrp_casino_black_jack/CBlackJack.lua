
function OnCasinoGameBlackJackStarted_handler( black_jack_data )
    CreateBlackJackGame( black_jack_data )
    triggerEvent( "onClientShowUICasinoGame", root, false )
end
addEvent( "OnCasinoGameBlackJackStarted", true )
addEventHandler( "OnCasinoGameBlackJackStarted", resourceRoot, OnCasinoGameBlackJackStarted_handler )

function OnCasinoGameBlackJackLeaved_handler( is_forced )
    DestroyBlackJackGame( is_forced )
end
addEvent( "OnCasinoGameBlackJackLeaved", true )
addEventHandler( "OnCasinoGameBlackJackLeaved", resourceRoot, OnCasinoGameBlackJackLeaved_handler )

function onClientSuccessAddRate_handler( data )
    if data.player == localPlayer then
        AddRate( data.chip )
    end
    RefreshPlayerRate( data.place_id, data.rate )
end
addEvent( "onClientSuccessAddRate", true )
addEventHandler( "onClientSuccessAddRate", resourceRoot, onClientSuccessAddRate_handler )

function onClientSuccessRemoveRate_handler( data )
    if data.player == localPlayer then
        RemoveRate( data.chip )
    end
    RefreshPlayerRate( data.place_id, data.rate )
end
addEvent( "onClientSuccessRemoveRate", true )
addEventHandler( "onClientSuccessRemoveRate", resourceRoot, onClientSuccessRemoveRate_handler )

function onClientShowPlayerRateMenu_handler( data )
    BLACK_JACK_DATA.current_state = data.type
    ShowRateMenu( data )
end
addEvent( "onClientShowPlayerRateMenu", true )
addEventHandler( "onClientShowPlayerRateMenu", resourceRoot, onClientShowPlayerRateMenu_handler )

function onClientShowPlayerCardActionMenu_handler( data )
    if data.player == localPlayer then
        ShowCardActionMenu( data )
        BLACK_JACK_DATA.current_state = data.type
    end
    SetCurrentActivePlayer( data.place_id )
end
addEvent( "onClientShowPlayerCardActionMenu", true )
addEventHandler( "onClientShowPlayerCardActionMenu", resourceRoot, onClientShowPlayerCardActionMenu_handler )

function onClientStartNewRound_handler( data )
    BLACK_JACK_DATA.rates             = {}
    BLACK_JACK_DATA.summ_rate         = 0
    BLACK_JACK_DATA.top_list          = data.winners_list
    BLACK_JACK_DATA.dealer_cards      = {}
    BLACK_JACK_DATA.player_data_cards = data.player_data_cards

    OnStartNewRound()
end
addEvent( "onClientStartNewRound", true )
addEventHandler( "onClientStartNewRound", resourceRoot, onClientStartNewRound_handler )

function onClientEndRateIteration_handler( data )
    BLACK_JACK_DATA.dealer_cards      = data.dealer_cards
    BLACK_JACK_DATA.player_data_cards = data.player_data_cards
    RefreshTable()
end
addEvent( "onClientEndRateIteration", true )
addEventHandler( "onClientEndRateIteration", resourceRoot, onClientEndRateIteration_handler )

function onClientPlayerJoinGame_handler( player_data )    
    BLACK_JACK_DATA.player_data_cards[ player_data.place_id ] = player_data
    OnPlayerJoinGame( player_data.place_id )
end
addEvent( "onClientPlayerJoinGame", true )
addEventHandler( "onClientPlayerJoinGame", resourceRoot, onClientPlayerJoinGame_handler )

function onClientPlayerLeaveGame_handler( player_data )
    BLACK_JACK_DATA.player_data_cards[ player_data.place_id ] = nil
    OnPlayerLeaveGame( player_data.place_id )
end
addEvent( "onClientPlayerLeaveGame", true )
addEventHandler( "onClientPlayerLeaveGame", resourceRoot, onClientPlayerLeaveGame_handler )

function onClientPlayerTakeCard_handler( player_data )
    if player_data.suf_summ and player_data.player == localPlayer then
        DestroyActionMenu()
    end
    BLACK_JACK_DATA.player_data_cards[ player_data.place_id ].cards = player_data.cards
    OnPlayerTakeCard( player_data.place_id )
end
addEvent( "onClientPlayerTakeCard", true )
addEventHandler( "onClientPlayerTakeCard", resourceRoot, onClientPlayerTakeCard_handler )

function onClientDealerOpenCard_handler( dealer_cards )
    BLACK_JACK_DATA.dealer_cards = dealer_cards
    SetCurrentActivePlayer()
    RefreshDealerCards()
end
addEvent( "onClientDealerOpenCard", true )
addEventHandler( "onClientDealerOpenCard", resourceRoot, onClientDealerOpenCard_handler )