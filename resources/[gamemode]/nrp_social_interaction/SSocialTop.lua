local topPlayers = {
    goodPlayers = { },
    badPlayers = { },
}

function getTopPlayers( )
    return topPlayers
end

function updateTops( )
    local function callback( query, arrayName )
        if not query then return end

        local data = dbPoll( query, 0 )
        dbFree( query )

        if type( data ) ~= "table" then return end

        topPlayers[arrayName] = data
    end

    DB:queryAsync( callback, { "goodPlayers" }, "SELECT id, nickname, social_rating FROM nrp_players WHERE accesslevel < ? ORDER BY social_rating DESC LIMIT 20", ACCESS_LEVEL_ADMIN )
    DB:queryAsync( callback, { "badPlayers" },  "SELECT id, nickname, social_rating FROM nrp_players WHERE accesslevel < ? ORDER BY social_rating LIMIT 20", ACCESS_LEVEL_ADMIN )
end

updateTops( )
setTimer( updateTops, 1000 * 60 * 5, 0 ) -- every 5 min