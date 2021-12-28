loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local srx, sry = guiGetScreenSize( )
local UIe = { }

function CreateBusinessesOffer( list )
	if isElement( UIe.black_bg ) then return end

	local businesses_offer = localPlayer:getData( "businesses_offer" )
	if not businesses_offer then return end

	local timestamp = getRealTimestamp( )
	if businesses_offer.end_timestamp <= timestamp then return end

	showCursor( true )

	UIe.black_bg = ibCreateBackground( nil, DestroyBusinessesOffer, true, true )
	UIe.bg = ibCreateImage( 0, 0, 1024, 768, "images/bg.png", UIe.black_bg ):center( )

	ibCreateButton(	972, 29, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			DestroyBusinessesOffer( )
		end, false )

	do
		local time = businesses_offer.end_timestamp - timestamp

		local hours = math.floor( time / 60 / 60 )
		local minutes = math.floor( time / 60 ) - hours * 60
		local seconds = time - minutes * 60 - hours * 60 * 60

		local hours_str = hours < 10 and ( "0".. hours ) or hours
		local minutes_str = minutes < 10 and ( "0".. minutes ) or minutes
		local seconds_str = seconds < 10 and ( "0".. seconds ) or seconds

		UIe.timer_hours_h_lbl = ibCreateLabel( 586, 130, 0, 0, utf8.sub( hours_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_hours_l_lbl = ibCreateLabel( 613, 130, 0, 0, utf8.sub( hours_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_minutes_h_lbl = ibCreateLabel( 660, 130, 0, 0, utf8.sub( minutes_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_minutes_l_lbl = ibCreateLabel( 687, 130, 0, 0, utf8.sub( minutes_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_seconds_h_lbl = ibCreateLabel( 732, 130, 0, 0, utf8.sub( seconds_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_seconds_l_lbl = ibCreateLabel( 760, 130, 0, 0, utf8.sub( seconds_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )

		UIe.timer_hours_h_lbl:ibTimer( function( )
			local businesses_offer = localPlayer:getData( "businesses_offer" )
			if not businesses_offer then return end

			local timestamp = getRealTimestamp( )
			if businesses_offer.end_timestamp <= timestamp then return end

			local time = businesses_offer.end_timestamp - timestamp

			local hours = math.floor( time / 60 / 60 )
			local minutes = math.floor( time / 60 ) - hours * 60
			local seconds = time - minutes * 60 - hours * 60 * 60

			local hours_str = hours < 10 and ( "0".. hours ) or hours
			local minutes_str = minutes < 10 and ( "0".. minutes ) or minutes
			local seconds_str = seconds < 10 and ( "0".. seconds ) or seconds

			UIe.timer_hours_h_lbl:ibData( "text", utf8.sub( hours_str, 1, 1 ) )
			UIe.timer_hours_l_lbl:ibData( "text", utf8.sub( hours_str, 2, 2 ) )
			UIe.timer_minutes_h_lbl:ibData( "text", utf8.sub( minutes_str, 1, 1 ) )
			UIe.timer_minutes_l_lbl:ibData( "text", utf8.sub( minutes_str, 2, 2 ) )
			UIe.timer_seconds_h_lbl:ibData( "text", utf8.sub( seconds_str, 1, 1 ) )
			UIe.timer_seconds_l_lbl:ibData( "text", utf8.sub( seconds_str, 2, 2 ) )
		end, 250, 0 )
	end

	do
		UIe.loading_bg = ibCreateArea( 0, 181, 1024, 587, UIe.bg )
		UIe.loading = ibLoading( { parent = UIe.loading_bg } )
	end

	if list then
		OnBusinessesOfferSetList_handler( list )
	else
		triggerServerEvent( "RequestBusinessesOfferList", resourceRoot )
	end
end
addEvent( "ShowBusinessesOffer", true )
addEventHandler( "ShowBusinessesOffer", resourceRoot, CreateBusinessesOffer )

function DestroyBusinessesOffer( )
	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end

	showCursor( false )
end

function OnBusinessesOfferSetList_handler( list )
	if not isElement( UIe.black_bg ) then return end

	if isElement( UIe.loading_bg ) then
		destroyElement( UIe.loading_bg )
	end

	UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 0, 181, 1024, 587, UIe.bg, { scroll_px = -20, bg_color = 0x00FFFFFF } )
	UIe.scroll_bar:ibData( "sensivity", 0.1 )

	local i = 0
	for category, info in pairs( list ) do
		local bg = ibCreateArea( ( i % 2 ) * 512, math.floor( i / 2 ) * 294, 511, 293, UIe.scroll_pane )

		if i % 2 == 0 then
			ibCreateImage( 511, 0, 1, 293, _, bg, ibApplyAlpha( COLOR_WHITE, 25 ) )
		end
		ibCreateImage( 0, 293, 512, 1, _, bg, ibApplyAlpha( COLOR_WHITE, 25 ) )

		ibCreateImage( 0, 0, 511, 213, _, bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		ibCreateImage( 0, 213, 511, 80, _, bg, ibApplyAlpha( COLOR_BLACK, 5 ) )

		do
			ibCreateLabel( 203, 70, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_24 )

			ibCreateLabel( 203, 110, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_16 )
			local lbl_old_cost = ibCreateLabel( 346, 110, 0, 0, format_price( info.cost ), bg, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
			local icon_old_cost = ibCreateImage( lbl_old_cost:ibGetAfterX( 10 ), 100, 19, 19, ":nrp_shared/img/money_icon.png", bg )
			ibCreateImage( 345, 110, icon_old_cost:ibGetAfterX( ) - 345, 1, _, bg, COLOR_WHITE )

			ibCreateLabel( 203, 140, 0, 0, "Цена:", bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_18 )
			local lbl_new_cost = ibCreateLabel( 263, 140, 0, 0, format_price( math.floor( info.cost * 0.75 ) ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_22 )
			ibCreateImage( lbl_new_cost:ibGetAfterX( 10 ), 125, 28, 28, ":nrp_shared/img/money_icon.png", bg )
		end

		if info.list then
			local img_cat = category

			do
				local img_bg = ibCreateArea( 107, 106, 0, 0, bg )
				if img_cat and not fileExists( ":nrp_businesses/img/icons/128x128/".. img_cat ..".png" ) then
					img_cat = split( img_cat, "_" )[ 1 ]
				end

				ibCreateImage( 0, 0, 0, 0, ":nrp_businesses/img/icons/128x128/".. img_cat ..".png", img_bg ):ibSetRealSize( ):center( )
			end

			ibCreateButton(	111, 240, 290, 30, bg, "images/btn_more", true )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					if isElement( UIe.category_list_bg ) then
						destroyElement( UIe.category_list_bg )
					end

					UIe.scroll_pane:ibData( "disabled", true )

					UIe.category_list_bg = ibCreateImage( 0, 80, 1024, 688, _, UIe.bg, ibApplyAlpha( 0xff1f2934, 95 ) )
					local bg = UIe.category_list_bg

					do
						local img_bg = ibCreateArea( 368, 83, 0, 0, bg )
						ibCreateImage( 0, 0, 0, 0, ":nrp_businesses/img/icons/128x128/".. img_cat ..".png", img_bg ):ibSetRealSize( ):center( )
					end

					do
						ibCreateLabel( 463, 48, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_24 )

						ibCreateLabel( 465, 87, 0, 0, "Цена без скидки:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_16 )
						local lbl_old_cost = ibCreateLabel( 607, 87, 0, 0, format_price( info.cost ), bg, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
						local icon_old_cost = ibCreateImage( lbl_old_cost:ibGetAfterX( 10 ), 77, 19, 19, ":nrp_shared/img/money_icon.png", bg )
						ibCreateImage( 607, 87, icon_old_cost:ibGetAfterX( ) - 607, 1, _, bg, COLOR_WHITE )

						ibCreateLabel( 465, 117, 0, 0, "Цена:", bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_18 )
						local lbl_new_cost = ibCreateLabel( 524, 117, 0, 0, format_price( math.floor( info.cost * 0.75 ) ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_22 )
						ibCreateImage( lbl_new_cost:ibGetAfterX( 10 ), 103, 28, 28, ":nrp_shared/img/money_icon.png", bg )
					end

					local scroll_pane, scroll_bar = ibCreateScrollpane( 0, 167, 1024, 521, bg, { scroll_px = -20, bg_color = 0x00FFFFFF } )
					scroll_bar:ibData( "sensivity", 0.1 )

					do
						local bg = scroll_pane
						local i = 0
						for id, gps_position in pairs( info.list ) do
							local bg = ibCreateImage( 0, 80 * i, 1024, 80, _, bg, ibApplyAlpha( 0xff314050, i % 2 == 0 and 75 or 0 ) )
							ibCreateLabel( 30, 40, 0, 0, info.name .." #".. id, bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_20 )

							ibCreateButton(	616, 18, 248, 44, bg, "images/btn_gps", true )
								:ibOnClick( function( key, state )
									if key ~= "left" or state ~= "up" then return end
									ibClick( )

									if localPlayer.dimension > 0 then
										localPlayer:ShowError( "Здесь навигация недоступна" )
										return
									end
									triggerEvent( "ToggleGPS", localPlayer, gps_position )
									triggerEvent( "ShowRadarMap", root )
								end, false )

							ibCreateButton(	884, 18, 110, 44, bg, "images/btn_buy", true )
								:ibOnClick( function( key, state )
									if key ~= "left" or state ~= "up" then return end
									ibClick( )

									ibConfirm( {
										title = "ПОКУПКА БИЗНЕСА", 
										text = "Ты действительно хочешь купить\n".. info.name .." #".. id .." за ".. format_price( math.floor( info.cost * 0.75 ) ) .." р.?" ,
										fn = function( self )
											triggerServerEvent( "OnPlayerWantBuyBusinesses", resourceRoot, info.ignore_id and id == 1 and category or category .."_".. id )
											self:destroy( )
										end,
										escape_close = true,
									} )
								end, false )

							i = i + 1
						end

						ibCreateArea( 0, 80 * i, 1024, 80, bg )
					end

					scroll_pane:AdaptHeightToContents( )
					scroll_bar:UpdateScrollbarVisibility( scroll_pane )

					ibCreateImage( 0, 441, 1024, 247, "images/category_list_gradient.png", bg ):ibData( "disabled", true )


					ibCreateButton(	457, 614, 110, 44, bg, "images/btn_hide", true )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )

						if isElement( UIe.category_list_bg ) then
							destroyElement( UIe.category_list_bg )
							UIe.scroll_pane:ibData( "disabled", false )
						end
					end, false )
				end, false )
		else
			do
				local img_bg = ibCreateArea( 107, 106, 0, 0, bg )
				local image = info.icon and split( category, "_" )[ 1 ] or string.gsub( category, "_%d+$", "" )
				ibCreateImage( 0, 0, 0, 0, ":nrp_businesses/img/icons/128x128/".. image ..".png", img_bg ):ibSetRealSize( ):center( )
			end

			ibCreateButton(	30, 232, 248, 44, bg, "images/btn_gps", true )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					if localPlayer.dimension > 0 then
						localPlayer:ShowError( "Здесь навигация недоступна" )
						return
					end
					triggerEvent( "ToggleGPS", localPlayer, info.gps_position )
					triggerEvent( "ShowRadarMap", root )
				end, false )

			ibCreateButton(	372, 232, 110, 44, bg, "images/btn_buy", true )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					ibConfirm( {
						title = "ПОКУПКА БИЗНЕСА", 
						text = "Ты действительно хочешь купить\n".. info.name .." за ".. format_price( math.floor( info.cost * 0.75 ) ) .." р.?" ,
						fn = function( self )
							triggerServerEvent( "OnPlayerWantBuyBusinesses", resourceRoot, category )
							self:destroy( )
						end,
						escape_close = true,
					} )
				end, false )
		end

		i = i + 1
	end

	UIe.scroll_pane:AdaptHeightToContents( )
	UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
end
addEvent( "OnBusinessesOfferSetList", true )
addEventHandler( "OnBusinessesOfferSetList", resourceRoot, OnBusinessesOfferSetList_handler )