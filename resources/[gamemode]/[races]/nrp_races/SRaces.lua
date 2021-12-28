loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SPlayer")
Extend("SPlayerOffline")
Extend("SInterior")
Extend("ShVehicleConfig")
Extend("SDB")
Extend("SClans")
Extend( "race_tracks/track_drag_track" )
Extend( "race_tracks/track_sochi_drift" )
Extend( "race_tracks/track_sochi_track" )

local SEARCHING_PLAYERS = {}
local SEARCH_TIMEOUTS = {}

RACE_LOBBIES = {}
LAST_ID = 1

function ReadTrack( sFileName, bOnlyTable )
	if TRACKS[sFileName] then
		TRACKS[sFileName].name = sFileName
		return table.copy( TRACKS[sFileName] )
	end

	return false
end

function OnPlayerRequestTrack( sName, sHash )
	triggerClientEvent(client, "RC:ReceiveTrack", resourceRoot, sName, GetPlayerLobby( client ))
end
addEvent("RC:OnPlayerRequestTrack", true)
addEventHandler("RC:OnPlayerRequestTrack", resourceRoot, OnPlayerRequestTrack)

-- Создание лобби
function CreateRaceLobby( data )
	local data = data or {}
	local self = {}

	self.id = LAST_ID
	self.track = ReadTrack( data.track, true )

	if not self.track then 
		return false, "Ошибка: выбранный трек не существует"
	end

	self.race_results = {}
	self.race_type = self.track.allowed_types[ 1 ]
	self.min_participants = RACE_TYPES_DATA[ self.race_type ].min_participants
	self.max_participants = RACE_TYPES_DATA[ self.race_type ].max_participants
	self.class = data.class or 1
	self.stats = data.stats or 200
	self.state = self.race_type == RACE_TYPE_DRAG and LOBBY_STATE_SEARCHING or LOBBY_STATE_CLOSED
	self.participants_data = {}
	self.participants = {}
	self.elements = {}
	self.rejections = {}
	self.bet = data.bet or 0
	self.rival = data.rival

	self.PlayerRequestJoin = function( self, pPlayer, pVehicle )
		if pVehicle:getData( "tow_evac_added" ) or pVehicle:getData( "tow_evacuated_real" ) or pVehicle:getData( "work_lobby_id" ) then
			pPlayer:ShowError( "Это авто ожидает эвакуации или уже эвакуируется" )
			return false
		end

		local available_vehicles = OnPlayerStartVehiclePreview( pPlayer, self.race_type )
		if not available_vehicles or #available_vehicles == 0 then
			pPlayer:ShowError( "У вас нет подходящего автомобиля для Гонки: " .. RACE_TYPES_DATA[ self.race_type ] )
			return false
		end

		if #self.participants >= self.max_participants then
			pPlayer:ShowError( "Лобби уже переполнено" )
			return false
		end

		if self.state ~= LOBBY_STATE_SEARCHING then
			pPlayer:ShowError( "Ошибка подключения (лобби закрыто)" )
			return false
		end

		self:PlayerJoin( pPlayer, pVehicle )

		return true
	end

	self.PlayerJoin = function( self, pPlayer, pVehicle, is_host )
		self.participants_data[ pPlayer ] = 
		{
			player_hp 		  = pPlayer.health,
			player_position   = pPlayer.position + Vector3( 0, 0, 1 ),
			player_interior   = pPlayer.interior,
			player_dimension  = pPlayer.dimension,
			vehicle 		  = pVehicle,
			vehicle_health    = pVehicle.health,
			vehicle_position  = pVehicle.position,
			vehicle_interior  = pVehicle.interior,
			vehicle_dimension = pVehicle.dimension,
			vehicle_static 	  = pVehicle:IsStatic(),
			vehicle_fuel 	  = pVehicle:GetFuel() or 10,
			vehicle_state 	  = GetVehicleState( pVehicle ),
			last_ready_switch = getTickCount(),
			current_marker_id = 1,
		}
		table.insert( self.participants, pPlayer )

		if is_host then
			self.participants_data[pPlayer].ready = true
			self.host = pPlayer
		end

		pPlayer:SetFactionVoiceChannel( RACING_DIMENSION + self.id )
		pPlayer:SetPrivateData( "in_race", true )
		pPlayer.frozen = true

		local pDataToSend =
		{
			state         = self.state,
			max_players   = self.max_participants,
			min_players   = self.min_participants,
			race_type     = self.race_type,
			host          = self.host,
			vehicle       = pVehicle,
			players_list  = self:PreparePlayersList(),
			allowed_types = self.track.allowed_types or { RACE_TYPE_CIRCLE_TIME },
			is_searching  = self.state == LOBBY_STATE_SEARCHING,
			track_name    = self.track.name,
			bet 		  = self.bet,
			class 	      = self.class,
		}

		SendElasticGameEvent( pPlayer:GetClientID(), "lobby_race_enter", 
        { 
			count     = tonumber( #self.participants ),
			car_id    = tonumber( pVehicle.model ),
			car_name  = tostring( VEHICLE_CONFIG[ pVehicle.model ].model ),
			car_class = tonumber( self.participants_data[ self.host ].vehicle:GetTier() ),
			race_type = tostring( RACE_TYPES_DATA[ self.race_type ].type ),
        } )
		
		if self.race_type == RACE_TYPE_DRIFT or self.race_type == RACE_TYPE_CIRCLE_TIME then
			triggerClientEvent( pPlayer, "RC:ShowUI_Lobby", resourceRoot, true, pDataToSend )
			triggerClientEvent( self.participants, "RC:OnPlayersListUpdated", resourceRoot, self:PreparePlayersList() )

			pPlayer.dimension = pPlayer:GetUniqueDimension( RACING_DIMENSION )
			pPlayer.interior = 0

			addEventHandler( "onPlayerWasted", pPlayer, OnPlayerWasted_handler )
			addEventHandler( "onPlayerDamage", pPlayer, cancelEvent )
		end
		triggerEvent( "RC:OnPlayerJoined", pPlayer )
		
		return true
	end

	self.PlayerRequestLeave = function( self, pPlayer, is_forced )
		self:PlayerLeave( pPlayer, is_forced )
	end

	self.PlayerLeave = function( self, pPlayer, bForced, bFinished, race_state, reason_state )
		local data = self.participants_data[ pPlayer ]
		if data then
			if bFinished then

				local race_time, race_points = 0					
				for k, v in pairs( self.players_positions or {} ) do
					if v.element == pPlayer then
						race_points = v.points
						if self.race_type == RACE_TYPE_CIRCLE_TIME or self.race_type == RACE_TYPE_DRAG then
							race_time = v.points / 1000
						end
						break
					end
				end

				if race_points > 0 then
					SetNewPointsValue( pPlayer, self.participants_data[ pPlayer ].vehicle, self.race_type, race_points )
				end
				
				local vehicle = self.participants_data[ pPlayer ].vehicle
				table.insert( self.race_results, {
					player	    = pPlayer,
					client_id 	= pPlayer:GetClientID(),
					level 	  	= pPlayer:GetLevel(),
					car_class 	= vehicle:GetTier(),
					car_model 	= vehicle.model,
        			reward    	= self.bet or 0, 
        			race_time 	= race_time,
					count_point = race_points,

					drag_count      = pPlayer:GetPermanentData( "drag_count" ) or 0,
					drag_call_count = pPlayer:GetPermanentData( "drag_call_count" ) or 0,
					drag_take_count = pPlayer:GetPermanentData( "drag_take_count" ) or 0,
				})

				if #self.race_results > 1 then
					table.sort( self.race_results, function( a, b )
						return CompareRaceRecord( self.race_type, a.count_point, b.count_point )
					end )
				end

				if self.race_type == RACE_TYPE_DRAG then
					local place = (race_state ~= RACE_STATE_LOSE and not self.is_winner_exist) and 1 or 2
					if place == 1 then
						triggerEvent( "onPlayerWinDragRace", pPlayer )
						pPlayer:GiveMoney( self.bet * 2, "drag_reward", "position_" .. #self.race_results )
						
						if pPlayer == self.host and isElement( self.rival ) then
							triggerClientEvent( self.rival, "RC:OnClientRivalFinishDragRace", resourceRoot )
						elseif pPlayer == self.rival and isElement( self.host ) then
							triggerClientEvent( self.host, "RC:OnClientRivalFinishDragRace", resourceRoot )
						end
						self.is_winner_exist = true
					end

					triggerClientEvent( pPlayer, "RC:OnRaceFinished", resourceRoot, false, (place == 1) and RACE_STATE_WIN or RACE_STATE_LOSE, {
						place  = place,
						reward = self.bet,
						points = race_points,
					} )

					if #self.race_results == #self.participants then
						for k, v in ipairs( self.race_results or {} ) do
							local coeff_result = (k == 1 and bFinished) and 1 or -1
							SendElasticGameEvent( v.client_id, "drag_racing_finish",
							{ 
								car_id          = tonumber( v.car_model ),
								car_name        = tostring( VEHICLE_CONFIG[ v.car_model ].model ),
								car_class       = tonumber( v.car_class ),
								race_duration   = tonumber( race_time ),
								bet_amount      = tonumber( v.reward ),
								win_sum         = tonumber( v.reward * coeff_result),
								prize_name      = "soft",
								finish_place    = tonumber( k ),
								drag_count      = tonumber( v.drag_count ),
								drag_call_count = tonumber( v.drag_call_count ),
								drag_take_count = tonumber( v.drag_take_count ),
							})
						end
					end
				elseif self.race_type == RACE_TYPE_CIRCLE_TIME or self.race_type == RACE_TYPE_DRIFT then
					if #self.race_results == #self.participants then

						-- Аналитика :-
						for k, v in ipairs( self.race_results ) do
							if v.count_point > 0 or v.race_time > 0 then
								SendElasticGameEvent( v.client_id, "race_finish",
								{ 
									
									racers_num  = tonumber( self.total_participants ), 
									prize_cost  = tonumber( v.reward ), 
									prize_name  = "soft",
									is_winner   = k == 1 and "true" or "false",
									race_time   = tonumber( v.race_time ),
									position    = tonumber( k ),
									count_point = tonumber( v.count_point ),
									car_id      = tonumber( v.car_model ), 
									car_name    = tostring( VEHICLE_CONFIG[ v.car_model ].model ),
									car_class   = tonumber( v.car_class ), 
									race_type   = tostring( RACE_TYPES_DATA[ self.race_type ].type ),
								})
							end
						end
					end
					
					if race_state == RACE_STATE_LOSE then
						triggerClientEvent( pPlayer, "RC:OnRaceFinished", resourceRoot, false, RACE_STATE_LOSE, {
							reason = reason_state,
						} )
					elseif isElement( pPlayer ) then
						local place = #self.race_results
						local g_place, g_points = GetPlayerGlobalBestStats( pPlayer:GetClientID(), self.race_type, vehicle:GetTier() )
						triggerClientEvent( pPlayer, "RC:OnRaceFinished", resourceRoot, false, RACE_STATE_FINISH, {
							place = place,
							points = race_points,
							g_place = g_place or 9999,
							g_points = g_points or race_points,
						} )
					end
				end
				triggerEvent( "onRaceAnyFinish", pPlayer, self.race_type, race_state ~= RACE_STATE_LOSE )
			else
				self:PlayerReadyToStart( pPlayer )
			end
		end

		if self.state == LOBBY_STATE_OPENED or self.state == LOBBY_STATE_SEARCHING then
			triggerClientEvent( pPlayer, "RC:ShowUI_Lobby", resourceRoot, false, false, true )
		end

		if bForced then
			self:PlayerRestore( pPlayer, bForced )
		end
	end

	self.PlayerRestore = function( self, pPlayer, bForced, is_drag_cancel )
		local data = self.participants_data[ pPlayer ]
		if not is_drag_cancel then
			if self.race_type ~= RACE_TYPE_DRAG then
				removePedFromVehicle( pPlayer )
			end

			if bForced then
				setCameraTarget( pPlayer, pPlayer )

				pPlayer.dimension = data.player_dimension
				pPlayer.interior  = data.player_interior
				pPlayer.position  = data.player_position

				pPlayer.frozen = false
				triggerClientEvent( pPlayer, "RC:OnRacePostFinished", resourceRoot )
			else
				pPlayer.frozen = true
				fadeCamera( pPlayer, false, 0.1 )

				local player_data = table.copy( data )
				setTimer(function( player, data )
					setCameraTarget( player, player )

					player.dimension = data.player_dimension
					player.interior  = data.player_interior
					player.position  = data.player_position

					player.frozen = true
				end, 1100, 1, pPlayer, player_data )

				setTimer(function( player )
					fadeCamera( player, true, 1 )
					player.frozen = false
				end, 2200, 1, pPlayer )
			end
			
			removeEventHandler( "onPlayerDamage", pPlayer, cancelEvent )

			if data.vehicle and isElement( data.vehicle ) then
				data.vehicle.health = data.vehicle_health
				data.vehicle:SetFuel( data.vehicle_fuel )
				SetVehicleState( data.vehicle, data.vehicle_state )
			    setElementVelocity( data.vehicle, 0, 0, 0 )

				if isVehicleOnRoof( data.vehicle ) then
					local _, _, rz = getElementRotation( data.vehicle )
					data.vehicle:setRotation( 0, 0, rz )
				end
				data.vehicle.damageProof = false

				if data.vehicle_dimension == 6666 then
					data.vehicle:SetParked( true )
				else
					data.vehicle.position  = data.vehicle_position
					data.vehicle.interior  = data.vehicle_interior
					data.vehicle.dimension = data.vehicle_dimension
					data.vehicle:SetStatic( data.vehicle_static )
					triggerClientEvent( pPlayer, "onClientResetVehicleLastPosition", root, data.vehicle )
				end
			end
		else
			pPlayer.frozen = false
		end

		pPlayer:SetFactionVoiceChannel( false )
		pPlayer:SetPrivateData( "in_race", false )

		removeEventHandler( "onPlayerWasted", pPlayer, OnPlayerWasted_handler )
		self.rejections[ pPlayer ] = getTickCount() + 120000

		self.participants_data[ pPlayer ] = nil

		for k,v in pairs( self.participants ) do
			if self.race_type == RACE_TYPE_DRAG then
				ResetPlayerDragEventHandlers( v )
			end
			
			if v == pPlayer then
				table.remove( self.participants, k )
				break
			end
		end

		if #self.participants >= 1 then
			local bHostUpdated = false
			if self.host == pPlayer then
				self.host = self.participants[ math.random( #self.participants ) ]
				bHostUpdated = true
			end

			if self.state ~= LOBBY_STATE_STARTED then
				triggerClientEvent( self.participants, "RC:OnPlayersListUpdated", resourceRoot, self:PreparePlayersList(), bHostUpdated and self.host )
			end
		elseif not is_drag_cancel then
			self:destroy()
		end
	end

	self.UpdatePlayerPosition = function( self, pPlayer, points, is_finish )
		if not self.participants_data[ pPlayer ] then return end

		local positions = self.players_positions or {}
		for k, v in pairs( positions ) do
			if v.element == pPlayer then
				if self.race_type == RACE_TYPE_CIRCLE_TIME or self.race_type == RACE_TYPE_DRAG then
					if v.points == 0 or points < v.points then
						v.score, v.points = points, points
					end
				elseif self.race_type == RACE_TYPE_DRIFT then
					v.score, v.points = points, points
				end
				break
			end
		end

		for i = #positions, 2, -1 do
			local next_value = positions[ i - 1 ]
			local current_value = positions[ i ]
			if next_value and self.race_type == RACE_TYPE_DRIFT and current_value.score > next_value.score then
				positions[ i - 1 ] = current_value
				positions[ i ] = next_value
			elseif next_value and (self.race_type == RACE_TYPE_CIRCLE_TIME or self.race_type == RACE_TYPE_DRAG ) and current_value.score < next_value.score and current_value.score ~= 0 then
				positions[ i - 1 ] = current_value
				positions[ i ] = next_value
			end
		end

		triggerClientEvent( self.participants, "RC:UpdateVisiblePosition", resourceRoot, positions )
	end

	self.SetState = function( self, iNewState, bNative )
		if iNewState == LOBBY_STATE_OPENED then
			if self.state == LOBBY_STATE_SEARCHING then
				triggerClientEvent( "RC:NotificationExpired", resourceRoot, self.id )
			end
		elseif iNewState == LOBBY_STATE_SEARCHING then
			self:NoticeSearchingPlayers()
		elseif iNewState == LOBBY_STATE_PROGRESS then
			triggerClientEvent( "RC:NotificationExpired", resourceRoot, self.id )
			self:StartRace()
		elseif iNewState == LOBBY_STATE_FINISHED then

		end

		self.state = iNewState
	end

	self.StartRace = function( self )
		self.total_participants = #self.participants
		self.current_circle = 1
		if self.race_type == RACE_TYPE_CIRCLE_TIME then
			self.circles = 2
		elseif self.race_type == RACE_TYPE_DRIFT then
			self.circles = 256
		elseif self.race_type == RACE_TYPE_DRAG then
			self.circles = 1
		end

		self.players_positions = {}
		for k, v in pairs( self.participants ) do
			table.insert( self.players_positions, {
				element = v,
				score = 0,
				points = GetPointsByRaceType( self.race_type ),
			} )
		end
		
		local pDataToSend = 
		{
			players        = self.participants,
			track_name     = self.track.name,
			race_type      = self.race_type,
			current_circle = self.current_circle,
			circles        = self.circles,
		}
		
		local iTotalCash = 0
		
		for i, player in pairs( self.participants ) do
			fadeCamera( player, false, 0.1 )
			
			player.dimension = self.id
			local pVehicle = self.participants_data[ player ].vehicle
			-- Безбилетников нахуй
			for k, v in pairs( getVehicleOccupants( pVehicle ) ) do
				removePedFromVehicle( v )
			end

			if pVehicle:IsCruiseEnabled() then
				pVehicle:SetCruiseEnabled( false )
			end

			setElementVelocity( pVehicle, 0, 0, 0 )
			setElementPosition( pVehicle, self.track.spawns[ i ].x, self.track.spawns[ i ].y, self.track.spawns[ i ].z )
			setElementRotation( pVehicle, self.track.spawns[ i ].rx or 0, self.track.spawns[ i ].ry or 0, self.track.spawns[ i ].rz or 0 )
			pVehicle.interior = 0
			pVehicle.dimension = self.id
			pVehicle:Fix()
			if self.race_type ~= RACE_TYPE_CIRCLE_TIME then pVehicle.damageProof = true end
			setVehicleOverrideLights( pVehicle, 2 )
			pVehicle:SetFuel( "full" )
			setElementCollisionsEnabled( pVehicle, true )
			pVehicle.frozen = true
			warpPedIntoVehicle( player, pVehicle )
			player:SetFactionVoiceChannel( false )
			setVehicleEngineState( pVehicle, true )
			
			if self.race_type == RACE_TYPE_DRAG then
				SendElasticGameEvent( player:GetClientID(), "drag_racing_start", 
    			{ 
    			    car_id          = tonumber( pVehicle.model ), 
					car_class       = tonumber( pVehicle:GetTier() ),
					car_name        = tostring( VEHICLE_CONFIG[ pVehicle.model ].model ),
					bet_amount      = tonumber( self.bet ),

					drag_count      = player:GetPermanentData( "drag_count" ) or 0,
					drag_call_count = player:GetPermanentData( "drag_call_count" ) or 0,
					drag_take_count = player:GetPermanentData( "drag_take_count" ) or 0,
				} )
			else
			    SendElasticGameEvent( player:GetClientID(), "race_start", 
    		    { 
				    racers_num = tonumber( #self.participants ), 
    		        car_id     = tonumber( pVehicle.model ), 
    		        car_class  = tonumber( pVehicle:GetTier() ), 
    		        car_name   = tostring( VEHICLE_CONFIG[ pVehicle.model ].model ),
    		        race_type  = tostring( RACE_TYPES_DATA[ self.race_type ].type ),
    		    })
			end

			local leaders_season = {}
			if self.race_type == RACE_TYPE_CIRCLE_TIME or self.race_type == RACE_TYPE_DRIFT then
				local vehicle_class = pVehicle:GetTier()
				local race_points_id = "race_" .. RACE_TYPES_DATA[ self.race_type ].type .. "_points"
				for i = 1, 5 do
					if RECORDS_DATA[ self.race_type ][ vehicle_class ][ i ] then
						table.insert( leaders_season, {
							nickname = RECORDS_DATA[ self.race_type ][ vehicle_class ][ i ][ "nickname" ],
							points   = RECORDS_DATA[ self.race_type ][ vehicle_class ][ i ][ race_points_id ],
						} )
					end
				end
			else
				pDataToSend.rival = player == self.host and self.rival or self.host
				pDataToSend.stats = { pVehicle:GetStats( pVehicle:GetParts(), true ) }
			end
			
			triggerClientEvent( player, "RC:OnRaceStarted", resourceRoot, pDataToSend, pVehicle, leaders_season )

			if self.race_type == RACE_TYPE_DRIFT then
				player:CompleteDailyQuest( "race_participation_drift" )
			elseif self.race_type == RACE_TYPE_DRAG then
				player:CompleteDailyQuest( "race_participation_drag" )
			elseif self.race_type == RACE_TYPE_CIRCLE_TIME then
				player:CompleteDailyQuest( "race_participation_circle" )
			end
		end
	end

	self.PlayerReadyToStart = function( self, pPlayer )
		if self.state ~= LOBBY_STATE_PROGRESS then return end
		
		self.participants_data[ pPlayer ].ready_start_race = true
		local target_players = {}
		for k, v in pairs( self.participants_data ) do
			local is_player = isElement( k )
			if not is_player or v.ready_start_race then
				if is_player then table.insert( target_players, k ) end
			else
				return false
			end
		end
		self:SetState( LOBBY_STATE_STARTED )
		triggerClientEvent( target_players, "onClientStartCountdown", resourceRoot )
	end

	self.PreparePlayersList = function( self )
		local pPlayers = {}
		for k,v in pairs( self.participants_data ) do
			table.insert( pPlayers, { 
				ele = k, 
				status = v.ready 
			} )
		end
		return pPlayers
	end

	self.SendUpdatedData = function( self )
		local pDataToSend = 
		{
			bet		     = self.bet,
			race_type    = self.race_type,
			is_searching = self.state == LOBBY_STATE_SEARCHING,
		}
		triggerClientEvent( self.participants, "RC:OnLobbyUpdated", resourceRoot, pDataToSend )
	end

	self.NoticeSearchingPlayers = function( self, pPlayer )
		if #self.participants < self.max_participants then
			if pPlayer then
				if self.rejections[ pPlayer ] and self.rejections[ pPlayer ] >= getTickCount() then
					return false
				end

				if pPlayer == self.host then 
					return false
				end

				local pSuitableVehicles = GetPlayerAvailableVehicles( pPlayer, self.race_type )

				if not pSuitableVehicles or #pSuitableVehicles <= 0 then
					return false
				end

				local pNotification = 
				{
					title = "Гонка",
					msg = "Начинается гонка: "..RACE_TYPES_DATA[self.race_type].name,
					special = "race_lobby_created",
					args = { id = self.id },
				}

				triggerClientEvent( pPlayer, "OnClientReceivePhoneNotification", root, pNotification )
			else
				for i, player in pairs( getElementsByType( "player" ) ) do
					if isElement( player ) and player:IsInGame() and player ~= self.host then
						if not getElementData( player, "driving_exam" ) then
							local pSuitableVehicles = GetPlayerAvailableVehicles( player, self.race_type )
							local bRejected = self.rejections[ player ] and self.rejections[ player ] >= getTickCount()
							if pSuitableVehicles and #pSuitableVehicles >= 1 and not bRejected then
								local pNotification = 
								{
									title = "Гонка",
									msg = "Начинается гонка: "..RACE_TYPES_DATA[self.race_type].name,
									special = "race_lobby_created",
									args = { id = self.id },
								}

								triggerClientEvent( player, "OnClientReceivePhoneNotification", root, pNotification )
							end
						end
					end
				end
			end
		end
	end

	self.destroy = function( self, is_drag_cancel )
		if isTimer( self.destroy_timer ) then
			killTimer( self.destroy_timer )
		end

		triggerClientEvent( root, "RC:NotificationExpired", resourceRoot, self.id )
		self.state = LOBBY_STATE_DISABLED

		for i, player in pairs( table.copy( self.participants ) ) do
			self:PlayerRestore( player, true, is_drag_cancel )
		end

		for i, element in pairs( self.elements ) do
			if isElement( element ) then
				element:destroy()
			end
		end

		if isTimer( self.check_players ) then
			killTimer( self.check_players )
		end

		if self.race_type == RACE_TYPE_DRAG then
			for k, v in pairs( { self.rival, self.host } ) do
				ResetPlayerDragEventHandlers( v )
				WAITING_DRAG_LOBBY[ v ] = nil
			end
		end

		RACE_LOBBIES[ self.id ] = nil
		setmetatable( self, nil )
	end

	RACE_LOBBIES[LAST_ID] = self

	self.check_players = setTimer(function( id )
		local lobby = RACE_LOBBIES[ id ]
		if lobby then
			for k,v in pairs( lobby.participants_data ) do
				if k ~= lobby.host and not v.ready and getTickCount() - v.last_ready_switch >= 180000 then
					lobby:PlayerLeave( k, true )
					k:ShowError( "Вы были исключены из лобби за продолжительное отсутствие" )
					SEARCH_TIMEOUTS[ k ] = getTickCount() + 300000
				end
			end
		end
	end, 30000, 0, self.id )

	LAST_ID = LAST_ID + 1

	return self
end

function onServerPlayerReadyToStartRace_handler()
	local iLobby = GetPlayerLobby( client )
	local pLobby = RACE_LOBBIES[ iLobby ]
	if pLobby then
		if not pLobby.participants_data[ client ] or pLobby.participants_data[ client ].ready_start_race then return false end
		pLobby:PlayerReadyToStart( client )
	end
end
addEvent( "onServerPlayerReadyToStartRace", true )
addEventHandler( "onServerPlayerReadyToStartRace", resourceRoot, onServerPlayerReadyToStartRace_handler )

function OnPlayerPostFinishRace()
	local iLobby = GetPlayerLobby( client )
	local pLobby = RACE_LOBBIES[ iLobby ]
	if pLobby then
		pLobby:PlayerRestore( client )
	end
end
addEvent( "RC:OnPlayerPostFinishRace", true )
addEventHandler( "RC:OnPlayerPostFinishRace", resourceRoot, OnPlayerPostFinishRace )

function OnPlayerRequestCreateLobby( pPlayer, data )
	if not isElement( pPlayer ) then return end
	if GetPlayerLobby( pPlayer ) then return end

	if data.vehicle:getData( "tow_evac_added" ) or data.vehicle:getData( "tow_evacuated_real" ) then
		pPlayer:ShowError( "Это авто ожидает эвакуации или уже эвакуируется" )
		return false
	end

	OnPlayerStopVehiclePreview( pPlayer, data.vehicle )

	local pLobby, err = CreateRaceLobby( { track = data.track, class = data.vehicle:GetTier(), stats = data.vehicle:GetStatsSum() } )
	if pLobby then
		pLobby:PlayerJoin( pPlayer, data.vehicle, true )
	else
		pPlayer:ShowError( err )
	end
end
addEvent( "RC:OnPlayerRequestCreateLobby", true )
addEventHandler( "RC:OnPlayerRequestCreateLobby", resourceRoot, OnPlayerRequestCreateLobby )

function OnPlayerUpdateLobbySettings( pPlayer, data )
	local iLobby = GetPlayerLobby( pPlayer )
	local pLobby = RACE_LOBBIES[iLobby]
	if pLobby then
		if pLobby.host == pPlayer then

			for k,v in pairs(pLobby.participants_data) do
				v.ready = false
			end

			for k, v in pairs(data) do
				if k == "race_type" then
					pLobby.race_type = v
				elseif k == "is_searching" then
					pLobby:SetState( v and LOBBY_STATE_SEARCHING or LOBBY_STATE_OPENED )
				end
			end

			pLobby:SendUpdatedData()
		end
	end
end
addEvent( "RC:OnPlayerUpdateLobbySettings", true )
addEventHandler( "RC:OnPlayerUpdateLobbySettings", resourceRoot, OnPlayerUpdateLobbySettings )

function OnPlayerRequestStartRace( pPlayer )
	local iLobby = GetPlayerLobby( pPlayer )
	local pLobby = RACE_LOBBIES[ iLobby ]
	if pLobby then
		if #pLobby.participants < pLobby.min_participants then
			pPlayer:ShowError( "Недостаточно участников" )
			return false
		end

		if pLobby.state == LOBBY_STATE_PROGRESS then
			pPlayer:ShowError( "Гонка уже началась" )
			return false
		end

		for k,v in pairs( pLobby.participants_data ) do
			if k ~= pLobby.host and not v.ready then
				pPlayer:ShowError( "Не все участники готовы" )
				return false
			end
		end

		pLobby:SetState( LOBBY_STATE_PROGRESS )
	end
end
addEvent( "RC:OnPlayerRequestStartRace", true )
addEventHandler( "RC:OnPlayerRequestStartRace", resourceRoot, OnPlayerRequestStartRace )

function OnPlayerRequestLeaveLobby( pPlayer, is_game_forced, race_state, reason_state )
	local iLobby = GetPlayerLobby( pPlayer )
	local pLobby = iLobby and RACE_LOBBIES[ iLobby ]
	if pLobby then
		if is_game_forced then
			pLobby:PlayerLeave( pPlayer, false, true, race_state, reason_state )
		else
			pLobby:PlayerRestore( pPlayer )
		end
	end
end
addEvent( "RC:OnPlayerRequestLeaveLobby", true )
addEventHandler( "RC:OnPlayerRequestLeaveLobby", resourceRoot, OnPlayerRequestLeaveLobby )

function OnPlayerRequestJoinLobby( pPlayer, iLobby, pVehicle )
	if not isElement( pPlayer ) then return end
	if GetPlayerLobby( pPlayer ) then return end
	OnPlayerStopVehiclePreview( pPlayer )
	
	if RACE_LOBBIES[ iLobby ] then
		RACE_LOBBIES[ iLobby ]:PlayerRequestJoin( pPlayer, pVehicle )
	end
end
addEvent( "RC:OnPlayerRequestJoinLobby", true )
addEventHandler( "RC:OnPlayerRequestJoinLobby", resourceRoot, OnPlayerRequestJoinLobby )

function OnPlayerReadyStateChanged( pPlayer, new_state )
	local iLobby = GetPlayerLobby( pPlayer )
	local pLobby = RACE_LOBBIES[ iLobby ]
	if pLobby then
		pLobby.participants_data[ pPlayer ].ready = new_state
		if not new_state then
			pLobby.participants_data[ pPlayer ].last_ready_switch = getTickCount()
		end
		triggerClientEvent( pLobby.participants, "RC:OnPlayersListUpdated", resourceRoot, pLobby:PreparePlayersList() )
	end
end
addEvent( "RC:OnPlayerReadyStateChanged", true )
addEventHandler( "RC:OnPlayerReadyStateChanged", resourceRoot, OnPlayerReadyStateChanged )

function OnPlayerCheckpoint( pPlayer, points, is_finish )
	local iLobby = GetPlayerLobby( pPlayer )
	local pLobby = RACE_LOBBIES[ iLobby ]
	if pLobby then
		pLobby:UpdatePlayerPosition( pPlayer, points, is_finish )
		if is_finish then
			if pLobby.race_type == RACE_TYPE_DRAG then
				if isElement( pPlayer ) then
					pLobby:PlayerLeave( pPlayer, false, true )
				end
			else
				setTimer( function ()
					if pLobby and pLobby.state ~= LOBBY_STATE_DISABLED and isElement( pPlayer ) then
						pLobby:PlayerLeave( pPlayer, false, true )
					end
				end, 5000, 1 )
			end
		end
	end
end
addEvent( "RC:OnPlayerCheckpoint", true )
addEventHandler( "RC:OnPlayerCheckpoint", resourceRoot, OnPlayerCheckpoint )

function onServerPlayerTryStartRace( race_type )
	if isPedDead( client ) then return end
	
	if not RACE_TYPES_DATA[ race_type ] or not RACE_TYPES_DATA[ race_type ].available then 
		client:ShowError( "Неизвестный тип гонки" )
		return 
	end

	local can_join, msg = client:CanJoinToEvent({ event_type = "race" })
	if not can_join then
		client:ShowError( msg )
		return false
	end
	
	local sTrackName = RACE_TYPES_DATA[ race_type ].maps[ 1 ]
	local pTrack = ReadTrack( sTrackName, true )
	local pData = 
	{
		track = 
		{
			name = pTrack.name,
		},
		vehicles = OnPlayerStartVehiclePreview( client, race_type ),
		host = true,
	}

	if not pData.vehicles or #pData.vehicles == 0 then
		client:ShowError("У Вас нет подходящего автомобиля")
		return false
	end

	removePedFromVehicle( client )
	client:setPosition( client:getPosition() )

	if client:getData( "phone.call" ) then
		triggerEvent( "onServerEndPhoneCall", client, client )
	end

	triggerClientEvent( client, "RC:ShowUI_Selector", client, true, pData )
end
addEvent( "RC:onServerPlayerTryStartRace", true )
addEventHandler( "RC:onServerPlayerTryStartRace", resourceRoot, onServerPlayerTryStartRace )

function OnPlayerSearchStart( pPlayer, iRaceType )
	local pVehicles = GetPlayerAvailableVehicles( pPlayer, iRaceType )
	if #pVehicles < 1 then
		pPlayer:ShowError( "У Вас нет подходящих автомобилей" )
		return false
	end

	if GetPlayerLobby( pPlayer ) then
		pPlayer:ShowError("Вы уже в лобби!")
		return false
	end

	if SEARCH_TIMEOUTS[ pPlayer ] then
		local iTimeLeft =  ( SEARCH_TIMEOUTS[pPlayer] - getTickCount() ) / 1000
		if iTimeLeft > 0 then
			pPlayer:ShowError( "Поиск временно заблокирован ( осталось "..math.ceil( iTimeLeft / 60 ).." минут)" )
			return false
		end
	end

	SEARCHING_PLAYERS[ pPlayer ] = 
	{
		vehicles = pVehicles,
		race_type = iRaceType,
	}

	triggerClientEvent( pPlayer, "RC:OnClientStartSearching", pPlayer )

	for k,v in pairs( RACE_LOBBIES ) do
		if v.state == LOBBY_STATE_SEARCHING and v.race_type == iRaceType then
			v:NoticeSearchingPlayers( pPlayer )
		end
	end
end
addEvent( "RC:OnPlayerSearchStart", true )
addEventHandler( "RC:OnPlayerSearchStart", root, OnPlayerSearchStart )

function OnPlayerSearchStop( pPlayer )
	if SEARCHING_PLAYERS[ pPlayer ] then
		SEARCHING_PLAYERS[ pPlayer ] = nil
		triggerClientEvent( pPlayer, "RC:OnClientStopSearching", pPlayer )
	end
end
addEvent( "RC:OnPlayerSearchStop", true)
addEventHandler( "RC:OnPlayerSearchStop", root, OnPlayerSearchStop )

function OnPlayerAcceptedLobbyInvitation( iLobby )
	local pPlayer = client
	local pLobby = RACE_LOBBIES[ iLobby ]
	if not pLobby then return end

	local pData = 
	{
		track = 
		{
			name = pLobby.track.name,
		},
		vehicles = OnPlayerStartVehiclePreview( pPlayer, pLobby.race_type ),
		lobby_id = pLobby.id,
	}

	if not pData.vehicles or #pData.vehicles == 0 then
		pPlayer:ShowError("У вас нет подходящего автомобиля")
		return false
	end

	local can_join, msg = pPlayer:CanJoinToEvent({ event_type = "race" })
	if can_join then
		triggerClientEvent( pPlayer, "RC:ShowUI_Selector", pPlayer, true, pData )
	else
		pPlayer:ShowError( msg )
	end
end
addEvent( "RC:OnPlayerAcceptedLobbyInvitation", true )
addEventHandler( "RC:OnPlayerAcceptedLobbyInvitation", root, OnPlayerAcceptedLobbyInvitation )

function OnPlayerRejectedLobbyInvitation( iLobby )
	local pPlayer = client
	local pLobby = RACE_LOBBIES[ iLobby ]
	if not pLobby then return end

	pLobby.rejections[ pPlayer ] = getTickCount() + 120000
end
addEvent( "RC:OnPlayerRejectedLobbyInvitation", true )
addEventHandler( "RC:OnPlayerRejectedLobbyInvitation", root, OnPlayerRejectedLobbyInvitation )

function OnPlayerWantRaceMenu_handler()
	if isPedDead( client ) then return end

	local player_stats = GetPlayerRecords( client )
	triggerClientEvent( client, "RC:onClientShowLobbyCreateUI", client, true, player_stats, RECORDS_DATA, SEASON_NUMBER, SEASON_END ) 
end
addEvent( "RC:OnPlayerWantRaceMenu", true )
addEventHandler( "RC:OnPlayerWantRaceMenu", root, OnPlayerWantRaceMenu_handler )

local function OnPlayerQuit( pPlayer )
	local pPlayer = isElement( pPlayer ) and pPlayer or source
	local iLobby = GetPlayerLobby( pPlayer )
	local pLobby = RACE_LOBBIES[ iLobby ]
	if pLobby then
		pLobby:PlayerLeave( pPlayer, true )
	end

	if SEARCHING_PLAYERS[ pPlayer ] then
		SEARCHING_PLAYERS[ pPlayer ] = nil
	end
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, OnPlayerQuit, true, "high+99999999999" )

addEventHandler( "onResourceStop", resourceRoot, function()
	for k,v in pairs( RACE_LOBBIES ) do
		v:destroy()
	end
end)

function OnPlayerWasted_handler()
	local iLobby = GetPlayerLobby( source )
	local pLobby = RACE_LOBBIES[ iLobby ]

	if pLobby then
		pLobby:PlayerRestore( source, true )
	end
end

addEvent( "RC:OnPlayerJoined", true )