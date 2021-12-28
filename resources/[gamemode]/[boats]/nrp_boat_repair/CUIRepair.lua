local ui = {}
local pData = { details = {} }
local iLastClick = 0

function ShowUI_Workshop( state, data )
	if (data and data.on_foot) or not localPlayer.vehicle then
		ShowUI_OnFootWorkshop( state, data )
		return
	end

	if state then
		ShowUI_Workshop( false )

		for k, v in pairs(data) do
			pData[k] = v
		end

		local sType = pData.vehicle:GetSpecialType()
		local pPartsConf = PARTS_LIST[sType]

		local updated = {}

		for k,v in pairs(pData.details) do
			updated[k] = {}
			updated[k].cost = math.floor( v * pData.percent_cost )
			updated[k].selected = false
		end

		pData.details = updated

		local iSpaceLeft = pData.vehicle:GetMaxFuel() - pData.vehicle:GetFuel()
		local iRefillCost = math.floor( iSpaceLeft * FUEL_COST )
		pData.details.refill = 
		{
			cost = iRefillCost,
			selected = false,
		}

		toggleAllControls( false )

		addEventHandler("onClientKey", root, WorkshopKeyHandler)
		showCursor( true )
		localPlayer.vehicle.velocity = Vector3(0,0,-0.05)
		--local rx, ry, rz = getElementRotation( localPlayer.vehicle )
		--localPlayer.vehicle.rotation = Vector3(0,0,rz)

		ui.main = ibCreateImage( 0, 0, 1080, scy, "files/img/bg.png" ):ibData("alpha", 0):ibAlphaTo(255, 1000)
		ui.title = ibCreateLabel( 80, 100, 0, 0, "РЕМОНТ МОРСКОГО ТРАНСПОРТА", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_38)
		ui.label_list = ibCreateLabel( 80, 170, 0, 0, "СПИСОК ДЕТАЛЕЙ:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		
		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 80, 210, 600, 200, ui.main )

		local px, py = 0, 0
		for k, part in pairs(pData.details) do
			if k ~= "refill" then
				local item = ibCreateImage( px, py, 500, 30, nil, ui.scrollpane, 0x00000000 )
				ibCreateLabel( 0, 0, 0, 30, pPartsConf[k], item, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_18)
				ibCreateLabel( 200, 0, 0, 30, "Восстановление", item, 0xFFffde9e, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
				ibCreateLabel( 430, 0, 0, 30, format_price( part.cost ), item, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
				ibCreateImage( 390, 4 , 27, 23, "files/img/icon_money.png", item )

				ui["btn_select"..k] = ibCreateButton( 550, 4, 26, 26, item, "files/img/btn_select.png", "files/img/btn_select_active.png", "files/img/btn_select_active.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
				:ibOnClick( function( button, state ) 
					if button == "left" and state == "down" then
						part.selected = not part.selected
						source:ibData("texture", part.selected and "files/img/btn_select_active.png" or "files/img/btn_select.png")
						UpdateCost()
						ibClick()
					end
				end)
				py = py + 40
			end
		end

		ui.scrollpane:AdaptHeightToContents()
		ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )

		ui.btn_select_all = ibCreateButton( 560, 450, 97, 22, ui.main, "files/img/btn_select_all.png", "files/img/btn_select_all.png", "files/img/btn_select_all.png", 0xFFDDDDDD, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibOnClick( function( button, state ) 
			if button == "left" and state == "down" then
				for k,v in pairs(pData.details) do
					if k ~= "refill" then
						v.selected = true
						ui["btn_select"..k]:ibData("texture", "files/img/btn_select_active.png")
					end
				end
				UpdateCost()
				ibClick()
			end
		end)

		ui.label_refill = ibCreateLabel( 80, 550, 0, 0, "ЗАПРАВКА ЛОДКИ:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		local item = ibCreateImage( 80, 590, 500, 30, nil, ui.main, 0x00000000 )
		ibCreateLabel( 0, 0, 0, 30, "Заправить полный бак", item, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_18)
		ibCreateLabel( 430, 0, 0, 30, format_price( pData.details.refill.cost ), item, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
		ibCreateImage( 390, 4 , 27, 23, "files/img/icon_money.png", item )
		ibCreateButton( 550, 4, 26, 26, item, "files/img/btn_select.png", "files/img/btn_select_active.png", "files/img/btn_select_active.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibOnClick( function( button, state ) 
			if button == "left" and state == "down" then
				pData.details.refill.selected = not pData.details.refill.selected
				source:ibData("texture", pData.details.refill.selected and "files/img/btn_select_active.png" or "files/img/btn_select.png")
				UpdateCost()
				ibClick()
			end
		end)

		ui.label_total_cost = ibCreateLabel( 80, 700, 0, 0, "Общая стоимость:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.total_cost = ibCreateLabel( 140, 740, 0, 0, "0", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_21)
		ui.icon_money = ibCreateImage( 80, 725, 36, 30, "files/img/icon_money_big.png", ui.main )

		ui.btn_pay = ibCreateButton( 470, 710, 194, 50, ui.main, "files/img/btn_pay.png", "files/img/btn_pay.png", "files/img/btn_pay.png", 0xFFDDDDDD, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibOnClick( function( button, state ) 
			if button == "left" and state == "down" then
				if getTickCount() - iLastClick <= 6000 then return end

				local iTotalParts = 0
				local pSelectedParts = {}
				for k,v in pairs(pData.details) do
					if v.selected then
						table.insert(pSelectedParts, k)
						iTotalParts = iTotalParts + 1
					end
				end

				ibClick()

				if iTotalParts < 1 then
					localPlayer:ShowError("Ты ничего не выбрал")
					return false
				end

				iLastClick = getTickCount()

				triggerServerEvent( "OnPlayerTryRepairSpecialBoatVehicle", localPlayer, { vehicle = pData.vehicle, parts = pSelectedParts } )
			end
		end)

	else
		if isElement(ui.main) then
			toggleAllControls( true )
			DisableHUD(false)
			--setPlayerHudComponentVisible( "radar", true )
			removeEventHandler("onClientKey", root, WorkshopKeyHandler)

			showCursor(false)
		end

		DestroyTableElements( ui )
		DestroyTableElements( pData )
		pData.on_foot = false
	end
end
addEvent("ShowUI_SpecialBoatWorkshop", true)
addEventHandler("ShowUI_SpecialBoatWorkshop", root, ShowUI_Workshop)

function UpdateCost()
	local iTotalCost = 0

	if pData.on_foot then
		for i, vehicle in pairs(pData.vehicles) do
			for k,v in pairs(vehicle.operations) do
				if v.selected then
					iTotalCost = iTotalCost + v.cost
				end
			end
		end
	else
		for k,v in pairs(pData.details) do
			if v.selected then
				iTotalCost = iTotalCost + v.cost
			end
		end
	end

	ui.total_cost:ibData("text", format_price(iTotalCost) )
end

function ShowUI_OnFootWorkshop( state, data )
	if state then
		ShowUI_OnFootWorkshop( false )

		for k, v in pairs(data) do
			pData[k] = v
		end

		for k,v in pairs( pData.vehicles ) do
			v.operations = {}

			local pVehicleConf = VEHICLE_CONFIG[ v.model ]
			local iSpaceLeft = (pVehicleConf.fuel or 100) - v.fuel

			local iRefillCost = math.floor( iSpaceLeft * FUEL_COST )
			v.operations.refill = 
			{
				name = "Заправка",
				cost = iRefillCost,
				selected = false,
			}


			local iTotalCost = VEHICLE_CONFIG[ v.model ].variants[ 1 ].cost * REPAIR_COST_MUL
			local fDamagePercent = 1 - math.floor(v.health) / 1000
			local iRepairCost = math.floor( fDamagePercent * iTotalCost )

			v.operations.repair = 
			{
				name = "Ремонт",
				cost = iRepairCost,
				selected = false,
			}
		end

		showCursor(true)
		DisableHUD(true)
		--setPlayerHudComponentVisible( "radar", false )
		toggleAllControls( false )
		localPlayer.frozen = true
		addEventHandler("onClientKey", root, WorkshopKeyHandler)

		ui.main = ibCreateImage( 0, 0, 1080, scy, "files/img/bg.png" )
		ui.title = ibCreateLabel( 80, 100, 0, 0, "МАСТЕРСКАЯ", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_38)
		ui.label_vehicle = ibCreateLabel( 50, 270, 0, 0, "Название:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.label_operation = ibCreateLabel( 280, 270, 0, 0, "Вид услуги:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.label_cost = ibCreateLabel( 430, 270, 0, 0, "Стоимость:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		
		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 310, 600, 200, ui.main )

		local px, py = 0, 0

		for i, vehicle in pairs(pData.vehicles) do
			local pVehicleConf = VEHICLE_CONFIG[ vehicle.model ]

			local g_item = ibCreateImage( px, py, 600, 90, nil, ui.scrollpane, i/2 == math.floor(i/2) and 0x00000000 or 0x40314050 )
			ibCreateLabel( 50, 0, 0, 90, pVehicleConf.model, g_item, 0xFFFFFFFF, 1, 1, "left", "center"):ibData("font", ibFonts.bold_18)
			local pby = 0
			for k, v in pairs(vehicle.operations) do
				local item = ibCreateImage( 0, pby, 500, 45, nil, g_item, 0x00000000 )
				ibCreateLabel( 260, 0, 0, 45, v.name, item, 0xFFffde9e, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
				ibCreateLabel( 440, 0, 0, 45, format_price( v.cost ) or 10000, item, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_16)
				ibCreateImage( 400, 12 , 27, 23, "files/img/icon_money.png", item )
			
				ui["btn_select"..k] = ibCreateButton( 550, 4, 26, 26, item, "files/img/btn_select.png", "files/img/btn_select_active.png", "files/img/btn_select_active.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
				:ibOnClick( function( button, state ) 
					if button == "left" and state == "down" then
						if v.cost <= 0 then return end

						if k == "refill" and not GetVehicle( vehicle.id ) then
							localPlayer:ShowError("Заправить можно только вызванный транспорт")
							return
						end

						v.selected = not v.selected
						source:ibData("texture", v.selected and "files/img/btn_select_active.png" or "files/img/btn_select.png")
						UpdateCost()
						ibClick()
					end
				end)
				pby = pby + 45
			end
			py = py + 90
		end

		ui.scrollpane:AdaptHeightToContents()
		ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )

		ui.label_total_cost = ibCreateLabel( 80, 700, 0, 0, "Общая стоимость:", ui.main, 0x70FFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_16)
		ui.total_cost = ibCreateLabel( 140, 740, 0, 0, "0", ui.main, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.bold_21)
		ui.icon_money = ibCreateImage( 80, 725, 36, 30, "files/img/icon_money_big.png", ui.main )

		ui.btn_pay = ibCreateButton( 420, 710, 194, 50, ui.main, "files/img/btn_pay.png", "files/img/btn_pay.png", "files/img/btn_pay.png", 0xFFDDDDDD, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibOnClick( function( button, state ) 
			if button == "left" and state == "down" then
				if getTickCount() - iLastClick <= 6000 then return end

				local iTotalParts = 0
				local pSelectedOperations = {}

				for i, vehicle in pairs(pData.vehicles) do
					for k,v in pairs(vehicle.operations) do
						if v.selected then
							table.insert(pSelectedOperations, { action = k, id = vehicle.id, cost = v.cost } )
							iTotalParts = iTotalParts + 1
						end
					end
				end

				ibClick()

				if iTotalParts < 1 then
					localPlayer:ShowError("Ты ничего не выбрал")
					return false
				end

				iLastClick = getTickCount()

				triggerServerEvent( "OnPlayerTryRepairSpecialBoatVehicle", localPlayer, { on_foot = true, operations = pSelectedOperations } )
			end
		end)
	else
		if isElement(ui.main) then
			removeEventHandler("onClientKey", root, WorkshopKeyHandler)
			showCursor(false)
			toggleAllControls( true )
			localPlayer.frozen = false
			DisableHUD(false)
			--setPlayerHudComponentVisible( "radar", true )
		end

		DestroyTableElements( ui )
		DestroyTableElements( pData )
		pData.on_foot = false
	end
end

function WorkshopKeyHandler( key, state )
	if key == "escape" and state then
		cancelEvent()
		if pData.on_foot then
			ShowUI_OnFootWorkshop( false ) 
		else 
			ShowUI_Workshop( false )
		end
	end
end

--ShowUI_OnFootWorkshop( true, { vehicles = { "SS" } } )
--ShowUI_Workshop( true, { vehicle = localPlayer.vehicle, workshop_id = 1 } )