
-- Доступность акции
Player.IsCanParticipateNewYearAuction = function( self )
    local timestamp = getRealTimestamp()
    if timestamp < OFFER_START_DATE or timestamp > OFFER_END_DATE then return false end

    local has_bike = false
    for k, v in ipairs( self:GetVehicles( false, true ) ) do
        if v.model == 522 then
            has_bike = true
            break
        end
    end

    return not has_bike and (self:IsPremiumActive() or self:GetPlayerRate() > 0)
end

-- Значение ставки
Player.GetPlayerRate = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_rate" ) or 0
end

Player.SetPlayerRate = function( self, value )
    self:SetRateNum( self:GetRateNum() + 1 )
    self:SetTimeoutRate( getRealTimestamp() + CONST_OFFER_TIMEOUT - 5 )
    return self:SetPermanentData( OFFER_NAME .. "_rate", value )
end

-- Количество ставок
Player.GetRateNum = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_rate_num" ) or 0
end

Player.SetRateNum = function( self, value )
    return self:SetPermanentData( OFFER_NAME .. "_rate_num", value )
end

-- Время таймаута
Player.GetTimeoutRate = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_timeout_rate" ) or 0
end

Player.SetTimeoutRate = function( self, value )
    return self:SetPermanentData( OFFER_NAME .. "_timeout_rate", value )
end

-- Общая сумма сброса таймаута
Player.GetDonateSumToDrop = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_sum_to_drop" ) or 0
end

Player.SetDonateSumToDrop = function( self, value )
    return self:SetPermanentData( OFFER_NAME .. "_sum_to_drop", value )
end


Player.SendMsg = function( self, msg, finish )
    self:ShowInfo( msg )
    self:PhoneNotification( {
        title   = "Новогодний аукцион",
        msg     = msg,
        special = "new_year_auction_rerate",
        finish  = finish,
	} )
end

Player.RefreshPlayerClientUI = function( self, data )
    local data = data or {}
    
    data.auction_leader = CURREN_LEADER_DATA
    data.cur_rate = self:GetPlayerRate()
    data.timeout = self:GetTimeoutRate()

    triggerClientEvent( self, "onClientRefreshRateRateUI", resourceRoot, data )
end



function ReturnPlayerBet( player, bet )
    ResetPlayerOfferData( player )
    if bet > 0 then
        player:GiveMoney( bet * 1000, "sale", "christmas_auction" )
        player:ShowInfo( "Ты не выиграл в новогоднем аукционе, компенсация: " .. format_price( bet ) .. "р." )
    end
end

function ResetPlayerOfferData( player )
    player:SetPlayerRate( 0 )
    
    player:SetPermanentData( OFFER_NAME .. "_show_first", false )
    player:SetDonateSumToDrop( nil )
    player:SetTimeoutRate( nil )
    player:SetRateNum( nil )
end