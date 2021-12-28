Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "SInterior" )

EXAM_DATA = {}

function OnPlayerTryBuySpecialLicense( iLicense, iSchool )
	local pPlayer = client

	local iLicenseState = pPlayer:GetLicenseState( iLicense )
	if iLicenseState == LICENSE_STATE_TYPE_BOUGHT or iLicenseState == LICENSE_STATE_TYPE_PASSED then
		pPlayer:ShowError("Ты уже оплатил обучение на эту категорию!")
		return false
	end

	if pPlayer:TakeMoney( LICENSES_DATA[iLicense].iPrice, "special_license_purchase" ) then
		pPlayer:SetLicenseState( iLicense, LICENSE_STATE_TYPE_BOUGHT )
		pPlayer:ShowSuccess( "Ты успешно оплатил обучение" )
		triggerClientEvent( pPlayer, "ShowUI_School", resourceRoot, true, iSchool )
		return true
	else
		pPlayer:ShowError("Недостаточно денег")
		return false
	end
end
addEvent("OnPlayerTryBuySpecialLicense", true)
addEventHandler("OnPlayerTryBuySpecialLicense", resourceRoot, OnPlayerTryBuySpecialLicense)

function OnPlayerTryStartSpecialExam( iLicense, iSchool )
	local pPlayer = client

	local iLicenseState = pPlayer:GetLicenseState( iLicense )
	if iLicenseState ~= LICENSE_STATE_TYPE_BOUGHT then
		pPlayer:ShowError("Ты уже оплатил обучение на эту категорию!")
		return false
	elseif iLicenseState == LICENSE_STATE_TYPE_PASSED then
		pPlayer:ShowError("У тебя уже есть права этой категории!")
		return false
	end

	StartExam( pPlayer, iLicense, iSchool )
end
addEvent("OnPlayerTryStartSpecialExam", true)
addEventHandler("OnPlayerTryStartSpecialExam", resourceRoot, OnPlayerTryStartSpecialExam)

function StartExam( pPlayer, iLicense, iSchool )
	CleanExamStuff( pPlayer )

	fadeCamera( pPlayer, false, 1 )

	EXAM_DATA[pPlayer] = 
	{
		license_type = iLicense,
		school_id = iSchool,
		dimension = pPlayer:GetUniqueDimension(),
		stage = 1,
	}

	local pData = ROUTES_LIST[ iSchool ][ iLicense ]

	pVehicle = Vehicle.CreateTemporary( pData.iModel, pData.vecSpawnPosition.x, pData.vecSpawnPosition.y, pData.vecSpawnPosition.z, 0, 0, pData.vecSpawnRotation.z )
	pVehicle.dimension = EXAM_DATA[pPlayer].dimension
	pVehicle.engineState = false
	pVehicle:SetFuel( "full" )

	setTimer(function( player, vehicle )
		if not isElement(player) or not isElement(vehicle) then return end

		warpPedIntoVehicle( player, vehicle )
		vehicle:SetStatic(true)
		player.dimension = vehicle.dimension
	end,1500,1, pPlayer, pVehicle)

	setTimer(function( player, vehicle )
		if not isElement(player) then return end

		fadeCamera( player, true, 1 )
		triggerClientEvent( player, "OnClientSpecialExamStarted", resourceRoot, EXAM_DATA[player] )
		vehicle:SetStatic(false)
	end,2500,1, pPlayer, pVehicle)

	setElementData( pVehicle, "tutorial", true, false )
	setElementData( pPlayer, "driving_exam", true, false )

	EXAM_DATA[pPlayer].vehicle = pVehicle
end

function FinishExam( pPlayer, is_passed, bForced )

	if bForced then
		removePedFromVehicle(pPlayer)

		local pos = ROUTES_LIST[ EXAM_DATA[pPlayer].school_id ][ EXAM_DATA[pPlayer].license_type ].vecPlayerSpawnPosition
		pPlayer:Teleport( pos, 0 )

		CleanExamStuff( pPlayer )
	else
		fadeCamera( pPlayer, false, 1 )

		setTimer( function(player)
			removePedFromVehicle(player)

			local pos = ROUTES_LIST[ EXAM_DATA[player].school_id ][ EXAM_DATA[player].license_type ].vecPlayerSpawnPosition
			player:Teleport( pos, 0 )

			CleanExamStuff( player )

			fadeCamera( player, true )
		end, 1500, 1, pPlayer)

		if is_passed then
			pPlayer:ShowSuccess("Ты успешно сдал экзамен и получил права!")
			pPlayer:SetLicenseState( EXAM_DATA[pPlayer].license_type, LICENSE_STATE_TYPE_PASSED )
		end
	end

	triggerClientEvent(pPlayer, "OnClientSpecialExamFinished", resourceRoot)
end

function OnPlayerSpecialExamFinished( is_passed )
	FinishExam( client, is_passed )
end
addEvent("OnPlayerSpecialExamFinished", true)
addEventHandler("OnPlayerSpecialExamFinished", resourceRoot, OnPlayerSpecialExamFinished)

function CleanExamStuff( pPlayer )
	if EXAM_DATA[pPlayer] then
		for k,v in pairs(EXAM_DATA[pPlayer]) do
			if isElement(v) then destroyElement( v ) end
		end
	end

	EXAM_DATA[pPlayer] = nil
end

function OnPlayerQuit()
	if EXAM_DATA[source] then
		FinishExam( source, false, true )
	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit, true, "high+99999999999")

function OnResourceStop()
	for player, data in pairs(EXAM_DATA) do
		if isElement(player) then
			FinishExam( player, false, true )
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, OnResourceStop)