local pSirenSounds = {}

SIRENS_VOLUME = 1

function ToggleVehicleSirensSound( pVehicle, state )
	if state then
		ToggleVehicleSirensSound(pVehicle, false)

		local conf = VEHICLE_SIREN_CONFIG[ pVehicle.model ]

		if conf and conf.by_faction and conf.by_faction[ pVehicle:GetFaction( ) ] then
			conf = conf.by_faction[ pVehicle:GetFaction( ) ]
		end

		if conf then
			pSirenSounds[pVehicle] = playSound3D( "files/sound/"..conf.sound, pVehicle.position, true )
			setSoundMinDistance( pSirenSounds[pVehicle], 20 )
			setSoundMaxDistance( pSirenSounds[pVehicle], 80 )
			pSirenSounds[pVehicle].dimension = pVehicle.dimension
			attachElements( pSirenSounds[pVehicle], pVehicle )
			setSoundVolume( pSirenSounds[pVehicle], SIRENS_VOLUME )
		end
	else
		if isElement(pSirenSounds[pVehicle]) then stopSound( pSirenSounds[pVehicle] ) end
		pSirenSounds[pVehicle] = nil
	end
end

addEventHandler("onClientElementDataChange", root, function( key )
	if getElementType(source) ~= "vehicle" then return end
	if key == "sirens" then
		local state = getElementData(source, key)
		ToggleVehicleSirensSound( source, state )

		if state then
			if source == localPlayer.vehicle then
				local current_quest = localPlayer:getData( "current_quest" )
				if current_quest and current_quest.id == "oleg_govhelp" then
					triggerServerEvent( "oleg_govhelp_step_siren", localPlayer )
				end
			end
		end
	end
end)

addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) ~= "vehicle" then return end
	ToggleVehicleSirensSound( source, false )
end)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) ~= "vehicle" then return end
	local state = getElementData(source, "sirens")
	if state then
		ToggleVehicleSirensSound( source, true )
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) ~= "vehicle" then return end
	ToggleVehicleSirensSound( source, false )
end)


function onSettingsChange_handler( changed, values )
	if changed.vehicle_engine then
		if values.vehicle_engine then
			SIRENS_VOLUME = values.vehicle_engine
			for i, v in pairs( pSirenSounds ) do
				setSoundVolume( v, SIRENS_VOLUME )
			end
		end
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

triggerEvent( "onSettingsUpdateRequest", localPlayer, "engine" )