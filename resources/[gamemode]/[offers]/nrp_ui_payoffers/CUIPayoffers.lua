loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "CUI" )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShWebshop" )
Extend( "CPayments" )

PAYOFFER = { }
LIMITED_PACKS_SOLD_COUNTER = { }

function ShowPayofferUI_handler( payoffer, sold_counter_table )
    PAYOFFER = payoffer
    LIMITED_PACKS_SOLD_COUNTER = sold_counter_table
    ShowUI( true )
end
addEvent( "ShowPayofferUI", true )
addEventHandler( "ShowPayofferUI", root, ShowPayofferUI_handler )

x, y = guiGetScreenSize( )
UI_elements = { }

function math.round( num,  idp )
    local mult = 10 ^ ( idp or 0 )
    return math.floor(num * mult + 0.5) / mult
end

function ShowUI( state )
    if state then
        ShowUI( false )

        script_folder = "payoffers/" .. PAYOFFER.folder .. "/"
        script_table = _G[ PAYOFFER.class ]

        if script_table then
            script_table:create( PAYOFFER )
            showCursor( true )

            --iprint( "Trigger payoffer", PAYOFFER )
            triggerEvent( "onPayofferInitialize", localPlayer, PAYOFFER )
        else
            --iprint( "No script table" )
        end

    else
        for i, v in pairs( UI_elements ) do
            if isTimer( v ) then killTimer( v ) end
            if isTimer( i ) then killTimer( i ) end
            if isElement( v ) then destroyElement( v ) end
            if isElement( i ) then destroyElement( i ) end
        end
        UI_elements = { }
        showCursor( false )
    end
end

function SelectPack( pack_id )
    local payment_window = ibPayment( )
    payment_window.selector.control_cursor = true
    payment_window.browser.control_cursor = true
    payment_window.data = { pack_id = pack_id }
    payment_window.init( )

    UI_elements.payment_window = payment_window
end

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
    triggerServerEvent( "ShowPayoffer", localPlayer )
end )

addEvent( "onPayofferInitialize", true )