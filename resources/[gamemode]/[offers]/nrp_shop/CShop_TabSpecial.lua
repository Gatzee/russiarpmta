local refreshFunction
SPECIAL_SC_DATA = {}

local sx, sy = 360, 280

TABS_CONF.special = {
	items = { },

	fn_create = function( self, parent )

		refreshFunction = function( )
			DestroyTableElements( getElementChildren( parent ) )

			local scrollpane, scrollbar = ibCreateScrollpane( 30, 45, 740, 463, parent, { scroll_px = 10 } )
			scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 100 )
			SPECIAL_SC_DATA.rt = scrollpane
			SPECIAL_SC_DATA.sc = scrollbar	

			local special_offers = { }
			local is_any_offer_limited = false
			for k,v in pairs( OFFERS_LIST ) do
				if IsSpecialOfferActive( v ) then
					is_any_offer_limited = is_any_offer_limited or ( not not v.limit_count )
					v._priority = v.limit_count and 999 or SPECIAL_OFFERS_CLASSES[ v.class ].priority or 0
					table.insert( special_offers, v )
				end
			end

			table.sort( special_offers, function( a, b ) return a._priority > b._priority end )

			local px, py = 0, 20
			if (localPlayer:getData( "offer_discount_gift_time_left" ) or 0) > getRealTimestamp() then
				local coupon_discount_list = localPlayer:GetCouponDiscountListByItemType( nil, "special_services" )
				local count_special_coupons = #coupon_discount_list
				if count_special_coupons > 0 then
					CreateSaleTab( py, scrollpane, {
						info_text = "Всего доступно купонов: " .. count_special_coupons .. " шт.",
					} )
					py = py + 70
				end
			end

			local last_sy = 0

			if is_any_offer_limited then
				ibCreateImage( 0, py, 740, 50, "img/cases/bg_limited_sale.png", scrollpane )
				py = py + 70
			end

			for k, v in pairs( special_offers ) do
				local path = "img/special_offers/bg_section" .. ( v.limit_count and "_limited" or "" )
				local bg = ibCreateImage( 0, 0, sx, sy, path .. ".png" )
				local hovered = ibCreateImage( 0, 0, sx, sy, path .. "_hovered.png", bg )
					:ibData( "alpha", 0 )
					:ibOnHover( function() source:ibAlphaTo( 255, 500 ) end )
					:ibOnLeave( function() source:ibAlphaTo( 0, 500 ) end )
	
				local item_img, btn = SPECIAL_OFFERS_CLASSES[ v.class ]:fn_create( v, bg, hovered )
				
				if v.limit_count then
					local bg_progress, sold_count 

					local UpdateCount = function( v, init )
						if not init and ( not isElement( bg_progress ) or sold_count == v.sold_count ) then return end
						if bg_progress then bg_progress:destroy( ) end

						sold_count = ( v.sold_count or 0 )
						local left_count = v.limit_count - sold_count
						local progress = math.max( 0, math.min( 1, left_count / v.limit_count ) )
						bg_progress = ibCreateImage( 75, 51, 210, 10, _, bg, ibApplyAlpha( COLOR_BLACK, 35 ) ):ibData( "disabled", true )
						ibCreateImage( 0, 0, math.ceil( 210 * progress ), 10, _, bg_progress, 0xFFff9759 ):ibData( "disabled", true )

						ibCreateLabel( 0, -18, 0, 0, "Осталось всего:", bg_progress, _, _, _, _, _, ibFonts.regular_12 ):ibData( "alpha", 255 * 0.6 )
						-- progress = math[ progress < 0.01 and "ceil" or "floor" ]( progress * 100 )
						ibCreateLabel( 0, -18, bg_progress:width( ), 0, left_count, bg_progress, _, _, _, "right", _, ibFonts.regular_12 )
					
						if v.sold_count and left_count <= 0 then
							btn:ibData( "disabled", true ):ibData( "alpha", 0.5 * 255 )
							item_img:ibData( "alpha", 0.3 * 255 )
							ibCreateImage( 0, 0, 360, 280, "img/cases/bg_select_case_limited_sold_top_layer.png", bg )
							-- :ibData( "disabled", true )
						end
					end
					UpdateCount( v, true )

					TABS_CONF.special.items[ v.id ] = {
						UpdateCount = UpdateCount,
					}
				end

				if px + sx > 740 then
					px = 0
					py = py + last_sy + 20
				end

				bg:setParent( scrollpane )
				bg:ibBatchData( { px = px, py = py } )

				last_sy = sy
				px = px + sx + 20
			end

			-- scrollpane fixer
			ibCreateImage( px, py+last_sy, 100, 30, nil, scrollpane, 0x00000000 )

			scrollpane:AdaptHeightToContents( )
			scrollbar:UpdateScrollbarVisibility( scrollpane )

			return #special_offers
		end

		local last_amount = refreshFunction( )
		
		parent:ibTimer( function( )
			local now_amount = 0
			for k,v in pairs( OFFERS_LIST ) do
				if IsSpecialOfferActive( v ) then
					now_amount = now_amount + 1
				end
			end
			if now_amount ~= last_amount then
				last_amount = refreshFunction( )
			end
		end, 500, 0 )
	end,
	
	fn_open = function( self, parent, is_same )
		if not is_same then
			local children = getElementChildren( parent )
			local rt, sc = children[ 1 ], children[ 2 ]

			if rt and sc then
				sc:ibData( 'position', 0 )
				rt:AdaptHeightToContents( )
				sc:UpdateScrollbarVisibility( rt )
			end
		end
	end,
}

SPECIAL_OFFERS_CLASSES = {
	weapon = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			local ammo_value = ( WEAPONS_LIST[ params.model ] or { } ).Ammo or 1
			local value = 1

			-- label name
			if params.name then
				--ibCreateLabel( 0, 10, sx, sy/4, params.name, bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
				--:ibData("disabled", true)

				ibCreateLabel( 0, 10, sx, sy / 4, "Оружие: #FFFFFF" .. params.name, bg, 0xFFAEC3D3, _, _, "center", "top", ibFonts.regular_14 )
				:ibData( "colored", true ):ibData( "disabled", true )
			end

			if params.finish_date and not params.limit_count then
				local offset_y = 20
				if params.name then offset_y = 30 end
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			-- image
			local item_img = ibCreateContentImage( 30, 27, 300, 180, "weapon", params.model, bg ):ibData( "disabled", true )

			-- cost
			local lbl_amount, img_line = nil, nil
			if params.cost_original then
				local lbl_cost = ibCreateLabel( 20, sy - 50, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 58, 16, 16, "img/special_offers/icon_hard.png", bg )
				lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX() + 10, sy - 50, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_16 )
				img_line = ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end

			local oy = params.cost_original and 10 or 0
			local lbl_cost = ibCreateLabel( 20, sy - 35 + oy, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 45 + oy, 23, 20, "img/special_offers/icon_hard.png", bg )
			local lbl_price = ibCreateLabel( icon_hard:ibGetAfterX( ) + 10, sy - 35 + oy, 0, 0, format_price( params.cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )

			-- button
			local btn = ibCreateButton( sx-133, sy-50, 113, 34, bg, "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function(key, state)
				if key ~= "left" or state ~= "up" then
					return
				end

				ibClick( )

				SendElasticGameEvent( "f4r_f4_unique_weapon_purchase_button_click" )
				ibConfirm( {
					title = "ПОКУПКА ОРУЖИЯ",
					text = "Ты хочешь купить оружие '" .. params.name .. "' за",
					cost = params.cost * value,
					cost_is_soft = false,
					fn = function( self )
						SendElasticGameEvent( "f4r_f4_unique_weapon_confirmation_ok_click" )
						triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, params.id, params.name, params.segment, value )
						self:destroy( )
					end,
					escape_close = true,
				} )
			end )
			:ibOnHover( function ( )
				hovered:ibAlphaTo( 255, 500 )
			end )
			:ibOnLeave( function ( )
				hovered:ibAlphaTo( 0, 500 )
			end )

			-- amount
			ibCreateImage( 156, 182, 48, 30, "img/special_offers/edit_value.png", bg )
			:ibOnHover( function ( )
				hovered:ibAlphaTo( 255, 500 )
			end )
			:ibOnLeave( function ( )
				hovered:ibAlphaTo( 0, 500 )
			end )

			local lbl_value = ibCreateLabel( 180, 197, 0, 0, value, bg, nil, nil, nil, "center", "center", ibFonts.bold_18 )
			:ibOnHover( function ( )
				hovered:ibAlphaTo( 255, 500 )
			end )
			:ibOnLeave( function ( )
				hovered:ibAlphaTo( 0, 500 )
			end )

			ibCreateImage( 250, 189, 30, 16, "img/special_offers/icon_bullets.png", bg )
			local lbl_ammo = ibCreateLabel( 288, 197, 0, 0, ammo_value, bg, ibApplyAlpha( 0xffffffff, 75 ), nil, nil, nil, "center", ibFonts.bold_18 )

			local function changeValue( v )
				value = value + v

				if value <= 0 then
					value = 1
				elseif value >= 100 then
					value = 99
				end

				lbl_value:ibData( "text", value )
				lbl_price:ibData( "text", format_price( params.cost * value ) )

				if lbl_amount then
					lbl_amount:ibData( "text", format_price( params.cost_original * value ) )
					img_line:ibData( "target_px", lbl_amount:ibGetAfterX( 1 ) )
				end

				lbl_ammo:ibData( "text", ammo_value * value )
			end

			ibCreateButton( 120, 182, 30, 30, bg, "img/special_offers/btn_minus.png", "img/special_offers/btn_minus.png", "img/special_offers/btn_minus.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnHover( function ( )
				hovered:ibAlphaTo( 255, 500 )
			end )
			:ibOnLeave( function ( )
				hovered:ibAlphaTo( 0, 500 )
			end )
			:ibOnClick( function(key, state)
				if key ~= "left" or state ~= "up" then
					return
				end

				ibClick( )
				changeValue( -1 )
				lbl_value:ibData( "text", value )
			end )

			ibCreateButton( 210, 182, 30, 30, bg, "img/special_offers/btn_plus.png", "img/special_offers/btn_plus.png", "img/special_offers/btn_plus.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnHover( function ( )
				hovered:ibAlphaTo( 255, 500 )
			end )
			:ibOnLeave( function ( )
				hovered:ibAlphaTo( 0, 500 )
			end )
			:ibOnClick( function(key, state)
				if key ~= "left" or state ~= "up" then
					return
				end

				ibClick( )
				changeValue( 1 )
				lbl_value:ibData( "text", value )
			end )

			return item_img, btn
		end,
	},

	accessory = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			-- label name
			if params.name then
				ibCreateLabel( 0, 10, sx, sy/4, params.name, bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
				:ibData("disabled", true)
			end

			if params.finish_date and not params.limit_count then
				local offset_y = 20
				if params.name then offset_y = 30 end
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			-- image
			local item_img = ibCreateContentImage( 30, 67, 300, 140, "accessory", params.model, bg ):ibData( "disabled", true )

			-- cost
			if params.cost_original then
				local lbl_cost = ibCreateLabel( 20, sy - 50, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 58, 16, 16, "img/special_offers/icon_hard.png", bg )
				local lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX() + 10, sy - 50, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_16 )
				ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end
			local oy = params.cost_original and 10 or 0
			local lbl_cost = ibCreateLabel( 20, sy - 35 + oy, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 45 + oy, 23, 20, "img/special_offers/icon_hard.png", bg )
			ibCreateLabel( icon_hard:ibGetAfterX( ) + 10, sy - 35 + oy, 0, 0, format_price( params.cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )

			-- button
			local btn = ibCreateButton( sx-133, sy-50, 113, 34, bg, "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick(function(key, state)
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					SendElasticGameEvent( "f4r_f4_unique_accessory_purchase_button_click" )
					ibConfirm(
						{
							title = "ПОКУПКА АКСЕССУАРА", 
							text = "Ты хочешь купить аксессуар '"..params.name.."' за",
							cost = params.cost,
							cost_is_soft = false,
							fn = function( self )
								SendElasticGameEvent( "f4r_f4_unique_accessory_confirmation_ok_click" )
								triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, params.id, params.name, params.segment )
								self:destroy()
							end,
							escape_close = true,
						}
					)
				end)
				:ibOnHover(function()
					hovered:ibAlphaTo( 255, 500 )
				end)
				:ibOnLeave( function()
					hovered:ibAlphaTo( 0, 500 )
				end)


			return item_img, btn
		end,
	},


	vehicle = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			if params.song then
				local song
				hovered
					:ibOnHover(function()
						if not isElement( song ) then
							song = playSound( params.song, true )
							setSoundVolume( song, 0 )
						end

						hovered:ibInterpolate( function( self )
							setSoundVolume( song, self.progress * 0.3 )
						end, 500, "Linear" )
					end)
					:ibOnLeave( function()
						if isElement( song ) then
							hovered:ibInterpolate( function( self )
								setSoundVolume( song, ( 1 - self.progress ) * 0.3 )
							end, 500, "Linear" )
						end
					end)
					:ibOnDestroy( function( )
						if isElement( song ) then stopSound( song ) end
					end )
			end

			-- label name
			if params.name then
				ibCreateLabel( 0, 10, sx, sy/4, params.name, bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
				:ibData("disabled", true)
			end

			if params.finish_date and not params.limit_count then
				local offset_y = 20
				if params.name then offset_y = 30 end
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			-- image
			local item_img = ibCreateContentImage( 30, 57, 300, 160, "vehicle", params.model, bg ):ibData( "disabled", true )

			-- if params.vehicle_lights then
			-- 	local lights = ibCreateImage( 0, 0, 0, 0, "img/special_offers/vehicles/vehicle"..params.model.."_lights.png", bg ):ibData( "priority", 1 )
			-- 		:ibSetRealSize():center( unpack( params.image_offset or { 0, 0 } ) ):ibData("disabled", true)

			-- 	lights:ibOnRender( function( )
			-- 		lights:ibData( "alpha", 150 + math.abs( math.sin( getTickCount( ) / 250 ) ) * hovered:ibData( "alpha" ) / 255 * 105 )
			-- 	end )
			-- end

			-- cost
			local oy = params.cost_original and 0 or 8
			local lbl_cost = ibCreateLabel( 20, sy - 43 + oy, 0, 0, "Цена:", bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( 77, sy - 53 + oy, 23, 20, "img/special_offers/icon_hard.png", bg ):ibData( "disabled", true )
			local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_vehicle", params.cost )
			if coupon_discount_value then
				CreateDiscountCoupon( 15, 187, "special_vehicle", coupon_discount_value, bg )
			end

			local lbl_amount = ibCreateLabel( 106, sy - 44 + oy, 0, 0, format_price( cost ), bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_18 )
			if params.cost_original then 
				local icon_hard_original = ibCreateImage( 85, sy - 28, 16, 14, "img/special_offers/icon_hard.png", bg ):ibData( "alpha", 191 ):ibData( "disabled", true )
				local lbl_amount_original = ibCreateLabel( 107, sy - 22, 0, 0, format_price( params.cost_original ), bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 ):ibData( "alpha", 191 )
				ibCreateLine( icon_hard_original:ibData( "px" ) - 3, lbl_amount_original:ibGetCenterY( ), lbl_amount_original:ibGetAfterX( 3 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end

			-- button
			local btn = ibCreateButton( sx-169, sy-50, 149, 34, bg, "img/overlays/vehicle_details/btn_details.png", "img/overlays/vehicle_details/btn_details_h.png", "img/overlays/vehicle_details/btn_details.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick(function(key, state)
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					SendElasticGameEvent( "f4r_f4_unique_auto_details_click" )
					onOverlayNotificationRequest_handler( OVERLAY_VEHICLE_DETAILS, params, true )
				end)
				:ibOnHover(function()
					hovered:ibAlphaTo( 255, 500 )
				end)
				:ibOnLeave( function()
					hovered:ibAlphaTo( 0, 500 )
				end)


			return item_img, btn
		end,
	},
	
	skin = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			if params.name then
				ibCreateLabel( 0, 10, sx, 0, params.name, bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
					:ibData("disabled", true)
			end

			if params.finish_date and not params.limit_count then
				local offset_y = 20
				if params.name then offset_y = 30 end
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			-- image
			local item_img = ibCreateContentImage( 30, 0, 300, 280, "skin", params.model, bg ):ibData( "disabled", true )

			-- cost
			if params.cost_original then
				local lbl_cost = ibCreateLabel( 20, sy - 50, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 58, 16, 16, "img/special_offers/icon_hard.png", bg )
				local lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX() + 10, sy - 50, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_16 )
				ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end
			local oy = params.cost_original and 10 or 0
			local lbl_cost = ibCreateLabel( 20, sy - 35 + oy, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 45 + oy, 23, 20, "img/special_offers/icon_hard.png", bg )

			local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_skin", params.cost )
			if coupon_discount_value then
				CreateDiscountCoupon( 15, 187, "special_skin", coupon_discount_value, bg )
			end

			ibCreateLabel( icon_hard:ibGetAfterX( ) + 10, sy - 35 + oy, 0, 0, format_price( cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )

			-- button
			local btn = ibCreateButton( sx-133, sy-50, 113, 34, bg, "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick(function(key, state)
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					local confirm_func = function( )
						ibClick( )
						ibConfirm(
							{
								title = "ПОКУПКА СКИНА",
								text = "Ты хочешь купить "..SKINS_NAMES[ params.model ].." за",
								cost = params.cost,
								cost_is_soft = false,
								fn = function( self )
									triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, params.id, params.name, params.segment )
									self:destroy()
								end,
								escape_close = true,
							}
						)
					end

					if SKINS_GENDERS[ params.model ] ~= localPlayer:GetGender( ) then
						ibInfo(
							{
								text = "Данный скин отличается от вашего пола, \nдля его использования необходимо сменить пол персонажа",
								fn = confirm_func
							}
						)
					else
						confirm_func( )
					end

				end)
				:ibOnHover(function()
					hovered:ibAlphaTo( 255, 500 )
				end)
				:ibOnLeave( function()
					hovered:ibAlphaTo( 0, 500 )
				end)

			return item_img, btn
		end,
	},

	numberplate = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			local region = tonumber( params.region ) and string.format("%02d", params.region) or string.lower( params.region )
			local path = "img/special_offers/number_plate_" .. region .. ".png"

			if not fileExists( path ) then
				path = "img/special_offers/number_plate.png"
			end

			local plate_bg = ibCreateImage( sx/2-85, 60, 170, 75, path, bg )
			local i = 0
			while dxGetTextWidth( params.name, 1, ibFonts[ "bold_" .. ( 23 - i ) ] ) > 100 do
				i = i + 1
			end
			ibCreateLabel( 0, 28, 120, 48, params.name, plate_bg, 0xff3a4c5f, _, _, "center", "center", ibFonts[ "bold_" .. ( 23 - i ) ] )
			ibCreateLabel( 120, 28, 50, 30, region:gsub( "%a", "" ), plate_bg, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_18  )

			if params.finish_date and not params.limit_count then
				local offset_y = 30
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			if params.cost_original then
				-- cost original
				local lbl_cost = ibCreateLabel( 90, 165, 0, 0, "Старая цена:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:ibGetAfterX()+10, 158, 16, 16, "img/special_offers/icon_hard.png", bg )

				local lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX()+10, 165, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_16 )

				ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )

				-- cost
				local lbl_cost = ibCreateLabel( 75, 191, 0, 0, "Уникальная цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:ibGetAfterX()+10, 183, 23, 20, "img/special_offers/icon_hard.png", bg )

				local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_numberplate", params.cost )
				if coupon_discount_value then
					CreateDiscountCoupon( 15, 225, "special_numberplate", coupon_discount_value, bg )
				end

				ibCreateLabel( icon_hard:ibGetAfterX()+10, 191, 0, 0, format_price( cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )
			else
				-- cost
				local lbl_cost = ibCreateLabel( 75, 191, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:ibGetAfterX()+10, 183, 23, 20, "img/special_offers/icon_hard.png", bg )

				local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_numberplate", params.cost )
				if coupon_discount_value then
					CreateDiscountCoupon( 15, 225, "special_numberplate", coupon_discount_value, bg )
				end
				ibCreateLabel( icon_hard:ibGetAfterX()+10, 191, 0, 0, format_price( cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )
			end

			if params.name then
				ibCreateLabel( 0, 10, sx, sy/4, "Уникальный номер \""..params.name.."\"", bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
				:ibData("disabled", true)
			end


			if params.start_date then
				if getRealTimestamp() - params.start_date <= 3*24*60*60 then
					ibCreateImage( sx-23, 0, 23, 23, "img/icon_indicator_new.png", bg )
				end
			end

			-- button
			local btn = ibCreateButton( sx/2-60, sy-60, 120, 44, bg, "img/btn_buy.png", "img/btn_buy.png", "img/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick(function(key, state)
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					SendElasticGameEvent( "f4r_f4_unique_auto_accessory_purchase_button_click" )
					onOverlayNotificationRequest_handler( OVERLAY_APPLY_NUMBERPLATE , params )
				end)
				:ibOnHover(function()
					hovered:ibAlphaTo( 255, 500 )
				end)
				:ibOnLeave( function()
					hovered:ibAlphaTo( 0, 500 )
				end)


			return plate_bg, btn
		end,
	},

	neon = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			if params.name then
				ibCreateLabel( 0, 10, sx, sy / 4, "Неон: #FFFFFF"..params.name, bg, 0xFFAEC3D3, _, _, "center", "top", ibFonts.regular_14 )
				:ibData( "colored", true ):ibData("disabled", true)
			end

			if params.finish_date and not params.limit_count then
				local offset_y = 20
				if params.name then offset_y = 30 end

				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end

				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			-- image
			local item_img = ibCreateContentImage( 30, 62 - 5, 300, 160, "neon", params.model, bg ):ibData( "disabled", true )

			-- cost
			if params.cost_original then
				local lbl_cost = ibCreateLabel( 20, sy - 50, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 58, 16, 16, "img/special_offers/icon_hard.png", bg )
				local lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX() + 10, sy - 50, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_16 )
				ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end
			local oy = params.cost_original and 10 or 0
			local lbl_cost = ibCreateLabel( 20, sy - 35 + oy, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 45 + oy, 23, 20, "img/special_offers/icon_hard.png", bg )

			local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_neon", params.cost )
			if coupon_discount_value then
				CreateDiscountCoupon( 13, 180, "special_neon", coupon_discount_value, bg )
			end
			ibCreateLabel( icon_hard:ibGetAfterX( ) + 10, sy - 35 + oy, 0, 0, format_price( cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )

			-- button
			local btn = ibCreateButton( sx - 133, sy - 50, 113, 34, bg, "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				ibConfirm( {
					title = "ПОКУПКА НЕОНА",
					text = "Ты действительно хочешь купить неон '".. params.name .."' за",
					cost = params.cost,
					cost_is_soft = false,
					fn = function( self )
						triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, params.id, params.name, params.segment )
						self:destroy( )
					end,
					escape_close = true,
				} )
			end)
			:ibOnHover( function( )
				hovered:ibAlphaTo( 255, 500 )
			end)
			:ibOnLeave( function( )
				hovered:ibAlphaTo( 0, 500 )
			end)

			return item_img, btn
		end,
	},

	vinyl = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			if params.name then
				ibCreateLabel( 0, 10, sx, sy / 4, "Винил: #FFFFFF"..params.name, bg, 0xFFAEC3D3, _, _, "center", "top", ibFonts.regular_14 ):ibData( "colored", true )
				:ibData("disabled", true)
			end

			if params.finish_date and not params.limit_count then
				local offset_y = 20
				if params.name then offset_y = 30 end
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			-- image
			local item_img = ibCreateContentImage( 30, 62 - 5, 300, 160, "vinyl", params.model, bg ):ibData( "disabled", true )

			-- cost
			if params.cost_original then
				local lbl_cost = ibCreateLabel( 20, sy - 50, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 58, 16, 16, "img/special_offers/icon_hard.png", bg )
				local lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX() + 10, sy - 50, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_16 )
				ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end
			local oy = params.cost_original and 10 or 0
			local lbl_cost = ibCreateLabel( 20, sy - 35 + oy, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 45 + oy, 23, 20, "img/special_offers/icon_hard.png", bg )
			
			local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_vinyl", params.cost )
			if coupon_discount_value then
				CreateDiscountCoupon( 15, 180, "special_vinyl", coupon_discount_value, bg )
			end
			ibCreateLabel( icon_hard:ibGetAfterX( ) + 10, sy - 35 + oy, 0, 0, format_price( cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )

			-- button
			local btn = ibCreateButton( sx - 133, sy - 50, 113, 34, bg, "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					SendElasticGameEvent( "f4r_f4_unique_auto_accessory_purchase_button_click" )
					onOverlayNotificationRequest_handler( OVERLAY_APPLY_VINYL , params )
				end)
				:ibOnHover( function( )
					hovered:ibAlphaTo( 255, 500 )
				end)
				:ibOnLeave( function( )
					hovered:ibAlphaTo( 0, 500 )
				end)


			return item_img, btn
		end,
	},

	pack = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			-- image
			local item_img = ibCreateContentImage( 0, 0, sx, sy, "pack", params.model, bg ):ibData( "disabled", true )

			-- name
			if params.name then
				local area = ibCreateArea( 0, 10, 0, 0, bg )
				local lbl_name = ibCreateLabel( 0, 0, 0, 0, "Набор: #FFFFFF"..params.name, area, 0xFFAEC3D3, _, _, _, _, ibFonts.regular_14 ):ibData( "colored", true )
				local bg_discount = ibCreateImage( lbl_name:ibGetAfterX( 8 ), -1, 116, 24, "img/special_offers/bg_discount.png", area ):ibData( "disabled", true )
				local discount = "ВЫГОДА " .. math.ceil( ( 1 - params.cost / params.cost_original ) * 100 ) .. "%"
				ibCreateLabel( 0, 0, 116, 24, discount, bg_discount, 0xFFFFFFFF, _, _, "center", "center", ibFonts.extrabold_12 )
				area:ibData( "sx", bg_discount:ibGetAfterX( ) ):center_x( )
			end

			-- timer
			if params.finish_date and not params.limit_count then
				CreateHumanTimer( 20, 32, bg, "Предложение действует еще:", params.finish_date, true )
			end

			-- cost
			local oy = params.cost_original and 0 or 8
			local lbl_cost = ibCreateLabel( 20, sy - 43 + oy, 0, 0, "Цена:", bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( 77, sy - 53 + oy, 23, 20, "img/special_offers/icon_hard.png", bg ):ibData( "disabled", true )
			
			local cost, coupon_discount_value = localPlayer:GetCostWithCouponDiscount( "special_pack", params.cost )
			if coupon_discount_value then
				CreateDiscountCoupon( 15, 190, "special_pack", coupon_discount_value, bg )
			end

			local lbl_amount = ibCreateLabel( 106, sy - 44 + oy, 0, 0, format_price( cost ), bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_18 )
			if params.cost_original then 
				local icon_hard_original = ibCreateImage( 85, sy - 28, 16, 14, "img/special_offers/icon_hard.png", bg ):ibData( "alpha", 191 ):ibData( "disabled", true )
				local lbl_amount_original = ibCreateLabel( 107, sy - 22, 0, 0, format_price( params.cost_original ), bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 ):ibData( "alpha", 191 )
				ibCreateLine( icon_hard_original:ibData( "px" ) - 3, lbl_amount_original:ibGetCenterY( ), lbl_amount_original:ibGetAfterX( 3 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end

			-- btn_details
			local btn = ibCreateButton( sx - 169, sy - 50, 149, 34, bg, "img/overlays/vehicle_details/btn_details.png", "img/overlays/vehicle_details/btn_details_h.png", "img/overlays/vehicle_details/btn_details.png" )
				:ibOnHover( function( ) hovered:ibAlphaTo( 255, 500 ) end )
				:ibOnLeave( function( ) hovered:ibAlphaTo( 0, 500 ) end )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					SendElasticGameEvent( "f4r_f4_unique_pack_details_click" )
					onOverlayNotificationRequest_handler( OVERLAY_PACK_PURCHASE, params, true )
				end )


			return item_img, btn
		end,
	},

	pack_limit = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function( self, params, bg, hovered )
			if params.name then
				params.name = utf8.gsub( params.name, " ?%(%d+%)$", "" )
				ibCreateLabel( 0, 10, sx, sy / 4, params.name, bg, _, _, _, "center", "top", ibFonts.regular_14 ):ibData("disabled", true)
			end

			if params.finish_date and not params.limit_count then
				local offset_y = 20
				if params.name then offset_y = 30 end
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			-- image
			local item_img = ibCreateContentImage( 72, 8, 212, 212, "other", "box_" .. params.model, bg ):ibData( "disabled", true )
			local count_area = ibCreateArea( 0, 188, 0, 0, item_img )
			local lbl1 = ibCreateLabel( 0, 0, 0, 0, "Количество: ", count_area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, _, _, ibFonts.regular_14 )
			local lbl2 = ibCreateLabel( lbl1:ibGetAfterX( ), 0, 0, 0, params.params.count, count_area, _, _, _, _, _, ibFonts.bold_14 )
			local lbl3 = ibCreateLabel( lbl2:ibGetAfterX( ), 0, 0, 0, " шт.", count_area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, _, _, ibFonts.regular_14 )
			count_area:ibData( "sx", lbl3:ibGetAfterX( ) ):center_x( )

			-- cost
			if params.cost_original then
				local lbl_cost = ibCreateLabel( 20, sy - 50, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 58, 16, 16, "img/special_offers/icon_hard.png", bg )
				local lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX() + 10, sy - 50, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_16 )
				ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end
			local oy = params.cost_original and 10 or 0
			local lbl_cost = ibCreateLabel( 20, sy - 35 + oy, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 45 + oy, 23, 20, "img/special_offers/icon_hard.png", bg )
			ibCreateLabel( icon_hard:ibGetAfterX( ) + 10, sy - 35 + oy, 0, 0, format_price( params.cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )
			
			-- button
			local btn = ibCreateButton( sx - 133, sy - 50, 113, 34, bg, "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", "img/special_offers/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					-- SendElasticGameEvent( "f4r_f4_unique_auto_accessory_purchase_button_click" )
					ibConfirm( {
						title = "ПОКУПКА НЕОНА",
						text = "Ты действительно хочешь купить '".. params.name .."' за",
						cost = params.cost,
						cost_is_soft = false,
						fn = function( self )
							triggerServerEvent( "onPlayerPurchaseSpecialOfferRequest", resourceRoot, params.id, params.name, params.segment )
							self:destroy( )
						end,
						escape_close = true,
					} )
				end)
				:ibOnHover( function( )
					hovered:ibAlphaTo( 255, 500 )
				end)
				:ibOnLeave( function( )
					hovered:ibAlphaTo( 0, 500 )
				end)


			return item_img, btn
		end,
	},
}

local offer_classes_list_sorted_by_priority = {
	"limited_offers",
	"pack",
	"vehicle",
	"skin",
	"accessory",
	"vinyl",
	"neon",
	"numberplate",
	"weapon",
}

for i, class in pairs( offer_classes_list_sorted_by_priority ) do
	if SPECIAL_OFFERS_CLASSES[ class ] then
		SPECIAL_OFFERS_CLASSES[ class ].priority = #offer_classes_list_sorted_by_priority - i + 1
	end
end