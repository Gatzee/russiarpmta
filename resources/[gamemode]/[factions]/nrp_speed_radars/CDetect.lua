local scx, scy = guiGetScreenSize()

local SOUND_VOLUME_MIN = 0.3
local SOUND_VOLUME_MAX = 0.6
local SOUND_SPEED_MIN = 0.2
local SOUND_SPEED_MAX = 1

local pRadarIcon = dxCreateTexture( "files/img/icon_radar.png" )
local pSound
local pData = {}

function OnPlayerDetectZoneEnter( data )
	pData = data
	
	removeEventHandler( "onClientRender", root, RenderDetect )
	addEventHandler( "onClientRender", root, RenderDetect )
end

function OnPlayerDetectZoneLeave()
	removeEventHandler( "onClientRender", root, RenderDetect )
	pData = {}

	if isElement( localPlayer.vehicle ) then
		for k,v in pairs( SPEED_RADARS ) do
			if isElementWithinColShape( localPlayer.vehicle, v.detect_colsphere ) then
				OnPlayerDetectZoneEnter( { vec_position = v.detect_colsphere.position, radius = v.radius, limit = v.velocity_limit } )
				break
			end
		end
	end
end

function RenderDetect()
	if pData.vec_position and localPlayer.vehicle then
		local vecDirection = pData.vec_position - localPlayer.vehicle.position
		local vecVehicleDirection = localPlayer.vehicle.velocity

		local fDistance = vecDirection.length

		local fDirectionAngle = math.atan2( vecDirection.y, vecDirection.x )
		local fVelocityAngle = math.atan2( vecVehicleDirection.y, vecVehicleDirection.x )

		local fAngle = math.abs( math.deg( fDirectionAngle - fVelocityAngle ) )

		local fProgress = 1 - ( fDistance - pData.radius ) / 180

		if vecVehicleDirection.length >= pData.limit and fAngle <= 80 then
			local fVolume, fSpeed = interpolateBetween( SOUND_SPEED_MIN, SOUND_VOLUME_MIN, 0, SOUND_SPEED_MAX, SOUND_VOLUME_MAX, 0, fProgress, "Linear")

			SwitchSound( true )

			setSoundVolume( pSound, fVolume )
			setSoundSpeed( pSound, fSpeed )

			dxDrawImage( 279, scy-269, 42, 42, pRadarIcon )
		else
			SwitchSound( false )
		end
	else
		removeEventHandler( "onClientRender", root, RenderDetect )
	end
end

function SwitchSound( state )
	if state then
		if not isElement(pSound) then
			pSound = playSound( "files/sounds/detect.wav" )
		end
	else
		if isElement(pSound) then
			destroyElement( pSound )
		end

		iSoundMode = nil
	end
end