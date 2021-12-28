-- Запрос на выход со стола
function onFoolTableLeaveRequest_handler( lobby_id, manualExit )
    local lobby_id = lobby_id or GetPlayerLobbyID( source )

    if client then triggerEvent( "onCasinoPlayerBlockLobbyJoin", client ) end

    if lobby_id and ROOMS[ lobby_id ] then 
        -- ЗДЕСЬ ДОЛЖНА БЫТЬ ПОТЕРЯ ДЕНЕГ ЗА ВЫХОД ИЛИ ДРУГАЯ ПРОВЕРКА
        local is_room_active = LobbyGet( lobby_id, "state" ) == CASINO_STATE_RUNNING

        if is_room_active and not LobbyGet( lobby_id, "restarting" ) then
            if #GetActivePlayersList( lobby_id ) >= 2 and source:GetState( lobby_id ) == CASINO_PLAYER_STATE_PLAYING then
                ParsePlayerVictory_Final( lobby_id, source, "lost", true )
            end
        end

        local turn_player = GetTurnPlayer( lobby_id )
		local turn_target = GetTurnTarget( lobby_id )
		
		local room = ROOMS[ lobby_id ]
		if room and manualExit then
			local iTimePassed = math.floor( (getTickCount() - (room.start_tick or getTickCount())) / 1000 )
			triggerEvent("OnCasinoGamePlayerLeft", source, iTimePassed, LobbyGet( lobby_id, "bet" ), CASINO_GAME_FOOL )
		end

        if GetPlayerLobbyID( source ) == lobby_id then
			LobbyCall( lobby_id, "leave", source )
        end
		if not ROOMS[ lobby_id ] then return end
		
        ROOMS[ lobby_id ].players[ source ] = nil
        ROOMS[ lobby_id ].hands[ source ] = nil
        --iprint( "player left clear", ROOMS[ lobby_id ].players )

        -- Если игрок ходил в этот момент
        if is_room_active then
            if source == turn_player then
                ROOMS[ lobby_id ].turn = nil
                onCasinoGameFoolTurnServersideEnd_handler( lobby_id, false, true )

            -- Если под игрока ходили в этот момент
            elseif source == turn_target then
                ROOMS[ lobby_id ].turn_target = nil
                onCasinoGameFoolTurnServersideEnd_handler( lobby_id, false, true )
            end
        end

        if is_room_active then
            local players_left = GetPlayersList( lobby_id )
            if #players_left == 1 then
                -- Если игрок остался один, выкидываем его из игры
                local alone_player = players_left[ 1 ]
                LobbyCall( lobby_id, "leave", alone_player, false, false, false, false, "finish" )
                alone_player:ShowError( "Ты остался один в лобби и оно было закрыто" )
            else
                -- Удаление игрока из списка онлайна
                RefreshPlayersInRoom( lobby_id, false )

                --[[if is_room_active then
                    local took_amount = ParsePlayerVictory_Final( lobby_id, source, "lost" )
                    source:ShowError( took_amount and "Ты покинул стол и потерял " .. took_amount or "Ты покинул стол" )

                    -- ОПРЕДЕЛЯТЬ НУЖНО ЛИ МЕНЯТЬ ЦЕЛЬ ИЛИ ИСТОЧНИК ИГРЫ
                    if not ignore_turn_transfer then

                        if should_drop_table_and_end_turn then
                            --onCasinoGameFoolTurnServersideEnd_handler( lobby_id, false, true, true )
                        end

                    end
                end]]

            end
        end

    end
end
addEvent( "onFoolTableLeaveRequest", true )
addEventHandler( "onFoolTableLeaveRequest", root, onFoolTableLeaveRequest_handler )

---------------------------
-------- НАЧАЛО ИГРЫ ------
---------------------------
function onCasinoGameFoolStart_handler( lobby_id )
    if client then return end
	
    --( "START PLAYERS LIST", LobbyGet( lobby_id, "players_list" ) )

    --iprint( "GET PLAYERS LIST", GetPlayersList( lobby_id ) )
    -- Установка игроков по позициям при начале игры

    local players_list = GetPlayersList( lobby_id )

    for i, player in pairs( players_list ) do
        local position      = ROOMS_POSITIONS[ i ]

        player.dimension    = 660 + lobby_id
        player.interior     = 1
        player.position     = position

        local new_rotation_vector = LOOKAT - position
        local dd_rotation_vector = Vector2( new_rotation_vector.x, new_rotation_vector.y ):getNormalized()
        local rotation_angle = -math.deg( math.atan2( dd_rotation_vector.x, dd_rotation_vector.y ) )
        setPedRotation( player, rotation_angle )
		setCameraTarget( player, player )
		triggerEvent( "OnCasinoGameStarted", player, lobby_id, CASINO_GAME_FOOL )
	end
	
	ROOMS[ lobby_id ].start_tick = getTickCount( )
    -- Ставим колоду
    SetDeck( lobby_id, GetRandomizedDeck( DECK_36 ) )

    -- Козырь и козырная карта, известная клиентам
    local trump_card = TakeCardFromDeck( lobby_id, math.random( #GetDeck( lobby_id ) ) )
    SetTrump( lobby_id, trump_card[ 2 ] ) 

    -- Возвращение козырной карты в колоду
    local deck = GetDeck( lobby_id )
    table.insert( deck, trump_card )
    SetDeck( lobby_id, deck )

    -- Ставим игрокам состояние "в игре" перед выбором игрока для хода
    for v, player in pairs( players_list ) do
        player:SetState( lobby_id, CASINO_PLAYER_STATE_PLAYING )
    end

    -- Выбор игрока для первого хода
    local first_player  = GetFirstPlayer( lobby_id )
    local target_player = GetNextPlayerAfter( lobby_id, first_player )
    SetTurnPlayer( lobby_id, first_player, target_player )

    first_player:SetGameTask( lobby_id, CASINO_TASK_PLAYING )
    target_player:SetGameTask( lobby_id, CASINO_TASK_DEFENDING )

    local predicted_deck_amount = #GetDeck( lobby_id ) - #players_list * 6

    -- Даём игрокам рандомные 6 карт
    for v, player in pairs( players_list ) do

        for i = 1, 6 do
            player:TakeCardFromDeck( lobby_id )
        end

        player:CompleteDailyQuest( "play_casino" )
        triggerClientEvent(   player, "onCasinoGameFoolStartRcv", player, 
                                    { 
                                        hand        = player:GetHand( lobby_id ), 
                                        trump       = GetTrump( lobby_id ), 
                                        trump_card  = trump_card,
                                        game_var    = LobbyGet( lobby_id, "game_var" ),
                                        deck_amount = predicted_deck_amount,
                                    }
                                )
    end

    -- Обновить инфу игроков
    RefreshPlayersInRoom( lobby_id, false )

    -- 50 секунд на первый ход после создания лобби
    StartTurnTimer( lobby_id, 50 )
end
addEvent( "onCasinoGameFoolStart", true )
addEventHandler( "onCasinoGameFoolStart", root, onCasinoGameFoolStart_handler )

function SwitchTurnToAdder( lobby_id )
    local turn_player = GetTurnPlayer( lobby_id )
    local turn_target = GetTurnTarget( lobby_id )
    local player_before_target = GetPreviousPlayerBefore( lobby_id, turn_target )
    local player_after_target = GetNextPlayerAfter( lobby_id, turn_target )

    if turn_target then

        -- Если стол не пустой
        if #GetTable( lobby_id ) > 0 then

            -- Если сейчас ходил тот, кто качал раунд
            if turn_player == player_before_target then

                -- Если это не тот же игрок, который уже ходит
                if player_before_target ~= player_after_target then

                    if #turn_target:GetHand( lobby_id ) > 0 then

                        SetTurnPlayer( lobby_id, player_after_target, turn_target )
                        player_before_target:SetGameTask( lobby_id, CASINO_TASK_WAITING )
                        player_after_target:SetGameTask( lobby_id, CASINO_TASK_ADDING )

                        RefreshPlayersInRoom( lobby_id )
                        ResetTurnTimer( lobby_id )

                        return true

                    end

                end
            end

        end

    end
end

function onCasinoGameFoolTurnServersideEnd_handler( lobby_id, force_take, force_clear, force_next_turn, force_start_taking )

    local is_forced_call = force_take or force_clear or force_next_turn

    -- Текущее состояние игры - кто на кого ходит
    local turn_player = GetTurnPlayer( lobby_id )
    local turn_target = GetTurnTarget( lobby_id )

    -- Игрок перед тем, на кого ходят
    local player_before_target = GetPreviousPlayerBefore( lobby_id, turn_target )

    -- Стол и колода
    local game_table    = GetTable( lobby_id )
    local game_deck     = GetDeck( lobby_id )

    -- Поддержка состояния "беру"
    if turn_target and turn_target:GetGameTask( lobby_id ) == CASINO_TASK_DEFENDING and not is_forced_call and #game_table > 0 then
        if #GetUnbeatenCards( lobby_id ) > 0 or force_start_taking then
            turn_target:SetGameTask( lobby_id, CASINO_TASK_TAKING )
            RefreshPlayersInRoom( lobby_id, false )
            StartTurnTimer( lobby_id, 20 )
            return
        end
    end

    -- Если есть возможность поменять на того, кто ходит, отменяем действие и делаем дело
    local turn_switching = not force_next_turn and not force_take and SwitchTurnToAdder( lobby_id )
    if turn_switching then return end


    -- Выбор - забирать стол или кидать в биту
    local is_target_taking = turn_target and turn_target:GetGameTask( lobby_id ) == CASINO_TASK_TAKING
    if not force_clear and turn_target or is_target_taking then
        if #game_table > 0 then
            local unbeaten_cards = #GetUnbeatenCards( lobby_id )
            if force_take or unbeaten_cards > 0 or is_target_taking then
                TakeTable( lobby_id, turn_target, true )
                turn_target:SyncHand( lobby_id )
                turn_target:SetState( lobby_id, CASINO_PLAYER_STATE_WAITING )
                turn_target:SetGameTask( lobby_id, CASINO_TASK_WAITING )
                
            else
                ClearTable( lobby_id )
            end

        else
            if turn_player then
                triggerEvent( "onFoolTableLeaveRequest", turn_player, lobby_id, true )
                turn_player:ShowError( "Раунд окончен из-за бездействия (ты обязан положить хотя бы 1 карту)" )
            end
        end
    else
        ClearTable( lobby_id )
    end

    -- Если лобби на этот момент уже не существует
    if not LobbyGet( lobby_id, "id" ) then return end

    -- Выбор источника игры
    local first_player = GetNextPlayerAfter( lobby_id, player_before_target )

    -- Возвращаем игрока в пул поиска, если был игрок, который забрал стол
    if turn_target and turn_target:GetState( lobby_id ) == CASINO_PLAYER_STATE_WAITING then
        turn_target:SetState( lobby_id, CASINO_PLAYER_STATE_PLAYING )
    end

    -- Выбор цели на игру
    local target_player = GetNextPlayerAfter( lobby_id, first_player )
    if first_player == target_player then target_player = GetNextPlayerAfter( lobby_id, target_player ) end

    -- Если у того, кто ходит, больше нет карт в руке и колода пустая
    if first_player and #first_player:GetHand( lobby_id ) <= 0 and #game_deck <= 0 then

        local saved_player = first_player

        local previous_player = GetPreviousPlayerBefore( lobby_id, saved_player )
        if previous_player:GetGameTask( lobby_id ) ~= CASINO_TASK_WON then
            previous_player:SetGameTask( lobby_id, CASINO_TASK_WAITING )
        end

        -- Ищем следующего ходящего, проверяем что он не равен тому, кто вышел из игры
        first_player = GetNextPlayerAfter( lobby_id, first_player )
        if saved_player == first_player then
            first_player = GetNextPlayerAfter( lobby_id, first_player )
        end

        -- Определяем цель после выбора нужного игрока
        target_player = GetNextPlayerAfter( lobby_id, first_player )

        -- Состояние "победил"
        ParsePlayerVictory_Final( lobby_id, saved_player, "won" )

        -- Если победивший игрок оказался целью хода, ищем нового
        if target_player == saved_player then 
            target_player = GetNextPlayerAfter( lobby_id, first_player ) 
        end

    end

    -- Если у того, на кого пытаемся ходить, нет карт в руке и колода пустая
    if target_player and #target_player:GetHand( lobby_id ) <= 0 and #game_deck <= 0 then
        local saved_player = target_player

        -- Ищем нового и ставим ему победу
        target_player = GetNextPlayerAfter( lobby_id, target_player )

        ParsePlayerVictory_Final( lobby_id, saved_player, "won" )
    end
    

    -- Случай когда за столом в игре остался 1 игрок
    local active_players    = GetActivePlayersList( lobby_id )
    local has_game_ended    = #active_players == 1
    
    if has_game_ended then

        -- Ищем оставшегося игрока за столом
        local player = active_players[ 1 ]

        -- Если за столом больше, чем оставшийся игрок, то определяем, что он проигравший
        if #GetPlayersList( lobby_id ) > 1 then
            ParsePlayerVictory_Final( lobby_id, player, "lost" )

        -- В ином случае, просто выходит со стола
        else
            player:ShowError( "За столом не осталось других игроков, раунд окончен" )
        end

        -- Завершаем раунд в любом случае
        EndRound( lobby_id, true )
        return
    end

    -- Устанавливаем ход
    SetTurnPlayer( lobby_id, first_player, target_player )

    -- Добор карт из колоды
    for i, v in pairs( GetActivePlayersList( lobby_id ) ) do
        local hand_changed = false
        while #v:GetHand( lobby_id ) < 6 and #GetDeck( lobby_id ) > 0 do
            hand_changed = true
            v:TakeCardFromDeck( lobby_id )
        end
        if hand_changed then v:SyncHand( lobby_id ) end
    end

    -- Устанавливаем состояния игроков
    local old_target_task = target_player:GetGameTask( lobby_id )
    -- Если у игрока было состояние "беру", то сохраняем его
    local new_target_task = old_target_task == CASINO_TASK_TAKING and CASINO_TASK_TAKING or CASINO_TASK_DEFENDING

    -- Обновляем состояния игроков и синхроним инфу
    target_player:SetGameTask( lobby_id, new_target_task )
    first_player:SetGameTask( lobby_id, CASINO_TASK_PLAYING )

    RefreshPlayersInRoom( lobby_id, true )

    -- Обновляем колоду
    RefreshDeck( lobby_id )

    -- Запускаем таймер
    StartTurnTimer( lobby_id, 30 )
end
addEvent( "onCasinoGameFoolTurnServersideEnd", true )
addEventHandler( "onCasinoGameFoolTurnServersideEnd", root, onCasinoGameFoolTurnServersideEnd_handler )


-- Попытка побить карту
function onCasinoFoolCardBeatRequest_handler( card_number, card_table_position )
    local player = client
    local lobby_id = GetPlayerLobbyID( player )
    if not lobby_id then return end

    if player:GetGameTask( lobby_id ) == CASINO_TASK_TAKING then
        player:ShowError( "Ты решил забрать карты, дождись пока тебе докинут еще" )
        triggerClientEvent( player, "onCardUsageError", player, card_number )
        return
    end

    local player_hand = player:GetHand( lobby_id )
    local game_table = GetTable( lobby_id )

    local card = player_hand[ card_number ]
    local card_table = game_table[ card_table_position ]

    -- Если эта карта уже побита
    if not card_table or card_table.beat then
        player:ShowError( "Карта уже побита!" )
        triggerClientEvent( player, "onCardUsageError", player, card_number )
        return
    end

    -- Если можно побить эту карту
    if DoesCardBeatAnother( card, card_table.card, GetTrump( lobby_id ) ) then
        game_table[ card_table_position ].beat = card
        SetTable( lobby_id, game_table )

        table.remove( player_hand, card_number )
        player:SetHand( lobby_id, player_hand )
        player:SyncHand( lobby_id )

        RefreshPlayersInRoom( lobby_id )

        ResetTurnTimer( lobby_id )

    else
        player:ShowError( "Эту карту не побить!" )
        triggerClientEvent( player, "onCardUsageError", player, card_number )
    end
end
addEvent( "onCasinoFoolCardBeatRequest", true )
addEventHandler( "onCasinoFoolCardBeatRequest", root, onCasinoFoolCardBeatRequest_handler )


-- Попытка положить новую карту на стол или перевести на другого игрока
function onCasinoFoolCardAddRequest_handler( card_number )
    local player = client
    local lobby_id = GetPlayerLobbyID( player )
    if not lobby_id then return end

    local player_hand = player:GetHand( lobby_id )
    local game_table = GetTable( lobby_id )

    if #game_table >= 6 then
        player:ShowError( "Нельзя положить на стол более 6 карт!" )
        triggerClientEvent( player, "onCardUsageError", player, card_number )
        return
    end

    local card = player_hand[ card_number ]
    if not card then return end

    if #game_table >= 1 then
        local card_exists_on_table = false
        for i, card_table_array in pairs( game_table ) do
            for n, card_table in pairs( { card_table_array.card, card_table_array.beat } ) do
                if card_table[ 1 ] == card[ 1 ] then
                    card_exists_on_table = true
                    break
                end
            end
        end
        if not card_exists_on_table then
            player:ShowError( "Нельзя подкинуть карту, которой нет на столе!" )
            triggerClientEvent( player, "onCardUsageError", player, card_number )
            return
        end
    end

    local last_table_card = game_table[ #game_table ]

    local game_var = LobbyGet( lobby_id, "game_var" )

    local unbeaten_cards, card_variety, last_card = #GetUnbeatenCards( lobby_id ), 0, { }
    for i, v in pairs( game_table ) do
        if last_card ~= last_table_card.card[ 1 ] then
            card_variety = card_variety + 1
            last_card = last_table_card.card[ 1 ]
        end
    end

    -- Если игроку нужно побить другую карту
    if unbeaten_cards >= CARDS_ON_TABLE_LIMIT then
        player:ShowError( "Слишком много небитых карт!" )
        triggerClientEvent( player, "onCardUsageError", player, card_number )
        return
    end

    local is_translating = false
    local is_turn_player = player == GetTurnPlayer( lobby_id )

    local turn_target = GetTurnTarget( lobby_id )

    if game_var == CASINO_GAME_FOOL_VAR_TRANSLATABLE then
        if player == turn_target then
            if #game_table >= 1 and unbeaten_cards == #game_table and card_variety == 1 and turn_target:GetGameTask( lobby_id ) == CASINO_TASK_DEFENDING then
                is_translating = true
            else
                player:ShowError( "Переводить можно только если ни одна карта не бита!" )
                triggerClientEvent( player, "onCardUsageError", player, card_number )
                return
            end
        elseif not is_turn_player then
            player:ShowError( "Сейчас не твой ход!" )
            triggerClientEvent( player, "onCardUsageError", player, card_number )
            return
        end
    end

    if not is_translating and not is_turn_player then
        player:ShowError( "Сейчас не твой ход!" )
        triggerClientEvent( player, "onCardUsageError", player, card_number )
        return
    end
    

    if is_translating then

        -- Выбор игрока для первого хода
        local turn_player = GetTurnPlayer( lobby_id )

        local first_player  = player
        local target_player = GetNextPlayerAfter( lobby_id, first_player )

        if #target_player:GetHand( lobby_id ) > #GetUnbeatenCards( lobby_id ) then

            if turn_player then turn_player:SetGameTask( lobby_id, CASINO_TASK_WAITING ) end

            SetTurnPlayer( lobby_id, first_player, target_player )

            first_player:SetGameTask( lobby_id, CASINO_TASK_PLAYING )
            target_player:SetGameTask( lobby_id, CASINO_TASK_DEFENDING )

            RefreshPlayersInRoom( lobby_id )

        else
            player:ShowError( "У противника недостаточно карт!" )
            triggerClientEvent( player, "onCardUsageError", player, card_number )
            return
        end
    else

        local target_player = GetTurnTarget( lobby_id )

        if #target_player:GetHand( lobby_id ) <= #GetUnbeatenCards( lobby_id ) then
            player:ShowError( "У противника недостаточно карт!" )
            triggerClientEvent( player, "onCardUsageError", player, card_number )
            return
        end

        if turn_target and #turn_target:GetHand( lobby_id ) < 1 then
            player:ShowError( "У игрока кончились карты! Больше подкинуть нельзя" )
            triggerClientEvent( player, "onCardUsageError", player, card_number )
            return
        end

    end

    -- Даём еще 20 сек
    ResetTurnTimer( lobby_id )

    -- Ставим карту на стол небитой
    table.insert( game_table, { card = card } )
    SetTable( lobby_id, game_table )

    -- Удаляем карту из руки
    table.remove( player_hand, card_number )
    player:SetHand( lobby_id, player_hand )
    player:SyncHand( lobby_id )

    -- Обновляем руки игроков
    RefreshPlayersInRoom( lobby_id, true )

    -- Игрок победил или проиграл, можно менять на другого
    local result = ParsePlayerVictory_Final( lobby_id, player )
    if result then
        local active_players = GetActivePlayersList( lobby_id )
        if #active_players == 1 then
            --ParsePlayerVictory_Final( lobby_id, active_players[ 1 ], "lost" )
            onCasinoGameFoolTurnServersideEnd_handler( lobby_id, nil, true )
        end
    end
end
addEvent( "onCasinoFoolCardAddRequest", true )
addEventHandler( "onCasinoFoolCardAddRequest", root, onCasinoFoolCardAddRequest_handler )


BETS_SECTIONED = {
    soft = {
        -- Тестовое значение
        [ 2 ] = {
            1, 0,
            comission = 0.04,
        },

        [ 3 ] = {
            0.6, 0.4, 0, 0,
            comission = 0.06,
        },
        [ 4 ] = {
            0.5, 0.3, 0.2, 0,
            comission = 0.08,
        },
        [ 5 ] ={
            0.4, 0.25, 0.2, 0.15,
            comission = 0.1,
        }
    },
}

function ParsePlayerVictory_Final( lobby_id, player, force_state, is_quit, check_only )
    local victory_state = ParsePlayerVictory( lobby_id, player, force_state, check_only )
    if victory_state == "won" then
        
        return true
    elseif victory_state == "lost" then
		if not check_only then
            local lost_amount = TakeLostAmount( lobby_id, player, is_quit )
			
			ROOMS[ lobby_id ].players[ player ].lost_summ_total = (ROOMS[ lobby_id ].players[ player ].lost_summ_total or 0) + lost_amount			
            player:ShowError( "Ты проиграл " .. tostring( lost_amount ) .. "!" )
        end

        return true
    end
end

-- Состояние победы или проигрыша для игрока
function ParsePlayerVictory( lobby_id, player, force_state, check_only )
    if player:GetState( lobby_id ) == CASINO_PLAYER_STATE_PLAYING then
        local hand_amount = #player:GetHand( lobby_id )
        local deck_amount = #GetDeck( lobby_id )

        if force_state == "won" or hand_amount <= 0 and deck_amount <= 0 then
            if not check_only then
                player:SetState( lobby_id, CASINO_PLAYER_STATE_WON )
                player:SetGameTask( lobby_id, CASINO_TASK_WON )
				table.insert( ROOMS[ lobby_id ].winners, player )

                RefreshPlayersInRoom( lobby_id )
            end

            return "won"
        
        elseif force_state == "lost" or hand_amount > 0 and deck_amount <= 0 and #GetActivePlayersList( lobby_id ) == 1 and #GetPlayersList( lobby_id ) > 1 then
            if not check_only then
                player:SetState( lobby_id, CASINO_PLAYER_STATE_LOST )
                player:SetGameTask( lobby_id, CASINO_TASK_LOST )
                ROOMS[ lobby_id ].loser = player

                RefreshPlayersInRoom( lobby_id, true )
            end

            return "lost"
        end
    end
end

function GiveWonAmount( lobby_id, player, position )
    local bet_amount = LobbyGet( lobby_id, "bet" )
    local bet_hard = LobbyGet( lobby_id, "hard" )

    local players = ROOMS[ lobby_id ].total_count
    local definition_table = BETS_SECTIONED[ bet_hard and "hard" or "soft" ][ players ]

    -- Донат
    if not bet_hard then
        -- Комиссия только с последнего победителя
        local comission_perc = position == players - 1 and ( 1 - definition_table.comission ) or 1
        local value = math.ceil( definition_table[ position ] * bet_amount * comission_perc )
        player:GiveMoney( value, "casino", "fool_win" )
        player:ShowInfo( "Ты выиграл " .. value .. "р. !" )
        triggerEvent( "onQuestCasinoComplete", player, CASINO_GAME_FOOL, value, bet_hard and "hard" or "soft", position == 1, bet_hard and player:GetDonate() or player:GetMoney() )
        return true
    end
end

function TakeLostAmount( lobby_id, player, is_quit )
    local bet_amount = LobbyGet( lobby_id, "bet" )
    local bet_hard = LobbyGet( lobby_id, "hard" )

    local players = ROOMS[ lobby_id ].total_count
    local definition_table = BETS_SECTIONED[ bet_hard and "hard" or "soft" ][ players ]

    if LobbyGet( lobby_id, "restarting" ) then return end -- Запрет снятия денег за рестарт

    if not bet_hard then
        -- Только если игрок проиграл в этот момент
        if player:GetState( lobby_id ) == CASINO_PLAYER_STATE_LOST then
            -- Снимаем деньги и проверяем действительно ли они были сняты
            local is_money_taken = player:TakeMoney( bet_amount, "casino", "fool_lost" )
            if is_money_taken then
                -- Изначальная сумма если игрок вышел
                local amount = is_quit and math.ceil( bet_amount * ( 1 - definition_table.comission ) / ( players - 1 ) ) or 0
                for i, v in pairs( GetPlayersList( lobby_id ) ) do
                    if player ~= v then

                        -- Если тот игрок вышел, делим поровну
                        if is_quit then
                            v:GiveMoney( amount, "fool_win" )

                        -- Если тот игрок проиграл, делим по соотношениям
                        else
                            local won_position = 0
                            for n, t in pairs( ROOMS[ lobby_id ].winners ) do
                                if v == t then
                                    won_position = n
                                    break
                                end
                            end

                            -- Если победитель, то определяем по позиции сколько ему выдать в соотношении
                            if won_position > 0 then
                                GiveWonAmount( lobby_id, v, won_position )
                            end

                        end

                    end
                end

                return bet_amount
            end

        end

    end
end

function EndRound( lobby_id, another_round )
    SetTurnPlayer( lobby_id )
    RefreshPlayersInRoom( lobby_id, false )

    StopTurnTimer( lobby_id )

    if another_round then

        LobbyCall( lobby_id, "destroy" )

        --[[LobbySet( lobby_id, "state", CASINO_STATE_WAITING )
        LobbySet( lobby_id, "invisible", true )

        for i, v in pairs( GetPlayersList( lobby_id ) ) do
            v:SetState( lobby_id, CASINO_PLAYER_STATE_WAITING )
        end

        triggerClientEvent( "onCasinoGameFoolAskForContinuation", resourceRoot, true )

        ROOMS[ lobby_id ].change_timer = setTimer( CheckLobbyReset, 30 * 1000, 1, lobby_id )]]



    end
end

function CheckLobbyReset( lobby_id )
    if not ROOMS[ lobby_id ] then return end
    for i, v in pairs( GetPlayersList( lobby_id ) ) do
        if ROOMS[ lobby_id ].players[ v ] and ROOMS[ lobby_id ].players[ v ].state == CASINO_PLAYER_STATE_READY then
            v:SetState( lobby_id, CASINO_PLAYER_STATE_WAITING )
        else
            LobbyCall( lobby_id, "leave", v )
        end
    end

    ResetLobby( lobby_id )
end

function onCasinoGameFoolAskForContinuationResultRcv_handler( agreed )
    local lobby_id = GetPlayerLobbyID( client )
    if not lobby_id then return end

    if not agreed then
        LobbyCall( lobby_id, "leave", client )
    else
        client:SetState( lobby_id, CASINO_PLAYER_STATE_READY )
    end
end
addEvent( "onCasinoGameFoolAskForContinuationResultRcv", true )
addEventHandler( "onCasinoGameFoolAskForContinuationResultRcv", root, onCasinoGameFoolAskForContinuationResultRcv_handler )

-- Кнопка "Взять"
function onCasinoGameFoolTakeRequestServerside_handler( lobby_id )
    local player = client or source
    local lobby_id = GetPlayerLobbyID( player )
    if not lobby_id then return end

    if GetTurnTarget( lobby_id ) == player then
        if #GetTable( lobby_id ) >= 1 then
            local game_task = player:GetGameTask( lobby_id )

            -- Если защищается, то передаем в обработку
            if game_task == CASINO_TASK_DEFENDING then
                onCasinoGameFoolTurnServersideEnd_handler( lobby_id, nil, nil, nil, true )

            -- Если уже берет, запрещаем
            elseif game_task == CASINO_TASK_TAKING then
                player:ShowError( "Ожидай пока тебе подкинут еще!" )
            end
        else
            player:ShowError( "Стол пуст!" )
        end
    end
end
addEvent( "onCasinoGameFoolTakeRequestServerside", true )
addEventHandler( "onCasinoGameFoolTakeRequestServerside", root, onCasinoGameFoolTakeRequestServerside_handler )

-- Кнопка "Пас"
function onCasinoGameFoolDropRequestServerside_handler( lobby_id, duration )
    local player = client
    local lobby_id = GetPlayerLobbyID( player )
    if not lobby_id then return end

    if GetTurnPlayer( lobby_id ) == player then

        if #GetTable( lobby_id ) >= 1 then
            local target_player = GetTurnTarget( lobby_id )

            if target_player then
                local game_task = target_player:GetGameTask( lobby_id )

                -- Если неотбитых карт нет, то завершаем ход и чистим стол
                if #GetUnbeatenCards( lobby_id ) <= 0 then
                    onCasinoGameFoolTurnServersideEnd_handler( lobby_id, false, true )

                -- Тот, кто отбивается, забирает карты и ход меняется
                elseif game_task == CASINO_TASK_TAKING then
                    onCasinoGameFoolTurnServersideEnd_handler( lobby_id, false, false )

                -- В случае если игрок пытается нажать "пас" и карты не отбиты и игрок не в состоянии "беру"
                else
                    player:ShowError( "Противник еще не отбил все карты!" )
                end
            else
                onCasinoGameFoolTurnServersideEnd_handler( lobby_id, false, true )
            end

        else
            player:ShowError( "Нужно сделать как минимум 1 ход!" )
        end
    end

end
addEvent( "onCasinoGameFoolDropRequestServerside", true )
addEventHandler( "onCasinoGameFoolDropRequestServerside", root, onCasinoGameFoolDropRequestServerside_handler )