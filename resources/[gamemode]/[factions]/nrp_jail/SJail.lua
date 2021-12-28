loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShSocialRating" )
Extend( "ShVehicleConfig" )
Extend( "ShClans" )

JAILED_PLAYERS_LIST = {}

-- Создание камер
function InitJailRooms()
	for i, jail in pairs(JAIL_ROOM_POSITIONS) do
		for k, room in pairs( jail.rooms ) do
			room.players = {}
			room.element = createColSphere( room.x, room.y, room.z, room.size )
			setElementDimension(room.element, room.dimension or jail.dimension or 0)
			setElementInterior(room.element, room.interior or jail.interior or 0)
		end
	end
end

-- Поиск свободной комнаты
function JailGetFreeRoomID( iJailID )
	local iRoomID
	local pJailData = JAIL_ROOM_POSITIONS[iJailID]

	if pJailData then
		for i, room in pairs(pJailData.rooms) do
			local iPlayersInside = room.players and #room.players or 0
			if iPlayersInside < room.capacity then
				iRoomID = i
				break
			end
		end

		if not iRoomID then
			iRoomID = math.random(1,#pJailData.rooms)
		end
	end

	return iRoomID or 1
end

-- Посадить в КПЗ
function JailPlayer( pSource, pTarget, iJailID, iTime, sReason, by_admin_cmd, on_login )
	if not isElement(pTarget) then return end

	if pTarget:getData( "phone.call" ) then
		triggerEvent( "onServerEndPhoneCall", pTarget, pTarget )
	end

	local is_source = isElement( pSource )

	if is_source then
		local faction = pSource:GetFaction()
		if not by_admin_cmd and not ( FACTION_RIGHTS.JAILID[ faction ] and FACTION_RIGHTS.JAILID[ faction ] == iJailID ) then
			return false
		end

		if pSource.dimension ~= pTarget.dimension or pSource.interior ~= pTarget.interior then
			return false
		end
	end

	if JAILED_PLAYERS_LIST[ pTarget ] then
		ReleasePlayer( nil, pTarget )
	end

	local iJailID = iJailID
	if not iJailID then
		local nearest_jail = nil
		local target_pos = pTarget.position

		for idx, data in pairs( JAIL_ROOM_POSITIONS ) do
			local c_pos = data.rooms[ 1 ]
			local dist = getDistanceBetweenPoints3D( c_pos.x, c_pos.y, c_pos.z, target_pos )
			if not nearest_jail or nearest_jail.dist < dist then
				nearest_jail = { id = idx, dist = dist }
			end
		end

		iJailID = nearest_jail.id
	end

	local iRoomID = JailGetFreeRoomID( iJailID )
	local sReason = sReason or "Нарушение законов"

	local iTotalJailTime = GetTotalJailTime( pTarget )
	local iTime = ( by_admin_cmd and iTime and iTime + iTotalJailTime ) or iTime or iTotalJailTime
	
	if not on_login and not by_admin_cmd then
		if pTarget:IsInClan() then
			iTime = iTime * ( 1 - pTarget:GetClanBuffValue( CLAN_UPGRADE_JAIL_TIME ) / 100 - pTarget:GetClanBuffValue( CLAN_UPGRADE_JAIL_TIME_2 ) / 100 )
		end
	end

	if iTime <= 0 then return end

	local release_player = false
	local iHigherPunishment = 0
	for k,v in pairs( pTarget:GetWantedData() ) do
		if not WANTED_REASONS_LIST[ v ] then
			-- Есть какая-то статья из-за которой не могли посадить чувака, будем ловить
			outputDebugString( "NON_EXIST_WANTED_REASON №" .. v, 1, 255, 0, 0 )
			ReleasePlayer( nil, pTarget, _, true )
			return false
		elseif WANTED_REASONS_LIST[ v ].duration > iHigherPunishment then
			iHigherPunishment = WANTED_REASONS_LIST[ v ].duration
			sReason = WANTED_REASONS_LIST[ v ].name
		end
	end

	if pTarget:IsOnFactionDuty() then
		pTarget:EndFactionDuty()
	end

	if pTarget.vehicle then
		pTarget.vehicle = nil
	end
	pTarget:ParkedVehicles()

	local pJailData = JAIL_ROOM_POSITIONS[ iJailID ]
	local pRoomData = pJailData.rooms[ iRoomID ]
	local pOldPosition = pTarget.position

	setElementInterior( pTarget, pRoomData.interior or pJailData.interior )
	setElementDimension( pTarget, pRoomData.dimension or pJailData.dimension )
	local vecPositionBias = Vector3( math.random(-pRoomData.size*0.5, pRoomData.size*0.5), math.random(-pRoomData.size*0.5, pRoomData.size*0.5), 0 )
	setElementPosition( pTarget, Vector3(pRoomData.x, pRoomData.y, pRoomData.z)	+ vecPositionBias )

	table.insert( pRoomData.players, pTarget )

	JAILED_PLAYERS_LIST[pTarget] = {
		jail_id = iJailID,
		room_id = iRoomID,
		room_element = pRoomData.element,
		time_left = iTime,
		reason = sReason,
		admin = by_admin_cmd,
		is_on_event = pTarget:getData( "is_on_event" ),
		old_position = pOldPosition,
	}

	if isElement( pTarget ) then 
		pTarget:SetPermanentData( "jail_data", {
			time_left = iTime,
			jail_id = iJailID,
			reason = sReason,
			admin = by_admin_cmd,
		} )
	end
	SendToLogserver( "Игрок " .. pTarget:GetNickName() .. " заключен в КПЗ", { reason = sReason, time_left = iTime } )

	local count_players = 0
	for k, v in pairs( JAILED_PLAYERS_LIST ) do
		count_players = count_players + 1
	end

	--Если число заключенных в КПЗ больше 10, то сообщаем сотрудникам фсин
	if count_players >= 10 then
		local target_fsin_players = {}
		for _, v in pairs( getElementsByType( "player" ) ) do
			if v:IsInGame() and v:IsOnFactionDuty() and v:GetFaction() == F_FSIN then
				table.insert( target_fsin_players, v )
			end
		end
		
		triggerClientEvent( target_fsin_players, "ShowInfo", resourceRoot, "В КПЗ находится больше 10 человек, необходимо произвести перевозку")
	end

	pTarget:ChangeSocialRating( SOCIAL_RATING_RULES.arrest.rating )
	pTarget:ShowInfo("Вас заключили в КПЗ ("..sReason..")")
	pTarget:TakeAllWeapons()
	--pTarget:setVoiceBroadcastTo( nil )

	if is_source then
		triggerClientEvent( pSource, "PlayerAction_JailedSuccess", pTarget )
		pSource:GiveFactionExp( 150, "JailPlayer" )
	end

	triggerClientEvent( pTarget, "jail:OnPlayerJailed", pTarget, JAILED_PLAYERS_LIST[pTarget] )

	local sReasonArticle, iHigherValue = "", 0
	for k,v in pairs( pTarget:GetWantedData() or {} ) do
		if WANTED_REASONS_LIST[v].duration > iHigherValue then
			sReasonArticle = v
			iHigherValue = WANTED_REASONS_LIST[v].duration
		end
	end

	triggerEvent( "OnPlayerJailed", pTarget, math.floor(iTime/60), sReasonArticle, pSource )
	setElementData( pTarget, "jailed", true )

	triggerEvent( "PlayerFailStopQuest", pTarget, { type = "fail_jail", fail_text = "Вы попали в КПЗ" } )
	triggerEvent( "onServerPlayerFailCoopQuest", pTarget, "попал в КПЗ" )

	if pTarget:GetClanID() then
		pTarget:AddClanStats("arrests", 1)
		pTarget:AddClanStats("jail_time", iTime/60)
	end
end

-- Выпустить из КПЗ
function ReleasePlayer( pSource, pTarget, sReason, bUpdate, move_prison )
	local pData = JAILED_PLAYERS_LIST[ pTarget ]
	if not pData then return end

	if pSource and isElement(pSource) then
		local faction = pSource:GetFaction()
		if not pSource:IsAdmin() and not ( FACTION_RIGHTS.JAILID[ faction ] and FACTION_RIGHTS.JAILID[ faction ] == pData.jail_id ) then
			return false
		end

		local count_release = pSource:GetPermanentData( "release_players" ) or 0
		if not pSource:IsAdmin() and count_release >= 3 then
			pSource:ShowError("Вы освободили сегодня уже 3 человека!")
			return false
		end
		count_release = count_release + 1
		pSource:SetPermanentData( "release_players", count_release )
	end

	local sReason = sReason or " - "

	local pReleasePositions = JAIL_ROOM_POSITIONS[ pData.jail_id ].release_positions
	local pRandomReleasePosition = pReleasePositions[ math.random(1, #pReleasePositions) ]

	if pData.admin then
		if isElement(pSource) and not pSource:IsAdmin() then
			return
		end
	end

	triggerClientEvent( pTarget, "jail:OnPlayerReleased", pTarget, move_prison )

	if not move_prison then
		setElementPosition( pTarget, pRandomReleasePosition.x, pRandomReleasePosition.y, pRandomReleasePosition.z )
		setElementInterior( pTarget, pRandomReleasePosition.interior or 0 )
		setElementDimension( pTarget, pRandomReleasePosition.dimension or 0 )
	end

	SendToLogserver( "Игрок " .. pTarget:GetNickName() .. " освобожден из КПЗ", { reason = sReason, move_prison = move_prison or false } )

	pTarget:ShowInfo("Вы были выпущены из КПЗ ( "..sReason.." )")
	--pTarget:setVoiceBroadcastTo( root )

	-- Выпустить с обнулением данных о сроке ( нативный выход )
	if bUpdate then
		local pRoomData = JAIL_ROOM_POSITIONS[ pData.jail_id ].rooms[ pData.room_id ]
		for k,v in pairs(pRoomData.players) do
			if v == pTarget then
				table.remove( pRoomData.players, k )
				break
			end
		end

		JAILED_PLAYERS_LIST[ pTarget ] = nil

		local sReasonArticle, iHigherValue = "", 0
		for k,v in pairs( pTarget:GetWantedData() or {} ) do
			if WANTED_REASONS_LIST[v].duration > iHigherValue then
				sReasonArticle = v
				iHigherValue = WANTED_REASONS_LIST[v].duration
			end
		end

		local iTotalTime = GetTotalJailTime( pTarget )
		
		triggerEvent( "OnPlayerReleasedFromJail", pTarget, iTotalTime, sReasonArticle )

		pTarget:ClearWanted()
		pTarget:SetPermanentData("jail_data", {})
	end

	removeElementData( pTarget, "jailed" )

	if pTarget:IsOnUrgentMilitary() then
		pTarget:EnterOnUrgentMilitaryBase()
	end

	if pData.is_on_event then
		pTarget.position = pData.old_position
		triggerEvent( "OnPlayerAdminEventUnjail", pTarget )
	end
end

function OnPlayerReleasedByUI( pTarget )
	if isElement(client) and isElement(pTarget) then
		ReleasePlayer( client, pTarget, "Сотрудником полиции", true )

		client:outputChat("Вы успешно выпустили заключённого "..pTarget:GetNickName().." из КПЗ")

		for i, v in pairs( getElementsByType( "player" ) ) do
			if v:IsAdmin() then
				outputChatBox( ( "%s выпустил %s из КПЗ" ):format( client:GetNickName(), pTarget:GetNickName() ), v, 255, 255, 255, true )
			end
		end

		WriteLog( "factions/unjail", "%s вытащил игрока %s из КПЗ", client, pTarget )
	end
end
addEvent("jail:OnPlayerReleasedByUI", true)
addEventHandler("jail:OnPlayerReleasedByUI", root, OnPlayerReleasedByUI)

-- Обновление сроков
function UpdateJailData()
	for player, data in pairs(JAILED_PLAYERS_LIST) do
		data.time_left = data.time_left - 10

		if data.time_left <= 0 then
			ReleasePlayer( nil, player, "Срок истёк", true )
		end
	end
end

-- Обработчик попадания в КПЗ при входе
function PlayerReadyToPlay_handler()
	local pPlayer = source

	if isElement(pPlayer) then
		local pData = pPlayer:GetPermanentData("jail_data") or {}

		if pData.time_left and pData.time_left > 0 then
			JailPlayer( nil, pPlayer, pData.jail_id, pData.time_left, pData.reason, false, true )
		end
	end
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, PlayerReadyToPlay_handler, true, "low-1000")


-- Сохранение данных при выходе
function SaveJailData( pPlayer )
	local pPlayer = isElement( pPlayer ) and pPlayer or source

	local pJailData = JAILED_PLAYERS_LIST[ pPlayer ]
	if pJailData then
		local pDataToSave = {
			time_left = pJailData.time_left,
			jail_id = pJailData.jail_id,
			reason = pJailData.reason,
			admin = pJailData.admin,
		}

		pPlayer:SetPermanentData("jail_data", pDataToSave)

		JAILED_PLAYERS_LIST[ pPlayer ] = nil

		local pRoomData = JAIL_ROOM_POSITIONS[ pJailData.jail_id ].rooms[ pJailData.room_id ]
		for k,v in pairs(pRoomData.players) do
			if v == pPlayer then
				table.remove( pRoomData.players, k )
				break
			end
		end

	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, SaveJailData)


function GetJailedPlayers( jail_id )
	local jail_data = {}
	for k, v in pairs( JAILED_PLAYERS_LIST ) do
		if k:getData( "jailed" ) == true then
			if jail_id and v.jail_id == jail_id then
				table.insert( jail_data, { player = k, data = v } )
			elseif not jail_id then
				table.insert( jail_data, { player = k, data = v } )
			end
		end
	end

	return jail_data
end


-- Выпускаем всех при остановке ресурса
addEventHandler("onResourceStop", resourceRoot, function()
	for player, data in pairs(JAILED_PLAYERS_LIST) do
		ReleasePlayer( nil, player, "" )
		SaveJailData( player )
	end
end)

-- Сажаем всех при запуске
addEventHandler("onResourceStart", resourceRoot, function()

	InitJailRooms()
	setTimer(UpdateJailData, 10000, 0)

	setTimer(function() -- Костыль
		for _, player in pairs( GetPlayersInGame( ) ) do
			local pData = player:GetPermanentData("jail_data") or {}

			if pData.time_left and pData.time_left > 0 then
				JailPlayer( nil, player, pData.jail_id, pData.time_left, pData.reason, false, true )
			end
		end
	end, 1000, 1)
end)
