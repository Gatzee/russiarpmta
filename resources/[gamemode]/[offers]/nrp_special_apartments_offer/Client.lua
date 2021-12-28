loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UIe = { }

function CreateApartmentsOffer( )
	if isElement( UIe.black_bg ) then return end

	local apartments_offer = localPlayer:getData( "apartments_offer" )
	if not apartments_offer then return end

	local timestamp = getRealTimestamp( )
	if apartments_offer <= timestamp then return end

	showCursor( true )

	UIe.black_bg = ibCreateBackground( _, DestroyBusinessesOffer )
	UIe.bg = ibCreateImage( 0, 0, 1024, 768, "images/bg.png", UIe.black_bg ):center( )

	ibCreateButton(	972, 29, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			destroyElement( UIe.black_bg )
			ibClick( )
		end, false )

	do
		local time = apartments_offer - timestamp

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
			local apartments_offer = localPlayer:getData( "apartments_offer" )
			if not apartments_offer then return end

			local timestamp = getRealTimestamp( )
			if apartments_offer <= timestamp then return end

			local time = apartments_offer - timestamp

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
end
addEvent( "ShowApartmentsOffer", true )
addEventHandler( "ShowApartmentsOffer", resourceRoot, CreateApartmentsOffer )

function DestroyBusinessesOffer( )
	showCursor( false )
end

CreateApartmentsOffer( )