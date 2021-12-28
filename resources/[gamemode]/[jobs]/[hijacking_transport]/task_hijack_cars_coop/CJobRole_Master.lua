
function ToggleMinigameMaster( state, data )
    if state then
        ToggleMinigameMaster( false )

        local self = data

        self.hard = math.random( 2, 4 )
        self.hard_text = {
            [ 2 ] = "Низкая",
            [ 3 ] = "Средняя",
            [ 4 ] = "Максимальная",
        }

        self.anim_duration = 1000
        self.blocks_breakin_direction = { 1, 2, 3, 6, 5, 4 }
        self.count_items = 96
        self.scroll_size = self.count_items * 76 
        self.scroll_duration = CONST_BREAKIN_CAR_TIME_IN_SEC * 1000 - (self.hard * 3500)
        self.attempts_left = 2

        self.black_bg = ibCreateBackground( 0xC01D252E )
        self.bg = ibCreateImage( 0, 0, 820, 615, "img/master/bg.png", self.black_bg ):center()
        ibCreateImage( 0, _SCREEN_Y - 105, 1194, 105, "img/master/minigame_hint.png", self.black_bg ):center_x()

        ibCreateLabel( 105, 109, 200, 30, VEHICLE_CONFIG[ self.hijacked_vehicle.model ].model, self.bg, 0xFF0A1620, nil, nil, "center", "center", ibFonts.bold_12 )
        ibCreateLabel( 515, 109, 200, 30, self.hard_text[ self.hard ], self.bg, 0xFF0A1620, nil, nil, "center", "center", ibFonts.bold_12 )

        self.bg_breakin_status = ibCreateImage( 315, 98, 190, 47, "img/master/bg_status.png", self.bg )
        self.bg_breakin_status_lbl = ibCreateLabel( 0, 0, 190, 35, "Ожидание", self.bg_breakin_status, 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.regular_14 )

        self.progress_bar_left = ibCreateImage( 60, 139, 700, 40, "img/master/progress_bar_tmr.png", self.bg ):ibData( "color", 0xFF5C94D1 )
        self.progress_bar_rigth = ibCreateImage( 350 + 60, 139, 700, 40, "img/master/progress_bar_tmr.png", self.bg ):ibBatchData( { u = 350, v = 0, u_size = 350, sx = 350, color = 0xFF5C94D1 } )
        
        ibCreateImage( 60, 139, 700, 40, "img/master/overlay_tmr.png", self.bg )
        
        self.bg_tmr = ibCreateImage( 392, 144, 36, 31, "img/master/bg_tmr.png", self.bg )
        self.bg_tmr_lbl = ibCreateLabel( 0, 0, 36, 31, CONST_BREAKIN_CAR_TIME_IN_SEC, self.bg_tmr, 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.oxaniumbold_14 )
        
        self.left_plug  = ibCreateImage( 4,   325, 26, 100, "img/master/plug_body_process.png", self.bg )
        self.right_plug = ibCreateImage( 790, 325, 26, 100, "img/master/plug_body_process.png", self.bg ):ibData( "rotation", 180 )
        self.down_plug  = ibCreateImage( 360, 575, 100, 26, "img/master/plug_body_down_process.png", self.bg )
        
        self.panes = {}
        self.func_create_blocks_pane = function( self, index )
            self.panes[ index ] = {}
            
            local pane_data = {
                blocks = {},
            }

            pane_data.blocks_pane, pane_data.scroll_v = ibCreateScrollpane( self.result_blocks[ index ]:ibData( "px" ), 319, 96, 218, self.bg )
            
            local py = 0
            for i = 1, self.count_items do
                pane_data.blocks[ i ] = ibCreateImage( 0, py, 96, 66, "img/master/block_process.png", pane_data.blocks_pane )
                pane_data.blocks[ i .. "lbl" ] = ibCreateLabel( 0, 0, 96, 72, "*", pane_data.blocks[ i ], 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.oxaniumbold_30 )
                py = py + 75
            end

            pane_data.blocks_pane:AdaptHeightToContents( )
            pane_data.scroll_v:ibBatchData( { position = index % 2 == 0 and 0.0 or 1.0, sensivity = 0, visible = false } )
            
            self.panes[ index ] = pane_data
        end

        self.result_blocks = {}

        local px, py = 63, 223
        for i = 1, 6 do
            self.result_blocks[ i ] = ibCreateImage( px, py, 96, 66, "img/master/block_process.png", self.bg )
            self.result_blocks[ i ]:ibData( "lbl", ibCreateLabel( 0, 0, 96, 66, "*", self.result_blocks[ i ], 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.oxaniumbold_30 ) )
            self.result_blocks[ i ]:ibData( "wire", ibCreateImage( px + 38, py + 66, 20, 30, "img/master/wire_process.png", self.bg ) )
            self.result_blocks[ i ]:ibData( "point", ibCreateImage( px + 68, py + 76, 10, 10, "img/master/point_process.png", self.bg ) )
            px = px + (i % 3 == 0 and 172 or 106)
            self:func_create_blocks_pane( i )
        end
        
        self.section_point = ibCreateImage( 405, 249, 10, 10, "img/master/point_process.png", self.bg )
        self.wire_left_section  = ibCreateImage( 372, 254, 36, 65, "img/master/wire_left_section_process.png", self.bg )
        self.wire_right_section = ibCreateImage( 411, 254, 36, 65, "img/master/wire_right_section_process.png", self.bg )
        
        self.bg_completed_block = ibCreateImage( 377, 319, 66, 66, "img/master/bg_completed_block_process.png", self.bg )
        self.bg_completed_block:ibData( "lbl", ibCreateLabel( 0, 0, 66, 66, "0", self.bg_completed_block, 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.oxaniumbold_30 ) )

        self.wire_complete = ibCreateImage( 389, 386, 42, 151, "img/master/wire_complete_process.png", self.bg )
            
        ibCreateImage( 44, 389, 731, 76, "img/master/overlay_select_h.png", self.bg )
        self.selector_v = ibCreateImage( 60, 213, 103, 333, "img/master/overlay_select_process_v.png", self.bg )

        self.func_start_breakin_process = function( self )
            self.is_started = true
            self.bg_tmr_lbl
                :ibData( "counter", CONST_BREAKIN_CAR_TIME_IN_SEC )
                :ibTimer( function( self_element )
                    if self.is_complete then return end
                    setSoundVolume( playSound( "sfx/hijacking_time_count.ogg" ), 0.5 )

                    local counter = self_element:ibData( "counter" ) - 1
                    self_element:ibBatchData( { counter = counter, text = counter } )
                    if counter == 0 then
                        self.fail_callback()
                    end
                end, 1000, CONST_BREAKIN_CAR_TIME_IN_SEC )

            local tick = getTickCount()
            local const_breakin_time_in_ms = CONST_BREAKIN_CAR_TIME_IN_SEC * 1000
            self.progress_bar_rigth
                :ibOnRender( function()
                    if self.is_complete then return end

                    local progress = (getTickCount() - tick) / const_breakin_time_in_ms
                    if progress <= 1 and not self.stop_fail_tmr then
                        local new_size = 350 * progress
                        self.progress_bar_left:ibBatchData( { px = 60 + new_size, u = new_size, v = 0, u_size = 350 - new_size, sx = 350 - new_size } )
                        self.progress_bar_rigth:ibBatchData( { u = 350, v = 0, u_size = 350 - new_size, sx = 350 - new_size } )
                    end
                    if progress >= 0.8 and not self.progress_bar_rigth:ibData( "little_time_color" ) then
                        self.progress_bar_rigth:ibData( "little_time_color", true )
                        self.progress_bar_left:ibData( "color", 0xFF7F1F21 )
                        self.progress_bar_rigth:ibData( "color", 0xFF7F1F21 )
                    end
                end )

            self:func_change_breakin_status( "process" )
            self:func_start_roll_next_pane()
        end

        self.func_start_roll_next_pane = function( self )
            self.real_current_block = (self.real_current_block or 0) + 1
            if self.real_current_block > #self.blocks_breakin_direction then
                
                -- fucking success anims
                local new_wire_left_section  = ibCreateImage( 372, 254, 36, 0, "img/master/wire_left_section_success.png", self.bg )
                local new_wire_right_section = ibCreateImage( 411, 254, 36, 0, "img/master/wire_right_section_success.png", self.bg )
                
                new_wire_right_section
                    :ibInterpolate( function( self )
                        if not isElement( self.element ) then return end
                    
                        local new_size = 65 * self.easing_value
                        new_wire_left_section:ibBatchData( { v = 0, u = 0, v_size = new_size, sy = new_size } )
                        new_wire_right_section:ibBatchData( { v = 0, u = 0, v_size = new_size, sy = new_size } )
                    end, self.anim_duration, "Linear" )
                
                new_wire_right_section:ibTimer( function()
                    self.section_point:ibData( "texture", "img/master/point_success.png" )
                    local new_bg_completed_block = ibCreateImage( 377, 319, 66, 66, "img/master/bg_completed_block_success.png", self.bg ):ibData( "alpha", 0 )
                    ibCreateLabel( 0, 0, 66, 66, self.num_success_symbols, new_bg_completed_block, 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.oxaniumbold_30 )
                    
                    new_bg_completed_block:ibAlphaTo( 255, self.anim_duration )
                    new_bg_completed_block:ibTimer( function()
                        local new_wire_complete = ibCreateImage( 389, 386, 42, 0, "img/master/wire_complete_success.png", self.bg )
                            :ibInterpolate( function( self_interpolate )
                                if not isElement( self_interpolate.element ) then return end
                            
                                local new_size = 151 * self_interpolate.easing_value
                                self_interpolate.element:ibBatchData( { v = 0, u = 0, v_size = new_size, sy = new_size } )
                                if self_interpolate.easing_value == 1 then
                                    self:func_change_plug_state( "down", "success" )
                                    self.bg:ibTimer( function()
                                        self:func_change_breakin_status( "success" )
                                        setSoundVolume( playSound( "sfx/hijacking_success.ogg" ), 0.5 )
                                        self.success_callback()
                                    end, self.anim_duration, 1 )
                                end
                            end, self.anim_duration * 2, "Linear" )

                    end, self.anim_duration, 1 )

                end, self.anim_duration, 1 )
            
            else
                -- next block pane
                self.current_block = self.blocks_breakin_direction[ self.real_current_block ]
                self.target_symbol = self.password:sub( self.real_current_block, self.real_current_block )

                local pane_data = self.panes[ self.current_block ]
                for i = 1, self.count_items do
                    local block_symbol = nil
                    if i % self.hard == 0 and i ~= 2 then
                        block_symbol = self.target_symbol
                        pane_data.blocks[ i ]:ibData( "texture", "img/master/block_target_symbol.png" )
                    else
                        block_symbol = CONST_PASSOWRD_SYMBOLS[ math.random( 1, #CONST_PASSOWRD_SYMBOLS ) ]
                    end

                    pane_data.blocks[ i .. "lbl" ]:ibData( "text", block_symbol )
                end
                
                self.selector_v
                    :ibData( "texture", "img/master/overlay_select_process_v.png" )
                    :ibMoveTo( self.result_blocks[ self.current_block ]:ibData( "px" ) - 3, nil, self.anim_duration )
                    :ibTimer( function()
                        self.current_direction = self.current_block % 2 == 0 and 1 or 0
                        pane_data.scroll_v:ibScrollTo( self.current_direction, self.scroll_duration, "Linear" )
                        self.is_animation = false
                    end, self.anim_duration + 100, 1 )
            end
        end

        self.func_change_plug_state = function( self, plug_side, state )
            local plug = self[ plug_side .. "_plug" ]
            local px, py, rot = plug:ibData( "px" ), plug:ibData( "py" ), plug:ibData( "rotation" )

            local pattern_interpolate = 
            {
                left = function( element, px, new_size, orig_sx, orig_sy )
                    element:ibBatchData( { u = 26 - new_size, px = px + 26 - new_size, v = 0, u_size = new_size, sx = new_size } )
                end,
                right = function( element, px, new_size )
                    element:ibBatchData( { u = 26 - new_size, v = 0, u_size = new_size, sx = new_size } )
                end,
                down = function( element, px, new_size )
                    element:ibBatchData( { v = 0, u = 0, v_size = new_size, sy = new_size } )
                end,
            }

            local is_down_plug = plug_side == "down"
            local new_plug_state = ibCreateImage( px, py, is_down_plug and 100 or 0, is_down_plug and 0 or 100, "img/master/plug_body_" .. (is_down_plug and "down_" or "") .. state .. ".png", self.bg )
                :ibData( "rotation", rot )
                :ibInterpolate( function( self_i )
                    if not isElement( self_i.element ) then return end
                    
                    pattern_interpolate[ plug_side ]( self_i.element, px, 26 * self_i.easing_value )
                    if self_i.easing_value == 1 then
                        self[ plug_side .. "_plug" ]:destroy()
                    end
                end, self.anim_duration, "Linear" )
        end

        self.func_change_breakin_status = function( self, status, arg )
            local status_data =
            {
                fail           = { text = "Машина заблокирована", bg_color = 0xFFD61B1B, lbl_color = 0xFFFF9E9E },
                fail_symbol    = { text = "Осталось попыток: " .. (arg and arg or ""),      bg_color = 0xFFD61B1B, lbl_color = 0xFFFF9E9E },
                success_symbol = { text = "Символ подобран",      bg_color = 0xFF5DFF2C, lbl_color = 0xFFFFFFFF },
                success        = { text = "Пароль подобран",      bg_color = 0xFF5DFF2C, lbl_color = 0xFFFFFFFF },
                process        = { text = "Идёт процесс взлома",  bg_color = 0xFF235D9C, lbl_color = 0xFFA4d7FF },
            }
            self.bg_breakin_status:ibData( "color", status_data[ status ].bg_color )
            self.bg_breakin_status_lbl:ibBatchData( { color = status_data[ status ].lbl_color, text = status_data[ status ].text } )
        end

        self.func_show_minigame_hint = function( self, state )
            if state then
                if isElement( self.bg_minigame_hint ) then return end

                self.bg_minigame_hint = ibCreateImage( 0, 0, 1024, 720, "img/master/bg_minigame_hint.png", self.black_bg ):center()
                ibCreateButton(	970, 28, 24, 25, self.bg_minigame_hint, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" or self.is_anim_close_minigame_hint then return end
                        ibClick()
                        self:func_show_minigame_hint( false )
                    end )

                local py = self.bg_minigame_hint:ibData( "py" )
                self.bg_minigame_hint:ibBatchData( { py = py - 100, alpha = 0 } )
                self.bg_minigame_hint:ibMoveTo( nil, py, 250 ):ibAlphaTo( 255, 250 )
                ibOverlaySound()
            else
                ibOverlaySound()
                self.is_anim_close_minigame_hint = true
                self.bg_minigame_hint:ibMoveTo( nil, self.bg_minigame_hint:ibData( "py" ) + 100, 250 ):ibAlphaTo( 0, 250 )
                    :ibTimer( function( self_element )
                        self_element:destroy()
                        self.is_anim_close_minigame_hint = false
                    end, 250, 1 )
            end
        end
        
        self.func_on_client_key_handler = function( key, state )
            if not state or self.is_animation then return end

            if key == "enter" then
                cancelEvent()
                
                if not self.real_current_block or self.real_current_block > #self.blocks_breakin_direction then return end

                local pane_data = self.panes[ self.current_block ]

                local scroll_position = pane_data.scroll_v:ibData( "position" )
                local scroll_py = math.floor( (pane_data.blocks[ self.count_items ]:ibData( "py" )  - 106) * scroll_position )
               
                local direction_borders = {
                    [ 0 ] = { min = 10, max = 280 },
                    [ 1 ] = { min = 50, max = 105 },
                }
                local direction_data = direction_borders[ self.current_direction ]

                local block_index = false
                for i = 1, self.count_items do
                    local diff = pane_data.blocks[ i ]:ibData( "py" ) - scroll_py
                    if diff > direction_data.min and diff < direction_data.max then
                        block_index = i
                        break
                    end
                end
                
                local block_symbol = block_index and pane_data.blocks[ block_index .. "lbl" ]:ibData( "text" )
                if block_symbol == self.target_symbol then
                    self.is_animation = true
                    if self.real_current_block == #self.blocks_breakin_direction then
                        self.is_complete = true
                    end

                    self.selector_v:ibData( "texture", "img/master/overlay_select_success_v.png" )
                    pane_data.blocks[ block_index ]:ibData( "texture", "img/master/block_success.png" )

                    self.num_success_symbols = (self.num_success_symbols or 0) + 1
                    
                    self:func_change_breakin_status( "success_symbol" )
                    local result_block = self.result_blocks[ self.current_block ]
                    local wire_result_block = result_block:ibData( "wire" )

                    local px, py = wire_result_block:ibData( "px" ), wire_result_block:ibData( "py" )
                    local wire_result_success = ibCreateImage( px, py, 20, 0, "img/master/wire_success.png", self.bg )
                    
                    wire_result_success:ibInterpolate( function( self_interpolate )
                            if not isElement( self_interpolate.element ) then return end
                            local new_size = 30 * self_interpolate.easing_value
                            self_interpolate.element:ibBatchData( { py = py + 30 - new_size, v = 30 - new_size, u = 0, v_size = new_size, sy = new_size } )
                            if self_interpolate.easing_value == 1 then 
                                local bg_completed_lbl = self.bg_completed_block:ibData( "lbl" )
                                bg_completed_lbl:ibData( "text", tonumber( bg_completed_lbl:ibData( "text" ) ) + 1 )
                                wire_result_block:destroy() 

                                if self.real_current_block == 3 then
                                    self:func_change_plug_state( "left", self.num_success_symbols == 3 and "success" or "fail" )
                                elseif self.real_current_block == 6 then
                                    self:func_change_plug_state( "right", self.num_success_symbols == 6 and "success" or "fail" )
                                end
                            end
                        end, self.anim_duration, "Linear" )
                        
                    wire_result_success:ibTimer( function()
                        local px, py = result_block:ibData( "px" ), result_block:ibData( "py" )
                        local success_block = ibCreateImage( px, py, 96, 66, "img/master/block_success.png", self.bg ):ibData( "alpha", 0 )
                        ibCreateLabel( 0, 0, 96, 66, self.target_symbol, success_block, 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.oxaniumbold_30 )
                        
                        local result_point = result_block:ibData( "point" )
                        success_block:ibAlphaTo( 255, self.anim_duration )
                            :ibTimer( function()
                                result_point:ibData( "texture", "img/master/point_success.png" )
                                self:func_change_breakin_status( "process" )
                                self:func_start_roll_next_pane()
                            end, self.anim_duration, 1 )

                        result_block:destroy()
                    end, self.anim_duration, 1 )
                    
                    pane_data.scroll_v:ibScrollTo( scroll_position, 500, "Linear" )
                    setSoundVolume( playSound( "sfx/hijacking_number_success.ogg" ), 0.5 )
                else
                    self.is_animation = true
                    self.attempts_left = self.attempts_left - 1
                    if self.attempts_left == 0 then
                        pane_data.scroll_v:ibScrollTo( scroll_position, 500, "Linear" )
                        self:func_change_breakin_status( "fail" )
                        setSoundVolume( playSound( "sfx/hijacking_fail.ogg" ), 0.5 )
                        self.fail_callback()
                    else
                        setSoundVolume( playSound( "sfx/hijacking_number_fail.ogg" ), 0.5 )
                        self:func_change_breakin_status( "fail_symbol", self.attempts_left )
                        self.selector_v
                            :ibData( "texture", "img/master/overlay_select_fail_v.png" )
                            :ibTimer( function()
                                self.is_animation = false
                                self.selector_v:ibData( "texture", "img/master/overlay_select_process_v.png" )
                                self:func_change_breakin_status( "process" )
                            end, 1000, 1 )
                    end
                end
            elseif key == "h" then
                self:func_show_minigame_hint( not isElement( self.bg_minigame_hint ) )
            elseif key ~= "z" then
                cancelEvent()
            end
        end
        addEventHandler( "onClientKey", root, self.func_on_client_key_handler )

        self.destroy = function( self )
            removeEventHandler( "onClientKey", root, self.func_on_client_key_handler )

            destroyElement( self.black_bg )
            showCursor( false )
            setCursorAlpha( 255 )

            setmetatable( self, nil )
        end
        
        setCursorAlpha( 0 )
        showCursor( true )

        self:func_start_breakin_process()
        CEs.ui_minigame = self
    elseif CEs.ui_minigame then
        CEs.ui_minigame:destroy()
        CEs.ui_minigame = nil
    end
end

--[[
ToggleMinigameMaster( true, 
{
    hijacked_vehicle = localPlayer.vehicle,
    success_callback = function()

    end,
    password = "ABCDEF",
    fail_callback = function()

    end,
})
--]]