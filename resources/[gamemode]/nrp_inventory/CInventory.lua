loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ib" )
Extend( "ib/navbar" )

ibUseRealFonts( true )

PLAYER_INVENTORY = nil
OTHER_INVENTORY = {}

-- Принятие полной синхронизации инвентаря
addEvent( "SyncInventory", true )
addEventHandler( "SyncInventory", resourceRoot, function( owner, data, max_weight, hotbar_items )
    local inventory = CreateInventory( owner, data, max_weight )
    CalculateCategoriesWeights( inventory )

    if owner == localPlayer then
        PLAYER_INVENTORY = inventory
        GiveClientsideItems()

        CreateInventoryHotbar( hotbar_items )

        local slow_walk = false
        setTimer( function()
            local weight_ratio = PLAYER_INVENTORY.total_weight / PLAYER_INVENTORY.max_weight 
            local is_inventory_full = weight_ratio >= 1
            toggleControl( "sprint", not is_inventory_full )
            localPlayer:setData( "is_inventory_full", is_inventory_full and weight_ratio or false, false )
        end, 1000, 0 )
    end
end )

addEvent( "ShowInventory", true )
addEventHandler( "ShowInventory", resourceRoot, function( owner, data, max_weight )
    if OTHER_INVENTORY.UI then
        OTHER_INVENTORY.UI:Destroy()
    end
    OTHER_INVENTORY = CreateInventory( owner, data, max_weight )
    CalculateCategoriesWeights( OTHER_INVENTORY )
    ShowUIInventory( true )
    InventoryUI.Create( OTHER_INVENTORY )
    HOTBAR:onOtherInventoryOpen()
end )

addEvent( "CloseInventory", true )
addEventHandler( "CloseInventory", root, function( owner )
    if OTHER_INVENTORY.owner == owner and OTHER_INVENTORY.UI then
        OTHER_INVENTORY.UI:Destroy()
    end
end )

addEvent( "AddInventory", true )
addEventHandler( "AddInventory", resourceRoot, function( owner, item_id, attributes, count, temp )
    local inventory = INVENTORIES[ owner ]
    if not inventory then return end

    if owner == localPlayer then
        HOTBAR:AddItemToFreeSlot( item_id, attributes )
    end
    inventory:AddItem( item_id, attributes, count, temp )
end )

addEvent( "RemoveInventory", true )
addEventHandler( "RemoveInventory", resourceRoot, function( owner, item_id, attributes, count, temp )
    local inventory = INVENTORIES[ owner ]
    if not inventory then return end

    inventory:RemoveItem( item_id, attributes, count, temp )
end )

addEvent( "ExpandInventory", true )
addEventHandler( "ExpandInventory", resourceRoot, function( owner, new_max_weight )
    local inventory = INVENTORIES[ owner ]
    if not inventory then return end

    inventory.max_weight = new_max_weight
    if inventory.UI then
        inventory.UI:UpdateTotalWeight( )
    end
end )

function UseItem( item_id, attributes, target )
    if localPlayer.dead then return end

    local item_conf = ITEMS_CONFIG[ item_id ]
    local result, error
    if type( item_conf[ CLIENTSIDE_CHECK ] ) == "function" then
        result, error = item_conf[ CLIENTSIDE_CHECK ]( item_conf, item_id, attributes or {}, target )
        if not result then
            if error then localPlayer:ShowError( error ) end
            return false
        end
    end

    INVENTORY_LOCKED = true
    INVENTORY_LOCKED_TIMER = Timer( function( ) INVENTORY_LOCKED = nil end, 5000, 1 )

    if type( item_conf[ CLIENTSIDE_SUCCESS ] ) == "function" then
        item_conf[ CLIENTSIDE_SUCCESS ]( item_conf, item_id, attributes or {}, target, error )
    end

    target = target and not isElementLocal( target ) and target
    triggerServerEvent( "InventoryUse", resourceRoot, item_id, attributes, target )
end

addEvent( "InventoryUseSuccess", true )
addEventHandler( "InventoryUseSuccess", resourceRoot, function( owner, item_id, attributes, keep_node )
    local inventory = INVENTORIES[ owner ]
    if not inventory then return end

    if not keep_node then
        inventory:RemoveItem( item_id, attributes, 1 )
    end
    if isTimer( INVENTORY_LOCKED_TIMER ) then killTimer( INVENTORY_LOCKED_TIMER ) end
    INVENTORY_LOCKED = nil
end )

function CalculateCategoriesWeights( inventory )
    inventory.categories_weights = {}
    local categories_weights = inventory.categories_weights
    for i, cat_info in pairs( CATEGORIES ) do
        categories_weights[ cat_info.category ] = 0
    end
    for item_id, item_container in pairs( inventory.data ) do
        local category = ITEMS_CONFIG[ item_id ][ CATEGORY ] or "stuff"
        if item_container[ 1 ] > 0 then
            categories_weights[ category ] = categories_weights[ category ] + GetItemWeight( item_id, _, item_container[ 1 ] )
        end
        for i = 2, #item_container do
            categories_weights[ category ] = categories_weights[ category ] + GetItemWeight( item_id, item_container[ i ] )
        end
    end
end

function onInventoryChange( inventory, item_id, delta_weight )
    local category = ITEMS_CONFIG[ item_id ][ CATEGORY ] or "stuff"
    inventory.categories_weights[ category ] = inventory.categories_weights[ category ] + delta_weight

    if inventory.UI then
        inventory.UI:Update( )
    end
    if HOTBAR and inventory.owner == localPlayer then
        HOTBAR:Update()
    end
end

-- Чисто клиентские предметы

function GiveClientsideItems()
    PLAYER_INVENTORY:AddIfNotExists( IN_PASSPORT )
    PLAYER_INVENTORY:AddIfNotExists( IN_JOB_HISTORY )

    if localPlayer:GetMilitaryLevel() >= 4 then
        PLAYER_INVENTORY:AddIfNotExists( IN_MILITARY )
    end

    if localPlayer:IsUrgentMilitaryVacation() then
        PLAYER_INVENTORY:AddIfNotExists( IN_ARMYFREE )
    end

    if POLICEID_FACTIONS[ localPlayer:GetFaction() ] then
        PLAYER_INVENTORY:AddIfNotExists( IN_POLICEID )
    end

    if ( localPlayer:getData( "gun_licenses" ) or 0 ) > getRealTimestamp() then
        PLAYER_INVENTORY:AddIfNotExists( IN_POLICEID )
    end
end

addEventHandler( "onClientElementDataChange", localPlayer, function( key, old_value, new_value )
    if not PLAYER_INVENTORY then return end
    if key == "faction_id" then
        if POLICEID_FACTIONS[ localPlayer:GetFaction() ] then
            PLAYER_INVENTORY:AddIfNotExists( IN_POLICEID )
        else
            PLAYER_INVENTORY:RemoveItem( IN_POLICEID )
        end
    elseif key == "military_level" then
        if localPlayer:GetMilitaryLevel() >= 4 then
            PLAYER_INVENTORY:AddIfNotExists( IN_MILITARY )
        end
    elseif key == "urgent_military_vacation" then
        if new_value then
            PLAYER_INVENTORY:AddIfNotExists( IN_ARMYFREE )
        else
            PLAYER_INVENTORY:RemoveItem( IN_ARMYFREE )
        end
    elseif key == "gun_licenses" then
        if new_value then
            PLAYER_INVENTORY:AddIfNotExists( IN_GUN_LICENSE )
        else
            PLAYER_INVENTORY:RemoveItem( IN_GUN_LICENSE )
        end
    end
end )

function RefreshVehiclePassport( vehicle, seat )
    if vehicle and seat ~= 0 then return end
    if vehicle and vehicle:GetOwnerID() ~= localPlayer:GetUserID() then return end
    PLAYER_INVENTORY:AddIfNotExists( IN_VEHICLE_PASSPORT )
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, RefreshVehiclePassport )
addEvent( "RefreshVehiclePassport", true )
addEventHandler( "RefreshVehiclePassport", root, RefreshVehiclePassport )