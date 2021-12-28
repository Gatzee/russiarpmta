--[[
    Конвертация в валюту:
    +++ Бизнесы
    +++ Квартиры
    - Товары бизнесменов
    +++ Випдома
    +++ Телефонные номера
    +++ Лицензии таксиста частника
]]

--[[
    Перенос:
    +++ Софт
    +++ Хард
    +++ Синие монеты
    +++ Машины
    +++ Мотоциклы
    +++ Авиатехника
    +++ Права на транспорт
    +++ Скины
    +++ Инвентарь
    +++ Оружие с рук
    +++ Фоны телефона
    +++ Аксессуары
    +++ Анимации
    +++ Бустеры гонок
    +++ Бустеры КБ
    +++ Билеты в КБ
    +++ Никнейм
    +++ Премиум
    +++ Жетоны рулеток
    +++ Купленные кейсы

    +++ Товары в хобби + заполненность рюкзака
    +++ Рингтоны/звук смс/звук уведомления/картинки
    +++ Тюнинг
    +++ Винилы
    +++ неоны
    +++ данные сезонных наград
    +++ Жетоны колеса рулетки
    +++ Жетоны колеса рулетки VIP
    +++ счетчики подкрутки для колеса фортуны (обычного и VIP)
    +++ Мед. книжка
    +++ счетчик ежедневных наград
    +++ Приобретенные слоты машин
    +++ Баланс суммы на кассе кинотеатра
    +++ рецепты для приготовления еды
    +++ ачивки
    +++ Соц рейтинг
    +++ Общак клана + развитие клана+ ящик хранилища (закрепляется за лидером клана)
    +++ опыт клана
    +++ позиция в текущем клане(ранг)
    +++ супруги
    +++ позиции в гонках (круг на время / дрифт) nrp_race_season_winners
    +++ опыт в той же фракции
    +++ штрафы nrp_fines
]]

loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVipHouses" )
Extend( "ShApartments" )
Extend( "ShVehicleConfig" )
Extend( "ShHouseSale" )
Extend( "SClans" )

MARIADB_INCLUDE = { APIDB = true }
Extend( "SDB" )

CLEARABLE_DATA = {
    id                      = true,
    client_id               = true,
    last_vehicle_id         = true,
    clan_id                 = true,
    clan_rank               = true,
    vehicle_access_sub_time = true,
    vehicle_access_sub_id   = true,
    refferer                = true,
    nickname_color_timeout  = true,
    faction_id              = true,
    phone_contacts          = true,
    wanted_data             = true,
    taxi_licenses           = true,
    taxi_rates              = true,
    ref_code                = true,
    phone_number            = true,
    phone_number_type       = true,
    phone_number_date_pur   = true,
    wedding_at_id           = true,
    engaged_at_id           = true,
}

CLEARABLE_VEHICLE_DATA = {
    id = true,
}

CLEAR_METHODS = {
    GetOwnedBusinesses   = "ClearBusinesses",
    GetOwnedTaxiLicenses = true,
    GetOwnedApartments   = "ClearApartments",
    GetOwnedPhoneNumber  = "ClearPhoneNumber",
}

TRANSFER_HANDLERS = { }
function AddTransferDataHandler( )
    TRANSFER_HANDLERS[ sourceResource ] = true

    addEventHandler( "onResourceStop", sourceResourceRoot, function( sourceResource )
        TRANSFER_HANDLERS[ sourceResource ] = nil
    end )
end
addEvent( "onTransferPrepareData_callback" )

function onPlayerRequestStartTransfer_handler( nickname )
    local transfer = GetSuitableTransfer( client )
    if not transfer then
        client:TransferError( "Перенос аккаунтов больше недоступен. Попробуйте позже!" )
        return
    end

    if nickname then
        nickname = utf8.gsub( nickname, "Ё", "Е" )
        nickname = utf8.gsub( nickname, "ё", "е" )
        local success, error = VerifyPlayerName( nickname )
        if not success then
            client:TransferError( error or "Невалидный ник" )
            return
        end
    end

    client:StartTransfer( transfer, GetTransferrableTargetServerConfig( transfer ), nickname )
end
addEvent( "onPlayerRequestStartTransfer", true )
addEventHandler( "onPlayerRequestStartTransfer", root, onPlayerRequestStartTransfer_handler )

function Player:GetAllCost( )
    local currency_total = { soft = 0, hard = 0, business_coins = 0 }
    local logdata_total, sold_total, saved_total = { }, { }, { }

    for method, reset_method in pairs( CLEAR_METHODS ) do
        -- Подсчёт суммы
        local currency, logdata, info = Player[ method ]( self )

        currency_total = table.add( currency_total, currency )
        logdata_total = table.merge( logdata_total, logdata )
        sold_total = table.merge( sold_total, info or { } )
    end

    for handler_resource in pairs( TRANSFER_HANDLERS ) do
        local currency, logdata, sold_info, saved_info = call( handler_resource, "GetTransferData", self )
        if currency then
            currency_total = table.add( currency_total, currency )
        end
        if logdata then
            logdata_total = table.merge( logdata_total, logdata )
        end
        if sold_info then
            sold_total = table.merge( sold_total, sold_info or { } )
        end
        if saved_info then
            saved_total = table.merge( saved_total, saved_info or { } )
        end
    end

    --iprint( "TOTAL", currency_total, logdata_total )

    local all_permanent_data = exports.nrp_player:GetAllPermanentData( self )
    for i, v in pairs( CLEARABLE_DATA ) do
        all_permanent_data[ i ] = nil
        if all_permanent_data.permanent_data then
            all_permanent_data.permanent_data[ i ] = nil
        end
    end

    return currency_total, logdata_total, all_permanent_data, sold_total, saved_total
end

function Player:ReadyToTransfer( )
    if self.dimension ~= 0 or self.interior ~= 0 or getCameraTarget( self ) ~= self then
        return "Нельзя переносить аккаунт, находясь здесь"
    end

    if self:GetOnShift( ) then
        return "Нельзя переносить аккаунт, находясь на смене"
    end

    if self:IsOnFactionDuty( ) then
        return "Нельзя переносить аккаунт, находясь на смене во фракции"
    end

    if self:getData( "current_quest" ) then
        return "Заверши текущую задачу чтобы продолжить"
    end

    if self:getData( "jailed" ) then
        return "Нельзя перенести аккаунт, находясь в тюрьме"
    end

	if self:getData( "isWithinTuning" ) then
		return "Нельзя принять участие отсюда!"
    end
    
    if self:IsOnUrgentMilitary( ) and not self:IsUrgentMilitaryVacation( ) then
		return "Нельзя перенести аккаунт, находясь на срочной службе"
    end
    
    if self:getData( "is_handcuffed" ) then
        return "Нельзя перенести аккаунт в наручниках"
    end

	if self:getData( "in_clan_event_lobby" ) then
		return "Нельзя принять участие отсюда!"
	end

    return true
end

function Player:StartTransfer( transfer, server, nickname )
    self:setData( "transfer", true, false )

    local ready = self:ReadyToTransfer( )
    if type( ready ) == "string" then
        self:TransferError( "Ошибка переноса NT00: " .. ready )
        return
    end

    -- Фикс области видимости вложенных функций
    local transfer, server = transfer, server

    local http_server = GetTargetServer( server )

    local user_id       = self:GetUserID( )
    local client_id     = self:GetClientID( )
    local serial        = self:getSerial( )
    local old_nickname  = self:GetNickName( )
    local nickname      = nickname or old_nickname

    -- Держим данные к очистке
    local phone_number          = self:GetPhoneNumber( )
    local businesses            = exports.nrp_businesses:GetOwnedBusinesses( self )
    local viphouse_list         = exports.nrp_vip_house:GetPlayerVipHouseList( self ) or {}
    local apartments_data_list  = exports.nrp_apartment:GetPlayerApartmentsData( self )

    local function await( result )
        if not result then return end
        return coroutine.yield( )
    end

    local resume
    resume = coroutine.wrap( function( )
        -- TestRecieverAvailability
        local result, err = await( callRemote( http_server, "nrp_transfer", "TestRecieverAvailability", resume, client_id, nickname ) )
        if not isElement( self ) then return end

        if result == "ERROR" then
            self:TransferError( "Перенос невозможен NT01: ошибка #" .. err )
            return
        elseif result ~= true then
            self:TransferError( "Перенос невозможен NT02: " .. tostring( result ) )
            return
        end

        local currency_total, logdata_total, all_permanent_data = self:GetAllCost( )

        local x, y, z = getElementPosition( self )
        local player_data = {
            nickname    = nickname,
            x           = x,
            y           = y,
            z           = z,
            dimension   = getElementDimension( self ),
            interior    = getElementInterior( self ),
            rotation    = getPedRotation( self ),
            armor       = getPedArmor( self ),
            health      = isPedDead( self ) and 0 or getElementHealth( self ),
            weapons     = toJSON( self:GetPermanentWeapons( ) or { }, true ),
        }

        for i, v in pairs( player_data ) do
            all_permanent_data[ i ] = v
        end

        triggerEvent( "onPlayerTransferAccept", self )

        local transfering_data = { }
        
        if next( TRANSFER_HANDLERS ) then
            local waiting_callbacks = table.copy( TRANSFER_HANDLERS )

            local function onTransferPrepareData_callback( add_transfering_data, add_permanent_data )
                if add_transfering_data then
                    for k, v in pairs( add_transfering_data ) do
                        transfering_data[ k ] = v
                    end
                end
                if add_permanent_data then
                    for k, v in pairs( add_permanent_data ) do
                        all_permanent_data.permanent_data[ k ] = v
                    end
                end
                waiting_callbacks[ sourceResource ] = nil
                if not next( waiting_callbacks ) then
                    resume( )
                end
            end
            addEventHandler( "onTransferPrepareData_callback", self, onTransferPrepareData_callback )

            local timeout = setTimer( resume, 5000, 1, true ) -- на случай всякой залупы в хэндлерах
            local is_timeout = await( setTimer( triggerEvent, 0, 1, "onTransferPrepareData", self ) ) -- ждём асихронные колбеки
            timeout:destroy( )
            if not isElement( self ) then return end
            removeEventHandler( "onTransferPrepareData_callback", self, onTransferPrepareData_callback )
            if is_timeout then
                self:TransferError( "Ошибка переноса NT28" )
                Debug( "check zalupa " .. inspect( waiting_callbacks ), 1 )
                return
            end
        end

        -- Удалённые машины (с префиксом "-")
        local query = await( DB:queryAsync( resume, { }, "SELECT * FROM nrp_vehicles WHERE owner_pid=?", "-" .. user_id ) )
        if not isElement( self ) then
            dbFree( query )
            return
        end

		local all_vehicles = query:poll( -1 )
		all_vehicles = { }

        -- Чтение обычных машин + мотоциклов
        for i, v in pairs( self:GetVehicles( false, true ) ) do
            local permanent_data
            if isElement( v ) then
                permanent_data = exports.nrp_vehicle:VGetAllPermanentData( v )
                if permanent_data then
                    local x, y, z = getElementPosition( v )
                    local rx, ry, rz = getElementRotation( v )
                    
                    local vehicle_data = {
                        x = x, y = y, z = z,
                        rx = rx, ry = ry, rz = rz,
                        dimension = getElementDimension( v ),
                        interior  = getElementInterior( v ),
                        health    = getElementHealth( v ),
                    }

                    for n, t in pairs( vehicle_data ) do
                        permanent_data[ n ] = t
                    end

                    table.insert( all_vehicles, permanent_data )
                end
            end
            --iprint( v, isElement( v ), permanent_data )
        end

        -- Чтение спешл транспорта
        local special_vehicles_ids = { }
        for i,v in pairs( self:GetSpecialVehicles( ) ) do
            local id = v[ 1 ]
            local vehicle = GetVehicle( id )
            if isElement( vehicle ) then
                exports.nrp_vehicle:DestroyVehicle( id )
            end
            table.insert( special_vehicles_ids, id )
        end

        if #special_vehicles_ids > 0 then
            local query = DB:queryAsync( resume, { }, "SELECT * FROM nrp_vehicles WHERE id=" .. table.concat( special_vehicles_ids, " OR id=" ) ) and coroutine.yield( )
            if not isElement( self ) then
                dbFree( query )
                return
            end

            local result = query:poll( -1 )
            for i, v in pairs( result ) do
                table.insert( all_vehicles, v )
            end
        end

        for i, v in pairs( all_vehicles ) do
            for n, t in pairs( CLEARABLE_VEHICLE_DATA ) do
                v[ n ] = nil
            end
        end

        transfering_data.all_vehicles = all_vehicles

        -- Обои, рингтоны на телефон
        local query = await( DB:queryAsync( resume, { }, "SELECT * FROM nrp_player_phone WHERE player_id=? LIMIT 1", self:GetID( ) ) )
        if not isElement( self ) then
            dbFree( query )
            return
        end

        local rows = query:poll( 0 )
        transfering_data.phone_settings = rows[ 1 ]

        -- TransferData
        local result, err = await( callRemote( http_server, "nrp_transfer", "TransferData", resume, client_id, transfer, currency_total, logdata_total, all_permanent_data, transfering_data ) )
        if not isElement( self ) then return end

        if result == "ERROR" or result ~= true then
            self:TransferError( "Ошибка переноса NT11, обратитесь к администрации: " .. tostring( result ) .. " " .. tostring( err ) )
            return
        end

        -- Очищаем сохраненные данные
        ClearBusinesses( businesses )
        ClearApartments( viphouse_list, apartments_data_list )
        ClearPhoneNumber( phone_number )
        triggerEvent( "onTransferClearOldData", self )

        DB:exec( "UPDATE nrp_players SET nickname=?, client_id=?, faction_id=0, clan_id=NULL WHERE client_id=? LIMIT 1", "-" .. old_nickname, serial, client_id )
        CommonDB:exec( "UPDATE account_transfer SET status='finished' WHERE client_id=? AND server=? AND status='offered' LIMIT 1", client_id, SERVER_NUMBER )
        CommonDB:exec( "UPDATE admin_payouts SET server_id = ? WHERE client_id = ? AND server_id = ? LIMIT 1", transfer.to_server, client_id, SERVER_NUMBER )

        APIDB:queryAsync( function( query )
            local result = query:poll( -1 )

            local function getFinalJSON( key )
                local list_json = result[ 1 ][ key ]
                local list = list_json and fromJSON( "[" .. list_json .. "]" ) or { }

                local new_list = { }
                for i, v in pairs( list ) do
                    if v ~= SERVER_NUMBER and v ~= server.id then
                        table.insert( new_list, v )
                    end
                end
                table.insert( new_list, server.id )
                local json = toJSON( new_list, true ):sub( 2, -2 )
                return json
            end
            APIDB:exec( "UPDATE Users SET servers=?, visibleServers=? WHERE clientId=? LIMIT 1", getFinalJSON( 'servers' ), getFinalJSON( 'visibleServers' ), client_id )
        end, { }, "SELECT servers, visibleServers FROM Users WHERE clientId=? LIMIT 1", client_id )

        -- Логаутим игрока
        triggerEvent( "onPlayerPreLogout", self )
        self:SetInGame( false )
        triggerClientEvent( self, "onClientPlayerRequestCancelLoadingAnimation", resourceRoot, true, transfer )

        -- Подключение на целевой сервер
        local t = { }
        function t.AcceptConnect( )
            if isElement( self ) then
                removeEventHandler( "onPlayerAcceptConnect", self, t.AcceptConnect )
                redirectPlayer( self, server.host, server.port, server.password or nil )
            end
        end
        addEvent( "onPlayerAcceptConnect", true )
        addEventHandler( "onPlayerAcceptConnect", self, t.AcceptConnect )

        setTimer( t.AcceptConnect, 10000, 1 )
    end )
    resume( )
end

function TestRecieverAvailability( client_id, nickname )
    --iprint( "TEST SUCCESS", client_id )
    if not client_id then
        return "NR2.0: Перенос данного аккаунта невозможен"
    end

    if GetPlayerFromClientID( client_id ) then
        return "Игрок под этим аккаунтом уже в сети на другом сервере"
    end

    if ACCOUNTS_DURING_TRANSFER[ client_id ] then
        return "Данный аккаунт уже находится в процессе переноса"
    end

    IGNORE_DB_DEPRECATION_WARNINGS = true
    local result = DB:query( "SELECT nickname FROM nrp_players WHERE client_id=? OR nickname=? LIMIT 1", client_id, nickname ):poll( 5000 )
    if #result > 0 then
        if nickname == result[ 1 ].nickname then
            return "Данный никнейм уже существует на сервере"
        else
            return "Данный аккаунт уже существует на сервере"
        end
    end
    IGNORE_DB_DEPRECATION_WARNINGS = nil
    
    return true
end

function GetKeysAndValues( tbl )
    local keys = { }
    local values = { }

    for i, v in pairs( tbl ) do
        table.insert( keys, dbPrepareString( DB, '`??`', i ) )
        table.insert( values, dbPrepareString( DB, v == false and "??" or "?", SQLConvertValue( v ) ) )
    end
    
    return keys, values
end

function SQLConvertValue( value )
    return type( value ) == "table" and ( toJSON( value or { }, true ) or "[[]]" ) or value == false and "NULL" or value
end

function SQLConcatTable( tbl )
    local result = utf8.gsub( table.concat( tbl, ", " ), [["NULL"]], "NULL" )
    return result
end

function GetPlayerQuery( client_id, tbl )
    tbl.client_id = client_id

    local keys, values = GetKeysAndValues( tbl )

	local query_str = table.concat( {
        "INSERT INTO nrp_players",
        " ( " .. SQLConcatTable( keys ) .. " ) ",
        "VALUES ( " .. SQLConcatTable( values ) .. " ) ",
    }, '' )

    return query_str
end

function GetVehicleQuery( tbl )
    local keys, values = GetKeysAndValues( tbl )

	local query_str = table.concat( {
        "INSERT INTO nrp_vehicles",

        " ( " .. SQLConcatTable( keys ) .. " ) ",
        "VALUES ( " .. SQLConcatTable( values ) .. " ) ",
    }, '' )

    return query_str
end

function GetPhoneSettingsQuery( tbl )
    local keys, values = GetKeysAndValues( tbl )

	local query_str = table.concat( {
        "INSERT INTO nrp_player_phone",

        " ( " .. SQLConcatTable( keys ) .. " ) ",
        "VALUES ( " .. SQLConcatTable( values ) .. " ) ",
    }, '' )

    return query_str
end

ACCOUNTS_DURING_TRANSFER = { }
function TransferData( client_id, transfer, currency_total, logdata_total, all_permanent_data, transfering_data )
    --iprint( "START TRANSFER SUCCESS", client_id )
    
    local final_test = TestRecieverAvailability( client_id, all_permanent_data.nickname )
    if final_test ~= true then
        return final_test
    end

    if not next( all_permanent_data ) then
        return "NR3: Перенос данного аккаунта невозможен"
    end

    ACCOUNTS_DURING_TRANSFER[ client_id ] = true

    -- Финальная сумма валюты
    all_permanent_data.money          = all_permanent_data.money + ( currency_total.soft or 0 )
    all_permanent_data.donate         = all_permanent_data.donate + ( currency_total.hard or 0 )
    all_permanent_data.business_coins = all_permanent_data.business_coins + ( currency_total.business_coins or 0 )

    -- Отметка о завершении переноса
    all_permanent_data.permanent_data.transfer_finished = transfer

    local query_str = GetPlayerQuery( client_id, all_permanent_data )

    -- Подмена владельца транспорта перед добавлением в базу
    local transfering_data = transfering_data
    DB:queryAsync( function( query )
        local result, num_affected_rows, last_insert_id = query:poll( -1 )

        local queries = { }

        for i, v in pairs( transfering_data.all_vehicles ) do
            v.owner_pid =
                string.sub( v.owner_pid, 1, 1 ) == "-" and ( "-" .. last_insert_id )
                    or
                string.sub( v.owner_pid, 1, 2 ) == "p:" and ( "p:" .. last_insert_id )

            table.insert( queries, GetVehicleQuery( v ) )
            --iprint( "Inserting veh", v.owner_pid )
        end

        --iprint( "Starting query", #queries )
        if #queries > 0 then
            DB:queryAsync( function( query )
                query:poll( -1, true )
                --iprint( "Finished inserting vehicles" )
                ACCOUNTS_DURING_TRANSFER[ client_id ] = nil
            end, { }, table.concat( queries, "; " ) )
        else
            ACCOUNTS_DURING_TRANSFER[ client_id ] = nil
        end

        if transfering_data.phone_settings then
            transfering_data.phone_settings.player_id = last_insert_id

            DB:exec( GetPhoneSettingsQuery( transfering_data.phone_settings ) )
            --iprint( "Insert phone settings finished" )
        end

        triggerEvent( "onTransferFinish", root, last_insert_id, client_id, transfering_data )
    end, { }, query_str )

    for i, v in pairs( logdata_total or { } ) do
        SendToLogserver( "[TRANSFER " .. i .. "/" .. ( #logdata_total ) .. "] client_id:" .. tostring( client_id ) .. " завершил перенос аккаунта: " .. tostring( v ), { client_id = client_id, nickname = all_permanent_data.nickname } )
    end

    SendToLogserver( "[TRANSFER FINISH] client_id:" .. tostring( client_id ) .. " полностью завершил перенос. Начислено за имущество: " .. inspect( currency_total ), { client_id = client_id, nickname = all_permanent_data.nickname } )

    return true
end

function Player:TransferError( message )
    self:setData( "transfer", false, false )
    triggerClientEvent( self, "onClientPlayerRequestCancelLoadingAnimation", resourceRoot, false, false, message )
end