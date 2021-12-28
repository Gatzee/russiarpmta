function onPlayerPurchaseDiscountOfferRequest_handler( item_type, id, segment )
	local conf = OFFERS_TABS.discounts[ item_type ]
	if not conf then
		client:ErrorWindow( "Не найден тип элемента" )
		return
	end

	local params = conf.array and conf.array[ id ]
	if not params then
		client:ErrorWindow( "Не найден элемент" )
		return
	end

	local result, analytics_data = conf:fn_call( id, params, client )

	if result then
		local analytics_data = analytics_data or { }
		for i, v in pairs( conf.analytics_conf or { } ) do
			analytics_data[ i ] = v
		end
		analytics_data.model = id
		analytics_data.segment = params.active_for_all and GetCurrentSegment( player ) or segment or GetAmountSegment( params.cost or 0 )

		--iprint( "Trigger purchase", analytics_data )
		triggerEvent( "onDiscountOfferPurchase", client, analytics_data )
	end
end
addEvent( "onPlayerPurchaseDiscountOfferRequest", true )
addEventHandler( "onPlayerPurchaseDiscountOfferRequest", root, onPlayerPurchaseDiscountOfferRequest_handler )

function onDiscountedVehiclePurchaseCallback_handler( vehicle, data )
	if isElement( vehicle ) and isElement( data.player ) then
		local sOwnerPID = "p:" ..data.player:GetUserID( )

		vehicle.locked = true
		vehicle.engineState = true
		vehicle:SetFuel( "full" )
		vehicle:SetPermanentData( "showroom_cost", data.cost )
		vehicle:SetPermanentData( "showroom_date", getRealTime( ).timestamp )
		vehicle:SetPermanentData( "first_owner", sOwnerPID )

		data.player:AddVehicleToList( vehicle )

		vehicle.position = data.player.position

		removePedFromVehicle( data.player )
		warpPedIntoVehicle( data.player, vehicle )

        triggerEvent( "onPlayerBuyVehicle", data.player, vehicle, data.cost or 0, false )
        triggerEvent( "onPlayerBuyCar", data.player, vehicle, data.cost or 0, true, true )        
	end
end
addEvent( "onDiscountedVehiclePurchaseCallback", true)
addEventHandler( "onDiscountedVehiclePurchaseCallback", resourceRoot, onDiscountedVehiclePurchaseCallback_handler )