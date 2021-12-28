PLAYER_TIMERS = { }

SERVERS_CONFIGS = { }
function UpdateServerConfig( )
    APIDB:queryAsync( function( query )
        local result = query:poll( 0 )
        SERVERS_CONFIGS = { }
        for i, v in pairs( result ) do
            local config = {
                id        = v.id,
                host      = v.ip,
                port      = tonumber( v.udpPort1 ),
                http_port = tonumber( v.tcpPort ),
                name      = v.name,
            }
            table.insert( SERVERS_CONFIGS, config )
        end
    end, { }, "SELECT * FROM ServersInfos" )
end
UpdateServerConfig( )
UPDATE_SERVER_TIMER = setTimer( UpdateServerConfig, 60 * 1000, 0 )

function GetServerConfigByID( id )
    for i, v in pairs( SERVERS_CONFIGS ) do
        if v.id == id then
            return v
        end
    end
end

function GetTargetServer( config )
    return config.host .. ":" .. config.http_port
end

function table.has_value( tbl, value )
    for i, v in pairs( tbl ) do
        if v == value then return true end
    end
end

function table.has_key( tbl, key )
    for i, v in pairs( tbl ) do
        if i == key then return true end
    end
end

function GetActiveTransfers( )
    local active_transfers = { }

    local function check_transfer( transfer )
        if not table.has_value( transfer.from_servers, SERVER_NUMBER ) then return end

        local ts = getRealTimestamp( )
        if transfer.start_date and ts < transfer.start_date then return end
        if transfer.finish_date and ts > transfer.finish_date then return end

        return true
    end

    for i, v in pairs( GetConfig( ) ) do
        if check_transfer( v ) then
            v.server_config = GetTransferrableTargetServerConfig( v )
            table.insert( active_transfers, v )
        end
    end

    return active_transfers
end

function GetSuitableTransfer( player )
    local transfers = GetActiveTransfers( )

    local function check_suitable_transfer( transfer )
        if transfer.from_level and player:GetLevel( ) < transfer.from_level then return end
        return true
    end

    for i, v in pairs( transfers ) do
        if check_suitable_transfer( v ) then
            return v
        end
    end
end

function GetConfig( )
    local config = MariaGet( "account_transfer_2_config" )
    return fromJSON( config )
end

function GetTransferFinishTime( transfer )
    return transfer.finish_date
end

function GetTransferExpBonusData( transfer, float )
    local bonus, time = unpack( transfer.exp_bonus )
    return float and ( 1 + bonus / 100 ) or bonus, time
end

function GetTransferJobBonusData( transfer, float )
    local bonus, time = unpack( transfer.job_bonus )
    return float and ( 1 + bonus / 100 ) or bonus, time
end

function GetTransferrableServers( transfer )
    local servers = transfer.from_servers
    local n = { }
    for i, v in pairs( servers ) do
        n[ v ] = true
    end
    return n
end

function GetTransferrableTargetServerConfig( transfer )
    return GetServerConfigByID( transfer.to_server )
end

function GetTransferrableTargetServer( transfer )
    return GetTargetServer( GetServerConfigByID( transfer.to_server ) )
end

function GetTransferrableLevel( transfer )
    return transfer.from_level
end

function onResourceStart_handler( )
    setTimer( function( )
        --iprint( "Transfer handler started with config: ", GetConfig( ) )
        for i, v in pairs( GetPlayersInGame( ) ) do
            onPlayerReadyToPlay_handler( v )
        end
    end, 2000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source

    -- Выдача бонуса
    local transfer = player:GetPermanentData( "transfer_finished" )
    if transfer then
        if transfer.exp_bonus then
            player:AddPermanentExpBonus( GetTransferExpBonusData( transfer, true ) )
        end
        if transfer.job_bonus then
            player:AddJobMoneyBonus( GetTransferJobBonusData( transfer, true ) )
        end

        local give_offers = transfer.give_offers
        if give_offers then
            if give_offers.donate_x2 then
                exports.nrp_welcome_x2:GiveOffer( player, give_offers.donate_x2.duration )
            end
            if give_offers.premium_3d then
                exports.nrp_offer_premium_3d:GiveOffer( player, give_offers.premium_3d.duration )
            end
        end

        player:SetPermanentData( "transfer_finished", nil )

        -- Показ окна приветствия
        triggerClientEvent( player, "ShowWelcomeTransferWindow", resourceRoot, transfer )

        triggerEvent( "onPlayerJoinAfterTransfer", player )
    end

    local transfer = GetSuitableTransfer( player )
    if not transfer then return end

    local target_connect_server = GetTransferrableTargetServerConfig( transfer )
    local target_server = GetTransferrableTargetServer( transfer )
    if target_connect_server.id < 100 and player:GetAccessLevel( ) > 0 then return end

    local level = player:GetLevel( )

    CommonDB:queryAsync( function( query )
        if not isElement( player ) then return end

        local result = query:poll( -1 )

        -- Нет переносов
        if #result <= 0 then
            CommonDB:exec(
                "INSERT INTO account_transfer ( client_id, date, human_date, server, server_target, status, nickname, level ) VALUES ( ?, UNIX_TIMESTAMP( ), NOW(), ?, ?, 'offered', ?, ? )",
                player:GetClientID( ), SERVER_NUMBER, target_connect_server.id, player:GetNickName( ), level
            )
            player:ShowAccountTransfer( true )

            -- Есть текущие переносы с любого из серверов
        else
            -- Ищем есть ли предложенные переносы с этого сервера
            local transfer

            for i, v in pairs( result ) do
                if v.server == SERVER_NUMBER and v.status == "offered" then
                    transfer = v
                    break
                end
            end

            -- Есть активный перенос - показываем, иначе игнорируем
            if transfer then
                player:ShowAccountTransfer( false )
            end
        end
    
    end, { }, "SELECT * FROM account_transfer WHERE client_id=?", player:GetClientID( ) )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function Player:ShowAccountTransfer( is_first_time, duration )
    local transfer = GetSuitableTransfer( self )

    local finish_date = ( duration and getRealTimestamp( ) + duration ) or GetTransferFinishTime( transfer )

    PLAYER_TIMERS[ self ] = setTimer( function( )
        self:HideAccountTransfer( )
    end, ( finish_date - getRealTimestamp( ) ) * 1000, 1, self )
    addEventHandler( "onPlayerQuit", self, onPlayerQuit_handler )

    if transfer.exp_bonus then
        local exp_bonus = GetTransferExpBonusData( transfer )
        local job_bonus = GetTransferJobBonusData( transfer )
        local duration = math.ceil( math.max( ({ GetTransferExpBonusData( transfer ) })[ 2 ], ({ GetTransferJobBonusData( transfer ) })[ 2 ] ) / ( 24 * 60 * 60 ) )
    end

    local target_connect_server = GetTransferrableTargetServerConfig( transfer )
    
    --iprint( "show with", exp_bonus, job_bonus, duration )
    triggerClientEvent( self, "onClientPlayerTransferShow", resourceRoot, finish_date, is_first_time, exp_bonus, job_bonus, duration, transfer )

    if is_first_time then
        triggerEvent( "onPlayerTransferShowFirst", self, true )
    end
end

function onPlayerQuit_handler( )
    if isTimer( PLAYER_TIMERS[ source ] ) then killTimer( PLAYER_TIMERS[ source ] ) end 
    PLAYER_TIMERS[ source ] = nil
    removeEventHandler( "onPlayerQuit", source, onPlayerQuit_handler )
end

function Player:HideAccountTransfer( )
    onPlayerQuit_handler( )
    triggerClientEvent( self, "onClientPlayerTransferHide", resourceRoot )
end

function onPlayerRequestTranserList_handler( from_f4 )
    local currency_total, logdata_total, all_permanent_data, sold_info, saved_total = client:GetAllCost( )

    local list_saved = { }

    table.insert( list_saved, { text = 'Имя персонажа "' .. client:GetNickName( ) .. '"' } )
    table.insert( list_saved, { text = "Игровой баланс" } )
    if client:GetDonate( ) > 0 then
        table.insert( list_saved, { text = "Донат-валюта" } )
    end
    if client:GetBusinessCoins( ) > 0 then
        table.insert( list_saved, { text = "Бизнес-монеты" } )
    end

    -- Премиум
    if client:IsPremiumActive( ) then
        table.insert( list_saved, { text = "Премиум (" .. getHumanTimeString( client:getData( "premium_time_left" ) ) .. ")" } )
    end

    -- Кейсы
    local cases_count = 0
    for i, v in pairs( client:GetCases( ) ) do
        cases_count = cases_count + ( tonumber( v ) or 0 )
    end
    if cases_count > 0 then
        table.insert( list_saved, { text = "Кейсы (" .. cases_count .. " шт.)" } )
    end

    -- Жетоны колеса фортуны
    local coins = client:GetCoins( )
    if coins > 0 then
        table.insert( list_saved, { text = "Жетоны колеса фортуны (" .. coins .. " шт.)" } )
    end
    local coins_gold = client:GetCoins( "gold" )
    if coins_gold > 0 then
        table.insert( list_saved, { text = "Жетоны VIP колеса фортуны (" .. coins_gold .. " шт.)" } )
    end

    -- Слоты машин
    local car_slots = client:GetPermanentData( "car_slots" ) or 0
    if car_slots > 0 then
        table.insert( list_saved, { text = "Приобретенные слоты машин (" .. car_slots .. " шт.)" } )
    end

    -- Транспорт обычный
    for i, v in pairs( client:GetVehicles( false, true ) ) do
        if isElement( v ) then
            table.insert( list_saved, { text = GetVehicleNameFromModel( v.model ) .. " #8c97a5(" .. v:GetNumberPlateHR( true ) .. ")" } )
        end
    end

    -- Спешл транспорт
    for i, v in pairs( client:GetSpecialVehicles( ) ) do
        table.insert( list_saved, { text = GetVehicleNameFromModel( v[ 2 ] ) } )
    end

    -- Танцы и анимации
    if next( client:GetPermanentData( "unlocked_animations" ) or { } ) then
        table.insert( list_saved, { text = "Танцы и анимации" } )
    end

    -- Права на транспорт
    if next( client:GetPermanentData( "licenses" ) or { } ) then
        table.insert( list_saved, { text = "Права на транспорт" } )
    end

    -- Бустеры гонок
    local race_boosters = client:GetPermanentData( "race_boosters" ) or { }
    local race_boosters_id = { "ram", "nitro", "slowmo", "wave" }
    local race_boosters_count = 0
    for i, v in pairs( race_boosters_id ) do
        local count = tonumber( race_boosters[ v ] ) or 0
        race_boosters_count = race_boosters_count + count
    end
    if race_boosters_count > 0 then
        table.insert( list_saved, { text = "Бустеры Гонок (" .. race_boosters_count .. " шт.)" } )
    end

    -- Сезонные награды
    table.insert( list_saved, { text = "Опыт сезонных наград" } )
    if exports.nrp_battle_pass:IsPlayerPremiumActive( client ) then
        table.insert( list_saved, { text = "Премиальная линейка сезонных наград" } )
    end
    if exports.nrp_battle_pass:IsPlayerBoosterActive( client ) then
        table.insert( list_saved, { text = "Усиление сезонных наград" } )
    end

    for k, v in pairs( saved_total ) do
        table.insert( list_saved, v )
    end

    if client:IsInFaction( ) then
        table.insert( list_saved, { text = "Опыт во фракции " .. FACTIONS_NAMES[ client:GetFaction( ) ] } )
    end

    -- Всякая хуйня
    table.insert( list_saved, { text = "Инвентарь" } )
    table.insert( list_saved, { text = "Оружие" } )
    table.insert( list_saved, { text = "Скины" } )
    table.insert( list_saved, { text = "Аксессуары" } )
    table.insert( list_saved, { text = "Товары для хобби" } )
    table.insert( list_saved, { text = "Детали внутреннего тюнинга и тюнинг-кейсы" } )
    table.insert( list_saved, { text = "Винилы и винил-кейсы" } )
    table.insert( list_saved, { text = "Неоны" } )
    table.insert( list_saved, { text = "Обои и рингтоны для телефона" } )
    table.insert( list_saved, { text = "Баланс суммы на кассе кинотеатра" } )
    table.insert( list_saved, { text = "Рецепты для приготовления еды" } )
    table.insert( list_saved, { text = "Достижения" } )
    table.insert( list_saved, { text = "Социальный рейтинг" } )
    table.insert( list_saved, { text = "Счетчик ежедневных наград" } )

    local clan_data
    if client:IsInClan( ) then
        local clan_id = client:GetClanID( )
        clan_data = {
            name = GetClanData( clan_id, "name" ),
            way = CLAN_WAY_NAMES[ GetClanData( clan_id, "way" ) ],
            tag = GetClanData( clan_id, "tag" ),
            money = GetClanMoney( clan_id ),
            honor = GetClanHonor( clan_id ),
            members = GetClanData( clan_id, "members_count" ) .. "/" .. GetClanData( clan_id, "slots" ),
            lb_position = exports.nrp_clans:GetClanLeaderboardPosition( clan_id ),
        }
    end

    local transfer = GetSuitableTransfer( client )
    if not transfer then return end
    local target_connect_server = GetTransferrableTargetServerConfig( transfer )

    triggerClientEvent( client, "onClientPlayerShowTransferInfo", resourceRoot, {
        server     = target_connect_server,
        currency   = currency_total,
        list_sold  = sold_info,
        list_saved = list_saved,
        clan_data  = clan_data,
    } )

    triggerEvent( "onPlayerTransferOfferShowInfoWindow", client, currency_total, from_f4 )
end
addEvent( "onPlayerRequestTransferList", true )
addEventHandler( "onPlayerRequestTransferList", root, onPlayerRequestTranserList_handler )