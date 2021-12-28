function Player.SetRateTarget( self, target, money )
    local client_id = target:GetClientID( )
    self:SetPermanentData( "txp_rate", { client_id, money } )
end

function Player.ResetRateTarget( self )
    self:SetPermanentData( "txp_rate", false )
end

function Player.GetRateTarget( self )
    return self:GetPermanentData( "txp_rate" )
end

function Player.SendRateInfo( self, force_show )
    local info = self:GetRateTarget( )
    if info then
        triggerClientEvent( self, "onTaxiPrivateRateInfo", self, info, force_show )
    end
end

function Player.GetRateList( self )
    return self:GetPermanentData( "taxi_rates" ) or { }
end

function Player.AddNewRate( self, player, rating, money )
    local client_id = player:GetClientID( )

    local rating_list = self:GetRateList( )
    table.insert( rating_list, { client_id, rating, money } )
    
    while #rating_list > 15 do
        table.remove( rating_list, 1 )
    end

    self:SetPermanentData( "taxi_rates", rating_list )
end

-- Онлайн редактирование рейтинга
function Player.EditRate( self, player, rating )
    local client_id = player:GetClientID( )

    local rating_list = self:GetRateList( )
    local total_rating = 0

    -- Изменение только последнео рейтинга рейтинга
    local found = false
    for i, v in ripairs( rating_list ) do
        if v[ 1 ] == client_id and not found then
            v[ 2 ] = rating
            found = true
        end
        total_rating = total_rating + v[ 2 ]
    end

    -- Сброс цели рейтинга
    self:ResetRateTarget( )

    -- Плохой рейтинг - чистим список и возвращаем сумму
    if #rating_list >= 15 and total_rating <= math.floor( #rating_list * 1.5 ) then
        local total_refund = 0
        for i, v in ripairs( rating_list ) do
            local client_id_target, money = v[ 1 ], v[ 3 ]
            if money and money > 0 then
                local result = self:TakeMoney( money, "taxi_private_refund" )
                if result then
                    local money_target = GetPlayerFromClientID( client_id_target )
                    total_refund = total_refund + money
                    if money_target then
                        money_target:GiveMoney( money, "job_salary", "taxi_private_refund" )
                    else
                        client_id_target:GiveMoney( money, "job_salary", "taxi_private_refund" )
                    end
                end
            end
        end
        self:SetPermanentData( "taxi_rates", { } )

        if total_refund > 0 then
            self:ErrorWindow( "За последние 15 поездок ваш рейтинг очень низкий.\nПассажирам возвращено: " .. total_refund .. " р.", "НИЗКИЙ РЕЙТИНГ" )
        end

    -- Все норм - собираем список дальше
    else
        self:SetPermanentData( "taxi_rates", rating_list )

    end
end

-- Оффлайн
function string.EditRate( self, player, rating )
    local client_id = player:GetClientID( )

    -- Сброс цели рейтинга
    player:ResetRateTarget( )

    DB:queryAsync( 
        function( query, client_id, rating )
            local result = query:poll( -1 )
            if #result <= 0 then return end

            local rating_list = fromJSON( result.taxi_rates or "[[]]" ) or { }
            for i, v in pairs( rating_list ) do
                if v[ 1 ] == client_id then
                    v[ 2 ] = rating
                end
            end
            
            DB:exec( "UPDATE nrp_players SET taxi_rates=? WHERE client_id=? LIMIT 1", toJSON( rating_list, true ), result.client_id )
        end,
        { player:GetClientID( ), rating },
        "SELECT client_id, taxi_rates FROM nrp_players WHERE client_id=? LIMIT 1", client_id
    )
end

-- Рейтинг игрока
function onTaxiPrivateRateRequest_handler( info, rating )
    if not info then return end
    local client_id = info[ 1 ]

    -- Редактирование рейтинга онлайн и оффлайн
    local player = GetPlayerFromClientID( client_id )
    if player then
        player:EditRate( client, rating )
    else
        client_id:EditRate( client, rating )
    end
end
addEvent( "onTaxiPrivateRateRequest", true )
addEventHandler( "onTaxiPrivateRateRequest", root, onTaxiPrivateRateRequest_handler )

-- Обновлять рейт-инфо при перезаходе
function onPlayerCompleteLogin_rateHandler( )
    if source:GetRateTarget( ) then
        source:SendRateInfo( )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_rateHandler )