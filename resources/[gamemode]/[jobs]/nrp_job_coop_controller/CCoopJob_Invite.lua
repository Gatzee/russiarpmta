
function ShowCoopJobInviteUI( state )
    local UI_elements = GetMainWindowElements( )
    if not UI_elements or not isElement( UI_elements.bg ) then return end

    local sx, sy = UI_elements.bg:width(), UI_elements.bg:height()
    local px, py = UI_elements.bg:ibGetBeforeX(), UI_elements.bg:ibGetBeforeY()

    if state then
        if isElement( UI_elements.invite_bg_rt ) then return end
        
        ibInterfaceSound()

        UI_elements.invite_bg_rt = ibCreateRenderTarget( 0, 92, sx, sy - 92, UI_elements.bg ):ibData( "priority", 1000 )
        UI_elements.invite_bg = ibCreateImage( 0, -sx, sx, sy - 92, _, UI_elements.invite_bg_rt, 0xF21F2934 )

        ibCreateLabel( 0, 173, sx, 0, "Приглашение напарника", UI_elements.invite_bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.bold_20 )

        local edit_bg = ibCreateImage( 221, 228, 583, 66, "img/invite_bg.png", UI_elements.invite_bg ):ibData("alpha", 178 )
        local edit_label = ibCreateLabel( 0, 0, 583, 66, "Введите имя игрока", edit_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_16 ):ibData("alpha", 102 )

		local edit = ibCreateEdit( 30, 17, 523, 32, "", edit_bg, COLOR_WHITE, 0, COLOR_WHITE )
        :ibData( "font", ibFonts.bold_16 )
        :ibData( "alpha", 102 )
        :ibOnDataChange( function( key, value )
            if key == "focused" and source:ibData( "text" ) == "" then
                edit_label:ibData( "alpha", value and 0 or 102 )
                edit_bg:ibData( "alpha", value and 255 or 178 )
            end
        end )

        ibCreateButton( 430, 352, 166, 49, UI_elements.invite_bg, "img/invite.png", "img/invite.png", "img/invite.png", ibApplyAlpha( 0xFFFFFFFF, 150 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 150 ) )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick( )
            
            local name = edit:ibData( "text" )
            if #name < 1 then localPlayer:ShowError( "Введите имя" ) return end

            for k, v in ipairs( getElementsByType( "player" ) ) do
                if v:GetNickName( ) == name then
                    triggerServerEvent( "onServerSendInvitePlayer", resourceRoot, v )
                    return
                end
            end

            localPlayer:ShowError( "Пользователь не найден" )
        end )

        ibCreateButton( 458, 604, 108, 42, UI_elements.invite_bg, "img/hide.png", "img/hide.png", "img/hide.png", ibApplyAlpha( 0xFFFFFFFF, 191 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 191 ) )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end

            ShowCoopJobInviteUI( false )
            ibClick( )
        end )

        UI_elements.invite_bg:ibMoveTo( 0, 0, 300 )
        ibOverlaySound()
    elseif isElement( UI_elements.invite_bg ) then
        UI_elements.invite_bg
        :ibMoveTo( 0, -sy, 300 )
        :ibTimer( function()
            destroyElement( UI_elements.invite_bg_rt )
        end, 300, 1 )
        ibOverlaySound()
    end
end


function onClientShowCoopJobSuccessInvite_handler( success_invite )
    if success_invite then
        local UI_elements = GetMainWindowElements( )
        if not UI_elements or not isElement( UI_elements.bg ) then return end

        local sx = UI_elements.bg:width()
        UI_elements.success_invite = ibCreateLabel( 0, 312, sx, 0, "Приглашение отправлено", UI_elements.invite_bg, 0xFFFFDE96, 1, 1, "center", "top", ibFonts.regular_14 )
    end
end
addEvent( "onClientShowCoopJobSuccessInvite", true )
addEventHandler( "onClientShowCoopJobSuccessInvite", root, onClientShowCoopJobSuccessInvite_handler )