loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShWedding" )
Extend( "ShClans" )

CONVERT_CASH_TO_RATING = 5000

AVAILABLE_LIKE = 3
AVAILABLE_DISLIKE = 3

AVAILABLE_RATING_DONATE = 20

function getPlayerFromNickName( nickName )
    nickName = utf8.upper( nickName )

    for _, player in pairs( GetPlayersInGame( ) ) do
        if utf8.upper( player:GetNickName( ) ) == nickName then
            return player
        end
    end

    return false
end

function getUserIDFromNickName( nickName )
    local player = getPlayerFromNickName( nickName )

    if player then
        return player:GetUserID( )
    end

    return false
end

function table.removevalue( t, val )
    for i, v in ipairs( t ) do
        if v == val then
            table.remove( t, i )
            return i
        end
    end

    return false
end