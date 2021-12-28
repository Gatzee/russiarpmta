-- Запрос на выход со стола
function onDiceTableLeaveRequest_handler( lobby_id, from_destroy, is_leave, leave_reason )
    local lobby_id = lobby_id or GetPlayerLobbyID( source )

    if client then triggerEvent( "onCasinoPlayerBlockLobbyJoin", client ) end
    
    if lobby_id and ROOMS[ lobby_id ] then 
        -- ЗДЕСЬ ДОЛЖНА БЫТЬ ПОТЕРЯ ДЕНЕГ ЗА ВЫХОД ИЛИ ДРУГАЯ ПРОВЕРКА
        local is_room_active = LobbyGet( lobby_id, "state" ) == CASINO_STATE_PLAYING
        local is_restarting = LobbyGet( lobby_id, "restarting" )

        local next_player_after_leaver = GetNextPlayerAfter( lobby_id, source )

        local turn_player = GetTurnPlayer( lobby_id )

        if ROOMS[lobby_id] and not ROOMS[ lobby_id ].participants_left[ source ] then
            ROOMS[ lobby_id ].participants_left[ source ] = { name = source:GetNickName(), uid = source:GetID(), is_leave = is_leave }
        end

        if GetPlayerLobbyID( source ) == lobby_id then
            LobbyCall( lobby_id, "leave", source, false, false, false, leave_reason )
        end

        if not ROOMS[ lobby_id ] then return end
        
        local player_quantity = #GetPlayersList( lobby_id )
        local player_data = table.copy( ROOMS[ lobby_id ].players[ source ] )
        if player_data then
            player_data.is_create = pWinner == ROOMS[ lobby_id ].owner
            player_data.is_win = false
            onCasinoBoneLeave( source, player_quantity, ROOMS[ lobby_id ], player_data, leave_reason )
        end

        ROOMS[ lobby_id ].players[ source ] = nil
        ROOMS[ lobby_id ].scores[ source ] = nil

        if is_room_active and not is_restarting then
            local players_left = GetPlayersList( lobby_id )

            -- Если игрок остался один, выкидываем его из игры
            if #players_left == 1 then
                local alone_player = players_left[ 1 ]
                FinishGame( lobby_id, alone_player, true, "finish" )
                alone_player:ShowError( "Ты остался один в лобби и оно было закрыто" )

                return true
            end

            -- Если игрок ходил в этот момент
            if source == turn_player then
                onCasinoGameDiceTurnServersideEnd_handler( lobby_id, true )
                SetTurnPlayer( lobby_id, next_player_after_leaver )
            end
        end

        if not from_destroy then
            local room = ROOMS[ lobby_id ]
            if room then
                local iTimePassed = getRealTimestamp() - ROOMS[lobby_id].start_time
                triggerEvent("OnCasinoGamePlayerLeft", source, iTimePassed, room.bet * LobbyGet( lobby_id, "players_count_required" ), room.bet_hard and CASINO_GAME_DICE_VIP or CASINO_GAME_DICE )
            end
        end

        triggerClientEvent( GetPlayersList( lobby_id ), "OnPlayerLeftDiceTable", source )
    end
end
addEvent( "onDiceTableLeaveRequest", true )
addEventHandler( "onDiceTableLeaveRequest", root, onDiceTableLeaveRequest_handler )

---------------------------
-------- НАЧАЛО ИГРЫ ------
---------------------------
function onCasinoGameDiceStart_handler( lobby_id )
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

        triggerEvent( "OnCasinoGameStarted", player, lobby_id, ROOMS[ lobby_id ].bet_hard and CASINO_GAME_DICE_VIP or CASINO_GAME_DICE )
        player:CompleteDailyQuest("play_casino" )
    end

    -- Ставим игрокам состояние "в игре" перед выбором игрока для хода
    for v, player in pairs( players_list ) do
        player:SetState( lobby_id, CASINO_PLAYER_STATE_PLAYING )
    end

    ROOMS[lobby_id].round_started = getTickCount()

    -- Выбор игрока для первого хода
    local first_player  = GetFirstPlayer( lobby_id )
    SetTurnPlayer( lobby_id, first_player )

    -- 15 секунд на первый ход после создания лобби
    StartTurnTimer( lobby_id, 15 )

    triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameDiceStarted", resourceRoot, { casino_id = casino_id, players = GetPlayersList( lobby_id ) } )

    triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameDiceTurnStarted", resourceRoot, ROOMS[ lobby_id ].turn )
end
addEvent( "onCasinoGameDiceStart", true )
addEventHandler( "onCasinoGameDiceStart", root, onCasinoGameDiceStart_handler )