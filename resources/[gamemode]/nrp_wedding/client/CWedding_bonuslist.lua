function CWeddingBonuslistSetState( state, data )
	if state then

		IB_elements.bonus = {}
		IB_elements.bonus.black_bg = ibCreateBackground( 0x00000000, CWeddingBonuslistSetState, true, true )
		IB_elements.bonus.bg = ibCreateImage( 0, 0, 1, 1, "files/bg_bonus.png", IB_elements.bonus.black_bg )
		:ibData( 'alpha', 0 )
		:ibSetRealSize()
		:center()
	
		IB_elements.bonus.close_but = ibCreateButton( IB_elements.bonus.bg:width() - 40, 22, 1, 1, IB_elements.bonus.bg, "files/close.png", "files/close.png", "files/close.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingBonuslistSetState( false )
		end )

		IB_elements.bonus.bg:ibAlphaTo( 255, 200 )
		showCursor( true )
	else
		if IB_elements.bonus and next( IB_elements.bonus ) then
			IB_elements.bonus.bg
			:ibAlphaTo( 0, 250 )
			:ibTimer(function()
				DestroyTableElements( IB_elements.bonus )
				IB_elements.bonus = {}
			end, 250, 1 )
		end
		showCursor( false )
	end
end
