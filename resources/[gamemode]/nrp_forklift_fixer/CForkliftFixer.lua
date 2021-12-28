-- Данный ресурс решает проблему въезда погрузчика в некоторый транспорт

local BOXES = {}
local VEHICLES = {}

function renderFixingBoxes()
    for vehicle, object in pairs(BOXES) do
        if isElement(vehicle) then 
            object:attach(vehicle, 0, -0.15, 0.9, 0.1, 90, 270)
        else
            BOXES[vehicle] = nil
        end
    end
end
setTimer(renderFixingBoxes, 100, 0)

addEventHandler("onClientVehicleCollision", root,
function(object, force)
    local owned_vehicle = VEHICLES[object]
    if not isElement(owned_vehicle) then return end
    if owned_vehicle ~= localPlayer.vehicle then return end
    owned_vehicle.velocity = owned_vehicle.velocity/10 --Vector3(0, 0, 0) --owned_vehicle.velocity / (force*0.1)
end)
--addEventHandler("onClientPreRender", root, renderFixingBoxes)

function createFixingBox(vehicle)
	destroyFixingBox(vehicle)
    local object = Object(1227, vehicle.position)
    object:attach(vehicle, 0, -0.15, 0.9, 0.1, 90, 270)
    BOXES[vehicle] = object
    VEHICLES[object] = vehicle
    object:setCollisionsEnabled(true)
    object.breakable = false
    object.alpha = 0
end

-- Удаление коробок у погрузчика
function destroyFixingBox(vehicle)
	local box = BOXES[vehicle]
	if isElement(box) then
		destroyElement(box)
    end
    BOXES[vehicle] = nil
end

-- Обработка входа игрока в стрим
function onStreamIn()
    local element_type = getElementType(source)
    if element_type == "vehicle" then
		if source.model == 530 then
			createFixingBox(source)
		end
	end
end
addEventHandler("onClientElementStreamIn", root, onStreamIn)

-- Обработка при старте ресурса
function onResourceStart()
	for i,v in pairs(getElementsByType("vehicle", root, true)) do
		if v.model == 530 then
			createFixingBox(v, value)
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)

-- Обработка выхода игрока из стрима
function onStreamOut()
    local element_type = getElementType(source)
    if element_type == "vehicle" then
        if source.model == 530 then
            destroyFixingBox(source)
        end
	end
end
addEventHandler("onClientElementStreamOut", root, onStreamOut)
addEventHandler("onClientElementDestroy", root, onStreamOut)