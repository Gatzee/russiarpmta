

function onServerPlayerWantBuyPrivateDance_handler( dance_id )
    local dance = PRIVATE_DANCE_GIRLS[ dance_id ]
    if not dance or not isElement( client ) then return end
    
    if client:GetPermanentData( "free_private_dance" ) then
        client:SetPermanentData( "free_private_dance", false )
        onStartPrivateDance( client, dance_id )
    elseif client:TakePlayerPrice( dance.price, dance.currency, "private_" .. dance_id ) then
        onStartPrivateDance( client, dance_id )
        client:OnBoughtService( dance.price, dance.currency )
        
        -- Аналитика :- Игрок купил приватный танец
        triggerEvent( "onPlayerPurchaseStripDance", client, false, true, dance_id, dance.price, dance.currency )
    else
        client:ShowError( "У вас недостаточно средств для покупки" )
    end
end
addEvent( "onServerPlayerWantBuyPrivateDance", true )
addEventHandler( "onServerPlayerWantBuyPrivateDance", root, onServerPlayerWantBuyPrivateDance_handler )

function onStartPrivateDance( player, dance_id )
    fadeCamera( player, false, 0 )
    player:Teleport( PRIVATE_DANCE_PLAYER_POSITION, player:GetUniqueDimension( ) )
    setElementRotation( player, PRIVATE_DANCE_PLAYER_ROTATION )

    triggerClientEvent( player, "onClientPlayerBuyPrivateDance", resourceRoot, dance_id, player:GetUniqueDimension() )
end

function onServerPlayerWantOpenPrivateDance_handler()
    triggerClientEvent( client, "onClientPlayerWantOpenPrivateDance", resourceRoot, true, { free_dance = client:GetPermanentData( "free_private_dance" ) })
end
addEvent( "onServerPlayerWantOpenPrivateDance", true )
addEventHandler( "onServerPlayerWantOpenPrivateDance", root, onServerPlayerWantOpenPrivateDance_handler )

function onServerPlayerFinishWatchPrivateDance_handler( )
    fadeCamera( client, false, 0 )
    client:Teleport( FINISH_PRIVATE_DANCE_PLAYER_POSITION, 1, 1 )
    setElementRotation( client, FINISH_PRIVATE_DANCE_PLAYER_ROTATION )
    setCameraTarget( client )
    setTimer( fadeCamera, 250, 1, client, true, 1 )
    
    triggerClientEvent( client, "onClientStopStartPrivateDacne", resourceRoot, false )
end
addEvent( "onServerPlayerFinishWatchPrivateDance", true )
addEventHandler( "onServerPlayerFinishWatchPrivateDance", root, onServerPlayerFinishWatchPrivateDance_handler )