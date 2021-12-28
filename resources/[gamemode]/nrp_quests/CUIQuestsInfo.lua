local screen_size_x, screen_size_y = guiGetScreenSize( )

local UI_elements = { }

local last_complete_shown = 0

function ShowPlayerUIQuestFailed_handler( fail_text, quest_id, is_quest_stop )
	if quest_id then
		local target_quest = nil
		for _, v in pairs( LIST.all ) do
			if v.id == quest_id then
				target_quest = v
				break
			end
		end
		if target_quest then
			ShowPlayerUIQuestFailed( fail_text, target_quest, is_quest_stop )
			return
		end
	end

	if isElement( UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
	end

	if isTimer( UI_elements.timer ) then
		killTimer( UI_elements.timer )
	end

	playSound( "sounds/mission_fail.wav" )

	UI_elements.black_bg = ibCreateBackground( 0xbf000000, _, true )
	UI_elements.black_bg:ibData( "alpha", 0 ):ibAlphaTo( 255, 1500 )

	UI_elements.bg = ibCreateImage( 0, 0, screen_size_x, screen_size_y, "images/fail_bg.png", UI_elements.black_bg )

	local coeff_x, coeff_y = screen_size_x / 1280, screen_size_y / 720
	local text_effect = ibCreateImage( 0, 119 * coeff_y, screen_size_x, 26 * coeff_y, "images/text_failed_effect.png", UI_elements.bg )
	ibCreateLabel( 0, -1, screen_size_x, 26 * coeff_y, "МИССИЯ ПРОВАЛЕНА", text_effect, 0xFFD42D2D, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 36 * coeff_y ) ] )
	:ibData("outline", 1)


	ibCreateLabel( 0, 201 * coeff_y, screen_size_x, 0, "Причина провала:", UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 16 * coeff_y ) ] )
	:ibData("outline", 1)
	ibCreateLabel( 0, 227 * coeff_y, screen_size_x, 0, fail_text, UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 24 * coeff_y ) ] )
	:ibData("outline", 1)

	UI_elements.timer = Timer( function()
		if isElement( UI_elements.black_bg ) then
			UI_elements.black_bg:ibAlphaTo( 0, 1000 )

			UI_elements.timer = Timer( function()
				if isElement( UI_elements.black_bg ) then
					destroyElement( UI_elements.black_bg )
				end
			end, 1000, 1 )
		end
	end, 7000, 1 )

end
addEvent( "ShowPlayerUIQuestFailed", true )
addEventHandler( "ShowPlayerUIQuestFailed", root, ShowPlayerUIQuestFailed_handler )

function ShowPlayerUIQuestFailed( fail_text, quest, is_quest_stop )
	if isElement( UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
	end

	if isTimer( UI_elements.timer ) then
		killTimer( UI_elements.timer )
	end

	playSound( "sounds/mission_fail.wav" )

	UI_elements.black_bg	= ibCreateBackground( 0xbf000000, _, true )
	UI_elements.black_bg:ibData( "alpha", 0 ):ibAlphaTo( 255, 1500 )

	UI_elements.bg = ibCreateImage( 0, 0, screen_size_x, screen_size_y, "images/fail_bg.png", UI_elements.black_bg )

	local coeff_x, coeff_y = screen_size_x / 1280, screen_size_y / 720
	local text_effect = ibCreateImage( 0, 119 * coeff_y, screen_size_x, 26 * coeff_y, "images/text_failed_effect.png", UI_elements.bg )
	ibCreateLabel( 0, -1, screen_size_x, 26 * coeff_y, "МИССИЯ ПРОВАЛЕНА", text_effect, 0xFFD42D2D, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 36 * coeff_y ) ] )
	:ibData("outline", 1)


	ibCreateLabel( 0, 201 * coeff_y, screen_size_x, 0, "Причина провала:", UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 16 * coeff_y ) ] )
	:ibData("outline", 1)
	ibCreateLabel( 0, 227 * coeff_y, screen_size_x, 0, fail_text, UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 24 * coeff_y ) ] )
	:ibData("outline", 1)

	if not is_quest_stop and not localPlayer:isDead() and not localPlayer:getData( "jailed" ) and not localPlayer:getData( "is_handcuffed" ) then

		local cancel_btn = ibCreateButton( (screen_size_x / 2 - 210 * coeff_x), 626 * coeff_y, 200 * coeff_x, 54 * coeff_y, UI_elements.bg, "images/menu/btn_cancel.png", "images/menu/btn_cancel_hovered.png", "images/menu/btn_cancel_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			hideFailInfo()
		end, false )

		local restart_btn = ibCreateButton( (screen_size_x / 2 + 10 * coeff_x), 626 * coeff_y, 200 * coeff_x, 54 * coeff_y, UI_elements.bg, "images/menu/btn_restart.png", "images/menu/btn_restart_hovered.png", "images/menu/btn_restart_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			hideFailInfo()
			triggerServerEvent( "PlayeStartQuest_".. quest.id, root, nil, true )
		end, false )

		bindKey( "space", "down", RestartQuest, quest.id )
	else

		local cancel_btn = ibCreateButton( (screen_size_x - 210 * coeff_x) / 2 , 626 * coeff_y, 200 * coeff_x, 54 * coeff_y, UI_elements.bg, "images/menu/btn_cancel.png", "images/menu/btn_cancel_hovered.png", "images/menu/btn_cancel_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			hideFailInfo()
		end, false )
		bindKey( "space", "down", hideFailInfo )
	end

	showCursor( true )

end

function hideFailInfo()

	if isElement( UI_elements.black_bg ) then
		ibClick( )
		UI_elements.black_bg:ibAlphaTo( 0, 1000 )

		UI_elements.timer = Timer( function()
			if isElement( UI_elements.black_bg ) then
				destroyElement( UI_elements.black_bg )
			end
		end, 1000, 1 )
	end
	unbindKey( "space", "down", hideFailInfo )
	unbindKey( "space", "down", RestartQuest )
	showCursor( false )

end

function RestartQuest( _, _, quest_id )
	triggerServerEvent( "PlayeStartQuest_".. quest_id, root, nil, true )
	hideFailInfo()
end

function ShowPlayerUIQuestSuccess_handler( quest_id, text )
	if quest_id then
		local target_quest = nil
		for _, v in pairs( LIST.all ) do
			if v.id == quest_id then
				target_quest = v
				break
			end
		end
		if not target_quest then
			for _, v in pairs( localPlayer:getData("cur_daily_quests") or {} ) do
				if v.id == quest_id then
					target_quest = v
					break
				end
			end
		end
		if target_quest and not target_quest.tutorial then
			ShowPlayerUIQuestCompleted_handler( target_quest )
			return
		end
	end

	if isElement( UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
	end

	if isTimer( UI_elements.timer ) then
		killTimer( UI_elements.timer )
	end

	playSound( "sounds/mission_completed.wav" )

	UI_elements.black_bg = ibCreateBackground( 0xbf000000, _, true )
	UI_elements.black_bg:ibData( "alpha", 0 ):ibAlphaTo( 255, 1500 )

	UI_elements.bg = ibCreateImage( 0, 0, screen_size_x, screen_size_y, "images/success_bg.png", UI_elements.black_bg )

	local coeff_x, coeff_y = screen_size_x / 1280, screen_size_y / 720
	local text_effect = ibCreateImage( 0, 119 * coeff_y, screen_size_x, 26 * coeff_y, "images/text_success_effect.png", UI_elements.bg )
	ibCreateLabel( 0, -1, screen_size_x, 26 * coeff_y, "МИССИЯ ВЫПОЛНЕНА", text_effect, 0xFF54FF68, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 36 * coeff_y ) ] )
	:ibData("outline", 1)

	ibCreateLabel( 0, 227 * coeff_y, screen_size_x, 0, text or "", UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 24 * coeff_y ) ] )
	:ibData("outline", 1)

	UI_elements.timer = Timer( function()
		if isElement( UI_elements.black_bg ) then
			UI_elements.black_bg:ibAlphaTo( 0, 1000 )

			UI_elements.timer = Timer( function()
				if isElement( UI_elements.black_bg ) then
					destroyElement( UI_elements.black_bg )
				end
			end, 1000, 1 )
		end
	end, 3000, 1 )
end
addEvent( "ShowPlayerUIQuestSuccess", true )
addEventHandler( "ShowPlayerUIQuestSuccess", root, ShowPlayerUIQuestSuccess_handler )

function ShowPlayerUIQuestCompleted_handler( quest )
	last_complete_shown = getTickCount( )

	if isElement( UI_elements.black_bg ) then
		destroyElement( UI_elements.black_bg )
	end

	if isTimer( UI_elements.timer ) then
		killTimer( UI_elements.timer )
	end

	playSound( "sounds/mission_completed.wav" )

	local quests_data = localPlayer:GetQuestsData()
    GenerateQuestList( quests_data )

	UI_elements.black_bg = ibCreateBackground( 0xbf000000, _, true )
	:ibData( "priority", 100 )
	UI_elements.black_bg:ibData( "alpha", 0 ):ibAlphaTo( 255, 1500 )

	UI_elements.bg = ibCreateImage( 0, 0, screen_size_x, screen_size_y, "images/success_bg.png", UI_elements.black_bg )

	local coeff_x, coeff_y = screen_size_x / 1280, screen_size_y / 720
	local text_effect = ibCreateImage( 0, 119 * coeff_y, screen_size_x, 26 * coeff_y, "images/text_success_effect.png", UI_elements.bg )
	ibCreateLabel( 0, -1, screen_size_x, 26 * coeff_y, quest.title or "МИССИЯ ВЫПОЛНЕНА", text_effect, 0xFF54FF68, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 36 * coeff_y ) ] )
	:ibData("outline", 1)

	local last_completed_quest, last_quest_info, last_quest_ts = nil, nil, 0

	for k,v in pairs( quests_data.completed ) do
		local ts = v and tonumber( v )

		if ts then
			if ts >= last_quest_ts then
				last_quest_ts = ts
				last_completed_quest = k
			end
		end
	end

	if last_completed_quest and not quest.is_daily then
		if getResourceFromName( "quest_"..last_completed_quest ) then
			last_quest_info = exports[ "quest_"..last_completed_quest ]:GetQuestInfo( false, true )
		end
	end

	if last_quest_info or quest.name then
		ibCreateLabel( 0, 201 * coeff_y, screen_size_x, 0, "Вы завершили задание:", UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 16 * coeff_y ) ] )
		:ibData("outline", 1)
		ibCreateLabel( 0, 227 * coeff_y, screen_size_x, 0, last_quest_info and last_quest_info.title or quest.name, UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 24 * coeff_y ) ] )
		:ibData("outline", 1)

		ibCreateImage( 0, 270 * coeff_y, 10, 30, "images/arrow_d.png", UI_elements.bg ):center_x( )
	end

	if quest then
		if not quest.info then
			local next_quest_daily
			if quest.timer_name then
				for _, v in pairs( localPlayer:getData("cur_daily_quests") or {} ) do
					if v.id and v.id ~= quest.id then
						next_quest_daily = DAILY_QUEST_LIST[ v.id ].name
						break
					end
				end
			end

			if #LIST.available > 0 or next_quest_daily then
				ibCreateLabel( 0, (201+120) * coeff_y, screen_size_x, 0, "Следующее задание:", UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 16 * coeff_y ) ] )
				:ibData("outline", 1)
				ibCreateLabel( 0, (227+120) * coeff_y, screen_size_x, 0, next_quest_daily and next_quest_daily or LIST.available[ 1 ].name, UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 24 * coeff_y ) ] )
				:ibData("outline", 1)
				ibCreateImage( (screen_size_x - 181 * coeff_x) / 2, (268+120) * coeff_y, 181 * coeff_x, 17 * coeff_y, "images/help_text.png", UI_elements.bg )
			else
				ibCreateLabel( 0, (227+120) * coeff_y, screen_size_x, 0, "Пока нет доступных квестов\nОжидай новых ежедневных заданий", UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 16 * coeff_y ) ] )
				:ibData("outline", 1)
			end
		else
			ibCreateLabel( 0, (227+120) * coeff_y, screen_size_x, 0, quest.info, UI_elements.bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 16 * coeff_y ) ] )
			:ibData("outline", 1)
		end

		if quest.rewards then
			local reward_text = ibCreateImage( (screen_size_x - 588 * coeff_x) / 2, 348 * coeff_y, 588 * coeff_x, 213 * coeff_y, "images/reward_texture_bg.png", UI_elements.bg )
			ibCreateLabel( 93 * coeff_x, 85 * coeff_y, 0, 0, "ПОЗДРАВЛЯЕМ! ВЫ ПОЛУЧИЛИ НАГРАДУ:", reward_text, 0xFFFFD339, 1, 1, "left", "top", ibFonts[ "bold_" .. math.floor( 18 * coeff_y ) ] )

			local px = screen_size_x / 2
			local count = 0
			for _,_ in pairs( quest.rewards ) do
				count = count + 1
			end
			if count == 1 then
				px = px - ( 50 * coeff_x )
			elseif count == 2 then
				px = px - ( 105 * coeff_x )
			else
				local total_width = ( 110*coeff_x ) * count - 10*coeff_x
				px = px - total_width / 2

				iprint( count, total_width )
			end

			local py = 487 * coeff_y
			for k, v in pairs( quest.rewards ) do
				local item_box = ibCreateImage( px, py, 100 * coeff_x, 100 * coeff_x, "images/reward_box.png", UI_elements.bg )

				if k == "case" then
					ibCreateImage( 0, 0, 0, 0, ":nrp_shop/img/cases/big/" .. v .. ".png", item_box )
						:ibSetRealSize( ):ibSetInBoundSize( math.floor( 94 * coeff_x ) ):center( )

				elseif tonumber( v ) and k ~= "tuning_internal" then
					local reward_icon = ibCreateImage( 24 * coeff_x, 13 * coeff_y, 55 * coeff_x, 55 * coeff_y, "images/rewards/" .. k .. ".png", item_box )
					:ibAttachTooltip( reward_tooltips_text[ k ], 101 )

					local sx, sy = reward_icon:ibGetTextureSize( )
					reward_icon:ibBatchData( { px = (100 * coeff_x - sx * coeff_x)/2, py = (100 * coeff_x - 72 * coeff_x)/2, sx = sx * coeff_x, sy = sy * coeff_y } )

					local reward_value = v
					if not quest.timer_name then
						if k == "soft" or k == "money" or k == "exp" then
							local mul = ( not quest.is_daily and not quest.is_bounty and localPlayer:IsPremiumActive( ) ) and 2 or 1
							reward_value = math.floor( reward_value * mul )
						end
					end
					reward_value = reward_count_format_fns[ k ] and reward_count_format_fns[ k ]( reward_value ) or reward_value
					ibCreateLabel( 0, 55 * coeff_y, 100 * coeff_x, 0, reward_value, item_box, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "bold_" .. math.floor( 21 * coeff_y ) ] )

				else
					local texture = nil
					local tooltip_text = nil

					if k == "tuning_internal" then
						texture = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ v.type ] .. ".png"
						tooltip_text = PARTS_NAMES[ v.type ] .. " " .. v.name .. " (" .. PARTS_TIER_NAMES[ v.category ] .. "), для автомобилей Класса " .. VEHICLE_CLASSES_NAMES[ v.tier ]
					elseif k == "package" then
						texture = "images/rewards/package_" .. v.id .. ".png"
						tooltip_text = v.name .. "\n" .. v.desc
					else
						texture = "images/rewards/" .. k .. ".png"
						tooltip_text = reward_tooltips_text[ k ]
					end

					ibCreateImage( 23 * coeff_x, 23 * coeff_y, 55 * coeff_x, 55 * coeff_y, texture, item_box )
						:ibAttachTooltip( tooltip_text, 101 )
				end

				px = px + ( 110 * coeff_x )
			end

		end
	end

	UI_elements.btn_close = ibCreateButton(	(screen_size_x - 100 * coeff_x) / 2, 626 * coeff_y, 100 * coeff_x, 54 * coeff_y, UI_elements.bg, "images/btn_ok.png", "images/btn_ok_hovered.png", "images/btn_ok_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        hideCompletedInfo()
	end, false )

	localPlayer:setData( "quest_reward_window", true, false )
	playSound( ":nrp_shop/sfx/reward_small.mp3" )
	bindKey( "space", "down", hideCompletedInfo)
	bindKey( "F2", "down", hideCompletedInfo)
	showCursor( true )
end
addEvent( "ShowPlayerUIQuestCompleted", true )
addEventHandler( "ShowPlayerUIQuestCompleted", root, ShowPlayerUIQuestCompleted_handler )

function hideCompletedInfo( is_quest_complete )
	if getTickCount() - last_complete_shown < 3000 then return end


	if isElement( UI_elements.black_bg ) then
		ibClick( )
		UI_elements.black_bg:ibAlphaTo( 0, 1000 )

		if is_quest_complete then
			ibGetRewardSound()
		end

		UI_elements.timer = Timer( function()
			if isElement( UI_elements.black_bg ) then
				destroyElement( UI_elements.black_bg )
			end
		end, 1000, 1 )
	end
	localPlayer:setData( "quest_reward_window", false, false )
	unbindKey( "space", "down", hideCompletedInfo )
	unbindKey( "F2", "down", hideCompletedInfo )
	showCursor( false )
	
end
