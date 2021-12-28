Extend("ShUtils")
Extend("CPlayer")
Extend("CUI")
Extend("ib")

scx, scy = guiGetScreenSize()

icon_soft = ":nrp_shared/img/money_icon.png"
icon_hard = ":nrp_shared/img/hard_money_icon.png"

local ui = {}

local icon_sizes = {}

local pIconTextures = 
{
	"icon_fish_1",
	"icon_fish_2",
	"icon_fish_3",
	"icon_box_1",
	"icon_box_2",
	"icon_box_3",
	"icon_fur",
	"icon_horns",
	"icon_meat",
}

function GetIconSizes()
	for k,v in pairs(pIconTextures) do
		local img = dxCreateTexture( "files/img/items/"..v..".png" )
		local w, h = dxGetMaterialSize( img )
		destroyElement( img )

		icon_sizes["files/img/items/"..v..".png"] = { w, h }
	end
end

function ShowUI_ItemReceived( state, item )
	if state then
		if not next(icon_sizes) then
			GetIconSizes()
		end

		playSound( ":nrp_shop/sfx/reward_small.mp3" )

		ui.main = ibCreateImage( 0, 0, scx, scy, "files/img/bg_reward.png" ):ibData("alpha", 0)
		ui.main:ibAlphaTo(255, 2000)

		local icon_path = "files/img/items/icon_"..item.icon..".png"
		local sx, sy = unpack( icon_sizes[icon_path] )
		ui.icon = ibCreateImage( scx/2-sx/2, scy/2-sy/2, sx, sy, icon_path, ui.main )

		ui.title = ibCreateLabel( scx/2, scy/2-sy-30, 0, 0, "Поздравляем! Ваша добыча:", ui.main, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_18)
		ui.name = ibCreateLabel( scx/2, scy/2-sy, 0, 0, item.name, ui.main, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_18)

		ui.weight = ibCreateLabel( scx/2, scy/2+sy, 0, 0, " Вес: ".. math.floor(item.weight*10)/10 .." кг.", ui.main, 0xFFEEEEEE, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_16)

		ui.btn_take = ibCreateButton( scx/2-70, scy/2+sy+40, 140, 54, ui.main, "files/img/btn_take.png", "files/img/btn_take.png", "files/img/btn_take.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

		local iCurrentLevel = localPlayer:GetHobbyLevel(item.hobby)
		local iCurrentExp = localPlayer:GetHobbyExp(item.hobby)-item.exp
		local fProgress = 1

		local pNextLevelData = HOBBY_LEVELS[item.hobby][iCurrentLevel + 1]
		if pNextLevelData then
			fProgress = math.max(0, iCurrentExp / pNextLevelData.exp or 0)
		end

		local fDelta = pNextLevelData and (item.exp / pNextLevelData.exp) or 0

		ui.l_your_progress = ibCreateLabel( scx/2-300, scy-130, 0, 20, "Ваш прогресс", ui.main, 0xDDFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_12)
		ui.l_exp = ibCreateLabel( scx/2+300, scy-130, 0, 20, "+"..item.exp, ui.main, 0xDDFFFFFF, 1, 1, "right", "center" ):ibData("font", ibFonts.regular_12)

		ui.progress_bar_bg = ibCreateImage( scx/2-300, scy-100, 600, 14, nil, ui.main, 0x40000000)
		ui.progress_bar_body = ibCreateImage( 0, 0, 600*fProgress, 14, nil, ui.progress_bar_bg, 0xFF47afff)
		ui.progress_bar_delta = ibCreateImage( 600*fProgress, 0, 0, 14, nil, ui.progress_bar_bg, 0xFF3bee87)

		setTimer(function()
			if isElement(ui.progress_bar_delta) then
				ui.progress_bar_delta:ibResizeTo( 600*fDelta, 14, 1000, "Linear" )
			end
		end, 2000, 1)

		addEventHandler( "ibOnElementMouseClick", ui.btn_take, function( key, state )
			if key ~= "left" or state ~= "down" then return end
			ShowUI_ItemReceived( false )
			ibClick()
		end, false )
		showCursor(true)
	else
		for k,v in pairs( ui ) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		showCursor(false)
	end
end
addEvent("HB:OnClientItemReceived", true)
addEventHandler("HB:OnClientItemReceived", resourceRoot, ShowUI_ItemReceived)

function ShowUI_ItemsSold( state, data )
	if state then
		HobbyEquipment_ShowUI(false)
		HobbyStore_ShowUI(false)
		
		playSound( ":nrp_shared/sfx/fx/buy.wav" )
		ui.main = ibCreateImage( 0, 0, scx, scy, "files/img/bg_reward.png" ):ibData("alpha", 0)
		ui.main:ibAlphaTo(255, 2000)

		ui.title = ibCreateLabel( scx/2, scy/3, 0, 0, "Поздравляем!\nВы продали добычу на:", ui.main, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_18)

		ui.cost = ibCreateLabel( scx/2-45, scy/2-20, 0, 0, format_price(data.cost), ui.main, 0xEE97ee85, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_60)
		ui.icon = ibCreateImage( scx/2+ui.cost:width()/2-35, scy/2-55, 90, 75, "files/img/icon_money_big.png", ui.main )

		ui.weight = ibCreateLabel( scx/2, scy/2+110, 0, 0, " Общий вес проданной добычи: ".. math.floor(data.weight*10)/10 .." кг.", ui.main, 0xFFEEEEEE, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_12)

		ui.btn_take = ibCreateButton( scx/2-70, scy/2+150, 140, 54, ui.main, "files/img/btn_take.png", "files/img/btn_take.png", "files/img/btn_take.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

		addEventHandler( "ibOnElementMouseClick", ui.btn_take, function( key, state )
			if key ~= "left" or state ~= "down" then return end
			ShowUI_ItemsSold( false )
		end, false )
		showCursor(true)
	else
		for k,v in pairs( ui ) do
			if isElement(v) then
				destroyElement( v )
			end
		end
		showCursor(false)
	end
end
addEvent("HB:OnClientItemsSold", true)
addEventHandler("HB:OnClientItemsSold", resourceRoot, ShowUI_ItemsSold)

function OnClientHobbyItemUnlocked()
	playSound( ":nrp_shared/sfx/fx/buy.wav" )
end
addEvent("OnClientHobbyItemUnlocked", true)
addEventHandler("OnClientHobbyItemUnlocked", root, OnClientHobbyItemUnlocked)