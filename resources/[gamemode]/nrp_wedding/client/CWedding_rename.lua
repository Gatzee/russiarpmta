function CWeddingRenameSetState( state, name )
	if state then

		IB_elements.rename = {}
		IB_elements.rename.black_bg = ibCreateBackground( 0x00000000, CWeddingRenameSetState, true, true )
		IB_elements.rename.bg = ibCreateImage( 0, 0, 1, 1, "files/bg_rename.png" )
		:ibSetRealSize()
		:ibData( 'alpha', 0 )
		:center()
		
		IB_elements.rename.label = ibCreateLabel(  0, 0, 1, 1, name .. "\nжелаете ли вы взять фамилию жениха ?", IB_elements.rename.bg )
		:center_x()
		:center_y( 60 )
		:ibBatchData( 
			{
				font = ibFonts.regular_15,
				align_x = "center",
				align_y = "center",
				alpha = 200
			} )


		IB_elements.rename.yes_but = ibCreateButton( 0, 0, 1, 1, IB_elements.rename.bg, "files/btn_yes.png", "files/btn_yes.png", "files/btn_yes.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x( - 71 )
		:center_y( 130 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingRenameSetState( false )
		end )

		IB_elements.rename.no_but = ibCreateButton( 0, 0, 1, 1, IB_elements.rename.bg, "files/btn_no.png", "files/btn_no.png", "files/btn_no.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x( 71 )
		:center_y( 130 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingRenameSetState( false )
		end )
		
		IB_elements.rename.close_but = ibCreateButton( IB_elements.rename.bg:width() - 40, 22, 1, 1, IB_elements.rename.bg, "files/close.png", "files/close.png", "files/close.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingRenameSetState( false )
		end )

		IB_elements.rename.bg:ibAlphaTo( 255, 200 )
		showCursor( true )
	else
		if IB_elements.rename and next( IB_elements.rename ) then
			IB_elements.rename.bg
			:ibAlphaTo( 0, 250 )
			:ibTimer(function()
				DestroyTableElements( IB_elements.rename )
				IB_elements.rename = {}
			end, 250, 1 )
		end
		showCursor( false )
	end
end