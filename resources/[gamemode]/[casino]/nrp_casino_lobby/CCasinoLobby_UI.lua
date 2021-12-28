
local REFRESH_LOBBY_TIME_MS = 2500

local UI_elements = nil
local SWITCH_MENU_ANIM_DURATION = 200

local MENU_DATA = nil

enum "eLobbyMenu" {
    "LOBBY_MENU_MAIN",
    "LOBBY_MENU_LOBBY",
    "LOBBY_MENU_LEADERBOARD",
    "LOBBY_MENU_RULES",
}

local HARD_CURRENCY_GAMES = 
{
    [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = true,
}

function ShowCasinoGameLobbyMenuUI( state )
    if state then
        if isElement( UI_elements and UI_elements.black_bg ) then return end

        ibInterfaceSound()

        UI_elements = {}
        UI_elements.lobby_name = ""

        UI_elements.black_bg = ibCreateBackground( 0x00000000, OnTryLeftGame, _, true ):ibData( "alpha", 0 )
        UI_elements.bg_menu = ibCreateImage( 0, 0, 0, 0, "img/lobby_menu/bg_lobby.png", UI_elements.black_bg ):ibSetRealSize():center()

        local offset_bg = 100
        local py = UI_elements.bg_menu:ibData( "py" )
        UI_elements.bg_menu:ibData( "py", py - offset_bg )
        UI_elements.bg_menu:ibMoveTo( _, py, 250 )
        UI_elements.black_bg:ibAlphaTo( 255, 250 )
        
        UI_elements.rt_menu = ibCreateRenderTarget( 0, 80, 1024, 689, UI_elements.bg_menu )
        
        ibCreateButton(	972, 29, 24, 24, UI_elements.bg_menu, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		    :ibOnClick( function( key, state )
		    	if key ~= "left" or state ~= "up" then return end

		    	ibClick( )
		    	OnTryLeftGame( false )
            end, false )
        
        UI_elements.logo = ibCreateImage( 30, 0, 0, 0, "img/icons/icon_game_" .. _DATA.game_id .. ".png", UI_elements.bg_menu ):ibSetRealSize()
        UI_elements.logo:ibData( "py", (79 - UI_elements.logo:height()) / 2 )

        ibCreateLabel( UI_elements.logo:ibGetAfterX() + 16, 0, 0, 79, CASINO_GAMES_NAMES[ _DATA.game_id ], UI_elements.bg_menu, _, _, _, "left", "center", ibFonts.bold_20 )
        UI_elements.menu = {}

        local px = 30
        for k, v in ipairs( MENU_DATA ) do
            if not v.condition or v.condition() then
                local name_len = dxGetTextWidth( v.name, 1, ibFonts.bold_16 )
                UI_elements.menu[ k ] = ibCreateArea( px, 30, name_len, 32, UI_elements.rt_menu )
                UI_elements.menu[ k .. "lbl" ] = ibCreateLabel( 0, 0, 0, 0, v.name, UI_elements.menu[ k ], k == LOBBY_MENU_MAIN and 0xFFFFFFFF or 0xFFC1C6CC, _, _, "left", "top", ibFonts.bold_16 ):ibData( "disabled", true )
                
                UI_elements.menu[ k ]
                :ibOnHover( function( )
                    UI_elements.menu[ k .. "lbl" ]:ibData( "color", 0xFFFFFFFF )
                end )
                :ibOnLeave( function( )
                    if UI_elements.menu_id ~= k then UI_elements.menu[ k .. "lbl" ]:ibData( "color", 0xFFC1C6CC ) end
                end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "down" then return end
                    ibClick( )
                    if UI_elements.menu_id ~= k then 
                        SwitchCasinoMenu( k ) 
                    end
                end )

                if k == 1 then
                    UI_elements.menu_id = k
                    UI_elements.menu_area = v.func()
                    UI_elements.menu_caret = ibCreateImage( 30, 59, name_len, 4, _, UI_elements.rt_menu, 0xFFFF965D )
                end

                px = px + name_len + 30
            end
        end

        UI_elements.bg_menu:ibTimer( function()
            if not LOBBY_CREATION_OPEN then 
                triggerServerEvent( "onServerPlayerRequestLobbyList", resourceRoot, _DATA.casino_id, _DATA.game_id )
            end
        end, REFRESH_LOBBY_TIME_MS, 0 )

        showCursor( true )
    elseif isElement( UI_elements and UI_elements.black_bg ) then
        triggerServerEvent( "onLeaveLobbyWaitingRequest", resourceRoot )
        
        destroyElement( UI_elements.black_bg )
        if UI_elements.confirmation then UI_elements.confirmation:destroy() end
        ShowCreateLobbyUI( false )

        UI_elements = nil
        _DATA = nil
        
        showCursor( false )
    end
end

function SwitchCasinoMenu( menu_id )
    local ticks = getTickCount()
    if ticks - (UI_elements.start_anim_ticks or 0) < SWITCH_MENU_ANIM_DURATION then return end
    UI_elements.start_anim_ticks = ticks

    local name_len = dxGetTextWidth( MENU_DATA[ menu_id ].name, 1, ibFonts.bold_16 )
    if UI_elements.is_anim then return end
    for k, v in ipairs( MENU_DATA ) do
        if isElement( UI_elements.menu[ k .. "lbl" ] ) then 
            UI_elements.menu[ k .. "lbl" ]:ibData( "color", menu_id ~= k and 0xFFC1C6CC or 0xFFFFFFFF ) 
        end
        
        if menu_id == k and isElement( UI_elements.menu[ k ] ) then
            UI_elements.menu_caret:ibResizeTo( name_len, _, SWITCH_MENU_ANIM_DURATION ):ibMoveTo( UI_elements.menu[ k ]:ibData( "px" ), _, SWITCH_MENU_ANIM_DURATION )
        end
    end
    
    local offset_value = 100
    local offset = UI_elements.menu_id > menu_id and -offset_value or offset_value
    
    local new_menu_area = MENU_DATA[ menu_id ].func():ibBatchData( { alpha = 0, priority = UI_elements.menu_area:ibData( "priority" ) + 1, px = offset } )
    UI_elements.menu_area:ibMoveTo( offset * -1, _, SWITCH_MENU_ANIM_DURATION ):ibAlphaTo( 0, SWITCH_MENU_ANIM_DURATION )
    
    new_menu_area:ibMoveTo( 0, _, SWITCH_MENU_ANIM_DURATION ):ibAlphaTo( 255, SWITCH_MENU_ANIM_DURATION )
    
    UI_elements.rt_menu:ibTimer( function()
        destroyElement( UI_elements.menu_area )
        UI_elements.menu_area = new_menu_area
        UI_elements.is_anim = false
    end, SWITCH_MENU_ANIM_DURATION, 1 )

    UI_elements.menu_id = menu_id
    UI_elements.is_anim = true
end

function ShowMainLobbyMenu()
    local menu_area = ibCreateImage( 0, 63, 1024, 626, "img/lobby_menu/lobby_main.png", UI_elements.rt_menu )
    UI_elements.last_lobby_name = nil

    UI_elements.dummy_lobby_name = ibCreateLabel( 73, 21, 240, 30, "Поиск лобби", menu_area, 0xFFAAAAAA, _, _, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
    UI_elements.edf_lobby_name = ibCreateEdit( 73, 22, 808, 30, "", menu_area, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF )
        :ibData( "font", ibFonts.regular_14 )
        :ibOnClick( function()
            if isElement( UI_elements.dummy_lobby_name  ) then destroyElement( UI_elements.dummy_lobby_name  ) end
        end )
        :ibOnDataChange( function( key, value )
            if key ~= "text" then return end
            UI_elements.temp_lobby_name = value
        end )
    
    ibCreateButton(	882, 73, 112, 11, menu_area, "img/lobby_menu/btn_lobby_list.png", "img/lobby_menu/btn_lobby_list_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 ):ibData( "priority", 100 )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "up" then return end
            ibClick( )
            SwitchCasinoMenu( LOBBY_MENU_LOBBY )
        end, false )
    
    
    ibCreateButton(	901, 20, 93, 31, menu_area, "img/lobby_menu/btn_find.png", "img/lobby_menu/btn_find_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "up" then return end
            ibClick( )
            UI_elements.lobby_name = UI_elements.temp_lobby_name
            RefreshTopLobbyUI( menu_area )
        end, false )
        
    UI_elements.min_lobby_rows = 4
    UI_elements.max_lobby_rows = 4
    RefreshTopLobbyUI( menu_area )

    ibCreateButton(	839, 324, 155, 14, menu_area, "img/lobby_menu/btn_full_leaderboard.png", "img/lobby_menu/btn_full_leaderboard_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 ):ibData( "priority", 100 )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "up" then return end
            ibClick( )
            SwitchCasinoMenu( LOBBY_MENU_LEADERBOARD )
        end, false )

    UI_elements.scrollpane_top, UI_elements.scrollbar_top = ibCreateScrollpane( 0, 384, 1024, 152, menu_area, { scroll_px = -20 } )
    UI_elements.scrollbar_top:ibSetStyle( "slim_nobg" ) 
    
    local py = 0
    local source_name = localPlayer:GetNickName()
    local currency = HARD_CURRENCY_GAMES[ _DATA.game_id ] and "hard" or "soft"
    for i = 1, 4 do
        local container = ibCreateImage( 0, py, 1024, 38, nil, UI_elements.scrollpane_top, (_DATA.top_data[ i ] and source_name == _DATA.top_data[ i ][ 2 ]) and 0xFF314050 or (i % 2 == 0 and 0x00000000 or 0x60314050) )
        ibCreateLabel( 30, 0, 36, 38, _DATA.top_data[ i ] and _DATA.top_data[ i ][ 1 ] or "-", container, _, _, _, "center", "center", ibFonts.bold_14 )
        ibCreateLabel( 138, 0, 0, 38, _DATA.top_data[ i ] and _DATA.top_data[ i ][ 2 ] or "-", container, _, _, _, "left", "center", ibFonts.bold_14 )
        local summ_lbl = ibCreateLabel( 849, 0, 0, 38, _DATA.top_data[ i ] and format_price( _DATA.top_data[ i ][ 3 ] ) or "-", container, _, _, _, "left", "center", ibFonts.bold_14 )
        if _DATA.top_data[ i ] then 
            ibCreateImage( 849 + summ_lbl:width() + 7, 10, 23, 19, "img/lobby_menu/icon_" .. currency .. ".png", container ) 
        end
        py = py + 38
    end

    UI_elements.scrollpane_top:AdaptHeightToContents()
    UI_elements.scrollbar_top:UpdateScrollbarVisibility( UI_elements.scrollpane_top )

    CreateLobbyInfo( menu_area )

    return menu_area
end

function RefreshTopLobbyUI( parent )
    if UI_elements.last_lobby_name == UI_elements.lobby_name and UI_elements.lobby_name ~= "" then return end
    UI_elements.last_lobby_name = UI_elements.lobby_name 

    if isElement( UI_elements.scrollpane_lobby_list ) then
        destroyElement( UI_elements.scrollpane_lobby_list )
        destroyElement( UI_elements.scrollbar_lobby_list )
    end

    local target_lobby_list = {}
    for k, v in pairs( _DATA.lobby_data ) do
        if not UI_elements.lobby_name or UI_elements.lobby_name == "" or string.find( v.name, UI_elements.lobby_name ) then
            table.insert( target_lobby_list, v )
            if #target_lobby_list == UI_elements.max_lobby_rows then break end
        end
    end

    local py, sy = (UI_elements.min_lobby_rows == 4 and 136 or 121), (UI_elements.min_lobby_rows == 4 and 148 or 415)
    UI_elements.scrollpane_lobby_list, UI_elements.scrollbar_lobby_list = ibCreateScrollpane( 0, py, 1024, sy, parent or UI_elements.menu_area, { scroll_px = -20 } )
    UI_elements.scrollbar_lobby_list:ibSetStyle( "slim_nobg" ) 
    
    local py = 0
    local sy = (UI_elements.min_lobby_rows == 4 and 37 or 40)
    local currency = HARD_CURRENCY_GAMES[ _DATA.game_id ] and "hard" or "soft"
    for i = 1, math.max( UI_elements.min_lobby_rows or 4, #target_lobby_list ) do
        if target_lobby_list[ i ] or i <= UI_elements.min_lobby_rows then
            local container = ibCreateImage( 0, py, 1024, sy, nil, UI_elements.scrollpane_lobby_list, (target_lobby_list[ i ] and localPlayer == target_lobby_list[ i ].owner) and 0xFF314050 or (i % 2 == 0 and 0x00000000 or 0x60314050) )
            ibCreateLabel( 30, 0, 36, sy, target_lobby_list[ i ] and target_lobby_list[ i ].name or "-", container, _, _, _, "left", "center", ibFonts.bold_14 )
            local count_players_lbl = ibCreateLabel( 354, 0, 0, sy, target_lobby_list[ i ] and (target_lobby_list[ i ].players) or "-", container, _, _, _, "left", "center", ibFonts.bold_16 )
            if target_lobby_list[ i ] then
                ibCreateLabel( count_players_lbl:ibGetAfterX() + 1, 0, 0, sy, target_lobby_list[ i ] and ("/" .. target_lobby_list[ i ].max_players) or "-", container, 0xFFB0B7BF, _, _, "left", "center", ibFonts.bold_14 )
            end
            local rate_lbl = ibCreateLabel( 584, 0, 0, sy, target_lobby_list[ i ] and format_price( target_lobby_list[ i ].bet ) or "-", container, _, _, _, "left", "center", ibFonts.bold_14 )
            if target_lobby_list[ i ] then 
                ibCreateImage( rate_lbl:ibGetAfterX() + 7, 10, 23, 19, "img/lobby_menu/icon_" .. currency .. ".png", container ) 
            end

            local wait_lobby = target_lobby_list[ i ] and _DATA.current_lobby == target_lobby_list[ i ].id
            local available = target_lobby_list[ i ] and (target_lobby_list[ i ].players < target_lobby_list[ i ].max_players and not _DATA.current_lobby) or false
            
            local status_lobby_text  = target_lobby_list[ i ] and (wait_lobby and "Ожидание" or available and "Свободно" or "Недоступно") or "-"
            local status_lobby_color = target_lobby_list[ i ] and (wait_lobby and 0xFFFFE900 or available and 0xFF1FD064 or 0xFFFF5959) or 0xFFFFFFFF
            ibCreateLabel( 834, 0, 0, sy, status_lobby_text, container, status_lobby_color, _, _, "left", "center", ibFonts.bold_14 )

            if target_lobby_list[ i ] then
                if target_lobby_list[ i ].voice_off then
                    ibCreateImage( 290, 0, 16, 16, "img/lobby_menu/off_voice_icon.png", container ):center_y()
                end

                local is_leave_action = _DATA.current_lobby == target_lobby_list[ i ].id
                local texture = is_leave_action and "exit" or "enter"

                local button_enter_leave = ibCreateButton( 957, 0, 37, sy, container, "img/lobby_menu/icon_" .. texture .. ".png", "img/lobby_menu/icon_" .. texture .. "_active.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        if is_leave_action then
                            triggerServerEvent( "onLeaveLobbyWaitingRequest", resourceRoot )
                            _DATA.current_lobby = nil
                        else
                            triggerServerEvent( "onServerJoinLobbyRequest", resourceRoot, target_lobby_list[ i ].id )
                        end

                        CreateLobbyInfo( UI_elements.menu_area )
                    end, false )

                if not available and not is_leave_action then
                    button_enter_leave:ibData( "disabled", true )
                    ibCreateImage( 0, 0, 1024, sy, nil, container, 0xAA000000 )
                end
            end
            py = py + sy
        end
    end

    UI_elements.scrollpane_lobby_list:AdaptHeightToContents()
    UI_elements.scrollbar_lobby_list:UpdateScrollbarVisibility( UI_elements.scrollpane_lobby_list )
end

function ShowLobbyListMenu( )
    local menu_area = ibCreateArea( 0, 63, 1024, 626, UI_elements.rt_menu )
    
    ibCreateImage( 0, 0, 1024, 121, "img/lobby_menu/lobby_header.png", menu_area )

    UI_elements.lobby_name = ""
    UI_elements.last_lobby_name = nil
    
    UI_elements.dummy_lobby_name = ibCreateLabel( 73, 31, 240, 30, "Поиск лобби", menu_area, 0xFFAAAAAA, _, _, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
    UI_elements.edf_lobby_name = ibCreateEdit( 73, 32, 808, 30, "", menu_area, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF )
        :ibData( "font", ibFonts.regular_14 )
        :ibOnClick( function()
            if isElement( UI_elements.dummy_lobby_name  ) then destroyElement( UI_elements.dummy_lobby_name  ) end
        end )
        :ibOnDataChange( function( key, value )
            if key ~= "text" then return end
            UI_elements.temp_lobby_name = value
        end )
    
    ibCreateButton(	901, 30, 93, 31, menu_area, "img/lobby_menu/btn_find.png", "img/lobby_menu/btn_find_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "up" then return end
            ibClick( )
            UI_elements.lobby_name = UI_elements.temp_lobby_name
            RefreshTopLobbyUI( menu_area )
        end, false )

    UI_elements.min_lobby_rows = 10
    UI_elements.max_lobby_rows = 31
    RefreshTopLobbyUI( menu_area )

    CreateLobbyInfo( menu_area )

    return menu_area
end

function ShowLeaderBoardMenu()
    local menu_area = ibCreateArea( 0, 63, 1024, 626, UI_elements.rt_menu )
    
    ibCreateImage( 0, 30, 1024, 30, "img/lobby_menu/top_header.png", menu_area )
    
    UI_elements.scrollpane_top, UI_elements.scrollbar_top = ibCreateScrollpane( 0, 60, 1024, 476, menu_area, { scroll_px = -20 } )
    UI_elements.scrollbar_top:ibSetStyle( "slim_nobg" ) 

    local py = 0
    local source_name = localPlayer:GetNickName()
    local sort_top_data = table.copy( _DATA.top_data )
    table.sort( sort_top_data, function( a, b ) return a[ 3 ] > b[ 3 ] end )
    
    local currency = HARD_CURRENCY_GAMES[ _DATA.game_id ] and "hard" or "soft"
    for i = 1, math.max( 11, #sort_top_data ) do
        if sort_top_data[ i ] or i <= 11 then
            local container = ibCreateImage( 0, py, 1024 , 40, nil, UI_elements.scrollpane_top, (sort_top_data[ i ] and source_name == sort_top_data[ i ][ 2 ]) and 0xFF314050 or (i % 2 == 0 and 0x00000000 or 0x60314050) )
            ibCreateLabel( 30, 0, 36, 40, sort_top_data[ i ] and sort_top_data[ i ][ 1 ] or "-", container, _, _, _, "center", "center", ibFonts.bold_14 )
            ibCreateLabel( 139, 0, 0, 40, sort_top_data[ i ] and sort_top_data[ i ][ 2 ] or "-", container, _, _, _, "left", "center", ibFonts.bold_14 )
            local summ_lbl = ibCreateLabel( 841, 0, 0, 40, sort_top_data[ i ] and format_price( sort_top_data[ i ][ 3 ] ) or "-", container, _, _, _, "left", "center", ibFonts.bold_14 )
            if sort_top_data[ i ] then 
                ibCreateImage( 841 + summ_lbl:width() + 7, 10, 23, 19, "img/lobby_menu/icon_" .. currency .. ".png", container ) 
            end
            py = py + 40
        end
    end

    UI_elements.scrollpane_top:AdaptHeightToContents()
    UI_elements.scrollbar_top:UpdateScrollbarVisibility( UI_elements.scrollpane_top )

    CreateLobbyInfo( menu_area )

    return menu_area
end

function ShowRulesMenu()
    local menu_area = ibCreateArea( 0, 63, 1024, 626, UI_elements.rt_menu )
    ibCreateImage( 0, 0, 0, 0, "img/rules/rules_" .. _DATA.game_id .. ".png", menu_area ):ibSetRealSize()
    return menu_area
end

function CreateLobbyInfo( parent )
    if isElement( UI_elements.bg_footer ) then destroyElement( UI_elements.bg_footer ) end

    UI_elements.bg_footer = ibCreateImage( 0, 536, 1024, 90, "img/lobby_menu/bg_footer.png", parent ):ibData( "priority", 100 )
    if not _DATA.current_lobby then
        if _DATA.create_lobby then
            ibCreateButton(	599, 26, 154, 38, UI_elements.bg_footer, "img/lobby_menu/btn_create_lobby.png", "img/lobby_menu/btn_create_lobby_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    if _DATA.current_lobby then
                        localPlayer:ErrorWindow( "Ты должен покинуть лобби чтобы создать новое!" )
                        return
                    end

                    ShowCreateLobbyUI( true )
                end, false )
        end
        
        ibCreateButton(	773, 26, 221, 38, UI_elements.bg_footer, "img/lobby_menu/btn_enter_free_lobby.png", "img/lobby_menu/btn_enter_free_lobby_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "onServerJoinFreeLobbyRequest", resourceRoot, { game_id = _DATA.game_id } )
            end, false )

        ibCreateLabel( 30, 0, 0, 90, "Ты можешь быстро найти свободное лобби" .. (_DATA.create_lobby and " или создать своё" or ""), UI_elements.bg_footer, 0xFF1FD064, _, _, "left", "center", ibFonts.regular_16 )
    else
        ibCreateLabel( 30, 0, 0, 90, "Ожидай участников лобби", UI_elements.bg_footer, 0xFF1FD064, _, _, "left", "center", ibFonts.regular_16 )
    end
end

function ShowCreateLobbyUI( state, parent )
    if state then
        if isElement( UI_elements.bg_create_lobby ) then return end

        UI_elements.bg_create_lobby = ibCreateImage( 0, -689, 1024, 689, "img/lobby_menu/bg_create_lobby.png", UI_elements.rt_menu ):ibBatchData( { alpha = 0, priority = 10000 } ):ibMoveTo( _, 0, 200 ):ibAlphaTo( 255, 200 )
        UI_elements.steps = {}
        local func_collect_rect_bg = function( px, py, sx, sy, parent, color )
            local area = ibCreateArea( px, py, sx + 40, sy, parent )

            local def_color = 0xFF202935
            ibCreateImage( 0, 0, 20, sy, "img/lobby_menu/rect_r.png", area, color or def_color ):ibBatchData( { priority = 0, disabled = true } )
            ibCreateImage( 20, 0, sx, sy, _, area, color or def_color ):ibBatchData( { priority = 0, disabled = true } )
            ibCreateImage( sx + 20, 0, 20, sy, "img/lobby_menu/rect_r.png", area, color or def_color ):ibBatchData( { rotation = 180, priority = 0, disabled = true } )

            return area
        end

        local step_content = {
            [ 1 ] = function( parent )
                ibCreateImage( 20, 20, 308, 265, "img/lobby_menu/content_step_1.png", parent ):ibData( "disabled", true )
                UI_elements.dummy_lobby_new_name = ibCreateLabel( 64, 151, 220, 46, "Введи название лобби", parent, 0xFF989FA7, _, _, "center", "center", ibFonts.regular_14 ):ibData( "disabled", true )
                UI_elements.edf_lobby_name = ibCreateEdit( 64, 151, 220, 46, "", parent, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF )
                :ibData( "font", ibFonts.regular_14 )
                :ibOnClick( function()
                    if isElement( UI_elements.dummy_lobby_new_name  ) then destroyElement( UI_elements.dummy_lobby_new_name  ) end
                end )
                :ibOnHover( function()
                    parent:ibData( "texture", "img/lobby_menu/bg_step_create_active.png" )
                end )
                :ibOnDataChange( function( key, value, old )
                    if key ~= "text" then return end
                    
                    local illegal_symbols = utf8.match( value, "[^А-яё0-9 ]+" )
                    local len = utf8.len( value )
                    if illegal_symbols or len > 30 then
                        UI_elements.edf_lobby_name:ibData( "text", old )
                        UI_elements.edf_lobby_name:ibData( "caret_position", 0 )
                        
                        UI_elements.edf_lobby_name:ibKillTimers()
                        UI_elements.edf_lobby_name:ibTimer( function()
                            UI_elements.edf_lobby_name:ibData( "caret_position", utf8.len( old ) )
                        end, 50, 1 )
                        return
                    end

                    UI_elements.new_lobby_name_lbl:ibData( "text", value )
                    UI_elements.lobby_new_name = value
                end )
            end,
            [ 2 ] = function( parent )
                ibCreateLabel( 0, 131, 0, 0, "Выбери кол-во игроков и режим", parent, 0xFF989FA7, _, _, "center", "top", ibFonts.regular_14 ):center_x():ibData( "disabled", true )
                local px, py = 41, 175
                local non_active_alpha = 150
                UI_elements.bg_count = {}
                for k, v in ipairs( COUNT_PLAYER_GAME_VARIANTS[ _DATA.game_id ] or COUNT_PLAYER_GAME_VARIANTS.default ) do
                    local name_len = dxGetTextWidth( v, 1, ibFonts.bold_14 )
                    local sx = 34 + name_len
                    UI_elements.bg_count[ k ] = func_collect_rect_bg( px, py, sx, 39, parent ):ibData( "alpha", non_active_alpha )
                    :ibOnLeave( function( )
                        if v ~= UI_elements.selected_count then UI_elements.bg_count[ k ]:ibData( "alpha", non_active_alpha ) end
                    end )
                    :ibOnHover( function()
                        UI_elements.bg_count[ k ]:ibData( "alpha", 255 )
                        parent:ibData( "texture", "img/lobby_menu/bg_step_create_active.png" )
                    end )
                    :ibOnClick( function()
                        if isElement( UI_elements.selected_count_ui ) then destroyElement( UI_elements.selected_count_ui ) end
                        UI_elements.selected_count = v
                        UI_elements.new_lobby_count_players_lbl:ibData( "text", v )

                        local px = UI_elements.bg_count[ k ]:ibData( "px" )
                        UI_elements.selected_count_ui = func_collect_rect_bg( px - 1, py - 1, sx + 2, 41, parent, 0xFF989FA7 ):ibData( "priority", UI_elements.bg_count[ k ]:ibData( "priority" ) - 1 )
                        for k, v in pairs(  UI_elements.bg_count ) do 
                            if v ~= UI_elements.selected_count then 
                                UI_elements.bg_count[ k ]:ibData( "alpha", non_active_alpha ) 
                            end 
                        end
                        UI_elements.bg_count[ k ]:ibData( "alpha", 255 )
                    end )

                    local user_icon = ibCreateImage( 24, 11, 14, 16, "img/lobby_menu/icon_user.png", UI_elements.bg_count[ k ] ):ibData( "disabled", true )
                    ibCreateLabel( user_icon:ibGetAfterX() + 7, 0, 0, UI_elements.bg_count[ k ]:ibData( "sy" ) - 2, v, UI_elements.bg_count[ k ], 0xFFBDC0C4, _, _, "left", "center", ibFonts.bold_14 ):ibData( "disabled", true )
                    px = px + UI_elements.bg_count[ k ]:ibData( "sx" ) + 10
                end
            end,
            [ 3 ] = function( parent )
                ibCreateLabel( 0, 81, 0, 0, "Сделай ставку", parent, 0xFF989FA7, _, _, "center", "top", ibFonts.regular_14 ):center_x():ibData( "disabled", true )
                
                local px, py = 27, 124
                local non_active_alpha = 150
                UI_elements.bg_bet = {}
                local currency = HARD_CURRENCY_GAMES[ _DATA.game_id ] and "hard" or "soft"
                for k, v in ipairs( BET_GAME_VARIANTS[ _DATA.casino_id ][ _DATA.game_id ] or BET_GAME_VARIANTS[ _DATA.casino_id ].default ) do
                    local bet_len = dxGetTextWidth( format_price( v ), 1, ibFonts.bold_14 )
                    bet_len = bet_len < 37 and 32 or (bet_len < 53 and 40 or 48)
                    local sx = 23 + bet_len 
                    
                    UI_elements.bg_bet[ k ] = func_collect_rect_bg( px, py, sx, 39, parent ):ibData( "alpha", non_active_alpha )
                    :ibOnLeave( function( )
                        if v ~= UI_elements.selected_bet then UI_elements.bg_bet[ k ]:ibData( "alpha", non_active_alpha ) end
                    end )
                    :ibOnHover( function()
                        UI_elements.bg_bet[ k ]:ibData( "alpha", 255 )
                        parent:ibData( "texture", "img/lobby_menu/bg_step_create_active.png" )
                    end )
                    :ibOnClick( function()
                        if isElement( UI_elements.selected_bet_ui ) then destroyElement( UI_elements.selected_bet_ui ) end
                        UI_elements.selected_bet = v
                        UI_elements.new_lobby_bet_lbl:ibData( "text", format_price( v ) )
                        if not isElement( UI_elements.new_lobby_bet_icon ) then
                            UI_elements.new_lobby_bet_icon = ibCreateImage( 0, 91, 23, 19, "img/lobby_menu/icon_" .. currency .. ".png", UI_elements.bg_create_selection )
                        end
                        UI_elements.new_lobby_bet_icon:ibData( "px", UI_elements.new_lobby_bet_lbl:ibGetAfterX() + 5 )

                        local px = UI_elements.bg_bet[ k ]:ibData( "px" )
                        local py = UI_elements.bg_bet[ k ]:ibData( "py" )
                        UI_elements.selected_bet_ui = func_collect_rect_bg( px - 1, py - 1, sx + 2, 41, parent, 0xFF989FA7 ):ibData( "priority", UI_elements.bg_bet[ k ]:ibData( "priority" ) - 1 )
                        for k, v in pairs(  UI_elements.bg_bet ) do 
                            if v ~= UI_elements.selected_bet then 
                                UI_elements.bg_bet[ k ]:ibData( "alpha", non_active_alpha ) 
                            end 
                        end
                        UI_elements.bg_bet[ k ]:ibData( "alpha", 255 )
                    end )

                    local area_bet = ibCreateArea( 0, 0, sx + 10 - (v == 500 and 15 or 2), 39, UI_elements.bg_bet[ k ] ):ibData( "disabled", true )
                    local bet = ibCreateLabel( 0, 0, 0, UI_elements.bg_bet[ k ]:ibData( "sy" ), format_price( v ), area_bet, 0xFFBDC0C4, _, _, "left", "center", ibFonts.bold_14 ):ibData( "disabled", true )
                    ibCreateImage( bet:ibGetAfterX() + 5, 9, 23, 19, "img/lobby_menu/icon_" .. currency .. ".png", area_bet ):ibData( "disabled", true )
                    area_bet:center()

                    px = px + UI_elements.bg_bet[ k ]:ibData( "sx" ) + 5
                    if px > 240 then
                        px = 68
                        py = py + 44
                    end
                end
            end,
        }

        local px = 9
        for i = 1, 3 do
            UI_elements.steps[ i ] = ibCreateImage( px, 58, 348, 305, "img/lobby_menu/bg_step_create.png", UI_elements.bg_create_lobby )
            :ibOnHover( function()
                UI_elements.steps[ i ]:ibData( "texture", "img/lobby_menu/bg_step_create_active.png" )
            end )
            :ibOnLeave( function( )
                UI_elements.steps[ i ]:ibData( "texture", "img/lobby_menu/bg_step_create.png" )
            end )

            step_content[ i ]( UI_elements.steps[ i ] )

            if i ~= 3 then
                ibCreateImage( 299, 114, 49, 38, "img/lobby_menu/icon_arrow_next.png", UI_elements.steps[ i ] ):ibData( "disabled", true )
            end

            ibCreateLabel( 0, 20, 357, 43, "Шаг " .. i, UI_elements.steps[ i ], _, _, _, "center", "center", ibFonts.bold_16 ):ibData( "disabled", true )

            px = px + 328
        end

        UI_elements.bg_create_selection = ibCreateImage( 0, 371, 1024, 143, "img/lobby_menu/bg_create_selection.png", UI_elements.bg_create_lobby )

        UI_elements.selected_ok = {}
        UI_elements.lobby_new_name = nil
        UI_elements.selected_count = nil
        UI_elements.selected_bet   = nil

        UI_elements.new_lobby_name_lbl          = ibCreateLabel( 428, 68,  0, 0, "-", UI_elements.bg_create_selection, _, _, _, "left", "center", ibFonts.bold_14 )
        UI_elements.new_lobby_count_players_lbl = ibCreateLabel( 483, 102, 0, 0, "-", UI_elements.bg_create_selection, _, _, _, "left", "center", ibFonts.bold_14 )
        UI_elements.new_lobby_bet_lbl           = ibCreateLabel( 651, 102, 0, 0, "-", UI_elements.bg_create_selection, _, _, _, "left", "center", ibFonts.bold_14 )

        ibCreateButton(	443, 543, 138, 44, UI_elements.bg_create_lobby, "img/lobby_menu/btn_create_nlobby.png", "img/lobby_menu/btn_create_nlobby_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                for k, v in pairs( UI_elements.selected_ok ) do
                    if isElement( v ) then destroyElement( v ) end
                end
                UI_elements.selected_ok = {}

                local fail_arg = false
                if not UI_elements.lobby_new_name then
                    UI_elements.steps[ 1 ]:ibData( "texture", "img/lobby_menu/bg_step_create_fail.png" )
                    fail_arg = true
                else
                    UI_elements.selected_ok[ 1 ] = ibCreateImage( 291, 23, 37, 37, "img/lobby_menu/icon_ok.png", UI_elements.steps[ 1 ] )
                end

                if not UI_elements.selected_count then
                    UI_elements.steps[ 2 ]:ibData( "texture", "img/lobby_menu/bg_step_create_fail.png" )
                    fail_arg = true
                else
                    UI_elements.selected_ok[ 2 ] = ibCreateImage( 291, 23, 37, 37, "img/lobby_menu/icon_ok.png", UI_elements.steps[ 2 ] )
                end
                
                if not UI_elements.selected_bet then
                    UI_elements.steps[ 3 ]:ibData( "texture", "img/lobby_menu/bg_step_create_fail.png" )
                    fail_arg = true
                else
                    UI_elements.selected_ok[ 3 ] = ibCreateImage( 291, 23, 37, 37, "img/lobby_menu/icon_ok.png", UI_elements.steps[ 3 ] )
                end

                if fail_arg then return end

                local lobby_name_len = utf8.len( UI_elements.lobby_new_name )
                if lobby_name_len > 30 then
                    localPlayer:ErrorWindow( "Слишком длинное название!" )
                    return
                elseif lobby_name_len < 5 then
                    localPlayer:ErrorWindow( "Слишком короткое название!" )
                    return
                end

                if HARD_CURRENCY_GAMES[ _DATA.game_id ] and localPlayer:GetDonate() < UI_elements.selected_bet or (localPlayer:GetMoney() < UI_elements.selected_bet) then
                    UI_elements.steps[ 3 ]:ibData( "texture", "img/lobby_menu/bg_step_create_fail.png" )
                    destroyElement( UI_elements.selected_ok[ 3 ] )
                    localPlayer:ShowError( "Недостаточно денег" )
                    return false
                end
            
                if UI_elements.confirmation then UI_elements.confirmation:destroy() end
                UI_elements.confirmation = ibConfirm( {
                    title = "СОЗДАНИЕ ЛОББИ", 
                    text = "Ты действительно хочешь создать новое лобби\n`" .. UI_elements.lobby_new_name .. "`?",
                    black_bg = 0xAA202025,
                    fn = function( self ) 
                        self:destroy()
                        local conf = {
                            game                    = _DATA.game_id,
                            name                    = UI_elements.lobby_new_name,
                            bet                     = UI_elements.selected_bet,
                            players_count_required  = UI_elements.selected_count,
                        }
                        triggerServerEvent( "onServerCreateLobbyRequest", resourceRoot, conf )
                    end,
                    escape_close = true,
                } )
            end, false )

        ibCreateButton(	458, 617, 108, 42, UI_elements.bg_create_lobby, "img/lobby_menu/btn_hide.png", "img/lobby_menu/btn_hide_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowCreateLobbyUI( false )
            end, false )
        
        LOBBY_CREATION_OPEN = true
        ibOverlaySound()
    elseif isElement( UI_elements and UI_elements.bg_create_lobby ) then
        UI_elements.bg_create_lobby:ibMoveTo( 0, -689, 200 )
        UI_elements.rt_menu:ibTimer( function()
            destroyElement( UI_elements.bg_create_lobby )
            LOBBY_CREATION_OPEN = false
        end, 230, 1 )

        ibOverlaySound()
    end
end

function onClientLobbySuccessCreated_handler( data )
    _DATA.lobby_data,  _DATA.current_lobby = data.lobby_data, data.current_lobby

    ShowCreateLobbyUI( false )
    SwitchCasinoMenu( LOBBY_MENU_LOBBY )
end
addEvent( "onClientLobbySuccessCreated", true )
addEventHandler( "onClientLobbySuccessCreated", resourceRoot, onClientLobbySuccessCreated_handler )

function RefreshLobbyTopUI()
    if isElement( UI_elements and UI_elements.scrollpane_lobby_list ) then RefreshTopLobbyUI() end
end

function OnTryLeftGame()
    if _DATA.current_lobby then
	    if UI_elements.confirmation then UI_elements.confirmation:destroy() end
	    UI_elements.confirmation = ibConfirm( {
	    	title = "Выход", 
	    	text = "Вы действительно хотите покинуть игру? \nВаше лобби будет закрыто" ,
        
	    	fn = function( self )
	    		ibClick()
	    		ShowCasinoGameLobbyMenuUI( false )            
	    	    self:destroy()
	    	end,
        
	    	fn_cancel = function( self )
                ibClick()
                UI_elements.black_bg:ibData( "can_destroy", true )
                UI_elements.confirmation = nil
	    		self:destroy()
            end,
            
            escape_close = true,
        } )
    else
        ShowCasinoGameLobbyMenuUI( false )
    end
end

function onStart()
    MENU_DATA = 
    {
        [ LOBBY_MENU_MAIN ]        = { id = 1, name = "Главная",   func = ShowMainLobbyMenu,   },
        [ LOBBY_MENU_LOBBY ]       = { id = 2, name = "Лобби",     func = ShowLobbyListMenu,   },
        [ LOBBY_MENU_LEADERBOARD ] = { id = 3, name = "Лидерборд", func = ShowLeaderBoardMenu, },
        [ LOBBY_MENU_RULES ]       = { id = 4, name = "Правила",   func = ShowRulesMenu, condition = function()
            if fileExists( "img/rules/rules_" .. _DATA.game_id .. ".png" ) then
                return true
            end
            return false
        end 
        },
    }
end
addEventHandler( "onClientResourceStart", resourceRoot, onStart )