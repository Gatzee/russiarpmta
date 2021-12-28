loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "ShClothesShops" )

ibUseRealFonts( true )

local UI = { }

function ShowFirstCaseGift( )
	if IS_UI_SHOWN then return end
	if isElement( UI.black_bg ) then return end
	
	local cases = localPlayer:GetCases( )
	if ( cases.gold_a or 0 ) <= 0 and ( cases.gold_b or 0 ) <= 0 then return end

	showCursor( true )

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
		:ibData( "priority", -1 )
	UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg_gift.png", UI.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	ibCreateButton(	0, UI.bg:ibData( "sy" ) - 30 - 40, 154, 40, UI.bg, 
			_, "img/btn_details_h.png", "img/btn_details_h.png", 0, 0xFFFFFFFF, 0xFFCCCCCC )
		:center_x( )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases", "first_case_gift" )
		end, false )
	
	IS_UI_SHOWN = true
end

function ShowFirstCaseGiftUI_handler( )
	addEvent( "onClientUILevelUpClose" )
	addEventHandler( "onClientUILevelUpClose", root, function( new_level )
		Timer( ShowFirstCaseGift, 1000, 1 )
	end )
	
	-- На случай, если левелап не сработал
	Timer( ShowFirstCaseGift, 5000, 1 )
end
addEvent( "ShowFirstCaseGift", true )
addEventHandler( "ShowFirstCaseGift", root, ShowFirstCaseGift )



-- Окно инфы о магазине одежды

function ShowFirstCaseSkinInfo( )
	if isElement( UI.black_bg ) then return end

	showCursor( true )

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg_clothes_info.png", UI.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	ibCreateButton(	972, 29, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
		end, false )

	ibCreateButton(	0, UI.bg:ibData( "sy" ) - 30 - 44, 248, 44, UI.bg, 
			_, "img/btn_show_on_map_h.png", "img/btn_show_on_map_h.png", 0, 0xFFFFFFFF, 0xFFCCCCCC )
		:center_x( )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
			triggerEvent( "ToggleGPS", localPlayer, CLOTHES_SHOPS_LIST, true )
		end, false )
end
addEvent( "ShowFirstCaseSkinInfo", true )
addEventHandler( "ShowFirstCaseSkinInfo", resourceRoot, ShowFirstCaseSkinInfo )