local SHADER, TEXTURE

local SHADER_CODE = [[
	texture gTexture;

	technique TexReplace
	{
		pass P0
		{
			Texture[0] = gTexture;
		}
	}
]]

function onPlayerCinemaEnter_copyrightsHandler( )
    onPlayerCinemaLeave_copyrightsHandler( )
    
    TEXTURE = dxCreateTexture( "img/copyrights.jpg" )
    SHADER  = dxCreateShader( SHADER_CODE, 1, 50 )
    
    dxSetShaderValue( SHADER, "gTexture", TEXTURE )
    engineApplyShaderToWorldTexture( SHADER, "k_teatr25" )
end
addEvent( "onPlayerCinemaEnter", true )
addEventHandler( "onPlayerCinemaEnter", root, onPlayerCinemaEnter_copyrightsHandler )

function onPlayerCinemaLeave_copyrightsHandler( )
    DestroyTableElements( { SHADER, TEXTURE } )
    SHADER, TEXTURE = nil, nil
end
addEvent( "onPlayerCinemaLeave", true )
addEventHandler( "onPlayerCinemaLeave", root, onPlayerCinemaLeave_copyrightsHandler )