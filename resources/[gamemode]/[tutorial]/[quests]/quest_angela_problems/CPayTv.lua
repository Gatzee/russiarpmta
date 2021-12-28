local TEXTURE_RT = nil
local SHADER_TV = nil

function CreateTvPayLeaders() 
    SHADER_TV = dxCreateShader( [[
        texture tTexture;
    
        technique tech
        {
            pass p0
            {
                Texture[0] = tTexture;
            }
        }
    ]] )
    if not SHADER_TV then return end
    TEXTURE_RT = dxCreateRenderTarget( 1024, 512 )

    dxSetRenderTarget( TEXTURE_RT, true )
    dxDrawImage( 0, 245, 1024, 256, ":nrp_strip_club/files/img/bg_tv.png")  

    dxSetRenderTarget() 
    dxSetShaderValue( SHADER_TV, "tTexture", TEXTURE_RT )
    engineApplyShaderToWorldTexture( SHADER_TV, "white_tv" )
end


function DestroyTvPayLeaders()
    if isElement( SHADER ) then
        SHADER_TV:destroy()
        if TEXTURE_RT then TEXTURE_RT:destroy() end
        SHADER_TV = nil
        TEXTURE_RT = nil
    end
end