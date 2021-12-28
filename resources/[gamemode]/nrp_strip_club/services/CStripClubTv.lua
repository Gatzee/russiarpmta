TEXTURE_RT = nil
SHADER_TV = nil

function CreateTvPayLeaders( pay_leaders ) 
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
    RefresTextureTvLeaders( pay_leaders )
end

function RefresTextureTvLeaders( pay_leaders )
    if not isElement( TEXTURE_RT ) then return end
    dxSetRenderTarget( TEXTURE_RT, true )
    dxDrawImage( 0, 245, 1024, 256, "files/img/bg_tv.png")  
    
    local py = 275
    for k, v in ipairs( pay_leaders or {} ) do
        dxDrawText( k .. ". " .. v.nickname .. " " .. v.pay_strip_money .. " рублей", 30, py, 0, 0, 0xFFFFFFFF, 1.45, 0.5, ibFonts.regular_24 )
        py = py + 30
    end

    dxSetRenderTarget() 
    dxSetShaderValue( SHADER_TV, "tTexture", TEXTURE_RT )
    engineApplyShaderToWorldTexture( SHADER_TV, "white_tv" )
end

function DestroyTvPayLeaders()
    if isElement( SHADER ) then
        SHADER_TV:destroy()
        SHADER_TV = nil
        if TEXTURE_RT then
            TEXTURE_RT:destroy()
        end
        TEXTURE_RT = nil
    end
end

function onClientRefreshPayTvLeaders_handler( pay_leaders )
    RefresTextureTvLeaders( pay_leaders )
end
addEvent( "onClientRefreshPayTvLeaders", true )
addEventHandler( "onClientRefreshPayTvLeaders", resourceRoot, onClientRefreshPayTvLeaders_handler )