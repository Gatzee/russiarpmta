loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )

local scx, scy = guiGetScreenSize()
local sizeX, sizeY = 128, 128
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

local pBlockedControlsList = { "fire", "jump", "forwards", "backwards", "left", "right", "enter_exit", "enter_passenger", "aim_weapon", "fire", "aim_weapon", "vehicle_fire", "vehicle_secondary_fire", "next_weapon", "previous_weapon", }
local iProcessDuration = 5000

local pCurrentProcess = nil
local pLeader, pSlave
local iNextInteriorJump = 0

WALK_HANDCUFFED_ANIM_REPLACE = {
	[ 118 ] = {
		idle = "idle_stance",
		sprint = { "sprint_panic", "run_civi",  },
		walk = {  "walk_civi", "walk_start", },
	},
	[ 132 ] = {
		idle = "woman_idlestance",
		sprint = { "woman_runsexy", "woman_runpanic", },
		walk = { "woman_walksexy", "walk_start", },
	},
}

function OnPlayerTryPutHandcuffs( pTarget, bState )
	if not isElement( pTarget ) then
		triggerServerEvent( "OnPlayerSucessfullyHandcuffed", localPlayer ) -- reset
		ResetProgress( localPlayer )
		return
	end

	if localPlayer == source then
		addEventHandler( "onClientRender", root, RenderProgress )
		setElementData( localPlayer, "radial_disabled", true, false )
		pCurrentProcess = { source, pTarget, getTickCount( ), bState }
		setPedAimTarget( localPlayer, pTarget.position )
		toggleControl( "aim_weapon", false )
		setControlState( "aim_weapon", false )
		setPedWeaponSlot( localPlayer, 0 )
	elseif localPlayer == pTarget then
		addEventHandler( "onClientRender", root, RenderProgress )
		setElementData( localPlayer, "radial_disabled", true, false )
		pCurrentProcess = { source, pTarget, getTickCount( ), bState }
	end

	setPedAnimation( source, "bomber", "bom_plant_loop", -1, true, false, false, false )

	setTimer( function( pPlayer )
		if not isElement( pPlayer ) then return end
		ResetProgress( pPlayer )
	end, iProcessDuration, 1, source )
end
addEvent( "OnPlayerTryPutHandcuffs", true )
addEventHandler( "OnPlayerTryPutHandcuffs", root, OnPlayerTryPutHandcuffs )

function ResetProgress( pPlayer )
	setPedAnimation( pPlayer, nil )
	toggleControl( "aim_weapon", true )
	triggerEvent( "onResetTaser", pPlayer ) 
end

function FollowTheLeader( )
	if localPlayer.vehicle then
		return
	end

	-- ENFORCED
	setPedWeaponSlot( localPlayer, 0 )

	for k, v in pairs( pBlockedControlsList ) do
		if isControlEnabled( v ) then
			toggleControl( v, false )
		end
	end

	if pLeader.dimension > 10 then
		return
	end

	local x1,y1,z1 = getElementPosition( localPlayer )
	local x2,y2,z2 = getElementPosition( pLeader )
	local distance = getDistanceBetweenPoints2D( x1, y1, x2, y2 )
	if distance >= 2 then
		local rot_z = findRotation( x1, y1, x2, y2 )

		setPedCameraRotation( localPlayer, rot_z )
		setControlState( "forwards", true )
		setControlState( "walk", false )

		if distance >= 8 then
			if not isLineOfSightClear( x1, y1, z1, x2, y2, z2 ) or distance >= 10 then
				setElementPosition( localPlayer, x2, y2, z2 )
			end
		elseif getPedControlState( pLeader, "walk" ) then
			setControlState( "walk", true )
		else
			setControlState( "walk", false )
			setControlState( "sprint", false )
		end

		if pLeader.interior ~= localPlayer.interior or pLeader.dimension ~= localPlayer.dimension then
			if getTickCount() >= iNextInteriorJump then
				triggerServerEvent( "FollowTheLeaderInterior", localPlayer, pLeader )
				iNextInteriorJump = getTickCount( ) + 3000
			end
		end
	else
		setControlState( "forwards", false )
	end
end

function OnLeaderVehicleStartEnter_handler( pPlayer )
	if pPlayer == pLeader then
		triggerServerEvent("FollowTheLeaderVehicle", localPlayer, source, true)
	end
end

function OnLeaderVehicleStartExit_handler( pPlayer )
	if pPlayer == pLeader then
		triggerServerEvent("FollowTheLeaderVehicle", localPlayer, pLeader, false)
	end
end

function RenderProgress( )
	local cop = pCurrentProcess[ 1 ]
	local player = pCurrentProcess[ 2 ]

	if not isElement( cop ) or not isElement( player ) or cop.health == 0 or player.health == 0 then
		removeEventHandler( "onClientRender", root, RenderProgress )
		setElementData( localPlayer, "radial_disabled", false, false )
		triggerServerEvent( "OnPlayerSucessfullyHandcuffed", localPlayer ) -- reset
		ResetProgress( localPlayer )
		return
	end

	local fProgress = ( getTickCount() - pCurrentProcess[3] ) / iProcessDuration
	local fIconBias = 25*fProgress
	dxDrawImage( posX-fIconBias, posY-fIconBias, sizeX+fIconBias*2, sizeY+fIconBias*2, "files/img/icon.png", 20*fProgress )
	dxDrawRectangle( posX-30, posY+sizeY+40, sizeX+60, 15, tocolor( 0,0,0, 150 ) )
	dxDrawRectangle( posX-30, posY+sizeY+40, (sizeX+60)*fProgress, 15, tocolor( 200-150*fProgress, 50+150*fProgress, 50, 200 ) )

	if fProgress <= 1 then
		if pCurrentProcess[4] then
			if cop == localPlayer then
				dxDrawText( "Заковываем #22dd22"..player:GetNickName().."#ffffff в наручники", posX-30, posY+sizeY+60, posX+sizeX+30, posY+sizeY+75, tocolor(255,255,255), 1, "default-bold", "center", "center", false, false, false, true )
			elseif player == localPlayer then
				dxDrawText( "#dd2222"..cop:GetNickName().." #ffffffзаковывает Вас в наручники", posX-30, posY+sizeY+60, posX+sizeX+30, posY+sizeY+75, tocolor(255,255,255), 1, "default-bold", "center", "center", false, false, false, true )
			end
		else
			if cop == localPlayer then
				dxDrawText( "Снимаем наручники с #22dd22"..player:GetNickName(), posX-30, posY+sizeY+60, posX+sizeX+30, posY+sizeY+75, tocolor(255,255,255), 1, "default-bold", "center", "center", false, false, false, true )
			elseif player == localPlayer then
				dxDrawText( "#dd2222"..cop:GetNickName().." #ffffffснимает с Вас наручники", posX-30, posY+sizeY+60, posX+sizeX+30, posY+sizeY+75, tocolor(255,255,255), 1, "default-bold", "center", "center", false, false, false, true )
			end
		end
	else
		removeEventHandler( "onClientRender", root, RenderProgress )
		setElementData( localPlayer, "radial_disabled", false, false )

		if player == localPlayer then -- localPlayer got handcuffed
			if pCurrentProcess[4] then
				pLeader = cop
				setPedAnimation( localPlayer, "CUSTOM_BLOCK_AREST", "walk_arest", -1, true, false, true, false )
				addEventHandler( "onClientRender", root, FollowTheLeader, true, "low-999999" )
				addEventHandler( "onClientVehicleEnter", root, OnLeaderVehicleStartEnter_handler)
				addEventHandler( "onClientVehicleExit", root, OnLeaderVehicleStartExit_handler)
				setElementData(localPlayer, "radial_disabled", true, false)
				setElementCollidableWith( localPlayer, pLeader, false )

				for k, v in pairs( pBlockedControlsList ) do
					toggleControl( v, false )
				end
			else
				setElementCollidableWith( localPlayer, pLeader, true )
				pLeader = nil

				for k,v in pairs( pBlockedControlsList ) do
					toggleControl( v, true )
					setControlState( v, false )
				end

				setPedAnimation( localPlayer, nil )
				removeEventHandler( "onClientRender", root, FollowTheLeader )
				removeEventHandler( "onClientVehicleEnter", root, OnLeaderVehicleStartEnter_handler)
				removeEventHandler( "onClientVehicleExit", root, OnLeaderVehicleStartExit_handler)
				setElementData(localPlayer, "radial_disabled", false, false)
			end
		elseif cop == localPlayer then -- localPlayer is police
			if pCurrentProcess[4] then
				pSlave = player
				setElementCollidableWith( localPlayer, pSlave, false )
				addEventHandler( "onClientPreRender", root, DisableWeaponControls )
			else
				setElementCollidableWith( localPlayer, pSlave, true )
				removeEventHandler( "onClientPreRender", root, DisableWeaponControls )
				toggleControl( "aim_weapon", true )
				toggleControl( "fire", true )
				pSlave = nil
			end

			triggerServerEvent( "OnPlayerSucessfullyHandcuffed", localPlayer, player, pCurrentProcess[4] )
		end
	end
end

function ChangeStateHudscuffedAnimation( player, state )
	local style_id = getPedWalkingStyle( player )
	if not WALK_HANDCUFFED_ANIM_REPLACE[ style_id ] then
		style_id = 118
	end
	local style = WALK_HANDCUFFED_ANIM_REPLACE[ style_id ]
	if state then
		engineReplaceAnimation( player, "ped", style.idle, "CUSTOM_BLOCK_AREST", "arest1" )
		for k, v in pairs( style.walk ) do
			engineReplaceAnimation( player, "ped", v, "CUSTOM_BLOCK_AREST", "walk_arest" )
		end
		for k, v in pairs( style.sprint ) do
			engineReplaceAnimation( player, "ped", v, "CUSTOM_BLOCK_AREST", "sprint_arest" )
		end
	else
		RestoreAnimations( player, style )
	end
end

function ForceBreakHandcuffs( )
	if pLeader then
		pLeader = nil

		for k,v in pairs( pBlockedControlsList ) do
			toggleControl( v, true )
			setControlState( v, false )
		end

		removeEventHandler( "onClientRender", root, FollowTheLeader )
		removeEventHandler( "onClientVehicleEnter", root, OnLeaderVehicleStartEnter_handler)
		removeEventHandler( "onClientVehicleExit", root, OnLeaderVehicleStartExit_handler)
		setElementData(localPlayer, "radial_disabled", false, false)
	elseif pSlave then
		removeEventHandler( "onClientPreRender", root, DisableWeaponControls )
		toggleControl( "aim_weapon", true )
		toggleControl( "fire", true )
		pSlave = nil
	end
end
addEvent( "ForceBreakHandcuffs", true )
addEventHandler( "ForceBreakHandcuffs", root, ForceBreakHandcuffs )

local allowed_weapons = {
	[0] = true,
	[3] = true,
	[22] = true,
	[24] = true,
	[28] = true,
	[30] = true,
	[32] = true,
}

function DisableWeaponControls( )
	local slot = getPedWeapon( localPlayer )
	if allowed_weapons[slot] then
		toggleControl( "aim_weapon", true )
		toggleControl( "fire", true )
	else
		toggleControl( "aim_weapon", false )
		toggleControl( "fire", false )
	end
end

-- Utils
function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function RestoreAnimations( player, style )
	
	if not style then
		local style_id = getPedWalkingStyle( player )
		if not WALK_HANDCUFFED_ANIM_REPLACE[ style_id ] then
			style_id = 118
		end
		style = WALK_HANDCUFFED_ANIM_REPLACE[ style_id ]
	end

	engineRestoreAnimation( player, "ped", style.idle )
	for k, v in pairs( style.walk ) do
		engineRestoreAnimation( player, "ped", v )
	end
	for k, v in pairs( style.sprint ) do
		engineRestoreAnimation( player, "ped", v )
	end
end

addEventHandler( "onClientResourceStart", resourceRoot, function()
	engineLoadIFP( "files/ifp/next.ifp", "CUSTOM_BLOCK_AREST" )
end )

addEventHandler( "onClientResourceStop", resourceRoot, function()
	for k, v in pairs( getElementsByType( "player") ) do
		if v:IsInGame() then
			RestoreAnimations( v )
		end
	end
end )

addEventHandler( "onClientElementDataChange", root, function( key, _, value )
	if key == "is_handcuffed" then
		ChangeStateHudscuffedAnimation( source, value )
	end
end )