function CWeddingContextSetState_handler( state )
	if state then

		IB_elements.context = {}

		IB_elements.context.black_bg = ibCreateBackground( 0x00000000, CWeddingContextSetState_handler, true, true )
		IB_elements.context.bg = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "files/bg_context.png" )
		:ibData( 'alpha', 0 )

		IB_elements.context.bg_info = ibCreateImage( 0, 0, 1, 1, "files/bg_context_info.png", IB_elements.context.bg )
		:ibSetRealSize()
		:center()

		IB_elements.context.but_close = ibCreateButton( 0, 0, 1, 1, IB_elements.context.bg_info, "files/context_but_close.png", "files/context_but_close.png", "files/context_but_close.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingContextSetState_handler( false )
		end )

		IB_elements.context.but_close:ibData( "py", _SCREEN_Y/2 + 20 )

		IB_elements.context.bg:ibAlphaTo( 255, 200 )
		showCursor( true )
	else
		if IB_elements.context and next( IB_elements.context ) then
			IB_elements.context.bg
			:ibAlphaTo( 0, 250 )
			:ibTimer(function()
				DestroyTableElements( IB_elements.context )
				IB_elements.context = {}
			end, 250, 1 )
		end
		showCursor( false )
	end
end
addEvent( "onWeddingContextSetState", true )
addEventHandler( "onWeddingContextSetState", localPlayer, CWeddingContextSetState_handler )