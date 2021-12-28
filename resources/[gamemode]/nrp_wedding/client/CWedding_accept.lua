function showPlayerAcceptWindow_handler( state, self, partner )
	if state then

		IB_elements.accept = {}

		IB_elements.accept.black_bg = ibCreateBackground( 0x00000000, function()
			showPlayerAcceptWindow_handler( false )
			triggerServerEvent( "OnWeddingPlayerAcceptWindowResult", resourceRoot, false )
		end, true, true )
		
		IB_elements.accept.bg = ibCreateImage( 0, 0, 1, 1, "files/bg_accept.png", IB_elements.accept.black_bg )
		:ibData( 'alpha', 0 )
		:ibSetRealSize()
		:center()
		
		IB_elements.accept.label = ibCreateLabel(  0, 0, 1, 1, "Готов" .. ( self[1] == 0 and "" or "а" )  .. " ли ты " .. self[2] .. "\nвзять в законные " .. ( partner[1] == 0 and "мужья " or "жёны " ) .. partner[2] .. " ?", IB_elements.accept.bg )
		:center_x()
		:center_y( 60 )
		:ibBatchData( { font = ibFonts.regular_15, align_x = "center", align_y = "center", alpha = 200 } )

		IB_elements.accept.yes_but = ibCreateButton( 0, 0, 1, 1, IB_elements.accept.bg, "files/btn_yes.png", "files/btn_yes.png", "files/btn_yes.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x( - 71 )
		:center_y( 130 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			showPlayerAcceptWindow_handler( false )
			triggerServerEvent( "OnWeddingPlayerAcceptWindowResult", resourceRoot, true )
		end )
		
		IB_elements.accept.no_but = ibCreateButton( 0, 0, 1, 1, IB_elements.accept.bg, "files/btn_no.png", "files/btn_no.png", "files/btn_no.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x( 71 )
		:center_y( 130 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			showPlayerAcceptWindow_handler( false )
			triggerServerEvent( "OnWeddingPlayerAcceptWindowResult", resourceRoot, false )
		end )
		
		IB_elements.accept.close_but = ibCreateButton( IB_elements.accept.bg:width() - 40, 22, 1, 1, IB_elements.accept.bg, "files/close.png", "files/close.png", "files/close.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			showPlayerAcceptWindow_handler( false )
			triggerServerEvent( "OnWeddingPlayerAcceptWindowResult", resourceRoot, false )
		end )

		IB_elements.accept.bg:ibAlphaTo( 255, 200 )
		showCursor( true )
	else
		if IB_elements.accept and next( IB_elements.accept ) then
			IB_elements.accept.bg
			:ibAlphaTo( 0, 250 )
			:ibTimer(function()
				DestroyTableElements( IB_elements.accept )
				IB_elements.accept = {}
			end, 250, 1 )
		end
		showCursor( false )
	end
end
addEvent( "OnWeddingshowPlayerAcceptWindow", true )
addEventHandler( "OnWeddingshowPlayerAcceptWindow", localPlayer, showPlayerAcceptWindow_handler )