function onPlayerTryBuyMedbook_handler( )
	if client:GetPermanentData( "has_medbook" ) then
		client:ShowError( "У вас уже есть мед. книжка" )
		return
	end

	if client:TakeMoney( MEDBOOK_COST, "medbook_purchase" ) then
		client:SetPermanentData( "has_medbook", true )
		if client:InventoryGetItemCount( IN_MEDBOOK ) <= 0 then
			client:InventoryAddItem( IN_MEDBOOK, nil, 1 )
		end
		client:ShowInfo( "Вы успешно приобрели мед. книжку" )
		client:triggerEvent( "ShowMedbookMarker", resourceRoot, false )
	else
		client:ShowError( "Недостаточно средств" )
	end
end
addEvent( "onPlayerTryBuyMedbook", true )
addEventHandler( "onPlayerTryBuyMedbook", resourceRoot, onPlayerTryBuyMedbook_handler )

function onPlayerReadyToPlay_handler( )
	if not source:GetPermanentData( "has_medbook" ) then
		source:triggerEvent( "ShowMedbookMarker", resourceRoot, true )
	end
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )