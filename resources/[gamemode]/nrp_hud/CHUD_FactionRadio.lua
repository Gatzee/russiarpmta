local CUSTOM_CHANNEL_NAMES = {}

HUD_CONFIGS.factionradio = {
    elements = { },
    use_real_fonts = true,
    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 50, "img/bg_faction_radio.png", bg )
        self.elements.bg = bg

        self.elements.lbl_channel = ibCreateLabel( 104, 25, 0, 0, "", bg, _, _, _, "left", "center", ibFonts.regular_14 )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function FACTIONRADIO_onElementDataChange( key )
    if key == "faction_id" or key == "_voicech" or key == "factions_day_off" then
        if ( localPlayer:IsInFaction( ) or next( CUSTOM_CHANNEL_NAMES ) )
        and not localPlayer:getData( "in_race" ) and not localPlayer:IsOnFactionDayOff( ) then
            AddHUDBlock( "factionradio" )
            RefreshRadioChannel( )
        else
            RemoveHUDBlock( "factionradio" )
        end
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, FACTIONRADIO_onElementDataChange )

function RefreshRadioChannel( )
    local id = "factionradio"
    local self = HUD_CONFIGS[ id ]

    local channel = localPlayer:GetFactionVoiceChannel( )
    local channel_name = channel and FACTIONS_SHORT_NAMES[ channel ] or CUSTOM_CHANNEL_NAMES[ channel ] or "Выкл."
    
    self.elements.lbl_channel:ibData( "alpha", 0 )
    self.elements.lbl_channel:ibData( "text", channel_name )
    self.elements.lbl_channel:ibAlphaTo( 255, 200 )
end
addEvent( "onClientRefreshRadioChannel", true )
addEventHandler( "onClientRefreshRadioChannel", root, RefreshRadioChannel )

function FACTIONRADIO_onStart( )
    if localPlayer:IsInGame( ) and (localPlayer:IsInFaction( ) or next( CUSTOM_CHANNEL_NAMES ) ) then
        AddHUDBlock( "factionradio" )
        RefreshRadioChannel( )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, FACTIONRADIO_onStart )

function FACTIONRADIO_onClientPlayerNRPSpawn_handler( spawn_mode )
    if spawn_mode == 3 then return end
    FACTIONRADIO_onStart( )
end
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, FACTIONRADIO_onClientPlayerNRPSpawn_handler )


function onClientRestoreRadioChannel_handler()
    FACTIONRADIO_onStart( )
end
addEvent( "onClientRestoreRadioChannel", true )
addEventHandler( "onClientRestoreRadioChannel", root, onClientRestoreRadioChannel_handler )


function onClientAddStationChannel_handler( station_data )
    CUSTOM_CHANNEL_NAMES[ station_data.station_id ] = station_data.channel_name
    FACTIONRADIO_onStart( )
end
addEvent( "onClientAddStationChannel", true )
addEventHandler( "onClientAddStationChannel", root, onClientAddStationChannel_handler )

function onClientRemoveStationChannel_handler( station_data )
    CUSTOM_CHANNEL_NAMES[ station_data.station_id ] = nil
    if not next( CUSTOM_CHANNEL_NAMES ) and not localPlayer:IsInFaction() then
        RemoveHUDBlock( "factionradio" )
    end
end
addEvent( "onClientRemoveStationChannel", true )
addEventHandler( "onClientRemoveStationChannel", root, onClientRemoveStationChannel_handler )


function onClientChangePriorityRadio_handler( priority )
    if not isElement( HUD_CONFIGS.factionradio.elements.bg ) or not tonumber( priority ) then return end
    HUD_CONFIGS.factionradio.elements.bg:ibData( "priority", priority )
end
addEvent( "onClientChangePriorityRadio" )
addEventHandler( "onClientChangePriorityRadio", root, onClientChangePriorityRadio_handler )