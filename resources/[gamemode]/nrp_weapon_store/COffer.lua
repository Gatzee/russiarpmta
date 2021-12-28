loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local ui = { }

function ShowGunShopOffer_handler( state, is_up_segment )
	if state then
		ShowGunShopOffer_handler( )


		ui.black_bg = ibCreateBackground( _, ShowGunShopOffer_handler, true, true ):ibData( "alpha", 0 )
		ui.bg = ibCreateImage( 0, 0, 1024, 720, "img/offer/bg.png", ui.black_bg ):ibSetRealSize( ):center( )

		-- закрыть
		ibCreateButton( 971, 28, 24, 24, ui.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			ShowGunShopOffer_handler( false, is_up_segment )
		end, false )

		-- таймер
		local tick = getTickCount( )
		local label_elements = { { 585,  127 }, { 614, 127 }, { 661, 127 }, { 688, 127 }, { 732, 127 }, { 760, 127 }, }
		for i, v in pairs( label_elements ) do
			ui[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ] + 44, v[ 2 ] + 7, 0, 0, "0", ui.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
		end

		local end_time = localPlayer:getData( "gun_shop_offer_finish" ) or 0
		local time_left = end_time - getRealTimestamp()
        local function UpdateTimer( )
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
                local element = ui[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end
        ui.bg:ibTimer( UpdateTimer, 500, 0 )
		UpdateTimer( )

		local segment = localPlayer:getData( "weapon_shop_segment" )
		local positions = { 30, 358, 686 }

		-- паки
		local position = 1
		for k, v in pairs( SEGMENTS[ segment ].packs ) do
			ibCreateImage( positions[ position ], 180, 308, 446, "img/offer/offer_" .. k .. ".png", ui.bg )
			position = position + 1
		end

		-- отметить на карте
		if not is_up_segment then
			ibCreateButton( 388, 645, 248, 44, ui.bg, "img/offer/btn_map_i.png", "img/offer/btn_map_h.png", "img/offer/btn_map_h.png" )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				triggerEvent( "ToggleGPS", localPlayer, {
					{ x = 172.112, y = -2130.621, z = 22.021 },
					{ x = -84.85, y = 2512.88, z = 21.61, },
				} )
				ShowGunShopOffer_handler( )
			end, false )
		end

		ui.black_bg:ibAlphaTo( 255 )
		showCursor( true )
	else
		DestroyTableElements( ui )
		if is_up_segment then return end
		showCursor( false )
	end
end
addEvent( "ShowGunShopOffer", true )
addEventHandler( "ShowGunShopOffer", resourceRoot, ShowGunShopOffer_handler )

function ActivateGunShopOffer_handler( finish_date )
	triggerEvent( "ShowSplitOfferInfo", root, "gun_shop", finish_date - getRealTimestamp( ) )
	localPlayer:setData( "gun_shop_offer_finish", finish_date, false )
	ShowGunShopOffer_handler( true )
end
addEvent( "ActivateGunShopOffer", true )
addEventHandler( "ActivateGunShopOffer", resourceRoot, ActivateGunShopOffer_handler )