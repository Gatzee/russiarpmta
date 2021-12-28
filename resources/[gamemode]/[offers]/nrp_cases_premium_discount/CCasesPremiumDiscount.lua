loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

function ShowCasesPremuimDiscount_handler( offer_data )
	if offer_data then
		localPlayer:setData( "cases_premium_discount", offer_data, false )
	else
		offer_data = localPlayer:getData( "cases_premium_discount" )
		if not offer_data then return end
	end

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
	
	UI.area_timer = ibCreateArea( 0, 134, 0, 0, UI.bg )
	ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
	UI.lbl_text = ibCreateLabel( 36, 0, 0, 0, "До конца акции: ", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	UI.lbl_timer = ibCreateLabel( UI.lbl_text:ibGetAfterX( ), 0, 0, 0, getHumanTimeString( offer_data.finish_ts ) or "0 с", UI.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
		:ibTimer( function( self )
			self:ibData( "text", getHumanTimeString( offer_data.finish_ts ) or "0 с" )
			UI.area_timer:ibData( "sx", UI.lbl_timer:ibGetAfterX( ) ):center_x( )
		end, 1000, 0 )
	UI.area_timer:ibData( "sx", UI.lbl_timer:ibGetAfterX( ) ):center_x( )

	local case_id, case = next( offer_data.array )
	ibCreateContentImage( 88, 262, 360, 280, "case", case_id, UI.bg )
	ibCreateLabel( 268, 205, 0, 0, case.name, UI.bg, _, _, _, "center", "center", ibFonts.bold_18 )
	ibCreateLabel( 268, 273, 0, 0, "СКИДКА " .. case.discount .. "%", UI.bg, _, _, _, "center", "center", ibFonts.bold_14 )
	local lbl_cost_original = ibCreateLabel( 333, 525, 0, 0, case.cost_original, UI.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_20 )
	ibCreateLine( 300, 525, lbl_cost_original:ibGetAfterX( ) + 4, _, _, 1, UI.bg )
	ibCreateLabel( 288, 561, 0, 0, case.cost, UI.bg, _, _, _, "left", "center", ibFonts.bold_22 )

	local case_id, case = next( offer_data.array, case_id )
	ibCreateContentImage( 577, 262, 360, 280, "case", case_id, UI.bg )
	ibCreateLabel( 757, 205, 0, 0, case.name, UI.bg, _, _, _, "center", "center", ibFonts.bold_18 )
	ibCreateLabel( 757, 273, 0, 0, "СКИДКА " .. case.discount .. "%", UI.bg, _, _, _, "center", "center", ibFonts.bold_14 )
	local lbl_cost_original = ibCreateLabel( 822, 525, 0, 0, case.cost_original, UI.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.bold_20 )
	ibCreateLine( 789, 525, lbl_cost_original:ibGetAfterX( ) + 4, _, _, 1, UI.bg )
	ibCreateLabel( 777, 561, 0, 0, case.cost, UI.bg, _, _, _, "left", "center", ibFonts.bold_22 )

	ibCreateButton(	427, 634, 170, 56, UI.bg, "img/btn_details", true )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )

			destroyElement( UI.black_bg )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases", "premium_discount_case" )
		end, false )
end
addEvent( "ShowCasesPremuimDiscount", true )
addEventHandler( "ShowCasesPremuimDiscount", root, ShowCasesPremuimDiscount_handler )

function onCasesDiscountsSync_handler( discounts, finish_time, is_join )
	if not discounts or not next( discounts ) then
		localPlayer:setData( "cases_premium_discount", nil, false )
		return
	end
	discounts.finish_ts = finish_time
	
	if is_join and discounts.id == "cases_premium_discount" then
		ShowCasesPremuimDiscount_handler( discounts )
		triggerServerEvent( "onPlayerGetCasesPremiumDiscount", resourceRoot )
	end
end
addEvent( "onCasesDiscountsSync", true )
addEventHandler( "onCasesDiscountsSync", root, onCasesDiscountsSync_handler )