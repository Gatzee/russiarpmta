loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UIe = { }

function OnSpecialCases30LastDiscount_handler( list )
	if isElement( UIe.black_bg ) then return end

	local discounts = exports.nrp_shop:HasDiscounts( )
	if not discounts or discounts.id ~= "cases30_last_discount" then return end

	showCursor( true )

	UIe.black_bg = ibCreateBackground( _, DestroyBusinessesOffer )
	UIe.bg = ibCreateImage( 0, 0, 1024, 768, "images/bg.png", UIe.black_bg ):center( )

	ibCreateButton(	972, 29, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
		end, false )

	do
		local timestamp = getRealTimestamp( )
		local time = discounts.finish_time - timestamp

		local hours = math.floor( time / 60 / 60 )
		local minutes = math.floor( time / 60 ) - hours * 60
		local seconds = time - minutes * 60 - hours * 60 * 60

		hours = math.min( hours, 99 )

		local hours_str = hours < 10 and ( "0".. hours ) or hours
		local minutes_str = minutes < 10 and ( "0".. minutes ) or minutes
		local seconds_str = seconds < 10 and ( "0".. seconds ) or seconds

		UIe.timer_hours_h_lbl = ibCreateLabel( 586, 127, 0, 0, utf8.sub( hours_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_hours_l_lbl = ibCreateLabel( 613, 127, 0, 0, utf8.sub( hours_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_minutes_h_lbl = ibCreateLabel( 660, 127, 0, 0, utf8.sub( minutes_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_minutes_l_lbl = ibCreateLabel( 687, 127, 0, 0, utf8.sub( minutes_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_seconds_h_lbl = ibCreateLabel( 732, 127, 0, 0, utf8.sub( seconds_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
		UIe.timer_seconds_l_lbl = ibCreateLabel( 760, 127, 0, 0, utf8.sub( seconds_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )

		UIe.timer_hours_h_lbl:ibTimer( function( )
			local discounts = exports.nrp_shop:HasDiscounts( )
			if not discounts or discounts.id ~= "cases30_last_discount" then
				destroyElement( UIe.black_bg )
				return
			end

			local timestamp = getRealTimestamp( )
			if discounts.finish_time <= timestamp then return end

			local time = discounts.finish_time - timestamp

			local hours = math.floor( time / 60 / 60 )
			local minutes = math.floor( time / 60 ) - hours * 60
			local seconds = time - minutes * 60 - hours * 60 * 60

			hours = math.min( hours, 99 )

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

	ibCreateButton(	435, 698, 154, 40, UIe.bg, "images/btn_shop", true )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases", "special_cases30_last_discount" )
		end, false )
end
addEvent( "OnSpecialCases30LastDiscount", true )
addEventHandler( "OnSpecialCases30LastDiscount", resourceRoot, OnSpecialCases30LastDiscount_handler )

function DestroyBusinessesOffer( )
	showCursor( false )
end