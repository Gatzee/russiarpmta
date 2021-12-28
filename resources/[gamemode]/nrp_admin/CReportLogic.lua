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

REPORTS = {} 

function onClientOpenReportMenu_handler( reports )
    REPORTS = reports
    OpenReportsWindow()
end
addEvent( "onClientOpenReportMenu", true )
addEventHandler( "onClientOpenReportMenu", root, onClientOpenReportMenu_handler )

--Приёма с сервера результата о сбросе
addEvent( "onClientResetReportCounter", true )
addEventHandler( "onClientResetReportCounter", root, function( result )
    if result then
        SetInfoLabelText( "Счетчик репортов успешно сброшен", 0, 255, 0 )
    else
        SetInfoLabelText( "При сбросе произошла ошибка, обратитесь к администрации.", 255, 0, 0 )
    end
end )


function RefreshReports()
    tryTriggerServerEvent( "onServerRefreshReportMenu", localPlayer )
end

--Обновление данных о репортах
addEvent( "onClientRefreshReportMenu", true )
addEventHandler( "onClientRefreshReportMenu", root, function( reports )
    
    for k, v in pairs( reports ) do
        if isElement( ui.main ) then
            RefreshGridList( k, v )
        end
        REPORTS[ k ] = v
    end

end )

--Добавление репорта в список
addEvent( "onClientAddReportInMenu", true )
addEventHandler( "onClientAddReportInMenu", root, function( report_id, report )
    if isElement( ui.main ) then
        AddRowToGirdList( report_id, report )
    end
    table.insert( REPORTS, report_id, report )
end )

--Удаление репорта из списка
addEvent( "onClientRemoveReportFromMenu", true )
addEventHandler( "onClientRemoveReportFromMenu", root, function( report_id )
    if isElement( ui.main ) then
        RemoveRowFromGridList( report_id )
    end
    table.remove( REPORTS, report_id )
end )

--Вывод информативного текста
addEvent( "onClientSetInfoLabelText", true )
addEventHandler( "onClientSetInfoLabelText", root, function( text, r, g, b )
    if isElement( ui.main ) then
        SetInfoLabelText( text, r, g, b )
    end
end )

function SendAnswerToUser( answer, report_id, report )
    
    local report_number = tonumber( report_id )
    if not report_number then
        SetInfoLabelText( "Не найден номер заявки, обновите меню", 255, 0, 0 )
        return
    end

    local report = REPORTS[ report_number ]
    if not report then
        SetInfoLabelText( "Заявки #" .. report_number .. " не существует, обновите меню", 255, 0, 0 )
        return
    end

    local source = report[ SOURCE_PLAYER ]
    if not isElement( source ) then
        SetInfoLabelText( "Игрок по данной заявке вышел с сервера", 255, 0, 0 )
        tryTriggerServerEvent( "onServerPlayerNotExist", localPlayer, report_number )
        return
    end
    
    if report[ CURRENT_HELPER ] and report[ CURRENT_HELPER ] ~= localPlayer:GetUserID() then
        SetInfoLabelText( "Данная заявка уже рассматривается", 255, 0, 0 )
        return
    end

    tryTriggerServerEvent( "onServerAdminTalkToUser", localPlayer, localPlayer, report_number, answer )

end

function CloseUserReport( reason, report_id, report )
    
    local report_number = tonumber( report_id )
    if not report_number then
        SetInfoLabelText( "Не найден номер заявки, обновите меню", 255, 0, 0 )
        return
    end

    local report = REPORTS[ report_number ]
    if not report then
        SetInfoLabelText( "Заявки #" .. report_number .. " не существует, обновите меню", 255, 0, 0 )
        return
    end

    if report[ CURRENT_HELPER ] and report[ CURRENT_HELPER ] ~= localPlayer:GetUserID() then
        SetInfoLabelText( "Данная заявка уже рассматривается", 255, 0, 0 )
        return
    end

    local reason_tbl = { reason }
    local reason_str = table.concat( reason_tbl, " " )
    if utf8.len( reason_str:gsub( " ", "" ) or "" ) <= 0 then
        SetInfoLabelText( "Вы не указали причину закрытия заявки!", 255, 0, 0 )
        return
    end
    SetInfoLabelText( "Вы закрыли заявку #" .. report_number .." по причине: " .. reason_str, 0, 255, 0 )
    tryTriggerServerEvent( "onServerAdminCloseReport", localPlayer, report_number, localPlayer, reason )

end