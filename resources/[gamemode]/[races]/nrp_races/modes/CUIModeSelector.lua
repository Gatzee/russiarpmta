
MODES.select_mode = 
{
    id = "select_mode",
    name = "Уличные гонки",
    create_content = function( parent )
        local curx = 30
        for k, v in pairs( RACE_TYPES_DATA ) do
            UI_elements[ "bg_" .. v.type ] = ibCreateImage( curx, 30, 308, 628, "files/img/mode_selector/bg_" .. v.type .. (not RACE_TYPES_DATA[ k ].available and "_off.png" or ".png"), parent ):ibData( "alpha", 200 )
            
            if RACE_TYPES_DATA[ k ].available then
                UI_elements[ "bg_" .. v.type ]
                :ibOnHover( function( )
                    UI_elements[ "bg_" .. v.type ]:ibAlphaTo( 255, 100 )
                end )
                :ibOnLeave( function( )
                    UI_elements[ "bg_" .. v.type ]:ibAlphaTo( 200, 100 )
                end )

                ibCreateButton( 69, 553, 170, 45, UI_elements[ "bg_" .. v.type ], "files/img/mode_selector/btn_select.png", "files/img/mode_selector/btn_select_hover.png", "files/img/mode_selector/btn_select_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
                :ibOnHover( function( )
                    UI_elements[ "bg_" .. v.type ]:ibAlphaTo( 255, 100 )
                end )
                :ibOnClick( function( button, state ) 
		        	if button ~= "left" or state ~= "down" then return end
                    ibClick()
                    if RACE_TYPES_DATA[ k ].available then
                        ChangeLobby( k )
                    else
                        localPlayer:ShowError( "Режим недоступен" )
                    end
                end )
            end
            curx = curx + 328
        end
        return parent
    end,
}

function ShowLobbyCreateUI( state, player_stats, records_data, season_number, season_end, data )
    if state then
        if isElement( UI_elements.black_bg ) then return end
        DestroyTableElements( UI_elements )
        UI_elements = {}

        UI_elements.player_stats  = player_stats
        UI_elements.records_data  = records_data
        UI_elements.season_number = season_number
        UI_elements.season_end    = season_end

        UI_elements.black_bg = ibCreateBackground( _, ShowLobbyCreateUI, 0xAA000000, true )
        
        local sx, sy = 1024, 768
        local px, py = (scX - sx) / 2, (scY - sy) / 2
        UI_elements.bg = ibCreateImage( px, py - 100, sx, sy, "files/img/mode_selector/bg_lobby_create.png", UI_elements.black_bg )
        :ibData( "alpha", 0 )

        UI_elements.tittle = ibCreateLabel( 0, 0, 1024, 79, "", UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_21 )

        UI_elements.helmet = ibCreateImage( 30, 22, 44, 36, "files/img/mode_selector/helmet.png", UI_elements.bg )
        UI_elements.back = ibCreateButton( 30, 33, 108, 17, UI_elements.bg, "files/img/mode_selector/back.png", "files/img/mode_selector/back.png", "files/img/mode_selector/back.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            ChangeLobby( UI_elements.go_back_item_id )
        end )
        
        ibCreateButton(	972, 29, 22, 22, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            ShowLobbyCreateUI( false )
        end )

        UI_elements.bg_content_rt = ibCreateRenderTarget( 0, 80, 1024, 688, UI_elements.bg )
        :ibData( "modify_content_alpha", true )
        
        UI_elements.bg_content = ibCreateArea( 0, 80, 1024, 688, UI_elements.bg_content_rt )
        ChangeLobby( "select_mode" )
        
        UI_elements.bg:ibMoveTo( px, py ):ibAlphaTo( 255, 400 )
        showCursor( true )

        if not data then return end
        if data.race_type == "drag" then
            RIVAL_DATA = {}
            RIVAL_DATA.rival_nickname = data.nickname
            ChangeLobby( RACE_TYPE_DRAG )
        end
    else
        if isElement( UI_elements and UI_elements.black_bg ) then
            destroyElement( UI_elements.black_bg )
        end
        UI_elements = {}
        
        showCursor( false )
    end
end
addEvent( "RC:onClientShowLobbyCreateUI", true )
addEventHandler( "RC:onClientShowLobbyCreateUI", root, ShowLobbyCreateUI )

function ChangeLobby( item_id )
    if item_id and MODES[ item_id ] and (not UI_elements.current_item or UI_elements.current_item.name ~= item_id) then
        if UI_elements.current_item then
            UI_elements.go_back_item_id = UI_elements.current_item.id
        end
        UI_elements.current_item = MODES[ item_id ]

        local parent = ibCreateArea( item_id == "select_mode" and 0 or -50, 0, 1024, 688, UI_elements.bg_content_rt )
        local new_content = item_id == "select_mode" and MODES[ item_id ].create_content( parent ) or OpenTabPanel( parent )
        :ibData("priority", 0)
        :ibData("alpha", 0)
        :ibAlphaTo(255, 200)
        
        if item_id == "select_mode" then
            UI_elements.bg_content:ibMoveTo( -50, _, 200 ):ibAlphaTo( 0, 200 )
            new_content:ibMoveTo( 0, _, 200 )
            
            UI_elements.helmet:ibBatchData({ disabled = false, alpha = 255 })
            UI_elements.back:ibBatchData({ disabled = true, alpha = 0 })
        else
            UI_elements.bg_content:ibMoveTo( 50, _, 200 ):ibAlphaTo( 0, 200 )
            new_content:ibMoveTo( 0, _, 200 )

            UI_elements.helmet:ibBatchData({ disabled = true, alpha = 0 })
            UI_elements.back:ibBatchData({ disabled = false, alpha = 200 })
        end

        UI_elements.bg_content:ibTimer( function( self, old_area )
            if isElement( old_area ) then
                old_area:destroy()
            end
        end, 200, 1, UI_elements.bg_content )
        UI_elements.tittle:ibData( "text", MODES[ item_id ].name )
        UI_elements.bg_content = new_content
    end
end

function OpenTabPanel( parent )
    UI_elements.current_tab_id = 1
    UI_elements.race_type_points = "race_" .. RACE_TYPES_DATA[ UI_elements.current_item.id ].type .. "_points"
    
    local px = 30
    for k, v in ipairs( UI_elements.current_item.tabs ) do
        local sx = dxGetTextWidth( v.name, 1, ibFonts.bold_16 )
        UI_elements[ "tab_area_" .. k ] = ibCreateArea( px, 15, sx, 25, parent )
        :ibOnHover( function( )
            if k ~= UI_elements.current_tab_id then
                UI_elements[ "tab_" .. k .. "_name" ]:ibData( "color", 0xFFFFFFFF )
            end
        end )
        :ibOnLeave( function( )
            if k ~= UI_elements.current_tab_id then
                UI_elements[ "tab_" .. k .. "_name" ]:ibData( "color", 0xFFC1C7CD )
            end
        end )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            if UI_elements.current_tab_id ~= k then
                ChangeItemTab( k )
            end
        end )

        UI_elements[ "tab_" .. k .. "_name" ] = ibCreateLabel( 0, 0, sx, 22, v.name, UI_elements[ "tab_area_" .. k ], 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
        :ibData( "disabled", true )
        if k ~= UI_elements.current_tab_id then
            UI_elements[ "tab_" .. k .. "_name" ]:ibData( "color", 0xFFC1C7CD )
        end

        px = px + sx + 29 
    end

    ibCreateImage( 30, 52, 964, 1, _, parent, 0x0FC1C7CD )
    UI_elements.tab_caret = ibCreateImage( 30, 49, 52, 4, _, parent, 0xFFFF965D )
        
    UI_elements.current_tab = ibCreateArea( 0, 53, 1024, 635, parent )
    UI_elements.current_item.tabs[ UI_elements.current_tab_id ].create_content( UI_elements.current_tab )

    return parent
end

function ChangeItemTab( new_tab_id )
    TAB_PX = 0
    UI_elements[ "tab_" .. new_tab_id .. "_name" ]:ibData( "alpha", 255 )
    if UI_elements.current_tab_id then
        TAB_PX = new_tab_id > UI_elements.current_tab_id and 30 or -30
        UI_elements[ "tab_" .. UI_elements.current_tab_id .. "_name" ]:ibData( "alpha", 200 )
    end
    
    UI_elements.tab_caret:ibMoveTo( UI_elements[ "tab_area_" .. new_tab_id ]:ibData( "px" ), _, 200, "Linear" )
    UI_elements.tab_caret:ibResizeTo( dxGetTextWidth( UI_elements.current_item.tabs[ new_tab_id ].name, 1, ibFonts.bold_16 ), _, 200, "Linear" )
    
    local new_current_tab = ibCreateArea( TAB_PX, 53, 1024, 635, UI_elements.current_tab:ibData( "parent" ) )
    UI_elements.current_item.tabs[ new_tab_id ].create_content( new_current_tab )

    new_current_tab
    :ibData( "priority", 0 )
    :ibData("alpha", 0)
    :ibAlphaTo( 255, 200 )

    if new_tab_id > UI_elements.current_tab_id then
        UI_elements.current_tab:ibMoveTo( -30, _, 200 ):ibAlphaTo( 0, 200 )
        new_current_tab:ibMoveTo( 0, _, 200 )
    elseif new_tab_id < UI_elements.current_tab_id then
        UI_elements.current_tab:ibMoveTo( 30, _, 200 ):ibAlphaTo( 0, 200 )
        new_current_tab:ibMoveTo( 0, _, 200 )
    end

    UI_elements.current_tab:ibTimer( function( self, old_area )
        if isElement( old_area ) then
            old_area:destroy()
        end
    end, 200, 1, UI_elements.current_tab )

    UI_elements.current_tab = new_current_tab
    UI_elements.current_tab_id = new_tab_id
    
end