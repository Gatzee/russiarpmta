ibUseRealFonts( true )

local UIe = { }
local CURRENT_TAB = 1

function CreateUI_Secretary( data )
	DestroyUI_Secretary( )

	UIe.black_bg = ibCreateBackground( _, DestroyUI_Secretary, _, true )
	UIe.bg = ibCreateImage( 0, 0, 800, 600, "img/secretary/bg.png", UIe.black_bg ):center( )
	UIe.bg = ibCreateRenderTarget( 0, 0, 800, 600, UIe.bg )

	ibCreateButton(	748, 23, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			DestroyUI_Secretary( )
		end, false )

	do
		local tabs = {
			{
				name = "Бизнесы";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 30, 140, 740, 440, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					for i, info in pairs( data.businesses ) do
						local bg = ibCreateImage( 0, 230 * ( i - 1 ), 740, 210, _, UIe.scroll_pane, ibApplyAlpha( 0xff55718f, 50 ) )
						local business_category = string.gsub( info.business_id, "_%d+$", "" )
						local business_category = info.icon and split( info.business_id, "_" )[ 1 ] or string.gsub( info.business_id, "_%d+$", "" )
						ibCreateImage( 0, 0, 740, 210, "img/secretary/icons/".. business_category ..".png", bg ):ibData( "alpha", 255 * 0.6 )

						ibCreateLabel( 20, 26, 0, 0, info.name, bg, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_20 )

						local max_succes_value = exports.nrp_businesses:GetMaxSuccesValue( )
						local progress = math.min( 1, ( info.succes_value / max_succes_value ) )
						local width = 201 * progress
						local text = ( info.succes_value or 0 ) .. "#cccccc / " .. max_succes_value
						ibCreateLabel( 20, 50, 0, 0, "Успешность:", bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_12 )
						ibCreateLabel( 221, 49, 0, 0, text, bg, 0xFFFFFFFF, 1, 1, "right", "center", ibFonts.regular_14 ):ibData( "colored", true )
						ibCreateImage( 20, 62, 201, 14, _, bg, 0x77000000 )
						ibCreateImage( 20, 62, width, 14, _, bg, 0xff00b4ff )
						ibCreateLabel( 241, 68, 0, 0, info.level .. " ур", bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_20 )

						ibCreateLabel( 20, 102, 0, 0, "Доход бизнеса:", bg, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_16 )
						local lbl_income = ibCreateLabel( 20, 130, 0, 0, format_price( info.max_weekly_income ), bg, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_24 )
						ibCreateImage( lbl_income:ibGetAfterX( 8 ), 116, 28, 28, ":nrp_shared/img/money_icon.png", bg )

						ibCreateImage( 698, 20, 24, 24, ":nrp_shared/img/money_icon.png", bg )
						local lbl_balance = ibCreateLabel( 690, 33, 0, 0, format_price( info.balance ), bg, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.bold_16 )
						ibCreateLabel( lbl_balance:ibGetBeforeX( -8 ), 32, 0, 0, "Баланс лицевого счёта:", bg, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.light_16 )
						ibCreateButton(	464, 57, 256, 32, bg, "img/secretary/btn_balance", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end

								ibClick( )
								if UIe.input then UIe.input:destroy() end
								UIe.input = ibInput(
									{
										title = "Пополнение лицевого счёта", 
										text = "",
										edit_text = "Введите сумму пополнения",
										btn_text = "ПОПОЛНИТЬ",
										fn = function( self, text )
											local amount = tonumber( text )
											if not amount or amount ~= math.floor( amount ) then
												localPlayer:ErrorWindow( "Неверная сумма для пополнения!" )
												return
											end

											self:destroy()
											triggerServerEvent( "onBusinessAddMoneyRequest", resourceRoot, info.business_id, amount )
											triggerServerEvent( "onPlayerRequestOfficeSecretaryMenu", resourceRoot )
										end,
										is_sum = true,
									}
								)

								local max_sum = math.min( localPlayer:GetMoney( ), info.max_balance - info.balance )
								local bg = UIe.input.elements.bg

								local lbl_balance = ibCreateLabel( 38, 105, 0, 0, "Ваш текущий баланс:", bg ):ibBatchData( { color = 0xffffdf93, font = ibFonts.regular_12 } )
								local lbl_amount = ibCreateLabel( 38 + lbl_balance:width( ) + 10, 105, 0, 0, format_price( info.balance ), bg ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_12 } )
								ibCreateImage( 38 + lbl_balance:width( ) + 10 + lbl_amount:width( ) + 10, 103, 24, 24, ":nrp_shared/img/money_icon.png", bg )
								ibCreateLabel( UIe.input.sx - 54, 166, 0, 0, "Макс. сумма - " .. format_price( max_sum ), bg, 0xFFBBBBBB ):ibBatchData( { font = ibFonts.regular_10, align_x = "right" } )
							end, false )

						-- Снятие со счёта
						ibCreateButton(	20, 158, 150, 32, bg, "img/office_control/btn_take", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )
								if UIe.input then UIe.input:destroy() end
								
								UIe.func_take = function( self, text )
									local amount = tonumber( text )
									if not amount or amount ~= math.floor( amount ) then
										localPlayer:ErrorWindow( "Неверная сумма для вывода!" )
										return
									end

									triggerServerEvent( "onBusinessTakeMoneyRequest", resourceRoot, info.business_id, amount )
									triggerServerEvent( "onPlayerRequestOfficeSecretaryMenu", resourceRoot )
									self:destroy()
								end
								
								UIe.input = ibInput( {
									title = "Вывод с лицевого счёта", 
									text = "",
									edit_text = "Введите сумму вывода",
									btn_text = "ВЫВОД",
									fn = UIe.func_take,
									is_sum = true,
								} )

								local max_sum = info.balance
								local bg = UIe.input.elements.bg

								ibUseRealFonts( false )
								UIe.input.elements.btn_ok:ibData( "px", 116 )
								local btn_max_value = ibCreateButton( 266, 264, 138, 44, bg, ":nrp_shared/img/btn_bg.png", ":nrp_shared/img/btn_bg_hover.png", ":nrp_shared/img/btn_bg_hover.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
									:ibOnClick( function( key, state )
										if key ~= "left" or state ~= "up" then return end
										ibClick( )
										if info.balance == 0 then
											localPlayer:ErrorWindow( "На лицевом счете нет средств!" )
											return
										end
										UIe.func_take( UIe.input, info.balance )
									end )
								ibCreateLabel( 0, 0, 0, 0, "ВЫВЕСТИ ВСЕ", btn_max_value, 0xFFDDDDDD ):ibBatchData( { font = ibFonts.bold_12, align_x = "center", align_y = "center", disabled = true } ):center( )
								ibUseRealFonts( true )

								local lbl_balance = ibCreateLabel( 38, 105, 0, 0, "Ваш текущий баланс:", bg ):ibBatchData( { color = 0xffffdf93, font = ibFonts.regular_12 } )
								local lbl_amount = ibCreateLabel( 38 + lbl_balance:width( ) + 10, 105, 0, 0, format_price( info.balance ), bg ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_12 } )
								ibCreateImage( 38 + lbl_balance:width( ) + 10 + lbl_amount:width( ) + 10, 103, 24, 24, ":nrp_shared/img/money_icon.png", bg )
								ibCreateLabel( UIe.input.sx - 54, 166, 0, 0, "Макс. сумма - " .. format_price( max_sum ), bg, 0xFFBBBBBB ):ibBatchData( { font = ibFonts.regular_10, align_x = "right" } )
							end, false )

						-- ПОЛУЧИТЬ ОТКАТ
						ibCreateButton(	190, 158, 170, 32, bg, "img/office_control/btn_take_bribe", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )
								exports.nrp_businesses:ShowTakeBribeOverlay( UIe.bg, info )
							end, false )

						local lbl_materials = ibCreateLabel( 720, 131, 0, 0, info.materials, bg, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.bold_16 )
						ibCreateLabel( lbl_materials:ibGetBeforeX( -8 ), 130, 0, 0, "Количество продукции:", bg, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.light_16 )
						ibCreateButton(	464, 158, 256, 32, bg, "img/secretary/btn_materials", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end

								ibClick( )

								amount = math.min( info.max_materials, info.max_materials - info.materials  )
								if amount <= 0 then
									localPlayer:ErrorWindow( "Вы превысили максимальное количество продукции! Закупка отменена" )
									return
								end

								local cost = amount * info.material_cost

								if UIe.confirmation then UIe.confirmation:destroy() end
								UIe.confirmation = ibConfirm(
									{
										title = "ПОКУПКА ПРОДУКЦИИ",
										text = "Ты действительно хочешь купить " .. amount .. " ед. продукции за " .. cost .. " р.?\nСумма будет списана с лицевого счёта бизнеса",
										black_bg = 0xaa000000,
										fn = function( self )
											self:destroy()
											triggerServerEvent( "onBusinessBuyMaterialsRequest", resourceRoot, info.business_id, amount )
											triggerServerEvent( "onPlayerRequestOfficeSecretaryMenu", resourceRoot )
										end,
										escape_close = true,
									}
								)
							end, false )
					end

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
				end;
			},
			{
				name = "Еда";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 30, 140, 740, 440, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					for i, info in pairs( CONST_FOOD_LIST ) do
						local bg = ibCreateImage( 380 * ( ( i - 1 ) % 2 ), 300 * math.floor( ( i - 1 ) / 2 ), 360, 280, ":nrp_player_hunger/img/block.png", UIe.scroll_pane )

						local bg_light = ibCreateImage( 0, 0, 360, 280, ":nrp_player_hunger/img/light.png", bg )
							:ibData( "disabled", true ):ibData( "alpha", 0 ):ibData( "priority", -1 )

						bg:ibOnHover( function( ) bg_light:ibAlphaTo( 255, 200 ) end )
						bg:ibOnLeave( function( ) bg_light:ibAlphaTo( 0, 200 ) end )

						local img = ibCreateImage( 0, 60, 0, 0, ":nrp_player_hunger/img/food/".. i ..".png" , bg ):ibData( "disabled", true )
						local sx, sy = img:ibGetTextureSize( )
						local scale = math.min( 143 / sx, 93 / sy )
						img:ibBatchData( { sx = sx * scale, sy = sy * scale } ):center_x( )

						ibCreateLabel( 0, 15, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "center", "top" ):ibData( "font", ibFonts.regular_16 ):center_x( )
						ibCreateLabel( 187, 170, 0, 0, info.calories, bg, COLOR_WHITE, 1, 1, "left", "top" ):ibData( "font", ibFonts.regular_18 )

						do
							local label_cost = ibCreateLabel( 19, 235, 0, 0, format_price( math.floor( info.cost * 1.2 ) ), bg ):ibData( "font", ibFonts.semibold_21 )
							ibCreateImage( label_cost:ibGetAfterX( 8 ), 235, 30, 30, ":nrp_shared/img/money_icon.png", bg ):ibData( "disabled", true )
						end


						ibCreateButton(	227, 230, 113, 34, bg, ":nrp_businesses_shop/img/btn_buy", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end

								ibClick( )
								triggerServerEvent( "onPlayerFoodPurchase", localPlayer, i, 1.2 )
							end, false )
					end

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
				end;
			},
			{
				name = "Аптека";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 30, 140, 740, 440, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					for i, info in pairs( CONST_MEDS_LIST ) do
						local bg = ibCreateImage( 380 * ( ( i - 1 ) % 2 ), 300 * math.floor( ( i - 1 ) / 2 ), 360, 280, ":nrp_drugstore/img/block.png", UIe.scroll_pane )

						local bg_light = ibCreateImage( 0, 0, 360, 280, ":nrp_drugstore/img/light.png", bg )
							:ibData( "disabled", true ):ibData( "alpha", 0 ):ibData( "priority", -1 )

						bg:ibOnHover( function( ) bg_light:ibAlphaTo( 255, 200 ) end )
						bg:ibOnLeave( function( ) bg_light:ibAlphaTo( 0, 200 ) end )

						local img = ibCreateImage( 0, 60, 0, 0, ":nrp_drugstore/img/meds/".. i ..".png" , bg ):ibData( "disabled", true )
						local sx, sy = img:ibGetTextureSize( )
						local scale = math.min( 143 / sx, 83 / sy )
						img:ibBatchData( { sx = sx * scale, sy = sy * scale } ):center_x( )

						ibCreateLabel( 0, 15, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "center", "top" ):ibData( "font", ibFonts.regular_16 ):center_x( )
						ibCreateLabel( 187, 165, 0, 0, info.health, bg, COLOR_WHITE, 1, 1, "left", "top" ):ibData( "font", ibFonts.regular_18 )

						do
							local label_cost = ibCreateLabel( 19, 235, 0, 0, format_price( math.floor( info.cost * 1.2 ) ), bg ):ibData( "font", ibFonts.semibold_21 )
							ibCreateImage( label_cost:ibGetAfterX( 8 ), 235, 30, 30, ":nrp_shared/img/money_icon.png", bg ):ibData( "disabled", true )
						end


						ibCreateButton(	227, 230, 113, 34, bg, ":nrp_businesses_shop/img/btn_buy", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end

								ibClick( )
								triggerServerEvent( "onPlayerMedsPurchase", localPlayer, i, 1.2 )
							end, false )
					end

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
				end;
			},
		}

		CURRENT_TAB = 1
		tabs[ CURRENT_TAB ].func_Create( )

		local line = ibCreateImage( 30, 114, 10, 3, _, UIe.bg, 0xffff965d )

		local pos_x = 30
		local prev_lbl = nil
		for i, tab in pairs( tabs ) do
			local lbl = ibCreateLabel( pos_x, 87, 0, 20, tab.name, UIe.bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_14 ):ibData( "alpha", i == CURRENT_TAB and 255 or 150 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					if source == prev_lbl then return end

					prev_lbl:ibAlphaTo( 150, 250 )
					source:ibAlphaTo( 255, 250 )

					line:ibMoveTo( source:ibData( "px" ), 114, 250 )
					line:ibResizeTo( source:ibData( "sx" ), 3, 250 )

					prev_lbl = source

					if isElement( UIe.scroll_pane ) then
						destroyElement( UIe.scroll_pane )
						destroyElement( UIe.scroll_bar )
					end
					CURRENT_TAB = i
					tabs[ CURRENT_TAB ].func_Create( )
				end, false )

			lbl:ibData( "sx", lbl:width( ) )
			pos_x = lbl:ibGetAfterX( 20 )

			if i == CURRENT_TAB then
				prev_lbl = lbl
				line:ibData( "sx", lbl:ibData( "sx" ) )
			end
		end
	end

	showCursor( true )
end
addEvent( "ShowOfficeSecretaryMenu", true )
addEventHandler( "ShowOfficeSecretaryMenu", resourceRoot, CreateUI_Secretary )

function DestroyUI_Secretary( )
	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	showCursor( false )
end