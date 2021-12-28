function GetPlayerLobby( pPlayer )
	for k,v in pairs( RACE_LOBBIES ) do
		for i, player in pairs( v.participants ) do
			if player == pPlayer then
				return k
			end
		end
	end
end

function GetVehicleState( pVehicle )
	local data = {}
	if isElement( pVehicle ) then
		data.hp = pVehicle.health
		data.panels = {}
	end

	return data
end

function SetVehicleState( pVehicle, data )
	if isElement( pVehicle ) and data then
		pVehicle.health = data.hp or 1000
	end
end

function isVehicleOnRoof( vehicle )
	if not vehicle or not isElement( vehicle ) then return end
	local rx, ry = getElementRotation( vehicle )
	if ( rx > 90 and rx < 270 ) or ( ry > 90 and ry < 270 ) then
		return true
	end
	return false
end

function GetPointsByRaceType( race_type )
	if race_type == RACE_TYPE_CIRCLE_TIME then
		return 0
	end
	return 0
end