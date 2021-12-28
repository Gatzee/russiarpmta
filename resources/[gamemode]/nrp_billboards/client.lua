local CONST_BILLBOARD_MODEL = 713

local TEXTURE_RT = nil

function onStart()
	local col = engineLoadCOL( "models/billboard.col" )
	local txd = engineLoadTXD( "models/billboard.txd" )
	local dff = engineLoadDFF( "models/billboard.dff" )
	engineReplaceCOL( col, CONST_BILLBOARD_MODEL )
	engineImportTXD( txd, CONST_BILLBOARD_MODEL )
	engineReplaceModel( dff, CONST_BILLBOARD_MODEL )
	
	local SHADER_RAW = [[
		texture tTexture;
	
		technique tech
		{
			pass p0
			{
				Texture[0] = tTexture;
			}
		}
	]]
	local shader = dxCreateShader( SHADER_RAW, 0, 150, false, "object" )
	TEXTURE_RT = dxCreateRenderTarget( 1280, 720 )
	ReloadTextureRt()
	dxSetShaderValue( shader, "tTexture", TEXTURE_RT )
	
	
	local OBJECT_POSITIONS = {
		{ x = 1893.72, y = 2428.38, z = 12.15, rz = 100 },
		{ x = 1690.33, y = 2791.56, z = 18.7, rz = 83 },
		{ x = -1075.189, y = 1874.682, z = 7.3, rz = 53 },
		{ x = -315.055, y = 2822.501, z = 14.25, rz = 93 },
	}

	for k, v in pairs( OBJECT_POSITIONS ) do
		local object = createObject( CONST_BILLBOARD_MODEL, v.x, v.y, v.z, 0, 0, v.rz )
		engineApplyShaderToWorldTexture( shader, "baner1", object )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onStart )

function ReloadTextureRt()
	dxSetRenderTarget( TEXTURE_RT, true )
	dxDrawImage( 0, 0, 1280, 720, "img/nextrp.png" )
	dxSetRenderTarget( )
end

function onClientRestore_handler( is_clear_rt )
    if not is_clear_rt then return end

	ReloadTextureRt()
end
addEventHandler( "onClientRestore", root, onClientRestore_handler )