local iRechargeDelay = 10000
local iHitWiresBlinkDuration = 3000
local iMissWiresBlinkDuration = 1000
local iDisableDuration = 10000

local iMaxDistance = 9

local iLastShot = 0
local iLastHit = 0
local pTaserSound = nil
local pHeartbeatSound = nil
local pTaserShotsAround = { }
local pWakeUpTimer = { }

local pBlockedControlsList = { "jump", "forwards", "backwards", "left", "right", "previous_weapon", "next_weapon", "aim_weapon", "enter_passenger", "enter_exit" }

local pTaserBeamMaterial = dxCreateTexture( "files/img/beam.png" )

local pBoundKeys = { }
for k, v in pairs( getBoundKeys( "fire" ) ) do
	pBoundKeys[ k ] = true
end

addEvent ( "onResetTaser", true ) 
addEventHandler ( "onResetTaser", root, function( )
	if localPlayer:getWeaponSlot( ) == 2 then
		OnPlayerWeaponSwitch_handler( 2, 3 ) 
		setTimer( function( )
			if localPlayer:getWeaponSlot( ) == 2 then
				OnPlayerWeaponSwitch_handler( 3, 2 ) 
			end 
		end, 500, 1 )
	end 
end )

function OnPlayerWeaponSwitch_handler( _, current_slot )
	if localPlayer:getData( "holdarea_id" ) then return end

	removeEventHandler( "onClientKey", root, OnPlayerTaserFire )

	local controlState = true
	if current_slot == 2 and getPedWeapon( localPlayer ) == 23 then
		addEventHandler( "onClientKey", root, OnPlayerTaserFire )
		controlState = false
	end

	toggleControl( "fire", controlState )
	toggleControl( "action", controlState )
end
addEventHandler( "onClientPlayerWeaponSwitch", root, OnPlayerWeaponSwitch_handler )

function DrawTaserCharge( )
	if localPlayer:getData( "holdarea_id" ) or localPlayer:getData( "is_handcuffed" ) then return end

	local is_taser = getPedWeapon( localPlayer ) == 23
	if is_taser then
		toggleControl( "fire", false )
		toggleControl( "action", false )

		if getControlState( "aim_weapon" ) then
			local tx, ty, tz = getPedTargetStart( localPlayer )
			local sx, sy = getScreenFromWorldPosition( tx, ty, tz )

			if sx and sy then
				local fProgress = ( getTickCount() - iLastShot ) / iRechargeDelay
				if fProgress <= 1 and iLastShot + iHitWiresBlinkDuration <= getTickCount() then
					dxDrawRectangle( sx-70, sy+30, 160, 15, tocolor( 50, 50, 50, 150 ) )
					dxDrawRectangle( sx-70, sy+30, 160*fProgress, 15, tocolor( 200-(150*fProgress), 50+(150*fProgress), 50 ) )
					dxDrawText( "Заряжается "..math.floor(fProgress*100).."%", sx-70, sy+30, sx+90, sy+45, 0xFFFFFFFF, 1, "default-bold", "center", "center"  )
				end
			end
		end
	end
end
addEventHandler( "onClientPreRender", root, DrawTaserCharge )

function OnPlayerTaserFire( key, state )
	if not state or localPlayer:getData( "jailed" ) then return end
	if pBoundKeys[key] then
		if getControlState( "aim_weapon" ) then
			TaserFire( )
		end
	end
end

function TaserFire()
	if getTickCount() - iLastShot <= iRechargeDelay then
		return
	end

	--setPedAnimation(localPlayer, "python", "python_fire", 150, false, false, true, false)
	local sx, sy, sz = getPedTargetStart( localPlayer )
	local tx, ty, tz = getPedTargetEnd( localPlayer )

	local _, _, _, _, pElement = processLineOfSight( sx, sy, sz, tx, ty, tz )

	if pElement and isElement( pElement ) then
		if pElement == localPlayer then return end
		local distance = ( localPlayer.position - pElement.position ).length
		if getElementType( pElement ) == "player" and distance <= iMaxDistance then
			triggerServerEvent( "OnPlayerTaserFire", localPlayer, pElement )
		end
	end
end

function DrawTaserWires()
	if #pTaserShotsAround == 0 then
		removeEventHandler( "onClientRender", root, DrawTaserWires )
	end

	for i = #pTaserShotsAround, 1, -1 do
		local shot = pTaserShotsAround[ i ]
		if getPedWeapon(shot.source) == 23 then
			if isElement(shot.target) then
				local x,y,z = getPedWeaponMuzzlePosition( shot.source )
				if x then
					for i=1,3 do
						local vecRandBias = Vector3( math.random(1,3)/10, math.random(1,3)/10, math.random(1,3)/10 )
						if getElementType(shot.target) == "player" then
							local tx,ty,tz = getPedBonePosition( shot.target, 2 )
							dxDrawMaterialLine3D( x,y,z, Vector3(tx,ty,tz)+vecRandBias, pTaserBeamMaterial, 0.05 )
						else
							dxDrawMaterialLine3D( x,y,z, shot.target.position+vecRandBias, pTaserBeamMaterial, 0.05 )
						end
					end
				end

				if getTickCount() - shot.started >= iHitWiresBlinkDuration then
					if shot.source == localPlayer then
						toggleControl( "aim_weapon", true )
					end
					table.remove(pTaserShotsAround, i)
				end
			else
				if getTickCount() - shot.started >= iMissWiresBlinkDuration then
					table.remove(pTaserShotsAround, i)
					if shot.source == localPlayer then
						toggleControl( "aim_weapon", true )
					end
				end
			end
		else
			table.remove(pTaserShotsAround, i)
		end
	end
end

function FeelsBad()
	if isElement(pHeartbeatSound) then
		local fProgress = (getTickCount() - iLastHit) / iDisableDuration
		setSoundSpeed( pHeartbeatSound, 1.2-(0.4*fProgress) )

		if fProgress >= 1 then
			stopSound( pHeartbeatSound )
			
			if true then -- Добавить проверку на то, не законван ли уже игрок в наручники или ещё что
				for k,v in pairs(pBlockedControlsList) do
					toggleControl(v, true)
				end
			end
			setElementFrozen( localPlayer, false )

			removeEventHandler( "onClientRender", root, FeelsBad )
		end
	end
end

function OnClientPlayerTaserFired( target, is_local_bot )
	if not isElementStreamedIn( source ) then return end

	if isElement(pTaserSound) then stopSound(pTaserSound) end
	pTaserSound = playSound3D( "files/sound/taser.mp3", source.position )

	local shot_data = 
	{
		started = getTickCount(),
		source = source,
		target = target,
	}

	local element_types = {
		ped = true,
		player = true,
	}

	if isElement(target) and element_types[ getElementType(target) ] then
		setPedAnimation( target,  "ped", "ko_shot_front", -1, false, false, true, false )
		setTimer(function()
			if not isElement( target ) then return end
			triggerEvent( "onClientHideMenuPhotoMode", resourceRoot )
			setPedAnimation( target,  "crack", "crckidle"..math.random(1,4), -1, true, false, false, false )
			setElementData( target, "is_tased", true, false )
		end,500,1)

		if not is_local_bot then
			if isTimer(pWakeUpTimer[target]) then killTimer(pWakeUpTimer[target]) end
			pWakeUpTimer[target] = setTimer(function(pTarget)
				if not isElement(pTarget) then return end
				setPedAnimation(pTarget, nil)
				setElementData(pTarget, "is_tased", false, false)
			end, iDisableDuration, 1, target)
		end
	end

	table.insert(pTaserShotsAround, shot_data)

	if #pTaserShotsAround == 1 then
		addEventHandler( "onClientRender", root, DrawTaserWires )
	end

	if localPlayer == target then
		if isElement(pHeartbeatSound) then stopSound(pHeartbeatSound) end
		pHeartbeatSound = playSound( "files/sound/heartbeat.mp3", true )
		setSoundSpeed( pHeartbeatSound, 1.2 )

		for k,v in pairs(pBlockedControlsList) do
			toggleControl(v, false)
		end
		setElementFrozen( localPlayer, true )

		if getTickCount() - iLastHit >= iDisableDuration then
			addEventHandler("onClientRender", root, FeelsBad)
		end

		iLastHit = getTickCount()
	end

	if localPlayer == source then
		toggleControl( "aim_weapon", false )
		setControlState( "aim_weapon", true )
		iLastShot = getTickCount()
	else
		setPedAnimation(source, "python", "python_fire", 150, false, false, true, false)
	end
end
addEvent("OnClientPlayerTaserFired", true)
addEventHandler("OnClientPlayerTaserFired", root, OnClientPlayerTaserFired)

addEventHandler( "onClientResourceStart", resourceRoot, function()
	local txd = engineLoadTXD ( "files/mdl/taser.txd" )
	engineImportTXD ( txd, 347 )
	local dff = engineLoadDFF ( "files/mdl/taser.dff" )
	engineReplaceModel ( dff, 347 )
end )