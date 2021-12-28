
SMS_APP = nil
SMS_COUNT = 0
SMS_SOUND = nil

MAX_MESSAGES = 20
MESSAGE_CACHE = {}

APPLICATIONS.sms = {
    id = "sms",
    icon = "img/apps/sms.png",
    name = "СМС",
    elements = { },
    ticks = getTickCount(),

    contact_list = {},

    CreateContactPopUp = function( self )
        self.elements.bg_popup = ibCreateImage( 0, 0, 204, 362, "img/elements/contacts/bg_sel_contact.png", self.elements.tab_rt )
        
        ibCreateButton( 172, 60, 18, 18, self.elements.bg_popup,
            ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            self.elements.bg_popup:destroy()
        end )

        if next( self.contact_list ) then
            self.elements.current_tab_scrollpane, self.elements.current_tab_scrollbar = ibCreateScrollpane( 14, 102, 176, 158, self.elements.bg_popup, { scroll_px = -10, bg_color = 0 } )
            self.elements.current_tab_scrollbar:ibData( "alpha", 0 )

            local py = 0
            for k, v in pairs( self.contact_list ) do
                local container = ibCreateImage( 0, py, 176, 27, _, self.elements.current_tab_scrollpane, 0x00FFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self.elements.edit_number:ibData( "text", v.phone_number )
                    self.elements.edit_number:ibData( "caret_position", 7 )
                    self.elements.bg_popup:destroy()
                end )
                :ibOnHover( function( )
                    source:ibData( "color", 0x55252F3B )
                end )
                :ibOnLeave( function( )
                    source:ibData( "color", 0x00FFFFFF )
                end )
                
                ibCreateLabel( 14, 0, 0, 27, v.player_nick, container, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
                ibCreateImage( 0, 26, 194, 1, _, container, 0xAA252F3B )

                py = py + 27
            end

            self.elements.current_tab_scrollpane:AdaptHeightToContents()
            self.elements.current_tab_scrollbar:UpdateScrollbarVisibility( self.elements.current_tab_scrollpane )
        else
            ibCreateLabel( 0, 0, 204, 362, "Список контактов\nпуст", self.elements.bg_popup, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 ):ibData( "disabled", true )
        end
            
    end,

    current_tab_id = 1,
    current_tab = nil,
    tabs = 
    {
        [ 1 ] = 
        {
            id = "sms",
            create = function( self, data )

                local btn_new_sms = ibCreateImage( 172, 26, 18, 18, "img/elements/contacts/add.png", self.elements.new_tab_element ):ibData( "alpha", 100 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self:SwitchTab( 2 )
                end )
                :ibOnHover( function( )
                    source:ibData( "alpha", 200 )
                end )
                :ibOnLeave( function( )
                    source:ibData( "alpha", 100 )
                end )

                if MESSAGE_CACHE and next( MESSAGE_CACHE ) then
                    self.elements.current_tab_scrollpane, self.elements.current_tab_scrollbar = ibCreateScrollpane( 0, 63, 204, 299, self.elements.new_tab_element, { scroll_px = -10, bg_color = 0 } )
                    self.elements.current_tab_scrollbar:ibData( "alpha", 0 )

                    local py = 0
                    for k, v in pairs( MESSAGE_CACHE ) do
                        local container = ibCreateImage( 0, py, 204, 52, _, self.elements.current_tab_scrollpane, 0x00FFFFFF )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                            
                            local ticks = getTickCount()
                            if ticks - self.ticks < 150 then return end
                            self.ticks = ticks
                            triggerServerEvent( "onServerPlayerSendSms", localPlayer, v.phone_number, "", true )
                        end )
                        :ibOnHover( function( )
                            source:ibData( "color", 0x55252F3B )
                        end )
                        :ibOnLeave( function( )
                            source:ibData( "color", 0x00FFFFFF )
                        end )

                        MESSAGE_CACHE[ k ].is_read = true
                        
                        local lbl = ibCreateLabel( 14, 10, 0, 0, v.player_nick, container, 0xFFFFFFFF, _, _, "left", "top", ibFonts.regular_10 )
                        ibCreateLabel( lbl:ibGetAfterX( 10 ), 11, 0, 0, v.last_msg, container, 0xAAFFFFFF, _, _, "left", "top", ibFonts.regular_9)
                        ibCreateLabel( 14, 26, 0, 0, utf8.sub( v.messages[ #v.messages ], 1, 16 ), container, 0xAAFFFFFF, _, _, "left", "top", ibFonts.regular_10 )
                        ibCreateImage( 0, 51, 204, 1, _, container, 0x55252F3B )
                        py = py + 52
                    end

                    onResourceStop_handler()

                    self.elements.current_tab_scrollpane:AdaptHeightToContents()
                    self.elements.current_tab_scrollbar:UpdateScrollbarVisibility( self.elements.current_tab_scrollpane )

                    SMS_COUNT = 0
                end

            end,

        },
        [ 2 ] = 
        {
            id = "new_sms",
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

                ibCreateLabel( 0, 77, 204, 0, "Введите номер", self.elements.new_tab_element, 0xFFFFFFFF - 0x55000000, _, _, "center", "top", ibFonts.regular_10 )
                
                self.elements.bg_edit = ibCreateImage( 14, 100, 176, 38, "img/elements/contacts/bg_edit_add_number.png", self.elements.new_tab_element )
                self.elements.edit_number = ibCreateEdit( 36, 0, 104, 40, "", self.elements.bg_edit, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF )
                self.elements.edit_number:ibBatchData( { font = ibFonts.regular_12, max_length = 7 } )

                if data and data.phone_number then
                    self.elements.edit_number:ibData( "text", data.phone_number )
                    self.elements.edit_number:ibData( "caret_position", 7 )
                end

                local btn_sel_contact = ibCreateImage( 45, 148, 115, 11, "img/elements/contacts/sel_contact.png", self.elements.new_tab_element ):ibData( "alpha", 128 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    self:CreateContactPopUp()
                end )
                :ibOnHover( function( )
                    source:ibData( "alpha", 255 )
                end )
                :ibOnLeave( function( )
                    source:ibData( "alpha", 128 )
                end )

                self.elements.bg_sms_edit = ibCreateImage( 14, 298, 176, 50, "img/elements/contacts/sms_area.png", self.elements.new_tab_element ):ibData( "alpha", 140 )
                self.elements.edit_sms = ibCreateEdit( 15, 5, 110, 40, "", self.elements.bg_sms_edit, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF )
                self.elements.edit_sms:ibBatchData( { font = ibFonts.regular_12 } )

                ibCreateButton( 150, 308, 30, 30, self.elements.new_tab_element, "img/elements/contacts/btn_send.png", "img/elements/contacts/btn_send_hover.png", "img/elements/contacts/btn_send_hover.png",
                    0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    local text_number = self.elements.edit_number:ibData( "text" )
                    local phone_number = tonumber( text_number )
                    local message = self.elements.edit_sms:ibData( "text" )
                    local real_len = string.gsub( message, "%s+", "" )                  
                    if utf8.len( text_number ) ~= 7 or not phone_number or utf8.len( message ) == 0 or utf8.len( message ) > 200 or #real_len == 0 then return end
                    
                    local ticks = getTickCount()
                    if ticks - self.ticks < 150 then return end
                    self.ticks = ticks
                    self.elements.edit_sms:ibData( "text", "" )
                    self.elements.edit_sms:ibData( "caret_position", 0 )   
                    triggerServerEvent( "onServerPlayerSendSms", localPlayer, phone_number, message, false, true )
                end )

            end,
        }
    },

    SwitchTab = function( self, id, data )
        self.current_tab = self.tabs[ id ]
        self.hsx, self.hsy = dxGetMaterialSize( self.elements[ "header_texture_" .. self.current_tab.id ] )

        if isElement( self.elements.new_tab_element ) then
            self.elements.new_tab_element:destroy()
        end

        local start_x = id >= self.current_tab_id and self.hsx * -1 or self.hsx
        self.current_tab_id = id

        self.elements.new_tab_element = ibCreateArea( start_x, 0, self.hsx, 317, self.elements.tab_rt ):ibMoveTo( 0, _, 150 )
        self.elements.header = ibCreateImage( 0, 0, self.hsx, self.hsy * self.conf.sx / self.hsx, self.elements[ "header_texture_" .. self.current_tab.id ], self.elements.new_tab_element, 0xFFFFFFFF )
                    
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

    create = function( self, parent, conf, hide_trigger )
        SMS_APP = self
        if not hide_trigger then
            triggerServerEvent( "onSmsListRequest", localPlayer )
        end

        self.parent = parent
        self.conf = conf

        self.elements.header_texture_sms = dxCreateTexture( "img/elements/sms_header.png" )
        self.elements.header_texture_new_sms = dxCreateTexture( "img/elements/new_sms_header.png" )

        return self
    end,

    create_secondary = function( self, parent, conf, contact_list )
        self.elements.tab_rt = ibCreateRenderTarget( 0, 0, 204, 362, parent )
        local phone_number = localPlayer:GetPhoneNumber()
        if not phone_number then
            ibCreateLabel( 0, 0, 204, 300, "Отсутствует сим карта", self.elements.tab_rt, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
            return
        end
        
        self.contact_list = contact_list
        self:SwitchTab( 1 )
    end,
    
    destroy = function( self, parent, conf )
        for i, v in pairs( self.elements ) do
            if isElement( v ) then destroyElement( v ) end 
            if isElement( i ) then destroyElement( i ) end 
        end
        SMS_APP = nil
    end,
}

function onSmsListRequestCallback_handler( contact_list, remove_list )
    RefreshMessageCacheByRemovedContacts( remove_list )
    RefreshRecentByRemovedContacts( remove_list )
    if not SMS_APP then return end
    SMS_APP:create_secondary( SMS_APP.parent, SMS_APP.conf, contact_list )
end
addEvent( "onSmsListRequestCallback", true )
addEventHandler( "onSmsListRequestCallback", root, onSmsListRequestCallback_handler )

local file_sms = "sms"
function LoadMessageCache()
    local serv = GetServerNumber()
    if not serv then return end
    local file_name = file_sms .. serv .. ".nrp"
    if fileExists( file_name ) then
        local file = fileOpen( file_name )
        local content_json = fileRead( file, fileGetSize( file ) )
        local content = content_json and fromJSON( content_json ) or { }
        for k, v in pairs( content ) do
            MESSAGE_CACHE[ tonumber( k ) or k ] = tonumber( v ) or v 
            if k == "is_read" then
                MESSAGE_CACHE[ k ].is_read = true
            end
        end
        fileClose( file )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, LoadMessageCache )

function LOGO_onClientPlayerNRPSpawn_handler( spawn_mode )
    if spawn_mode == 3 then return end
    LoadMessageCache()
    LoadPhoneApplications( )
end
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, LOGO_onClientPlayerNRPSpawn_handler )

function onResourceStop_handler()
    local file_name = file_sms .. GetServerNumber() .. ".nrp"
    if fileExists( file_name ) then fileDelete( file_name ) end
    local file = fileCreate( file_name )
    local content_json = toJSON( MESSAGE_CACHE, true )
    fileWrite( file, content_json )
    fileClose( file )
end
addEventHandler( "onClientResourceStop", resourceRoot, onResourceStop_handler )

function GetServerNumber()
    local data = localPlayer:getData( "_srv" )
    return data and data[ 1 ] or false
end

function RefreshMessageCacheByRemovedContacts( remove_list )
    if remove_list and next( remove_list ) then
        for k, v in pairs( remove_list ) do
            if MESSAGE_CACHE[ v.player_id ] then
                table.remove( MESSAGE_CACHE, v.player_id )
            end
        end
        onResourceStop_handler()
    end
end

function onClientReceivePrivateMessage_handler( message_data )

    if message_data.message == "" then return end

    local src_player_nick = "Вы: "
    local is_read = true
    if message_data.src ~= localPlayer:GetUserID() then
        src_player_nick = ""
        is_read = false
    end
    local time = getRealTime()
    local last_msg = string.format( "%02d:%02d ", time.hour, time.minute )
    if not MESSAGE_CACHE[ message_data.player_id ] then 
        MESSAGE_CACHE[ message_data.player_id ] = 
        {
            player_id    = message_data.player_id,
            player_nick  = message_data.player_nick,
            phone_number = message_data.phone_number,
            messages     = { src_player_nick .. message_data.message },
            last_msg =  last_msg,
            timestamp = getRealTimestamp(),
            is_read = is_read,
        }
    else
        MESSAGE_CACHE[ message_data.player_id ].last_msg = last_msg
        MESSAGE_CACHE[ message_data.player_id ].timestamp = getRealTimestamp()
        MESSAGE_CACHE[ message_data.player_id ].is_read = is_read
        table.insert( MESSAGE_CACHE[ message_data.player_id ].messages, src_player_nick .. message_data.message )
        if #MESSAGE_CACHE[ message_data.player_id ].messages > 10 then
            table.remove( MESSAGE_CACHE[ message_data.player_id ].messages, 1 )
        end
    end

    
    if message_data.src ~= localPlayer:GetUserID() then
        local chat_exist = exports.nrp_handler_chat:IsPrivateChatExist( message_data.src )
        if chat_exist then
            SMS_SOUND = playSound( "sound/message/" .. PHONE_CURRENT_SOUNDS.message .. ".wav" )
            setSoundVolume( SMS_SOUND, SETTINGS.notifications or 0.4 )
        end
    end

    table.sort( MESSAGE_CACHE, function( a, b )
        return ( a and b ) and a.timestamp > b.timestamp or false
    end )
    onResourceStop_handler()

    SMS_COUNT = 0
    for k, v in pairs( MESSAGE_CACHE ) do
        if not v.is_read then
            SMS_COUNT = SMS_COUNT + 1
        end
    end

end
addEvent( "onClientReceivePrivateMessage", true )
addEventHandler( "onClientReceivePrivateMessage", root, onClientReceivePrivateMessage_handler )