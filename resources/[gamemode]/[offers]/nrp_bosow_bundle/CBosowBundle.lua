loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

function ShowBosowBundle_handler( offer_data )
	if offer_data then
		localPlayer:setData( "bosow_bundle", offer_data, false )
	else
		offer_data = localPlayer:getData( "bosow_bundle" )
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

	UI.area_timer = ibCreateArea( 0, 125, 0, 0, UI.bg )
	ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
	UI.lbl_timer = ibCreateLabel( 36, 0, 0, 0, "До конца предложения осталось: ", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	ibCreateLabel( UI.lbl_timer:ibGetAfterX( ), 0, 0, 0, getHumanTimeString( offer_data.finish_ts ) or "0 с", UI.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
		:ibTimer( function( self )
			self:ibData( "text", getHumanTimeString( offer_data.finish_ts ) or "0 с" )
			UI.area_timer:ibData( "sx", self:ibGetAfterX( ) ):center_x( )
		end, 1000, 0 )
	UI.area_timer:ibData( "sx", UI.lbl_timer:ibGetAfterX( ) ):center_x( )

	local area_buy = ibCreateArea( 0, 613, 0, 0, UI.bg )
	local lbl_cost_text = ibCreateLabel( 0, 0, 0, 0, "Стоимость: ", area_buy, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "left", "center", ibFonts.regular_16 )
	local lbl_cost = ibCreateLabel( lbl_cost_text:ibGetAfterX( ), -1, 0, 0, format_price( offer_data.cost ), area_buy, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
	local img_cost = ibCreateImage( lbl_cost:ibGetAfterX( 8 ), 0, 24, 24, ":nrp_shared/img/hard_money_icon.png", area_buy ):center_y( )
	area_buy:ibData( "sx", img_cost:ibGetAfterX( ) ):center_x( )

	ibCreateButton(	433, 637, 158, 66, UI.bg, "img/btn_buy.png", "img/btn_buy_h.png", "img/btn_buy_h.png", _,_, 0xFFCCCCCC )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )

			ibConfirm( {
				title = "ПОДТВЕРЖДЕНИЕ", 
				text = "Ты хочешь купить этот пак за",
				cost = offer_data.cost,
				cost_is_soft = false,
				fn = function( self ) 
					self:destroy()
					destroyElement( UI.black_bg )
					triggerServerEvent( "onPlayerWantBuyBosowBundle", resourceRoot )
				end,
				escape_close = true,
			} )
		end, false )
end
addEvent( "ShowBosowBundle", true )
addEventHandler( "ShowBosowBundle", root, ShowBosowBundle_handler )

function ShowBosowBundleRewards( )
	localPlayer:setData( "bosow_bundle", nil, false )

	local rewards_data = { }

	showCursor( true )
	local reward_element = ibCreateBackground( )

    triggerEvent( "ShowTakeReward", reward_element, reward_element, "phone_img", { params = { id = "bosow" } } )
	addEventHandler( "ShowTakeReward_callback", reward_element, function( data )
		
		triggerEvent( "ShowTakeReward", reward_element, reward_element, "vinyl", { params = { id = "bosow_1" } } )
		addEventHandler( "ShowTakeReward_callback", reward_element, function( data )
			rewards_data.bosow_1 = data

			triggerEvent( "ShowTakeReward", reward_element, reward_element, "vinyl", { params = { id = "bosow_2" } } )
			addEventHandler( "ShowTakeReward_callback", reward_element, function( data )
				rewards_data.bosow_2 = data
				triggerServerEvent( "onPlayerWantTakeBosowBundle", resourceRoot, rewards_data )

				reward_element:destroy( )
				showCursor( false )
			end )
		end )
	end )
end
addEvent( "ShowBosowBundleRewards", true )
addEventHandler( "ShowBosowBundleRewards", resourceRoot, ShowBosowBundleRewards )