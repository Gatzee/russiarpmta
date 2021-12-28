----------------------------------------------------------------------------------------
-- Выдача оружия игрока при входе/выходе из лобби, обработчики
----------------------------------------------------------------------------------------

function RestoreData( player, role, lobby_id )
	local lobby_data = GetLobbyDataById( lobby_id )

	toggleControl( player, "enter_exit", true )
	toggleControl( player, "enter_passenger", true )

	if role == JOB_ROLE_DRIVER then
		player:SetPrivateData( "block_engine_incasator", false )
		triggerClientEvent( player, "onClientHideTrashmanHUD", player )
	end
end

function GetVehicleCountOccupants( vehicle )
    local count = 0
    for seat, player in pairs( getVehicleOccupants(vehicle) ) do
        count = count + 1
    end
    return count
end