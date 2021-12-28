loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SPlayerCommon" )

SEGMENTS = { }

SEGMENTS_START_DATE = getTimestampFromString( "3 декабря 2020 00:00" )
SEGMENTS_END_DATE = getTimestampFromString( "5 декабря 2020 23:59" )
DEFAULT_DURATION = 48 * 60 * 60

function LoadCSV( )
    local file = fileOpen( "csv/list.csv" )
    if file then
        local contents = fileRead( file, fileGetSize( file ) )
        fileClose( file )

        local lines = split( contents, "\n" )

        for i, v in pairs( lines ) do
            -- Ignore first line as column header
			-- "client_id = segment" csv
			--local data = split( v, ";" )
			--SEGMENTS[ data[ 1 ] ] = tonumber( data[ 2 ] )

			-- general client_id csv list
			SEGMENTS[ v:gsub( "\r", "" ) ] = 1
        end
    end
end

function MarkMeTest( player, cmd, segment )
    if player:GetAccessLevel( ) < ACCESS_LEVEL_DEVELOPER then return end
    local client_id = player:GetClientID( )
    if SEGMENTS[ client_id ] then return end
    if not tonumber( segment ) then return end
    SEGMENTS[ client_id ] = tonumber( segment )
    outputChatBox( "Тестовый сегмент установлен для аккаунта: " .. segment, player, 0, 255, 0 )
end
addCommandHandler( "smd", MarkMeTest )

function onResourceStart_handler( )
    local ts = getRealTimestamp( )
    if ts <= SEGMENTS_START_DATE or ts >= SEGMENTS_END_DATE then return end

    LoadCSV( )
    
    setTimer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            onPlayerReadyToPlay_handler( v )
        end
    end, 2000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onPlayerReadyToPlay_handler( player )
	local player = isElement( player ) and player or source

    local ts = getRealTimestamp( )
    if ts <= SEGMENTS_START_DATE or ts >= SEGMENTS_END_DATE + DEFAULT_DURATION then return end

    local client_id = player:GetClientID( )
    local segment = SEGMENTS[ client_id ]
    if not segment then return end

    player:GetCommonData( { "oooo_fuck_11", "oooo_fuck_finish_11" }, { player, segment }, function( result, player, segment )
        if not isElement( player ) then return end

        local ts = getRealTimestamp( )

        if not result.oooo_fuck_11 then
            if ts >= SEGMENTS_END_DATE then return end

            player:SetCommonData( { oooo_fuck_11 = segment, oooo_fuck_finish_11 = ts + DEFAULT_DURATION } )
            StartOffer( player, segment, DEFAULT_DURATION, true )

            SendElasticGameEvent( client_id, "retargeting_offer_enter", {
                user_segment = segment,
            } )
        else
            local finish = tonumber( result.oooo_fuck_finish_11 )
            local left = finish - ts

            if left > 0 then StartOffer( player, segment, left ) end
        end
    end )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function StartOffer( player, segment, time_left, first_time )
    local segments = {
        -- Offer X2
        [ 1 ] = 1,
        [ 2 ] = 1,
        [ 3 ] = 1,
        [ 4 ] = 1,
        -- Offer x3
        --[ 3 ] = 2,
        --[ 4 ] = 2,
    }
    player:setData( "retargeting_offer_segment", segment, false )
    triggerClientEvent( player, "onClientPlayerStartOffer", resourceRoot, segments[ segment ], time_left, first_time )
end

-- Покупка х2/х3
function onPlayerPackPurchase_handler( client_id, pack_id, sum, transaction_id )
    local player = GetPlayerFromClientID( client_id )
    if not player then return end

    local conversion = {
        [ 601 ] = "x2",
        [ 602 ] = "x3",
    }

    local segment = player:getData( "retargeting_offer_segment" )
    if conversion[ pack_id ] and segment then
        player:setData( "retargeting_offer_segment", false, false )
        player:SetCommonData( { oooo_fuck_finish_11 = -1 } )
        triggerClientEvent( "onClientPlayerResetOffer", resourceRoot )

        SendElasticGameEvent( client_id, "retargeting_offer_purchase", {
            offer_type   = conversion[ pack_id ],
            user_segment = segment,
            cost         = sum,
        } )
    end
end
addEvent( "onPlayerPackPurchase" )
addEventHandler( "onPlayerPackPurchase", root, onPlayerPackPurchase_handler, true, "high" )
