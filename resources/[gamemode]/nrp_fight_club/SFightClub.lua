loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend("ShUtils")
Extend("SPlayer")
Extend("SPlayerOffline")
Extend("SInterior")
Extend("ShTimelib")
Extend("SDB")

LOBBIES_LIST = {}
LAST_ID = 1

function InPlayerCanEnter( player )
	--TODO: Больше условий для входа, если требуется
	return true
end

function onPlayerWannaEnterFightClub_handler( entering_dimension )
	if not entering_dimension then return end
	local success, info = InPlayerCanEnter( client )
	if not success then
		return client:ShowError( info )
	end

	client:Teleport( Vector3( -2121.492, 244.896, 665.1 ), entering_dimension, 1 )
	OnUpdateTournamentDataToClients()

	client:CompleteDailyQuest( "np_visit_fc" )
end
addEvent( "onPlayerWannaEnterFightClub", true )
addEventHandler( "onPlayerWannaEnterFightClub", resourceRoot, onPlayerWannaEnterFightClub_handler )

function onPlayerWannaExitFightClub_handler( index )
	client:Teleport( Vector3( FIGHT_CLUB_ENTRANCES[index].x, FIGHT_CLUB_ENTRANCES[index].y, FIGHT_CLUB_ENTRANCES[index].z ), 0, 0 )
end
addEvent( "onPlayerWannaExitFightClub", true )
addEventHandler( "onPlayerWannaExitFightClub", resourceRoot, onPlayerWannaExitFightClub_handler )

addEventHandler("onResourceStop", resourceRoot, function()
	for k,v in pairs(LOBBIES_LIST) do
		v:Shutdown()
	end

	local vecPosition = Vector3(-459.9245, 2549.1801, 17.2376)
	for _,v in pairs(getElementsWithinRange( -2097.698,  1110.252 - 860,  665.098, 40, "player") ) do
		v:Teleport( vecPosition + Vector3( math.random(3), math.random(3), 0 ), 0, 0 )
	end
end)


function CreateLobby( data )
	local self = {}
	self.id = LAST_ID
	self.name = data.name or "Лобби #"..LAST_ID
	self.host = data.host or nil
	self.is_tournament = data.is_tournament or false
	self.settings = data.settings or {}
	self.elements = {}
	self.participants = {}
	self.participants_data = {}
	self.started = false
	self.cost = data.cost or 0

	self.StartFight = function( self )
		for k, v in pairs( self.participants ) do
			if not isElement( v ) then
				self:PlayerLeave( v )
				return
			else
				triggerEvent( "onPlayerSomeDo", v, "start_fight_fc" ) -- achievements
			end
		end

		local pDataToSend = 
		{
			id = self.id,
			participants = self.participants,
			is_tournament = self.is_tournament,
			settings = self.settings,
			corners = {},
		}

		self.started = getRealTimestamp()

		local iCorner = 1
		for _,v in pairs(self.participants) do
			pDataToSend.corners[ v ] = iCorner
			setElementPosition( v, unpack(RING_CORNERS[iCorner].pos))
			setElementRotation( v, unpack(RING_CORNERS[iCorner].rot))
			setElementDimension( v, 100+self.id )
			setElementInterior( v, 1 )
			setElementHealth(v, 100)
			setElementModel(v, iCorner % 2 == 0 and 121 or 122)
			setPedArmor(v, 0)
			iCorner = iCorner + 1
		end

		setTimer(function( id )
			local lobby = LOBBIES_LIST[id]
			if not lobby then return end
			local fHigherHP, pWinner = 0, lobby.participants[1]
			for k, v in pairs(lobby.participants) do
				if isElement(v) then
					local hp = v.health
					if hp >= fHigherHP then
						fHigherHP = hp
						pWinner = v
					end
				end
			end
			lobby:FinishFight( pWinner )
		end, 300000, 1, self.id)
		OnUpdateTournamentDataToClients()
		triggerClientEvent( self.participants, "FC:StartFight", resourceRoot, pDataToSend )

		triggerEvent( "onFightClubStatedFight", root, self.participants )
	end

	self.FinishFight = function( self, pWinner )
		if isElement(pWinner) then
			if not self.is_tournament then
				local iSum = self.cost * #self.participants
				pWinner:GiveMoney( iSum * 0.85, "fc", "fc_win" )
				onFightClubWin( pWinner, iSum * 0.15, iSum * 0.85 )
				triggerEvent( "onFightClubPlayerWon", pWinner, iSum * 0.85 )
			end
			pWinner:ShowSuccess("Вы победили в поединке!")
		end

		for k, player in pairs(self.participants) do
			self:PlayerLeave( player, true )
		end

		if self.is_tournament then
			local iWinnerID = isElement(pWinner) and pWinner:GetUserID() or pWinner.uid
			local sWinnerName = isElement(pWinner) and pWinner:GetNickName() or pWinner.name
			local sWinnerClientID = isElement(pWinner) and pWinner:GetClientID() or pWinner.client_id

			-- UPDATE RESULTS
			local timestamp = getRealTimestamp()
			TOURNAMENT_DATA.fights[ self.is_tournament ].result = 
			{
				uid = iWinnerID,
				client_id = sWinnerClientID,
				name = sWinnerName,
				duration = timestamp - (self.started or timestamp),
			}

			for k, v in pairs( TOURNAMENT_DATA.fights[ self.is_tournament ].participants ) do
				if isElement( v ) and v:GetUserID() ~= iWinnerID then
					v:SetPermanentData( "finish_fc", true )
				end
			end
			
			OnUpdateTournamentDataToClients()

			-- BETS
			local iWinSum, iLoseSum = 0, 0
			for iBettorID, data in pairs(TOURNAMENT_BETS) do
				if data[1] == iWinnerID then
					iWinSum = iWinSum + data[2]
				else
					iLoseSum = iLoseSum + data[2]
				end
			end

			for iBettorID, data in pairs(TOURNAMENT_BETS) do
				local reward_sum = 0
				local is_win = data[ 1 ] == iWinnerID
				local pBettor = GetPlayer(iBettorID, true)
				if is_win then
					local fPercent = data[2] / iWinSum
					reward_sum = math.floor( data[2] + ( iLoseSum*fPercent*0.75 ) )

					
					if pBettor then
						pBettor:GiveMoney( reward_sum, "fc", "fc_bet_win" )
						pBettor:ShowSuccess("Ваша ставка в бойцовском клубе сыграла, выигрыш" .. reward_sum .. "р.")
					else
						DB:queryAsync(function(queryHandler, value, iLoseSum, fPercent)
					        local result = dbPoll(queryHandler,0)
					        if type ( result ) ~= "table" or #result == 0 then
					            return false
					        end

					        DB:exec("UPDATE nrp_players SET money = ? WHERE id = ? LIMIT 1", (result[1].money or 0) + value, result[1].id)
					    end, {reward_sum, iLoseSum, fPercent}, "SELECT id, money, level, client_id FROM nrp_players WHERE id=? LIMIT 1", iBettorID)
					end
				elseif isElement( pBettor ) then
					pBettor:ShowSuccess( "Ваша ставка в бойцовском клубе не сыграла, вы проиграли" .. data[ 2 ] .. "р." )
				end

				onFightClubBet( data[ 3 ], data[ 2 ], sWinnerClientID, is_win, reward_sum )
			end

			UpdateTournamentGrid( TOURNAMENT_DATA.fights[ self.is_tournament ].round )
			WriteLog( "fight_club", "[FIGHT_COMPLETED] Day: %s, Winner: %s", GetTournamentDay(), iWinnerID )
		end

		self:destroy()
	end

	self.OnPlayerRequestJoin = function( self, pPlayer )
		if not pPlayer:HasFCMembership() then
			pPlayer:ShowError("Доступно только для членов бойцовского клуба")
			return false
		end

		if pPlayer:IsOnFactionDuty( ) then
			pPlayer:ShowError( "Нельзя принять участие находясь на смене" )
			return false
		end

		if #self.participants >= 2 then
			pPlayer:ShowError("Лобби переполнено")
			return false
		end

		local result, msg = pPlayer:CanJoinToEvent({ event_type = "fight" })
		if not result then
			pPlayer:ShowError( msg )
			return false
		end

		if self.is_tournament then
			local iUserID = pPlayer:GetUserID()

			for i, fighter in pairs(TOURNAMENT_DATA.fights[self.is_tournament].participants) do
				if iUserID == fighter.uid then
					self:PlayerJoin( pPlayer )
					return true
				end
			end

			pPlayer:ShowError("Сегодня не ваш бой")
			return false
		end

		if pPlayer:TakeMoney( self.cost, "fc", "fc_participate" ) then
			self:PlayerJoin( pPlayer )
		else
			pPlayer:ShowError( "Недостаточно средств для участия")
		end
	end

	self.PlayerJoin = function( self, pPlayer )
		table.insert(self.participants, pPlayer)

		self.participants_data[pPlayer] = 
		{
			interior = pPlayer.interior,
			dimension = pPlayer.dimension ,
			position = pPlayer.position,
			health = pPlayer.health,
			armor = pPlayer.armor,
			model = pPlayer.model
		}

		pPlayer:SetPrivateData( "in_fc", true )

		if #self.participants >= 2 then
			self:StartFight()
		end
	end

	self.PlayerLeave = function( self, pPlayer, bFinished, bForced )
		for k,v in pairs(self.participants) do
			if v == pPlayer then
				table.remove( self.participants,k )
			end
		end

		if isElement(pPlayer) then
			local r_data = self.participants_data[pPlayer]
			pPlayer.health = r_data.health
			pPlayer.armor = r_data.armor
			pPlayer.model = r_data.model
			pPlayer:Teleport( r_data.position, r_data.dimension, r_data.interior )

			triggerEvent( "FC:OnServerFightFinished", pPlayer )

			if self.started and not bForced then
				triggerClientEvent(pPlayer, "FC:OnFightFinished", resourceRoot)
				if not bFinished then
					self:destroy()
				end
			else
				pPlayer:GiveMoney( self.cost, "fc", "fc_left" )
			end
		end

		self.participants_data[pPlayer] = nil
		pPlayer:SetPrivateData( "in_fc", nil )

		OnUpdateTournamentDataToClients()
		if #self.participants <= 0 then
			if not self.is_tournament then
				self:destroy()
			end
		end
	end

	self.Shutdown = function( self )
		if self.is_tournament then
			if not self.started then
				if #self.participants >= 1 then
					self:FinishFight( self.participants[math.random(#self.participants)] )
					WriteLog( "fight_club", "[FIGHT_UNCOMPLETED] Day: %s, Existing winner: %s", GetTournamentDay(), self.participants[1]:GetUserID() )
				else
					local pWinner = TOURNAMENT_DATA.fights[ self.is_tournament ].participants[math.random(2)]
					self:FinishFight( pWinner )
					self:destroy()
					WriteLog( "fight_club", "[FIGHT_UNCOMPLETED] Day: %s, Generated winner: %s", GetTournamentDay(), pWinner.uid )
				end
			else
				self:FinishFight( self.participants[math.random(#self.participants)] )
			end
		else
			for k,v in pairs(self.participants) do
				self:PlayerLeave(v, false, true)
			end
		end
	end

	self.destroy = function( self )
		for k,v in pairs(self.participants) do
			self:PlayerLeave(v)
		end

		for k,v in pairs(self.elements) do
			if isElement(v) then destroyElement( v ) end
		end
		OnUpdateTournamentDataToClients()
		LOBBIES_LIST[self.id] = nil
		setmetatable(self, nil)
	end

	if self.host then
		self:PlayerJoin( self.host )
	end

	if self.is_tournament then
		setTimer(function( id )
			local lobby = LOBBIES_LIST[id]
			if not lobby then return end
			if not lobby.started then
				if #lobby.participants >= 1 then
					lobby:FinishFight( lobby.participants[math.random(#lobby.participants)] )
				else
					local pWinner = TOURNAMENT_DATA.fights[ lobby.is_tournament ].participants[math.random(2)]
					lobby:FinishFight( pWinner )
					lobby:destroy()
				end
			end
		end, 300000, 1, self.id)

		for k, v in pairs( TOURNAMENT_DATA.fights[ self.is_tournament ].participants ) do
			local pPlayer = GetPlayer( v.uid, true )
			if pPlayer and not pPlayer:GetPermanentData( "finish_fc" ) then
				pPlayer:PhoneNotification( { title="Бойцовский клуб", msg = "Сейчас проводится твой турнирный бой, успей принять участие!" } )
			end
		end
	end

	LOBBIES_LIST[LAST_ID] = self
	LAST_ID = LAST_ID + 1
	return self
end

function OnUpdateTournamentDataToClients()
	triggerClientEvent( "FC:UpdateTournamentData", resourceRoot, TOURNAMENT_DATA )
end

addEventHandler( "onPlayerReadyToPlay", root, function ( )
 	triggerClientEvent( source, "FC:UpdateTournamentData", resourceRoot, TOURNAMENT_DATA )
end, true, "high" )

function OnCreateLobbyRequest( pPlayer, conf )
	if not pPlayer:HasFCMembership( ) then
		pPlayer:ShowError( "Доступно только для членов бойцовского клуба" )
		return false
	end

	if pPlayer:GetMoney( ) < conf.cost then
		pPlayer:ShowError( "Недостаточно средств для участия" )
		return false
	end

	if pPlayer:IsOnFactionDuty( ) then
		pPlayer:ShowError( "Нельзя принять участие находясь на смене" )
		return false
	end

	pPlayer:TakeMoney( conf.cost, "fc", "fc_lobby_create" )

	conf.host = pPlayer
	CreateLobby(conf)
end
addEvent("FC:OnCreateLobbyRequest", true)
addEventHandler("FC:OnCreateLobbyRequest", resourceRoot, OnCreateLobbyRequest)

function OnPlayerTryBuyMembership( pPlayer, iID )
	if pPlayer:GetMoney() < MEMBERSHIP_DATA[iID].cost then
		pPlayer:ShowError("Недостаточно средств для покупки билета")
		return false
	end

	if pPlayer:GetLevel() < 4 then
		pPlayer:ShowError("Требуется 4 уровень")
		return false
	end

	if pPlayer:HasFCMembership() then
		pPlayer:ShowError("У тебя уже есть билет")
		return false
	end

	pPlayer:TakeMoney( MEMBERSHIP_DATA[iID].cost, "fc", "fc_ticket_purchase" )
	pPlayer:GiveFCMembership( MEMBERSHIP_DATA[iID].days )
	pPlayer:SetPermanentData("fc_membership_id", iID)

	pPlayer:ShowSuccess("Вы успешно приобрели членство на "..MEMBERSHIP_DATA[iID].days.." дней")
	pPlayer:InventoryRemoveItem( IN_RP_TICKET )
	pPlayer:InventoryAddItem( IN_RP_TICKET, { iID }, 1 )

	triggerEvent("onPlayerFCMembershipPurchase", pPlayer, MEMBERSHIP_DATA[iID].days, MEMBERSHIP_DATA[iID].cost)
end
addEvent("FC:OnPlayerTryBuyMembership", true)
addEventHandler("FC:OnPlayerTryBuyMembership", resourceRoot, OnPlayerTryBuyMembership)

function OnFightFinished( pWinner )
	local iLobby = GetPlayerLobby( pWinner )
	if not iLobby then return end

	LOBBIES_LIST[iLobby]:FinishFight( pWinner )
end
addEvent("FC:OnFightFinished", true)
addEventHandler("FC:OnFightFinished", resourceRoot, OnFightFinished)

function GetPlayerLobby( pPlayer )
	for k,v in pairs(LOBBIES_LIST) do
		for i, fighter in pairs(v.participants) do
			if fighter == pPlayer then
				return k
			end
		end
	end
end

function OnPlayerRequestAppData()
	local data = 
	{
		fighters = {},
		bet = TOURNAMENT_BETS[ client:GetUserID() ],
	}

	for k,v in pairs( GetTodayFights() ) do
		if not v.result then
			for i, fighter in pairs(v.participants) do
				table.insert(data.fighters, { uid = fighter.uid, client_id = fighter.client_id, name = fighter.name })
			end
		end
	end

	triggerClientEvent( client, "FC:OnAppDataReceived", client, data )
end
addEvent("FC:OnPlayerRequestAppData", true)
addEventHandler("FC:OnPlayerRequestAppData", root, OnPlayerRequestAppData)

function OnPlayerRequestLobbyList()
	local pFormatted = {}
	for k,v in pairs(LOBBIES_LIST) do
		local tab = {
			name = v.name,
			max_players = 2,
			players = #v.participants or 0,
			id = v.id,
			bet = v.cost,
		}

		table.insert(pFormatted, tab)
	end

	triggerClientEvent( client, "FC:onPlayerRequestLobbyList_callback", client, pFormatted, GetPlayerLobby(client) )
end
addEvent("FC:OnPlayerRequestLobbyList", true)
addEventHandler("FC:OnPlayerRequestLobbyList", root, OnPlayerRequestLobbyList)

function OnJoinLobbyRequest( id )
	if LOBBIES_LIST[id] then
		LOBBIES_LIST[id]:OnPlayerRequestJoin( client )
	end
end
addEvent("FC:OnJoinLobbyRequest", true)
addEventHandler("FC:OnJoinLobbyRequest", root, OnJoinLobbyRequest)

function OnLeaveLobbyWaitingRequest()
	local iLobby = GetPlayerLobby(client)
	if iLobby then
		if not LOBBIES_LIST[iLobby].started then
			LOBBIES_LIST[iLobby]:PlayerLeave(client)
		end
	end
end
addEvent("FC:OnLeaveLobbyWaitingRequest", true)
addEventHandler("FC:OnLeaveLobbyWaitingRequest", root, OnLeaveLobbyWaitingRequest)

function OnPlayerQuit( pPlayer )
	local pPlayer = isElement( pPlayer ) or source
	local iLobby = GetPlayerLobby(pPlayer)
	if iLobby then
		LOBBIES_LIST[iLobby]:PlayerLeave( pPlayer )
	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit)


if SERVER_NUMBER > 100 then
	addCommandHandler( "min_participants", function( player, cmd, arg1 )
		local count = tonumber( arg1 )
		TOURNAMENT_MAX_PARTICIPANTS = count
		TESETED_COUNT = TOURNAMENT_MAX_PARTICIPANTS / 2
		player:ShowInfo( "Количество участников: " .. count ) 

		StartTournament()
	end )

	addCommandHandler( "start_tournament", function( player )
		TryStartTournament()
	end )

	addCommandHandler( "finish_tournament", function( player )
		FinishTournament( player )
	end )

	addCommandHandler( "finish_ticket", function( player )
		player:SetPermanentData( "fc_membership", 0 )
		player:SetPrivateData( "fc_membership", 0 )
	end )
end