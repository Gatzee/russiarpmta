loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShSocialRating" )

JAILED_PLAYERS_LIST = {}

-- Создание камер
function InitJailRooms()

	for _, jail in pairs( PRISON_ROOM_POSITIONS ) do

		for _, room in pairs( jail.rooms ) do
			room.players = {}
			room.element = createColSphere( room.x, room.y, room.z, room.size )
			setElementDimension( room.element, room.dimension or jail.dimension or 0 )
			setElementInterior( room.element, room.interior or jail.interior or 0 )
		end

	end

end

-- Поиск свободной комнаты
function JailGetFreeRoomID( iJailID )

	local iRoomID
	local pJailData = PRISON_ROOM_POSITIONS[ iJailID ]

	if pJailData then
		for i, room in pairs( pJailData.rooms ) do
			local iPlayersInside = room.players and #room.players or 0
			if iPlayersInside < room.capacity then
				iRoomID = i
				break
			end
		end

		if not iRoomID then
			iRoomID = math.random( 1, #pJailData.rooms )
		end
	end

	return iRoomID or 1

end

-- Посадить в тюрьму
function JailPlayer( is_admin, pTarget, iJailID, iTime, sReason, hide_logs )

	if not isElement(pTarget) then return end

	if JAILED_PLAYERS_LIST[ pTarget ] then
		ReleasePlayer( nil, pTarget )
	end
	fadeCamera( pTarget, false, 0 )
	setTimer( fadeCamera, 50, 1, pTarget, true, 5 )

	local iRoomID = JailGetFreeRoomID( iJailID )
	local pJailData = PRISON_ROOM_POSITIONS[ iJailID ]
	local pRoomData = pJailData.rooms[ iRoomID ]

	pTarget:removeFromVehicle()
	setElementInterior( pTarget, pRoomData.interior or pJailData.interior )
	setElementDimension( pTarget, pRoomData.dimension or pJailData.dimension )

	local vecPositionBias = Vector3( math.random( -pRoomData.size * 0.15, pRoomData.size * 0.15), math.random( -pRoomData.size * 0.15, pRoomData.size * 0.15), 0 )
	setElementPosition( pTarget, Vector3( pRoomData.x, pRoomData.y, pRoomData.z )	+ vecPositionBias )

	table.insert( pRoomData.players, pTarget )

	JAILED_PLAYERS_LIST[ pTarget ] =
	{
		jail_id = iJailID,
		room_id = iRoomID,
		room_element = pRoomData.element,
		time_left = iTime,
		reason = sReason,
		admin = is_admin,
	}
	if not hide_logs then
		pTarget:ChangeSocialRating( SOCIAL_RATING_RULES.jail.rating )
		SendToLogserver( "Игрок " .. pTarget:GetNickName() .. " заключен в колонию", { reason = sReason, time_left = iTime } )
	end
	pTarget:TakeAllWeapons()

	--Если игрок пытался сбежать и вышел
	local add_time = GetTotalJailTime( pTarget )
	JAILED_PLAYERS_LIST[ pTarget ].time_left = JAILED_PLAYERS_LIST[ pTarget ].time_left + add_time
	pTarget:ClearWanted()

	pTarget:setData( "jailed", "is_prison" )

	triggerClientEvent( pTarget, "prison:OnPlayerJailed", pTarget, JAILED_PLAYERS_LIST[ pTarget ], getRealTime().hour )
	
	triggerEvent( "OnPlayerPrisoned", pTarget )
end

--Посадка заключенного в камеру сотрудником ФСИН
function OnServerJailPlayerByFsin( pTarget, iJailID, iRoomID )

	triggerEvent( "OnPlayerJailedByFsin", pTarget )

	local sDimension = source:getDimension()
	local sInterior = source:getInterior()

	setElementInterior( pTarget, sInterior )
	setElementDimension( pTarget, sDimension )

	local pJailData = PRISON_ROOM_POSITIONS[ iJailID ]
	local pRoomData = pJailData.rooms[ iRoomID ]

	local vecPositionBias = Vector3( math.random( -pRoomData.size * 0.20, pRoomData.size * 0.20), math.random( -pRoomData.size * 0.20, pRoomData.size * 0.20), 0 )
	local tPosition = Vector3( pRoomData.x, pRoomData.y, pRoomData.z )	+ vecPositionBias
	setElementPosition( pTarget, tPosition )

	JAILED_PLAYERS_LIST[ pTarget ].room_id = iRoomID
	JAILED_PLAYERS_LIST[ pTarget ].room_element = pRoomData.element

	triggerClientEvent( pTarget, "prison:OnPlayerJailedByFsin", pTarget,
	{
		x = tPosition.x, y = tPosition.y, z = tPosition.z,
		dimension = sDimension,
		interior = sInterior,
		room_element = pRoomData.element,
		jail_id = iJailID,
		room_id = iRoomID,
	}, getRealTime().hour )

	BlockGoToJobs( pTarget, 15 * 60 )
	pTarget:ChangeSocialRating( SOCIAL_RATING_RULES.jail.rating )
end
addEvent("prison:OnServerJailPlayerByFsin", true)
addEventHandler("prison:OnServerJailPlayerByFsin", root, OnServerJailPlayerByFsin)

-- Выпустить из тюрьмы
function ReleasePlayer( pSource, pTarget, sReason, bUpdate, is_restart )

	local pData = JAILED_PLAYERS_LIST[ pTarget ]
	if not pData then return end

	if pSource and isElement( pSource ) then
		local faction = pSource:GetFaction()
		if not pSource:IsAdmin() and not ( FACTION_RIGHTS.PRISONID[ faction ] and FACTION_RIGHTS.PRISONID[ faction ] == pData.jail_id ) then
			return false
		end
	end

	local pReleasePositions = PRISON_ROOM_POSITIONS[ pData.jail_id ].release_positions
	local pRandomReleasePosition = pReleasePositions[ math.random(1, #pReleasePositions) ]

	if pData.admin then
		if isElement( pSource ) and not pSource:IsAdmin() then
			return
		end
	end

	if not is_restart then
		triggerClientEvent( pTarget, "prison:OnPlayerReleased", pTarget )
		SendToLogserver( "Игрок " .. pTarget:GetNickName() .. " освобожден из колонии", { src = pSource or nil, reason = sReason } )
	end

	setElementPosition( pTarget, pRandomReleasePosition.x, pRandomReleasePosition.y, pRandomReleasePosition.z )
	setElementInterior( pTarget, pRandomReleasePosition.interior or 0 )
	setElementDimension( pTarget, pRandomReleasePosition.dimension or 0 )

	pTarget:ShowInfo("Вы были выпущены из тюрьмы ( ".. ( sReason or " срок закончился " ).." )")

	-- Выпустить с обнулением данных о сроке ( нативный выход )
	if bUpdate then
		local pRoomData = PRISON_ROOM_POSITIONS[ pData.jail_id ].rooms[ pData.room_id ]
		for k,v in pairs(pRoomData.players) do
			if v == pTarget then
				table.remove( pRoomData.players, k )
				break
			end
		end

		JAILED_PLAYERS_LIST[ pTarget ] = nil

		DropJailQuests( pTarget, "У вас закончился срок заключения" )

		pTarget:SetPermanentData("prison_data", {})

	end

	removeElementData( pTarget, "jailed" )

	for _, v in pairs( OFF_CONTROLS ) do
		toggleControl( pTarget, v, true )
	end

	if pTarget:IsOnUrgentMilitary() then
		pTarget:EnterOnUrgentMilitaryBase()
	end

end

-- Обновление сроков
function UpdateJailData()

	for player, data in pairs(JAILED_PLAYERS_LIST) do

		if not data.prison_break then
			data.time_left = data.time_left - 10

			if data.time_left <= 0 then
				ReleasePlayer( nil, player, "Срок истёк", true )
			end

			--Обновление блокировки выхода на работу
			if JAILED_PLAYERS_LIST[ player ] and JAILED_PLAYERS_LIST[ player ].block_go_to_jobs then
				if JAILED_PLAYERS_LIST[ player ].block_go_to_jobs then
					JAILED_PLAYERS_LIST[ player ].block_go_to_jobs = JAILED_PLAYERS_LIST[ player ].block_go_to_jobs - 10
					if JAILED_PLAYERS_LIST[ player ].block_go_to_jobs <= 0 then
						JAILED_PLAYERS_LIST[ player ].block_go_to_jobs = nil
						player:SetPrivateData( "block_go_to_jobs", false )
					end
				end
			end

			--Обновление начала квестов
			for k in pairs( JAIL_QUESTS ) do
				if JAILED_PLAYERS_LIST[ player ] and JAILED_PLAYERS_LIST[ player ][ k ] then
					JAILED_PLAYERS_LIST[ player ][ k ] = JAILED_PLAYERS_LIST[ player ][ k ] - 10
					if JAILED_PLAYERS_LIST[ player ][ k ] <= 0 then
						JAILED_PLAYERS_LIST[ player ][ k ] = nil
						player:SetPrivateData( k, false )
					end
				end
			end

		end

	end

end

-- Обработчик попадания в тюрьму при входе
function PlayerReadyToPlay_handler()

	if isElement( source ) then
		local pData = source:GetPermanentData("prison_data") or {}

		if pData.time_left and pData.time_left > 0 then
			JailPlayer( nil, source, pData.jail_id, pData.time_left, pData.reason, true )
			if pData.block_go_to_jobs then
				BlockGoToJobs( source, pData.block_go_to_jobs )
			end
		end
	end

end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, PlayerReadyToPlay_handler, true, "low-1000" )


-- Сохранение данных при выходе
function SaveJailData( pPlayer )

	local pPlayer = isElement( pPlayer ) and pPlayer or source

	local pJailData = JAILED_PLAYERS_LIST[ pPlayer ]
	if pJailData then
		local pDataToSave =
		{
			time_left = pJailData.time_left,
			jail_id = pJailData.jail_id,
			reason = pJailData.reason,
			admin = pJailData.admin,
			block_go_to_jobs = pJailData.block_go_to_jobs or false,
		}

		pPlayer:SetPermanentData("prison_data", pDataToSave)

		JAILED_PLAYERS_LIST[ pPlayer ] = nil

		local pRoomData = PRISON_ROOM_POSITIONS[ pJailData.jail_id ].rooms[ pJailData.room_id ]
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


-- Выпускаем всех при остановке ресурса
addEventHandler("onResourceStop", resourceRoot, function()
	for player, data in pairs(JAILED_PLAYERS_LIST) do
		ReleasePlayer( nil, player, "", false, true )
		SaveJailData( player )
		DropJailQuests( player, "Приносим свои извинения, квест был остановлен сервером")
	end
end)

-- Сажаем всех при запуске
addEventHandler("onResourceStart", resourceRoot, function()

	InitJailRooms()
	setTimer(UpdateJailData, 10000, 0)

	setTimer(function() -- Костыль
		for _, player in pairs(getElementsByType("player")) do
			local pData = player:GetPermanentData("prison_data") or {}
			if pData.time_left and pData.time_left > 0 then
				JailPlayer( nil, player, pData.jail_id, pData.time_left, pData.reason, true )
			end
			--if player:GetUserID() == 1 then
				 --JailPlayer( nil, player, 1, 20000, "Разбой" )
				 --ReleasePlayer( _, player, "bla", true )
			--end
		end

	end, 2000, 1)
end)


-----------------------------------------------------------------------
-- ЭКСПОРТ ФУНКЦИИ	---------------------------------------------------
-----------------------------------------------------------------------

-- Получени информации о камере игрока для спавна

function GetFsinPlayerData( player, wasted )

	local data = JAILED_PLAYERS_LIST[ player ]
	local pJailData = PRISON_ROOM_POSITIONS[ data.jail_id ]
	local pRoomData = pJailData.rooms[ data.room_id ]
	local vecPositionBias = Vector3( math.random( -pRoomData.size * 0.20, pRoomData.size * 0.20), math.random( -pRoomData.size * 0.20, pRoomData.size * 0.20), 0 )

	if JAILED_PLAYERS_LIST[ player ].time_left then
		BlockGoToJobs( player, math.floor( JAILED_PLAYERS_LIST[ player ].time_left * 0.1 ) )
	end

	return
	{
		position = Vector3( pRoomData.x, pRoomData.y, pRoomData.z )	+ vecPositionBias;
		interior = pRoomData.interior or pJailData.interior;
		dimension = pRoomData.dimension or pJailData.dimension;
		rotation = 0;
	}

end

function IsPlayerInCamera( pTarget )
	if JAILED_PLAYERS_LIST[ pTarget ] then
		return isElementWithinColShape( pTarget, JAILED_PLAYERS_LIST[ pTarget ].room_element )
	end
	return false
end


-- Блокировка выхода на работу
function BlockGoToJobs( player, time )

	if JAILED_PLAYERS_LIST[ player ]  then
		JAILED_PLAYERS_LIST[ player ].block_go_to_jobs = time
		triggerClientEvent( player, "prison:OnPlayerBlockGoToJobs", player, JAILED_PLAYERS_LIST[ player ].block_go_to_jobs )
	end

end
addEvent( "onServerBlockPlayerGoToJobs", true )
addEventHandler( "onServerBlockPlayerGoToJobs", root, BlockGoToJobs )
