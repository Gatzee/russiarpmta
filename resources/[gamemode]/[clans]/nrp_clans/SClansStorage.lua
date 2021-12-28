function onPlayerWantGiveItemFromClanStorage_handler( item, count, members )
	local player = client or source
	local clan = player:GetClan( )
    if not clan then return end
    
    if member and not isElement( member ) then return end

    if player:GetClanRole( ) < CLAN_ROLE_MODERATOR then
        player:ShowError( "Вы не можете использовать хранилище!" )
        return
    end

    local total_count = 0
    for i, member in pairs( members ) do
        if isElement( member ) then
            total_count = total_count + count
        else
            members[ i ] = nil
        end
    end

    if total_count <= 0 then return end

	local result, error = clan:RemoveItemFromStorage( item, total_count )

    if result then
        for i, member in pairs( members ) do
            member:InventoryAddItem( item.type, { item.id }, count )
            if member ~= player then
                member:ShowInfo( "Вам выдали предмет из Хранилища!" )
            end
        end

		player:ShowSuccess( "Предмет успешно выдан!" )
		triggerClientEvent( player, "onClientUpdateClanUI", player, {
			storage = clan.storage,
        } )
        
	elseif error then
		player:ShowError( error )
	end
end
addEvent( "onPlayerWantGiveItemFromClanStorage", true )
addEventHandler( "onPlayerWantGiveItemFromClanStorage", root, onPlayerWantGiveItemFromClanStorage_handler )