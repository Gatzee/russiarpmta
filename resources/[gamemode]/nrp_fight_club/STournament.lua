TOURNAMENT_DATA = {}
TOURNAMENT_BETS = {}

function StartTournament()
	TOURNAMENT_DATA = 
	{
		started = getRealTimestamp(),
		recruiting = true,
		participants = {},
		max_participants = TOURNAMENT_MAX_PARTICIPANTS,
		fights = {},
	}
	OnUpdateTournamentDataToClients()
	TOURNAMENT_BETS = {}

	SaveTournamentData( true, true )

	WriteLog( "fight_club", "[TOURNAMENT_STARTED] Timestamp: %s", TOURNAMENT_DATA.started )
end

function FinishTournament( pWinner )
	local pPlayer = type( pWinner ) == "table" and GetPlayer( pWinner.uid, true ) or pWinner
	local reward_sum = #TOURNAMENT_DATA.participants * TOURNAMENT_PARTICIPATION_COST
	if pPlayer then
		pPlayer:GiveMoney( reward_sum, "fc", "fc_tournament_win" )
		pPlayer:ShowSuccess("Поздравляем, ты победил в бойцовком турнире!")

		onFightClubTournamentWin( pPlayer:GetClientID(), reward_sum )
	else
		DB:queryAsync( function( queryHandler, value )
		    local result = dbPoll( queryHandler, 0 )
		    if type ( result ) ~= "table" or #result == 0 then
		        return false
		    end

		    DB:exec("UPDATE nrp_players SET money = ? WHERE id = ? LIMIT 1", (result[1].money or 0) + value, result[1].id)
		end, { reward_sum }, "SELECT id, client_id, level, money FROM nrp_players WHERE id=? LIMIT 1", pWinner.uid )

		onFightClubTournamentWin( pWinner.client_id, reward_sum )
	end

	WriteLog( "fight_club", "[TOURNAMENT_COMPLETED] WINNER: %s", pWinner.uid )

	StartTournament()
end

function OnTournamentForceRestartRequest()
	if client then
		if client:GetAccessLevel() < ACCESS_LEVEL_DEVELOPER then
			client:ShowError("Недостаточно прав")
			return false
		end

		client:ShowSuccess("Турнир успешно перезапущен")
	end

	for k, data in pairs(TOURNAMENT_DATA.participants) do
		local pPlayer = GetPlayer( data.uid, true )
		if pPlayer then
			pPlayer:GiveMoney( TOURNAMENT_PARTICIPATION_COST, "fc", "fc_restart_refund" )
		else
			DB:queryAsync(function(queryHandler)
			    local result = dbPoll(queryHandler,0)
			    if type ( result ) ~= "table" or #result == 0 then
			        return false
			    end

			    DB:exec("UPDATE nrp_players SET money = ? WHERE id = ? LIMIT 1", (result[1].money or 0) + TOURNAMENT_PARTICIPATION_COST, result[1].id)
			end, {}, "SELECT id, money FROM nrp_players WHERE id=? LIMIT 1", data.uid)
		end
	end

	for uid, bet in pairs(TOURNAMENT_BETS) do
		local pPlayer = GetPlayer( uid, true )
		if pPlayer then
			pPlayer:GiveMoney( bet[ 2 ], "fc", "fc_restart_bet_refund" )
		else
			DB:queryAsync(function(queryHandler, bet)
			    local result = dbPoll(queryHandler,0)
			    if type ( result ) ~= "table" or #result == 0 then
			        return false
			    end

			    DB:exec("UPDATE nrp_players SET money = ? WHERE id = ? LIMIT 1", (result[1].money or 0) + bet, result[1].id)
			end, {bet[2]}, "SELECT id, money FROM nrp_players WHERE id=? LIMIT 1", uid)
		end
	end

	StartTournament()
end
--addEvent("FC:OnTournamentForceRestartRequest", true)
--addEventHandler("FC:OnTournamentForceRestartRequest", root, OnTournamentForceRestartRequest)

function GetTournamentDay()
	return math.ceil( (getRealTimestamp() - TOURNAMENT_DATA.started or 0) / (24*60*60) )
end

function GetTodayFights( iDay )
	local result = {}
	local iDay = iDay or GetTournamentDay()
	for k,v in pairs(TOURNAMENT_DATA.fights) do
		if v.day == iDay or SERVER_NUMBER > 100 then
			table.insert(result, v)
		end
	end

	return result
end

function OnPlayerTryParticipate( pPlayer )
	local iUserID = pPlayer:GetUserID()

	if IsPlayerParticipatingTournament( pPlayer ) then
		pPlayer:ShowError("Ты уже принимаешь участие в турнире")
		return false
	end

	if #TOURNAMENT_DATA.participants >= TOURNAMENT_MAX_PARTICIPANTS then
		pPlayer:ShowError("Свободных мест не осталось")
		return false
	end

	if pPlayer:TakeMoney( TOURNAMENT_PARTICIPATION_COST, "fc", "fc_tournament_purchase" ) then
		pPlayer:SetPermanentData( "finish_fc", false )

		table.insert( TOURNAMENT_DATA.participants, { uid = iUserID, client_id = pPlayer:GetClientID(), name = pPlayer:GetNickName() } )
		pPlayer:ShowSuccess("Ты успешно записался на участие в турнире")

		if #TOURNAMENT_DATA.participants >= TOURNAMENT_MAX_PARTICIPANTS then
			TOURNAMENT_DATA.recruiting = false
			GenerateTournamentGrid()
		end
		OnUpdateTournamentDataToClients()
		SaveTournamentData( true, false )
	else
		pPlayer:ShowError( "Недостаточно средств для участия в турнире")
	end
end
--addEvent("FC:OnPlayerTryParticipate", true)
--addEventHandler("FC:OnPlayerTryParticipate", resourceRoot, OnPlayerTryParticipate)

function GenerateTournamentGrid()
	local fighters = table.copy( TOURNAMENT_DATA.participants )

	local function GetRandomFighter()
		local iRand = math.random( #fighters )
		local pFighter = table.copy( fighters[iRand] )
		table.remove(fighters, iRand)

		return pFighter
	end

	local iDay = 1
	for i = 1, math.floor( #fighters/2 ) do
		TOURNAMENT_DATA.fights[i] = { id = i, participants = { GetRandomFighter(), GetRandomFighter() }, round = 1, day = iDay }
	end
	OnUpdateTournamentDataToClients()

	SaveTournamentData( true, false )
end

function UpdateTournamentGrid( iRound )
	local pLastFight = TOURNAMENT_DATA.fights[#TOURNAMENT_DATA.fights]

	local function GetRandomFighter()
		local pIgnoredUsers = {}
		for i, fight in pairs(TOURNAMENT_DATA.fights) do
			if not fight.result then
				for k,v in pairs(fight.participants) do
					pIgnoredUsers[v.uid] = true
				end
			end
		end

		local pFightersLeft = {}
		for i, fight in pairs(TOURNAMENT_DATA.fights) do
			if fight.result and fight.round == iRound then
				if not pIgnoredUsers[ fight.result.uid ] then
					table.insert(pFightersLeft, { uid = fight.result.uid, client_id = fight.result.client_id, name = fight.result.name })
				end
			end
		end

		return #pFightersLeft >= 1 and pFightersLeft[math.random(#pFightersLeft)]
	end

	if iRound == 4 or iRound == TESETED_COUNT then
		FinishTournament( TOURNAMENT_DATA.fights[#TOURNAMENT_DATA.fights].result )
		return
	end

	local pFighter = GetRandomFighter()
	if pFighter then
		if pLastFight then
			if #pLastFight.participants < 2 then
				table.insert(pLastFight.participants, pFighter)
			else
				GetTodayFights( pLastFight.day )
				local iDay = GetTournamentDay() + 1

				table.insert(TOURNAMENT_DATA.fights, { id = #TOURNAMENT_DATA.fights+1, participants = {pFighter}, round = iRound + 1, day = iDay })
				OnUpdateTournamentDataToClients()
			end
		end
	end

	SaveTournamentData( true, true )
end

function OnPlayerTryPlaceBet( pPlayer, amount, uid, name )
	local iUserID = pPlayer:GetUserID()

	local amount = tonumber(amount)
	if not amount then
		pPlayer:ShowError("Некорректная сумма ставки")
		return false
	end

	amount = math.abs( math.floor(amount) )

	if TOURNAMENT_BETS[iUserID] then
		pPlayer:ShowError("Ты уже сделал ставку на сегодняшний бой")
		return false
	end

	if not pPlayer:HasFCMembership() then
		pPlayer:ShowError("Необходимо членство в клубе")
		return false
	end

	if IsPlayerParticipatingTournament( pPlayer ) then
		pPlayer:ShowError("Участники турнира не могут делать ставки")
		return false
	end

	if amount > 15000 then
		pPlayer:ShowError("Максимальный размер ставки - 15.000")
		return false
	end

	if pPlayer:TakeMoney( amount, "fc", "fc_tournament_bet" ) then
		TOURNAMENT_BETS[iUserID] = {uid, amount, pPlayer:GetClientID()}
		pPlayer:ShowSuccess("Ты успешно поставил "..amount.." на "..name)
		SaveTournamentData( false, true )
		return true
	else
		pPlayer:ShowError( "Недостаточно средств для ставки")
	end
end
--addEvent("FC:OnPlayerTryPlaceBet", true)
--addEventHandler("FC:OnPlayerTryPlaceBet", root, OnPlayerTryPlaceBet)

function IsPlayerParticipatingTournament( pPlayer )
	if isElement(pPlayer) then
		local iUserID = pPlayer:GetUserID()
		for k,v in pairs(TOURNAMENT_DATA.participants) do
			if v.uid == iUserID then
				return true
			end
		end
	end
end

function CreateTournamentLobby( fight_data )
	WriteLog( "fight_club", "[LOBBY_CREATED] Day: %s", fight_data.day )

	return CreateLobby({
		is_tournament = fight_data.id,
		name = "[Турнир] "..fight_data.participants[1].name.." x "..fight_data.participants[2].name
	})
end

function SaveTournamentData( bTournament, bBets )
	if bTournament then
		DB:exec("UPDATE nrp_fight_club SET cvalue = ? WHERE ckey = ?", toJSON(TOURNAMENT_DATA), "tournament")
	end

	if bBets then
		DB:exec("UPDATE nrp_fight_club SET cvalue = ? WHERE ckey = ?", toJSON(TOURNAMENT_BETS), "bets")
	end
end

function LoadTournamentData()
	DB:queryAsync(function(queryHandler, value)
	    local result = dbPoll(queryHandler,0)
	    if type ( result ) ~= "table" or #result == 0 then
			StartTournament()
			DB:exec("INSERT INTO nrp_fight_club ( ckey, cvalue ) VALUES(?, ?)", "tournament", toJSON(TOURNAMENT_DATA) )
			DB:exec("INSERT INTO nrp_fight_club ( ckey, cvalue ) VALUES(?, ?)", "bets", toJSON({}) )
	        return false
	    end

	    for k,v in pairs(result) do
			if v.ckey == "bets" then
				TOURNAMENT_BETS = fromJSON(v.cvalue)
			elseif v.ckey == "tournament" then
				TOURNAMENT_DATA = fromJSON(v.cvalue)
				OnUpdateTournamentDataToClients()
			end
	    end

		local timestamp = getRealTimestamp()
		local time = getRealTime( timestamp )

	    if time.hour > 18 then
			local pFights = GetTodayFights()
			for k, v in pairs(pFights) do
				if not v.result then
					CreateTournamentLobby( v )
					break
				end
			end
	    end

		Tournament_StartTimed()
	end, {}, "SELECT * FROM nrp_fight_club")
end

--addEventHandler("onResourceStart", resourceRoot, function()
--	DB:createTable("nrp_fight_club", {
--	    { Field = "ckey",			Type = "varchar(128)",		Null = "NO",	Key = "PRI",		Default = NULL  };
--	    { Field = "cvalue",			Type = "json",				Null = "NO",	Key = "",			Default = NULL  };
--	})
--
--	LoadTournamentData()
--end)

function Tournament_StartTimed()
	ExecAtTime( TOURNAMENT_FIGHTS_TIME, TryStartTournament )
end

function TryStartTournament()
	local iDay = GetTournamentDay()
	for k, v in pairs( TOURNAMENT_DATA.fights ) do
		if v.day < iDay and not v.result then
			local pWinner = v.participants[ math.random(#v.participants) ]
			v.result = { duration = 0,  name = pWinner.name, client_id = pWinner.client_id, uid = pWinner.uid }
			UpdateTournamentGrid( v.round )

			WriteLog( "fight_club", "[FIGHT_BROKEN] Fight Day: %s, Tournament Day: %s, Generated winner: %s", v.day, iDay, pWinner.uid )
		end
	end

	local pFights = GetTodayFights()
	for k, v in pairs( pFights ) do
		if not v.result then
			CreateTournamentLobby( v )
		end
	end

	local pSuitablePlayers = {}
	for k, v in pairs( GetPlayersInGame() ) do
		if v:GetLevel() > 3 then
			table.insert( pSuitablePlayers, v )
		end
	end

	if #pSuitablePlayers > 0 then
		triggerLatentClientEvent( pSuitablePlayers, "OnClientReceivePhoneNotification", root, 
		{
			title = "Турнир единоборств",
			msg   = "Начались бои турнира смешанных единоборств!",
		} )
	end
end

--TOURNAMENT_START_TIMER = Timer( Tournament_StartTimed, MS24H, 0 )

