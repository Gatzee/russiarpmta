Extend( "SPlayer" )

PACK_ID  = 902

function IsOfferActive()
    local timestamp = getRealTimestamp()
    return timestamp > CONST_OFFER_START_DATE and timestamp < CONST_OFFER_END_DATE
end

function onServerPlayerPurchasedDonate_handler( player, sum )
    if player:GetPermanentData( CONST_OFFER_NAME .. "_finish" ) then return end

    local cur_mul = player:GetCurrentMulStep()
    local mul_payment_finish = player:GetCompletedMulPayment()

    local coeff_offer = LEVEL_MULTIPLY[ cur_mul ] or DEFAULT_MULTIPLY_DATA
    if mul_payment_finish >= cur_mul then return false end

    local give_sum = math.floor( sum * coeff_offer.value )
    local src_class_type_id = tostring( coeff_offer.value ):gsub( "[.]", "_" )
    player:GiveDonate( give_sum, "donate_pack", "last_riches_" .. src_class_type_id )

    onLastRichesHardPurchase( player, sum, give_sum, cur_mul )

    if not IsOfferActive() then 
        player:SetPermanentData( CONST_OFFER_NAME .. "_finish", true )
        return
    end

    player:TryAddPartCompleteStep( "payment_" .. src_class_type_id, 1 )
    player:SetCompletedMulPayment( cur_mul )

    if cur_mul == #LEVEL_MULTIPLY then
        player:SetPrivateData( "offer_last_wealth_time_left", false )
        player:SetPermanentData( CONST_OFFER_NAME .. "_finish", true )
    end
end
addEvent( "onServerPlayerPurchasedDonate" )
addEventHandler( "onServerPlayerPurchasedDonate", root, onServerPlayerPurchasedDonate_handler )

function onServerPlayerTryPurchaseDonate_handler( sum )
    local player = client
    if not isElement( player ) or not tonumber( sum ) or player:GetPermanentData( CONST_OFFER_NAME .. "_finish" ) then return end

    local cur_mul = player:GetCurrentMulStep()
    local mul_payment_finish = player:GetCompletedMulPayment()

    local coeff_offer = LEVEL_MULTIPLY[ cur_mul ] or DEFAULT_MULTIPLY_DATA
    if mul_payment_finish >= cur_mul then
        player:ShowError( "Вы уже купили валюту по множителю \nx" .. coeff_offer.value )
        return false
    end

    if sum < coeff_offer.min_payment_sum then
        player:ShowError( "Минимальная сумма платежа " .. coeff_offer.min_payment_sum .. "р.")
        return false
    end

    triggerClientEvent( player, "onClientSelectLastWealthPackInBrowser", resourceRoot, PACK_ID, sum )
end
addEvent( "onServerPlayerTryPurchaseDonate", true )
addEventHandler( "onServerPlayerTryPurchaseDonate", resourceRoot, onServerPlayerTryPurchaseDonate_handler )


function ShowPlayerAction( player, first_show )
    if not isElement( player ) or player:GetLevel() < 3 or not IsOfferActive() then return end

    -- Не засираем перманентку, чистим при обновлении акции
    if CONST_OFFER_NUMBER ~= player:GetOfferNumber() then
        player:ResetOfferData()
        player:SetOfferNumber( CONST_OFFER_NUMBER )
    end

    if player:GetPermanentData( CONST_OFFER_NAME .. "_finish" ) then return end
    
    -- ВЫРЕЗАТЬ НАХУЙ ПОСЛЕ РЕЛИЗА!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    local is_battle_pass_active = exports.nrp_battle_pass:IsPlayerPremiumActive( player )
    if is_battle_pass_active then
        player:TryAddPartCompleteStep( "premium_battle_pass" )
    end
    local is_battle_pass_booster_acitve = exports.nrp_battle_pass:IsPlayerBoosterActive( player )
    if is_battle_pass_booster_acitve then
        player:TryAddPartCompleteStep( "booster_battle_pass" )
    end

    -- Учет краша при оплате через браузер и прочего говна
    player:TryCompleteStep()

    local data = 
    {
        exec_mul = player:GetExecutableMulStep(),
        cur_mul = player:GetCurrentMulStep(),
        cur_mul_step = player:GetMulSteps(),
    }

    triggerClientEvent( player, "onClientShowOfferLastWealth", resourceRoot, data, first_show )
end

function onPlayerReadyToPlay_handler()
    ShowPlayerAction( source, true )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function onServerPlayerRequestDataOfferLastWealth_handler()
    ShowPlayerAction( client )
end
addEvent( "onServerPlayerRequestDataOfferLastWealth", true )
addEventHandler( "onServerPlayerRequestDataOfferLastWealth", root, onServerPlayerRequestDataOfferLastWealth_handler )


if SERVER_NUMBER > 100 then
    addCommandHandler( "show_lw_offer", function( player )
        ShowPlayerAction( player, true )
    end )

    addCommandHandler( "pay_lw_offer", function( player, cmd, arg )
        local src_class_type_id = tostring( arg ):gsub( "[.]", "_" )
        player:TryAddPartCompleteStep( "payment_" .. src_class_type_id, 1 )
        player:ShowInfo( "Платеж выполнен" )
    end )

    addCommandHandler( "min_sum_lw_offer", function( player, cmd, arg )
        DEFAULT_MULTIPLY_DATA.min_payment_sum = 1
        for k, v in ipairs( LEVEL_MULTIPLY ) do
            v.min_payment_sum = 1
        end
        player:ShowInfo( "Платежи снижены до 1 рубля" )
    end )

    addCommandHandler( "reset_lw_offer", function( player )
        player:ResetOfferData()
        player:ShowInfo( "Оффер очищен" )
    end )
end