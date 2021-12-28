
---------------------------------------------------
-- Progression points
---------------------------------------------------

Player.AddProgressionPoints = function( self, id, variant, count )
    local new_count_points = self:GetProgressionPointsCount( id ) + (CONST_PROGRESSION_POINTS_FOR_LOTTERY_VARIANT[ variant ] * count)
    self:SetProgressionPoints( id, new_count_points )
    return new_count_points
end

Player.SetProgressionPoints = function( self, id, value )
    local progression_points_data = self:GetProgressionPointsData()
    progression_points_data[ id ] = value
    self:SetPermanentData( "ltr_progression_points", progression_points_data )
end

Player.GetProgressionPointsData = function( self )
    return self:GetPermanentData( "ltr_progression_points" ) or {}
end

Player.GetProgressionPointsCount = function( self, id )
    local progression_points_data = self:GetProgressionPointsData()
    return progression_points_data[ id ] or 0
end

Player.ClearProgressionPoints = function( self )
    self:SetPermanentData( "ltr_progression_points", nil )
end


---------------------------------------------------
-- Received Progression Rewards
---------------------------------------------------

Player.SetReceivedReward = function( self, id, is_premium, reward_id )
    local awards = self:GetReceivedAwards()
    if not awards[ id ] then awards[ id ] = { Premium = {}, Common = {} } end
    awards[ id ][ is_premium and "Premium" or "Common" ][ reward_id ] = true
    self:SetPermanentData( "ltr_received_awards", awards )
end

Player.GetReceivedAwards = function( self )
    local result = {}
    for lottery_id, lottery_data in pairs( self:GetPermanentData( "ltr_received_awards" ) or {} )  do
        result[ lottery_id ] = {}
        for lottery_type, lottery_reward_data in pairs( lottery_data ) do
            result[ lottery_id ][ lottery_type ] = {}
            for k, v in pairs( lottery_reward_data ) do
                result[ lottery_id ][ lottery_type ][ tonumber( k ) ] = v
            end
        end
    end
    return result
end

Player.IsRewardReceived = function( self, id, reward_id )
    local rewards_data = self:GetReceivedAwards()
    if not rewards_data[ id ] then return false end
    return rewards_data[ id ][ "Premium" ][ reward_id ] ~= nil or rewards_data[ id ][ "Common" ][ reward_id ] ~= nil
end

Player.ClearReceivedAwards = function( self, id )
    self:SetPermanentData( "ltr_received_awards", nil )
end

---------------------------------------------------
-- Seasons
---------------------------------------------------

Player.GetLastSeasonNum = function( self )
    return self:GetPermanentData( "ltr_last_season_ts" ) or 0
end

Player.SetLastSeasonNum = function( self, ts )
    self:SetPermanentData( "ltr_last_season_ts", ts )
end


---------------------------------------------------
-- Tickets
---------------------------------------------------

Player.AddPurchasedTicket = function( self, id, variant, count )
    self:SetNumberOfPurchasedTickets( id, variant, math.max( 0, self:GetCountPurchasedTickets( id, variant ) + count ) )
end

Player.TakePurchasedTicket = function( self, id, variant, count )
    self:SetNumberOfPurchasedTickets( id, variant, math.max( 0, self:GetCountPurchasedTickets( id, variant ) - count ) )
end

Player.GetPurchasedTickets = function( self, id )
    local result = {}
    for id, tickets in pairs( self:GetPermanentData( "ltr_purchased_tickets" ) or {} ) do
        for variant, count in pairs( tickets ) do
            if count > 0 then
                if not result[ id ] then result[ id ] = {} end
                table.insert( result[ id ], tonumber( variant ), count )
            end
        end
    end
    return result
end

Player.GetCountPurchasedTickets = function( self, id, variant )
    local ltr_purchased_tickets = self:GetPurchasedTickets()
    return ltr_purchased_tickets[ id ] and ltr_purchased_tickets[ id ][ variant ] or 0
end

Player.SetNumberOfPurchasedTickets = function( self, id, variant, value )
    local purchased_tickets = self:GetPurchasedTickets( id )
    if not purchased_tickets[ id ] then purchased_tickets[ id ] = {} end
    purchased_tickets[ id ][ variant ] = value
    self:SetPermanentData( "ltr_purchased_tickets", purchased_tickets )
end

---------------------------------------------------
-- Queue purchase tickets
---------------------------------------------------

Player.AddQueueCountLotteryTicket = function( self, count )
    self:setData( "ltr_queue_ticket_count", count + self:GetQueueCountLotteryTicket(), false )
end

Player.GetQueueCountLotteryTicket = function( self )
    return self:getData( "ltr_queue_ticket_count" ) or 0
end

Player.ResetQueueCountLotteryTicket = function( self )
    self:setData( "ltr_queue_ticket_count", false, false )
end