----------------------------------------------------------------------------------------
-- Выдача оружия игрока при входе/выходе из лобби, обработчики
----------------------------------------------------------------------------------------

function RestoreData( player, role, lobby_id )
	local lobby_data = GetLobbyDataById( lobby_id )
	
	player:setData( "incasator_unload_bags", nil, false ) 
	toggleControl( player, "enter_exit", true )
	toggleControl( player, "enter_passenger", true )

	if role == JOB_ROLE_DRIVER then
		player:SetPrivateData( "block_engine_incasator", false )
		unbindKey( player, PPS_CALL_KEY, "down", TryCallPPS )
		triggerClientEvent( player, "onClientDestroyIncasatorInfo", player )
	end
	
	removeEventHandler( "onPlayerDamage", player, onPlayerDamage_handler )
end