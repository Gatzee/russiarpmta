
Player.GenerateTickedCode = function( self )
    return tonumber( SERVER_NUMBER .. string.format( "%09d", self:GetID() ) )
end

Player.GetRemainingTime = function( self )
    local remainig_time = self:GetPermanentData( OFFER_NAME .. "_remaining_time" )
    return remainig_time and math.max( 0, (remainig_time - self:GetTimeSession()) ) or -1
end

Player.SetRemainingTime = function( self, value )
    return self:SetPermanentData( OFFER_NAME .. "_remaining_time", value )
end

Player.SetTimestapmSession = function( self )
    return self:setData( "start_ingame_" .. OFFER_NAME, getRealTimestamp(), false )
end

Player.GetTimeSession = function( self )
    local start_ingame_draw = self:getData( "start_ingame_" .. OFFER_NAME )
    return start_ingame_draw and (getRealTimestamp() - start_ingame_draw) or 0
end

Player.IsSelectContact = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_is_select_contact" )
end

Player.MarkSelectedContact = function( self )
    return self:SetPermanentData( OFFER_NAME .. "_is_select_contact", true )
end

Player.IsHasTicket = function( self )
    return self:GetPermanentData( OFFER_NAME .. "_ticket" )
end

Player.MarkTicketCode = function( self )
    self:SetPermanentData( OFFER_NAME .. "_ticket", true )
end