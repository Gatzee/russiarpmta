loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShDiseases" )

TREATING_MEDICS = { }
TREATING_PLAYERS = { }

function onPlayerTryStartTreat_handler( target )
	if isElement( TREATING_PLAYERS[ target ] ) then
		source:ShowInfo( target:GetNickName( ) .. " уже лечится" )
		return
	end
	if isElement( TREATING_MEDICS[ source ] ) then
		source:ShowInfo( "Вы уже лечите другого игрока" )
		return
	end

	local player_diseases = target:GetPermanentData( "diseases" )
	if not player_diseases then return end

	local cooldown_time = false
	for disease_id, disease in pairs( player_diseases ) do
		if disease.stage > 0 then
			if disease.last_treat_date and disease.last_treat_date + TREATING_COOLDOWN > getRealTimestamp( ) then
				cooldown_time = math.min( cooldown_time or math.huge, disease.last_treat_date + TREATING_COOLDOWN )
			else
				triggerClientEvent( source, "onClientPlayerStartTreat", target, disease_id, disease.stage )
				source.frozen = true
				target.frozen = true
				target:setData( "is_undergoing_treatment", true, false )
				
				TREATING_MEDICS[ source ] = target
				TREATING_PLAYERS[ target ] = source

				target:ShowInfo( string.format( "Врач %s начал ваше лечение." , source:GetNickName( ) ) )

				return true
			end
		end
	end

	if cooldown_time then
		source:ShowInfo( target:GetNickName( ) .. " сможет принять следующеее лечение через " .. getHumanTimeString( cooldown_time, true ) )
	else
		source:ShowInfo( target:GetNickName( ) .. " ничем не болеет" )
	end
	return false
end
addEvent( "onPlayerTryStartTreat", true )
addEventHandler( "onPlayerTryStartTreat", root, onPlayerTryStartTreat_handler )

function onPlayerBuyTreat_handler( )
    if not isElement( source ) then return end
	
	if source:getData( "is_undergoing_treatment" ) then
		source:ShowError( "Вы уже проходите лечение" )
		return
	end

    local player_diseases = source:GetPermanentData( "diseases" )
    if not player_diseases then return end
	
	local cooldown_time = false
	for disease_id, disease in pairs( player_diseases ) do
		if disease.stage > 0 then
			if disease.last_treat_date and disease.last_treat_date + TREATING_COOLDOWN > getRealTimestamp( ) then
				cooldown_time = math.min( cooldown_time or math.huge, disease.last_treat_date + TREATING_COOLDOWN )
			else
				if not source:TakeMoney( COST_BUY_TREAT, "soft_service", "health_care" ) then
					source:ErrorWindow( "Недостаточно средств" )
					return
				end

				local anal = {
					cost = COST_BUY_TREAT,
					currency = "soft",
					ill_id = tostring( disease_id ),
					ill_name = DISEASES_INFO[ disease_id ].name_eng,
				}
			
				SendElasticGameEvent( source:GetClientID( ), "health_care_purchase", anal )

				triggerEvent( "onPlayerSomeDo", source, "delightful_treatment" ) -- achievements

				triggerEvent( "onPlayerTreatComplete", source, source, disease_id, true )
				if source:GetPermanentData( "has_medbook" ) then
					triggerEvent( "onPlayerShowMedbook", source, source, disease_id, DISEASES_INFO[ disease_id ].note  )
				end
			end
		end
	end

	if cooldown_time then
		source:ShowInfo( "Вы сможет принять следующеее лечение через " .. getHumanTimeString( cooldown_time, true ) )
	end
end
addEvent( "onPlayerBuyTreat", true )
addEventHandler( "onPlayerBuyTreat", root, onPlayerBuyTreat_handler, true, "high" )

function onPlayerTreatComplete_handler( target, disease_id, buy_treat )
	if buy_treat then return end

	source.frozen = false
	TREATING_MEDICS[ source ] = nil

	if not isElement( target ) then return end
	target.frozen = false
	target:setData( "is_undergoing_treatment", false, false )

	TREATING_PLAYERS[ target ] = nil

	local player_diseases = target:GetPermanentData( "diseases" )
	if not player_diseases then return end

	local disease = player_diseases[ disease_id ]
	if not disease or disease.stage == 0 then return end

	if target:GetPermanentData( "has_medbook" ) then
		triggerEvent( "onPlayerShowMedbook", target, source, disease_id, DISEASES_INFO[ disease_id ].note )
	end

	triggerEvent( "onServerCompleteShiftPlan", source, source, "treating" )
end
addEvent( "onPlayerTreatComplete", true )
addEventHandler( "onPlayerTreatComplete", root, onPlayerTreatComplete_handler, true, "high+1" )

function onPlayerPreLogout_handler( )
	if TREATING_MEDICS[ source ] then
		if isElement( TREATING_MEDICS[ source ] ) then
			TREATING_MEDICS[ source ].frozen = false
			TREATING_MEDICS[ source ]:setData( "is_undergoing_treatment", false, false )
			TREATING_PLAYERS[ TREATING_MEDICS[ source ] ] = nil
		end
		TREATING_MEDICS[ source ] = nil
	end

	if TREATING_PLAYERS[ source ] then
		if isElement( TREATING_PLAYERS[ source ] ) then
			TREATING_PLAYERS[ source ].frozen = false
			TREATING_MEDICS[ TREATING_PLAYERS[ source ] ] = nil
		end
		TREATING_PLAYERS[ source ] = nil
	end
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )