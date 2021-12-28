loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SDB")
Extend("SPlayer")

local cache_faction_member_list = {}
local cache_timeout = 0

function GetCountFactionMemberList( player )
	local faction_id = player:GetFaction( )
	return table.size( cache_faction_member_list[ faction_id ] or { } )
end

function ClientRequestFactiobMemberList()
	if not client then return end
	if not client:IsInGame() then return end
	if not client:IsInFaction() then return end

	local player_faction = client:GetFaction()

	if cache_faction_member_list[ player_faction ] and cache_timeout > getRealTime().timestamp then
		UpdateFactionMemberListOnline( player_faction )
		local shift_plan = exports.nrp_faction_shift_plan:GetShiftPlanData( client )
		triggerClientEvent( client, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true, shift_plan )
	else
		cache_timeout = getRealTime().timestamp + 2 * 60

		local COLUMNS_LIST = { "id", "nickname", "faction_level", "faction_exp", "faction_warns", "banned", "last_date" }
		DB:queryAsync( ClientRequestFactiobMemberList_Callback, { client, player_faction }, "SELECT ?? FROM nrp_players WHERE faction_id = ?", table.concat( COLUMNS_LIST, ", " ), player_faction  )
	end
end
addEvent( "ClientRequestFactiobMemberList", true )
addEventHandler( "ClientRequestFactiobMemberList", resourceRoot, ClientRequestFactiobMemberList )

function ClientRequestFactiobMemberList_Callback( query, player, player_faction )
	local result = query:poll( -1 )

	cache_faction_member_list[ player_faction ] = {}
	
	for _, member in pairs( result ) do
		if utf8.sub( member.nickname, 1, 1 ) ~= "-" then
			local member_player = GetPlayerFromUserID( member.id )

			if member_player then
				if member_player:GetFaction() == player_faction then
					cache_faction_member_list[ player_faction ][ member.id ] = {
						name = member.nickname;
						level = member_player:GetFactionLevel();
						exp = member_player:GetFactionExp();
						warnings = member_player:GetPermanentData( "faction_warns" );
						reports = member_player:GetPermanentData( "faction_reports" ) or {};
						status = 1;
						last = member_player:IsOnFactionDuty();
					}
				else
					cache_faction_member_list[ player_faction ][ member.id ] = nil
				end
			else
				cache_faction_member_list[ player_faction ][ member.id ] = {
					name = member.nickname;
					level = member.faction_level;
					exp = member.faction_exp;
					warnings = member.faction_warns;
					reports = member.faction_reports and fromJSON(member.faction_reports) or {};
					status = member.banned <= getRealTime().timestamp and 2 or 3;
					last = member.last_date;
				}
			end
		end
	end

	for i, member_player in pairs( GetPlayersInGame() ) do
		if member_player:GetFaction() == player_faction then
			local id = member_player:GetUserID()
			if not cache_faction_member_list[ player_faction ][ id ] then
				cache_faction_member_list[ player_faction ][ id ] = {
					name = member_player:GetNickName();
					level = member_player:GetFactionLevel();
					exp = member_player:GetFactionExp();
					warnings = member_player:GetPermanentData( "faction_warns" );
					reports = member_player:GetPermanentData( "faction_reports" );
					status = 1;
					last = member_player:IsOnFactionDuty();
				}
			end
		end
	end

	if isElement( player ) then
		local shift_plan = exports.nrp_faction_shift_plan:GetShiftPlanData( player )
		triggerClientEvent( player, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true, shift_plan )
	end
end

function UpdateFactionMemberListOnline( faction_id )
	for i, member_player in pairs( GetPlayersInGame() ) do
		local id = member_player:GetUserID()

		if member_player:GetFaction() == faction_id then
			if not cache_faction_member_list[ faction_id ][ id ] then
				cache_faction_member_list[ faction_id ][ id ] = {
					name = member_player:GetNickName();
					level = member_player:GetFactionLevel();
					exp = member_player:GetFactionExp();
					warnings = member_player:GetPermanentData( "faction_warns" );
					reports = member_player:GetPermanentData( "faction_reports" );
					status = 1;
					last = member_player:IsOnFactionDuty();
				}
			end
		elseif cache_faction_member_list[ faction_id ][ id ] then
			cache_faction_member_list[ faction_id ][ id ] = nil
		end
	end
end



function PlayerFactionMenuControl_levelup( member_id )
	if not client then return end
	if not client:IsInFaction() then return end
	if not client:IsHasFactionControlRights() then return end

	local player_faction = client:GetFaction()
	local member_player = GetPlayerFromUserID( member_id )

	if member_player then
		if member_player:GetFaction() ~= player_faction or not client:IsHasFactionControlRightsToPlayer( member_player ) then
			client:ShowError( "Недостаточно привилегий" )
			return
		end

		local member_new_f_level = member_player:GetFactionLevel() + 1
		if FACTIONS_LEVEL_LIMITS[ player_faction ] and FACTIONS_LEVEL_LIMITS[ player_faction ][ member_new_f_level ] then
			local count_on_level = 0
			for member_user_id, data in pairs( cache_faction_member_list[ player_faction ] ) do
				if data.level == member_new_f_level then
					count_on_level = count_on_level + 1
				end
			end

			if count_on_level >= FACTIONS_LEVEL_LIMITS[ player_faction ][ member_new_f_level ] then
				client:ShowInfo( "Превышен лимит игроков на новом звании (максимум ".. FACTIONS_LEVEL_LIMITS[ player_faction ][ member_new_f_level ] ..")" )
				return
			end
		end

		if member_player:GiveFactionLevelUp() then
			cache_faction_member_list[ player_faction ][ member_id ].level = member_player:GetFactionLevel()
			cache_faction_member_list[ player_faction ][ member_id ].exp = member_player:GetFactionExp()

			client:ShowSuccess( "Звание подчиненного успешно повышено" )
			member_player:ShowSuccess( "Твоё звание успешно повышено" )

			local iRank = member_player:GetFactionLevel()
			local sOldRank = FACTIONS_LEVEL_NAMES[ player_faction ][ iRank - 1 ] or "?"
			local sNewRank = FACTIONS_LEVEL_NAMES[ player_faction ][ iRank ] or "?"

			member_player:AddFactionRecord( player_faction, "Повышен", "-", sOldRank.." > "..sNewRank )

			WriteLog( "factions/levelup", "%s повысил %s с ранга %s на ранг %s", client, member_player, sOldRank, sNewRank )
		else
			client:ShowInfo( "У подчиненного недостаточно опыта" )
			return
		end

	else
		client:ShowError( "Подчиненный не в игре" )
		return
	end

	UpdateFactionMemberListOnline( player_faction )
	triggerClientEvent( client, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true )
end
addEvent( "PlayerFactionMenuControl_levelup", true )
addEventHandler( "PlayerFactionMenuControl_levelup", resourceRoot, PlayerFactionMenuControl_levelup )


function PlayerFactionMenuControl_leveldown( member_id )
	if not client then return end
	if not client:IsInFaction() then return end
	if not client:IsHasFactionControlRights() then return end

	local player_faction = client:GetFaction()
	local member_player = GetPlayerFromUserID( member_id )

	if member_player then
		if member_player:GetFaction() ~= player_faction or not client:IsHasFactionControlRightsToPlayer( member_player ) then
			client:ShowError( "Недостаточно привилегий" )
			return
		end

		if member_player:GetFactionLevel() == 1 then
			client:ShowSuccess( "Куда еще ниже? Только если уволить" )
			return
		end

		member_player:SetFactionLevel( member_player:GetFactionLevel() - 1 )

		cache_faction_member_list[ player_faction ][ member_id ].level = member_player:GetFactionLevel()
		cache_faction_member_list[ player_faction ][ member_id ].exp = member_player:GetFactionExp()
		
		client:ShowSuccess( "Звание подчиненного успешно понижено" )
		member_player:ShowSuccess( "Твоё звание было понижено" )

		local iRank = member_player:GetFactionLevel()
		local sOldRank = FACTIONS_LEVEL_NAMES[ player_faction ][ iRank + 1 ] or "?"
		local sNewRank = FACTIONS_LEVEL_NAMES[ player_faction ][ iRank ] or "?"

		member_player:AddFactionRecord( player_faction, "Понижен", "-", sOldRank.." > "..sNewRank )

		WriteLog( "factions/leveldown", "%s понизил %s с ранга %s на ранг %s", client, member_player, sOldRank, sNewRank )
	else
		client:ShowError( "Подчиненный не в игре" )
		return
	end

	UpdateFactionMemberListOnline( player_faction )
	triggerClientEvent( client, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true )
end
addEvent( "PlayerFactionMenuControl_leveldown", true )
addEventHandler( "PlayerFactionMenuControl_leveldown", resourceRoot, PlayerFactionMenuControl_leveldown )

function PlayerFactionMenuControl_thanks( member_id )
	if not client then return end
	if not client:IsInFaction() then return end
	if not client:IsHasFactionControlRights() then return end

	local player_faction = client:GetFaction()
	local member_player = GetPlayerFromUserID( member_id )

	if member_player then
		if member_player:GetFaction() ~= player_faction or not client:IsHasFactionControlRightsToPlayer( member_player ) then
			client:ShowError( "Недостаточно привилегий" )
			return
		end

		local result = member_player:GiveFactionThanks( )
		if not result then
			client:ShowError( "Подчиненный уже получал сегодня благодарность" )
			return
		end

		WriteLog( "factions/thanks", "%s выдал благодарность %s", client, member_player )
	
		client:ShowSuccess( "Благодарность успешно выдана" )
	else
		client:ShowError( "Подчиненный не в игре" )
		return
	end

	UpdateFactionMemberListOnline( player_faction )
	triggerClientEvent( client, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true )
end
addEvent( "PlayerFactionMenuControl_thanks", true )
addEventHandler( "PlayerFactionMenuControl_thanks", resourceRoot, PlayerFactionMenuControl_thanks )

function PlayerFactionMenuControl_warning( member_id )
	if not client then return end
	if not client:IsInFaction() then return end
	if not client:IsHasFactionControlRights() then return end

	local player_faction = client:GetFaction()
	local member_player = GetPlayerFromUserID( member_id )

	if member_player then
		if member_player:GetFaction() ~= player_faction or not client:IsHasFactionControlRightsToPlayer( member_player ) then
			client:ShowError( "Недостаточно привилегий" )
			return
		end

		member_player:GiveFactionWarning( )
		client:ShowSuccess( "Выговор успешно выдан" )

		cache_faction_member_list[ player_faction ][ member_id ].warnings = member_player:GetPermanentData( "faction_warns" )

		WriteLog( "factions/warns", "%s выдал выговор %s", client, member_player )

	else
		client:ShowError( "Подчиненный не в игре" )
		return
	end

	UpdateFactionMemberListOnline( player_faction )
	triggerClientEvent( client, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true )
end
addEvent( "PlayerFactionMenuControl_warning", true )
addEventHandler( "PlayerFactionMenuControl_warning", resourceRoot, PlayerFactionMenuControl_warning )

function PlayerFactionMenuControl_set_deputy( member_id )
	if not client then return end
	if not client:IsInFaction() then return end
	if not client:IsFactionOwner( ) then return end

	local available_faction =
	{
		[ F_GOVERNMENT_GORKI ] = true,
		[ F_GOVERNMENT_NSK ] = true,
		[ F_GOVERNMENT_MSK ] = true,
	}
	local player_faction = client:GetFaction()
	if not available_faction[ player_faction ] then
		return
	end
	local set_deputy_cooldown = client:GetPermanentData( "set_deputy_cooldown" )
	if set_deputy_cooldown and set_deputy_cooldown > getRealTime().timestamp then
		client:ShowError( "Назначить заместителя можно раз в неделю!" )
		return
	end
	

	local member_new_f_level = FACTION_OWNER_LEVEL - 1
	if FACTIONS_LEVEL_LIMITS[ player_faction ] and FACTIONS_LEVEL_LIMITS[ player_faction ][ member_new_f_level ] then
		local count_on_level = 0
		for member_user_id, data in pairs( cache_faction_member_list[ player_faction ] ) do
			if data.level == member_new_f_level then
				count_on_level = count_on_level + 1
			end
		end

		if count_on_level >= FACTIONS_LEVEL_LIMITS[ player_faction ][ member_new_f_level ] then
			client:ShowInfo( "Превышен лимит игроков на новом звании (максимум ".. FACTIONS_LEVEL_LIMITS[ player_faction ][ member_new_f_level ] ..")" )
			return
		end
	end

	local member_player = GetPlayerFromUserID( member_id )
	if member_player then
		if member_player:GetFaction() ~= player_faction or not client:IsHasFactionControlRightsToPlayer( member_player ) then
			client:ShowError( "Недостаточно привилегий" )
			return
		end

		member_player:SetFactionLevel( member_new_f_level, "Повышением мэром" )
		cache_faction_member_list[ player_faction ][ member_id ].level = member_player:GetFactionLevel()
		
		client:SetPermanentData( "set_deputy_cooldown", getRealTime().timestamp + 7 * 24 * 60 * 60 )
		client:ShowSuccess( "Подчиненный повышен до заместителя" )

		WriteLog( "factions/warns", "%s сделал заместителем %s", client, member_player )

	else
		client:ShowError( "Подчиненный не в игре" )
		return
	end

	UpdateFactionMemberListOnline( player_faction )
	triggerClientEvent( client, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true )
end
addEvent( "PlayerFactionMenuControl_set_deputy", true )
addEventHandler( "PlayerFactionMenuControl_set_deputy", resourceRoot, PlayerFactionMenuControl_set_deputy )

function PlayerFactionMenuControl_kick( member_id, reason )
	if not client then return end
	if not client:IsInFaction() then return end
	if not client:IsHasFactionControlRights() then return end

	local player_faction = client:GetFaction()
	local member_player = GetPlayerFromUserID( member_id )

	if member_player then
		if member_player:GetFaction() ~= player_faction or not client:IsHasFactionControlRightsToPlayer( member_player ) then
			client:ShowError( "Недостаточно привилегий" )
			return
		end

		local iRank = member_player:GetFactionLevel()

		member_player:SetFaction( 0 )
		member_player:SetPermanentData( "faction_timeout", getRealTimestamp( ) + FACTION_JOIN_TIMEOUT.leader )

		client:ShowSuccess( "Подчиненный успешно уволен" )
		member_player:ShowInfo( "Вы были уволены из фракции" )
		cache_faction_member_list[ player_faction ][ member_id ] = nil

		local sRank = FACTIONS_LEVEL_NAMES[ player_faction ][ iRank ] or "?"
		member_player:AddFactionRecord( player_faction, "Уволен", reason, sRank )

		WriteLog( "factions/fire", "%s уволил %s по причине %s", client, member_player, reason )

		triggerEvent( "onPlayerFactionChangeAnalytics", member_player, false, player_faction, table.size( cache_faction_member_list[ player_faction ] ), iRank, false )

	elseif cache_faction_member_list[ player_faction ] and cache_faction_member_list[ player_faction ][ member_id ] then
		local info = cache_faction_member_list[ player_faction ][ member_id ]

		if not client:IsHasFactionControlRightsToPlayer( info.level ) then
			client:ShowError( "Недостаточно привилегий" )
			return
		end

		local query = DB:exec( "UPDATE nrp_players SET faction_id=0, faction_level=0, faction_exp=0, faction_timeout=? WHERE id=? LIMIT 1", getRealTimestamp( ) + FACTION_JOIN_TIMEOUT.leader, member_id )
		if query then
			client:ShowSuccess( "Подчиненный успешно уволен" )
			cache_faction_member_list[ player_faction ][ member_id ] = nil

			triggerEvent("AddFactionRecord", client, member_id, player_faction, "Уволен", reason, FACTIONS_LEVEL_NAMES[ player_faction ][ info and info.level ] or "?" )

			local client = client
			
			DB:queryAsync( function( query, client_id, reason )
				local result = query:poll( -1 )
				local data = result[ 1 ]

				WriteLog( "factions/fire", "%s уволил %s (ID:%s, SERIAL:%s, IP:%s, client_id:%s) по причине %s", client, data.nickname, data.id, data.last_serial, data.last_ip, data.client_id, reason )
			end, { client:GetClientID( ), reason }, "SELECT id, last_serial, last_ip, nickname, client_id FROM nrp_players WHERE id=? LIMIT 1", member_id )
			
		end
	end

	UpdateFactionMemberListOnline( player_faction )
	triggerClientEvent( client, "UIControlMenu", resourceRoot, cache_faction_member_list[ player_faction ], true )
end
addEvent( "PlayerFactionMenuControl_kick", true )
addEventHandler( "PlayerFactionMenuControl_kick", resourceRoot, PlayerFactionMenuControl_kick )

function PlayerFactionMenuControl_invite( nickname )
	if not client then return end
	if not client:IsInFaction() then return end
	if not client:IsHasFactionControlRights() then return end

	local player_faction = client:GetFaction( )
	local UNIQUE_REQUIREMENT = {
		[ F_POLICE_PPS_MSK ] = {
			social_rating = 500,
			level = 15,
		},
		[ F_POLICE_DPS_MSK ] = {
			social_rating = 500,
			level = 15,
		},
		[ F_MEDIC_MSK ] = {
			social_rating = 500,
			level = 15,
		},
		[ F_GOVERNMENT_MSK ] = {
			social_rating = 500,
			level = 15,
		}
	}
	
	for i, player in pairs( GetPlayersInGame( ) ) do
		if player:GetNickName( ) == nickname then

			if player:IsInClan( ) then
				client:ShowError( "Невозможно принять этого игрока\nИгрок состоит в клане" )
				return
			end

			if player:IsInFaction( ) then
				client:ShowError( "Невозможно принять этого игрока\nИгрок состоит во фракции" )
				return
			end

			if FACTIONS_NEED_MILITARY[ player_faction ] and not player:HasMilitaryTicket( ) then
				client:ShowError( "Невозможно принять этого игрока\nОтсутствует военный билет" )
				return
			end

			local requirement = UNIQUE_REQUIREMENT[ player_faction ]
			if requirement then
				if requirement.social_rating > player:GetSocialRating( ) then
					client:ShowError( "Невозможно принять этого игрока\nЕго соц. рейтинг ниже " .. requirement.social_rating .. " ед." )
					return
				end

				if UNIQUE_REQUIREMENT[ player_faction ].level > player:GetLevel( ) then
					client:ShowError( "Невозможно принять этого игрока\nТребуется " .. requirement.level .. " уровень и выше" )
					return
				end
			else
				if player:GetSocialRating( ) < 50 then
					client:ShowError( "Невозможно принять этого игрока\nЕго соц. рейтинг ниже требуемого" )
					return
				end

				if player:GetLevel( ) < 4 then
					client:ShowError( "Невозможно принять этого игрока\nТребуется 4 уровень и выше" )
					return
				end
			end

			player:setData( "faction_invite_id", player_faction, false )
			triggerClientEvent( player, "UIApplyInvitePopup", resourceRoot, player_faction )
			client:ShowSuccess( "Приглашение успешно отправлено" )

			WriteLog( "factions/invites", "%s отправил приглашение во фракцию %s", client, player )

			return
		end
	end

	client:ShowError( "Игрок не найден" )
end
addEvent( "PlayerFactionMenuControl_invite", true )
addEventHandler( "PlayerFactionMenuControl_invite", resourceRoot, PlayerFactionMenuControl_invite )

function PlayerFactionMenuControl_apply_invite()
	if not client then
		return
	end
	
	local faction_id = client:getData( "faction_invite_id" )
	if not faction_id then
		return
	end

	local current_time = getRealTimestamp( )
	local timeout = client:GetPermanentData( "faction_timeout" ) or 0
	if timeout > current_time then
		local time_left = ( timeout - current_time ) / 60
		local hours = string.format( "%02d", math.floor( time_left / 60 ) )
		local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 ) ) )

		client:ShowError( "Вступление во фракцию возможно через " .. hours .. " ч. и " .. minutes .. " м." )
		return
	end

	client:setData( "faction_invite_id", nil, false )

	if client:IsInFaction( ) or client:IsInClan( ) then
		return
	end

	if FACTIONS_NEED_MILITARY[ faction_id ] and not client:HasMilitaryTicket() then
		return
	end

	if client:getData( "work_lobby_id" ) then
		client:ShowError( "Вы на работе" )
		return
	end

	client:SetFaction( faction_id )

	client:ShowSuccess( "Вы успешно вступили в фракцию “".. FACTIONS_NAMES[ faction_id ] .."“" )

	client:CompleteDailyQuest( "np_join_faction" )

	client:AddFactionRecord( faction_id, "Принят", "-", FACTIONS_LEVEL_NAMES[ faction_id ][1]  )
	
	WriteLog( "factions/invites", "%s принял приглашение во фракцию", client )

	triggerEvent( "onPlayerFactionChangeAnalytics", client, true, faction_id, table.size( cache_faction_member_list[ faction_id ] ) )
end
addEvent( "PlayerFactionMenuControl_apply_invite", true )
addEventHandler( "PlayerFactionMenuControl_apply_invite", resourceRoot, PlayerFactionMenuControl_apply_invite )