loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SClans" )

SHOP_CLASSES = {
    player = {
        weapon = function( player, data )
            local item = data.item
            player:InventoryAddItem( IN_WEAPON, { item.id }, data.count or 1 )
            player:AddClanStats( "weapons_bought", data.count or 1 )
            triggerEvent( "onPlayerWeaponPurchase", player, item.id, data.count )
        end,

        -- skin = function( player, data )
        --     local item = data.item
        --     player:SetUnlock( "cs_"..item.type.."_"..item.id, true )
        -- end,

        drugs = function( player, data )
            local item = data.item
            player:InventoryAddItem( IN_DRUGS, { item.id }, data.count or 1 )
        end
    },

    clan = {
        weapon = function( clan_id, data )
            CallClanFunction( clan_id, "AddItemToStorage", { type = IN_WEAPON, id = data.item.id, count = data.count or 1 } )
        end,

        drugs = function( clan_id, data )
            CallClanFunction( clan_id, "AddItemToStorage", { type = IN_DRUGS, id = data.item.id, count = data.count or 1 } )
        end
    },
}

function onClanPlayerWantBuyWeapon_handler( shop, cart_items, to_clan_storage )
    local player = client or source

    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local total_cost = 0
    local total_items_count = 0

    for k, v in pairs( cart_items ) do
        if v.count >= 1 then
            v.item = SHOP_ASSORTMENT[ v.iid ]

            v.cost = player:GetItemCost( v.item )
            v.total_cost = v.cost * ( v.count or 1 )
            total_cost = total_cost + v.total_cost
            total_items_count = total_items_count + ( v.count or 1 )
        end
    end

    if to_clan_storage then
        local result, error = CallClanFunction( clan_id, "TakeMoney", total_cost )
        if not result then
            player:ShowError( error or "Недостаточно средств в общаке клана!" )
            return
        end
    elseif not to_clan_storage and not player:TakeMoney( total_cost, "clan", shop == "clanpanel" and "clan_shop_purchase" or "clan_huckster_purchase" ) then
		player:EnoughMoneyOffer( "Band shop", total_cost, "onClanPlayerWantBuyWeapon", player, cart_items, to_clan_storage )
        return
    end

    for k, v in pairs( cart_items ) do
        local item = v.item
        if to_clan_storage then
            SHOP_CLASSES.clan[ item.type ]( clan_id, v )
        else
            SHOP_CLASSES.player[ item.type ]( player, v )
        end
        triggerEvent( "onClanShopPurchase", player, item )
    end

    local clan_name = GetClanName( clan_id )
    if to_clan_storage then
        CallClanFunction( clan_id, "AddLogMessage", CLAN_LOG_ITEMS_PURCHASE, -total_cost, player )
        player:ShowSuccess( "Товар доставлен в хранилище клана!" )

        local clan_members_num = GetClanData( clan_id, "members_count" )
        for k, v in pairs( cart_items ) do
            SendElasticGameEvent( player:GetClientID( ), "clan_money_spend", {
                clan_id = clan_id,
                clan_name = clan_name,
                clan_members_num = clan_members_num,
                spend_sum = v.total_cost,
                spend_type = "guns_purch",
                item_name = v.item.key,
            } )
        end
    else
        player:ShowSuccess( "Товар закуплен!" )
        local cart_items_data = { }
        for k, v in pairs( cart_items ) do
            table.insert( cart_items_data, {
                item_name = v.item.key,
                item_id = v.item.id,
                item_count = v.count,
                item_cost_per_item = v.cost,
                item_cost_total = v.total_cost,
                item_type = "common",
                currency = "soft",
            } )
        end
        SendElasticGameEvent( player:GetClientID( ), shop == "clanpanel" and "clan_shop_purchase" or "clan_huckster_purchase", {
            clan_id = clan_id,
            clan_name = clan_name,
            current_lvl_clan = player:GetClanRank( ),
            cart_items = toJSON( cart_items_data, true )
        } )
    end

    triggerClientEvent( player, "onClanCartCleanRequest", player )
end
addEvent( "onClanPlayerWantBuyWeapon", true )
addEventHandler( "onClanPlayerWantBuyWeapon", root, onClanPlayerWantBuyWeapon_handler )