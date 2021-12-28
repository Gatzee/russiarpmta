loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend("Globals")
Extend("ShUtils")
Extend("CVehicle")
Extend("CSound")
Extend("CPlayer")
Extend("ShVehicleConfig")

LAST_VEHICLE_POSITION = { }
UPDATE_COUNTER = 0
SYNCED = { }
DAMAGE_MULTIPLIERS = {
	0.6,
	0.55,
	0.5,
	0.4,
	0.3,
	0.5,
}

OFF_ENGINE_TMR = {}
OFF_ENGINE_TIME_MS = 60 * 10 * 1000

local function getTierByModel( model, variant )
	local tier = 1
	local tiers = {
		[ 1 ] = 0,
		[ 2 ] = 184,
		[ 3 ] = 219,
		[ 4 ] = 249,
		[ 5 ] = 279,
	}

	local max_speed = VEHICLE_CONFIG[model].variants[variant].max_speed
	while true do
		if tiers[ tier + 1 ] and tiers[ tier + 1 ] < max_speed then
			tier = tier + 1
		else
			break
		end
	end

	return tier
end

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	for model, info in pairs( VEHICLE_CONFIG ) do
		for variant, config in ipairs( info.variants ) do
			if config.handling.centerOfMassX then
				config.handling.centerOfMass = {
					config.handling.centerOfMassX,
					config.handling.centerOfMassY,
					config.handling.centerOfMassZ,
				}

				config.handling.centerOfMassX = nil
				config.handling.centerOfMassY = nil
				config.handling.centerOfMassZ = nil
			end

			for key, value in pairs( config.handling ) do
				--setModelHandling( model, key, value )
			end

			if not config.use_collisions_dm then
				local class = getTierByModel( model, variant )
				local damageMultiplier = DAMAGE_MULTIPLIERS[ class ] or 1

				--setModelHandling( model, "collisionDamageMultiplier", damageMultiplier )
			end
		end
	end
end )

local function GetCurrentVehicle()
	local veh = getPedOccupiedVehicle( localPlayer )
	if isElement(veh) then
		if getVehicleController( veh ) == localPlayer then
			return veh
		end
	end
end

function ForceSyncVehicleStats( pVehicle, fFuel, fMileage, status )
	pVehicle:SetFuel( fFuel )
	pVehicle:SetMileage( fMileage )
	SYNCED[pVehicle] = true
	LAST_VEHICLE_POSITION[pVehicle] = nil
end
addEvent("ForceSyncVehicleStats", true)
addEventHandler("ForceSyncVehicleStats", root, ForceSyncVehicleStats)

function UpdateVehicleData( bSync )
	local pVehicle = GetCurrentVehicle()
	if isElement(pVehicle) then
		if not SYNCED[pVehicle] then return end
		local bSync = bSync or UPDATE_COUNTER == 12
		local old_position = LAST_VEHICLE_POSITION[pVehicle] or pVehicle.position
		local distance = (localPlayer.position - old_position).length
		if distance >= 1000 then return end

		LAST_VEHICLE_POSITION[pVehicle] = pVehicle.position

		pVehicle:SetMileage( pVehicle:GetMileage( ) + distance / 1000 )

		-- Fuel consumption
		local current_quest = localPlayer:getData( "current_quest" ) or { }
		if getVehicleEngineState( pVehicle ) and not (pVehicle.model == 468 and current_quest.is_company_quest) then
			local fFuelLoss = pVehicle:GetProperty("fuel_loss") or 5
			local fSpeedMul = Clamp(0.3, 1.5, pVehicle.velocity.length)

			pVehicle:SetFuel( math.max( pVehicle:GetFuel() - fFuelLoss*fSpeedMul / 30, 0 ) )

			if pVehicle:GetFuel() <= 0 then
				triggerServerEvent("ForceToggleVehicleEngine", localPlayer, pVehicle, false)
				bSync = true
			end
		end

		if bSync then
			triggerServerEvent("ForceSyncVehicleStats", localPlayer, pVehicle, pVehicle:GetFuel(), pVehicle:GetMileage())
			triggerServerEvent( "OnRequestVehicleProperties", localPlayer, pVehicle )
		end

		UPDATE_COUNTER = UPDATE_COUNTER + 1
		if UPDATE_COUNTER > 12 then UPDATE_COUNTER = 0 end
	end
end
setTimer(UpdateVehicleData, 5000, 0)

addEventHandler("onClientVehicleStartExit", root, function( pPlayer, iSeat )
	if pPlayer == localPlayer and iSeat == 0 then
		UpdateVehicleData( true )
		UPDATE_COUNTER = 0
		toggleControl( "steer_forward", true )
	end
end)

local HAS_SIRENS_VEHICLE_MODELS =
{
	[ 490 ] = true,
	[ 596 ] = true,
	[ 432 ] = true,
}

local function ClientRender()
	--[[for i, pVehicle in ipairs( getElementsByType( "vehicle", root, true ) ) do
		if pVehicle:IsBroken() and getVehicleType(pVehicle) == "Helicopter" and getVehicleOccupant(pVehicle) and math.abs(getHelicopterRotorSpeed(pVehicle)) > 0.08 then
			setHelicopterRotorSpeed(pVehicle, 0.08)
		end
	end]]

	local pVehicle = getPedOccupiedVehicle( localPlayer )
	if pVehicle then
		local vehicle_model = pVehicle.model
		if vehicle_model == 468 or ( VEHICLE_CONFIG[ vehicle_model ] or { } ).is_moto then
			if isVehicleOnGround( pVehicle ) then
				if getControlState( "accelerate" ) then
					toggleControl( "steer_forward", false )
				else
					toggleControl( "steer_forward", true )
				end
			else
				toggleControl( "steer_forward", true )
			end
		elseif HAS_SIRENS_VEHICLE_MODELS[ vehicle_model ] then
			setVehicleSirensOn( pVehicle, false )
		end

		if pVehicle.engineState and not pVehicle:getData( "off_brake_reverse" ) then
			toggleControl( "brake_reverse", true )
		else
			toggleControl( "brake_reverse", false )
		end
	end
end
Timer( ClientRender, 50, 0 )
--addEventHandler( "onClientPreRender", root, ClientRender )

addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function( veh, seat )
	if seat == 0 then
		if isTimer( OFF_ENGINE_TMR[ veh ] ) then killTimer( OFF_ENGINE_TMR[ veh ] ) end

		SYNCED = {}
		UPDATE_COUNTER = 0

		setPedWeaponSlot(localPlayer,0)

		local vehicle = localPlayer.vehicle
		local vehicle_model = vehicle.model
		if HAS_SIRENS_VEHICLE_MODELS[ vehicle_model ] then
			removeEventHandler( "onClientKey", root, playerPressedKey )
			addEventHandler( "onClientKey", root, playerPressedKey )
		end

		removeEventHandler("onClientKey", root, OnClientAccelerartionKey_handler)
		addEventHandler("onClientKey", root, OnClientAccelerartionKey_handler)
	end
end )

addEventHandler( "onClientPlayerVehicleExit", localPlayer, function( veh, seat )
	if seat == 0 then
		removeEventHandler( "onClientKey", root, playerPressedKey )
		
		-- off engine temporary bike
		if isElement( veh ) and veh.model == 468 and veh:IsOwnedBy( localPlayer ) then
			OFF_ENGINE_TMR[ veh ] = setTimer( function()
				if isElement( veh ) and not veh.controller then
					veh.engineState = false
				end
			end, OFF_ENGINE_TIME_MS, 1 )
		end

		removeEventHandler("onClientKey", root, OnClientAccelerartionKey_handler)
	end
end )

function ReceiveVehicleProperties( pData )
	source:setData("properties", pData, false)
	triggerEvent("OnClientVehiclePropertiesChanged", source, pData)
end
addEvent("ReceiveVehicleProperties", true)
addEventHandler("ReceiveVehicleProperties", root, ReceiveVehicleProperties)

function onClientResetVehicleLastPosition_handler( vehicle )
	LAST_VEHICLE_POSITION[ vehicle ] = nil
end
addEvent( "onClientResetVehicleLastPosition", true )
addEventHandler( "onClientResetVehicleLastPosition", root, onClientResetVehicleLastPosition_handler )


LAST_CAPS_PRESS = 0
function playerPressedKey( button, press )
	if press and ( button == "capslock" or button == "h" ) then
		local vehicle = localPlayer.vehicle
		if vehicle.model == 432 then
			cancelEvent()
			return
		end

		local tick = getTickCount( )
		if tick - LAST_CAPS_PRESS <= 1000 then cancelEvent( ) end
		LAST_CAPS_PRESS = tick
		setVehicleSirensOn( vehicle, false )
	end
end

ACCELERATE_KEYS = getBoundKeys( "accelerate" )
LAST_ACCELERATE_TICK = 0
REPEATS_IN_ROW = 0

function OnClientAccelerartionKey_handler( key, state )
	if not ACCELERATE_KEYS[ key ] then return end
	local tick = getTickCount()

	if state then
		if tick - LAST_ACCELERATE_TICK <= 200 then
			REPEATS_IN_ROW = REPEATS_IN_ROW + 1

			if REPEATS_IN_ROW >= 3 then
				cancelEvent()
			end
		else
			REPEATS_IN_ROW = 0
		end
		LAST_ACCELERATE_TICK = getTickCount()
	end
end