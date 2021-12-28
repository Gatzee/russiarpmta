loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SClans" )
Extend( "ShTimelib" )

SDB_SEND_CONNECTIONS_STATS = true
Extend( "SDB" )

CLAN_DELETE_AFTER_TIME = 2 * 24 * 60 * 60
PLAYER_REJOIN_COOLDOWN = 48 * 60 * 60
CLAN_HONOR_SCORE_COEF = 1 / 3
CLAN_MONEY_SCORE_COEF = 1 / 2500

CLANS_LIST = {
    -- clan_data,
    -- clan_data,
    -- clan_data,
}

CLANS_BY_ID = {
    -- [ 1 ] = clan_data,
    -- [ 2 ] = clan_data,
    -- [ 5 ] = clan_data,
}

PLAYERS_MEMBER_DATA = { }

local DEFAULT_PERMADATA_VALUES = {
    tag = 1,
    way = 1,
    -- name = "Название",
    -- desc = "Описание",
    -- motd = "Сообщение дня",
    money = 0,
    honor = 0,
    score = 0,
    slots = 25,
    members_count = 0,
    is_closed = false,
    ex_members = { },
    money_log = { },
    upgrades = { },
    storage = { },
    freezer = { },
    alco_factory = { },
    hash_factory = { },
}

function Clan( permanent_data )
    local self = { }

    self.id = permanent_data.id
    if not self.id then
        local id = os.time( )
        while( CLANS_BY_ID[ id ] ) do
            id = id + 1
        end
        self.id = id
    end

    self.team = createTeam( permanent_data.name, 255, 255, 255 )
    if not self.team then return end

    self.team:setID( "c" .. self.id )
    self.team:setFriendlyFire( false )
    if self.color then
        self.team:setColor( unpack( self.color ) )
    end

    -- Перманентные (сохраняемые в БД) данные

    self.permanent_data = permanent_data

    for k, v in pairs( DEFAULT_PERMADATA_VALUES ) do
        permanent_data[ k ] = permanent_data [ k ] or table.copy( v )
    end
    local metatable = {
        __index = self.permanent_data,
    }
    setmetatable( self, metatable )

    self.GetPermanentData = function( self, key )
        return self.permanent_data[ key ]
    end

    self.SetPermanentData = function( self, key, value )
        self.permanent_data[ key ] = value
        self.need_save = true
        return true
    end

    -- Общак

    self.GetMoney = function( self )
        return self:GetPermanentData( "money" ) or 0
    end

    self.SetMoney = function( self, value, ignore_lock )
        if not ignore_lock and self:IsMoneyLocked( ) then
            return false, "Общак заблокирован на время уплаты налога картелю!"
        end
        self:SetPermanentData( "money", math.floor( value ) )
        self:UpdateScore( )
        self:UpdateLeaderboardData( LB_CLAN_MONEY, value )
        triggerClientEvent( self:GetOnlineMembers( ), "onClientUpdateClanUI", resourceRoot, {
            money = value,
        } )
        return true
    end

    self.GiveMoney = function( self, value, ignore_lock, player )
        local result, msg = self:SetMoney( self:GetMoney( ) + value, ignore_lock )
        if not result then
            return false, msg
        end

        if isElement( player ) then
            self:AddLogMessage( CLAN_LOG_ADD_MONEY, value, player )
        end
        return true
    end

    self.TakeMoney = function( self, value, ignore_lock )
        local money = self:GetMoney( )
        if money >= value then
            return self:SetMoney( money - value, ignore_lock )
        end
        return false, "Недостаточно средств в общаке клана!"
    end

    self.IsMoneyLocked = function( self )
        return self.cartel_tax_data and not self.cartel and self.cartel_tax_data.season == CURRENT_SEASON_ID
    end

    -- Журнал действий по общаку

    self.AddLogMessage = function( self, type, value, player, params )
        local money_log = self.permanent_data.money_log or { }
        if #money_log >= 50 then
            table.remove( money_log, 1 )
        end
        table.insert( money_log, { 
            name = player:GetNickName( ), 
            type = type, 
            value = value, 
            params = params, 
            date = os.time( ),
        } )
        self:SetPermanentData( "money_log", money_log )
    end

    -- Очки чести

    self.today_members_scores = { }
    self.today_best_member = { }

    self.GetHonor = function( self )
        return self:GetPermanentData( "honor" ) or 0
    end

    self.SetHonor = function( self, value, reset, delta, event_name, players, player_rank_exp )
        if event_name then
            if type( players ) ~= "table" then
                local player = players
                players = {
                    {
                        element = player,
                        client_id = player:GetClientID( ),
                        rank = player:GetClanRank( ),
                    },
                }
            end
            for i, player_data in pairs( players ) do
                if isElement( player_data.element ) then
                    triggerEvent( "onPlayerChangeClanHonor", player_data.element, event_name )
                end
            end
        end

        if LOCKED_SEASON or not reset and self:IsBlocked( ) then
            return false
        end
        
        value = value > 0 and value or 0
        self:SetPermanentData( "honor", value )
        self:UpdateLeaderboardData( LB_CLAN_HONOR, value )
        self:UpdateScore( )
        
        if event_name then
            local today_members_scores = self.today_members_scores
            for i, player_data in pairs( players ) do
                local score_earned = math.floor( delta * CLAN_HONOR_SCORE_COEF )
                local player = isElement( player_data.element ) and player_data.element
                if delta > 0 and player then
                    player:AddClanStats( "score_earned", score_earned )

                    local user_id = player:GetUserID( )
                    today_members_scores[ user_id ] = ( today_members_scores[ user_id ] or 0 ) + score_earned
                    if today_members_scores[ user_id ] > ( self.today_best_member.score or 0 ) then
                        self.today_best_member.name = player:GetNickName( )
                        self.today_best_member.score = today_members_scores[ user_id ]
                    end
                end

                SendElasticGameEvent( player_data.client_id, "clan_points", {
                    clan_rank = player and player:GetClanRank( ) or player_data.clan_rank,
                    clan_rank_exp = player_rank_exp or 0,
                    clan_id = self.id,
                    clan_name = self.name,
                    clan_lb_points = self.score,
                    clan_lb_position = GetClanLeaderboardPosition( self ),
                    season_num = CURRENT_SEASON_ID,
                    points_income = delta / #players,
                    points_lb_income = score_earned,
                    points_type = "honor_points",
                    event_name = event_name,
                } )
            end
        end

        return true
    end
    
    self.GiveHonor = function( self, value, event_name, players, player_rank_exp )
        return self:SetHonor( self:GetHonor( ) + value, false, value, event_name, players, player_rank_exp )
    end

    self.TakeHonor = function( self, value, event_name, players, player_rank_exp )
        return self:SetHonor( self:GetHonor( ) - value, false, -value, event_name, players, player_rank_exp )
    end

    -- Очки в лидерборде

    self.GetScore = function( self )
        return math.floor( self.honor * CLAN_HONOR_SCORE_COEF + self.money * CLAN_MONEY_SCORE_COEF )
    end

    self.UpdateScore = function( self )
        if LOCKED_SEASON then return end

        local score = self:GetScore( )
        self:UpdateLeaderboardData( LB_CLAN_SCORE, score )
        return self:SetPermanentData( "score", score )
    end

    -- Спутник

    self.GetSputnik = function( self )
        local timeTo = self:GetPermanentData( "sputnik" ) or 0
        local timeLeft = timeTo - getRealTime( ).timestamp

        return timeLeft < 0 and 0 or timeLeft
    end

    self.GiveSputnik = function( self )
        self:SetPermanentData( "sputnik", getRealTime( ).timestamp + SPUTNIK_TIME_AVAILABLE )
    end

    self.SetSputnik = function( self, value ) -- DEV & TEST
        value = tonumber( value )
        if not value then return end
        self:SetPermanentData( "sputnik", getRealTime( ).timestamp + value )
    end

    -- Развитие

    self.GetUpgrades = function( self )
        return self:GetPermanentData( "upgrades" ) or {}
    end

    self.GetUpgradeLevel = function( self, upgrade_id )
        return self:GetUpgrades( )[ upgrade_id ]
    end

    self.RequestUpgrade = function( self, upgrade_id, player )
        local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
        local next_level = ( self:GetUpgrades( )[ upgrade_id ] or 0 ) + 1
        local upgrade = upgrade_conf[ next_level ]
        if upgrade then
            if upgrade.is_available then
                local result, msg = upgrade.is_available( self )
                if not result then
                    return false, msg
                end
            end

            local result, error = self:TakeMoney( upgrade.cost )
            if result then
                self:ApplyUpgrade( upgrade_id, next_level )
                self:AddLogMessage( CLAN_LOG_UPGRADE, -upgrade.cost, player, { id = upgrade_id } )

                SendElasticGameEvent( player:GetClientID( ), "clan_money_spend", {
                    clan_id = self.id,
                    clan_name = self.name,
                    clan_members_num = self.members_count,
                    spend_sum = upgrade.cost,
                    spend_type = "clan_improve",
                    item_name = upgrade_conf.key,
                } )

                if upgrade.buff_value then
                    SendElasticGameEvent( player:GetClientID( ), "clan_develop_theme_purchase", {
                        clan_id = self.id,
                        clan_name = self.name,
                        theme_id = CLAN_WAY_KEYS[ self.way ],
                        lvl_num = next_level,
                        buff_id = ( upgrade_id - CLAN_UPGRADE_MAX_HP + 1 ) .. "_" .. next_level, -- чтобы начинались с 1, а не с 6
                        buff_name = upgrade_conf.key,
                        buff_cost = upgrade.cost,
                        currency = "soft",
                    } )
                elseif upgrade_conf.product_type then
                    SendElasticGameEvent( player:GetClientID( ), "clan_develop_product_purchase", {
                        clan_id = self.id,
                        clan_name = self.name,
                        product_type = upgrade_conf.product_type,
                        product_lvl_num = next_level,
                        cost = upgrade.cost,
                        currency = "soft",
                    } )
                end
                return true
            else
                return false, error
            end
        else
            return false, "Это улучшение уже на максимальном уровне"
        end
    end

    self.ApplyUpgrade = function( self, upgrade_id, level )
        local upgrades = self:GetUpgrades( )
        upgrades[ upgrade_id ] = level
        if CLAN_UPGRADES_LIST[ upgrade_id ][ level ].apply then
            CLAN_UPGRADES_LIST[ upgrade_id ][ level ].apply( self )
        end
        self:SetPermanentData( "upgrades", upgrades )

        triggerEvent( "onClanUpgrade", resourceRoot, self.id, upgrade_id, level )
        triggerClientEvent( self:GetOnlineMembers( ), "onClientClanUpgrade", resourceRoot, upgrade_id, level )

        return true
    end

    self.AddSlots = function( self, slots )
        self:SetPermanentData( "slots", ( self.slots or 0 ) + 25 )
        self:UpdateLeaderboardData( LB_CLAN_SLOTS, self.slots )
    end

    -- Хранилище

    self.HasStorage = function( self )
        return self:GetUpgrades( )[ CLAN_UPGRADE_STORAGE ]
    end

    self.AddItemToStorage = function( self, new_item )
        if not self:HasStorage( ) then
            return false, "Хранилище ещё не приобретено!"
        end

        for i, item in pairs( self.storage ) do
            if item.id == new_item.id and item.type == new_item.type then
                item.count = ( item.count or 1 ) + ( new_item.count or 1 )
                self.need_save = true
                return true
            end
        end
        
        table.insert( self.storage, new_item )
        self.need_save = true
        return true
    end

    self.RemoveItemFromStorage = function( self, need_item, count )
        for i, item in pairs( self.storage ) do
            if item.id == need_item.id and item.type == need_item.type then
                if ( item.count or 1 ) < ( count or 1 ) then
                    return false, "В наличии только " .. ( item.count or 1 ) .. " шт."
                end

                item.count = ( item.count or 1 ) - ( count or 1 )
                if item.count == 0 then
                    table.remove( self.storage, i )
                end
                self.need_save = true
                return true
            end
        end
        return false
    end

    -- Добавление игрока

    self.today_join_count = 0
    self.today_leave_count = 0
    self.members_cache = {
        -- { user_id = 1, name = "Никнейм", last_date = os.time( ), exp = 100, rank = 1, role = 1, stats = { } },
    }

    self.RequestJoinPlayer = function( self, player, is_invited, show_clan_menu_on_succes )
        local clan_banned = player:GetPermanentData( "clan_banned" )

        if clan_banned then
            player:ShowError( "Вам заблокирован доступ к кланам! ("..clan_banned..")" )
            return false, "Вам заблокирован доступ к кланам! ("..clan_banned..")"
        end 

        --[[ local last_join_clan_ts = player:GetPermanentData( "join_ts" )  -- Ограничение на вступление в клан
        if last_join_clan_ts and last_join_clan_ts + PLAYER_REJOIN_COOLDOWN > getRealTimestamp( ) and player:GetAccessLevel( ) <= 1 then
            local text = "Вы сможете вступить в клан только через " .. getHumanTimeString( last_join_clan_ts + PLAYER_REJOIN_COOLDOWN )
            player:ShowError( text )
            return false, text
        end]]

        local blocked, reason = self:IsBlocked( )
        if blocked then
            player:ShowError( "Действие этого клана приостановлено по причине: "..reason )
            return false, "Действие этого клана приостановлено по причине: "..reason
        end

        if self.is_closed and not is_invited then
            player:ShowError( "В этот клан можно вступить только по приглашению" )
            return false, "В этот клан можно вступить только по приглашению"
        end

        if self.deleted then
            player:ShowError( "Этот клан был удален" )
            return false, "Этот клан был удален"
        end

        if self.members_count >= self.slots then
            player:ShowError( "В клане не осталось свободных слотов!" )
            return
        end

        local joined, error = self:JoinPlayer( player, show_clan_menu_on_succes )

        if joined then
			player:CompleteDailyQuest( "np_join_clan" )
            SendElasticGameEvent( player:GetClientID( ), "clan_join", {
                clan_id = self.id,
                clan_name = self.name,
                clan_creation_date = self.create_date,
                clan_money = self.money,
                clan_join_status = not self.is_closed and "открытый" or "закрытый",
                clan_honor_points = self.honor,
                clan_lb_points = self.score,
                clan_lb_position = GetClanLeaderboardPosition( self ),
                self_join = not is_invited and "true" or "false",
            } )
        elseif not joined and error then
            player:ShowError( error )
        end
    end

    self.JoinPlayer = function( self, player, show_clan_menu_on_succes )
        if player:IsInFaction( ) then
            return false, "Ты не можешь быть в клане и во фракции одновременно!"
        end

        if player:GetClan( ) then
            return false, "Вы уже состоите в клане"
        end

        player:SetClanID( self.id )

        player:SetClanRole( 1 )
        local ex_member = self.ex_members[ player:GetUserID( ) ] or self.ex_members[ player:GetClientID( ) ]
        if ex_member then
            player:SetClanRank( ex_member.rank or 1 )
            player:SetClanEXP( ex_member.exp or 0 )
            player:SetClanStats( _, ex_member.stats or { } )
        else
            player:SetClanRank( 0 ) -- Ставим не на 1, иначе не сработает обновление ранга и не выдадутся балончики при вступлении
            player:SetClanEXP( 0 )
            player:ResetClanStats( )
            player:SetClanStats( "join_ts", getRealTimestamp( ) )
        end

        player:SetPermanentData( "join_ts", getRealTimestamp( ) )
        player:SetClanStats( "join_season", LOCKED_SEASON and ( CURRENT_SEASON_ID + 1 ) or CURRENT_SEASON_ID )

        local user_id = player:GetUserID( )
        for i, member in pairs( self.members_cache ) do
            if member.user_id == user_id then
                table.remove( self.members_cache, i )
                break
            end
        end
        table.insert( self.members_cache, { 
            user_id = user_id,
            name = player:GetNickName( ),
            role = player:GetClanRole( ) or 1,
            -- exp = player:GetClanEXP( ),
            rank = player:GetClanRank( ),
            -- stats = player:GetPermanentData( "clan_stats" ),
            last_date = true,
        } )
        self:UpdateMembersCount( self.members_count + 1 )

        SetSessionStart( player )

        triggerEvent( "onPlayerJoinClan", player, self.id )
        triggerClientEvent( player, "onClientClanUpgradesSync", player, self:GetUpgrades( ) )

        if show_clan_menu_on_succes then
            triggerEvent( "onPlayerWantShowClanMainUI", player )
        end

        self.today_join_count = self.today_join_count + 1

        return true
    end

    -- Является ли игрок членом

    self.FindPlayer = function( self, player )
        return player:GetClanID( ) == self.id
    end

    -- Удаление игрока
    
    self.LeavePlayer = function( self, player, is_kicked )
        if not self:FindPlayer( player ) then return false end

        local user_id = player:GetUserID( )
        for i, member in pairs( self.members_cache ) do
            if member.user_id == user_id then
                table.remove( self.members_cache, i )
                break
            end
        end
        self:UpdateMembersCount( self.members_count - 1 )

        local rank = player:GetClanRank( )
        local role = player:GetClanRole( )
        local exp = player:GetClanEXP( )
        local stats = player:GetClanStats( )
        if rank ~= 1 or exp ~= 0 then
            local ex_members = self.ex_members or { }
            ex_members[ player:GetUserID( ) ] = {
                rank = rank,
                exp = exp,
                stats = stats,
            }
            self:SetPermanentData( "ex_members", ex_members )
        end

        player:SetClanID( )
        player:SetClanRole( 0 )
        player:SetClanRank( 0 )
        player:SetClanEXP( 0 )
        player:ResetClanStats( )

        triggerClientEvent( player, "onClientPlayerLeaveClan", player )
        triggerEvent( "onPlayerLeaveClan", player, self.id )

        self.today_leave_count = self.today_leave_count + 1
        
        SendElasticGameEvent( player:GetClientID( ), "clan_leave", {
            clan_id = self.id,
            clan_name = self.name,
            leave_status = not is_kicked and 1 or 2,
            clan_rank = rank,
            clan_role = role,
        } )

        SetSessionEnd( player )

        return true
    end
    
    self.LeavePlayerOffline = function( self, user_id, source_player )
		DB:queryAsync(
			function( query )
                local result = query:poll( -1 )
                local player_data = result and result[ 1 ]
                if not player_data then return end
                if source_player and not isElement( source_player ) then return end

                if source_player and player_data.clan_role >= source_player:GetClanRole( ) then
                    source_player:ShowError( "Роль этого игрока выше вашего" )
                    return
                end

                local target = GetPlayer( user_id )
                if target then
                    self:LeavePlayer( target )
                    target:PhoneNotification( {
                        title = "Клан",
                        msg = "Ты был исключен из клана!",
                    } )
                else
                    for i, member in pairs( self.members_cache ) do
                        if member.user_id == user_id then
                            table.remove( self.members_cache, i )
                            break
                        end
                    end
                    self:UpdateMembersCount( self.members_count - 1 )
            
                    player_data.clan_stats = player_data.clan_stats and fromJSON( player_data.clan_stats ) or { }
                    if player_data.clan_rank ~= 1 or player_data.clan_exp ~= 0 then
                        local ex_members = self.ex_members or { }
                        ex_members[ user_id ] = {
                            rank = player_data.clan_rank,
                            exp = player_data.clan_exp,
                            stats = player_data.stats,
                        }
                        self:SetPermanentData( "ex_members", ex_members )
                    end
                    DB:exec( "UPDATE nrp_players SET clan_id = NULL WHERE id = ? LIMIT 1", user_id, clan_id )
        
                    SendElasticGameEvent( player_data.client_id, "clan_leave", {
                        clan_id = self.id,
                        clan_name = self.name,
                        leave_status = 2,
                        clan_rank = player_data.clan_rank,
                        clan_role = player_data.clan_role,
                    } )
                end
                if source_player then
                    source_player:ShowSuccess( "Вы успешно выгнали игрока " .. player_data.nickname )
                    triggerClientEvent( source_player, "onClientUpdateClanUI", source_player, {
                    	members = self.members_cache,
                    } )
                end
			end, { },
			"SELECT client_id, nickname, clan_rank, clan_exp, clan_stats, clan_role FROM nrp_players WHERE id = ? AND clan_id = ? LIMIT 1", user_id, self.id
        )
        return true
    end

    -- Изменение роли игрока в кэше

    self.RequestChangePlayerRole = function( self, user_id, new_role )
        local players_with_this_role_count = 0
        for i, member in pairs( self.members_cache ) do
            if member.role == new_role then
                players_with_this_role_count = players_with_this_role_count + 1
            end
        end

        local max_count = CLAN_ROLES_PLAYERS_LIMIT[ new_role ]
        if max_count and players_with_this_role_count >= max_count then
            return false, "Макс. количество участников на этой роли: " .. max_count
        end

        self:UpdateMemberData( user_id, "role", new_role )

        return true
    end

    self.UpdateMemberData = function( self, user_id, key, value )
        for i, member in pairs( self.members_cache ) do
            if member.user_id == user_id then
                member[ key ] = value
            end
        end
        return true
    end

    self.GetOnlineMembers = function( self )
        return self.team.players
    end

    self.GetMembers = function( self, callback, ... )
        if not callback then
            return self.members_cache
        end

        if not self.is_members_loaded then
            DB:queryAsync(
                function( query, ... )
                    local result = dbPoll( query, -1 )
                    local members = type( result ) == "table" and result or {}
                    local list = { }

                    -- Проверяем, т.к. игрок мог вступить в клан, а его данные в БД ещё не обновились
                    local online_used_ids = { }
                    for i, player in pairs( self:GetOnlineMembers( ) ) do
                        local user_id = player:GetUserID( )
                        table.insert( list, { 
                            user_id = user_id,
                            name = player:GetNickName( ),
                            role = player:GetClanRole( ),
                            -- exp = player:GetClanEXP( ),
                            rank = player:GetClanRank( ),
                            -- stats = player:GetClanStats( ),
                            last_date = true,
                        } )
                        online_used_ids[ user_id ] = true
                    end

                    for i, player_data in pairs( members ) do
                        if not online_used_ids[ player_data.id ] then
                            -- Проверяем, т.к. игрок мог покинуть клан, а его данные в БД ещё не обновились
                            if not GetPlayer( player_data.id ) then
                                if utf8.sub( player_data.nickname, 1, 1 ) ~= "-" then
                                    table.insert( list, { 
                                        user_id = player_data.id,
                                        name = player_data.nickname,
                                        role = player_data.clan_role or 1,
                                        -- exp = player_data.clan_exp,
                                        rank = player_data.clan_rank,
                                        -- stats = fromJSON( player_data.clan_stats ),
                                        last_date = player_data.last_date,
                                    } )
                                end
                            end
                        end
                    end

                    self.members_cache = list
                    self.is_members_loaded = true
                    self:UpdateMembersCount( )
                    callback( list, ... )
                end, { ... },
                -- "SELECT id, nickname, clan_rank, clan_exp, clan_stats, clan_role, last_date FROM nrp_players WHERE clan_id = ?", self.id
                "SELECT id, nickname, clan_rank, clan_role, last_date FROM nrp_players WHERE clan_id = ?", self.id
            )
        else
            callback( self.members_cache, ... )
        end
    end

    self.GetMembersCount = function( self )
        return self.members_count
    end

    self.UpdateMembersCount = function( self, count )
        self:SetPermanentData( "members_count", count or #self.members_cache )
        self:UpdateLeaderboardData( LB_CLAN_MEMBERS_COUNT, self.members_count )
    end

    self.SetClosed = function( self, state )
        self:SetPermanentData( "is_closed", state )
        self:UpdateLeaderboardData( LB_CLAN_IS_CLOSED, state )
        return true
    end

    -- Кэш данных для лидербоарда

    self.leaderboard_data = { }

    self.UpdateLeaderboardData = function( self, key, value )
        if key then
            if key == LB_CLAN_TAG then
                self.leaderboard_data[ LB_CLAN_TAG ] = self.cartel and self.tag or nil
            else
                self.leaderboard_data[ key ] = value
            end
        else
            local data = self.leaderboard_data
            data[ LB_CLAN_ID ] = self.id
            -- data[ LB_CLAN_NAME ] = self.name
            data[ LB_CLAN_MONEY ] = self:GetMoney( )
            data[ LB_CLAN_HONOR ] = self:GetHonor( )
            data[ LB_CLAN_SCORE ] = self:GetScore( )
    
            data[ LB_CLAN_SLOTS ] = self.slots
            data[ LB_CLAN_MEMBERS_COUNT ] = self.members_count
            data[ LB_CLAN_IS_CLOSED ] = self.is_closed

            if self.cartel then
                data[ LB_CLAN_TAG ] = self.tag
            end
        end
    end
    self:UpdateLeaderboardData( )

    self.IsBlocked = function( self )
        local blocked = self.blocked
        if blocked and blocked >= os.time( ) then
            return true, self.blocked_reason
        end

        return false
    end

    self.timers = { }

    self.SetDeleteDate = function( self, state )
        if isTimer( self.timers.delete_timer ) then
            killTimer( self.timers.delete_timer )
        end
        if state then
            self:SetPermanentData( "delete_date", os.time( ) + CLAN_DELETE_AFTER_TIME )
            self.timers.delete_timer = setTimer( function( )
                self:destroy( )
            end, CLAN_DELETE_AFTER_TIME * 1000, 1 )

            triggerClientEvent( self:GetOnlineMembers( ), "ShowInfo", resourceRoot, "Твой клан будет удален через 2 дня" )
        else
            self:SetPermanentData( "delete_date", nil )
        end
    end
    
    if self.delete_date then
        self.timers.delete_timer = setTimer( function( )
            self:destroy( )
        end, math.max( 0, self.delete_date - os.time( ) ) * 1000, 1 )
    end

    self.destroy = function( self )
        Async:foreach( self:GetOnlineMembers( ), function( v )
            if isElement( v ) and v:GetClanID( ) == self.id then
                v:ShowInfo( "Твой клан был удален" )
                self:LeavePlayer( v )
            end
        end )
        DB:exec( "UPDATE nrp_players SET clan_id = NULL WHERE clan_id = ?", tostring( self.id ) )
    
        if self.team then self.team:destroy( ) end
        DestroyTableElements( self.timers )

        if self.cartel then
            SetCartelData( self.cartel, nil )
        end
    
        for i = 1, #CLANS_LIST do
            if CLANS_LIST[ i ] == self then
                table.remove( CLANS_LIST, i )
                table.remove( LEADERBOARD_LIST, i )
                break
            end
        end
        CLANS_BY_ID[ self.id ] = nil
    
        DB:exec( "DELETE FROM nrp_clans_new WHERE id = ?", self.id )
        
        self.deleted = true

        return true
    end

    table.insert( CLANS_LIST, self )
    table.insert( LEADERBOARD_LIST, self.leaderboard_data )
    CLANS_BY_ID[ self.id ] = self

    if self.cartel then
        SetCartelData( self.cartel, self )
    end
    
    -- На случай, если кто-то(я) не будет юзать SetPermanentData для перманентных данных
    metatable.__newindex = function( _self, key, value )
        rawset( self, key, value )
        if DEFAULT_PERMADATA_VALUES[ key ] then
            self:SetPermanentData( key, value )
            outputDebugString( "attempt to dolbaeb (SetPermanentData expected) [self." .. tostring( key ) .. " = " .. tostring( value ) .. "]", 1 )
        end
    end
    
    return self
end

function ResetClansTodayBestMembers( )
    for i = 1, #CLANS_LIST do
        local clan = CLANS_LIST[ i ]
        clan.today_members_scores = { }
        clan.today_best_member = { }
    end
    setTimer( ResetClansTodayBestMembers, MS24H, 1 )
end
ExecAtTime( "04:00", ResetClansTodayBestMembers )

Player.GetClan = function( self )
    return CLANS_BY_ID[ self:GetClanID( ) ]
end

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source
    local clan_id = tonumber( player:GetClanID( ) )
    if not clan_id then return end

    local clan = CLANS_BY_ID[ clan_id ]
    if clan then
        player:SetClanID( clan_id )
        -- player:setTeam( clan.team )
        player:SetClanRank( player:GetClanRank( ) )
        player:SetClanEXP( player:GetClanEXP( ) )
        -- UpdateClanRankUnlocks( player )
        CheckClanSeasonRewards( clan, player )
        clan:UpdateMemberData( player:GetUserID( ), "last_date", true )
    else
        player:SetClanID( )
    end
end

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source
    local clan = player:GetClan( )

    if clan then
        CheckClanSkins( clan, player )
        CheckCartelTax( clan, player )
        CheckClanWar( clan, player )
        triggerClientEvent( player, "onClientClanUpgradesSync", player, clan:GetUpgrades( ) )

        local delete_date = clan:GetPermanentData( "delete_date" )
        if delete_date then
            player:PhoneNotification( {
                title = "Клан",
                msg = "Твой клан будет удалён через ".. ( getHumanTimeString( delete_date ) or "1 мин" )
            } )
        end
    end
    triggerClientEvent( player, "onClientCartelsTagsUpdate", player, CARTEL_TAGS )
end

function UpdatePlayerLastDate( player )
    local player = isElement( player ) and player or source
    local clan = player:GetClan( )
    if clan then
        clan:UpdateMemberData( player:GetUserID( ), "last_date", os.time( ) )
    end
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, UpdatePlayerLastDate )

function UpdatePlayerNickName( nickname )
    local player = source
    local clan = player:GetClan( )
    if clan then
        clan:UpdateMemberData( player:GetUserID( ), "name", nickname )
    end
end
addEvent( "onPlayerNickNameChange" )
addEventHandler( "onPlayerNickNameChange", root, UpdatePlayerNickName )

addEvent( "OnPlayerForceSwitchTeam", true )
addEventHandler( "OnPlayerForceSwitchTeam", root, function( player, state )
	player = client or source
    if state then
        local clan = player:GetClan( )
        if clan and clan.team then 
            setPlayerTeam( player, clan.team )
        end
    else
        setPlayerTeam( player, nil )
    end
end )

-- Создание клана

CLAN_CREATION_WAITING_PLAYERS = { }

function onPlayerWantCreateClan_handler( name, tag, way, base_id )
    local player = client or source

    if CLAN_CREATION_WAITING_PLAYERS[ player:GetUserID( ) ] then
        triggerClientEvent( player, "onClientClanCreateResponse", player, "Ваш клан создается, ожидайте, пожалуйста!" )
        return
    end

    local cost = ( player:getData( "offer_clan" ) or { } ).new_price
    if not cost or ( ( player:getData( "offer_clan" ) or { } ).time_to or 0 ) <= getRealTimestamp( ) then
        cost = CLAN_CREATION_COST
    end

    if player:GetMoney( ) < cost then
		player:EnoughMoneyOffer( "Clan creation", cost, "onPlayerWantCreateClan", player, name, tag, base_id )
        triggerClientEvent( player, "onClientClanCreateResponse", player )
        return
    end

    if utf8.len( name ) < 3 or utf8.len( name ) > 12 then
        triggerClientEvent( player, "onClientClanCreateResponse", player, "Название должно содержать от 3 до 12 символов" )
        return
    end

    if player:IsInFaction( ) then
        triggerClientEvent( player, "onClientClanCreateResponse", player, "Ты не можешь быть в клане и во фракции одновременно!" )
        return
    end

    if player:GetClan( ) then
        triggerClientEvent( player, "onClientClanCreateResponse", player, "Ты должен покинуть текущий клан, чтобы создать свой!" )
        return
    end

    for i = 1, #CLANS_LIST do
        if CLANS_LIST[ i ].name == name then
            triggerClientEvent( player, "onClientClanCreateResponse", player, "Это название уже занято" )
            return false
        end
    end

    if MAX_CLANS_COUNT and #CLANS_LIST >= MAX_CLANS_COUNT then
        triggerClientEvent( player, "onClientClanCreateResponse", player, "Создано макс. колво кланов!" )
        return
    end

    -- if player:GetAccessLevel( ) <= 9 then
    --     triggerClientEvent( player, "onClientClanCreateResponse", player, "Только админы могут создать кланы!" )
    --     return
    -- end

    local clan = Clan( {
        name = name,
        tag = tag,
        way = way,
        owner_id = player:GetUserID( ),
        base_id = base_id or 1,
        create_date = os.time( ),
    } )

    if clan then
        CLAN_CREATION_WAITING_PLAYERS[ player:GetUserID( ) ] = true
        player:SetPermanentData( "clan_id", clan.id ) -- Чтобы игрок не мог вступить в другой клан, пока создается этот. Если клан не будет создан, то он сбросится в callbacke или при перезаходе

        DB:queryAsync( InsertClanData_callback, { clan.id, clan.owner_id, cost }, "INSERT INTO nrp_clans_new ( data ) VALUES ( ? )", toJSON( clan.permanent_data, true ) )
    else
        triggerClientEvent( player, "onClientClanCreateResponse", player, "Неизвестная ошибка" )
    end
end
addEvent( "onPlayerWantCreateClan", true )
addEventHandler( "onPlayerWantCreateClan", root, onPlayerWantCreateClan_handler )

function InsertClanData_callback( query, clan_temp_id, owner_id, cost )
    CLAN_CREATION_WAITING_PLAYERS[ owner_id ] = nil
    local clan = CLANS_BY_ID[ clan_temp_id ]
    if not clan then return end -- Если уже был удален

    local player = GetPlayer( owner_id ) -- Юзаем GetPlayer, т.к. игрок мог перезайти

    local result, num_affected_rows, last_insert_id = query:poll( -1 )
    if result then
        clan.id = last_insert_id
        clan:SetPermanentData( "id", clan.id )
        clan.team:setID( "c" .. clan.id )
        clan.leaderboard_data[ LB_CLAN_ID ] = clan.id

        CLANS_BY_ID[ clan_temp_id ] = nil
        CLANS_BY_ID[ clan.id ] = clan

        if player and player:GetPermanentData( "clan_id" ) == clan_temp_id then
            clan:JoinPlayer( player )
            player:SetClanRole( CLAN_ROLE_LEADER )
            player:TakeMoney( cost, "clan_create" )

            local old_clan_compensation = player:GetPermanentData( "old_clan_compensation" )
            if old_clan_compensation then
                if old_clan_compensation.money then
                    clan:GiveMoney( old_clan_compensation.money, true )
                end
                if old_clan_compensation.slots_upgrade then
                    for level = 1, old_clan_compensation.slots_upgrade do
                        clan:ApplyUpgrade( CLAN_UPGRADE_SLOTS, level )
                    end
                end
                player:SetPermanentData( "old_clan_compensation", nil )
            end

            player:ShowSuccess( "Клан успешно создан!" )
            triggerClientEvent( player, "onClientClanCreateResponse", player, true )
            triggerEvent( "onPlayerWantEnterClanHouse", player, clan.base_id )

            triggerEvent( "onPlayerCreateClan", player, clan_id )

            SendElasticGameEvent( player:GetClientID( ), "clan_creation", {
                clan_id = clan.id,
                clan_name = clan.name,
                logo_id = clan.tag,
                clan_type = CLAN_WAY_KEYS[ clan.way ],
                creation_cost = cost,
                clan_location = CLAN_BASE_KEYS_BY_ID[ clan.base_id ],
            } )
        else
            clan:destroy( )
        end
    else
        clan:destroy( )
        if player and player:GetPermanentData( "clan_id" ) == clan_temp_id then
            triggerClientEvent( player, "onClientClanCreateResponse", player, "Неизвестная ошибка" )
            player:SetPermanentData( "clan_id", nil )
        end
    end
end

function onPlayerWantJoinClan_handler( clan_id, is_invited )
    local player = client or source
    local clan = CLANS_BY_ID[ clan_id ]
    if clan then
        clan:RequestJoinPlayer( player, is_invited, true )
    end
end
addEvent( "onPlayerWantJoinClan", true )
addEventHandler( "onPlayerWantJoinClan", root, onPlayerWantJoinClan_handler )

function onPlayerWantLeaveClan_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if clan then
        if player:GetClanRole( ) == CLAN_ROLE_LEADER then
            player:ShowError( "Вы не можете покинуть клан, т.к. являетесь его лидером" )
            return
        end
        clan:LeavePlayer( player )
    end
end
addEvent( "onPlayerWantLeaveClan", true )
addEventHandler( "onPlayerWantLeaveClan", root, onPlayerWantLeaveClan_handler )

function onPlayerWantDeleteClan_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if clan then
        if player:GetClanRole( ) ~= CLAN_ROLE_LEADER then
            player:ShowError( "Только лидер может удалить клан" )
            return
        end
        clan:SetDeleteDate( true )
		triggerClientEvent( player, "onClientUpdateClanUI", player, {
			delete_date = clan.delete_date,
		} )
    end
end
addEvent( "onPlayerWantDeleteClan", true )
addEventHandler( "onPlayerWantDeleteClan", root, onPlayerWantDeleteClan_handler )

function onPlayerWantCancelDeleteClan_handler( )
    local player = client or source
    local clan = player:GetClan( )
    if clan then
        if player:GetClanRole( ) ~= CLAN_ROLE_LEADER then
            player:ShowError( "Только лидер может отменить удаление клана" )
            return
        end
        clan:SetDeleteDate( false )
		triggerClientEvent( player, "onClientUpdateClanUI", player, {
			delete_date = false,
		} )
    end
end
addEvent( "onPlayerWantCancelDeleteClan", true )
addEventHandler( "onPlayerWantCancelDeleteClan", root, onPlayerWantCancelDeleteClan_handler )

CallClanFunction = function( clan_id, key, ... )
    local clan = CLANS_BY_ID[ clan_id ]
    if clan then
        return clan[ key ]( clan, ... )
    end
    return
end






if SERVER_NUMBER > 100 then
    addCommandHandler( "setclanscountlimit", function( player, cmd, count )
        if not tonumber( count ) then
            outputConsole( "Введите колво" )
            return
        end

        MAX_CLANS_COUNT = tonumber( count ) or 6
    end )

    addCommandHandler( "setallplayersmoney", function( player, cmd, count )
        if not tonumber( count ) then
            outputConsole( "Введите колво" )
            return
        end

        for i, player in pairs( GetPlayersInGame( ) ) do
            player:SetMoney( tonumber( count ) )
        end
    end )

    addCommandHandler( "deleteclan", function( player, cmd, id ) 
        if not id then
            for i, v in pairs( CLANS_BY_ID ) do 
                outputConsole( i..": ".. v.name, player )
            end
            return
        else
            id = tonumber( id )
            if not id then player:ShowError( "ID должен быть в цифрах" ) return end
            local found_clan = CLANS_BY_ID[ id ]
            if id == -1 then
                found_clan = player:GetClan( )
            end
            
            if not found_clan then player:ShowError( "Клан не найден" ) return end

            found_clan:destroy( )
            player:ShowInfo( "Клан успешно удален" )
        end
    end )
end