loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )

local x, y = guiGetScreenSize()
local camera_element = getCamera()
local shader
local alpha = 0
local cvx, cvy, cvz = 0, 0, 0

function RenderSnow()
	local cx, cy, cz = getCameraMatrix( )
	local crx, cry, crz = getElementRotation( camera_element )
	local ncvx, ncvy, ncvz = getElementVelocity( localPlayer.vehicle or localPlayer )

	cvx, cvy, cvz = cvx + math.abs( ncvx / 10 ), cvy + math.abs( ncvy / 10 ), cvz + math.abs( ncvz / 10 )

	dxSetShaderValue( shader, "cam_rotation", crx, cry, crz )
	dxSetShaderValue( shader, "cam_velocity", cvx, cvy, 0  )

	local condition = 
		isLineOfSightClear( cx, cy, cz-0.3, cx, cy, cz + 20 ) and
		localPlayer:IsInGame() and
		localPlayer.interior == 0 and
		not localPlayer:getData( "bFirstPerson" )

	alpha = math.min( 255, math.max( 0, condition and alpha + 10 or alpha - 10 ) )

	dxSetShaderValue( shader, "alpha", alpha / 255 )

	if alpha > 0 then
		dxDrawImage( 0, 0, x, y, shader )
	end
end

function onSettingsChange_handler( changed, values )
	if changed.snow then
		removeEventHandler( "onClientHUDRender", root, RenderSnow )
		if isElement( shader ) then destroyElement( shader ) end
		if values.snow and ( values.snow == 1 or values.snow == 3 ) then
			shader = dxCreateShader( "fx/snow.fx" )
			if isElement( shader ) then
				addEventHandler( "onClientHUDRender", root, RenderSnow, false, "high+100000" )
			end
		end
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	triggerEvent( "onSettingsUpdateRequest", localPlayer, "snow" )
end )