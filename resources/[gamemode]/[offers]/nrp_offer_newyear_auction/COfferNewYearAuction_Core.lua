Extend( "ib" )
Extend( "CPlayer" )

function onClientShowOfferNewYearAuction_handler( data, is_show_first )
    if is_show_first and not INIT_OFFER then
        CHECK_ANY_WINDOW_TMR = setTimer( function( )
            if ibIsAnyWindowActive( ) then return end
            killTimer( CHECK_ANY_WINDOW_TMR )

            localPlayer:setData( "offer_newyear_auction_time_left", OFFER_END_DATE, false )
            ShowNewYearAuctionMenu( true, data )

            triggerEvent( "ShowSplitOfferInfo", root, OFFER_NAME, OFFER_END_DATE - getRealTimestamp() )
        end, 1000, 0 )
    else
        ShowNewYearAuctionMenu( true, data )
    end
end
addEvent( "onClientShowOfferNewYearAuction", true )
addEventHandler( "onClientShowOfferNewYearAuction", resourceRoot, onClientShowOfferNewYearAuction_handler )

function onClientEndNewYearAuctionUI_handler( data )
    ShowNewYearAuctionMenu( false )
    localPlayer:setData( "offer_newyear_auction_time_left", false, false )
end
addEvent( "onClientEndNewYearAuctionUI", true )
addEventHandler( "onClientEndNewYearAuctionUI", resourceRoot, onClientEndNewYearAuctionUI_handler )

function onClientRefreshRateRateUI_handler( data )
    RefreshRateUI( data )
end
addEvent( "onClientRefreshRateRateUI", true )
addEventHandler( "onClientRefreshRateRateUI", resourceRoot, onClientRefreshRateRateUI_handler )