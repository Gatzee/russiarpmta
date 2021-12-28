local UI_elements

function ShowPurchaseUI( state, conf )
    if state then
        ShowPurchaseUI( false )

        InitModules( )

        local config = VIP_HOUSES_REVERSE[ conf.hid ]

        UI_elements = { }
        
		local sx, sy = 500, 500

		local timestamp = getRealTime( ).timestamp
		local apartments_offer = localPlayer:getData( "apartments_offer" )

        UI_elements.bg_black = ibCreateBackground( _, ShowPurchaseUI, true, true )
        UI_elements.bg = ibCreateImage( 0, 0, sx, sy, "img/bg_purchase.png", UI_elements.bg_black ):center( )

        UI_elements.btn_close = ibCreateButton(  sx - 24, -34, 24, 24, UI_elements.bg, 
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowPurchaseUI( false )
		end, false )
		
		if conf.hid then
            if conf.img then
                ibCreateImage( 0, 98, 500, 160, "img/icons/".. conf.img ..".png", UI_elements.bg )
            else
                ibCreateImage( 0, 98, 500, 160, "img/icons/".. conf.hid ..".png", UI_elements.bg )
            end
		end

        showCursor( true )

        local button_purchase = ibCreateButton(  339, 420, 126, 44, UI_elements.bg, 
                                                    "img/btn_purchase.png", "img/btn_purchase.png", "img/btn_purchase.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", button_purchase, function( key, state )
            if key ~= "left" or state ~= "up" then return end
            if confirmation then confirmation:destroy() end
            
			local cost = math.floor( config.cost )
			if apartments_offer and apartments_offer > timestamp then
				cost = DISCOUNT_COST_CONVERT[ cost ] or math.floor( cost * 0.8 )
			end
            cost = format_price( cost )

            confirmation = ibConfirm(
                {
                    title = "ПОКУПКА", 
                    text = "Ты точно хочешь купить " .. config.name .. " за " .. cost .. " р. ?",
                    fn = function( self ) 
                        self:destroy()
                        triggerServerEvent( "onViphousePurchaseAttempt", resourceRoot, conf.hid )
                    end,
                    fn_cancel = function( self )
                        self:destroy()
                    end,
                    escape_close = true,
                }
            )
        end, false )

        local button_back = ibCreateButton(  250, 434, 69, 16, UI_elements.bg, 
                                                    "img/btn_back.png", "img/btn_back.png", "img/btn_back.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", button_back, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowPurchaseUI( false )
        end, false )

        ibCreateLabel( 30, 30, 0, 0, conf.name, UI_elements.bg ):ibBatchData( { font = ibFonts.bold_20, color = 0xffffffff } )

        ibCreateLabel( 110, 289, 0, 0, conf.class, UI_elements.bg ):ibBatchData( { font = ibFonts.bold_12, color = 0xff8bfeb1 } )
        ibCreateLabel( 140, 319, 0, 0, conf.owner_name or "Нет владельца", UI_elements.bg ):ibBatchData( { font = ibFonts.bold_12, color = 0xffffffff } )
        ibCreateLabel( 156, 360, 0, 0, config.inventory_max_weight .. " кг", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_12 )

		if apartments_offer and apartments_offer > timestamp then
			local icon_new_cost = ibCreateImage( 50, 440, 28, 28, ":nrp_shared/img/money_icon.png", UI_elements.bg )
			ibCreateLabel( icon_new_cost:ibGetAfterX( 8 ), 454, 0, 0, 100, UI_elements.bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_17 )

			local icon_old_cost = ibCreateImage( 52, 475, 19, 19, ":nrp_shared/img/money_icon.png", UI_elements.bg, ibApplyAlpha( COLOR_WHITE, 50 ) )
			local lbl_old_cost = ibCreateLabel( icon_old_cost:ibGetAfterX( 8 ), 483, 0, 0, format_price( conf.cost ), UI_elements.bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.bold_13 )
			ibCreateImage( 50, 483, lbl_old_cost:ibGetAfterX( ) - 50, 1, _, UI_elements.bg, ibApplyAlpha( COLOR_WHITE, 50 ) )
		else
			local icon_new_cost = ibCreateImage( 50, 440, 28, 28, ":nrp_shared/img/money_icon.png", UI_elements.bg )
			ibCreateLabel( icon_new_cost:ibGetAfterX( 8 ), 454, 0, 0, format_price( conf.cost or 0 ), UI_elements.bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_17 )
		end
    else
        if isElement( UI_elements and UI_elements.bg_black ) then
            destroyElement( UI_elements.bg_black  )
        end
        UI_elements = nil

        showCursor( false )
    end
end
addEvent( "ShowPurchaseUI", true )
addEventHandler( "ShowPurchaseUI", root, ShowPurchaseUI )