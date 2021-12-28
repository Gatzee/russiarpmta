
local CHURCH_POSITION = Vector3( 179.9600, -1701.0000, 21 )

function CWeddingCongratSetState_handler( state )
	if state then

		IB_elements.congrat = {}
		IB_elements.congrat.black_bg = ibCreateBackground( 0x00000000, CWeddingCongratSetState_handler, true, true )
		IB_elements.congrat.bg = ibCreateImage( 0, 0, 1, 1, "files/bg_congrat.png", IB_elements.congrat.black_bg  )
		:ibData( 'alpha', 0 )
		:ibSetRealSize()
		:center()

		IB_elements.congrat.yes_but = ibCreateButton( 0, 0, 1, 1, IB_elements.congrat.bg, "files/congrat_locate.png", "files/congrat_locate.png", "files/congrat_locate.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x()
		:center_y( 149 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingCongratSetState_handler( false )
			triggerEvent( "ToggleGPS", localPlayer, CHURCH_POSITION )
		end )

		IB_elements.congrat.but_close_tex = dxCreateTexture( 'files/close.png' )
		but_tex_x, but_tex_y = dxGetMaterialSize( IB_elements.congrat.but_close_tex )
		IB_elements.congrat.close_but = ibCreateButton( IB_elements.congrat.bg:width() - 40, 22, 1, 1, IB_elements.congrat.bg, "files/close.png", "files/close.png", "files/close.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingCongratSetState_handler( false )
		end )

		IB_elements.congrat.bg:ibAlphaTo( 255, 200 )
		showCursor( true )
	else
		if IB_elements.congrat and next( IB_elements.congrat ) then
			IB_elements.congrat.bg
			:ibAlphaTo( 0, 250 )
			:ibTimer(function()
				DestroyTableElements( IB_elements.congrat )
				IB_elements.congrat = {}
			end, 250, 1 )
		end
		showCursor( false )
	end
end
addEvent( "CWeddingCongratSetState", true )
addEventHandler( "CWeddingCongratSetState", localPlayer, CWeddingCongratSetState_handler )