Extend( "ShVehicleConfig" )
Extend( "SPlayer" )
Extend( "SVehicle" )

Player.TakeNewYearCoins = function( self, count )
	count = tonumber( count ) or 0
	if count <= 0 then return end

	local event_coins = ( self:GetPermanentData( EVENT_COINS_VALUE_NAME ) or 0 ) - count

	if event_coins < 0 then return end

	self:SetPermanentData( EVENT_COINS_VALUE_NAME, event_coins )
	self:SetPrivateData( EVENT_COINS_VALUE_NAME, event_coins )

	return event_coins
end

function PlayerWantBuyItem_handler( index )
	if not client then return end

	local item = SHOP_ITEMS[ CURRENT_EVENT ][ index ]
	if not item then return end

	if item.type == "booster" then
		PlayerWantBuyBooster( client, item )

	else
		if item.type == "accessory" then
			if client:GetOwnedAccessories( )[ item.id ] then
				client:ShowError( "Вы уже приобрели данный аксессуар" )
				return
			end

			if not client:TakeNewYearCoins( item.cost ) then
				client:ShowError( "Недостаточно монет" )
				return
			end

			client:AddOwnedAccessory( item.id )
			client:InfoWindow( "Аксессуар успешно приобретён!" )

		elseif item.type == "skin" then
			if client:HasSkin( item.id ) then
				client:ShowError( "Ты уже владеешь этим скином" )
				return
			end

			if not client:TakeNewYearCoins( item.cost ) then
				client:ShowError( "Недостаточно монет" )
				return
			end

			client:GiveSkin( item.id )
			client:InfoWindow( "Скин успешно приобретён и добавлен в твой гардероб!" )

		elseif item.type == "vehicle" then
			if client.interior ~= 0 or client.dimension ~= 0 then
				client:ErrorWindow( "Покупать машины можно только на улице, не находясь на задании!" )
				return
			end

			if client:getData( "jailed" ) then
				client:ErrorWindow( "В тюрьме нельзя делать покупки" )
				return
			end

			if not client:TakeNewYearCoins( item.cost ) then
				client:ShowError( "Недостаточно монет" )
				return
			end

			local sOwnerPID = "p:" .. client:GetUserID()

			local color = item.color and (type( item.color[ 1 ] ) == "table" and item.color[ math.random( 1, #item.color ) ] or item.color) or { 255, 255, 255 }
			local pRow	= {
				model 		= item.id;
				variant		= item.variant or 1;
				x			= 0;
				y			= 0;
				z			= 0;
				rx			= 0;
				ry			= 0;
				rz			= 0;
				owner_pid	= sOwnerPID;
				color		= color;
			}

			exports.nrp_vehicle:AddVehicle( pRow, true, "OnNewYearVehicleAdded", { player = client, cost = item.soft_cost or VEHICLE_CONFIG[ item.id ].variants[ item.variant or 1 ].cost } )
			client:InfoWindow( "Транспорт успешно приобретён!" )
		end

		local item_quantity = 1
		triggerEvent( "SDEV2DEV_event_item_purchase", client, CURRENT_EVENT, item.id, item.name, item.type, item.cost, "event", item_quantity, item_quantity * item.cost )
	end
end
addEvent( "PlayerWantBuyItem", true )
addEventHandler( "PlayerWantBuyItem", resourceRoot, PlayerWantBuyItem_handler )


function OnNewYearVehicleAdded_handler( vehicle, data )
	if isElement(vehicle) and isElement(data.player) then
		local sOwnerPID = "p:" .. data.player:GetUserID()

		vehicle:SetOwnerPID( sOwnerPID )
		vehicle:SetFuel( "full" )

		vehicle:SetParked( true )

		vehicle:SetPermanentData( "showroom_cost", data.cost )
		vehicle:SetPermanentData( "showroom_date", getRealTimestamp( ) )
		vehicle:SetPermanentData( "first_owner", sOwnerPID )
		triggerEvent( "CheckTemporaryVehicle", vehicle )

		triggerEvent( "CheckPlayerVehiclesSlots", data.player )
	end
end
addEvent("OnNewYearVehicleAdded", true)
addEventHandler("OnNewYearVehicleAdded", resourceRoot, OnNewYearVehicleAdded_handler)


function PlayerWantBuyBooster( player, booster_data )
	local booster_timeout = player:GetPermanentData( EVENT_BOOSTER_VALUE_NAME ) or 0

	if booster_timeout >= EVENTS_TIMES[ CURRENT_EVENT ].to then
		player:ShowError( "Твоих подарков хватит до конца эвента" )
		return
	end

	if not player:TakeDonate( booster_data.cost, "NEW_YEAR_BUY_BOOSTER", "NRPDszx5x" ) then
		triggerClientEvent( player, "onShopNotEnoughHard", player, "booster event shop", "onPlayerRequestDonateMenu", "donate" )
		return
	end

	local timestamp = getRealTimestamp( )
	if booster_timeout < timestamp then
		booster_timeout = timestamp
	end

	booster_timeout = booster_timeout + ( booster_data.time * ( 60 * 60 * ( booster_data.time_type == DAYS and 24 or 1 ) ) )
	player:SetPermanentData( EVENT_BOOSTER_VALUE_NAME, booster_timeout )
	player:SetPrivateData( EVENT_BOOSTER_VALUE_NAME, booster_timeout )

	player:InfoWindow( "Подарок успешно приобретён!" )

	local item_quantity = 1
	triggerEvent( "SDEV2DEV_event_booster_purchase", player, CURRENT_EVENT, booster_data.id, booster_data.name, booster_data.cost, "hard", item_quantity, item_quantity * booster_data.cost )
end

function PlayerWantBuyBooster_handler( booster_index )
	if not client then return end
	
	if not SHOP_BOOSTERS[ CURRENT_EVENT ][ booster_index ] then return end
	PlayerWantBuyBooster( client, SHOP_BOOSTERS[ CURRENT_EVENT ][ booster_index ] )
end
addEvent( "PlayerWantBuyBooster", true )
addEventHandler( "PlayerWantBuyBooster", resourceRoot, PlayerWantBuyBooster_handler )

-- Тестирование
if SERVER_NUMBER > 100 then
    addCommandHandler( "may_events_shop", function( player )
        triggerClientEvent( player, "OnClientCreateEventShop", resourceRoot )
    end )
end