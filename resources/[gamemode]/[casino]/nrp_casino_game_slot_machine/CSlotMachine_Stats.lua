

function ShowSlotMachineStatsMenu( state, casino_id, game_id, data )
    if isElement( UI_elements and UI_elements.black_bg ) then
        destroyElement( UI_elements.logo_texture )
        destroyElement( UI_elements.black_bg )
    end

    if state then
        local game_string_id = CASINO_GAME_STRING_IDS[ game_id ]

        UI_elements.black_bg = ibCreateBackground( 0x801B1E25, OnTryLeftGame, true, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 400 )
        ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/games/" .. game_string_id .. "/machine/bg.png", UI_elements.black_bg ):center()

        UI_elements.bg_menu = ibCreateImage( 0, 0, 1024 * cfX, 769 * cfY, "img/stats/bg_stats.png", UI_elements.black_bg ):center()
        ibCreateButton(	972 * cfX, 29 * cfY, 24 * cfX, 24 * cfY, UI_elements.bg_menu, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		    :ibOnClick( function( key, state )
		    	if key ~= "left" or state ~= "up" then return end

		    	ibClick( )
		    	OnTryLeftGame()
		    end, false )

        UI_elements.logo_texture = dxCreateTexture( "img/games/" .. game_string_id .. "/logo.png" )
        
        local sx, sy = dxGetMaterialSize( UI_elements.logo_texture )
        UI_elements.logo = ibCreateImage( 30 * cfX, ((79 - sy) / 2) * cfY, sx * cfX, sy * cfY, UI_elements.logo_texture, UI_elements.bg_menu )
        ibCreateLabel( UI_elements.logo:ibGetAfterX() + 16 * cfX, 0, 0, 79 * cfY, CASINO_GAMES_NAMES[ game_id ], UI_elements.bg_menu, _, _, _, "left", "center", ibFonts[ "bold_" .. math.floor(20 * cfX) ] )

        UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 0, 186 * cfY, 1024 * cfX, 477 * cfY, UI_elements.bg_menu, { scroll_px = -20 } )
        UI_elements.scrollbar:ibSetStyle( "slim_nobg" ) 
        
        local py = 0
        local source_name = localPlayer:GetNickName()
        for i = 1, math.max( 10, #data ) do
            if data[ i ] or i <= 10 then
                local container = ibCreateImage( 0, py, 1024 * cfX, 40 * cfY, nil, UI_elements.scrollpane, (data[ i ] and source_name == data[ i ][ 2 ]) and 0xFF314050 or (i % 2 == 0 and 0x00000000 or 0x60314050) )
                ibCreateLabel( 30 * cfX, 0, 36 * cfX, 40 * cfY, data[ i ] and data[ i ][ 1 ] or "-", container, _, _, _, "center", "center", ibFonts[ "bold_" .. math.floor(14 * cfX) ] )
                ibCreateLabel( 139 * cfX, 0, 0, 40 * cfY, data[ i ] and data[ i ][ 2 ] or "-", container, _, _, _, "left", "center", ibFonts[ "bold_" .. math.floor(14 * cfX) ] )
                local summ_lbl = ibCreateLabel( 841 * cfX, 0, 0, 40 * cfY, data[ i ] and format_price( data[ i ][ 3 ] ) or "-", container, _, _, _, "left", "center", ibFonts[ "bold_" .. math.floor(14 * cfX) ] )
                if data[ i ] then ibCreateImage( 841 * cfX + summ_lbl:width() + 7 * cfY, 10 * cfY, 23 * cfX, 19 * cfY, "img/soft.png", container ) end
                py = py + 40
            end
        end

        UI_elements.scrollpane:AdaptHeightToContents()
	    UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )

        ibCreateButton( 0, 695 * cfY, 150 * cfX, 44 * cfY, UI_elements.bg_menu, "img/stats/btn_play.png", "img/stats/btn_play_hover.png", "img/stats/btn_play.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):center_x()
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                ShowSlotMachineStatsMenu( false )
                StartSlotMachineGame( game_id )
            end, false )
    end

    showCursor( state )
end