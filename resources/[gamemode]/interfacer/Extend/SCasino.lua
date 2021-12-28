function LobbyDestroy( lobby_id ) 
    return exports.nrp_casino_lobby:LobbyDestroy( lobby_id )
end

function LobbyGet( lobby_id, var )
    return exports.nrp_casino_lobby:LobbyGet( lobby_id, var )
end

function LobbySet( lobby_id, var, value )
    return exports.nrp_casino_lobby:LobbySet( lobby_id, var, value )
end

function LobbyCall( lobby_id, fn, ... )
    return exports.nrp_casino_lobby:LobbyCall( lobby_id, fn, ... )
end

function LobbyGetAll( lobby_id )
    return exports.nrp_casino_lobby:LobbyGetAll( lobby_id )
end

function GetPlayerLobbyID( player )
    return exports.nrp_casino_lobby:GetPlayerLobbyID( player )
end
