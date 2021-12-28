loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CPlayer")
Extend("CVehicle")
Extend("ShVehicleConfig")
Extend("ShUtils")

local DGS = exports.DGS

local UI_elements = {}
local screen_size_x, screen_size_y = guiGetScreenSize()

local fonts

local function CreateFonts()
	fonts = {
		bold_14 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 14, false, "default");
		bold_25 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 25, false, "default");
		bold_30 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 30, false, "default");
		regular_16 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 16, false, "default");
		light_20 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Light.ttf", 20, false, "default");
	}
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

local player_enter_data = {
	start_city = 0;
	gender = 0;
	skin = 11;
	nickname = "Вася Иванов";
	birthday = 0;
}

local select_timeout = 0
local selected_city = 1
local selected_gender = 0
local selected_skin = 0

local sound_ambient = nil

local generated_city_elements = {}

--[[
	model = 415
	pos = 2211.393, y = -293.270, z = 60.296
	rot = 1.102, y = 359.946, z = 22.392

	pos = 2211.152, y = -288.388, z = 60.655
	rot = 10.5

	matrix =	2211.4733886719, -286.55078125, 60.946575164795,
				2218.6437988281, -385.998046875, 68.616539001465
]]

function ShowUIRegister()
	-- Шаг туториала -1 - до начала туториала
	--triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), -1 )

	CreateFonts()
	
	localPlayer.frozen = true
	localPlayer.position = CITY_HALL_PLAYER_POSITION

	sound_ambient = playSound("sounds/ambient.ogg", true)
	setSoundVolume(sound_ambient, 0.25)

	selected_city = 1

	localPlayer.interior = 0
	setCameraMatrix(2211.0733886719, -286.55078125, 60.946575164795, 2218.6437988281, -385.998046875, 68.616539001465)
	generated_city_elements[0] = createPed(SKINS_LIST[0][0][1], -2054.8, 1255.217, 16.162+1, -40)
	generated_city_elements[2] = createVehicle(579, -2058.443, 1253.338, 16.258+1, 0, 0, 325.5)
	setTimer(setVehicleColor, 500, 1, generated_city_elements[2], 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10)
	generated_city_elements[2]:setData( "CVehicle::m_pColor", { 10, 10, 10 } )
	if VEHICLE_CONFIG[579].custom_tuning then
		Timer(function()
			for _, tuning in pairs(VEHICLE_CONFIG[579].custom_tuning) do
				for _, info in ipairs(tuning) do
					generated_city_elements[2]:setComponentVisible(info.component, info.stock == true)
				end
			end
		end, 50, 1)
	end
	local sNumber = "01:в001ор77"
	generated_city_elements[2]:SetNumberPlate(sNumber)

	generated_city_elements[1] = createPed(SKINS_LIST[0][0][1], 2211.352, -288.388, 60.655, 10.5)
	generated_city_elements[3] = createVehicle(415, 2211.393, -293.270, 60.296, 1.102, 359.946, 22.392)
	setTimer(setVehicleColor, 200, 1, generated_city_elements[3], 25, 25, 112, 25, 25, 112, 25, 25, 112, 25, 25, 112)
	generated_city_elements[3]:setData( "CVehicle::m_pColor", { 25, 25, 112 } )
	if VEHICLE_CONFIG[415].custom_tuning then
		Timer(function()
			for _, tuning in pairs(VEHICLE_CONFIG[415].custom_tuning) do
				for _, info in pairs(tuning) do
					generated_city_elements[3]:setComponentVisible(info.component, info.stock == true)
				end
			end
		end, 50, 1)
	end
	local sNumber = "01:о777оо77"
	generated_city_elements[3]:SetNumberPlate(sNumber)

	for _, element in pairs(generated_city_elements) do
		element.dimension = localPlayer.dimension
	end

	fadeCamera( true )

	
	ShowSelectGender()
end
addEvent("ShowUIRegister", true)
addEventHandler("ShowUIRegister", root, ShowUIRegister)

--[[function ShowUISelectCity()
	DestroyUI()

	showCursor(true)

	false_texture		= dxCreateTexture("images/bg_gradient.png")
	false				= DGS:dgsCreateImage(	-80, (screen_size_y - 1080) / 2, 800, 1080,
																false_texture, false)
	DGS:dgsSetAlpha(false, 0)
	local _, y = DGS:dgsGetPosition(false)
	DGS:dgsMoveTo(false, 0, y, false, false, "Linear", 250)
	DGS:dgsAlphaTo(false, 1, false, "Linear", 250)

	UI_elements.label_city				= DGS:dgsCreateLabel(	80, 1080 / 2 - 245, 0, 0,
																"ВЫБОР ГОРОДА", false, false)
	DGS:dgsSetProperty(UI_elements.label_city, "textcolor", 0xFFFFFFFF)
	DGS:dgsSetProperty(UI_elements.label_city, "alignment", {"left","center"})
	DGS:dgsSetFont(UI_elements.label_city, fonts.bold_30)

	UI_elements.label_first_city		= DGS:dgsCreateLabel(	80, 1080 / 2 - 190, 145, 20,
																"Новороссийск", false, false)
	DGS:dgsSetProperty(UI_elements.label_first_city, "textcolor", selected_city == 0 and 0xFFFFFFFF or 0x80FFFFFF)
	DGS:dgsSetProperty(UI_elements.label_first_city, "alignment", {"left","center"})
	DGS:dgsSetFont(UI_elements.label_first_city, fonts.regular_16)

	addEventHandler("onDgsMouseClick", UI_elements.label_first_city, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if selected_city == 0 then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700
		selected_city = 0

		local _, y = DGS:dgsGetPosition(UI_elements.line_select_city)
		DGS:dgsMoveTo(UI_elements.line_select_city, 80, y, false, false, "Linear", 150)
		DGS:dgsSizeTo(UI_elements.line_select_city, 145, 1, false, false, "Linear", 150)
		DGS:dgsSetProperty(UI_elements.label_second_city, "textcolor", 0x80FFFFFF)
		DGS:dgsSetProperty(UI_elements.label_first_city, "textcolor", 0xFFFFFFFF)
		DGS:dgsSetText(UI_elements.label_desc, CITY_DISC[0])
		
		fadeCamera(false, 0.25)

		Timer(setCameraMatrix, 250, 1, -2053.1135253906, 1256.44921875, 16.702558898926+1, -2132.5905761719, 1195.7583007813, 16.982555389404+1)

		Timer(fadeCamera, 500, 1, true, 0.25)
	end)

	UI_elements.label_second_city		= DGS:dgsCreateLabel(	260, 1080 / 2 - 190, 128, 20,
																"Горки-Город", false, false)
	DGS:dgsSetProperty(UI_elements.label_second_city, "textcolor", selected_city == 1 and 0xFFFFFFFF or 0x80FFFFFF)
	DGS:dgsSetProperty(UI_elements.label_second_city, "alignment", {"left","center"})
	DGS:dgsSetFont(UI_elements.label_second_city, fonts.regular_16)

	addEventHandler("onDgsMouseClick", UI_elements.label_second_city, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if selected_city == 1 then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700

		selected_city = 1

		local _, y = DGS:dgsGetPosition(UI_elements.line_select_city)
		DGS:dgsMoveTo(UI_elements.line_select_city, 260, y, false, false, "Linear", 150)
		DGS:dgsSizeTo(UI_elements.line_select_city, 128, 1, false, false, "Linear", 150)
		DGS:dgsSetProperty(UI_elements.label_first_city, "textcolor", 0x80FFFFFF)
		DGS:dgsSetProperty(UI_elements.label_second_city, "textcolor", 0xFFFFFFFF)
		DGS:dgsSetText(UI_elements.label_desc, CITY_DISC[1])

		fadeCamera(false, 0.25)

		Timer(setCameraMatrix, 250, 1, 2211.3733886719, -286.55078125, 60.946575164795, 2218.6437988281, -385.998046875, 68.616539001465)

		Timer(fadeCamera, 500, 1, true, 0.25)
	end)

	UI_elements.line_select_city = DGS:dgsCreateImage(selected_city == 0 and 80 or 260, 1080 / 2 - 165, selected_city == 0 and 145 or 128, 1, nil, false, false, 0xFFFFFFFF)


	UI_elements.label_desc		= DGS:dgsCreateLabel(	80, 1080 / 2 - 100, 0, 0,
																CITY_DISC[selected_city], false, false)
	DGS:dgsSetProperty(UI_elements.label_desc, "textcolor", 0x99FFFFFF)
	DGS:dgsSetProperty(UI_elements.label_desc, "alignment", {"left","top"})
	DGS:dgsSetFont(UI_elements.label_desc, fonts.light_20)


	UI_elements.button_select_idle_tex = dxCreateTexture("images/button_select_idle.png")
	UI_elements.button_select_hover_tex = dxCreateTexture("images/button_select_hover.png")
	UI_elements.button_select_click_tex = dxCreateTexture("images/button_select_click.png")
	UI_elements.button_select = DGS:dgsCreateButton(	80, 1080 / 2 + 220, 184, 50,
													"", false, false, 0xFFFFFFFF, 1, 1,
													UI_elements.button_select_idle_tex, UI_elements.button_select_hover_tex, UI_elements.button_select_click_tex,
													0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)

	addEventHandler("onDgsMouseClick", UI_elements.button_select, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700

		player_enter_data.start_city = selected_city

		local _, y = DGS:dgsGetPosition(false)
		DGS:dgsMoveTo(false, -80, y, false, false, "Linear", 250)
		DGS:dgsAlphaTo(false, 0, false, "Linear", 250)
		Timer(ShowSelectGender, 250, 1)
		
		if selected_city == 0 then
			smoothMoveCamera(-2053.1135253906, 1256.44921875, 16.702558898926+1, -2132.5905761719, 1195.7583007813, 16.982555389404+1,
							-2053.3135253906, 1256.64921875, 16.702558898926+1, -2132.5905761719, 1195.7583007813, 16.982555389404+1, 500)
		else
			smoothMoveCamera(2211.3733886719, -286.55078125, 60.946575164795, 2218.6437988281, -385.998046875, 68.616539001465,
							2211.0733886719, -286.55078125, 60.946575164795, 2218.6437988281, -385.998046875, 68.616539001465, 500)
		end
	end)
end]]

function drawBG()
	UI_elements.background =  dxDrawImage(0 , 0, 400, 1080,
	"images/bg_gradient.png")
end

function ShowSelectGender()
	DestroyUI()

	-- Шаг туториала 1 - Показ выбора персонажа
	--triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 1 )

	showCursor(true)

	selected_gender = 0
	selected_skin = 0
	generated_city_elements[selected_city].model = SKINS_LIST[selected_gender][selected_skin][1]

	addEventHandler('onClientRender', root, drawBG)
	


	--[[false_texture		= dxCreateTexture("images/bg_gradient.png")
	false				= DGS:dgsCreateImage(	screen_size_x - 720, (screen_size_y - 1080) / 2, 800, 1080,
																false_texture, false)
	DGS:dgsSetProperty(false, "rotation", 180)
	DGS:dgsSetAlpha(false, 0)
	local _, y = DGS:dgsGetPosition(false)
	DGS:dgsMoveTo(false, screen_size_x - 800, y, false, false, "Linear", 250)
	DGS:dgsAlphaTo(false, 1, false, "Linear", 250)]]

	UI_elements.label_city				= DGS:dgsCreateLabel(	720, 1080 / 2 - 245, 0, 0,
																"ВЫБОР ПЕРСОНАЖА", false, false)
	DGS:dgsSetProperty(UI_elements.label_city, "textcolor", 0xFFFFFFFF)
	DGS:dgsSetProperty(UI_elements.label_city, "alignment", {"right","center"})
	DGS:dgsSetFont(UI_elements.label_city, fonts.bold_30)

	UI_elements.label_first_city		= DGS:dgsCreateLabel(	620, 1080 / 2 - 190, 100, 20,
																"Женский", false, false)
	DGS:dgsSetProperty(UI_elements.label_first_city, "textcolor", 0x80FFFFFF)
	DGS:dgsSetProperty(UI_elements.label_first_city, "alignment", {"right","center"})
	DGS:dgsSetFont(UI_elements.label_first_city, fonts.regular_16)

	addEventHandler("onDgsMouseClick", UI_elements.label_first_city, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700

		selected_gender = 1
		selected_skin = 0

		local len = dxGetTextWidth(SKINS_LIST[selected_gender][selected_skin][2], 1, fonts.regular_16)
		DGS:dgsSetPosition(UI_elements.button_prev, 660 - len, 1080 / 2 - 100, false)
		DGS:dgsSetText(UI_elements.label_skin_name, SKINS_LIST[selected_gender][selected_skin][2])
		
		generated_city_elements[selected_city].model = SKINS_LIST[selected_gender][selected_skin][1]

		local _, y = DGS:dgsGetPosition(UI_elements.line_select_city)
		DGS:dgsMoveTo(UI_elements.line_select_city, 630, y, false, false, "Linear", 150)
		DGS:dgsSetProperty(UI_elements.label_second_city, "textcolor", 0x80FFFFFF)
		DGS:dgsSetProperty(UI_elements.label_first_city, "textcolor", 0xFFFFFFFF)
	end)

	UI_elements.label_second_city		= DGS:dgsCreateLabel(	500, 1080 / 2 - 190, 100, 20,
																"Мужской", false, false)
	DGS:dgsSetProperty(UI_elements.label_second_city, "textcolor", 0xFFFFFFFF)
	DGS:dgsSetProperty(UI_elements.label_second_city, "alignment", {"right","center"})
	DGS:dgsSetFont(UI_elements.label_second_city, fonts.regular_16)

	addEventHandler("onDgsMouseClick", UI_elements.label_second_city, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700

		selected_gender = 0
		selected_skin = 0

		local len = dxGetTextWidth(SKINS_LIST[selected_gender][selected_skin][2], 1, fonts.regular_16)
		DGS:dgsSetPosition(UI_elements.button_prev, 660 - len, 1080 / 2 - 100, false)
		DGS:dgsSetText(UI_elements.label_skin_name, SKINS_LIST[selected_gender][selected_skin][2])
		
		generated_city_elements[selected_city].model = SKINS_LIST[selected_gender][selected_skin][1]

		local _, y = DGS:dgsGetPosition(UI_elements.line_select_city)
		DGS:dgsMoveTo(UI_elements.line_select_city, 510, y, false, false, "Linear", 150)
		DGS:dgsSetProperty(UI_elements.label_first_city, "textcolor", 0x80FFFFFF)
		DGS:dgsSetProperty(UI_elements.label_second_city, "textcolor", 0xFFFFFFFF)
	end)

	UI_elements.line_select_city		= DGS:dgsCreateImage(510, 1080 / 2 - 165, 90, 1,
															nil, false, false, 0xFFFFFFFF)


	local len = dxGetTextWidth(SKINS_LIST[selected_gender][selected_skin][2], 1, fonts.regular_16)
	UI_elements.button_prev_tex = dxCreateTexture("images/button_prev.png")
	UI_elements.button_prev = DGS:dgsCreateButton(	660 - len, 1080 / 2 - 100, 10, 16,
													"", false, false, 0xFFFFFFFF, 1, 1,
													UI_elements.button_prev_tex, UI_elements.button_prev_tex, UI_elements.button_prev_tex,
													0xFFFFFFFF, 0xF0FFFFFF, 0xA0FFFFFF)
	addEventHandler("onDgsMouseClick", UI_elements.button_prev, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700

		selected_skin = (selected_skin - 1) % (#SKINS_LIST[selected_gender] + 1)

		local len = dxGetTextWidth(SKINS_LIST[selected_gender][selected_skin][2], 1, fonts.regular_16)
		DGS:dgsSetPosition(UI_elements.button_prev, 660 - len, 1080 / 2 - 100, false)
		DGS:dgsSetText(UI_elements.label_skin_name, SKINS_LIST[selected_gender][selected_skin][2])

		generated_city_elements[selected_city].model = SKINS_LIST[selected_gender][selected_skin][1]
	end)

	UI_elements.label_skin_name			= DGS:dgsCreateLabel(	690, 1080 / 2 - 92, 0, 0,
																SKINS_LIST[selected_gender][selected_skin][2], false, false)
	DGS:dgsSetProperty(UI_elements.label_skin_name, "textcolor", 0xFFFFFFFF)
	DGS:dgsSetProperty(UI_elements.label_skin_name, "alignment", {"right","center"})
	DGS:dgsSetFont(UI_elements.label_skin_name, fonts.regular_16)

	UI_elements.button_next_tex = dxCreateTexture("images/button_next.png")
	UI_elements.button_next = DGS:dgsCreateButton(	704, 1080 / 2 - 100, 10, 16,
													"", false, false, 0xFFFFFFFF, 1, 1,
													UI_elements.button_next_tex, UI_elements.button_next_tex, UI_elements.button_next_tex,
													0xFFFFFFFF, 0xF0FFFFFF, 0xA0FFFFFF)
	addEventHandler("onDgsMouseClick", UI_elements.button_next, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700

		selected_skin = (selected_skin + 1) % (#SKINS_LIST[selected_gender] + 1)

		local len = dxGetTextWidth(SKINS_LIST[selected_gender][selected_skin][2], 1, fonts.regular_16)
		DGS:dgsSetPosition(UI_elements.button_prev, 660 - len, 1080 / 2 - 100, false)
		DGS:dgsSetText(UI_elements.label_skin_name, SKINS_LIST[selected_gender][selected_skin][2])

		generated_city_elements[selected_city].model = SKINS_LIST[selected_gender][selected_skin][1]
	end)

	UI_elements.button_select_idle_tex = dxCreateTexture("images/button_select_idle.png")
	UI_elements.button_select_hover_tex = dxCreateTexture("images/button_select_hover.png")
	UI_elements.button_select_click_tex = dxCreateTexture("images/button_select_click.png")
	UI_elements.button_select = DGS:dgsCreateButton(	536, 1080 / 2 + 220, 184, 50,
													"", false, false, 0xFFFFFFFF, 1, 1,
													UI_elements.button_select_idle_tex, UI_elements.button_select_hover_tex, UI_elements.button_select_click_tex,
													0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)

	addEventHandler("onDgsMouseClick", UI_elements.button_select, function(button, state)
		if button ~= "left" or state ~= "up" then return end
		if select_timeout > getTickCount() then return end

		select_timeout = getTickCount() + 700

		player_enter_data.start_city = selected_city;
		player_enter_data.gender = selected_gender;
		player_enter_data.skin = SKINS_LIST[selected_gender][selected_skin][1];
		PlayerSelectGender()
	end)
end

function PlayerSelectGender()
	fadeCamera(false, 0.25)
	-- затухание интерфейса

	removeEventHandler('onClientRender', root, drawBG)
	Timer(DestroyUI, 250, 1)

	Timer(function()
		setElementInterior(localPlayer, 1)
		setCameraMatrix(-32, -867.5, 1049, -29.872, -863.453, 1047.537)
	end, 250, 1)
	Timer(SetupCityHallRegister, 1250, 1)

	Timer(ShowUICityHall, 2500, 1)
end

function ShowUICityHall()
	if isElement(UI_elements.bg_img) then return end

	-- Шаг туториала 2 - Показ паспорта
	triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 2 )

	showCursor(true)

	UI_elements.bg_texture			= dxCreateTexture("images/pasport_bg.png")
	UI_elements.bg_img				= DGS:dgsCreateImage(	(screen_size_x - 575) / 2, (screen_size_y - 460) / 2, 575, 460,
															UI_elements.bg_texture, false, nil)
	DGS:dgsSetAlpha(UI_elements.bg_img, 0)
	DGS:dgsAlphaTo(UI_elements.bg_img, 1, false, "Linear", 1000)

	local clicked_edit_first_name = false
	UI_elements.edit_first_name = DGS:dgsCreateEdit(350, 90, 175, 28, "Имя",
													false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5, nil, 0x20000000)
	DGS:dgsSetFont(UI_elements.edit_first_name, fonts.bold_14)
	DGS:dgsEditSetWhiteList(UI_elements.edit_first_name, "[^а-яА-Яa-zA-Z$]")
	DGS:dgsEditSetMaxLength(UI_elements.edit_first_name, 16)
	addEventHandler("onDgsMouseClick", UI_elements.edit_first_name, function(button, state)
		if clicked_edit_first_name then return end

		clicked_edit_first_name = true
		DGS:dgsSetText(source, "")
	end)
	
	local clicked_edit_second_name = false
	UI_elements.edit_second_name = DGS:dgsCreateEdit(350, 140, 175, 28, "Фамилия",
													false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5, nil, 0x20000000)
	DGS:dgsSetFont(UI_elements.edit_second_name, fonts.bold_14)
	DGS:dgsEditSetWhiteList(UI_elements.edit_second_name, "[^а-яА-Яa-zA-Z$]")
	DGS:dgsEditSetMaxLength(UI_elements.edit_second_name, 16)
	addEventHandler("onDgsMouseClick", UI_elements.edit_second_name, function(button, state)
		if clicked_edit_second_name then return end

		clicked_edit_second_name = true
		DGS:dgsSetText(source, "")
	end)
	addEventHandler("onDgsEditSwitched", UI_elements.edit_second_name, function(button, state)
		if clicked_edit_second_name then return end

		clicked_edit_second_name = true
		DGS:dgsSetText(source, "")
	end)

	UI_elements.edit_day = DGS:dgsCreateEdit(	430, 190, 23, 25, "",
												false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5, nil, 0x20000000)
	DGS:dgsSetFont(UI_elements.edit_day, fonts.bold_14)
	DGS:dgsEditSetWhiteList(UI_elements.edit_day, "[^0-9$]")
	DGS:dgsEditSetMaxLength(UI_elements.edit_day, 2)
	
	UI_elements.edit_month = DGS:dgsCreateEdit(462, 190, 23, 25, "",
												false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5, nil, 0x20000000)
	DGS:dgsSetFont(UI_elements.edit_month, fonts.bold_14)
	DGS:dgsEditSetWhiteList(UI_elements.edit_month, "[^0-9$]")
	DGS:dgsEditSetMaxLength(UI_elements.edit_month, 2)

	UI_elements.edit_year = DGS:dgsCreateEdit(495, 190, 42, 25, "",
												false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5, nil, 0x20000000)
	DGS:dgsSetFont(UI_elements.edit_year, fonts.bold_14)
	DGS:dgsEditSetWhiteList(UI_elements.edit_year, "[^0-9$]")
	DGS:dgsEditSetMaxLength(UI_elements.edit_year, 4)

	UI_elements.label_sex	= DGS:dgsCreateLabel(	250, 202, 0, 0,
													player_enter_data.gender == 0 and "Муж." or "Жен.", false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5)
	DGS:dgsSetProperty(UI_elements.label_sex, "alignment", {"left","center"})
	DGS:dgsSetFont(UI_elements.label_sex, fonts.bold_25)

	UI_elements.label_city	= DGS:dgsCreateLabel(	528, 255, 0, 0,
													player_enter_data.start_city == 0 and "Новороссийск" or "Горки-Город", false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5)
	DGS:dgsSetProperty(UI_elements.label_city, "alignment", {"right","center"})
	DGS:dgsSetFont(UI_elements.label_city, fonts.bold_25)

	local time = getRealTime()
	time.month = time.month + 1
	UI_elements.label_reg_date	= DGS:dgsCreateLabel(45, 320, 0, 0,
													(time.monthday < 10 and "0" or "") .. time.monthday .."/".. (time.month < 10 and "0" or "") .. time.month .."/".. (1900 + time.year), false, UI_elements.bg_img, 0xFF000000, 0.5, 0.5)
	DGS:dgsSetProperty(UI_elements.label_reg_date, "alignment", {"left","center"})
	DGS:dgsSetFont(UI_elements.label_reg_date, fonts.bold_25)

	UI_elements.photo_texture		= dxCreateTexture(":nrp_documents/img/skins/".. (player_enter_data.skin or 1) ..".png")
	UI_elements.photo_img			= DGS:dgsCreateImage(	46, 82, 135, 150,
															UI_elements.photo_texture, false, UI_elements.bg_img)
	DGS:dgsSetAlpha(UI_elements.photo_img, 0)

	UI_elements.button_take_photo_tex = dxCreateTexture("images/button_take_photo.png")
	UI_elements.button_take_photo = DGS:dgsCreateButton(	46, 82, 135, 150,
															"", false, UI_elements.bg_img, 0xFFFFFFFF, 1, 1,
															UI_elements.button_take_photo_tex, UI_elements.button_take_photo_tex, UI_elements.button_take_photo_tex,
															0xFFFFFFFF, 0xFFFAFAFA, 0xFFF0F0F0)
	DGS:dgsAlphaTo(UI_elements.photo_img, 1, false, "InQuad", 2000)
	DGS:dgsSetVisible(UI_elements.button_take_photo, false)
	--[[addEventHandler("onDgsMouseClick", UI_elements.button_take_photo, function(button, state)
		if button ~= "left" or state ~= "up" then return end

		fadeCamera(false, 0.25, 255, 255, 255)
		
		Timer(fadeCamera, 250, 1, true, 0.5)
		playSound("sounds/photo.wav")
		DGS:dgsSetVisible(UI_elements.button_take_photo, false)
	end)]]

	UI_elements.button_enter_idle_tex = dxCreateTexture("images/button_take_idle.png")
	UI_elements.button_enter_hover_tex = dxCreateTexture("images/button_take_hover.png")
	UI_elements.button_enter_click_tex = dxCreateTexture("images/button_take_click.png")
	UI_elements.button_enter = DGS:dgsCreateButton(185, 360, 206, 56,
													"", false, UI_elements.bg_img, 0xFFFFFFFF, 1, 1,
													UI_elements.button_enter_idle_tex, UI_elements.button_enter_hover_tex, UI_elements.button_enter_click_tex,
													0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)

		addEventHandler('onClientClick', root, function(btn, state, ax, ay)
			if btn == "left" and state == "up" then 
			if isMouseInPosition(((screen_size_x - 575) / 2)+185, ((screen_size_y - 460) / 2) + 360, 206, 56) then 
			local first_name = DGS:dgsGetText(UI_elements.edit_first_name)
			local second_name = DGS:dgsGetText(UI_elements.edit_second_name)
	
			first_name = utf8.upper(utf8.sub(first_name, 1, 1)) .. utf8.lower(utf8.sub(first_name, 2))
			DGS:dgsSetText(UI_elements.edit_first_name, first_name)
			second_name = utf8.upper(utf8.sub(second_name, 1, 1)) .. utf8.lower(utf8.sub(second_name, 2))
			DGS:dgsSetText(UI_elements.edit_second_name, second_name)
	
			local check_nickname, error_reason = VerifyNickName(first_name, second_name)
	
			if not check_nickname then
				localPlayer:ShowError(error_reason)
				return
			end
	
			local day = tonumber(DGS:dgsGetText(UI_elements.edit_day)) or 0
			local month = tonumber(DGS:dgsGetText(UI_elements.edit_month)) or 0
			local year = tonumber(DGS:dgsGetText(UI_elements.edit_year)) or 0
			local check_birthday = VerifyBirthday(day, month, year)
	
			if not check_birthday then
				localPlayer:ShowError("Неверная дата рождения")
				return
			end
	
			if year > 2001 then
				localPlayer:ShowError( "Персонаж должен быть старше 18 лет" )
				return
			end
	
			if DGS:dgsGetVisible(UI_elements.button_take_photo) then
				localPlayer:ShowError("Ты забыл сделать фотографию в паспорт")
				return
			end
	
			player_enter_data.nickname = first_name .." ".. second_name
			player_enter_data.birthday = GetTimestamp(year, month, day, 0, 0, 0)
	
	
			localPlayer.frozen = false
	
			triggerServerEvent("PlayerEnterRegisterData", resourceRoot, player_enter_data)
		end
		end
		end)

	--[[addEventHandler("onDgsMouseClick", UI_elements.button_enter, function(button, state)
		if button ~= "left" or state ~= "up" then return end

		local first_name = DGS:dgsGetText(UI_elements.edit_first_name)
		local second_name = DGS:dgsGetText(UI_elements.edit_second_name)

		first_name = utf8.upper(utf8.sub(first_name, 1, 1)) .. utf8.lower(utf8.sub(first_name, 2))
		DGS:dgsSetText(UI_elements.edit_first_name, first_name)
		second_name = utf8.upper(utf8.sub(second_name, 1, 1)) .. utf8.lower(utf8.sub(second_name, 2))
		DGS:dgsSetText(UI_elements.edit_second_name, second_name)

		local check_nickname, error_reason = VerifyNickName(first_name, second_name)

		if not check_nickname then
			localPlayer:ShowError(error_reason)
			return
		end

		local day = tonumber(DGS:dgsGetText(UI_elements.edit_day)) or 0
		local month = tonumber(DGS:dgsGetText(UI_elements.edit_month)) or 0
		local year = tonumber(DGS:dgsGetText(UI_elements.edit_year)) or 0
		local check_birthday = VerifyBirthday(day, month, year)

		if not check_birthday then
			localPlayer:ShowError("Неверная дата рождения")
			return
		end

		if year > 2001 then
			localPlayer:ShowError( "Персонаж должен быть старше 18 лет" )
			return
		end

		if DGS:dgsGetVisible(UI_elements.button_take_photo) then
			localPlayer:ShowError("Ты забыл сделать фотографию в паспорт")
			return
		end

		player_enter_data.nickname = first_name .." ".. second_name
		player_enter_data.birthday = GetTimestamp(year, month, day, 0, 0, 0)


		localPlayer.frozen = false

		triggerServerEvent("PlayerEnterRegisterData", resourceRoot, player_enter_data)
	end)]]
end

local player_ped = nil

function PlayerRegisterCompleted(pRow)
	DestroyUI()

	-- Шаг туториала 3 - Ввод данных паспорта и нажатие "Получить паспорт"
	--triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 3 )

	smoothMoveCamera(-32, -867.5, 1049, -29.872, -863.453, 1047.537,
	-41.074901580811, -868.91748046875, 1048.9826660156, -41.200, -872.778, 1048, 2000)

	Timer(destroyElement, 2000, 1, player_ped)
	Timer(setCameraTarget, 2000, 1, localPlayer)
	setElementModel(localPlayer, SKINS_LIST[selected_gender][selected_skin][1])
	--player_enter_data.id = pRow.id
	--player_enter_data.intro = pRow.intro
	--player_enter_data.reg_date = pRow.reg_date
end
addEvent("PlayerRegisterCompleted", true)
addEventHandler("PlayerRegisterCompleted", root, PlayerRegisterCompleted)

function DestroyUI()
	if isElement(UI_elements.bg_img) then destroyElement(UI_elements.bg_img) end
	
	for _, element in pairs(UI_elements) do
		if isElement(element) then destroyElement(element) end
	end

	UI_elements = {}

	showCursor(false)
end


function VerifyNickName( sName, sLastName)
	if tonumber( sName ) then
		return false, "Имя не может состоять из цифр";
	end

	if utf8.upper( utf8.sub( sName, 1, 1 ) ) ~= utf8.sub( sName, 1, 1 ) then
		return false, "Имя должно начинаться с большой буквы";
	end

	if utfLen( sName ) > 16 then
		return false, "Имя не может быть длинее 16 символов";
	end

	if utfLen( sName ) < 3 then
		return false, "Имя не может быть короче 3 символов";
	end

	if not utf8.find( sName, "[а-яА-Я]+$" ) then
		return false, "Имя может содержать только буквы киррилицы.";
	end

	if tonumber( sLastName ) then
		return false, "Фамилия не может состоять из цифр";
	end

	if utf8.upper( utf8.sub( sLastName, 1, 1 ) ) ~= utf8.sub( sLastName, 1, 1 ) then
		return false, "Фамилия должна начинаться с большой буквы";
	end

	if utfLen( sLastName ) > 16 then
		return false, "Фамилия не может быть длинее 16 символов";
	end

	if utfLen( sLastName ) < 3 then
		return false, "Фамилия не может быть короче 3 символов";
	end

	if not utf8.find( sLastName, "[а-яА-Я]+$" ) then
		return false, "Фамилия может содержать только буквы киррилицы.";
	end

	if sName == sLastName then
		return false, "Имя и фамилия не могут быть равны";
	end

	if sName == "Имя" or sLastName == "Фамилия" then
		return false, "Нельзя использовать фамилию и имя из примера";
	end

	return true;
end

function VerifyBirthday(day, month, year)
	if day < 1 or day > 31 then return false end
	if month < 1 or month > 12 then return false end
	if year < 1930 or year > 2011 then return false end

	return true
end


local loaded_elements = {}
local exit_marker = nil

local marker_pulsar = 1

function SetupCityHallRegister()
	for i, bot in ipairs(CITY_HALL_BOTS) do
		loaded_elements[i] = createPed(bot.skin, bot.position, bot.rotation)
		loaded_elements[i].interior = localPlayer.interior
		loaded_elements[i].dimension = localPlayer.dimension
	end

	StartAnimPeds()

	fadeCamera(true, 2)

	exit_marker = createMarker( -40.984, -876.566, 1046.537, "cylinder", 2, 0, 255, 0, 255)
	exit_marker.interior = localPlayer.interior
	exit_marker.dimension = localPlayer.dimension

	addEventHandler("onClientMarkerHit", exit_marker, function(player, dim)
		if player ~= localPlayer or not dim then return end

		-- Шаг туториала 4 - Выход в город через маркер
		--triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 4 )
		
		fadeCamera(false, 1)
		--setTimer( triggerServerEvent, 1000, 1, "onPlayerVerifyReadyToSpawn_Callback", resourceRoot )
		--setTimer( triggerEvent, 1000, 1, "onPlayerVerifyReadyToSpawn", localPlayer )
		--onPlayerVerifyReadyToSpawn_Callback
		HWID = getPlayerSerial(player)
		SESSIONID = HWID
		setTimer( triggerServerEvent, 2000, 1, "OnClientPlayerReady", localPlayer, {HWID = HWID, SESSIONID = SESSIONID} )
		
		for i, bot in ipairs(loaded_elements) do
			destroyElement(bot)
		end

		if isElement(sound_ambient) then
			destroyElement(sound_ambient)
		end

		Timer(destroyElement, 3000, 1, exit_marker)
	end)

	Timer(function()
		if not isElement(exit_marker) then
			killTimer(sourceTimer)
			return
		end

		local r, g, b, a = exit_marker:getColor()
		if a >= 250 or a <= 5 then marker_pulsar = marker_pulsar * -1 end
		exit_marker:setColor(r, g, b, (a + 10 * marker_pulsar) % 256)
	end, 50, 0)


end

function StartAnimPeds()
	local ped_1 = createPed(15, -29.872, -865.691, 1047.537, 88)
	ped_1.interior = localPlayer.interior
	ped_1.dimension = localPlayer.dimension
	setPedControlState(ped_1, "walk", true)
	setPedControlState(ped_1, "forwards", true)

	Timer(destroyElement, 3000, 1, ped_1)


	player_ped = createPed(player_enter_data.skin, -29.872, -867, 1047.537)
	player_ped.interior = localPlayer.interior
	player_ped.dimension = localPlayer.dimension
	setPedControlState(player_ped, "walk", true)
	setPedControlState(player_ped, "forwards", true)

	Timer(function()
		player_ped.frozen = true
		setPedControlState(player_ped, "forwards", false)
	end, 1500, 1)
end


local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end
 
local function camRender()
	if (sm.moov == 1) then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientPreRender",root,camRender)
	end
end


function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	setTimer(removeCamHandler,time,1)
	setTimer(destroyElement,time,1,sm.object1)
	setTimer(destroyElement,time,1,sm.object2)
	addEventHandler("onClientPreRender",root,camRender)
	return true
end