loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

function ShowCasesPackOffer_handler( offer_data )
	if offer_data then
		localPlayer:setData( "cases_pack_offer", offer_data, false )
	else
		offer_data = localPlayer:getData( "cases_pack_offer" )
		if not offer_data then return end
	end

	if isElement( UI.black_bg ) then return end

	showCursor( true )

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/" .. offer_data.pack_id .. ".png", UI.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	ibCreateButton(	972, 29, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
		end, false )
	
	UI.area_timer = ibCreateArea( 0, 44, 0, 0, UI.bg )
	ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
	UI.lbl_text = ibCreateLabel( 36, 0, 0, 0, "До конца акции: ", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	UI.lbl_timer = ibCreateLabel( UI.lbl_text:ibGetAfterX( ), 0, 0, 0, getHumanTimeString( offer_data.finish_ts ) or "0 с", UI.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
		:ibTimer( function( self )
			self:ibData( "text", getHumanTimeString( offer_data.finish_ts ) or "0 с" )
			UI.area_timer:ibData( "px", UI.bg:width( ) - 30 - 24 - 30 - UI.lbl_timer:ibGetAfterX( ) )
		end, 1000, 0 )
	UI.area_timer:ibData( "px", UI.bg:width( ) - 30 - 24 - 30 - UI.lbl_timer:ibGetAfterX( ) )

	ibCreateButton(	442, 644, 140, 46, UI.bg, "img/btn_buy", true )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )

			ibConfirm( {
				title = "ПОДТВЕРЖДЕНИЕ", 
				text = "Ты хочешь купить этот пак кейсов за",
				cost = offer_data.cost,
				cost_is_soft = false,
				fn = function( self ) 
					self:destroy()
					destroyElement( UI.black_bg )
					triggerServerEvent( "onPlayerWantBuyCasesPack", resourceRoot, offer_data.pack_id )
				end,
				escape_close = true,
			} )
		end, false )
end
addEvent( "ShowCasesPackOffer", true )
addEventHandler( "ShowCasesPackOffer", root, ShowCasesPackOffer_handler )