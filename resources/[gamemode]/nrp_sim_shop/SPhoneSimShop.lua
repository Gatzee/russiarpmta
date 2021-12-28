loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SDB" )

-- Вход в магазин
function onSimShopJoinRequest_handler( )
    local conf = {
        current_number = client:GetPhoneNumber( ),
        available_numbers = GetNumbersList(),
    }
    triggerClientEvent( client, "ShowSimShopUI", resourceRoot, true, conf )
end
addEvent( "onSimShopJoinRequest", true )
addEventHandler( "onSimShopJoinRequest", root, onSimShopJoinRequest_handler )

-- Запрос нового списка
function onSimShopUpdateListRequest_handler( player )
    local player = client or player 
    triggerClientEvent( player, "UpdateSimShopList", resourceRoot, GetNumbersList(), player:GetPhoneNumber() )
end
addEvent( "onSimShopUpdateListRequest", true )
addEventHandler( "onSimShopUpdateListRequest", root, onSimShopUpdateListRequest_handler )

-- Попытка покупки номера уникального/премиум/люкс |- номера
function onSimShopPurchaseRequest_handler( resulting_number )
    TryChangePhoneNumber( client, resulting_number )
end
addEvent( "onSimShopPurcahseRequest", true )
addEventHandler( "onSimShopPurcahseRequest", root, onSimShopPurchaseRequest_handler )

-- Попытка покупки обычного номера
function onSimShopRandomNumberPurchaseRequest_handler( )    
    TryChangePhoneNumber( client, NUMBERS.ordinary.GenerateNumber() )
end
addEvent( "onSimShopRandomNumberPurchaseRequest", true )
addEventHandler( "onSimShopRandomNumberPurchaseRequest", root, onSimShopRandomNumberPurchaseRequest_handler )
