
local UI_elements = nil

function ShowIngameDrawMainUI( state, data )
    if state then
        ShowIngameDrawMainUI( false )

        UI_elements = {}

        UI_elements.black_bg = ibCreateBackground( 0xBF1D252E, nil, nil ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
        UI_elements.bg_rt = ibCreateRenderTarget( 0, 0, 1024, 720, UI_elements.black_bg ):center()
        UI_elements.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI_elements.bg_rt )
        
        local lost_time_in_sec = (OFFER_END_DATE - getRealTimestamp())
        local lost_days = math.floor(lost_time_in_sec / 86400)
        local timer_icon = ibCreateImage(lost_days > 0 and 669 or 631, 32, 214, 24, "img/timer.png", UI_elements.bg )
        if lost_days > 0 then
            local time_days_lbl = ibCreateLabel( timer_icon:ibGetAfterX(), 34, 100, 40, lost_days, UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
            ibCreateLabel( time_days_lbl:ibGetAfterX(), 35, 100, 40, plural( lost_days, " день ", " дня ", " дней " ), UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.regular_16 )
        else
            local hours = math.floor(lost_time_in_sec / 3600)
            local minutes = math.floor( (lost_time_in_sec - hours * 3600) / 60 )
            
            local time_hour_lbl = ibCreateLabel( timer_icon:ibGetAfterX(), 34, 100, 40, string.format("%02d", hours ), UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
            ibCreateLabel( time_hour_lbl:ibGetAfterX( 3 ), 35, 100, 40, "ч.", UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.regular_16 )

            local time_minutes_lbl = ibCreateLabel( timer_icon:ibGetAfterX( 40 ), 34, 100, 40, string.format("%02d", minutes ), UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
            ibCreateLabel( time_minutes_lbl:ibGetAfterX( 3 ), 35, 100, 40, "мин.", UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.regular_16 )
        end

        ibCreateButton( 972, 35, 22, 22, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowIngameDrawMainUI( false )
            end )
            
        if data.remaining_time == -1 then
            UI_elements.btn_paricipate = ibCreateButton( 413, 642, 198, 61, UI_elements.bg, "img/btn_participate.png", "img/btn_participate_hover.png", "img/btn_participate_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    UI_elements.btn_paricipate
                        :ibData( "disabled", true )
                        :ibAlphaTo( 0, 250 )
                        :ibTimer( function()
                            ibCreateLabel( 0, 658, 1024, 43, "ТЫ УЧАСТВУЕШЬ", UI_elements.bg, 0xFFDADDE1, nil, nil, "center", "top", ibFonts.bold_16 )
                        end, 250, 1 )
                        
                    triggerServerEvent( "onServerPlayerTryParticipateIngameDraw", resourceRoot )
                    
                    UI_elements.bg_condition_2_lbl:destroy()
                    UI_elements.bg_condition_2_desc_lbl:destroy()
                    UI_elements.bg_condition_2_desc_lbl_1:destroy()

                    UI_elements.bg_condition_2_lbl = ibCreateLabel( 64, 16, 160, 0, "Ты отыграл:", UI_elements.bg_condition_2, 0xFFB6BABF, nil, nil, "center", "top", ibFonts.regular_14 )
                    UI_elements.bg_condition_2_desc_lbl = ibCreateLabel( 66, 43, 160, 0, "00:00", UI_elements.bg_condition_2, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_18 )

                    UI_elements.bg_condition_3 = ibCreateImage( 1319, 171, 258, 78, "img/bg_condition_3.png", UI_elements.bg )
                    UI_elements.bg_condition_3_lbl_1 = ibCreateLabel( 37, 44, 160, 0, "Выполни", UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.bold_14 )
                    UI_elements.bg_condition_3_lbl_2 = ibCreateLabel( UI_elements.bg_condition_3_lbl_1:ibGetAfterX( 8 ), 44, 160, 0, "2", UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_14 )
                    UI_elements.bg_condition_3_lbl_3 = ibCreateLabel( UI_elements.bg_condition_3_lbl_2:ibGetAfterX( 24 ), 44, 160, 0, "пункт", UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.bold_14 )
                    
                    UI_elements.bg_condition_1:ibMoveTo( -624, nil, 500 )
                    UI_elements.bg_condition_2:ibMoveTo( 71, nil, 500 )
                    UI_elements.bg_condition_3:ibMoveTo( 695, nil, 500 )
                end )

            UI_elements.bg_condition_1 = ibCreateImage( 71, 171, 258, 78, "img/bg_condition_1.png", UI_elements.bg )
            UI_elements.bg_condition_2 = ibCreateImage( 695, 171, 258, 78, "img/bg_condition_2.png", UI_elements.bg )
            UI_elements.bg_condition_2_lbl = ibCreateLabel( 68, 17, 160, 0, "Отыграй в игре", UI_elements.bg_condition_2, 0xFFB6BABF, nil, nil, "center", "top", ibFonts.regular_14 )
            
            UI_elements.bg_condition_2_desc_lbl = ibCreateLabel( 66, 45, 115, 0, CONST_INGAME_TIME_HOURS, UI_elements.bg_condition_2, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_14 )
            UI_elements.bg_condition_2_desc_lbl_1 = ibCreateLabel( 87, 45, 135, 0, plural( CONST_INGAME_TIME_HOURS, " час ", " часа ", " часов " ), UI_elements.bg_condition_2, nil, nil, nil, "center", "center", ibFonts.bold_14 )
        elseif data.remaining_time > 0 then
            UI_elements.bg_condition_2 = ibCreateImage( 71, 171, 258, 78, "img/bg_condition_2.png", UI_elements.bg )
            UI_elements.bg_condition_2_lbl = ibCreateLabel( 64, 16, 160, 0, "Ты отыграл:", UI_elements.bg_condition_2, 0xFFB6BABF, nil, nil, "center", "top", ibFonts.regular_14 )
            
            local play_time_in_sec = CONST_INGAME_TIME_HOURS * 60 * 60 - (data.remaining_time)
            local hours = math.floor(play_time_in_sec / 3600)
            local minutes = math.floor( (play_time_in_sec - hours * 3600) / 60 )
            UI_elements.bg_condition_2_desc_lbl = ibCreateLabel( 66, 43, 160, 0, string.format("%02d:%02d", hours, minutes ), UI_elements.bg_condition_2, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_18 )
                :ibTimer( function()
                    UI_elements.bg_condition_3_lbl_1:destroy()
                    UI_elements.bg_condition_3_lbl_2:destroy()
                    UI_elements.bg_condition_3_lbl_3:destroy()

                    ibCreateLabel( 68, 44, 160, 0, format_price( tonumber( data.ticket_code ) ), UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_18 )
                    UI_elements.bg_condition_4 = ibCreateImage( 1319, 171, 258, 78, "img/bg_condition_4.png", UI_elements.bg )
                    
                    UI_elements.bg_condition_2:ibMoveTo( -624, nil, 500 )
                    UI_elements.bg_condition_3:ibMoveTo( 71, nil, 500 )
                    UI_elements.bg_condition_4:ibMoveTo( 695, nil, 500 )
                end, data.remaining_time * 1000, 1 )

            UI_elements.bg_condition_3 = ibCreateImage( 695, 171, 258, 78, "img/bg_condition_3.png", UI_elements.bg )
            UI_elements.bg_condition_3_lbl_1 = ibCreateLabel( 37, 44, 160, 0, "Выполни", UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.bold_14 )
            UI_elements.bg_condition_3_lbl_2 = ibCreateLabel( UI_elements.bg_condition_3_lbl_1:ibGetAfterX( 8 ), 44, 160, 0, "2", UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_14 )
            UI_elements.bg_condition_3_lbl_3 = ibCreateLabel( UI_elements.bg_condition_3_lbl_2:ibGetAfterX( 24 ), 44, 160, 0, "пункт", UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.bold_14 )
        elseif data.ticket_code and data.remaining_time == 0 then
            UI_elements.bg_condition_3 = ibCreateImage( 71, 171, 258, 78, "img/bg_condition_3.png", UI_elements.bg )
            ibCreateImage( 695, 171, 258, 78, "img/bg_condition_4.png", UI_elements.bg )
            ibCreateLabel( 68, 44, 160, 0, format_price( tonumber( data.ticket_code ) ), UI_elements.bg_condition_3, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_18 )
        end

        if data.remaining_time ~= -1 then
            ibCreateLabel( 0, 658, 1024, 43, "ТЫ УЧАСТВУЕШЬ", UI_elements.bg, 0xFFDADDE1, nil, nil, "center", "top", ibFonts.bold_16 )
        end

        UI_elements.bg_computer_details = ibCreateImage( 560, 157, 332, 303, "img/bg_computer_details.png", UI_elements.bg ):ibBatchData( { alpha = 0, priority = 1000 } )
        UI_elements.func_interpolate = function( element, value )
            local px, py = element:ibData( "px" ), element:ibData( "py" )
            local sx, sy = element:ibData( "sx" ), element:ibData( "sy" )
            element:ibInterpolate( function( self_interpolate )
                local delta = value * self_interpolate.easing_value
                self_interpolate.element:ibBatchData( { px = px - delta / 2, py = py - delta / 2, sx = sx + delta, sy = sy + delta } )
            end, 500, "Linear" )
        end

        UI_elements.info_icon = ibCreateImage( 711, 123, 28, 28, "img/info_icon.png", UI_elements.bg )
            :ibOnHover( function( )
                UI_elements.bg_computer_details:ibAlphaTo( 255, 250 )
            end )
            :ibOnLeave( function( )
                UI_elements.bg_computer_details:ibAlphaTo( 0, 250 )
            end )
            :ibData( "direction", 1 )
            :ibTimer( function( self )
                local direction = UI_elements.info_icon:ibData( "direction" )
                UI_elements.info_icon:ibData( "direction", direction == 1 and 0 or 1 )
                UI_elements.func_interpolate( UI_elements.info_icon, direction == 1 and 5 or -5 )
            end, 550, 0 )

        local func_show_rewards = function()
            local anim_duration = 250

            UI_elements.bg_rewards_rt = ibCreateRenderTarget( 0, 80, 1024, 640, UI_elements.bg ):ibData( "priority", 1000 )
            local bg_rewards = ibCreateImage( 0, -640, 1024, 640, "img/overlay_rewards.png", UI_elements.bg_rewards_rt ):ibMoveTo( 0, 0, anim_duration )

            ibCreateButton( 29, 13, 103, 17, bg_rewards, "img/btn_back.png", "img/btn_back.png", "img/btn_back.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    
                    ibClick( )
                    if UI_elements.bg_rewards_rt:ibData( "moved" ) then return end

                    UI_elements.bg_rewards_rt:ibData( "moved", true )
                    
                    bg_rewards:ibMoveTo( 0, - bg_rewards:ibData( "sy" ), anim_duration )
                    bg_rewards:ibTimer( function()
                        destroyElement( UI_elements.bg_rewards_rt )
                        UI_elements.bg_rewards_rt = nil
                    end, anim_duration, 1 )

                    ibOverlaySound()
                end )

            local hint_area = ibCreateArea( 617, 489, 90, 90, bg_rewards ):ibAttachTooltip("Ремкомплект и канистра выдается\nвсем участникам, кто отыграл 30 часов")

            ibOverlaySound()
        end
        
        ibCreateButton( 393, 579, 238, 61, UI_elements.bg, "img/btn_details.png", "img/btn_details_hover.png", "img/btn_details_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                if isElement( UI_elements.bg_rewards_rt ) then return end

                func_show_rewards()
            end )


        showCursor( true )
    elseif IsUIActive() then
        destroyElement( UI_elements.black_bg )
        showCursor( false )
        UI_elements = nil
    end
end

function ShowIngameDrawContactsUI( state, data )
    if state then
        ShowIngameDrawMainUI( false )
        ShowIngameDrawContactsUI( false )

        UI_elements = {}

        UI_elements.black_bg = ibCreateBackground( 0xBF1D252E, nil, nil ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
        UI_elements.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg_contact.png", UI_elements.black_bg ):center()

        UI_elements.func_show_dropdown_contact_type_list = function()
            if isElement( UI_elements.bg_contact_list ) then
                destroyElement( UI_elements.bg_contact_list )
                return
            end

            local contact_type_list = { 
                { type = "email",    text = "E-mail",   py = 1  }, 
                { type = "discord",  text = "Discord",  py = 0  }, 
                { type = "vk",       text = "Vk.com",   py = 2  }, 
                { type = "telegram", text = "Telegram", py = -2 }, 
                { type = "whatsapp", text = "WhatsApp", py = -3 },
            }
            UI_elements.bg_contact_list = ibCreateImage( 241, 344, 530, 241, "img/bg_contact_list.png", UI_elements.bg )

            local px, py = 405, 19
            for k, v in ipairs( contact_type_list ) do
                if UI_elements.selected_contact == v.type then
                    ibCreateImage( px + 34, py + 7, 14, 12, "img/arrow_selected.png", UI_elements.bg_contact_list )
                else
                    ibCreateButton( px, py, 80, 27, UI_elements.bg_contact_list, "img/btn_select.png", "img/btn_select_hover.png", "img/btn_select_hover.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            
                            if not UI_elements.selected_contact then
                                UI_elements.select_type_contact_lbl:ibData( "color", 0xFFFFFFFF )
                                UI_elements.btn_select_type_contact:ibBatchData( { color = 0x00000000, color_hover = 0x00000000, color_click = 0x00000000 } )
                                UI_elements.type_icon = ibCreateImage( 70 - utf8.len( v.text ) * 7, v.py or 0, 0, 0, "img/" .. v.type .. "_icon.png", UI_elements.btn_select_type_contact ):ibSetRealSize()
                            else
                                UI_elements.type_icon:ibBatchData( { texture = "img/" .. v.type .. "_icon.png", px = 70 - utf8.len( v.text ) * 7 , py = v.py or 0 } ):ibSetRealSize()
                            end
                            
                            UI_elements.selected_contact = v.type
                            UI_elements.select_type_contact_lbl:ibData( "text", v.text )
                            UI_elements.func_show_dropdown_contact_type_list()
                        end )
                end
                py = py + 43
            end
        end

        UI_elements.btn_select_type_contact = ibCreateButton( 424, 304, 190, 17, UI_elements.bg, "img/btn_select_contact_type.png", "img/btn_select_contact_type.png", "img/btn_select_contact_type.png", 0xFF99A0AA, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                UI_elements.func_show_dropdown_contact_type_list()
            end )
            :ibOnHover( function()
                if UI_elements.selected_contact then return end
                UI_elements.select_type_contact_lbl:ibData( "color", 0xFFFFFFFF )
            end )
            :ibOnLeave( function()
                if UI_elements.selected_contact then return end
                UI_elements.select_type_contact_lbl:ibData( "color", 0xFF99A0AA )
            end )

        UI_elements.select_type_contact_lbl = ibCreateLabel( 0, 0, 170, 17, "Выбери тип контакта", UI_elements.btn_select_type_contact, 0xFF99A0AA, _, _, "center", "center", ibFonts.regular_16 ):ibData( "disabled", true )


        UI_elements.dummy_contact_name = ibCreateLabel( 333, 367, 346, 66, "Заполни поле", UI_elements.bg, 0xFFAAAAAA, _, _, "center", "center", ibFonts.regular_16 ):ibData( "disabled", true )
        UI_elements.edf_lobby_name = ibCreateEdit( 333, 380, 346, 40, "", UI_elements.bg, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF )
            :ibBatchData( { font = ibFonts.regular_16, align_x = "center" } )
            :ibOnClick( function()
                if isElement( UI_elements.dummy_contact_name  ) then destroyElement( UI_elements.dummy_contact_name  ) end
            end )
            :ibOnDataChange( function( key, value )
                if key ~= "text" then return end
                UI_elements.contact_text = value
            end )

        ibCreateButton( 391, 439, 230, 90, UI_elements.bg, "img/btn_send.png", "img/btn_send_hover.png", "img/btn_send_hover.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                if not UI_elements.selected_contact then
                    localPlayer:ShowError( "Не выбран тип контакта" )
                    return false
                end

                if not UI_elements.contact_text or utf8.len( UI_elements.contact_text ) == 0 then
                    localPlayer:ShowError( "Не заполнено поле контакта" )
                    return false
                end

                local is_contact_valide, error_text = IsContactDataValid( UI_elements.selected_contact, UI_elements.contact_text )
                if not is_contact_valide then
                    localPlayer:ShowError( "Данные контакта некорректны" .. (error_text and ("\nПример заполнения: " .. error_text) or "") )
                    return false
                end

                triggerServerEvent( "onServerPlayerSelectedContact", resourceRoot, UI_elements.selected_contact, UI_elements.contact_text )
                ShowIngameDrawContactsUI( false )
            end )

        showCursor( true )
    elseif IsUIActive() then
        destroyElement( UI_elements.black_bg )
        showCursor( false )
        UI_elements = nil
    end
end

function IsUIActive()
    return isElement( UI_elements and UI_elements.black_bg )
end