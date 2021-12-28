loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend("CVehicle")

record_data = {}
record_vehicle = false
record_timer = false

play_data = {}

is_recording = false

function StartRecord(veh, name)
	if not veh then return end
	if is_recording then return end
	record_vehicle = veh
	record_data = {steps = {}}
	record_data.model = veh.model
	record_data.name = name or "record"
	is_recording = true
	if isTimer(record_timer) then killTimer(record_timer) end
	record_timer = nil
	record_timer = setTimer(SaveStep, 50, 0)
end

function EndRecord()
	is_recording = false
	local file_name = SaveRecord()
	record_data = {}
	return file_name
end

function SaveRecord()
	record_data.count = #record_data.steps
	local file_name = getRealTime().timestamp.."-"..record_data.name..".json"
	local newFile = fileCreate(file_name)
	if (newFile) then
		fileWrite(newFile, toJSON(record_data, false, "tabs"))
		fileClose(newFile)
	end
	return file_name
end

function SaveStep()
	if not is_recording then return end
	local veh = record_vehicle
	if not isElement(veh) then return end
	table.insert(record_data.steps, (#record_data.steps+1),
	{
		position = {x = veh.position.x,y = veh.position.y,z = veh.position.z},
		rotation = {x = veh.rotation.x,y = veh.rotation.y,z = veh.rotation.z},
		turnVelocity = {x = veh.turnVelocity.x,y = veh.turnVelocity.y,z = veh.turnVelocity.z},
		velocity = {x = veh.velocity.x,y = veh.velocity.y,z = veh.velocity.z},
		tickCount = getTickCount()
	})
end

function PlayRecord(name, interior, dimension)
	interior = tonumber(interior) or 0
	dimension = tonumber(dimension) or 0
	local file = fileOpen(name..".json")
	if not file then
		return false
	end
	local count = fileGetSize(file)
	local data = fileRead(file, count)
	fileClose(file)
	local id = #play_data + 1
	play_data[id] = fromJSON(data)
	play_data[id].play_vehicle = createVehicle(
		play_data[id].model, 
		Vector3(play_data[id].steps[1].position.x, play_data[id].steps[1].position.y, play_data[id].steps[1].position.z),
		Vector3(play_data[id].steps[1].rotation.x,play_data[id].steps[1].rotation.y,play_data[id].steps[1].rotation.z)
	)
	setElementDimension(play_data[id].play_vehicle, dimension)
	setElementInterior(play_data[id].play_vehicle, interior)
	setVehicleEngineState(play_data[id].play_vehicle, true)

	play_data[id].current_step = 1
	
	play_data[id].play_timer = setTimer(PlayStep, 50, 0, id)
	checked = false
	return play_data[id].play_vehicle, id
end

function PlayStep(id)
	if play_data[id].current_step > play_data[id].count then return end
	local step = play_data[id].steps[play_data[id].current_step]
	if not step then StopRecord(id) return end
	local veh = play_data[id].play_vehicle
	setElementPosition(veh, Vector3(step.position.x, step.position.y, step.position.z))
	setElementRotation(veh, Vector3(step.rotation.x, step.rotation.y, step.rotation.z))
	setElementVelocity(veh, Vector3(step.velocity.x, step.velocity.y, step.velocity.z))
	setVehicleTurnVelocity(veh, Vector3(step.turnVelocity.x, step.turnVelocity.y, step.turnVelocity.z))
	play_data[id].current_step = play_data[id].current_step + 1
end

function StopRecord(id)
	if not id or not play_data[id] then return end
	if isTimer(play_data[id].play_timer) then killTimer(play_data[id].play_timer) end
	play_data[id].play_vehicle:destroy()
	play_data[id] = nil
end