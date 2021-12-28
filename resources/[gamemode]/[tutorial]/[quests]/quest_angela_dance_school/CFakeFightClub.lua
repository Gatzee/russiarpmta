
scx, scy = guiGetScreenSize()

RECOVER_PERIOD = 2000
BLOCK_PERIOD = 2000

local bars_data = 
{
	stamina = 
	{
		x = scx/8*6,
		y = scy/2,
		sx = 35,
		sy = 234,
		bx = scx/8*6+1,
		by = scy/2+232,
		bsx = 33,
		bsy = 232,
	},

	block_stamina = 
	{
		x = scx/8*6-30,
		y = scy/2+44,
		sx = 24,
		sy = 146,
		bx = scx/8*6-29,
		by = scy/2+189,
		bsx = 22,
		bsy = 144,
	},
}

CENTER_RING = Vector3( -2068.0239, 247.6311, 666.4254 )

disabled_controls = 
{
	"sprint",
	"fire",
	"enter_exit",
	"next_weapon",
	"previous_weapon",
}

disabled_keys = 
{
	["q"] = true,
	["tab"] = true,
	["p"] = true,
}

help_info_block = false
help_info_punch = false
help_info_keys = false

local pPunchTypes = 
{
	light = { loss = 100/6, control = "fire" },
	heavy = { loss = 50, control = "enter_exit"},
}

local iStamina, iBlockStamina = 100, 100
local pTarget = nil
local pDoor = nil

local last_hit = getTickCount()
local last_tick = getTickCount()
local last_block_state = getTickCount()

local is_last_punch = false

function StartFight( pTarget )
    OnFightStarted( pTarget )
end

function OnFightStarted( target )
	iStamina = 100
	iBlockStamina = 100
	is_last_punch = false
	pTarget = target

	pDoor = createObject( 17289, -2068.5, 1101.588, 666.504 )
	pDoor.interior = localPlayer.interior
	pDoor.dimension = localPlayer.dimension
	setElementRotation( pDoor, 0, 0, 90 )
	setElementAlpha( pDoor, 0 )

	setElementData( localPlayer, "fc_fighting", true, false )
    
    addEventHandler( "onClientPlayerDamage", localPlayer, DamageHandler )
    addEventHandler( "onClientPedDamage", pTarget, DamageHandler )
    
	addEventHandler( "onClientKey", root, FightKeyHandler )
	addEventHandler( "onClientRender", root, DrawFightUI )
	addEventHandler( "onClientPreRender", root, UpdateCamera )

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end

	toggleControl( "aim_weapon", true )

	setPedWeaponSlot( localPlayer, 0 )

	setElementRotation( localPlayer, 0, 0, -findRotation( CENTER_RING.x, CENTER_RING.y, localPlayer.position.x, localPlayer.position.y ) )
	setElementRotation( target, 0, 0, -findRotation( CENTER_RING.x, CENTER_RING.y, target.position.x, target.position.y ) )
end

function OnFightFinished()
	if isElement( pDoor ) then destroyElement( pDoor ) end
	
	setElementData( localPlayer, "fc_fighting", false, false )
    
	removeEventHandler( "onClientPlayerDamage", localPlayer, DamageHandler )
	if isElement( pTarget ) then
		removeEventHandler( "onClientPedDamage", pTarget, DamageHandler )
	end
    
	removeEventHandler( "onClientKey", root, FightKeyHandler )
	removeEventHandler( "onClientRender", root, DrawFightUI )
	removeEventHandler( "onClientPreRender", root, UpdateCamera )

	for k,v in pairs( disabled_controls ) do
		toggleControl( v, true )
    end
	setCameraTarget( localPlayer )
	help_info_block, help_info_punch, help_info_keys = false, false, false
	setGameSpeed( 1 )
end

function DamageHandler( attacker, weapon, bodypart, loss )
	cancelEvent()

	if source == pTarget then
		loss = loss * 2.5
		source.health = source.health - math.min( 5, loss )
	else
		source.health = source.health - 2
	end
	
	if source == pTarget and source.health < 10 and not is_last_punch then
		--CleanupAIPedPatternQueue( GEs.boyfriend )
		--ResetAIPedPattern( GEs.boyfriend )
		GEs.boyfriend.frozen = true

		addEventHandler( "onClientPedDamage", GEs.boyfriend, cancelEvent )

		setGameSpeed( 0.2 )
		playSound( ":nrp_fight_club/files/sfx/fatality.mp3" )
		fadeCamera( false, 1 )
		setTimer(function()
			setGameSpeed( 1 )

            localPlayer.position = QUEST_CONF.positions.fight_club_ring_enter
            fadeCamera( true, 1 )
			triggerServerEvent( "angela_dance_school_step_13", localPlayer )

            OnFightFinished()
		end, 4000, 1)

        is_last_punch = getTickCount()
	elseif source == localPlayer and source.health < 10 then
        OnFightFinished()
        triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "fail_quest", fail_text = "Вы проиграли бой" } )
	end
end

function FightKeyHandler( key, state )
	if getControlState( "jump" ) then return end
	if isChatBoxInputActive() then return end

	if disabled_keys[ key ] then
		cancelEvent()
		return
	end

	if key == "mouse1" and state then
		ApplyPunch( "light" )
	elseif key == "f" and state then
		ApplyPunch( "heavy" )
	elseif key == "space" then
		if iBlockStamina <= 10 or not getControlState( "aim_weapon" ) then
			cancelEvent()
			return
		end
	elseif key == "lshift" and CEs.hint_3 then
		if not help_info_block then
			help_info_block = true
			setGameSpeed( 0.1 )
			localPlayer:ShowInfo( "Следи за желтой полосой, она отвечает за время в блоке" )
			setTimer( function()
				setGameSpeed(1)
			end, 6000, 1 )
		end
	end
end

function ApplyPunch( sPunchType )
	if is_last_punch or CEs.hint_1 or CEs.hint then return end

	local data = pPunchTypes[ sPunchType ]
	if data then
		if getTickCount() - last_hit <= 250 then
			return
		end
		if iStamina < data.loss then
			return
		end

		setControlState( data.control, true )
		last_hit = getTickCount(  )

		setTimer( function( control, loss )
			setControlState( control, false )
			if isPedDoingTask( localPlayer, "TASK_SIMPLE_FIGHT" ) then
				iStamina = iStamina - data.loss
			end
		end, 200, 1, data.control, data.loss)

		if not help_info_punch then
			help_info_punch = true
			setGameSpeed( 0.1 )
			localPlayer:ShowInfo( "Следи за синей полосой, она отвечает за выносливость" )
			setTimer( function()
				setGameSpeed(1)
				CEs.hint_2 = CreateSutiationalHint( {
					text = "Нажми key=F для сильного удара",
					condition = function( )
						return true
					end
				} ) 
			end, 6000, 1 )
		end
	end
end

function DrawFightUI()
	local img = bars_data.stamina
	local fMul = iStamina / 100
	dxDrawImage( img.x, img.y, img.sx, img.sy, ":nrp_fight_club/files/img/hud/stamina.png" )
	dxDrawImageSection( img.bx, img.by-img.bsy*fMul, img.bsx, img.bsy*fMul, 0, img.bsy-img.bsy*fMul, img.bsx, img.bsy*fMul, ":nrp_fight_club/files/img/hud/stamina_body.png" )
	
	local img = bars_data.block_stamina
	local fMul = iBlockStamina/100
	dxDrawImage( img.x, img.y, img.sx, img.sy, ":nrp_fight_club/files/img/hud/block_stamina.png" )
	dxDrawImageSection( img.bx, img.by-img.bsy*fMul, img.bsx, img.bsy*fMul, 0, img.bsy-img.bsy*fMul, img.bsx, img.bsy*fMul, ":nrp_fight_club/files/img/hud/block_stamina_body.png" )
end

local last_camera_update = 0
local last_camera_position = { 0,0,0 }

function UpdateCamera()
	local tick = getTickCount()
	if getControlState( "jump" ) and getControlState( "aim_weapon" ) and not getControlState( "forwards" ) and not getControlState( "backwards" ) and not getControlState( "left" ) and not getControlState( "right" ) then
		iBlockStamina = iBlockStamina - 100*( (tick - last_tick) / BLOCK_PERIOD )
		if iBlockStamina <= 10 then
			setControlState( "jump", false )
		end
		last_block_state = tick
	end

	if iBlockStamina < 100 and tick - last_block_state >= 1000 then
		iBlockStamina = iBlockStamina+100*( (tick - last_tick) / RECOVER_PERIOD )
		if iBlockStamina >= 100 then 
			iBlockStamina = 100
		end
	end

	if iStamina < 100 and tick - last_hit >= 1500 then
		iStamina = iStamina+100*( (tick - last_tick) / RECOVER_PERIOD )
		if iStamina >= 100 then 
			iStamina = 100
			last_tick = false
		end
	end
	last_tick = tick

	-- TARGET FORWARDING
	local x, y = getElementPosition(localPlayer)
	local tx, ty, tz = getElementPosition(pTarget)
	local vecPlayerPosition = localPlayer.position
	local vecOpponentPosition = pTarget.position

	local fProgress = (tick - last_camera_update) / 600

	local px, py, pz = interpolateBetween( last_camera_position[1], last_camera_position[2], last_camera_position[3], tx, ty, tz, fProgress, "Linear" )
	local vecTargetPosition = Vector3(px, py, pz)
	if fProgress >= 1 then
		last_camera_update = getTickCount()
		last_camera_position = { px, py, pz }
	end

	local rot_z = findRotation( px, py, x, y )

	local vecDirection = vecPlayerPosition-vecTargetPosition
	vecDirection:normalize()
	local bx, by = getPointFromDistanceRotation( 0.4, -rot_z-90 )
	local vecBias = Vector3(bx, by, 0)
	local vecPoint1 = vecPlayerPosition + vecDirection*2 - vecBias + Vector3(0, 0, 1)
	local vecPoint2 = vecTargetPosition - vecDirection*2 + Vector3(0, 0, 0.5)

	if is_last_punch then
		setControlState( "aim_weapon", false )
		local fProgress = (tick - is_last_punch) / 3000
		local bx, by = getPointFromDistanceRotation( 6-fProgress*4, 120*fProgress )
		vecBias = Vector3(bx, by, 0)
		vecPoint1 = vecPlayerPosition - (vecPlayerPosition-vecOpponentPosition)/2 + vecBias
		vecPoint2 = vecPlayerPosition - (vecPlayerPosition-vecOpponentPosition)/2
	end
	setCameraMatrix( vecPoint1, vecPoint2 )
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t
end

function getPointFromDistanceRotation(dist, angle)
    local a = math.rad(90 - angle)
 
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist
 
    return dx, dy
end