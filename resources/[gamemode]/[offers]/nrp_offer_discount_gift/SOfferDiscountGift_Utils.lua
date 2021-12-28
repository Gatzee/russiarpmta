
-- Функционал сохранения/загрузки данных скидок оффера
Player.AddOfferSpecialDiscount = function( self, discount_data )
    self:AddSpecialCouponDiscount( discount_data )
    return true
end

-- Функционал для аналитики
Player.IsOfferShowFirst = function( self )
    return self:GetPermanentData( OFFER_NAME .. "is_show_first" ) == nil
end

Player.SetOfferShowFirst = function( self, value )
    return self:SetPermanentData( OFFER_NAME .. "is_show_first", value )
end


-- Функционал для купленных паков(UI)
Player.AddPackBought = function( self, pack_id )
    local packs_bought = self:GetBoughtPacks()
    packs_bought[ pack_id ] = true
    self:SetPermanentData( OFFER_NAME .. "packs_bought", packs_bought )

    return true
end

Player.GetBoughtPacks = function( self )
    return self:GetPermanentData( OFFER_NAME .. "packs_bought" ) or {}
end

Player.IsAllPacksBought = function( self )
    local count_bought_pack = 0
    for k, v in pairs( self:GetBoughtPacks() ) do
        count_bought_pack = count_bought_pack + 1
    end
    return count_bought_pack == #PACK_DATA, count_bought_pack
end

Player.ClearAllPackBought = function( self )
    self:SetPermanentData( OFFER_NAME .. "packs_bought", nil )
    return true
end


-- Функционал для обработки слуая, когда все паки куплены(скидон до конца акции, без обновлений)
Player.SetAllDiscounts = function( self, value )
    self:SetPermanentData( OFFER_NAME .. "has_all_discounts", value )
    return true
end

Player.HasAllDiscounts = function( self )
    return self:GetPermanentData( OFFER_NAME .. "has_all_discounts" ) or false
end


-- Очистка данных оффера после акции/при тестировании
Player.ClearDiscountGiftOffer = function( self )
    self:SetPrivateData( "offer_discount_gift_time_left", false )
    self:SetSpecialCouponsDiscount( false )
    self:SetOfferShowFirst( nil )
    self:ClearAllPackBought()
    self:SetAllDiscounts( nil )
end