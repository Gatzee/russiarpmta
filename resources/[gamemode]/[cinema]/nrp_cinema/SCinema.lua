loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "SPlayer" )

ROOMS = { }
DELAY_TOLERATION = 2000 -- задержка перед началом нового видео в очереди

function onCinemaRoomEnter_handler( room_num )
    if not ROOMS[ room_num ] then
        local settings = ROOMS_CONFIG[ GetShapeNumFromRoomID( room_num ) ]
        ROOMS[ room_num ] = {
            is_vip  = settings.is_vip,
            players = { },

            queue        = { },
            video        = false,
            started_at   = false,
            duration     = false,
            timer_switch = false,
        }
    end

    local conf = ROOMS[ room_num ]

    table.insert( conf.players, client )

    if IsRoomVideoRunning( room_num ) then
        local passed = getRealTime( ).timestamp - conf.started_at
        triggerClientEvent( client, "onCinemaVideoSync", resourceRoot, conf.video.url, passed )
    end

    addEventHandler( "onPlayerPreLogout", client, onPlayerPreLogout_handler )
end
addEvent( "onCinemaRoomEnter", true )
addEventHandler( "onCinemaRoomEnter", resourceRoot, onCinemaRoomEnter_handler )

function onPlayerPreLogout_handler( )
    -- Зачистка игрока со всех залов после выхода
    for room_num, conf in pairs( ROOMS ) do
        for i, player in pairs( conf.players ) do
            if player == source then
                table.remove( conf.players, i )
                break
            end
        end
    end
end

function onCinemaRoomLeave_handler( room_num )
    local conf = ROOMS[ room_num ]
    for i, v in pairs( conf.players ) do
        if v == client then
            table.remove( conf.players, i )
            break
        end
    end
    triggerClientEvent( client, "onCinemaVideoSync", resourceRoot )

    removeEventHandler( "onPlayerPreLogout", client, onPlayerPreLogout_handler )
end
addEvent( "onCinemaRoomLeave", true )
addEventHandler( "onCinemaRoomLeave", resourceRoot, onCinemaRoomLeave_handler )

function onRoomTimerEnd( room_num )
    local conf = ROOMS[ room_num ]
    outputDebugString( "CINEMA [ROOM #" .. room_num .. "] Видео закончилось (" .. conf.video.duration .. "): " .. conf.video.title )
    ParseRoomVideo( room_num, true )
end

function ParseRoomVideo( room_num, force_new_video )
    local conf = ROOMS[ room_num ]
    local start_new_video = false

    if force_new_video or not IsRoomVideoRunning( room_num ) then
        start_new_video = true
    end

    -- Если нужно запустить новое видео, ищем в очереди
    if start_new_video then
        if isTimer( conf.timer_switch ) then killTimer( conf.timer_switch ) end

        local function SeekForVideo( )
            -- Видео найдено
            local video = conf.queue[ 1 ]
            if video then
                local player = GetPlayer( video.user_id, true )

                if player then
                    local cost = GetVideoCost( video, conf.is_vip )

                    -- Пытаемся снять баланс кассы
                    local balance = player:GetCinemaBalance( )
                    if balance >= cost then
                        local duration = video.duration_seconds

                        conf.started_at = getRealTime( ).timestamp
                        conf.video      = video
                        conf.duration   = duration
                        table.remove( conf.queue, 1 )

                        -- Синхронизируем всем видео
                        triggerClientEvent( conf.players, "onCinemaVideoSync", resourceRoot, video.url )

                        outputDebugString( "CINEMA [ROOM #" .. room_num .. "] Началось новое видео (" .. video.duration .. "): " .. conf.video.title )

                        -- Включаем таймер на окончание
                        conf.timer_switch = setTimer( onRoomTimerEnd, duration * 1000 + DELAY_TOLERATION, 1, room_num )

                        -- Сообщаем всем
                        --[[for i, v in pairs( conf.players ) do
                            v:ShowInfo( "Запущен фильм, заказаный " .. video.name .. " под названием `" .. video.title .. "`" )
                        end]]

                        -- Сообщаем тому, кто поставил видео
                        player:PhoneNotification( { title = "Кинотеатр", msg_short = "Началось твое видео!", msg = "Началось твое видео, не пропусти!" } )
                        triggerClientEvent( player, "onCinemaRejoinQueueRequest", resourceRoot, video.url, room_num )

                        -- Снимаем бабки
                        player:TakeCinemaBalance( cost )

                        SendElasticGameEvent( player:GetClientID( ), "cinema_video_start", {
                            cost = cost,
                            minutes = math.floor( duration / 6 ) * 10,
                            is_vip = conf.is_vip and "true" or "false",
                        } )

                        -- For task "cinema5"
                        triggerEvent( "onCinemaVideoStart", player, cost, duration )

                    -- У игрока не получилось снять с баланса - пропускаем
                    else

                        outputDebugString( "CINEMA [ROOM #" .. room_num .. "] Недостаточно средств: " .. conf.queue[ 1 ].title )

                        table.remove( conf.queue, 1 )

                        player:PhoneNotification( { title = "Касса Кинотеатра", msg_short = "Недостаточно средств", msg = "Недостаточно средств для показа вашего видео" } )
                        triggerClientEvent( player, "onCinemaUpdateInQueueRequest", resourceRoot, false )

                    end

                -- Игрок не найден - пропускаем
                else
                    outputDebugString( "CINEMA [ROOM #" .. room_num .. "] Недостаточно средств: " .. conf.queue[ 1 ].title )

                    table.remove( conf.queue, 1 )
                    SeekForVideo( )

                end

            -- Видео отсутствует
            else
                ROOMS[ room_num ].video      = nil
                ROOMS[ room_num ].started_at = nil
                ROOMS[ room_num ].duration   = nil
                triggerClientEvent( conf.players, "onCinemaVideoSync", resourceRoot )

            end
        end

        SeekForVideo( )
    end
end

function IsRoomVideoRunning( room_num )
    local conf = ROOMS[ room_num ]
    return conf and conf.video and conf.started_at + conf.duration > getRealTime( ).timestamp
end