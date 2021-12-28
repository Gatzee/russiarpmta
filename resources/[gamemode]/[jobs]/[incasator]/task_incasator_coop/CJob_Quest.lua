loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CInterior" )
Extend( "ib" )
Extend( "CQuestCoop" )

local CHECK_DISTANCE_TMR = nil
local FAIL_TEXT_AREA = nil

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuestCoop( QUEST_DATA )

	for k, v in pairs( CASH_OUT_POINTS ) do
		createCashOutPoint( v )
	end
end )

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		localPlayer:ShowError( "Ты не в автомобиле инкассатора" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель автомобиля инкассатора" )
		return false
	end

	return true
end

function GetForwardBackwardElementPosition( self, direction, distance )
	if direction == 1 then distance = distance * -1 end
	local x, y, z  = getElementPosition( self )
	local _, _, rz = getElementRotation( self )
	
    x = x - math.sin( math.rad( rz ) ) * distance
	y = y + math.cos( math.rad( rz ) ) * distance
	
    return Vector3( x, y, z )
end

function Client_CancelPlayerInVehicleDamage()
	if not localPlayer.vehicle then return end

	local vehicle_health = localPlayer.vehicle.health
	if vehicle_health > 950 and localPlayer.vehicle == localPlayer:getData( "job_vehicle" ) then
        cancelEvent()
    end
end

--------------------------------------------------------------------------

function onClientCancelIncasatorVehicleDamage_handler( state )
	if state then
		addEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
	else
		removeEventHandler( "onClientPlayerDamage", localPlayer, Client_CancelPlayerInVehicleDamage )
	end
end
addEvent( "onClientCancelIncasatorVehicleDamage", true )
addEventHandler( "onClientCancelIncasatorVehicleDamage", resourceRoot, onClientCancelIncasatorVehicleDamage_handler	 )