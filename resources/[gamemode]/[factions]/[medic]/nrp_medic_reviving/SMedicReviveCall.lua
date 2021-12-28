Extend( "ShApartments" )
Extend( "ShVipHouses" )

REVIVE_CALL_ACCEPT_COOLDOWN = 15 * 60
MAX_REVIVE_CALL_DISTANCE = 2000

REVIVE_CALL_PLAYER_BY_MEDIC = { }
REVIVE_CALL_MEDIC_BY_PLAYER = { }

MEDIC_REVIVE_CALL_ACCEPT_TIMEOUTS = {}

function onMedicTryAcceptReviveCall_handler( target )
	if not isElement( target ) then return end

	if REVIVE_CALL_PLAYER_BY_MEDIC[ source ]  then 
		source:ShowError( "Вы уже приняли другой вызов" )
		return 
	end

	if REVIVE_CALL_MEDIC_BY_PLAYER[ target ] then 
		source:ShowError( "Этот вызов уже принял другой медик" )
		return 
	end

	if not target.dead then 
		source:ShowError( target:GetNickName( ) .. " уже не нуждается в спасении" )
		return 
	end

	if target.interior == 0 and target.dimension == 0 then
		SetReviveCallData( source, target )
	else
		local interior_tpoint_position = target:GetPermanentData( "interior_tpoint_position" )
		if interior_tpoint_position then
			interior_tpoint_position = interior_tpoint_position.old_position
		else
			local id, number = target:GetHouseIsInside( )
			if id then
				if id > 0 then
					local info = APARTMENTS_LIST[ id ]
					interior_tpoint_position = info and info.enter_position
				else
					local info = VIP_HOUSES_LIST[ number ]
					interior_tpoint_position = info and info.enter_marker_position
				end
			end
		end

		if interior_tpoint_position then
			SetReviveCallData( source, target, interior_tpoint_position )
		else
			source:ShowError( "Не удалось определить местоположение игрока" )
			return 
		end
	end
end
addEvent( "onMedicTryAcceptReviveCall", true )
addEventHandler( "onMedicTryAcceptReviveCall", root, onMedicTryAcceptReviveCall_handler )

function SetReviveCallData( source, target, interior_tpoint_position )
	triggerClientEvent( source, "onClientSetReviveMarker", target, interior_tpoint_position )
	REVIVE_CALL_PLAYER_BY_MEDIC[ source ] = target
	REVIVE_CALL_MEDIC_BY_PLAYER[ target ] = source
	addEventHandler( "onPlayerSpawn", target, ClearReviveCallData )
end

function ClearReviveCallData( )
	removeEventHandler( "onPlayerSpawn", source, ClearReviveCallData )
	if REVIVE_CALL_MEDIC_BY_PLAYER[ source ] then
		REVIVE_CALL_PLAYER_BY_MEDIC[ REVIVE_CALL_MEDIC_BY_PLAYER[ source ] ] = nil
		REVIVE_CALL_MEDIC_BY_PLAYER[ source ] = nil
	end
end

function onMedicArrivedToReviveCall_handler( target )
	if isElement( target ) then
		local medic_id = source:GetUserID( )
		local target_id = target:GetUserID( )
		if not MEDIC_REVIVE_CALL_ACCEPT_TIMEOUTS[ medic_id ] then
			MEDIC_REVIVE_CALL_ACCEPT_TIMEOUTS[ medic_id ] = { }
		end
		MEDIC_REVIVE_CALL_ACCEPT_TIMEOUTS[ medic_id ][ target_id ] = true
		setTimer( ClearReviveCallAcceptTimeout, REVIVE_CALL_ACCEPT_COOLDOWN * 1000, 1, medic_id, target_id )
	end

	triggerEvent( "onServerCompleteShiftPlan", source, source, "shift_call", _, 0 )
end
addEvent( "onMedicArrivedToReviveCall", true )
addEventHandler( "onMedicArrivedToReviveCall", root, onMedicArrivedToReviveCall_handler )

function ClearReviveCallAcceptTimeout( medic_id, target_id )
	local timeouts = MEDIC_REVIVE_CALL_ACCEPT_TIMEOUTS[ medic_id ]
	if timeouts then
		timeouts[ target_id ] = nil
		if not next( timeouts ) then
			MEDIC_REVIVE_CALL_ACCEPT_TIMEOUTS[ medic_id ] = nil
		end
	end
end

function onPlayerPreLogout_handler( )
	if REVIVE_CALL_PLAYER_BY_MEDIC[ source ] then
		REVIVE_CALL_MEDIC_BY_PLAYER[ REVIVE_CALL_PLAYER_BY_MEDIC[ source ] ] = nil
		REVIVE_CALL_PLAYER_BY_MEDIC[ source ] = nil
	end

	if REVIVE_CALL_MEDIC_BY_PLAYER[ source ] then
		REVIVE_CALL_PLAYER_BY_MEDIC[ REVIVE_CALL_MEDIC_BY_PLAYER[ source ] ] = nil
		REVIVE_CALL_MEDIC_BY_PLAYER[ source ] = nil
	end
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onPlayerShowDeathCountdown_handler( )
	if not source:IsInClan( ) and not source:getData( "jailed" ) and not source:GetPermanentData( "has_medbook" ) then
		local source_id = source:GetUserID( )
		local source_position = source.position
		local target_players = { }

		for k, v in pairs( GetPlayersInGame( ) ) do
			if v ~= source and FACTION_RIGHTS.REANIMATION[ v:GetFaction( ) ] and v:IsOnFactionDuty( ) then
				local timeouts = MEDIC_REVIVE_CALL_ACCEPT_TIMEOUTS[ v:GetUserID( ) ]
				if not timeouts or not timeouts[ source_id ] then
					if v.position:distance( source_position ) < MAX_REVIVE_CALL_DISTANCE then
						table.insert( target_players, v )
					end
				end
			end
		end
		
		triggerClientEvent( target_players, "OnClientReceivePhoneNotification", source, {
			title = "[Минздрав] Новый вызов", 
			special = "medic_revive_call",
			args = { target = source },
		} )
	end
end
addEvent( "onPlayerShowDeathCountdown", true )
addEventHandler( "onPlayerShowDeathCountdown", root, onPlayerShowDeathCountdown_handler )