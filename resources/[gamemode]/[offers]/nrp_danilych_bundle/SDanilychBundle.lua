loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "rewards/_ShItems" )
Extend( "rewards/Server" )

OFFER_DATA = { }

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "danilych_bundle" then return end

	if not value or next( value ) == nil then 
		OFFER_DATA = { }
	else
		OFFER_DATA = value[ 1 ]
		-- OFFER_DATA.cost = OFFER_DATA.cost
		OFFER_DATA.start_ts = getTimestampFromString( OFFER_DATA.start_ts )
		OFFER_DATA.finish_ts = getTimestampFromString( OFFER_DATA.finish_ts )
	end
end )
triggerEvent( "onSpecialDataRequest", resourceRoot, "danilych_bundle" )

function InitOffer( player )
    if not player:HasFinishedTutorial( ) then return end
    
    -- Игрок не забрал винилы после покупки
    if player:GetPermanentData( "bosow_bundle_rewards" ) then
        triggerClientEvent( player, "ShowDanilychBundleRewards", resourceRoot )
        return
    end

    -- Оффер активен
	local current_ts = getRealTimestamp( )
	if not OFFER_DATA.start_ts then return end
    if OFFER_DATA.start_ts > current_ts or current_ts > OFFER_DATA.finish_ts then return end

    -- Игрок не воспользовался оффером
    if OFFER_DATA.start_ts == player:GetPermanentData( "danilych_bundle_used" ) then return end
    
    -- Первый показ оффера игроку
    local danilych_bundle_init = player:GetPermanentData( "danilych_bundle_init" ) or 0
    if danilych_bundle_init ~= OFFER_DATA.start_ts then
        player:SetPermanentData( "danilych_bundle_init", OFFER_DATA.start_ts )

        SendElasticGameEvent( player:GetClientID( ), "danilych_sale_showfirst" )
    end
    
    triggerClientEvent( player, "ShowDanilychBundle", player, OFFER_DATA )
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    InitOffer( source )
end, true, "low" )

addEvent( "onPlayerWantBuyDanilychBundle", true )
addEventHandler( "onPlayerWantBuyDanilychBundle", resourceRoot, function ( )
    local player = client

    -- Оффер активен
    if not OFFER_DATA.start_ts then
        player:ShowError( "Данное предложение больше недоступно" )
        return
    end

    -- Игрок не воспользовался оффером
    if OFFER_DATA.start_ts == player:GetPermanentData( "danilych_bundle_used" ) then
        player:ShowError( "Ты уже воспользовался этим предложением" )
        return
    end

    if not player:TakeDonate( OFFER_DATA.cost, "sale", "danilych_sale" ) then
        triggerClientEvent( player, "onShopNotEnoughHard", player, "danilych_sale", "onPlayerRequestDonateMenu", "donate" )
        return
    end

    player:ShowSuccess( "Ты успешно приобрёл уникальный стиль Danilych!" )

    player:GiveReward( { type = "vehicle", id = 6636, tuning = { color = { 0, 0, 0 } }, event_name = "OnPlayerDanilychVehicleReceived" } )
    
    player:SetPermanentData( "danilych_bundle_used", OFFER_DATA.start_ts )
    player:SetPermanentData( "danilych_bundle_rewards", true )

    SendElasticGameEvent( player:GetClientID( ), "danilych_sale_purchase", {
        current_lvl = player:GetLevel( ),
        cost = OFFER_DATA.cost,
        quantity = 1,
        spend_sum = OFFER_DATA.cost,
        currency = "hard",
    } )
end )

function OnPlayerDanilychVehicleReceived( veh, data )
    triggerClientEvent( data.player, "ShowDanilychBundleRewards", resourceRoot )
end
addEvent( "OnPlayerDanilychVehicleReceived", true )
addEventHandler( "OnPlayerDanilychVehicleReceived", root, OnPlayerDanilychVehicleReceived )

addEvent( "onPlayerWantTakeDanilychBundle", true )
addEventHandler( "onPlayerWantTakeDanilychBundle", resourceRoot, function ( data )
    local player = client

    if not player:GetPermanentData( "danilych_bundle_rewards" ) then
        return
    end

    player:SetPermanentData( "danilych_bundle_rewards", nil )
    
    player:GiveVinyl( { 
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE ]      = "s63",
        [ P_CLASS ]      = data.danilych_1 and isElement( data.danilych_1.vehicle ) and data.danilych_1.vehicle:GetTier( ) or 1,
        [ P_NAME ]       = "Danilych",
        [ P_PRICE ]      = 50,
    } )
    player:GiveVinyl( { 
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE ]      = "s64",
        [ P_CLASS ]      = data.danilych_2 and isElement( data.danilych_2.vehicle ) and data.danilych_2.vehicle:GetTier( ) or 1,
        [ P_NAME ]       = "Danilych 2",
        [ P_PRICE ]      = 50,
    } )

    player:GiveVinyl( { 
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE ]      = "s65",
        [ P_CLASS ]      = data.danilych_3 and isElement( data.danilych_3.vehicle ) and data.danilych_3.vehicle:GetTier( ) or 1,
        [ P_NAME ]       = "Danilych 3",
        [ P_PRICE ]      = 50,
    } )
end )

if SERVER_NUMBER > 100 then

    addCommandHandler( "init_danilych_bundle", function( player )
        player:SetPermanentData( "danilych_bundle_rewards", nil )
        player:SetPermanentData( "danilych_bundle_used", nil )
        InitOffer( player )
    end )

end