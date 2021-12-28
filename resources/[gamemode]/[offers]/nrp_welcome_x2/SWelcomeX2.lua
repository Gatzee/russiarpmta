loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

MARIADB_INCLUDE = { APIDB = true }
Extend( "SDB" )

Extend( "SPlayerCommon" )

OFFER_DURATION = 48 * 60 * 60

function GiveOffer( player, duration )
    player:SetCommonData( {
        X2_available = true,
        X2_bought = false,
        X2_start = getRealTimestamp( ) + ( duration or OFFER_DURATION ),
    } )
    triggerEvent( "onActivateX2Request", player, duration )
end

-- Доступ к офферу после завершения туториала
function onPlayerFinishTutorialGlobally_handler( )
    local player = client or source

    local client_id = player:GetClientID( )
    APIDB:queryAsync( function( query )
        if not isElement( player ) then
            dbFree( query )
            return
        end

        local result = query:poll( -1 )

        local list = result[ 1 ].servers or "[]"
        local amount = fromJSON( "[" .. list .. "]" )
        if not amount or not next( amount ) or amount[ 1 ] == SERVER_NUMBER then
            player:SetCommonData( { X2_available = true } )
        end
    end, { }, "SELECT servers FROM Users WHERE clientId=? LIMIT 1", client_id )
    --triggerEvent( "onPlayerOfferX2Available", player )
end
addEvent( "onPlayerFinishTutorialGlobally" )
addEventHandler( "onPlayerFinishTutorialGlobally", root, onPlayerFinishTutorialGlobally_handler )

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source
    if not player:HasFinishedTutorial( ) then return end

    player:GetCommonData( { "X2_available", "X2_bought" }, { player }, function( result, player )
        if not isElement( player ) then return end -- Игрок вышел за время запроса
        if not result.X2_bought and result.X2_available then
            triggerEvent( "onPlayerOfferX2Available", player )
        end
    end )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function onResourceStart_handler( )
    for i, v in pairs( getElementsByType( "player" ) ) do
        if v:IsInGame( ) then
            onPlayerCompleteLogin_handler( v )
        end
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onPlayerOfferX2Available_handler( group_name )
    local player = client or source

    -- Проверяем есть ли уже запущенный оффер
    player:GetCommonData( { "X2_start", "COMFORT_bought" }, { player }, function( result, player )
        if not isElement( player ) then return end -- Игрок вышел за время запроса

        -- Начинаем новый оффер если его не было
        if not result.X2_start then
            triggerEvent( "onActivateX2Request", player )
        else
            local passed = result.X2_start - getRealTime( ).timestamp
            if passed > 0 then
                triggerEvent( "onActivateX2Request", player, passed )
            elseif not result.COMFORT_bought then
                triggerEvent( "onX2WelcomeOfferComplete", player )
            end
        end
    end )
end
addEvent( "onPlayerOfferX2Available" )
addEventHandler( "onPlayerOfferX2Available", root, onPlayerOfferX2Available_handler )

function onActivateX2Request_handler( time_left )
    local player = client or source

    local prolonging_offer = type( time_left ) == "number"
    triggerClientEvent( player, "onStartX2Request", player, prolonging_offer and time_left or OFFER_DURATION, not prolonging_offer, "https://api.nextrp.ru/pay/pack" )

    if not prolonging_offer then
        player:SetCommonData( { X2_start = getRealTime( ).timestamp + OFFER_DURATION } )
        triggerEvent( "onX2ShowFirst", player )
    end
end
addEvent( "onActivateX2Request" )
addEventHandler( "onActivateX2Request", root, onActivateX2Request_handler )

-- Очистка оффера после покупки
function onX2Purchase_handler( cost )
    local player = client or source
    
    player:SetCommonData( { X2_bought = true } )
    setElementData( player, "X2_ready", false, false )
    triggerEvent( "onX2WelcomeOfferComplete", player )
    triggerClientEvent( player, "onParseX2Purchase", resourceRoot )
end
addEvent( "onX2Purchase", true )
addEventHandler( "onX2Purchase", root, onX2Purchase_handler )