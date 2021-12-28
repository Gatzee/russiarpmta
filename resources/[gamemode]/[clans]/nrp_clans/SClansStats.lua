SESSION_STARTED = {}

function SetSessionStart( player )
	SESSION_STARTED[ player ] = getRealTimestamp( )
	player:SetPrivateData( "time_clan_login", SESSION_STARTED[ player ] )
end

function SetSessionEnd( player )
	if SESSION_STARTED[ player ] then
		local iTimePassed = getRealTimestamp( ) - SESSION_STARTED[ player ]
		player:AddClanStats( "total_time", math.floor( iTimePassed/60 ) )
		SESSION_STARTED[ player ] = nil
	end
end

function OnPlayerLogin( )
	if source:GetClanID( ) then
		SetSessionStart( source )
	end
end
addEvent( "onPlayerReadyToPlay" )
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerLogin, true, "low-1000" )

function OnPlayerQuit( )
	SetSessionEnd( source )
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, OnPlayerQuit )

addEventHandler( "onPlayerWasted", root, function( _, killer )
	if isElement( killer ) and getElementType( killer ) == "player" then
		local killer_clan_id = killer:GetClanID( )
		if not killer_clan_id then return end
		
		killer:AddClanStats( "total_kills", 1 )

		if source:GetClanID( ) ~= killer_clan_id  then
			killer:AddClanStats( "foe_kills", 1 )
			killer:CompleteDailyQuest( "band_kill_opponents" )
		end
	end
end )

addEventHandler ( "onPlayerDamage", root, function( attacker )
	if not isElement( attacker ) or getElementType( attacker ) ~= "player" then
		return
	end

	local source_clan_id = source:GetClanID( )
	if not source_clan_id then return end

	local attacker_clan_id = attacker:GetClanID( )
	if not attacker_clan_id then return end
	if source_clan_id == attacker_clan_id then return end

	local attackerData = attacker:getData( "cur_daily_quests" )

	if not attackerData then return end

	local quest_exist = false
	for _, v in pairs( attackerData ) do
		if v.id == "band_start_fight" then
			attacker:CompleteDailyQuest( "band_start_fight" )
			return
		end
	end
end )