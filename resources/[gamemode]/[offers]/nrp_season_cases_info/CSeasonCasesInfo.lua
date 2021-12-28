loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )

ibUseRealFonts( true )

local UI = { }

function onClientSeasonCasesInfo_handler( )
	if isElement( UI.black_bg ) then return end

	showCursor( true )

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	UI.bg = ibCreateImage( 0, 0, 1024, 768, ":nrp_battle_pass/img/login_window/bg.png", UI.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	ibCreateLabel( 0, 26, 1024, 0, "У вас есть сезонные кейсы!", UI.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
	ibCreateLabel( 0, 53, 1024, 0, "Не забудь открыть и получить ценную награду!", UI.bg, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "center", "center", ibFonts.bold_14 )

	ibCreateButton(	972, 29, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
		end, false )

	ibCreateButton(	435, 698, 154, 40, UI.bg, "images/btn_details.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases", "season_cases_info" )
		end, false )
end
addEvent( "onClientSeasonCasesInfo", true )
addEventHandler( "onClientSeasonCasesInfo", root, onClientSeasonCasesInfo_handler )