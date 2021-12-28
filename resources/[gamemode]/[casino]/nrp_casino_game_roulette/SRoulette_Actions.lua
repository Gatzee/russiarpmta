-- Запрос на выход со стола
function onRouletteTableLeaveRequest_handler( lobby_id, from_destroy, leave_reason )
    local lobby_id = lobby_id or GetPlayerLobbyID( source )

    if client then 
        triggerEvent( "onCasinoPlayerBlockLobbyJoin", client )
    end

    if lobby_id and ROOMS[ lobby_id ] then 
        -- ЗДЕСЬ ДОЛЖНА БЫТЬ ПОТЕРЯ ДЕНЕГ ЗА ВЫХОД ИЛИ ДРУГАЯ ПРОВЕРКА
        local is_room_active = LobbyGet( lobby_id, "state" ) == CASINO_STATE_PLAYING
        local is_restarting = LobbyGet( lobby_id, "restarting" )

        local next_player_after_leaver = GetNextPlayerAfter( lobby_id, source )

        local turn_player = GetTurnPlayer( lobby_id )

        if GetPlayerLobbyID( source ) == lobby_id then
            LobbyCall( lobby_id, "leave", source, false, false, false, "finish" )
        end

        --iprint( source, "LEAVE ATTEMPT", not ROOMS[ lobby_id ], is_room_active, not is_restarting, client )

        if not ROOMS[ lobby_id ] then return end

        local alone_player = nil
        local lobby_players = GetPlayersList( lobby_id )
        if #lobby_players == 1 then
            alone_player = lobby_players[ 1 ]
        else
            WriteLog( "casino_roulette", "[GAME_FINISHED][ lobby_id: %s ] Проигравший %s, Игроков %s, Проигрыш: %s", lobby_id, source, ROOMS[ lobby_id ].total_count, ROOMS[ lobby_id ].bet )
        end

        local player_quantity = #GetPlayersList( lobby_id )
        local player_data = table.copy( ROOMS[ lobby_id ].players[ source ] )
        if ROOMS[ lobby_id ].started and player_data then
            player_data.is_create = source == ROOMS[ lobby_id ].owner
            player_data.is_win = false
            onCasinoRusRouletteLeave( source, player_quantity, ROOMS[ lobby_id ], player_data, leave_reason )
        end

        ROOMS[ lobby_id ].players[ source ] = nil

        if is_room_active and not is_restarting then
            -- Если игрок остался один, выкидываем его из игры
            lobby_players = GetPlayersList( lobby_id )
            if #lobby_players == 1 then
                FinishGame( lobby_id, lobby_players[ 1 ], "finish" )
            end

            -- Если игрок ходил в этот момент
            if source == turn_player then
                onCasinoGameRouletteTurnServersideEnd_handler( lobby_id, true )
                SetTurnPlayer( lobby_id, next_player_after_leaver )
            end
        end

        if not from_destroy then
            local room = ROOMS[lobby_id]
            if room then
                local iTimePassed = getRealTimestamp() - ROOMS[lobby_id].start_time
                triggerEvent("OnCasinoGamePlayerLeft", source, iTimePassed, room.bet * LobbyGet( lobby_id, "players_count_required" ), ROOMS[ lobby_id ].game )
            end
        end

        triggerClientEvent( GetPlayersList( lobby_id ), "OnPlayerLeftRouletteTable", source )
    end
end
addEvent( "onRouletteTableLeaveRequest", true )
addEventHandler( "onRouletteTableLeaveRequest", root, onRouletteTableLeaveRequest_handler )

---------------------------
-------- НАЧАЛО ИГРЫ ------
---------------------------
function onCasinoGameRouletteStart_handler( lobby_id )
    if client then return end
    -- Установка игроков по позициям при начале игры
    
    local casino_id = ROOMS[ lobby_id ].casino_id
    local players_list = GetPlayersList( lobby_id )
    local casino_interior =
    {
        [ CASINO_THREE_AXE ] = 1,
        [ CASINO_MOSCOW ] = 4,
    }

    for i, player in pairs( players_list ) do
        local position      = ROOMS_POSITIONS[ casino_id ][ i ]

        player.dimension    = 660 + lobby_id
        player.interior     = casino_interior[ casino_id ]
        player.position     = position

        local new_rotation_vector = LOOKAT[ casino_id ] - position
        local dd_rotation_vector = Vector2( new_rotation_vector.x, new_rotation_vector.y ):getNormalized()
        local rotation_angle = -math.deg( math.atan2( dd_rotation_vector.x, dd_rotation_vector.y ) )
        setElementRotation( player, 0, 0, rotation_angle )
        player.rotation.z = rotation_angle
        setPedRotation( player, rotation_angle )

        triggerEvent( "OnCasinoGameStarted", player, lobby_id, ROOMS[ lobby_id ].game )
    end

    -- Ставим игрокам состояние "в игре" перед выбором игрока для хода
    for v, player in pairs( players_list ) do
        player:SetState( lobby_id, CASINO_PLAYER_STATE_PLAYING )
        player:CompleteDailyQuest( "play_casino" )
    end

    -- Выбор игрока для первого хода
    local rand = math.random(#players_list)
    SetTurnPlayer( lobby_id, players_list[rand] )

    -- 15 секунд на первый ход после создания лобби
    StartTurnTimer( lobby_id, 15 )

    triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameRouletteStarted", resourceRoot, { casino_id = casino_id, players = GetPlayersList( lobby_id ) } )

    triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameRouletteTurnStarted", resourceRoot, ROOMS[ lobby_id ].turn )
end
addEvent( "onCasinoGameRouletteStart", true )
addEventHandler( "onCasinoGameRouletteStart", root, onCasinoGameRouletteStart_handler )