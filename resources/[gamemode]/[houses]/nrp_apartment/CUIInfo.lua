local click_timeout = 0
local UI_elements = { }
local scX, scY = guiGetScreenSize()

local apartments_call_ticks = {}

function UIInfo( info )
	if isElement( UI_elements.bg_img ) then return end

	showCursor( true )

	UI_elements.black_bg = ibCreateBackground(0x80495F76, DestroyUIInfo, true, true)
	UI_elements.bg_img = ibCreateImage( 0, 0, 500, 535, "images/info/bg.png", UI_elements.black_bg ):center( )

	UI_elements.button_close = ibCreateButton( 476, 0, 24, 24, UI_elements.bg_img, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			DestroyUIInfo()
		end )

	UI_elements.title = ibCreateLabel( 50, 95, 0, 0, "КВАРТИРА #".. info.number, UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_20 )
	UI_elements.back = ibCreateButton( 25, 83, 14, 22, UI_elements.bg_img, "images/button_back.png", "images/button_back.png", "images/button_back.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			DestroyUIInfo()
			triggerServerEvent( "PlayerWantShowListApartments", resourceRoot, info.id )
		end )

	UI_elements.class_img = ibCreateImage( 0, 133, 500, 160, "images/info/class/".. info.class ..".png", UI_elements.bg_img )

	local class_names = { "Низкий (1-ый)", "Средний (2-ой)", "Высокий (3-ий)", [8] = "Элитный (4-й)" }
	UI_elements.class_text = ibCreateLabel( 188, 335, 0, 0, class_names[ info.class ], UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.light_12 )

	UI_elements.inventory_max_weight = ibCreateLabel( 153, 366, 0, 0, APARTMENTS_CLASSES[ info.class ].inventory_max_weight .. " кг", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.light_12 )

	local timestamp = getRealTimestamp( )
	local apartments_offer = localPlayer:getData( "apartments_offer" )
	local apart20_offer = ( localPlayer:getData( "offer_property" ) or { } ).time_to
	--Если новый оффер активен, то скидка 20%
	local offerCost20 = ( apart20_offer and apart20_offer > timestamp ) and math.floor( info.cost * 0.8 )
	--Если актив старый оффер на апарты то кастомная скидка( info.discount_cost ) или если ее нет то 20%
	local offerCost = ( apartments_offer and apartments_offer > timestamp ) and ( info.discount_cost or math.floor( info.cost * 0.8 ) )

	local finalCost = offerCost20 or offerCost or info.cost
	if ( not info.owner or info.owner == 0 ) and finalCost ~= info.cost then
		local icon_new_cost = ibCreateImage( 50, 450, 28, 28, ":nrp_shared/img/money_icon.png", UI_elements.bg_img )
		UI_elements.cost_text = ibCreateLabel( icon_new_cost:ibGetAfterX( 8 ), 463, 0, 0, format_price( finalCost ), UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_17 )

		local icon_old_cost = ibCreateImage( 52, 482, 19, 19, ":nrp_shared/img/money_icon.png", UI_elements.bg_img, ibApplyAlpha( COLOR_WHITE, 50 ) )
		local lbl_old_cost = ibCreateLabel( icon_old_cost:ibGetAfterX( 8 ), 490, 0, 0, format_price( info.cost ), UI_elements.bg_img, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.bold_13 )
		ibCreateImage( 50, 490, lbl_old_cost:ibGetAfterX( ) - 50, 1, _, UI_elements.bg_img, ibApplyAlpha( COLOR_WHITE, 50 ) )
	else
		local icon_new_cost = ibCreateImage( 50, 450, 28, 28, ":nrp_shared/img/money_icon.png", UI_elements.bg_img )
		UI_elements.cost_text = ibCreateLabel( icon_new_cost:ibGetAfterX( 8 ), 463, 0, 0, format_price( info.cost ), UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_17 )
	end

	if not info.owner or info.owner == 0 then
		UI_elements.button_prev = ibCreateButton( 305, 235, 160, 34, UI_elements.bg_img, 
			"images/info/button_prev_idle.png", "images/info/button_prev_hover.png", "images/info/button_prev_click.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end
				if localPlayer:GetBlockInteriorInteraction() then
					localPlayer:ShowInfo( "Вы не можете войти во время задания" )
					return false
				end
				triggerServerEvent( "PlayerWantEnterApartment", resourceRoot, info.id, info.number )
				DestroyUIInfo()
			end )

		UI_elements.button_buy = ibCreateButton( 339, offerActive and 455 or 440, 126, 44, UI_elements.bg_img, 
			"images/info/button_buy_idle.png", "images/info/button_buy_hover.png", "images/info/button_buy_click.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end

				if UI_elements.confirm then
					UI_elements.confirm:destroy( )
				end

				UI_elements.confirm = ibConfirm( {
					title = "ПОКУПКА КВАРТИРЫ",
					text = "Вы точно хотите купить данную квартиру\nза " .. format_price( finalCost ) .. " рублей?",
					fn = function( self )
						self:destroy( )
						DestroyUIInfo( )
						triggerServerEvent( "PlayerWantBuyApartment", resourceRoot, info.id, info.number )
					end,
					escape_close = true,
				} )
			end )

	elseif info.owner == localPlayer:GetUserID() or info.wedding_use then
		UI_elements.button_buy = ibCreateButton( 339, 440, 126, 44, UI_elements.bg_img, 
			"images/info/button_enter_idle.png", "images/info/button_enter_hover.png", "images/info/button_enter_click.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end
				if localPlayer:GetBlockInteriorInteraction() then
					localPlayer:ShowInfo( "Вы не можете войти во время задания" )
					return false
				end
				triggerServerEvent( "PlayerWantEnterApartment", resourceRoot, info.id, info.number )
				DestroyUIInfo()
			end )

	else
		UI_elements.button_buy = ibCreateButton( 339, 440, 126, 44, UI_elements.bg_img, 
			"images/info/button_call_idle.png", "images/info/button_call_idle.png", "images/info/button_call_idle.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end

				if not apartments_call_ticks[info.id] then
					apartments_call_ticks[info.id] = {}
				end
				if getTickCount() - ( apartments_call_ticks[info.id][info.number] or 0 ) < 120000 then
					localPlayer:ShowError( "Позвонить можно раз в 2 мин." )
					return
				end
				apartments_call_ticks[info.id][info.number] = getTickCount()
				
				playSound( ":nrp_house_call/files/door_bell.mp3" )

				triggerServerEvent( "PlayerWantCallApartment", resourceRoot, info.id, info.number )
				DestroyUIInfo()
			end )
	end
end
addEvent( "ShowUIInfo", true )
addEventHandler( "ShowUIInfo", resourceRoot, UIInfo )

addEvent( "HideUIInfo", true )
addEventHandler( "HideUIInfo", resourceRoot, function()
	DestroyUIInfo( )
end )

function DestroyUIInfo( )
	if isElement( UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
	end
	UI_elements = { }

	showCursor( false )
end