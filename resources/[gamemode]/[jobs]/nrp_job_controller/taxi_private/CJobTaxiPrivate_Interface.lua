
function ShowTaxiPrivateJobUI_handler( state, data )
    UI_elements = GetMainWindowElements()
    if state then
        local job_data = JOB_DATA[ data.current_job_class ]
        local job_company_conf = job_data.conf_reverse[ data.current_job_id ]

        UI_elements.black_bg = ibCreateBackground( _, ShowJobUI_handler, 0xAA000000, true )

        UI_elements.bg = ibCreateImage( 0, 0, 800, 580, "img/" .. JOB_ID[ data.current_job_class ] .. "/bg_main.png", UI_elements.black_bg ):center()
        UI_elements.licenses_data = data.licenses_data

        ibCreateButton( 748, 25, 22, 22, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()

                ShowJobUI_handler( false )
            end )

        ibCreateImage( 30, 126, 36, 30, "img/soft_icon.png", UI_elements.bg )
		ibCreateLabel( 76, 123, 0, 0, format_price( data.earned_today or 0 ), UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.oxaniumbold_21 )

        -- Overlay buy license
        UI_elements.selected_duration = 1
        UI_elements.func_try_purchase_license = function( self, selected_license )
            if not selected_license then return end
            if self.confirmation then self.confirmation:destroy() end
        
            self.confirmation = ibConfirm(
            {
                title = "ПОДТВЕРЖДЕНИЕ", 
                text = "Ты действительно хочешь приобрести\nлицензию на Класс " .. VEHICLE_CLASSES_NAMES[ selected_license ] .. "?",
                fn = function( self_obj ) 
                    self_obj:destroy()
                    triggerServerEvent( "onServerTaxiPrivateBuyLicense", resourceRoot, selected_license, self.selected_duration )
                end,
                fn_cancel = function( self_obj )
                    self_obj:destroy()
                end,
                escape_close = true,
            } )
        end

        UI_elements.refresh_licenses_overlay = function( self )
            if not isElement( self.bg_purchase_license ) then return end

            if isElement( self.licenses_area ) then destroyElement( self.licenses_area ) end
            self.licenses_area = ibCreateArea( 30, 246, 800, 162, self.bg_purchase_license )
            
            local px, py = 0, 0
            for k, v in ipairs( TAXI_LICENSES ) do 
                local license_state = self.licenses_data[ k ]
                if license_state == TAXI_LICENSE_ENDLESS then
                    local area = ibCreateArea( px, py, 132, 162, self.licenses_area )
                    local area_price = ibCreateImage( 0, 122, 132, 40, nil, area, 0x19FFFFFF ):ibData( "disabled", true )
                    ibCreateLabel( 25, 0, 0, 40, "Навсегда", area_price, 0xFF9A9DA0, nil, nil, "left", "center", ibFonts.bold_16 ):ibData( "disabled", true )
                else
                    local cost = v[ self.selected_duration ]
                    local cost_format_price = format_price( cost )

                    local area = ibCreateArea( px, py, 132, 162, self.licenses_area )
                    local area_purchase = ibCreateButton( 0, 122, 132, 40, area, nil, nil, nil, 0xFF079B61, 0xFF00C271, 0xCC079B61 ):ibData( "alpha", 0 )
                    ibCreateLabel( 0, 0, 132, 40, "КУПИТЬ", area_purchase, 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.bold_18 ):ibData( "disabled", true )

                    local area_price = ibCreateImage( 0, 122, 132, 40, nil, area, 0x19FFFFFF ):ibData( "disabled", true )
                    local container_price = ibCreateArea( 0, 0, 25 + dxGetTextWidth( cost_format_price, 1, ibFonts.oxaniumbold_16 ), 16, area_price ):ibData( "disabled", true ):center()
                    ibCreateImage( 0, 0, 20, 16, TAXI_LICENSES_DURATIONS[ self.selected_duration ] == TAXI_LICENSE_ENDLESS and "img/taxi_private/donate.png" or "img/taxi_private/money.png", container_price ):ibData( "disabled", true )
                    ibCreateLabel( 25, 0, 0, 16, cost_format_price, container_price, 0xFFFFFFFF, nil, nil, "left", "center", ibFonts.oxaniumbold_16 ):ibData( "disabled", true )

                    local func_add_hover_handlers = function( element )
                        element
                            :ibOnHover( function( )
                                area_price:ibAlphaTo( 0, 150 )
                                area_purchase:ibAlphaTo( 255, 150 )
                            end )
                            :ibOnLeave( function( )
                                area_price:ibAlphaTo( 255, 150 )
                                area_purchase:ibAlphaTo( 0, 150 )
                            end )
                    end
                    func_add_hover_handlers( area )
                    func_add_hover_handlers( area_purchase )

                    area_purchase
                        :ibOnClick( function( button, state )
                            if button ~= "left" or state ~= "down" then return end
                            ibClick( )
                            self:func_try_purchase_license( k )
                        end )
                end
            
                px = px + 152
            end
        end

        UI_elements.func_show_overlay_purchase_license = function( self, state )
            if isElement( self.bg_purchase_license ) and self.bg_purchase_license:ibData( "moved" ) then return end

            if state then
                if isElement( self.rt_purchase_license ) then return end

                self.selected_duration = 1
                self.rt_purchase_license = ibCreateRenderTarget( 0, 72, 800, 508, self.bg ):ibData( "priority", 10 )
                self.bg_purchase_license = ibCreateImage( 0, -800, 800, 508, "img/taxi_private/bg_purchase_license.png", self.rt_purchase_license )
                
                self.btn_durations = {}
                local px = 514
                for k, v in pairs( TAXI_LICENSES_DURATIONS ) do
                    self.btn_durations[ k ] = ibCreateImage( px, 207, 82, 26, k == 1 and "img/taxi_private/btn_time_pressed.png" or "img/taxi_private/btn_time_idle.png", self.bg_purchase_license )
                        :ibOnHover( function( )
                            if k ~= self.selected_duration then
                                source:ibData( "texture", "img/taxi_private/btn_time_hover.png" )
                            end
                        end )
                        :ibOnLeave( function( )
                            if k ~= self.selected_duration then
                                source:ibData( "texture", "img/taxi_private/btn_time_idle.png" )
                            end
                        end )
                        :ibOnClick( function( button, state )
                            if button ~= "left" or state ~= "down" then return end
                            ibClick( )
                            if k == self.selected_duration then return end

                            self.selected_duration = k
                            for k, v in pairs( TAXI_LICENSES_DURATIONS ) do
                                if k ~= self.selected_duration then
                                    self.btn_durations[ k ]:ibData( "texture", "img/taxi_private/btn_time_idle.png" )
                                end
                            end
                            
                            source:ibData( "texture", "img/taxi_private/btn_time_pressed.png" )
                            self:refresh_licenses_overlay()
                        end )

                    ibCreateLabel( 0, 0, 82, 26, v ~= TAXI_LICENSE_ENDLESS and (TAXI_LICENSES_DURATIONS[ k ] .. " дней") or "Навсегда", self.btn_durations[ k ], nil, nil, nil, "center", "center", ibFonts.bold_12 ):ibData( "disabled", true )
                    px = px + 90
                end

                self:refresh_licenses_overlay()

                ibCreateButton( 348, 438, 108, 42, self.bg_purchase_license, "img/btn_hide.png", "img/btn_hide.png", "img/btn_hide.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" then return end
                    
                        self:func_show_overlay_purchase_license( false )
                        ibClick( )
                    end )
        
                self.bg_purchase_license:ibMoveTo( 0, 0, 300 )
                ibOverlaySound()
            elseif isElement( self.bg_purchase_license ) then
                self.bg_purchase_license:ibData( "moved", true )
                self.bg_purchase_license:ibMoveTo( 0, -800, 300 )
                    :ibTimer( function()
                        destroyElement( self.rt_purchase_license )
                    end, 300, 1 )
                ibOverlaySound()
            end
        end

        ibCreateButton( 597, 39, 120, 11, UI_elements.bg, "img/taxi_private/btn_license_list.png", "img/taxi_private/btn_license_list.png", "img/taxi_private/btn_license_list.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()

                UI_elements:func_show_overlay_purchase_license( true )
            end )

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

        if data.current_job_id and not localPlayer:HasAnyApartment( true ) then
            UI_elements.remaining_time:ibData( "alpha", 255 )
            UI_elements.remaining_time:ibTimer( function()
                UI_elements:func_update_shift_time()
            end, 1000, 0 )
            UI_elements:func_update_shift_time()
        end
        
        -- Start/End/Select vehicle
        UI_elements.tiers_vehicle = {}
        for i = 1, 5 do
            UI_elements.tiers_vehicle[ i ] = {}
            for k, v in pairs( data.vehicles_data ) do
                if i == v[ 2 ] then
                    table.insert( UI_elements.tiers_vehicle[ i ], v )
                end
            end
        end

        UI_elements.refresh_select_vehicle_overlay = function( self )
            if not isElement( self.bg_select_vehicle ) then return end

            if isElement( self.scrollpane_sel_veh ) then destroyElement( self.scrollpane_sel_veh ) end
            if isElement( self.scrollbar_sel_veh ) then destroyElement( self.scrollbar_sel_veh ) end

            self.scrollpane_sel_veh, self.scrollbar_sel_veh = ibCreateScrollpane( 0, 139, 800, 280, self.bg_select_vehicle )
            
            local py =  0
            for k, v in pairs( self.tiers_vehicle[ self.selected_class ] ) do
                if isElement( v[ 3 ] ) then
                    local container = ibCreateImage( 0, py, 800, 75, nil, self.scrollpane_sel_veh, 0x00FFFFFF )
                    ibCreateImage( 30, 0, 740, 1, nil, container, 0x40FFFFFF ):ibData( "disabled", true )
                    ibCreateImage( 30, 21, 49, 33, "img/taxi_private/vehicle_icon.png", container ):ibData( "disabled", true )
                    
                    local veh_name = ibCreateLabel( 100, 0, 0, 74, VEHICLE_CONFIG[ v[ 3 ].model ].model, container, 0xFFFFFFFF, nil, nil, "left", "center", ibFonts.regular_16 ):ibData( "disabled", true )
                    ibCreateLabel( veh_name:ibGetAfterX( 5 ), 0, 0, 74, "(" .. v[ 3 ]:GetNumberPlateHR() .. ")", container, 0xFFCCCCCC, nil, nil, "left", "center", ibFonts.regular_16 ):ibData( "disabled", true )

                    local btn_select = ibCreateButton( 647, 18, 126, 38, container, "img/taxi_private/btn_select.png", "img/taxi_private/btn_select_hover.png", "img/taxi_private/btn_select_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                        
                            triggerServerEvent( "onServerTaxiPrivateVehicleSelectRequest", resourceRoot, v[ 1 ], CURRENT_CITY )
                        end )

                    local func_add_hover_handlers = function( element )
                        element
                            :ibOnHover( function( )
                                container:ibData( "color", 0x0CFFFFFF )
                            end )
                            :ibOnLeave( function( )
                                container:ibData( "color", 0x00FFFFFF )
                            end )
                    end

                    func_add_hover_handlers( container )
                    func_add_hover_handlers( btn_select )
                        

                    py = py + 74
                end
            end

            self.scrollpane_sel_veh:AdaptHeightToContents()
            self.scrollbar_sel_veh:UpdateScrollbarVisibility( self.scrollpane_sel_veh )
        end

        UI_elements.func_select_start_shift_vehicle = function( self, state, forced )
            if isElement( self.bg_select_vehicle ) and self.bg_select_vehicle:ibData( "moved" ) then return end

            if state then
                if isElement( self.rt_select_vehicle ) then return end

                self.count_tiers = 0
                self.selected_class = nil
                for i = 1, 5 do
                    if #self.tiers_vehicle[ i ] > 0 and self.licenses_data[ i ] ~= TAXI_LICENSE_EXPIRED and self.licenses_data[ i ] ~= TAXI_LICENSE_NOT_PURCHASED then
                        self.count_tiers = self.count_tiers + 1
                        if not self.selected_class then self.selected_class = i end
                    end
                end

                if self.count_tiers == 0 then
                    localPlayer:ErrorWindow( "Приобрети хотя бы одну лицензию!" )
                    return
                end

                self.rt_select_vehicle = ibCreateRenderTarget( 0, 72, 800, 508, self.bg ):ibData( "priority", 9 )
                self.bg_select_vehicle = ibCreateImage( 0, -800, 800, 508, "img/taxi_private/bg_select_vehicle.png", self.rt_select_vehicle )
                
                self.bg_select_area_vehicles = ibCreateArea( 0, 50, 116 * self.count_tiers, 38, self.bg_select_vehicle ):center_x()
                self.selected_buttons = {}
                local px = 0
                for i = 1, 5 do
                    if self.licenses_data[ i ] ~= TAXI_LICENSE_EXPIRED and self.licenses_data[ i ] ~= TAXI_LICENSE_NOT_PURCHASED then
                        self.selected_buttons[ i ] = ibCreateImage( px, 0, 100, 34, i == self.selected_class and "img/taxi_private/btn_veh_pressed.png" or "img/taxi_private/btn_veh_idle.png", self.bg_select_area_vehicles )
                        ibCreateLabel( 0, 0, 100, 34, VEHICLE_CLASSES_NAMES[ i ] .. " класс", self.selected_buttons[ i ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData( "disabled", true )

                        self.selected_buttons[ i ]
                            :ibOnHover( function( )
                                if i ~= self.selected_class then
                                    source:ibData( "texture", "img/taxi_private/btn_veh_hover.png" )
                                end
                            end )
                            :ibOnLeave( function( )
                                if i ~= self.selected_class then
                                    source:ibData( "texture", "img/taxi_private/btn_veh_idle.png" )
                                end
                            end )
                            :ibOnClick( function( button, state )
                                if button ~= "left" or state ~= "down" then return end
                                ibClick( )
                                if i == self.selected_class then return end

                                self.selected_class = i
                                for i = 1, 5 do
                                    if i ~= self.selected_class and self.selected_buttons[ i ] then
                                        self.selected_buttons[ i ]:ibData( "texture", "img/taxi_private/btn_veh_idle.png" )
                                    end
                                end

                                source:ibData( "texture", "img/taxi_private/btn_veh_pressed.png" )
                                self:refresh_select_vehicle_overlay()
                            end )

                        px = px + 110
                    end
                end

                self:refresh_select_vehicle_overlay()

                ibCreateButton( 348, 438, 108, 42, self.bg_select_vehicle, "img/btn_hide.png", "img/btn_hide.png", "img/btn_hide.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" then return end
                        ibClick( )
                        self:func_select_start_shift_vehicle( false )
                    end )
                    
                if forced then
                    self.bg_select_vehicle:ibData( "py", 0 )
                else
                    self.bg_select_vehicle:ibMoveTo( 0, 0, 300 )
                    ibOverlaySound()
                end
            elseif isElement( self.bg_select_vehicle ) then
                self.bg_select_vehicle:ibData( "moved", true )
                self.bg_select_vehicle:ibMoveTo( 0, -800, 300 )
                    :ibTimer( function()
                        destroyElement( self.rt_select_vehicle )
                    end, 300, 1 )
                ibOverlaySound()
            end
        end
        SetShiftStateTaxiPrivate( localPlayer:GetJobClass() ~= data.current_job_class, data.current_job_class )
        
        -- Licenses
        UI_elements.func_refresh_current_licenses = function( self )
            if isElement( self.scrollpane ) then destroyElement( self.scrollpane ) end
            if isElement( self.scrollbar ) then destroyElement( self.scrollbar ) end
            
            self.scrollpane, self.scrollbar = ibCreateScrollpane( 30, 208, 700, 42, self.bg, { horizontal = true } )
            self.scrollbar:ibSetStyle( "slim_nobg" )

            local px = 0
            for k, v in ipairs( TAXI_LICENSES ) do 
                local bg_item = ibCreateImage( px, 0, 95, 41, "img/taxi_private/bg_small_license.png", self.scrollpane )
                ibCreateLabel( 23, 0, 22, 42, VEHICLE_CLASSES_NAMES[ k ], bg_item, 0xFF331E33, nil, nil, "center", "center", ibFonts.bold_20 )
                ibCreateLabel( bg_item:ibGetAfterX( 4 ), 2, 0, 0, VEHICLE_CLASSES_NAMES[ k ], self.scrollpane, 0xFFD8DCE0, nil, nil, "left", "top", ibFonts.bold_14 )
                
                local license_state = self.licenses_data[ k ]
                if license_state == TAXI_LICENSE_NOT_PURCHASED or license_state == TAXI_LICENSE_EXPIRED then
                    local btn = ibCreateButton( px + 59, 28, 61, 14, self.scrollpane, "img/taxi_private/btn_buy.png", "img/taxi_private/btn_buy.png", "img/taxi_private/btn_buy.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFF808080 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick()
                            
                            self:func_show_overlay_purchase_license( true )
                        end )

                    px = btn:ibGetAfterX()
                elseif license_state == TAXI_LICENSE_ENDLESS then
                    local lbl = ibCreateLabel( px + 59, 22, 0, 0, "Навсегда", self.scrollpane, 0xBFFFFFFF, nil, nil, "left", "top", ibFonts.bold_14 )
                    px = lbl:ibGetAfterX()
                else
                    local t1, u1, t2, u2 = nil, nil, nil, nil
                    local diff_time = license_state - getRealTimestamp( )

                    local days_time_left = math.floor( diff_time / 86400 )
                    if days_time_left > 0 then
                        t1 = days_time_left
                        u1 = "д."
                    
                        t2 = math.floor( (diff_time - days_time_left * 86400) / 3600 )
                        t2 = t2 > 0 and t2 or nil
                        u2 = t2 and "ч."
                    else
                        t1 = math.floor( (diff_time - days_time_left * 86400) / 3600 )
                        if t1 > 0 then
                            u1 = "ч."
                        
                            t2 = math.floor( (diff_time - t1 * 3600) / 60 )
                            t2 = t2 > 0 and t2 or nil
                            u2 = t2 and "м."
                        else
                            t1 = math.floor( (diff_time - t1 * 3600) / 60 )
                            u1 = "м."
                        
                            t2 = math.floor( diff_time - t1 * 60 )
                            u2 = "с." 
                        end
                    end


                    if t1 then
                        ibCreateImage( px + 59, 24, 15, 17, "img/taxi_private/tmr.png", self.scrollpane, days_time_left > 1 and 0xFFFFDF93 or 0xFFFF6363 )
                        self.f_time_lbl = ibCreateLabel( px + 78, 20, 0, 0, t1, self.scrollpane, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
                        self.f_time_unit_lbl = ibCreateLabel( self.f_time_lbl:ibGetAfterX( 4 ), 19 + 2, 0, 0, u1, self.scrollpane, nil, nil, nil, "left", "top", ibFonts.regular_16 )
                        px = self.f_time_unit_lbl:ibGetAfterX()
                    end
        
                    if t2 then
                        self.s_time_lbl = ibCreateLabel( self.f_time_unit_lbl:ibGetAfterX( 5 ), 20, 0, 0, t2, self.scrollpane, nil, nil, nil, "left", "top", ibFonts.oxaniumbold_16 )
                        self.s_time_unit_lbl = ibCreateLabel( self.s_time_lbl:ibGetAfterX( 4 ), 19 + 2, 0, 0, u2, self.scrollpane, nil, nil, nil, "left", "top", ibFonts.regular_16 )
                        px = self.s_time_unit_lbl:ibGetAfterX()
                    end
                end

                if TAXI_LICENSES[ k + 1 ] then
                    ibCreateImage( px + 19, 0, 1, 41, nil, self.scrollpane, 0x19FFFFFF )
                    px = px + 40
                end
	        end

            self.scrollpane:ibBatchData( { sx = px, priority = 0 } )
            self.scrollbar:ibBatchData( { position = 0, visible = false } )
        end
        UI_elements:func_refresh_current_licenses( )

        ibCreateButton( 750, 219, 20, 20, UI_elements.bg, "img/taxi_private/btn_circle.png", "img/taxi_private/btn_circle.png", "img/taxi_private/btn_circle.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()

                local original_rotation = source:ibData( "rotation" )
                local direction = original_rotation == 0 and 0 or 1
                local duration = 200
                
                source:ibInterpolate( function( self )
                    if not isElement( self.element ) then return end
                    self.element:ibData( "rotation", 180 * (math.abs( direction - self.progress )) )
                end, duration, "Linear" )

                UI_elements.scrollbar:ibScrollTo( 1 - direction, duration, "Linear" )
            end )
            
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
    elseif UI_elements.confirmation ~= nil then
        UI_elements.confirmation:destroy()
        UI_elements.confirmation = nil
    end
end

function SetShiftStateTaxiPrivate( state, job_class )
    if not UI_elements or not isElement( UI_elements.bg ) then return end

    if isElement( UI_elements.btn_shift ) then destroyElement( UI_elements.btn_shift ) end

    if state then
        UI_elements.btn_shift = ibCreateButton( 587, 131, 192, 58, UI_elements.bg, "img/btn_start_shift.png", "img/btn_start_shift_h.png", "img/btn_start_shift_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick( )

                UI_elements:func_select_start_shift_vehicle( true )
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

function onClientPrivateTaxiSetLicenses_handler( licenses )
    UI_elements = GetMainWindowElements()
    if not UI_elements then return end
    
    UI_elements.licenses_data = licenses
    
    if UI_elements.func_refresh_current_licenses then
        UI_elements:func_refresh_current_licenses()
    end

    if UI_elements.refresh_licenses_overlay then
        UI_elements:refresh_licenses_overlay()
    end

    if isElement( UI_elements.rt_select_vehicle ) then
        destroyElement( UI_elements.rt_select_vehicle )
        UI_elements:func_select_start_shift_vehicle( true )
    end
end
addEvent( "onClientPrivateTaxiSetLicenses", true )
addEventHandler( "onClientPrivateTaxiSetLicenses", resourceRoot, onClientPrivateTaxiSetLicenses_handler )