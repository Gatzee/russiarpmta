local current_exams = { }

function OnResourceStop_handler( )
	for player, _ in pairs( current_exams ) do
		if isElement( player ) then
			OnPassedExamAir_handler( player, false, true, true )
		end
	end
end
addEventHandler( "onResourceStop", resourceRoot, OnResourceStop_handler )

function DestroyExamAirStuff( player )
	if current_exams[ player ] then
		DestroyTableElements( current_exams[ player ] )
	end

	current_exams[ player ] = nil
end

function OnTryStartExam_handler( license, school, type )
	local player = client
	local data = nil
	local model = nil
	local license_state = player:GetLicenseState( license )
	if license_state == LICENSE_STATE_TYPE_PASSED then player:ShowError( "У тебя уже есть права этой категории!" ) return end

	if type == "auto" then
		if license_state < LICENSE_STATE_TYPE_CUSTOM1 then player:ShowInfo( "Вы ещё не сдали теоретический экзамен" ) return end

		data = AUTO_SCHOOL_ROUTES[ school ]
		if not data then return end
		model = data.models[ license ]
		if not model then return end

		player.interior = 0
		player:Teleport( data.vec_payer_spawn_position )
		player.rotation = data.vec_payer_spawn_rotation
	elseif type == "air" then
		if license_state ~= LICENSE_STATE_TYPE_BOUGHT then player:ShowError( "Ты уже оплатил обучение на эту категорию!" )	return end

		DestroyExamAirStuff( player )
		data = AIR_SCHOOL_ROUTES[ school ][ license ]
		model = data.model
	end

	local dimension = player:GetUniqueDimension( )
	player.dimension = dimension

	local vehicle = Vehicle.CreateTemporary( model, data.vec_spawn_position.x, data.vec_spawn_position.y, data.vec_spawn_position.z, 0, 0, data.vec_spawn_rotation.z )
	vehicle.dimension = dimension
	vehicle.overrideLights = 1
	vehicle.engineState = false
	vehicle:SetFuel( "full" )

	setElementData( vehicle, "tutorial", true, false )
	setElementData( player, "driving_exam", true, false )

	if type == "auto" then StartExamAuto( player, license, vehicle, dimension, school )
	elseif type == "air" then StartExamAir( player, license, school, vehicle, dimension ) end
end
addEvent( "OnTryStartExam", true )
addEventHandler( "OnTryStartExam", root, OnTryStartExam_handler )

function StartExamAir( player, license, school, vehicle, dimension )
	warpPedIntoVehicle( player, vehicle )
	player.dimension = vehicle.dimension

	current_exams[ player ] =
	{
		license_type = license,
		school_id = school,
		dimension = dimension,
		stage = 1,
	}

	setTimer(function( player, vehicle )
		if not isElement( player ) then return end

		fadeCamera( player, true, 1 )
		triggerClientEvent( player, "OnStartlExamAir", resourceRoot, current_exams[ player ] )

	end, 1500, 1, player, vehicle)

	current_exams[ player ].vehicle = vehicle
end

function OnPassedExamAir_handler( player, is_passed, forced )
	local data = current_exams[ player ]
	setElementData( player, "driving_exam", false, false )

	if data then
		if forced then
			removePedFromVehicle( player )
			player:Teleport( AIR_SCHOOL_ROUTES[ data.school_id ][ data.license_type ].vec_player_spawn_position, 0 )
			DestroyExamAirStuff( player )
		else
			fadeCamera( player, false, 1 )

			setTimer( function( player )
				removePedFromVehicle( player )
				player:Teleport( AIR_SCHOOL_ROUTES[ data.school_id ][ data.license_type ].vec_player_spawn_position, 0 )
				DestroyExamAirStuff( player )
				fadeCamera( player, true )
			end, 1500, 1, player )

			if is_passed then
				player:ShowSuccess( "Ты успешно сдал экзамен и получил права!" )
				player:SetLicenseState( data.license_type, LICENSE_STATE_TYPE_PASSED )
			end

			triggerClientEvent( player, "OnFinishExamAir", resourceRoot )
		end
	end
end
addEvent( "OnPassedExamAir", true )
addEventHandler( "OnPassedExamAir", root, OnPassedExamAir_handler )