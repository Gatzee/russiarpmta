local playersBuffs = { } -- for others buffs

function addBuff( player, buffName, id, seconds, showAnyway )
    if not playersBuffs[player] then
        playersBuffs[player] = { }
    end

    local generatedTable = { }
    if id then generatedTable.id = id end
    if seconds then generatedTable.timeTo = getRealTimestamp() + seconds end
    if showAnyway then generatedTable.showAnyway = true end

    playersBuffs[player][buffName] = generatedTable
end

function removeBuff( player, buffName )
    if not playersBuffs[player] then return end

    playersBuffs[player][buffName] = nil
end

function getPlayerBuffs( player )
    local allBuffs = { }
    local currentTime = getRealTimestamp()

    local buffFoodIDs = player:GetPermanentData( "food_buff_ids" ) or { }
    local playerFoodBuffs = player:GetPermanentData( "food_buffs" ) or { }

    for index, timeTo in pairs( playerFoodBuffs ) do
        if buffFoodIDs[index] and currentTime < timeTo then
            table.insert( allBuffs, { name = "food", id = buffFoodIDs[index], index = index, timeTo = timeTo })
        end
    end

    for name, data in pairs( playersBuffs[player] or { } ) do
        if currentTime < data.timeTo or data.showAnyway then
            table.insert( allBuffs, { name = name, id = data.id, timeTo = data.timeTo })
        end
    end

    local doubleExp = player:IsBoosterActive( BOOSTER_DOUBLE_EXP )
    if doubleExp then
        table.insert( allBuffs, { name = "exp", timeTo = doubleExp.expires })
    end

    local doubleMoney = player:IsBoosterActive( BOOSTER_DOUBLE_MONEY )
    if doubleMoney then
        table.insert( allBuffs, { name = "soft", timeTo = doubleMoney.expires })
    end

    local playerPartnerID = player:GetPermanentData( "wedding_at_id" )
    if playerPartnerID then
        local partner = GetPlayer( playerPartnerID )
        if partner and isElement( partner ) and getDistanceBetweenPoints3D( player:getPosition( ), partner:getPosition( ) ) <= WEDDING_EXP_BOOST_DISTANCE then
            table.insert( allBuffs, { name = "partner" } )
        end
    end

    local diseases = player:GetPermanentData( "diseases" ) or { }
    for index, disease in pairs( diseases ) do
        if disease.stage > 0 then
            table.insert( allBuffs, { name = "disease", index = index, stage = disease.stage })
        end
    end

    local premiumTo = getElementData( player, "premium_time_left" ) or 0
    local premiumTimeLeft = premiumTo - getRealTimestamp()
    if premiumTimeLeft > 0 then
        table.insert( allBuffs, { name = "premium", timeTo = premiumTo })
    end

    local job_partner = player:getData( "job_partner" )
    if job_partner then
        table.insert( allBuffs, { name = "job_partner" })
    end

    if player:IsNickNameHidden( ) then
        local timeTo = player:GetHideNickExpirationTime( )
        table.insert( allBuffs, { name = "hide_nickname", timeTo = timeTo })
    end

    local hunting = player:getData( "hunting" )
    if hunting then
        table.insert( allBuffs, { name = "order" .. hunting.way, timeTo = hunting.timeTo } )
    end

    if player:IsInClan( ) then
        local dubplicate_data = {}
        for upgrade_id, lvl in pairs( exports.nrp_clans_buffs:GetPlayerClanBuffs( player ) or { } ) do
            
            local buff_value = CLAN_UPGRADES_LIST[ upgrade_id ][ lvl ].buff_value
            if CLAN_UPGRADES_LIST[ upgrade_id ].dupblicate then
                table.insert( dubplicate_data, { id = upgrade_id, buff_value = buff_value } )
            else
                table.insert( allBuffs, { name = "clan_buff", id = upgrade_id, lvl = lvl, buff_value = buff_value } )
            end
        end

        for k, v in pairs( dubplicate_data ) do
            for _, data in pairs( allBuffs ) do
                if data.name == "clan_buff" and CLAN_UPGRADES_LIST[ v.id ].dupblicate == data.upgrade_id then
                    data.buff_value = data.buff_value + v.buff_value
                end
            end
        end
    end

    return allBuffs
end

addEventHandler( "onPlayerQuit", root, function ( )
    playersBuffs[source] = nil
end )