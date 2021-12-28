loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )

addEvent( "CheckIsExchangeAvailable", true )
addEventHandler( "CheckIsExchangeAvailable", resourceRoot, function( item_uid, item_type, item_params )
	local player = client
	local is_exchange_available = true
	local can_take = nil
	local item_class = REGISTERED_ITEMS[ item_type ]
	if not item_class.isExchangeAvailable or not item_class.isExchangeAvailable( player, item_params ) then
		is_exchange_available = nil
	elseif not item_class.checkHasItem( player, item_params ) then
		can_take = true
	end
	triggerClientEvent( player, "CheckIsExchangeAvailable_callback", resourceRoot, item_uid, is_exchange_available, can_take )
end )