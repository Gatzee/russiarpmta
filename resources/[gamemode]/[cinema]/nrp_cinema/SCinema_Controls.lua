-- Запрос информации по залу
function onCinemaRequestRoomInformation_handler( room_num )
    local user_id = client:GetUserID( )

    -- Поиск позиции в очереди
    local before_in_queue
    for i, v in pairs( ROOMS[ room_num ].queue ) do
        if v.user_id == user_id then
            before_in_queue = i .. " чел."
            break
        end
    end

    local info = {
        balance         = client:GetCinemaBalance( ),
        is_vip          = ROOMS[ room_num ].is_vip or false,
        before_in_queue = before_in_queue,
    }

    triggerClientEvent( client, "ShowRoomUI", resourceRoot, true, info )
end
addEvent( "onCinemaRequestRoomInformation", true )
addEventHandler( "onCinemaRequestRoomInformation", root, onCinemaRequestRoomInformation_handler )

function GetMovielist( dimension )
    local list = { }
    for i, v in pairs( ROOMS_CONFIG ) do
        local real_id = dimension * 100 + i
        local real_conf = ROOMS[ real_id ]
        local video = IsRoomVideoRunning( real_id ) and real_conf.video
        local conf = {
            name  = v.name,
            video = video,
        }
        table.insert( list, conf )
    end
    return { dimension = dimension, list = list }
end

function onCinemaRequestMovieList_handler( dimension )
    if not dimension then return end
    local movielist = GetMovielist( dimension )
    triggerClientEvent( client, "ShowMovielistUI", resourceRoot, true, movielist )
end
addEvent( "onCinemaRequestMovieList", true )
addEventHandler( "onCinemaRequestMovieList", root, onCinemaRequestMovieList_handler )

function onCinemaUpdateMovielistRequest_handler( dimension )
    if not dimension then return end
    local movielist = GetMovielist( dimension )
    triggerClientEvent( client, "UpdateMovielist", resourceRoot, movielist )
end
addEvent( "onCinemaUpdateMovielistRequest", true )
addEventHandler( "onCinemaUpdateMovielistRequest", root, onCinemaUpdateMovielistRequest_handler )

-- Постановка на очередь
function onCinemaJoinQueueRequest_handler( room_num, video )
    if not video then
        client:ErrorWindow( "Твой плейлист пуст!" )
        return
    end

    local user_id = client:GetUserID( )
    local conf = ROOMS[ room_num ]
    for room_num_other, room_conf in pairs( ROOMS ) do
        if IsRoomVideoRunning( room_num_other ) and room_conf.video.user_id == user_id and room_num ~= room_num_other then
            client:ErrorWindow( "Твое видео уже запущено в другом зале!" )
            return
        end

        for i, v in pairs( room_conf.queue ) do
            if v.user_id == user_id then
                if room_num == room_num_other then
                    client:InfoWindow( "Ты уже в очереди воспроизведения!" )

                else
                    client:InfoWindow( "Ты уже в очереди воспроизведения в другом зале!" )

                end

                return
            end
        end
    end

    local is_vip = conf.is_vip
    local cost = GetVideoCost( video, is_vip )

    if client:GetCinemaBalance( ) < cost then
        client:ErrorWindow( "Недостаточно средств на балансе кассы!" )
        return
    end

    client:CompleteDailyQuest( "start_kino_list" ) 

    -- Добавляем информацию по игроку в видос
    VideoAddInformation( video, client )

    -- Добавляем видео в очередь
    table.insert( conf.queue, video )
    outputDebugString( "CINEMA [ROOM #" .. room_num .. "] " .. client:GetNickName( ) .. " добавил новое видео в очередь (" .. video.duration .. "): " .. video.title )

    triggerClientEvent( client, "onCinemaUpdateInQueueRequest", resourceRoot, room_num )

    triggerEvent( "onPlayerSomeDo", client, "watch_cinema" ) -- achievements

    ParseRoomVideo( room_num )
end
addEvent( "onCinemaJoinQueueRequest", true )
addEventHandler( "onCinemaJoinQueueRequest", root, onCinemaJoinQueueRequest_handler )

function onCinemaUpdateQueuedVideo_handler( video )
    local user_id = client:GetUserID( )

    -- Поиск активной комнаты игрока
    for i, conf in pairs( ROOMS ) do
        local room_num, video_num
        for n, video in pairs( conf.queue ) do
            if video.user_id == user_id then
                room_num, video_num = i, n
                break
            end
        end

        -- Комната и видео найдены
        if room_num and video_num then
            client:ShowInfo( "Твое следующее видео было обновлено согласно плейлисту" )

            -- Обновление параметров следующего видео по плейлисту
            ROOMS[ room_num ][ video_num ] = video
            VideoAddInformation( video, client )

            return
        end

    end
end
addEvent( "onCinemaUpdateQueuedVideo", true )
addEventHandler( "onCinemaUpdateQueuedVideo", root, onCinemaUpdateQueuedVideo_handler )

function VideoAddInformation( video, player )
    video.user_id = player:GetUserID( )
    video.name    = player:GetNickName( )
end

-- Уход с очереди
function onCinemaLeaveQueueRequest_handler( room_num )
    local user_id = client:GetUserID( )
    local conf = ROOMS[ room_num ]
    for i, v in pairs( conf.queue ) do
        if v.user_id == user_id then
            table.remove( conf.queue, i )
            triggerClientEvent( client, "onCinemaUpdateInQueueRequest", resourceRoot, false )
            client:InfoWindow( "Ты покинул очередь воспроизведения!" )
            return
        end
    end

    client:ErrorWindow( "Ты сейчас не находишься в очереди в этом зале!" )
end
addEvent( "onCinemaLeaveQueueRequest", true )
addEventHandler( "onCinemaLeaveQueueRequest", root, onCinemaLeaveQueueRequest_handler )

-- Пополнение кассы
function onCinemaAddMoneyReqeuest_handler( amount )
    if not amount or amount <= 0 or amount ~= math.floor( amount ) then
        client:ErrorWindow( "Указана неверная сумма" )
        return
    end

    if client:TakeMoney( amount, "cinema_add_balance" ) then
        local cinema_balance = client:GetCinemaBalance( ) + amount
        client:SetCinemaBalance( cinema_balance )
        client:InfoWindow( "Баланс кассы успешно пополнен!" )
        triggerClientEvent( client, "onCinemaUpdateBalanceInfo", resourceRoot, cinema_balance )

    else
        client:ErrorWindow( "Ошибка пополнения баланса кассы" )
    end
end
addEvent( "onCinemaAddMoneyReqeuest", true )
addEventHandler( "onCinemaAddMoneyReqeuest", root, onCinemaAddMoneyReqeuest_handler )