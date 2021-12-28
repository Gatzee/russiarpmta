local SHADER_CODE = [[
float gMultiplier = 2;
float speed = 4;

texture gTexture0 < string textureState="0,Texture"; >;
float gTime : TIME;
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;

sampler Sampler0 = sampler_state
{
    Texture = gTexture0;
};

struct PSInput
{
  float4 Position : POSITION0;
  float2 TexCoord : TEXCOORD0;
  float4 Diffuse : COLOR0;
};

float4 PixelShaderFunction( PSInput PS ) : COLOR0
{
    float sin_mul = gMultiplier * abs( sin( gTime * speed ) );
    float4 color = pow( PS.Diffuse, 0.5 ) * tex2D( Sampler0, PS.TexCoord );
    color.rgb *= sin_mul;
    return color;
}

technique tec0
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
]]

local pDisabler = dxCreateShader( SHADER_CODE, 0, 50, true, "vehicle" )
dxSetShaderValue( pDisabler,  "gMultiplier", 0 )

local pShader = dxCreateShader( SHADER_CODE, 0, 50, true, "vehicle" )
local pSound = nil

local iLastClick = 0

addEventHandler("onClientResourceStart", resourceRoot, function()
	engineApplyShaderToWorldTexture( pDisabler, "rpb_right")
	engineApplyShaderToWorldTexture( pDisabler, "rpb_left")
end)

function SwitchSignals( iState )
	if getTickCount() - iLastClick <= 1000 then return end

	local pVehicle = getPedOccupiedVehicle( localPlayer )
	if isElement(pVehicle) and pVehicle.controller == localPlayer then
		local iOldState = getElementData(pVehicle, "signals")
		if iOldState == iState then
			iState = 0
		end

		--setElementData( pVehicle, "signals", iState, false )
		triggerServerEvent( "setSignals", resourceRoot, pVehicle, iState )

		iLastClick = getTickCount( )
	end
end

function UpdateSound()
	if isElement(pSound) then
		stopSound(pSound)
	end

	local pVehicle = getPedOccupiedVehicle( localPlayer )
	if isElement(pVehicle) then
		local iState = getElementData(pVehicle, "signals") or 0
		if iState > 0 then
			pSound = playSound( "files/sound.wav", true )
		end
	end
end

function onVehicleDestroy( )
	if isElement( pSound ) then stopSound( pSound ) end
	removeEventHandler( "onClientElementDestroy", source, onVehicleDestroy )
end

function onClientPlayerWasted( )
	if isElement( pSound ) then stopSound( pSound ) end
	removeEventHandler( "onClientPlayerWasted", source, onClientPlayerWasted )
end

addEventHandler("onClientPlayerVehicleEnter", root, function( vehicle )
	if source ~= localPlayer then return end
	UpdateSound()
	removeEventHandler( "onClientElementDestroy", vehicle, onVehicleDestroy )
	removeEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted )
	addEventHandler( "onClientElementDestroy", vehicle, onVehicleDestroy )
	addEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted )
end)

addEventHandler("onClientPlayerVehicleExit", root, function( vehicle )
	if source ~= localPlayer then return end
	if not vehicle or not isElement( vehicle ) then return end
	UpdateSound()
	removeEventHandler( "onClientElementDestroy", vehicle, onVehicleDestroy )
	removeEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted )
end)

function UpdateSignals( pVehicle, value )
	local value = value or getElementData(pVehicle, "signals") or 0

	if value == 0 then -- OFF
		engineRemoveShaderFromWorldTexture( pShader, "rpb_right", source )
		engineRemoveShaderFromWorldTexture( pShader, "rpb_left", source )
	elseif value == 1 then -- LEFT
		engineApplyShaderToWorldTexture( pShader, "rpb_left", source )
		engineRemoveShaderFromWorldTexture( pShader, "rpb_right", source )
	elseif value == 2 then -- RIGHT
		engineApplyShaderToWorldTexture( pShader, "rpb_right", source )
		engineRemoveShaderFromWorldTexture( pShader, "rpb_left", source )
	elseif value == 3 then -- BOTH
		engineApplyShaderToWorldTexture( pShader, "rpb_right", source )
		engineApplyShaderToWorldTexture( pShader, "rpb_left", source )
	end

	if pVehicle == localPlayer.vehicle then
		UpdateSound()
	end
end

function onClientElementDataChange_handler( key, _, value )
	if key ~= "signals" then return end
	UpdateSignals( source )
end

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) ~= "vehicle" then return end
	removeEventHandler( "onClientElementDataChange", source, onClientElementDataChange_handler )
	addEventHandler( "onClientElementDataChange", source, onClientElementDataChange_handler )
	--UpdateSignals( source )
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) ~= "vehicle" then return end
	removeEventHandler( "onClientElementDataChange", source, onClientElementDataChange_handler )
	setElementData( source, "signals", false, false )
	UpdateSignals( source, 0 )
end)

function setSignalsRemote_handler( vehicle, state )
	if isElement( vehicle ) and isElementStreamedIn( vehicle ) then
		setElementData( vehicle, "signals", state, false )
		UpdateSignals( vehicle, state )
	end
end
addEvent( "setSignalsRemote", true )
addEventHandler( "setSignalsRemote", root, setSignalsRemote_handler )

bindKey(",", "down", function()
	SwitchSignals(1)
end)

bindKey(".", "down", function()
	SwitchSignals(2)
end)

bindKey("/", "down", function()
	SwitchSignals(3)
end)

for i, v in pairs( getElementsByType( "vehicle", root, true ) ) do
	if isElementStreamedIn( v ) then
		addEventHandler( "onClientElementDataChange", v, onClientElementDataChange_handler )
		UpdateSignals( v )
	end
end