local payment_window

function SelectPack( pack_id, sum )
    HidePaymentWindow( )
    
    payment_window = ibPayment( )
    payment_window.selector.control_cursor = true
    payment_window.browser.control_cursor = true
    payment_window.data = { pack_id = pack_id, sum = sum }
    payment_window.init( )
end

function HidePaymentWindow( )
    if payment_window then
        payment_window.destroy( )
        payment_window = nil
    end
end

function onClientSelectThirdPackInBrowser_handler( pack_id, sum )
    SelectPack( pack_id, sum )
end
addEvent( "onClientSelectThirdPackInBrowser", true )
addEventHandler( "onClientSelectThirdPackInBrowser", resourceRoot, onClientSelectThirdPackInBrowser_handler )
