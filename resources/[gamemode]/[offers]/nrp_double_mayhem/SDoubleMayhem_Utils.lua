
-- Данные о купленных паках
Player.GetPackData = function( self, pack_id )
    return self:GetPermanentData( OFFER_NAME .. "_pack_data" ) or {}
end

Player.SetPackData = function( self, pack_data )
    self:SetPermanentData( OFFER_NAME .. "_pack_data", pack_data )
end

Player.IsAllPackPurchased = function( self )
    local count_purchased_packs = 0
    for k, v in pairs( self:GetPackData( ) ) do
        count_purchased_packs = count_purchased_packs + 1
    end
    return count_purchased_packs == #PACKS_STRING_ID
end

Player.GetPackState = function( self, pack_id )
    return self:GetPackData()[ pack_id ]
end

Player.SetPackState = function( self, pack_id, value )
    local pack_data = self:GetPackData()
    pack_data[ pack_id ] = value
    self:SetPackData( pack_data )
end

-- Текущая неполученная награда
Player.SetCurrentGiftReward = function( self, value )
    self:SetPermanentData( OFFER_NAME .. "_cur_reward", value )
end

Player.GetCurrentGiftReward = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_cur_reward" )
end

-- Открыл награду
Player.SetOpenGiftState = function( self, value )
    self:SetPermanentData( OFFER_NAME .. "_open_gift", value )
end

Player.IsOpenGift = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_open_gift" )
end

-- Состояние 1 показа
Player.SetShowFirstState = function( self, state )
    self:SetPermanentData( OFFER_NAME .. "_is_show_first", state )
end

Player.IsShowFirst = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_is_show_first" )
end

-- Идентификатор для очистки данных, нехуй складировать данные
Player.GetLastDoubleMayhemId = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_last_dm_id" )
end

Player.SetLastDoubleMayhemId = function( self, id )
    return self:SetPermanentData( OFFER_NAME .. "_last_dm_id", id )
end

-- Очистка данных оффера
Player.ResetOffer = function( self )
    self:SetPackData( false )
    self:SetShowFirstState( false )
    self:SetOpenGiftState( false )
end