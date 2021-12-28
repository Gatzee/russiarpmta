function OnPlayerWantBuyKeysItem( item_id, args, amount )
	if not amount or amount <= 0 then return end

	local item_conf = SHOP_ITEMS_LIST[ item_id ] and table.copy( SHOP_ITEMS_LIST[ item_id ] )
	if not item_conf then return end

	local cost = item_conf.cost * amount

	if client:GetCoopQuestKeys( ) < cost then
		client:ShowError( "Недостаточно ключей" )
		return 
	end

	client:TakeCoopQuestKeys( cost )

	item_conf.count = amount

	client:Reward( item_conf, args )
	client:ShowNotification( "Покупка успешно совершена!" )

	local case_class = ( item_conf.type == "tuning_case" or item_conf.type == "vinyl_case") and ( args and args.vehicle and args.vehicle:GetTier() or 1 ) or "null"
	local soft_value = case_class ~= "null" and item_conf.soft_value[ case_class ] or item_conf.soft_value

	SendElasticGameEvent( client:GetClientID( ), "coop_quest_purchase", {
		id          = tostring( item_id ),
        cost        = cost,
        quantity    = amount,
        type        = item_conf.type,
        class       = tostring( case_class ),
        spend_sum   = amount*soft_value,
        currency    = "key",
    } )
end
addEvent( "OnPlayerWantBuyKeysItem", true )
addEventHandler( "OnPlayerWantBuyKeysItem", resourceRoot, OnPlayerWantBuyKeysItem )