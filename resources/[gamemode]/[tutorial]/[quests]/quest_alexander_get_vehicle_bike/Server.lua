loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SQuest" )
Extend( "SActionTasksUtils" )

addEventHandler( "onResourceStart", resourceRoot, function( )
	SQuest( QUEST_DATA )
end )

function OnQuestBikeAdded_handler( vehicle, data )
	local sOwnerPID = "p:" .. data.player:GetUserID( )

	vehicle:SetOwnerPID( sOwnerPID )
	vehicle:SetFuel( "full" )
	vehicle:SetPermanentData( "untradable", true )
	vehicle:SetPermanentData( "govuntradable", true )

	vehicle:SetPermanentData( "showroom_cost", data.cost )
	vehicle:SetPermanentData( "showroom_date", getRealTime().timestamp )
	vehicle:SetPermanentData( "first_owner", sOwnerPID )

	triggerEvent( "CheckPlayerVehiclesSlots", data.player )

	local main_position = Vector3( 1808.2707519531, -608.18873596191 + 860, 60.351829528809 )
	while true do
		if isAnythingWithinRange( main_position, 3 ) then
			main_position = main_position + Vector3( 0, -4, 0 )
		else
			break
		end
	end

	vehicle.position = main_position
	vehicle.rotation = Vector3( 0.66995239257813, 359.9543762207, 123.30780029297 )
end
addEvent( "OnQuestBikeAdded" )
addEventHandler( "OnQuestBikeAdded", root, OnQuestBikeAdded_handler )