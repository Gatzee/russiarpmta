loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )

local UI
local LOG = { }

function SetAnalyticsTestUI( state )
    if state then
        SetAnalyticsTestUI( false )

        if UI then
            UI.window:setVisible( true )
        else
            UI = { }

            UI.window = guiCreateWindow( 50, 50, 800, 500, "Окно теста аналитики [Курсор - K]", false )

            UI.grid_eventlist = guiCreateGridList( 10, 30, 780, 400, false, UI.window )
            UI.grid_eventlist:addColumn( "#", 0.05 )
            UI.grid_eventlist:addColumn( "Название", 0.25 )
            UI.grid_eventlist:addColumn( "Активна проверка", 0.2 )
            UI.grid_eventlist:addColumn( "Текущий статус проверки", 0.2 )
            UI.grid_eventlist:addColumn( "Ошибки", 0.7 )

            local n = 0
            for event_name, params in pairs( EVENTS_PARAMS ) do
                n = n + 1

                guiGridListAddRow( UI.grid_eventlist, n, event_name, "Нет", "Не проверено", "-" )
            end

            UI.btn_set_state = guiCreateButton( 10, 440, 200, 40, "Вкл/выкл проверку", false, UI.window )
            addEventHandler( "onClientGUIClick", UI.btn_set_state, function( key, state )
                if key ~= "left" or state ~= "up" then return end
                local item = guiGridListGetSelectedItem( UI.grid_eventlist )
                if not item then return end

                local event_name = guiGridListGetItemText( UI.grid_eventlist, item, 2 )
                triggerServerEvent( "onClientDev2devChangeStateRequest", resourceRoot, event_name )

                SetTracingState( event_name, not GetTracingState( event_name ) )
            end, false )

            UI.btn_check_error = guiCreateButton( 220, 440, 200, 40, "Просмотреть текущие ошибки", false, UI.window )
            addEventHandler( "onClientGUIClick", UI.btn_check_error, function( key, state )
                if key ~= "left" or state ~= "up" then return end
                local item = guiGridListGetSelectedItem( UI.grid_eventlist )
                if not item then return end

                local event_name = guiGridListGetItemText( UI.grid_eventlist, item, 2 )
                local event_err = guiGridListGetItemText( UI.grid_eventlist, item, 5 )
                local err_list = table.concat( split( event_err, ";" ), "\n" )

                local osx, osy = 600, 480

                local px, py = guiGetPosition( UI.window, false )
                local sx, sy = guiGetSize( UI.window, false )
                local err_window = guiCreateWindow( px + sx / 2 - osx / 2, py + sy / 2 - osy / 2, osx, osy, "[СКМ ЧТОБЫ ЗАКРЫТЬ] Событие: " .. event_name, false )

                local memo = guiCreateMemo( 0, 0.1, 1, 0.9, err_list, true, err_window )

                addEventHandler( "onClientGUIClick", memo, function( key, state )
                    if key ~= "middle" or state ~= "up" then return end
                    destroyElement( err_window )
                end, true )
            end, false )

            UI.btn_full_log = guiCreateButton( 430, 440, 200, 40, "Полный лог всех событий", false, UI.window )
            addEventHandler( "onClientGUIClick", UI.btn_full_log, function( key, state )
                if key ~= "left" or state ~= "up" then return end

                local px, py = guiGetPosition( UI.window, false )
                local sx, sy = guiGetSize( UI.window, false )
                local log_window = guiCreateWindow( px, py, sx, sy, "[СКМ ЧТОБЫ ЗАКРЫТЬ] Лог всех событий", false )

                local memo = guiCreateMemo( 0, 0.05, 1, 0.95, "", true, log_window )
                local function UpdateMemo( )
                    guiSetText( memo, table.concat( LOG, "\n\n--------------------------\n\n" ) )
                end

                addEventHandler( "onClientGUISize", log_window, function ( )
                    guiSetSize( memo, 1, 1, true )
                end, false )
                
                addEventHandler( "onDev2devLogUpdated", memo, function( )
                    UpdateMemo( )
                end )

                addEventHandler( "onClientGUIClick", memo, function( key, state )
                    if key ~= "middle" or state ~= "up" then return end
                    destroyElement( log_window )
                end, true )

                UpdateMemo( )
            end, false )
        end
    else
        if UI then
            UI.window:setVisible( false )
        end
    end
end

function ShowAnalayticsPanel( )
    if not localPlayer:getData( "is_acl_admin_permissions" ) then return end

    if UI and UI.window.visible then
        SetAnalyticsTestUI( false )
    else
        SetAnalyticsTestUI( true )
        triggerServerEvent( "onDev2devRequestState", resourceRoot )
    end
end

function ToggleCursor( )
    if not localPlayer:getData( "is_acl_admin_permissions" ) then return end

    if not UI then return end
    outputChatBox( "[dev2dev Test] Курсор включен: " .. tostring( not isCursorShowing( ) ), 255, 255, 255, true )
    showCursor( not isCursorShowing( ) )
end

addEventHandler( "onClientKey", root, function( key, pressed )
    if not pressed then return end
    if guiGetInputEnabled() then return end

    if key == "i" then
        ShowAnalayticsPanel( )
    elseif key == "k" then
        ToggleCursor( )
    end
end )

function GetItemIDByEventName( event_name )
    if not UI then return end
    local item
    for i = 0, guiGridListGetRowCount( UI.grid_eventlist ) - 1 do
        if guiGridListGetItemText( UI.grid_eventlist, i, 2 ) == event_name then
            item = i
            break
        end
    end
    return item
end

function onDev2devRequestStateCallback_handler( events_data )
    if not UI then return end
    
    for event_name, state in pairs( events_data ) do
        onClientDev2devChangeStateRequestCallback_handler( event_name, state )
    end
end
addEvent( "onDev2devRequestStateCallback", true )
addEventHandler( "onDev2devRequestStateCallback", root, onDev2devRequestStateCallback_handler )

function onClientDev2devChangeStateRequestCallback_handler( event_name, state )
    if not UI then return end

    local item = GetItemIDByEventName( event_name )

    if item then
        guiGridListSetItemText( UI.grid_eventlist, item, 3, state and "Да" or "Нет", false, false )

        local r, g, b = 255, 255, 255
        if state then
            r, g, b = 0, 255, 0
        end

        guiGridListSetItemColor( UI.grid_eventlist, item, 3, r, g, b )
    end
end
addEvent( "onClientDev2devChangeStateRequestCallback", true )
addEventHandler( "onClientDev2devChangeStateRequestCallback", root, onClientDev2devChangeStateRequestCallback_handler )

function onClientDev2devTraceEvent_handler( client_id, name, params, success, err )
    local item = GetItemIDByEventName( name )

    if item then
        guiGridListSetItemText( UI.grid_eventlist, item, 4, success and "Корректно" or "FAIL", false, false )
        guiGridListSetItemText( UI.grid_eventlist, item, 5, #err > 0 and table.concat( err, ";" ) or "-", false, false )

        local r, g, b = 255, 0, 0
        if success then
            r, g, b = 0, 255, 0
        end

        guiGridListSetItemColor( UI.grid_eventlist, item, 4, r, g, b )

        local default_params = params
        local event_params = { }

        for k, v in pairs( EVENTS_PARAMS[ name ] or { } ) do
            event_params[ k ] = params[ k ]
            params[ k ] = nil
        end

        local text = {
            "СОБЫТИЕ: " .. name,
            "client_id: " .. tostring( client_id ),
            "ПАРАМЕТРЫ: " .. inspect( default_params ):sub( 1, -3 ) .. ", \n\n" .. inspect( event_params ):sub ( 3 ),
            "УСПЕХ: " .. ( success and "Да" or "Нет" ),
            "ОШИБКИ: " .. ( #err > 0 and table.concat( err, "\n" ) or "-" ),
        }

        table.insert( LOG, 1, table.concat( text, "\n" ) )

        if #LOG > 500 then
            table.remove( LOG, 1 )
        end

        triggerEvent( "onDev2devLogUpdated", root )
    end
end
addEvent( "onClientDev2devTraceEvent", true )
addEventHandler( "onClientDev2devTraceEvent", root, onClientDev2devTraceEvent_handler )

addEvent( "onDev2devLogUpdated", true )