function PlayerEnterOnApartmentsWardrobe_handler( id, number )
	if not client then return end
	if not tonumber( id ) then return end
	if not tonumber( number ) then return end

	if not WEDDING_USE_BOTH_WARDROBE then
		if not client:IsHouseOwner( id, number ) then
			return client:ShowError( "Это не твой гардероб" )
		end
	else
		if not CheckPlayerWeddingAtApartOwner( client, id, number ) then
			return client:ShowInfo( "Это не твой гардероб" )
		end
	end

	if APARTMENTS_LIST_OWNERS[ id ][ number ].paid_days < 0 then
		client:ShowError( "Оплати долг за квартиру!" )
		return
	end
	
	setPedWeaponSlot( client, 0 )
	triggerEvent( "PlayerWantShowUIWardrobe", client, true, id, number )
end
addEvent( "PlayerEnterOnApartmentsWardrobe", true )
addEventHandler( "PlayerEnterOnApartmentsWardrobe", resourceRoot, PlayerEnterOnApartmentsWardrobe_handler )

function PlayerEnterOnApartmentsCooking_handler( id, number )
	if not client then return end
	if not tonumber( id ) then return end
	if not tonumber( number ) then return end

	if not WEDDING_USE_BOTH_COOKING then
		if not client:IsHouseOwner( id, number ) then
			return client:ShowError( "Ты не можешь готовить еду в чужом доме" )
		end
	else
		if not CheckPlayerWeddingAtApartOwner( client, id, number ) then
			return client:ShowInfo( "Ты не можешь готовить еду в чужом доме" )
		end
	end

	if APARTMENTS_LIST_OWNERS[ id ][ number ].paid_days < 0 then
		client:ShowError( "Оплати долг за квартиру!" )
		return
	end

	triggerEvent( "onPlayerWantShowCookingUI", client )
end
addEvent( "PlayerEnterOnApartmentsCooking", true )
addEventHandler( "PlayerEnterOnApartmentsCooking", resourceRoot, PlayerEnterOnApartmentsCooking_handler )