Extend( "SPlayer" )
Extend( "SClans" )

local TRASH_MARKER_COOLDOWNS = { }

addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function( )
        triggerClientEvent( "CAF:onClientCreateMarkers", resourceRoot, TRASH_MARKER_COOLDOWNS )
    end, 1000, 1 )
end )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    local player = source
    local clan_id = player:GetClanID( )
    if clan_id and GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_ALCO_FACTORY ) > 0 then
        triggerClientEvent( player, "CAF:onClientCreateMarkers", resourceRoot, TRASH_MARKER_COOLDOWNS )
    end
end )

addEvent( "onClanUpgrade" )
addEventHandler( "onClanUpgrade", root, function( clan_id, upgrade_id, upgrade_lvl )
    if upgrade_id == CLAN_UPGRADE_ALCO_FACTORY and upgrade_lvl == 1 then
        triggerClientEvent( CallClanFunction( clan_id, "GetOnlineMembers" ), "CAF:onClientCreateMarkers", resourceRoot, TRASH_MARKER_COOLDOWNS )
    end
end )

addEvent( "onPlayerJoinClan" )
addEventHandler( "onPlayerJoinClan", root, function( clan_id )
    local player = source
    if GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_ALCO_FACTORY ) > 0 then
        triggerClientEvent( player, "CAF:onClientCreateMarkers", resourceRoot, TRASH_MARKER_COOLDOWNS )
    end
end )

-- Поиск бутылок

addEvent( "CAF:onPlayerSearchTrashMarker", true )
addEventHandler( "CAF:onPlayerSearchTrashMarker", root, function( marker_id )
    local player = client

    if ( TRASH_MARKER_COOLDOWNS[ marker_id ] or 0 ) > getRealTimestamp( ) or player.frozen then
        return
    end

    TRASH_MARKER_COOLDOWNS[ marker_id ] = getRealTimestamp( ) + TRASH_MARKER_COOLDOWN

    local all_clans_players = GetPlayersInGame( )
    for i, player in pairs( all_clans_players ) do
        if not player:IsInClan( ) then
            all_clans_players[ i ] = nil
        end
    end
    triggerClientEvent( all_clans_players, "CAF:onClientCooldownMarker", resourceRoot, marker_id )

    player.frozen = true
    player:setAnimation( "bomber", "bom_plant_loop", -1, true, false, false, false )
    setTimer( onPlayerFinishSearchTrashMarker, TRASH_SEARCHING_DURATION * 1000, 1, player )
end )

function onPlayerFinishSearchTrashMarker( player )
    if not isElement( player ) then return end
    player.frozen = false
    player:setAnimation( false )
    if math.random( ) <= 0.75 then
        player:InventoryAddItem( IN_BOTTLE_DIRTY, nil, 1 )
        player:ShowSuccess( "Найдена 1 Бутылка" )

        triggerEvent( "onPlayerCollectClanFactoryItem", player, IN_BOTTLE_DIRTY )
    else
        player:ShowError( "Неудача. Тут бутылок нет" )
    end
end

-----------------------------------------------------------------
-- Мытье бутылок

addEvent( "CAF:onPlayerWantShowWashingUI", true )
addEventHandler( "CAF:onPlayerWantShowWashingUI", resourceRoot, function( )
    local player = client
        
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    triggerClientEvent( player, "CAF:ShowWashingUI", resourceRoot, true, {
        available_count = player:InventoryGetItemCount( IN_BOTTLE_DIRTY ),
    } )
end )

addEvent( "CAF:onPlayerStartWashing", true )
addEventHandler( "CAF:onPlayerStartWashing", resourceRoot, function( )
    local player = client
        
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    player:setAnimation( "int_house", "wash_up", -1, true, false, false, false )
end )

addEvent( "CAF:onPlayerWashBottle", true )
addEventHandler( "CAF:onPlayerWashBottle", resourceRoot, function( )
    local player = client
        
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    if player:InventoryGetItemCount( IN_BOTTLE_DIRTY ) <= 0 then return end

    player:InventoryRemoveItem( IN_BOTTLE_DIRTY, 1 )
    player:InventoryAddItem( IN_BOTTLE, nil, 1 )
end )

addEvent( "CAF:onPlayerStopWashing", true )
addEventHandler( "CAF:onPlayerStopWashing", resourceRoot, function( )
    local player = client

    player:setAnimation( false )
end )