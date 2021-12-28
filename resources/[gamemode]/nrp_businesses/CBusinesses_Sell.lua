local UI_elements = { }

function isBusinessSellWindowActive( )
    local _, element = next( UI_elements or { } )
    return isElement( element )
end

function ShowBusinessSellUI_handler( state, conf )
    if state then
        ShowBusinessSellUI_handler( false )

        --iprint( "Show business sell ui" )

        UI_elements = { }

        local x, y = guiGetScreenSize()

        UI_elements.black_bg = ibCreateBackground( _, ShowBusinessSellUI_handler, true, true ):ibData( "alpha", 0 )
        local sx, sy = 800, 580
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg_sell.png", UI_elements.black_bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 26, 24, 24, 24, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessSellUI_handler( false )
            ShowBusinessSellChooserUI_handler( true )
        end, false )

        ibCreateLabel( 30, 104, 0, 0, "У вас в наличии " .. ( #conf.businesses == 1 and "1 бизнес" or #conf.businesses .. " бизнеса"), UI_elements.bg ):ibBatchData( { font = ibFonts.regular_12 } )

        local npx, npy = 0, 0
		local nsx, nsy = 800, 175
		UI_elements.scroll_pane, UI_elements.scroll_bar = ibCreateScrollpane( 0, 122, 800, 355, UI_elements.bg, { scroll_px = -16, bg_color = 0x00FFFFFF } )
		UI_elements.scroll_bar:ibData( "sensivity", 0.1 )
        for i, business_config in pairs( conf.businesses ) do
			local bg = ibCreateArea( npx, npy, nsx, nsy, UI_elements.scroll_pane )
			if i ~= #conf.businesses then
				ibCreateLine( 30, 173, 770, 173, ibApplyAlpha( 0xFFFFFFFF, 10 ), 1, bg )
			end
            local image = business_config.icon and split( business_config.business_id, "_" )[ 1 ] or string.gsub( business_config.business_id, "_%d+$", "" )
            ibCreateImage( 94 - 128 / 2, 84 - 128 / 2, 128, 128, "img/icons/128x128/" .. image .. ".png", bg )

            local name = ( business_config.name or "Бизнес" ) .. " (" .. business_config.level .. " ур)"
            ibCreateLabel( 192, 33, 0, 0, name, bg ):ibBatchData( { font = ibFonts.regular_12 } )
            
            -- Обычное состояние
            if business_config.on_sale == 0 then
                local minmax = ibCreateLabel( 192, 55, 0, 0, "Цена мин/макс: ", bg ):ibBatchData( { font = ibFonts.regular_11 } )
                ibCreateLabel( 192 + minmax:width( ) + 5, 55, 0, 0, format_price( business_config.min_cost ) .. " / " .. format_price( business_config.max_cost ), bg ):ibBatchData( { font = ibFonts.bold_11 } )

                ibCreateImage( 190, 97, 190, 34, "img/editbox.png", bg )

                local removed = false
                local edit = ibCreateEdit( 200, 100, 170, 27, "Введите сумму продажи", bg, 0xffffffff, 0x00000000, 0x99ffffff ):ibBatchData( { font = ibFonts.bold_10 } )
                
                addEventHandler( "ibOnElementDataChange", edit, function( key, value, old )
                    if key == "focused" then
                        if not removed then
                            edit:ibData( "text", "" )
                            edit:ibData( "caret_position", 0 )
                            removed = true
                        end
                    end
                end )

                UI_elements.btn_sell = ibCreateButton(  640, 38, 130, 34, bg,
                                                    "img/btn_confirm_sell.png", "img/btn_confirm_sell_hover.png", "img/btn_confirm_sell_hover.png",
                                                    0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                addEventHandler( "ibOnElementMouseClick", UI_elements.btn_sell, function( button, state )
                    if button ~= "left" or state ~= "up" then return end

                    local cost = tonumber( edit:ibData( "text" ) )
                    if not cost or cost ~= math.floor( cost ) then
                        localPlayer:ErrorWindow( "Неверная сумма продажи!" )
                        return
                    end

                    if UI_elements.confirmation then UI_elements.confirmation:destroy() end
                    UI_elements.confirmation = ibConfirm(
                        {
                            title = "ПРОДАЖА БИЗНЕСА", 
                            text = "Ты точно хочешь выставить свой бизнес на продажу?",
                            fn = function( self ) 
                                triggerServerEvent( "onBusinessSellRequest", resourceRoot, business_config.business_id, cost )
                                self:destroy()
                            end,
                            escape_close = true,
                        }
                    )
                end, false )

                UI_elements.btn_sell_to = ibCreateButton(  500, 86, 270, 34, bg,
                                                    "img/btn_sell_to.png", "img/btn_sell_to_hover.png", "img/btn_sell_to_hover.png",
                                                    0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                addEventHandler( "ibOnElementMouseClick", UI_elements.btn_sell_to, function( button, state )
					if button ~= "left" or state ~= "up" then return end

					local found = false
					for i, v in pairs( SELL_POINTS ) do
						if Vector3( localPlayer.position - Vector3( v.x, v.y, v.z )).length <= ( v.radius + 1 ) then
							found = true
							break
						end
					end

					if not found then
						localPlayer:ErrorWindow( "Для индивидуальной продажи\nнужно находиться у Биржи!" )
						return
					end

                    local cost = tonumber( edit:ibData( "text" ) )
                    if not cost or cost ~= math.floor( cost ) then
                        localPlayer:ErrorWindow( "Неверная сумма продажи!" )
                        return
                    end

                    if UI_elements.input then UI_elements.input:destroy() end
                    UI_elements.input = ibInput(
                        {
                            title = "Индивидуальная продажа", 
                            text = "Отправка предложения по продаже бизнеса",
                            edit_text = "Введите имя пользователя",
                            btn_text = "ОТПРАВИТЬ",
                            fn = function( self, text )
                                if utf8.len( text ) < 6 then
                                    localPlayer:ErrorWindow( "Слишком короткое имя пользователя" )
                                    return
                                end

                                if utf8.len( text ) > 33 then
                                    localPlayer:ErrorWindow( "Слишком длинное имя пользователя" )
                                    return
                                end

                                triggerServerEvent( "onBusinessSellRequest", resourceRoot, business_config.business_id, cost, text )
                                self:destroy()
                            end
                        }
                    )
                end, false )

            -- Сейчас в процессе продажи - функционал отмены продажи
            else
                local sellfor = ibCreateLabel( 192, 55, 0, 0, "Продаётся за: ", bg ):ibBatchData( { font = ibFonts.regular_11 } )
                ibCreateLabel( 192 + sellfor:width( ) + 5, 55, 0, 0, format_price( business_config.sale_cost ) .. " р. ", bg ):ibBatchData( { font = ibFonts.bold_11 } )

                ibCreateLabel( 192, 91, 0, 0, "Бизнес выставлен на продажу", bg ):ibBatchData( { font = ibFonts.bold_11, color = 0xffff6868 } )

                UI_elements.btn_cancel = ibCreateButton(  640, math.floor( nsy / 2 - 17 ), 130, 34, bg,
                                                    "img/btn_cancel.png", "img/btn_cancel_hover.png", "img/btn_cancel_hover.png",
                                                    0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                addEventHandler( "ibOnElementMouseClick", UI_elements.btn_cancel, function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    if UI_elements.confirmation then UI_elements.confirmation:destroy() end
                    UI_elements.confirmation = ibConfirm(
                        {
                            title = "ОТМЕНА ПРОДАЖИ", 
                            text = "Ты точно хочешь снять свой бизнес с продажи?",
                            fn = function( self ) 
                                triggerServerEvent( "onBusinessCancelSellRequest", resourceRoot, business_config.business_id )
                                self:destroy()
                            end,
                            escape_close = true,
                        }
                    )
                end, false )

            end


            npy = npy + nsy + 1
        end
        UI_elements.scroll_pane:AdaptHeightToContents( )
		UI_elements.scroll_bar:UpdateScrollbarVisibility( UI_elements.scroll_pane )
        UI_elements.black_bg:ibAlphaTo( 255, 300 )

        showCursor( true )

    else
        if isElement( UI_elements and UI_elements.black_bg ) then
            destroyElement( UI_elements.black_bg )
        end
        UI_elements = nil
        showCursor( false )
    end
end
addEvent( "ShowBusinessSellUI", true )
addEventHandler( "ShowBusinessSellUI", root, ShowBusinessSellUI_handler )