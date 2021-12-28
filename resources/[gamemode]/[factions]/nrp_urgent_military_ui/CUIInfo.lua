
local UI_elements = {}
local LIST = {}

addEventHandler( "onClientResourceStart", resourceRoot, function()
	local config = {
		radius = 2,
		x = -2411.7803, y = -57.3902 + 860, z = 20.25;
		interior = 0;
		marker_text = "Служба";
		dimension = URGENT_MILITARY_DIMENSION;
	}

	info_marker = TeleportPoint( config )
	info_marker.keypress = "lalt"
	info_marker.text = "ALT Взаимодействие"
	info_marker.element:setData( "material", true, false )
	info_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 245, 128, 255, 1.6 } )
	info_marker.marker:setColor( 128, 245, 128, 100 )
	info_marker.PostJoin = function( self, player )
		UIInfo()
	end
	info_marker.PostLeave = function( self, player )
		DestroyUIInfo()
	end
end )

function UIInfo()
	if not localPlayer:IsInGame() then return end
	if not localPlayer:IsOnUrgentMilitary() then return end
	if isElement(UI_elements.bg_img) then return end

	GenerateQuestList()

	showCursor( true )

	UI_elements.black_bg = ibCreateImage( 0, 0, scX, scY, _, _, 0x80495F76 )
	UI_elements.bg_img = ibCreateImage( (scX - 600) / 2, (scY - 450) / 2, 600, 450, "images/info/bg.png", UI_elements.black_bg )

	UI_elements.button_close = ibCreateButton( 547, 25, 24, 24, UI_elements.bg_img, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )
	:ibOnClick( function(button, state)
		if button ~= "left" or state ~= "up" then return end
		DestroyUIInfo()
	end )

	UI_elements.button_leave = ibCreateButton( 400, 24, 117, 27, UI_elements.bg_img, "images/info/button_leave_idle.png", "images/info/button_leave_hover.png", "images/info/button_leave_hover.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )
	:ibOnClick( function(button, state)
		if button ~= "left" or state ~= "up" then return end
		ShowMilitaryLeaveConfirmation()
	end )

	local military_level = localPlayer:GetMilitaryLevel()

	UI_elements.rank_img = ibCreateImage( 32, 103, 62, 78, "images/info/ranks/".. military_level ..".png", UI_elements.bg_img )

	UI_elements.rank_name = ibCreateLabel( 115, 115, 0, 0, MILITARY_LEVEL_NAMES[ military_level ], UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_20 )
	UI_elements.exp_info = ibCreateLabel( 368, 174, 0, 0, localPlayer:GetMilitaryExp() .." / ".. localPlayer:GetMilitaryExpMax( military_level ), UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_10 )

	UI_elements.exp_progress_img = ibCreateImage( 120, 170, math.ceil( localPlayer:GetMilitaryExp() / localPlayer:GetMilitaryExpMax( military_level ) * 235 ), 10, _, UI_elements.bg_img, 0xFFEAB933 )

	for i, quest in ipairs( LIST ) do
		CreateQuestItem( quest, "list_".. i, 280 + 50 * (i - 1) )
	end

	SetTasksInfo()
	UI_elements.timer = Timer( SetTasksInfo, 1000, 0 )
end
addEvent( "ShowUIInfo", true )
addEventHandler( "ShowUIInfo", resourceRoot, UIInfo )

function CreateQuestItem( quest, prefix, pos_y )
	UI_elements[ prefix .."_name" ] = ibCreateLabel( 32, pos_y + 10, 0, 0, quest.name, UI_elements.bg_img, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_12 )
		
	UI_elements[ prefix .."_state" ] = ibCreateLabel( 32, pos_y + 30, 0, 0, "...", UI_elements.bg_img, quest.current and 0xFFE2DA7F or 0x80FFFFFF, 1, 1, "left", "center", ibFonts.regular_10 )
	
	if quest.rewards.military_exp then
		UI_elements[ prefix .."_reward" ] = ibCreateLabel( 472, pos_y + 15, 0, 0, "+ ".. quest.rewards.military_exp .." оч.", UI_elements.bg_img, 0xFF9AFFA4, 1, 1, "right", "center", ibFonts.regular_12 )
	end

	UI_elements.button_task_start = ibCreateButton( 487, pos_y, 83, 27, UI_elements.bg_img, 
		"images/info/button_task_start_idle.png", "images/info/button_task_start_hover.png", "images/info/button_task_start_click.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )		

	:ibOnClick( function(button, state)
		if button ~= "left" or state ~= "up" then return end
		triggerServerEvent( "PlayeStartQuest_".. quest.id, root )
		DestroyUIInfo()
	end )
end

function SetTasksInfo()
	if not isElement( UI_elements.bg_img ) then
		killTimer( sourceTimer )
		return
	end

	local server_timestamp = getRealTimestamp()

	for i, quest in ipairs(LIST) do
		local text_state = "Уже доступно"
		local enabled = true
		if quest.current then
			text_state = "Выполняется"
			enabled = false
		else
			if quest.completed and quest.replay_timeout and ( quest.completed + quest.replay_timeout ) > server_timestamp then
				local time_data = ConvertSecondsToTime( quest.completed + quest.replay_timeout - server_timestamp )
				text_state = "Доступно через: ".. ( time_data.minute > 0 and ( time_data.minute .." мин. " ) or "" ) .. time_data.second .." сек."
				enabled = false

			elseif quest.failed and quest.failed_timeout and ( quest.failed + quest.failed_timeout) > server_timestamp then
				local time_data = ConvertSecondsToTime( quest.failed + quest.failed_timeout - server_timestamp )
				text_state = "Доступно через: ".. ( time_data.minute > 0 and ( time_data.minute .." мин. " ) or "" ) .. time_data.second .." сек."
				enabled = false
			end
		end

		UI_elements[ "list_".. i .."_state" ]:ibData( "text", text_state )
		UI_elements.button_task_start:ibData( "disabled", not enabled )
	end
end

function DestroyUIInfo()
	if isElement( UI_elements.bg_img ) then destroyElement( UI_elements.bg_img ) end
	
	for _, element in pairs( UI_elements ) do
		if isElement( element ) then destroyElement( element ) end
	end

	UI_elements = { }

	showCursor( false )
end

function GenerateQuestList()
	LIST = { }
	local quests_info = localPlayer:GetQuestsData()

	for i, quest_name in ipairs( REGISTERED_URGENT_MILITARY_TASKS ) do
		local resource = getResourceFromName( "task_".. quest_name )
		if resource and getResourceState( resource ) == "running" then
			local quest = exports[ "task_".. quest_name ]:GetQuestInfo( true )
			
			if quest then
				local current_quest = localPlayer:getData( "current_quest" )
				local quest_data = {
					id = quest.id;

					name = quest.title;
					description = quest.description;

					completed = quests_info.completed[ quest.id ];
					failed = quests_info.failed[ quest.id ];
					current = current_quest and current_quest.id == quest.id;

					count_failed = quests_info.count_failed and quests_info.count_failed[ quest.id ] or 0;
					count_completed = quests_info.count_completed and quests_info.count_completed[ quest.id ] or 0;

					replay_timeout = quest.replay_timeout;
					failed_timeout = quest.failed_timeout;

					tutorial = quest.tutorial;

					rewards = quest.rewards;
				}

				if quest_data.completed and not quest_data.replay_timeout then
					table.insert( LIST, quest_data )

				elseif quest_data.current then
					table.insert( LIST, 1, quest_data )

				else
					if not LIST[ 1 ] or LIST[ 1 ].completed then
						table.insert( LIST, 1, quest_data )

					else
						table.insert( LIST, 2, quest_data )
					end
				end
			end
		end
	end
end


function ShowMilitaryLeaveConfirmation( )
	if not isElement( UI_elements.bg_img ) then return end

	local sx, sy = 600, 450

	local applypopup_bg = ibCreateImage( 0, 0, 600, 450, _, UI_elements.bg_img, 0xFA45596E )
	:ibData( "alpha", 0 )
	:ibAlphaTo( 255, 250, "InQuad" )
	table.insert(UI_elements, applypopup_bg)

	local label = ibCreateLabel( 0, 0, 600, 200, "Ты действительно хочешь\nпокинуть срочную службу?", applypopup_bg, 0xFFFFFFFF, 1, 1, "center", "bottom", ibFonts.bold_22 )
	:ibData( "wordbreak", true )

	local label_bttom = ibCreateLabel( 0, 390, 600, 250, "Прогресс будет утерян и ты не получишь военный билет", applypopup_bg, 0xFFFF9898, 1, 1, "center", "top", ibFonts.regular_15 )
	:ibData( "wordbreak", true )


	local apply = ibCreateButton( 170, 265, 105, 65, applypopup_bg, _, _, _, 0xFF558C5E, 0xFF4D8056, 0xFF3d6544 )	
	:ibOnClick( function(button, state)
		if button ~= "left" or state ~= "up" then return end
		DestroyUIInfo()
		triggerServerEvent( "PlayerWantMilitaryLeave", localPlayer )
	end )

	ibCreateLabel( 0, 0, 105, 65, "Да", apply, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )
	:ibData( "disabled", true )

	local cancel = ibCreateButton( 290, 265, 145, 65, applypopup_bg, _, _, _, 0xFF764949, 0xFF663F3F, 0xFF4E2F2F )	
	:ibOnClick( function(button, state)
		if button ~= "left" or state ~= "up" then return end

		if isElement( applypopup_bg ) then			
			applypopup_bg:ibAlphaTo( 255, 250, "OutQuad" )

			setTimer(function()
				if isElement( applypopup_bg ) then
					destroyElement( applypopup_bg )
				end
			end, 250, 1)
			UIInfo()
		end
	end )

	ibCreateLabel( 0, 0, 145, 65, "Отмена", cancel, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )
	:ibData( "disabled", true )
end