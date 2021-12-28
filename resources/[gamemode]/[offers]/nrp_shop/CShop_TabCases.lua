-- Лень перебирать, и так норм.
local screen_size_x, screen_size_y = guiGetScreenSize( )

local CONST_RARE_COLORS = {
	[1] = 0xffaff7ff;
	[2] = 0xffa975ff;
	[3] = 0xfffd56ff;
	[4] = 0xffff6464;
	[5] = 0xffffb346;
}

local CACHE_CASES = { }
local UI_elements = { }

local SEND_DATA_TIMEOUT = 0
local SCROLL_SLIDER_ACTIVE = true

WINDOW_TYPE = nil
WINDOW_TYPE_CASE_INFO = 1

local refreshFunction, updateFunction

local NO_COST_CASES = {
	[ "bp_season_1" ] = true,
	[ "bp_season_2" ] = true,
	[ "bp_season_3" ] = true,
	[ "bp_season_4" ] = true,
	[ "bp_season_5" ] = true,
}

local GIFT_CASES = {
	[ "gold_a" ] = true,
	[ "gold_b" ] = true,
	[ "titan" ] = true,
	[ "platinum" ] = true,
}

local function IsCaseCostHidden( case )
	return NO_COST_CASES[ case.id ] or ( case.position == 0 and not GIFT_CASES[ case.id ] )
end

function GetAdditionalCasesIDs( )
	local additional_ids = { }
	for case_id, count in pairs( localPlayer:GetCases( ) ) do
		if count > 0 then
			table.insert( additional_ids, case_id )
		end
	end
	return additional_ids
end

function UpdateCasesInfo( cases_info, err )
	if not IsDonateOpen( ) then return end

	-- Если ошибка чтения, но раньше уже читались кейсы
	if not cases_info and CACHE_CASES then
		refreshFunction( )
		return
	end

	local additional_discount_cases = { }
	--[[
	local discounts_data = HasDiscounts( )
	if discounts_data and discounts_data.id == "7cases_discount" and discounts_data.cases_data then
		for k,v in pairs( discounts_data.cases_data ) do
			additional_discount_cases[ k ] = true
		end
	end
	]]
	local ts = getRealTimestamp( )

	local has_some_case = false
	local last_temp_end = 0
	local cases_menu = { }
	local available_ended_cases = { }
	for case_id, case_data in pairs( cases_info ) do
		case_data.id = case_id
		case_data.count = case_data.count or case_data.temp_start_count

		if not case_data.count and ( case_data.temp_end or 0 ) > ts and case_data.temp_end - ts <= 2 * 24 * 60 * 60 then
			case_data.count = 1200
		end

		if case_data.versus and ( case_data.count or 0 ) <= 0 then
			case_data.purchase_disabled = true
			cases_info[ case_data.versus ].purchase_disabled = true
		end

		local has_case = localPlayer:HasCase( nil, case_id )
		has_some_case = has_some_case or has_case

		if case_data.temp_end then
			if ( case_data.temp_start or 0 ) < ts and case_data.temp_end > ts or ( has_case and case_data.temp_start == 946674000 ) then
				table.insert( cases_menu, case_data )
				last_temp_end = math.max( last_temp_end, case_data.temp_end )
			elseif has_case or additional_discount_cases[ case_id ] then
				table.insert( available_ended_cases, case_data )
				if case_data.versus then
					case_data.versus = false
				end
			end
		else
			if not case_data.count or case_data.count > 0 or has_case or case_data.versus then
				if not case_data.temp_start or case_data.temp_start < ts then
					table.insert( cases_menu, case_data )
				elseif has_case or additional_discount_cases[ case_id ] then
					table.insert( available_ended_cases, case_data )
					if case_data.versus then
						case_data.versus = false
					end
				end
			end
		end
	end
	table.sort( cases_menu, function( a, b ) return ( a.position or math.huge ) < ( b.position or math.huge ) end )
	for i, case_data in ipairs( available_ended_cases ) do
		table.insert( cases_menu, case_data )
	end

	CACHE_CASES = cases_menu

	if has_some_case or last_temp_end > 0 then
		SetNavbarTabNew( "cases", not has_some_case and last_temp_end or false )
	end

	refreshFunction( )
end

TABS_CONF.cases = {
	fn_create = function( self, parent )
		DestroyTableElements( getElementChildren( parent ) )
		ibLoading( { parent = parent } )

		refreshFunction = function( )
			-- Очищаем текущее окно
			DestroyTableElements( getElementChildren( parent ) )
			
			local player_cases = localPlayer:GetCases()
			local cases_list, last_item = CACHE_CASES, CONF.last_item

			local rt, sc = ibCreateScrollpane( 30, 45, 740, 463, parent, { scroll_px = 10 } )
			sc:ibSetStyle( "slim_small_nobg" )
			sc:ibData( 'position', 0 )

			local area_cases_bg = ibCreateArea( 0, 20, 740, 1, rt )

			local dy = 20

			local discounts_data = HasDiscounts( )
			if discounts_data and discounts_data.text then
				local finish_time = GetDiscountFinishTime( )

				local img_path = "img/cases/bg_sale_" .. discounts_data.id .. ".png"
				if not fileExists( img_path ) then
					img_path = "img/cases/bg_sale.png"
				end
				local bg = ibCreateImage( 0, dy, 740, 50, img_path, rt )
				area_cases_bg:ibData( "py", area_cases_bg:ibData("py") + 70 )

				local lbl_desc = ibCreateLabel( 70, 25, 0, 0, discounts_data.text, bg, _, _, _, "left", "center", ibFonts.bold_16 )

				if finish_time and finish_time > getRealTimestamp( ) then
					ibCreateLabel( lbl_desc:ibGetAfterX( 10 ), 25, 0, 0, "(Закончится через: " .. getHumanTimeString( finish_time ) .. ")", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				end

				ibCreateButton( 704, 17, 16, 16, bg,
								":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
								0xFFDDDDDD, 0xFFEEEEEE, 0xFFFFFFFF )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )
					bg:ibAlphaTo( 0, 200 ):ibMoveTo( _, 8, 200 ):ibTimer( function( self ) self:destroy( ) end, 200, 1 )
					area_cases_bg:ibMoveTo( _, area_cases_bg:ibData("py") - 70, 200 )
				end )
			elseif discounts_data and discounts_data.id == "7cases_discount" then
	            local bg = ibCreateButton( 0, dy, 740, 50, rt,
	            "img/cases/bg_sale_7cases.png", "img/cases/bg_sale_7cases_h.png", "img/cases/bg_sale_7cases_h.png",
	            COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
	            :ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )
					ShowDonateUI( false )

					triggerEvent( "ShowUI_7CasesDiscount", localPlayer, true )
				end )

	            local btn_close = ibCreateButton( 740-36, 17, 16, 16, bg, 
	            "img/cases/btn_close_sale_i.png", "img/cases/btn_close_sale_h.png", "img/cases/btn_close_sale_h.png",
	            COLOR_WHITE, COLOR_WHITE, COLOR_WHITE)
	            :ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )
					bg:ibAlphaTo( 0, 200 ):ibMoveTo( _, 8, 200 ):ibTimer( function( self ) self:destroy( ) end, 200, 1 )
					area_cases_bg:ibMoveTo( _, area_cases_bg:ibData("py") - 70, 200 )
				end )

	            area_cases_bg:ibData( "py", area_cases_bg:ibData("py") + 70 )

	            dy = dy + 70
	        elseif discounts_data and discounts_data.id == "wholesome_case_discount" then
	        	local finish_time = GetDiscountFinishTime( )

				local img_path = "img/cases/bg_sale_" .. discounts_data.id .. ".png"
				if not fileExists( img_path ) then
					img_path = "img/cases/bg_sale.png"
				end
				local bg = ibCreateImage( 0, dy, 740, 50, img_path, rt )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick()
					ShowDonateUI( false )
					triggerEvent( "ShowUI_WholesomeCaseDiscount", localPlayer, true )
				end )
				area_cases_bg:ibData( "py", area_cases_bg:ibData("py") + 70 )

				local lbl_desc = ibCreateLabel( 70, 25, 0, 0, "Спешите купить! Скидка на кейсы до 35%!", bg, _, _, _, "left", "center", ibFonts.bold_16 )

				if finish_time and finish_time > getRealTimestamp( ) then
					ibCreateLabel( lbl_desc:ibGetAfterX( 10 ), 25, 0, 0, "(Закончится через: " .. getHumanTimeString( finish_time ) .. ")", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				end

				ibCreateButton( 704, 17, 16, 16, bg,
								":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
								0xFFDDDDDD, 0xFFEEEEEE, 0xFFFFFFFF )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )
					bg:ibAlphaTo( 0, 200 ):ibMoveTo( _, 8, 200 ):ibTimer( function( self ) self:destroy( ) end, 200, 1 )
					area_cases_bg:ibMoveTo( _, area_cases_bg:ibData("py") - 70, 200 )
				end )
			end

			local npx, npy = 0, 20
			if (localPlayer:getData( "offer_discount_gift_time_left" ) or 0) > getRealTimestamp() then
				local coupon_discount_list = localPlayer:GetCouponDiscountListByItemType( "special_case" )
				local count_special_coupons = #coupon_discount_list
				if count_special_coupons > 0 then
					CreateSaleTab( npy, area_cases_bg, {
						discount_text = (count_special_coupons == 1 and "Скидочный купон на кейсы: " or "Скидочные купоны на кейсы: ") .. coupon_discount_list[ 1 ].value .. "%",
						count_special_coupons = count_special_coupons,
					} )
					npy = npy + 70
				end
			end

			local discount_data = HasDiscounts( )

			for i, v in pairs( cases_list ) do
				if i > 1 and i % 2 == 1 then
					npx = 0
					npy = npy + 280 + 20
				elseif i > 1 then
					npx = npx + 360 + 20
				end

				local is_7cases_case = false
				if discount_data and discount_data.id == "7cases_discount" then
					for key,val in pairs( discount_data.array ) do
						if val.case_id == v.id then
				     		is_7cases_case = key
				     		break
						end
					end
				end

				local current_date = getRealTimestamp( )
				local time_left = v.temp_end and v.temp_end - current_date
				local is_case_active = not time_left or time_left > 0
				local is_case_expiring = time_left and time_left <= 2 * 24 * 60 * 60

				if v.versus and i % 2 == 1 then
					ibCreateImage( 0, npy - 10, 0, 0, "img/cases/header_case_battle.png", area_cases_bg )
						:ibSetRealSize( )
						:center_x( )
					npy = npy + 30
					ibCreateImage( 0, npy + 72, 0, 0, "img/cases/vs.png", area_cases_bg )
						:ibData( "priority", 1 )
						:ibData( "disabled", true )
						:ibSetRealSize( )
						:center_x( )
				elseif not v.versus and cases_list[ i - 1 ] and cases_list[ i - 1 ].versus then
					ibCreateImage( 0, npy - 15, 0, 0, "img/cases/header_case_shop.png", area_cases_bg )
						:ibSetRealSize( )
						:center_x( )
					npy = npy + 30
				end

				if v.temp_start_count and is_case_active and not v.versus and ( not cases_list[ i - 1 ] or cases_list[ i - 1 ].versus ) then
					ibCreateImage( 0, npy, 740, 50, "img/cases/bg_limited_sale.png", area_cases_bg )
					npy = npy + 70
				end

				local is_case_winner = ( v.versus and ( v.count or 0 ) <= 0 )
				
				local area = ibCreateArea( npx, npy, 360, 280, area_cases_bg )
				local bg_url = "img/cases/bg_select_case"
				if is_case_active then
					if v.versus then
						bg_url = "img/cases/bg_select_case_battle" .. ( is_case_winner and "_winner" or "" )
					elseif v.temp_start_count then
						bg_url = "img/cases/bg_select_case_limited"
					elseif discounts_data and discounts_data.id == "cases_premium_discount" and discounts_data.array[ v.id ] then
						bg_url = "img/cases/bg_select_case_premium_discount"
					end
				end
				local bg_px = v.versus and i % 2 == 0 and -44 or 0
				local bg = ibCreateImage( bg_px, 0, 0, 0, bg_url .. ".png", area )
					:ibData( "disabled", true )
					:ibSetRealSize( )
				local bg_hover = ibCreateImage( bg_px, 0, 0, 0, bg_url .. "_hover.png", area )
					:ibData( "disabled", true )
					:ibSetRealSize( )
					:ibData( "alpha", 0 )

				if GIFT_CASES[ v.id ] then
					local bg_sx, bg_sy = bg:ibData( "sx" ), bg:ibData( "sy" )
					local function animate_gift_case( )
						bg:ibInterpolate( function( self )
							if not isElement( bg ) then return end
							self.easing_value = 1 - 0.05 * self.easing_value
							local animated_values = { 
								px = ( bg_px - bg_sx * ( self.easing_value - 1 ) * 0.5 ), 
								py = ( 0 - bg_sy * ( self.easing_value - 1 ) * 0.5 ), 
								sx = ( bg_sx * self.easing_value ), 
								sy = ( bg_sy * self.easing_value ), 
							}
							bg:ibBatchData( animated_values )
							bg_hover:ibBatchData( animated_values )
						end, 800, "SineCurve" )
						
						bg_hover:ibAlphaTo( 255, 900, "SineCurve" )
					end
					animate_gift_case( )
					bg:ibTimer( animate_gift_case, 1100, 0 )
				end

				if v.versus and i % 2 == 0 then
					bg:ibData( "rotation", 180 )
					bg_hover:ibData( "rotation", 180 )
				end
					
				area:ibOnHover( function( )
						bg_hover:ibAlphaTo( 255, 200 )
						bg:ibAlphaTo( 0, 200 )
					end )
					:ibOnLeave( function( )
						bg_hover:ibAlphaTo( 0, 200 )
						bg:ibAlphaTo( 255, 200 )
					end )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )

						local x = guiGetScreenSize( )
						UI.bg_image:ibMoveTo( -x, _, 500, "OutBack" )

						SendElasticGameEvent( "f4r_f4_cases_case_click" )
						ShowUICase( v )

						UI_elements.bg:ibData( "px", x ):ibMoveTo( x / 2 - 800 / 2, _, 500, "OutBack" )
					end )

				local case_image = ibCreateContentImage( 0, 0, 360, 280, "case", v.id, area )
					:ibData( "disabled", true )

				if not v.versus and v.count and v.count <= 0 then
					case_image:ibData( "alpha", 0.3 * 255 )
					ibCreateImage( 0, 0, 360, 280, "img/cases/bg_select_case_limited_sold_top_layer.png", area )
						:ibData( "disabled", true )
				end

				local discount = GetDiscountForCase( v.id )
				local lbl_py = is_case_active and ( v.versus or ( v.temp_start_count or 0 ) > 50 ) and 11 or 15
				local lbl_font = is_case_active and ( v.versus or ( v.temp_start_count or 0 ) > 50 ) and ibFonts.regular_14 or ibFonts.light_16
				if is_case_winner then
					local lbl_name = ibCreateLabel( 0, lbl_py, 0, 0, v.name, area, _, _, _, "center", "top", lbl_font ):center_x( -11 )
					ibCreateImage( lbl_name:ibGetAfterX( 8 ), 7, 0, 0, "img/cases/icon_winner.png", area ):ibSetRealSize( ):ibData( "disabled", true )

				elseif discount and ( discounts_data.id ~= "cases_premium_discount" or is_case_expiring ) then
					local inner_area = ibCreateArea( 0, lbl_py, 0, 0, area )
					local lbl_name = ibCreateLabel( 0, 0, 0, 0, v.name, inner_area, _, _, _, "left", "top", lbl_font )
					local discount_img = ibCreateImage( lbl_name:ibGetAfterX( 8 ), -2, 0, 0, "img/cases/discount_bg.png", inner_area ):ibSetRealSize( ):ibData( "disabled", true )
					ibCreateLabel( 0, 0, 0, 0, "СКИДКА ".. discount.discount .. "%", discount_img, _, _, _, "center", "center", ibFonts.extrabold_12 ):center( )
					inner_area:ibData( "sx", discount_img:ibGetAfterX( ) ):center_x( )

				elseif v.is_hit == 1 or v.is_new == 1 then
					local inner_area = ibCreateArea( 0, lbl_py, 0, 0, area )
					local lbl_name = ibCreateLabel( 0, 0, 0, 0, v.name, inner_area, _, _, _, "left", "top", lbl_font )
					local area_hit = ibCreateArea( lbl_name:ibGetAfterX( 10 ), 0, 43, 24, inner_area ):ibData( "disabled", true )
					if v.is_hit == 1 then
						ibCreateImage( 0, 0, 0, 0, "img/cases/icon_hit.png", area_hit ):ibSetRealSize( ):center( ):ibData( "disabled", true )
					elseif v.is_new == 1 then
						ibCreateImage( 0, 0, 0, 0, "img/cases/icon_new.png", area_hit ):ibSetRealSize( ):center( 10, 0 ):ibData( "disabled", true )
					end
					inner_area:ibData( "sx", area_hit:ibGetAfterX( ) ):center_x( )
				else
					ibCreateLabel( 0, lbl_py, 0, 0, v.name, area, _, _, _, "center", "top", lbl_font ):center_x( )
				end
				
				local case_count = 0
				local count_area = ibCreateArea( 0, IsCaseCostHidden( v ) and 243 or 215, 0, 0, area ):ibData( "alpha", 0 )
				local lbl_count_text = ibCreateLabel( 0, 0, 0, 0, "В наличии:", count_area )
					:ibData( "font", ibFonts.light_16 )
				local lbl_count = ibCreateLabel( lbl_count_text:ibGetAfterX( 8 ), -2, 0, 0, case_count, count_area )
					:ibData( "font", ibFonts.bold_18 )

				local function UpdateCaseCount( )
					player_cases = localPlayer:GetCases( )
					if ( player_cases[ v.id ] or 0 ) == case_count then return end
					case_count = player_cases[ v.id ] or 0

					if case_count > 0 then
						lbl_count:ibData( "text", case_count )
						count_area:ibBatchData( { sx = lbl_count:ibGetAfterX( ), alpha = 255 } ):center_x( )
						case_image:center( 0, 0 )
					else
						count_area:ibData( "alpha", 0 )
						case_image:center( )
					end
				end
				UpdateCaseCount( )
				count_area:ibTimer( UpdateCaseCount, 1000, 0 )

				if not IsCaseCostHidden( v ) then
					local cost_area = ibCreateArea( 0, 234, 0, 0, area ):center_x( )
					local inner_area = ibCreateArea( 0, 0, 0, 0, cost_area )
					local discount = GetDiscountForCase( v.id )
					if discount and not is_7cases_case then
						local lbl_old_cost = ibCreateLabel( 0, 5, 0, 0, v.cost, inner_area, ibApplyAlpha( COLOR_WHITE, 50 ) ):ibData( "font", ibFonts.semibold_18 )
						ibCreateLine( lbl_old_cost:ibData( "px" ) - 2, lbl_old_cost:ibGetCenterY( ), lbl_old_cost:ibGetAfterX( 2 ), _, COLOR_WHITE, 1, inner_area )
						local lbl_cost = ibCreateLabel( lbl_old_cost:ibGetAfterX( 10 ), 0, 0, 0, discount.cost, inner_area ):ibData( "font", ibFonts.bold_24 )
						local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 10 ), 4, 28, 28, ":nrp_shared/img/hard_money_icon.png", inner_area ):ibData( "disabled", true )

						inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
					else
						local cost = localPlayer:GetCostWithCouponDiscount( "special_case", v.cost )
						local lbl_cost = ibCreateLabel( 0, 0, 0, 0, format_price( cost ), inner_area ):ibData( "font", ibFonts.bold_24 )
						local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 10 ), 4, 28, 28, ":nrp_shared/img/".. ( v.cost_is_soft and "" or "hard_" ) .."money_icon.png", inner_area ):ibData( "disabled", true )

						inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
					end

					if ( v.versus or v.temp_start_count and v.temp_start_count > 50 ) and is_case_active and not is_7cases_case then
						local start_count = v.temp_start_count or 2500

						local bg_progress = ibCreateImage( 75, 51, 210, 10, _, area, ibApplyAlpha( COLOR_BLACK, 35 ) )
							:ibData( "disabled", true )
						local progressbar = ibCreateImage( 75, 51, 0, 10, _, area, 0xFFff9759 )
							:ibData( "disabled", true )

						ibCreateLabel( 0, -18, 0, 0, "Осталось кейсов:", bg_progress )
							:ibData( "font", ibFonts.regular_12 )
							:ibData( "alpha", 255 * 0.6 )
						local lbl_percent = ibCreateLabel( 0, -18, bg_progress:width( ), 0, "", 
							bg_progress, _, _, _, "right", "top", ibFonts.regular_12 )

						local function UpdateCaseCountProgressBar( )
							local progress = math.max( 0, math.min( 1, ( v.count or 0 ) / start_count ) )
							progressbar:ibData( "sx", math.ceil( 210 * progress ) )

							if start_count <= 100 then
								lbl_percent:ibData( "text", v.count )
							else
								progress = math[ progress < 0.01 and "ceil" or "floor" ]( progress * 100 )
								lbl_percent:ibData( "text", progress .. "%" )
							end
						end
						UpdateCaseCountProgressBar( )
						bg_progress:ibTimer( UpdateCaseCountProgressBar, 2000, 0 )
							
					elseif ( v.temp_start_count or v.count ) and is_case_active and not is_7cases_case then
						local bg_global_count = ibCreateImage( 0, 43, 360, 24, "img/cases/bg_case_global_count.png", area ):center_x( ):ibData( "disabled", true )
						local inner_area = ibCreateArea( 0, 0, 0, 0, bg_global_count )
						local lbl_info = ibCreateLabel( 0, 12, 0, 0, "Осталось кейсов:", inner_area, 0xBFFFFFFF, _, _, "left", "center", ibFonts.light_16 )
						local lbl_count = ibCreateLabel( lbl_info:ibGetAfterX( 5 ), 12, 0, 0, math.max( v.count or 0, 0 ), inner_area, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_16 )
						
						local lbl_timer
						if is_case_expiring then
							local lbl_slash = ibCreateLabel( lbl_count:ibGetAfterX( 10 ), 12, 0, 0, "/", inner_area, 0x44FFFFFF, _, _, "left", "center", ibFonts.light_16 )
							local icon_tmp = ibCreateImage( lbl_slash:ibGetAfterX( 8 ), 3, 22, 24, "img/cases/icon_tmp.png", inner_area ):ibData( "disabled", true )
								:ibSetInBoundSize( 16, 16 )
							lbl_timer = ibCreateLabel( icon_tmp:ibGetAfterX( 5 ), 12, 0, 0, "", inner_area, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_16 )
						end

						local function UpdateCaseCount( )
							lbl_count:ibData( "text", math.max( v.count or 0, 0 ) )
							if lbl_timer then
								lbl_timer:ibData( "text", getHumanTimeString( v.temp_end, true ) or "" )
							end
						end
						UpdateCaseCount( )
						bg_global_count:ibTimer( UpdateCaseCount, 2000, 0 )

						inner_area:ibData( "sx", ( lbl_timer or lbl_count ):ibGetAfterX( ) ):center_x( )
						case_image:center( 0, 0 )
						
					elseif not GIFT_CASES[ v.id ] and ( is_case_expiring or ( v.temp_start or 0 ) > current_date ) and not is_7cases_case then
						local inner_area = ibCreateArea( 0, 55, 0, 0, area )
						local icon_tmp = ibCreateImage( 0, 0, 22, 24, "img/cases/icon_tmp.png", inner_area ):center_y( ):ibData( "disabled", true )
						local temp_timeout = ( v.temp_start or 0 ) > current_date and 0 or v.temp_end
						local temp_text = getHumanTimeString( temp_timeout, true )
						local lbl_info = ibCreateLabel( icon_tmp:ibGetAfterX( 10 ), 0, 0, 0, temp_text and "Кейс доступен еще:" or "Покупка больше недоступна", inner_area, 0xBFFFFFFF, _, _, "left", "center", ibFonts.regular_14 )
						local lbl_timeout = ibCreateLabel( lbl_info:ibGetAfterX( 5 ), 0, 0, 0, temp_text or "", inner_area, 0xBFFFFFFF, _, _, "left", "center", ibFonts.bold_14 )

						inner_area:ibData( "sx", lbl_timeout:ibGetAfterX( ) ):center_x( )
						case_image:center( 0, 0 )
					
					elseif discount and discounts_data.id == "cases_premium_discount" then	
						local inner_area = ibCreateArea( 0, 45, 0, 0, area )
						local lbl_name = ibCreateLabel( 0, 0, 0, 0, "Премиальная скидка", inner_area, _, _, _, "left", "top", ibFonts.regular_14 )
						local discount_img = ibCreateImage( lbl_name:ibGetAfterX( 8 ), -2, 0, 0, "img/cases/discount_bg.png", inner_area ):ibSetRealSize( ):ibData( "disabled", true )
						ibCreateLabel( 0, 0, 0, 0, "СКИДКА ".. discount.discount .. "%", discount_img, _, _, _, "center", "center", ibFonts.extrabold_12 ):center( )
						inner_area:ibData( "sx", discount_img:ibGetAfterX( ) ):center_x( )
					end
				end
			end

			area_cases_bg:ibData( "sy", npy + 20 + 280 )
			
			rt:AdaptHeightToContents( )

			if last_item then
				ShowCasesReward( last_item, true )
			end
		end
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
function CasesGoBack( )
	if not isElement( UI_elements.bg ) then return end

	if UI.bg_image then
		UI.bg_image:ibData( "px", -screen_size_x):ibMoveTo( screen_size_x / 2 - 800 / 2, _, 500, "OutBack" )
	end
	UI_elements.bg
		:ibData( "px", screen_size_x / 2 - 800 / 2 )
		:ibMoveTo( screen_size_x, _, 500, "OutBack" )
		:ibTimer( function( self ) self:destroy( ) end, 500, 1 )
end
addEvent( "onCaseReturnToMenu", true )
addEventHandler( "onCaseReturnToMenu", root, CasesGoBack )

function ShowUICase( case_info )
	if isElement( UI_elements.bg ) then
		UI_elements.bg:destroy( )
	end
    
	WINDOW_TYPE = { WINDOW_TYPE_CASE_INFO, case_info }

    UI_elements.bg = ibCreateImage( 0, screen_size_y / 2 - 570 / 2, 800, 570, "img/cases/bg_case.png", UI.black_bg )
        :ibOnDestroy( function( )
			WINDOW_TYPE = nil
			if isElement( UI_elements.description_box ) then
				destroyElement( UI_elements.description_box )
			end
        end )

	UI_elements.btn_back = ibCreateButton(	21, 19, 130, 40, UI_elements.bg,
												"img/cases/btn_back.png", "img/cases/btn_back.png", "img/cases/btn_back.png",
												0xBFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
	addEventHandler( "ibOnElementMouseClick", UI_elements.btn_back, function( key, state )
		if key ~= "left" or state ~= "up" then return end

		ibClick( )

        CasesGoBack( )
	end, false )

	UI_elements.btn_close	= ibCreateButton(	748, 25, 24, 24, UI_elements.bg,
												":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
												0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
	addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( key, state )
		if key ~= "left" or state ~= "up" then return end

		ibClick( )
		ShowDonateUI( false )
	end, false )


	ibCreateLabel( 400, 37, 0, 0, case_info.name or "", UI_elements.bg ):ibBatchData( { font = ibFonts.bold_23, align_x = "center", align_y = "center" })
	ibCreateContentImage( 0, 80, 372, 252, "case", case_info.id, UI_elements.bg )

	local case_discount = GetDiscountForCase( case_info.id )
	local time_left = case_info.temp_end and case_info.temp_end - getRealTimestamp( )
	local is_case_active = not time_left or time_left > 0

	if ( ( case_info.temp_start_count or 0 ) > 50 or case_info.versus ) and is_case_active then
		local start_count = case_info.temp_start_count or 2500
		local bg_progress = ibCreateImage( 82, 100, 210, 10, _, UI_elements.bg, ibApplyAlpha( COLOR_BLACK, 35 ) )
		local progressbar = ibCreateImage( 0, 0, 0, 10, _, bg_progress, 0xFFff9759 )

		ibCreateLabel( 0, -18, 0, 0, "Осталось кейсов:", bg_progress )
			:ibData( "font", ibFonts.regular_12 )
			:ibData( "alpha", 255 * 0.6 )
		local lbl_percent = ibCreateLabel( 0, -18, bg_progress:width( ), 0, "", 
			bg_progress, _, _, _, "right", "top", ibFonts.regular_12 )
		
		local function UpdateCaseCountProgressBar( )
			local progress = math.max( 0, math.min( 1, ( case_info.count or 0 ) / start_count ) )
			progressbar:ibData( "sx", math.ceil( 210 * progress ) )

			if start_count <= 100 then
				lbl_percent:ibData( "text", case_info.count or 0 )
			else
				progress = math[ progress < 0.01 and "ceil" or "floor" ]( progress * 100 )
				lbl_percent:ibData( "text", progress .. "%" )
			end
		end
		UpdateCaseCountProgressBar( )
		bg_progress:ibTimer( UpdateCaseCountProgressBar, 1000, 0 )


	elseif case_info.count and is_case_active then
		local bg_global_count = ibCreateImage( 0, 73, 360, 24, "img/cases/bg_case_global_count.png", UI_elements.bg ):ibData( "disabled", true )
		local area_count = ibCreateArea( 0, 0, 0, 0, bg_global_count )
		local lbl_info = ibCreateLabel( 0, 0, 0, 24, "Осталось кейсов:", area_count, 0xBFFFFFFF, _, _, "left", "center", ibFonts.light_16 )
		local lbl_count = ibCreateLabel( lbl_info:ibGetAfterX( 5 ), 12, 0, 0, math.max( case_info.count, 0 ), area_count, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_16 )
		
		local function UpdateCaseCount( )
			lbl_count:ibData( "text",  math.max( case_info.count, 0 ) )
			area_count:ibData( "sx", lbl_count:ibGetAfterX() ):center_x()
		end
		UpdateCaseCount( )
		lbl_count:ibTimer( UpdateCaseCount, 1000, 0 )
	else
		if case_discount then
			local bg = ibCreateImage( 0, 73, 367, 45, "img/cases/bg_discount.png", UI_elements.bg )
			local lbl_discount = ibCreateLabel( bg:ibGetCenterX( ), bg:ibData( "py" ) + 4, 0, 0, "-" .. case_discount.discount .. "%", UI_elements.bg, 0xffff5858, _, _, "center", "top", ibFonts.bold_14 )
			ibCreateLabel( bg:ibGetCenterX( ), lbl_discount:ibGetAfterY( 0 ), 0, 0, "Скидка действует ограниченное время!", UI_elements.bg, 0xffffffff, _, _, "center", "top", ibFonts.bold_10 )
		elseif case_info.is_hit == 1 then
			ibCreateImage( 138, 73, 95, 41, "img/cases/hit_icon.png", UI_elements.bg )
		end
	end


	local balance_text = ibCreateLabel( 510, 101, 0, 0, format_price( case_info.cost_is_soft and localPlayer:GetMoney( ) or localPlayer:GetDonate( ) ), UI_elements.bg )
	balance_text:ibBatchData( { font = ibFonts.bold_18, align_x = "left", align_y = "center" })

	local balance_img = ibCreateImage( balance_text:ibGetAfterX( 10 ), 87, 28, 28, ":nrp_shared/img/".. ( case_info.cost_is_soft and "" or "hard_" ) .."money_icon.png", UI_elements.bg )

	local balance_btn	= ibCreateButton(	650, 83, 126, 34, UI_elements.bg,
											"img/cases/btn_balance_i.png", "img/cases/btn_balance_h.png", "img/cases/btn_balance_c.png",
											0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
	addEventHandler( "ibOnElementMouseClick", balance_btn, function( key, state )
		if key ~= "left" or state ~= "up" then return end
        ibClick( )
        
        CasesGoBack( )
        SwitchNavbar( "donate" )
	end, false )


	local buy_count = 1

	local cost = localPlayer:GetCostWithCouponDiscount( "special_case", case_info.cost )
	local case_cost_amount = case_discount and case_discount.cost or cost

	local cost_area = ibCreateArea( 0, 0, 0, 0, UI_elements.bg ):center( -214, 85 )
	local inner_area = ibCreateArea( 0, 0, 0, 0, cost_area )
	local case_cost = ibCreateLabel( 0, 0, 0, 0, format_price( case_cost_amount ), inner_area ):ibBatchData( { font = ibFonts.bold_24, align_x = "left", align_y = "center" }):center_y( )
	local icon_money = ibCreateImage( case_cost:ibGetAfterX( 10 ), 0, 28, 28, ":nrp_shared/img/".. ( case_info.cost_is_soft and "" or "hard_" ) .."money_icon.png", inner_area ):center_y( )

	inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )

	if IsCaseCostHidden( case_info ) then
		cost_area:ibData( "visible", false )
	end

	-- Если у кейса скидка

	local lbl_old_cost, line_old_cost
	local function UpdateOldCostPositions( )
		if not isElement( lbl_old_cost ) and not isElement( line_old_cost ) then return end
		
		local cost = localPlayer:GetCostWithCouponDiscount( "special_case", case_info.cost )
		lbl_old_cost:ibBatchData( {
			px = cost_area:ibGetBeforeX( 5 ),
			py = cost_area:ibGetCenterY( -30 ),
			text = cost * buy_count,
		} )

		line_old_cost:ibBatchData( {
			px = lbl_old_cost:ibGetBeforeX( -2 ),
			py = lbl_old_cost:ibGetCenterY( ),
			sx = lbl_old_cost:width( ) + 4,
		} )
	end

	if case_discount then
		lbl_old_cost
			= ibCreateLabel( 0, 0, 0, 0, 0, UI_elements.bg )
			:ibBatchData( { font = ibFonts.regular_14, align_x = "right", align_y = "center", color = 0x77ffffff } )

		case_cost:ibData( "text", format_price( case_discount.cost ) )
		icon_money:ibData( "px", case_cost:ibGetAfterX( 10 ) )
		inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
		line_old_cost = ibCreateImage( 0, 0, 0, 1, _, UI_elements.bg, 0xffffffff )
		UpdateOldCostPositions( )
	end

	local case_count	= ibCreateLabel( 186, 426, 0, 0, buy_count, UI_elements.bg )
	case_count:ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" })

	local max_count = HasDiscounts( ) and HasDiscounts( ).id == "cases50" and case_discount and 3 or 99

	local btn_min		= ibCreateButton(	126, 411, 30, 30, UI_elements.bg,
											":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png",
											0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
	addEventHandler( "ibOnElementMouseClick", btn_min, function( key, state )
		if key ~= "left" or state ~= "up" then return end

		if not localPlayer:HasCase( nil, case_info.id ) then
			buy_count = ( buy_count - 2 ) % max_count + 1
			--if case_discount and buy_count == 2 then buy_count = 1 end
			case_count:ibData( "text", buy_count )
			case_cost:ibData( "text", format_price( case_cost_amount * buy_count ) )
			icon_money:ibData( "px", case_cost:ibGetAfterX( 10 ) )
			inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
			UpdateOldCostPositions( )

			ibClick( )
		end
	end, false )

	local btn_plus		= ibCreateButton(	215, 411, 30, 30, UI_elements.bg,
											":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png",
											0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
	addEventHandler( "ibOnElementMouseClick", btn_plus, function( key, state )
		if key ~= "left" or state ~= "up" then return end

		if not localPlayer:HasCase( nil, case_info.id ) then
			buy_count = buy_count % max_count + 1
			--if case_discount and buy_count == 2 then buy_count = 3 end
			case_count:ibData( "text", buy_count )
			case_cost:ibData( "text", format_price( case_cost_amount * buy_count ) )
			icon_money:ibData( "px", case_cost:ibGetAfterX( 10 ) )
			inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
			UpdateOldCostPositions( )

			ibClick( )
		end
	end, false )

	local case_btn_original_sx, case_btn_original_sy = 175, 79
	local case_btn_original_px, case_btn_original_py = 98, 444
	local case_btn =
		case_discount and
			ibCreateButton(	68, 446, 244, 76, UI_elements.bg,
												"img/cases/btn_buy_discount_i.png", "img/cases/btn_buy_discount_h.png", "img/cases/btn_buy_discount_c.png",
												0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		or
			ibCreateButton(	case_btn_original_px, case_btn_original_py, case_btn_original_sx, case_btn_original_sy, UI_elements.bg,
													"img/cases/btn_buy_i.png", "img/cases/btn_buy_h.png", "img/cases/btn_buy_c.png",
													0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

	local case_btn_px, case_btn_py = case_btn:ibData( "px" ), case_btn:ibData( "py" )
	local case_btn_sx, case_btn_sy = case_btn:ibData( "sx" ), case_btn:ibData( "sy" )
	local case_btn_i, case_btn_h, case_btn_c = case_btn:ibData( "texture" ), case_btn:ibData( "texture_hover" ), case_btn:ibData( "texture_click" )

	local current_case_btn_type = "buy"
	local function SetPurchaseButton( btype )
		if current_case_btn_type == btype then return end
		current_case_btn_type = btype
		if btype == "open" then
			case_btn:ibBatchData( {
				px = case_btn_original_px,
				py = case_btn_original_py,
				sx = case_btn_original_sx,
				sy = case_btn_original_sy,
				disabled = false,

				texture       = "img/cases/btn_open_i.png",
				texture_hover = "img/cases/btn_open_h.png",
				texture_click = "img/cases/btn_open_c.png",
			} )
		else
			case_btn:ibBatchData( {
				px = case_btn_px,
				py = case_btn_py,
				sx = case_btn_sx,
				sy = case_btn_sy,

				texture       = case_btn_i,
				texture_hover = case_btn_h,
				texture_click = case_btn_c,
			} )

		end
	end

	case_btn:ibTimer( function( self )
		self:ibInterpolate( function( self )
			if not isElement( self.element ) or current_case_btn_type ~= "open" then return end
			if self.element:ibData( "disabled" ) then
				SetPurchaseButton( "open" )
				return
			end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { 
				px = ( case_btn_original_px - case_btn_original_sx * ( self.easing_value - 1 ) * 0.5 ), 
				py = ( case_btn_original_py - case_btn_original_sy * ( self.easing_value - 1 ) * 0.5 ), 
				sx = ( case_btn_original_sx * self.easing_value ), 
				sy = ( case_btn_original_sy * self.easing_value ), 
			} )
		end, 400, "SineCurve" )
	end, 800, 0 )

	addEventHandler( "ibOnElementMouseClick", case_btn, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		
		if SEND_DATA_TIMEOUT > getTickCount( ) then return end
		SEND_DATA_TIMEOUT = getTickCount( ) + 500

		if localPlayer:HasCase( nil, case_info.id ) then
			triggerServerEvent( "PlayerWantOpenCase", resourceRoot, case_info.id, not SCROLL_SLIDER_ACTIVE )
			ibClick( )
		elseif IsCaseCostHidden( case_info ) then
			return
		else
			local discount_data = HasDiscounts( )
			if discount_data and discount_data.id == "7cases_discount" then
				for k,v in pairs( discount_data.array ) do
					if v.case_id == case_info.id then
						ShowDonateUI( false )
	            		triggerEvent("ShowUI_7CasesDiscount", localPlayer, true)
	            		return
					end
				end
			end

			if discount_data and discount_data.id == "wholesome_case_discount" and buy_count >= 3 then
				for k,v in pairs( discount_data.array ) do
					if v.case_id == case_info.id then
						ShowDonateUI( false )
	            		triggerEvent( "ShowUI_WholesomeCaseDiscount", localPlayer, true )
	            		return
					end
				end
			end

			SendElasticGameEvent( "f4r_f4_cases_purchase_button_click" )

			if case_info.temp_start then
				local current_date = getRealTimestamp( )
				if case_info.temp_start > current_date or ( case_info.temp_end and case_info.temp_end < current_date ) then
					localPlayer:ShowError( "Кейс недоступен для покупки" )
					return
				end
			end

			if case_info.count and case_info.count < buy_count then
				if case_info.count <= 0 then
					localPlayer:ShowError( "Кейс больше недоступен для покупки" )
				else
					localPlayer:ShowError( "На складе нет столько кейсов (доступно ".. case_info.count .." шт.)" )
				end
				return
			end

			if case_info.purchase_disabled then
				localPlayer:ShowError( "Кейс больше недоступен для покупки" )
				return
			end

			if case_info.cost_is_soft then
				if not localPlayer:HasMoney( case_cost_amount * buy_count ) then
					localPlayer:ShowError( "Недостаточно средств" )
					return
				end
				ibBuyProductSound()
			else
				if not localPlayer:HasDonate( case_cost_amount * buy_count ) then
					triggerEvent( "onShopNotEnoughHard", localPlayer, "Cases", "onCaseReturnToMenu" )
					return
				end
				ibBuyDonateSound()
			end

			triggerServerEvent( "PlayerWantBuyCase", resourceRoot, case_info.id, buy_count )
		end
	end, false )

	if IsCaseCostHidden( case_info ) or localPlayer:HasCase( nil, case_info.id ) then
		local player_cases = localPlayer:GetCases()
		case_count:ibData( "text", player_cases[ case_info.id ] or 0 )
		btn_min:ibData( "alpha", 0 )
		btn_plus:ibData( "alpha", 0 )

		SetPurchaseButton( "open" )
	else
		case_cost:ibData( "text", format_price( case_cost_amount * buy_count ) )
		icon_money:ibData( "px", case_cost:ibGetAfterX( 10 ) )
		inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
		UpdateOldCostPositions( )
		btn_min:ibData( "alpha", 255 )
		btn_plus:ibData( "alpha", 255 )
	end

	UI_elements.bg:ibTimer( function()
		local player_cases = localPlayer:GetCases()

		balance_text:ibData( "text", format_price( case_info.cost_is_soft and localPlayer:GetMoney( ) or localPlayer:GetDonate( ) ) )
		balance_img:ibData( "px", balance_text:ibGetAfterX( 10 ) )

		if localPlayer:HasCase( nil, case_info.id ) then
			buy_count = 1
			case_count:ibData( "text", player_cases[ case_info.id ] or 0 )
			case_cost:ibData( "text", format_price( case_cost_amount ) )
			icon_money:ibData( "px", case_cost:ibGetAfterX( 10 ) )
			inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
			UpdateOldCostPositions( )
			btn_min:ibData( "alpha", 0 )
			btn_plus:ibData( "alpha", 0 )

			SetPurchaseButton( "open" )
			
		elseif IsCaseCostHidden( case_info ) then
			case_count:ibData( "text", 0 )
			case_btn:ibData( "disabled", true )
		else
			case_count:ibData( "text", buy_count )
			case_cost:ibData( "text", format_price( case_cost_amount * buy_count ) )
			icon_money:ibData( "px", case_cost:ibGetAfterX( 10 ) )
			inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
			UpdateOldCostPositions( )
			btn_min:ibData( "alpha", 255 )
			btn_plus:ibData( "alpha", 255 )

			SetPurchaseButton( "buy" )
		end
	end, 250, 0 )

	local scroll_text			= ibCreateLabel( 105, 536, 0, 0, SCROLL_SLIDER_ACTIVE and "Прокрутка активирована" or "Прокрутка деактивирована", UI_elements.bg, 0x80ffffff ):ibBatchData( { font = ibFonts.regular_14, align_x = "left", align_y = "center" })
	UI_elements.scroll_slider	= ibCreateSlider( 31, 522, UI_elements.bg, function( new_state )
									if new_state then
										scroll_text:ibData( "text", "Прокрутка активирована" )
									else
										scroll_text:ibData( "text", "Прокрутка деактивирована" )
									end

									SCROLL_SLIDER_ACTIVE = new_state
								end, SCROLL_SLIDER_ACTIVE )

	UI_elements.items_pane, scroll_v	= ibCreateScrollpane( 373, 190, 427, 365, UI_elements.bg, { scroll_px = -25, bg_color = 0x00FFFFFF } )
	scroll_v:ibData( "sensivity", 0.1 )

	if next( case_info.items ) then
		for j, item in pairs( case_info.items ) do
			if REGISTERED_ITEMS[ item.id ] then
				CreateCaseItem( item, 60 + 108 * ( ( j - 1 ) % 3 ), 5 + 108 * math.floor( ( j - 1 ) / 3 ), UI_elements.items_pane )
			end
		end
	end

	UI_elements.items_pane:AdaptHeightToContents( )
    scroll_v:UpdateScrollbarVisibility( UI_elements.items_pane )
end

function CreateCaseItem( item, pos_x, pos_y, bg )
	local item_bg		= ibCreateImage( pos_x, pos_y, 96, 96, "img/cases/item_bg.png", bg )
	local item_bg_hover	= ibCreateImage( 0, 0, 96, 96, "img/cases/item_bg_hover.png", item_bg ):ibData( "alpha", 0 )
	ibCreateImage( 16, -9, 65, 29, "img/cases/rare.png", item_bg, CONST_RARE_COLORS[ item.rare ] )
	REGISTERED_ITEMS[ item.id ].uiCreateItem_func( item.id, item.params, item_bg, fonts )

	local description_area	= ibCreateArea( 3, 3, 90, 90, item_bg )
	addEventHandler( "ibOnElementMouseEnter", description_area, function( )
		if isElement( UI_elements.description_box ) then
			destroyElement( UI_elements.description_box )
		end

		item_bg_hover:ibAlphaTo( 255, 350 )

		local description_data = REGISTERED_ITEMS[ item.id ].uiGetDescriptionData_func( item.id, item.params )
		if description_data then
			local title_len = dxGetTextWidth( description_data.title, 1, ibFonts.bold_15 ) + 30
			local box_s_x = math.max( 170, title_len )
			local box_s_y = 92
			if not description_data.description then
				box_s_x = title_len
				box_s_y = 35
			end

			local pos_x, pos_y = getCursorPosition( )
			pos_x, pos_y = pos_x * screen_size_x, pos_y * screen_size_y
	
			UI_elements.description_box = ibCreateImage( pos_x - 5, pos_y - box_s_y - 5, box_s_x, box_s_y, nil, nil, 0xCC000000 )
				:ibData( "alpha", 0 )
				:ibAlphaTo( 255, 350 )
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

		item_bg_hover:ibAlphaTo( 0, 350 )
	end, false )

    return item_bg
end

function ShowCasesReward( item, is_forgotten_to_take )
	if not item then return end
	if isElement( UI_elements.reward_bg ) then return end

	if UI and isElement(UI.black_bg) then
		UI.black_bg:ibData( "can_destroy", false )
	end

	UI_elements.reward_bg		= ibCreateImage( 0, 0, screen_size_x, screen_size_y, 0, UI_elements.black_bg, 0xE6394A5C ):ibData( "alpha", 0 ):ibAlphaTo( 255, 700 )
	UI_elements.reward_brash	= ibCreateImage( 0, 0, 1174, 692, "img/cases/reward_bg.png", UI_elements.reward_bg ):center( )

	local item_class = REGISTERED_ITEMS[ item.id ]
	local description_data = item_class.uiGetDescriptionData_func( item.id, item.params )
	if description_data then
		local reward_text = is_forgotten_to_take and "Вы не забрали свою награду:" or "Поздравляем! Вы получили:"
		UI_elements.reward_text = ibCreateLabel( 0, 0, 0, 0, reward_text, UI_elements.reward_bg )
			:ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })
			:center( 0, -244 )

		local func_interpolate = function( self )
			self:ibInterpolate( function( self )
				if not isElement( self.element ) then return end
				self.easing_value = 1 + 0.2 * self.easing_value
				self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
			end, 350, "SineCurve" )
		end

		local title = ( description_data.reward_title or description_data.title or "" ):gsub( "\n", " " ):gsub( "  ", " " )
		ibCreateLabel( 0, 32, 0, 0, title, UI_elements.reward_text, 0xffffe743 )
			:ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })
			:ibTimer( func_interpolate, 100, 1 )
			:ibTimer( func_interpolate, 1000, 0 )
	end

	UI_elements.reward_item_bg = ibCreateArea( 0, 0, 300, 396, UI_elements.reward_bg ):center( )
	-- UI_elements.reward_item_bg = ibCreateArea( 0, 0, 0, 340, UI_elements.reward_bg ):center( )
	item_class.uiCreateRewardItem_func( item.id, item.params, UI_elements.reward_item_bg, fonts, true )

	if item.rare > 3 then
		playSound( "sfx/reward_big.wav" )
	else
		playSound( "sfx/reward_small.mp3" )
	end

	if not item.params.exchange or item.params.exchange.or_take then
		UI_elements.btn_take = ibCreateButton( 0, 0, 192, 110, UI_elements.reward_bg,
				"img/cases/btn_take_i.png", "img/cases/btn_take_h.png", "img/cases/btn_take_h.png",
				0xFFFFFFFF, 0xFFFFFFFF, 0xAAFFFFFF )
			:center( 0, 223 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				if UI and isElement(UI.black_bg) then
					UI.black_bg:ibData( "can_destroy", true )
				end

				destroyElement( UI_elements.reward_bg )
				
				if item_class.takeReward_client_func then
					item_class.takeReward_client_func( item, item.params )
				else
					triggerServerEvent( "PlayerWantTakeOpenedCaseItem", resourceRoot )
				end
			end, false )
	end

	if item.params.exchange then
		UI_elements.reward_text:center( 0, -326 )
		UI_elements.reward_item_bg:center( 0, -150 )
		if isElement( UI_elements.btn_take ) then
			UI_elements.btn_take:center( 0, 55 )
		end

		local bg = ibCreateImage( 0, 0, 366, 166, "img/cases/bg_exchange.png", UI_elements.reward_bg )
			:center( 0, isElement( UI_elements.btn_take ) and 225 or 130 )

		local text = item.params.exchange.or_take 
			and "Пол этого скина не совпадает с полом вашего персонажа. \nВы можете его обменять:"
			or "У вас в наличии уже есть полученный предмет. \nВы можете его обменять:"
		ibCreateLabel( 0, 0, 0, 0, text, bg )
			:ibBatchData( { font = ibFonts.regular_16, align_x = "center", align_y = "top" })
			:center_x( )

		ibCreateLabel( 68, 141, 0, 0, item.params.exchange.exp, bg )
			:ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })

		ibCreateButton( 18, 185, 100, 40, bg,
				"img/cases/btn_exchange_i.png", "img/cases/btn_exchange_h.png", "img/cases/btn_exchange_h.png",
				0xFFFFFFFF, 0xFFFFFFFF, 0xAAFFFFFF )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				if UI and isElement(UI.black_bg) then
					UI.black_bg:ibData( "can_destroy", true )
				end

				destroyElement( UI_elements.reward_bg )
				triggerServerEvent( "PlayerWantSellOpenedCaseItem", resourceRoot, "exp" )
			end, false )

		ibCreateLabel( 298, 141, 0, 0, abbreviate_number( item.params.exchange.soft ), bg )
			:ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })

		ibCreateButton( 248, 185, 100, 40, bg,
				"img/cases/btn_exchange_i.png", "img/cases/btn_exchange_h.png", "img/cases/btn_exchange_h.png",
				0xFFFFFFFF, 0xFFFFFFFF, 0xAAFFFFFF )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				if UI and isElement(UI.black_bg) then
					UI.black_bg:ibData( "can_destroy", true )
				end

				destroyElement( UI_elements.reward_bg )
				triggerServerEvent( "PlayerWantSellOpenedCaseItem", resourceRoot, "soft" )
			end, false )
	end
end
addEvent( "ShowCasesReward", true )
addEventHandler( "ShowCasesReward", resourceRoot, ShowCasesReward )

local roll_data = nil
local CONST_ITEMS_ROLLING_COUNT = 120
local CONST_ROLLING_CLOSE_TIMES = 500
local CONST_ROLLING_TIMES = 15 * 1000

local block_sx, block_sy = 320, 300
local block_gap = 15

local roll_bg_x, roll_bg_y = math.floor( ( screen_size_x - 1174 ) / 2 ), math.floor( ( screen_size_y - 692 ) / 2 )
local _count_blocks = math.ceil( screen_size_x / ( block_sx + block_gap ) )
_count_blocks = _count_blocks + ( _count_blocks % 2 )
local _start_index = _count_blocks / 2 + 1.5
local _pos_x = math.floor( ( screen_size_x - ( block_sx + block_gap ) * _count_blocks - block_sx ) / 2 )
local _pos_y = math.floor( ( screen_size_y - block_sy ) / 2 )
local tmp_curr_index = 0

function ShowRewardRolling( case_id, item_index, item, ignore_rolling )
--	if not isElement( UI.bg ) then return end
	if roll_data then return end

	local case_index = nil
	for i, info in pairs( CACHE_CASES ) do
		if info.id == case_id then
			case_index = i
			break
		end
	end

	if not case_index or ignore_rolling then
		ShowCasesReward( item )
		return
	end
	
	roll_data = {
		start_tick = getTickCount( );

		case_id = case_id;
		case_index = case_index;
		case_items = table.copy( CACHE_CASES[ case_index ].items );
		reward_item_index = item_index;
		reward_item = item;

		current_index = _start_index;
		reward_item_index_scroll = 0.05 + math.random( ) * 0.9;

		loading_item_textures = { },
		list_index_items = GenerateRollingListItems( case_index, item_index );
	}

	if UI and isElement(UI.black_bg) then
		UI.black_bg:ibData( "can_destroy", false )
	end
	
	if isElement( UI_elements.bg_roll ) then
		destroyElement( UI_elements.bg_roll )
	end
	UI_elements.bg_roll = ibCreateArea( 0, 0, screen_size_x, screen_size_y, UI_elements.black_bg ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
	UI_elements.loading_roll = ibLoading( { parent = UI_elements.bg_roll } )

	LoadItemsTextures( case_index )
end
addEvent( "ShowCasesRollingReward", true )
addEventHandler( "ShowCasesRollingReward", resourceRoot, ShowRewardRolling )

function LoadItemsTextures( case_index )
	for i, item in pairs( roll_data.case_items ) do
		local uiGetContentTextureRolling = REGISTERED_ITEMS[ item.id ].uiGetContentTextureRolling
		if uiGetContentTextureRolling then
			local content_type, content_id, width, height = uiGetContentTextureRolling( item.id, item.params );
			if content_type then
				local texture_path = ":nrp_content/content/" .. content_type .. "/" .. width .. "x" .. height .. "/" .. content_id .. ".png"
				item.texture_path = texture_path
				roll_data.loading_item_textures[ texture_path ] = true
			end
		end
	end
	for i, item in pairs( roll_data.case_items ) do
		if item.texture_path then
			local content_type, content_id, width, height = REGISTERED_ITEMS[ item.id ].uiGetContentTextureRolling( item.id, item.params );
			-- local texture_path = exports.nrp_content:RequestContentImageTexture( content_type, content_id, width, height )
			triggerEvent( "RequestContentImageTexture", root, content_type, content_id, width, height )
		end
	end
end

addEvent( "onClientContentImageLoad" )
addEventHandler( "onClientContentImageLoad", root, function( texture_path, is_success )
	if not roll_data or not roll_data.loading_item_textures[ texture_path ] then return end

	roll_data.loading_item_textures[ texture_path ] = nil

	if not next( roll_data.loading_item_textures ) and not roll_data.items_textures_data then
		StartRewardRolling( )
	end
end )

function StartRewardRolling( )
	roll_data.items_textures_data = GenerateItemsTextures( case_index )
	UI_elements.loading_roll:destroy( )
	roll_data.start_tick = getTickCount( );
	addEventHandler( "onClientRender", root, RenderCaseRolling, true, "low-999" )
	addEventHandler( "onClientKey", root, onClientKey_handler )
end

function GenerateItemsTextures( )
	local items_textures_data = { }

	for i, item in pairs( roll_data.case_items ) do
		local uiCreateTextureRolling = REGISTERED_ITEMS[ item.id ].uiCreateTextureRolling
		items_textures_data[ i ] = { }
		items_textures_data[ i ].tex = uiCreateTextureRolling and uiCreateTextureRolling( item.id, item.params ) or dxCreateTexture( item.texture_path );
		items_textures_data[ i ].x, items_textures_data[ i ].y = dxGetMaterialSize( items_textures_data[ i ].tex )
		if not items_textures_data[ i ].x then
			items_textures_data[ i ].x, items_textures_data[ i ].y = 0, 0
		end
	end

	return items_textures_data
end

function GenerateRollingListItems( case_index, item_index, inc_chances )
	local items = CACHE_CASES[ case_index ].items

	inc_chances = 2 - math.sin( ( items[ 1 ].fake_chance or items[ 1 ].chance ) * 10 ) * 0.5

	local rare_item_indexes = { }
	
	local total_chance_sum = 0
	for i, item in pairs( items ) do
		item.chance = item.fake_chance or item.chance
		total_chance_sum = total_chance_sum + item.chance * ( item.rare >= 2 and inc_chances ^ ( item.rare - 1 ) or 1 )
		if item.rare >= 4 then
			table.insert( rare_item_indexes, i )
		end
	end

	if total_chance_sum <= 0 then return end

	local list_index_items = { }
	local counter = 1
	while counter <= CONST_ITEMS_ROLLING_COUNT do
		local dot = math.random( ) * total_chance_sum
		local current_sum = 0

		for i, item in pairs( items ) do
			local item_chance = item.chance * ( item.rare >= 2 and inc_chances ^ ( item.rare - 1 ) or 1 )

			if current_sum <= dot and dot < ( current_sum + item_chance ) then
				if i ~= list_index_items[ counter - 1 ] or i ~= list_index_items[ counter - 2 ] then
					table.insert( list_index_items, i )
					counter = counter + 1
					break
				end
			end

			current_sum = current_sum + item_chance
		end
	end

	local stop_pos = CONST_ITEMS_ROLLING_COUNT - _count_blocks / 2
	list_index_items[ stop_pos ] = item_index
	list_index_items[ math.random( stop_pos - 4 ) ] = 1
	if math.random( ) > 0.5 then
		list_index_items[ stop_pos - 1 ] = rare_item_indexes[ math.random( #rare_item_indexes ) ]
	end
	if math.random( ) > 0.5 then
		list_index_items[ stop_pos + 1 ] = rare_item_indexes[ math.random( #rare_item_indexes ) ]
	end

	return list_index_items
end

function CleanUpCaseRolling( )
	removeEventHandler( "onClientRender", root, RenderCaseRolling )
	removeEventHandler( "onClientKey", root, onClientKey_handler )

	if roll_data then
		for _, data in pairs( roll_data.items_textures_data ) do
			if isElement( data.tex ) then
				destroyElement( data.tex )
			end
		end
	end

	roll_data = nil

	if isElement( UI_elements.bg_roll ) then
		destroyElement( UI_elements.bg_roll )
	end
end

function onClientKey_handler( )
	cancelEvent( )
end

local roll_sound_timeout = 0

function RenderCaseRolling( )
	if not roll_data then
		CleanUpCaseRolling( )
		return
	end

	local items = CACHE_CASES[ roll_data.case_index ].items
	local pos_x = _pos_x
	local pos_y = _pos_y

	if roll_data.current_index then
		dxDrawRectangle( 0, 0, screen_size_x, screen_size_y, ibApplyAlpha( 0xF2394a5c, UI_elements.bg_roll:ibData( "alpha" ) / 255 * 100 ), true )
		dxDrawImage( roll_bg_x, roll_bg_y, 1174, 692, "img/cases/roll_bg.png", 0, 0, 0, ibApplyAlpha( COLOR_WHITE, UI_elements.bg_roll:ibData( "alpha" ) / 255 * 100 ), true )

		local current_index = math.floor( roll_data.current_index )

		if tmp_curr_index ~= current_index then
			tmp_curr_index = current_index
			
			if roll_sound_timeout < getTickCount( ) then
				playSound( "sfx/roll.wav" ).volume = 0.1
				roll_sound_timeout = getTickCount( ) + 50
			end
		end

		pos_x = pos_x - ( block_sx + block_gap ) * ( roll_data.current_index - current_index - 0.5 )
		for i = current_index - ( _count_blocks / 2 ), current_index + ( _count_blocks / 2 ) do
			local item = items[ roll_data.list_index_items[ i ] ]
			local item_texture_data = roll_data.items_textures_data[ roll_data.list_index_items[ i ] ]
			if item_texture_data then
				local alpha = ( i == current_index and 255 or 128 )
				local white_color = ibApplyAlpha( tocolor( 255, 255, 255, alpha ), UI_elements.bg_roll:ibData( "alpha" ) / 255 * 100 )

				dxDrawImage( pos_x, pos_y, block_sx, block_sy, "img/cases/item_big_bg.png", 0, 0, 0, white_color, true )
				REGISTERED_ITEMS[ item.id ].uiDrawItemInRolling( pos_x + block_sx * 0.5, pos_y + block_sy * 0.5, item_texture_data.tex, item_texture_data.x, item_texture_data.y, alpha, item.id, item.params, fonts )
				dxDrawImage( pos_x + ( block_sx - 190 ) * 0.5, pos_y - 10, 190, 38, "img/cases/rare_big.png", 0, 0, 0, ( CONST_RARE_COLORS[ item.rare ] - tocolor( 0, 0, 0, 255 - alpha ) ), true )
			end

			pos_x = pos_x + ( block_sx + block_gap )
		end

		dxDrawImage( math.floor( ( screen_size_x - 102 ) / 2 ), math.floor( screen_size_y / 2 ) - 356 * 0.5 - 7, 102, 356, "img/cases/roll_line.png", 0, 0, 0, white_color, true )

		local progress = ( getTickCount( ) - roll_data.start_tick ) / CONST_ROLLING_TIMES
		if progress < 1 then
			roll_data.current_index = _start_index + getEasingValue( progress, "InOutQuad" ) * ( CONST_ITEMS_ROLLING_COUNT - _count_blocks - 1 - 0.5 + roll_data.reward_item_index_scroll)
		else
			if ( getTickCount( ) - roll_data.start_tick - CONST_ROLLING_TIMES ) >= CONST_ROLLING_CLOSE_TIMES then
				ShowCasesReward( roll_data.reward_item )
				CleanUpCaseRolling( )
			end
		end
	end
end

function UpdateCasesWindow( )
	if type( WINDOW_TYPE ) == "table" and WINDOW_TYPE[ 1 ] == WINDOW_TYPE_CASE_INFO then
		ShowUICase( WINDOW_TYPE[ 2 ] )
		UI_elements.bg:center( )
	end

	if type( refreshFunction ) == "function" and IsDonateOpen( ) then
		refreshFunction( )
	end
end

----------------------------
-- START: СКИДКИ НА КЕЙСЫ
local DISCOUNTS

function GetDiscountForCase( case_id )
	return DISCOUNTS and DISCOUNTS.array and DISCOUNTS.array[ case_id ]
end

function HasDiscounts( )
	return DISCOUNTS and next( DISCOUNTS ) ~= nil and DISCOUNTS
end

function GetDiscountFinishTime( )
	return DISCOUNTS and DISCOUNTS.finish_time and DISCOUNTS.finish_time
end

function onCasesDiscountsSync_handler( discounts, finish_time, is_join )
	DISCOUNTS = discounts or { }
	DISCOUNTS.finish_time = finish_time

	UpdateCasesWindow( )
	
	--[[if is_join and HasDiscounts( ) then
		triggerEvent( "onCasesDiscountShowInformation", resourceRoot )
	end]]
end
addEvent( "onCasesDiscountsSync", true )
addEventHandler( "onCasesDiscountsSync", root, onCasesDiscountsSync_handler )

function onUpdateCasesCacheGlobalCount_handler( case_id, new_count )
	for i, info in pairs( CACHE_CASES ) do
		if info.id == case_id then
			info.count = new_count
			break
		end
	end
end
addEvent( "onUpdateCasesCacheGlobalCount", true )
addEventHandler( "onUpdateCasesCacheGlobalCount", root, onUpdateCasesCacheGlobalCount_handler )

function onClientGetCasesInfo_handler( cases_info )
	UpdateCasesInfo( cases_info, { success = true, statusCode = 200 } )
end
addEvent( "onClientGetCasesInfo", true )
addEventHandler( "onClientGetCasesInfo", root, onClientGetCasesInfo_handler )

--[[function onCasesDiscountsFinish_handler( )
	onCasesDiscountsSync_handler(  nil )
end
addEvent( "onCasesDiscountsFinish", true )
addEventHandler( "onCasesDiscountsFinish", root, onCasesDiscountsFinish_handler )]]

-- END: СКИДКИ НА КЕЙСЫ
--------------------------]]