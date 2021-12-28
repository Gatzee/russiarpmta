function CWeddingOfferSetState_handler( state, initiator, partner )
	if state then

		local text_label = ""
		if initiator then
			text_label = "Вы решили сделать предложение " .. partner:GetNickName() .. ".\nВы уверены?"
		else
			text_label = partner:GetNickName() .. " сделал" .. ( partner:GetGender() == 1 and "а" or "" ) ..  " вам предложение руки и сердца.\nВы согласны принять данное предложение ?"
		end

		IB_elements.offer = {}

		IB_elements.offer.black_bg = ibCreateBackground( 0x00000000, function()
			CWeddingOfferSetState_handler( false )
			triggerServerEvent( "OnWeddingPlayerCancelStartEngage", resourceRoot, partner )
		end, true, true )
		
		IB_elements.offer.bg = ibCreateImage( 0, 0, 1, 1, "files/bg_offer.png" )
		:ibSetRealSize()
		:ibData( 'alpha', 0 )
		:center()

		IB_elements.offer.offer_label = ibCreateLabel( 0, 0, 1, 1, text_label, IB_elements.offer.bg, 0xFFFFFFFF, 1, 1, "center", "center" )
		:ibData( "font", ibFonts.regular_15 )
		:center_x()
		:center_y( 60 )
		

		IB_elements.offer.yes_but = ibCreateButton( 0, 0, 1, 1, IB_elements.offer.bg, "files/btn_yes.png", "files/btn_yes.png", "files/btn_yes.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x( - 71 )
		:center_y( 130 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if initiator then --Если инициатор
				triggerServerEvent( "OnWeddingRootReadyToStartEngage", resourceRoot, partner )
			else --Если предложение от инициатора
				triggerServerEvent( "OnWeddingPlayerReadyStartEngage", resourceRoot, partner )
			end
			CWeddingOfferSetState_handler( false )
		end )
		
	
		IB_elements.offer.no_but = ibCreateButton( 0, 0, 1, 1, IB_elements.offer.bg, "files/btn_no.png", "files/btn_no.png", "files/btn_no.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:center_x( 71 )
		:center_y( 130 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingOfferSetState_handler( false )
			if initiator then --Если инициатор
				--TODO: мб триггер в сервер для очистки данных
			else
				triggerServerEvent( "OnWeddingPlayerCancelStartEngage", resourceRoot, partner )
			end
		end )
		
		IB_elements.offer.close_but = ibCreateButton( IB_elements.offer.bg:width() - 40, 22, 1, 1, IB_elements.offer.bg, "files/close.png", "files/close.png", "files/close.png", 0xFFFFFFFF, 0xD9FFFFFF, 0xFFFFFFFF )
		:ibSetRealSize()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingOfferSetState_handler( false )
			triggerServerEvent( "OnWeddingPlayerCancelStartEngage", resourceRoot, partner )
		end )

		IB_elements.offer.bg:ibAlphaTo( 255, 200 )
		showCursor( true )
	else
		if IB_elements.offer and next( IB_elements.offer ) then
			IB_elements.offer.bg
			:ibAlphaTo( 0, 250 )
			:ibTimer(function()
				DestroyTableElements( IB_elements.offer )
				IB_elements.offer = {}
			end, 250, 1 )
		end
		showCursor( false )
	end
end
addEvent( "OnWeddingIsPlayerReadyToStartEngage", true )
addEventHandler( "OnWeddingIsPlayerReadyToStartEngage", localPlayer, CWeddingOfferSetState_handler )