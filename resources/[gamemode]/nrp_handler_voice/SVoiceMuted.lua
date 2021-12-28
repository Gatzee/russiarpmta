local PLAYERS_VOICE_MUTE = { }
local DELAY_MS = 5000

function CheckingPlayerVoiceMute( )
    local timestamp = getRealTimestamp( )
    
    for k, v in pairs( PLAYERS_VOICE_MUTE ) do
        if isElement( k ) and timestamp > v then
            k:SetUnMuteVoice( )
        end
    end
end

function OnPlayerUnMute( )
    PLAYERS_VOICE_MUTE[ source ] = nil
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, OnPlayerUnMute )

addEvent( "onPlayerUnMute" )
addEventHandler( "onPlayerUnMute", root, OnPlayerUnMute )

function onPlayerMute( end_time_mute )
    PLAYERS_VOICE_MUTE[ source ] = end_time_mute
end
addEvent( "onPlayerMute" )
addEventHandler( "onPlayerMute", root, onPlayerMute )

setTimer( CheckingPlayerVoiceMute, DELAY_MS, 0 )