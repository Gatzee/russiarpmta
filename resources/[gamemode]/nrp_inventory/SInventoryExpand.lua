local ANALYTICS_NAMES = {
    player  = "invent_pers_up",
    vehicle = "invent_car_up" ,
    house   = "invent_box_up" ,
}

function onPlayerWantExpandInventory_handler( inventory_owner )
    if not inventory_owner then return end

	local player = client
    local owner_type = inventory_owner.type or "house"
	local service = SHOP_SERVICES[ "inventory_" .. owner_type ]
	local cost = service.cost

    if player:GetDonate( ) < cost then
        triggerClientEvent( player, "onShopNotEnoughHard", player, "Inventory Expand" )
        return
    end

    if not player:HasAccessToInventoryOf( inventory_owner ) then return end

    Inventory_Expand( inventory_owner, service.value, player )

    local analytics_name = ANALYTICS_NAMES[ owner_type ]
    player:TakeDonate( cost, "f4_service", analytics_name )
    player:InfoWindow( "Инвентарь успешно расширен!" )
    player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )

    SendElasticGameEvent( player:GetClientID( ), "f4_service_purchase", {
        item = analytics_name,
        cost = cost,
        quantity = 1,
        spend_sum = cost,
        currency = "hard",
    } )

    SendElasticGameEvent( player:GetClientID( ), "f4r_f4_services_purchase", { service = analytics_name } )
end
addEvent( "onPlayerWantExpandInventory", true )
addEventHandler( "onPlayerWantExpandInventory", root, onPlayerWantExpandInventory_handler )

function Inventory_Expand( inventory_owner, add_value, player )
    local inventory = INVENTORIES[ inventory_owner ]
    local expand_value = inventory and inventory.expand_value or inventory_owner:GetPermanentData( "inventory_expand" ) or 0
    local new_expand_value = expand_value + add_value
    if inventory then
        inventory.expand_value = new_expand_value
        inventory.max_weight = inventory.max_weight + add_value
        if player then
            player:triggerEvent( "ExpandInventory", resourceRoot, inventory_owner, inventory.max_weight )
        end
    end

    if inventory and inventory.house then
        local id, number = unpack( inventory.house )
        if id > 0 then
            exports.nrp_apartment:SetApartmentsData( id, number, "inventory_expand", new_expand_value )
        else
            exports.nrp_vip_house:SetViphouseData( number, "inventory_expand", new_expand_value )
        end
    else
        inventory_owner:SetPermanentData( "inventory_expand", new_expand_value )
    end
end

Player.HasAccessToInventoryOf = function( self, owner )
    return owner == self
        or owner.type == "vehicle" and self:GetID() == owner:GetOwnerID() 
        or type( owner ) == "string" and self:HasAccessToHouse( owner )
end