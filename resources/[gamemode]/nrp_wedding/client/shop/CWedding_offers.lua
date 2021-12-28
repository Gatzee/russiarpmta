OFFERS_LIST = {
	{ key = "wedding" },
	{ key = "divorce" },
};
local overlay_info = {
	["wedding"] = { buy = { 665, 70 }, hide = { 350, 460 } },
	["divorce"] = { buy = { 350, 280 }, hide = { 350, 430 } },
};

--[[
	tbl["wedding"]
	tbl.wedding
	tbl = { wedding = 123 }
]]

TABS_CONF.offers = {
	fn_create = function( self, parent )
		DestroyTableElements( getElementChildren( parent ) )

		local scrollpane, scrollbar = ibCreateScrollpane( 30, 45, 740, 463, parent, { scroll_px = 10 } )
		scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 100 )

		local px, py = 0, 20
		local last_sy = 0

		-- scrollpane fixer
		ibCreateImage( px, py+last_sy, 100, 30, nil, scrollpane, 0x00000000 )

		local npx, npy = 0, 0
		for i, v in pairs( OFFERS_LIST ) do
			if i > 1 and i % 2 == 1 then
				npx = 0
				npy = npy + 280 + 20
			elseif i > 1 then
				npx = npx + 360 + 20
			end
			
			local area = ibCreateArea( npx, npy, 360, 280, scrollpane )
			local bg_light = ibCreateImage( 0, 20, 360, 280, "files/shop/gift_light_bg.png", area )
			:ibBatchData( { disabled = true, alpha = 0 })
			local bg = ibCreateImage( 0, 20, 360, 280, "files/shop/" .. v.key .. ".png", area )

			bg:ibOnHover( function( )
				bg_light:ibAlphaTo( 255, 500 )
			end )
			bg:ibOnLeave( function( )
				bg_light:ibAlphaTo( 0, 500 )
			end )

			local cost_txt, cost_img
			if WEDDING_SHOP_PARTS[v.key].hard_cost then
				cost_txt = WEDDING_SHOP_PARTS[v.key].hard_cost
				cost_img = ":nrp_shared/img/hard_money_icon.png"
			elseif WEDDING_SHOP_PARTS[v.key].soft_cost then
				cost_txt = WEDDING_SHOP_PARTS[v.key].soft_cost
				cost_img = ":nrp_shared/img/money_icon.png"
			else
				cost_txt = 0
				cost_img = ":nrp_shared/img/money_icon.png"
			end
			
			local label_cost = ibCreateLabel( 15, 235, 0, 34, "Цена:", bg )
			:ibBatchData( { font = ibFonts.regular_12, align_x = "left", align_y = "center", disabled = true })

			local cost_img = ibCreateImage( label_cost:ibGetAfterX( 10 ), 238, 28, 28, cost_img, bg )
			:ibData( "disabled", true )

			local label_price = ibCreateLabel( cost_img:ibGetAfterX( 7 ), 235, 0, 34, cost_txt, bg )
			:ibBatchData( { font = ibFonts.bold_12, align_x = "left", align_y = "center", disabled = true })

			ibCreateButton(	237, 235, 149, 34, bg,
				"files/btn_info.png", "files/btn_info.png", "files/btn_info.png",
				0xBFFFFFFF, 0xFFFFFFFF, 0xBFFFFFFF )
			:center_x( 95 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				OfferOverlayEnable( true, v.key, parent )
			end )

		end

		scrollpane:AdaptHeightToContents( )
		scrollbar:UpdateScrollbarVisibility( scrollpane )
		scrollpane:ibData( "sy", scrollpane:ibData( "sy" ) + 40 )
    end,
}

function OfferOverlayEnable( state, part, parent )
	if state then
		ibOverlaySound()
		OfferOverlayEnable( false )
		IB_elements.offers_overlay = ibCreateImage( 0, 0, 800, 509, "files/shop/" .. part .. "_overlay.png", parent )

		ibCreateButton(	overlay_info[part].buy[1], overlay_info[part].buy[2], 113, 34, IB_elements.offers_overlay,
			"files/btn_buy.png", "files/btn_buy.png", "files/btn_buy.png",
			0xBFFFFFFF, 0xFFFFFFFF, 0xBFFFFFFF )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			IB_elements.offer_overlay_confirmation = ibConfirm(
			{
				title = "ПОКУПКА УСЛУГИ", 
				text = "Вы уверены что хотите приобрести \"" .. WEDDING_SHOP_PARTS[part].name .. "\" за " .. format_price( WEDDING_SHOP_PARTS[part].hard_cost ) .. " ?",
				fn = function( self ) 
					self:destroy()
					CWeddingShopSetState_handler( false )
					triggerServerEvent( "onWeddingPlayerWeddingShopBuyItem", resourceRoot, part )
				end,
				fn_cancel = function( self )
					self:destroy()
					OfferOverlayEnable( false )
				end,
				escape_close = true,
			}
		)
		end )

		ibCreateButton(	overlay_info[part].hide[1], overlay_info[part].hide[2], 101, 34, IB_elements.offers_overlay,
			"files/btn_hide.png", "files/btn_hide.png", "files/btn_hide.png",
			0xBFFFFFFF, 0xFFFFFFFF, 0xBFFFFFFF )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			OfferOverlayEnable( false )
		end )
	else
		if isElement( IB_elements.offers_overlay ) then IB_elements.offers_overlay:destroy(); end
	end
end