METHODS_CONTENTS = { }

function UpdatePaymentMethodsList_handler( methods_contents )
    iprint( methods_contents )
    METHODS_CONTENTS = methods_contents
end
addEvent( "UpdatePaymentMethodsList", true )
addEventHandler( "UpdatePaymentMethodsList", resourceRoot, UpdatePaymentMethodsList_handler )

function GetPaymentMethodsInfo( )
    return METHODS_CONTENTS
end