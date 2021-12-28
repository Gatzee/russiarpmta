Extend( "SDB" )
Extend( "SPlayer" )
Extend( "SPlayerOffline" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

CURREN_LEADER_DATA = { player_id = -1, nickname = "Отсутствует", value = 0, skin_id = 0 }

-- Запрос на показ акции
function ShowNewYearAuctionOffer( player, is_show_first )
    if not isElement( player ) or not player:IsCanParticipateNewYearAuction() then return end

    -- Аналитика :-
    if is_show_first and not player:GetPermanentData( OFFER_NAME .. "_show_first" ) then
        player:SetPermanentData( OFFER_NAME .. "_show_first", true )
        onChristmasAuctionShowfirst( player )
    end
    
    local data =
    {
        auction_leader = CURREN_LEADER_DATA,
        cur_rate = player:GetPlayerRate(),
        timeout = player:GetTimeoutRate(),
    }

    triggerClientEvent( player, "onClientShowOfferNewYearAuction", resourceRoot, data, is_show_first )
end

-- Обработка входа игрока на сервер
function onPlayerVehiclesLoad_handler()
    local timestamp = getRealTimestamp()
    if timestamp > OFFER_END_DATE then
        local bet = source:GetPlayerRate()
        if bet == -1 then
            ResetPlayerOfferData( source )
            GivePlayerAuctionVehicle( source )
        elseif bet > 0 then
            ReturnPlayerBet( source, bet )
        end
    else
        ShowNewYearAuctionOffer( source, true )
    end
end
addEvent( "onPlayerVehiclesLoad", true )
addEventHandler( "onPlayerVehiclesLoad", root, onPlayerVehiclesLoad_handler )

-- Запрос на показ акции
function onServerPlayerRequestNewYearAuction_handler()
    ShowNewYearAuctionOffer( source )
end
addEvent( "onServerPlayerRequestNewYearAuction", true )
addEventHandler( "onServerPlayerRequestNewYearAuction", root, onServerPlayerRequestNewYearAuction_handler )



-- Попытка сбросить время
function onServerPlayerTryDropTimeout_handler()
    local player = client
    if not isElement( player ) or not player:IsCanParticipateNewYearAuction() then return end

    if player:TakeDonate( COST_DROP_TIMEOUT, "sale", "christmas_auction_skiptime" ) then
        player:SetTimeoutRate( 0 )
        player:SetDonateSumToDrop( player:GetDonateSumToDrop() + COST_DROP_TIMEOUT )
        player:RefreshPlayerClientUI()
    else
        player:ShowError( "Недостаточно средств" )
    end
end
addEvent( "onServerPlayerTryDropTimeout", true )
addEventHandler( "onServerPlayerTryDropTimeout", resourceRoot, onServerPlayerTryDropTimeout_handler )

-- Попытка сделать ставку
function onServerPlayerTryAddNewYearAuctionRate_handler( value )
    local player = client
    if not isElement( player ) or not player:IsCanParticipateNewYearAuction() or not tonumber( value ) or value <= 0 then return end

    if player:GetTimeoutRate() - getRealTimestamp() > 0 then return false end

    if player:GetDonate() < value then
        player:ShowError( "Недостаточно средств" )
        return false
    end

    local player_rate = player:GetPlayerRate()
    if player_rate == 0 and value < CONST_MIN_RATE then
        player:ShowError( "Минимальная ставка " .. format_price( CONST_MIN_RATE ) .. "р." )
        return false
    end

    local new_rate_value = player_rate + value
    if new_rate_value <= CURREN_LEADER_DATA.value then
        player:ShowError( "Ставка должна быть больше лидирующей ставки!" )
        return false
    end

    if player:TakeDonate( value, "sale", "christmas_auction_bet" ) then
        player:SetPlayerRate( new_rate_value )

        TryRefreshLeader( player, new_rate_value )
        player:RefreshPlayerClientUI( { is_first_bet = player:GetRateNum() == 1 } )

        -- Аналитика :-
        onChristmasAuctionBet( player )
    end
end
addEvent( "onServerPlayerTryAddNewYearAuctionRate", true )
addEventHandler( "onServerPlayerTryAddNewYearAuctionRate", resourceRoot, onServerPlayerTryAddNewYearAuctionRate_handler )



-- Попытка обновить лидера
function TryRefreshLeader( player, new_rate_value )
    if new_rate_value <= CURREN_LEADER_DATA.value then return end

    local old_player = GetPlayer( CURREN_LEADER_DATA.player_id )
    if CURREN_LEADER_DATA.player_id ~= -1 and old_player ~= player then
        local timestamp = getRealTimestamp()
        if isElement( old_player ) then
            old_player:SendMsg( "Твою ставку в новогоднем\nаукционе перебили!" )
        end
    end

    CURREN_LEADER_DATA = { player_id = player:GetID(), nickname = player:GetNickName(), value = new_rate_value, skin_id = player.model }
end

-- Оповещение участникам о перебитой ставке
function ShowOutbidInfoMsg()
    local timestamp = getRealTimestamp()
    local time_diff = OFFER_END_DATE - timestamp
    if time_diff < 0 then return end

    local hours = string.format( "%02d", math.floor( time_diff / 60 / 60 ) )
    local minutes = string.format( "%02d", math.floor( ( time_diff - hours * 60 * 60 ) / 60 ) )
    local msg = "До окончания новогоднего\nаукциона осталось " .. hours .. ":" .. minutes

    for k, v in pairs( GetPlayersInGame() ) do
        local player_id = v:GetID()
        local player_rate = v:GetPlayerRate()
        if player_id ~= CURREN_LEADER_DATA.player_id and player_rate > 0 then
            v:SendMsg( msg )
        end
    end

    if time_diff - CONST_OUTBID_INTERVAL > 0 then
        setTimer( ShowOutbidInfoMsg, CONST_OUTBID_INTERVAL * 1000, 1 )
    end
end



-- Инициализация
function onStart()
    local timestamp = getRealTimestamp()
    if timestamp < OFFER_START_DATE or timestamp > OFFER_END_DATE then return false end

    DB:queryAsync( function( qh )
        local result = qh:poll( -1 )
        if not result or #result == 0 then return end

        CURREN_LEADER_DATA = result[ 1 ]
    end, {}, "SELECT id AS player_id, nickname, new_year_auction_rate AS value, skin AS skin_id FROM nrp_players WHERE new_year_auction_rate > 0 ORDER BY new_year_auction_rate DESC LIMIT 1" )

    local time_diff = OFFER_END_DATE - getRealTimestamp()
    if time_diff > 0 then
        setTimer( FinishAuction, time_diff * 1000, 1 )
        setTimer( ShowOutbidInfoMsg, CONST_OUTBID_INTERVAL * 1000, 1 )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onStart )


if SERVER_NUMBER > 100 then
    addCommandHandler( "show_newyear_auction", function( player ) 
        ShowNewYearAuctionOffer( player, true )
    end )

    addCommandHandler( "finish_newyear_auction", function( player ) 
        FinishAuction()
    end )

    addCommandHandler( "reset_newyear_auction", function( player ) 
        for k, v in pairs( getElementsByType( "player" ) ) do
            ResetPlayerOfferData( v )
        end

        DB:exec( "UPDATE nrp_players SET new_year_auction_rate = 0" )
        CURREN_LEADER_DATA = { player_id = -1, nickname = "Отсутствует", value = 0, skin_id = 0 }
        player:ShowInfo("Оффер подготовлен")
	end )
end