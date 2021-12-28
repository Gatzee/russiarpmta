local MAX_STAMINA = 100
local SPRINT_CONSUMPTION = 300 -- per 100 units
local LIGHT_ATTACK_CONSUMPTION = 16
local HEAVY_ATTACK_CONSUMPTION = 30
local JUMP_CONSUMPTION = 30
local FULL_RECOVER_PERIOD = 10000

local iCurrentStamina = 100
local bStaminaEnabled = false
local iLastStaminaUsage = 0

function ToggleStaminaHandler( state )
	if state then
		if not bStaminaEnabled then
			iCurrentStamina = 100
			iLastStaminaUsage = getTickCount()
			bStaminaEnabled = true
			addEventHandler("onClientPreRender", root, HandleStamina)
			addEventHandler("onClientRender", root, DrawStamina)
			addEventHandler("onClientKey", root, StaminaKeyHandler)
		end
	else
		if bStaminaEnabled then
			removeEventHandler("onClientPreRender", root, HandleStamina)
			removeEventHandler("onClientRender", root, DrawStamina)
			removeEventHandler("onClientKey", root, StaminaKeyHandler)
			bStaminaEnabled = false
		end
	end
end

local last_update, last_tick = 0, 0
local last_jump = 0
local vecLastPosition

function HandleStamina()
	local iCurrentTick = getTickCount()

	if getPedMoveState( localPlayer ) == "sprint" then
		if iCurrentTick - last_update >= 500 then
			if not vecLastPosition then 
				vecLastPosition = localPlayer.position 
			end

			TakeStamina( SPRINT_CONSUMPTION * ( vecLastPosition-localPlayer.position ).length / 100 )
			vecLastPosition = localPlayer.position
			last_update = iCurrentTick

			if iCurrentStamina <= 10 then
				setPedControlState(localPlayer, "sprint", false)
			end
		end

	elseif getPedMoveState( localPlayer ) == "jump" then
		if iCurrentTick - last_jump >= 1400 then
			TakeStamina( JUMP_CONSUMPTION )
			last_jump = iCurrentTick
		end
	end

	-- RECOVER
	local iTimePassed = iCurrentTick - iLastStaminaUsage
	if iCurrentStamina < MAX_STAMINA and iTimePassed >= 1000 then
		if vecLastPosition then
			vecLastPosition = nil
		end

		local fProgress = ( iCurrentTick - last_tick ) / FULL_RECOVER_PERIOD
		iCurrentStamina = math.min( iCurrentStamina + MAX_STAMINA*fProgress, MAX_STAMINA )
	end

	last_tick = iCurrentTick
end

local camera = getCamera()

function DrawStamina()
	local fStamina = iCurrentStamina/MAX_STAMINA
	if fStamina < 1 then
		local vecPlayerPosition = localPlayer.position
		local _, _, c_rz = getElementRotation(camera)

		local angle = math.rad( c_rz )
		local vecRelativeDirection = Vector3( math.cos(angle), math.sin(angle), -0.8 ) * 0.4

		local sx, sy = getScreenFromWorldPosition( vecPlayerPosition-vecRelativeDirection )
		if sx and sy then
			local distance = (camera.position - vecPlayerPosition).length
			local mul = interpolateBetween( 1.2, 0, 0, 0.8, 0, 0, distance/6, "Linear" )

			dxDrawRectangle( sx-6*mul, sy-60*mul, 12*mul, 120*mul, 0xFF212b36 )
			dxDrawRectangle( sx-5*mul, sy-58*mul+116*mul*(1-fStamina), 10*mul, 116*mul*(fStamina), 0xFF4195e3 )
		end
	end
end

local bound_keys = 
{
	jump = {},
	sprint = {},
	fire = {},
	enter_exit = {},
}

for control, tab in pairs(bound_keys) do
	local keys = getBoundKeys(control)
	if keys then
		for k,v in pairs(keys) do
			tab[k] = true
		end
	end
end

local last_melee_attack = 0

function StaminaKeyHandler( key, state )
	if bound_keys.jump[key] and state then
		if iCurrentStamina <= JUMP_CONSUMPTION then
			cancelEvent()
		end
	elseif bound_keys.sprint[key] and state then
		if iCurrentStamina <= 10 then
			cancelEvent()
		end
	elseif bound_keys.fire[key] and state then
		if getPedWeaponSlot(localPlayer) == 0 and not isPedInVehicle( localPlayer ) and isPedOnGround( localPlayer ) then
			if getTickCount() - last_melee_attack <= 350 then
				cancelEvent()
				return
			end

			if iCurrentStamina <= LIGHT_ATTACK_CONSUMPTION then
				cancelEvent()
			else
				TakeStamina( LIGHT_ATTACK_CONSUMPTION )
				last_melee_attack = getTickCount()
			end
		end
	elseif bound_keys.enter_exit[key] and state then
		if getPedWeaponSlot(localPlayer) == 0 then
			if getControlState( "aim_weapon" ) then
				if getTickCount() - last_melee_attack <= 350 then
					cancelEvent()
					return
				end

				if iCurrentStamina <= HEAVY_ATTACK_CONSUMPTION then
					cancelEvent()
				else
					TakeStamina( HEAVY_ATTACK_CONSUMPTION )
					last_melee_attack = getTickCount()
				end
			end
		end
	end
end

function TakeStamina( iValue )
	iCurrentStamina = math.max(iCurrentStamina - iValue, 0)
	iLastStaminaUsage = getTickCount()
end

function ResetStamina( )
	iCurrentStamina = MAX_STAMINA
end