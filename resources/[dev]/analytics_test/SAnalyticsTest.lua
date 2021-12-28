loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

function onDev2devTraceEvent_handler( client_id, name, params )
    local success, err = true, { }

    -- Базовая валидация

    local function Fail( condition, reason )
        if not condition then
            success = false
            if reason then
                table.insert( err, reason )
            end
        end
    end

    -- Проверка базовых значений
    Fail( EVENTS_PARAMS[ name ], "Отсутствие EVENTS_PARAMS значения в тесте" )
    Fail( EVENTS_PARAMS[ name ].client_id == "nil" or type( client_id ) == "string", "client_id обязан быть строкой: " .. type( client_id ) )
    Fail( type( name ) == "string", "Не указано название ивента: " .. type( name ) )
    Fail( type( params ) == "table", "Параметры ивента должны быть таблицей: " .. type( params ) )
    
    for i, v in pairs( EVENTS_PARAMS[ name ] or { } ) do
        local param_type = type( params[ i ] )
        Fail( param_type == v, "Параметр отличается от требуемого: " .. tostring( i ) .. " -> " .. tostring( param_type ) .. " (должен быть " .. tostring( v ) .. ")"  )
    end

    triggerClientEvent( root, "onClientDev2devTraceEvent", resourceRoot, client_id, name, params, success, err, params_list, params_types )
end
addEvent( "onDev2devTraceEvent", true )
addEventHandler( "onDev2devTraceEvent", root, onDev2devTraceEvent_handler )

function onDev2devRequestState_handler( )
    local events_data = GetAllEventsData( )
    triggerClientEvent( "onDev2devRequestStateCallback", resourceRoot, events_data )
end
addEvent( "onDev2devRequestState", true )
addEventHandler( "onDev2devRequestState", root, onDev2devRequestState_handler )

function GetAllEventsData( )
    local data = { }
    for i, v in pairs( EVENTS_PARAMS ) do
        data[ i ] = GetTracingState( i ) or nil
    end
    return data
end

function onClientDev2devChangeStateRequest_handler( event_name )
    local state = GetTracingState( event_name )
    SetTracingState( event_name, not state )

    triggerClientEvent( root, "onClientDev2devChangeStateRequestCallback", resourceRoot, event_name, not state )
end
addEvent( "onClientDev2devChangeStateRequest", true )
addEventHandler( "onClientDev2devChangeStateRequest", root, onClientDev2devChangeStateRequest_handler )

local function setDataAdm( player )
    local playerAccount = getPlayerAccount ( player )
    if isGuestAccount( playerAccount ) then return end

    local accName = getAccountName ( playerAccount )
    if isObjectInACLGroup( "user." .. accName, aclGetGroup ( "Admin" ) ) then
        player:SetPrivateData( "is_acl_admin_permissions", true )
    end
end

addEventHandler ( "onResourceStart", resourceRoot, function()
    local tPlayers = getElementsByType( "player" )

    for _, player in pairs( tPlayers ) do
        setDataAdm( player )
    end

end )

addEventHandler( "onPlayerLogin", root, function()
    setDataAdm( source )
end )

addEventHandler( "onPlayerLogout", root, function()
    source:SetPrivateData( "is_acl_admin_permissions", false )
end )