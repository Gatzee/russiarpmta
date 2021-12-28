loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SDB" )
Extend( "ShSocialRating" )

local PLAYER_FINES = {}
local FINES = {}
local PLAYER_LAST_FINE_GIVEN = {}
local PLAYER_LAST_FINE_RECEIVED = {}
PLAYER_DOCUMENTS_SHOWN = {}

local ADD_FINE_DELAY = 15*60

function OnResourceStart()
	DB:createTable( "nrp_fines", {
        { Field = "id",						Type = "int(11) unsigned",		Null = "NO",	Key = "PRI", Extra = "auto_increment", Default = NULL },
        { Field = "source_uid",          	Type = "int(11) unsigned",	    Null = "NO",	Key = "",  },
		{ Field = "target_uid",				Type = "int(11) unsigned",		Null = "YES",	Key = "",  },
		{ Field = "source_name",			Type = "text",					Null = "NO",	Key = "",	Default = "" },
		{ Field = "target_name",			Type = "text",					Null = "NO",	Key = "",	Default = "" },
		{ Field = "fine_id",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 1 },
		{ Field = "cost",					Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0 },
		{ Field = "reason",					Type = "text",					Null = "YES",	Key = "",	Default = NULL },
		{ Field = "creation_date",			Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0 },
		{ Field = "repayment_date",			Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL },
	})

	DB:exec( "CREATE INDEX target_uid ON nrp_fines( target_uid )" )

	for i, player in pairs( getElementsByType("player") ) do
		OnPlayerReadyToPlay( player )
	end
end
addEventHandler("onResourceStart", resourceRoot, OnResourceStart)

function OnResourceStop()
	for i, player in pairs( getElementsByType("player") ) do
		OnPlayerQuit( player )
	end
end
addEventHandler("onResourceStop", resourceRoot, OnResourceStop)

function OnPlayerReadyToPlay( pPlayer )
	local pPlayer = isElement(pPlayer) and getElementType(pPlayer) == "player" and pPlayer or source

	LoadPlayerFines( pPlayer )
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerReadyToPlay, true, "low-1000")

function OnPlayerQuit( pPlayer )
	local pPlayer = isElement(pPlayer) and pPlayer or source

	if PLAYER_FINES[pPlayer] then
		for k,v in pairs(PLAYER_FINES[pPlayer]) do
			FINES[ v.id ] = nil
		end

		PLAYER_FINES[pPlayer] = nil
	end

	PLAYER_LAST_FINE_GIVEN[pPlayer] = nil
	PLAYER_LAST_FINE_RECEIVED[pPlayer] = nil
	PLAYER_DOCUMENTS_SHOWN[pPlayer] = nil

	PLAYER_LAST_WANTED_GIVEN[pPlayer] = nil
	PLAYER_LAST_WANTED_RECEIVED[pPlayer] = nil

	if CONFISCATION_SEQUENCES[ pPlayer ] then
		if isElement( CONFISCATION_SEQUENCES[ pPlayer ].timer ) then killTimer( CONFISCATION_SEQUENCES[ pPlayer ].timer ) end

		CONFISCATION_SEQUENCES[ pPlayer ].vehicle:SetConfiscated( true )
		CONFISCATION_SEQUENCES[ pPlayer ] = nil
	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit, true, "high+99999999999")

function LoadPlayerFines( pPlayer )
	local function OnPlayerFinesListReceived( query, player )
		if not isElement( player ) then
			dbFree( query )
			return
		end 

		local result = dbPoll( query, 0 )
		if type(result) ~= "table" then return end

		PLAYER_FINES[player] = {}

		for k,v in pairs(result) do
			v.player = player
			FINES[ v.id ] = v
			PLAYER_FINES[player][ v.id ] = FINES[ v.id ]
		end

		if not PlayerHasFines( player ) then
			if player:HasConfiscatedVehicle() then
				for k,v in pairs( player:GetVehicles( _, true ) ) do
					if v:IsConfiscated() then
						v:SetConfiscated( false )
					end
				end
			end
		end
	end
	DB:queryAsync( OnPlayerFinesListReceived, { pPlayer }, "SELECT * FROM nrp_fines WHERE target_uid = ?", pPlayer:GetID() )
end

function AddFine( pSource, pTarget, iFine, sReason, iCost )
	if not isElement(pTarget) then
		if isElement(pSource) and getElementType(pSource) == "player" then
			pSource:ShowInfo("Игрок не найден")
		end

		return false
	end

	if pTarget:GetLevel() < 3 then return end

	local pFineData = FINES_LIST[iFine]
	local pNewFine = {
		fine_id = iFine,
		reason = sReason or "",
		cost = iCost and tonumber(iCost) or pFineData.cost,
		creation_date = getRealTime().timestamp,
		target_uid = pTarget:GetID(),
		source_uid = isElement(pSource) and pSource:GetID() or 0,
		target_name = pTarget:GetNickName(),
		source_name = isElement(pSource) and pSource:GetNickName() or "-",
	}

	local function OnFineAddedToDatabase( query, pSource, pTarget, pNewFine )
		local result, rows, last_id = dbPoll( query, 0 )

		if last_id then
			pNewFine.id = tonumber(last_id)

			if isElement(pTarget) then
				pNewFine.player = pTarget

				FINES[ last_id ] = pNewFine

				if not PLAYER_FINES[ pTarget ] then PLAYER_FINES[ pTarget ] = {} end

				PLAYER_FINES[ pTarget ][ last_id ] = FINES[ last_id ]

				if pTarget:GetFinesSum( ) >= 60000 then
					pTarget:AddWanted( "1.11", 1, true )

					pTarget:ShowInfo("Сумма штрафов превысила 60.000\nПоторопись оплатить их, или твой транспорт отправят на штраф-стоянку!")

					local pVehicle = pTarget.vehicle
					if pVehicle and not CONFISCATION_SEQUENCES[ pTarget ] then
						if pVehicle:GetOwnerID( ) == pTarget:GetID( ) then
							StartConfiscationSequence( pTarget, pVehicle )
						else
							local vehicles = pTarget:GetVehicles( nil, true, true )
							if next( vehicles ) then
								local vehicle = vehicles[ math.random( 1, #vehicles ) ]
								StartConfiscationSequence( pTarget, vehicle )
							end
						end
					end
				end

				-- ANALYTICS
				triggerEvent( "OnPlayerPunishmentReceived", pTarget, "fine", pNewFine.fine_id, pNewFine.cost )
			end
		end
	end

	local pKeys, pValues, pSymbols = {}, {}, {}

	for k, v in pairs(pNewFine) do
		table.insert( pKeys, k )
		table.insert( pValues, v )
		table.insert( pSymbols, "?" )
	end

	DB:queryAsync( OnFineAddedToDatabase, { pSource, pTarget, pNewFine }, "INSERT INTO nrp_fines ( ".. table.concat(pKeys, ", ") .." ) VALUES ( "..table.concat(pSymbols, ", ").." )", unpack( pValues ))
end
addEvent( "OnAddFineRequest", true )
addEventHandler( "OnAddFineRequest", root, AddFine )

function RemoveFine( iFineID )
	local iFineID = tonumber(iFineID)
	if not iFineID then return end

	local pFine = FINES[iFineID]

	if pFine then
		if pFine.player and isElement(pFine.player) then
			PLAYER_FINES[ pFine.player ][ iFineID ] = nil
		end

		FINES[iFineID] = nil

		if not PlayerHasFines( pFine.player ) then
			if pFine.player:HasConfiscatedVehicle() then
				for k,v in pairs( pFine.player:GetVehicles( _, true ) ) do
					if v:IsConfiscated() then
						v:SetConfiscated( false )
					end
				end
			end

			if pFine.player:IsWantedFor("1.11") then
				pFine.player:RemoveWanted("1.11")

				if CONFISCATION_SEQUENCES[ pFine.player ] then
					BreakConfiscationSequence( pFine.player )
				end
			end
		end

		if pFine.fine_id == 14 and pFine.player:IsWantedFor( "1.13" ) then
			pFine.player:RemoveWanted( "1.13" )
		end
	end

	DB:exec( "DELETE FROM nrp_fines WHERE id = ? LIMIT 1", iFineID )

	return true
end
addEvent("OnRemoveFineRequest", true)
addEventHandler("OnRemoveFineRequest", root, RemoveFine)

function RemoveAllPlayerFines( pPlayer )
	local pFinesList = GetPlayerFines( pPlayer )

	for k,v in pairs(pFinesList) do
		RemoveFine( v.id )
	end

	return true
end

function GetPlayerFines( pPlayer )
	local pFinesList = {}

	if PLAYER_FINES[ pPlayer ] then
		for k,v in pairs(PLAYER_FINES[pPlayer]) do
			table.insert(pFinesList, v)
		end
	end

	return pFinesList
end

function GetPlayerFinesSum( pPlayer )
	local pFines = GetPlayerFines( pPlayer )

	local iTotalCash = 0

	for k,v in pairs(pFines) do
		iTotalCash = iTotalCash + (v.cost or 0)
	end

	return iTotalCash
end

function PlayerHasFines( pPlayer )
	local pFines = GetPlayerFines( pPlayer )
	return pFines and #pFines > 0
end

function OnPlayerTryAddFines( pTarget, pFines, bOnPost, pOptionalSource )

	-- **pOptionalSource для вызова из SWanted.lua
	local pSource = client or pOptionalSource
	local iCurrentTime = getRealTime().timestamp

	if not isElement(pSource) or not isElement(pTarget) then
		if isElement(pSource) then
			pSource:ShowError("Игрок не найден")
		end

		return
	end

	local iLastDocumentsShown = PLAYER_DOCUMENTS_SHOWN[pSource] and PLAYER_DOCUMENTS_SHOWN[pSource][pTarget]

	if not iLastDocumentsShown or (getRealTime().timestamp - iLastDocumentsShown) > 600 then
		pSource:ShowError( "Сначала предъяви игроку документы" )
		return
	end

	if not bOnPost then
		if PLAYER_LAST_FINE_GIVEN[ pSource ] then
			local iTimePassed = iCurrentTime - PLAYER_LAST_FINE_GIVEN[ pSource ]
			if iTimePassed < ADD_FINE_DELAY then
				pSource:ShowError("Нельзя выписывать штрафы так часто.\n(Доступно через: "..math.ceil( (ADD_FINE_DELAY - iTimePassed) / 60 ).." мин)")
				return
			end
		end
	end

	if PLAYER_LAST_FINE_RECEIVED[ pTarget ] then
		local iTimePassed = iCurrentTime - PLAYER_LAST_FINE_RECEIVED[ pTarget ]
		if iTimePassed < ADD_FINE_DELAY then
			pSource:ShowError("Игроку недавно выписывали штрафы.\n(Доступно через: "..math.ceil( (ADD_FINE_DELAY - iTimePassed) / 60 ).." мин)")
			return
		end
	end

	-- add
	for k,v in pairs( pFines ) do
		AddFine( pSource, pTarget, v )
	end

	PLAYER_LAST_FINE_GIVEN[ pSource ] = iCurrentTime
	PLAYER_LAST_FINE_RECEIVED[ pTarget ] = iCurrentTime

	pSource:ShowSuccess("Штраф успешно выписан")
	pTarget:ShowInfo("Вам выписали штраф")

    return true
end
addEvent( "OnPlayerTryAddFines", true )
addEventHandler( "OnPlayerTryAddFines", resourceRoot, OnPlayerTryAddFines )

function OnPlayerTryPayFines( sMethod, jail_id )
	local pPlayer = client or source
	local sMethod = sMethod or "cash"

	if sMethod == "cash" then
		local pFinesList = GetPlayerFines( pPlayer )
		local iTotalCost = 0

		if #pFinesList < 1 then
			pPlayer:ShowError("У тебя нет штрафов")
			return false
		end

		for k,v in pairs(pFinesList) do
			iTotalCost = iTotalCost + (v.cost or 0)
		end

		if pPlayer:TakeMoney( iTotalCost, "fines_pay" ) then
			pPlayer:ChangeSocialRating( #pFinesList * SOCIAL_RATING_RULES.fine.rating )

			-- ANALYTICS
			for k,v in pairs(pFinesList) do
				triggerEvent( "OnPlayerFinePaid", pPlayer, v.fine_id )
			end

			RemoveAllPlayerFines( pPlayer )
			pPlayer:ShowSuccess("Штрафы успешно оплачены")
		else
			pPlayer:EnoughMoneyOffer( "Fines pay", iTotalCost, "OnPlayerTryPayFines", pPlayer, sMethod )
		end
	elseif sMethod == "jail" then
		if not pPlayer:IsWantedFor("1.11") then
			pPlayer:AddWanted( "1.11", 1, true )
		end

		pPlayer:Jail( nil, jail_id )
		SendToLogserver( "Игрок " .. pPlayer:GetNickName() .. " отсидит за штрафы" )
	end
end
addEvent( "OnPlayerTryPayFines", true )
addEventHandler( "OnPlayerTryPayFines", root, OnPlayerTryPayFines )

function OnPlayerReleasedFromJail()
	local pPlayer = source
	if not isElement(pPlayer) then return end

	RemoveAllPlayerFines( pPlayer )
end
addEvent("OnPlayerReleasedFromJail", true)
addEventHandler("OnPlayerReleasedFromJail", root, OnPlayerReleasedFromJail)

function OnPlayerRequestShowFinesList( pPlayer, jail_id )
	local pPlayer = client or source or pPlayer

	local pFinesList = GetPlayerFines( pPlayer )
	local pListToSend = { }

	for k, v in pairs(pFinesList) do
		table.insert( pListToSend, v.fine_id )
	end

	triggerClientEvent( pPlayer, "ShowUI_FinesList", resourceRoot, true, { fines = pListToSend, jail_id = jail_id } )
end
addEvent("OnPlayerRequestShowFinesList", true)
addEventHandler("OnPlayerRequestShowFinesList", resourceRoot, OnPlayerRequestShowFinesList)

function OnPlayerRequestAddFineOrWantedUI( pTarget, iType )
	local pPlayer = client or source

	if not isElement(pTarget) then return end

	if iType == 1 then
		triggerClientEvent( pPlayer, "ShowUI_AddFine", resourceRoot, true, { target = pTarget } )
	elseif iType == 2 then
		triggerClientEvent( pPlayer, "ShowUI_AddWanted", resourceRoot, true, { target = pTarget } )
	end
end
addEvent("OnPlayerRequestAddFineOrWantedUI", true)
addEventHandler("OnPlayerRequestAddFineOrWantedUI", root, OnPlayerRequestAddFineOrWantedUI)

function OnPlayerShownPoliceID( pTarget )
	local pPlayer = client or source

	if not PLAYER_DOCUMENTS_SHOWN[ pPlayer ] then
		PLAYER_DOCUMENTS_SHOWN[ pPlayer ] = {}
	end

	PLAYER_DOCUMENTS_SHOWN[ pPlayer ][ pTarget ] = getRealTime().timestamp
end
addEvent("OnPlayerShownPoliceID", true)
addEventHandler("OnPlayerShownPoliceID", root, OnPlayerShownPoliceID)