loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShInventoryConfig" )

PLAYER_MAX_WEIGHT = 50

REMOVED_ITEMS = {
    [ IN_PASSPORT ] = true,
    [ IN_JOB_HISTORY ] = true,
    -- [ IN_RP_TICKET ] = true,
    [ IN_POLICEID ] = true,
    [ IN_MILITARY ] = true,
    [ IN_ARMYFREE ] = true,
    [ IN_GUN_LICENSE ] = true,
    [ IN_VEHICLE_PASSPORT ] = true,
    [ IN_TUTORIAL_HASH ] = true,
    [ IN_NEWYEAR_LETTER ] = true,
    [ IN_9MAY_RIBBON ] = true,
    [ IN_RP_CERT ] = true,
    [ IN_SMARTWATCH ] = true,

    -- Удаляем старые предметы хобби
    [ IN_HOBBY_FISHING_ROD ] = true,
    [ IN_HOBBY_FISHING_BAIT ] = true,
    [ IN_HOBBY_HUNTING_RIFFLE ] = true,
    [ IN_HOBBY_HUNTING_AMMO ] = true,
    [ IN_HOBBY_DIGGING_SHOVEL ] = true,
}

addEvent( "onHouseUpdate" )
addEventHandler( "onHouseUpdate", root, function ( id, number, data, inventory_max_weight )
    local hid = id .. "_" .. number
    local items = FixTableKeys( data.inventory_data or {}, true )
    local inventory = CreateInventory( hid, items, inventory_max_weight, data.inventory_expand )
    inventory.house = { id, number }
end )

-- Загрузка данных и преобразование в новый формат
function Inventory_LoadPlayer( player, inventory_data )
    inventory_data = FixTableKeys( inventory_data, true )
    local expand_value = player:GetPermanentData( "inventory_expand" )
    local inventory = CreateInventory( player, inventory_data, PLAYER_MAX_WEIGHT, expand_value )

    local old_data = player:GetPermanentData( "items" )
    if old_data and next( old_data ) then
        inventory_data = table.copy( inventory_data ) -- отделяем от inventory.data, чтобы потом пересоздать в случае ошибки
        local result, error = pcall( ConvertOldData, player, inventory, old_data )
        if result then
            player:SetPermanentData( "items", nil )
        else
            Debug( error, 1 )
            SendToLogserver( error, { 
                file_short = "SInventory.lua_ConvertOldData",
                level = 3,
                old_data = toJSON( old_data, true ),
            } )
            -- Пересоздаём для сброса предметов из старого инвентаря, которые были выданы до возникновения ошибки, игрок получит их после фикса
            inventory = CreateInventory( player, inventory_data, PLAYER_MAX_WEIGHT, expand_value )
        end
    end

    -- Выдача постоянных элементов игрокам
    inventory:RemoveItem( IN_RP_TICKET )
    if player:HasFCMembership() then    
        inventory:AddItem( IN_RP_TICKET, { player:GetPermanentData("fc_membership_id") or 2 } )
    end

    local hotbar_items = FixTableKeys( player:GetPermanentData( "hotbar_items" ) or {} )
    player:SetPermanentData( "hotbar_items", hotbar_items )
    player:triggerEvent( "SyncInventory", resourceRoot, player, inventory.data, inventory.max_weight, hotbar_items )

    -- Сообщаем всем о том, что инвентарь готов получать предметы
    triggerEvent( "onInventoryInitializationFinished", player )
end

function ConvertOldData( player, inventory, old_data )
    for i, node in pairs( old_data ) do
        if node[ 1 ] == IN_WEAPON then
            local weapon_id = node[ 2 ][ 1 ]
            if WEAPONS_LIST[ weapon_id ] then
                local item_id = ITEM_IDS_BY_TYPE[ IN_WEAPON ][ weapon_id ]
                if item_id then
                    local ammo = node[ 2 ][ 2 ]
                    if ammo == WEAPONS_LIST[ weapon_id ].Ammo then ammo =  nil end
                    inventory:AddItem( item_id, ammo and { ammo = ammo } )
                end
            end
        elseif node[ 1 ] == IN_FOOD then
            local food_id = node[ 2 ] and node[ 2 ][ 1 ]
            local item_id = food_id and ITEM_IDS_BY_TYPE[ IN_FOOD ][ food_id + 1 ] or IN_FOOD_LUNCHBOX
            inventory:AddItem( item_id, nil, 1 )
        elseif node[ 1 ] and not REMOVED_ITEMS[ node[ 1 ] ] then
            if node[ 2 ] and not next( node[ 2 ] ) then
                node[ 2 ] = nil
            end
            inventory:AddItem( node[ 1 ], node[ 2 ] )
        end
    end

    triggerEvent( "onInventoryConvertOldData", player )

    return true
end

function Inventory_AddNode( player, item_id, attributes, count, temp )
    local inventory = INVENTORIES[ player ]
    if not inventory then return end

    -- TODO: Временный костыль, пока везде не заменю IN_WEAPON на его производные
    if ITEM_IDS_BY_TYPE[ item_id ] then
        item_id = ITEM_IDS_BY_TYPE[ item_id ][ attributes[ 1 ] ]
        if attributes[ 2 ] then
            attributes = { ammo = attributes[ 2 ] }
        else
            attributes = nil
        end
    end

    inventory:AddItem( item_id, attributes, count, temp )

    player:triggerEvent( "AddInventory", resourceRoot, player, item_id, attributes, count, temp )
end
addEvent( "InventoryAddItem" )
addEventHandler( "InventoryAddItem", root, Inventory_AddNode )

function Inventory_RemoveItem( player, item_id, attributes, count, temp )
    local inventory = INVENTORIES[ player ]
    if not inventory then return end

    -- TODO: Временный костыль, пока везде не заменю IN_WEAPON на его производные
    if ITEM_IDS_BY_TYPE[ item_id ] then
        item_id = ITEM_IDS_BY_TYPE[ item_id ][ attributes[ 1 ] ]
        if attributes[ 2 ] then
            attributes = { ammo = attributes[ 2 ] }
        else
            attributes = nil
        end
    end

    inventory:RemoveItem( item_id, attributes, count, temp )

    player:triggerEvent( "RemoveInventory", resourceRoot, player, item_id, attributes, count, temp )
end
addEvent( "InventoryRemoveItem" )
addEventHandler( "InventoryRemoveItem", root, Inventory_RemoveItem )

function Inventory_Clear( inventory_owner )
    local inventory = INVENTORIES[ inventory_owner ]
    if not inventory then return end
    inventory:Clear()
end

function Inventory_Show( inventory_owner )
    local player = source
    local inventory = INVENTORIES[ inventory_owner ]
    if not inventory then
        if isElement( inventory_owner ) and inventory_owner.type == "vehicle" then
            local data = FixTableKeys( inventory_owner:GetPermanentData( "inventory_data" ) or {}, true )
            local max_weight = VEHICLES_MAX_WEIGHTS[ inventory_owner.model ]
            local expand_value = inventory_owner:GetPermanentData( "inventory_expand" )
            inventory = CreateInventory( inventory_owner, data, max_weight, expand_value )
        else
            return
        end
    end
    player:triggerEvent( "ShowInventory", resourceRoot, inventory_owner, inventory.data, inventory.max_weight )
    INVENTORIES[ player ].connected_inventory = inventory
end
addEvent( "InventoryShow" )
addEventHandler( "InventoryShow", root, Inventory_Show )

function Inventory_Move( item_id, attributes, count, is_from_player_inventory )
    local player = client
    local inventory = INVENTORIES[ player ]
    local connected_inventory = inventory.connected_inventory
    if not inventory or not connected_inventory then return end
    if not count or count <= 0 or count ~= math.floor( count ) then return end
    if attributes and attributes._temp then return end

    local item_conf = ITEMS_CONFIG[ item_id ]
    if not item_conf then return end

    local from_inventory = is_from_player_inventory and inventory or connected_inventory
    local to_inventory = is_from_player_inventory and connected_inventory or inventory

    count = math.min( count or 1, from_inventory:GetItemCount( item_id, attributes ) )
    if count <= 0 then return end

    local item_weight = GetItemWeight( item_id, { attributes = attributes }, count )
    if to_inventory.total_weight + item_weight > to_inventory.max_weight then
        player:ShowError( "Недостаточно места" )
        return
    end

    from_inventory:RemoveItem( item_id, attributes, count )
    to_inventory:AddItem( item_id, attributes, count )

    player:triggerEvent( "RemoveInventory", resourceRoot, from_inventory.owner, item_id, attributes, count )
    player:triggerEvent( "AddInventory", resourceRoot, to_inventory.owner, item_id, attributes, count )

    triggerEvent( "onPlayerChangeInventory", player, item_id, attributes, is_from_player_inventory and -count or count )

    SendElasticGameEvent( player:GetClientID( ), "inventory_put", {
        type = to_inventory.owner_type,
        vehicle_id = to_inventory.owner_type == "vehicle" and tostring( to_inventory.owner.model ) or "null",
        mortage_id = to_inventory.owner_type == "house" and tostring( to_inventory.owner ) or "null",
        item_id = tostring( item_id ),
        item_name = item_conf[ VISUAL_CONSTRUCT ] and ( item_conf[ VISUAL_CONSTRUCT ]( item_conf, item_id, attributes or {} ) or {} ).text or "",
        items_type = item_conf[ CATEGORY ] or "stuff",
    } )
end
addEvent( "InventoryMove", true )
addEventHandler( "InventoryMove", resourceRoot, Inventory_Move )

function Inventory_Use( item_id, attributes, target_information )
    local player = client
    if player.dead then return end

    local item_conf = ITEMS_CONFIG[ item_id ]
    if not item_conf then return end

    local inventory = INVENTORIES[ player ]
    if not inventory or inventory:GetItemCount( item_id, attributes ) <= 0 and item_conf[ CATEGORY ] ~= "documents" then return end

    local result, error
    if type( item_conf[ SERVERSIDE_CHECK ] ) == "function" then
        result, error = item_conf[ SERVERSIDE_CHECK ]( item_conf, item_id, attributes or {}, player, target_information )
        if not result then
            if error then player:ShowError( error ) end
            return false
        end
    end

    local keep_inventory_node = nil
    if type( item_conf[ SERVERSIDE_SUCCESS ] ) == "function" then
        keep_inventory_node = item_conf[ SERVERSIDE_SUCCESS ]( item_conf, item_id, attributes or {}, player, target_information, error )
    end

    if not keep_inventory_node then
        inventory:RemoveItem( item_id, attributes, 1 )
    end
    triggerClientEvent( player, "InventoryUseSuccess", resourceRoot, player, item_id, attributes, keep_inventory_node )
end
addEvent( "InventoryUse", true )
addEventHandler( "InventoryUse", resourceRoot, Inventory_Use )

function Inventory_Delete( item_id, attributes, count, is_from_player_inventory )
    local player = client
    local inventory = INVENTORIES[ player ]
    if inventory and not is_from_player_inventory then
        inventory = inventory.connected_inventory
    end
    if not inventory then return end
    if not count or count <= 0 or count ~= math.floor( count ) then return end

    local item_conf = ITEMS_CONFIG[ item_id ]
    if not item_conf then return end

    count = math.min( count or 1, inventory:GetItemCount( item_id, attributes ) )
    if count <= 0 then return end

    inventory:RemoveItem( item_id, attributes, count )
    player:triggerEvent( "RemoveInventory", resourceRoot, inventory.owner, item_id, attributes, count )

    if is_from_player_inventory then
        triggerEvent( "onPlayerChangeInventory", player, item_id, attributes, -count )
    end
end
addEvent( "InventoryDelete", true )
addEventHandler( "InventoryDelete", resourceRoot, Inventory_Delete )

addEvent( "InventoryHotbarChange", true )
addEventHandler( "InventoryHotbarChange", resourceRoot, function( slot, value )
    local player = client
    local hotbar_items = player:GetPermanentData( "hotbar_items" ) or {}
    hotbar_items[ slot ] = value
    player:SetPermanentData( "hotbar_items", hotbar_items )
end )

function onInventoryChange( inventory )
    if inventory.house then
        local id, number = unpack( inventory.house )
        if id > 0 then
            exports.nrp_apartment:SetApartmentsData( id, number, "inventory_data", inventory.data )
        else
            exports.nrp_vip_house:SetViphouseData( number, "inventory_data", inventory.data )
        end
    else
        inventory.owner:SetPermanentData( "inventory_data", inventory.data )
    end
end

function Inventory_ReadyPlayerServerside( player )
    local player = player or source
    local inventory_data = player:GetPermanentData( "inventory_data" )
    Inventory_LoadPlayer( player, inventory_data )
end
addEventHandler( "onPlayerCompleteLogin", root, Inventory_ReadyPlayerServerside, true, "high+999999999" )

function CleanupPlayerInventoryData()
	INVENTORIES[ source ] = nil
end
addEventHandler( "onPlayerPreLogout", root, CleanupPlayerInventoryData, true, "low-1000000000" )

function onResourceStart()
    setTimer( function( )
        for i, v in pairs( getElementsByType( "player") ) do
            Inventory_ReadyPlayerServerside( v )
        end
    end, 2000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart )

-- function AdminForceInventoryOverwrite( player, target )
--     if target then
--         if type( target ) == "table" then
--             INVENTORIES[ player ].data = target
--         else
--             player:SetPermanentData( "old_items_to_restore", INVENTORIES[ player ].data )
--             INVENTORIES[ player ].data = INVENTORIES[ target ]
--         end
--     elseif player:GetPermanentData( "old_items_to_restore" ) then
--         INVENTORIES[ player ].data = player:GetPermanentData( "old_items_to_restore" )
--         player:SetPermanentData( "old_items_to_restore", nil )
--     else
--         cancelEvent()
--         return
--     end
--     player:triggerEvent( "SyncInventory", resourceRoot, player, INVENTORIES[ player ].data )
--     -- player:SetPermanentData( "inventory_data", inventory_data )
-- end
-- addEvent("AdminForceInventoryOverwrite")
-- addEventHandler("AdminForceInventoryOverwrite", root, AdminForceInventoryOverwrite)




if SERVER_NUMBER > 100 then

    function onDebugMessage_handler( message, level, file, line, r, g, b )
        if level == 1 and tete then
            iprint( tete )
        end
    end
    addEventHandler( "onDebugMessage", root, onDebugMessage_handler )

    addCommandHandler( "set_old_data", function( player )
        player:SetPermanentData( "inventory_data", nil )
        player:SetPermanentData( "items", fromJSON( '[[[1],[2],[34],[5],[5],[5],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[11,[3]],[5],[14],[14],[14],[5],[5],[5],[5],[14],[14],[5],[5],[14],[14],[5],[5],[14],[14],[5],[5],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[6],[6],[5],[5],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6,[]],[6,[]],[53],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[14],[12,[22]],[12,[22]],[12,[22]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[30]],[12,[34]],[12,[34]],[12,[34]],[12,[34]],[12,[34]],[11,[2]],[11,[2]],[11,[2]],[11,[3]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[24]],[12,[34]],[12,[34]],[12,[34]],[12,[34]],[12,[34]],[12,[34]],[12,[29]],[12,[29]],[12,[29]],[12,[29]],[12,[22]],[12,[22]],[12,[22]],[12,[22]],[12,[22]],[12,[22]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[5],[5],[6],[6],[14],[14],[14],[12,[34,30]],[12,[29]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[34,30]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[22]],[12,[22]],[12,[29]],[12,[34]],[12,[30]],[12,[29]],[12,[22]],[12,[24]],[12,[30]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[34]],[12,[41]],[12,[41]],[12,[41]],[12,[30]],[12,[41]],[12,[41]],[12,[41]],[12,[34]],[12,[29]],[12,[41]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[22]],[12,[22]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[29]],[12,[30]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[29]],[12,[22]],[12,[41]],[12,[41]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[29]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24,10]],[12,[22]],[12,[29]],[12,[34]],[12,[24]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[5],[5],[6],[6],[14],[14],[14],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[29]],[12,[34]],[12,[24]],[12,[30]],[12,[34,30]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24,10]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[29]],[12,[34]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[5],[5],[14],[14],[14],[6],[6],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[29]],[12,[34]],[12,[24]],[5],[5],[14],[14],[14],[6],[6],[5],[5],[14],[14],[14],[6],[6],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[14],[6],[6],[6],[6],[6],[15],[15],[15],[5],[5],[14],[6],[6],[6],[6],[6],[15],[15],[15],[15],[15],[5],[5],[14],[6],[6],[6],[6],[6],[5],[5],[6],[6],[14],[14],[14],[5],[5],[6],[6],[14],[14],[5],[5],[6],[6],[14],[14],[15],[5],[5],[5],[5],[14],[47],[15],[5],[5],[5],[5],[5],[5],[5],[14],[14],[6],[6],[15],[5],[5],[5],[47],[5],[5],[5],[14],[5],[5],[5],[14],[5],[5],[14],[14],[6],[6],[15],[5],[5],[14],[47],[5],[5],[5],[5],[5],[5],[5],[14],[14],[6],[6],[5],[15],[14],[5],[15],[47],[5],[5],[5],[5],[5],[14],[14],[6],[6],[5],[5],[47],[15],[5],[14],[5],[5],[14],[14],[6],[6],[5],[5],[15],[5],[14],[5],[5],[14],[14],[6],[6],[5],[5],[5],[5],[5],[47],[15],[5],[14],[5],[5],[14],[14],[6],[6],[15],[5],[14],[5],[5],[14],[14],[6],[6],[15],[5],[14],[5],[5],[14],[14],[6],[6],[15],[5],[14],[5],[5],[14],[14],[6],[6],[5],[5],[5],[5],[5],[47],[15],[5],[14],[5],[5],[14],[14],[6],[6],[5],[5],[5],[5],[5],[47],[5],[5],[14],[14],[6],[6],[5],[5],[14],[14],[6],[6],[5],[5],[14],[14],[6],[6],[5],[5],[5],[5],[5],[6],[6],[14],[14],[14],[32],[5],[5],[6],[6],[14],[14],[14],[5],[5],[14],[14],[6],[6],[5],[5],[6],[6],[14],[14],[14],[15],[5],[5],[14],[5],[5],[5],[5],[14],[14],[6],[6],[5],[5],[14],[14],[6],[6],[57,{"level":"I","multiplier":0,"amount":2}],[57,{"level":"I","multiplier":0,"amount":2}],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[29]],[15],[5],[15],[5],[5],[14],[14],[6],[6],[12,[24]],[12,[30]],[15],[5],[14],[12,[29,150]],[12,[34,30]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[5],[5],[5],[5],[5],[6],[6],[6],[11,[1]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[14],[14],[14],[5],[5],[5],[5],[5],[5],[5],[6],[14],[14],[14],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[5],[6],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[69],[69],[69],[69],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[69],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[66],[66],[66],[66],[66],[66],[66],[66],[66],[66],[66],[12,[22]],[66],[66],[12,[29]],[12,[34]],[12,[24]],[12,[30]],[12,[29,150]],[12,[34,30]],[12,[29]],[12,[41]],[12,[41]],[12,[41]],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[69],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[29]],[12,[34]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[68,[1]],[69],[69],[69],[69],[69],[69],[69],[69],[70],[70],[70],[70],[70],[70],[70],[70],[70],[70],[15],[15],[15],[12,[29]],[12,[34]],[12,[24]],[12,[29]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[22]],[12,[29]],[12,[34]],[12,[24]],[12,[30]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[24]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[12,[41]],[54,{"amount":1,"level":"II"}],[55,{"level":"II","multiplier":10,"amount":2}],[55,{"level":"II","multiplier":10,"amount":2}],[55,{"level":"II","multiplier":10,"amount":2}],[55,{"level":"II","multiplier":10,"amount":2}],[55,{"level":"II","multiplier":10,"amount":2}],[42],[38,[6]],[38,[1]],[38,[5]],[38,[1]],[38,[1]],[37,[63]]]]') )
    end )
end