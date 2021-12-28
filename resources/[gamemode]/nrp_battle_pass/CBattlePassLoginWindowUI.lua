function ShowLoginWindow( to_take_reward )
	if isElement( UI.black_bg ) then return end

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	showCursor( true )

	UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/login_window/bg.png", UI.black_bg )
		:center( )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )
    
    ibCreateLabel( 0, 26, 1024, 0, "Сезонные награды активны!", UI.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
    local current_stage = 1
    for i, stage in ipairs( BP_STAGES ) do
        if stage.start_ts <= getRealTimestamp( ) then
            current_stage = i
        else
            break
        end
    end
    ibCreateLabel( 0, 53, 1024, 0, "Действует " .. current_stage .. " этап", UI.bg, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "center", "center", ibFonts.bold_14 )

    UI.area_timer = ibCreateArea( 0, 113, 0, 0, UI.bg )
    ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
    ibCreateLabel( 36, 0, 0, 0, "Сезон закончится через:", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
    UI.lbl_timer = ibCreateLabel( 235, 0, 0, 0, getHumanTimeString( BP_CURRENT_SEASON_END_TS ) or "0 с", UI.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
        :ibTimer( function( self )
            self:ibData( "text", getHumanTimeString( BP_CURRENT_SEASON_END_TS ) or "0 с" )
            UI.area_timer:ibData( "sx", UI.lbl_timer:ibGetAfterX( ) ):center_x( )
        end, 1000, 0 )
    UI.area_timer:ibData( "sx", UI.lbl_timer:ibGetAfterX( ) ):center_x( )

	ibCreateButton(	972, 29, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			destroyElement( UI.black_bg )
		end, false )

    local btn_img = "img/login_window/" .. ( to_take_reward and "btn_take_reward.png" or "btn_details.png" )
    ibCreateButton(	0, 698, 0, 0, UI.bg, btn_img, _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibSetRealSize( ):center_x( )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			destroyElement( UI.black_bg )
            triggerServerEvent( "BP:onPlayerWantShowUI", localPlayer )
		end, false )
end

addEvent( "BP:ShowLoginWindow", true )
addEventHandler( "BP:ShowLoginWindow", resourceRoot, function( to_take_reward )
    if CHECK_ACTIVE_WINDOWS_TIMER then return end

    CHECK_ACTIVE_WINDOWS_TIMER = setTimer( function( )
        if ibIsAnyWindowActive( ) then return end

        sourceTimer:destroy( )
        ShowLoginWindow( to_take_reward )
    end, 1000, 0 )
end )