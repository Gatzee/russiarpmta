Extend( "SPlayer" )
Extend( "SDB" )

PLAYERS_POOL = { }
QUESTIONS_FORMS = { }
AVAILABLE_QUESTIONS_FORMS = { }

function questionFormIsPassed( player, id )
    local passed_questions = player:GetPermanentData( "passed_questions" ) or { }

    for idx, passed_id in pairs( passed_questions ) do
        if passed_id == id then
            return true
        end
    end

    return false
end

function onPlayerRequestOpenForm_handler( )
    if not client then return end
    if not PLAYERS_POOL[ client ] then return end

    -- TODO: request from F4 window
end
addEvent( "onPlayerRequestOpenForm", true )
addEventHandler( "onPlayerRequestOpenForm", resourceRoot, onPlayerRequestOpenForm_handler )

function onPlayerAnswerForm_handler( )
    if not client then return end

    local id = PLAYERS_POOL[ client ]
    if not id then return end

    local data = QUESTIONS_FORMS[ id ]
    if not data then
        client:ErrorWindow( "Ошибка. Опрос не найден" )
        return
    end

    if questionFormIsPassed( client, id ) then
        client:ErrorWindow( "Ты уже участвовал в данном опросе" )
        return
    end

    local passed_questions = client:GetPermanentData( "passed_questions" ) or { }
    table.insert( passed_questions, id )
    client:SetPermanentData( "passed_questions", passed_questions )

    if data.reward_type == "hard" then
        client:GiveDonate( data.reward, "custdev", "custdev_ingame_" .. id )
    elseif data.reward_type == "soft" then
        client:GiveMoney( data.reward, "custdev", "custdev_ingame_" .. id )
    end

    triggerClientEvent( client, "ShowQuestionFormRewardUI", resourceRoot, data.reward, data.reward_type )
end
addEvent( "onPlayerAnswerForm", true )
addEventHandler( "onPlayerAnswerForm", resourceRoot, onPlayerAnswerForm_handler )

function onPlayerReadyToPlay_handler( )
    if not source:HasFinishedTutorial( ) then
        return
    end

    local level = source:GetLevel( ) or 1
    local donate_total = source:GetPermanentData( "donate_total" ) or 0
    local client_id = source:GetClientID( )

    for question_id, data in pairs( AVAILABLE_QUESTIONS_FORMS ) do
        if ( data.for_all_users or data.client_ids[ client_id ] ) and not questionFormIsPassed( source, question_id )
        and donate_total >= data.donate_total and ( not data.faction_id or data.faction_id == source:GetFaction( ) )
        and level >= data.min_level and ( not data.max_level or level <= data.max_level ) then
            PLAYERS_POOL[ source ] = question_id
            triggerClientEvent( source, "onQuestionShowInfo", resourceRoot, true, {
                url = data.url,
                reward = data.reward,
                reward_type = data.reward_type
            } )
            break
        end
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler, true, "low" )

function onPlayerQuit_handler( )
    PLAYERS_POOL[ source ] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_handler )

function onMariaDBUpdate_handler( key, value )
    if key ~= "custdev" then return end

    QUESTIONS_FORMS = { } -- clear table
    AVAILABLE_QUESTIONS_FORMS = { } -- clear table

    local timestamp = getRealTimestamp( )

    for idx, data in pairs( value ) do
        data.for_all_users = ( tonumber( data.for_all_users ) or 0 ) == 1
        data.is_active = ( tonumber( data.is_active ) or 0 ) == 1
        data.min_level = data.min_level or 0
        data.donate_total = data.donate_total or 0

        -- convert time
        data.start_date = data.start_date and ( getTimestampFromString( data.start_date ) or 0 ) or 0
        data.finish_date = data.finish_date and ( getTimestampFromString( data.finish_date ) or 0 ) or 0

        -- convert table clients_ids
        local clients_ids = { }
        if not data.for_all_users then
            for idx, id in pairs( fromJSON( tostring( data.client_ids ) ) or { } ) do
                clients_ids[ id ] = true
            end
        end
        data.client_ids = clients_ids

        -- update
        QUESTIONS_FORMS[ data.id ] = data

        if data.is_active and timestamp >= data.start_date and timestamp < data.finish_date then
            AVAILABLE_QUESTIONS_FORMS[ data.id ] = data
        end
    end
end
onMariaDBUpdate_handler( "custdev", MariaGet( "custdev" ) )
addEvent( "onMariaDBUpdate" )
addEventHandler( "onMariaDBUpdate", root, onMariaDBUpdate_handler )