addEvent( "onPlayerGetOrientations", true )
addEventHandler( "onPlayerGetOrientations", root, function ( )
    if source ~= client then return end

    local factionID = client:GetFaction( ) or 0
    local clanID = client:GetClanID( ) or 0

    local orderWay = nil
    if COPS_FACTIONS[factionID] then orderWay = ARREST_BY_FACTION
    elseif clanID > 0 then orderWay = KILL_BY_CLAN
    else return end

    local orientations = { }

    for idx, order in pairs( orders ) do
        if order.order_way == orderWay and order.complete_date == 0 then
            local player = GetPlayer( order.target_uid )
            if player then
                if ( clanID > 0 and clanID ~= order.target_cid and clanID ~= player:GetClanID( ) )
                or ( factionID > 0 and factionID ~= player:GetFaction( ) ) then
                    local timeLeft = calcTimeLeft( player, order )

                    if timeLeft > 0 then
                        local skin_id = player:GetSkins( ).s1
                        local orientation = table.copy( order )

                        if order.target_skin_id == 0 then -- is empty
                            order.target_skin_id = skin_id
                        end

                        if order.target_client_id == "" then -- is empty
                            order.target_client_id = player:GetClientID( )
                        end

                        orientation.time_left = timeLeft
                        orientation.skin = skin_id
                        table.insert( orientations, orientation )
                    end
                end
            end
        end
    end

    triggerClientEvent( client, "onPlayerGetOrientations", client, orientations )
end )

addEvent( "onPlayerOrderRequest", true )
addEventHandler( "onPlayerOrderRequest", root, function ( orderWay )
    local killer = killers[ client ]
    if not killer or source ~= client or not PRICES_FOR_ORDERS[ orderWay ] then return end

    local data = PRICES_FOR_ORDERS[ orderWay ]
    if not client:HasMoney( data.price ) then
        client:ShowError( "Упс... недостаточно средств\nдля оплаты заказа" )
        return
    end

    local result, reason = createOrder( client:GetUserID( ), client:GetClientID( ), killer.id, orderWay, killer.clanID )

    if result then
        client:TakeMoney( data.price, "bounty_hunters", "bounty_hunters_order" )
    elseif not result then
        client:ShowError( reason )
        return
    end

    triggerEvent( "onPlayerOrderCivilianForBounty", client, orderWay == 1 and "clans" or "police", data.price, killer.id, killer.name )
    client:ShowInfo( "Ваш заказ принят!" )

    triggerEvent( "onPlayerSomeDo", client, "bounty_order" ) -- achievements
end )

addEvent( "OnPlayerJailed", false )
addEventHandler( "OnPlayerJailed", root, function ( _, _, cop )
    if source:IsNickNameHidden( ) or not cop then return end

    local factionID = cop:GetFaction( ) or 0
    local factionIDofSource = source:GetFaction( ) or 0
    local order = getOrderOfTarget( source )

    if not order or order.order_way ~= ARREST_BY_FACTION or not COPS_FACTIONS[factionID] or factionID == factionIDofSource then return end

    local copName = cop:GetNickName( )
    local money = source:GetMoney( )
    local moneyLoss = math.floor( money * 0.03 ) > 100000 and 100000 or math.floor( money * 0.03 )

    cop:CompleteDailyQuest( "pps_order_complite" )

    if money > 0 and moneyLoss > 0 then
        source:TakeMoney( moneyLoss, "hunting_loss" ) -- loss of cash
        source:PhoneNotification( {
            title = "Месть",
            msg = "Вы были задержаны сотрудником ППС " .. copName .. " за убийство. В заключении вы были ограблены сокамерниками на " .. format_price( moneyLoss ) .. " рублей."
        } )
    else
        source:PhoneNotification( {
            title = "Месть",
            msg = "Вы были задержаны сотрудником ППС " .. copName .. " за убийство."
        } )
    end

    local info = {
        title = "ПРЕСТУПНИК ПОЙМАН",
        info = copName .. " посадил в КПЗ " .. source:GetNickName( ),
    }

    for _, c in pairs( GetPlayersInGame( ) ) do
        if c:GetFaction( ) == factionID and c:IsOnFactionDuty( ) then
            local cash = c ~= cop and COPS_HUNTERS_REWARDS[ c:GetFactionLevel( ) ] or COP_REWARD

            if cash then
                info.is_bounty = true
                info.rewards = {
                    money = cash,
                }

                c:GiveMoney( cash, "bounty_hunters", "bounty_hunters_rewards" )

                -- analytics
                triggerEvent( "onPlayerGotRewardForOrderByFaction", c, cash )
            end

            triggerClientEvent( c, "ShowPlayerUIQuestCompleted", c, info )
        end
    end

    completeOrder( order, nil, true )
end )

addEventHandler( "onPlayerWasted", root, function ( _, killer )
    if not isElement( killer ) then return end

    local time = getRealTimestamp( )
    death_time[ killer ] = time
    if death_time[ source ] == time then return end -- killer kill source & source kill killer in one time > bug

    if source:IsInEventLobby( ) then return end

    if not killer or killer == source or ( killer.dimension ~= source.dimension )
    or killer.type ~= "player" or killer:IsOnFactionDuty( ) then return end

    local kClan = killer:GetClanID( ) or 0
    local kFaction = killer:GetFaction( ) or 0
    local pClan = source:GetClanID( ) or 0
    local pFaction = source:GetClanID( ) or 0

    if kClan > 0 and kClan == pClan then return end -- in one clan
    if kFaction > 0 and kFaction == pFaction then return end -- in one faction

    local killerName = killer:GetNickName( )

    killers[ source ] = {
        id = killer:GetUserID( ),
        name = killerName,
        clanID = kClan,
    }
    triggerClientEvent( source, "onPlayerOrderRevenge", source, killers[ source ].name )

    if not source:IsNickNameHidden( ) then
        local order = getOrderOfTarget( source )

        if order and order.order_way == KILL_BY_CLAN and kClan > 0 and order.target_cid ~= kClan and kClan ~= pClan then
            local money = source:GetMoney( )
            local moneyLoss = math.floor( money * 0.1 ) > 200000 and 200000 or math.floor( money * 0.1 )

            if money > 0 and moneyLoss > 0 then
                source:TakeMoney( moneyLoss, "hunting_loss" ) -- loss of cash
                source:PhoneNotification( {
                    title = "Месть",
                    msg = "Вы были убиты " .. killerName .. ", членом клана " .. GetClanName( kClan ) .. " по заказу. Также вас ограбили на сумму " .. format_price( moneyLoss ) .. " рублей."
                } )
            else
                source:PhoneNotification( {
                    title = "Месть",
                    msg = "Вы были убиты " .. killerName .. ", членом клана " .. GetClanName( kClan ) .. " по заказу."
                } )
            end

            GiveClanMoney( kClan, CLAN_REWARD ) -- reward for clan
            completeOrder( order, nil, true ) -- complete

            local info = {
                title = "ЗАКАЗ ВЫПОЛНЕН",
                info = killerName .. " ликвидировал " .. source:GetNickName( ),
            }

            for _, p in pairs( CallClanFunction( kClan, "GetOnlineMembers" ) or { } ) do
                local cash = CLAN_MEMBER_REWARDS[ p:GetClanRole( ) ]
                if cash then
                    info.is_bounty = true
                    info.rewards = {
                        money = cash,
                    }

                    p:GiveMoney( cash, "bounty_hunters", "bounty_hunters_rewards" )
                end

                if p == killer then
                    triggerClientEvent( p, "ShowPlayerUIQuestCompleted", p, info )
                else
                    p:PhoneNotification( {
                        title = "Заказ",
                        msg = "Твой клан выполнил заказ охоты, награда " .. format_price( cash or 0 ) .. " рублей."
                    } )
                end
            end

            -- analytics
            triggerEvent( "onPlayerGotRewardForOrderByClan", killer, CLAN_REWARD )
        end
    end
end )

addEventHandler( "onPlayerSpawn", root, function ( )
    if not source:IsInGame( ) then return end
    triggerClientEvent( source, "onPlayerOrderRevenge", source )
end )

addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, function ( )
    local params = getOrderOfTarget( source )
    if not params then return end

    updateTimerHUD( params )
    sendInfoAboutOrder( params )
end )

addEventHandler( "onPlayerQuit", root, function ( )
    local params = getOrderOfTarget( source )

    if params then
        local currentTime = getRealTimestamp( )
        local eDate = source:GetPermanentData( "last_enter_date" ) or 0

        local date = params.creation_date > eDate and params.creation_date or eDate
        params.time_passed = params.time_passed + math.max( 0, currentTime - date ) -- save
        params.last_date = currentTime
    end

    killers[source] = nil
    positions[source] = nil
end )

addEventHandler( "onResourceStart", resourceRoot, function ( )
    DB:createTable( "nrp_bounty_orders", {
        { Field = "id",					Type = "int(11) unsigned",		Null = "NO",	Key = "PRI",    Default = NULL,     Extra = "auto_increment"    },
        { Field = "source_uid",         Type = "int(11) unsigned",	    Null = "YES",	Key = "",       Default = NULL                                  },
        { Field = "target_uid",			Type = "int(11) unsigned",		Null = "YES",	Key = "",       Default = NULL                                  },
        { Field = "target_cid",			Type = "int(11) unsigned",		Null = "YES",	Key = "",       Default = NULL                                  },
        { Field = "target_client_id",	Type = "char(36)",              Null = "NO",	Key = "",       Default = ""                                    },
        { Field = "source_client_id",	Type = "char(36)",              Null = "NO",	Key = "",       Default = ""                                    },
        { Field = "target_skin_id",		Type = "int(11) unsigned",		Null = "NO",	Key = "",       Default = 0                                     },
        { Field = "order_way",		    Type = "int(3) unsigned",		Null = "NO",	Key = "",	    Default = 0                                     },
        { Field = "last_position",		Type = "text",		            Null = "YES",	Key = "",       Default = NULL,                                 },
        { Field = "last_date",		    Type = "int(11) unsigned",	    Null = "NO",	Key = "",       Default = 0,                                    },
        { Field = "creation_date",		Type = "int(11) unsigned",		Null = "NO",	Key = "",	    Default = 0                                     },
        { Field = "complete_date",		Type = "int(11) unsigned",		Null = "NO",	Key = "",	    Default = 0                                     },
        { Field = "time_passed",		Type = "int(11) unsigned",		Null = "NO",	Key = "",	    Default = 0                                     },
    } )

    local function callback( query )
        if not query then return end
        local data = dbPoll( query, 0 )
        dbFree( query )
        if type( data ) ~= "table" then return end

        for _, params in pairs( data ) do
            if params.complete_date == 0 then
                params.last_position = fromJSON( params.last_position )
                loadOrder( params )
            end
        end
    end

    DB:queryAsync( callback, { }, "SELECT * FROM nrp_bounty_orders" )
end )

addEventHandler( "onResourceStop", resourceRoot, saveOrderList )