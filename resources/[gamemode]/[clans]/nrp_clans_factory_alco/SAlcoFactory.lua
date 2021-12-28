function onPlayerWantShowUI( )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    triggerClientEvent( player, "CAF:ShowUI", resourceRoot, true, {
        upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_ALCO_FACTORY ),
        items = GetClanData( clan_id, "alco_factory" ),
    } )
end
addEvent( "CAF:onPlayerWantShowUI", true )
addEventHandler( "CAF:onPlayerWantShowUI", resourceRoot, onPlayerWantShowUI )

function onPlayerWantAddBottle( slot )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    if player:InventoryGetItemCount( IN_BOTTLE ) <= 0 then
        return
    end

    local alco_factory = GetClanData( clan_id, "alco_factory" ) or { }
    if alco_factory[ slot ] then
        return
    end

    local upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_ALCO_FACTORY )
    local alco_factory_conf = FACTORY_UPGRADES[ upgrade_lvl ]

    if slot > alco_factory_conf.max_slots then
        return
    end

    player:InventoryRemoveItem( IN_BOTTLE, 1 )

    alco_factory[ slot ] = {
        quality = GetRandomQuality( alco_factory_conf.quality_chances ),
    }
    SetClanData( clan_id, "alco_factory", alco_factory )

    triggerClientEvent( player, "CAF:UpdateUI", resourceRoot, {
        items = alco_factory,
    } )
end
addEvent( "CAF:onPlayerWantAddBottle", true )
addEventHandler( "CAF:onPlayerWantAddBottle", resourceRoot, onPlayerWantAddBottle )

function onPlayerWantStartMakingAlco( )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local alco_factory = GetClanData( clan_id, "alco_factory" )
    local upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_ALCO_FACTORY )
    local alco_factory_conf = FACTORY_UPGRADES[ upgrade_lvl ]

    for slot, item in pairs( alco_factory ) do
        if not item.finish_ts then
            item.finish_ts = getRealTimestamp( ) + alco_factory_conf.making_time - player:GetClanBuffValue( CLAN_UPGRADE_ALCO_FERMENT_TIME )
        end
    end
    SetClanData( clan_id, "alco_factory", alco_factory )

    triggerClientEvent( player, "CAF:UpdateUI", resourceRoot, {
        items = alco_factory,
    } )
end
addEvent( "CAF:onPlayerWantStartMakingAlco", true )
addEventHandler( "CAF:onPlayerWantStartMakingAlco", resourceRoot, onPlayerWantStartMakingAlco )

function onPlayerWantTakeAlco( slot )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local alco_factory = GetClanData( clan_id, "alco_factory" )
    local item = alco_factory[ slot ]
    if not item then
        return
    end

    if not item.finish_ts or getRealTimestamp( ) < item.finish_ts then
        return
    end

    player:InventoryAddItem( IN_ALCO, { item.quality }, 1 )

    triggerEvent( "onPlayerCollectClanFactoryItem", player, IN_ALCO )

    alco_factory[ slot ] = nil
    SetClanData( clan_id, "alco_factory", alco_factory )

    triggerClientEvent( player, "CAF:UpdateUI", resourceRoot, {
        items = alco_factory,
    } )

    SendElasticGameEvent( player:GetClientID( ), "clan_develop_production", {
        clan_id = clan_id,
        clan_name = GetClanName( clan_id ),
        product_type = "alco",
        product_lvl_num = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_ALCO_FACTORY ),
        product_grade = "grade_" .. item.quality,
    } )
end
addEvent( "CAF:onPlayerWantTakeAlco", true )
addEventHandler( "CAF:onPlayerWantTakeAlco", resourceRoot, onPlayerWantTakeAlco )

function onPlayerWantTakeAllAlco( )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local alco_factory = GetClanData( clan_id, "alco_factory" )

    local current_ts = getRealTimestamp( )
    local item_count_by_quality = { }
    for slot, item in pairs( alco_factory ) do
        if item.finish_ts and current_ts >= item.finish_ts then
            item_count_by_quality[ item.quality ] = ( item_count_by_quality[ item.quality ] or 0 ) + 1
            alco_factory[ slot ] = nil
        end
    end

    local client_id = player:GetClientID( )
    local clan_name = GetClanName( clan_id )
    local upgrade_lvl = GetClanUpgradeLevel( clan_id, CLAN_UPGRADE_ALCO_FACTORY )

    for quality, count in pairs( item_count_by_quality ) do
        player:InventoryAddItem( IN_ALCO, { quality }, count )
        triggerEvent( "onPlayerCollectClanFactoryItem", player, IN_ALCO, count )

        for i = 1, count do
            SendElasticGameEvent( client_id, "clan_develop_production", {
                clan_id = clan_id,
                clan_name = clan_name,
                product_type = "alco",
                product_lvl_num = upgrade_lvl,
                product_grade = "grade_" .. quality,
            } )
        end
    end

    SetClanData( clan_id, "alco_factory", alco_factory )

    triggerClientEvent( player, "CAF:UpdateUI", resourceRoot, {
        items = alco_factory,
    } )
end
addEvent( "CAF:onPlayerWantTakeAllAlco", true )
addEventHandler( "CAF:onPlayerWantTakeAllAlco", resourceRoot, onPlayerWantTakeAllAlco )

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