loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ib")
Extend("ShUtils")
Extend("Globals")
Extend("CPlayer")
Extend("CInterior")

RECOVER_PERIOD = 2000
BLOCK_PERIOD = 2000

local START_FIGHT = false
local FATALITY_DAMAGE = false

local UI_elements = {}

local bars_data = 
{
	stamina = 
	{
		x = _SCREEN_X/8*6,
		y = _SCREEN_Y/2,
		sx = 35,
		sy = 234,
		bx = _SCREEN_X/8*6+1,
		by = _SCREEN_Y/2+232,
		bsx = 33,
		bsy = 232,
	},

	block_stamina = 
	{
		x = _SCREEN_X/8*6-30,
		y = _SCREEN_Y/2+44,
		sx = 24,
		sy = 146,
		bx = _SCREEN_X/8*6-29,
		by = _SCREEN_Y/2+189,
		bsx = 22,
		bsy = 144,
	},
}

local disabled_controls = 
{
	"sprint",
	"fire",
	"enter_exit",
	"next_weapon",
	"previous_weapon",
}

local disabled_keys = 
{
	["q"] = true,
	["tab"] = true,
	["p"] = true,
}

local pPunchTypes = 
{
	light = { loss = 25, control = "fire" },
	heavy = { loss = 50, control = "enter_exit"},
}

local iStamina, iBlockStamina = 100, 100
local pTarget = nil
local pDoor = nil

local last_hit = getTickCount()
local last_tick = getTickCount()
local last_block_state = getTickCount()

local is_last_punch = false

function StartFight( data )
	START_FIGHT = false
	FATALITY_DAMAGE = false

	for k, v in pairs( data.participants ) do
		if v ~= localPlayer then
			OnFightStarted( v )
			break
		end
	end

	setTimer( function()
		if not isElement( pDoor ) then return end
		setElementRotation( localPlayer, unpack(RING_CORNERS[data.corners[ localPlayer ]].rot))
	end, 1000, 1 )

	ShowStartSequence( function()
		START_FIGHT = true
	end )
end
addEvent( "FC:StartFight", true )
addEventHandler( "FC:StartFight", resourceRoot, StartFight )

local COUNTDOWN_TEXT = { "3", "2", "1", "GO" }

function ShowStartSequence( callback )
	UI_elements.timer_bg = ibCreateArea( 0, 0, 0, 0 ):center( 0, -280 )
	local function StartSequence( self, index )
		if not COUNTDOWN_TEXT[ index ] then 
			if isElement( UI_elements.timer_bg ) then destroyElement( UI_elements.timer_bg ) end
			callback()
			return 
		end

		local sound_path = index < #COUNTDOWN_TEXT and ":nrp_races/files/sfx/timer_tick.wav" or ":nrp_races/files/sfx/start.wav"
		local sound = playSound( sound_path )
		sound.volume = 0.35

		ibCreateLabel( 300, 0, 0, 0, COUNTDOWN_TEXT[ index ], UI_elements.timer_bg, _, _, _, "center", "center", ibFonts.bold_60 )
			:ibData( "outline", 1 )
			:ibData( "alpha", 0 )
			:ibAlphaTo( 255, 500, "SineCurve" )
			:ibMoveTo( -300, 0, 500, "OutInQuad" )
			:ibTimer( StartSequence, 1000, 1, index + 1 )
			:ibTimer( destroyElement, 1100, 1 )
	end
	StartSequence( _, 1 )
end

function OnFightStarted( target )
	iStamina = 100
	iBlockStamina = 100
	pTarget = target

	pDoor = createObject(17289, -2068.5, 1101.588 - 860, 666.504 )
	pDoor.interior = localPlayer.interior
	pDoor.dimension = localPlayer.dimension
	setElementRotation(pDoor, 0, 0, 90)
	setElementAlpha(pDoor, 0)

	setElementData(localPlayer, "fc_fighting", true, false)
	addEventHandler("onClientPlayerDamage", localPlayer, DamageHandler)
	addEventHandler("onClientPlayerDamage", target, DamageHandler)
	addEventHandler("onClientKey", root, FightKeyHandler)
	addEventHandler("onClientRender", root, DrawFightUI)
	addEventHandler("onClientPreRender", root, UpdateCamera)

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end

	toggleControl( "aim_weapon", true )

	setPedWeaponSlot(localPlayer, 0)

	triggerServerEvent("OnPlayerForceSwitchTeam", localPlayer, localPlayer, false)
end
addEvent("FC:OnFightStarted", true)
addEventHandler("FC:OnFightStarted", resourceRoot, OnFightStarted)

function OnFightFinished()
	if isElement( UI_elements.timer_bg ) then destroyElement( UI_elements.timer_bg ) end
	if isElement(pDoor) then destroyElement( pDoor ) end
	
	setElementData(localPlayer, "fc_fighting", false, false)
	removeEventHandler("onClientPlayerDamage", localPlayer, DamageHandler)
	removeEventHandler("onClientPlayerDamage", pTarget, DamageHandler)
	removeEventHandler("onClientKey", root, FightKeyHandler)
	removeEventHandler("onClientRender", root, DrawFightUI)
	removeEventHandler("onClientPreRender", root, UpdateCamera)

	for k,v in pairs(disabled_controls) do
		toggleControl( v, true )
	end

	setGameSpeed( 1 )
	setCameraTarget(localPlayer)
	triggerServerEvent("OnPlayerForceSwitchTeam", localPlayer, localPlayer, true)
end
addEvent("FC:OnFightFinished", true)
addEventHandler("FC:OnFightFinished", resourceRoot, OnFightFinished)

function FinishFight( pWinner )
	triggerServerEvent("FC:OnFightFinished", resourceRoot, pWinner)
end

function DamageHandler(attacker, weapon, bodypart, loss)
	cancelEvent()
	if FATALITY_DAMAGE then return end

	loss = loss * 2.5
	source.health = math.max( 10, source.health - loss )

	if source.health < 20 and not is_last_punch then
		FATALITY_DAMAGE = true

		setGameSpeed(0.2)
		playSound( "files/sfx/fatality.mp3" )
		setTimer(function()
			is_last_punch = false
		end, 3100, 1)

		if localPlayer == attacker then
			setTimer(FinishFight, 3000, 1, attacker)
		end
		
		is_last_punch = getTickCount()
	end
end

function FightKeyHandler( key, state )
	if isChatBoxInputActive() then return end

	if disabled_keys[ key ] or not START_FIGHT or FATALITY_DAMAGE then
		cancelEvent()
		return
	end

	if key == "mouse1" and state then
		ApplyPunch("light")
	elseif key == "f" and state then
		ApplyPunch("heavy")
	elseif key == "space" then
		if iBlockStamina <= 10 or not getControlState("aim_weapon") then
			cancelEvent()
			return
		end
	end
end

function ApplyPunch( sPunchType )
	if is_last_punch then return end

	local data = pPunchTypes[sPunchType]
	if data then
		if getTickCount() - last_hit <= 250 then
			return
		end
		if iStamina < data.loss then
			return
		end

		setControlState(data.control, true )
		last_hit = getTickCount(  )

		setTimer(function( control, loss )
			setControlState( control, false )
			if isPedDoingTask( localPlayer, "TASK_SIMPLE_FIGHT" ) then
				iStamina = iStamina - data.loss
			end
		end, 200, 1, data.control, data.loss)
	end
end

function DrawFightUI()
	local img = bars_data.stamina
	local fMul = iStamina/100
	dxDrawImage( img.x, img.y, img.sx, img.sy, "files/img/hud/stamina.png")
	dxDrawImageSection( img.bx, img.by-img.bsy*fMul, img.bsx, img.bsy*fMul, 0, img.bsy-img.bsy*fMul, img.bsx, img.bsy*fMul, "files/img/hud/stamina_body.png")
	
	local img = bars_data.block_stamina
	local fMul = iBlockStamina/100
	dxDrawImage( img.x, img.y, img.sx, img.sy, "files/img/hud/block_stamina.png")
	dxDrawImageSection( img.bx, img.by-img.bsy*fMul, img.bsx, img.bsy*fMul, 0, img.bsy-img.bsy*fMul, img.bsx, img.bsy*fMul, "files/img/hud/block_stamina_body.png")
end

local last_camera_update = 0
local last_camera_position = { 0,0,0 }

function UpdateCamera()
	local tick = getTickCount()
	if getControlState("jump") and getControlState("aim_weapon") and not getControlState("forwards") and not getControlState("backwards") and not getControlState("left") and not getControlState("right") then
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

--[[ FOR TESTS
local ped = createPed(11, localPlayer.position + Vector3(1,0,0))
ped.interior = 1
ped.dimension = localPlayer.dimension
OnFightStarted( ped )
setTimer(function()
	local moves = {
		"left", "right", "forwards", "backwards"
	}
	for k,v in pairs(moves) do
		setPedControlState( ped, v, false )
	end
	setPedControlState( ped, moves[math.random(#moves)], true )
end, 100, 0)
OnFightFinished( localPlayer )
]]