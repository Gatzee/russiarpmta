Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

-- Маркер входа
function onServerInterfaceOpenRequest_handler( marker_id, job_class )
	local player = client or source
	if not player:CheckJoinJob( job_class, marker_id ) then return end

	if player:IsInFaction( ) and not player:IsOnFactionDayOff( ) then
		player:ShowInfo( "Ты находишься во фракции, возьми отгул и приходи!" )
		return false
	end

	local marker = JOB_DATA[ job_class ].markers_positions[ marker_id ]
	if marker and marker.fn then
		local result = marker.fn( player )
		if not result then return end
	end

	local lobby_id = player:GetCoopJobLobbyId()
	player:ShowJobUI( lobby_id, job_class, LOBBY_LIST[ lobby_id ] and LOBBY_LIST[ lobby_id ].owner == player or true )
end
addEvent( "onServerInterfaceOpenRequest", true )
addEventHandler( "onServerInterfaceOpenRequest", root, onServerInterfaceOpenRequest_handler )

function onResourceStop_handler( )
	for k, v in pairs( LOBBY_LIST ) do
		v:Destroy( true, 
		{
			fail_type = "resource_stop",
		} )
	end
end
addEventHandler( 'onResourceStop', resourceRoot, onResourceStop_handler, true, 'high+1000' )

----------------------------------------------------------------------------------------
-- Взаимодействие с интерфейсом
----------------------------------------------------------------------------------------

-- Создание лобби
function onServerCreateLobby_handler( city, job_class )
	if not job_class or not JOB_ID[ job_class ] then return end

	local wokr_conf = 
	{
		owner = client,
		job_class = job_class,
		city = city,
		players_search_duration = 0,
	}
	local lobby = CreateLobby( wokr_conf )
end
addEvent( "onServerCreateLobby", true )
addEventHandler( "onServerCreateLobby", root, onServerCreateLobby_handler )

-- Удаление игрока из лобби по кнопке
function onServerRemovePlayer_handler( player )
	local lobby = GetLobbyFromElement( client, true )
	if not lobby or lobby.lobby_state == LOBBY_STATE_START_WORK then return end

	for k, participant in pairs( lobby.participants ) do
		if participant.player == player then
			lobby:PlayerLeave( participant.player )
			break
		end
	end
end
addEvent( "onServerRemovePlayer", true )
addEventHandler( "onServerRemovePlayer", resourceRoot, onServerRemovePlayer_handler )

-- Смена роли
function onServerChangePlayerRole_handler( player, role_id )
	local lobby = GetLobbyFromElement( client, true )
	if not lobby or lobby.lobby_state == LOBBY_STATE_START_WORK then return end

	lobby:ChangeRole( player, role_id )
end
addEvent( "onServerChangePlayerRole", true )
addEventHandler( "onServerChangePlayerRole", resourceRoot, onServerChangePlayerRole_handler )

-- Отправка приглашения игроку по нику
function onServerSendInvitePlayer_handler( player )
	local lobby = GetLobbyFromElement( client, true )
	if not lobby or lobby.lobby_state == LOBBY_STATE_START_WORK or client == player then return end

	lobby:SendInviteTargetPlayer( client, player )
end
addEvent( "onServerSendInvitePlayer", true )
addEventHandler( "onServerSendInvitePlayer", resourceRoot, onServerSendInvitePlayer_handler )

-- Обработка кнопки "Поиск"
function onServerSearch_handler( operation )
	local lobby = GetLobbyFromElement( client, true )
	if not lobby or lobby.lobby_state == LOBBY_STATE_START_WORK then return end

	if operation == SEARCH_STATE_START then
		if lobby:IsSearchTimeOut() then
			return 
		end

		lobby.start_search_time = getRealTimestamp()
		lobby:SendInviteAllPlayers( )
	elseif operation == SEARCH_STATE_CANCEL then
		lobby.players_search_duration = getRealTimestamp() - lobby.start_search_time
		lobby:DeleteInviteAllPlayers( false )
	end
end
addEvent( "onServerSearch", true )
addEventHandler( "onServerSearch", resourceRoot, onServerSearch_handler )

-- Начать работу
function onServerPreStartWork_handler( )
	local lobby = GetLobbyFromElement( client, true )
	if not lobby or lobby.lobby_state == LOBBY_STATE_START_WORK then return end

	lobby:PreStartWork()
end
addEvent( "onServerPreStartWork", true )
addEventHandler( "onServerPreStartWork", resourceRoot, onServerPreStartWork_handler )

-- Присоединение игрока к лобби
function onServerJoinCoopJobLobby_handler( lobby_id )
	if client:GetCoopJobLobbyId() then
		client:ShowError( "Ты уже находишься в лобби" )
		return false
	end

	local lobby = LOBBY_LIST[ lobby_id ]
	if not lobby or lobby.lobby_state == LOBBY_STATE_START_WORK then return end

	lobby:PlayerJoin( client )
	client:HideJobUI()
end
addEvent( "onServerJoinCoopJobLobby", true )
addEventHandler( "onServerJoinCoopJobLobby", root, onServerJoinCoopJobLobby_handler )

-- Игрок покинул смену
function onServerLeaveCoopJobLobby_handler( fail_type )
	local player = client or source
    local lobby = GetLobbyFromElement( player )
	if not lobby then 
		if player:GetJobClass() then
			player:SetJobClass()
		end
		return false 
	end

	local is_destroy = lobby:PlayerLeave( player, 
	{
		failed = true,
		fail_text = "Ключевой участник покинул смену",
		fail_type = fail_type,
	} )

	player:HideJobUI()
	
	if not is_destroy then
		player:ShowInfo( "Ты завершил смену" )
	end
end
addEvent( "onServerLeaveCoopJobLobby", true )
addEventHandler( "onServerLeaveCoopJobLobby", root, onServerLeaveCoopJobLobby_handler )

function ResetPlayerShiftData( player )
	if player:GetShiftActive() then
		local shift = player:GetPermanentData( "job_shift" ) or { }
		shift.last_started = nil

		player:SetPermanentData( "job_shift", shift )
		player:SetPrivateData( "job_shift", shift )
	end
end

function onPlayerCompleteLogin_handler( )
	ResetPlayerShiftData( source )
	
	if source:GetJobClass() then
		source:SetJobClass()
    	source:SetJobID()
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function onResourceStart_handler( )
	for k, v in ipairs( getElementsByType( "player" ) ) do
		ResetPlayerShiftData( v )
	end
end
addEventHandler( 'onResourceStart', resourceRoot, onResourceStart_handler, true, 'high+1000' )