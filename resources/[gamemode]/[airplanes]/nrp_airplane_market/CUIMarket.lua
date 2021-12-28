local pAvailableColors = 
{
	{ 200, 50, 50 },
	{ 50, 200, 50 },
	{ 50, 50, 200 },
	{ 50, 50, 50 },
	{ 200, 200, 200 },
}

local vehicles_data = 
{
	[419] = { z_bias = 2, },
	[520] = { z_bias = 0.2, comment = "Гражданский" },
	[487] = { z_bias = 0.5, },
	[563] = { z_bias = 0.5, comment = "Гражданский" },
	[425] = { z_bias = 0.5, comment = "Гражданский" },
}

local ui = {}
local pData = {}
local pAssortment = {}
local x, y = guiGetScreenSize()
function ShowUI_Market( state, market_id )
	if state then
		pMarket = MARKETS_LIST[ market_id ]

		pAssortment = {}

		for k, v in pairs( VEHICLE_CONFIG ) do
			if v.sell and v.marketlist == pMarket.assortment_id then
				v.model_id = k
				table.insert(pAssortment, v)
			end
		end

		if #pAssortment <= 0 then
			localPlayer:ShowError("Этот салон временно закрыт")
			return false
		end

		table.sort( pAssortment, function( first, second )
			if first.time_new and not second.time_new then
				return true
			end
		end)

		pData.dimension = localPlayer:GetUniqueDimension()
		local z_bias = vehicles_data[pAssortment[1].model_id] and vehicles_data[pAssortment[1].model_id].z_bias or 0
		pData.pVehicle = createVehicle( pAssortment[1].model_id, pMarket.vehicle_position + Vector3( 0, 0, z_bias), 0, 0, pMarket.vehicle_rotation or 0 )
		pData.pVehicle.dimension = pData.dimension


		fadeCamera(false, 1)
		toggleAllControls( false )
		localPlayer.frozen = true

		-- Помощь по клавишам
		local sx, sy = 312, 40

		ui.black_bg = ibCreateBackground( 0x00000000, ShowUI_Market, _, true )
			:ibTimer( function()
				setCameraMatrix( unpack( pMarket.camera_position ) )
				localPlayer:Teleport( nil, pData.dimension )
			end, 1200, 1 )

		ui.HelpPopup_left = ibCreateLabel(x - 80, 80, 0, 0, "- обратно", ui.black_bg, 0xffffffff, _, _, "right", "center", ibFonts.regular_15):ibData("alpha", 0)
			:ibTimer( function()
				fadeCamera(true, 1)
				showCursor(true)
				DisableHUD(true)
				--setPlayerHudComponentVisible( "radar", false )
				ui.main:ibAlphaTo(255, 1000)
				ui.HelpPopup_left:ibAlphaTo(255, 1000)
				ui.HelpPopup_left_key:ibAlphaTo(255, 1000)
				ui.HelpPopup_right:ibAlphaTo(255, 1000)
				ui.HelpPopup_right_key:ibAlphaTo(255, 1000)
				addEventHandler("onClientKey", root, MarketKeyHandler, true, "high-9999999999999")
			end, 2200, 1 )

		ui.HelpPopup_left_key = ibCreateLabel(x - 175, 80, 0, 0, "ESC", ui.black_bg, 0xffffffff, _, _, "right", "center", ibFonts.bold_18):ibData("alpha", 0)

		ui.HelpPopup_right = ibCreateLabel(x - 80, 110, 0, 0, "- выбрать", ui.black_bg, 0xffffffff, _, _, "right", "center", ibFonts.regular_15):ibData("alpha", 0)

		ui.HelpPopup_right_key = ibCreateLabel(x - 175, 110, 0, 0, "Enter", ui.black_bg, 0xffffffff, _, _, "right", "center", ibFonts.bold_18 ):ibData("alpha", 0)

		ui.main = ibCreateImage( 0, 0, 1080, scy, "files/img/bg.png", ui.black_bg ):ibData("alpha", 0)
		ui.title = ibCreateLabel( 80, 200, 0, 0, "АВИАСАЛОН", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_38)
		ibCreateLabel( 80, 280, 0, 0, "Модель:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ibCreateLabel( 80, 340, 0, 0, "Цвет:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)

		ui.label_model = ibCreateLabel( 280, 280, 0, 0, "BMW M5", ui.main, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_21)
		ui.label_comment = ibCreateLabel( 280, 305, 0, 0, "", ui.main, 0xFFCC2222, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_12)

		local bias_x = ui.label_model:width()/2 + 15
		
		ui.btn_prev = ibCreateButton( 280-bias_x-15, 272, 10, 16, ui.main, "files/img/arrow.png", "files/img/arrow.png", "files/img/arrow.png", 0xFFBBBBBB, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibData("rotation", 180)
		:ibOnClick( function( button, state ) 
			if button == "left" and state == "down" then
				local iNewID = pAssortment[ pData.iAssortmentID - 1 ] and pData.iAssortmentID - 1 or #pAssortment
				UpdateModel( iNewID )
				ibClick()
			end
		end)

		ui.btn_next = ibCreateButton( 280+bias_x, 272, 10, 16, ui.main, "files/img/arrow.png", "files/img/arrow.png", "files/img/arrow.png", 0xFFBBBBBB, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibOnClick( function( button, state ) 
			if button == "left" and state == "down" then
				local iNewID = pAssortment[ pData.iAssortmentID + 1 ] and pData.iAssortmentID + 1 or 1
				UpdateModel( iNewID )
				ibClick()
			end
		end)

		ui.selection_circle = ibCreateImage( 178, 326, 30, 30, "files/img/circle.png", ui.main, 0xFFFFFFFF )

		local px, py = 180, 328
		for k,v in pairs( pAvailableColors ) do
			ui["color"..k] = ibCreateImage( px, py, 26, 26, "files/img/circle.png", ui.main, tocolor( unpack(v) ))
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end
				UpdateVehicleColor(k)
				ui.selection_circle:ibData("px", source:ibData("px")-2)
				ibClick()
		 	end)
			px = px + 40
		end

		ibCreateLabel( 80, scy/2-30, 0, 0, "Тяга:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
		ibCreateLabel( 80, scy/2, 0, 0, "Макс.скорость:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
		ibCreateLabel( 80, scy/2+30, 0, 0, "Расход:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)

		ui.power = ibCreateLabel( 235, scy/2-30, 0, 0, "122 кН", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.max_speed = ibCreateLabel( 235, scy/2, 0, 0, "500 км/ч", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.consumption = ibCreateLabel( 235, scy/2+30, 0, 0, "5.0 л", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)

		ibCreateLabel( 80, scy-130, 0, 0, "Стоимость:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.cost = ibCreateLabel( 80, scy-100, 0, 0, "80 000 000", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_22)

		ui.btn_buy = ibCreateButton( 280, scy-130, 160, 50, ui.main, "files/img/btn_buy.png", "files/img/btn_buy.png", "files/img/btn_buy.png", 0xFFEEEEEE, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			
			local pConfig = pAssortment[pData.iAssortmentID]
			local pVariant = pConfig.variants[1]

			ui.confirm = ibConfirm(
			    {
			        title = "ПОКУПКА ТРАНСПОРТА", 
			        text = "Ты хочешь купить "..pConfig.model.." за "..format_price(pVariant.cost).."р.?" ,
			        fn = function( self )
			        	triggerServerEvent("OnPlayerTryBuySpecialVehicle", resourceRoot, { model = pConfig.model_id, variant = 1, color = pAvailableColors[pData.iSelectedColor] } )
			            self:destroy()
					end,
					escape_close = true,
			    }
			)

			ibClick()
		end)

		UpdateModel( 1 )
	else
		if isElement(ui.main) then
			fadeCamera(false, 1)

			setTimer(function()
				setCameraTarget( localPlayer )
			end, 1200, 1)

			setTimer(function()
				fadeCamera(true, 1)
				toggleAllControls( true )

				DisableHUD(false)
				--setPlayerHudComponentVisible( "radar", true )
				localPlayer.frozen = false
				localPlayer:Teleport( nil, 0 )
			end, 2200, 1)

			removeEventHandler("onClientKey", root, MarketKeyHandler)

			showCursor(false)
		end

		DestroyTableElements( ui )
		DestroyTableElements( pData )
	end
end
addEvent("ShowUI_SpecialMarket", true)
addEventHandler("ShowUI_SpecialMarket", resourceRoot, ShowUI_Market)

function UpdateModel( iAssortmentID )
	local pConfig = pAssortment[iAssortmentID]
	local pVariant = pConfig.variants[1]

	pData.iAssortmentID = iAssortmentID
	pData.pVehicle.model = pConfig.model_id
	pData.pVehicle.engineState = false

	local z_bias = vehicles_data[pAssortment[iAssortmentID].model_id] and vehicles_data[pAssortment[iAssortmentID].model_id].z_bias or 0
	pData.pVehicle.position = pMarket.vehicle_position + Vector3( 0, 0, z_bias)
	pData.pVehicle.rotation = Vector3( 0, 0, pMarket.vehicle_rotation )

	UpdateVehicleColor( pData.iSelectedColor or 1 )

	if isElement( ui.new_img ) then destroyElement( ui.new_img ) end

	ui.label_model:ibData("text", pConfig.model)

	local px, half_width = 280, ui.label_model:width()/2

	ui.btn_prev:ibData( "px", px - half_width - 20 )

	if pConfig.time_new and pConfig.time_new > getRealTimestamp() then
		ui.new_img = ibCreateImage( px + half_width, 259, 80, 44, ":nrp_business_carsell/img/new.png", ui.main )
		ui.btn_next:ibData( "px", px + half_width + 84 )
	else
		ui.btn_next:ibData( "px", px + half_width + 10 )
	end

	ui.power:ibData("text", pVariant.power.." кН")
	ui.max_speed:ibData("text", pVariant.max_speed.." км/ч")
	ui.consumption:ibData("text", pVariant.fuel_loss.." л")
	ui.cost:ibData("text", format_price(pVariant.cost) )

	ui.label_comment:ibData("text", vehicles_data[pAssortment[iAssortmentID].model_id] and vehicles_data[pAssortment[iAssortmentID].model_id].comment or "")
end

function UpdateVehicleColor( iColor )
	pData.iSelectedColor = iColor
	setVehicleColor( pData.pVehicle, unpack( pAvailableColors[iColor] ) )
end

function MarketKeyHandler( key, state )
	if not state then return end

	if key == "arrow_r" then
		local iNewID = pAssortment[ pData.iAssortmentID + 1 ] and pData.iAssortmentID + 1 or 1
		UpdateModel( iNewID )
	elseif key == "arrow_l" then
		local iNewID = pAssortment[ pData.iAssortmentID - 1 ] and pData.iAssortmentID - 1 or #pAssortment
		UpdateModel( iNewID )
	end
end