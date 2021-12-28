function onResourceStart()
	loadstring(exports.interfacer:extend("Interfacer"))()
	Extend("ShUtils")
	Extend("SPlayer")
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)

-- Создание звукового элемента
function SoundCreateSource(player, sound_type, path, ...)
	local sound_conf
	local path = (path:sub(1,1) == ":" or not sourceResource or path:sub(1,4) == "http") and path or ":"..getResourceName(sourceResource).."/"..path
	local args = {...}
	-- Генерация рандомного числа с учетом времени, чтоб не было столкновений в айдишниках
	local id = getTickCount()..math.random(1,255)
	if sound_type == SOUND_TYPE_2D then
		sound_conf = {SOUND_TYPE_2D, path, args[1], args[2], band = args[3], id = id}
	else
		local position = args[1]
		local px, py, pz = position and position.x or 0, position and position.x or 0, position and position.x or 0
		sound_conf = {path, px, py, pz, args[2], args[3], band = args[4], id = id}
	end

	if sound_conf then
		local sound_conf_full = {
			id = id, 
			player = player, 
			sound_conf = sound_conf,
		}
		triggerClientEvent(player, "onSoundSourceCreateRequest", player, sound_conf)
		return id, sound_conf_full
	end
end

-- Удаление звукового элемента
function SoundDestroySource(player, id)
	triggerClientEvent(player, "onSoundSourceDestroyRequest", player, id)
end