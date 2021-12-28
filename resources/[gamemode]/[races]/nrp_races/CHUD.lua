local bLeaving = false

function UIShowBasis_HUD( state, data )
	if state then
		SEQUENCE_ACTIVE = true
		triggerEvent( "onClientHideHudComponents", root, HIDE_HUD_BLOCKS, true )
		
		addEventHandler( "onClientRender", root, DetectPlayerActions )
		if MODES[ data.race_type ].leader_boards then
			UIShow_LeaderBoards( true, data )
		end

		if RACE_DATA.race_type == RACE_TYPE_DRIFT then
			InitializeDrift()
		elseif RACE_DATA.race_type == RACE_TYPE_DRAG then
			ShowDragUI( true, data )
		end
		bFinished = false
		bLeaving  = false
	else
		SEQUENCE_ACTIVE = false
		DestroyDrift()
		DestroyDrag()
		UIShow_LeaderBoards( false )
		removeEventHandler( "onClientRender", root, DetectPlayerActions )
		DestroyTableElements( UI_elements )
		UI_elements = {}
	end
end

function UIShow_LeaderBoards( state, data )
	if state then
		UI_elements.bg_cur_positions = ibCreateArea( 20, 100, 248, 51 + 51 * #data.players )
		ibCreateImage( 0, 0, 248, 51, _, UI_elements.bg_cur_positions, 0xFF323840 )
		ibCreateLabel( 0, 0, 248, 51, "Текущий заезд", UI_elements.bg_cur_positions, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
		
		UI_elements.stats_nick = {}
		UI_elements.stats_value = {}

		local py = 51
		for k, v in pairs( data.players ) do
			local container = ibCreateImage( 0, py, 248, 50, "files/img/hud/bg_score.png", UI_elements.bg_cur_positions )
			ibCreateLabel( 0, 0, 39, 50, k, container, 0xFFFF965D, 1, 1, "center", "center", ibFonts.bold_24 )
			ibCreateLabel( 50, 23, 0, 0, MODES[ data.race_type ].text_points .. ":", container, 0xFFABADAF, 1, 1, "left", "top", ibFonts.regular_12 )
			UI_elements.stats_nick[ k ] = ibCreateLabel( 82, 5, 39, 0, v:GetNickName(), container, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_12 )
			UI_elements.stats_value[ k ] = ibCreateLabel( 93, 23, 39, 0, MODES[ data.race_type ].prepare_points( 0 ), container, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_12 )
			UI_elements.stats_value[ k ]:ibData( "value", 0 )
			py = py + 51
		end

		if data.race_type == RACE_TYPE_CIRCLE_TIME then
			UI_elements.current_circle = ibCreateLabel( 0, 50, scX, 0, "Круг 1/" .. RACE_DATA.circles, _, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.regular_24 )
			:ibData( "outline", 1 )

			UI_elements.current_circle_time = ibCreateLabel( 0, 85, scX, 0, "00:00:000", _, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.regular_19 )
			:ibData( "outline", 1 )
			:ibOnRender( function()
				if UI_elements.finish_race or not UI_elements.start_time then return end
				UI_elements.current_circle_time:ibData( "text", MODES[ RACE_DATA.race_type ].prepare_points( getTickCount() - UI_elements.start_time ) )
			end )
		end

		UI_elements.bg_top_leaders = ibCreateImage( scX - 268, 20, 248, 304, "files/img/hud/bg_top.png" )
		local py = 50
		for i = 1, 5 do
			ibCreateLabel( 50, py + 23, 0, 0, MODES[ data.race_type ].text_points .. ":", UI_elements.bg_top_leaders, 0xFFABADAF, 1, 1, "left", "top", ibFonts.regular_12 )
			ibCreateLabel( 82, py + 6, 39, 0,  data.leaders_season[ i ] and data.leaders_season[ i ].nickname or "-", UI_elements.bg_top_leaders, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_12 )
			ibCreateLabel( 96, py + 23, 39, 0, data.leaders_season[ i ] and MODES[ RACE_DATA.race_type ].prepare_points( data.leaders_season[ i ].points ) or "-", UI_elements.bg_top_leaders, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_12 )
			py = py + 51
		end
	end
end

function RefreshLeaderBoards( data )
	if not RACE_DATA or not RACE_DATA.race_type or not MODES[ RACE_DATA.race_type ].leader_boards then return end

	if not isElement( UI_elements.bg_cur_positions ) then
		return
	end

	for k, v in pairs( data ) do
		UI_elements.stats_nick[ k ]:ibData( "text", v.element:GetNickName() )
		UI_elements.stats_value[ k ]:ibData( "text", MODES[ RACE_DATA.race_type ].prepare_points( v.points ) )
		UI_elements.stats_value[ k ]:ibData( "value", v.points )
	end
end
addEvent( "RC:UpdateVisiblePosition", true )
addEventHandler( "RC:UpdateVisiblePosition", resourceRoot, RefreshLeaderBoards )


function DetectPlayerActions()
	if SEQUENCE_ACTIVE then return end

	if getKeyState( "f" ) and not bFinished and not bLeaving and not UI_elements.last_f_push then
		UI_elements.last_f_push = getTickCount()
		
		if isElement( UI_elements.leave_img ) then
			destroyElement( UI_elements.leave_img )
		end
		
		UI_elements.leave_img = ibCreateImage( scX / 2 - 151, scY - 201, 302, 42, _, _, 0x99000000 )
		UI_elements.leave_progress = ibCreateImage( 1, 1, 0, 40, _, UI_elements.leave_img, 0xFFDD2222 )
		ibCreateLabel( 0, 0, 302, 42, "Выход из гонки", UI_elements.leave_img, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_12 )

		UI_elements.leave_progress
		:ibInterpolate( 
			function( self )
				if self.progress >= 0.495 then
					if isElement( UI_elements.leave_img ) then
						destroyElement( UI_elements.leave_img )
					end
					
					triggerServerEvent( "RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer, true, RACE_STATE_LOSE, "Вы покинули состязание" )
					UI_elements.last_f_push = nil
					bLeaving = true
					return
				elseif not bLeaving then
					UI_elements.leave_progress:ibBatchData({
						sx = 300 * self.easing_value,
					})
				end
			end, 5000, "SineCurve"
		)

	elseif (not getKeyState( "f" ) or bFinished) and UI_elements.last_f_push then
		UI_elements.last_f_push = nil
		if isElement( UI_elements.leave_img ) then
			destroyElement( UI_elements.leave_img )
			UI_elements.last_f_push = nil
		end
	end
end
