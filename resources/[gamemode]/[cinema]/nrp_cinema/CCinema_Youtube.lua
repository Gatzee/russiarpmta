-- REQUEST_SEARCH_URL = "https://yt-nextrp-scraper.herokuapp.com/search" -- "http://gallardo994.xyz:3000/search"

FUCK_YOUTUBE_URLS = {
    -- Основные
    "http://ytscraper.gamecluster.nextrp.ru/search",
    --"https://yt-nextrp-scraper.herokuapp.com/search",
    --"http://gallardo994.xyz:3002/search",
    --"http://devhost.nextrp.ru:3000/search",
    -- DL Сервера
    --"http://51.68.206.4:3000/search",
    --"http://51.77.133.217:3000/search",
    --"http://51.68.153.11:3000/search",
    --"http://51.68.153.32:3000/search",
    --"http://54.36.126.137:3000/search",
    --"http://51.77.133.216:3000/search",
    --"http://51.77.133.209:3000/search",
    --"http://51.77.133.208:3000/search",
    --"http://54.36.177.97:3000/search",
    --"http://145.239.68.24:3000/search",
    --"http://51.68.153.26:3000/search",
    --"http://51.68.153.34:3000/search",
}

PROXY_URL = "http://ytscraper.gamecluster.nextrp.ru/proxy"
--PROXY_URL = "http://devhost.nextrp.ru:3000/proxy"

-- Шаффлим для разгрузки
--[[for i = 1, #FUCK_YOUTUBE_URLS do
    local num = math.random( 1, #FUCK_YOUTUBE_URLS )
    local url = FUCK_YOUTUBE_URLS[ math.random( 1, #FUCK_YOUTUBE_URLS ) ]
    table.remove( FUCK_YOUTUBE_URLS, num )
    table.insert( FUCK_YOUTUBE_URLS, url )
end]]

DEAD_URLS = { }
SERVER_REPEAT_TIME = 10

function GetYoutubeList( str, page, callback )
    local page = page or 1

    local parameters = {
        q = urlencode( str ),
        page = page,
    }

    -- Наёбываем ютуб
    local chosen_url
    for i = 1, #FUCK_YOUTUBE_URLS do
        local url = FUCK_YOUTUBE_URLS[ i ]
        if not DEAD_URLS[ url ] or getTickCount( ) - DEAD_URLS[ url ] >= SERVER_REPEAT_TIME * 1000 then
            chosen_url = url
            break
        end
    end

    if not chosen_url then
        chosen_url = FUCK_YOUTUBE_URLS[ math.random( 1, #FUCK_YOUTUBE_URLS ) ]
    end

    --iprint( "Requesting from: ", chosen_url )
    RequestGet( chosen_url, parameters, function( data, err )
        local tbl = fromJSON( data )

        if not tbl then
            --iprint( "ERR VIDEO LIST", chosen_url, err, data )
            localPlayer:ErrorWindow( "Ошибка, код " .. tostring( err.statusCode ) .. ", попробуйте повторить поиск" )
            DEAD_URLS[ chosen_url ] = getTickCount( )
            callback( { } )
            return
        end

        if tbl and tbl.results and #tbl.results == 0 then
            DEAD_URLS[ chosen_url ] = getTickCount( )
        else
            DEAD_URLS[ chosen_url ] = nil
        end

        local info = { }
        for i, v in pairs( tbl and tbl.results ) do
            local video_info = ConvertVideoInfo( v )
            if video_info then
                table.insert( info, video_info )
            end
        end
        
        callback( info )
    end )
end

function ConvertVideoInfo( video_table )
    local video = video_table.video
    local uploader = video_table.uploader
    if video and uploader then
        local info = {
            title            = video.title,
            url              = video.url,
            duration         = video.duration,
            duration_seconds = ConvertDuration( video.duration ),
            views            = tonumber( video.views ),
            uploader         = uploader.username,
        }
        return info
    end
end

function ConvertDuration( str )
    local seconds, n = 0, 0
    
    for i, v in ripairs( split( str, ":" ) ) do
        if tonumber( v ) then
            seconds = seconds + tonumber( v ) * ( 60 ^ n )
        end
        n = n + 1
    end

    return seconds
end

function RequestGet( url, parameters, callback, args )
    local url = URLAppendParameters( url, parameters )

    local options = {
        connectionAttempts = 5,
        connectTimeout = 15000,
        method = "GET",
    }

    fetchRemote( url, options, callback, args or { } )
end

function URLAppendParameters( url, parameters )
    local get_str = ""

    local n = 1
    for i, v in pairs( parameters ) do
        local i, v = tostring( i ), tostring( v )
        if n ~= 1 then
            get_str = get_str .. "&"
        else
            get_str = get_str .. "?"
        end
        get_str = get_str .. urlencode( i ) .. "=" .. urlencode( v )
        n = n + 1
    end

    return url .. get_str
end

local char_to_hex = function( c )
    return string.format( "%%%02X", utf8.byte( c ) )
end
function urlencode( url )
    if url == nil then return end
    url = url:gsub( "\n", "\r\n" )
    url = url:gsub( "([^%w ])", char_to_hex )
    url = url:gsub( " ", "+" )
    return url
end
local hex_to_char = function( x )
    return utf8.char( tonumber( x, 16 ) )
end
function urldecode( url )
    if url == nil then return end
    url = url:gsub( "+", " " )
    url = url:gsub( "%%(%x%x)", hex_to_char )
    return url
end
