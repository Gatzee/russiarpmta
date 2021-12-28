loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShAsync" )

local RADIO_CHANNELS = {}
for k, v in ipairs( FACTIONS_NAMES ) do
    table.insert( RADIO_CHANNELS, { channel = k } )
end

function onRecieveFactionVoice_handler( channel )
    if isElement( source ) then
        source:SetFactionVoiceChannel( channel )
    end
end
addEvent( "onRecieveFactionVoice", true )
addEventHandler( "onRecieveFactionVoice", root, onRecieveFactionVoice_handler )

function onBatchRecieveFactionVoice_handler( list )
    for v, n in pairs( list ) do
        v:SetFactionVoiceChannel( n )
    end
end
addEvent( "onBatchRecieveFactionVoice", true )
addEventHandler( "onBatchRecieveFactionVoice", root, onBatchRecieveFactionVoice_handler )

function chgChannel( _, _, state )
    local current_channel = GetTargetChannel( state )
    triggerServerEvent( "onSetFactionVoiceChannel", resourceRoot, current_channel == 0 and current_channel or RADIO_CHANNELS[ current_channel ].channel )
end
bindKey( "[", "down", chgChannel, -1 )
bindKey( "]", "down", chgChannel, 1 )

function GetIndexFromCurrentChannel()
    local current_channel = localPlayer:GetFactionVoiceChannel( ) or 0

    for k, v in ipairs( RADIO_CHANNELS ) do
        if v.channel == current_channel then
            return k
        end
    end

    return 0
end

function GetTargetChannel( state, current_channel )
    current_channel = current_channel or GetIndexFromCurrentChannel( )
    
    local old_channel = current_channel
    local new_channel = current_channel + state
    current_channel = new_channel > #RADIO_CHANNELS and 0 or new_channel < 0 and #RADIO_CHANNELS or new_channel

    if FACTIONS_NAMES[ current_channel ] and ( not localPlayer:IsInFaction( ) or localPlayer:IsOnFactionDayOff( ) ) then
        return GetTargetChannel( state, current_channel )
    end

    return current_channel
end

function onClientAddStationChannel_handler( station_data )
    onClientRemoveStationChannel_handler( station_data )
    table.insert( RADIO_CHANNELS, { channel = station_data.station_id } )
end
addEvent( "onClientAddStationChannel", true )
addEventHandler( "onClientAddStationChannel", root, onClientAddStationChannel_handler )

function onClientRemoveStationChannel_handler( station_data )
    for v, n in pairs( RADIO_CHANNELS ) do
        if n.channel == station_data.station_id then
            table.remove( RADIO_CHANNELS, v )
            break
        end
    end
end
addEvent( "onClientRemoveStationChannel", true )
addEventHandler( "onClientRemoveStationChannel", root, onClientRemoveStationChannel_handler )