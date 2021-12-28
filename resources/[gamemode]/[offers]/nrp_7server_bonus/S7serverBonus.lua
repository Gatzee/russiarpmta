loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

BONUS_INFO = {
    start = 0, --1561064400, -- пятница, 21 июня 2019 г., 0:00:00 GMT+03:00
    finish = 1561064400 + 7 * 24 * 60 * 60, -- +7 дней с начала
    target_level = 6,
    active = false,
}

SERVERS = {
    [ 7 ] = true,
    [ 101 ] = true,
}

function OnPlayerLevelUp_handler( level, player )
    if BONUS_INFO.active then
        local player = isElement( player ) and player or source

        local timestamp = getRealTime( ).timestamp
        if timestamp >= BONUS_INFO.start and timestamp <= BONUS_INFO.finish then
            if level >= BONUS_INFO.target_level then
                if not player:GetPermanentData( "7s_bonus_got" ) then
                    player:GiveMoney( 250000, "7SERVER_BONUS" )
                    triggerClientEvent( player, "Show7SRewardUI", resourceRoot )
                    player:SetPermanentData( "7s_bonus_got", true )
                end
            end
        end
    end
end
addEvent( "OnPlayerLevelUp" )

function onResourceStart_handler( )
    --iprint( "Server number", SERVER_NUMBER )
    if SERVERS[ SERVER_NUMBER ] then
        BONUS_INFO.active = true
        addEventHandler( "OnPlayerLevelUp", root, OnPlayerLevelUp_handler )

        setTimer( function( )
            for i, v in pairs( getElementsByType( "player" ) ) do
                onPlayerCompleteLogin_handler( v )
            end
        end, 1000, 1 )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onPlayerCompleteLogin_handler( player )
    if BONUS_INFO.active then
        local player = isElement( player ) and player or source

        local timestamp = getRealTime( ).timestamp
        if timestamp >= BONUS_INFO.start and timestamp <= BONUS_INFO.finish then
            local level = player:GetLevel( )
            if not player:GetPermanentData( "7s_bonus_got" ) then
                if level < BONUS_INFO.target_level then
                    triggerClientEvent( player, "Show7SBonusUI", resourceRoot )
                else
                    OnPlayerLevelUp_handler( level, player )
                end
            end
        end
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )