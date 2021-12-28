loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )

ibUseRealFonts( true )

local UIe = { }

function onPlayerShowSpecialOfferForWhales_handler( )
    DestroySpecialOfferForWhales( )
    showCursor( true )

    UIe.black_bg = ibCreateBackground( _, _, true )
    UIe.bg = ibCreateImage( 0, 0, 1024, 720, "images/offer_bg.png", UIe.black_bg ):center( )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

    ibCreateButton( 972, 29, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            DestroySpecialOfferForWhales( )
        end, false )

    do
        local timestamp = getRealTimestamp( )
        local end_time = localPlayer:getData( "offer_for_whales" )
        local time = end_time - timestamp

        local hours = math.floor( time / 60 / 60 )
        local minutes = math.floor( time / 60 ) - hours * 60
        local seconds = time - minutes * 60 - hours * 60 * 60

        hours = math.min( hours, 99 )

        local hours_str = hours < 10 and ( "0".. hours ) or hours
        local minutes_str = minutes < 10 and ( "0".. minutes ) or minutes
        local seconds_str = seconds < 10 and ( "0".. seconds ) or seconds

        UIe.timer_hours_h_lbl   = ibCreateLabel( 633    - 3, 127, 0, 0, utf8.sub( hours_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
        UIe.timer_hours_l_lbl   = ibCreateLabel( 613+47 - 3, 127, 0, 0, utf8.sub( hours_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
        UIe.timer_minutes_h_lbl = ibCreateLabel( 660+47 - 3, 127, 0, 0, utf8.sub( minutes_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
        UIe.timer_minutes_l_lbl = ibCreateLabel( 687+47 - 3, 127, 0, 0, utf8.sub( minutes_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
        UIe.timer_seconds_h_lbl = ibCreateLabel( 732+47 - 3, 127, 0, 0, utf8.sub( seconds_str, 1, 1 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )
        UIe.timer_seconds_l_lbl = ibCreateLabel( 760+47 - 3, 127, 0, 0, utf8.sub( seconds_str, 2, 2 ), UIe.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_36 )

        UIe.timer_hours_h_lbl:ibTimer( function( )
            local timestamp = getRealTimestamp( )
            if end_time <= timestamp then return end

            local time = end_time - timestamp

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

    ibCreateButton( 435, UIe.bg:height( ) - 30 - 40, 154, 40, UIe.bg, "images/btn_detail.png", "images/btn_detail_h.png", "images/btn_detail_h.png", _, _, 0xFFcccccc )
        :ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			
			triggerServerEvent( "onPlayerWantShowWhalesOfferDetailed", resourceRoot )
            ibClick( )
        end, false )
end
addEvent( "onPlayerShowSpecialOfferForWhales", true )
addEventHandler( "onPlayerShowSpecialOfferForWhales", root, onPlayerShowSpecialOfferForWhales_handler )

addEvent( "onPlayerShowWhalesOfferDetailed", true )
addEventHandler( "onPlayerShowWhalesOfferDetailed", resourceRoot, function( offer_data )
	DestroySpecialOfferForWhales( )
	ShowOfferGoodsForWhalesUI( true, offer_data )
end )

function DestroySpecialOfferForWhales( )
    for k, v in pairs( UIe ) do
        if isElement( v ) then destroyElement( v ) end
    end
    showCursor( false )
end