Extend( "ib" )
Extend( "ShAccessories" )
Extend( "ShVehicleConfig" )
Extend( "ShDances" )
Extend( "ShSkin" )
Extend( "ShVinyls" )
Extend( "ShPhone" )

local ACCESSORY_IDS = { }
for id, data in pairs( CONST_ACCESSORIES_INFO ) do
	ACCESSORY_IDS[ data.model ] = { id, data }
end

local CONST_PHONE_IMG_NAMES = { }

for i, wallpaper in pairs( CONST_WALLPAPER ) do
	CONST_PHONE_IMG_NAMES[ wallpaper.img ] = wallpaper.name
end

ibUseRealFonts( true )

local UI_elements = nil

local ANIM_DURATION = 300

function ShowOfferValentineDay( state, data )
    if state and not isElement( REWARD_ELEMENT ) then
        ShowOfferValentineDay( false, { reopen = true } )

        UI_elements = {}
        UI_elements.black_bg = ibCreateBackground( 0xBE1d252e, ShowOfferLastWealth, _, true ):ibData( "alpha", 0 )
        UI_elements.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI_elements.black_bg ):center( )
        
        ibCreateButton( 965, 32, 29, 30, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowOfferValentineDay( false )
            end )

        local days_time_left = math.floor((OFFER_END_DATE - getRealTimestamp()) / 86400)
        local timer_icon = ibCreateImage( days_time_left > 0 and 403 or 381, 154, 163, 24, "img/timer_icon.png", UI_elements.bg )
        ibCreateLabel( timer_icon:ibGetAfterX() + 6, timer_icon:ibGetBeforeY() + 2, 0, 0, getHumanTimeString( OFFER_END_DATE, true ), UI_elements.bg, nil, nil, nil, "left", "top", ibFonts.bold_16 )

        for pack_id, pack_position in ipairs( { { 30, 270 }, { 694, 270 }, { 350, 240 } } ) do
            local pack_data = PACK_DATA[ data.segment_num ][ pack_id ]
            local pack_container = ibCreateImage( pack_position[ 1 ], pack_position[ 2 ], 0, 0, "img/pack_" .. data.segment_num .. "_" .. pack_id .. ".png", UI_elements.bg ):ibSetRealSize()
            
            local container_sy = pack_container:ibData( "sy" )
            local cost_lbl = ibCreateLabel( pack_id == 3 and 188 or 175, container_sy - 124, 0, 0, format_price( pack_data.cost ), pack_container, nil, nil, nil, "left", "top", ibFonts.bold_20 )
            ibCreateImage( cost_lbl:ibGetAfterX() + 7,  cost_lbl:ibGetAfterY() - 26, 26, 22, "img/hard_icon.png", pack_container )

            local true_cost_lbl = ibCreateLabel( pack_id == 3 and 195 or 183, container_sy - 93, 0, 0, format_price( pack_data.true_cost ), pack_container, 0xFFCFD4DC, nil, nil, "left", "top", ibFonts.bold_16 )
            local true_cost_icon = ibCreateImage( true_cost_lbl:ibGetAfterX() + 7, true_cost_lbl:ibGetAfterY() - 20, 20, 17, "img/hard_icon.png", pack_container )
            
            local before_x =  true_cost_lbl:ibGetBeforeX() - 5
            local after_x = true_cost_icon:ibGetAfterX() + 5
            ibCreateImage( before_x, true_cost_icon:ibGetAfterY() - 9, after_x - before_x, 1, _, pack_container, 0xFFE4E7EB )

            ibCreateButton( 0, container_sy - 59, 140, 42, pack_container, "img/btn_details.png", "img/btn_details_hover.png", "img/btn_details_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC ):center_x()
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    ShowPackOverlay( true, pack_id, pack_data )
                end )
        end
        
        local py = UI_elements.bg:ibData( "py" )
        UI_elements.bg:ibData( "py", py - 100 ):ibMoveTo( _, py, ANIM_DURATION )
        UI_elements.black_bg:ibAlphaTo( 255, ANIM_DURATION )

        ibInterfaceSound()
        showCursor( true )
    elseif isElement( UI_elements and UI_elements.black_bg ) and not UI_elements.closed then
        UI_elements.closed = true

        local py = UI_elements.bg:ibData( "py" )
        UI_elements.bg:ibMoveTo( _, py + 100, ANIM_DURATION )
        UI_elements.black_bg:ibAlphaTo( 0, ANIM_DURATION )

        if data and data.reopen then
            destroyElement( UI_elements.black_bg )
            UI_elements = nil
        else
            UI_elements.black_bg:ibTimer( function()
                destroyElement( UI_elements.black_bg )
                UI_elements = nil
            end, ANIM_DURATION, 1 )
        end

        if UI_elements and UI_elements.confirmation then UI_elements.confirmation:destroy() end
        if not REWARD_ELEMENT then showCursor( false ) end
        ibInterfaceSound()
    end
end

function ShowPackOverlay( state, pack_id, pack_data )
    if state then
        if isElement( UI_elements.rt_overlay_pack ) then return end

        UI_elements.rt_overlay_pack = ibCreateRenderTarget( 0, 92, 1024, 628, UI_elements.bg )
        UI_elements.bg_overlay_pack = ibCreateImage( 0, -628, 1024, 628, "img/bg_overlay_pack.png", UI_elements.rt_overlay_pack )

        local discounts = { cupids_set = 30, valentines_present = 40, lupercal = 45 }

        local tittle = ibCreateArea( 0, 21, 0, 0, UI_elements.bg_overlay_pack )
        local tittle_text ="?????????? \"" .. pack_data.name_ingame .. "\""
        local tittle_lbl = ibCreateLabel( -dxGetTextWidth( tittle_text, 1, ibFonts.bold_18 ) / 1.3, 0, 0, 0, tittle_text, tittle, nil, nil, nil, "left", "top", ibFonts.bold_18 )
        local discount_bg = ibCreateImage( tittle_lbl:ibGetAfterX() + 10, 0, 117, 26, "img/bg_discount.png", tittle )
        ibCreateLabel( 0, 0, 117, 26, "???????????? " .. discounts[ pack_data.name ] .. "%", discount_bg, nil, nil, nil, "center", "center", ibFonts.bold_14 )
        tittle:center_x()

        local rewards_count = #pack_data.rewards
        local pack_items_bg = ibCreateImage( 0, 66, 1024, 382, "img/bg_items_" .. rewards_count .. ".png", UI_elements.bg_overlay_pack )
        local available_px = { [ 1 ] = 387, [ 2 ] = 261, [ 3 ] = 130, [ 4 ] = 1 }

        local px = available_px[ rewards_count ]
        for k, v in ipairs( pack_data.rewards ) do
            local lbl_name = ibCreateLabel( px, 0, 256, 31, v.item_name, pack_items_bg, nil, nil, nil, "center", "center", ibFonts.regular_14 )
            if v.quantity > 1 then
                ibCreateLabel( px + dxGetTextWidth( v.item_name, 1, ibFonts.regular_14 ) / 2 + 128, lbl_name:ibData( "py" ) + 6, 0, 0, " x" .. v.quantity, pack_items_bg, nil, nil, nil, "left", "top", ibFonts.bold_14 )
                lbl_name:ibData( "px", lbl_name:ibData( "px" ) - 5 )
            end

            local bg_item = ibCreateImage( px + 10, 62, 236, 288, "img/bg_item.png", pack_items_bg )

            local reward_path = (v.type == "case" and (v.type .. "_" .. v.item_id) or v.type == "soft" and v.type or v.item_id)
            ibCreateImage( 0, 0, 236, 288, "img/rewards/" .. reward_path .. ".png", bg_item )

            if v.type == "case" then
                ibCreateButton( 66, 242, 103, 17, bg_item, "img/btn_details_item.png", "img/btn_details_item.png", "img/btn_details_item.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        ShowPackItemOverlay( true, v )
                    end )
            elseif v.type == "soft" then
                ibCreateLabel( 0, 176, 0, 0, v.cost >= 1000 and (v.cost / 1000 .. "M") or (v.cost .. "K"), bg_item, nil, nil, nil, "center", "top", ibFonts.bold_34 ):center_x()
            end

            px = px + 256
        end

        local true_cost_lbl = ibCreateLabel( 484, 476, 0, 0, format_price( pack_data.true_cost ), UI_elements.bg_overlay_pack, 0xFFD6D7D8, nil, nil, "left", "top", ibFonts.bold_16 )        
        ibCreateImage( 454, 487, true_cost_lbl:ibGetAfterX() - 449, 1, 0xFFE4E7EB, UI_elements.bg_overlay_pack )

        ibCreateLabel( 444, 492, 0, 0, format_price( pack_data.cost ), UI_elements.bg_overlay_pack, nil, nil, nil, "left", "top", ibFonts.bold_27 )

        ibCreateButton( 550, 478, 139, 48, UI_elements.bg_overlay_pack, "img/btn_buy.png", "img/btn_buy_hover.png", "img/btn_buy_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                if UI_elements.confirmation then return end
                UI_elements.confirmation = ibConfirm( {
                    title = "?????????????? ????????", 
                    text = "???? ?????????????? ?????? ???????????? ???????????????????? ??????????\n\"" .. pack_data.name_ingame .. "\" ???? " .. format_price( pack_data.cost ) .. "??.?" ,
                    fn = function( self )
                        self:destroy()
                        UI_elements.confirmation = nil
                        triggerServerEvent( "onServerPlayerWantToBuyValentinePack", resourceRoot, pack_id )
                    end,
                    fn_cancel = function( self )
                        self:destroy()
                        UI_elements.confirmation = nil
                    end,
                    escape_close = true,
                } )
            end )

        ibCreateButton( 460, 558, 104, 40, UI_elements.bg_overlay_pack, "img/btn_hide.png", "img/btn_hide_hover.png", "img/btn_hide_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()

                ShowPackOverlay( false )
            end )

        UI_elements.bg_overlay_pack:ibMoveTo( 0, 0, ANIM_DURATION )
        ibOverlaySound()
    else
        UI_elements.bg_overlay_pack:ibMoveTo( 0, -628, ANIM_DURATION )
        UI_elements.bg_overlay_pack:ibTimer( function()
            destroyElement( UI_elements.rt_overlay_pack )
        end, ANIM_DURATION, 1 )
        ibOverlaySound()
    end
end

function abbreviate_number( number )
	if number >= 1000 then
		number = math.floor( number / 1000 )

		if number >= 1000 then
			number = ( math.floor( number / 100 ) / 10 ) .."??"
		else
			number = number .."??"
		end
	end
	return number
end

function ShowPackItemOverlay( state, item_data )
    if state then
        if isElement( UI_elements.rt_overlay_item ) then return end

        UI_elements.rt_overlay_item = ibCreateRenderTarget( 0, 92, 1024, 628, UI_elements.bg )
        UI_elements.bg_overlay_item = ibCreateImage( 0, -628, 1024, 628, "img/bg_overlay_item_" .. item_data.type .. ".png", UI_elements.rt_overlay_item )
        
        local create_item_img = function( item, bg )
            local img = nil
            local title = ""
            local description = nil
            if item.id == "dance" then
                img = ibCreateContentImage( 0, 0, 90, 90, "animation", item.params.id, bg )
                title = DANCES_LIST[ item.params.id ].name
                description = "????????????????.\n???????????????????? ??????????????????\n?? ?????????? ????????????"
            elseif item.id == "vehicle" then
                img = ibCreateContentImage( 0, 0, 90, 90, item.id, item.params.model .. ( item.params.color and "_" .. item.params.color or "" ), bg ):center()
		        if item.params.temp_days then
                    ibCreateLabel( 0, 0, 0, 0, item.params.temp_days .." ??.", bg ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" }):center( 0, 25 )
		        	img:center( 0, -15 )
                end
                title = VEHICLE_CONFIG[ item.params.model ].model
            elseif item.id == "accessory" then
                img = ibCreateContentImage( 0, 0, 90, 90, item.id, ACCESSORY_IDS[ item.params.model ][ 1 ], bg ):center( )
                title = "?????????????????? " .. ACCESSORY_IDS[ item.params.model ][ 2 ].name
                description = "??????????????????.\n???????????????????? ????????????????\n?? ??????????????????"
            elseif item.id == "wof_coin" then
                img = ibCreateContentImage( 0, 0, 90, 90, "other", "wof_coin_".. item.params.type, bg ):center( )
                ibCreateLabel( 45, 72, 0, 0, item.params.count, img ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
                title = "??????????"
                description = item.params.type == "gold" and "?????? VIP ???????????? ??????????????" or "?????? ???????????? ??????????????"
            elseif item.id == "skin" then
                img = ibCreateContentImage( 0, 0, 90, 90, item.id, item.params.model, bg ):center( )
                title = "???????? " .. SKINS_NAMES[ item.params.model ]
                description = "???????????????? ????????????.\n???????????????????? ????????????????\n?? ??????????????????"
            elseif item.id == "premium" then
                img = ibCreateContentImage( 0, 0, 90, 90, "other", item.id, bg ):center( )
                ibCreateLabel( 45, 72, 0, 0, item.params.days .. " ??.", img ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
                title = "?????????????? ???? ".. item.params.days .." ".. plural( item.params.days, "????????", "??????", "????????" )
            elseif item.id == "soft" then
                img = ibCreateContentImage( 0, 0, 90, 90, "other", item.id, bg ):center( )
                ibCreateLabel( 45, 72, 0, 0, abbreviate_number( item.params.count ), img ):ibBatchData( { font = ibFonts.bold_18, align_x = "center", align_y = "center" } )
                title = format_price( item.params.count ) .. " ??."
            elseif item.id == "vinyl" then
                img = ibCreateContentImage( 0, 0, 90, 90, item.id, item.params.id, bg ):center( )
                title = "?????????? " .. VINYL_NAMES[ params.id ]
                description = "?????????? ?????? ????????????"
            elseif item.id == "box" then
                img = ibCreateContentImage( 0, 0, 90, 90, "other", "box" .. item.params.number, bg ):center( )
                local CONST_BOX_NAMES = {
                    [1] = "?????????? ???????????? ????????????????????";
                    [2] = "?????????? ???????????? ??????????????????";
                }
                title = item.params.name or CONST_BOX_NAMES[ item.params.number ]
            elseif item.id == "phone_img" then
                img = ibCreateContentImage( 0, 0, 90, 90, item.id, item.params.id, bg ):center( )
                title = "???????? ???? ?????????????? - " .. CONST_PHONE_IMG_NAMES[ item.params.id ]
                description = "???????? ???? ??????????????.\n???????????????????? ????????????????\n?? ???????????????? ????????????????"
            end
            
            local description_area	= ibCreateArea( 3, 3, 90, 90, bg )
	        addEventHandler( "ibOnElementMouseEnter", description_area, function( )
	        	if isElement( UI_elements.description_box ) then
	        		destroyElement( UI_elements.description_box )
	        	end
                        
	        	local description_data = { title = title, description = description }
	        	if description_data then
	        		local title_len = dxGetTextWidth( description_data.title, 1, ibFonts.bold_15 ) + 30
	        		local box_s_x = math.max( 170, title_len )
	        		local box_s_y = 92
	        		if not description_data.description then
	        			box_s_x = title_len
	        			box_s_y = 35
	        		end
                
	        		local pos_x, pos_y = getCursorPosition( )
	        		pos_x, pos_y = pos_x * _SCREEN_X, pos_y * _SCREEN_Y
                
	        		UI_elements.description_box = ibCreateImage( pos_x - 5, pos_y - box_s_y - 5, box_s_x, box_s_y, nil, nil, 0xCC000000 ):ibData( "alpha", 0 ):ibAlphaTo( 255, 350 )
	        			:ibOnRender( function ( )
	        				local cx, cy = getCursorPosition( )
	        				cx, cy = cx * _SCREEN_X, cy * _SCREEN_Y
	        				UI_elements.description_box:ibBatchData( { px = cx - 5, py = cy - box_s_y - 5 } )
	        			end )
                    
	        		ibCreateLabel( 0, 17, box_s_x, 0, description_data.title, UI_elements.description_box ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" })
	        		if description_data.description then
	        			ibCreateLabel( 0, 30, box_s_x, 0, description_data.description, UI_elements.description_box, 0xffd3d3d3 ):ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "top" })
	        		end
	        	end
	        end, false )
        
	        addEventHandler( "ibOnElementMouseLeave", description_area, function( )
	        	if isElement( UI_elements.description_box ) then
	        		destroyElement( UI_elements.description_box )
	        	end            
	        end, false )

            return img
        end

        if item_data.type == "case" then
            local case_data = CASES_DATA[ item_data.item_id ]

            ibCreateLabel( 41, 107, 379, 0, case_data.name, UI_elements.bg_overlay_item, nil, nil, nil, "center", "top", ibFonts.bold_26 )
            ibCreateContentImage( 40, 160, 372, 252 , "case", item_data.item_id, UI_elements.bg_overlay_item )

            UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 431, 96, 562, 350, UI_elements.bg_overlay_item, { scroll_px = -20, bg_color = 0xFF315168 } )
            UI_elements.scrollbar:ibSetStyle( "slim_nobg" )

            local px, py = 71, 20
            local rare_colors = { [1] = 0xFFAFF7FF, [2] = 0xFFA975FF, [3] = 0xFFFD56FF, [4] = 0xFFFF6464, [5] = 0xFFFFB346, }
            for k, v in pairs( case_data.items ) do
                local item_bg = ibCreateImage( px, py, 96, 96, "img/item_bg.png", UI_elements.scrollpane )
                
                ibCreateImage( 16, -12, 65, 29, ":nrp_shop/img/cases/rare.png", item_bg, rare_colors[ v.rare ] ):ibData( "disabled", true )
                create_item_img( v, item_bg ):ibData( "disabled", true )

                if k % 4 == 0 then
                    px = 71
                    py = py + 110
                else
                    px = px + 110
                end
            end

            py = py + 110
            ibCreateArea( 0, py, 0, 0, UI_elements.scrollpane )

            UI_elements.scrollpane:AdaptHeightToContents()
            UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
            
            ibCreateImage( 431, 316, 562, 130, "img/bg_gradient.png", UI_elements.bg_overlay_item ):ibData( "disabled", true )
        end

        ibCreateButton( 457, 478, 110, 40, UI_elements.bg_overlay_item, "img/btn_hide_middle.png", "img/btn_hide_middle_hover.png", "img/btn_hide_middle_hover.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowPackItemOverlay( false )
            end )

        UI_elements.bg_overlay_item:ibMoveTo( 0, 0, ANIM_DURATION )
        ibOverlaySound()
    else
        UI_elements.bg_overlay_item:ibMoveTo( 0, -628, ANIM_DURATION ):ibAlphaTo( 0, ANIM_DURATION )
        UI_elements.bg_overlay_item:ibTimer( function()
            destroyElement( UI_elements.rt_overlay_item )
        end, ANIM_DURATION, 1 )
        ibOverlaySound()
    end
end