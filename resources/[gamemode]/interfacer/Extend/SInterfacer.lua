-- SInterfacer

Import( "ShAsync" )
Import( "SElement" )

LOGSERVER = "185.97.255.19:12201/gelf"

function MariaGet( ... )
    return exports.nrp_mariadb:MariaGet( ... )
end

function WriteLog( ... )
    triggerEvent( "onLogWriteRequest", resourceRoot, ... )
end

function SendToLogserver( ... )
    triggerEvent( "SendToLogserver", resourceRoot, ... )
end

function SendToElastic( ... )
    triggerEvent( "SendToElastic", resourceRoot, ... )
end

function SendElasticGameEvent( ... )
    triggerEvent( "SendElasticGameEvent", resourceRoot, ... )
end

function WriteLogGet( ... )
    return exports.interfacer:WriteLog( ... )
end

function DiscordAlert(...)
    triggerEvent( "onDiscordAlertRequest", resourceRoot, ... )
end

function SlackAlert( ... )
    triggerEvent( "onSlackAlertRequest", resourceRoot, ... )
end

function SendAdminActionToLogserver( message, data, ... )
    local elements = { ... }

    local data = data or { }
    for i, v in pairs( elements ) do
        local element, prefix = unpack( v )

        local element_type = getElementType( element )

        if element_type == "player" then
            data[ prefix .. "_name" ]     = element:GetNickName( )
            data[ prefix .. "_id" ]       = element:GetID( )
            data[ prefix .. "_clientid" ] = element:GetClientID( )
            data[ prefix .. "_serial" ]   = getPlayerSerial( element )
            data[ prefix .. "_access_level" ] = element:GetAccessLevel( ) or 0

        elseif element_type == "vehicle" then
            data[ prefix .. "_name" ]     = GetVehicleNameFromModel( element.model ) or element.model
            data[ prefix .. "_model" ]    = element.model
            data[ prefix .. "_id" ]       = element:GetID( )
            data[ prefix .. "_serial" ]   = getPlayerSerial( element )

        end
    end

    data.logtype = "admin_action"

    SendToLogserver( message, data )
end