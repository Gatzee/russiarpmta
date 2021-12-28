CASES_DATA = nil

local CHECK_ANY_WINDOW_TMR = nil

function onClientShowDefenderFatherlandDayOffer_handler( cases_data, data )
    if not CASES_DATA then 
        CASES_DATA = cases_data

        CHECK_ANY_WINDOW_TMR = setTimer( function( )
            if ibIsAnyWindowActive( ) then return end
            killTimer( CHECK_ANY_WINDOW_TMR )

            if not data.reward_data then
                ShowOfferDefenderFatherlandDay( true, data )
            end

            localPlayer:setData( "offer_" .. OFFER_NAME .. "_time_left", OFFER_END_DATE, false )
            triggerEvent( "ShowSplitOfferInfo", root, OFFER_NAME, OFFER_END_DATE - getRealTimestamp() )
        end, 1000, 0 )
    else
        ShowOfferDefenderFatherlandDay( true, data )
    end
end
addEvent( "onClientShowDefenderFatherlandDayOffer", true )
addEventHandler( "onClientShowDefenderFatherlandDayOffer", resourceRoot, onClientShowDefenderFatherlandDayOffer_handler )

function onClientSuccessfulPurchaseDefenderFatherlandDayOffer_handler()
    ShowOfferDefenderFatherlandDay( false )
    HidePaymentWindow( )
    ibBuyDonateSound()
end
addEvent( "onClientSuccessfulPurchaseDefenderFatherlandDayOffer", true )
addEventHandler( "onClientSuccessfulPurchaseDefenderFatherlandDayOffer", resourceRoot, onClientSuccessfulPurchaseDefenderFatherlandDayOffer_handler )

function onClientSelectVinyl_handler( item )
    HidePaymentWindow( )
    
    REWARD_ELEMENT = ibCreateDummy()
    triggerEvent( "ShowTakeReward", REWARD_ELEMENT, REWARD_ELEMENT, item.type, item )
    
    showCursor( true )
    setCursorAlpha( 255 )

    addEventHandler( "ShowTakeReward_callback", REWARD_ELEMENT, function( data )
        showCursor( false )
        REWARD_ELEMENT:destroy( )
        REWARD_ELEMENT = nil
		triggerServerEvent( "onServerPlayerSelectedVinyl", resourceRoot, data )
    end )
end
addEvent( "onClientSelectVinyl", true )
addEventHandler( "onClientSelectVinyl", resourceRoot, onClientSelectVinyl_handler )