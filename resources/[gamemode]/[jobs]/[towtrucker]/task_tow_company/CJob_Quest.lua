loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CInterior" )
Extend( "ib" )
Extend( "CQuestCoop" )

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuestCoop( QUEST_DATA )
end )

RETURN_TARGETS = 
{
	[ 0 ] = 
	{ 
		Vector3( -1013.23, -686.85 + 860, 23 ),
	},
}

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		localPlayer:ShowError( "Ты не в автомобиле Эвакуаторщика" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель автомобиля Эвакуаторщика" )
		return false
	end

	return true
end