
ibUseRealFonts( true )

local UI_elements = nil

function ShowNewYearAuctionMenu( state, data )
    if state then
        ShowNewYearAuctionMenu( false )

        UI_elements = {}
        UI_elements.black_bg = ibCreateBackground( 0xF2394A5C, nil, nil ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
        UI_elements.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI_elements.black_bg ):center()
        UI_elements.bg_rt = ibCreateRenderTarget( 631, 151, 393, 569, UI_elements.bg )     
        
        UI_elements.show_rules_func = function()
            if isElement( UI_elements.bg_rt_help ) then return end

            local anim_duration = 250
            ibOverlaySound()

            UI_elements.bg_rt_help = ibCreateRenderTarget( 0, 90, 1024, 630, UI_elements.bg ):ibData( "priority", 1000 )
            local bg_rules = ibCreateImage( 0, -630, 1024, 630, "img/bg_rules.png", UI_elements.bg_rt_help ):ibMoveTo( 0, 0, anim_duration )

            ibCreateButton( 458, 558, 108, 42, bg_rules, "img/btn_hide.png", "img/btn_hide_hover.png", "img/btn_hide_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    if UI_elements.bg_rt_help:ibData( "moved" ) then return end

                    UI_elements.bg_rt_help:ibData( "moved", true )
                    ibOverlaySound()
                    bg_rules:ibMoveTo( 0, -630, anim_duration )
                    bg_rules:ibTimer( function()
                        destroyElement( UI_elements.bg_rt_help )
                        UI_elements.bg_rt_help = nil
                    end, anim_duration, 1 )
                end )
        end

        UI_elements.show_first_rate_menu = function( data )
            if isElement( UI_elements.bg_rate ) then destroyElement( UI_elements.bg_rate ) end
            
            UI_elements.bg_rate = ibCreateImage( 0, 0, 393, 469, "img/bg_first_rate.png", UI_elements.bg_rt )
            
            ibCreateContentImage( 30, 52, 130, 160, "skin", localPlayer.model, UI_elements.bg_rate )

            ibCreateButton( 107, 430, 180, 39, UI_elements.bg_rate, "img/btn_rate.png", "img/btn_rate_hover.png", "img/btn_rate_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
                    local value = tonumber( UI_elements.first_rate_value )
                    if not value or value < CONST_MIN_RATE then
                        localPlayer:ShowError( "Минимальная начальная сумма: " .. format_price( CONST_MIN_RATE ) .. "p." )
                        return false
                    end

                    ShowConfirmation( "Ты уверен, что хочешь внести " .. format_price( value ) .. "р. для ставки?", "onServerPlayerTryAddNewYearAuctionRate", { value } )
                end )

            UI_elements.dummy_rate_sum_lbl = ibCreateLabel( 95, 370, 230, 40, "Введите ставку", UI_elements.bg_rate, 0xFFAEB4BB, nil, nil, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
            UI_elements.edf_rate_sum = ibCreateEdit( 95, 370, 230, 40, "", UI_elements.bg_rate, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_14 )
                :ibOnClick( function()
                    if isElement( UI_elements.dummy_rate_sum_lbl  ) then destroyElement( UI_elements.dummy_rate_sum_lbl  ) end
                end )
                :ibOnDataChange( function( key, value, old )
                    if key ~= "text" then return end

                    local illegal_symbols = utf8.match( value, "[^0-9]+" )
                    local len = utf8.len( value )
                    if illegal_symbols or len > 10 then
                        UI_elements.edf_rate_sum:ibData( "text", old )
                        UI_elements.edf_rate_sum:ibData( "caret_position", 0 )

                        UI_elements.edf_rate_sum:ibKillTimers()
                        UI_elements.edf_rate_sum:ibTimer( function()
                            UI_elements.edf_rate_sum:ibData( "caret_position", utf8.len( old ) )
                        end, 50, 1 )
                        return
                    end

                    UI_elements.first_rate_value = value
                end )

            return true
        end

        UI_elements.show_rerate_menu = function( data )
            local func_refresh_leader = function()
                UI_elements.cur_leader_lbl:ibData( "text", data.auction_leader.nickname:gsub( " ", "\n" ) )
                UI_elements.leader_rate_lbl:ibData( "text",  format_price( data.auction_leader.value ) )
                UI_elements.leader_rate_icon:ibData( "px", UI_elements.leader_rate_lbl:ibGetAfterX() + 9 )

                UI_elements.cur_rate_lbl:ibData( "text", format_price( data.cur_rate ) )
                UI_elements.cur_rate_icon:ibData( "px", UI_elements.cur_rate_lbl:ibGetAfterX() + 7 )

                UI_elements.cur_rate = data.cur_rate
                UI_elements.finish_rate_sum_lbl:ibData( "text",  format_price( UI_elements.cur_rate ) )

                if not isElement( UI_elements.dummy_rate_sum_lbl ) then
                    UI_elements.dummy_rate_sum_lbl = ibCreateLabel( 95, 316, 230, 40, "Введите ставку", UI_elements.bg_rate, 0xFFD8DBDE, nil, nil, "left", "center", ibFonts.regular_14 ):ibBatchData( { disabled = true, priority = -1 } )
                end

                UI_elements.edf_rate_sum:ibData( "text", "" )
                UI_elements.edf_rate_sum:ibData( "caret_position", 0 )

                UI_elements.rate_value = 0

                if data.auction_leader.skin_id ~= 0 then
                    if isElement( UI_elements.skin_icon ) then destroyElement( UI_elements.skin_icon ) end
                    UI_elements.skin_icon = ibCreateContentImage( 30, 52, 130, 160, "skin", data.auction_leader.skin_id, UI_elements.bg_rate ) 
                end
            end
            
            if isElement( UI_elements.bg_rate ) and data.is_first_bet then
                UI_elements.old_bg_rate = UI_elements.bg_rate 
                UI_elements.old_bg_rate:ibMoveTo( -393, _, 250 )
                UI_elements.old_bg_rate:ibAlphaTo( 0, 250 )
                UI_elements.old_bg_rate:ibTimer( function()
                    destroyElement( UI_elements.old_bg_rate )
                end, 250, 1 )

                ibOverlaySound()
            elseif isElement( UI_elements.bg_rate ) then
                func_refresh_leader()
                UI_elements.refresh_time_out( data, false )
                return true
            end

            UI_elements.bg_rate = ibCreateImage( 393, 0, 393, 538, "img/bg_rerate.png", UI_elements.bg_rt ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibMoveTo( 0, _, 250 )

            UI_elements.cur_leader_lbl = ibCreateLabel( 179, 82, 0, 0, 0, UI_elements.bg_rate, nil, nil, nil, "left", "top", ibFonts.bold_18 ):ibData( "priority", 100 )
            UI_elements.leader_rate_lbl = ibCreateLabel( 179, 169, 0, 0, 0, UI_elements.bg_rate, nil, nil, nil, "left", "top", ibFonts.bold_26 ):ibData( "priority", 100 )
            UI_elements.leader_rate_icon = ibCreateImage( 0, 175, 28, 24, "img/hard.png", UI_elements.bg_rate ):ibData( "priority", 100 )
            
            ibCreateLabel( 71, 252, 0, 0, "Ваша текущая ставка:", UI_elements.bg_rate, nil, nil, nil, "left", "top", ibFonts.regular_16 ):ibData( "priority", 100 )
            UI_elements.cur_rate_lbl = ibCreateLabel( 247, 250, 0, 0, 0, UI_elements.bg_rate, nil, nil, nil, "left", "top", ibFonts.bold_18 ):ibData( "priority", 100 )
            UI_elements.cur_rate_icon = ibCreateImage( 0, 253, 20, 17, "img/hard.png", UI_elements.bg_rate ):ibData( "priority", 100 )

            UI_elements.finish_rate_sum_lbl = ibCreateLabel( 95, 439, 230, 40, 0, UI_elements.bg_rate, 0xFFD8DBDE, nil, nil, "left", "center", ibFonts.regular_14 )
            UI_elements.edf_rate_sum = ibCreateEdit( 95, 316, 230, 40, "", UI_elements.bg_rate, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_14 )
                :ibOnClick( function()
                    if isElement( UI_elements.dummy_rate_sum_lbl  ) then destroyElement( UI_elements.dummy_rate_sum_lbl  ) end
                end )
                :ibOnDataChange( function( key, value, old )
                    if key ~= "text" then return end

                    local illegal_symbols = utf8.match( value, "[^0-9]+" )
                    local len = utf8.len( value )
                    if illegal_symbols or len > 10 then
                        UI_elements.edf_rate_sum:ibData( "text", old )
                        UI_elements.edf_rate_sum:ibData( "caret_position", 0 )

                        UI_elements.edf_rate_sum:ibKillTimers()
                        UI_elements.edf_rate_sum:ibTimer( function()
                            UI_elements.edf_rate_sum:ibData( "caret_position", utf8.len( old ) )
                        end, 50, 1 )
                        return
                    end

                    UI_elements.rate_value = tonumber( value ) or 0
                    UI_elements.finish_rate_sum_lbl:ibData( "text", format_price( UI_elements.cur_rate + UI_elements.rate_value ) )
                end )

            ibCreateButton( 107, 499, 180, 39, UI_elements.bg_rate, "img/btn_rerate.png", "img/btn_rerate_hover.png", "img/btn_rerate_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
                    local value = tonumber( UI_elements.rate_value )
                    if not value or value == 0 then
                        localPlayer:ShowError( "Некорректная сумма!" )
                        return false
                    end

                    ShowConfirmation( "Ты уверен, что хочешь внести " .. format_price( value ) .. "р. для ставки?", "onServerPlayerTryAddNewYearAuctionRate", { value } )
                end )
            
            UI_elements.refresh_time_out( data, true ) 
            func_refresh_leader()

            return true
        end
        
        UI_elements.refresh_time_out = function( data, ignore_animation )
            if data.timeout - getRealTimestamp() > 0 then
                if isElement( UI_elements.bg_rate_overlay_timeout ) then return end

                UI_elements.bg_rate_overlay_timeout = ibCreateImage( 0, ignore_animation and 0 or 569, 393, 569, "img/bg_rerate_overlay.png", UI_elements.bg_rate )
                if not ignore_animation then UI_elements.bg_rate_overlay_timeout:ibMoveTo( _, 0, 250 ) end

                ibCreateLabel( 183, 375, 0, 0, getHumanTimeString( data.timeout ), UI_elements.bg_rate_overlay_timeout, nil, nil, nil, "left", "top", ibFonts.bold_16 )

                local cost_drop_lbl = ibCreateLabel( 250, 414, 0, 0, format_price( COST_DROP_TIMEOUT ), UI_elements.bg_rate_overlay_timeout, nil, nil, nil, "left", "top", ibFonts.bold_18 )
                ibCreateImage( cost_drop_lbl:ibGetAfterX() + 8, 417, 20, 17, "img/hard.png", UI_elements.bg_rate_overlay_timeout )

                ibCreateButton( 111, 453, 166, 39, UI_elements.bg_rate_overlay_timeout, "img/btn_skip.png", "img/btn_skip_hover.png", "img/btn_skip_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        
                        ShowConfirmation( "Ты уверен, что хочешь внести " .. format_price( COST_DROP_TIMEOUT ) .. "р. для пропуска времени?", "onServerPlayerTryDropTimeout", {} )
                    end )
                
                ibOverlaySound()

            elseif isElement( UI_elements.bg_rate_overlay_timeout ) then
                UI_elements.bg_rate_overlay_timeout:ibMoveTo( _, 569, 250 )
                UI_elements.bg_rate_overlay_timeout:ibTimer( function()
                    destroyElement( UI_elements.bg_rate_overlay_timeout )
                end, 250, 1 )
                
                ibOverlaySound()
            end
        end


        local timer_icon = ibCreateImage( 527, 33, 192, 24, "img/timer_icon.png", UI_elements.bg )
        ibCreateLabel( timer_icon:ibGetAfterX(), 35, 100, 40, getHumanTimeString( OFFER_END_DATE, true ), UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.bold_16 )

        ibCreateButton( 835, 30, 107, 31, UI_elements.bg, "img/btn_help.png", "img/btn_help_hover.png", "img/btn_help_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                UI_elements.show_rules_func( )
            end )

        ibCreateButton( 972, 35, 22, 22, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowNewYearAuctionMenu( false )
            end )


        local result = data.auction_leader.player_id == -1 and UI_elements.show_first_rate_menu( data ) or UI_elements.show_rerate_menu( data )

        showCursor( true )
    elseif isElement( UI_elements and UI_elements.black_bg ) then
        destroyElement( UI_elements.black_bg )
        if UI_elements.confirmation then UI_elements.confirmation:destroy() end

        UI_elements = nil
        showCursor( false )
    end
end

function ShowConfirmation( text, callback_event, args )
    if UI_elements.confirmation then return end

    UI_elements.confirmation = ibConfirm( {
	    title = "НОВОГОДНИЙ АУКЦИОН", 
	    text = text,
	    fn = function( self )
	    	triggerServerEvent( callback_event, resourceRoot, unpack( args ) )
            self:destroy( )
            UI_elements.confirmation = nil
        end,
        fn_cancel = function( self )
            UI_elements.confirmation = nil
        end
	} )
end

function RefreshRateUI( data )
    if UI_elements then UI_elements.show_rerate_menu( data ) end
end