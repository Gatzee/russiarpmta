local SEARCHING_PLAYERS = { }

function OnPlayerRequestToggleSearch( player, force_stop, location_id )
	local player = client or player
	local lobby = GetPlayerLobby( player )
	if lobby then 
		lobby:RemovePlayer( player )
		return 
	end

	if SEARCHING_PLAYERS[ player ] or force_stop then
		SEARCHING_PLAYERS[ player ] = nil
		removeEventHandler("onPlayerPreLogout", player, OnPlayerSearchPreLogout_handler)
		triggerClientEvent( player, "OnClientLobbyDataSynced", resourceRoot, { is_searching = false } )
	else
		local is_allowed, reason = CanPlayerJoinCoopQuest( player )
		if not is_allowed then
			player:ShowError( reason )
			return
		end

		SEARCHING_PLAYERS[ player ] = location_id
		addEventHandler("onPlayerPreLogout", player, OnPlayerSearchPreLogout_handler)
		triggerClientEvent( player, "OnClientLobbyDataSynced", resourceRoot, { is_searching = true } )
	end
end
addEvent( "OnPlayerRequestToggleSearch", true )
addEventHandler( "OnPlayerRequestToggleSearch", resourceRoot, OnPlayerRequestToggleSearch )

function OnPlayerSearchPreLogout_handler( )
	if SEARCHING_PLAYERS[ source ] then
		SEARCHING_PLAYERS[ source ] = nil
	end
end

function SearchImpulse( )
	local players_list = { }

	for player, state in pairs( SEARCHING_PLAYERS ) do
		table.insert( players_list, player )
	end

	if #players_list <= 1 then return end

	local function CombineTeam( player )
		if #players_list <= 1 then return end

		local location_id = SEARCHING_PLAYERS[ player ]

		table.remove( players_list, 1 )

		local teammate = players_list[ math.random( #players_list ) ]

		OnPlayerRequestToggleSearch( player, true )
		OnPlayerRequestToggleSearch( teammate, true )

		local new_lobby = CreateQuestLobby( )
		new_lobby:AddPlayer( player, 1, location_id )
		new_lobby:AddPlayer( teammate, 1 )
	end

	repeat
		CombineTeam( players_list[1] )
	until
		#players_list <= 1
end
setTimer( SearchImpulse, 3000, 0 )

function CanPlayerJoinCoopQuest( player )
	local is_allowed, reason = player:CanJoinToEvent( )

	if player:GetCoopQuestAttempts( ) <= 0 then
		is_allowed = false
		reason = "Вы исчерпали свой лимит заданий на сегодня"
	end

	if not player:HasLicense( LICENSE_TYPE_AUTO ) then
		is_allowed = false
		reason = "Требуются права категории \"B\""
	end

	if player:getData( "current_quest" ) then
		is_allowed = false
		reason = "Закончи текущую задачу!"
	end

	if player.interior ~= 0 or player.dimension ~= 0 then
		is_allowed = false
		reason = "Нельзя начинать квест отсюда!"
	end

	if player:IsOnFactionDuty( ) then
		is_allowed = false
		reason = "Нельзя принимать участие на смене!"
	end

	return is_allowed, reason
end