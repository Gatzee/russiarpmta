loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UIe = { }

function onClientCasesSaleEnding_handler( case_names, finish_time )
	if isElement( UIe.black_bg ) then return end

	showCursor( true )

	UIe.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	UIe.bg = ibCreateImage( 0, 0, 1024, 768, "images/bg.png", UIe.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	ibCreateButton(	972, 29, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
		end, false )

	UIe.timer_hours_h_lbl   = ibCreateLabel( 591, 127, 0, 0, 0, UIe.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_36 )
	UIe.timer_hours_l_lbl   = ibCreateLabel( 618, 127, 0, 0, 0, UIe.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_36 )
	UIe.timer_minutes_h_lbl = ibCreateLabel( 665, 127, 0, 0, 0, UIe.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_36 )
	UIe.timer_minutes_l_lbl = ibCreateLabel( 692, 127, 0, 0, 0, UIe.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_36 )
	UIe.timer_seconds_h_lbl = ibCreateLabel( 737, 127, 0, 0, 0, UIe.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_36 )
	UIe.timer_seconds_l_lbl = ibCreateLabel( 765, 127, 0, 0, 0, UIe.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_36 )

	function UpdateTimerLabels( )
		local timestamp = getRealTimestamp( )
		local time = finish_time - timestamp
		if time <= 0 then time = 0 end

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
	end
	UpdateTimerLabels( )
	UIe.timer_hours_h_lbl:ibTimer( UpdateTimerLabels, 500, 0 )

	for i, case_name in pairs( case_names ) do
		local py = 542 + ( i - 1 ) * ( 40 - #case_names )
		ibCreateImage( 0, py, 608, 30, "images/bg_case_name.png", UIe.bg )
			:center_x( )
		ibCreateLabel( 0, py + 2, 0, 0, case_name, UIe.bg, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_18 )
			:center_x( )
	end

	ibCreateButton(	435, 698, 154, 40, UIe.bg, "images/btn_details.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases", "cases_sale_ending" )
		end, false )
end
addEvent( "onClientCasesSaleEnding", true )
addEventHandler( "onClientCasesSaleEnding", resourceRoot, onClientCasesSaleEnding_handler )