SOUND_BANDS = {}
SOUND_BANDS_DATA = {}
SOUND_BANDS_REVERSE = {}
SOUND_ELEMENTS = {}

SOUND_IDS = {}

RESOURCES = {}

MASTER_VOLUME = 1.0

DEFAULT_BAND = nil

addEventHandler("onClientResourceStart", resourceRoot, function()
	loadstring(exports.interfacer:extend("Interfacer"))()
	Extend("ShUtils")
	Extend("Globals")

	-- Создадим стандартные band'ы, где "other" - стандартный для всех звуков без категории.
	SoundBandCreate("engine")
	SoundBandCreate("radio")
	SoundBandCreate("other",true) -- обязательно должен быть 1 стандартный band.
end)

function SoundBandCreate(band,is_default)
	if type(band) ~= "string" then return end
	if SOUND_BANDS[band] then return end
	local element = createElement("CSound::Bands","CSound::Band_"..band)
	if element then
		SOUND_BANDS[band] = {}
		SOUND_BANDS_DATA[band] = { element = element, volume = 1.0 }
		if is_default then
			DEFAULT_BAND = band
		end
	end
	return element
end

addEvent("onSoundSourceCreateRequest", true)
function onSoundSourceCreateRequest(sound_conf)
	local id = sound_conf.id
	local element = SoundCreateSource(unpack(sound_conf))
	if element then
		if sound_conf.band then
			SoundSetBand(element, sound_conf.band)
		end
		SOUND_IDS[id] = element
	end
end
addEventHandler("onSoundSourceCreateRequest", root, onSoundSourceCreateRequest)

addEvent("onSoundSourceDestroyRequest", true)
function onSoundSourceDestroyRequest(id)
	local element = SOUND_IDS[id]
	if element then
		SoundDestroySource(element)
		SOUND_IDS[id] = nil
	end
end
addEventHandler("onSoundSourceDestroyRequest", root, onSoundSourceDestroyRequest)

-- Создание звукового элемента
function SoundCreateSource(sound_type, path, ...)
	local pSound
	local args = {...}
	local path = (path:sub(1,1) == ":" or not sourceResource or path:sub(1,4) == "http") and path or ":"..getResourceName(sourceResource).."/"..path
	if sound_type == SOUND_TYPE_2D then
		pSound = playSound(path,args[1],args[2])
	else
		local position = args[1]
		local px,py,pz = position and position.x or 0, position and position.y or 0, position and position.z or 0
		pSound = playSound3D(path,px,py,pz,args[2],args[3])
	end
	if isElement(pSound) then
		SOUND_ELEMENTS[pSound] = { volume = 1.0 }
		setSoundVolume(pSound,MASTER_VOLUME)
		SoundSetBand(pSound,DEFAULT_BAND)
		if sourceResource then
			RESOURCES[sourceResource.name] = RESOURCES[sourceResource.name] or {}
			table.insert(RESOURCES[sourceResource.name], pSound)
		end
		return pSound
	end
end

function onAnyResourceStop(restarted_resource)
	if restarted_resource == getThisResource() then return end
	for i, sound in pairs(RESOURCES[restarted_resource.name] or {}) do
		if isElement(sound) then
			SoundDestroySource(sound)
		end
	end
end
addEventHandler("onClientResourceStop", root, onAnyResourceStop)

function SoundDestroySource(pSound)
	if not SOUND_BANDS_REVERSE[pSound] then return end
	SOUND_BANDS[SOUND_BANDS_REVERSE[pSound]][pSound] = nil
	stopSound(pSound)
end

-- Смена категории звука (band)
function SoundSetBand(pSound,band)
	if not band or not SOUND_BANDS[band] or not SOUND_ELEMENTS[pSound] then return end
	if SOUND_BANDS_REVERSE[pSound] then SOUND_BANDS[SOUND_BANDS_REVERSE[pSound]][pSound] = nil end
	SOUND_BANDS[band][pSound] = true
	SOUND_BANDS_REVERSE[pSound] = band
	SOUND_ELEMENTS[pSound].band = band
	SoundSetVolume(pSound,SOUND_ELEMENTS[pSound].volume or 1)
end

-- Узнать категорию звука (band)
function SoundGetBand(pSound)
	if not SOUND_ELEMENTS[pSound] then return end
	return SOUND_BANDS_REVERSE[pSound]
end

-- Установка громкости звука в соответствии с категорией (band) и главной громкостью (master)
function SoundSetVolume(pSound,volume)
	if not SOUND_ELEMENTS[pSound] then return end
	if not isElement(pSound) then return end
	SOUND_ELEMENTS[pSound].volume = volume or SOUND_ELEMENTS[pSound].volume or 1
	local band = SOUND_BANDS_REVERSE[pSound]
	local new_volume = SOUND_ELEMENTS[pSound].volume*SOUND_BANDS_DATA[band].volume*MASTER_VOLUME
	setSoundVolume(pSound,new_volume)
end

-- Взятие относительной громкости конкретного звука
function SoundGetVolume(pSound)
	if not SOUND_ELEMENTS[pSound] then return end
	local band = SOUND_BANDS_REVERSE[pSound]
	local master_volume = MASTER_VOLUME ~= 1 and MASTER_VOLUME or 1
	local band_volume = SOUND_BANDS_DATA[band].volume ~= 0 and SOUND_BANDS_DATA[band].volume or 1
	local real_volume = (SOUND_ELEMENTS[pSound].volume or 1)/band_volume/master_volume
	return real_volume
end

-- Установка звука для конкретного band'а
function SoundBandSetVolume(band,volume)
	if not band or not SOUND_BANDS[band] then return end
	SOUND_BANDS_DATA[band].volume = volume or SOUND_BANDS_DATA[band].volume
	for pSound,v in pairs(SOUND_BANDS[band]) do
		SoundSetVolume(pSound)
	end
end

function SoundBandGetVolume(band)
	if not band or not SOUND_BANDS[band] then return end
	return SOUND_BANDS_DATA[band].volume
end

-- Установка звука для master канала (все band'ы одновременно)
function SoundMasterSetVolume(volume)
	MASTER_VOLUME = volume
	for band,v in pairs(SOUND_BANDS) do
		SoundBandSetVolume(band)
	end
end

-- Взятие звука
function SoundMasterGetVolume()
	return MASTER_VOLUME
end