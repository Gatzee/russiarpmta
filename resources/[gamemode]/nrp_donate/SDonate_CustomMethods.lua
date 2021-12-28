METHODS_CONTENTS = { }

function UpdateMethodsContents( )
    APIDB:queryAsync( function( query )
        local values = query:poll( -1 )
        local methods_contents = { }
        for i, v in pairs( values ) do
            local params = fromJSON( v.item_params )

            params.pmethod = v.pmethod_selection ~= "" and v.pmethod_selection or nil
            params.item_name = v.item_name

            table.insert( methods_contents, params )
        end

        local is_updated = not table.compare( methods_contents, METHODS_CONTENTS )
        METHODS_CONTENTS = methods_contents
        if is_updated then
            RefreshPlayersData( )
        end
    end, { }, "SELECT * FROM PaymentMethodsContents WHERE active=1 ORDER BY id ASC" )
end

function onResourceStart_methodsHandler( )
    UpdateMethodsContents( )
    setTimer( UpdateMethodsContents, 5000, 0 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_methodsHandler )

function RefreshPlayersData( )
    iprint( "called refresh" )
    triggerClientEvent( "UpdatePaymentMethodsList", resourceRoot, METHODS_CONTENTS )
end

function onPlayerReadyToPlay_methodsHandler( )
    triggerClientEvent( source, "UpdatePaymentMethodsList", resourceRoot, METHODS_CONTENTS )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_methodsHandler )

--[[
function onSegmentedPaymentsLoadFinished_handler( )
    if not isElement( source ) then return end
    triggerClientEvent( source, "UpdatePaymentMethodsList", source, METHODS_CONTENTS )
end
addEvent( "onSegmentedPaymentsLoadFinished" )
addEventHandler( "onSegmentedPaymentsLoadFinished", resourceRoot, onSegmentedPaymentsLoadFinished_handler )
]]