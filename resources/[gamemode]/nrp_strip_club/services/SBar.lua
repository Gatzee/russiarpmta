
function onServerPlayerWantBuyAlcohol_handler( alcohol_id )
    local alcohol = DRINKS[ alcohol_id ]
    if not alcohol or not isElement( client ) then return end
    
    if client:TakePlayerPrice( alcohol.price, alcohol.currency, "alcohold_" .. alcohol_id ) then
        client:OnBoughtService( alcohol.price, alcohol.currency )

        triggerClientEvent( GetPlayersInStripClub(), "onClientPlayerBuyAlcohol", client, alcohol_id )

        -- Аналитика :- Игрок купил алкоголь
        triggerEvent( "onPlayerPurchaseAlcohol", client, alcohol.id, alcohol.price, alcohol.currency )
    else
        client:ShowError( "У Вас недостаточно средств для покупки" )
    end
end
addEvent( "onServerPlayerWantBuyAlcohol", true )
addEventHandler( "onServerPlayerWantBuyAlcohol", root, onServerPlayerWantBuyAlcohol_handler )
