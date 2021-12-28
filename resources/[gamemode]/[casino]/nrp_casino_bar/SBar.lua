Extend( "SPlayer" )

function GetCasinoPlayers( player )
    local casino_id = getElementData( player, "casino_id" )
    if not casino_id then return false end
    
    local target_players = {}
    for k, v in pairs( GetPlayersInGame() ) do
        if getElementData( v, "casino_id" ) == casino_id then
            table.insert( target_players, v )
        end
    end

    return target_players
end

function onServerPlayerWantBuyAlcoholInCasino_handler( alcohol_id )
    local alcohol = DRINKS[ alcohol_id ]
    if not isElement( client ) or not alcohol then return end
    
    local players = GetCasinoPlayers( client )
    if not players then return end

    if client:TakeMoney( alcohol.cost, "casino", "drink_purchase" ) then
        if players or #players == 0 then 
            triggerClientEvent( players, "onClientPlayerBuyAlcoholInCasino", client, alcohol_id )
        end

        triggerEvent( "onPlayerPurchaseAlcohol", client, alcohol.id, alcohol.price, alcohol.currency )
    else
        client:ShowError( "У Вас недостаточно средств для покупки" )
    end
end
addEvent( "onServerPlayerWantBuyAlcoholInCasino", true )
addEventHandler( "onServerPlayerWantBuyAlcoholInCasino", resourceRoot, onServerPlayerWantBuyAlcoholInCasino_handler )


function onServerPlayerLostConsciousnessInCasino_handler()
    local casino_id = getElementData( client, "casino_id" )
    if not casino_id then return end
    
    local casino_data = CASINO_DATA[ casino_id ]
    if not casino_data then return end
    
    client:SetPrivateData( "casino_id", false )
    client:Teleport( casino_data.woke_up_position:AddRandomRange( 5 ), 0, 0 )

    triggerClientEvent( client, "onClientPlayerWokeUpCasino", resourceRoot, casino_id )
end
addEvent( "onServerPlayerLostConsciousnessInCasino", true )
addEventHandler( "onServerPlayerLostConsciousnessInCasino", resourceRoot, onServerPlayerLostConsciousnessInCasino_handler )