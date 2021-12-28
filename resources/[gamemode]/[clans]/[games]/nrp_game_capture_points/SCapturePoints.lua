loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SInterior" )
Extend( "SClans" )
Extend( "ShAsync" )

DEBUG_DATA = {
	elements = { },
	timers = { }
 }

GAME_DATA = 
{
	participants = {},
	participants_data = {},
	score = { purple = 1, green = 1 },
}

function OnGameLobbyCreated( lobby_data )
	GAME_DATA.data = lobby_data.data
	GAME_DATA.participants = lobby_data.participants
	GAME_DATA.participants_data = lobby_data.participants_data
	GAME_DATA.dimension = lobby_data.dimension
	GAME_DATA.id = lobby_data.id
	GAME_DATA.points = {}
end
addEvent("CEV:OnGameLobbyCreated", true)
addEventHandler("CEV:OnGameLobbyCreated", resourceRoot, OnGameLobbyCreated)

function OnGameLobbyStateChanged( lobby_data )
	GAME_DATA.participants = lobby_data.participants
	GAME_DATA.participants_data = lobby_data.participants_data
	GAME_DATA.state = lobby_data.state

	if GAME_DATA.state == 4 then
		DEBUG_DATA.start_time = getRealTime( ).timestamp

		GAME_DATA.score = { purple = 1, green = 1 }

		for k,v in pairs(POINT_POSITIONS) do
			local conf = 
			{
				x = v.x, 
				y = v.y,
				z = v.z,
				name = v.name,
				dimension = GAME_DATA.dimension,
				point_id = k,
			}

			GAME_DATA.points[k] = CapturePoint_Create( conf )

			table.insert( DEBUG_DATA.elements, GAME_DATA.points[ k ] )
		end

		CreateEventVehicles( GAME_DATA.dimension )

		for k,v in pairs(GAME_DATA.participants) do
			v.dimension = GAME_DATA.dimension
			v.position = SPAWN_POSITIONS[ v:GetBandID() ]:AddRandomRange(5)

			addEventHandler("onPlayerPreWasted", v, OnPlayerPreWasted_handler)
			addEventHandler("onPlayerWasted", v, OnPlayerWasted_handler)
		end

		local pDataToSend =
		{
			time_left = GAME_DATA.data.game_duration, 
			scores = GAME_DATA.score,
		}

		triggerClientEvent( GAME_DATA.participants, "CEV:OnClientGameStarted", resourceRoot, pDataToSend )
	elseif GAME_DATA.state == 5 then
		FinishGame()
	end
end
addEvent("CEV:OnLobbyStateChanged", true)
addEventHandler("CEV:OnLobbyStateChanged", resourceRoot, OnGameLobbyStateChanged)

function OnPlayerLobbyJoin( pPlayer )
	pPlayer:Teleport( SPAWN_POSITIONS[ pPlayer:GetBandID() ]:AddRandomRange(5), GAME_DATA.dimension )
end
addEvent("CEV:OnPlayerLobbyJoin", true)
addEventHandler("CEV:OnPlayerLobbyJoin", resourceRoot, OnPlayerLobbyJoin)

function OnPlayerLobbyLeave( pPlayer )
	if isElement(pPlayer) then
		removeEventHandler("onPlayerPreWasted", pPlayer, OnPlayerPreWasted_handler)
		removeEventHandler("onPlayerWasted", pPlayer, OnPlayerWasted_handler)

		if not GAME_DATA.participants then return end

		for k,v in pairs(GAME_DATA.participants) do
			if v == pPlayer then
				table.remove(GAME_DATA.participants, k)
				break
			end
		end

		GAME_DATA.participants_data[ pPlayer ] = nil
	end
end
addEvent("CEV:OnPlayerLobbyLeave", true)
addEventHandler("CEV:OnPlayerLobbyLeave", resourceRoot, OnPlayerLobbyLeave)

function OnGameLobbyDestroyed()
	DEBUG_DATA.destroy_time = getRealTime( ).timestamp

	DestroyEventVehicles()

	for k,v in pairs(GAME_DATA.points or {}) do
		v:destroy()
	end

	GAME_DATA = {}
end
addEvent("CEV:OnLobbyDestroyed", true)
addEventHandler("CEV:OnLobbyDestroyed", resourceRoot, OnGameLobbyDestroyed)

function OnPlayerPreWasted_handler()
	cancelEvent()
end

function OnPlayerWasted_handler( _, killer )
	--iprint(killer)

	if isElement(killer) and getElementType(killer) == "player" then
		killer:GiveClanEXP( 2 )

		if killer:IsClanMember() then
            GiveClanEXP( killer:GetClanID(), 2 )
           --iprint(killer:GetClanID())
        end
	end
end

function OnPlayerRequestRespawn()
	if not isElement(client) then return end
	RespawnPlayer( client )
end
addEvent("CEV:OnPlayerRequestRespawn", true)
addEventHandler("CEV:OnPlayerRequestRespawn", resourceRoot, OnPlayerRequestRespawn)

function RespawnPlayer( player )
	if not isElement(player) then return end
	local vecPosition = SPAWN_POSITIONS[ player:GetBandID() ]:AddRandomRange(5)
	player:spawn( vecPosition, 0, player.model, GAME_DATA.interior or 0, GAME_DATA.dimension )
	player.health = 100
end

local iLastUpdate = 0

function UpdateScore( band, value )
	if not GAME_DATA.score then
		local lobby = exports.nrp_clans_events:GetLobbyByGameType( 2 )
		if lobby then
			exports.nrp_clans_events:DestroyLobby( lobby.id )
		else
			OnGameLobbyDestroyed( )
		end

		local not_deleted_points = 0
		for i, v in pairs( DEBUG_DATA.elements ) do
			if type( v ) == "table" and isElement( v.element ) then
				v:destroy( )
				not_deleted_points = not_deleted_points + 1
			end
		end

		local not_deleted_timers = 0
		for i, v in pairs( DEBUG_DATA.timers ) do
			if isTimer( v ) then
				killTimer( v )
				not_deleted_timers = not_deleted_timers + 1
			end
		end

		SendToLogserver( "[DEBUG] nrp_game_capture_points/SCapturePoints.lua", { 
			file_short = "SCapturePoints.lua",
			start = DEBUG_DATA.start_time or 0,
			destroy = DEBUG_DATA.destroy_time or 0, 
			points = not_deleted_points, 
			timers = not_deleted_timers, 
			lobby = lobby and 1 or 0, 
		} )
			
		return
	end

	GAME_DATA.score[band] = GAME_DATA.score[band] + value

	if getTickCount() - iLastUpdate >= 3000 then
		triggerClientEvent( GAME_DATA.participants, "CEV:UpdateGameUI", resourceRoot, { scores = GAME_DATA.score } )
		iLastUpdate = getTickCount()
	end

	if GAME_DATA.score[band] >= 800 then
		FinishGame()
	end
end

function FinishGame()
	if GAME_DATA.finished then return end
	
	local sWinners = GAME_DATA.score.green > GAME_DATA.score.purple and "green" or "purple"

	GAME_DATA.finished = true

	for k,v in pairs(GAME_DATA.participants) do
		if isPedDead(v) then
			RespawnPlayer( v )
		end
	end

	triggerClientEvent( GAME_DATA.participants, "CEV:OnClientGameFinished", resourceRoot, sWinners )

	triggerEvent("CEV:OnGameFinished", root, GAME_DATA.id, { band = sWinners })
end