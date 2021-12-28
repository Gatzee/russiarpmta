CALL_POPUP = nil

MAX_RECENT  = 20
CURRENT_RECENT = {}
CURRENT_STATUS = nil

CALL_SOUND = nil
CALL_TIMER = nil
CALL_TIME_START = nil

TYPE_CALL =
{
    OUTGOING = "Исходящий вызов",
    INCOMING = "Входящий вызов"
}

CONTACTS_APP = nil
APPLICATIONS.contacts = {
    id = "contacts",
    icon = "img/apps/contacts.png",
    name = "Контакты",
    elements = { },

    current_tab_id = 1,
    current_tab = nil,

    CreateContactPopUp = function( self, data, recent )
        self.elements.bg_popup = ibCreateImage( 0, 0, 204, 362, "img/elements/contacts/popup_contact.png", self.elements.tab_rt )
        
        ibCreateButton(   172, 60, 18, 18, self.elements.bg_popup,
            ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            self.elements.bg_popup:destroy()
        end )

        local isOn = GetPlayer( data.player_id )
        ibCreateLabel( 0, 140, 204, 0,
                isOn and "В сети" or "Не в сети",
                self.elements.bg_popup,
                isOn and 0xff7fa5d0 or 0x55ffffff, _, _,
                "center", "top", ibFonts.regular_10
        )
        ibCreateLabel( 0, 154, 204, 0, data.player_nick, self.elements.bg_popup, 0xAAFFFFFF, _, _, "center", "top", ibFonts.regular_10 )
        ibCreateLabel( 0, 170, 204, 0, format_price( data.phone_number ), self.elements.bg_popup, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_10 )

        local texture = dxCreateTexture( "img/elements/contacts/btn_message.png" )
        local texture_hover = dxCreateTexture( "img/elements/contacts/btn_message_hover.png" )
        local btn_message = ibCreateButton( 28, 191, 148, 28, self.elements.bg_popup, texture, texture_hover, texture_hover, 0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            PREVIOUS_APPLICATION_NAME = "contacts"
            CONTACTS_APP:destroy()
            CONTACTS_APP = nil

            UI_elements.background:ibData( "alpha", 0 )
            CURRENT_APPLICATION = table.copy( APPLICATIONS.sms ):create( UI_elements.background, CURRENT_PHONE_CONF, true )
            
            CURRENT_APPLICATION:create_secondary( CURRENT_APPLICATION.parent, CURRENT_APPLICATION.conf, self.contact_list )
            CURRENT_APPLICATION:SwitchTab( 2, data )
            
            UI_elements.background:ibAlphaTo( 255, 50 )
        end )

        local texture_call = dxCreateTexture( "img/elements/contacts/btn_call.png" )
        local texture_call_hover = dxCreateTexture( "img/elements/contacts/btn_call_hover.png" )
        local btn_call = ibCreateButton( 28, 226, 148, 28, self.elements.bg_popup, texture_call, texture_call_hover, texture_call_hover, 0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            CALL_POPUP = self:CreatePopUpTryCall( data, recent )
        end )
    end,

    DestroyCurrentMenu = function( self )
        for k, v in pairs( self.elements ) do
            if isElement( v ) and v ~= self.elements.tab_rt then
                v:destroy()
            end
        end
    end,

    StartCallBeep = function()
        if isTimer( CALL_TIMER ) then
            killTimer( CALL_TIMER )
        end
        if isElement( CALL_SOUND ) then
            stopSound( CALL_SOUND )
        end
        CALL_TIMER = setTimer( function()
            CALL_SOUND = playSound( "sound/sound_call.wav" )
            setSoundVolume( CALL_SOUND, 0.4 )
        end, 3000, 0 )
    end,

    StopCallBeep = function( call_error )
        if isTimer( CALL_TIMER ) then
            killTimer( CALL_TIMER )
        end
        if isElement( CALL_SOUND ) then
            stopSound( CALL_SOUND )
        end
        local file_path = "sound/" .. call_error .. ".wav"
        if fileExists( file_path ) then
            CALL_SOUND = playSound( file_path )
            setSoundVolume( CALL_SOUND, 0.4 )
            if CONTACTS_APP and isElement( CONTACTS_APP.elements.bg_popup ) then
                CONTACTS_APP.elements.bg_popup:destroy()
            end
        end
    end,

    CreatePopUpTryCall = function( self, data, recent )
        self:DestroyCurrentMenu()
        
        local bg = ibCreateImage( 0, 0, 204, 362, "img/elements/contacts/bg_accept_call.png", self.elements.tab_rt )

        ibCreateLabel( 0, 40, 204, 0, TYPE_CALL[ "OUTGOING" ], bg, 0xFF978566, _, _, "center", "top", ibFonts.regular_11 )
        ibCreateLabel( 0, 183, 204, 0, data.player_nick or "Неизвестный", bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_11 )
        ibCreateLabel( 0, 211, 204, 0, "+ " .. format_price( data.phone_number ), bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_18 )

        ibCreateButton( 72, 288, 60, 60, bg, "img/elements/contacts/btn_ignore_call.png", "img/elements/contacts/btn_ignore_call_hover.png", "img/elements/contacts/btn_ignore_call_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            bg:destroy()
            if isElement( CALL_SOUND ) then
                stopSound( CALL_SOUND )
            end
            if not isTimer( STOP_CALL_TIMER ) then
                triggerServerEvent( "onServerIgnorePhoneCall", localPlayer )
            else
                killTimer( STOP_CALL_TIMER )
                if isElement( UI_elements.background ) then
                    CONTACTS_APP = nil
                    CreateApplication( "contacts", UI_elements.background, CURRENT_PHONE_CONF.usable_area )
                end
            end
        end )

        if not data or data.start_time ~= -1 then
            APPLICATIONS.contacts.StartCallBeep()
            if recent then
                triggerServerEvent( "onServerPlayerCallPhoneNumber", localPlayer, data.phone_number )
            else
                triggerServerEvent( "onServerPlayerCallPhoneContact", localPlayer, data.phone_number )
            end
        end

        return bg
    end,

    CreatePopUpCall = function( self, data )
        self:DestroyCurrentMenu()

        local bg = ibCreateImage( 0, 0, 204, 362, "img/elements/contacts/bg_accept_call.png", self.elements.tab_rt )

        ibCreateLabel( 0, 40, 204, 0, TYPE_CALL[ "INCOMING" ], bg, 0xFF978566, _, _, "center", "top", ibFonts.regular_11 )
        ibCreateLabel( 0, 183, 204, 0, data.abonent:GetNickName() or "Неизвестный", bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_11 )
        ibCreateLabel( 0, 211, 204, 0, "+ " .. format_price( data.phone_number ), bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_18 )

        ibCreateButton( 20, 288, 60, 60, bg, "img/elements/contacts/btn_accept_call.png", "img/elements/contacts/btn_accept_call_hover.png", "img/elements/contacts/btn_accept_call_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            bg:destroy()
            stopSound( CALL_SOUND )
            triggerServerEvent( "onServerAcceptPhoneCall", localPlayer )
        end )

        ibCreateButton( 124, 288, 60, 60, bg, "img/elements/contacts/btn_ignore_call.png", "img/elements/contacts/btn_ignore_call_hover.png", "img/elements/contacts/btn_ignore_call_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            bg:destroy()
            stopSound( CALL_SOUND )
            triggerServerEvent( "onServerIgnorePhoneCall", localPlayer )

            if not CONTACTS_APP then return end
            CONTACTS_APP:create_secondary( CONTACTS_APP.parent, CONTACTS_APP.conf, CONTACTS_APP.data )
        end )
        if not isElement( CALL_SOUND ) then
            CALL_SOUND = playSound( "sound/ringtone/" .. PHONE_CURRENT_SOUNDS.ringtone .. ".wav", true )
            setSoundVolume( CALL_SOUND, SETTINGS.notifications or 0.4 )
        end

        return bg
    end,

    CreatePopUpTalk = function( self, data )
        self:DestroyCurrentMenu()

        local bg = ibCreateImage( 0, 0, 204, 362, "img/elements/contacts/bg_talk_call.png", self.elements.tab_rt )
        
        ibCreateLabel( 0, 40, 204, 0, TYPE_CALL[ data.type_call or "INCOMING" ], bg, 0xFF978566, _, _, "center", "top", ibFonts.regular_11 )
        ibCreateLabel( 0, 156, 204, 0, data.abonent:GetNickName() or "Неизвестный", bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_11 )
        ibCreateLabel( 0, 181, 204, 0, "+ " .. format_price( data.phone_number or 0 ), bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_18 )
        
        ibCreateButton( 72, 288, 60, 60, bg, "img/elements/contacts/btn_end_call.png", "img/elements/contacts/btn_end_call_hover.png", "img/elements/contacts/btn_end_call_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            bg:destroy()
            triggerServerEvent( "onServerEndPhoneCall", localPlayer )

            if not CONTACTS_APP then return end
            CONTACTS_APP:create_secondary( CONTACTS_APP.parent, CONTACTS_APP.conf, CONTACTS_APP.data )
        end )
        
        APPLICATIONS.contacts.time_call = ibCreateLabel( 0, 255, 204, 0, "00:00", bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_18 )
        :ibOnRender( function()
            local time = (getTickCount() - CALL_TIME_START) / 1000
            local minute = math.floor( time / 60 )
            local seconds = math.floor( time - minute * 60 )
            APPLICATIONS.contacts.time_call:ibData( "text", string.format( "%02d:%02d", minute, seconds ) )
        end )

        return bg
    end,
    
    tabs = 
    {
        [ 1 ] = 
        {
            id = "contacts",
            create = function( self )
                local btn_add_contact = ibCreateImage( 172, 26, 18, 18, "img/elements/contacts/add.png", self.elements.new_tab_element ):ibData( "alpha", 100 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self:SwitchTab( 5 )
                end )
                :ibOnHover( function( )
                    source:ibData( "alpha", 200 )
                end )
                :ibOnLeave( function( )
                    source:ibData( "alpha", 100 )
                end )

                
                ibCreateImage( 14, 69, 24, 24, "img/elements/contacts/user.png", self.elements.new_tab_element )
                ibCreateLabel( 48, 64, 0, 0, "Ваш номер:", self.elements.new_tab_element, 0xFFFFFFFF - 0x55000000, _, _, "left", "top", ibFonts.regular_10 )

                local phone_number = localPlayer:GetPhoneNumber()
                if not phone_number then
                    btn_add_contact:ibData( "disabled", true )
                end

                local current_phone_number = phone_number and ( "+" .. format_price( phone_number ) ) or "Нет номера"
                ibCreateLabel( 48, 80, 0, 0, current_phone_number, self.elements.new_tab_element, 0xFFFFFFFF, _, _, "left", "top", ibFonts.regular_10 )
                
                
                self.elements.current_tab_scrollpane, self.elements.current_tab_scrollbar = ibCreateScrollpane( 0, 107, self.hsx, 210, self.elements.new_tab_element, { scroll_px = -10, bg_color = 0 } )
                self.elements.current_tab_scrollbar:ibData( "alpha", 0 )

                local online_list = { }
                local offline_list = { }

                for _, data in pairs( self.contact_list ) do
                    table.insert( GetPlayer( data.player_id ) and online_list or offline_list, data )
                end
                
                local py = 0

                local function drawList( list )
                    py = py + 16

                    for k, data in pairs( list ) do
                        local symbol = utf8.sub( data.player_nick, 1, 1 )
                        if not isElement( self.elements[ "contact_group_" .. symbol ] ) then
                            self.elements[ "contact_group_" .. symbol ] = ibCreateImage( 0, py, 204, 14, _, self.elements.current_tab_scrollpane, 0xFF252F3B )
                            ibCreateLabel( 14, 0, 0, 13, symbol, self.elements[ "contact_group_" .. symbol ], 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_8 )
                            py = py + 19
                        end

                        ibCreateLabel( 14, py, 176, 27, data.player_nick, self.elements.current_tab_scrollpane, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
                        --:ibData( "color", GetPlayer( data.player_id ) and 0xFFFFFFFF or 0xAAFFFFFF )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                            self:CreateContactPopUp( data )
                        end )
                        ibCreateImage( 14, py + 26, 176, 1, _, self.elements.current_tab_scrollpane, 0x551E252F )

                        local texture = data.favorite and "img/elements/contacts/star_hover.png" or "img/elements/contacts/star.png"
                        self.elements[ "contact_favorite_" .. data.player_id ] = ibCreateImage( 167, py + 3, 16, 16, texture, self.elements.current_tab_scrollpane )
                        :ibData( "alpha", 200 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                            data.favorite = not data.favorite
                            local texture = data.favorite and "img/elements/contacts/star_hover.png" or "img/elements/contacts/star.png"
                            self.elements[ "contact_favorite_" .. data.player_id ]:ibData( "texture", texture )
                            triggerServerEvent( "onServerSetContactFavorite", localPlayer, data.phone_number, data.favorite )
                        end )
                                :ibOnHover( function( )
                            self.elements[ "contact_favorite_" .. data.player_id ]:ibData( "alpha", 255 )
                        end )
                                :ibOnLeave( function( )
                            self.elements[ "contact_favorite_" .. data.player_id ]:ibData( "alpha", 200 )
                        end )

                        py = py + 27
                    end
                end

                if #online_list > 0 then
                    ibCreateImage( 0, py, 204, 16, "img/elements/contacts/contacts_online.png", self.elements.current_tab_scrollpane )
                    drawList( online_list, py )
                end

                if #offline_list > 0 then
                    ibCreateImage( 0, py, 204, 16, "img/elements/contacts/contacts_offline.png", self.elements.current_tab_scrollpane )
                    drawList( offline_list )
                end

                self.elements.current_tab_scrollpane:AdaptHeightToContents()
                self.elements.current_tab_scrollbar:UpdateScrollbarVisibility( self.elements.current_tab_scrollpane )
            end
        },
        [ 2 ] = 
        {
            id = "recent",
            create = function( self )
                self.elements.current_tab_scrollpane, self.elements.current_tab_scrollbar = ibCreateScrollpane( 0, 55, self.hsx, 262, self.elements.new_tab_element, { scroll_px = -10, bg_color = 0 } )
                self.elements.current_tab_scrollbar:ibData( "alpha", 0 )

                local py = 0
                for k, v in pairs( CURRENT_RECENT ) do
                    local area = ibCreateArea( 0, py, 204, 49, self.elements.current_tab_scrollpane )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        self:CreateContactPopUp( v, true )
                    end )
                    local phone_icon = ibCreateImage( 14, 18, 16, 16, "img/elements/contacts/phone_icon.png", area )
                    ibCreateImage( 14, py + 48, 176, 1, _, area, 0xAA252F3B )
                    local phone_call_type = "Пропущенный"
                    if v.type == "INCOMING" then
                        phone_icon:ibData( "color", 0xFF42FF80 )
                        phone_call_type = "Входящий"
                    elseif v.type == "OUTGOING" then
                        phone_icon:ibData( "color", 0xFF959BA2 )
                        phone_call_type = "Исходящий"
                    elseif v.type == "NOT_ANSWER" then
                        phone_icon:ibData( "color", 0xFFFF5C5C )
                        
                    end
                    ibCreateLabel( 44, 5, 0, 0, v.player_nick, area, 0xFFFFFFFF, _, _, "left", "top", ibFonts.regular_11 )
                    ibCreateLabel( 44, 25, 0, 0, phone_call_type, area, 0xAAFFFFFF, _, _, "left", "top", ibFonts.regular_10 )
                    
                    ibCreateLabel( 158, 21, 0, 0, v.start_time, area, 0xAAFFFFFF, _, _, "left", "top", ibFonts.regular_10 )
                    
                    py = py + 49
                end
                
                self.elements.current_tab_scrollpane:AdaptHeightToContents()
                self.elements.current_tab_scrollbar:UpdateScrollbarVisibility( self.elements.current_tab_scrollpane )
            end
        },
        [ 3 ] = 
        {
            id = "dial_number",
            create = function( self )
                local px, py = 41, 98
                local buttons = { 1, 2, 3, 4, 5, 6, 7, 8, 9, "+", 0, "C" }
                
                self.elements.enter_number = ibCreateLabel( 0, 68, 204, 0, "", self.elements.new_tab_element, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_12  )
                for i = 1, 12 do
                    self.elements[ "btn_number_" .. i ] = ibCreateImage( px, py, 34, 34, "img/elements/contacts/ellipse_bg.png", self.elements.new_tab_element, 0xAAFFFFFF )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        local text = self.elements.enter_number:ibData( "text" )
                        local text_len = utf8.len( text )
                        local number = tonumber( buttons[ i ] )
                        if number then
                            if text_len == 7 then return end
                            self.elements.enter_number:ibData( "text", text .. number )
                        elseif buttons[ i ] == "C" and text_len > 0 then
                            local new_str = utf8.sub( text, 1, text_len - 1 )
                            self.elements.enter_number:ibData( "text", new_str )
                        end
                    end )
                    :ibOnHover( function( )
                        self.elements[ "btn_number_" .. i ]:ibData( "color", 0xFFFFFFFF )
                    end )
                    :ibOnLeave( function( )
                        self.elements[ "btn_number_" .. i ]:ibData( "color", 0xAAFFFFFF )
                    end )
                    ibCreateLabel( 0, 0, 34, 34, buttons[ i ], self.elements[ "btn_number_" .. i ], 0xFF000000, _, _, "center", "center", ibFonts.regular_10 ):ibData( "disabled", true )
                    if i % 3 ==0 then
                        px = 41
                        py = py + 43
                    else
                        px = px + 43
                    end
                end

                self.elements.call_btn = ibCreateImage( 85, 269, 34, 34, "img/elements/contacts/ellipse_call.png", self.elements.new_tab_element, 0xAAFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    local text =  self.elements.enter_number:ibData( "text" )
                    local text_len = utf8.len( text )
                    local phone_number = tonumber( text )
                    if text_len ~= 7 or not phone_number then return end
                    local player_number = localPlayer:GetPhoneNumber()
                    if player_number == phone_number then
                        return
                    end
                    CALL_POPUP = self:CreatePopUpTryCall( { phone_number = phone_number }, true )
                end )
                :ibOnHover( function( )
                    self.elements.call_btn:ibData( "color", 0xFFFFFFFF )
                end )
                :ibOnLeave( function( )
                    self.elements.call_btn:ibData( "color", 0xAAFFFFFF )
                end )
            end
        },
        [ 4 ] = 
        {
            id = "favorites",
            create = function( self )
                if isElement( self.elements.current_tab_scrollpane ) then
                    self.elements.current_tab_scrollpane:destroy()
                end

                self.elements.current_tab_scrollpane, self.elements.current_tab_scrollbar = ibCreateScrollpane( 0, 55, self.hsx, 262, self.elements.new_tab_element, { scroll_px = -10, bg_color = 0 } )
                self.elements.current_tab_scrollbar:ibData( "alpha", 0 )

                local py = 0
                for k, v in pairs( self.contact_list ) do
                    if v.favorite then
                        ibCreateLabel( 14, py, 176, 38, v.player_nick, self.elements.current_tab_scrollpane, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
                        :ibData( "color", GetPlayer( v.player_id ) and 0xFFFFFFFF or 0xAAFFFFFF )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                            self:CreateContactPopUp( v )
                        end )

                        ibCreateImage( 14, py + 37, 176, 1, _, self.elements.current_tab_scrollpane, 0x551E252F )
                    
                        self.elements[ "contact_favorite_" .. k ] = ibCreateImage( 167, py + 10, 16, 16, "img/elements/contacts/star_hover.png", self.elements.current_tab_scrollpane )
                        :ibData( "alpha", 200 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                            self.contact_list[ k ].favorite = false
                            self.elements[ "contact_favorite_" .. k ]:destroy()
                            triggerServerEvent( "onServerSetContactFavorite", localPlayer, self.contact_list[ k ].phone_number, self.contact_list[ k ].favorite )

                            CONTACTS_APP.current_tab.create( CONTACTS_APP )
                        end )
                        :ibOnHover( function( )
                            self.elements[ "contact_favorite_" .. k ]:ibData( "alpha", 255 )
                        end )
                        :ibOnLeave( function( )
                            self.elements[ "contact_favorite_" .. k ]:ibData( "alpha", 200 )
                        end )

                        py = py + 38
                    end
                end

                self.elements.current_tab_scrollpane:AdaptHeightToContents()
                self.elements.current_tab_scrollbar:UpdateScrollbarVisibility( self.elements.current_tab_scrollpane )
            end
        },
        [ 5 ] =
        {
            id = "new_contact",
            is_not_menu = true,
            create = function( self )
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

                ibCreateLabel( 0, 95, 204, 0, "Введите номер", self.elements.new_tab_element, 0xFFFFFFFF - 0x55000000, _, _, "center", "top", ibFonts.regular_10 )
                self.elements.bg_edit = ibCreateImage( 14, 116, 176, 38, "img/elements/contacts/bg_edit_add_number.png", self.elements.new_tab_element )
                self.elements.edit_number = ibCreateWebEdit( 36, 0, 104, 40, "", self.elements.bg_edit, 0xFFFFFFFF, 0x00000000 )
                self.elements.edit_number:ibBatchData( { font = "regular_12_900", max_length = 7, text_align = "center" } )

                self.elements.btn_add = ibCreateButton( 52, 174, 100, 28, self.elements.new_tab_element, "img/elements/contacts/btn_add.png", "img/elements/contacts/btn_add_hover.png", "img/elements/contacts/btn_add_hover.png", 0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
                :ibOnClick( function(key, state)
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    local text = self.elements.edit_number:ibData( "text" )
                    local text_len = utf8.len( text )
                    local phone_number = tonumber( text )
                    if text_len ~= 7 or not phone_number then return end
                    if self:IsContactExist( phone_number ) then
                        return
                    end
                    local player_number = localPlayer:GetPhoneNumber()
                    if player_number == phone_number then
                        return
                    end

                    iprint("client", phone_number)

                    triggerServerEvent( "onServerPlayerAddPhoneContact", localPlayer, phone_number )
                end, false )
            end
        }
    },

    create = function( self, parent, conf )
        CONTACTS_APP = self

        self.parent = parent
        self.conf = conf

        triggerServerEvent( "onClientRequestContactList", resourceRoot )

        return self
    end,

    RefreshContactList = function( self, contact_list, add_contact )
        self.contact_list = contact_list or {}
        table.sort( self.contact_list, function( a, b )
            return (a and b) and a.player_nick < b.player_nick or false
        end )
        if add_contact then
            self:SwitchTab( 1 )
        end
    end,

    IsContactExist = function( self, phone_number )
        for k, v in pairs( self.contact_list ) do
            if v.phone_number == phone_number then
                return true
            end
        end
        return false
    end,

    SwitchTab = function( self, id )
            
        self.current_tab = self.tabs[ id ]
        
        self.elements.texture_header = dxCreateTexture( "img/elements/contacts/" .. self.current_tab.id .. "_header.png" )
        self.hsx, self.hsy = dxGetMaterialSize( self.elements.texture_header )

        if isElement( self.elements.new_tab_element ) then
            self.elements.new_tab_element:destroy()
        end

        local start_x = id >= self.current_tab_id and self.hsx * -1 or self.hsx
        self.current_tab_id = id

        self.elements.new_tab_element = ibCreateArea( start_x, 0, self.hsx, 317, self.elements.tab_rt ):ibMoveTo( 0, _, 150 )
        self.elements.header = ibCreateImage( 0, 0, self.hsx, self.hsy * self.conf.sx / self.hsx, self.elements.texture_header, self.elements.new_tab_element, 0xFFFFFFFF )
                    
        self.current_tab.create( self )

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

        for k, v in pairs( self.tabs ) do
            if not v.is_not_menu then
                if v.id ~= self.current_tab.id then
                    self.elements["btn_" .. v.id ]:ibData( "color", 0xFF1E252F )
                else
                    self.elements["btn_" .. v.id ]:ibData( "color", 0xFF64768B )
                end
            end
        end

    end,

    create_secondary = function( self, parent, conf, data )
        if not isElement( self.elements.tab_rt ) then
            self.elements.tab_rt = ibCreateRenderTarget( 0, 0, 204, 362, parent )
        end

        local phone_number = localPlayer:GetPhoneNumber()
        if not phone_number then
            ibCreateLabel( 0, 0, 204, 300, "Отсутствует сим карта", self.elements.tab_rt, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
            return
        end

        self:RefreshContactList( data.contact_list )

        local px, py = 16, 11
        self.elements.bottom_bar = ibCreateArea( 0, 317, 204, 45, self.elements.tab_rt )
        ibCreateImage( 0, 0, 204, 1, _, self.elements.bottom_bar, 0x551E252F )
        for k, v in pairs( self.tabs ) do
            if not v.is_not_menu then
                local texture = dxCreateTexture( "img/elements/contacts/btn_" .. v.id .. ".png" )
                local sx, sy = dxGetMaterialSize( texture )
                self.elements["btn_" .. v.id ] = ibCreateImage( px, py, sx, sy, texture, self.elements.bottom_bar, 0xFF1E252F )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    if v.id ~= self.current_tab.id then
                        self:SwitchTab( k )
                    end
                    ibClick()
                end )
                :ibOnHover( function( )
                    if v.id ~= self.current_tab.id then
                        self.elements["btn_" .. v.id ]:ibData( "color", 0xAA64768B )
                    end
                end )
                :ibOnLeave( function( )
                    if v.id ~= self.current_tab.id then
                        self.elements["btn_" .. v.id ]:ibData( "color", 0xFF1E252F )
                    end
                end )
                px = px + sx + 27
                if k == 1 then
                    self.elements["btn_" .. v.id ]:ibData( "color", 0xFF64768B )
                end
            end
        end

        self:SwitchTab( self.current_tab_id )

    end,
    
    destroy = function( self, parent, conf )
        for i, v in pairs( self.elements ) do
            if isElement( v ) then destroyElement( v ) end 
            if isElement( i ) then destroyElement( i ) end 
        end
        CONTACTS_APP = nil
    end,
}


addEvent( "onClientRequestContactListCallback", true )
addEventHandler( "onClientRequestContactListCallback", root, function( conf )
    
    RefreshMessageCacheByRemovedContacts( conf.remove_list )
    RefreshRecentByRemovedContacts( conf.remove_list )
    
    CONTACTS_APP.data = conf
    CURRENT_STATUS = conf.status
    if not CURRENT_STATUS or CURRENT_STATUS.code == 0 then
        if not CONTACTS_APP then return end
        CONTACTS_APP:create_secondary( CONTACTS_APP.parent, CONTACTS_APP.conf, conf )
    else
        LoadPhoneMenu()
    end

end )


addEvent( "onClientContactListRefresh", true )
addEventHandler( "onClientContactListRefresh", root, function( contact_list, remove_list, add_contact, status )
    
    RefreshMessageCacheByRemovedContacts( remove_list )
    RefreshRecentByRemovedContacts( remove_list )
    
    CONTACTS_APP.data = conf
    CURRENT_STATUS = status
    if not CURRENT_STATUS or CURRENT_STATUS.code == 0 then
        if not CONTACTS_APP then return end
        CONTACTS_APP:RefreshContactList( contact_list, add_contact )
    else
        LoadPhoneMenu()
    end

end )

function LoadPhoneMenu()
    if isElement( CALL_POPUP ) then CALL_POPUP:destroy() end

    CONTACTS_APP.elements.tab_rt = ibCreateRenderTarget( 0, 0, 204, 362, CONTACTS_APP.parent )

    if CURRENT_STATUS.code == 3 then
        CALL_POPUP = CONTACTS_APP:CreatePopUpTalk( CURRENT_STATUS.data )
    elseif CURRENT_STATUS.data.type_call == "INCOMING" then 
        CALL_POPUP = CONTACTS_APP:CreatePopUpCall( CURRENT_STATUS.data )
    elseif CURRENT_STATUS.data.type_call == "OUTGOING" then
        CALL_POPUP = CONTACTS_APP:CreatePopUpTryCall( CURRENT_STATUS.data ) 
    end
end

-- Звонок провален
STOP_CALL_TIMER = nil
function onClientFailCall_handler( call_error )
    if isElement( CALL_POPUP ) then
        CALL_POPUP:ibData( "disabled", true )
    end
    APPLICATIONS.contacts.StopCallBeep( call_error or "" )
    
    if isTimer( STOP_CALL_TIMER ) then killTimer( STOP_CALL_TIMER ) end
    
    local sound_lenght = 1000
    if isElement( CALL_SOUND ) then
        sound_lenght = getSoundLength( CALL_SOUND ) * 1000 - 2000
    else
        CALL_SOUND = playSound( "sound/call_failed.wav" )
        setSoundVolume( CALL_SOUND, 0.4 )
    end
    STOP_CALL_TIMER = setTimer( function() 
        if isElement( CALL_POPUP ) then
            CALL_POPUP:destroy()
        end
        if isElement( UI_elements.background ) then
            CreateApplication( "contacts", UI_elements.background, CURRENT_PHONE_CONF.usable_area )
        end
    end, sound_lenght, 1 )
    CURRENT_STATUS = nil
    CALL_TIME_START = nil
end
addEvent( "onClientFailCall", true )
addEventHandler( "onClientFailCall", root, onClientFailCall_handler )

-- Звонок принят
function onClientAcceptPhoneCall_handler( data, data_source )
    if not isElement( UI_elements.background ) then
        OnPlayerPhoneKey()
    else
        if isElement( CALL_POPUP ) then
            CALL_POPUP:destroy()
        end
    end

    data_source.abonent:setData( "phone.call", true, false )
    data.abonent:setData( "phone.call", true, false )
    
    local abonent_data = data.abonent == localPlayer and data_source or data
    CURRENT_STATUS = { code = 3, data = abonent_data }

    APPLICATIONS.contacts.StopCallBeep( call_error or "" )
    if CONTACTS_APP then    
        CALL_POPUP = CONTACTS_APP:CreatePopUpTalk( abonent_data )
    end

    CALL_TIME_START = getTickCount()
end
addEvent( "onClientAcceptPhoneCall", true )
addEventHandler( "onClientAcceptPhoneCall", root, onClientAcceptPhoneCall_handler )

-- Попытка звонка игроку
function onClientTryPhoneCallPlayer_handler( data, contact_list )
    CURRENT_STATUS = { code = 2, data = data }

    if isElement( CALL_SOUND ) then stopSound( CALL_SOUND ) end
    CALL_SOUND = playSound( "sound/ringtone/" .. PHONE_CURRENT_SOUNDS.ringtone .. ".wav", true )
    setSoundVolume( CALL_SOUND, SETTINGS.notifications or 0.4 )

    if not isElement( UI_elements.background ) then return end
    if isElement( CALL_POPUP ) then
        CALL_POPUP:destroy()
    end
    
    if CONTACTS_APP then
        CALL_POPUP = CONTACTS_APP:CreatePopUpCall( data )
    end
end
addEvent( "onClientTryPhoneCallPlayer", true )
addEventHandler( "onClientTryPhoneCallPlayer", root, onClientTryPhoneCallPlayer_handler )

-- Звонок закончен
function onClientEndPhoneCall_handler( call_data )
    
    if isElement( call_data.abonent ) then
        call_data.abonent:setData( "phone.call", nil, false )
    end

    if isElement( CALL_POPUP ) then
        CALL_POPUP:destroy()
    end

    if isElement( CALL_SOUND ) then
        stopSound( CALL_SOUND )
    end

    APPLICATIONS.contacts.StopCallBeep( call_error or "" )
    if isElement( UI_elements.background ) then
        CURRENT_APPLICATION:destroy()
        CONTACTS_APP = nil
        CreateApplication( "contacts", UI_elements.background, CURRENT_PHONE_CONF.usable_area )
    end

    CALL_SOUND = playSound( "sound/call_failed.wav" )
    setSoundVolume( CALL_SOUND, 0.3 )

    local time = getRealTime()
    local start_time = string.format( "%02d:%02d ", time.hour, time.minute )
    AddRecentCall( { type = call_data.type_call, start_time = start_time, timestamp = getRealTimestamp(), phone_number = call_data.phone_number, player_id = call_data.abonent:GetUserID(), player_nick = call_data.abonent:GetNickName() } )

    CURRENT_STATUS = nil
    CALL_TIME_START = nil
end
addEvent( "onClientEndPhoneCall", true )
addEventHandler( "onClientEndPhoneCall", root, onClientEndPhoneCall_handler )

-----------------------------------------------------------------------------
-- Вспомогательный функционаzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
-----------------------------------------------------------------------------

local file_path_recent = "recentcall"

function AddRecentCall( call_data )
    if call_data then
        if #CURRENT_RECENT + 1 > MAX_RECENT then
            table.remove( CURRENT_RECENT, 1 )
        end
        table.insert( CURRENT_RECENT, call_data )
        table.sort( CURRENT_RECENT, function( a, b )
            return ( a and b ) and a.timestamp > b.timestamp or false
        end )
    end
    local file = fileCreate( file_path_recent )
    fileFlush( file )
    fileWrite( file, toJSON( CURRENT_RECENT ) )
    fileClose( file )
end

function RefreshRecentByRemovedContacts( remove_list )
    for k, v in pairs( remove_list or {} ) do
        for id, recent in pairs( CURRENT_RECENT ) do
            if recent.phone_number == v.phone_number then
                table.remove( CURRENT_RECENT, id )
                break
            end
        end
    end
    AddRecentCall()
end

function LoadPhoneApplications( )
    file_path_recent = file_path_recent .. GetServerNumber() .. ".nrp"
    if not fileExists( file_path_recent ) then
        local file = fileCreate( file_path_recent )
        fileClose( file )
    else
        local file = fileOpen( file_path_recent )
        local data = fileRead( file, fileGetSize( file ) )
        
        CURRENT_RECENT = fromJSON( data ) or {}
        fileClose( file )
    end

    table.sort( CURRENT_RECENT, function( a, b )
        return ( a and b ) and a.timestamp > b.timestamp or false
    end )
end
addEventHandler( "onClientResourceStart", resourceRoot, function()
    if localPlayer:IsInGame( ) then
        LoadPhoneApplications( )
    end
end )

function GetStringDataFromUNIX( unix_time )
    local minutes, seconds = math.floor( unix_time / 60 % 60 ), math.floor( unix_time % 60 )
    return string.format( "%02d:%02d ", minutes, seconds )
end

-----------------------------------------------------------------------------