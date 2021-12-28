Import( "SPlayer" )
Import( "SVehicle" )
Import( "rewards/_ShItems" )

Player.Reward = function( self, item, args )
    REGISTERED_ITEMS[ item.type or item.id ].Give( self, item.params or item, args or { }, item.cost )
end

Player.GiveReward = Player.Reward

addEvent( "CheckIsRewardExchangeAvailable", true )
addEventHandler( "CheckIsRewardExchangeAvailable", resourceRoot, function( item_uid, item_type, item_params )
	local player = client
	local is_exchange_available = true
	local can_take = nil
	local item_class = REGISTERED_ITEMS[ item_type ]
	if not item_class.isExchangeAvailable or not item_class.isExchangeAvailable( player, item_params ) then
		is_exchange_available = nil
	elseif not item_class.checkHasItem( player, item_params ) then
		can_take = true
	end
	triggerClientEvent( player, "CheckIsRewardExchangeAvailable_callback", resourceRoot, item_uid, is_exchange_available, can_take )
end )
