function OnPlayerDataCollected( id )
	local quest = GetPlayerQuestHandler( client )
	if not quest then return end
	if quest:GetQuestData( "collected_data_"..id ) then return end

	quest:SetQuestData( "collected_data_"..id, true )

	local team_id = quest:GetPlayerTeam( client )
	local team_score = quest:GetTeamData( team_id, "score" ) or 0
	quest:SetTeamData( team_id, "score", team_score + 1 )

	triggerClientEvent( quest.players_list, "OnClientPlayerDataCollected", resourceRoot, id )

	client:ShowInfo( "Данные получены" )

	triggerClientEvent( quest.players_list, "OnClientTeamScoresSynced", resourceRoot, { quest:GetTeamData( 1, "score" ), quest:GetTeamData( 2, "score" ) } )
end
addEvent( "OnPlayerDataCollected", true )
addEventHandler( "OnPlayerDataCollected", resourceRoot, OnPlayerDataCollected )