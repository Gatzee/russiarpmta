local object_id = 647
local shader_code = [[
	float gTime : TIME;
	texture gTexture;
	float3x3 getTextureTransform( )
	{
		return float3x3(1, 0, 0, 0, 1, 0, 0, -fmod( gTime/12 , 1 ), 1 );
	}
	technique tec0
	{
		pass P0
		{
			Texture[0] = gTexture;
			TextureTransform[0] = getTextureTransform( );
			TextureTransformFlags[0] = Count2;
			ColorOp[0] = SelectArg1; 
			ColorArg1[0] = Texture; 
		}
	}
]]

local is_model_loaded = false
function LoadSnowModel( )
	if is_model_loaded then return end
	is_model_loaded = true
	engineImportTXD( engineLoadTXD(  "files/snow.txd" ), object_id )
	engineReplaceModel( engineLoadDFF(  "files/snow.dff" ), object_id, true )
	engineReplaceCOL( engineLoadCOL(  "files/snow.col" ), object_id )
	engineSetModelLODDistance( object_id, 300 )
end

local elements = { }

function CreateSnow3D( )
	LoadSnowModel( )

	elements.shader = dxCreateShader( shader_code, 0, 0, false, "object" )

	if not elements.shader then return end

	elements.texture = dxCreateTexture( "files/snow.png", "dxt5" )

	dxSetShaderValue( elements.shader, "gTexture", elements.texture )
	engineApplyShaderToWorldTexture( elements.shader, "__snow" )

	local interval = 154
	for x = -3100, 3100, interval do
		for y = -3100, 3100, interval do
			local snow_object = createObject( object_id, x, y, 0, 0, 0, math.random( 360 ) )
			setElementDoubleSided( snow_object, true )
			setElementDimension( snow_object, -1 )
			table.insert( elements, snow_object )
		end
	end
end

function DestroySnow3D( )
	for k, v in pairs( elements ) do
		if isElement( v ) then destroyElement( v ) end
	end
	elements = { }
end

addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, function( changed, values )
	if changed.snow then
		DestroySnow3D( )
		if values.snow and ( values.snow == 2 or values.snow == 3 ) then
			CreateSnow3D( )
		end
	end
end )