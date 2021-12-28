Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "SInterior" )
Extend( "ShVehicleConfig" )

local current_exams = { }

function onResourceStop( )
	for k, v in pairs( current_exams ) do
		DestroyExamAutoStuff( k )
	end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop )

function DestroyExamAutoStuff( player )
	local data = current_exams[ player ]
    
	if data then
		if isElement( data.vehicle ) then
			Vehicle.DestroyTemporary( data.vehicle )
		end

		if isElement( data.ped ) then
			destroyElement( data.ped )
		end

		if isElement( data.player ) then
			data.player:Teleport( AUTO_SCHOOL_ROUTES[ data.school ].vec_payer_spawn_position, 0, 0 )
			data.player:SetPrivateData( "iDrivingSchool", false )
			setElementData( data.player, "driving_exam", false, false )
		end
	end

	current_exams[ player ] = nil
end

function OnTryPayLicense_handler( license, school, type )
	local player = client
	if not isElement( player ) then return end

	local license_state = player:GetLicenseState( license )
	if license_state == LICENSE_STATE_TYPE_BOUGHT or license_state == LICENSE_STATE_TYPE_PASSED then
		player:ShowError( "Ты уже оплатил обучение на эту категорию!" )
		return false
	end

	if player:TakeMoney( LICENSES_DATA[ license ].iPrice, "driving_school_purchase" ) then
		player:SetLicenseState( license, LICENSE_STATE_TYPE_BOUGHT )
		player:ShowSuccess( "Ты успешно оплатил обучение" )

		if type == "air" then
			triggerClientEvent( player, "OnShowUIAirSchool", resourceRoot, true, school )
		elseif type == "auto" then
			triggerClientEvent( player, "OnShowUIAutoSchool", player, true, "stages", category )
		end
		
		return true
	else
		player:ShowError( "Недостаточно денег" )
		return false
	end
end
addEvent( "OnTryPayLicense", true )
addEventHandler( "OnTryPayLicense", root, OnTryPayLicense_handler )

function OnPassedExamAuto_handler( category, exan, state )
	local player = client
	if not isElement( player ) then return end

	if exan == "theory" then
		local key = "theory_attempt_" .. category
		local attempt = ( player:GetPermanentData( key ) or 0 ) + 1
		player:SetPermanentData( key, attempt )

		if state then
			player:SetLicenseState( category, LICENSE_STATE_TYPE_CUSTOM1 )
			triggerEvent( "onDrivingSchoolAttempt", player, true, category, LICENSES_DATA[ category ].iPrice, attempt, true )
		else
			triggerEvent( "onDrivingSchoolAttempt", player, true, category, LICENSES_DATA[ category ].iPrice, attempt, false )
		end
	elseif exan == "driving" then
		DestroyExamAutoStuff( player )

		local key = "practice_attempt_" .. category
		local attempt = ( player:GetPermanentData( key ) or 0 ) + 1
		player:SetPermanentData( key, attempt )

		if state then
			player:SetLicenseState(category, LICENSE_STATE_TYPE_PASSED )
			triggerEvent( "onDrivingSchoolAttempt", player, false, category, LICENSES_DATA[ category ].iPrice, 1, true )
			
			if category == LICENSE_TYPE_AUTO then
				player:CompleteDailyQuest( "np_get_b_rights" )
			end
		else
			triggerEvent( "onDrivingSchoolAttempt", player, false, category, LICENSES_DATA[ category ].iPrice, 1, false )
		end
	end
end
addEvent( "OnPassedExamAuto", true )
addEventHandler( "OnPassedExamAuto", root, OnPassedExamAuto_handler )

function StartExamAuto( player, license, vehicle, dimension, school_id )
	local ped = nil

	if license ~= LICENSE_TYPE_MOTO and license ~= LICENSE_TYPE_TRUCK then
		ped = createPed( 66, 0, 0, 0 )
		ped.dimension = dimension
        warpPedIntoVehicle( ped, vehicle, 1 )
	end

	current_exams[ player ] = {
		player = player,
		vehicle = vehicle,
		ped = ped,
		stage = 1,
		school = school_id,
	}
	
	setElementVelocity( vehicle, 0, 0, -0.01 )
    triggerClientEvent( player, "OnStartExamAuto", player, { vehicle = vehicle, category = license } )
end

function OnStartDrivingAutoStage_handler( )
	if current_exams[ client ] then current_exams[ client ].vehicle:SetStatic( false ) end
end
addEvent( "OnStartDrivingAutoStage", true )
addEventHandler( "OnStartDrivingAutoStage", root, OnStartDrivingAutoStage_handler )

addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, function( )
	if current_exams[ source ] then
		DestroyExamAutoStuff( source )
	else
		OnPassedExamAir_handler( source, false, true )
	end
end)