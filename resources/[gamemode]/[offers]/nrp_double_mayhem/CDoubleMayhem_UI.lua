

local UI_elements = { }

function ShowDoubleMayhemOfferUI( state, data )
    if state then
		ShowDoubleMayhemOfferUI( false )

        local left_pack = data.pack_data[ PACKS_STRING_ID[ 1 ] ]
		local right_pack = data.pack_data[ PACKS_STRING_ID[ 2 ] ]

		UI_elements.black_bg = ibCreateBackground( nil, ShowDoubleMayhemOfferUI, true, true )
		UI_elements.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI_elements.black_bg ):center( )

        ibCreateImage( 0, 159, 964, 541, "img/bg_content.png", UI_elements.bg )
            :ibData( "priority", 4 )
            :center_x()

		ibCreateButton( 971, 28, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                ShowDoubleMayhemOfferUI( false )
			end, false )

        ibCreateLabel( 0, 33, 1024, 0, "Акция: “" .. OFFER_NAME_RU .. "”", UI_elements.bg, nil, nil, nil, "center", "center", ibFonts.bold_20 )

		local label_elements = { { 586,  123 }, { 614, 123 }, { 660, 123 }, { 688, 123 }, { 731, 123 }, { 760, 123 }, }
		for i, v in pairs( label_elements ) do
			UI_elements[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ] + 5, v[ 2 ] + 7, 0, 0, "0", UI_elements.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
		end

        local tick = getTickCount( )
		local time_left = ( localPlayer:getData( "double_mayhem_offer_finish" ) or 0 ) - getRealTimestamp()
        local function func_update_timer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( time_left - passed / 1000 )

            if time_diff < 0 then OFFER_A_LEFT = nil return end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

            if hours > 99 then minutes = 60; seconds = 0 end

            hours = string.format( "%02d", math.min( hours, 99 ) )
            minutes = string.format( "%02d", math.min( minutes, 60 ) )
            seconds = string.format( "%02d", seconds )

            local str = hours .. minutes .. seconds

            for i = 1, #label_elements do
                local element = UI_elements[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end
        UI_elements.bg:ibTimer( func_update_timer, 500, 0 )
		func_update_timer( )
        
        ibCreateButton(	76, 676, 130, 12, UI_elements.bg, "img/btn_details", true )
            :ibData( "priority", 5 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				ShowDoubleMayhemOfferUIInfo( true )
			end, false )

		ibCreateButton(	821, 676, 130, 12, UI_elements.bg, "img/btn_details", true )
            :ibData( "priority", 5 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				ShowDoubleMayhemOfferUIInfo( true )
			end, false )

		if not right_pack and left_pack then
			ibCreateImage( 60, 103, 167, 50, "img/pack_tooltip.png", UI_elements.bg )
            ibCreateImage( 254, 176, 312, 524, "img/bg_block_left.png", UI_elements.bg )
            ibCreateImage( 250, 582, 526, 92, "img/open_right.png", UI_elements.bg )
        elseif not left_pack and right_pack then
            ibCreateImage( 801, 103, 167, 50, "img/pack_tooltip.png", UI_elements.bg )
            ibCreateImage( 513, 176, 259, 524, "img/bg_block_right.png", UI_elements.bg )
            ibCreateImage( 250, 582, 526, 92, "img/open_left.png", UI_elements.bg )
        end

		if right_pack then
			ibCreateLabel( 141, 443, 0, 0, "Куплено", UI_elements.bg, 0xFFABB0B7, _, _, "center", "center", ibFonts.bold_16 ):ibData( "priority", 5 )
			ibCreateImage( 254, 176, 259, 524, "img/bg_open_left.png", UI_elements.bg )
		else
			ibCreateImage( 254, 176, 259, 524, "img/bg_block_chain_left.png", UI_elements.bg )
			ibCreateButton(	77, 424, 130, 39, UI_elements.bg, "img/btn_buy", true )
                :ibData( "priority", 5 )
			    :ibOnClick( function( key, state )
			    	if key ~= "left" or state ~= "up" then return end
			    	ibClick( )
			    	triggerServerEvent( "onServerPlayerTryPurchaseDoubleMayhemPack", resourceRoot, PACKS_STRING_ID[ 2 ] )
			    end, false )
		end

		if left_pack then
			ibCreateLabel( 884, 443, 0, 0, "Куплено", UI_elements.bg, 0xFFABB0B7, _, _, "center", "center", ibFonts.bold_16 ):ibData( "priority", 5 )
			ibCreateImage( 513, 176, 258, 524, "img/bg_open_right.png", UI_elements.bg )
		else
			ibCreateImage( 513, 176, 258, 524, "img/bg_block_chain_right.png", UI_elements.bg )
			ibCreateButton(	816, 424, 130, 39, UI_elements.bg, "img/btn_buy", true )
                :ibData( "priority", 5 )
			    :ibOnClick( function( key, state )
			    	if key ~= "left" or state ~= "up" then return end
			    	ibClick( )
			    	triggerServerEvent( "onServerPlayerTryPurchaseDoubleMayhemPack", resourceRoot, PACKS_STRING_ID[ 1 ] )
			    end, false )
		end

		if not right_pack and not left_pack then
            ibCreateImage( 254, 176, 258, 524, "img/bg_block_left.png", UI_elements.bg )
            ibCreateImage( 513, 176, 258, 524, "img/bg_block_right.png", UI_elements.bg )
            ibCreateImage( 249, 582, 525, 92, "img/block_all.png", UI_elements.bg )
        elseif right_pack and left_pack then
            ibCreateImage( 250, 582, 526, 92, "img/open_all.png", UI_elements.bg )
        end

        local gift_data = OFFER_CONFIG.gift
        ibCreateContentImage( 0, 0, 600, 316, gift_data.type, gift_data.params.model .. ( gift_data.params.color and "_" .. gift_data.params.color or "" ), UI_elements.bg )
            :ibBatchData( { sx = 600 * 0.7, sy = 313 * 0.7 } )
            :center( 0, 65 )

		ibCreateLabel( 512, 200, 0, 0, "Купи оба набора и получи тачку в подарок", UI_elements.bg, 0xffffffff, _, _, "center", "center", ibFonts.bold_18 )

        showCursor( true )
	elseif isElement( UI_elements and UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
        showCursor( false )
	end
end

function IsUIActive()
    return isElement( UI_elements and UI_elements.black_bg )
end

function ShowDoubleMayhemOfferUIInfo( state )
    if not UI_elements.black_bg then return end

	local sx, sy = 1024, 630

    if state then
        ShowDoubleMayhemOfferUIInfo( )

        UI_elements.info_rt = ibCreateRenderTarget( 0, 92, sx, sy, UI_elements.bg ):ibData( "priority", 6 )
		UI_elements.info = ibCreateImage( 0, -sx, sx, sy, "img/info.png", UI_elements.info_rt )
		
        local px, py = 125, 285
        for k, v in pairs( OFFER_CONFIG.packs[ PACKS_STRING_ID[ 2 ] ].items ) do
            local bg_item = ibCreateImage( px, py, 122, 122, "img/bg_item.png", UI_elements.info )
            REGISTERED_ITEMS[ v.type ].uiCreateItem_func( v.type, v.params, bg_item )

            local item_info = REGISTERED_ITEMS[ v.type ].uiGetDescriptionData_func( v.type, v.params )
            bg_item:ibAttachTooltip( item_info.title .. (item_info.description and "\n" .. item_info.description or "") )

            ibCreateLabel( 0, 90, 122, 0, "x" .. (v.params.count or v.params.number or 1), bg_item, 0xFFFFFFFF, _, _, "center", "top", ibFonts.oxaniumbold_14 )

            px = (k % 2 == 0 and 125 or px + 130)
            py = py + (k % 2 == 0 and 130 or 0)
        end

        local px, py = 575, 285
        for k, v in pairs( OFFER_CONFIG.packs[ PACKS_STRING_ID[ 1 ] ].items ) do
            local bg_item = ibCreateImage( px, py, 122, 122, "img/bg_item.png", UI_elements.info )
            REGISTERED_ITEMS[ v.type ].uiCreateItem_func( v.type, v.params, bg_item )

            local item_info = REGISTERED_ITEMS[ v.type ].uiGetDescriptionData_func( v.type, v.params )
            bg_item:ibAttachTooltip( item_info.title .. (item_info.description and "\n" .. item_info.description or "") )

            ibCreateLabel( 0, 90, 122, 0, "x" .. (v.params.count or v.params.number or 1), bg_item, 0xFFFFFFFF, _, _, "center", "top", ibFonts.oxaniumbold_14 )

            px = (k % 3 == 0 and 642 or px + 130)
            py = py + (k % 3 == 0 and 130 or 0)
        end

		ibCreateButton(	458, 604 - 46, 108, 42, UI_elements.info, "img/btn_hide", true )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end

                ibClick( )
                ShowDoubleMayhemOfferUIInfo( )
            end )

        UI_elements.info
            :ibMoveTo( 0, 0, 300 )

        ibOverlaySound()
    elseif isElement( UI_elements.info_rt ) then
        UI_elements.info
            :ibMoveTo( 0, -sy, 300 )
            :ibTimer( function()
                destroyElement( UI_elements.info_rt )
            end, 300, 1 )
        ibOverlaySound()
    end
end