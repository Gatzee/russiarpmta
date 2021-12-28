Extend( "SPlayer" )

addEvent( "onJobEarnMoney" )

function earnMoney( job_class, money )
    local offer_piggy_bank = source:GetPermanentData( DATA_NAME )
    if not offer_piggy_bank or not job_class or not ALLOW_JOBS[ job_class ] then
        return
    end

    local percent = money * ( source:IsPremiumActive( ) and 0.5 or 0.3 )
    offer_piggy_bank = offer_piggy_bank + percent

    -- save data
    source:SetPermanentData( DATA_NAME, offer_piggy_bank )
    source:SetPrivateData( DATA_NAME, offer_piggy_bank )
end

function initOffer( player, type )
    local level = player:GetLevel( )
    local data = player:GetPermanentData( DATA_NAME )

    if level >= MIN_LEVEL and level < MAX_LEVEL then
        if data == nil then
            data = 0
            player:SetPermanentData( DATA_NAME, data )

            -- show first time
            triggerClientEvent( player, "onPlayerOfferPiggyBank", player )

            -- analytics
            SendElasticGameEvent( source:GetClientID( ), "offer_piggy_bank_showfirst", {
                type = type,
            } )
        end

        if data ~= false then
            player:SetPrivateData( DATA_NAME, data )

            -- player's tracking
            removeEventHandler( "onJobEarnMoney", player, earnMoney )
            addEventHandler( "onJobEarnMoney", player, earnMoney )

            if level == 9 then
                triggerClientEvent( player, "onPlayerOfferPiggyBank", player )
            end
        end
    else
        if data then
            stopOffer( player )
        end
    end
end

function stopOffer( player )
    player:SetPermanentData( DATA_NAME, false )
    player:SetPrivateData( DATA_NAME, nil )

    -- stop player's tracking
    removeEventHandler( "onJobEarnMoney", player, earnMoney )
end

addEvent( "OnPlayerLevelUp" )
addEventHandler( "OnPlayerLevelUp", root, function ( )
    initOffer( source, "level_up" )
end )

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    initOffer( source, "in_enter" )
end, true, "low" )

addEvent( "onPlayerWantReturnTaxByOffer", true )
addEventHandler( "onPlayerWantReturnTaxByOffer", resourceRoot, function ( )
    if not client then
        return
    end

    local level = client:GetLevel( )
    if client:GetLevel( ) >= MAX_LEVEL then
        client:ShowError( "Получить налоговый вычет можно только до " .. MAX_LEVEL .. " уровня" )
        return
    end

    local offer_piggy_bank = client:GetPermanentData( DATA_NAME )
    if not offer_piggy_bank then
        return
    end

    if offer_piggy_bank < MIN_CONVERT_VALUE then
        client:ShowError( "Сумма к возврату должна быть не меньше " .. format_price( MIN_CONVERT_VALUE ) .. " руб." )
        return
    end

    local price = getPriceOfTax( offer_piggy_bank, level )
    if client:GetDonate( ) < price then
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Return tax" )
        return
    end

    client:TakeDonate( price, "sale", "piggy_bank" )
    client:GiveMoney( offer_piggy_bank, "sale", "piggy_bank" )

    -- analytics
    SendElasticGameEvent( client:GetClientID( ), "offer_piggy_bank_purchase", {
        sum_soft = offer_piggy_bank,
        cost = price,
        quantity = 1,
        currency = "hard",
    } )

    stopOffer( client )
end )