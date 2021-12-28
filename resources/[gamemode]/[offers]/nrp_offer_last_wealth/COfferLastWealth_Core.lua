Extend( "ib" )
Extend( "CPlayer" )
Extend( "CPayments" )

ibUseRealFonts( true )

function onClientShowOfferLastWealth_handler( data, first_show )
    if first_show then
        CHECK_ANY_WINDOW_TMR = setTimer( function( )
            if ibIsAnyWindowActive( ) then return end
            killTimer( CHECK_ANY_WINDOW_TMR )

            localPlayer:setData( "offer_last_wealth_time_left", CONST_OFFER_END_DATE, false )
            ShowOfferLastWealth( true, data )
            if not INIT_OFFER then
                INIT_OFFER = true
                triggerEvent( "ShowSplitOfferInfo", root, CONST_OFFER_NAME, CONST_OFFER_END_DATE - getRealTimestamp() )
            end
        end, 1000, 0 )
    else
        ShowOfferLastWealth( true, data )
    end
end
addEvent( "onClientShowOfferLastWealth", true )
addEventHandler( "onClientShowOfferLastWealth", resourceRoot, onClientShowOfferLastWealth_handler )