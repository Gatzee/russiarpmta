Extend( "SPlayer" )
Extend( "SClans" )

local COLLECTING_MARKER_COOLDOWNS = { { }, { } }
local PLAYERS_IN_LABS = { { }, { } }
local PLAYER_to_LAB_ID = { }

addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function( )
        triggerClientEvent( "CHF:onClientCreateMarkers", resourceRoot, COLLECTING_MARKER_COOLDOWNS )
    end, 1000, 1 )
end )

-- Сбор сырья

addEvent( "CHF:onPlayerEnterLaboratory", true )
addEventHandler( "CHF:onPlayerEnterLaboratory", root, function( lab_id )
    local player = client

    if PLAYER_to_LAB_ID[ player ] then
        if PLAYER_to_LAB_ID[ player ] ~= lab_id then
            RemovePlayerFromLab( player, PLAYER_to_LAB_ID[ player ] )
        else
            return
        end
    end

    table.insert( PLAYERS_IN_LABS[ lab_id ], player )
    PLAYER_to_LAB_ID[ player ] = lab_id

    triggerClientEvent( player, "CHF:UpdateMarkerCooldowns", resourceRoot, COLLECTING_MARKER_COOLDOWNS[ lab_id ] )
end )

addEvent( "CHF:onPlayerExitLaboratory", true )
addEventHandler( "CHF:onPlayerExitLaboratory", root, function( )
    local player = client
    if PLAYER_to_LAB_ID[ player ] then
        RemovePlayerFromLab( player, PLAYER_to_LAB_ID[ player ] )
    end
end )

addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, function( )
    local player = source
    if PLAYER_to_LAB_ID[ player ] then
        RemovePlayerFromLab( player, PLAYER_to_LAB_ID[ player ] )
    end
end )

function RemovePlayerFromLab( player, lab_id )
    for i, player_in_lab in pairs( PLAYERS_IN_LABS[ lab_id ] ) do
        if player == player_in_lab then
            table.remove( PLAYERS_IN_LABS[ lab_id ], i )
            break
        end
    end
    PLAYER_to_LAB_ID[ player ] = nil
end

addEvent( "CHF:onPlayerCollectHash", true )
addEventHandler( "CHF:onPlayerCollectHash", root, function( lab_id, marker_id )
    local player = client

    if ( COLLECTING_MARKER_COOLDOWNS[ lab_id ][ marker_id ] or 0 ) > getRealTimestamp( ) or player.frozen then
        return
    end

    COLLECTING_MARKER_COOLDOWNS[ lab_id ][ marker_id ] = getRealTimestamp( ) + COLLECTING_COOLDOWN

    triggerClientEvent( PLAYERS_IN_LABS[ lab_id ], "CHF:onClientCooldownMarker", resourceRoot, marker_id )

    player.frozen = true
    player:setAnimation( "bomber", "bom_plant_loop", -1, true, false, false, false )
    setTimer( onPlayerFinishCollecting, COLLECTING_DURATION * 1000, 1, player )
end )

function onPlayerFinishCollecting( player )
    if not isElement( player ) then return end
    player.frozen = false
    player:setAnimation( false )
    
    player:InventoryAddItem( IN_HASH_RAW, nil, 1 )
    player:ShowSuccess( "Получена 1 Шишка-петрушки" )

    triggerEvent( "onPlayerCollectClanFactoryItem", player, IN_HASH_RAW )
end

-----------------------------------------------------------------
-- Фасовка

addEvent( "CHF:onPlayerWantShowPackingUI", true )
addEventHandler( "CHF:onPlayerWantShowPackingUI", resourceRoot, function( )
    local player = client
        
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    triggerClientEvent( player, "CHF:ShowPackingUI", resourceRoot, true, {
        available_count = player:InventoryGetItemCount( IN_HASH_DRY ),
    } )
end )

addEvent( "CHF:onPlayerStartPacking", true )
addEventHandler( "CHF:onPlayerStartPacking", resourceRoot, function( )
    local player = client
        
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    player:setAnimation( "int_house", "wash_up", -1, true, false, false, false )
end )

addEvent( "CHF:onPlayerPackHash", true )
addEventHandler( "CHF:onPlayerPackHash", resourceRoot, function( )
    local player = client
        
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    if player:InventoryGetItemCount( IN_HASH_DRY ) <= 0 then return end

    local upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_HASH_FACTORY )
    local factory_conf = FACTORY_UPGRADES[ upgrade_lvl ]
    local quality = GetRandomQuality( factory_conf.quality_chances )

    player:InventoryRemoveItem( IN_HASH_DRY, 1 )
    player:InventoryAddItem( IN_HASH, { quality }, 1 )

    triggerEvent( "onPlayerCollectClanFactoryItem", player, IN_HASH )

    SendElasticGameEvent( player:GetClientID( ), "clan_develop_production", {
        clan_id = clan_id,
        clan_name = GetClanName( clan_id ),
        product_type = "hash",
        product_lvl_num = upgrade_lvl,
        product_grade = "grade_" .. quality,
    } )
end )

addEvent( "CHF:onPlayerStopPacking", true )
addEventHandler( "CHF:onPlayerStopPacking", resourceRoot, function( )
    local player = client

    player:setAnimation( false )
end )