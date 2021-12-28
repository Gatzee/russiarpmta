CARTEL_CLANS = { }
CARTEL_TAGS = { }

function SetCartelClan( cartel_id, clan_id )
    local clan = CLANS_BY_ID[ clan_id ]
    if clan_id and not clan then return end

    local old_cartel_clan = CARTEL_CLANS[ cartel_id ]
    if old_cartel_clan then
        old_cartel_clan.team:removeData( "cartel" )
        old_cartel_clan:SetPermanentData( "cartel", nil )
        old_cartel_clan:UpdateLeaderboardData( LB_CLAN_TAG )
    end

    SetCartelData( cartel_id, clan )
    if clan then
        clan:SetPermanentData( "cartel", cartel_id )
        clan:UpdateLeaderboardData( LB_CLAN_TAG )
    end

    triggerClientEvent( GetPlayersInGame( ), "onClientCartelsTagsUpdate", resourceRoot, { [ cartel_id ] = CARTEL_TAGS[ cartel_id ] } )

    return true
end

function SetCartelData( cartel_id, clan )
    if clan then
        CARTEL_CLANS[ cartel_id ] = clan
        CARTEL_TAGS[ cartel_id ] = clan.tag
        clan.team:setData( "cartel", cartel_id )
    else
        CARTEL_CLANS[ cartel_id ] = nil
        CARTEL_TAGS[ cartel_id ] = nil
    end
end

TAX_MIN_LIMIT = 3000000
MAX_TAX_TAKEN_MONEY = 10000000
TAX_PERCENT = 0.25

LOOTING_MONEY_MIN_LIMIT = 3000000
MAX_LOOTED_MONEY = 20000000
LOOTING_MONEY_PERCENT = 0.5

CARTEL_TAX_WAIT_DURATION = 2 * 60 * 60

CARTEL_TAX_WAITING_TIMERS = { }

-- CARTEL_TAX_LOG = { } --SEASON_DATA.cartel_tax_log

function GetCartelTaxLog( cartel_id )
    return SEASON_DATA.cartel_tax_log and SEASON_DATA.cartel_tax_log[ cartel_id ]
end

function CanCartelsRequestTax( )
    return LOCKED_SEASON and ( SEASON_DATA.can_cartels_request_tax or os.time( ) >= ALLOW_CARTELS_TAX_REQUESTS_DATE and os.time( ) < DISALLOW_CARTELS_TAX_REQUESTS_DATE )
end

function CanCartelsDeclareWar( )
    return LOCKED_SEASON and ( SEASON_DATA.can_cartels_declare_war or os.time( ) >= ALLOW_CARTELS_TAX_REQUESTS_DATE and os.time( ) < DISALLOW_CARTELS_TAX_WARS_DATE )
end

function AddCartelTaxLog( cartel_id, clan, status, money_value )
    local data = { }
    data[ CT_LOG_CLAN_NAME ] = clan.name
    data[ CT_LOG_DATE ] = os.time( )
    data[ CT_LOG_TAX_STATUS ] = status
    data[ CT_LOG_VALUE ] = money_value

    if not SEASON_DATA.cartel_tax_log then
        SEASON_DATA.cartel_tax_log = { }
    end
    if not SEASON_DATA.cartel_tax_log[ cartel_id ] then
        SEASON_DATA.cartel_tax_log[ cartel_id ] = { }
    end
    table.insert( SEASON_DATA.cartel_tax_log[ cartel_id ], data )
    if #SEASON_DATA.cartel_tax_log[ cartel_id ] > 50 then
        table.remove( SEASON_DATA.cartel_tax_log[ cartel_id ], 1 )
    end
	SaveSeasonData( )
end

ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION = 20 * 60 * 60
DISALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION = 6 * 60 * 60
DISALLOW_CARTELS_TAX_WARS_WAITING_DURATION = 9 * 60 * 60

function CalculateCartelsTaxDates( )
	ALLOW_CARTELS_TAX_REQUESTS_DATE = SEASON_END_DATE + ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION
	DISALLOW_CARTELS_TAX_REQUESTS_DATE = ALLOW_CARTELS_TAX_REQUESTS_DATE + DISALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION
    DISALLOW_CARTELS_TAX_WARS_DATE = ALLOW_CARTELS_TAX_REQUESTS_DATE + DISALLOW_CARTELS_TAX_WARS_WAITING_DURATION
    
	if os.time( ) > DISALLOW_CARTELS_TAX_WARS_DATE then
		ALLOW_CARTELS_TAX_REQUESTS_DATE = ALLOW_CARTELS_TAX_REQUESTS_DATE + TOTAL_SEASON_DURATION
		DISALLOW_CARTELS_TAX_REQUESTS_DATE = DISALLOW_CARTELS_TAX_REQUESTS_DATE + TOTAL_SEASON_DURATION
		DISALLOW_CARTELS_TAX_WARS_DATE = DISALLOW_CARTELS_TAX_WARS_DATE + TOTAL_SEASON_DURATION
    end
    
    if not SEASON_DATA.cartels_requested_taxes_count then
        SEASON_DATA.cartels_requested_taxes_count = { 0, 0 }
    end
end

function AllowCartelTaxes( )
	print( "AllowCartelTaxes" )
    SEASON_DATA.can_cartels_request_tax = true
    SEASON_DATA.can_cartels_declare_war = true
    SEASON_DATA.cartels_requested_taxes_count = { 0, 0 }
	SaveSeasonData( )
end

function AllowCartelTaxRequestsAndWars( )
	print( "AllowCartelTaxes", formatTimestamp( os.time( ) ) )
    -- SEASON_DATA.can_cartels_request_tax = true
    -- SEASON_DATA.can_cartels_declare_war = true
    -- SEASON_DATA.cartels_requested_taxes_count = { 0, 0 }
	-- SaveSeasonData( )
end

function DisallowCartelTaxes( )
	print( "DisallowCartelTaxes", formatTimestamp( os.time( ) ) )
    -- SEASON_DATA.can_cartels_request_tax = false
	-- SaveSeasonData( )
end

function DisallowCartelsDeclareWar( )
	print( "DisallowCartelsDeclareWar", formatTimestamp( os.time( ) ) )
    -- SEASON_DATA.can_cartels_declare_war = false
	-- SaveSeasonData( )
end

function RequestCartelTaxFromClan( clan, cartel_id )
    local expires_date = os.time( ) + CARTEL_TAX_WAIT_DURATION
    clan:SetPermanentData( "cartel_tax_data", {
        season = CURRENT_SEASON_ID,
        cartel_id = cartel_id,
        expires_date = expires_date,
        request_date = os.time( ),
    } )
    CARTEL_TAX_WAITING_TIMERS[ clan.id ] = setTimer( OnCartelTaxWaitingTimeExpired, CARTEL_TAX_WAIT_DURATION * 1000, 1, clan.id )
    
    triggerClientEvent( clan:GetOnlineMembers( ), "onClientCartelRequestMoney", resourceRoot, CARTEL_CLANS[ cartel_id ].id, expires_date )

    if not SEASON_DATA.cartels_requested_taxes_count then
        SEASON_DATA.cartels_requested_taxes_count = { 0, 0 }
    end
    SEASON_DATA.cartels_requested_taxes_count[ cartel_id ] = SEASON_DATA.cartels_requested_taxes_count[ cartel_id ] + 1
	SaveSeasonData( )
end

function OnCartelTaxWaitingTimeExpired( clan_id )
    local clan = CLANS_BY_ID[ clan_id ]
    if not clan then return end
    if not clan.cartel_tax_data then return end
    if not clan.cartel_tax_data.expires_date then return end

    TakeCartelTax( clan )
end

function TakeCartelTax( clan, is_leader_decision )
    local cartel_tax_data = clan.cartel_tax_data
    local cartel_id = cartel_tax_data.cartel_id
    local cartel_clan = CARTEL_CLANS[ cartel_id ]
    local cartel_money_before = cartel_clan.money
    local money, money_to_take = clan.money
    if money > TAX_MIN_LIMIT then
        money_to_take = math.min( MAX_TAX_TAKEN_MONEY, money * TAX_PERCENT )
        if money - money_to_take < TAX_MIN_LIMIT then
            money_to_take = money - TAX_MIN_LIMIT
        end
        -- local half = math.floor( money_to_take / 2 )
        -- CARTEL_CLANS[ 1 ]:GiveMoney( half )
        -- CARTEL_CLANS[ 2 ]:GiveMoney( half )
        clan:TakeMoney( money_to_take, true )
        cartel_clan:GiveMoney( money_to_take )

        clan:SetPermanentData( "cartel_tax_payed_season" , CURRENT_SEASON_ID )
        AddCartelTaxLog( cartel_id, clan, CARTEL_TAX_PAYED, money_to_take )

        if is_leader_decision then
            triggerClientEvent( clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
                title = "Картель",
                msg = "Ваш лидер клана выплатил налог картелю в 25%",
            } )
        else
            triggerClientEvent( clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
                title = "Картель",
                msg = "Ваш лидер клана не принял решение, картель забрал налог в 25%",
            } )
        end
        triggerClientEvent( cartel_clan:GetOnlineMembers( ), "onClientCartelTaxResponse", resourceRoot, clan.id, money_to_take )
    else
        triggerClientEvent( clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
            title = "Картель",
            msg = "Ваш клан слишком мелкий, картель не стал запрашивать процент от вашей прибыли!",
        } )
        triggerClientEvent( cartel_clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
            title = "Картель",
            msg = "Клан \"" .. clan.name .. "\" слишком мелкий для налога",
        } )
    end
    clan:SetPermanentData( "cartel_tax_data", nil )

    SendElasticGameEvent( nil, "clan_tax_request", {
        clan_id = clan.id,
        clan_name = clan.name,
        tax_decision_duration = os.time( ) - cartel_tax_data.request_date,
        tax_decision = is_leader_decision and 1 or 0,
        cartel_id = cartel_id,
        cartel_clan_name = cartel_clan.name,
        tax_sum = money_to_take or 0,
        clan_money_before = money,
        clan_money_after = clan.money,
        cartel_money_before = cartel_money_before,
        cartel_money_after  = cartel_clan.money,
    } )
end

function onCartelRequestTaxFromClan_handler( clan_id )
    local player = client or source
    local cartel_clan = player:GetClan( )
    if not cartel_clan or not cartel_clan.cartel then return end

    local clan = CLANS_BY_ID[ clan_id ]
    if not clan then return end

    if not CanCartelsRequestTax( ) then
        player:ShowError( "Вы не можете сейчас запрашивать налоги!" )
        return
    end

    local requested_taxes_count = SEASON_DATA.cartels_requested_taxes_count and SEASON_DATA.cartels_requested_taxes_count[ cartel_clan.cartel ]
    if requested_taxes_count and requested_taxes_count >= MAX_CARTEL_REQUESTED_TAXES_COUNT_PER_SEASON then
        player:ShowError( "Вы исчерпали лимит запросов!" )
        return
    end
    
    if clan.cartel_tax_data then
        player:ShowError( "У этого клана уже запросили налог!" )
        return
    end

    if clan.cartel_tax_payed_season == CURRENT_SEASON_ID then
        player:ShowError( "Этот клан уже оплатил налог!" )
        return
    end

    if clan.cartel_tax_war_win == CURRENT_SEASON_ID then
        player:ShowError( "Этот клан уже защитил свою честь!" )
        return
    end

    if clan.cartel_tax_war_lose == CURRENT_SEASON_ID then
        player:ShowError( "Этот клан уже ограблен!" )
        return
    end
    
    if REGISTERED_CLAN_WARS[ clan_id ] then
        if REGISTERED_CLAN_WARS[ clan_id ].enemy_clan_id == cartel_clan.id then
            player:ShowError( "Вы уже объявили войну этому клану!" )
        else
            player:ShowError( "Этому клану уже объявил войну другой картель!" )
        end
        return
    end
    
    RequestCartelTaxFromClan( clan, cartel_clan.cartel )
    player:ShowSuccess( "Вы успешно запросили налог у клана " .. clan.name )
    triggerClientEvent( player, "onClientUpdateClanUI", player, {
        clans_list = GetCartelTaxPayedClans( cartel_clan.cartel )
    } )
    triggerClientEvent( cartel_clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
        title = "Картель",
        msg = "У клана \"" .. clan.name .. "\" был запрошен налог.",
    } )
end
addEvent( "onCartelRequestTaxFromClan", true )
addEventHandler( "onCartelRequestTaxFromClan", root, onCartelRequestTaxFromClan_handler )

function onPlayerCartelTaxResponse_handler( to_pay_tax )
    local player = client or source
    local clan = player:GetClan( )
    if not clan then return end

    local cartel_tax_data = clan.cartel_tax_data
    if not cartel_tax_data then
        player:ShowError( "Вы не успели дать ответ в срок, Картель уже забрал налог" )
        return
    end

    if not cartel_tax_data.expires_date then return end

    if to_pay_tax then
        TakeCartelTax( clan, true )
    else
        cartel_tax_data.expires_date = nil
        clan:SetPermanentData( "cartel_tax_data", cartel_tax_data )
        
        triggerClientEvent( clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
            title = "Картель",
            msg = "Ваш лидер клана отказался платить налог Картелю. Пора готовиться к войне.",
        } )
        local cartel_id = cartel_tax_data.cartel_id
        local cartel_clan = CARTEL_CLANS[ cartel_id ]
        triggerClientEvent( cartel_clan:GetOnlineMembers( ), "onClientCartelTaxResponse", resourceRoot, clan.id, false )

        SendElasticGameEvent( nil, "clan_tax_request", {
            clan_id = clan.id,
            clan_name = clan.name,
            tax_decision_duration = os.time( ) - cartel_tax_data.request_date,
            tax_decision = 2,
            cartel_id = cartel_id,
            cartel_clan_name = cartel_clan.name,
            tax_sum = 0,
            clan_money_before = clan.money,
            clan_money_after = clan.money,
            cartel_money_before = cartel_clan.money,
            cartel_money_after  = cartel_clan.money,
        } )
    end
end
addEvent( "onPlayerCartelTaxResponse", true )
addEventHandler( "onPlayerCartelTaxResponse", root, onPlayerCartelTaxResponse_handler )

function onCartelDeclaredWarOnClan_handler( clan_id )
    local player = client or source
    local cartel_clan = player:GetClan( )
    if not cartel_clan or not cartel_clan.cartel then return end

    local clan = CLANS_BY_ID[ clan_id ]
    if not clan then return end

    if not CanCartelsDeclareWar( ) then
        player:ShowError( "Вы не можете сейчас объявлять войны!" )
        return
    end

    if clan.cartel_tax_data and clan.cartel_tax_data.expires_date then
        player:ShowError( "Этот клан ещё не дал ответ!" )
        return
    end

    if clan.cartel_tax_payed_season == CURRENT_SEASON_ID then
        player:ShowError( "Этот клан уже оплатил налог!" )
        return
    end

    if clan.cartel_tax_war_win == CURRENT_SEASON_ID then
        player:ShowError( "Этот клан уже защитил свою честь!" )
        return
    end

    if clan.cartel_tax_war_lose == CURRENT_SEASON_ID then
        player:ShowError( "Этот клан уже ограблен!" )
        return
    end
    
    if REGISTERED_CLAN_WARS[ clan_id ] then
        if REGISTERED_CLAN_WARS[ clan_id ].enemy_clan_id == cartel_clan.id then
            player:ShowError( "Вы уже объявили войну этому клану!" )
        else
            player:ShowError( "Этому клану уже объявил войну другой картель!" )
        end
        return
    end
    
    if REGISTERED_CLAN_WARS[ cartel_clan.id ] then
        player:ShowError( "Вы не можете объявить войну нескольким кланам одновременно!" )
        return
    end
    
    RegisterClanWar( clan_id, cartel_clan.id, CLAN_EVENT_CARTEL_TAX_WAR )
    player:ShowSuccess( "Вы объявили войну клану " .. clan.name )
    triggerClientEvent( player, "onClientUpdateClanUI", player, {
        clans_list = GetCartelTaxPayedClans( cartel_clan.cartel )
    } )

    SendElasticGameEvent( nil, "cartel_clan_money_war", {
        clan_id = clan.id,
        clan_name = clan.name,
        clan_money = clan.money,
        cartel_id = cartel_clan.cartel,
        cartel_clan_name = cartel_clan.name,
    } )
end
addEvent( "onCartelDeclaredWarOnClan", true )
addEventHandler( "onCartelDeclaredWarOnClan", root, onCartelDeclaredWarOnClan_handler )

function onCartelDeclaredWarFinish_handler( results )
    local winner_clan = CLANS_BY_ID[ results.winner_clan_id ]
    local loser_clan = CLANS_BY_ID[ results.loser_clan_id ]
    if not winner_clan or not loser_clan then return end

    local clan, cartel_clan
    local money, money_to_take
    local cartel_money_before

    if loser_clan.cartel then
        clan = winner_clan
        cartel_clan = loser_clan
        winner_clan:SetPermanentData( "cartel_tax_war_win", CURRENT_SEASON_ID )
        AddCartelTaxLog( loser_clan.cartel, winner_clan, CARTEL_TAX_SAVED )

        triggerClientEvent( winner_clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
            title = "Война за общак",
            msg = "Ваш клан отбил свой общак",
        } )
        triggerClientEvent( loser_clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
            title = "Война за общак",
            msg = "Клан \"" .. winner_clan.name .. "\" отбил свой общак",
        } )
    else
        clan = loser_clan
        cartel_clan = winner_clan
        cartel_money_before = cartel_clan.money

        loser_clan:SetPermanentData( "cartel_tax_war_lose", CURRENT_SEASON_ID )

        money, money_to_take = loser_clan.money
        if money > LOOTING_MONEY_MIN_LIMIT then
            money_to_take = math.min( MAX_LOOTED_MONEY, money * LOOTING_MONEY_PERCENT )
            if money - money_to_take < LOOTING_MONEY_MIN_LIMIT then
                money_to_take = money - LOOTING_MONEY_MIN_LIMIT
            end
        end

        AddCartelTaxLog( winner_clan.cartel, loser_clan, CARTEL_TAX_TAKEN, money_to_take )
        winner_clan:GiveMoney( money_to_take )
        loser_clan:TakeMoney( money_to_take, true )

        triggerClientEvent( loser_clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
            title = "Война за общак",
            msg = "Картель ограбил общак вашего клана на сумму " .. format_price( money_to_take ),
        } )
        triggerClientEvent( winner_clan:GetOnlineMembers( ), "OnClientReceivePhoneNotification", resourceRoot, {
            title = "Война за общак",
            msg = "Ваш картель ограбил общак клана \"" .. winner_clan.name .. "\".\nСумма ограбления: " .. format_price( money_to_take ),
        } )
    end

    local cartel_tax_data = clan.cartel_tax_data
    clan:SetPermanentData( "cartel_tax_data", nil )
    
    SendElasticGameEvent( nil, "cartel_clan_money_war_end", {
        clan_id = clan.id,
        clan_name = clan.name,
        cartel_id = cartel_clan.cartel,
        cartel_clan_name = cartel_clan.name,
        cartel_win = winner_clan.cartel and "true" or "false",
        tax_sum = money_to_take or 0,
        clan_money_before = money or clan.money,
        clan_money_after = clan.money,
        cartel_money_before = cartel_money_before or cartel_clan.money,
        cartel_money_after = cartel_clan.money,
        match_score = ( results.scores[ cartel_clan.id ] or 0 ) .. ":" .. ( results.scores[ clan.id ] or 0 ),
        match_duration = results.duration,
        leave_count = results.leave_count,
    } )
end
addEvent( "onCartelDeclaredWarFinish", true )
addEventHandler( "onCartelDeclaredWarFinish", root, onCartelDeclaredWarFinish_handler )

function onCartelHouseWarFinish_handler( results )
    -- TODO: кланы могут удалить
    local winner_clan = CLANS_BY_ID[ results.winner_clan_id ]
    local loser_clan = CLANS_BY_ID[ results.loser_clan_id ]
    iprint( "onCartelHouseWarFinish_handler", "winner_clan", winner_clan.name .. ( winner_clan.cartel and "(картель)" or ""), "loser_clan", loser_clan.name .. ( loser_clan.cartel and "(картель)" or "") )
    -- if not winner_clan or not loser_clan then return end

    local clan, cartel_clan, cartel_id

    local all_clans_players = GetPlayersInGame( )
    for i, player in pairs( all_clans_players ) do
        if not player:IsInClan( ) then
            all_clans_players[ i ] = nil
        end
    end
    if loser_clan.cartel then
        clan = winner_clan
        cartel_clan = loser_clan

        cartel_id = loser_clan.cartel
        SetCartelClan( cartel_id, results.winner_clan_id )

        triggerClientEvent( all_clans_players, "onClientCartelHouseWarFinish", resourceRoot, results.loser_clan_id, results.winner_clan_id )
    else
        clan = loser_clan
        cartel_clan = winner_clan

        triggerClientEvent( all_clans_players, "onClientCartelHouseWarFinish", resourceRoot, results.winner_clan_id, results.loser_clan_id )
    end

    SendElasticGameEvent( nil, "cartel_house_war_end", {
        clan_id = clan.id,
        clan_name = clan.name,
        cartel_id = cartel_id or cartel_clan.cartel,
        cartel_clan_name = cartel_clan.name,
        cartel_win = winner_clan == cartel_clan and "true" or "false",
        match_score = ( results.scores[ cartel_clan.id ] or 0 ) .. ":" .. ( results.scores[ clan.id ] or 0 ),
        match_duration = results.duration,
        leave_count = results.leave_count,
        reg_count_cartel = results.clans_reg_count[ cartel_clan.id ],
        reg_count_clan = results.clans_reg_count[ clan.id ],
    } )
end
addEvent( "onCartelHouseWarFinish", true )
addEventHandler( "onCartelHouseWarFinish", root, onCartelHouseWarFinish_handler )

function GetCartelTaxPayedClans( cartel_id )
    local cartel_clan_id = CARTEL_CLANS[ cartel_id ].id
    local check_season = LOCKED_SEASON and CURRENT_SEASON_ID or CURRENT_SEASON_ID - 1
    local list = { }
    for i, clan in pairs( CLANS_LIST ) do
        if not clan.cartel then
            local data = { }
            data[ CT_CLAN_ID ]                  = clan.id
            data[ CT_CLAN_MONEY ]               = clan:GetMoney( )
            data[ CT_CLAN_SCORE ]               = clan:GetScore( )
            data[ CT_CLAN_SLOTS ]               = clan.slots
            data[ CT_CLAN_MEMBERS_COUNT ]       = clan.members_count
            data[ CT_CLAN_TAX_STATUS ]          = clan.cartel_tax_payed_season == check_season and CARTEL_TAX_PAYED -- Оплачено
                                                        or clan.cartel_tax_war_win == check_season and CARTEL_TAX_SAVED -- Клан отбился от налога
                                                        or clan.cartel_tax_war_lose == check_season and CARTEL_TAX_TAKEN -- Ограблен
                                                        or REGISTERED_CLAN_WARS[ clan.id ] and ( REGISTERED_CLAN_WARS[ clan.id ].enemy_clan_id == cartel_clan_id and CARTEL_TAX_FIGHT -- Вы объявили войну
                                                                                                                                                                 or  CARTEL_TAX_OTHER_FIGHT ) -- Другой картель объявил войну
                                                        or clan.cartel_tax_data and ( clan.cartel_tax_data.cartel_id ~= cartel_id and CARTEL_TAX_OTHER_WAITING -- Другой картель запросил налог
                                                                                             or clan.cartel_tax_data.expires_date and CARTEL_TAX_WAITING -- Ожидание ответа 
                                                                                                                                  or  CARTEL_TAX_REFUSED ) -- Отказ платить
                                                        or clan.money > TAX_MIN_LIMIT and CARTEL_TAX_NOT_REQUESTED -- Налог не запрашивался
                                                        or nil -- Не хватает денег у клана
            data[ CT_CLAN_TAX_WAIT_UNTIL_DATE ] = clan.cartel_tax_data and clan.cartel_tax_data.expires_date or nil
            table.insert( list, data )
        end
    end
    return list
end

function CheckCartelTax( clan, player )
    local cartel_tax_data = clan.cartel_tax_data
    if not cartel_tax_data then return end
    if not cartel_tax_data.expires_date then return end

    local cartel_clan = CARTEL_CLANS[ cartel_tax_data.cartel_id ]
    triggerClientEvent( player, "onClientCartelRequestMoney", player, cartel_clan and cartel_clan.id, cartel_tax_data.expires_date )
end

function OnClanLoaded( clan )
    if not clan.cartel_tax_data then return end
    if clan.cartel_tax_data.season == CURRENT_SEASON_ID then
        if not clan.cartel_tax_data.expires_date then return end
        local time_left = clan.cartel_tax_data.expires_date - os.time( )
        if time_left > 0 then
            setTimer( OnCartelTaxWaitingTimeExpired, time_left * 1000, 1, clan.id )
        else
            OnCartelTaxWaitingTimeExpired( clan.id )
        end
    else
        clan:SetPermanentData( "cartel_tax_data", nil )
    end
end


if SERVER_NUMBER > 100 then

    addCommandHandler( "setcartelclan", function( player, cmd, cartel_id, ... )
        cartel_id = tonumber( cartel_id )
        if not tonumber( cartel_id ) then
            outputConsole( "Введите cartel_id (1 - запад или 2 - восток)" )
            return
        end
        
        local name = table.concat( { ... }, " " )
        local clan_id = name == "" and player:GetClanID( ) or name == "0" and false
        for i, other_clan in pairs( CLANS_LIST ) do
            if other_clan.name == name then
                clan_id = other_clan.id
                break
            end
        end

        SetCartelClan( tonumber( cartel_id ), clan_id )
        if clan_id then
            if clan_id == player:GetClanID( ) then
                outputConsole( "Вы успешно установили свой клан как картель" )
            else
                outputConsole( "Вы успешно установили клан " .. name .. " как картель" )
            end
        else
            outputConsole( "Вы успешно убрали клан картеля" )
        end

    end )

end