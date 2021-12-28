PREWANTED_TIMEOUT = 1.5 * 60 * 1000
PREWANTED_PLAYERS = { }
PLAYER_PREWANTED_STOP_TICKS = { }
PLAYER_DOCUMENTS_REQUESTED = { }

function Player:SetPreWanted( state )
	PREWANTED_PLAYERS[ self ] = state or nil
	PLAYER_PREWANTED_STOP_TICKS[ self ] = nil
	PLAYER_DOCUMENTS_REQUESTED[ self ] = nil

	if state ~= nil then
		self:SetPrivateData( "prewanted", state )
	end
end

Player.IsPolice = function( self )
	return FACTION_RIGHTS.WANTED_KNOW[ self:GetFaction( ) ]
end

addEvent( "onPlayerFixatePreWanted", true )
addEventHandler( "onPlayerFixatePreWanted", root, function ( target, state )
	if not isElement( target ) then return end

	if target:IsPolice( ) then
		if source ~= target then
			source:ShowError( "Нельзя фиксировать сотрудников ППС/ДПС" )
		end
		return
	end

	target:SetPreWanted( state )
end )

addEventHandler( "onPlayerDamage", root, function( attacker, weapon, bodypart, loss )
	if not isElement( attacker ) or attacker == source then return end

	if getElementType( attacker ) == "vehicle" and isElement( attacker.controller ) then
		attacker = attacker.controller
	elseif getElementType( attacker ) ~= "player" then
		return
	end

	local is_attacker_police = attacker:IsPolice( )
	if ( is_attacker_police and not attacker:IsOnFactionDuty( ) ) then return end
	local is_source_police = source:IsPolice( )

	if is_attacker_police then
		if ( not is_source_police and weapon and weapon >= 22 and weapon <= 34 ) then
			source:SetPreWanted( true )
		end
	elseif ( is_source_police and source:IsOnFactionDuty( ) ) then
		attacker:SetPreWanted( true )
	end

	if attacker:IsInFaction( ) or attacker:getData( "current_event" ) or attacker:getData( "is_on_event" ) then return end

	local current_tick = getTickCount( )

	local reason = "1.4"
	local key_damage_done = "player_damage_done"
	local key_damage_tick = "player_damage_tick"

	if source:IsInFaction( ) and source:IsOnFactionDuty( ) then
		reason = "1.3"
		key_damage_done = "player_faction_damage_done"
		key_damage_tick = "player_faction_damage_tick"
	end

	local last_attack_tick = attacker:getData( key_damage_tick ) or 0
	local total_damage = ( current_tick - last_attack_tick <= 5000 and attacker:getData( key_damage_done ) or 0 ) + loss

	if total_damage >= 20 then
		attacker:AddWanted( reason, _, true )
		attacker:setData( key_damage_done, 0, false )
	else
		attacker:setData( key_damage_done, total_damage, false)
	end

	attacker:setData( key_damage_tick, current_tick, false )

end )

addEvent( "onPlayerTaserDamage" )
addEventHandler( "onPlayerTaserDamage", root, function ( attacker )
	if not isElement( attacker ) then return end

	if not attacker:IsPolice( ) then return end
	if source:IsPolice( ) and source:IsOnFactionDuty( ) then return end

	source:SetPreWanted( true )
end )

addEvent( "onPlayerGotHandcuffed" )
addEventHandler( "onPlayerGotHandcuffed", root, function ( leader )
	if not isElement( leader ) then return end

	if not leader:IsPolice( ) then return end
	if source:IsPolice( ) and source:IsOnFactionDuty( ) then return end

	source:SetPreWanted( true )
end )

addEvent( "OnPlayerRequestDocuments" )
addEventHandler( "OnPlayerRequestDocuments", root, function ( target )
	if not isElement( target ) then return end

	if not source:IsPolice( ) or not source:IsOnFactionDuty( ) then return end
	if target:IsPolice( ) and target:IsOnFactionDuty( ) then return end

	target:SetPreWanted( true )
	PLAYER_DOCUMENTS_REQUESTED[ target ] = true
end )

addEvent( "OnPassportShowRequest", true )
addEventHandler( "OnPassportShowRequest", root, function ( target )
	if not isElement( target ) then return end

	if not target:IsPolice( ) or not target:IsOnFactionDuty( ) then return end
	if source:IsPolice( ) and source:IsOnFactionDuty( ) then return end

	source:SetPreWanted( not PLAYER_DOCUMENTS_REQUESTED[ source ] or #source:GetWantedData( ) > 0 )
end )

addEvent( "OnPlayerJailed", true )
addEventHandler( "OnPlayerJailed", root, function( )
	if PREWANTED_PLAYERS[ source ] then
		source:SetPreWanted( false )
	end
end )

addEventHandler( "onPlayerWasted", root, function()
	if PREWANTED_PLAYERS[ source ] then
		source:AddFine( 14 )
		source:PhoneNotification( {
			title = "Штраф",
			msg_short = "Штраф 3000р";
			msg = "Нарушение - уход от РП процесса. Статья 1.12. Штраф 3.000р.";
		} )

		source:SetPreWanted( false )
	end
end )

addEventHandler( "onPlayerPreLogout", root, function( )
	if PREWANTED_PLAYERS[ source ] then
		source:AddFine( 14 )

		source:GetClientID( ):PhoneNotification( {
			title = "Штраф",
			msg_short = "Штраф 3000р";
			msg = "Нарушение - уход от РП процесса. Статья 1.12. Штраф 3.000р.";
		} )

		source:SetPreWanted( nil )
	end
end )

setTimer( function( )
	Async:foreach( PREWANTED_PLAYERS, function( _, player )
		if not isElement( player ) then
			player:SetPreWanted( nil )
			return
		end

		local timeout = PLAYER_PREWANTED_STOP_TICKS[ player ]
		for k, v in pairs( getElementsWithinRange( player.position, 100, "player" ) ) do
			if v:IsInGame( ) and v:IsPolice( ) then
				if timeout then
					PLAYER_PREWANTED_STOP_TICKS[ player ] = nil
				end
				return
			end
		end
		if not timeout then
			PLAYER_PREWANTED_STOP_TICKS[ player ] = getTickCount( ) + PREWANTED_TIMEOUT
		elseif timeout <= getTickCount( ) then
			player:SetPreWanted( false )
		end
	end )
end, 2000, 0 )
