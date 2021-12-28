local scx, scy = guiGetScreenSize( )
SSAO = {shader = nil, colorRT = nil, enabled = false}

function enableAO( )
	if SSAO.enabled then return end
	SSAO.enabled = true

	SSAO.shader = dxCreateShader( "fx/ssao.fx" )
	SSAO.colorRT = dxCreateRenderTarget( scx, scy, false )
	
	SSAO.water_rt_shader = dxCreateShader( "fx/water_rt.fx", 0, 0, true )
	SSAO.water_rt_shader:applyToWorldTexture( "water*" )
	SSAO.water_rt = dxCreateRenderTarget( scx, scy, false )
	SSAO.water_rt_shader:setValue( "RT", SSAO.water_rt )

	if SSAO.shader and SSAO.colorRT then
		dxSetShaderValue( SSAO.shader, "fViewportSize", scx, scy )
		dxSetShaderValue( SSAO.shader, "sPixelSize", 1 / scx, 1 / scy )
		dxSetShaderValue( SSAO.shader, "sAspectRatio", scx / scy )
		dxSetShaderValue( SSAO.shader, "sRTColor", SSAO.colorRT )
		dxSetShaderValue( SSAO.shader, "sRTWater", SSAO.water_rt )
		dxSetShaderValue( SSAO.shader, "sProjection", createImageProjectionMatrix( { x = scx, y = scy }, 1000, 100, 10000) )

		addEventHandler( "onClientPreRender", root, onClientPreRender_AO, true, "high+9" )
		addEventHandler( "onClientFirstPersonStateChange", root, onClientFirstPersonStateChange_AO )

		SSAO.interior_timer = setTimer( UpdateShaderInInterior, 300, 0 )
	else
		disableAO( )
	end
end

function disableAO( )
	if not SSAO.enabled then return end

	if isElement( SSAO.shader ) then
		destroyElement( SSAO.shader )
	end
	if isElement( SSAO.colorRT ) then
		destroyElement( SSAO.colorRT )
	end
	if isElement( SSAO.water_rt_shader ) then
		destroyElement( SSAO.water_rt_shader )
	end
	if isElement( SSAO.water_rt ) then
		destroyElement( SSAO.water_rt )
	end
	if isTimer( SSAO.interior_timer ) then
		SSAO.interior_timer:destroy( )
	end
	
	removeEventHandler( "onClientPreRender", root, onClientPreRender_AO )
	removeEventHandler( "onClientFirstPersonStateChange", root, onClientFirstPersonStateChange_AO )

	SSAO = { }
end

function onClientPreRender_AO( )
	dxSetRenderTarget( SSAO.water_rt, true )
	dxSetRenderTarget( )
	dxSetRenderTarget( SSAO.colorRT )
	dxSetRenderTarget( )
	local cPosX, cPosY, cPosZ = getCameraMatrix( )
	dxDrawMaterialLine3D( cPosX + 0.5, cPosY + 1, cPosZ, cPosX + 0.5, cPosY , cPosZ, SSAO.shader, 1, nil, cPosX + 0.5,cPosY + 0.5, cPosZ + 1 )
end

function onClientFirstPersonStateChange_AO( state )
	removeEventHandler( "onClientPreRender", root, onClientPreRender_AO )
	if not state then
		addEventHandler( "onClientPreRender", root, onClientPreRender_AO, true, "high+9" )
	end
end

function UpdateShaderInInterior( )
	SSAO.shader:setValue( "fMXAOAmbientOcclusionAmount", localPlayer.interior == 0 and 0.7 * 4.0 or 0.3 * 4.0 )
end

function createImageProjectionMatrix( viewportSize, adjustZFactor, nearPlane, farPlane )
    local Q = farPlane / ( farPlane - nearPlane )
    local rcpSizeX = 2.0 / viewportSize.x * adjustZFactor
    local rcpSizeY = -2.0 / viewportSize.y * adjustZFactor

    return {
		rcpSizeX, 0, 0,  0, 
		0, rcpSizeY, 0, 0, 
		0, 0, Q, 1,
        ( -viewportSize.x / 2.0 - 0.5 ) * rcpSizeX,( -viewportSize.y / 2.0 - 0.5 ) * rcpSizeY, -Q * nearPlane , 0,
    }
end