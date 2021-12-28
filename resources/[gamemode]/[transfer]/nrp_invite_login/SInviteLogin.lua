loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )

local IS_PLAYER_WAITING_RESPONSE = { }
local IS_PLAYER_WAITING_COOLDOWN = { }
local COOLDOWN = 15 * 1000

addEvent( "CheckInviteCode", true )
addEventHandler( "CheckInviteCode", resourceRoot, function( invite_code )
    if not invite_code or type( invite_code ) ~= "string" or #invite_code > 50 then return end
    local player = client

    if IS_PLAYER_WAITING_RESPONSE[ player ] then return end

    if IS_PLAYER_WAITING_COOLDOWN[ player ] then 
        triggerClientEvent( player, "CheckInviteCode_callback", resourceRoot, false, "Не так часто" )
        return
    end
    IS_PLAYER_WAITING_COOLDOWN[ player ] = setTimer( function( ) IS_PLAYER_WAITING_COOLDOWN[ player ] = nil end, COOLDOWN, 1 )

    if invite_code:match( "%d+%-%d%d[%dA-Z]+" ) then
        CheckUserInviteCode( player, invite_code )
    else
        CheckApiInviteCode( player, invite_code )
    end

    IS_PLAYER_WAITING_RESPONSE[ player ] = true
end )

function CheckUserInviteCode( player, invite_code )
    DB:queryAsync( function( query )
        local result, num_affected_rows = query:poll( -1 )
        IS_PLAYER_WAITING_RESPONSE[ player ] = nil
        if not isElement( player ) then return end

        local succes, msg = false
        if not result then
            msg = "Неизвестная ошибка, попробуйте ещё раз"
        elseif num_affected_rows > 0 then
            player:setData( "is_invite_checked", true, false )
            succes = true
        end
        triggerClientEvent( player, "CheckInviteCode_callback", resourceRoot, succes, msg )
        triggerEvent( "onPlayerInviteCodeUse", player, invite_code )
    end, { }, "UPDATE nrp_user_invite_codes SET is_activated = 1 WHERE ckey = ? AND is_activated = 0", invite_code )
end

function CheckApiInviteCode( player, invite_code )
    local options = {
        queueName = "invitation",
        connectionAttempts = 5,
        connectTimeout = 15000,
        postData = utf8.sub( toJSON( {
            client_id = player:GetClientID( ),
            server_id = SERVER_NUMBER,
            invite_code = invite_code,
        }, true ), 2, -2 ),
        method = "POST",
        headers = {
            ['Content-Type'] = "application/json",
        },
    }
    fetchRemote( "https://webclient.gamecluster.nextrp.ru/invitation", options, function( result, info )
        IS_PLAYER_WAITING_RESPONSE[ player ] = nil
        if not isElement( player ) then return end

        local succes, msg = false
        if info.statusCode == 200 then
            player:setData( "is_invite_checked", true, false )
            succes = true
        elseif not info.statusCode or info.statusCode >= 500 then
            msg = "Неизвестная ошибка, попробуйте ещё раз"
        end
        triggerClientEvent( player, "CheckInviteCode_callback", resourceRoot, succes, msg )
    end )
end

addEvent( "onPlayerAcceptRules", true )
addEventHandler( "onPlayerAcceptRules", resourceRoot, function( )
    local player = client
    if not player:getData( "is_invite_checked" ) then return end
    triggerEvent( "onPlayerStartRegisterRequest", player )
end )