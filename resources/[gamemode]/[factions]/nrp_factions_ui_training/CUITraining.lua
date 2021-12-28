loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CPlayer")
Extend("CInterior")
Extend( "ib" )
Extend( "ShUtils" )

local screen_size_x, screen_size_y = guiGetScreenSize()


local UI_elements = {}
local LIST = {}

local _training_name = nil
local _button_timeout = nil
local _scroll_position = 0

-- Фракции, которые видят только определенные id учений
LOCKED_FACTIONS_LIST = {
	[ F_GOVERNMENT_GORKI ] = {
		cityhall_rating_gorki = true,
	},
	[ F_GOVERNMENT_NSK ] = {
		cityhall_rating = true,
	},
	[ F_GOVERNMENT_MSK ] = {
		cityhall_rating_msk = true,
	}
}

addEventHandler( "onClientResourceStart", resourceRoot, function()
	for i, config in pairs( FACTIONS_TRAINING_MENU_POSITIONS ) do
		config.radius = 2
		config.z = config.z - 0.02
		config.marker_text = "Учения"

		info_marker = TeleportPoint( config )
		info_marker.text = "ALT Взаимодействие"
		info_marker.marker:setColor( 128, 128, 245, 100 )
		info_marker.element:setData( "material", true, false )
		info_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 128, 245, 255, 1.5 } )
		info_marker.PostJoin = function( self, player )
			if not localPlayer:IsInFaction() then return end
			if _training_name then return end

			local current_quest = localPlayer:getData( "current_quest" )
			if current_quest then
				localPlayer:ShowError( "У вас есть незаконченная задача" )
				return
			end

			 if not localPlayer:IsOnFactionDuty() then
			 	localPlayer:ShowError( "Вы не на смене" )
			 	return
			 end

			triggerServerEvent( "PlayerRequestLobbyList", resourceRoot )
		end
		info_marker.PostLeave = function( self, player )
			if isElement(UI_elements.bg_img) then
				if _training_name then
					triggerServerEvent( "PlayerWantLeaveLobby", resourceRoot, _training_name )
				end

				DestroyUI()
			end
		end
	end
end )

addEventHandler("onClientResourceStop", getResourceRootElement(), function()
	DestroyUI()
end)

function UITrainingList( lobby_list )
	if isElement(UI_elements.bg_img) then
		return
	end

	GenerateLobbyList( lobby_list )

	showCursor(true)
	ibInterfaceSound()

	UI_elements.black_bg = ibCreateBackground( 0x80495F76, DestroyUI, _, true )
	UI_elements.bg_img = ibCreateImage((screen_size_x - 750) / 2, (screen_size_y - 400) / 2, 750, 400, "images/bg.png", UI_elements.black_bg)

	UI_elements.button_close = ibCreateButton(547+150, 25, 24, 24, UI_elements.bg_img, 
		"images/button_close.png", "images/button_close.png", "images/button_close.png",
		0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF)
	:ibOnClick( function( button, state ) 
		if button == "left" and state == "up" then
			DestroyUI()
		end
	end)

	UI_elements.title = ibCreateLabel(30, 36, 0, 0, "Учения", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.bold_15)

	UI_elements.column_1 = ibCreateLabel(30, 105, 0, 0, "Название", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_9)

	UI_elements.column_2 = ibCreateLabel(270, 105, 0, 0, "Статус", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_9)

	UI_elements.column_3 = ibCreateLabel(370, 105, 0, 0, "Создатель", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_9)

	UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane(0, 120, 750, 224, UI_elements.bg_img, {scroll_px = -20})
 	UI_elements.scrollbar
        :ibSetStyle("slim_nobg")
        :ibBatchData({ sensivity = 100, absolute = true, color = 0x99ffffff})
        :UpdateScrollbarVisibility(UI_elements.scrollpane)

	local member = localPlayer:GetFaction()

	local iter = 1
	local function GenerateList( list )
		for i, lobby in ipairs( list ) do
			UI_elements[ "list_".. iter .."_bg" ] = ibCreateImage(0, 56 * (iter - 1), 755, 56, nil, 
				UI_elements.scrollpane, ( ( iter - 1 ) % 2 ) * 0x30000000
			)
			CreateLobbyItem(lobby, UI_elements[ "list_".. iter .."_bg" ])
			iter = iter + 1	
		end
	end

	local function FilterList( list, tasks )
		local result = { }
		for i, v in ipairs( list ) do
			if tasks[ v.id ] then
				table.insert( result, v )
			end
		end
		return result
	end

	GenerateList( LOCKED_FACTIONS_LIST[ member ] and FilterList( LIST, LOCKED_FACTIONS_LIST[ member ] ) or LIST )

	UI_elements.scrollpane:AdaptHeightToContents()
	UI_elements.scrollbar:UpdateScrollbarVisibility(UI_elements.scrollpane)

	UI_elements.timer = Timer( function()
		triggerServerEvent( "PlayerRequestLobbyList", resourceRoot )
	end, 4000, 0 )
end
addEvent("ShowUITrainingList", true)
addEventHandler("ShowUITrainingList", resourceRoot, UITrainingList)

function CreateLobbyItem(lobby, bg_element)

	local name = ibCreateLabel(30, 28, 180, 0, lobby.name, bg_element, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_11)

	local status = ibCreateLabel(270, 28, 0, 0, lobby.status, bg_element, 0x80ffffff, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_11)
	
	local creator = ibCreateLabel(370, 28, 0, 0, lobby.creator, bg_element, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_11)


	local button_select = ibCreateButton( 478 + 150, 14, 92, 27, bg_element,
		"images/button_select_idle.png", "images/button_select_hover.png", "images/button_select_click.png")
	:ibOnClick(function(button, state) 
		if button ~= "left" or state ~= "up" then return end

		if lobby.empty then
			triggerServerEvent( "PlayerWantCreateLobby", resourceRoot, lobby.id )
		elseif not lobby.started then
			triggerServerEvent( "PlayerWantEnterLobby", resourceRoot, lobby.id )
		end
	end)

	if lobby.started then
		button_select:ibData("disabled", true)
	end

	UI_elements.scrollpane:AdaptHeightToContents()
	UI_elements.scrollbar:UpdateScrollbarVisibility(UI_elements.scrollpane)
end

function UITrainingLobby( training_name, lobby_info, player_slot )
	local scroll_position = 0
	if isElement(UI_elements.bg_img) then
		if _training_name and isElement( UI_elements.scrollbar ) then
			scroll_position = UI_elements.scrollbar:ibData( "position" ) or 0
		end
		DestroyUI()
	end

	_training_name = training_name
	GenerateLobbyMembersList( _training_name, lobby_info )
	_button_timeout = getTickCount() + 1000

	showCursor(true)

	UI_elements.black_bg = ibCreateImage(0, 0, screen_size_x, screen_size_y, nil, nil, 0x80495F76)

	UI_elements.bg_img = ibCreateImage((screen_size_x - 755) / 2, (screen_size_y - 400) / 2, 755, 400, "images/bg.png", UI_elements.black_bg)

	UI_elements.button_close = ibCreateButton(547+150, 25, 24, 24, UI_elements.bg_img, 
		"images/button_close.png", "images/button_close.png", "images/button_close.png",
		0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF)
	:ibOnClick( function( button, state ) 
		if button ~= "left" or state ~= "up" then return end

		triggerServerEvent( "PlayerWantLeaveLobby", resourceRoot, _training_name )
		DestroyUI()
	end)


	UI_elements.title = ibCreateLabel(30, 36, 0, 0, "Учения / Лобби", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.bold_15)


	UI_elements.column_1 = ibCreateLabel(43, 105, 0, 0, "Ник", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_9)

	UI_elements.column_2 = ibCreateLabel(210, 105, 0, 0, "Звание", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_9)

	UI_elements.column_3 = ibCreateLabel(290, 105, 0, 0, "Роль", UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_9)

	UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane(0, 120, 755, 224, UI_elements.bg_img, {scroll_px = -20})
	UI_elements.scrollbar
        :ibSetStyle("slim_nobg")
        :ibBatchData({sensivity = 100, absolute = true, color = 0x99ffffff})
        :UpdateScrollbarVisibility(UI_elements.scrollpane)

	local count_ready = 0
	local max_count_ready = 0

	for i, lobby in pairs(lobby_info) do
		UI_elements[ "list_".. i .."_bg" ] = ibCreateImage(0, 56 * (i - 1), 755, 56, nil, UI_elements.scrollpane, ( ( i - 1 ) % 2 ) * 0x30000000)
		CreateLobbyMember( lobby, UI_elements[ "list_".. i .."_bg" ], i, player_slot, player_slot == i, player_slot == 1 )

		if lobby.ready then
			count_ready = count_ready + 1
		end

		if not lobby.uncritical or lobby.ready then
			max_count_ready = max_count_ready + 1
		end
	end

	UI_elements.scrollpane:AdaptHeightToContents()
	UI_elements.scrollbar:UpdateScrollbarVisibility(UI_elements.scrollpane):ibData( "position", scroll_position )

	max_count_ready = math.max( count_ready, max_count_ready )

	UI_elements.ready_text = ibCreateLabel(30, 372, 0, 0, "Готовность: ".. count_ready .." из ".. max_count_ready, 
		UI_elements.bg_img, count_ready == max_count_ready and 0xff98ff98 or 0xffff9898, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_11)

	if player_slot == 1 then
		UI_elements.button_start				= ibCreateButton(	478, 359, 92, 27, UI_elements.bg_img, 
			"images/button_start_idle.png", "images/button_start_hover.png", "images/button_start_click.png",
			0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
		):ibOnClick(function(button, state)
			if button ~= "left" or state ~= "up" then return end
			if _button_timeout > getTickCount() then return end

			triggerServerEvent( "PlayerWantStartTraining", resourceRoot, _training_name )
			DestroyUI()
		end)

		if count_ready < max_count_ready then
			UI_elements.button_start:ibData("disabled", true)
		end
	elseif player_slot then
		UI_elements.ready_text = ibCreateLabel(545, 372, 0, 0, "Готов?", 
			UI_elements.bg_img, lobby_info[ player_slot ].ready and 0xff98ff98 or 0xffff9898, 1, 1, "right", "center")
		:ibData("font", ibFonts.regular_11)
		
		ibCreateImage(552, 363, 18, 18, lobby_info[ player_slot ].ready and "images/checked.png" or "images/unchecked.png", UI_elements.bg_img )
		
		UI_elements.button_ready			= ibCreateButton(500, 363, 70, 18, UI_elements.bg_img,
			nil, nil, nil, 0x00FFFFFF, 0x10FFFFFF, 0x20FFFFFF)
		:ibOnClick(function(button, state)
			if button ~= "left" or state ~= "up" then return end
			if _button_timeout > getTickCount() then return end

			triggerServerEvent( "PlayerChgReadyState", resourceRoot, _training_name, player_slot )
		end)
	end

	if not player_slot then
		UI_elements.timer = Timer( function()
			triggerServerEvent( "PlayerWantEnterLobby", resourceRoot, training_name )
		end, 4000, 1 )
	end
end
addEvent("ShowUITrainingLobby", true)
addEventHandler("ShowUITrainingLobby", resourceRoot, UITrainingLobby)

function CreateLobbyMember( member, bg_element, slot, player_slot, current_slot, creator )
	if creator and current_slot then
		ibCreateImage( 13, 18, 22, 21, "images/icon_creator.png", bg_element )
	elseif not member.uncritical or not member.free then
		ibCreateImage( 15, 20, 18, 18, member.ready and "images/checked.png" or "images/unchecked.png", bg_element )
	end
	
	local name = ibCreateLabel( 43, 28, 160, 0, member.name, bg_element, 0xffc4f6af, 1, 1, "left", "center")
	:ibData("wordbreak", true):ibData("font", ibFonts.regular_11)


	if member.uncritical then
		local uncritical = ibCreateLabel(43, 43, 0, 0, "необязательный", bg_element, 0x80FFFFFF, 1, 1, "left", "center")
		:ibData("font", ibFonts.regular_9)
	end

	ibCreateImage(218, 16, 19, 23, ":nrp_factions_ui_info/images/ranks/".. FACTIONS_LEVEL_ICONS[ member.faction ] .."/".. member.level ..".png", bg_element )
	
	local role_text = ibCreateLabel(290, 28, 0, 0, member.role, bg_element, 0xFFFFFFFF, 1, 1, "left", "center")
	:ibData("font", ibFonts.regular_11)

	local button_slot_name = "exit"
	local size_x = 72
	if not current_slot then
		if creator then
			button_slot_name = "kick"
			size_x = 92
		else
			button_slot_name = "select"
			size_x = 92
		end
	end

	local button_select = ibCreateButton(478 + (92 - size_x) / 2, 14, size_x, 27, bg_element,
		"images/button_".. button_slot_name .."_idle.png", "images/button_".. button_slot_name .."_hover.png", "images/button_".. button_slot_name .."_click.png",
		0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
	:ibOnClick(function(button, state)
		if button ~= "left" or state ~= "up" then return end

		if current_slot then
			triggerServerEvent( "PlayerWantLeaveLobby", resourceRoot, _training_name )
			DestroyUI()
		else
			if creator then
				triggerServerEvent( "PlayerWantKickPlayerFromSlot", resourceRoot, _training_name, slot )
			else
				triggerServerEvent( "PlayerWantEnterLobby", resourceRoot, _training_name, slot, player_slot )
			end
		end
	end)
	

	if not current_slot or not player_slot then
		button_select:ibData( "disabled", creator == member.free )
	end
end

function DestroyUI()
	if isElement( UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
	end
	if isTimer( UI_elements.timer ) then killTimer( UI_elements.timer ) end
	UI_elements = { }
	
	_training_name = nil

	showCursor(false)
end
addEvent( "HideTrainingLobbyUI", true )
addEventHandler( "HideTrainingLobbyUI", resourceRoot, DestroyUI )

function GenerateLobbyList( lobby_list )
	LIST = { }

	for trainig_name, training_info in pairs( REGISTERED_FACTIONS_TRAINING ) do
		
		local trainig_id = "training_".. trainig_name .."_".. training_info[ 1 ][ 1 ]
		local resource = getResourceFromName( trainig_id )
		if resource and getResourceState( resource ) == "running" then
			local quest = exports[ trainig_id ]:GetQuestInfo( true )

			if quest then
				local lobby_info = lobby_list[ trainig_name ]

				if lobby_info and isElement( lobby_info.members[ 1 ] ) then
					local lobby_data = {
						id = trainig_name;

						name = quest.title;
						status = lobby_info.started and "Запущены" or "Сбор";
						creator = lobby_info.members[ 1 ]:GetNickName();

						started = lobby_info.started;
					}

					if lobby_info.started then
						table.insert( LIST, lobby_data )
					else
						table.insert( LIST, 1, lobby_data )
					end
				else
					local lobby_data = {
						id = trainig_name;

						name = quest.title;
						status = "Не создан";
						creator = "-";

						empty = true;
					}

					table.insert( LIST, lobby_data )
				end
			end
		end
	end
end

function GenerateLobbyMembersList( trainig_name, lobby_list )
	for i, training_info in ipairs( REGISTERED_FACTIONS_TRAINING[ trainig_name ] ) do
		local member_info = lobby_list[ i ]
		local trainig_id = "training_".. trainig_name .."_".. training_info[ 1 ]
		local resource = getResourceFromName( trainig_id )
		if resource and getResourceState( resource ) == "running" then
			local quest = exports[ trainig_id ]:GetQuestInfo( true )
			
			if member_info then
				member_info.role = quest.role_name
				member_info.free = false
			else
				lobby_list[ i ] = {
					name = "Свободно";
					faction = training_info[ 2 ];
					level = training_info[ 3 ];
					role = quest.role_name;
					uncritical = quest.training_uncritical;

					free = true;
				}
			end
		end
	end
end