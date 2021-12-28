loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")

local RADIO = {}

function createRadio( vehicle )
	RADIO[ vehicle ] = { channel = 1, volume = 0.8 }
	updateRadio( vehicle )
end

function updateRadio( vehicle, players )
	local target_players = players
	if not target_players or #target_players == 0 then
		target_players = getOccupants( vehicle )
	end
	if #target_players > 0 then
		triggerClientEvent( target_players, "onClientPlayerReceiveRadioData", resourceRoot, RADIO[ vehicle ] )
		if RADIO[ vehicle ] == 1 then
			RADIO[ vehicle ] = nil
		end
	end
end

function getOccupants( vehicle )
	local target_players = {}
	if not vehicle or not isElement( vehicle ) then
		if RADIO[ vehicle ] then
			RADIO[ vehicle ] = nil
		end
		return target_players
	end
	local occupants = getVehicleOccupants( vehicle )
	for k, v in pairs( occupants ) do
		if k ~= 0 then
			table.insert( target_players, v )
		end
	end
	return target_players
end

function setVolume( iVolume )
	if not client then return end
	local vehicle = getPedOccupiedVehicle( client )
	if isElement( vehicle ) and RADIO[ vehicle ] then
		RADIO[ vehicle ].volume = iVolume
		updateRadio( vehicle )
	end
end
addEvent( "radio:setVolume", true )
addEventHandler( "radio:setVolume", root, setVolume )

function setChannel( iChannel, vehicle )
	if not client then return end
	if isElement( vehicle ) then
		if not RADIO[ vehicle ] then
			createRadio( vehicle )
		end
		RADIO[ vehicle ].channel = iChannel
		updateRadio( vehicle )
	elseif RADIO[ vehicle ] then
		RADIO[ vehicle ] = nil
	end
end
addEvent( "radio:setChannel", true )
addEventHandler( "radio:setChannel", root, setChannel )

addEventHandler( "onPlayerVehicleEnter", root, function( vehicle, seat )
	local mdl = getElementModel( vehicle )
	if VEHICLE_TYPE_BIKE[ mdl ] then
		return false
	end
	if seat == 0 or not RADIO[ vehicle ] or RADIO[ vehicle ].channel == 1 or RADIO[ vehicle ].volume == 0 then return end
	
	local driver_exist = false
	for k, v in pairs( getVehicleOccupants( vehicle )) do
		if k == 0 then
			driver_exist = true
			break
		end
	end
	triggerClientEvent( source, "onClientPlayerReceiveRadioData", source, RADIO[ vehicle ] )
end )

addEvent( "onServerVehicleDestroyed", true )
addEventHandler( "onServerVehicleDestroyed", root, function( occupants, vehicle )
	if not vehicle or not RADIO[ vehicle ] then return end

	RADIO[ vehicle ].channel = 1
	triggerClientEvent( occupants, "onClientPlayerReceiveRadioData", resourceRoot, RADIO[ vehicle ] )
	RADIO[ vehicle ] = nil
end )

--[[ Эта хуета почему-то не работает, когда вытаскивают из тачки, ищу ответ
addEventHandler ( "onPlayerVehicleExit", root, function( vehicle, seat )
	local mdl = getElementModel( vehicle )
	if VEHICLE_TYPE_BIKE[ mdl ] then
		return false
	end
	if seat ~= 0 or not RADIO[ vehicle ] or RADIO[ vehicle ].channel == 1 then return end
	RADIO[ vehicle ].channel = 1

	local target_players = getOccupants( vehicle )
	triggerClientEvent( target_players, "onClientPlayerReceiveRadioData", source, RADIO[ vehicle ], true )
end )
--]]