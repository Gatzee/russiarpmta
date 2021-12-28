loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShUtils" )

ibUseRealFonts( true )

UIe = { }

function ShowUI( days )
	if isElement( UIe.black_bg ) then return end

	showCursor( true )

	UIe.black_bg = ibCreateBackground( _, _, true )

	UIe.bg = ibCreateImage( 0, 0, 800, 570, "images/bg.png", UIe.black_bg ):center( )
	UIe.btn_close = ibCreateButton( 747, 25, 22, 22, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
			showCursor( false )
		end )

	UIe.btn_balance = ibCreateButton( 644, 83, 126, 34, UIe.bg, "images/btn_balance", true )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
			showCursor( false )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "annuity_payments" )
		end )

	local balance_text = ibCreateLabel( 510, 101, 0, 0, format_price( localPlayer:GetDonate( ) ), UIe.bg )
		:ibBatchData( { font = ibFonts.bold_18, align_x = "left", align_y = "center" })
	ibCreateImage( balance_text:ibGetAfterX( 8 ), 87, 28, 28, ":nrp_shared/img/hard_money_icon.png", UIe.bg )

	if days then
		local can_take = false

		-- Инфо бар о возможности забрать награду
		do
			local can_take_days = nil
			for day in ipairs( CONST_DAYS ) do
				if days[ day ] == DAY_RECEIVED then
					can_take = true

					if can_take_days then
						can_take_days = can_take_days ..", ".. day .." день"
					else
						can_take_days = day .." день"
					end
				end
			end
			
			if can_take then
				local bg = ibCreateImage( 373, 128, 427, 68, "images/bg_can_take.png", UIe.bg )
				ibCreateLabel( 0, 46, 0, 0, can_take_days, bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "center", "center", ibFonts.regular_14 ):center_x( )
			end
		end

		-- Содержимое пакета
		do
			local offset_y = can_take and 70 or 0
			ibCreateLabel( 585, 155 + offset_y, 0, 0, "Содержимое пакета:", UIe.bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_16 )

			UIe.scrollpane, UIe.scrollbar	= ibCreateScrollpane( 431, 183 + offset_y, 369, 387 - offset_y, UIe.bg, { scroll_px = -20, bg_color = 0 } )
			UIe.scrollbar:ibBatchData( { absolute = true, sensivity = 50 } ):ibSetStyle( "slim_small_nobg" )

			for day, data in pairs( CONST_DAYS ) do
				local bg = ibCreateImage( 110 * ( ( day - 1 ) % 3 ), 127 * math.floor( ( day - 1 ) / 3 ), 92, 92, "images/bg_day.png", UIe.scrollpane )

				if days[ day ] == DAY_RECEIVED then

					local img_received = ibCreateImage( 0, 0, 92, 92, "images/day_received.png", bg ):ibData( "alpha", 0 )
					
					local func_interpolate = function( self )
						self:ibInterpolate( function( self )
							if not isElement( self.element ) then return end
							local easing_value = 255 * self.easing_value
							self.element:ibData( "alpha", easing_value )
						end, 1000, "SineCurve" )
					end
		
					img_received:ibTimer( func_interpolate, 1000, 0 )
						:ibTimer( func_interpolate, 50, 1 )
				end

				local bg_items = ibCreateArea( 0, 0, 92, 92, bg )

				ibCreateImage( 0, 0, 29, 29, "images/icon_".. data[ 2 ] ..".png", bg_items ):center( -23, -23 ):ibData( "alpha" )
				ibCreateLabel( 0, 0, 0, 0, "+", bg_items, COLOR_WHITE, _, _, "center", "center", ibFonts.light_12 ):center( 0, -22 )
				ibCreateImage( 0, 0, 29, 29, "images/icon_".. data[ 3 ] ..".png", bg_items ):center( 23, -23 )

				ibCreateImage( 0, 40, 28, 28, ":nrp_shared/img/money_icon.png", bg_items ):center_x( )
				ibCreateLabel( 0, 76, 0, 0, format_price( data[ 1 ] ), bg_items, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_14 ):center_x( )

				ibCreateLabel( 0, 0, 0, 0, day .." день", bg, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_14 ):center( 0, 60 )

				if not days[ day ] then
					bg:ibData( "alpha", 50 )

				elseif days[ day ] == DAY_TAKEN then
					bg_items:ibData( "alpha", 50 )
					ibCreateImage( 1, 1, 90, 90, "images/day_taken.png", bg )

				elseif days[ day ] == DAY_MISSED then
					bg_items:ibData( "alpha", 50 )
					ibCreateImage( 1, 1, 90, 90, "images/day_missed.png", bg )

				elseif days[ day ] == DAY_RECEIVED then
				end
			end

			UIe.scrollpane:AdaptHeightToContents( )
			UIe.scrollpane:ibData( "sy", UIe.scrollpane:ibData( "sy" ) + 110 )
			UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )

			ibCreateImage( 373, 302, 400, 268, "images/gradient.png", UIe.bg )
		end

		-- Забрать доступные плюшки
		do
			ibCreateButton( 521, 497, 130, 44, UIe.bg, "images/btn_take", true )
				:ibData( "disabled", not can_take )
				:ibData( "alpha", can_take and 255 or 100 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					destroyElement( UIe.black_bg )
					showCursor( false )
					triggerServerEvent( "PlayerWantTakeAnnuityPaymentsPack", resourceRoot )
				end )
		end
	else
		-- Таймер
		do
			local cost_area = ibCreateArea( 0, 103, 0, 0, UIe.bg ):center_x( -214 )
			local inner_area = ibCreateArea( 0, 0, 0, 0, cost_area )
			local icon_timer_bg = ibCreateArea( 0, 0, 22, 24, inner_area ):center_y( )
			local icon_timer = ibCreateImage( 0, 0, 22, 24, "images/icon_timer.png", icon_timer_bg )
			local lbl_name = ibCreateLabel( icon_timer:ibGetAfterX( 10 ), 0, 0, 0, "Акция действует еще:", inner_area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
			local lbl_time = ibCreateLabel( lbl_name:ibGetAfterX( 5 ), 0, 0, 0, getHumanTimeString( localPlayer:getData( "annuity_payment_timeout" ), true ), inner_area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )

			inner_area:ibData( "sx", lbl_time:ibGetAfterX( ) ):center( )


			local func_interpolate = function( self )
				self:ibInterpolate( function( self )
					if not isElement( self.element ) then return end
					local easing_value = 1 - 0.2 * self.easing_value
					self.element:ibBatchData( { sx = 22 * easing_value; sy = 24 * easing_value } ):center( )
				end, 250, "SineCurve" )
			end

			icon_timer:ibTimer( func_interpolate, 1000, 0 )
				:ibTimer( func_interpolate, 50, 1 )
		end

		-- Купить
		do
			ibCreateLabel( 29, 522, 0, 0, "Стоимость:", UIe.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.light_18 )
			local lbl_cost = ibCreateLabel( 129, 521, 0, 0, "490", UIe.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_24 )
			ibCreateImage( lbl_cost:ibGetAfterX( 8 ), 506, 28, 28, ":nrp_shared/img/hard_money_icon.png", UIe.bg )

			ibCreateButton( 233, 497, 110, 44, UIe.bg, "images/btn_buy", true )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )

					if not localPlayer:HasDonate( 490 ) then
						localPlayer:ShowError( "Недостаточно средств" )
						return
					end

					destroyElement( UIe.black_bg )
					showCursor( false )

					triggerServerEvent( "PlayerWantBuyAnnuityPaymentsPack", resourceRoot )
				end )
		end

		-- Содержимое пакета
		do
			ibCreateLabel( 585, 155, 0, 0, "Содержимое пакета:", UIe.bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_16 )

			UIe.scrollpane, UIe.scrollbar	= ibCreateScrollpane( 431, 183, 369, 387, UIe.bg, { scroll_px = -20, bg_color = 0 } )
			UIe.scrollbar:ibBatchData( { absolute = true, sensivity = 50 } ):ibSetStyle( "slim_small_nobg" )

			for day, data in pairs( CONST_DAYS ) do
				local bg = ibCreateImage( 110 * ( ( day - 1 ) % 3 ), 127 * math.floor( ( day - 1 ) / 3 ), 92, 92, "images/bg_day.png", UIe.scrollpane )

				ibCreateImage( 0, 0, 29, 29, "images/icon_".. data[ 2 ] ..".png", bg ):center( -23, -23 )
				ibCreateLabel( 0, 0, 0, 0, "+", bg, COLOR_WHITE, _, _, "center", "center", ibFonts.light_12 ):center( 0, -22 )
				ibCreateImage( 0, 0, 29, 29, "images/icon_".. data[ 3 ] ..".png", bg ):center( 23, -23 )

				ibCreateImage( 0, 40, 28, 28, ":nrp_shared/img/money_icon.png", bg ):center_x( )
				ibCreateLabel( 0, 76, 0, 0, format_price( data[ 1 ] ), bg, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_14 ):center_x( )

				ibCreateLabel( 0, 0, 0, 0, day .." день", bg, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_14 ):center( 0, 60 )
			end

			UIe.scrollpane:AdaptHeightToContents( )
			UIe.scrollpane:ibData( "sy", UIe.scrollpane:ibData( "sy" ) + 110 )
			UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )

			ibCreateImage( 373, 302, 400, 268, "images/gradient.png", UIe.bg )
		end
	end
end
addEvent( "ShowAnnuityPaymentsUI", true )
addEventHandler( "ShowAnnuityPaymentsUI", resourceRoot, ShowUI )