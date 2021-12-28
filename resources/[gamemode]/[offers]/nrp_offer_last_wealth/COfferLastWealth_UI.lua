

local UI_elements

function ShowOfferLastWealth( state, data )
    if state then
        ShowOfferLastWealth( false )
        
        UI_elements = {}
        UI_elements.black_bg = ibCreateBackground( 0x00000000, ShowOfferLastWealth, _, true ):ibData( "alpha", 0 )
        UI_elements.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI_elements.black_bg ):center( )

        UI_elements.construct_time_lbl = function( self, time_left )
            local f_time, f_time_u, s_time, s_time_u = nil, nil, nil, nil
            
            local diff_time = CONST_OFFER_END_DATE - getRealTimestamp()
            local days_time_left = math.floor( diff_time / 86400 )
            if days_time_left > 0 then
                f_time = days_time_left
                f_time_u = "д."

                s_time = math.floor( (diff_time - days_time_left * 86400) / 3600 )
                s_time = s_time > 0 and s_time or nil
                s_time_u = s_time and "ч."
            else
                f_time = math.floor( (diff_time - days_time_left * 86400) / 3600 )
                if f_time > 0 then
                    f_time_u = "ч."

                    s_time = math.floor( (diff_time - f_time * 3600) / 60 )
                    s_time = s_time > 0 and s_time or nil
                    s_time_u = s_time and "м."
                else
                    f_time = math.floor( (diff_time - f_time * 3600) / 60 )
                    f_time_u = "м."

                    s_time = math.floor( diff_time - f_time * 60 )
                    s_time_u = "с." 
                end
            end

            if not self.timer_icon then 
                self.timer_icon = ibCreateImage( 0, 34, 169, 24, "img/timer.png", self.bg )
            end

            local offset = 57
            for k, v in ipairs( { f_time, s_time, s_time_u, f_time_u  } ) do
                if v then
                    offset = offset + dxGetTextWidth( v, 1, k < 2 and ibFonts.regular_16 or ibFonts.oxaniumbold_16 )
                end
            end
            if not f_time or not s_time then offset = offset + 10 end

            local btn_close_before_px = self.btn_exit:ibGetBeforeX()
            self.timer_icon:ibData( "px", btn_close_before_px - offset )

            if not self.f_time_lbl then 
                self.f_time_lbl = ibCreateLabel( self.timer_icon:ibGetAfterX(), self.timer_icon:ibGetBeforeY() + 1, 0, 0, f_time, self.bg, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
                self.f_time_unit_lbl = ibCreateLabel( self.f_time_lbl:ibGetAfterX( 4 ), self.timer_icon:ibGetBeforeY() + 2, 0, 0, f_time_u, self.bg, nil, nil, nil, "left", "top", ibFonts.regular_16 )
            else
                self.f_time_lbl:ibBatchData( { text = f_time, px = self.timer_icon:ibGetAfterX() } )
                self.f_time_unit_lbl:ibBatchData( { text = f_time_u, px = self.f_time_lbl:ibGetAfterX( 4 ) } )
            end

            if s_time then
                if not self.s_time_lbl then 
                    self.s_time_lbl = ibCreateLabel( self.f_time_unit_lbl:ibGetAfterX( 5 ), self.timer_icon:ibGetBeforeY() + 1, 0, 0, s_time, self.bg, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
                    self.s_time_unit_lbl = ibCreateLabel( self.s_time_lbl:ibGetAfterX( 4 ), self.timer_icon:ibGetBeforeY() + 2, 0, 0, s_time_u, self.bg, nil, nil, nil, "left", "top", ibFonts.regular_16 )
                else
                    self.s_time_lbl:ibBatchData( { text = s_time, px = self.f_time_unit_lbl:ibGetAfterX( 5 ) } )
                    self.s_time_unit_lbl:ibBatchData( { text = s_time_u, px = self.s_time_lbl:ibGetAfterX( 4 ) } )
                end
            end
        end

        UI_elements.level_mul = LEVEL_MULTIPLY[ data.cur_mul ] or DEFAULT_MULTIPLY_DATA
        local min_payment_lbl = ibCreateLabel( 929, 429, 0, 0, UI_elements.level_mul.min_payment_sum, UI_elements.bg, 0xFFFFFFFF, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
        ibCreateImage( min_payment_lbl:ibGetAfterX() + 5, 433, 20, 17, "img/hard.png", UI_elements.bg )

        local current_level_string_id = tostring( UI_elements.level_mul.value ):gsub( "[.]", "," )
        ibCreateLabel( 950, 467, 0, 50, "x" .. current_level_string_id, UI_elements.bg, 0xFFD8DBDE, nil, nil, "right", "center", ibFonts.oxaniumbold_14 )

        UI_elements.dummy_convert_sum_lbl = ibCreateLabel( 773, 467, 240, 50, "Введите сумму", UI_elements.bg, 0xFF647282, nil, nil, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
        UI_elements.convert_summ = ibCreateLabel( 773, 570, 240, 50, "Вы получите", UI_elements.bg, 0xFF647282, nil, nil, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )

        UI_elements.edf_convert_sum = ibCreateEdit( 773, 467, 240, 50, "", UI_elements.bg, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_14 )
            :ibOnClick( function()
                if isElement( UI_elements.dummy_convert_sum_lbl  ) then destroyElement( UI_elements.dummy_convert_sum_lbl  ) end
            end )
            :ibOnDataChange( function( key, value, old )
                if key ~= "text" then return end
                
                local illegal_symbols = utf8.match( value, "[^0-9]+" )
                local len = utf8.len( value )
                if illegal_symbols or len > 10 then
                    UI_elements.edf_convert_sum:ibData( "text", old )
                    UI_elements.edf_convert_sum:ibData( "caret_position", 0 )
                    
                    UI_elements.edf_convert_sum:ibKillTimers()
                    UI_elements.edf_convert_sum:ibTimer( function()
                        UI_elements.edf_convert_sum:ibData( "caret_position", utf8.len( old ) )
                    end, 50, 1 )
                    return
                end

                UI_elements.convert_sum_value = value
                UI_elements.convert_summ:ibBatchData( { color = 0xFFFFFFFF, text = len > 0 and format_price( tonumber( value ) * UI_elements.level_mul.value ) or "" } )
            end )

        ibCreateButton( UI_elements.bg:ibData( "sx" ) - 59, 32, 29, 29, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowOfferLastWealth( false )
            end )
        
        local mul_icon_path =  "img/x" .. current_level_string_id .. "_icon.png"
        if fileExists( mul_icon_path ) then
            ibCreateImage( 724, 87, 300, 174, mul_icon_path, UI_elements.bg )
        else
            UI_elements.current_mul_lbl = ibCreateLabel( 724, 140, 300, 0, "x" .. current_level_string_id, UI_elements.bg, nil, nil, nil, "center", "top", ibFonts.bold_44 )
        end
        ibCreateLabel( 724, 107, 300, 0, "Ваш множитель", UI_elements.bg, 0xFFFFFFFF, nil, nil, "center", "top", ibFonts.regular_16 )


        UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 30, 209, 663, 448, UI_elements.bg, { scroll_px = 10 } )
        UI_elements.scrollbar:ibSetStyle( "slim_nobg" )

        ibCreateImage( 754, 297, 240, 64, "img/mul_title.png", UI_elements.bg )
        
        if data.cur_mul ~= #LEVEL_MULTIPLY then
            ibCreateImage( 236, 1, 193, 18, "img/available_task.png", UI_elements.scrollpane )
        end

        local is_completed_exists = false
        local multiply_px  = 754

        local max_level_mul = #LEVEL_MULTIPLY
        local is_last_mul = data.cur_mul == max_level_mul
        local container_py = is_last_mul and 1 or 38
        
        for k, v in ipairs( LEVEL_MULTIPLY ) do
            local is_cur_mul = data.cur_mul == k
            local is_complete_mul = data.exec_mul > k

            local coeff_text = "x" .. tostring( v.value ):gsub( "[.]", "," )

            local multiply_texture = is_cur_mul and "current" or is_complete_mul and "completed" or "uncompleted"
            local multiply = ibCreateImage( multiply_px, 226, 30, 30, "img/task_" .. multiply_texture .. ".png", UI_elements.bg )
            if k < max_level_mul then ibCreateImage( multiply:ibGetAfterX() + 17, multiply:ibGetBeforeY() + 12, 6, 6, "img/point.png", UI_elements.bg, k < data.cur_mul and 0xAA4E87BA or 0x50FFFFFF ) end
            ibCreateLabel( multiply:ibGetBeforeX(), multiply:ibGetAfterY() + 5, 30, 0, coeff_text, UI_elements.bg, nil, nil, nil, "center", "top", data.cur_mul == k and ibFonts.oxaniumbold_14 or ibFonts.oxaniumregular_14 )

            if data.cur_mul < k then
                local header = ibCreateImage( 0, container_py, 513, 56, "img/bg_header.png", UI_elements.scrollpane )
                local task_name = ibCreateLabel( 20, 0, 0, 56, v.name, header, nil, nil, nil, "left", "center", ibFonts.bold_16 )
                ibCreateLabel( 382, 0, 0, 56, "Выполнено:", header, 0xFFBDC3CB, nil, nil, "left", "center", ibFonts.regular_14 )
                
                local bg_mul = ibCreateImage( 513, container_py, 150, 0, nil, UI_elements.scrollpane, 0xFF6583A5 )
                local bg_mul_img = ibCreateImage( 0, 0, 0, 0, "img/bg_x" .. tostring( v.value ):gsub( "[.]", "_" ) .. ".png", bg_mul )
                container_py = container_py + 56
                
                local task_num = 0
                local steps_height = 0
                local count_completed_steps = 0
                for step_id, step_data in pairs( v.steps ) do
                    local container_height = step_data.name:find( "\n" ) and 62 or 53
                    steps_height = steps_height + container_height + 1

                    local container = ibCreateImage( 0, container_py, 513, container_height, nil, UI_elements.scrollpane, 0x14FFFFFF )
                    local step_name = ibCreateLabel( 20, 0, 0, container_height, step_data.name, container, 0xFFBDC3CB, nil, nil, "left", "center", ibFonts.regular_14 )

                    if step_data.payment then ibCreateLabel( step_name:ibGetAfterX() + 5, 0, 0, container_height, step_data.value, container, nil, nil, nil, "left", "center", ibFonts.bold_14 ) end

                    local progrss_bar_py = (container_height - 12) / 2
                    ibCreateImage( 249, progrss_bar_py, 209, 12, _, container, 0x20000000 )

                    local task_progress_steps = math.min( data.cur_mul_step[ step_id ] or 0, step_data.count  )
                    count_completed_steps = count_completed_steps + (task_progress_steps == step_data.count and 1 or 0)
                    if task_progress_steps > 0 then ibCreateImage( 249, progrss_bar_py, math.ceil( task_progress_steps / step_data.count * 209), 12, _, container, 0xFF47AFFF ) end

                    local complete_steps_lbl = ibCreateLabel( 468, 0, 0, container_height, task_progress_steps, container, nil, nil, nil, "left", "center", ibFonts.oxaniumbold_12 )
                    ibCreateLabel( complete_steps_lbl:ibGetAfterX(), 0, 0, container_height, " / " .. step_data.count, container, 0xFFC4CAD1, nil, nil, "left", "center", ibFonts.oxaniumregular_12 )

                    task_num = task_num + 1
                    if task_num < v.task_count then
                        ibCreateImage( 0, container_py + container_height, 513, 1, nil, UI_elements.scrollpane, ibApplyAlpha( COLOR_WHITE, 20 ) )
                    end

                    container_py = container_py + container_height + 1
                end

                bg_mul:ibData( "sy", steps_height + 55 )
                bg_mul_img:ibSetRealSize():center()

                local completed_steps_count_lbl = ibCreateLabel( 468, 15, 0, 0, count_completed_steps, header, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
                ibCreateLabel( completed_steps_count_lbl:ibGetAfterX(), 18, 0, 0, " / " .. v.task_count, header, 0xFFBDC3CB, nil, nil, "left", "top", ibFonts.oxaniumregular_14 )
                
                container_py = container_py + 10
            else
                is_completed_exists = true
            end

            multiply_px  = multiply_px + 70
        end

        if is_completed_exists or is_last_mul then
            ibCreateImage( 236, container_py + 10, 193, 18, "img/completed_task.png", UI_elements.scrollpane )
            container_py = container_py + 48

            for k = 4, 1, -1 do
                local v = LEVEL_MULTIPLY[ k ]
                if data.cur_mul >= k then
                    local alpha = (is_last_mul and k == max_level_mul) and 255 or 120
                    
                    local header = ibCreateImage( 0, container_py, 513, 56, "img/bg_header.png", UI_elements.scrollpane ):ibData( "alpha", alpha )
                    local task_name = ibCreateLabel( 20, 0, 0, 56, v.name, header, nil, nil, nil, "left", "center", ibFonts.bold_16 )
                    ibCreateLabel( 414, 0, 0, 56, "Выполнено", header, 0xFF38C175, nil, nil, "left", "center", ibFonts.regular_14 )
                    ibCreateImage( task_name:ibGetAfterX() + 7, 24, 12, 11, "img/arrow.png", header )
                    
                    local bg_mul = ibCreateImage( 513, container_py, 150, 0, nil, UI_elements.scrollpane, 0xFF6583A5 ):ibData( "alpha", alpha )
                    local bg_mul_img = ibCreateImage( 0, 0, 0, 0, "img/bg_x" .. tostring( v.value ):gsub( "[.]", "_" ) .. ".png", bg_mul )
                    container_py = container_py + 56
                    
                    local task_num = 0
                    local steps_height = 0
                    local count_completed_steps = 0
                    for step_id, step_data in pairs( v.steps ) do
                        local container_height = step_data.name:find( "\n" ) and 62 or 53
                        steps_height = steps_height + container_height + 1
    
                        local container = ibCreateImage( 0, container_py, 513, container_height, nil, UI_elements.scrollpane, 0x14FFFFFF ):ibData( "alpha", alpha )
                        local step_name = ibCreateLabel( 20, 0, 0, container_height, step_data.name, container, 0xFFBDC3CB, nil, nil, "left", "center", ibFonts.regular_14 )
    
                        if step_data.payment then ibCreateLabel( step_name:ibGetAfterX() + 5, 0, 0, container_height, step_data.value, container, nil, nil, nil, "left", "center", ibFonts.bold_14 ) end
    
                        local progrss_bar_py = (container_height - 12) / 2
                        ibCreateImage( 249, progrss_bar_py, 209, 12, _, container, 0xFF47AFFF )
    
                        local complete_steps_lbl = ibCreateLabel( 468, 0, 0, container_height, step_data.count, container, nil, nil, nil, "left", "center", ibFonts.oxaniumbold_12 )
                        ibCreateLabel( complete_steps_lbl:ibGetAfterX(), 0, 0, container_height, " / " .. step_data.count, container, 0xFFC4CAD1, nil, nil, "left", "center", ibFonts.oxaniumregular_12 )
    
                        task_num = task_num + 1
                        if task_num < v.task_count then
                            ibCreateImage( 0, container_py + container_height, 513, 1, nil, UI_elements.scrollpane, ibApplyAlpha( COLOR_WHITE, 10 ) )
                        end
    
                        container_py = container_py + container_height + 1
                    end

                    bg_mul:ibData( "sy", steps_height + 55 )
                    bg_mul_img:ibSetRealSize():center()

                    container_py = container_py + 10
                end
            end

        end

        UI_elements.scrollpane:AdaptHeightToContents( )
        UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )

        UI_elements.btn_exit = ibCreateButton( 814, 640, 120, 50, UI_elements.bg, "img/btn_buy.png", "img/btn_buy_hover.png", "img/btn_buy_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                local value = tonumber( UI_elements.convert_sum_value )
                if not value or value < 0 then 
                    localPlayer:ShowError( "Некорректная сумма" )
                    return 
                end

                triggerServerEvent( "onServerPlayerTryPurchaseDonate", resourceRoot, value )
            end )

        UI_elements:construct_time_lbl( CONST_OFFER_END_DATE )
        UI_elements.bg:ibTimer( function()
            UI_elements:construct_time_lbl( CONST_OFFER_END_DATE )
        end, 1000, 0 )

        local py = UI_elements.bg:ibData( "py" )
        UI_elements.bg:ibData( "py", py - 100 )
        UI_elements.bg:ibMoveTo( _, py, 250 )
        UI_elements.black_bg:ibAlphaTo( 255, 250 )

        showCursor( true )
    elseif isElement( UI_elements and UI_elements.black_bg ) then
        destroyElement( UI_elements.black_bg )
        UI_elements = nil
        showCursor( false )
    end
end