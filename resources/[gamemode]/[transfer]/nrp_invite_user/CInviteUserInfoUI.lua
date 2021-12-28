loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

function ShowInviteUserInfo()
	if isElement( UI.black_bg ) then return end

	showCursor( true )

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	ibCreateButton(	972, 29, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
		end, false )

	ibCreateButton(	413, 637, 198, 66, UI.bg, "img/btn_invite.png", _, _, 0xDAFFFFFF, _, 0xFFCCCCCC )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )

			destroyElement( UI.black_bg )
			triggerEvent( "ShowPhoneUI", localPlayer, true )
		end, false )
end
addEvent( "ShowInviteUserInfo", true )
addEventHandler( "ShowInviteUserInfo", resourceRoot, ShowInviteUserInfo )