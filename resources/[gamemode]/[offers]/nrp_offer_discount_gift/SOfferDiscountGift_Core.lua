Extend( "Globals" )
Extend( "SPlayer" )

function onPlayerReadyToPlay_handler()
    local player = source
    if not isElement( player ) or player:GetLevel() < 3 then return end

    if not IsOfferActive() then
        player:ClearDiscountGiftOffer()
        return
    end
    
    player:SetPrivateData( "offer_discount_gift_time_left", OFFER_END_DATE )

    if player:IsOfferShowFirst() then
        player:SetOfferShowFirst( true )
        onOfferDiscountGiftShowFirst( player )
    else
        local special_coupons_discount = player:GetSpecialCouponsDiscount()
        if next( special_coupons_discount ) then
            player:SetSpecialCouponsDiscount( special_coupons_discount )
        end
    end

    local is_all_pack_bought, num_purchased_packs = player:IsAllPacksBought()
    local data = 
    {
        num_purchased_packs = num_purchased_packs,
    }
    triggerClientEvent( player, "onClientShowOfferDiscountGift", resourceRoot, data )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function onServerPlayerPurchaseDiscountGiftPack_handler( player, sum )
    local bought_pack_index = nil
    for k, v in pairs( PACK_DATA ) do
        if v.cost == sum then
            bought_pack_index = k
            break
        end
    end
    if not bought_pack_index then return end

    player:AddPackBought( bought_pack_index )
    
    local pack_data = PACK_DATA[ bought_pack_index ]
    player:GiveDonate( pack_data.value_sum, "donate_pack", "donate_offer_discount" )

    local is_all_pack_bought, num_purchased_packs = player:IsAllPacksBought()
    triggerClientEvent( player, "onClientShowOfferDiscountGiftPackReward", resourceRoot, bought_pack_index, num_purchased_packs )

    onOfferDiscountGiftPurchase( player, pack_data )

    if not IsOfferActive() then return end

    if not player:HasAllDiscounts() and is_all_pack_bought then
        player:SetAllDiscounts( true )
        player:AddOfferSpecialDiscount( PACK_DATA_ALL_DISCOUNTS )
    end
    player:AddOfferSpecialDiscount( pack_data.discount_data )
end
addEvent( "onServerPlayerPurchaseDiscountGiftPack" )
addEventHandler( "onServerPlayerPurchaseDiscountGiftPack", root, onServerPlayerPurchaseDiscountGiftPack_handler )



if SERVER_NUMBER > 100 then
    addCommandHandler( "clear_dg", function( player )
        player:ClearDiscountGiftOffer()
        player:ShowInfo( "Данные оффера сброшены" )
    end )

    addCommandHandler( "min_cost_dg", function( player )
        local cost = 1
        for pack_index, pack_data in pairs( PACK_DATA ) do
            pack_data.cost = cost
            cost = cost + 1
        end
        triggerClientEvent( player, "onClientUseTestCosts", resourceRoot )
        player:ShowInfo( "Минимальные цены установлены" )
    end )

    addCommandHandler( "add_coupons_dg", function( player )
        for _, pack_data in pairs( PACK_DATA ) do
            player:AddOfferSpecialDiscount( pack_data.discount_data )
        end
        player:AddOfferSpecialDiscount( PACK_DATA_ALL_DISCOUNTS )

        for k, v in pairs( player:GetSpecialCouponsDiscount() ) do
            iprint( player:GetSpecialCouponsDiscount()  )
        end
        player:ShowInfo( "Купоны добавлены" )
    end )
end