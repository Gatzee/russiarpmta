local UI_elements

function ShowJobUI_handler( state, data )
    if state then
        ShowJobUI_handler( false )

        UI_elements = {}
        if data.current_job_class == JOB_CLASS_TAXI_PRIVATE then
            ShowTaxiPrivateJobUI_handler( state, data )
            return
        end

        local job_data = JOB_DATA[ data.current_job_class ]
        local job_company_conf = job_data.conf_reverse[ data.current_job_id ]

        UI_elements.black_bg = ibCreateBackground( _, ShowJobUI_handler, 0xAA000000, true )

        UI_elements.bg = ibCreateImage( 0, 0, 800, 580, "img/" .. JOB_ID[ data.current_job_class ] .. "/bg_main.png", UI_elements.black_bg ):center()
        
        ibCreateButton( 748, 25, 22, 22, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()

                ShowJobUI_handler( false )
            end )

        ibCreateImage( 30, 126, 36, 30, "img/soft_icon.png", UI_elements.bg )
		ibCreateLabel( 76, 125, 0, 0, format_price( data.earned_today or 0 ), UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.oxaniumbold_21 )

        local piggy_bank = localPlayer:getData( "offer_piggy_bank" )
        if piggy_bank then
            ibCreateImage( 250, 102, 1, 30, nil, UI_elements.bg, ibApplyAlpha( 0xffffffff, 10 ) )
            ibCreateLabel( 272, 108, 0, 0, "Подоходный налог:", UI_elements.bg, 0x88dddddd, 1, 1, "left", "center", ibFonts.bold_16 )
            ibCreateImage( 270, 126, 30, 30, "img/tax_icon.png", UI_elements.bg )
            local lbl_amount = ibCreateLabel( 310, 125, 0, 0, format_price( piggy_bank ), UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.oxaniumbold_21 )

            ibCreateButton( 320 + lbl_amount:width( ), 125, 100, 30, UI_elements.bg, "img/btn_more_i.png", "img/btn_more_h.png", "img/btn_more_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then
                    return
                end

                triggerEvent( "onPlayerOfferPiggyBank", localPlayer )
                ibClick( )
            end )
        end

        -- Available shift
        UI_elements.remaining_time = ibCreateLabel( 713, 98, 0, 0, "", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_18 )

        UI_elements.shift_state = nil
        UI_elements.func_update_shift_time = function( self )
            local new_shift_state = nil
			if localPlayer:IsNewShiftDay() then
				if self.shift_state ~= JOB_SHIFT_STATE_NEW then
					new_shift_state = JOB_SHIFT_STATE_NEW
					self.remaining_time:ibData( "text", "" )
				end
			else
				local remaining_time = localPlayer:GetShiftRemainingTime()
				
                local hours   = math.max( 0, math.floor( remaining_time / 3600 ) )
				local minutes = math.max( 0, math.floor( remaining_time / 60 - hours * 60 ) )
				local seconds = math.max( 0, math.floor( remaining_time - hours * 3600 - minutes * 60 ) )

				if hours <= 0 and minutes <= 0 and seconds <= 0 then
                    local remaining_time_to_new_shift = getRealTime( getRealTimestamp() )
                    hours, minutes, seconds = 23 - remaining_time_to_new_shift.hour, 59 - remaining_time_to_new_shift.minute, 59 - remaining_time_to_new_shift.second
                    
                    if self.shift_state ~= JOB_SHIFT_STATE_ENDED then
						new_shift_state = JOB_SHIFT_STATE_ENDED
						self.remaining_time:ibData( "px", 713 )
					end
                elseif self.shift_state ~= JOB_SHIFT_STATE_AVAILABLE then
					new_shift_state = JOB_SHIFT_STATE_AVAILABLE
					self.remaining_time:ibData( "px", 713 )
				end

                self.remaining_time:ibData( "text", string.format( "%d:%02d:%02d", hours, minutes, seconds ) )
			end

            if new_shift_state then
                self:func_update_shift_state( new_shift_state )
            end
        end
        
        UI_elements.func_update_shift_state = function( self, new_shift_state )
            if self.shift_state == new_shift_state then return end
            self.shift_state = new_shift_state

            if self.bg_shift then destroyElement( self.bg_shift ) end
            self.bg_shift = ibCreateArea( 443, 103, 500, 50, self.bg )
            
            if self.shift_state == JOB_SHIFT_STATE_AVAILABLE then
                ibCreateImage( 96, 0, 16, 18, "img/tmr_icon.png", self.bg_shift ):ibData( "alpha", 191 )
                ibCreateLabel( 121, 0, 0, 18, "Доступно в течении:", self.bg_shift, nil, nil, nil, "left", "center", ibFonts.regular_14 ):ibData( "alpha", 191 )
            elseif self.shift_state == JOB_SHIFT_STATE_ENDED then
                ibCreateImage( 0, 0, 16, 18, "img/tmr_icon.png", self.bg_shift ):ibData( "alpha", 191 )
                ibCreateLabel( 26, 0, 0, 18, "Смена окончена, приходите через:", self.bg_shift, nil, nil, nil, "left", "center", ibFonts.regular_14 ):ibData( "alpha", 125 )
            elseif self.shift_state == JOB_SHIFT_STATE_NEW then
                ibCreateImage( 143, 0, 18, 18, "img/shift_available_icon.png", self.bg_shift ):ibData( "alpha", 191 )
                ibCreateLabel( 171, 0, 0, 18, "Доступна новая смена", self.bg_shift, 0xFFFFD892, nil, nil, "left", "center", ibFonts.semibold_14 ):ibData( "alpha", 191 )
            end
        end

        -- Start/End/Fines
        if data.current_job_id and not localPlayer:HasAnyApartment( true ) then
            UI_elements.remaining_time:ibData( "alpha", 255 )
            UI_elements.remaining_time:ibTimer( function()
                UI_elements:func_update_shift_time()
            end, 1000, 0 )
            UI_elements:func_update_shift_time()
        end
        SetShiftState( localPlayer:GetJobClass() ~= data.current_job_class, data.current_job_class )

        if job_data.has_fines then
            UI_elements.func_show_fines_overlay = function( self, state )
                if isElement( self.fines_bg ) and self.fines_bg:ibData( "moved" ) then return end

                if state then
                    if isElement( self.fines_bg_rt ) then return end

                    self.fines_bg_rt = ibCreateRenderTarget( 0, 72, 800, 508, self.bg )
                    self.fines_bg = ibCreateImage( 0, -800, 800, 508, "img/bg_fines.png", self.fines_bg_rt )
            
                    ibCreateButton( 346, 436, 108, 42, self.fines_bg, "img/btn_hide.png", "img/btn_hide.png", "img/btn_hide.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                        :ibOnClick( function( button, state )
                            if button ~= "left" or state ~= "down" then return end
                        
                            self:func_show_fines_overlay( false )
                            ibClick( )
                        end )
            
                    self.fines_bg:ibMoveTo( 0, 0, 300 )
                    ibOverlaySound()
                else
                    self.fines_bg:ibData( "moved", true )
                    self.fines_bg:ibMoveTo( 0, -800, 300 )
                        :ibTimer( function()
                            destroyElement( self.fines_bg_rt )
                        end, 300, 1 )
                    ibOverlaySound()
                end
            end

            ibCreateButton( 587, 186, 192, 58, UI_elements.bg, "img/btn_fines.png", "img/btn_fines_h.png", "img/btn_fines_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick()
                    UI_elements:func_show_fines_overlay( true )
                end )
        end

        -- Levels
        local px = 30
        local curret_compnany_id = data.current_job_id and job_data.conf_reverse[ data.current_job_id ].position or 0

        local min_visible_company_id = 1 + (curret_compnany_id and math.max( 0, curret_compnany_id - 3 ) or 0)
        local max_visible_company_id = min_visible_company_id + 2

        UI_elements.func_interpolate = function( element, value )
            local px, py = element:ibData( "px" ), element:ibData( "py" )
            local sx, sy = element:ibData( "sx" ), element:ibData( "sy" )
            element:ibInterpolate( function( self_interpolate )
                local delta = value * self_interpolate.easing_value
                self_interpolate.element:ibBatchData( { px = px - delta / 2, py = py - delta / 2, sx = sx + delta, sy = sy + delta } )
            end, 800, "Linear" )
        end

        for company_id, company_data in ipairs( job_data.conf ) do
            if company_id >= min_visible_company_id and company_id <= max_visible_company_id then 
                local is_cur_company = company_id == curret_compnany_id
                local is_passed_company = curret_compnany_id > company_id
                local company_state = is_cur_company and "current" or is_passed_company and "passed" or "blocked"
                local company_next = (company_id == max_visible_company_id) and "last" or "next"
                local level_value = company_state .. "_" .. company_next
                local img = ibCreateImage( px, 258, 0, 0, "img/levels/" .. level_value .. ".png", UI_elements.bg ):ibSetRealSize()
                ibCreateLabel( 0, 0, 50, 50, ROMAN_NUMERALS[ company_id ], img, is_passed_company and 0xFF47AFFF or is_cur_company and 0xFFFFFFFF or 0xFF748191, 1, 1, "center", "center", ibFonts.bold_20 ):ibData( "disabled", true )
                ibCreateLabel( 59, 18, 0, 0, company_data.name, img, is_cur_company and 0xFFFFFFFF or 0xFFB0BCC9, 1, 1, "left", "center", ibFonts.bold_14 ):ibData( "disabled", true )
                ibCreateLabel( 59, 34, 0, 0, is_cur_company and "Текущий" or is_passed_company and "Пройдена" or company_data.condition_text, img, is_cur_company and 0xAAFFFFFF or 0xAAB1BCC9, 1, 1, "left", "center", ibFonts.regular_12 ):ibData( "disabled", true )

                if curret_compnany_id < company_id and company_data.require_license and not localPlayer:HasLicense( company_data.require_license ) then
                    local info_icon = ibCreateImage( 170, 10, 17, 17, "img/info_icon.png", img )
                        :ibAttachTooltip( GetHintAboutLackLicense( company_data.require_license ) )

                    info_icon:ibTimer( function( self )
                        local direction = info_icon:ibData( "direction" )
                        info_icon:ibData( "direction", direction == 1 and 0 or 1 )
                        UI_elements.func_interpolate( info_icon, direction == 1 and 3 or -3 )
                    end, 850, 0 )
                end

                local offsets = {
                    blocked_next = 23,
                }
                px = px + img:ibData( "sx" ) - (offsets[ level_value ] or 34)
            end
        end

        -- Daily tasks
        local px = 141
        for k, v in pairs( data.tasks or { } ) do
            local task = JOB_DATA[ data.current_job_class ].tasks_reverse[ v.id ]
            if task then
                local is_progress_task = ( not v.finished and v.progress and task.get_progress_text )
                local circle = ibCreateImage( px, 520, 30, 30, "img/circle_" .. (v.finished and "completed" or "progress") .. ".png", UI_elements.bg )
                local lbl_text = ibCreateLabel( px + 40, 522, 0, 26, task.text, UI_elements.bg, 0xFFA5B2BD, nil, nil, "left", "center", ibFonts.regular_14 )
                
                if is_progress_task then
                    local bg_tooltip = ibCreateImage( px + 30, 510, 107, 50, nil, UI_elements.bg, 0xFF070B0D ):ibData( "alpha", 0 )
                    ibCreateLabel( 7, 16, 0, 0, "Прогресс цели:", bg_tooltip, 0xFFFFFFFF, nil, nil, "left", "center", ibFonts.regular_12 )
                    
                    local progress_text, progress_normalized = task:get_progress_text( v.progress )
                    ibCreateLabel( 7, 33, 0, 0, progress_text, bg_tooltip, 0xFFFFFFFF, nil, nil, "left", "center", ibFonts.bold_14 )
                    
                    local shader = dxCreateShader( "fx/circle.fx" )
                    local texture = dxCreateTexture( "img/circle_progress_value.png" )
                    dxSetShaderValue( shader, "tex", texture )
                    dxSetShaderValue( shader, "angle", 0.1 )
                    dxSetShaderValue( shader, "dg", progress_normalized * 2 )
            
                    ibCreateImage( 0, 0, 30, 30, shader, circle ):ibBatchData( { disabled = true, rotation = 90 } )
                        :ibOnDestroy( function( )
                            shader:destroy( )
                            texture:destroy( )
                        end )
                    
                    circle
                        :ibOnHover( function()
                            bg_tooltip:ibAlphaTo( 255, 150 )
                        end )
                        :ibOnLeave( function()
                            bg_tooltip:ibAlphaTo( 0, 150 )
                        end )
                end

                if data.tasks[ k + 1 ] then
                    local line_px = lbl_text:ibGetAfterX() + 20
                    ibCreateImage( line_px, 520, 1, 30, nil, UI_elements.bg, 0x19FFFFFF )
                    px = line_px + 21
                end
            end
        end
        

        local py = UI_elements.bg:ibData( "py" ) 
        UI_elements.bg:ibBatchData( { alpha = 0, py = py - 100 } ):ibMoveTo( nil, py, 500, "OutElastic" ):ibAlphaTo( 255, 1000 )

        ibInterfaceSound()
        showCursor( true )
    elseif isElement( UI_elements and UI_elements.black_bg ) then 
        ShowTaxiPrivateJobUI_handler( false )
        destroyElement( UI_elements.black_bg )
		showCursor( false )
    end
end
addEvent( "ShowJobUI", true )
addEventHandler( "ShowJobUI", root, ShowJobUI_handler )


function SetShiftState( state, job_class )
    if not UI_elements or not isElement( UI_elements.bg ) then return end

    if job_class == JOB_CLASS_TAXI_PRIVATE then
        SetShiftStateTaxiPrivate( true, job_class )
        return
    end

    if isElement( UI_elements.btn_shift ) then destroyElement( UI_elements.btn_shift ) end

    if state then
        UI_elements.btn_shift = ibCreateButton( 587, 131, 192, 58, UI_elements.bg, "img/btn_start_shift.png", "img/btn_start_shift_h.png", "img/btn_start_shift_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick( )

                triggerServerEvent( "onJobStartShiftRequest", root, job_class, CURRENT_CITY )
            end )                                
    else
        UI_elements.btn_shift = ibCreateButton( 587, 131, 192, 58, UI_elements.bg, "img/btn_end_shift.png", "img/btn_end_shift_h.png", "img/btn_end_shift_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick( )
                triggerServerEvent( "onJobEndShiftRequest", resourceRoot, { type = "quest_end_job_shift", fail_text = "Ты завершил смену" } )                    
            end )
    end
end
addEvent( "SetShiftState", true )
addEventHandler( "SetShiftState", root, SetShiftState )

function GetMainWindowElements()
    return UI_elements
end