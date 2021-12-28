
local UI_elements = nil
local ANIM_DURATION = 250


function ShowOfferUI( state, data )
    if state then
        ShowOfferUI( false )

        UI_elements = {}

        UI_elements.func_get_guman_timestring = function( self, time_diff )
            local time_str = ""

            local s1h = 60 * 60        
            local hours = math.floor( time_diff / s1h )
            if hours > 0 then
                time_diff = time_diff - hours * s1h
                time_str = hours .. " ч."
            end
            
            minutes = math.max( 1, time_diff - hours * s1h )
            if minutes > 0 then
                time_str = time_str .. " " .. minutes .. " м."
            end

            return time_str
        end

        UI_elements.func_try_purchase_pack = function( self, pack_index )
            if self.confirmation then return end
            
            self.confirmation = ibConfirm( {
                title = "ПОКУПКА ПАКА", 
                text = "Вы уверены что хотите приобрести набор\nза " .. format_price( PACK_DATA[ pack_index ].cost ) .. "р.?" ,
                fn = function( self_element )
                    self_element:destroy()
                    self.confirmation = nil
                    onClientSelectOfferDiscountDayInBrowser_handler( PACK_ID, PACK_DATA[ pack_index ].cost )
                end,
                fn_cancel = function( self_element )
                    self_element:destroy()
                    self.confirmation = nil
                end,
                escape_close = true,
            } )
        end

        UI_elements.func_refresh_nums_pack = function( self, num_purchased_packs )
            if isElement( self.bg_last_ticket ) then destroyElement( self.bg_last_ticket ) end

            local last_ticket_opened = num_purchased_packs == #PACK_DATA
            self.bg_last_ticket = ibCreateImage( 9, 362, 1007, 448, "img/bg_last_ticket_" .. (last_ticket_opened and "opened" or "blocked") .. ".png", self.bg ):ibData( "priority", -1 )
            if last_ticket_opened then
                ibCreateButton( 730, 249, 198, 64, self.bg_last_ticket, "img/btn_desc.png", "img/btn_desc_h.png", "img/btn_desc_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                    
                        ShowOfferUI( false )
                        triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "special" )
                    end )
            else
                ibCreateLabel( 836, 278, 0, 0, num_purchased_packs, self.bg_last_ticket, 0xFFf7f6f5, nil, nil, "left", "top", ibFonts.regular_18 )
            end
        end

        UI_elements.black_bg = ibCreateBackground( 0xBF11202A, nil, nil, false ):ibData( "alpha", 0 )
        UI_elements.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI_elements.black_bg ):center( )
        ibCreateButton( 966, 31, 30, 30, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowOfferUI( false )
            end )

        local time_diff = math.max( 0, OFFER_END_DATE - getRealTimestamp() )
        local timer_icon = ibCreateImage( 670, 23, 163, 24, "img/timer_hours.png", UI_elements.bg )
        ibCreateLabel( timer_icon:ibGetAfterX() + 6, timer_icon:ibGetBeforeY() + 2, 0, 0, UI_elements:func_get_guman_timestring( time_diff ), UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.bold_16 )
        
        UI_elements.func_show_info_overlay = function( self, state )
            if state and not isElement( self.rt_info_overlay ) then
                self.rt_info_overlay = ibCreateRenderTarget( 0, 92, 1024, 720, self.bg )
                self.bg_info_overlay = ibCreateImage( 0, -628, 1024, 628, "img/bg_info_overlay.png", self.rt_info_overlay )

                ibCreateButton( 30, 42, 103, 16, self.bg_info_overlay, "img/btn_back.png", "img/btn_back_h.png", "img/btn_back_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                    
                        self:func_show_info_overlay( false )
                    end )
                
                self.bg_info_overlay:ibMoveTo( nil, 0, ANIM_DURATION )
                ibOverlaySound()
            elseif isElement( self.bg_info_overlay ) and not self.bg_info_overlay:ibData( "anim" ) then
                self.bg_info_overlay:ibData( "anim", true )
                self.bg_info_overlay:ibMoveTo( 0, -628, ANIM_DURATION )
                self.bg_info_overlay:ibTimer( function()
                    destroyElement( self.rt_info_overlay )
                end, ANIM_DURATION, 1 )
                ibOverlaySound()
            end
        end

        ibCreateButton( timer_icon:ibGetBeforeX() + 35, 52, 75, 13, UI_elements.bg, "img/btn_help.png", "img/btn_help.png", "img/btn_help.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                UI_elements:func_show_info_overlay( true )
            end )

        local px, py = 12, 94
        for i = 1, 2 do
            local _btn = ibCreateImage( px, py, 508, 286, "img/bg_item_" .. i .. ".png", UI_elements.bg )
            ibCreateArea( 306, 60, 85, 45, _btn ):ibAttachTooltip( PACK_DATA[ i ].discount_text )

            ibCreateArea( 20, 197, 468, 69, _btn )
                :ibOnHover( function ( ) _btn:ibData( "texture", "img/bg_item_" .. i .. "_h.png" ) end )
                :ibOnLeave( function ( ) _btn:ibData( "texture", "img/bg_item_" .. i .. ".png" ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    UI_elements:func_try_purchase_pack( i )
                end )
            
            px = px + 492
        end
        
        UI_elements:func_refresh_nums_pack( data.num_purchased_packs )
        
        local px, py = 13, 356
        for i = 3, 6 do
            local _btn = ibCreateImage( px, py, 260, 217, "img/bg_item_" .. i .. ".png", UI_elements.bg )
            ibCreateArea( 165, 60, 62, 40, _btn ):ibAttachTooltip( PACK_DATA[ i ].discount_text )

            ibCreateArea( 19, 146, 222, 51, _btn )
                :ibOnHover( function ( ) _btn:ibData( "texture", "img/bg_item_" .. i .. "_h.png" ) end )
                :ibOnLeave( function ( ) _btn:ibData( "texture", "img/bg_item_" .. i .. ".png" ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    UI_elements:func_try_purchase_pack( i )
                end )
                
            px = px + 246
        end

        local py = UI_elements.bg:ibData( "py" )
        UI_elements.bg:ibData( "py", py - 100 ):ibMoveTo( _,py, ANIM_DURATION )
        UI_elements.black_bg:ibAlphaTo( 255, ANIM_DURATION )
        ibInterfaceSound()

        showCursor( true )
    elseif IsUIActive() then
        destroyElement( UI_elements.black_bg )
        UI_elements = nil

        showCursor( false )
    end
end

function ShowPackRewards( state, pack_index, num_purchased_packs )
    if state then
        HidePaymentWindow( )
        ShowPackRewards( false )

        if not IsUIActive() then
            UI_elements = {}
            UI_elements.black_bg = ibCreateBackground( 0xBF11202A, nil, nil, false )
            showCursor( true )
        elseif UI_elements.func_refresh_nums_pack then
            UI_elements:func_refresh_nums_pack( num_purchased_packs )
        end

	    UI_elements.reward_element = ibCreateDummy( UI_elements.black_bg )

        triggerEvent( "ShowTakeReward", UI_elements.reward_element, UI_elements.black_bg, "hard", { params = { count = PACK_DATA[ pack_index ].value_sum } } )
        addEventHandler( "ShowTakeReward_callback", UI_elements.reward_element, function( data )
            ShowPackRewards( false )
        end )
    elseif IsUIActive() then
        if not isElement( UI_elements and UI_elements.bg ) then
            UI_elements.black_bg:destroy()
            UI_elements = nil
        elseif isElement( UI_elements and UI_elements.reward_element ) then
            UI_elements.reward_element:destroy()
        end
    end
end

function IsUIActive()
    return isElement( UI_elements and UI_elements.black_bg )
end