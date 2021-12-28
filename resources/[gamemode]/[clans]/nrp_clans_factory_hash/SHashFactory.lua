function onPlayerWantShowUI( )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    triggerClientEvent( player, "CHF:ShowUI", resourceRoot, true, {
        upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_HASH_FACTORY ),
        items = GetClanData( clan_id, "hash_factory" ),
    } )
end
addEvent( "CHF:onPlayerWantShowUI", true )
addEventHandler( "CHF:onPlayerWantShowUI", resourceRoot, onPlayerWantShowUI )

function onPlayerWantAddRawMaterial( slot )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    if player:InventoryGetItemCount( IN_HASH_RAW ) <= 0 then
        return
    end

    local hash_factory = GetClanData( clan_id, "hash_factory" ) or { }
    if hash_factory[ slot ] then
        return
    end

    local upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_HASH_FACTORY )
    local factory_conf = FACTORY_UPGRADES[ upgrade_lvl ]

    if slot > factory_conf.max_slots then
        return
    end

    player:InventoryRemoveItem( IN_HASH_RAW, 1 )

    hash_factory[ slot ] = {
        -- quality = GetRandomQuality( factory_conf.quality_chances ),
    }
    SetClanData( clan_id, "hash_factory", hash_factory )

    triggerClientEvent( player, "CHF:UpdateUI", resourceRoot, {
        items = hash_factory,
    } )
end
addEvent( "CHF:onPlayerWantAddRawMaterial", true )
addEventHandler( "CHF:onPlayerWantAddRawMaterial", resourceRoot, onPlayerWantAddRawMaterial )

function onPlayerWantStartMakingProduct( )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local hash_factory = GetClanData( clan_id, "hash_factory" )
    local upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_HASH_FACTORY )
    local factory_conf = FACTORY_UPGRADES[ upgrade_lvl ]

    for slot, item in pairs( hash_factory ) do
        if not item.finish_ts then
            item.finish_ts = getRealTimestamp( ) + factory_conf.making_time - player:GetClanBuffValue( CLAN_UPGRADE_HASH_DRYING_TIME )
        end
    end
    SetClanData( clan_id, "hash_factory", hash_factory )

    triggerClientEvent( player, "CHF:UpdateUI", resourceRoot, {
        items = hash_factory,
    } )
end
addEvent( "CHF:onPlayerWantStartMakingProduct", true )
addEventHandler( "CHF:onPlayerWantStartMakingProduct", resourceRoot, onPlayerWantStartMakingProduct )

function onPlayerWantTakeProduct( slot )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local hash_factory = GetClanData( clan_id, "hash_factory" )
    local item = hash_factory[ slot ]
    if not item then
        return
    end

    if not item.finish_ts or getRealTimestamp( ) < item.finish_ts then
        return
    end

    player:InventoryAddItem( IN_HASH_DRY, nil, 1 )

    hash_factory[ slot ] = nil
    SetClanData( clan_id, "hash_factory", hash_factory )

    triggerClientEvent( player, "CHF:UpdateUI", resourceRoot, {
        items = hash_factory,
    } )
end
addEvent( "CHF:onPlayerWantTakeProduct", true )
addEventHandler( "CHF:onPlayerWantTakeProduct", resourceRoot, onPlayerWantTakeProduct )

function onPlayerWantTakeAllProducts( )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local hash_factory = GetClanData( clan_id, "hash_factory" )
    local upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_HASH_FACTORY )
    local factory_conf = FACTORY_UPGRADES[ upgrade_lvl ]

    local current_ts = getRealTimestamp( )
    local item_count = 0
    for slot, item in pairs( hash_factory ) do
        if item.finish_ts and current_ts >= item.finish_ts then
            item_count = item_count + 1
            hash_factory[ slot ] = nil
        end
    end
    player:InventoryAddItem( IN_HASH_DRY, nil, item_count )

    SetClanData( clan_id, "hash_factory", hash_factory )

    triggerClientEvent( player, "CHF:UpdateUI", resourceRoot, {
        items = hash_factory,
    } )
end
addEvent( "CHF:onPlayerWantTakeAllProducts", true )
addEventHandler( "CHF:onPlayerWantTakeAllProducts", resourceRoot, onPlayerWantTakeAllProducts )

function GetRandomQuality( quality_chances )
	local total_chance_sum = 0
	for _, chance in pairs( quality_chances ) do
		total_chance_sum = total_chance_sum + chance
	end

	local dot = math.random( ) * total_chance_sum
	local current_sum = 0
	
	for i, chance in pairs( quality_chances ) do
		if current_sum <= dot and dot < ( current_sum + chance ) then
			return i
		end

		current_sum = current_sum + chance
	end
end