local carsell_businesses = {
	["1"] = Vector3(-1011.702, -1475.423, 21.773),
	["2"] = Vector3(-362.323, -1741.648, 20.917),
	["3"] = Vector3(1782.086, -628.719, 60.852),
	["4"] = Vector3(2047.004, -806.692, 62.649),
	["5"] = Vector3(1227.8587, 2488.2177, 11.211),
	["8"] = Vector3(-252.068, -1901.595, 20.808),
}

local refreshFunction
OFFERS_SC_DATA = {}
TABS_CONF.offers = {
    fn_create = function( self, parent )
        refreshFunction = function( )
            DestroyTableElements( getElementChildren( parent ) )

            local scrollpane, scrollbar = ibCreateScrollpane( 30, 45, 740, 463, parent, { scroll_px = 10 } )
			scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 100 )	
			OFFERS_SC_DATA.rt = scrollpane
			OFFERS_SC_DATA.sc = scrollbar		
            
            local i = 0
            local npx, npy = 0, 20

            local function AddOffer( v )
                local item =
                        v.fn_create and v:fn_create( v )
                    or
                        DISCOUNTS_OFFERS[ v.class ] and DISCOUNTS_OFFERS[ v.class ].fn_create and DISCOUNTS_OFFERS[ v.class ]:fn_create( v )
                    
				if item then
					i = i + 1

					if i > 1 and i % 2 == 1 then
						npx = 0
						npy = npy + 280 + 20
					elseif i > 1 then
						npx = npx + 360 + 20
					end

                    item:setParent( scrollpane )
                    item:ibBatchData( { px = npx, py = npy } )
                end
			end
			
			for i, v in pairs( CONF.retention_tasks) do
				v.fn_create = CreateRetentionTask
				v.id = i
				AddOffer( v )
			end

            for n, v in pairs( OFFERS ) do
				v.data = localPlayer:getData( v.id )
                if v.active == true or type( v.active ) == "function" and v:active( ) then
                    AddOffer( v )
                end
            end

            local ts = getRealTimestamp( )

			for k,v in pairs( OFFERS_LIST ) do
				if v.type == "discounts" then
					local conditions = { }

					if v.finish_date then table.insert( conditions, v.finish_date >= ts ) end
					if v.start_date then table.insert( conditions, v.start_date <= ts ) end

					local result = DISCOUNTS_OFFERS[ v.class ]:fn_check( v )

					for i, v in pairs( conditions ) do result = result and v end

					if result then
						AddOffer( v )
					end
				end
			end

            scrollpane:AdaptHeightToContents( )
			scrollbar:UpdateScrollbarVisibility( scrollpane )
			
            scrollpane:ibData( "sy", scrollpane:ibData( "sy" ) + 20 )

            return i
        end

        local last_amount
        
        parent:ibTimer( function( )
            local now_result = 0
            for n, v in pairs( OFFERS ) do
                if v.active == true or type( v.active ) == "function" and v:active( ) then
                    now_result = now_result + 1
                end
            end
            if now_result ~= last_amount then
                last_amount = refreshFunction( )
            end
        end, 5 * 60 * 1000, 0 )

        last_amount = refreshFunction( )
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

DISCOUNTS_OFFERS = {
	vehicle_discount = {
		fn_check = function( self, params )
			return true
		end,
		fn_create = function(self, params)
			local sx, sy = 360, 280
			local bg = ibCreateImage( 0, 0, sx, sy, "img/special_offers/bg_section.png" )
			local hovered = ibCreateImage( 0, 0, sx, sy, "img/special_offers/bg_section_hovered.png", bg ):ibData("alpha", 0)

			hovered
				:ibOnHover( function() source:ibAlphaTo( 255, 500 ) end )
				:ibOnLeave( function() source:ibAlphaTo( 0, 500 ) end )
			
			-- image
			ibCreateContentImage( 30, 57, 300, 160, "vehicle", params.model, bg ):ibData( "disabled", true )

			-- if params.vehicle_lights then
			-- 	local lights = ibCreateImage( 0, 0, 0, 0, "img/special_offers/vehicles/vehicle"..params.model.."_lights.png", bg ):ibData( "priority", 1 )
			-- 		:ibSetRealSize():center( unpack( params.image_offset or { 0, -20 } ) ):ibData("disabled", true)
					
			-- 	lights:ibOnRender( function( )
			-- 		lights:ibData( "alpha", 150 + math.abs( math.sin( getTickCount( ) / 250 ) ) * hovered:ibData( "alpha" ) / 255 * 105 )
			-- 	end )
			-- end
			
			-- label name
			local name = params.name or GetVehicleNameFromModel( params.model, params.variant or 1 )
			ibCreateLabel( 0, 10, sx, sy/4, name, bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
				:ibData("disabled", true)

			if params.finish_date then
				local offset_y = 20
				if name then offset_y = 30 end
				local img = ibCreateImage( 20, offset_y, 22, 24, "img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "Предложение действует еще:", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( params.finish_date, true ) )
				end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )
			end

			if params.start_date then
				if getRealTimestamp() - params.start_date <= 3*24*60*60 then
					ibCreateImage( sx-23, 0, 23, 23, "img/icon_indicator_new.png", bg )
				end
			end

			-- cost
			if params.cost_original then
				local lbl_cost = ibCreateLabel( 20, sy - 50, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_14 )
				local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 58, 16, 16, "img/special_offers/icon_soft.png", bg )
				local lbl_amount = ibCreateLabel( icon_hard:ibGetAfterX() + 10, sy - 50, 0, 0, format_price( params.cost_original ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_16 )
				ibCreateLine( icon_hard:ibData( "px" ) - 2, lbl_amount:ibGetCenterY( ), lbl_amount:ibGetAfterX( 1 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, bg )
			end
			local oy = params.cost_original and 10 or 0
			local lbl_cost = ibCreateLabel( 20, sy - 35 + oy, 0, 0, "Цена:", bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_16 )
			local icon_hard = ibCreateImage( lbl_cost:width( ) + 30, sy - 45 + oy, 23, 20, "img/special_offers/icon_soft.png", bg )
			ibCreateLabel( icon_hard:ibGetAfterX( ) + 10, sy - 35 + oy, 0, 0, format_price( params.cost ), bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_18 )
			
			if params.start_date then
				if getRealTimestamp() - params.start_date <= 3*24*60*60 then
					ibCreateImage( sx-23, 0, 23, 23, "img/icon_indicator_new.png", bg )
				end
			end
			
			-- button
			local btn_img = "img/offers/btn_show_on_map_mini.png"
			ibCreateButton( sx - 20 - 50, 230, 0, 0, bg, btn_img, btn_img, btn_img, 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibSetRealSize( )
                :ibOnClick(function(key, state)
					if key ~= "left" or state ~= "up" then return end
					ibClick( )
					
					if params.show_on_map then
						ShowDonateUI( false )

						local market_id = VEHICLE_CONFIG[ params.model ].marketlist			
						triggerEvent( "ToggleGPS", localPlayer, carsell_businesses[ market_id ] )
						SendElasticGameEvent( "f4r_f4_promo_mark_on_map_click" )
					else
						ibConfirm(
							{
								title = "ПОКУПКА ТРАНСПОРТА", 
								text = "Ты хочешь купить "..VEHICLE_CONFIG[ params.model ].model.." за",
								cost = params.cost,
								cost_is_soft = false,
								fn = function( self )
									triggerServerEvent( "onPlayerPurchaseDiscountOfferRequest", resourceRoot, "vehicle_discount", params.model, params.segment )
									self:destroy()
								end,
								escape_close = true,
							}
						)
					end
				end)
				:ibOnHover(function()
					hovered:ibAlphaTo( 255, 500 )
				end)
				:ibOnLeave( function()
					hovered:ibAlphaTo( 0, 500 )
				end)


			return bg, sx, sy
		end,
    }
}

function CreateRetentionTask( self, params )
	if not getHumanTimeString( params.timestamp_end ) then return end
	
	local name = exports.nrp_retention_tasks:GetRetentionTaskValue( params.id, "name" )
	if not name then return end

	local area = ibCreateArea( 0, 0, 360, 280 )

	local bg = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers.png", area ):ibSetRealSize( )
	local bg_hover = ibCreateImage( 0, 0, 0, 0, "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
		:ibData( "disabled", true )
		:ibData( "alpha", 0 )
	
	bg
		:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
		:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )
		:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				triggerServerEvent( "ShowRetentionInterfaceRequest", localPlayer, params.id )
			end )

	-- Название
	ibCreateLabel( 0, 10, 360, 0, name, area, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
		:ibData( "disabled", true )

	-- Награда
	local reward = localPlayer:getData( "economy_hard_test" ) and exports.nrp_retention_tasks:GetRetentionTaskValue( params.id, "reward_economy_test" ) or exports.nrp_retention_tasks:GetRetentionTaskValue( params.id, "reward" )
	local reward_name = exports.nrp_retention_tasks:GetRetentionTaskValue( params.id, "reward_name" )
	local inner_area = ibCreateArea( 0, 242, 0, 0, area )
	local lbl = ibCreateLabel( 0, 0, 0, 0, "Награда:", inner_area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, _, _, ibFonts.regular_16 )

	if reward_name then
		local lbl_reward = ibCreateLabel( lbl:ibGetAfterX( 5 ), -1, 0, 0, reward_name, inner_area, COLOR_WHITE, _, _, _, _, ibFonts.bold_18 )
		inner_area:ibData( "sx", lbl_reward:ibGetAfterX( ) ):center_x( )
	else
		local lbl_reward = ibCreateLabel( lbl:ibGetAfterX( 5 ), -1, 0, 0, reward, inner_area, COLOR_WHITE, _, _, _, _, ibFonts.bold_18 )
		local icon_soft = ibCreateImage( lbl_reward:ibGetAfterX( 5 ) + 3, 0, 23, 20, "img/special_offers/icon_soft.png", inner_area )
		inner_area:ibData( "sx", icon_soft:ibGetAfterX( ) ):center_x( )
	end

	-- Описание
	local desc = exports.nrp_retention_tasks:GetRetentionTaskValue( params.id, "desc" )
	ibCreateLabel( 0, 215, 360, 0, desc, area, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_14 )
		:ibData( "disabled", true )

	-- Таймер
	local img = ibCreateImage( 60, 40, 22, 24, "img/icon_timer.png", area )
	local desc_label = ibCreateLabel( img:ibGetAfterX( 15 ), img:ibGetCenterY( ), 0, 0, "До конца акции: " .. getHumanTimeString( params.timestamp_end, false, false, false ), area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )    

	-- Изображение
	ibCreateImage( 0, 0, 0, 0, "img/offers/retention_tasks/" .. params.id .. ".png", area ):ibSetRealSize( ):ibData( "disabled", true ):center( )

	-- Магия
	area:ibBatchData( { sx = bg:width( ), sy = bg:height( ) } )
	return area
end

function CreateOfferItem( parent, conf, params )
	local area = ibCreateArea( 0, 0, 360, 280, parent )
	local bg = ibCreateImage( 0, 0, 360, 280, params.bg or "img/offers/bg_offers.png", area )
	local bg_hover = ibCreateImage( 0, 0, 0, 0, params.bg_hover or "img/offers/bg_offers_hover.png", area ):ibSetRealSize( )
		:ibData( "disabled", true )
		:ibData( "alpha", 0 )
		:ibData( "priority", -1)

	bg:ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
	bg:ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

	if params.img then
		ibCreateImage( params.img.px or 0, params.img.py or 0, 0, 0, params.img.url or params.img, area ):ibData( "disabled", true ):ibSetRealSize( )
	end

	if params.discount then
		ibCreateLabel( params.discount.px, params.discount.py or 24, 0, 0, params.discount.text, area, COLOR_WHITE, _, _, "center", "center", ibFonts.extrabold_12 )
	end

	if params.timer then
		local timer = type( params.timer ) == "table" and params.timer or { params.timer }
		local time_label = ibCreateLabel( timer.px or 234, timer.py or 44, 0, 0, "", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_14 )
		local function UpdateTime( )
			time_label:ibData( "text", getHumanTimeString( timer[ 1 ], true ) )
		end
		UpdateTime( )
		time_label:ibTimer( UpdateTime, 1000, 0 )
	end

	ibCreateImage( 105, 226, 0, 0, "img/offers/btn_details.png", area )
		:ibSetRealSize( )
		:ibData( "alpha", 200 )
		:ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) bg_hover:ibAlphaTo( 255, 200 ) end )
		:ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			if ( conf.fn_details and not conf.fn_details( conf ) ) or ( params.fn_details and not params.fn_details( conf ) ) then
				ShowDonateUI( false )
			end
		end )

	return area
end

function CreateOfferSlider( parent, conf, params )
	local bg = ibCreateImage( 0, 278, 741, 210, params.bg, parent )

	if params.discount then
		CreateSliderDiscount( params.discount .. "%", bg )
	end

	if params.timer then
		local timer = params.timer
		if timer.is_digital then
			CreateSliderTimer( timer[ 1 ], timer.px or 381, timer.py or 75, bg )
		else
			CreateHumanTimer( timer.px, timer.py, bg, timer.text or "", timer[ 1 ], timer.is_short, timer.no_icon )
		end
	end

	params.btn = params.btn or { }
	ibCreateImage( params.btn.px or 380, params.btn.py or 128, 0, 0, "img/sliders/btn_details.png", bg )
		:ibSetRealSize( )
		:ibData( "alpha", 200 )
		:ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
		:ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			if ( conf.fn_details and not conf.fn_details( conf ) ) or ( params.fn_details and not params.fn_details( conf ) ) then
				ShowDonateUI( false )
			end
		end )

	return bg
end