local UI_elements = { }
ibUseRealFonts( true )

local SEARCH_TIMEOUT = nil



function ShowCoopJobUI( state, conf )
	if state then
		ShowCoopJobUI( false )
		ibInterfaceSound()

        QUEST_DATA = exports[ JOB_DATA[ conf.job_class ].task_resource ]:GetQuestData( )

		UI_elements = { }
		local conf = conf or { }

		UI_elements.black_bg = ibCreateBackground( _, ShowCoopJobUI, 0xaa000000, true )
		UI_elements.bg_texture = dxCreateTexture( "img/" .. JOB_ID[ conf.job_class ] .. "/bg_main.png" )

		local sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
		local px, py = ( _SCREEN_X - sx ) / 2, ( _SCREEN_Y - sy ) / 2

		UI_elements.bg = ibCreateImage( px, py + 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg ):ibData( "alpha", 0 )
		ibCreateButton( 971, 34, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			ShowCoopJobUI( false )
			ibClick( )
		end )

        if fileExists( "img/" .. JOB_ID[ conf.job_class ] .. "/bg_fines.png" ) then
		    ibCreateButton( 820, 192, 175, 40, UI_elements.bg, "img/fines.png", "img/fines.png", "img/fines.png", ibApplyAlpha( 0xFFFFFFFF, 190 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 190 ) )
		    :ibOnClick( function( button, state )
		    	if button ~= "left" or state ~= "down" then return end
		    	ShowCoopFinesUI( true, conf.job_class )
		    	ibClick( )
            end )
        end

        UI_elements.btn_discord = ibCreateButton( sx-140, 275, 110, 20, UI_elements.bg, "img/btn_discord_i.png", "img/btn_discord_h.png", "img/btn_discord_h.png", 0xffffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function( button, state )
        	if button ~= "left" or state ~= "down" then return end
		    ibClick( )

		    setClipboard( "https://discord.gg/YY9mNQZDrs" )
		    localPlayer:ShowInfo( "Ссылка скопирована в буфер обмена" )
        end )

		UI_elements.reward_bonus = ibCreateLabel( 905, 39, 0, 12, "0 %", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )

		ibCreateImage( 30, 136, 36, 36, ":nrp_shared/img/money_icon.png", UI_elements.bg )
		ibCreateLabel( 77, 136, 0, 0, format_price( conf.earned_today or 0 ) .. " р.", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_21 )

		local piggy_bank = localPlayer:getData( "offer_piggy_bank" )
		if piggy_bank then
			ibCreateImage( 250, 112, 1, 54, nil, UI_elements.bg, ibApplyAlpha( 0xffffffff, 10 ) )
			ibCreateLabel( 272, 118, 0, 0, "Подоходный налог:", UI_elements.bg, 0x88dddddd, 1, 1, "left", "center", ibFonts.bold_16 )
			ibCreateImage( 270, 136, 30, 30, "img/tax_icon.png", UI_elements.bg )
			local lbl_amount = ibCreateLabel( 310, 136, 0, 0, format_price( piggy_bank ), UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.oxaniumbold_21 )

			ibCreateButton( 320 + lbl_amount:width( ), 135, 100, 30, UI_elements.bg, "img/btn_more_i.png", "img/btn_more_h.png", "img/btn_more_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
					:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then
					return
				end

				triggerEvent( "onPlayerOfferPiggyBank", localPlayer )
				ibClick( )
			end )
		end

		local levels_info = 
		{
			available = conf.available or { },
			passed = conf.passed or { },
		}
		
		local current_level = math.max( 1, conf.current_job_position - 1 )
		if not JOB_DATA[ conf.job_class ].conf[ current_level + 2 ] then
			current_level = current_level - 1
		end

		local area_px, area_py = 31, 183
		local last_level = current_level + 2
		for i = current_level, current_level + 2 do
			if not JOB_DATA[ conf.job_class ].conf[ i ] then break end
			local compnay_conf = JOB_DATA[ conf.job_class ].conf[ i ]
			if compnay_conf then
				local area = ibCreateArea( area_px, area_py, 300, 40, UI_elements.bg )
				local company_name = ibCreateLabel( 60, 15, 0, 0, compnay_conf.name, area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
				:ibData( "priority", 10 )
				
				if i == conf.current_job_position or i < conf.current_job_position or levels_info.passed[ compnay_conf.id ] then
					local company_id_color = 0xFF47AFFF
					local texture = last_level == i and "img/lvl/passed.png" or "img/lvl/passed_next.png"
					if i ~= conf.current_job_position then
						company_name:ibData( "color", 0xFFB1BDCA )
					else
						texture = last_level == i and "img/lvl/available.png" or "img/lvl/available_next.png"
						company_id_color = 0xFFFFFFFF
						company_name:ibData( "color", company_id_color )
					end

					local container = ibCreateImage( 0, 0, 0, 0, texture, area ):ibSetRealSize()
					ibCreateLabel( 60, 23, 0, 0, i == conf.current_job_position and "Текущий" or "Пройден", area ):ibBatchData( { color = 0xAAB1BCC9, font = ibFonts.regular_12 } )
					ibCreateLabel( 0, 0, 50, 50, ROMAN_NUMERALS[ i ], container, company_id_color, 1, 1, "center", "center", ibFonts.bold_20 )

				else
					company_name:ibData( "color", 0xFF949FAB )
					local texture = last_level == i and "img/lvl/blocked.png" or "img/lvl/blocked_next.png"
					local container = ibCreateImage( 0, 0, 0, 0, texture, area ):ibSetRealSize()
					ibCreateLabel( 60, 23, 0, 0, compnay_conf.condition_text, area ):ibBatchData( { color = 0x99ffffff, font = ibFonts.regular_12 } )
					ibCreateLabel( 0, 0, 50, 50, ROMAN_NUMERALS[ i ], container, 0xFF949FAB, 1, 1, "center", "center", ibFonts.bold_20 )
				end
			end
			area_px = area_px + 250
		end

		-- Оставшееся время смены
		UI_elements.remaining_time = ibCreateLabel( 935, 106, 0, 0, "", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_18 )

		local shift_state
		local function CalculationShiftTime( )
			if localPlayer:HasAnyApartment( true ) then
				UI_elements.remaining_time:ibData( "alpha", 0 )
				return
			else
				UI_elements.remaining_time:ibData( "alpha", 255 )
			end

			if localPlayer:IsNewShiftDay( ) then
				--доступна новая смена
				if shift_state ~= "new" then
					shift_state = "new"
					UpdateShiftCoopJobUI( shift_state )
					UI_elements.remaining_time:ibData( "text", "" )
				end
			else
				local remaining_time = localPlayer:GetShiftRemainingTime( )
				local hours = math.max( 0, math.floor( remaining_time / 60 / 60 ) )
				local minutes = math.max( 0, math.floor( remaining_time / 60 - hours * 60 ) )
				local seconds = math.max( 0, math.floor( remaining_time - hours * 60 * 60 - minutes * 60 ) )

				if hours <= 0 and minutes <= 0 and seconds <= 0 then
					--время до начала следующей смены
					if shift_state ~= "ended" then
						shift_state = "ended"
						UI_elements.remaining_time:ibData( "px", 922 )
						UpdateShiftCoopJobUI( shift_state )
					end
					local time_after_shift = getRealTime( getRealTimestamp( ) - SHIFT_CHANGE_TIME )
					UI_elements.remaining_time:ibData( "text", string.format( "%d:%02d:%02d", 23 - time_after_shift.hour, 59 - time_after_shift.minute, 59 - time_after_shift.second ) )
				else
					--оставшееся время смены
					if shift_state ~= "available" then
						shift_state = "available"
						UI_elements.remaining_time:ibData( "px", 935 )
						UpdateShiftCoopJobUI( shift_state )
					end
					UI_elements.remaining_time:ibData( "text", string.format( "%d:%02d:%02d", hours, minutes, seconds ) )
				end
			end
		end

		CalculationShiftTime( )
		UI_elements.remaining_time:ibTimer( CalculationShiftTime, 500, 0 )

		-- Обновляем изменяемые элементы
		onClientUpdateButtonsCoopJobUI_handler( conf )
		onClientUpdatePlayersCoopJobUI_handler( conf )

		-- Показываем окно
		UI_elements.bg:ibMoveTo( px, py, 750, "OutElastic" ):ibAlphaTo( 255, 1200 )
		showCursor( true )
    elseif isElement( UI_elements.black_bg ) then 
        destroyElement( UI_elements.black_bg )
		showCursor( false )
	end
end
addEvent( "onClientShowCoopJobUI", true )
addEventHandler( "onClientShowCoopJobUI", resourceRoot, ShowCoopJobUI )

function UpdateShiftCoopJobUI( shift_state )
	if not UI_elements then return end
	if UI_elements.shift then destroyElement( UI_elements.shift ) end

	UI_elements.shift = ibCreateArea( 524, 92, 500, 50, UI_elements.bg )
	if shift_state == "available" then
		ibCreateImage( 235, 20, 16, 18, "img/timer.png", UI_elements.shift ):ibData( "alpha", 191 )
		ibCreateLabel( 261, 18, 0, 0, "Доступно в течении:", UI_elements.shift, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_14 ):ibData( "alpha", 191 )
	elseif shift_state == "ended" then
		ibCreateImage( 127, 20, 16, 18, "img/timer.png", UI_elements.shift ):ibData( "alpha", 191 )
		ibCreateLabel( 151, 18, 0, 0, "Смена окончена, приходите через:", UI_elements.shift, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_14 ):ibData( "alpha", 125 )
	elseif shift_state == "new" then
		ibCreateImage( 290, 20, 16, 18, "img/timer_end.png", UI_elements.shift ):ibData( "alpha", 191 )
		ibCreateLabel( 318, 18, 0, 0, "Доступна новая смена", UI_elements.shift, 0xFFFFD892, 1, 1, "left", "top", ibFonts.regular_14 ):ibData( "alpha", 191 )
	end
end

function onClientUpdateButtonsCoopJobUI_handler( conf )
	if not UI_elements or not isElement( UI_elements.bg ) then return end
	if isElement( UI_elements.buttons ) then 
		destroyElement( UI_elements.buttons ) 
	end

	local sx = UI_elements.bg:width( )
	local sy = UI_elements.bg:height( )
	UI_elements.buttons = ibCreateArea( 0, 664, sx, sy, UI_elements.bg )

	if conf.lobby_state then
		ibCreateButton( 820, -521, 175, 40, UI_elements.buttons, "img/leave_lobby.png", "img/leave_lobby.png", "img/leave_lobby.png", ibApplyAlpha( 0xFFFFFFFF, 170 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 170 ) )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			
			triggerServerEvent( "onServerLeaveCoopJobLobby", resourceRoot, "quest_end_job_shift" )
			ibClick( )
		end )
	else
		ibCreateButton( 820, -521, 175, 40, UI_elements.buttons, "img/create_lobby.png", "img/create_lobby.png", "img/create_lobby.png", ibApplyAlpha( 0xFFFFFFFF, 191 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 191 ) )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			
			triggerServerEvent( "onServerCreateLobby", resourceRoot, CURRENT_CITY, conf.job_class )
			ibClick( )
		end )
	end

	if conf.lobby_state == LOBBY_STATE_START_WORK or (conf.owner and conf.owner ~= localPlayer) then
		return false
	end

	if conf.search_state == SEARCH_STATE_START then
		local search_label = ibCreateLabel( 30, 59, 0, 0, "Текущее время поиска:", UI_elements.buttons, ibApplyAlpha( 0xFFFFFFFF, 150 ), 1, 1, "left", "top", ibFonts.regular_12 )
		UI_elements.timer_search_label = ibCreateLabel( search_label:ibGetAfterX( ) + 9, 59, 0, 0, "", UI_elements.buttons, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_12 )

		local function CalculationSearchTime( )
			local s = getRealTimestamp( ) - conf.search_start_timestamp
			if s < 0 then s = 0 end

			local m = math.floor( s / 60 )
			s = math.floor( s - m * 60 )
			local time = ( m > 0 and ( m .. " " .. plural( m, "минута", "минуты", "минут" ) .. " " ) or "" ) .. ( s > 0 and ( s .. " " .. plural( s, "секунда", "секунды", "секунд" ) ) or "0 секунд" )

			UI_elements.timer_search_label:ibData( "text", time )
		end

		CalculationSearchTime( )
		UI_elements.timer_search_label:ibTimer( CalculationSearchTime, 500, 0 )

		ibCreateButton( 615, 31, 95, 44, UI_elements.buttons, "img/cancel.png", "img/cancel.png", "img/cancel.png", ibApplyAlpha( 0xFFFFFFFF, 150 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 150 ) )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end

			if conf.lobby_state then
				triggerServerEvent( "onServerSearch", resourceRoot, SEARCH_STATE_CANCEL )
			else
				localPlayer:ShowError( "Лобби не создано" )
			end
			ibClick( )
		end )
	elseif conf.search_state == SEARCH_STATE_WAIT or conf.search_state == SEARCH_STATE_END then
		if conf.search_state == SEARCH_STATE_WAIT then
			local search_label = ibCreateLabel( 30, 59, 0, 0, "Примерное время ожидания:", UI_elements.buttons, ibApplyAlpha( 0xFFFFFFFF, 150 ), 1, 1, "left", "top", ibFonts.regular_12 )
			ibCreateLabel( search_label:ibGetAfterX( ) + 9, 59, 0, 0, "1 минута 30 секунд", UI_elements.buttons, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_12 )
		else
			ibCreateLabel( 30, 59, 0, 0, "Напарники найдены", UI_elements.buttons, 0xFFFFDE96, 1, 1, "left", "top", ibFonts.regular_12 )
		end

		ibCreateButton( 615, 31, 95, 44, UI_elements.buttons, "img/search.png", "img/search.png", "img/search.png", ibApplyAlpha( 0xFFFFFFFF, 150 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 150 ) )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			local timeout = IsSearchTimeOut() 
			if timeout then 
				localPlayer:ShowError( "Начать поиск можно будет через " .. timeout .. " " .. plural( timeout, "секунда", "секунды", "секунд" ) )
				return false
			end
			
			if conf.lobby_state then
				if conf.search_state == SEARCH_STATE_END then 
					localPlayer:ShowError( "Напарники найдены" ) 
					return false
                end

				triggerServerEvent( "onServerSearch", resourceRoot, SEARCH_STATE_START )
			else
				localPlayer:ShowError( "Лобби не создано" )
			end
			ibClick( )
		end )
	end

	local texture_start = conf.can_start and "img/start_available.png" or "img/start.png"
	ibCreateButton( 899, 31, 95, 44, UI_elements.buttons, texture_start, texture_start, texture_start, ibApplyAlpha( 0xFFFFFFFF, 191 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 191 ) )
	:ibOnClick( function( button, state )
		if button ~= "left" or state ~= "down" then return end
		
        if conf.lobby_state then
            if conf.search_state == SEARCH_STATE_END then 
				localPlayer:ShowError( "Смена уже начата" ) 
				return 
            end
            
			triggerServerEvent( "onServerPreStartWork", resourceRoot )
		else
			localPlayer:ShowError( "Лобби не создано" )
		end
		ibClick( )
	end )

	ibCreateButton( 730, 31, 149, 44, UI_elements.buttons, "img/invite.png", "img/invite.png", "img/invite.png", ibApplyAlpha( 0xFFFFFFFF, 150 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 150 ) )
	:ibOnClick( function( button, state )
		if button ~= "left" or state ~= "down" then return end
		
		if conf.lobby_state then
			if conf.search_state == SEARCH_STATE_END then 
				localPlayer:ShowError( "Напарники найдены" ) 
				return 
			end

			ShowCoopJobInviteUI( true )
		else
			localPlayer:ShowError( "Лобби не создано" )
		end
		ibClick( )
	end )
end
addEvent( "onClientUpdateButtonsCoopJobUI", true )
addEventHandler( "onClientUpdateButtonsCoopJobUI", resourceRoot, onClientUpdateButtonsCoopJobUI_handler )

function onClientUpdatePlayersCoopJobUI_handler( conf )
	if not UI_elements or not isElement( UI_elements.bg ) then return end

	if UI_elements.participants then destroyElement( UI_elements.participants ) end

	local participants = conf.participants or { }

	local sx = UI_elements.bg:width( )
	UI_elements.participants = ibCreateArea( 0, 463, sx, 200, UI_elements.bg )
	UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 0, 0, sx, 200, UI_elements.participants, { scroll_px = -16, bg_color = 0x00FFFFFF } )

	UI_elements.scrollbar:ibSetStyle( "slim_nobg" ):UpdateScrollbarVisibility( UI_elements.scrollpane )

	local max_players = QUEST_DATA.max_players
	local max_width_role
	for i = 1, #QUEST_DATA.roles do
		max_width_role = dxGetTextWidth ( QUEST_DATA.roles[ i ].name, 1, ibFonts.bold_14 )
	end

	if conf.reward_bonus then
		UI_elements.reward_bonus:ibData( "text", round( conf.reward_bonus, 1 ) .. " %" )
	end

	for i = 1, math.max( 4, max_players ) do
		local color_item = i == 1 and 0xFF314050 or i % 2 == 0 and ibApplyAlpha( 0xFF314050, 125 ) or 0xFF475d75

		local container = ibCreateImage( 0, ( i - 1 ) * 50, sx, 50, _, UI_elements.scrollpane, color_item )
		ibCreateLabel( 32, 0, 0, 50, i, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
		ibCreateImage( 944, 0, 50, 50, _, container, 0x72314050 )

		if i > max_players then
			ibCreateLabel( 100, 0, 0, 50, "Недоступно", container, 0x77ffffff, 1, 1, "left", "center", ibFonts.bold_14 )
			ibCreateLabel( 361, 0, 0, 50, "-", container, 0x77ffffff, 1, 1, "left", "center", ibFonts.bold_14 )
			ibCreateLabel( 633, 0, 0, 50, "-", container, 0x77ffffff, 1, 1, "left", "center", ibFonts.bold_14 )
		elseif participants[ i ] then
			ibCreateLabel( 100, 0, 0, 50, participants[ i ].player:GetNickName( ), container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
			ibCreateLabel( 361, 0, 0, 50, QUEST_DATA.roles[ participants[ i ].role ].name, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )

			local status = participants[ i ].player == conf.owner and "Лидер" or "Ожидание"
			ibCreateLabel( 633, 0, 0, 50, status, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
            
            if conf.lobby_state and conf.lobby_state ~= LOBBY_STATE_START_WORK then
                ibCreateButton( 381 + max_width_role, 0, 18, 50, container, "img/more.png", "img/more.png", "img/more.png", ibApplyAlpha( 0xFFFFFFFF, 165 ), 0xFFFFFFFF, ibApplyAlpha( 0xFFFFFFFF, 165 ) )
			    :ibOnClick( function( button, state )
			    	if button ~= "left" or state ~= "down" then return end
                
			    	ShowCoopJobChangeRole( true, participants[ i ], i )
			    	ibClick( )
                end )
            end

			if conf.lobby_state ~= LOBBY_STATE_START_WORK and conf.owner == localPlayer and participants[ i ].player ~= conf.owner then
				ibCreateButton( 962, 16, 14, 18, container, "img/delete.png", "img/delete.png", "img/delete.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end

					triggerServerEvent( "onServerRemovePlayer", resourceRoot, participants[ i ].player )
					ibClick( )
				end )
			end
		else
			ibCreateLabel( 100, 0, 0, 50, "-", container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
			ibCreateLabel( 361, 0, 0, 50, "-", container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
			ibCreateLabel( 633, 0, 0, 50, "-", container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
		end
	end

	UI_elements.scrollpane:AdaptHeightToContents()
	UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
end
addEvent( "onClientUpdatePlayersCoopJobUI", true )
addEventHandler( "onClientUpdatePlayersCoopJobUI", resourceRoot, onClientUpdatePlayersCoopJobUI_handler )

function ShowCoopJobChangeRole( state, participant, index_player )
	if not UI_elements or not isElement( UI_elements.bg ) then return end
	if isElement( UI_elements.roles ) then destroyElement( UI_elements.roles ) end
	if not state then return end

	local max_width_role
	for i = 1, #QUEST_DATA.roles do
		max_width_role = dxGetTextWidth ( QUEST_DATA.roles[ i ].name, 1, ibFonts.bold_14 )
	end

	UI_elements.roles = ibCreateArea( 366 + max_width_role, ( index_player - 1 ) * 50 + 10, 405, #QUEST_DATA.roles * 44 + 10, UI_elements.participants )
	:ibOnLeave( function( )
		ShowCoopJobChangeRole( false )
	end )

	ibCreateImage( 9, 0, 10, 5, "img/triangle.png", UI_elements.roles )

	for i = 1, #QUEST_DATA.roles do
		ibCreateImage( 5, 4 + 43, 198, 1, _, UI_elements.roles, 0x19000000 )
		ibCreateButton( 5, 4 + ( i - 1 ) * 44, 198, 44, UI_elements.roles, _, _, _, 0xFF66809D, 0xFF768DA7, 0xFF66809D )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end

			if i == participant.role then
				localPlayer:ShowError( "Игрок уже с данной ролью" )
				return
			end
			ShowCoopJobChangeRole( false )
			triggerServerEvent( "onServerChangePlayerRole", resourceRoot, participant.player, i )
			ibClick( )
		end )
		:ibOnHover( function( )
			if isElement( UI_elements.role_info ) then destroyElement( UI_elements.role_info ) end
			
            UI_elements.role_info = ibCreateImage( 213, 4 + ( i - 1 ) * 44, 190, 58, _, UI_elements.roles, 0xCC000000 )
            
			ibCreateLabel( 15, 9, 0, 44, "Роль " .. QUEST_DATA.roles[ i ].name, UI_elements.role_info, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_14 )
			ibCreateLabel( 15, 30, 0, 44, "Макс. участников - " .. QUEST_DATA.roles[ i ].max_count, UI_elements.role_info, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_12 )
		end )
		ibCreateLabel( 17, 4 + ( i - 1 ) * 44, 0, 44, QUEST_DATA.roles[ i ].name, UI_elements.roles, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_12 )
	end
end

function IsSearchTimeOut()
	local timestamp = getRealTimestamp()
	local diff = (SEARCH_TIMEOUT or timestamp) - timestamp
	if diff > 0 then
		return diff
	end

	SEARCH_TIMEOUT = timestamp + SEARCH_TIMEOUT_TIME
	return false
end

function round( num, idp )
	return tonumber( string.format( "%." .. ( idp or 0 ) .. "f", num ) )
end

function GetMainWindowElements()
	return UI_elements
end
