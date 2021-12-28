PLAYER_LAST_WANTED_GIVEN = {}
PLAYER_LAST_WANTED_RECEIVED = {}

local ADD_WANTED_DELAY = 5 * 60

function OnPlayerTryAddWanted( pTarget, pWantedList, pFinesList, bOnPost )
	local pSource = client
	local iCurrentTime = getRealTime( ).timestamp

	if not isElement( pSource ) or not isElement( pTarget ) then
		if isElement( pSource ) then
			pSource:ShowError( "Игрок не найден" )
		end

		return
	end

	local iLastDocumentsShown = PLAYER_DOCUMENTS_SHOWN[pSource] and PLAYER_DOCUMENTS_SHOWN[pSource][pTarget]

	if not iLastDocumentsShown or ( getRealTime( ).timestamp - iLastDocumentsShown ) > 600 then
		pSource:ShowError( "Сначала предъяви игроку документы" )
		return
	end

	if not bOnPost then
		if PLAYER_LAST_WANTED_GIVEN[ pSource ] then
			local iTimePassed = iCurrentTime - PLAYER_LAST_WANTED_GIVEN[ pSource ]
			if iTimePassed < ADD_WANTED_DELAY then
				pSource:ShowError("Нельзя обьявлять в розыск так часто.\n(Доступно через: "..math.ceil( (ADD_WANTED_DELAY - iTimePassed) / 60 ).." мин)")
				return
			end
		end
	end

	if PLAYER_LAST_WANTED_RECEIVED[ pTarget ] then
		local iTimePassed = iCurrentTime - PLAYER_LAST_WANTED_RECEIVED[ pTarget ]
		if iTimePassed < ADD_WANTED_DELAY then
			pSource:ShowError("Игрока недавно обьявляли в розыск.\n(Доступно через: "..math.ceil( (ADD_WANTED_DELAY - iTimePassed) / 60 ).." мин)")
			return
		end
	end

	if #pFinesList > 0 then
		local bSucceed = OnPlayerTryAddFines( pTarget, pFinesList, bOnPost, pSource )
		if not bSucceed then return end
	end

	if #pWantedList == 0 then return end

	for i, sReason in ripairs( pWantedList ) do
		pTarget:AddWanted( sReason, _, true )
		WriteLog( "factions/give_wanted", "%s выдал статью %s игроку %s", pSource, sReason, pTarget )
	end

	PLAYER_LAST_WANTED_GIVEN[ pSource ] = iCurrentTime
	PLAYER_LAST_WANTED_RECEIVED[ pTarget ] = iCurrentTime

	pSource:ShowSuccess( "Розыск успешно выдан." )
	pTarget:ShowInfo( "Вы в розыске." )
end
addEvent( "OnPlayerTryAddWanted", true )
addEventHandler( "OnPlayerTryAddWanted", resourceRoot, OnPlayerTryAddWanted )