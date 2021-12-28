loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SChat" )

local REPORTS = { }
local REPORTS_COUNTER = 0

local PLAYERS_REPORTS = { }

enum "eReports" {
    "THEME",
    "SOURCE",
    "SOURCE_PLAYER",
    "CURRENT_HELPER",
    "RESPOND_TIMER",
    "TIMESTAMP",
    "LAST_TIMESTAMP",
    "MSG_HISTORY",
    "FIRST_ALERT_TIMER",
    "NAME",
}

enum "eErrors" {
    "ERR_SUCCESS",
    "ERR_NO_RESPONSE",
    "ERR_GM_OFFLINE",
    "ERR_PLAYER_OFFLINE",
}

local REASONS = {
    [ ERR_NO_RESPONSE ] = "На вашу заявку не было ответа более, чем за 15 минут и была аннулирована",
    [ ERR_GM_OFFLINE ] = "Ваш игровой мастер вышел из игры",
}

local REASONS_GM = {
    [ ERR_NO_RESPONSE ] = "Вы не дали ответа на заявку #%s и она была аннулирована",
    [ ERR_PLAYER_OFFLINE ] = "Игрок по заявке #%s вышел из игры",
}

local REASONS_LOG = {
    [ ERR_NO_RESPONSE ] = "На заявку не было дано ответа",
    [ ERR_GM_OFFLINE ] = "Игровой мастер вышел из игры",
    [ ERR_PLAYER_OFFLINE ] = "Игрок вышел из игры",
}

--Приём репорта от игрока
function onServerReceivePlayerReport_handler( name, theme, ... )
    if not client:IsInGame( ) then return end

    if client.muted then
        client:ShowError( "Ваш чат отключен и вы не можете писать репорты" )
        return
    end
    
    if PLAYERS_REPORTS[ client ] then
        client:ShowError( "У вас уже имеется активная заявка. Пожалуйста, дождитесь ответа игрового мастера" )
        return
    end
    
    local player_id = client:GetID()
    local player_name = client:GetNickName()

    local report_number = REPORTS_COUNTER + 1
    REPORTS[ report_number ] = 
    { 
        [ NAME          ] = name,
        [ THEME         ] = theme,
        [ SOURCE_PLAYER ] = client, 
        [ SOURCE        ] = player_id,
        [ TIMESTAMP     ] = getRealTime().timestamp,
        [ RESPOND_TIMER ] = setTimer( ReportCancel, 15 * 60 * 1000, 1, report_number, ERR_NO_RESPONSE ),
        [ MSG_HISTORY   ] = { },
    }

    REPORTS_COUNTER = report_number

    PLAYERS_REPORTS[ client ] = REPORTS_COUNTER

    local msg_tbl = { ... }
    local msg_str = table.concat( msg_tbl, " " )

    local msg_log = table.concat( { "> *", player_name, " (ID:", player_id, ")*: ", msg_str}, "" )
    table.insert( REPORTS[ REPORTS_COUNTER ][ MSG_HISTORY ], msg_log )

    local msg_report = table.concat( { "*", player_name, " (ID:", player_id, ")*: ", msg_str }, "" )
    REPORTS[ REPORTS_COUNTER ][ FIRST_ALERT_TIMER ] = setTimer( triggerEvent, 30*1000, 1, "onSlackAlertRequest", root, 1, "Открыта новая заявка *#" .. REPORTS_COUNTER .. "*", { text = msg_report, color = "#9966ff", attachment_type = "default" } )

    local target_users = {}
    local report_send_message = "Игрок " .. player_name .. " [ UID: " ..  player_id .. " ] написал репорт"
    for _, v in pairs( GetPlayersInGame() ) do
        if ( v:IsAdmin() ) then
            v:ShowInfo( report_send_message )
            table.insert( target_users, v )
        end
    end

    SendAdminActionToLogserver(
        client:GetNickName( ) .. " создал репорт #" .. report_number .. " с текстом: " .. msg_str,
        { rights_action = "create_report", report_number = report_number },
        { client, "player" }
    )

    triggerClientEvent( target_users, "onClientAddReportInMenu", client, REPORTS_COUNTER, REPORTS[ REPORTS_COUNTER ]  )
end
addEvent("onServerReceivePlayerReport", true )
addEventHandler( "onServerReceivePlayerReport", root, onServerReceivePlayerReport_handler )

-- Прием репорта от администратора, Ответ из панели управления репортами
function onServerAdminTalkToUser_handler( admin, report_number, ... )
    if not admin:IsAdmin() then return end

    report_number = tonumber( report_number )
    local report = REPORTS[ report_number ]
    if not report then
        admin:SendMessage( CHAT_TYPE_NORMAL, "Неправильный номер заявки!", 0xFFFF0000 )
        return
    end

    local msg_tbl = { ... }
    local msg_str = table.concat( msg_tbl, " " )
    if utf8.len( msg_str:gsub( " ", "" ) or "" ) <= 0 then msg_str = nil end

    local admin_id = admin:GetUserID()
    if report[ CURRENT_HELPER ] and report[ CURRENT_HELPER ] ~= admin_id then
        admin:SendMessage( "Данную заявку уже обарабатывает другой администратор", 0xFFFF0000 )
        return
    elseif report[ CURRENT_HELPER ] ~= admin_id then

        --Добавление отдельного канала с приветствием
        local target_player = report[ SOURCE_PLAYER ]
        target_player:ShowInfo( "Администратор принял вашу заявку. Добавлен чат канал '" .. CHAT_CHANNELS_NAME[ CHAT_TYPE_REPORT ] ..  "'")
        target_player:AddChatChannel( CHAT_TYPE_REPORT, true )
        target_player:SendMessage( CHAT_TYPE_REPORT, "Вас приветствует администрация NEXT RP", 0xFF00FF00 )
        report[ CURRENT_HELPER ] = admin_id

        triggerEvent( "onAdminAcceptReport", admin )
    end

    if msg_str then
        report[ SOURCE_PLAYER ]:SendMessage( CHAT_TYPE_REPORT, admin:GetNickName() .. ": " .. msg_str, 0xFF8FCC00 )
        admin:SendMessage( CHAT_TYPE_NORMAL, ">[Репорт#" .. report_number .. "]" .. admin:GetNickName() .. ": " .. msg_str, 0xFF8FCC00 )

        local msg_log = table.concat( { ">> *", admin:GetNickName(), " (ID:" .. admin:GetUserID()  .. " )*: ", msg_str}, "" )
        table.insert( report[ MSG_HISTORY ], msg_log )
    end

    if isTimer( report[ FIRST_ALERT_TIMER ] ) then 
        killTimer( report[ FIRST_ALERT_TIMER ] ) 
    end
    
    if isTimer( report[ RESPOND_TIMER ] ) then
        resetTimer( report[ RESPOND_TIMER ] )
    end

    local target_users = {}
    for _, v in pairs( GetPlayersInGame() ) do
        if ( v:IsAdmin() ) then
            table.insert( target_users, v )
        end
    end
    
    triggerClientEvent( target_users, "onClientRefreshReportMenu", admin, { [ report_number ] = report } )
end
addEvent("onServerAdminTalkToUser", true )
addEventHandler( "onServerAdminTalkToUser", root, onServerAdminTalkToUser_handler )

addCommandHandler( "r", function( player, cmd, report_number, ...  )
    triggerEvent( "onServerAdminTalkToUser", player, player, report_number, ... )
end )

-- Ответ игрока в чате
function onServerUserTalkToGamemaster_handler( ... )
    
    local report_number = PLAYERS_REPORTS[ source ]
    local report = REPORTS[ report_number ]
    if not report_number or not report then return end
    if source.muted then
        source:SendMessage( CHAT_TYPE_REPORT, "Ваш чат отключен и вы не можете отвечать при работе с гейм-мастерами", 0xFFFF0000 )
        return
    end

    local msg_tbl = { ... }
    local msg_str = table.concat( msg_tbl, " " )

    if utf8.len( msg_str:gsub( " ", "" ) or ""  ) == 0 then
        return
    end

    local admin_uid = report[ CURRENT_HELPER ]
    local admin = GetPlayer( admin_uid, true )
    if not isElement( admin ) then
        source:SendMessage( CHAT_TYPE_REPORT, "Администратора нет в сети", 0xFFC896FF )
        source:SendMessage( CHAT_TYPE_REPORT, "Чат будет закрыт через 10 секунд...", 0xFF00FF00 )
        setTimer( function( player )
            player:RemoveChatChannel( CHAT_TYPE_REPORT )
        end, 10000, 1, player )
        ReportCancel( report_number, ERR_GM_OFFLINE, true, _, true )
        return
    end

    source:SendMessage( CHAT_TYPE_REPORT, source:GetNickName() .. ": " .. msg_str, 0xFFFFFFFF )
    admin:SendMessage( CHAT_TYPE_NORMAL, "[Репорт#" .. report_number .. "][" .. source:GetID() .. "]" .. source:GetNickName() .. ": " .. msg_str, 0xFFFFFFFF )

    local msg_log = table.concat( { "> *", source:GetNickName(), " (ID:", source:GetID(), ")*: ", msg_str}, "" )
    table.insert( report[ MSG_HISTORY ], msg_log )
    if isTimer( report[ RESPOND_TIMER ] ) then
        resetTimer( report[ RESPOND_TIMER ] )
    end

    local target_users = {}
    for _, v in pairs( GetPlayersInGame() ) do
        if ( v:IsAdmin() ) then
            table.insert( target_users, v )
        end
    end
    triggerClientEvent( target_users, "onClientRefreshReportMenu", source, { [ report_number ] = report } )
end
addEvent("onServerUserTalkToGamemaster", true )
addEventHandler( "onServerUserTalkToGamemaster", root, onServerUserTalkToGamemaster_handler )

-- Закрытие заявки администратором
function onServerAdminCloseReport_handler( report_number, admin, reason_str )
    if not admin then admin = client end
    
    if not admin:IsAdmin() then return end

    report_number = tonumber( report_number )
    local report = REPORTS[ report_number ]
    local admin_id = admin:GetUserID()
    if not report or  report[ CURRENT_HELPER ] ~= admin_id then
        admin:SendMessage( CHAT_TYPE_NORMAL, "Неправильный номер заявки!", 0xFFFF0000 )
        return
    end

    if not reason_str or reason_str == "" then
        admin:SendMessage( CHAT_TYPE_NORMAL, "Не введена причина!", 0xFFFF0000 )
        return
    end

    local admin_name = admin:GetNickName( )
    local player = GetPlayer( report[ SOURCE ], true )
    if player then
        player:SendMessage( CHAT_TYPE_REPORT, "Ваша заявка была закрыта по причине: " .. reason_str, 0xFF00FF00 )
        player:SendMessage( CHAT_TYPE_REPORT, "Чат будет закрыт через 10 секунд...", 0xFF00FF00 )
        player:SendMessage( CHAT_TYPE_REPORT, "Вы можете оценить качество работы администратора в приложении “Репорты”", 0xFF00FF00 )
        
        setTimer( function( player )
            if isElement( player ) then
                player:RemoveChatChannel( CHAT_TYPE_REPORT )
            end
        end, 10000, 1, player )

        local admin_client_id = admin:GetClientID( )
        triggerClientEvent( player, "onClientReportClosed", player, {
            id = admin:GetUserID( ),
            client_id = admin_client_id,
            name = admin_name,
            until_date = os.time( ) + 3600,
        } )

        SendElasticGameEvent( admin_client_id, "admin_report_close", {
            admin_name = admin_name,
        } )
    end

    local success = ReportCancel( report_number, "Заявка была успешно закрыта по причине: " .. reason_str, false, true, true )
    
    if success then
        local target_users = {}
        for _, v in pairs( GetPlayersInGame() ) do
            if ( v:IsAdmin() ) then
                table.insert( target_users, v )
            end
        end
        triggerClientEvent( target_users, "onClientRemoveReportFromMenu", admin, report_number )

        SendAdminActionToLogserver(
            admin_name .. " закрыл репорт #" .. report_number .. " от игрока " .. player:GetNickName( ) .. " по причине:" .. reason_str,
            { rights_action = "close_report", report_close_reason = reason_str, report_number = report_number },
            { admin, "admin" }, { player, "player" }
        )
    end
end
addEvent("onServerAdminCloseReport", true )
addEventHandler( "onServerAdminCloseReport", root, onServerAdminCloseReport_handler )

addCommandHandler( "rdone", function( player, cmd, report_number, ...  )
    triggerEvent( "onServerAdminCloseReport", player, report_number, player, ... )
end )

--Событие с клиента для принудительного обновления репортов
addEvent("onServerRefreshReportMenu", true )
addEventHandler( "onServerRefreshReportMenu", root, function()
    triggerClientEvent( client, "onClientRefreshReportMenu", client, REPORTS )
end )

--Сброс счётчика репортов
addEvent("onServerResetReportCounter", true )
addEventHandler( "onServerResetReportCounter", root, function()
    if not client:IsAdmin() or ( client:GetAccessLevel() < ACCESS_LEVEL_SUPERVISOR ) then 
        triggerClientEvent( client, "onClientResetReportCounter", client, false )
        return 
    end

    REPORTS_COUNTER = 0
    triggerClientEvent( client, "onClientResetReportCounter", client, true )
end )

-- Отмена заявки
function ReportCancel( report_number, reason, silent, success, is_closed )
    local report = REPORTS[ report_number ]
    if not report then return end

    local player = GetPlayer( report[ SOURCE ], true )
    if isElement( player ) then
        PLAYERS_REPORTS[ player ] = nil
        if not silent and REASONS[ reason ] then
            player:SendMessage( CHAT_TYPE_REPORT, REASONS[ reason ], 0xFFC896FF )
        end
        if not is_closed then
            setTimer( function( player )
                if isElement( player ) then
                    player:RemoveChatChannel( CHAT_TYPE_REPORT )
                end
            end, 3000, 1, player )
        end
    end

    local player_gm = GetPlayer( report[ CURRENT_HELPER ], true )
    if isElement( player_gm ) then
        if not silent and REASONS_GM[ reason ] then
            triggerClientEvent( player_gm, "onClientSetInfoLabelText", player_gm, REASONS_GM[ reason ]:format( report_number ), 200, 150, 255 )
        end
    end

    if isTimer( report[ RESPOND_TIMER ] ) then
        killTimer( report[ RESPOND_TIMER ] )
    end

    local reason = REASONS_LOG[ reason ] or type( reason ) == "string" and reason
    table.insert( REPORTS[ report_number ][ MSG_HISTORY ], reason )

    local msg_total = table.concat( REPORTS[ report_number ][ MSG_HISTORY ], "\n" )
    local msg_color = success and "#00ff00" or "#ff0000"
    local duration = math.floor( ( getRealTime().timestamp - REPORTS[ report_number ][ TIMESTAMP ] ) / 60 )
    local msg_header = table.concat( { "*[REPORT #", report_number, "]* Затраченое время: ", duration, " мин." }, "" )
    triggerEvent( "onSlackAlertRequest", root, 2, msg_header, { text = msg_total, color = msg_color, attachment_type = "default" } )

    REPORTS[ report_number ] = nil
    
    local target_users = {}
    for _, v in pairs( GetPlayersInGame() ) do
        if ( v:IsAdmin() ) then
            table.insert( target_users, v )
        end
    end
    triggerClientEvent( target_users, "onClientRemoveReportFromMenu", root, report_number )

    return true
end

--Игрок не был найден на клиенте
function onServerPlayerNotExist_handler( report_number )
    REPORTS[ report_number ] = nil
    local target_users = {}
    for _, v in pairs( GetPlayersInGame() ) do
        if ( v:IsAdmin() ) then
            table.insert( target_users, v )
        end
    end
    triggerClientEvent( target_users, "onClientRemoveReportFromMenu", client, report_number )
end
addEvent("onServerPlayerNotExist", true )
addEventHandler( "onServerPlayerNotExist", root, onServerPlayerNotExist_handler )

-- Обработчик выхода игроков
function ReportGmLeave_Handler( )
    local player = source
    if player:IsAdmin() then
        local uid = player:GetUserID()
        for i, v in pairs( REPORTS ) do
            if v[ CURRENT_HELPER ] == uid then
                ReportCancel( i, ERR_GM_OFFLINE )
            end
        end
    end
    if PLAYERS_REPORTS[ player ] then
        local report_number = PLAYERS_REPORTS[ player ]
        if report_number then 
            ReportCancel( report_number, ERR_PLAYER_OFFLINE )
        end
    end
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, ReportGmLeave_Handler )