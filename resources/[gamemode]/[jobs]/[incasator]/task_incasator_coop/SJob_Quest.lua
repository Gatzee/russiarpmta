Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "SQuestCoop" )

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuestCoop( QUEST_DATA )
end )

-- Начало смены
function onServerIncasatorStartWork_handler( lobby )
	local lobby_id = lobby.lobby_id
	local lobby_data = GetLobbyDataById( lobby_id )
	if lobby_data then
		WriteLog("#1 ERROR CREATE LOBBY TASK TOWTRUCKER")
		return false
	end
	lobby.job_weapon = table.copy( INCASATOR_WEAPONS_DATA )
	lobby_data = CreateLobbyData( lobby_id, lobby )
	PreStartQuest( lobby_data )

	local participants = lobby_data.participants
	for idx, v in pairs( participants ) do
		v.player:CompleteDailyQuest( "np_start_incasator" )
		v.player:CompleteDailyQuest( "start_shift" )

		if #participants >= 4 then
			v.player:CompleteDailyQuest( "np_start_incasator_4" )
		end
	end
end
addEvent( "onServerIncasatorStartWork" )
addEventHandler( "onServerIncasatorStartWork", root, onServerIncasatorStartWork_handler )

-- Проверка на кол-во пассажиров в транспорте, после старта
function PreStartQuest( lobby_data )
	lobby_data.check_start_tmr = setTimer( function()
		if GetVehicleCountOccupants( lobby_data.job_vehicle ) < 2 then
			triggerEvent( "PlayerFailStopCoopQuest", resourceRoot, lobby_data.lobby_id, "Ключевой участник покинул смену", "fail_count_players" )
		else
			
			lobby_data.count_delivered_bags = 0			
			AddIncasatorVehicleHandlers( lobby_data )

			triggerClientEvent( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), "onClientCancelIncasatorVehicleDamage", resourceRoot, true )
		end
	end, 2000, 1 )
end

-- Окончание смены
function onServerIncasatorEndWork_handler( lobby_id, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	if isTimer( lobby_data.check_start_tmr ) then
		killTimer( lobby_data.check_start_tmr )
	end

	for k, v in pairs( lobby_data.participants ) do
		RestoreData( v.player, v.role, lobby_data.lobby_id )
		-- Аналитика: Окончание смены
		onIncasatorJobFinish( v.player, lobby_data, reason_data )
	end

	triggerClientEvent( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), "onClientCancelIncasatorVehicleDamage", resourceRoot, false )
end
addEvent( "onServerIncasatorEndWork" )
addEventHandler( "onServerIncasatorEndWork", root, onServerIncasatorEndWork_handler )

-- Игрок покинул работу
function onServerPlayerLeaveLobbyCoopQuest_handler( lobby_id, player, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	local player_data = GetPlayerData( lobby_id, player )
	if GetPlayerBag( player ) then
		onGuardLeaveQuestWithBag( player, player_data.role, lobby_data )
	end
	
	RestoreData( player, player_data.role, lobby_data.lobby_id )
	-- Аналитика: Окончание смены
	onIncasatorJobFinish( player, lobby_data, reason_data )

	triggerClientEvent( player, "onClientCancelIncasatorVehicleDamage", resourceRoot, false )
end
addEvent( "onServerPlayerLeaveLobbyCoopQuest" )
addEventHandler( "onServerPlayerLeaveLobbyCoopQuest", root, onServerPlayerLeaveLobbyCoopQuest_handler )

-- Обработка любого окончания смены
function onAnyFinishIncasator( lobby_id, finish_state )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end
	
	HideCallPPS( lobby_data )
	RemovePPSNotifications( lobby_data )

	DestroyBagsData( lobby_data )
end

-- Награда
function onCoopJobCompletedLap_handler( player, lobby_id, money, exp )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	-- Аналитика: Окончание рейса
	oNIncasatorJobFinishVoyage( player, lobby_data, money or 0, exp or 0 )
end
addEvent( "onCoopJobCompletedLap" )
addEventHandler( "onCoopJobCompletedLap", resourceRoot, onCoopJobCompletedLap_handler )