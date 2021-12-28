function PlayerWantBuyAccessory_handler( accessory_id )
	local player = client or source
	if not player then return end
	if not accessory_id then return end

	local info = CONST_ACCESSORIES_INFO[ accessory_id ]
	if not info then return end

	if info.level and player:GetLevel() < info.level then
		player:ShowError( "Доступно только с ".. info.level .." уровня" )
		return
	end

	if player:GetOwnedAccessories()[ accessory_id ] then
		player:ShowError( "Вы уже приобрели данный аксессуар" )
		return
	end

	local success_buy = false

	if info.soft_cost then
		if not player:TakeMoney( info.soft_cost, "accessory_purchase" ) then
			player:EnoughMoneyOffer( "Accessory purchase", info.soft_cost, "PlayerWantBuyAccessory", player, accessory_id )
			return
		end

		success_buy = true

	elseif info.hard_cost then
		if not player:TakeDonate( info.hard_cost, "accessory_purchase" ) then
			player:ShowError( "У вас недостаточно средств" )
			return
		end

		success_buy = true
	end

	if success_buy then
		player:AddOwnedAccessory( accessory_id )
		player:InfoWindow( "Позравляем с покупкой!" )

		triggerClientEvent( player, "UpdatePlayerBuyAccessory", resourceRoot, accessory_id )

		local currency = info.soft_cost and "soft" or info.hard_cost and "hard"
		triggerEvent( "onPlayerBuyAccessory", player, accessory_id, info.name, info.soft_cost or info.hard_cost, currency, false )
	end
end
addEvent( "PlayerWantBuyAccessory", true )
addEventHandler( "PlayerWantBuyAccessory", root, PlayerWantBuyAccessory_handler )

function PlayerWantChangeAccessoriesSlot_handler( model, slot, accessory_id, position, rotation, scale )
	if not client then return end
	if not model then return end

	model = tonumber( model )

	local accessories = client:GetAccessories( model )
	if slot then
		if accessory_id then
			local info = CONST_ACCESSORIES_INFO[ accessory_id ]
			if not info then return end

			if not client:GetOwnedAccessories()[ accessory_id ] and not ( info.premium and client:IsPremiumActive( ) ) then return end

			accessories[ slot ] = {
				id = accessory_id;

				position = position;
				rotation = rotation;
				scale = scale;
			}
		else
			accessories[ slot ] = nil
		end
	else
		accessories = { }
	end

	client:SetAccessories( accessories, model )
end
addEvent( "PlayerWantChangeAccessoriesSlot", true )
addEventHandler( "PlayerWantChangeAccessoriesSlot", resourceRoot, PlayerWantChangeAccessoriesSlot_handler )