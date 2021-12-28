Extend("CPlayer")
Extend("CVehicle")
Extend("CUI")
Extend("CChat")
Extend("ib")
Extend("CActionTasksUtils")
Extend( "race_tracks/track_drag_track" )
Extend( "race_tracks/track_sochi_drift" )
Extend( "race_tracks/track_sochi_track" )

ibUseRealFonts( true )

scX, scY = guiGetScreenSize()
UI_elements = {}

TRACK = nil
pNextMarker = nil
pNextVisibleMarker = nil

MODES = {}
TEXTURE_LIST = {}

local pAmbientMusic
function SwitchMusic(state)
	if state then
		if isElement( pAmbientMusic ) then return end
		pAmbientMusic = playSound( "files/sfx/music_race_lobby.ogg", true )
		pAmbientMusic:setVolume(0.5)
	elseif isElement( pAmbientMusic ) then
		destroyElement( pAmbientMusic )
	end
end

function ReceiveTrack( name, dimension )
	local track = ReadTrack( name, true )
	LoadTrack( track, dimension )
	return true
end
addEvent( "RC:ReceiveTrack", true )
addEventHandler( "RC:ReceiveTrack", resourceRoot, ReceiveTrack )

function ReadTrack( sFileName, bOnlyTable )
	if TRACKS[sFileName] then
		TRACKS[sFileName].name = sFileName
		return table.copy( TRACKS[sFileName] )
	end

	return false
end

function LoadTrack( data, iDim )
	DestroyTrack()

	local iDim = iDim or localPlayer.dimension
	local data = table.copy( data )

	table.remove(data.markers, 1)

	for k,v in pairs( data.static_objects ) do
		v.temp = createObject( v.model, v.x, v.y, v.z, 0, v.ry or 0, v.rz )
		setElementFrozen( v.temp, true)
		setElementDimension( v.temp, iDim )
	end

	for k, v in pairs( data.dynamic_objects ) do
		local rand = math.random( #v )
		for i, obj in pairs( v ) do
			obj.temp = createObject( obj.model, obj.x, obj.y, obj.z, 0, 0, obj.rz )
			setElementFrozen( obj.temp, true)
			setElementAlpha( obj.temp, i == rand and 255 or 0 )
			setElementCollisionsEnabled( obj.temp, i == rand )
			setElementDimension( obj.temp, iDim )
		end
	end
	TRACK = data
	
	return data
end

function DestroyTrack( track )
	local track = track or TRACK
	if not track then return end

	for k, v in pairs( pNextMarker or {} ) do
		if isElement( v ) then
			destroyElement( v )
		end
	end
	
	for k, v in pairs( track.markers ) do
		if isElement( v.temp ) then
			destroyElement( v.temp )
		end

		if isElement( v.visible ) then
			destroyElement( v.visible )
		end
	end

	for k, v in pairs( track.static_objects ) do
		if isElement( v.temp ) then
			destroyElement( v.temp )
		end
	end

	for k,v in pairs( track.dynamic_objects ) do
		for i, obj in pairs(v) do
			if isElement( obj.temp ) then
				destroyElement( obj.temp )
			end
		end
	end

	TRACK = nil
end

local MARKER_RACE_HIDE =
{
	[ RACE_TYPE_DRIFT ] = true,
}

function CreateNextMarker()
	if not RACE_DATA.last_marker then
		RACE_DATA.last_marker = 0
		pNextMarker = TRACK.markers[ 1 ]
	end

	if RACE_DATA.race_type == RACE_TYPE_CIRCLE_TIME and RACE_DATA.last_marker == 1 then
		UI_elements.start_time = getTickCount()
	end

	local bHitVisible = RACE_DATA.last_marker <= 0 and not MARKER_RACE_HIDE[ RACE_DATA.race_type ]

	if isElement( pNextMarker.temp ) then
		pNextMarker.temp:destroy()
	end

	if isElement( pNextMarker.visible ) then
		pNextMarker.blip:destroy()
		pNextMarker.visible:destroy()
		bHitVisible = true
	end

	iRecoveryMarker = RACE_DATA.last_marker

	RACE_DATA.last_marker = RACE_DATA.last_marker + 1
	pNextMarker = TRACK.markers[ RACE_DATA.last_marker ]

	if not pNextMarker and RACE_DATA.current_circle < RACE_DATA.circles then
		pNextMarker = TRACK.markers[ 1 ]
		RACE_DATA.last_marker = 0
		RACE_DATA.current_circle = RACE_DATA.current_circle + 1
		CreateNextMarker()

		if RACE_DATA.race_type == RACE_TYPE_CIRCLE_TIME then
			UI_elements.current_circle:ibData( "text", "Круг " .. RACE_DATA.current_circle  .. "/" .. RACE_DATA.circles )	
			triggerServerEvent( "RC:OnPlayerCheckpoint", resourceRoot, localPlayer, getTickCount() - UI_elements.start_time )
		end
		return
	end

	if RACE_DATA.last_marker > 1 then
		local is_finish = not pNextMarker
		if is_finish then
			UI_elements.finish_race = true
		end

		if RACE_DATA.race_type == RACE_TYPE_CIRCLE_TIME then
			if is_finish then
				CreateUIStartTimer( { "Подсчёт результатов" }, 5000 )
				removeEventHandler( "onClientVehicleDamage", localPlayer.vehicle, onClientVehicleDamage_handler )
				triggerServerEvent( "RC:OnPlayerCheckpoint", resourceRoot, localPlayer, getTickCount() - UI_elements.start_time, is_finish )
			end
		elseif RACE_DATA.race_type == RACE_TYPE_DRIFT then
			triggerServerEvent( "RC:OnPlayerCheckpoint", resourceRoot, localPlayer, CLIENT_VAR_drift_total_score )
		elseif RACE_DATA.race_type == RACE_TYPE_DRAG and is_finish then
			-- setVehicleParameters( localPlayer.vehicle, -200, 0, 0 )
			localPlayer:setData( "drag_race", nil, false )
			toggleAllControls( false )

			CreateUIStartTimer( { "Подсчёт результатов" }, 3000 )
			triggerServerEvent( "RC:OnPlayerCheckpoint", resourceRoot, localPlayer, getTickCount() - UI_elements.start_time, is_finish )
			UI_elements.start_time = nil
		end
	end

	if pNextMarker then
		pNextMarker.temp = createMarker( pNextMarker.x, pNextMarker.y, pNextMarker.z, "cylinder", 20, 0, 0, 0, 0 )
		pNextMarker.temp.dimension = localPlayer.dimension
		addEventHandler( "onClientMarkerHit", pNextMarker.temp, function( player, dim )
			if player == localPlayer and dim then
				CreateNextMarker()
			end
		end )

		if bHitVisible then
			local iNextVisibleMarker = RACE_DATA.last_marker - 1
			
			repeat 
				iNextVisibleMarker = iNextVisibleMarker + 1
			until
				not TRACK.markers[ iNextVisibleMarker ] or TRACK.markers[ iNextVisibleMarker ].is_visible
	
			pNextVisibleMarker = TRACK.markers[ iNextVisibleMarker ]
			if pNextVisibleMarker then
				pNextVisibleMarker.visible = createMarker( pNextVisibleMarker.x, pNextVisibleMarker.y, pNextVisibleMarker.z, "checkpoint", 20, 200, 50, 50 )
				pNextVisibleMarker.visible.dimension = localPlayer.dimension
				pNextVisibleMarker.blip = createBlipAttachedTo( pNextVisibleMarker.visible, 0, 3, 200, 50, 50 )
				
				local target_marker = TRACK.markers[ iNextVisibleMarker + 1 ]
				if target_marker and (RACE_DATA.race_type ~= RACE_TYPE_CIRCLE_TIME or (RACE_DATA.race_type == RACE_TYPE_CIRCLE_TIME and RACE_DATA.last_marker > 1)) then
					setMarkerTarget( pNextVisibleMarker.visible, target_marker.x, target_marker.y, target_marker.z )
				else
					setMarkerColor( pNextVisibleMarker.visible, 50, 200, 50, 150 )
					setMarkerIcon( pNextVisibleMarker.visible, "finish" )
				end
			end
		end
	else 
		for k,v in pairs(TRACK.markers) do
			if isElement(v.temp) then
				v.temp:destroy()
			end

			if isElement(v.visible) then
				v.visible:destroy()
			end

			if isElement(v.blip) then
				v.blip:destroy()
			end
		end
	end
end