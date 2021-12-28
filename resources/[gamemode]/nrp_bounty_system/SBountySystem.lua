Extend( "SPlayerOffline" )
Extend( "SPlayer" )
Extend( "SClans" )
Extend( "SDB" )

enum "ORDERS_WAY" {
    "KILL_BY_CLAN",
    "ARREST_BY_FACTION"
}

killers = { } -- [ID of who has died] = ID of last killer
orders = { }
positions = { } -- [player element] = { x = number, y = number, valid_to = timestamp }
death_time = { }

local SAVE_TIME = SERVER_NUMBER > 100 and 60 or 5 * 60 * 1000 -- every 5 minutes (ms)
local SAVE_POS_TIME = 15 * 1000 -- every 15 seconds
local SPUTNIK_TIME_UP = 30 -- every 30 seconds (sec)
local AUTO_COMPLETE_AFTER = 72 * 3600 -- 72 hours (sec)

function loadOrder( params )
    table.insert( orders, params )
    updateTimerHUD( params )
end

function createOrder( userID, clientID, targetID, orderWay, clanID )
    local counter = 0
    for _, data in pairs( orders ) do
        if data.complete_date == 0 then -- if non completed
            if data.target_uid == targetID then
                return false, "Данный игрок уже заказан"

            elseif data.source_uid == userID then
                counter = counter + 1

                if counter >= 5 then
                    return false, "Вы не можете заказать\nбольше 5 игроков"
                end
            end
        end
    end

    local target = GetPlayer( targetID )
    local currentTime = getRealTimestamp( )
    local p = {
        source_uid = userID,
        source_client_id = clientID,
        target_uid = targetID,
        target_cid = clanID,
        target_client_id = target and target:GetClientID( ) or "",
        target_skin_id = target and ( target:GetSkins( ).s1 or 0 ) or 0,
        order_way = orderWay,
        last_position = getPlayerPosition( target ) or { x = 0, y = 0 },
        last_date = currentTime,
        creation_date = currentTime,
        complete_date = 0,
        time_passed = 0,
    }

    local function callback( query )
        if not query then return end
        local data = dbPoll( query, 0 )

        if type( data ) ~= "table" or not data[1] or not data[1].id then return end

        p.id = data[1].id
        loadOrder( p )
        sendInfoAboutNewOrder( p )
    end

    DB:exec(
        "INSERT INTO nrp_bounty_orders ( source_uid, source_client_id, target_uid, target_cid, order_way, last_position, last_date, creation_date, complete_date, time_passed ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )",
        p.source_uid, p.source_client_id, p.target_uid, p.target_cid, p.order_way, toJSON( p.last_position, true ), p.last_date, p.creation_date, p.complete_date, p.time_passed
    )

    DB:queryAsync( callback, { }, "SELECT id FROM nrp_bounty_orders ORDER BY id DESC LIMIT 1" )

    return true
end

function updateTimerHUD( params )
    local player = GetPlayer( params.target_uid ) -- is player online?
    if not player or params.complete_date > 0 then return end

    local timeLeft = calcTimeLeft( player, params )
    if timeLeft <= 0 then return end

    player:SetPrivateData( "hunting", {
        timeTo = getRealTimestamp( ) + timeLeft,
        way = params.order_way
    } )
end

function sendInfoAboutNewOrder( params )
    local player = GetPlayer( params.target_uid )
    if not player then return end

    player:PhoneNotification( {
        special = "order_for_bounty",
        title = "Вы в розыске!"
    } )

    local nickname = player:GetNickName( )
    local factionID = player:GetFaction( ) or 0
    local clanID = player:GetClanID( ) or 0
    clanID = type( clanID ) == "number" and clanID or 0

    for _, p in pairs( GetPlayersInGame( ) ) do
        local pFactionID = p:GetFaction( ) or 0
        local pClanID = p:GetClanID( ) or 0
        pClanID = type( pClanID ) == "number" and pClanID or 0
        local pClanRole = p:GetClanRole( )
        local check = ( pFactionID > 0 or pClanID > 0 ) and ( ( pClanID ~= clanID ) or ( pFactionID ~= factionID ) ) or false

        if check then
            if params.order_way == KILL_BY_CLAN and CLAN_MEMBER_REWARDS[ pClanRole ] then
                p:PhoneNotification( {
                    title = "Новый заказ",
                    msg = [[Вы получили заказ за голову ]] .. nickname .. [[.
                    После выполнения заказа ваша награда составит ]] .. format_price( CLAN_MEMBER_REWARDS[ pClanRole ] or 0 ) .. [[ рублей, награда вашего клана составит ]] .. format_price( CLAN_REWARD ) .. [[ рублей.
                    Для отслеживания примерного место положения цели вы можете арендовать в магазине спутник]]
                } )
            elseif params.order_way == ARREST_BY_FACTION and COPS_FACTIONS[pFactionID] then
                p:PhoneNotification( {
                    title = "Новый заказ",
                    msg = [[Вы получили ориентировку на ]] .. nickname .. [[.
                    За его поимку вы и ваши коллеги получите соответствующую премию.
                    Вам доступно использование спутника для примерного определения места положения преступника в окне "Списка ориентировок"]]
                } )
            end
        end
    end
end

function sendInfoAboutOrder( params )
    local player = GetPlayer( params.target_uid )
    if not player then return end

    local factionID = player:GetFaction( ) or 0
    local clanID = player:GetClanID( ) or 0

    for _, p in pairs( GetPlayersInGame( ) ) do
        local pFactionID = p:GetFaction( ) or 0
        local pClanID = p:GetClanID( ) or 0

        if ( params.order_way == KILL_BY_CLAN and pClanID > 0 and pClanID ~= clanID and pClanID ~= params.target_cid )
        or ( params.order_way == ARREST_BY_FACTION and COPS_FACTIONS[pFactionID] and pFactionID ~= factionID ) then
            p:PhoneNotification( {
                title = "Активный заказ",
                msg = "Разыскиваемый гражданин " .. player:GetNickName( ) .. " в сети, можно начать его поиск"
            } )
        end
    end
end

function getPlayerPosition( player )
    if player and player.dimension == 0 and player.interior == 0 then
        local pos = player.position
        return { x = pos.x, y = pos.y }
    end
end

function getPlayerPositionForSputnik( player )
    local currentTime = getRealTimestamp( )

    if positions[ player ] and positions[ player ].valid_to > currentTime then
        return positions[ player ]
    end

    local pos = getPlayerPosition( player )
    if not pos then
        local params = getOrderOfTarget( player )
        pos = params and table.copy( params.last_position ) or { x = 0, y = 0 }
    end

    for i, v in pairs( pos ) do
        local ran = math.random( - 90, 90 )
        pos[i] = v + ran
    end

    positions[ player ] = pos -- save
    positions[ player ].valid_to = currentTime + SPUTNIK_TIME_UP -- update time

    return pos
end

function completeOrder( order, timestamp, is_success )
    local owner = GetPlayer( order.source_uid )
    local target = GetPlayer( order.target_uid )
    local orderWay = order.order_way
    local order_const = PRICES_FOR_ORDERS[ orderWay ]
    local cash_back = ( not is_success and order_const.cash_back ) and order_const.price or false

    local success_notification = {
        [ KILL_BY_CLAN ] = "Ваш заказ был выполнен! - кланы.",
        [ ARREST_BY_FACTION ] = "Полиция выполнила поимку преступника по вашей ориентировке.",
    }

    local notification = {
        special = "order_for_bounty_completed",
        title = is_success and "Заказ выполнен" or "Заказ не выполнен",
        msg = is_success and success_notification[ orderWay ] or "Ваш обидчик ушел от преследования.",
        data = {
            skin_id = order.target_skin_id,
            nickname = ( order.target_client_id ):GetNickName( ) or "?",
            result = is_success and ( orderWay == 1 and "death" or "arrest" ) or "fail"
        }
    }

    if not is_success and orderWay == KILL_BY_CLAN then
        for idx, player in pairs( GetPlayersInGame( ) ) do
            if ( player:GetClanID( ) or 0 ) > 0 and player ~= target then
                notification.msg = "Скрылся от преследования."
                player:PhoneNotification( notification ) -- send notification
            end
        end
    end

    if owner then
        owner:PhoneNotification( notification ) -- send notification
        if cash_back then
            owner:GiveMoney( cash_back, "bounty_hunters", "cash_back" )
        end
    else
        tostring( order.source_client_id ):PhoneNotification( notification ) -- send notification
        if cash_back then
            DB:exec( "UPDATE nrp_players SET money = money + ? WHERE id = ? LIMIT 1", cash_back, order.source_uid )
        end
    end

    if timestamp then
        triggerEvent( "onOrderForBountyTimeEnd", root, orderWay == 1 and "clans" or "police", order_const.price, order.target_uid )
    end

    order.complete_date = timestamp or getRealTimestamp( ) -- complete

    if target then
        target:SetPrivateData( "hunting", nil ) -- remove
        target:PhoneNotification( { title = "Розыск", msg = "Вы ушли от преследования!" } )
    end
end

function getOrderOfTarget( player )
    local id = player:GetUserID( )
    for _, order in pairs( orders ) do
        if order.target_uid == id and order.complete_date == 0 then -- only non completed
            return order
        end
    end
end

function getOrdersBySource( player )
    local id = player:GetUserID( )
    local player_orders = { }
    for _, order in pairs( orders ) do
        if order.source_uid == id and order.complete_date == 0 then
            table.insert( player_orders, order )
        end
    end

    return player_orders
end

function removeOrdersBySource( player )
    local id = player:GetUserID( )
    for _, order in pairs( orders ) do
        if order.source_uid == id and order.complete_date == 0 then
            order.complete_date = getRealTimestamp( )
        end
    end
end

function calcTimeLeft( player, params )
    local currentTime = getRealTimestamp( )
    local eDate = player:GetPermanentData( "last_enter_date" ) or 0

    local startSearchDate = params.creation_date > eDate and params.creation_date or eDate
    local timeLeft = startSearchDate + SEARCH_TIME - currentTime - params.time_passed

    return timeLeft
end

function updateOrderList( )
    local updatedOrders = { }

    for _, params in pairs( orders ) do
        if params.complete_date == 0 then
            table.insert( updatedOrders, params )
        end
    end

    orders = updatedOrders
end

function savePlayersPositions( )
    for _, params in pairs( orders ) do
        if params.complete_date == 0 then -- if non completed
            local pos = getPlayerPosition( GetPlayer( params.target_uid ) )
            if pos then params.last_position = pos end
        end
    end
end

setTimer( savePlayersPositions, SAVE_POS_TIME, 0 )

function saveOrderList( )
    local currentTime = getRealTimestamp( )

    for _, p in pairs( orders ) do
        local player = GetPlayer( p.target_uid )
        if not player and currentTime > p.last_date + AUTO_COMPLETE_AFTER and p.complete_date == 0 then -- auto complete after 72 hours (offline)
            completeOrder( p, p.last_date + AUTO_COMPLETE_AFTER, false )

        elseif player and p.complete_date == 0 then -- end of search time
            local timeLeft = calcTimeLeft( player, p )
            if timeLeft <= 0 then
                completeOrder( p, currentTime - timeLeft, false )
            end
        end

        local q = "UPDATE nrp_bounty_orders SET target_client_id = ?, target_skin_id = ?, complete_date = ?, time_passed = ?, last_position = ?, last_date = ? WHERE id = ? LIMIT 1"
        DB:exec( q, p.target_client_id, p.target_skin_id, p.complete_date, p.time_passed, toJSON( p.last_position, true ), p.last_date, p.id )
    end

    updateOrderList( ) -- unload completed orders
end

setTimer( saveOrderList, SAVE_TIME, 0 )

if SERVER_NUMBER > 100 then
    addCommandHandler( "bountyautocomplete", function ( _, _, time )
        AUTO_COMPLETE_AFTER = tonumber( time ) and tonumber( time ) or AUTO_COMPLETE_AFTER
    end )

    addCommandHandler( "bountysearchtime", function ( _, _, time )
        SEARCH_TIME = tonumber( time ) and tonumber( time ) or SEARCH_TIME
    end )

    addCommandHandler( "bountyiamkiller", function ( source )
        killers[source] = {
            id = source:GetUserID( ),
            name = source:GetNickName( ),
            clanID = 0,
        }

        triggerClientEvent( source, "onPlayerOrderRevenge", source, killers[source].name )
    end )
end