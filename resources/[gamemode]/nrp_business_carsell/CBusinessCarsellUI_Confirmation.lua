function OpenConfirmationUI( )
	if not CONFIRMATIONSELECTOR then
		local vehicle_list = localPlayer:GetVehicles( )
		local have_slots = DATA.have_slots

		if GetVehicleBlockedReason( ) then
			localPlayer:ShowError( GetVehicleBlockedReason( ) )
			
		elseif DATA.assortment_id <= 5 and #vehicle_list >= have_slots then
			if DATA.apartments_info then
				return ShowNotEnoughSlotsWindow( true )
			else
				return localPlayer:ShowError( "У вас нет свободных слотов под новый транспорт ( всего ".. have_slots .." шт. )" )
			end
		else
			return ShowConfirmationUI( true )
		end
	end
end

function ShowConfirmationUI( state )
	if state then
		ShowConfirmationUI( false )

		local rcost = format_price( GetVehicleDiscountCost( ) or VARIANT_DATA.cost )

		UIElements.confirmation = ibConfirm( 
		    {
		        title = ( DATA.assortment_id == 8 and "ПОКУПКА МОТОЦИКЛА" or "ПОКУПКА АВТОМОБИЛЯ" ), 
		        text = "Ты действительно хочешь купить ".. VEHICLE_DATA.model .. ( VARIANT_DATA.mod == "" and "" or " в комлектации ".. VARIANT_DATA.mod ) .." за ".. rcost .."?" ,
		        fn = function( self )
		        	triggerServerEvent( "onCarsellVehiclePurchase", resourceRoot, VEHICLE_DATA.vmodel, VARIANT_DATA.id, COLORS[COLOR], DATA.veh_spawn )
					ShowConfirmationUI( false )
		        end,

		        fn_cancel = function( self )
		        	ShowConfirmationUI( false )
				end,
				escape_close = true,
		    }
		)
        ibAddKeyAction( "enter", 9999, UIElements.confirmation.elements.black_bg, UIElements.confirmation.fn )

		IS_VEHICLE_SELECTOR_DISABLED = true
		CONFIRMATIONSELECTOR = true
	else
		IS_VEHICLE_SELECTOR_DISABLED = false

		if UIElements.confirmation then 
			UIElements.confirmation:destroy( ) 
		end

		CONFIRMATIONSELECTOR = nil
	end
end