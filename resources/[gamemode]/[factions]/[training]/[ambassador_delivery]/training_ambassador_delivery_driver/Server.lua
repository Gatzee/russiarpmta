loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SClans")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

function FailCreateGameAmbassador( training_failed )
	if training_failed then
		return
	end
	
	player = source

	local vehicle = player:getData( "quest_vehicle" )
	if not isElement( vehicle ) then
		return
	end

	triggerEvent( "CreateAmbassador", root, {
		model = vehicle.model;

		position_x = vehicle.position.x;
		position_y = vehicle.position.y;
		position_z = vehicle.position.z;

		rotation_x = vehicle.rotation.x;
		rotation_y = vehicle.rotation.y;
		rotation_z = vehicle.rotation.z;

		health = vehicle.health;
		wheel_states = { vehicle:getWheelStates() };
		number_plate = vehicle:GetNumberPlate();

		duration = 10 * 60;
		points = 400;
		money = 25000;
	} )
end