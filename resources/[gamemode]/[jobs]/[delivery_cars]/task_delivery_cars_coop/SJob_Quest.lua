Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "SQuestCoop" )

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuestCoop( QUEST_DATA )
end )

-- Начало смены
function onServerDeliveryCarsStartWork_handler( lobby )
	local lobby_id = lobby.lobby_id
	local lobby_data = GetLobbyDataById( lobby_id )
	if lobby_data then
		WriteLog("#1 ERROR CREATE LOBBY TASK TOWTRUCKER")
		return false
	end

	lobby_data = CreateLobbyData( lobby_id, lobby )
	for k, v in pairs( lobby_data.participants ) do
		v.player:setData( "count_speak", 0, false )
		v.player:setData( "count_sms", 0, false )

		v.player:CompleteDailyQuest( "np_start_delivery_car" )
		v.player:CompleteDailyQuest( "start_shift" )
	end
end
addEvent( "onServerDeliveryCarsStartWork" )
addEventHandler( "onServerDeliveryCarsStartWork", root, onServerDeliveryCarsStartWork_handler )

-- Окончание смены
function onServerDeliveryCarsEndWork_handler( lobby_id, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	for k, v in pairs( lobby_data.participants ) do
		onDeliveryCarsJobFinish( v.player, lobby_data, reason_data )
		v.player:setData( "count_speak", false, false )
		v.player:setData( "count_sms", false, false )
	end
end
addEvent( "onServerDeliveryCarsEndWork" )
addEventHandler( "onServerDeliveryCarsEndWork", root, onServerDeliveryCarsEndWork_handler )

-- Игрок покинул работу
function onServerPlayerLeaveLobbyCoopQuest_handler( lobby_id, player, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	player:setData( "count_speak", false, false )
	player:setData( "count_sms", false, false )

	-- Аналитика: Окончание смены
	onDeliveryCarsJobFinish( player, lobby_data, reason_data )
end
addEvent( "onServerPlayerLeaveLobbyCoopQuest" )
addEventHandler( "onServerPlayerLeaveLobbyCoopQuest", root, onServerPlayerLeaveLobbyCoopQuest_handler )

-- Награда
function onCoopJobCompletedLap_handler( player, lobby_id, money, exp )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	-- Аналитика: Окончание рейса
	onDeliveryCarsJobFinishVoyage( player, lobby_data, money or 0, exp or 0 )

	player:setData( "count_speak", 0, false )
	player:setData( "count_sms", 0, false )
end
addEvent( "onCoopJobCompletedLap" )
addEventHandler( "onCoopJobCompletedLap", resourceRoot, onCoopJobCompletedLap_handler )
