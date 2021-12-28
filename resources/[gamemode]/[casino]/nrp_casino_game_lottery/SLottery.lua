Extend( "SPlayer" )
Extend( "SVehicle" )

LAST_WINNERS = { }

function UpdateLastWinners( player, lottery_id, reward, reward_id )
    if reward.rare >= 5 then
        if not LAST_WINNERS[ lottery_id ] then LAST_WINNERS[ lottery_id ] = { } end
        table.insert( LAST_WINNERS[ lottery_id ], 1, { name = player:GetNickName( ), reward_id = reward_id } )
        if #LAST_WINNERS[ lottery_id ] > 4 then
            table.remove( LAST_WINNERS[ lottery_id ] )
        end
        triggerClientEvent( player, "onClientUpdateLotteryLastWinners", resourceRoot, lottery_id, LAST_WINNERS[ lottery_id ] )
    end
end

function TryFixFuckingProgressionRewards( player )
    local id = "theme_20"
    local cur_reward_id = GetLotteryRewardIdByPoints( player:GetProgressionPointsCount( id ) )
    if cur_reward_id > 1 then
        local reward_id = nil
        local is_premium_active = player:IsPremiumActive()
        local received_awards = player:GetReceivedAwards()
        if not received_awards[ id ] then return end
        for i = 1, #CONST_PROGRESSION_POINTS do
            if not received_awards[ id ][ is_premium_active and "Premium" or "Common" ][ i ] and i < cur_reward_id then
                reward_id = i
                break
            end
        end

        if not reward_id or player:IsRewardReceived( id, reward_id ) then return end

        progression_reward, season_num = GetLotteryProgressionRewards( id, is_premium_active, reward_id )
        progression_reward.lottery_id = id
        
        progression_reward.is_progression_reward = true
        progression_reward.reward_num = reward_id
        progression_reward.season_num = season_num

        player:SetPermanentData( "lottery_reward", progression_reward )
        player:SetReceivedReward( id, is_premium_active, reward_id )
    end
end

function onPlayerLotteryPlayStart_handler( )
    local player = client
    if player:getData( "in_casino" ) then return end
    
    local last_season_num = player:GetLastSeasonNum()
    local cur_season_pr, season_num = GetLotteryProgressionRewards( "classic" )
    if season_num ~= last_season_num then
        player:SetLastSeasonNum( season_num )
        player:ClearProgressionPoints()
        player:ClearReceivedAwards()
    end

    player:setData( "source_dimension", player.dimension, false )
	player:Teleport( nil, player:GetUniqueDimension( ) )
    
    player:SetPrivateData( "in_casino", true )
    addEventHandler( "onPlayerPreLogout", player, onPlayerLotteryPlayStop_handler )
    
    TryFixFuckingProgressionRewards( player )

    local old_reward = player:GetPermanentData( "lottery_reward" )
    if old_reward then
        old_reward.is_shown_again = true
        player:SetPermanentData( "lottery_reward", old_reward )
    end

    triggerClientEvent( player, "ShowLotteryMainUI", resourceRoot, true, {
        old_reward = old_reward,
        last_winners = LAST_WINNERS,
        points = player:GetProgressionPointsData(),
        purchased_tickets = player:GetPurchasedTickets(),
        received_awards = player:GetReceivedAwards(),
    } )
end
addEvent( "onPlayerLotteryPlayStart", true )
addEventHandler( "onPlayerLotteryPlayStart", resourceRoot, onPlayerLotteryPlayStart_handler )

function onPlayerLotteryPlayStop_handler()
    local player = client or source
    
    player:Teleport( nil, player:getData( "source_dimension" ) )
    player:setData( "source_dimension", false, false )
    
    player:SetPrivateData( "in_casino", false )
    removeEventHandler( "onPlayerPreLogout", player, onPlayerLotteryPlayStop_handler )
end
addEvent( "onPlayerLotteryPlayStop", true )
addEventHandler( "onPlayerLotteryPlayStop", resourceRoot, onPlayerLotteryPlayStop_handler )

function onPlayerWantBuyLottery_handler( player, id, variant, count )
    player = client or player
    if not isElement( player ) or not count or count < 0 or not tonumber( count ) then return end

    local access_level = player:GetAccessLevel( )
    if access_level >= 1 and SERVER_NUMBER < 100 then
        local maria_result = MariaGet( "admin_casino_allowed" )
        local data = maria_result and fromJSON( maria_result ) or {}
        if data[ tostring( access_level ) ] ~= 1 and data[ player:GetClientID() ] ~= 1 then
            player:ShowError( "Тебе запрещено играть в казино!" )
            return
        end
    end 

    local lottery_info = LOTTERIES_INFO[ id ]
    if not lottery_info then return end
    if lottery_info.IsActive and not lottery_info:IsActive() then 
        player:ShowError( "Продажа билетов данной лотереи закончилась!" )
        return 
    end 

    local lottery_variant = lottery_info.variants[ variant ]
    if not lottery_variant then return end

    if variant > 3 and not player:IsPremiumActive() then return end

    local discount = GetCurrentQueueDiscount( player:GetQueueCountLotteryTicket(), variant )
    discount = discount and (1 - discount) or 1

    local final_cost = math.floor( lottery_variant.cost * count * discount )
    if lottery_info.cost_is_hard then
        if not player:TakeDonate( final_cost, "casino", "lottery_" .. lottery_info.type ) then
            triggerClientEvent( player, "onShopNotEnoughHard", player, "Casino lottery", "onPlayerRequestDonateMenu", "donate" )
            return
        end
    else
        if not player:TakeMoney( final_cost, "casino", "lottery_" .. lottery_info.type ) then
            player:EnoughMoneyOffer( "lottery", final_cost, "onPlayerWantBuyLottery", resourceRoot, player, id, variant )
            return
        end
    end
    
    player:AddPurchasedTicket( id, variant, count )
    player:AddProgressionPoints( id, variant, count )
    player:AddQueueCountLotteryTicket( count )

    player:CompleteDailyQuest( "play_casino" )
    triggerEvent( "onCasinoPlayersGame", root, CASINO_GAME_LOTTERY, { player } )
    triggerEvent( "onPlayeLotteryPurchase", player, id, variant, count )
    
    SendElasticGameEvent( player:GetClientID( ), "casino_lottery_purchase", {
        lottery_id = id,
        lottery_type = lottery_info.type,
        lottery_theme_name = lottery_info.analytics_name or "null",
        lottery_name = lottery_variant.name,
        lottery_cost = lottery_variant.cost,
        quantity = count,
        currency = lottery_info.cost_is_hard and "hard" or "soft",
    } )

    local received_awards, progression_reward, season_num = nil, nil, nil
    local reward_id = GetLotteryRewardIdByPoints( player:GetProgressionPointsCount( id ) )
    local is_premium_active = player:IsPremiumActive()
    if reward_id > 0 and not player:IsRewardReceived( id, reward_id ) then
        progression_reward, season_num = GetLotteryProgressionRewards( id, is_premium_active, reward_id )
        progression_reward.lottery_id = id
        
        progression_reward.is_progression_reward = true
        progression_reward.reward_num = reward_id
        progression_reward.season_num = season_num

        player:SetPermanentData( "lottery_reward", progression_reward )

        player:SetReceivedReward( id, is_premium_active, reward_id )
        received_awards = player:GetReceivedAwards()
    end

    local cur_discount = GetCurrentQueueDiscount( player:GetQueueCountLotteryTicket(), variant )
    triggerClientEvent( player, "onClientUpdateLotteryData", resourceRoot, variant, player:GetProgressionPointsData(), player:GetPurchasedTickets(), received_awards, progression_reward, cur_discount )
end
addEvent( "onPlayerWantBuyLottery", true )
addEventHandler( "onPlayerWantBuyLottery", resourceRoot, onPlayerWantBuyLottery_handler )

function onServerResetPlayerQueuePurchaseLotteryTicket_handler()
    client:ResetQueueCountLotteryTicket()
end
addEvent( "onServerResetPlayerQueuePurchaseLotteryTicket", true )
addEventHandler( "onServerResetPlayerQueuePurchaseLotteryTicket", resourceRoot, onServerResetPlayerQueuePurchaseLotteryTicket_handler )

function onPlayerWantOpenLottery_handler( player, id, variant )
    player = client or player

    -- Если игрок не забрал по какой-то причине предыдущую награду
    local old_reward = player:GetPermanentData( "lottery_reward" )
    if old_reward then
        -- is_shown_again чтобы исключить багнутые старые награды, которые игрок не смог забрать ещё при открытии уя
        if not old_reward.is_shown_again then
            triggerClientEvent( player, "ShowLotteryReward", resourceRoot, old_reward )
            return
        else
            Debug( player:GetClientID( ) .. " bug reward " .. inspect( old_reward ), 1 )
        end
    end

    local count_purchased_tickets = player:GetCountPurchasedTickets( id, variant )
    if count_purchased_tickets == 0 then return end
    player:TakePurchasedTicket( id, variant, 1 )

    local lottery_info = LOTTERIES_INFO[ id ]
    local lottery_variant = lottery_info.variants[ variant ]

    local reward, reward_id = GetRandomItem( player, lottery_variant.items )
    triggerClientEvent( player, "ShowLotteryScratchRewardUI", resourceRoot, variant, reward, player:GetProgressionPointsData(), player:GetPurchasedTickets() )
    reward.lottery_id = id
    player:SetPermanentData( "lottery_reward", reward )

    UpdateLastWinners( player, id, reward, reward_id )

    SendElasticGameEvent( player:GetClientID( ), "casino_lottery_reward", {
        lottery_id  = id,
        lottery_name = lottery_variant.name,
        lottery_type = lottery_info.type,
        lottery_theme_name = lottery_info.analytics_name or "null",
        reward_name = reward.name,
        reward_cost = reward.cost,
        quantity = 1,
        reward_type = reward.type,
        point_num = player:GetProgressionPointsCount( id ),
    } )
end
addEvent( "onPlayerWantOpenLottery", true )
addEventHandler( "onPlayerWantOpenLottery", resourceRoot, onPlayerWantOpenLottery_handler )

function onPlayerWantTakeLotteryReward_handler( data )
    local player = client
    local reward = player:GetPermanentData( "lottery_reward" )
    if not reward then return end

    if reward.type == "soft" then
        reward.params.source_class = "casino"
        reward.params.source_class_type = "lottery_" .. ( LOTTERIES_INFO[ reward.lottery_id ] and LOTTERIES_INFO[ reward.lottery_id ].type or "classic" )
    end

    if reward.is_progression_reward then
        SendElasticGameEvent( player:GetClientID( ), "casino_lottery_progress_reward", {
            lottery_id  = reward.lottery_id,
            season_num  = reward.season_num,
            reward_name = reward.name,
            reward_cost = reward.cost,
            quantity    = 1,
            reward_num  = reward.reward_num,
        } )
    end

    REGISTERED_ITEMS[ reward.type ].rewardPlayer_func( client, reward.params, reward.cost, data )
    player:SetPermanentData( "lottery_reward", nil )

    if RefreshPlayersTop( player, reward ) then
        triggerClientEvent( player, "onClientUpdateLotteryPlayersTop", resourceRoot, TOP_PLAYERS[ reward.lottery_id ] )
    end
end
addEvent( "onPlayerWantTakeLotteryReward", true )
addEventHandler( "onPlayerWantTakeLotteryReward", resourceRoot, onPlayerWantTakeLotteryReward_handler )

function onPlayerPremium_handler( duration, cost, client_id, is_exten )
    triggerClientEvent( source, "onClientPlayerPremium", source )
end
addEvent( "onPlayerPremium", true )
addEventHandler( "onPlayerPremium", root, onPlayerPremium_handler )

function GetPlayerIncChances( player, lottery_id )
    if player:IsYoutuber( ) then
        return 4, 4
    end
    return 5, 5
end

function GetRandomItem( player, items )
    if SERVER_NUMBER > 100 and player:getData( "__lottery_reward_id" ) then
        local i = player:getData( "__lottery_reward_id" )
        i = items[ i ] and i or #items
        return items[ i ], i
    end

    local inc_chances, from_rare = GetPlayerIncChances( player, lottery_id )
    from_rare = from_rare or 3

	local total_chance_sum = 0
	for _, item in pairs( items ) do
		total_chance_sum = total_chance_sum + item.chance * ( item.rare >= from_rare and inc_chances or 1 )
	end

    
	if total_chance_sum <= 0 then return end

	local dot = math.random( ) * total_chance_sum
	local current_sum = 0

	for i, item in pairs( items ) do
		local item_chance = item.chance * ( item.rare >= from_rare and inc_chances or 1 )

		if current_sum <= dot and dot < ( current_sum + item_chance ) then
			return item, i
		end

		current_sum = current_sum + item_chance
	end
end

function CalculateLotteryItemChances( )
    for lottery_type, lottery in pairs( LOTTERIES_INFO ) do
        for lottery_variant_id, lottery_variant in pairs( lottery.variants ) do
            for i, item in pairs( lottery_variant.items ) do
                item.chance = lottery_variant.cost / ( item.chance_cost or item.cost )
            end
        end
    end
end



----------------------------------------------------------------------------

if SERVER_NUMBER > 100 then
    addCommandHandler( "set_lottery_reward", function( player, cmd, reward_id )
        player:setData( "__lottery_reward_id", tonumber( reward_id ) )
    end )

    addCommandHandler( "clear_last_winners", function( player )
        LAST_WINNERS = { }
        outputConsole( "Список последних победителей очищен" )
    end )

    addCommandHandler( "clear_progression_rewards", function( player, cmd )
        player:ClearProgressionPoints()
        player:ClearReceivedAwards()
        player:ShowInfo( "Прогрессивные награды и очки сброшены" )
    end )

    addCommandHandler( "clear_purchased_tickets", function( player, cmd )
        player:SetPermanentData( "ltr_purchased_tickets", nil )
        player:ShowInfo( "Купленные билеты сброшены" )
    end )
end