loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "CInterior" )
Extend( "ShUtils" )
Extend( "ib" )

ibUseRealFonts( true )

local UI = { }
local LIST = { }

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
	for i, config in pairs( FACTIONS_INFO_MENU_POSITIONS ) do
		config.radius = 2
		config.marker_text = "Начало смены"
		config.keypress = "lalt"
		config.text = "ALT Взаимодействие"

		info_marker = TeleportPoint( config )
		info_marker.marker:setColor( 128, 128, 245, 100 )

		info_marker:SetImage( "images/marker.png" )
		info_marker.element:setData( "material", true, false )
		info_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 128, 245, 255, 1.5 } )

		info_marker.PostJoin = function( self, player )
			if not localPlayer:IsInGame( ) then return end
			if config.faction ~= localPlayer:GetFaction( ) then return end
			
			if localPlayer:IsOnFactionDuty( ) and localPlayer:GetFactionDutyCity( ) ~= config.city then
				localPlayer:ShowInfo( "Вы уже начали смену в другом городе" )
				return
			end

			UIInfo( config.city )

			if localPlayer:IsOnFactionDayOff( ) then
				triggerEvent( "onClientShowDayOffWindow", localPlayer )
			end
		end
		info_marker.PostLeave = function( self, player )
			DestroyUIInfo( )
		end
	end
end )

function UIInfo( city, duty )
	if isElement( UI.bg_img ) then
		return
	end

	-- generate quest's list
	local faction_id = localPlayer:GetFaction( )
	local faction_level = localPlayer:GetFactionLevel( )
	local faction_exp = localPlayer:GetFactionExp( )
	local faction_max_exp = localPlayer:GetFactionExpMax( faction_level )

	GenerateQuestList( faction_id )

	-- background
	UI.black_bg = ibCreateBackground( 0xBF1D252E, DestroyUIInfo, _, true )

	-- main window
	UI.bg_img = ibCreateImage( 0, 0, 600, 450, "images/bg.png", UI.black_bg )
	:ibSetRealSize( ):center( )

	-- close
	UI.button_close = ibCreateButton( 972, 34, 22, 22, UI.bg_img, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "up" then
			return
		end

		ibClick( )
		DestroyUIInfo( )
	end, false )

	-- menu
	UI.menu = ibCreateArea( 0, 146, 0, 0, UI.bg_img )

	-- line
	ibCreateImage( 30, 0, 964, 1, nil, UI.menu, 0x22ffffff )

	-- orange shadow
	local shadow = ibCreateImage( 30, -3, 4, 4, nil, UI.menu, 0xffff965d )

	-- tabs
	UI.render_target = ibCreateRenderTarget( 0, 147, 1024, 573, UI.bg_img )

	UI.tabs = { }
	local tabs = {
		{
			to = "stats",
		  	name = "Статистика",
			selected = true,
			draw = function ( self, state, anim_offset )
				local name = self.to
				local current_state = isElement( UI.tabs[ name ] )

				if not state and current_state then
					UI.tabs[ name ]:ibAlphaTo( 0, 250 ):ibMoveTo( anim_offset, nil, 250 ):ibData( "priority", 0 )

				elseif state and current_state then
					UI.tabs[ name ]:ibAlphaTo( 255, 250 ):ibMoveTo( 0, nil, 250 ):ibData( "priority", 1 )

				elseif state and not current_state then
					UI.tabs[ name ] = ibCreateArea( anim_offset, 0, 1024, 573, UI.render_target )
					:ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibMoveTo( 0, nil, 250 ):ibData( "priority", 1 )

					local rank_img_path = "images/ranks/" .. FACTIONS_LEVEL_ICONS[ faction_id ] .. "/" .. faction_level .. ".png"
					ibCreateImage( 30, 42, 62, 77, rank_img_path, UI.tabs[ name ] )

					local lbl_level_name = ibCreateLabel( 113, 51, 0, 0, FACTIONS_LEVEL_NAMES[ faction_id ][ faction_level ],
						UI.tabs[ name ], 0xfff3d88f, nil, nil, nil, "center", ibFonts.bold_18 )

					ibCreateButton( 136 + lbl_level_name:width( ), 48, 90, 11, UI.tabs[ name ],
					"images/button_all_ranks.png", "images/button_all_ranks.png", "images/button_all_ranks.png",
					0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
					:ibOnClick( function( button, state )
						if button ~= "left" or state ~= "up" then
							return
						end

						DestroyUIInfo( )
						triggerEvent( "ShowUIFactionRanksList", root, true, faction_id, faction_exp )
					end )

					ibCreateLabel( 113, 89, 0, 0, "Очков до следующего звания:", UI.tabs[ name ],
						ibApplyAlpha( nil, 40 ), nil, nil, nil, "center", ibFonts.regular_14 )

					ibCreateImage( 113, 107, 245, 11, nil, UI.tabs[ name ], ibApplyAlpha( 0xff1f2934, 50 ) )

					local exp_sx = faction_max_exp and math.ceil( math.min( 1, faction_exp / faction_max_exp ) * 245 ) or 245
					ibCreateImage( 113, 107, exp_sx, 11, nil, UI.tabs[ name ], 0xffff965d )

					ibCreateLabel( 366, 112, 0, 0, faction_max_exp and ( faction_exp .. " / " .. faction_max_exp ) or "MAX",
						UI.tabs[ name ], ibApplyAlpha( nil, 40 ), nil, nil, nil, "center", ibFonts.regular_14 )

					ibCreateImage( 0, 160, 1024, 413, nil, UI.tabs[ name ], ibApplyAlpha( 0xff000000, 10 ) )
					ibCreateImage( 0, 160, 1024, 1, nil, UI.tabs[ name ], ibApplyAlpha( nil, 10 ) )
					ibCreateImage( 0, 225, 1024, 1, nil, UI.tabs[ name ], ibApplyAlpha( nil, 10 ) )
					ibCreateImage( 216, 181, 24, 24, "images/icon_star.png", UI.tabs[ name ] )
					ibCreateLabel( 30, 193, 0, 0, "Задачи на сегодня", UI.tabs[ name ], nil, nil, nil, nil, "center", ibFonts.bold_18 )

					local scrollpane, scrollbar = ibCreateScrollpane( 0, 226, 1024, 347, UI.tabs[ name ], { scroll_px = -20 } )
					scrollbar:ibSetStyle( "slim_small_nobg" ):ibTimer( SetTasksInfo, 50, 0 )

					local current_quest = localPlayer:getData( "current_quest" )
					for i, quest in ipairs( LIST ) do
						CreateQuestItem( scrollpane, current_quest, quest, "list_".. i, 63 * ( i - 1 ), i % 2 == 0 )
					end

					scrollpane:AdaptHeightToContents( )
					scrollbar:UpdateScrollbarVisibility( scrollpane )

					if duty or localPlayer:IsOnFactionDuty( ) then
						ibCreateButton( 264, 177, 184, 34, UI.tabs[ name ], "images/button_duty_stop", true )
						:ibOnClick( function( button, state )
							if button ~= "left" or state ~= "up" then
								return
							end

							DestroyUIInfo( )
							triggerServerEvent( "PlayerWantEndDuty", root )
						end )
					else
						local overlay = ibCreateImage( 0, 161, 1024, 412, nil, UI.tabs[ name ], ibApplyAlpha( 0xff000000, 70 ) )

						ibCreateButton( 0, 0, 230, 50, overlay, "images/button_duty_start", true )
						:center( ):ibOnClick( function( button, state )
							if button ~= "left" or state ~= "up" then
								return
							end

							DestroyUIInfo( )
							triggerServerEvent( "PlayerWantStartDuty", resourceRoot, city )
						end )
					end
				end
			end,
		},
		{
			to = "day_off",
			name = "Отгул/Увольнение",
			draw = function ( self, state, anim_offset )
				local name = self.to
				local current_state = isElement( UI.tabs[ name ] )

				if not state and current_state then
					UI.tabs[ name ]:ibAlphaTo( 0, 250 ):ibMoveTo( anim_offset, nil, 250 ):ibData( "priority", 0 )

				elseif state and current_state then
					UI.tabs[ name ]:ibAlphaTo( 255, 250 ):ibMoveTo( 0, nil, 250 ):ibData( "priority", 1 )

				elseif state and not current_state then
					UI.tabs[ name ] = ibCreateImage( anim_offset, 0, 1024, 573, "images/bg_day_off.png", UI.render_target )
					:ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibMoveTo( 0, nil, 250 ):ibData( "priority", 1 )

					ibCreateImage( 140, 455, 252, 3, nil, UI.tabs[ name ], ibApplyAlpha( 0xff000000, 10 ) )

					local counter = FACTION_DUTY_VALUE_FOR_DAY_OFF - ( localPlayer:getData( "duty_counter_for_day_off" ) or 0 )
					ibCreateLabel( 326, 339, 0, 0, counter, UI.tabs[ name ], nil, nil, nil, nil, "center", ibFonts.bold_19 )

					local selected_days = 0
					local days_available = localPlayer:getData( "factions_day_off_available" ) or 0

					local lbl_days = ibCreateLabel( 113, 456, 0, 0, "0", UI.tabs[ name ], nil, nil, nil, "center", "center", ibFonts.regular_16 )
					ibCreateLabel( 420, 456, 0, 0, days_available, UI.tabs[ name ], nil, nil, nil, "center", "center", ibFonts.regular_16 )

					ibCreateLabel( 345, 410, 0, 0, days_available, UI.tabs[ name ], nil, nil, nil, nil, "center", ibFonts.bold_19 )

					local scrollpane, scrollbar = ibCreateScrollpane( 140, 362, 252, 100, UI.tabs[ name ], { horizontal = true } )
					scrollbar:ibSetStyle( "slim_nobg" ):ibBatchData( { handle_px = 0, handle_lower_limit = 1, handle_upper_limit = -100 } )
					scrollpane:ibData( "sx", 1024 ):ibTimer( function ( )
						selected_days = math.ceil( days_available * scrollbar:ibData( "position" ) )
						lbl_days:ibData( "text", selected_days )
					end, 50, 0 )

					ibCreateButton( 186, 484, 160, 42, UI.tabs[ name ], "images/button_day_off", true )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then
							return
						end

						if UI.confirm then
							UI.confirm:destroy( )
						end

						if selected_days <= 0 or selected_days > days_available then
							localPlayer:ShowError( "Неверное количество дней отгула" )
							return
						end

						UI.confirm = ibConfirm( {
							title = "ПОДТВЕРЖДЕНИЕ",
							text = "Ты действительно хочешь взять отгул на " .. selected_days .. " дн.?",
							fn = function( self )
								triggerServerEvent( "PlayerWantGetDayOffFaction", localPlayer, selected_days )

								self:destroy( )
								DestroyUIInfo( )
							end,
							escape_close = true,
						} )
					end )

					ibCreateButton( 684, 484, 160, 42, UI.tabs[ name ], "images/button_leave", true )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then
							return
						end

						if UI.confirm then
							UI.confirm:destroy( )
						end

						UI.confirm = ibConfirm( {
							title = "ПОДТВЕРЖДЕНИЕ",
							text = "Ты действительно хочешь уволиться? Повторное вступление в любую фракцию будет возможно через:  " .. FACTION_JOIN_TIMEOUT.himself / 3600 .. " ч.",
							fn = function( self )
								triggerServerEvent( "PlayerWantLeaveFaction", resourceRoot )

								self:destroy( )
								DestroyUIInfo( )
							end,
							escape_close = true,
						} )
					end )
				end
			end,
		},
	}

	local oldNum = 1
	for num, data in ipairs( tabs ) do
		local x = tabs[ num - 1 ] and tabs[ num - 1 ].element:ibGetAfterX( ) + 30 or 30
		local width = dxGetTextWidth( data.name, 1, ibFonts.bold_16 )

		data.element = ibCreateLabel( x, - 50, width, 50, data.name, UI.menu, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_16 )
		:ibData( "alpha", data.selected and 255 or 100 )
		:ibOnClick( function ( key, state )
			if key ~= "left" or state ~= "up" then
				return
			end

			for buttonNum, data in ipairs( tabs ) do
				data.selected = buttonNum == num and true or false
				data.element:ibAlphaTo( data.selected and 255 or 100, 50 )

				if not data.selected then
					data:draw( false, oldNum > num and 100 or - 100 ) -- hide component
				end
			end

			ibClick( )

			if oldNum == num then
				return
			end

			shadow:ibMoveTo( x, nil, 200 )
			shadow:ibResizeTo( width, 4, 200 )

			data:draw( true, oldNum < num and 100 or - 100 ) -- show component

			oldNum = num
		end )
		:ibOnHover( function( )
			data.element:ibAlphaTo( 255, 200 )
		end )
		:ibOnLeave( function ( )
			if data.selected then
				return
			end

			data.element:ibAlphaTo( 100, 200 )
		end )

		if data.selected then
			shadow:ibData( "sx", width )
			shadow:ibMoveTo( x, nil, 200 )

			data:draw( true, 0 ) -- show component
		end
	end

	showCursor( true )
end
addEvent( "ShowUIInfo", true )
addEventHandler( "ShowUIInfo", resourceRoot, UIInfo )

function CreateQuestItem( parent, current_quest, quest, prefix, pos_y, is_colored )
	local is_current_quest = current_quest and current_quest.id == quest.id
	local area = ibCreateImage( 0, pos_y, 1024, 62, nil, parent, is_colored and ibApplyAlpha( 0xff314050, 25 ) or 0x00000000 )

	ibCreateLabel( 30, 20, 0, 0, quest.name, area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )

	UI[ prefix .. "_state" ] = ibCreateLabel( 30, 41, 0, 0, "...", area, quest.current and 0xffe2da7f or 0x80FFFFFF, nil, nil, "left", "center", ibFonts.regular_12 )

	if quest.rewards.faction_exp then
		ibCreateLabel( is_current_quest and 847 or 888, 30, 0, 0, "+ ".. quest.rewards.faction_exp .." оч.", area, ibApplyAlpha( nil, 40 ), nil, nil, "right", "center", ibFonts.regular_14 )
	end

	if is_current_quest then
		UI[ prefix .. "_button_task_action" ] = ibCreateButton( 859, 14, 135, 34, area, "images/button_stop", true )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end

				triggerServerEvent( "PlayeStopQuest_".. quest.id, root )
				DestroyUIInfo( )
			end )
	else
		UI[ prefix .. "_button_task_action" ] = ibCreateButton( 901, 14, 94, 34, area, "images/button_start", true )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end

				triggerServerEvent( "PlayeStartQuest_" .. quest.id, root )
				DestroyUIInfo( )
			end )
	end

	ibCreateImage( 0, 62, 1024, 1, nil, area, ibApplyAlpha( nil, 10 ) )
end

function SetTasksInfo( )
	if not isElement( UI.bg_img ) then
		killTimer( sourceTimer )
		return
	end

	local server_timestamp = getRealTimestamp( )

	for i, quest in ipairs( LIST ) do
		local text_state = "Уже доступно"
		local enabled = true
		if quest.current then
			text_state = "Выполняется"
		else
			if quest.completed and quest.replay_timeout and ( quest.completed + quest.replay_timeout ) > server_timestamp then
				local time_data = ConvertSecondsToTime( quest.completed + quest.replay_timeout - server_timestamp )
				text_state = "Доступно через: ".. ( time_data.minute > 0 and ( time_data.minute .." мин. " ) or "" ) .. time_data.second .." сек."
				enabled = false
			elseif quest.failed and quest.failed_timeout and ( quest.failed + quest.failed_timeout ) > server_timestamp then
				local time_data = ConvertSecondsToTime( quest.failed + quest.failed_timeout - server_timestamp )
				text_state = "Доступно через: ".. ( time_data.minute > 0 and ( time_data.minute .." мин. " ) or "" ) .. time_data.second .." сек."
				enabled = false
			end
		end

		UI[ "list_".. i .."_state" ]:ibData( "text", text_state )
		UI[ "list_".. i .."_button_task_action" ]:ibData( "disabled", not enabled )
	end
end

function DestroyUIInfo( )
	if isElement( UI.black_bg ) then
		destroyElement( UI.black_bg )
	end
	UI = { }

	showCursor( false )
end

function GenerateQuestList( faction_id )
	LIST = { }
	local quests_info = localPlayer:GetQuestsData( )

	for i, quest_name in ipairs( REGISTERED_FACTIONS_TASKS[ faction_id ] ) do
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