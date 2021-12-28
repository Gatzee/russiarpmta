-- Запрет биндов в полях ввода
guiSetInputMode( "no_binds_when_editing" )

local LOG_URL = nil

function StartLoggingClientErrors( url )
    LOG_URL = url
    --addEventHandler( "onClientDebugMessage", root, LogClientsideErrors )
end

DEBUG_LEVELS = {
	[ 1 ] = 3,
	[ 2 ] = 4,
}
LOG_QUEUE_NUM = 0

local function SendLogs( data )
    local data_json = toJSON( data, true ):sub( 2, -2 )

    LOG_QUEUE_NUM = LOG_QUEUE_NUM + 1

    local options = {
        queueName = "log_" .. LOG_QUEUE_NUM,
        connectionAttempts = 10,
        connectTimeout = 15000,
        postData = data_json,
        method = "POST",
        headers = {
            [ "Content-type" ] = "application/json",
        }
    }

    fetchRemote( LOG_URL, options, function( data, err ) end )
end

function SendToLogserver( message, data )
	local data = data or { }

	data.short_message = message
	data.version       = 1.2
	data.environment   = "client"
	data.host          = "127.0.0.1"

	SendLogs( data )
end
addEvent( "SendToLogserver" )
addEventHandler( "SendToLogserver", root, SendToLogserver )

function LogClientsideErrors( message, level, file, line )
    if not DEBUG_LEVELS[ level ] then return end
    local server = ( localPlayer:getData( "_srv" ) or { } )[ 1 ]
    
    local file = file:gsub( "\\", "/" )
    local path = split( file, "/" )
    local file_short = path[ #path ]

    -- Пошли на хуй со своей видеопамятью в 100кб
    if file_short ~= "ibRenderTarget.lua" then
        SendToLogserver( message, { message = message, level = DEBUG_LEVELS[ level ], file = file, line = line, file_short = file_short, server = server } )
    end
end

addEventHandler( "onClientVehicleStartEnter", root, function( player )
	if player == localPlayer and localPlayer.dimension ~= source.dimension then
		cancelEvent( )
	end
end )

shutdown( )