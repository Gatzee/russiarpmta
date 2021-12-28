-- default events

addEventHandler( "onPlayerWasted", root, function ( _, killer )
    if killer and killer.type == "player" and killer ~= source and killer.dimension == 0 then
        local counter2 = killer:GetPermanentData( "kill_counter" ) or 0
        killer:SetPermanentData( "kill_counter", counter2 + 1 )

        if killer:GetFaction( ) == F_ARMY or killer:getData( "incasator_unload_bags" ) then return end
        killer:ChangeSocialRating( SOCIAL_RATING_RULES.kill.rating )
    end

    if source.dimension == 0 then
        local counter = source:GetPermanentData( "death_counter" ) or 0
        source:SetPermanentData( "death_counter", counter + 1 )
    end
end )

-- custom events

addEvent( "onJobEarnMoney", true )
addEventHandler( "onJobEarnMoney", root, function ( _, money_reward )
    local rewards = source:GetPermanentData( "jobs_cash_rewards" ) or 0
    source:SetPermanentData( "jobs_cash_rewards", rewards + money_reward )
end )

addEvent( "onHobbyEarnMoney", true )
addEventHandler( "onHobbyEarnMoney", root, function ( _, _, money_reward )
    local rewards = source:GetPermanentData( "hobby_cash_rewards" ) or 0
    source:SetPermanentData( "hobby_cash_rewards", rewards + money_reward )
end )

addEvent( "onPlayerJoinToEvent", true )
addEventHandler( "onPlayerJoinToEvent", root, function (  )
    local counter = source:GetPermanentData( "join_events_counter" ) or 0
    source:SetPermanentData( "join_events_counter", counter + 1 )
end )

addEvent( "onPlayerAddWanted", true )
addEventHandler( "onPlayerAddWanted", root, function ( sArticle )
    if source.dimension ~= 0 or source.interior ~= 0 then return end

    local counter = source:GetPermanentData( "wanted_counter" ) or 0
    source:SetPermanentData( "wanted_counter", counter + 1 )

    local reasons = {
        ["1.4"] = SOCIAL_RATING_RULES.attack.rating,
        ["1.5"] = SOCIAL_RATING_RULES.damage_private.rating,
        ["1.6"] = SOCIAL_RATING_RULES.damage_gov.rating,
        ["1.7"] = SOCIAL_RATING_RULES.vandalism.rating,
        ["1.9"] = SOCIAL_RATING_RULES.weapon.rating,
        ["3.1"] = SOCIAL_RATING_RULES.escape.rating,
        -- ["1.1"] = SOCIAL_RATING_RULES.kill.rating,
        ["1.2"] = SOCIAL_RATING_RULES.offense.rating,
        ["1.3"] = SOCIAL_RATING_RULES.attack_gov.rating,
        ["1.11"] = SOCIAL_RATING_RULES.nonpayment.rating,
    }

    if reasons[sArticle] then
        source:ChangeSocialRating( reasons[sArticle] )
    end
end )

-- custom events part #2

addEvent( "onPlayerChangeAlcoIntexiation", true )
addEventHandler( "onPlayerChangeAlcoIntexiation", root, function ( levelNum, seconds )
    if not isElement( client ) or client ~= source or levelNum < 1 then return end

    if levelNum < 5 then
        addBuff( client, "alco", levelNum, seconds )
        client:ChangeSocialRating( SOCIAL_RATING_RULES.alcohol.rating )
    else
        removeBuff( client, "alco" )
    end
end )

addEvent( "onPlayerChangeDrugIntexiation", true )
addEventHandler( "onPlayerChangeDrugIntexiation", root, function ( drugNum, seconds )
    if not isElement( client ) or client ~= source or drugNum < 1 or drugNum > 3 then return end

    addBuff( client, "drug", drugNum, seconds )
    client:ChangeSocialRating( SOCIAL_RATING_RULES.drug.rating )
end )

-- custom events part #3

local function expChangeHandler( value, oldValue, isFaction )
    if not oldValue then return end

    local exp_cache = source:GetPermanentData( "exp_cache", value ) or 0
    local difference = value - oldValue

    if difference > 0 then
        exp_cache = exp_cache + difference

        if exp_cache >= 100 then
            local count = math.floor( exp_cache / 100 )
            local countSocialRating = count * ( isFaction and SOCIAL_RATING_RULES.faction_exp.rating or SOCIAL_RATING_RULES.clan_exp.rating )

            exp_cache = exp_cache - 100 * count
            source:ChangeSocialRating( countSocialRating )
        end

        source:SetPermanentData( "exp_cache", exp_cache )
    else
        source:SetPermanentData( "exp_cache", 0 )
    end
end

addEvent( "onFactionEXPChange", false )
addEventHandler( "onFactionEXPChange", root, function ( value, oldValue )
    expChangeHandler( value, oldValue, true )
end )

addEvent( "onClanEXPChange", false )
addEventHandler( "onClanEXPChange", root, function ( value, oldValue )
    expChangeHandler( value, oldValue, false )
end )