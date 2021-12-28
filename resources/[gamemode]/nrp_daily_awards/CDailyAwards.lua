loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

CASE_ITEMS_LIST = {
	lucky_box_mk1 = { "money:6000", "exp:650", "firstaid", "repairbox", "armor", "weapon_24" },
	lucky_box_mk2 = { "money:15000", "exp:900", "firstaid", "repairbox", "armor", "weapon_30", "weapon_34", "weapon_22", "premium:1 День" },
}

local scx, scy = guiGetScreenSize( )
local sizeX, sizeY = 800, 580
local posX, posY = ( scx - sizeX) / 2, ( scy - sizeY ) / 2
local ui, tex = { }, { }

local cached_data

function ShowUI( state, data, day )
	if state then
		--local data = { {1, 0}, {1, 0}, {1, 0}, {1, 0}, {1, 0}, {1, 0}, {1, 0} }

		ShowUI(false)

		local icons_list = { 
			icon_exp = { 52, 42 },
			icon_money = { 31, 26 },
		}
		showCursor(true)

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg.png" )
		ui.close = ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

		local px, py, sx, sy, sep = 0, 72, 266, 180, 1
		for i = 1, 7 do

			ui["day"..i] = ibCreateImage( px, py, sx, sy, nil, ui.main, 0x05FFFFFF )
			
			local day_bg = ibCreateImage( (sx-80)/2, 0, 80, 30, "files/img/day.png", ui["day"..i] )
			local day_label = ibCreateLabel( 0, 0, sx, 30, i.." день", ui["day"..i], 0xFFffffff, 1, 1, "center", "center" )
			day_label:ibData("font", ibFonts.bold_12)

			if i == 3 then
				local icon_box = ibCreateImage( 36, (sy-66)/2-10, 54, 66, "files/img/luckybox.png", ui["day"..i])
				local label_box = ibCreateLabel( 36+66+20, (sy-63)/2-10, 100, 63, "Lucky Box", ui["day"..i], 0xFFFFFFFF, 1, 1, "left", "center" )
				label_box:ibData("font", ibFonts.bold_14)
			elseif i == 7 then
				local icon_box = ibCreateImage( 80, (sy-90)/2, 74, 90, "files/img/luckybox2.png", ui["day"..i])
				local label_box = ibCreateLabel( 80+91+20, (sy-87)/2, 100, 87, "Lucky Box II", ui["day"..i], 0xFFFFFFFF, 1, 1, "left", "center" )
				label_box:ibData("font", ibFonts.bold_14)
			else
				local icon_money = ibCreateImage( 36, (sy-icons_list.icon_money[2])/2-10, icons_list.icon_money[1], icons_list.icon_money[2], "files/img/icon_money.png", ui["day"..i])
				local icon_exp = ibCreateImage( 145, (sy-icons_list.icon_exp[2])/2-10, icons_list.icon_exp[1], icons_list.icon_exp[2], "files/img/icon_exp.png", ui["day"..i] )

				local label_money = ibCreateLabel( 36+icons_list.icon_money[1]+10, (sy-icons_list.icon_money[2])/2-10, 100, icons_list.icon_money[2], AWARDS_LIST[i].money, ui["day"..i], 0xFFffffff, 1, 1, "left", "center" )
				label_money:ibData("font", ibFonts.bold_14)
				local label_exp = ibCreateLabel( 145+icons_list.icon_exp[1], (sy-icons_list.icon_exp[2])/2-10, 100, icons_list.icon_exp[2], AWARDS_LIST[i].exp, ui["day"..i], 0xFFffffff, 1, 1, "left", "center" )
				label_exp:ibData("font", ibFonts.bold_14)
			end

			if data[i][2] == 1 then
				local btn_tex = i == 3 and "files/img/btn_open_small.png" or i == 7 and "files/img/btn_open_small.png" or "files/img/btn_receive.png"
				local btn_receive = ibCreateButton( (sx-132)/2, sy-70, 132, 68, ui["day"..i], btn_tex, btn_tex, btn_tex, 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			
				addEventHandler( "ibOnElementMouseClick", btn_receive, function( key, state )
					if key ~= "left" or state ~= "up" then return end
					triggerServerEvent("DA:OnPlayerTakeAward", resourceRoot, localPlayer, i)
					ShowUI(false)
					ibClick()
				end, false)
			elseif data[i][2] == 0 then
				if i == day then
					local timer = ibCreateLabel( 0, sy-30, sx, 0, "Осталось ".. math.ceil(REQUIRED_DAILY_PLAYTIME-data[i][1]) .." минут", ui["day"..i], 0xFFFFFFFF, 1, 1, "center", "center" )
					timer:ibData("font", ibFonts.bold_12)
				else
					local overlay = ibCreateImage( 0, 0, sx, sy, nil, ui["day"..i], 0xAA3f5368 )
				end
			end

			px = px + sx + sep
			if i == 3 then
				px = 0
				py = py + sy + sep
			elseif i == 6 then
				px = 0
				py = py + sy + sep
				sx = sizeX
				sy = 150
			end
		end

		addEventHandler( "ibOnElementMouseClick", ui.close, function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ShowUI(false)
			ibClick()
		end, false)
	else
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		for k,v in pairs(tex) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		showCursor(false)
	end
end
addEvent("DA:ShowUI", true)
addEventHandler("DA:ShowUI", root, ShowUI)

function ShowCaseUI(state, case, item )
	if state then
		ShowUI(false)

		local sizeX, sizeY = 800, 580
		local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

		showCursor(true)

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg_"..case..".png" )
		--iprint(case)
		ui.close = ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		
		local case_names = {lucky_box_mk1 = "Lucky Box", lucky_box_mk2 = "Lucky Box II"}

		--ui.title = ibCreateLabel( 0, 280, sizeX-20, 0, case_names[case], ui.main, 0xFFFFFFFF, 1, 1, "center", "center" )
		--ui.title:ibData("font", ibFonts.bold_14)

		ui.btn_open = ibCreateButton( (sizeX-152)/2, 250, 152, 78, ui.main, "files/img/btn_open_big.png", "files/img/btn_open_big.png", "files/img/btn_open_big.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)

		local px, py = 40, 380
		for k,v in pairs(CASE_ITEMS_LIST[case]) do
			local box = ibCreateImage(px, py, 90, 90, "files/img/rounded_box.png", ui.main)

			local icon = "files/img/items/"..v..".png"
			if string.find(v, ":") then
				local pItem = split(v,":")
				icon = "files/img/items/"..pItem[1]..".png"
				local label = ibCreateLabel( 0, 75, 90, 0, pItem[2], box, 0xFFFFFFFF, 1, 1, "center", "center" )
				label:ibData("font", ibFonts.bold_12)
			end
			local icon = ibCreateImage( 0, 0, 129/2, 103/2, icon, box )
			icon:center()

			px = px + 100
			if px >= sizeX-140 then
				px = 40
				py = py + 100
			end
		end

		addEventHandler( "ibOnElementMouseClick", ui.close, function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ShowUI(false)
			ibClick()
		end, false)

		addEventHandler( "ibOnElementMouseClick", ui.btn_open, function( key, state )
			if key ~= "left" or state ~= "up" then return end
			triggerServerEvent("DA:OnPlayerOpenLuckyBox", resourceRoot, localPlayer, case)
			ibClick()

			ShowUI(false)
			showCursor(true)
			
			ui.main = ibCreateImage( (scx-963)/2, (scy-700)/2, 963, 700, "files/img/case_reward_bg.png" )

			local sItem = CASE_ITEMS_LIST[case][item]

			local icon = "files/img/items/"..sItem..".png"
			if string.find(sItem, ":") then
				local pItem = split(sItem,":")
				icon = "files/img/items/"..pItem[1]..".png"
				local label = ibCreateLabel( 0, (700-120)/2+80, 960, 0, pItem[2], ui.main, 0xFFFFFFFF, 1, 1, "center", "center" )
				label:ibData("font", ibFonts.bold_16)
			end
			local icon = ibCreateImage( (963-129)/2, (700-103)/2-30, 129, 103, icon, ui.main )

			ui.btn_take = ibCreateButton( (963-140)/2, 420, 140, 54, ui.main, "files/img/btn_take.png", "files/img/btn_take.png", "files/img/btn_take.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

			for k,v in pairs(ui) do
				if isElement(v) then
					v:ibData( "alpha", 0, true )
					v:ibAlphaTo( 255, 1000 )
				end
			end

			addEventHandler( "ibOnElementMouseClick", ui.btn_take, function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ShowUI(false)
				ibClick()
			end, false)

		end, false)
	else
		ShowUI(false)
	end
end
addEvent("DA:ShowCaseUI", true)
addEventHandler("DA:ShowCaseUI", root, ShowCaseUI)