Extend( "SPlayer" )
Extend( "SVehicle" )

function InitOffer( player )
    if not player:HasFinishedTutorial( ) then return end

    -- Оффер активен
	local current_ts = getRealTimestamp( )
    if OFFER_START_DATE > current_ts or current_ts > OFFER_END_DATE then return end
    
    -- Первый показ оффера игроку
    local offer_data = player:GetPermanentData( "march_offer" )
    if not offer_data then
        player:SetPermanentData( "march_offer", { } )

        SendElasticGameEvent( player:GetClientID( ), "march_offer_show_first" )
    else
        offer_data.bought_packs = FixTableKeys( offer_data.bought_packs )
        offer_data.taken_packs = FixTableKeys( offer_data.taken_packs )
        player:SetPermanentData( "march_offer", offer_data )
    end
    
    triggerClientEvent( player, "ShowOffer8March", player, offer_data or { } )
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    InitOffer( source )
end, true, "low" )

addEvent( "8M:onPlayerWantBuyPack", true )
addEventHandler( "8M:onPlayerWantBuyPack", resourceRoot, function ( pack_id )
    local player = client
    local offer_data = player:GetPermanentData( "march_offer" ) or { }

    if offer_data.bought_packs and offer_data.bought_packs[ pack_id ] then
        player:ShowError( "Ты уже купил этот набор" )
        return
    end

    local pack_lvl = offer_data.bought_packs_count or 1
    local pack = PACKS[ pack_id ][ pack_lvl ]
    if not player:TakeDonate( pack.cost, "sale", "march_offer" ) then
        triggerEvent( "onPlayerRequestDonateMenu", player, "donate", "march_offer" )
        return
    end

    if not offer_data.bought_packs then offer_data.bought_packs = { } end
    offer_data.bought_packs[ pack_id ] = pack_lvl
    offer_data.bought_packs_count = ( offer_data.bought_packs_count or 1 ) + 1

    for i, item in pairs( pack.items ) do
        -- player:GiveCase( case_id, count )
    end
    player:ShowSuccess( "Ты успешно купил этот набор!" )
    
    player:SetPermanentData( "march_offer", offer_data )

    triggerClientEvent( player, "8M:onClientPackBuy", resourceRoot, pack_id )

    SendElasticGameEvent( player:GetClientID( ), "march_offer_offer_purchase", {
        id = "march_offer_" .. pack_id .. "_" .. pack_lvl,
        name = pack.key,
        cost = pack.cost,
        quantity = 1,
        spend_sum = pack.cost,
        currency = "hard",
    } )
end )

addEvent( "8M:onPlayerWantTakePack", true )
addEventHandler( "8M:onPlayerWantTakePack", resourceRoot, function ( pack_id, rewards_data )
    local player = client
    local offer_data = player:GetPermanentData( "march_offer" ) or { }

    if not offer_data.bought_packs or not offer_data.bought_packs[ pack_id ] then
        player:ShowError( "Ты ещё не купил этот набор" )
        return
    end

    if offer_data.taken_packs and offer_data.taken_packs[ pack_id ] then
        return
    end

    if not offer_data.taken_packs then offer_data.taken_packs = { } end
    offer_data.taken_packs[ pack_id ] = true
    player:SetPermanentData( "march_offer", offer_data )

    local bought_lvl = offer_data.bought_packs[ pack_id ]
    local pack = PACKS[ pack_id ][ bought_lvl ]
    for i, item in pairs( pack.items ) do
        local reward_data = rewards_data[ i ]
        if item.exchange and reward_data and reward_data.exchange_to then
            if reward_data.exchange_to == "soft" then
                iprint( item.exchange )
                player:GiveMoney( item.exchange.soft, "sale", "march_offer" )
            else
                player:GiveExp( item.exchange.exp, "march_offer" )
            end
        else
            REGISTERED_ITEMS[ item.type ].Give( player, item, reward_data )
        end
    end
end )

addEvent( "8M:onPlayerWantBuyVinylCase", true )
addEventHandler( "8M:onPlayerWantBuyVinylCase", resourceRoot, function ( )
    local player = client
    local offer_data = player:GetPermanentData( "march_offer" ) or { }

    if ( offer_data.bought_packs_count or 0 ) < #PACKS then
        player:ShowError( "Сначала нужно приобрести все наборы" )
        return
    end

    if not player:TakeDonate( VINYL_CASE.cost, "sale", "march_offer" ) then
        triggerEvent( "onPlayerRequestDonateMenu", player, "donate", "march_offer" )
        return
    end

    player:GiveCase( VINYL_CASE.id, 1 )
    player:ShowSuccess( "Ты успешно купил этот винил-кейс!" )

    SendElasticGameEvent( player:GetClientID( ), "march_offer_offer_purchase", {
        id = VINYL_CASE.id,
        name = VINYL_CASE.id,
        cost = VINYL_CASE.cost,
        quantity = 1,
        spend_sum = VINYL_CASE.cost,
        currency = "hard",
    } )
end )






if SERVER_NUMBER > 100 then

    addCommandHandler( "init_march_offer", function( player )
        InitOffer( player )
    end )

end