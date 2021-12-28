loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

function onFactionVoiceChannelChange_handler( new )
    triggerClientEvent( source, "onRecieveFactionVoice", source, new )

    local src_voice_channel = source:GetFactionVoiceChannel( )
    Async:foreach( getElementsByType( "player" ), function( v )
        if isElement( source ) and isElement( v ) and v ~= source and
        ( v:IsInFaction( ) or v:HasVoiceStation( src_voice_channel ) ) then
            triggerClientEvent( v, "onRecieveFactionVoice", source, new )
        end
    end )
end
addEvent( "onFactionVoiceChannelChange", true )
addEventHandler( "onFactionVoiceChannelChange", root, onFactionVoiceChannelChange_handler )

function onSetFactionVoiceChannel_request( num )
    if num == 0 then num = false end
    client:SetFactionVoiceChannel( num )
end
addEvent( "onSetFactionVoiceChannel", true )
addEventHandler( "onSetFactionVoiceChannel", root, onSetFactionVoiceChannel_request )

function onPlayerFactionChange_handler( player, ignore_team_reset )
    local player = isElement( player ) and player or source
    player:SetFactionVoiceChannel( false )
end
addEvent( "onPlayerFactionChange", true )
addEventHandler( "onPlayerFactionChange", root, onPlayerFactionChange_handler )

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source
    if player:IsInFaction() then
        local players_info = { }
        for i, v in pairs( getElementsByType( "player" ) ) do
            local channel = v:GetFactionVoiceChannel()
            if channel then
                players_info[ v ] = channel
            end
        end
        if next( players_info ) then
            triggerClientEvent( player, "onBatchRecieveFactionVoice", resourceRoot, players_info )
        end
    end
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function onResourceStart_handler()
    Async:foreach( getElementsByType( "player" ), function( v )
        onPlayerReadyToPlay_handler( v )
    end )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )