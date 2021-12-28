Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "rewards/Server" )

Player.ResetAllBattlePassData = function( self )
	self:SetBatchPermanentData( {
        bp_last_season_start_ts = BP_CURRENT_SEASON_START_TS,
        bp_tasks = { },
        bp_rewards = { },
        bp_exp = 0,
        bp_level = 0,
        bp_premium_purchase_ts = false,
        bp_booster_end_ts = false,
        bp_task_skip_count = false,
    } )
end

Player.IsBattlePassBoosterActive = function( self )
	return ( self:GetPermanentData( "bp_booster_end_ts" ) or 0 ) > getRealTimestamp( )
end
IsPlayerBoosterActive = Player.IsBattlePassBoosterActive

Player.IsBattlePassPremiumActive = function( self )
	return ( self:GetPermanentData( "bp_premium_purchase_ts" ) or 0 ) > BP_CURRENT_SEASON_START_TS
end
IsPlayerPremiumActive = Player.IsBattlePassPremiumActive

function onPlayerCompleteLogin_handler( player )
    player = isElement( player ) and player or source
    local bp_last_season_start_ts = player:GetPermanentData( "bp_last_season_start_ts" )
    if ( bp_last_season_start_ts or 0 ) < BP_CURRENT_SEASON_START_TS then
        player:ResetAllBattlePassData( )
    else
        local data = player:GetBatchPermanentData( "bp_tasks", "bp_rewards" )
        data.bp_tasks = FixTableKeys( data.bp_tasks, true )
        data.bp_rewards = FixTableKeys( data.bp_rewards, true )
        player:SetBatchPermanentData( data )
    end
end
addEvent( "onPlayerCompleteLogin" )
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

addEventHandler( "onResourceStart", resourceRoot, function( )
    for i, player in pairs( GetPlayersInGame( ) ) do
        onPlayerCompleteLogin_handler( player )
    end
end )

addEvent( "onPlayerReadyToPlay" )
addEventHandler( "onPlayerReadyToPlay", root, function( )
    local player = source

    if BP_CURRENT_SEASON_END_TS < getRealTimestamp( ) then return end
    if not player:HasFinishedTutorial( ) then return end
    
    triggerClientEvent( player, "BP:ShowLoginWindow", resourceRoot, ( GetPlayerAvailableRewardsCount( player ) or 0 ) > 0 )
end )

function GetPlayerAvailableRewardsCount( player )
    if BP_CURRENT_SEASON_END_TS < getRealTimestamp( ) then return end

    local count = 0
    local rewards = player:GetPermanentData( "bp_rewards" ) or { }
    for i, type in pairs( { "free", player:IsBattlePassPremiumActive( ) and "premium" or nil } ) do
        for level = 1, player:GetBattlePassLevel( ) do
            if ( not rewards[ type ] or not rewards[ type ][ level ] ) and BP_LEVELS_REWARDS[ type ][ level ] then
                count = count + 1
            end
        end
    end

    return count > 0 and count or nil
end

addEvent( "BP:onPlayerWantTakeReward", true )
addEventHandler( "BP:onPlayerWantTakeReward", resourceRoot, function( level, is_premium, args )
    local player = client
    local rewards = player:GetPermanentData( "bp_rewards" ) or { }

    local type = is_premium and "premium" or "free"
    if not rewards[ type ] then
        rewards[ type ] = { }
    end

    if rewards[ type ][ level ] then return end
    if player:GetBattlePassLevel( ) < level then return end

    if is_premium and not player:IsBattlePassPremiumActive( ) then
        player:ShowError( "Необходимо приобрести доступ к премиум-наградам" )
        return
    end

    rewards[ type ][ level ] = true
    player:SetPermanentData( "bp_rewards", rewards )

    local reward = BP_LEVELS_REWARDS[ type ][ level ]

    if not args then args = { } end
    args.source = "battle_pass"
    args.source_type = "battle_pass_season" .. BP_CURRENT_SEASON_ID
    reward.Give( player, reward, args, reward.cost )

    triggerClientEvent( player, "BP:onClientRewardTake", resourceRoot, level, is_premium )

    local description_data = reward.uiGetDescriptionData( reward.type, reward )
    local analytics_data = reward.GetAnalyticsData and reward.GetAnalyticsData( player, reward, args ) or { }
    local name = ( analytics_data.name or description_data.title or reward.name ):gsub( "\n", " " )
    SendElasticGameEvent( player:GetClientID( ), "battle_pass_take_reward", {
        season_num  = BP_CURRENT_SEASON_ID                                           ,
        id_reward   = tostring( analytics_data.id or reward.id or reward.type )      ,
        type_reward = reward.type                                                    ,
        name_reward = Translit( name or "" )                                         ,
        type_line   = type                                                           ,
        quantity    = reward.count or 1                                              ,
        receive_sum = analytics_data.cost or ( reward.cost * ( reward.count or 1 ) ) ,
        currency    = "hard"                                                         ,
    } )
end )

addEvent( "BP:onPlayerWantBuyPremium", true )
addEventHandler( "BP:onPlayerWantBuyPremium", resourceRoot, function( from_take_button )
    local player = client

    if BP_CURRENT_SEASON_END_TS <= getRealTimestamp( ) then
        player:ShowInfo( "Сезон уже окончен" )
        return
    end

    if player:IsBattlePassPremiumActive( ) then
        player:ShowInfo( "Вы уже приобрели премиум" )
        return
    end

    local cost, discount = GetBattlePassPremuimCost( )
    if not player:TakeDonate( cost, "battle_pass", "battle_pass_season" .. BP_CURRENT_SEASON_ID ) then
        triggerClientEvent( player, "onShopNotEnoughHard", player, "Battle pass premium", "onPlayerRequestDonateMenu", "donate" )
        return
    end

    player:SetPermanentData( "bp_premium_purchase_ts", getRealTimestamp( ) )
    player:GiveBattlePassEXP( 1000 )

    triggerClientEvent( player, "BP:UpdateUI", resourceRoot, {
        is_premium_active = true,
        level = player:GetBattlePassLevel( ),
        exp = player:GetBattlePassEXP( ),
    } )

    SendElasticGameEvent( player:GetClientID( ), "battle_pass_purchase", {
        id_item = "premium",
        season_num = BP_CURRENT_SEASON_ID,
        quantity = 1,
        spend_sum = cost,
        currency = "hard",
        discount = discount or 0,
    } )

    triggerEvent( "onServerPlayerPurchaseBattlePassPremium", player )
end )

addEvent( "BP:onPlayerWantShowUI", true )
addEventHandler( "BP:onPlayerWantShowUI", root, function( )
    local player = client or source

    if BP_CURRENT_SEASON_END_TS > getRealTimestamp( ) then
        local data = player:GetBatchPermanentData( "bp_tasks", "bp_rewards", "bp_exp", "bp_level", "bp_booster_end_ts", "bp_task_skip_count" )
        triggerClientEvent( player, "BP:ShowUI", resourceRoot, true, {
            tasks = data.bp_tasks,
            rewards = data.bp_rewards,
            exp = data.bp_exp,
            level = data.bp_level,
            booster_end_ts = data.bp_booster_end_ts,
            is_premium_active = player:IsBattlePassPremiumActive( ),
            task_skip_count = data.bp_task_skip_count,
        } )
    else
        player:InfoWindow( "Текущий сезон закончился.\nОжидайте начала следующего." )
    end
end )



----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

if SERVER_NUMBER > 100 then

    

end