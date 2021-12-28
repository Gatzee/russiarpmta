local nrp_transfer = getResourceFromName( "nrp_transfer" )
if nrp_transfer and nrp_transfer.state == "running" then
	exports.nrp_transfer:AddTransferDataHandler( )
end

addEventHandler( "onResourceStart", root, function( resource )
	if resource.name == "nrp_transfer" then
		exports.nrp_transfer:AddTransferDataHandler( )
	end
end )

function GetTransferData( player )
    local currency = { soft = 0 }
    local logdata, info = { }, { }

    if player:IsInClan( ) and player:GetClanRole( ) == CLAN_ROLE_LEADER then
        local cost = CLAN_CREATION_COST
        currency.soft = currency.soft + cost
        table.insert( logdata, "Создание клана, стоимость: " .. cost )
        table.insert( info, { text = "Создание клана", cost = cost, type = "soft" } )
    end

    return currency, logdata, info
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source
	local clan = player:GetClan( )
	if not clan or player:GetClanRole( ) ~= CLAN_ROLE_LEADER then
		triggerEvent( "onTransferPrepareData_callback", player )
		return
	end

	DB:queryAsync( function( query, ... )
		if not isElement( player ) then
			dbFree( query )
			return
		end

		local result = dbPoll( query, -1 )
		local members = type( result ) == "table" and result or {}

		if clan.deleted then
			triggerEvent( "onTransferPrepareData_callback", player )
			return
		end

		local data = {
			money = clan.money,
			permanent_data = {
				slots = clan.slots,
				upgrades = { },
				storage = table.copy( clan.storage ),
				freezer = table.copy( clan.freezer ),
				ex_members = { },
			}
		}

		for upgrade_id, lvl in pairs( clan.upgrades or { } ) do
			local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
			if upgrade_conf[ 1 ].buff_value then
				for i = 1, lvl do
					data.money = data.money + upgrade_conf[ i ].cost
				end
			else
				data.permanent_data.upgrades[ upgrade_id ] = lvl
			end
		end

		-- Сначала сохраняем свежие данные онлайн игроков
		for i, player in pairs( clan:GetOnlineMembers( ) ) do
			data.permanent_data.ex_members[ player:GetClientID( ) ] = {
				exp = player:GetClanEXP( ),
				rank = player:GetClanRank( ),
				stats = player:GetClanStats( ),
			}
		end

		for i, player_data in pairs( members ) do
			if not data.permanent_data.ex_members[ player_data.client_id ] and utf8.sub( player_data.nickname, 1, 1 ) ~= "-" then
				data.permanent_data.ex_members[ player_data.client_id ] = {
					exp = player_data.clan_exp,
					rank = player_data.clan_rank,
					stats = fromJSON( player_data.clan_stats ),
				}
			end
		end

		triggerEvent( "onTransferPrepareData_callback", player, nil, {
			transfer_clan_data = data,
		} )
	end, { }, "SELECT client_id, nickname, clan_rank, clan_exp, clan_stats FROM nrp_players WHERE clan_id = ?", clan.id )
end )

addEvent( "onTransferClearOldData" )
addEventHandler( "onTransferClearOldData", root, function( )
    local player = source
	local clan = player:GetClan( )
	if clan and player:GetClanRole( ) == CLAN_ROLE_LEADER then
		clan:destroy( )
	end
end )

addEvent( "onPlayerCreateClan" )
addEventHandler( "onPlayerCreateClan", root, function( )
    local player = source
	local transfer_clan_data = player:GetPermanentData( "transfer_clan_data" )
	if transfer_clan_data then
		local clan = player:GetClan( )
		if transfer_clan_data.money then
			clan:GiveMoney( transfer_clan_data.money, true )
		end
		for k, v in pairs( FixTableKeys( transfer_clan_data.permanent_data, true ) ) do
			clan:SetPermanentData( k, v )
		end
		clan:UpdateLeaderboardData( )
		player:SetPermanentData( "transfer_clan_data", nil )
	end
end )