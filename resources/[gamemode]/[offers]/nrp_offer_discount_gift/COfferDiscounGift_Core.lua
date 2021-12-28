
Extend( "ib" )
Extend( "CPlayer" )
Extend( "CPayments" )

ibUseRealFonts( true )

OFFER_DATA = nil

function onClientShowOfferDiscountGift_handler( data )
    if not IsOfferActive() then return end
    
    if data then 
        OFFER_DATA = data
        CHECK_ANY_WINDOW_TMR = setTimer( function( )
            if ibIsAnyWindowActive() then return end
            killTimer( CHECK_ANY_WINDOW_TMR )
            triggerEvent( "ShowSplitOfferInfo", root, OFFER_NAME, OFFER_END_DATE - getRealTimestamp() )

            ShowOfferUI( true, OFFER_DATA )
        end, 1000, 0 )
    elseif OFFER_DATA then
        ShowOfferUI( true, OFFER_DATA )
    end
end
addEvent( "onClientShowOfferDiscountGift", true )
addEventHandler( "onClientShowOfferDiscountGift", root, onClientShowOfferDiscountGift_handler )

function onClientShowOfferDiscountGiftPackReward_handler( pack_index, num_purchased_packs )
    if OFFER_DATA then OFFER_DATA.num_purchased_packs = num_purchased_packs end
    ShowPackRewards( true, pack_index, num_purchased_packs )
end
addEvent( "onClientShowOfferDiscountGiftPackReward", true )
addEventHandler( "onClientShowOfferDiscountGiftPackReward", resourceRoot, onClientShowOfferDiscountGiftPackReward_handler )


function onClientUseTestCosts_handler()
    local cost = 1
    for pack_index, pack_data in pairs( PACK_DATA ) do
        pack_data.cost = cost
        cost = cost + 1
    end
end
addEvent( "onClientUseTestCosts", true )
addEventHandler( "onClientUseTestCosts", resourceRoot, onClientUseTestCosts_handler )