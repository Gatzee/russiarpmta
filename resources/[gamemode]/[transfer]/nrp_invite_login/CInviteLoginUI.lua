local ICON_URL = "https://nextrp.ru/assets/images/server-%s.png"

function InitModules( )
    if not _MODULES_LOADED then
        loadstring( exports.interfacer:extend( "Interfacer" ) )( )
        Extend( "ib" )
        Extend( "ShUtils" )
        ibUseRealFonts( true )
        _MODULES_LOADED = true
    end
end

function ShowInviteLoginUI( state, conf )
    if state then
        InitModules( )
        ShowInviteLoginUI( false )

        UI = { }

        UI.black_bg = ibCreateBackground( _, _, true ):ibData( "priority", 100 )
        UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg.png", UI.black_bg ):ibSetRealSize( ):center( )

        local server_number, server_name = unpack( conf )
        ibCreateLabel( 960, 494, 0, 0, utf8.upper( server_name ), UI.bg, 0xffffffff, _, _, "center", "center", ibFonts.regular_40 )

        UI.bg_edit = ibCreateImage( 710, 571, 500, 68, "img/edit_bg.png", UI.bg ):ibData( "alpha", 255 * 0.7 )
        UI.edit = ibCreateWebEdit( UI.bg_edit:ibData( "px" ), UI.bg_edit:ibData( "py" ), UI.bg_edit:width( ), UI.bg_edit:height( ) - 6, "", UI.bg, COLOR_WHITE )
            :ibBatchData( {
                font = "regular_12_300",
                text_align = "center",
                placeholder = "Введите код приглашения",
                placeholder_color = 0xFF909193,
                bg_color = 0,
                max_length = 50,
            } )
            :ibOnFocusChange( function( focused )
                UI.bg_edit:ibAlphaTo( focused and 255 or 255 * 0.7, 100 )
            end )

        UI.error = ibCreateLabel( 960, 668, 0, 0, "", UI.bg, 0xFFff3a3a , _, _, "center", "center", ibFonts.regular_14 )
            :ibData( "alpha", 255 * 0.6 )

        UI.ShowError = function( msg )
            UI.error
                :ibData( "text", msg )
                :ibKillTimers( )
                :ibAlphaTo( 255, 500 )
                :ibTimer( ibAlphaTo, 500, 255 * 0.6, 500 )
        end

        UI.btn_send = ibCreateButton( 851, 694, 0, 0, UI.bg, "img/btn_send.png", "img/btn_send_h.png", "img/btn_send_h.png", _, _, 0xFFCCCCCC )
            :ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                local invite_code = UI.edit:ibData( "text" )
                if not invite_code or #invite_code == 0 then
                    UI.ShowError( "Введите код" )
                    return
                end

                UI.loading = ibLoading( { parent = UI.black_bg } ):ibData( "alpha", 1 ):ibAlphaTo( 255, 300 )
                triggerServerEvent( "CheckInviteCode", resourceRoot, UI.edit:ibData( "text" ) )
            end )

        fetchRemote( ICON_URL:format( server_number ), function ( data, error )
            if not data or error ~= 0 then return end
            if not isElement( UI.bg ) then return end

            UI.server_icon_texture = dxCreateTexture( data, "argb" )
            if not UI.server_icon_texture then return end
            UI.server_icon = ibCreateImage( _SCREEN_X / 2 - 60 / 2, _SCREEN_Y - 112, 60, 60, UI.server_icon_texture, UI.black_bg )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 500 )
        end )

        ibCreateLabel( _SCREEN_X / 2, _SCREEN_Y - 35, 0, 0, "ROLE PLAY", UI.black_bg, ibApplyAlpha( 0xffffffff, 20 ), _, _, "center", "center", ibFonts.bold_16 )

        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil

        showCursor( false )
    end
end
addEvent( "ShowInviteLoginUI", true )
addEventHandler( "ShowInviteLoginUI", root, ShowInviteLoginUI )

addEvent( "CheckInviteCode_callback", true )
addEventHandler( "CheckInviteCode_callback", resourceRoot, function( succes, error )
    if not UI then return end
    if succes then
        UI.btn_send:ibData( "disabled", true )
        ShowInviteRulesUI( true )
    else
        UI.loading:ibAlphaTo( 0 ):ibTimer( destroyElement, 200, 1 )
        UI.ShowError( error or "Неверный код" )
    end
end )

addEvent( "onRegisterStart", true )
addEventHandler( "onRegisterStart", root, function( )
    if not UI then return end
    UI.black_bg:ibAlphaTo( 0, 500 )
    setTimer( ShowInviteLoginUI, 500, 1, false )
end )