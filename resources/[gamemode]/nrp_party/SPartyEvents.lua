DB_TABLE_NAME = "nrp_parties"
MEMBERS_LIST_UPDATE_TIME = 30
TOP_LIST_UPDATE_TIME = 30
ONE_DAY_SECONDS = 3600 * 24
MIN_PARTY_PLAYERS = 25

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    local party = PARTY_LIST[ source:GetPartyID( ) ]

    if party and party.time_start and not party.owner_is_leave then
        source:PhoneNotification( {
            title = "Тусовка",
            msg = '"' .. party.name .. '" начало в ' .. ( "%02d:%02d" ):format( unpack( party.time_start ) ) .. " по МСК. Быть всем желающим!",
        } )

    elseif source:IsYoutuber( ) and source:CanCreateParty( ) then -- source is youtuber
        if not party and not source:GetPermanentData( "party_wc" ) then -- has not party
            source:SetPermanentData( "party_wc", true )
            triggerClientEvent( source, "onClientShowPartyCreation", resourceRoot )

        elseif party and party.owner_is_leave then -- if youtuber did reconnected
            source:MoveToParty( true, true )
            party.owner_is_leave = false

            for _, member in pairs( party.members ) do
                local player = GetPlayer( member.id )

                if player and player ~= source then
                    player:PhoneNotification( {
                        title       = "Тусовка возобновлена",
                        msg         = 'Организатор снова в игре. Хотите вернуться в тусовку?',
                        special     = "party_by_youtuber",
                        player      = player
                    } )
                end
            end
        end
    end
end, true, "low" )

addEventHandler( "onPlayerQuit", root, function ( )
    local party = PARTY_LIST[ source:GetPartyID( ) ]

    if not party then return end

    party.watchers[ source ] = nil -- can't watch on UI

    if not party.is_started then return end

    source:RemoveFromParty( ) -- remove from party if it's active

    if source:GetPartyRole( ) >= PARTY_ROLE_LEADER then
        partyEnd( party, source, "Тусовка была приостановлена.\nОрганизатор вышел из игры", true )
    end
end )

addEvent( "onPlayerRequestCreateParty", true )
addEventHandler( "onPlayerRequestCreateParty", resourceRoot, function ( )
    if not client or ( not client:IsYoutuber( ) and not client:CanCreateParty( ) ) then return end
    if client:GetPartyID( ) > 0 then return end

    createParty( client )
end )

addEventHandler( "onResourceStart", resourceRoot, function ( )
    DB:createTable( DB_TABLE_NAME, {
        { Field = "id",                 Type = "int(11) unsigned",  Null = "NO",	Key = "PRI",    Default = NULL,     Extra = "auto_increment"                    },
        { Field = "youtuber_id",        Type = "char(36)",          Null = "NO",	Key = "",       Default = ""                                                    },
        { Field = "name",		        Type = "varchar(64)",		Null = "NO",	Key = "",       Default = ""                                                    },
        { Field = "last_play",		    Type = "int(11)",	        Null = "NO",    Key = "",       Default = 0	                                                    },
        { Field = "pack_id",		    Type = "int(11)",	        Null = "NO",    Key = "",       Default = 0	                                                    },
        { Field = "counter",		    Type = "int(11)",	        Null = "NO",    Key = "",       Default = 0	                                                    },
        { Field = "draw_result",        Type = "text",              Null = "YES",   Key = "",       Default = NULL,     options = { ignore = true, autofix = true } },
        { Field = "top_list",           Type = "text",              Null = "YES",   Key = "",       Default = NULL,     options = { ignore = true, autofix = true } },
    } )

    DB:queryAsync( function ( query )
        if not query then return end

        for _, party in pairs( dbPoll( query, -1 ) or { } ) do
            party.members = { }

            -- start load party
            loadParty( party )
        end
    end, { }, "SELECT * FROM " .. DB_TABLE_NAME )
end )

addEventHandler( "onResourceStop", resourceRoot, function ( )
    for _, party in pairs( PARTY_LIST ) do
        partyEnd( party, nil, "Тусовка была завершена администрацией" )
    end

    saveAllParties( )
end )

addEvent( "onPartyDataRequest", true )
addEventHandler( "onPartyDataRequest", resourceRoot, function ( party_id, action )
    if not client then return end

    local party = getParty( party_id )
    if not party then return end

    local isClient = client:GetPartyID( ) == party_id
    local isOwner = client:GetPartyRole( ) == PARTY_ROLE_LEADER and isClient
    local timestamp = getRealTimestamp( )

    if action == PARTY_MAIN then
        triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_MAIN, isOwner, isClient, party.time_start )

    elseif action == PARTY_UP_TIMER then
        local time = party.last_play > 0 and party.last_play + ONE_DAY_SECONDS * 6 - timestamp or nil

        if time and time > 0 then
            triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_UP_TIMER, time )
        end

    elseif action == PARTY_TOP_LIST then
        if ( party.top_list_last_update or 0 ) + TOP_LIST_UPDATE_TIME < timestamp then
            updateTopList( party, client )
        else
            triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_TOP_LIST, party.top_10 )
        end

    elseif action == PARTY_REWARD_RESULT then
        if canUpdateRewardPack( party ) then
            party.draw_result = { }
        end

        triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_REWARD_RESULT, party.pack_id, party.draw_result, party.draw_result_names or { } )

    elseif action == PARTY_MEMBERS then
        if ( party.members_last_update or 0 ) + MEMBERS_LIST_UPDATE_TIME < timestamp then
            updatePartyMembers( party, client )
        else
            triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_MEMBERS, party.members )
        end
    end
end )

addEvent( "onPartyActionRequest", true )
addEventHandler( "onPartyActionRequest", resourceRoot, function ( action, data )
    if not client then return end

    local party = getParty( client:GetPartyID( ) )
    local isOwner = client:GetPartyRole( ) == PARTY_ROLE_LEADER
    local timestamp = getRealTimestamp( )

    local function updatePlayerParty( player_or_id, is_leave, party_id, role, check_party, message, refresh_list )
        local player = isElement( player_or_id ) and player_or_id or GetPlayer( player_or_id )

        local locked_time = nil
        if is_leave then -- if member was kicked out by owner / leave himself
            locked_time = timestamp + ONE_DAY_SECONDS * 3 -- 72 hours
        end

        if player then -- online player
            if check_party and player:GetPartyID( ) ~= party.id then
                client:ShowError( "Ошибка выполнения запроса" )
                return
            end

            if is_leave then
                player:SetPartyLockedTime( locked_time )
            end

            player:RemoveFromParty( )
            player:SetPartyID( party_id )
            player:SetPartyRole( role )

            -- interaction with client
            if message then client:ShowInfo( message ) end
            if party and refresh_list then
                triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_MEMBERS, party.members )
            end

        else -- offline player
            DB:queryAsync( function ( query, client )
                if not query then
                    client:ShowError( "Ошибка выполнения запроса" )
                    return
                end

                local result = dbPoll( query, -1 ) or { }
                if not result[ 1 ] or ( check_party and result[ 1 ].party_id ~= party.id ) then
                    client:ShowError( "Ошибка выполнения запроса" )
                    return
                end

                if is_leave then
                    DB:exec( "UPDATE nrp_players SET party_locked_time = ? WHERE id = ? LIMIT 1", locked_time, player_or_id )
                end

                DB:exec( "UPDATE nrp_players SET party_id = ?, party_role = ? WHERE id = ? LIMIT 1", party_id, role, player_or_id )

                -- interaction with client
                if message then client:ShowInfo( message ) end
                if party and refresh_list then
                    triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_MEMBERS, party.members )
                end

            end, { client }, "SELECT party_id FROM nrp_players WHERE id = ? LIMIT 1", player_or_id )
        end
    end

    if action == PARTY_WINDOW_STATE then
        local party_id, state = ( data or { } )[ 1 ], ( data or { } )[ 2 ]

        if party_id == "all" then
            for idx, party in pairs( PARTY_LIST ) do
                party.watchers[ client ] = nil
            end
        elseif PARTY_LIST[ party_id ] then
            PARTY_LIST[ party_id ].watchers[ client ] = state and true or nil
        end

    elseif action == PARTY_DELETE_MEMBER then
        if type( data ) ~= "table" or not data.client_id or not data.id then return end
        if data.id == client:GetID( ) or not isOwner or not party then return end

        party:RemovePlayer( data.id ) -- fast update members list
        updatePlayerParty( data.id, true, 0, 0, true, "Игрок был исключен из тусовки", true )

        -- analytics
        triggerEvent( "onPlayerLeaveFromParty", client, data.client_id, party.youtuber_id, party.name, "kick" )

    elseif action == PARTY_ACCEPT_MEMBER then
        if type( data ) ~= "table" or not data.client_id or not data.id then return end
        if data.id == client:GetID( ) or not isOwner or not party then return end

        party:AddPlayer( data.id, PARTY_ROLE_MEMBER ) -- fast update members list
        updatePlayerParty( data.id, false, party.id, PARTY_ROLE_MEMBER, true, "Заявка на вступление была одобрена", true )

        -- analytics
        triggerEvent( "onPlayerRequestToPartyResponse", client, data.client_id, party.youtuber_id, party.name, true )

    elseif action == PARTY_ACCEPT_MEMBER_ALL then
        if not isOwner or not party then return end

        for idx, member in pairs( table.copy( party.members ) ) do
            if member.party_role == PARTY_ROLE_REQUEST then
                party:AddPlayer( member.id, PARTY_ROLE_MEMBER ) -- fast update members list
                updatePlayerParty( member.id, false, party.id, PARTY_ROLE_MEMBER, true, nil, false )

                -- analytics
                triggerEvent( "onPlayerRequestToPartyResponse", client, member.client_id, party.youtuber_id, party.name, true )
            end
        end

        setTimer( function ( client )
            triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_MEMBERS, party.members )
        end, 1000, 1, client )

        client:ShowInfo( "Все входящие заявки были одобрены" )

    elseif action == PARTY_DECLINE_MEMBER then
        if type( data ) ~= "table" or not data.client_id or not data.id then return end
        if data.id == client:GetID( ) or not isOwner or not party then return end

        party:RemovePlayer( data.id ) -- fast update members list
        updatePlayerParty( data.id, false, 0, 0, true, "Заявка на вступление была отклонена", true )

        -- analytics
        triggerEvent( "onPlayerRequestToPartyResponse", client, data.client_id, party.youtuber_id, party.name, false )

    elseif action == PARTY_INVITE_MEMBER then
        triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_INVITE_RESULT, sendInvite( client, tostring( data ) ) )

    elseif action == PARTY_ACCEPT_INVITE then
        local new_party = getParty( ( data or { } )[ 1 ] )
        local answer = ( data or { } )[ 2 ]
        local invitation = new_party and new_party.invitations[ client:GetID( ) ] or nil

        if party then
            client:ShowError( "Одновременно можно быть\nтолько на одной тусовке" )
            return
        elseif not invitation or invitation < timestamp then
            client:ShowError( "Истёк срок действия приглашения" )
            return
        end

        -- analytics
        triggerEvent( "onPlayerInvitationAccepted", client, new_party.youtuber_id, new_party.name, answer and true or false )

        if answer then
            client:SetPartyID( new_party.id )
            client:SetPartyRole( PARTY_ROLE_MEMBER )
            client:ShowSuccess( 'Добро пожаловать на тусовку\n"' .. new_party.name .. '"' )
        else
            client:ShowInfo( "Вы отклонили приглашение" )
        end

    elseif action == PARTY_RENAME then
        if not isOwner or not party then return end

        -- data is name
        party.name = tostring( data )

    elseif action == PARTY_LEAVE then
        if not party or isOwner then return end

        party:RemovePlayer( client:GetID( ) ) -- fast update members list
        updatePlayerParty( client, true, 0, 0, false, "Вы успешно вышли из тусовки" )

        -- update main window
        triggerClientEvent( client, "onPartyDataResponse", resourceRoot, PARTY_MAIN, false, false, party.time_start )

        -- analytics
        triggerEvent( "onPlayerLeaveFromParty", client, client:GetClientID( ), party.youtuber_id, party.name, "self" )

    elseif action == PARTY_SEND_REQUEST then
        if party then
            client:ShowError( "Ты уже состоишь в другой тусовке" )
            return
        end

        local new_party = getParty( tonumber( data ) or 0 )

        if client:GetLevel( ) < MIN_LEVEL_FOR_PARTY then
            client:ShowError( "Для этого нужно иметь уровень не ниже " .. MIN_LEVEL_FOR_PARTY )
            return
        elseif not client:IsChangePartyAvailable( ) then
            local hours = math.ceil( ( client:GetPartyLockedTime( ) - timestamp ) / 3600 )
            client:ShowError( "Вам заблокирована возможность вступления в тусовку на " .. hours .. " ч.")
            return
        elseif not new_party then
            client:ShowError( "Ошибка выполнения запроса")
            return
        end

        updatePlayerParty( client, false, new_party.id, PARTY_ROLE_REQUEST, false, "Запрос на вступление успешно отправлен" )

        -- analytics
        triggerEvent( "onPlayerSendRequestToParty", client, new_party.youtuber_id, new_party.name )

    elseif action == PARTY_SEND_NOTIFICATION then
        if not isOwner or not party then return end

        if party.time_start then
            client:ShowError( "Уведомления уже разосланы" )
            return
        elseif party.last_play + ONE_DAY_SECONDS * 6 > timestamp then
            client:ShowError( "Отправка следующего уведомления\nвозможна через " .. math.ceil( ( party.last_play + ONE_DAY_SECONDS * 6 - timestamp ) / 3600 ) .. " ч." )
            return
        elseif not data or not data[ 1 ] or not data[ 2 ] then
            client:ShowError( "Указано некорректное время" )
            return
        end

        local hours, minutes = math.floor( data[ 1 ] ), math.floor( data[ 2 ] ) -- dota is time

        if hours < 0 or hours > 23 or minutes < 0 or minutes > 60 then
            client:ShowError( "Указано некорректное время" )
            return
        end

        for _, player in pairs( GetPlayersInGame( ) ) do
            if player:GetPartyID( ) == party.id and player:GetPartyRole( ) < PARTY_ROLE_LEADER then
                player:PhoneNotification( {
                    title = "Тусовка",
                    msg = '"' .. party.name .. '" начало в ' .. ( "%02d:%02d" ):format( hours, minutes ) .. " по МСК. Быть всем желающим!",
                } )
            end
        end

        party.time_start = { hours, minutes }
        client:ShowSuccess( "Уведомление успешно отправлено\nвсем участникам тусовки" )

        -- analytics
        triggerEvent( "onPlayerInitNotification", client, party.youtuber_id, party.name, party.total_online_players, party.time_start, party.counter + 1 )

    elseif action == PARTY_START then
        if not isOwner or not party then return end

        if party.is_started then
            client:ShowError( "Тусовка уже началась" )
            return
        elseif party.last_play + ONE_DAY_SECONDS * 7 > timestamp then
            client:ShowError( "Проведение тусовки возможно\nчерез " .. math.ceil( ( party.last_play + ONE_DAY_SECONDS * 7 - timestamp ) / 3600 ) .. " ч." )
            return
        elseif not client:MoveToParty( true ) then -- leader can't move to party right now
            return
        end

        party.is_started = true
        party.counter = party.counter + 1
        party.last_play = timestamp

        for _, member in pairs( party.members ) do
            local player = GetPlayer( member.id )

            if player and player ~= client then
                player:PhoneNotification( {
                    title       = "Тусовка началась",
                    msg         = '"' .. party.name .. '" активирована. Залетай к нам на пати!',
                    special     = "party_by_youtuber",
                    player      = player
                } )
            end
        end

    elseif action == PARTY_START_DRAW then
        if not isOwner or not party then return end

        if not party.is_started then -- not started
            client:ShowError( "Сначала нужно начать сбор" )
            return
        elseif party.draw then
            client:ShowError( "Розыгрыш уже запущен" )
            return
        elseif party.last_play + 60 * 5 > timestamp then -- start draw possible in 5 minutes
            client:ShowError( "Начать розыгрыш возможно\nчерез 5 минут после сбора" )
            return
        elseif countPlayersOnParty( party ) < MIN_PARTY_PLAYERS then
            client:ShowError( "На тусовке менее " .. MIN_PARTY_PLAYERS .. " игроков" )
            return
        end

        party.draw = true
        party.draw_result = { }
        party.draw_result_names = { }

        for _, member in pairs( party.members ) do
            local player = GetPlayer( member.id )
            if player then
                player:ShowInfo( "Внимание! Розыгрыш запущен!" )
            end
        end

        -- need for analytics
        party.counter_players_on_start = countPlayersOnParty( party )

    elseif action == PARTY_DRAW_POS then
        local place = tonumber( data ) -- data is place

        if not isOwner or not party or not place or party.draw_result[ place ] then return end

        if not party.draw then -- draw not started
            client:ShowError( "Сначала нужно начать розыгрыш" )
            return
        elseif countPlayersOnParty( party ) < MIN_PARTY_PLAYERS then
            client:ShowError( "На тусовке менее " .. MIN_PARTY_PLAYERS .. " игроков" )
            return
        elseif place < 10 and not party.draw_result[ place + 1 ] then
            client:ShowError( "Розыгрыш призов доступен только по порядку" )
            return
        end

        local reward = getRewardByPosition( party.pack_id, place )
        if reward then
            -- get random winner
            local players = { }
            for pl in pairs( party.players_on_party ) do
                table.insert( players, pl )
            end

            local num_try = 1
            local function getWinner( )
                local winner = players[ math.random( 1, #players ) ]

                if winner:GetPermanentData( "party_last_win" ) or winner:GetPartyRole( ) >= PARTY_ROLE_LEADER then -- already winner / youtuber
                    num_try = num_try + 1

                    if num_try > 10 then
                        return false
                    end

                    return getWinner( )
                else
                    winner:SetPermanentData( "party_last_win", { timestamp, 2 } )
                    return winner
                end
            end

            local winner = getWinner( )
            if not winner then
                client:ShowError( "Победитель не определён,\nповторите действие" )
                return
            end

            local reward_name = reward.type == "vehicle" and VEHICLE_CONFIG[ reward.id ].model or reward.name
            winner:ShowSuccess( "Поздравляем!\nТы выиграл " .. reward_name )

            local winner_name = winner:GetNickName( )
            local winner_client_id = winner:GetClientID( )

            party.draw_result_names[ place ] = winner_name
            party.draw_result[ place ] = true

            -- update top list
            local function insertTop( num )
                table.insert( party.top_list, num, {
                    cost = reward.cost,
                    r_name = reward.type == "vehicle" and VEHICLE_CONFIG[ reward.id ].model or reward.name,
                    client_id = winner_client_id,
                } )
            end

            if not next( party.top_list ) then
                insertTop( 1 )
            else
                for idx, opponent_reward in ipairs( party.top_list ) do
                    if not opponent_reward or reward.cost > opponent_reward.cost then
                        insertTop( idx )

                        if #party.top_list > 10 then
                            table.remove( party.top_list, #party.top_list )
                        end

                        break
                    end
                end
            end

            -- sync data for watchers
            for watcher in pairs( party.watchers ) do
                triggerClientEvent( watcher, "onPartyDataResponse", resourceRoot, PARTY_REWARD_POS, place, winner_name )
            end

            -- give reward
            if reward.type == "case" then
                winner:GiveCase( reward.id, 1 )
            elseif reward.type == "vehicle" then
                exports.nrp_vehicle:AddVehicle( { model = reward.id, owner_pid = "p:" .. winner:GetID( ), }, true )
            elseif reward.type == "vinyl" then
                winner:GiveVinyl( {
                    [ P_PRICE_TYPE ] = "hard",
                    [ P_IMAGE ]      = reward.id,
                    [ P_CLASS ]      = math.random( 1, 6 ),
                    [ P_NAME ]       = reward.name,
                    [ P_PRICE ]      = 0,
                } )
            end

            -- analytics
            triggerEvent( "onPlayerInitPartyDraw", client, party.youtuber_id, party.name, party.counter, countPlayersOnParty( party ), winner_client_id, tostring( reward.id ), reward_name )
        end

    elseif action == PARTY_END then
        if not isOwner or not party then return end

        if not party.is_started then -- not started
            client:ShowError( "Тусовка не активирована" )
            return
        end

        partyEnd( party, client, "Тусовка была завершена!\nДо новых встреч!" )
    end
end )

addEvent( "onPartyStart", true )
addEventHandler( "onPartyStart", root, function ( )
    if not client or source ~= client then return end

    client:MoveToParty( )
end )

addEvent( "onPartyListRequest", true )
addEventHandler( "onPartyListRequest", root, function ( )
    if not client then return end

    local party_id = client:GetPartyID( )
    local list = { }
    local client_party = nil

    for i, party in pairs( PARTY_LIST ) do
        local data = {
            id = party.id,
            name = party.name,
            counter_of_members = #party.members, -- requests include, but ok
        }

        if party.id == party_id then
            data.contain_client = true
            client_party = data
        else
            table.insert( list, data )
        end
    end

    table.sort( list, function ( a, b ) return a.counter_of_members < b.counter_of_members end )
    if client_party then
        table.insert( list, 1, client_party )
    end

    local can_create = not PARTY_LIST[ party_id ] and client:IsYoutuber( ) and client:CanCreateParty( )
    triggerClientEvent( client, "onPartyListResponse", client, list, can_create and true or false )
end )

addEvent( "onPartyInvite", false )
addEventHandler( "onPartyInvite", root, function ( target )
    local result, message = sendInvite( source, target )

    if result then
        source:ShowSuccess( message )
    else
        source:ShowError( message )
    end
end )