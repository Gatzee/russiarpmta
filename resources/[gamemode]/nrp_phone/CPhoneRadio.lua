local scX, scY = guiGetScreenSize()
CURRENT_RADIO_STATE = false
CURRENT_RADIO_ID = 1
CURRENT_RADIO_SOUND = false
WAS_PLAY_RADIO = false

RADIOAPP = nil
APPLICATIONS.radio = {
    id = "radio",
    icon = "img/apps/radio.png",
    name = "Радио",
    elements = { },

    current_tab_id = 1,
    current_tab = nil,
    tabs = 
    {
        [ 1 ] = 
        {
            id = "radio",
            create = function( self, data )
                ibCreateButton(  0, 55, 204, 41, self.elements.new_tab_element, 
                    "img/elements/radio/btn_radio_list.png", "img/elements/radio/btn_radio_list_hover.png", "img/elements/radio/btn_radio_list_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self:SwitchTab( 2 )
                end )
                
                
                self.elements.radio_lbl = ibCreateLabel( 0, 131, 204, 0, VEHICLE_RADIO[ CURRENT_RADIO_ID or 1 ].FriendlyName, self.elements.new_tab_element, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_12 )

                ibCreateButton( 10, 125, 6, 10, self.elements.new_tab_element, "img/elements/radio/btn_arrow.png", "img/elements/radio/btn_arrow.png", "img/elements/radio/btn_arrow.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF999999 )
                :ibData( "rotation", 180 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self:ChangeRadioChannelMainMenu( -1 )
                end )

                ibCreateButton( 187, 125, 6, 10, self.elements.new_tab_element, "img/elements/radio/btn_arrow.png", "img/elements/radio/btn_arrow.png", "img/elements/radio/btn_arrow.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF999999 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self:ChangeRadioChannelMainMenu( 1 )
                end )
                
                local volume_text_lbl = ibCreateLabel( 14, 294, 0, 0, "Громкость:", self.elements.new_tab_element, 0xFFABAEB2, _, _, "left", "top", ibFonts.bold_9 )
                self.elements.volume_value = ibCreateLabel( volume_text_lbl:ibGetAfterX( 5 ), 293, 0, 0, math.floor( SETTINGS.radio_coeff * 100 ) .. "%", self.elements.new_tab_element, 0xFFFFFFFF, _, _, "left", "top", ibFonts.bold_10 )
                
                self.max_width_volume = 176
                self.elements.bg_volume_rect = ibCreateImage( 14, 315, self.max_width_volume, 14, _, self.elements.new_tab_element, 0xFF3E4F62 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "down" then return end
                    ibClick()
                    self.is_regulator_press = true
                end )
                :ibOnRender( function()
                    if self.is_regulator_press then
                        local cx  = getCursorPosition()
                        self:ChangeRadioVolume( (math.floor(cx * scX) - self.elements.bg_volume_rect:ibData("real_px")) / self.max_width_volume )
                    end
                end )
                
                self.elements.volume_rect = ibCreateImage( 14, 315, self.max_width_volume * SETTINGS.radio_coeff, 14, _, self.elements.new_tab_element, 0xFF7FA5D0 ):ibData( "disabled", true )
                self.elements.volume_reg = ibCreateButton( 14 + self.max_width_volume * SETTINGS.radio_coeff, 312, 4, 20, self.elements.new_tab_element, _, _, _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "down" then return end
                    ibClick()
                    self.is_regulator_press = true
                end )
                
                self.onPlayerClick = function( key, state )
                    if key == "left" and state == "up" then 
                        self.is_regulator_press = false 
                    end
                end

                removeEventHandler( "onClientClick", root, self.onPlayerClick )
                addEventHandler( "onClientClick", root, self.onPlayerClick )

                self.is_regulator_press = false
                self:ChangeRadioStateMainMenu( true )
            end,
        },
        [ 2 ] =
        {
            id = "radio_list",
            create = function( self, data )
                self.elements.back = ibCreateImage( 14, 28, 18, 14, "img/elements/arrow_back.png", self.elements.new_tab_element )
                :ibData( "alpha", 150 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self:SwitchTab( 1 )
                end )
                :ibOnHover( function( )
                    source:ibData( "alpha", 255 )
                end )
                :ibOnLeave( function( )
                    source:ibData( "alpha", 150 )
                end )

                ibCreateLabel( 0, 55, 204, 40, "Радио волны", self.elements.new_tab_element, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_10 )

                self.elements.current_tab_scrollpane, self.elements.current_tab_scrollbar = ibCreateScrollpane( 0, 95, 204, 267, self.elements.new_tab_element, { scroll_px = -15, bg_color = 0 } )
                self.elements.current_tab_scrollbar:ibData( "alpha", 0 )

                local py = 0
                self.elements.radio = {}
                for k, v in pairs( VEHICLE_RADIO ) do
                    local container = ibCreateImage( 0, py, 204, 23, _, self.elements.current_tab_scrollpane, 0x00FFFFFF )
                    :ibOnHover( function( )
                        source:ibData( "color", 0x55252F3B )
                    end )
                    :ibOnLeave( function( )
                        source:ibData( "color", 0x00FFFFFF )
                    end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        if IsPlayerCanPlayRadio() then
                            CURRENT_RADIO_ID = k
                            SaveCurrentRadioChannel( CURRENT_RADIO_ID )
                            self:SwitchTab( 1 )
                            self:ChangeRadio()
                        end
                    end )

                    ibCreateImage( 0, 0, 204, 1, _, container, 0xFF69798E )
                    
                    local lbl = ibCreateLabel( 14, 0, 0, 23, k .. ". " .. v.FriendlyName, container, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 ):ibData( "disabled", true )
                    
                    local btn_dummy = ibCreateArea( lbl:ibGetAfterX( 1 ), 0, 23, 23, container )
                    
                    if k == CURRENT_RADIO_ID and CURRENT_RADIO_STATE then
                        self.elements.radio[ k ] = ibCreateImage( 8, 8, 8, 8, "img/elements/individ/stop.png", btn_dummy )
                    else
                        self.elements.radio[ k ] = ibCreateImage( 8, 8, 8, 8, "img/elements/individ/play.png", btn_dummy )
                    end
                    
                    self.elements.radio[ k ]:ibData( "disabled", true )
                    btn_dummy
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        if IsPlayerCanPlayRadio() then
                            self:ChangeRadioStateListMenu( k )
                        end
                    end )

                    py = py + 23
                end
                self.elements.current_tab_scrollpane:AdaptHeightToContents()
                self.elements.current_tab_scrollbar:UpdateScrollbarVisibility( self.elements.current_tab_scrollpane )

            end,
        }
    },

    ChangeRadioChannelMainMenu = function( self, direction )
        CURRENT_RADIO_ID = CURRENT_RADIO_ID + direction
        if CURRENT_RADIO_ID > #VEHICLE_RADIO then
            CURRENT_RADIO_ID = 1
        elseif CURRENT_RADIO_ID < 1 then
            CURRENT_RADIO_ID = #VEHICLE_RADIO
        end
        SaveCurrentRadioChannel( CURRENT_RADIO_ID )
        self.elements.radio_lbl:ibData( "text", VEHICLE_RADIO[ CURRENT_RADIO_ID or 1 ].FriendlyName )

        if CURRENT_RADIO_STATE then
            self:ChangeRadio()
        end
    end,

    StartPhoneRadio = function( self )
        removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, OnPlayerEnterInVehicle )
        addEventHandler( "onClientPlayerVehicleEnter", localPlayer, OnPlayerEnterInVehicle )
        self:ChangeRadio()

        if isTimer( self.quest_camera_timer ) then killTimer( self.quest_camera_timer ) end
        self.quest_camera_time = setTimer( self.HandleQuestCamera, 200, 0 )

        triggerEvent( "onClientPlayerSomeDo", localPlayer, "play_radio" ) -- achievements
    end,

    ChangeRadio = function( self )
        if isElement( CURRENT_RADIO_SOUND ) then
            SoundDestroySource( CURRENT_RADIO_SOUND )
        end
        CURRENT_RADIO_SOUND = SoundCreateSource( SOUND_TYPE_2D, VEHICLE_RADIO[ CURRENT_RADIO_ID or 1 ].Value )
        SoundSetVolume( CURRENT_RADIO_SOUND, SETTINGS.radio_coeff )
        setElementData( localPlayer, "radio.channel", { channel = CURRENT_RADIO_ID + 1, state = "phone" }, false )
    end,

    StopPhoneRadio = function( self )
        if isTimer( self.quest_camera_timer ) then killTimer( self.quest_camera_timer ) end
        SoundDestroySource( CURRENT_RADIO_SOUND )
        CURRENT_RADIO_SOUND = nil
        removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, OnPlayerEnterInVehicle )
    end,

    HandleQuestCamera = function( )
        local self = APPLICATIONS.radio
        local was_in_quest = self.was_in_quest
        local is_in_quest = false
        
        if isElement( CURRENT_RADIO_SOUND ) then
            if getCameraTarget( ) ~= localPlayer then
                local current_quest = localPlayer:getData( "current_quest" )
                if current_quest then
                    local quest_id = current_quest.id
                    for i, v in pairs( REGISTERED_QUESTS ) do
                        if v == quest_id then
                            is_in_quest = true
                            break
                        end
                    end
                end
            end

            if was_in_quest ~= is_in_quest then
                self:FadeVolumeTo( is_in_quest and 0.05 or nil )
                self.was_in_quest = is_in_quest
            end
        end
    end,

    HandleFading = function( )
        local self = APPLICATIONS.radio

        if isElement( CURRENT_RADIO_SOUND ) and self.fade_conf then
            local to = self.fade_conf.to
            local delta = CURRENT_RADIO_SOUND.volume - to

            if math.abs( delta ) > 0.05 then
                CURRENT_RADIO_SOUND.volume = CURRENT_RADIO_SOUND.volume - delta / 1000 * 60
            else
                self.fade_conf.to = nil
                removeEventHandler( "onClientPreRender", root, self.HandleFading )
            end
        else
            removeEventHandler( "onClientPreRender", root, self.HandleFading )
        end
    end,

    FadeVolumeTo = function( self, volume )
        removeEventHandler( "onClientPreRender", root, self.HandleFading )

        self.fade_conf = { from = CURRENT_RADIO_SOUND.volume, to = volume or SETTINGS.radio_coeff }

        addEventHandler( "onClientPreRender", root, self.HandleFading )
    end,

    ChangeRadioVolume = function( self, radio_volume )
        SetSetting( "radio_coeff", math.floor( math.min( 1, math.max( 0, radio_volume ) ) * 100 ) / 100 )
        
        if isElement( CURRENT_RADIO_SOUND ) then
            SoundSetVolume( CURRENT_RADIO_SOUND, SETTINGS.radio_coeff )
        end

        self.elements.volume_rect:ibData( "sx", 176 * SETTINGS.radio_coeff )
        self.elements.volume_reg:ibData( "px", 14 + 176 * SETTINGS.radio_coeff )
        self.elements.volume_value:ibData( "text", math.floor( SETTINGS.radio_coeff * 100 ) .. "%" )
    end,

    ChangeRadioStateMainMenu = function( self, ignore_inversion, radio_off )
        if not ignore_inversion then
            CURRENT_RADIO_STATE = radio_off and false or not CURRENT_RADIO_STATE
            self.elements.btn_radio_state:destroy()
            self.elements.lbl_radio_state:destroy()
        end
        if CURRENT_RADIO_STATE then
            if not ignore_inversion then
                self:StartPhoneRadio()
            end
            self.elements.btn_radio_state = ibCreateButton( 80, 174, 45, 61, self.elements.new_tab_element, "img/elements/radio/btn_pause.png", "img/elements/radio/btn_pause.png", "img/elements/radio/btn_pause.png", 0xFFDDE4ED, 0xFFFFFFFF, 0xFF959BA2 )
            self.elements.lbl_radio_state = ibCreateLabel( 0, 240, 204, 0, "Приостановить", self.elements.new_tab_element, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_10 )
        else
            if not ignore_inversion then
                self:StopPhoneRadio()
            end
            self.elements.btn_radio_state = ibCreateButton( 76, 174, 54, 61, self.elements.new_tab_element, "img/elements/radio/btn_play.png", "img/elements/radio/btn_play.png", "img/elements/radio/btn_play.png", 0xFFDDE4ED, 0xFFFFFFFF, 0xFF959BA2 )
            self.elements.lbl_radio_state = ibCreateLabel( 0, 240, 204, 0, "Включить", self.elements.new_tab_element, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_10 )
        end
        
        self.elements.btn_radio_state
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            if IsPlayerCanPlayRadio() then
                self:ChangeRadioStateMainMenu()
            end
        end )
    end,

    ChangeRadioStateListMenu = function( self, radio_id, radio_off )
        if radio_id == CURRENT_RADIO_ID then
            CURRENT_RADIO_STATE = radio_off and false or not CURRENT_RADIO_STATE
            self.elements.radio[ CURRENT_RADIO_ID ]:ibData( "texture", CURRENT_RADIO_STATE and "img/elements/individ/stop.png" or "img/elements/individ/play.png" )
        elseif radio_id then
            self.elements.radio[ CURRENT_RADIO_ID ]:ibData( "texture", "img/elements/individ/play.png" )
            self.elements.radio[ radio_id ]:ibData( "texture", "img/elements/individ/stop.png" )
            
            CURRENT_RADIO_STATE = true
            CURRENT_RADIO_ID = radio_id
            SaveCurrentRadioChannel( CURRENT_RADIO_ID )
        end

        if CURRENT_RADIO_STATE then
            self:StartPhoneRadio()
        else
            self:StopPhoneRadio()
        end
    end,

    SwitchTab = function( self, id, data )
        
        if self.onPlayerClick then
            removeEventHandler( "onClientClick", root, self.onPlayerClick )
        end
        
        self.current_tab = self.tabs[ id ]

        self.elements.header_texture = dxCreateTexture( "img/elements/" .. self.current_tab.id ..  "_header.png" )
        self.hsx, self.hsy = dxGetMaterialSize( self.elements.header_texture )

        if isElement( self.elements.new_tab_element ) then
            self.elements.new_tab_element:destroy()
        end

        local start_x = id >= self.current_tab_id and self.hsx * -1 or self.hsx
        self.current_tab_id = id

        self.elements.new_tab_element = ibCreateArea( start_x, 0, self.hsx, 317, self.elements.tab_rt ):ibMoveTo( 0, _, 150 )
        self.elements.header = ibCreateImage( 0, 0, self.hsx, self.hsy * self.conf.sx / self.hsx, self.elements.header_texture, self.elements.new_tab_element, 0xFFFFFFFF )
                    
        self.current_tab.create( self, data )

        if isElement( self.elements.current_tab_element ) then
            
            self.elements.current_tab_element:ibMoveTo( start_x * -1, _, 150 )
            self.elements.current_tab_element:ibAlphaTo( 0, 150 )
            
            self.elements.new_tab_element:ibTimer( function()
                if isElement( self.elements.current_tab_element ) then
                    self.elements.current_tab_element:destroy()
                end
                self.elements.current_tab_element = self.elements.new_tab_element
            end, 150, 1 )

        end

    end,

    create = function( self, parent, conf )
        self.parent = parent
        self.conf = conf
        
        CURRENT_RADIO_ID = GetCurrentRadioChannel()

        self.elements.tab_rt = ibCreateRenderTarget( 0, 0, 204, 362, parent )
        self:SwitchTab( 1 )
        
        RADIOAPP = self
        return self
    end,
    
    destroy = function( self, parent, conf )

        if self.onPlayerClick then
            removeEventHandler( "onClientClick", root, self.onPlayerClick )
        end

        DestroyTableElements( self.elements )
        RADIOAPP = nil
    end,
}


local radio_file_path = "radio.nrp"
function GetCurrentRadioChannel()
    local radio_channel_id = 1
    if fileExists( radio_file_path ) then
        local file = fileOpen( radio_file_path )
        local file_content = fileRead( file, fileGetSize( file ) )
        radio_channel_id = tonumber( file_content)
        fileClose( file )
    end
    
    if not radio_channel_id or radio_channel_id > #VEHICLE_RADIO or radio_channel_id < 1 then
        radio_channel_id = 1
    end
    
    return radio_channel_id
end

function SaveCurrentRadioChannel( radio_channel_id )
    local radio_channel_id = tonumber( radio_channel_id )
    if not radio_channel_id or radio_channel_id > #VEHICLE_RADIO or radio_channel_id < 1 then
        radio_channel_id = 1
    end
    if fileExists( radio_file_path ) then
        fileDelete( radio_file_path )
    end
    local file = fileCreate( radio_file_path )
    fileWrite( file, tostring( radio_channel_id ) )
    fileClose( file )
end

function OnPlayerEnterInVehicle()
    CURRENT_RADIO_STATE = false
    
    if not RADIOAPP then
        APPLICATIONS.radio:StopPhoneRadio()
    else
        if RADIOAPP.current_tab_id == 1 then
            RADIOAPP:ChangeRadioStateMainMenu( false, true )
        elseif RADIOAPP.current_tab_id == 2 then
            RADIOAPP:ChangeRadioStateListMenu( CURRENT_RADIO_ID, true )
        end
    end
end

function onSettingsChange_handler( changed, values )
	if changed.radio_coeff and CURRENT_RADIO_SOUND then
		if values.radio_coeff then
			SoundSetVolume( CURRENT_RADIO_SOUND, SETTINGS.radio_coeff )
		end
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

function IsPlayerCanPlayRadio()
    if isPedInVehicle( localPlayer ) or localPlayer:getData( "in_race" ) then 
        localPlayer:ShowError( "В машине нельзя включать радио в телефоне")
        return false
    end
    return true
end

function onClientOffPhoneRadio_handler( hide_phone )
    if isElement( CURRENT_RADIO_SOUND ) then
        SoundDestroySource( CURRENT_RADIO_SOUND )
        if hide_phone then
            OnPlayerPhoneKey( true )
        end
    end
end
addEvent( "onClientOffPhoneRadio" )
addEventHandler( "onClientOffPhoneRadio", root, onClientOffPhoneRadio_handler )