
function ShowActiveChat( state, data )
    if state then
        ShowActiveChat( false )

        UI_elements = {}
        UI_elements.bg = ibCreateImage( 20, 100, 450, 370, "img/bg_container.png" ):ibData( "priority",-10 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end

                CHAT_SETTING.select_chat_list = false
                ShowDropdownListChat( CHAT_SETTING.select_chat_list )
            end )

        UI_elements.btn_dropdown_chat_list = ibCreateButton( 328, 0, 38, 40, UI_elements.bg, "img/btn_more_dummy.png" )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" or #CHAT_CHANNELS < 5 then return end
                ibClick()
                CHAT_SETTING.select_chat_list = not CHAT_SETTING.select_chat_list
                ShowDropdownListChat( CHAT_SETTING.select_chat_list )
            end )


        ibCreateButton( 379, 8, 24, 24, UI_elements.bg, "img/btn_setting.png", "img/btn_setting_hovered.png", "img/btn_setting_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xAACCCCCC )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                
                ibClick()
                ShowMenuSetting( not isElement( UI_elements.bg_setting ) )
            end )

        local func_get_help_keys_chat_list = function()
            local str = "Горячие клавиши чата: "
            for i = 1, 4 do
                if CHAT_CHANNELS[ i ] then
                    str = str .. "\nCTRL + " .. i .. " - " .. CHAT_CHANNELS_NAME[ CHAT_CHANNELS[ i ].channel_id ] .. " чат"
                end
            end
            return str
        end

        ibCreateImage( 416, 8, 24, 24, "img/btn_question.png", UI_elements.bg )
            :ibOnHover( function()
                source:ibData( "texture", "img/btn_question_hovered.png" )
            end )
            :ibOnLeave( function()
                source:ibData( "texture", "img/btn_question.png" )
            end )
            :ibAttachTooltip( func_get_help_keys_chat_list(), _, "left", "center" )


        UI_elements.edf_message = ibCreateEdit( 23, 316, 337, 38, "", UI_elements.bg, COLOR_WHITE, 0x00000000, COLOR_WHITE ):ibData( "font", ibFonts.regular_14 )

        ibCreateButton( 370, 320, 60, 30, UI_elements.bg, "img/btn_send.png" )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end

                SendMessageToServer()
            end )

        UI_elements.lbl_send_restriction = ibCreateLabel( 20, 315, 230, 38, "Сообщение можно будет отправить через - 60 сек.", UI_elements.bg, 0xFFFF5151, 1, 1, "left", "center", ibFonts.regular_12 )
        :ibData( "alpha", 0 )
        :ibData( "disabled", true )

	    UI_elements.edf_message:ibTimer( function( self )
            if CheckBlockCurrentChannel() then return end
            self:ibData( "max_length", CHAT_SETTING.max_messsage_len )
            self:ibData( "focused", true )
        end, 150, 1 )    
        
        UI_elements.key_action_close = ibAddKeyAction( _, _, UI_elements.bg, function()
            if CHAT_SETTING.active_state then
                NextMessage()
            end
        end )

        guiSetInputMode( "no_binds" )

        showCursor( true, not localPlayer:getData( "bFirstPerson" ) )
        triggerEvent( "onClientChangeInterfaceState", root, true, { open_chat = true } )
        
        SwitchChatChannel( CHAT_SETTING.current_channel_id )
        RefreshBlockedInfo( CHAT_SETTING.current_channel_id )

        RefillActiveChatChannels()
        RefillActiveChatMessages()
    elseif isElement( UI_elements and UI_elements.bg ) then
        UI_elements.key_action_close:destroy()
        ShowMenuSetting( false )
        
        destroyElement( UI_elements.bg )
        UI_elements = nil
        showCursor( false, not localPlayer:getData( "bFirstPerson" ) )

        guiSetInputMode( "no_binds_when_editing" )
        triggerEvent( "onClientChangeInterfaceState", root, false, { open_chat = true } )
    end
end

function RefreshStatesActiveChat( old_channel_id, new_channel_id )
    if not UI_elements or not UI_elements.bg then return end

    RefreshBlockedInfo( new_channel_id )

    if isElement( UI_elements[ "chat_lbl_" .. old_channel_id ] ) then
        UI_elements[ "chat_lbl_" .. old_channel_id ]:ibData( "color", 0x96FFFFFF )
    end

    if isElement( UI_elements[ "chat_lbl_" .. new_channel_id ] ) then
        UI_elements[ "chat_lbl_" .. new_channel_id ]:ibData( "color", 0xFFFFFFFF )
    end

    if isElement( UI_elements.chat_containers[ old_channel_id ] ) then
        UI_elements.chat_containers[ old_channel_id ]:ibData( "texture", "img/tab_passive.png" )
    end

    if isElement( UI_elements[ "chat_active_" .. old_channel_id ] ) then
        UI_elements[ "chat_active_" .. old_channel_id ]:ibData( "alpha", 0 )
    end

    if isElement( UI_elements[ "chat_active_" .. new_channel_id ] ) then
        UI_elements[ "chat_active_" .. new_channel_id ]:ibData( "alpha", 255 )
    end

    if isElement( UI_elements.chat_containers[ new_channel_id ] ) then
        UI_elements.chat_containers[ new_channel_id ]:ibData( "texture", "img/tab_active.png" )
    end
end

function RefreshBlockedInfo( target_channel_id )
    local channel_id = target_channel_id or CHAT_SETTING.current_channel_id
    local blocked_time = CHAT_SETTING.blocked_channels[ target_channel_id ]
    
    if blocked_time and getTickCount() - blocked_time < CHAT_SETTING.blocked_time then
        local lost_time = math.floor(CHAT_SETTING.blocked_time / 1000 - (getTickCount() - blocked_time) / 1000 ) + 1
        UI_elements.lbl_send_restriction
            :ibAlphaTo( 255, 150 )
            :ibTimer( function()
                local lost_time = math.floor(CHAT_SETTING.blocked_time / 1000 - (getTickCount() - blocked_time) / 1000 )
                if lost_time > 0 then
                    UI_elements.lbl_send_restriction:ibData( "text", "Сообщение можно будет отправить через - " .. lost_time .. " сек.")
                else
                    UI_elements.lbl_send_restriction:ibData( "alpha", 0 )
                end
            end, 1000, lost_time )
    else
        UI_elements.lbl_send_restriction:ibData( "alpha", 0 )
    end
end

function ShowDropdownListChat( state )
    if state then
        ShowDropdownListChat( false )

        local sy = (#CHAT_CHANNELS - 4) * 44
        UI_elements.dropdown_area = ibCreateArea( 158, 43, 198, sy, UI_elements.bg ):ibData( "priority", 10 )
        ibCreateImage( 184, 0, 10, 5, "img/icon_triangle.png", UI_elements.dropdown_area )

        local dropdown_menu_chats = ibCreateImage( 0, 5, 198, sy, _, UI_elements.dropdown_area, 0xFF4E5F73 )
        local start_dropdown_chat_num = 5
        for k = start_dropdown_chat_num, #CHAT_CHANNELS do
            local channel_id = CHAT_CHANNELS[ k ].channel_id
            local chat_container = ibCreateArea( 0, (k - 5) * 44, 198, 44, dropdown_menu_chats )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    ibClick()
                    SwitchChatChannel( channel_id )
                
                    CHAT_SETTING.select_chat_list = false
                    ShowDropdownListChat( CHAT_SETTING.select_chat_list )
                end )
                :ibOnHover( function()
                    if CHAT_SETTING.current_channel_id == channel_id then return end
                    UI_elements[ "chat_lbl_" .. channel_id ]:ibData( "color", 0xFFFFFFFF )
                end )
                :ibOnLeave( function( )
                    if CHAT_SETTING.current_channel_id == channel_id then return end
                    UI_elements[ "chat_lbl_" .. channel_id ]:ibData( "color", 0x96FFFFFF )
                end )

            local chat_color = CHAT_SETTING.current_channel_id == channel_id and 0xFFFFFFFF or 0x96FFFFFF
            UI_elements[ "chat_lbl_" .. channel_id ] = ibCreateLabel( 17, 0, 198, 43, CHAT_CHANNELS_NAME[ channel_id ], chat_container, chat_color, 1, 1, "left", "center", ibFonts.regular_12 )
            :ibData( "disabled", true )
        
            UI_elements[ "chat_active_" .. channel_id ] = ibCreateImage( 195, 15, 3, 15, _, chat_container, 0xFF86A2C4 ):ibData( "alpha", CHAT_SETTING.current_channel_id == channel_id and 255 or 0 )

            if k > start_dropdown_chat_num then 
                UI_elements[ "start_line" .. channel_id ] = ibCreateImage( 0, 0, 198, 1, _, chat_container, 0xFF465567 )
            end
        end
    elseif isElement( UI_elements and UI_elements.dropdown_area ) then
        destroyElement( UI_elements.dropdown_area )
    end
end

function RefillActiveChatMessages()
    if not UI_elements or not UI_elements.bg then return end

    if UI_elements.message_panel then
        destroyElement( UI_elements.message_panel )
        destroyElement( UI_elements.message_scroll )
    end

    UI_elements.message_panel, UI_elements.message_scroll = ibCreateScrollpane( 0, 55, 425, 250, UI_elements.bg, { scroll_px = 0 } )
    UI_elements.message_scroll:ibSetStyle( "slim_small_nobg" ):ibBatchData( { sensivity = 60, absolute = true, color = 0x99ffffff } )

    local py = 0
    local last_line = false
    local count_output_messages = GetCacheMessages( CHAT_SETTING.current_channel_id )
    for k, v in pairs( count_output_messages ) do
        local is_cur_channel = CHAT_SETTING.current_channel_id == v.channel_id
        local sy = (is_cur_channel and v.string_count or v.string_count_other_channel) * 20
        local msg_lbl = ibCreateLabel( 20, py, 420, sy, is_cur_channel and v.message or v.message_other_channel, UI_elements.message_panel, v.color, _, _, "left", "top", ibFonts.regular_14 )
        last_line = ibCreateImage( 20, py + sy + 5, 420, 1, _, UI_elements.message_panel, 0xFF3a4147 )
        py = py + sy + 10
    end

    if isElement( last_line ) then destroyElement( last_line ) end

    UI_elements.message_panel:AdaptHeightToContents()
    UI_elements.message_scroll:UpdateScrollbarVisibility( UI_elements.message_panel )  
    
    UI_elements.message_scroll:ibData( "position", 1 )
end


function RefillActiveChatChannels()
    if not UI_elements or not UI_elements.bg then return end

    for k, v in pairs( UI_elements.chat_containers or {} ) do
        destroyElement( v )
    end
    UI_elements.chat_containers = {}

    local px = 0
    local chat_count = #CHAT_CHANNELS
    for k = 1, math.max( 4, math.min( 4, chat_count ) ) do
        local channel_id = CHAT_CHANNELS[ k ] and CHAT_CHANNELS[ k ].channel_id
        if k <= 4 and channel_id then
            local texture = channel_id == CHAT_SETTING.current_channel_id and "img/tab_active.png" or "img/tab_passive.png"
            UI_elements.chat_containers[ channel_id ] = ibCreateImage( (k - 1) * 82, 0, 80, 40, texture, UI_elements.bg )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    ibClick()
                    SwitchChatChannel( channel_id )

                    CHAT_SETTING.select_chat_list = false
                    ShowDropdownListChat( CHAT_SETTING.select_chat_list )
                end )
                :ibOnHover( function()
                    if CHAT_SETTING.current_channel_id == channel_id then return end
                    UI_elements[ "chat_lbl_" .. channel_id ]:ibData( "color", 0xFFFFFFFF )
                end )
                :ibOnLeave( function( )
                    if CHAT_SETTING.current_channel_id == channel_id then return end
                    UI_elements[ "chat_lbl_" .. channel_id ]:ibData( "color", 0x96FFFFFF )
                end )

            local channel_name = utf8.sub( CHAT_CHANNELS_NAME[ channel_id ], 1, 8 )
            local chat_color = CHAT_SETTING.current_channel_id == channel_id and 0xFFFFFFFF or 0x96FFFFFF
            UI_elements[ "chat_lbl_" .. channel_id ] = ibCreateLabel( 0, 0, 80, 40, channel_name, UI_elements.chat_containers[ channel_id ], chat_color, 1, 1, "center", "center", ibFonts.regular_12 ):ibData( "disabled", true )
        else
            ibCreateImage( (k - 1) * 82, 0, 80, 40, "img/tab_dummy.png", UI_elements.bg )
        end
    end

    if chat_count > 4 then
        UI_elements.btn_dropdown_chat_list:ibBatchData({ 
            texture = "img/btn_more.png",
            texture_hover = "img/btn_more_hovered.png",
            texture_click = "img/btn_more_hovered.png",
        } )
    else
        UI_elements.btn_dropdown_chat_list:ibBatchData({ 
            texture = "img/btn_more_dummy.png",
            texture_hover = "img/btn_more_dummy.png",
            texture_click = "img/btn_more_dummy.png",
        } )
    end
end

function ShowPassiveChat( state )
    if state then
        ShowPassiveChat( false )
        
        UI_elements = {}
        UI_elements.bg_passive = ibCreateArea( 20, 100, 450, 320 ):ibBatchData( { alpha = 0, disabled = true, priority = -11 } )
        RefillPassiveChatMessages()

    elseif isElement( UI_elements and UI_elements.bg_passive ) then
        destroyElement( UI_elements.bg_passive )
        if isTimer( UI_elements.tmr_hide ) then killTimer( UI_elements.tmr_hide ) end
        UI_elements = nil
    end
end

function RefillPassiveChatMessages()
    if not UI_elements or not UI_elements.bg_passive then return end

    if isTimer( UI_elements.tmr_hide ) then killTimer( UI_elements.tmr_hide ) end
    
    if UI_elements.message_panel then
        destroyElement( UI_elements.message_panel )
        destroyElement( UI_elements.message_scroll )
    end

    UI_elements.message_panel, UI_elements.message_scroll = ibCreateScrollpane( 0, 0, 425, 250, UI_elements.bg_passive )
    UI_elements.message_scroll:ibData( "alpha", 0 )

    local string_count = 0
    local output_messages = {}
    local target_messages = GetCacheMessages( CHAT_SETTING.current_channel_id )

    local count_target_messages = #target_messages
    if count_target_messages > 0 then
        for i = count_target_messages, 1, -1 do
            local message_data = target_messages[ i ]
            local is_cur_channel = CHAT_SETTING.current_channel_id == message_data.channel_id

            string_count = string_count + (is_cur_channel and message_data.string_count or message_data.string_count_other_channel)
            if string_count > 10 then break end

            table.insert( output_messages, message_data )
        end
    end

    local count_output_messages = #output_messages
    if count_output_messages > 0 then
        local py = 0
        for i = count_output_messages, 1, -1 do
            local message_data = output_messages[ i ]
            local is_cur_channel = CHAT_SETTING.current_channel_id == message_data.channel_id
            local string_count = (is_cur_channel and message_data.string_count or message_data.string_count_other_channel)
            local sy = string_count * 20
            local msg_lbl = ibCreateLabel( 20, py, 420, sy, is_cur_channel and message_data.message or message_data.message_other_channel, UI_elements.message_panel, message_data.color, nil, nil, "left", "top", ibFonts.regular_14 )
            py = py + sy + 10 - ((string_count) * 1.5)
        end
    end

    UI_elements.message_panel:AdaptHeightToContents()
    UI_elements.message_scroll:UpdateScrollbarVisibility( UI_elements.message_panel ):ibData( "position", 1 )

    UI_elements.bg_passive:ibData( "alpha", 255 )
    UI_elements.tmr_hide = setTimer( function()
        UI_elements.bg_passive:ibAlphaTo( 0, 150 )
    end, 60 * 1000, 1 )
end

addEventHandler("onClientKey", root, function( key, state )
    if getKeyState("lctrl") and state then
        local chat_number = tonumber( key )
        if chat_number and chat_number <= #CHAT_CHANNELS then
            CHAT_SETTING.select_chat_list = false
            ShowDropdownListChat( CHAT_SETTING.select_chat_list )
            
            SwitchChatChannel( CHAT_CHANNELS[ chat_number ].channel_id )
            return
        end
    end

    if not UI_elements or not UI_elements.edf_message then return end

    if (key == "enter" or key == "num_enter") and state and CHAT_SETTING.active_state then
        SendMessageToServer()
        return true
    elseif key == "lctrl" and CHAT_SETTING.active_state then
        local chat_number = 1
        for k, v in ipairs( CHAT_CHANNELS ) do
            UI_elements[ "chat_lbl_" .. v.channel_id ]:ibData( "text", state and ("[CTRL + " .. chat_number .. "]") or CHAT_CHANNELS_NAME[ v.channel_id ])

            chat_number = chat_number + 1
            if chat_number > 4 then return end
        end
    end
end, true, "low-100000" )
