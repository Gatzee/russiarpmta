Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "CUI" )
Extend( "ib" )

ibUseRealFonts( true )

_DATA = nil

function onPlayerRequestLobbyList_callback_handler( data )
    if not _DATA then return end
    _DATA.lobby_data,  _DATA.current_lobby = data.lobby_data, data.current_lobby
    RefreshLobbyTopUI()
end
addEvent( "onPlayerRequestLobbyList_callback", true )
addEventHandler( "onPlayerRequestLobbyList_callback", resourceRoot, onPlayerRequestLobbyList_callback_handler )

function onClientShowUICasinoGame_handler( state, data )
    _DATA = data
    ShowCasinoGameLobbyMenuUI( state )
end
addEvent( "onClientShowUICasinoGame", true )
addEventHandler( "onClientShowUICasinoGame", root, onClientShowUICasinoGame_handler )


function ShowLeaderBoards( state, data )
    if state then
        ShowLeaderBoards( false )
        
        local shader_raw = [[
            texture tTexture;
        
            technique tech
            {
                pass p0
                {
                    Texture[0] = tTexture;
                }
            }
        ]]

        SHADER_TV = dxCreateShader( shader_raw )
        if not SHADER_TV then return end

        TEXTURE_RT = dxCreateRenderTarget( 1024, 512 )
        if not TEXTURE_RT then return end
        
        dxSetRenderTarget( TEXTURE_RT, true )
            dxDrawRectangle( 0, 0, 1024, 512, 0xFF111111 )  

        dxSetRenderTarget() 
        
        dxSetShaderValue( SHADER_TV, "tTexture", TEXTURE_RT )
        for i = 1, 7 do
            engineApplyShaderToWorldTexture( SHADER_TV, "mcs_tv" .. i )
        end
    elseif isElement( SHADER_TV ) then
        destroyElement( SHADER_TV )
        destroyElement( TEXTURE_RT )
        TEXTURE_RT = nil
        SHADER_TV = nil
    end
end
addEvent( "onClientShowLeaderBoards", true )
addEventHandler( "onClientShowLeaderBoards", root, ShowLeaderBoards )

function onClientPlayerCasinoEnter_handler( casino_id )
    if casino_id ~= CASINO_MOSCOW then return end

    ShowLeaderBoards( true )
end
addEvent( "onClientPlayerCasinoEnter", true )
addEventHandler( "onClientPlayerCasinoEnter", localPlayer, onClientPlayerCasinoEnter_handler )

function onClientPlayerCasinoExit_handler( casino_id )
    if casino_id ~= CASINO_MOSCOW then return end

    ShowLeaderBoards( false )
end
addEvent( "onClientPlayerCasinoExit", true )
addEventHandler( "onClientPlayerCasinoExit", localPlayer, onClientPlayerCasinoExit_handler )