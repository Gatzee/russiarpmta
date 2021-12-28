local cursor_handlers = { }
local _showCursor = showCursor
function showCursor( state, handler, toggle_controls )
    cursor_handlers[ handler ] = state or nil
    _showCursor( state or next( cursor_handlers ) and true or false, toggle_controls )
end

local UI

local col_px = 0
local row_sy = 58
local bg_row
local columns = {
    {
        title = "Участник",
        sx = 210,
        fn_create = function( self, k, v )
            ibCreateLabel( col_px, 10, 0, row_sy, v.name, bg_row, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
            ibCreateLabel( col_px, 30, 0, row_sy, CLAN_ROLES_NAMES[ v.role ], bg_row, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.regular_12 )
        end,
    },
    {
        title = "Действие",
        sx = 100,
        fn_create = function( self, k, v )
            if localPlayer:GetClanRole( ) >= CLAN_ROLE_MODERATOR and localPlayer:GetClanRole( ) > v.role then
                ibCreateButton( col_px, 0, 81, 33, bg_row, 
                        "img/event_lobby/btn_remove.png", "img/event_lobby/btn_remove_hover.png", "img/event_lobby/btn_remove_hover.png", _, _, 0xFFAAAAAA )
                    :center_y( )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        ibConfirm(
                            {
                                title = "ЛОББИ", 
                                text = "Вы точно хотите выгнать игрока " .. v.name .. "?",
                                fn = function( self ) 
                                    self:destroy()
                                    triggerServerEvent( "CEV:OnPlayerRequestKickOther", localPlayer, v.player )
                                end,
                                escape_close = true,
                            }
                        )
                    end )
            else
                ibCreateLabel( col_px, 0, 0, row_sy, "Недоступно", bg_row, 0xFFab4a4e, 1, 1, "left", "center", ibFonts.regular_14 )
            end
        end,
    },
}

HUD_CONFIGS.event_lobby = {
    elements = { },
    use_real_fonts = true,
    order = 998,

    create = function( self, data )
        UI = self.elements

        local bg = ibCreateImage( 0, 0, 340, 320, _, _, ibApplyAlpha( 0xFF2a323c, 85 ) )
            -- :ibResizeTo( _, 320, 500 )

        UI.bg = bg

        local header = ibCreateImage( 0, 0, 340, 59, _, bg, ibApplyAlpha( 0xFF2a323c, 75 ) )
            -- :ibData( "alpha", 0 )

        header:ibTimer( header.ibAlphaTo, 100, 1, 255, 100 )

        local lbl = ibCreateLabel( 20, 16, 0, 0, "Лобби", header, COLOR_WHITE, _, _, "left", "top", ibFonts.bold_18 )
        ibCreateLabel( lbl:ibGetAfterX( 5 ), 22, 0, 0, "(" .. CLAN_EVENTS_NAMES[ data.event_id ] .. ")", header, ibApplyAlpha( COLOR_WHITE, 60 ), _, _, "left", "top", ibFonts.regular_12 )

        ibCreateLine( 0, header:height( ) - 1, header:ibData( "sx" ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, header )

        UI.lbl_max_count = ibCreateLabel( header:width( ) - 20, 20, 0, 0, "/12", header, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "right", "top", ibFonts.bold_14 )
        UI.lbl_count = ibCreateLabel( UI.lbl_max_count:ibGetBeforeX( -3 ), 18, 0, 0, "1", header, COLOR_WHITE, _, _, "right", "top", ibFonts.bold_16 )

        col_px = 20
        for i, col in pairs( columns ) do
            ibCreateLabel( col_px, 65, 0, 0, col.title, UI.bg, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "top", ibFonts.regular_12 )
            col_px = col_px + col.sx
        end

        UpdatePlayersList( data, true )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
        UI = nil
    end,
}

function UpdatePlayersList( data, init )
    table.sort( data.players, function( a, b ) return ( a.role or 0 ) > ( b.role or 0 ) end )
    
    UI.lbl_max_count:ibData( "text", "/" .. ( data.max_count or 12 ) )
    UI.lbl_count:ibData( "text", #data.players ):ibData( "px", UI.lbl_max_count:ibGetBeforeX( -3 ) )

    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( true )

    local old_scroll_pos = UI.scrollbar and UI.scrollbar:ibData( "position" ) or 0
    if isElement( UI.scrollpane ) then
        UI.scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        UI.scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
    end

    UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 0, 90, 340, 320 - 90,  UI.bg, { scroll_px = -20 } )
        -- :ibData( "alpha", 0 )

    UI.scrollpane:ibTimer( UI.scrollpane.ibAlphaTo, 100, 1, 255, 100 )

    UI.scrollbar:ibSetStyle( "slim_small_nobg" )
    
    local i = 0
    for k, v in pairs( data.players ) do
        i = i + 1
        bg_row = ibCreateImage( 0, ( i - 1 ) * row_sy, UI.scrollpane:ibData( "sx" ), row_sy, _, UI.scrollpane, ibApplyAlpha( 0xFF2a323c, 75 ) * ( i % 2 ) )
        col_px = 20
        for col_i, col in pairs( columns ) do
            col:fn_create( k, v )
            col_px = col_px + col.sx
        end
    end
    UI.scrollpane
        :AdaptHeightToContents( )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
    UI.scrollbar
        :UpdateScrollbarVisibility( UI.scrollpane )
        :ibData( "position", old_scroll_pos )

    ibUseRealFonts( fonts_real )
end

function ShowEventLobbyList( key, state )
    local is_visible = UI and true
    RemoveHUDBlock( "event_lobby" )
    if is_visible then
        showCursor( false, "event_lobby" )
    else
        AddHUDBlock( "event_lobby", LOBBY_DATA )
        showCursor( true, "event_lobby" )
    end
end

function OnClientPlayerLobbyJoin( data )
    SetAllMinorHUDBlocksVisible( false )
    if not data.players then return end
    LOBBY_DATA = data
    bindKey( "tab", "down", ShowEventLobbyList, data )
    HUD_CONFIGS.event_lobby.elements.info_press_key = ibInfoPressKey( {
        do_text = "Нажмите",
        text = "чтобы показать список игроков в лобби",
        key = "tab",
        key_text = "TAB",
        black_bg = 0,
    } )
end
addEvent( "CEV:OnClientPlayerLobbyJoin", true )
addEventHandler( "CEV:OnClientPlayerLobbyJoin", root, OnClientPlayerLobbyJoin )

function OnClientOtherPlayerLobbyJoin( role )
    table.insert( LOBBY_DATA.players, {
        player = source,
        name = source:GetNickName( ),
        role = role,
    } )
    if UI then
        RemoveHUDBlock( "event_lobby" )
        AddHUDBlock( "event_lobby", LOBBY_DATA )
    end
end
addEvent( "CEV:OnClientOtherPlayerLobbyJoin", true )
addEventHandler( "CEV:OnClientOtherPlayerLobbyJoin", root, OnClientOtherPlayerLobbyJoin )

function OnClientOtherPlayerLobbyLeave( )
    if not LOBBY_DATA then return end

    for i, data in pairs( LOBBY_DATA.players ) do
        if data.player == source then
           table.remove( LOBBY_DATA.players, i )
           break
        end
    end
    if UI then
        RemoveHUDBlock( "event_lobby" )
        AddHUDBlock( "event_lobby", LOBBY_DATA )
    end
end
addEvent( "CEV:OnClientOtherPlayerLobbyLeave", true )
addEventHandler( "CEV:OnClientOtherPlayerLobbyLeave", root, OnClientOtherPlayerLobbyLeave )

function DestroyEventLobbyUI( )
    if not LOBBY_DATA then return end
    unbindKey( "tab", "down", ShowEventLobbyList )
    RemoveHUDBlock( "event_lobby" )
    showCursor( false, "event_lobby" )
    LOBBY_DATA = nil
end
addEvent( "CEV:OnClientGameStarted", true )
addEventHandler( "CEV:OnClientGameStarted", root, DestroyEventLobbyUI )
addEvent( "CEV:OnClientPlayerLobbyLeave", true )
addEventHandler( "CEV:OnClientPlayerLobbyLeave", root, DestroyEventLobbyUI )