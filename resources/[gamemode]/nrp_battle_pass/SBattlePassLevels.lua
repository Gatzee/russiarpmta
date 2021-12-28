Player.GetBattlePassEXP = function( self )
    return self:GetPermanentData( "bp_exp" ) or 0
end

Player.SetBattlePassEXP = function( self, exp )
    return self:SetPermanentData( "bp_exp", exp )
end

Player.GiveBattlePassEXP = function( self, exp )
	local current_exp = self:GetBattlePassEXP( )
	local current_level = self:GetBattlePassLevel( )

    local boost_coef = self:GetBattlePassBoostCoef( )
    exp = math.floor( exp + exp * boost_coef )

	current_exp = current_exp + exp

    local need_exp = BP_LEVELS_NEED_EXP[ current_level + 1 ]
	if need_exp and current_exp >= need_exp then
        current_exp = current_exp - need_exp
        current_level = current_level + 1

        self:SetBattlePassLevel( current_level )

        local next_need_exp = BP_LEVELS_NEED_EXP[ current_level + 1 ]
        if not next_need_exp then
            current_exp = 0
        elseif current_exp >= next_need_exp then
            self:SetBattlePassEXP( current_exp )
            self:GiveBattlePassEXP( 0 )
            return exp
        end
    end
    self:SetBattlePassEXP( current_exp )
    
	return exp
end

Player.GetBattlePassLevel = function( self )
	return self:GetPermanentData( "bp_level" ) or 0
end

Player.SetBattlePassLevel = function( self, level, is_bought )
    local old_level = self:GetPermanentData( "bp_level" )

    if old_level and level > old_level then
        self:CompleteDailyQuest( "battle_pass_uplvl" )
    end

    for i = old_level + 1, level do
        SendElasticGameEvent( self:GetClientID( ), "battle_pass_level_up", {
            level_num = i,
            season_num = BP_CURRENT_SEASON_ID,
            stage_num = BP_CURRENT_SEASON_STAGE_ID,
            total_boost = math.floor( self:GetBattlePassBoostCoef( ) * 100 + 0.5 ),
            is_bought = tostring( is_bought or false ),
        } )
    end

	return self:SetPermanentData( "bp_level", level )
end

Player.GetBattlePassBoostCoef = function( self )
    local boost_coef = 0
    if self:IsBattlePassBoosterActive( ) then
        boost_coef = boost_coef + BP_BOOSTER_EXP_MULTIPLIER
    end
    if self:IsBattlePassPremiumActive( ) then
        boost_coef = boost_coef + BP_PREMIUM_EXP_MULTIPLIER
    end
    return boost_coef
end

addEvent( "BP:onPlayerWantBuyBooster", true )
addEventHandler( "BP:onPlayerWantBuyBooster", resourceRoot, function( booster_id )
    local player = client

    if BP_CURRENT_SEASON_END_TS <= getRealTimestamp( ) then
        player:ShowInfo( "Сезон уже окончен" )
        return
    end

    local booster = BP_BOOSTERS[ booster_id ]
    if not booster then return end

    local cost, discount = GetBattlePassBoosterCost( booster_id, player )
    if not player:TakeDonate( cost, "battle_pass", "battle_pass_season" .. BP_CURRENT_SEASON_ID ) then
        triggerClientEvent( player, "onShopNotEnoughHard", player, "Battle pass booster", "onPlayerRequestDonateMenu", "donate" )
        return
    end

    local bp_booster_end_ts = player:GetPermanentData( "bp_booster_end_ts" ) or 0
    local timestamp = getRealTimestamp()
    if bp_booster_end_ts < timestamp then
        bp_booster_end_ts = timestamp + booster.days * 24 * 60 * 60
    else
        bp_booster_end_ts = bp_booster_end_ts + booster.days * 24 * 60 * 60
    end
    player:SetPermanentData( "bp_booster_end_ts", bp_booster_end_ts )

    triggerClientEvent( player, "BP:UpdateUI", resourceRoot, { booster_end_ts = bp_booster_end_ts } )
    
    SendElasticGameEvent( player:GetClientID( ), "battle_pass_purchase", {
        id_item = "s" .. BP_CURRENT_SEASON_ID .. "_boost_" .. string.gsub( booster.days, "%.", "" ),
        season_num = BP_CURRENT_SEASON_ID,
        quantity = 1,
        spend_sum = cost,
        currency = "hard",
        discount = discount or 0,
    } )

    triggerEvent( "onServerPlayerPurchaseBattlePassBooster", player )
end )

addEvent( "BP:onPlayerWantBuyLevel", true )
addEventHandler( "BP:onPlayerWantBuyLevel", resourceRoot, function( level )
    local player = client

    if BP_CURRENT_SEASON_END_TS <= getRealTimestamp( ) then
        player:ShowInfo( "Сезон уже окончен" )
        return
    end

    local current_level = player:GetBattlePassLevel()
    if current_level >= level then
        player:ShowInfo( "Вы уже получили этот уровень" )
        return
    end

    local cost, discount = GetBattlePassLevelCost( level, current_level )
    if not player:TakeDonate( cost, "battle_pass", "battle_pass_season" .. BP_CURRENT_SEASON_ID ) then
        triggerClientEvent( player, "onShopNotEnoughHard", player, "Battle pass level", "onPlayerRequestDonateMenu", "donate" )
        return
    end

    player:SetBattlePassLevel( level, true )
    player:SetBattlePassEXP( 0 )

    triggerClientEvent( player, "BP:UpdateUI", resourceRoot, { 
        level = level,
        exp = 0,
    } )
    
    SendElasticGameEvent( player:GetClientID( ), "battle_pass_purchase", {
        id_item = "level_purchase",
        season_num = BP_CURRENT_SEASON_ID,
        quantity = 1,
        spend_sum = cost,
        currency = "hard",
        discount = discount or 0,
    } )
end )