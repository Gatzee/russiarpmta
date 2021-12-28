local ui = {}

function ShowUI_Tickets( state )
	if state then
		showCursor(true)

		ui.black_bg = ibCreateBackground( _, ShowUI_Tickets, _, true )
		ui.main = ibCreateImage( 0, 0, 800, 512, "files/img/tickets/bg.png", ui.black_bg ):center()
		ui.close = ibCreateButton( 750, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
        	    ShowUI_Tickets(false)
        	end, false )

		local px, py = 40, 100
		for i,v in pairs(MEMBERSHIP_DATA) do
			ui["ticket"..i] = ibCreateImage(px, py, 226, 370, "files/img/tickets/outline.png", ui.main)
			ui["days"..i] = ibCreateLabel( 0, 0, 226, 60, v.days.." Дней", ui["ticket"..i], 0xFFffffff, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14)
			ui["icon"..i] = ibCreateImage( 18, 60, 190, 96, "files/img/tickets/"..v.icon, ui["ticket"..i] )

			if v.old_cost then
				ui["lcost"..i] = ibCreateLabel( 0, 210, 226, 0, "Стоимость:", ui["ticket"..i], 0xffaaaaaa, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_12)
				
				ui["old_cost"..i] = ibCreateLabel( 0, 240, 140, 0, format_price( v.old_cost ), ui["ticket"..i], 0xaaaaaaaa, 1, 1, "right", "center" ):ibData("font", ibFonts.bold_16)
				ui["old_icon_money"..i] = ibCreateImage( 150, 227, 30, 25, "files/img/tickets/icon_money.png", ui["ticket"..i], 0xaaaaaaaa )
				ui["line"..i] = ibCreateImage( 40, 240, 160, 1, nil, ui["ticket"..i], 0xaaaaaaaa )

				ui["cost"..i] = ibCreateLabel( 0, 270, 140, 0, format_price( v.cost ), ui["ticket"..i], 0xffffffff, 1, 1, "right", "center" ):ibData("font", ibFonts.bold_16)
				ui["icon_money"..i] = ibCreateImage( 150, 257, 30, 25, "files/img/tickets/icon_money.png", ui["ticket"..i] )
			else
				ui["lcost"..i] = ibCreateLabel( 0, 240, 226, 0, "Стоимость:", ui["ticket"..i], 0xffaaaaaa, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_12)
				ui["cost"..i] = ibCreateLabel( 0, 270, 140, 0, format_price( v.cost ), ui["ticket"..i], 0xffffffff, 1, 1, "right", "center" ):ibData("font", ibFonts.bold_16)
				ui["icon_money"..i] = ibCreateImage( 150, 257, 30, 25, "files/img/tickets/icon_money.png", ui["ticket"..i] )
			end

			ui["btn_buy"..i] = ibCreateButton( 3, 260, 220, 132, ui["ticket"..i], "files/img/tickets/btn_buy.png", "files/img/tickets/btn_buy_hover.png", "files/img/tickets/btn_buy_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick(function( key, state )
	        	    if key ~= "left" or state ~= "down" then return end
					
					if confirmation then confirmation:destroy() end
					
					confirmation = ibConfirm( {
	        	        title = "Покупка билета", 
	        	        text = "Ты действительно хочешь купить билет на "..v.days.." дней?\nСтоимость - "..format_price(v.cost),
	        	        black_bg = 0xaa202025,
	        	        fn = function( self ) 
							self:destroy()
							confirmation = nil
	        	            ShowUI_Tickets(false)
	        	            triggerServerEvent( "FC:OnPlayerTryBuyMembership", resourceRoot, localPlayer, i )
						end,
						escape_close = true,
	        	    } )
			end, false )
			
			px = px + 246
		end
	else
		if isElement(ui and ui.black_bg) then
			destroyElement( ui.black_bg )
		end
		ui = {}
		showCursor(false)
	end

end
addEvent("FC:ShowUI_Tickets", true)
addEventHandler("FC:ShowUI_Tickets", resourceRoot, ShowUI_Tickets)