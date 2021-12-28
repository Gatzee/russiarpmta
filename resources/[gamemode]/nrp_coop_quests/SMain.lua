Extend( "SInterior" )
Extend( "SVehicle" )
Extend( "rewards/Server" )

COOP_QUEST_ATTEMPTS_IGNORED = false

Player.GetCoopQuestKeys = function( self )
	return self:GetPermanentData( "coop_quest_keys" ) or 0
end

Player.SetCoopQuestKeys = function( self, value )
	if not value or not tonumber( value ) then return end
	local value = tonumber( value )

	self:SetPrivateData( "coop_quest_keys", value )
	return self:SetPermanentData( "coop_quest_keys", value )
end

Player.TakeCoopQuestKeys = function( self, value )
	if not value or not tonumber( value ) then return end
	local old_value = self:GetCoopQuestKeys( )

	return self:SetCoopQuestKeys( old_value - value )
end

Player.GiveCoopQuestKeys = function( self, value )
	if not value or not tonumber( value ) then return end
	local old_value = self:GetCoopQuestKeys( )

	return self:SetCoopQuestKeys( old_value + value )
end

Player.GetCoopQuestAttempts = function( self )
	return self:GetPermanentData( "coop_quest_attempts" ) or 0
end

Player.SetCoopQuestAttempts = function( self, value )
	if not value or not tonumber( value ) then return end
	local value = tonumber( value )

	self:SetPrivateData( "coop_quest_attempts", value )
	return self:SetPermanentData( "coop_quest_attempts", value )
end

Player.TakeCoopQuestAttempts = function( self, value )
	if not value or not tonumber( value ) then return end
	local old_value = self:GetCoopQuestAttempts( )

	if COOP_QUEST_ATTEMPTS_IGNORED then
		return true
	end

	return self:SetCoopQuestAttempts( old_value - value )
end

Player.GiveCoopQuestAttempts = function( self, value )
	if not value or not tonumber( value ) then return end
	local old_value = self:GetCoopQuestAttempts( )

	return self:SetCoopQuestAttempts( old_value + value )
end

function OnPlayerReadyToPlay( player )
	local player = isElement( player ) and player or source

	player:SetPrivateData( "coop_quest_keys", player:GetCoopQuestKeys( ) )
	player:SetPrivateData( "coop_quest_attempts", player:GetCoopQuestAttempts( ) )

	local today_timestamp = getCurrentDayTimestamp( )
    local last_attempts_reset = player:GetPermanentData( "last_daily_coop_quests_reset" ) or 0
    
    if last_attempts_reset ~= today_timestamp then
    	player:SetPermanentData( "last_daily_coop_quests_reset", today_timestamp )
        player:SetCoopQuestAttempts( 2 )
    end
end
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerReadyToPlay, _, "low" )