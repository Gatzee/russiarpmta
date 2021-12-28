CACHE_DURATION = 120

function ShowDonateUI( state, conf )
    if state then
        ibAutoclose( )
        ShowDonateUI( false )
        UI = { }
        CONF = conf or { }

        ibWindowSound()

        UI.black_bg = ibCreateBackground( 0xaa000000, ShowDonateUI, true, true )
            :ibData( "alpha", 0 )
            :ibAlphaTo( 255, 500 )
        
        UI.bg_texture = dxCreateTexture( "img/bg.png" )
        local sx, sy = dxGetMaterialSize( UI.bg_texture )

        local x, y = guiGetScreenSize( )
        local px, py = x / 2 - sx / 2, y / 2 - sy / 2

        UI.bg_image = ibCreateImage( px, py + 100, sx, sy, "img/bg.png", UI.black_bg )
        :ibMoveTo( px, py, 500 )
        
        UI.bg = ibCreateRenderTarget( 0, 0, sx, sy, UI.bg_image ):ibData( "modify_content_alpha", true )

        -- Создаем заголовок окна
        CreateHeader( UI.bg )

        -- Навигация по вкладкам
        CreateNavbar( UI.bg )

        -- Весь контент
        CreateAllContent( UI.bg )

        -- Переключение на дефолтную вкладку или указанную в конфиге
        SwitchNavbar( conf.tab or 1 )

        LAST_CHAT = isChatVisible( )
        showCursor( true )
        UI.bg_texture:destroy( )

    else
        if isElement( UI and UI.black_bg ) then
            destroyElement( UI.black_bg )
        end
        UI = nil

        if LAST_CHAT ~= nil then
            LAST_CHAT = nil
        end

        if not UI_limited then
            showCursor( false )
        end
    end

    localPlayer:setData( "f4_is_active", state, false )
end

function IsDonateOpen( )
    return UI and next( UI ) ~= nil
end

bindKey( "F4", "down", function( )
    if localPlayer:IsInGame( ) then
        if UI then
            if UI.black_bg:ibData( "can_destroy" ) == false then
                return false
            end

            ShowDonateUI( false )
            SendElasticGameEvent( "f4_window_close" )
        else
			SendElasticGameEvent( "f4r_f4_key_press" )
            triggerServerEvent( "onPlayerRequestDonateMenu", resourceRoot, nil )
        end
    end
end )

ibAttachAutoclose( function( )
    if IsDonateOpen( ) then
        ShowDonateUI( false )
        SendElasticGameEvent( "f4_window_close" )
    end
end )