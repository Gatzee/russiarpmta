local UI_elements = { }

function ShowLobbyListUI( state )
    if state then
        if isElement(UI_elements.bg) then return end
        ShowLobbyListUI( false )

        triggerServerEvent( "FC:OnPlayerRequestLobbyList", localPlayer )

        -- Общий фон
        UI_elements.black_bg = ibCreateBackground( _, ShowLobbyListUI, true, true )
        
        -- Фон окна
        sx, sy                  = 800, 580
        px, py                  = _SCREEN_X / 2 - sx / 2, _SCREEN_Y / 2 - sy / 2
        UI_elements.bg			= ibCreateImage( px, py + 100, sx, sy, "files/img/lobby/bg.png", UI_elements.black_bg )
        UI_elements.bg:ibData( "alpha", 0 )
        UI_elements.bg:ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 400 )
        -- "Закрыть"
        UI_elements.btn_close = ibCreateButton(	736, 37, 22, 22, UI_elements.bg, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "down" then return end
                ShowLobbyListUI( false )
            end, false )


        COLUMNS = { 
            { "Название лобби", 420, textcolor = 0xfff3e19b }, 
            { "Игроков", 90, 10 },
            { "Ставка", 165, 10, bet = true },
            { "", 48, join = true },
        }
        
        ROWS = 7
        ROW_HEIGHT = 48
    
        ONPX, ONPY = 40, 97

        UI_elements.line = ibCreateImage( ONPX, ONPY, 723, 1, nil, UI_elements.bg, 0x1Effffff )
        UI_elements.line_bottom = ibCreateImage( ONPX, ONPY + ROW_HEIGHT, 723, 1, nil, UI_elements.bg, 0x1Effffff )
    
        local text_font = ibFonts.bold_10
        local npx, npy = ONPX, ONPY
        for i, v in pairs( COLUMNS ) do
            local name, length = v[ 1 ], v[ 2 ]
            local text_offset = v[ 3 ] or 22
            UI_elements[ i .. "_column_name" ] = ibCreateLabel( npx + text_offset, npy, 0, ROW_HEIGHT, name, UI_elements.bg )
            UI_elements[ i .. "_column_name" ]:ibBatchData( { color = 0xFFffffff, align_y = "center", font = text_font })
            UI_elements[ "line_col" .. i ] = ibCreateImage( npx, npy, 1, ROW_HEIGHT * ( ROWS + 1 ), nil, UI_elements.bg, 0x1Effffff )
            npx = npx + length

            if i == #COLUMNS then
                UI_elements[ "line_col" .. i ] = ibCreateImage( npx, npy, 1, ROW_HEIGHT * ( ROWS + 1 ), nil, UI_elements.bg, 0x1Effffff )
            end
        end

        UI_elements.rt_lobbies, UI_elements.sc_lobbies  = ibCreateScrollpane( ONPX, ONPY + ROW_HEIGHT, 724, ROWS * ROW_HEIGHT, UI_elements.bg, { scroll_px = 13 } )

        UI_elements.btn_create_lobby = ibCreateButton( 314, 510, 172, 42, UI_elements.bg, "files/img/lobby/btn_create.png", "files/img/lobby/btn_create.png", "files/img/lobby/btn_create.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "color_disabled", 0x55FFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if CURRENT_LOBBY then
                    localPlayer:ShowError( "Ты должен покинуть лобби чтобы создать новое!" )
                    return
                end
                ShowLobbyCreateUI( true )
            end, false )


        showCursor( true )
    else
        triggerServerEvent( "FC:OnLeaveLobbyWaitingRequest", localPlayer )
        DestroyTableElements( UI_elements )
        UI_elements = { }

        showCursor( false )
    end
end

function onPlayerRequestLobbyList_callback_handler( list, current_lobby )
    if not isElement( UI_elements.rt_lobbies ) then return end

    if UI_elements.lobbies_list then
        for i, v in pairs( UI_elements.lobbies_list ) do
            if isTimer( v ) then killTimer( v ) end
            if isElement( v ) then destroyElement( v ) end
        end
    end
    UI_elements.lobbies_list = { }
    
    local list_organized = { }
    for i = 1, math.max( ROWS, #list ) do
        local v = list[ i ]
        if v then
            local readable_conf = {
                v.name, v.players .. "/" .. v.max_players, v.bet,
                id = v.id, bet_hard = v.bet_hard,
            }
            table.insert( list_organized, readable_conf )
        else
            table.insert( list_organized, { } )
        end
    end

    local npy = 0
    local row_black = true
    for i, v in ipairs( list_organized ) do
        UI_elements.lobbies_list[ i .. "_row_bg" ] = ibCreateImage( 0, npy, 0, ROW_HEIGHT, nil, UI_elements.rt_lobbies, row_black and 0 or 0 )

        local npx = 0
        local text_font = ibFonts.bold_10

        for n, k in pairs( COLUMNS ) do
            local text = v[ n ]

            local text_offset = k[ 3 ] or 22
            local length = k[ 2 ]

            if v[ 1 ] then
                if k.join then 
                    local is_btn_leave = current_lobby and current_lobby == v.id
                    local texture = is_btn_leave and "files/img/lobby/icon_exit.png" or "files/img/lobby/icon_enter.png"
                    UI_elements.lobbies_list[ i .. "_btn_join" ] = ibCreateButton(  npx, npy, 48, 48, UI_elements.rt_lobbies, texture, texture, texture, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            if is_btn_leave then
                                triggerServerEvent( "FC:OnLeaveLobbyWaitingRequest", localPlayer )
                            else
                                triggerServerEvent( "FC:OnJoinLobbyRequest", localPlayer, v.id )
                            end
                        end, false )
                else
                    UI_elements.lobbies_list[ i .. "_" .. n .. "_column_text" ] = ibCreateLabel( npx + text_offset, npy, 0, ROW_HEIGHT, text, UI_elements.rt_lobbies )
                    UI_elements.lobbies_list[ i .. "_" .. n .. "_column_text" ]:ibBatchData( { color = k.textcolor or 0xffffffff, align_y = "center", font = text_font } )
                    if k.bet then
                        local icon_position = npx + text_offset + dxGetTextWidth( text, 1, text_font ) + 8
                        local isx, isy = 16, 14

                        local texture = v.bet_hard and "files/img/lobby/icon_hard.png" or "files/img/lobby/icon_soft.png"
                        UI_elements.lobbies_list[ i .. "_bet_icon" ] = ibCreateImage( icon_position, npy + ROW_HEIGHT / 2 - isy / 2, isx, isy, texture, UI_elements.rt_lobbies )
                    end
                end
            end

            npx = npx + length
        end

        if current_lobby and current_lobby ~= v.id then
            UI_elements.lobbies_list[ i .. "_row_hide" ] = ibCreateImage( 0, npy, 723, ROW_HEIGHT, nil, UI_elements.rt_lobbies, 0xaa000000 )
        end

        npy = npy + ROW_HEIGHT
        row_black = not row_black

        UI_elements.lobbies_list[ i .. "_row_line" ] = ibCreateImage( 0, npy - 1, 723, 1, nil, UI_elements.rt_lobbies, 0x1Effffff )
    end

    CURRENT_LOBBY = current_lobby
    
    UI_elements.btn_create_lobby:ibData( "disabled", not not CURRENT_LOBBY )
    UI_elements.rt_lobbies:AdaptHeightToContents( )

    StartRequestAnotherListTimer()
end
addEvent( "FC:onPlayerRequestLobbyList_callback", true )
addEventHandler( "FC:onPlayerRequestLobbyList_callback", root, onPlayerRequestLobbyList_callback_handler )

function StartRequestAnotherListTimer()
    StopRequestAnotherListTimer()
    UI_elements.request_timer = setTimer( RequestAnotherList, 1000, 1 )
end

function StopRequestAnotherListTimer()
    if isTimer( UI_elements.request_timer ) then killTimer( UI_elements.request_timer ) end
end

function RequestAnotherList()
    if LOBBY_CREATION_OPEN then
        StartRequestAnotherListTimer()
    else
        triggerServerEvent( "FC:OnPlayerRequestLobbyList", localPlayer )
    end
end
--ShowLobbyListUI( true )