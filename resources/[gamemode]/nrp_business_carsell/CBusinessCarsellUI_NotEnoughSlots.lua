function ShowNotEnoughSlotsWindow( state )
	if state then
		InitCarsell( )

		ShowNotEnoughSlotsWindow( false )
		IS_VEHICLE_SELECTOR_DISABLED = true

		triggerServerEvent( "onSlotOfferShow", getResourceRootElement( ), localPlayer )
		
		UIElements.ApartmentsInfo = {}
		
		UIElements.ApartmentsInfo.black_bg = ibCreateBackground( 0xa0475d75, ShowNotEnoughSlotsWindow, _, true )
		UIElements.ApartmentsInfo.img = ibCreateImage( 0, 0, 540, 360, "img/not_enough_slots_window/bg.png", UIElements.ApartmentsInfo.black_bg ):center( )

		UIElements.ApartmentsInfo.Ok = ibCreateButton( 45, 260, 140, 50, UIElements.ApartmentsInfo.img, "img/not_enough_slots_window/button_okey", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ShowNotEnoughSlotsWindow( false )
			end )

		UIElements.ApartmentsInfo.BuySlot = ibCreateButton( 	205, 264, 156, 42, UIElements.ApartmentsInfo.img, "img/not_enough_slots_window/button_buy_slot", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ShowNotEnoughSlotsWindow( false )
				SendElasticGameEvent( "f4r_not_enough_slots_window_click" )
				triggerServerEvent( "onCarSellSlotBuy", getResourceRootElement( ), localPlayer )
			end )
	else
		IS_VEHICLE_SELECTOR_DISABLED = false
		if isElement( UIElements.ApartmentsInfo and UIElements.ApartmentsInfo.black_bg ) then
			destroyElement( UIElements.ApartmentsInfo.black_bg )
		end
	end
end