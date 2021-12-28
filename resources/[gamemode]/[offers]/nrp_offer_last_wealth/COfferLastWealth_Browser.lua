local payment_window
function SelectPack( pack_id, sum )
    HidePaymentWindow( )
    
    payment_window = ibPayment( )
    payment_window.data = { pack_id = pack_id, sum = sum }
    payment_window.init( )
end

function HidePaymentWindow( )
    if payment_window then
        payment_window.destroy( )
        payment_window = nil
    end
end

function onClientSelectLastWealthPackInBrowser_handler( pack_id, sum )
    -- ShowOfferLastWealth( false ) -- нахуя?
    SelectPack( pack_id, sum )
end
addEvent( "onClientSelectLastWealthPackInBrowser", true )
addEventHandler( "onClientSelectLastWealthPackInBrowser", resourceRoot, onClientSelectLastWealthPackInBrowser_handler )
