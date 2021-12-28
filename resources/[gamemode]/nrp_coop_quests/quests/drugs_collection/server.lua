function OnPlayerTryPickupQuestItem( tid )
	local quest = GetPlayerQuestHandler( client )
	if not quest then return end

	for k,v in pairs( quest.players_data ) do
		if v.holding_item == tid then
			return 
		end
	end

	quest:SetPlayerData( client, "holding_item", tid )

	if quest.stage == 2 then
		local team_id = quest:GetPlayerTeam( client )
		if team_id then
			if not quest:GetTeamData( team_id, "reached_first_location" ) then
				quest:SetTeamTask( team_id, _, "Ожидание другой команды" )
				quest:SetTeamData( team_id, "reached_first_location", true )
			end
		end
	end

	if isElement( quest.col_finish ) then
		if isElementWithinColShape( client, quest.col_finish ) then
			quest:SetQuestData( "item_on_point", false )
		end
	end

	triggerClientEvent( quest.players_list, "OnPlayerPickupQuestItem", resourceRoot, client, tid )
end
addEvent( "OnPlayerTryPickupQuestItem", true )
addEventHandler( "OnPlayerTryPickupQuestItem", resourceRoot, OnPlayerTryPickupQuestItem )

function OnPlayerTryDropQuestItem( player )
	local player = client or player

	local quest = GetPlayerQuestHandler( player )
	if not quest then return end

	local tid = quest:GetPlayerData( player, "holding_item" )
	if not tid then return end

	quest:SetPlayerData( player, "holding_item", false )
	triggerClientEvent( quest.players_list, "OnPlayerDropQuestItem", resourceRoot, player, tid )

	if isElement( quest.col_finish ) then
		if isElementWithinColShape( player, quest.col_finish ) then
			quest:SetQuestData( "item_on_point", true )
		end
	end
end
addEvent( "OnPlayerTryDropQuestItem", true )
addEventHandler( "OnPlayerTryDropQuestItem", resourceRoot, OnPlayerTryDropQuestItem )