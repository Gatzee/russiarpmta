function onPlayerRequestClanUpgrade_handler( upgrade_id )
	local player = client or source
	local clan = player:GetClan( )
	if not clan then return end
	
    if player:GetClanRole( ) ~= CLAN_ROLE_LEADER then
		triggerClientEvent( player, "onClientClanUpgradeResponse", player, "Только лидер клана может приобрести улучшения" )
        return
    end

	local result, error = clan:RequestUpgrade( upgrade_id, player )

	if result then
		player:ShowSuccess( "Улучшение успешно приобретено!" )
		triggerClientEvent( player, "onClientUpdateClanUI", player, {
			slots = clan.slots,
			money_log = clan.money_log,
		} )
	else
		triggerClientEvent( player, "onClientClanUpgradeResponse", player, error )
	end
end
addEvent( "onPlayerRequestClanUpgrade", true )
addEventHandler( "onPlayerRequestClanUpgrade", root, onPlayerRequestClanUpgrade_handler )

function onPlayerWantAddClanMoney_handler( amount )
	if client and client ~= source then
		triggerEvent( "DetectPlayerAC", client, "15", true )
		return
	end

	local player = client or source
	local clan = player:GetClan( )
	if not clan then return end

	local accessLevel = player:GetAccessLevel( ) 
	if accessLevel > 0 and accessLevel <= 10 then
		player:ShowError( "Вам запрещено пополнять общак" )
		return
	end

	if clan:IsMoneyLocked( ) then
		player:ShowError( "Общак заблокирован на время уплаты налога картелю!" )
		return
	end

	if player:TakeMoney( amount, "clan_balance_topup" ) then
		clan:GiveMoney( amount, false, player )
		local exp = math.floor( amount / 50 )
		player:GiveClanEXP( exp, true )
		player:ShowSuccess( "Общак успешно пополнен! +" .. exp .. " XP" )

		triggerClientEvent( player, "onClientUpdateClanUI", player, {
			exp = player:GetClanEXP( ),
			rank = player:GetClanRank( ),
			money_log = clan.money_log,
		} )
		
		local score_earned = math.floor( amount * CLAN_MONEY_SCORE_COEF )
		player:AddClanStats( "score_earned", score_earned )

		local user_id = player:GetUserID( )
		clan.today_members_scores[ user_id ] = ( clan.today_members_scores[ user_id ] or 0 ) + score_earned
		if clan.today_members_scores[ user_id ] > ( clan.today_best_member.score or 0 ) then
			clan.today_best_member.name = player:GetNickName( )
			clan.today_best_member.score = clan.today_members_scores[ user_id ]
		end
        
        SendElasticGameEvent( player:GetClientID( ), "clan_points", {
			clan_rank = player:GetClanRank( ),
			clan_rank_exp = exp,
            clan_id = clan.id,
            clan_name = clan.name,
            clan_lb_points = clan.score,
            clan_lb_position = GetClanLeaderboardPosition( clan ),
            season_num = CURRENT_SEASON_ID,
            points_income = amount,
            points_lb_income = math.floor( amount * CLAN_MONEY_SCORE_COEF ),
            points_type = "clan_money",
            event_name = "clan_money_income",
        } )

		SendElasticGameEvent( player:GetClientID( ), "clan_money_income", {
			clan_id = clan.id,
			clan_name = clan.name,
			clan_members_num = clan.members_count,
			income_sum = amount,
			clan_money = clan.money,
		} )
	else
		player:EnoughMoneyOffer( "Clan money", amount, "onPlayerWantAddClanMoney", player, amount )
	end
end
addEvent( "onPlayerWantAddClanMoney", true )
addEventHandler( "onPlayerWantAddClanMoney", root, onPlayerWantAddClanMoney_handler )

function onPlayerWantRentSputnik_handler( )
	local player = client or source
	local clan = player:GetClan( )

	if not clan or clan:GetSputnik( ) > 0 then return end

	local access = {
		[CLAN_ROLE_LEADER] = true,
		[CLAN_ROLE_MODERATOR] = true,
	}

	if not access[player:GetClanRole( )] then
		player:ShowError( "Только лидер или модератор\nможет арендовать спутник" )
		return
	end

	local result, error = clan:TakeMoney( SPUTNIK_PRICE_FOR_CLAN )
	if not result then
		player:ShowError( error )
		return
	end

	clan:GiveSputnik( )

	triggerClientEvent( player, "onClientUpdateClanUI", player, {
		sputnik = clan:GetSputnik( ),
	} )

	player:ShowSuccess( "Спутник успешно арендован" )
	triggerEvent( "onPlayerRentSputnik", player, clan.name, SPUTNIK_PRICE_FOR_CLAN )
end
addEvent( "onPlayerWantRentSputnik", true )
addEventHandler( "onPlayerWantRentSputnik", root, onPlayerWantRentSputnik_handler )

function onPlayerWantChangeClanWay_handler( selected_way )
    local player = client or source
    local clan = player:GetClan( )
    if not clan then return end

	if player:GetClanRole( ) ~= CLAN_ROLE_LEADER then
		player:ShowError( "Только лидер клана может сменить путь развития" )
		return
	end

	if clan.way == selected_way then
		return
	end

	local result, error = clan:TakeMoney( CLAN_WAY_CHANGE_COST )
	if not result then
		player:ShowError( error )
		return
	end
	clan:AddLogMessage( CLAN_LOG_CHANGE_WAY, -CLAN_WAY_CHANGE_COST, player )
	
	local old_way = clan.way
	clan:SetPermanentData( "way", selected_way )

	triggerClientEvent( player, "onClientUpdateClanUI", player, {
		money_log = clan.money_log,
		way = selected_way,
	} )

	-- Сброс всех тематических улучшений
	local clan_upgrades = clan:GetUpgrades( )
	for upgrade_id in pairs( clan_upgrades ) do
		if CLAN_UPGRADES_LIST[ upgrade_id ][ 1 ].buff_value then
			clan_upgrades[ upgrade_id ] = nil
		end
	end
	clan:SetPermanentData( "upgrades", clan_upgrades )
	triggerClientEvent( clan:GetOnlineMembers( ), "onClientClanUpgradesSync", resourceRoot, clan_upgrades )
	triggerEvent( "onClanWayChange", resourceRoot, clan.id )

	player:ShowSuccess( "Путь развития успешно изменён" )

	SendElasticGameEvent( player:GetClientID( ), "clan_develop_theme_change", {
		clan_id = clan.id,
		clan_name = clan.name,
		theme_id_old = CLAN_WAY_KEYS[ old_way ],
		theme_id_new = CLAN_WAY_KEYS[ clan.way ],
		cost = CLAN_WAY_CHANGE_COST,
		currency = "soft",
	} )
end
addEvent( "onPlayerWantChangeClanWay", true )
addEventHandler( "onPlayerWantChangeClanWay", root, onPlayerWantChangeClanWay_handler )