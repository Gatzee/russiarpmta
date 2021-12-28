loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

BONUS_INFO = {
    start = 0, --1558645200, -- пятница, 24 мая 2019 г., 0:00:00 GMT+03:00
    finish = 1558645200 + 7 * 24 * 60 * 60, -- +7 дней с начала
    target_playtime = 10 * 60 * 60,
    active = false,
}

SERVERS = {
    [ 6 ] = true,
    [ 101 ] = true,
}

CONST_TIME_TO_LEFT_REWARD = 10 * 60

function onResourceStart_handler( )
    --iprint( "Server number", SERVER_NUMBER )
    if SERVERS[ SERVER_NUMBER ] then
        BONUS_INFO.active = true

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
            if not player:GetPermanentData( "6s_bonus_got" ) then
                if not player:GetPermanentData( "6s_bonus" )  then
                    player:SetPermanentData( "6s_bonus", true )
                    player:SetPermanentData( "6s_bonus_timer", 0 )
                    StartWaitingForBonus( player )
                else
                    StartWaitingForBonus( player )
                end
                triggerClientEvent( player, "Show6SBonusUI", resourceRoot )
            end
        end
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function StartWaitingForBonus( player )
    Timer( TimerHandler, 60000, 0, player )
end

function TimerHandler( player )
    if not isElement( player ) or not player:IsInGame( ) then
        killTimer( sourceTimer )
        return
    end

    times = player:GetPermanentData( "6s_bonus_timer" )
	if not times then
		killTimer( sourceTimer )
		return
	end

    times = times + 1
    player:SetPermanentData( "6s_bonus_timer", times )

    if times % 60 == 0 then
        local time_left = CONST_TIME_TO_LEFT_REWARD - times
        
        if time_left <= 0 then
            player:SetPermanentData( "6s_bonus_got", true )
            player:SetPermanentData( "6s_bonus", nil )
            player:SetPermanentData( "6s_bonus_timer", nil )

			killTimer( sourceTimer )

            player:GiveMoney( 250000, "6SERVER_BONUS" )
            triggerClientEvent( player, "Show6SRewardUI", resourceRoot )
			return
        end
        
        local hours = string.format( "%02d", math.floor( time_left / 60 ) )
		local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 ) ) )

        player:PhoneNotification( {
			title = "Награда";
			msg = "Ты получишь награду через ".. hours .." ч. ".. minutes .." м.";
		} )
    end
end