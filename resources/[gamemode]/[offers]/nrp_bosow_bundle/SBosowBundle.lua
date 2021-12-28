loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

OFFER_DATA = { }

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "bosow_bundle" then return end

	if not value or next( value ) == nil then 
		OFFER_DATA = { }
	else
		OFFER_DATA = value[ 1 ]
		-- OFFER_DATA.cost = OFFER_DATA.cost
		OFFER_DATA.start_ts = getTimestampFromString( OFFER_DATA.start_ts )
		OFFER_DATA.finish_ts = getTimestampFromString( OFFER_DATA.finish_ts )
	end
end )
triggerEvent( "onSpecialDataRequest", resourceRoot, "bosow_bundle" )

function InitOffer( player )
    if not player:HasFinishedTutorial( ) then return end
    
    -- Игрок не забрал винилы после покупки
    if player:GetPermanentData( "bosow_bundle_rewards" ) then
        triggerClientEvent( player, "ShowBosowBundleRewards", resourceRoot )
        return
    end

    -- Оффер активен
	local current_ts = getRealTimestamp( )
	if not OFFER_DATA.start_ts then return end
    if OFFER_DATA.start_ts > current_ts or current_ts > OFFER_DATA.finish_ts then return end

    -- Игрок не воспользовался оффером
    if OFFER_DATA.start_ts == player:GetPermanentData( "bosow_bundle_used" ) then return end
    
    -- Первый показ оффера игроку
    local bosow_bundle_init = player:GetPermanentData( "bosow_bundle_init" ) or 0
    if bosow_bundle_init ~= OFFER_DATA.start_ts then
        player:SetPermanentData( "bosow_bundle_init", OFFER_DATA.start_ts )

        SendElasticGameEvent( player:GetClientID( ), "bosow_sale_showfirst" )
    end
    
    triggerClientEvent( player, "ShowBosowBundle", player, OFFER_DATA )
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    InitOffer( source )
end, true, "low" )

addEvent( "onPlayerWantBuyBosowBundle", true )
addEventHandler( "onPlayerWantBuyBosowBundle", resourceRoot, function ( )
    local player = client

    -- Оффер активен
    if not OFFER_DATA.start_ts then
        player:ShowError( "Данное предложение больше недоступно" )
        return
    end

    -- Игрок не воспользовался оффером
    if OFFER_DATA.start_ts == player:GetPermanentData( "bosow_bundle_used" ) then
        player:ShowError( "Ты уже воспользовался этим предложением" )
        return
    end

    if not player:TakeDonate( OFFER_DATA.cost, "sale", "bosow_sale" ) then
        triggerClientEvent( player, "onShopNotEnoughHard", player, "bosow_sale", "onPlayerRequestDonateMenu", "donate" )
        return
    end

    player:ShowSuccess( "Ты успешно приобрёл уникальный стиль Bosow!" )
    
    player:SetPermanentData( "bosow_bundle_used", OFFER_DATA.start_ts )
    player:SetPermanentData( "bosow_bundle_rewards", true )
    triggerClientEvent( player, "ShowBosowBundleRewards", resourceRoot )

    SendElasticGameEvent( player:GetClientID( ), "bosow_sale_purchase", {
        current_lvl = player:GetLevel( ),
        cost = OFFER_DATA.cost,
        quantity = 1,
        spend_sum = OFFER_DATA.cost,
        currency = "hard",
    } )
end )

addEvent( "onPlayerWantTakeBosowBundle", true )
addEventHandler( "onPlayerWantTakeBosowBundle", resourceRoot, function ( data )
    local player = client

    if not player:GetPermanentData( "bosow_bundle_rewards" ) then
        return
    end

    player:SetPermanentData( "bosow_bundle_rewards", nil )
    
    player:GivePhoneWallpaper( "bosow" )
    
    player:GiveVinyl( { 
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE ]      = "bosow_1",
        [ P_CLASS ]      = data.bosow_1 and isElement( data.bosow_1.vehicle ) and data.bosow_1.vehicle:GetTier( ) or 1,
        [ P_NAME ]       = "Bosow",
        [ P_PRICE ]      = 199,
    } )
    player:GiveVinyl( { 
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE ]      = "bosow_2",
        [ P_CLASS ]      = data.bosow_2 and isElement( data.bosow_2.vehicle ) and data.bosow_2.vehicle:GetTier( ) or 1,
        [ P_NAME ]       = "Bosow 2",
        [ P_PRICE ]      = 199,
    } )
end )






if SERVER_NUMBER > 100 then

    addCommandHandler( "init_bosow_bundle", function( player )
        InitOffer( player )
    end )

end