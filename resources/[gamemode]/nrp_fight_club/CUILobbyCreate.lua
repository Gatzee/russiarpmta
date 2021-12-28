local UI_elements = { }

function ShowLobbyCreateUI( state )
    if state then
        ShowLobbyCreateUI( false )

        LOBBY_CREATION_OPEN = true

        -- Общий фон
        UI_elements.black_bg = ibCreateBackground( _, ShowLobbyCreateUI, true, true )
        
        -- Фон окна
        sx, sy                  = 520, 430
        px, py                  = _SCREEN_X / 2 - sx / 2, _SCREEN_Y / 2 - sy / 2
        UI_elements.bg			= ibCreateImage( px, py - 100, sx, sy, "files/img/lobby/bg_confirmation.png", UI_elements.black_bg ):ibData( "alpha", 0 )
        UI_elements.bg:ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 400 )
        
        -- "Закрыть"
        UI_elements.btn_close = ibCreateButton(	467, 26, 22, 22, UI_elements.bg, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080)
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "down" then return end
                ShowLobbyCreateUI( false )
            end, false )

        -- Имя
        UI_elements.edit_name = ibCreateEdit( 40, 105, 445, 38, "", UI_elements.bg, 0xffffffff, 0x00000000, 0xffffffff )
        UI_elements.edit_name:ibBatchData( { font = ibFonts.bold_12, max_length = 20 } )

        UI_elements.bet_selector = ibCreateSelector( {
            values = {
                { { value = 500, sx = 90 }, { value = 1000, sx = 101 }, { value = 5000, sx = 101 }, { value = 10000, sx = 112 }, },
                { { value = 25000, sx = 112 }, },
            },
            sx = 126, sy = 44,
            px = 35, py = 200,
            icon = { 
                texture = "files/img/lobby/icon_soft.png",
                sx = 16, sy = 14,
                gap = 5,
                direction = "right",
            },
            parent = UI_elements.bg,
            font = ibFonts.bold_12,
        } )

        --Создать
        UI_elements.btn_create = ibCreateButton(	196, 336, 128, 42, UI_elements.bg, "files/img/lobby/btn_create_confirm.png", "files/img/lobby/btn_create_confirm.png", "files/img/lobby/btn_create_confirm.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                local name = UI_elements.edit_name:ibData( "text" )
                local name_len = utf8.len( name )
                if name_len > 30 then
                    localPlayer:ShowError( "Слишком длинное название!" )
                    return
                elseif name_len < 5 then
                    localPlayer:ShowError( "Слишком короткое название!" )
                    return
                end

                local bet = UI_elements.bet_selector:getSelectedItem()
                
                if confirmation then confirmation:destroy() end

                confirmation = ibConfirm( {
                    title = "СОЗДАНИЕ ЛОББИ", 
                    text = "Ты действительно хочешь создать новое лобби\n`" .. name .. "`?",
                    black_bg = 0xaa202025,
                    fn = function( self ) 
                        self:destroy()
                        ShowLobbyCreateUI( false )
                        local conf = {
                            name                    = name,
                            players_count_required  = 2,
                            cost                    = bet,
                            host                    = localPlayer,
                        }
                        triggerServerEvent( "FC:OnCreateLobbyRequest", resourceRoot, localPlayer, conf )
                    
                        StopRequestAnotherListTimer( )
                        RequestAnotherList( )
                        StartRequestAnotherListTimer( )
                    end,
                    escape_close = true,
                } )
            
            end )
    else
        if isElement(UI_elements and UI_elements.black_bg) then
			destroyElement( UI_elements.black_bg )
		end
        UI_elements = { }

        LOBBY_CREATION_OPEN = nil
    end
end
addEvent( "ShowLobbyCreateUI", true )
addEventHandler( "ShowLobbyCreateUI", root, ShowLobbyCreateUI )