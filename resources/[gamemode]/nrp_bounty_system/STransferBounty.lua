local nrp_transfer = getResourceFromName( "nrp_transfer" )
if nrp_transfer and nrp_transfer.state == "running" then
	exports.nrp_transfer:AddTransferDataHandler( )
end

addEventHandler( "onResourceStart", root, function( resource )
	if resource.name == "nrp_transfer" then
		exports.nrp_transfer:AddTransferDataHandler( )
	end
end )

function GetTransferData( player )
    local currency = { soft = 0 }
    local logdata, info = { }, { }

    local orders = getOrdersBySource( player )
    for _, order in pairs( orders ) do
        local cost = PRICES_FOR_ORDERS[ order.order_way ].price
        currency.soft = currency.soft + cost
        table.insert( logdata, "Заказ на голову, стоимость: " .. cost )

        table.insert( info, { text = "Заказ на голову", cost = cost, type = "soft" } )
    end

    return currency, logdata, info
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source
	triggerEvent( "onTransferPrepareData_callback", player )
end )

addEvent( "onTransferClearOldData" )
addEventHandler( "onTransferClearOldData", root, function( )
    local player = source
    removeOrdersBySource( player )
end )