loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "rewards/Client" )

ibUseRealFonts( true )

local ui = { }

enum "eWheelStates" {
	"WHEEL_STOP",
	"WHEEL_RUN",
	"WHEEL_CAN_STOP",
}

local SECTION_ROTATIONS = 
{
	[ SECTION_SMALL ] = { 330, 180, 210, 240, 120 },
	[ SECTION_MEDIUM ] = { 0, 60, 300 },
	[ SECTION_INVENTORY ] = { 30 },
	[ SECTION_BOOST_PLUS_50 ] = { 90 },
	[ SECTION_BOOST_X2 ] = { 270 },
	[ SECTION_JACKPOT ] = { 150 },
}

local reward_positions = { 150, 402, 652, 904 }
local point_positions = { 539, 449, 360, 269 }
local wheel_reward_positions = {
	-- small
	{ 322, 264, 120 },
	{ 30, 183, -90 },
	{ 48, 262, -120 },
	{ 107, 317, -150 },
	{ 107, 50, -30 },
	-- medium
	{ 343, 184, 90 },
	{ 265, 48, 30 },
	{ 261, 320, 150 },
	-- inventory
	{ 319, 108, 25 },
	-- boost +50
	{ 184, 29, 0 },
	-- boost X2
	{ 184, 340, 180 },
	-- jackpot
	{ 49, 110, -60 },
}

local REWARDS_CACHE = { }
local WOF_DATA = { }

local next_coin_time = FREE_COIN_PERIOD
local selected_tab = "default"
local current_boost = TYPE_BOOST_DEFAULT
local token_count = 1
local sound_state = true
local animation_state = false
local block_controls = false
local last_angle = math.random( 0, 12 ) * 30
local current_prize = 0
local target_angle = 0
local start_tick = 0
local current_angle = 0
local wheel_state = WHEEL_STOP

function InitWheel_handler( state, wof_data, rewards_cache, next_coin_time )
	next_coin_time = next_coin_time
	REWARDS_CACHE = rewards_cache
	WOF_DATA = wof_data
	selected_tab = "default"

	ShowUI( state, next_coin_time )
end
addEvent( "InitWheel", true )
addEventHandler( "InitWheel", root, InitWheel_handler )

function ShowUI( state, next_coin_time )
	if state then
		ShowUI( false )
		showCursor( true )
		addEventHandler( "onClientElementDataChange", root, UpdateBalanceTokenChangeData )

		ui = { }
		ui.black_bg	= ibCreateBackground( _, ShowUI, true, true )
		ui.bg = ibCreateImage( 0, 0, 1024, 720, "files/img/bg.png", ui.black_bg ):center( )
		wheel_state = WHEEL_STOP
		token_count = 1

		-- закрыть
		ui.close = ibCreateButton(	965, 36, 24, 24, ui.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			ShowUI( false )
		end, false )

		-- баланс
		ui.donate = ibCreateLabel( 820, 36, 0, 0, format_price( localPlayer:GetDonate( ) ), ui.bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
		ui.donate_img = ibCreateImage( ui.donate:ibGetAfterX( 8 ), 22, 28, 28, ":nrp_shared/img/hard_money_icon.png", ui.bg )
			
		-- пополнить
		ui.balance = ibCreateButton(	724, 47, 120, 20, ui.bg, "files/img/btn_balance_i.png", "files/img/btn_balance_h.png", "files/img/btn_balance_h.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			ShowUI( false )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "event_shop_main" )
		end, false )

		-- помощь
		ui.help = ibCreateButton(	912, 110, 83, 15, ui.bg, "files/img/btn_help.png", "files/img/btn_help.png", "files/img/btn_help.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			ShowInfo( true )
		end, false )


		local func_refresh_next_coin_time = function( self )
			next_coin_time = next_coin_time - 1
			if next_coin_time <= 0 then
				UpdateTokenBalance( )
				next_coin_time = FREE_COIN_PERIOD
			end

			local time_left = next_coin_time * 60

			local hours = math.floor( time_left / 60 / 60 )
            local minutes = math.floor( ( time_left - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_left - hours * 60 * 60 ) - minutes * 60 ) )
			
			local time_str = (hours > 0 and hours .. " ч " or "") .. (minutes > 0 and minutes .. " мин" or "") .. (hours == 0 and minutes == 0 and seconds .. " сек" or "")
			self:ibData( "text", time_str )
		end

		-- бесплатный жетон
		ui.next_coin_time = ibCreateLabel( 477, 108, 0, 0, "Бесплатный жетон через: ", ui.bg, 0x99FFFFFF, _, _, _, _, ibFonts.regular_14 )
		ui.next_coin_time_value = ibCreateLabel( 660 - 477, 117 - 108, 0, 0, "", ui.next_coin_time, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_16 ):ibTimer( func_refresh_next_coin_time, 60000, 0 )
		func_refresh_next_coin_time( ui.next_coin_time_value )

		-- обновится через ( шкала очков )
		local function GetPointsTime( )
			local date_now = convertUnixToDate( getRealTimestamp( ) )
			return 24 - date_now.hour .. " ч."
		end

		ui.next_point_time = ibCreateLabel( 59, 686, 0, 0, GetPointsTime( ), ui.bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_12 )
			:ibTimer( function( )
				ui.next_point_time:ibData( "text", GetPointsTime( ) )
			end, 60000, 0 )

		-- ваш баланс
		ui.coin_label = ibCreateLabel( 477 + 277, 108, 0, 0, "Ваш баланс: ", ui.bg, 0xAAFFFFFF, _, _, _, _, ibFonts.regular_14 )
		ui.coin = ibCreateLabel( 477 + 277 + 90, 106, 0, 0, localPlayer:GetCoins( selected_tab ), ui.bg, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_16 )

		-- табы
		local px = 0
		for type, info in pairs( ROULETTE_CONFIG ) do
			local text_len = dxGetTextWidth( info.name, 1, ibFonts.regular_16 )
			ui[ "tab_button_" .. type ] = ibCreateArea( px + 30, 91, text_len, 71, ui.bg )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				if block_controls then return end
                ibClick( )
                if selected_tab == type then return end
                SwitchTabMenu( type )
            end )

			ui[ "tab_name_" .. type ] = ibCreateLabel( 0, 15, text_len, 0, info.name, ui[ "tab_button_" ..  type ], 0xFFC2C8CE, 1, 1, "center", "top", ibFonts.regular_16 )
			:ibData( "disabled", true )
			
			if not isElement( ui.tab_line_img ) then
                ui.tab_line_img = ibCreateImage( 30, 137, text_len, 4, false, ui.bg, 0xFFFF965D )
                SwitchTabMenu( type )
			end
            
			px = px + text_len + 28
			-- стоимость жетонов
			ui[ "token_cost_icon_" .. type ] = ibCreateImage( 839, 384, 22, 22, "files/img/icon_coin_" .. type .. ".png", ui.bg ):ibData( "alpha", selected_tab == type and 255 or 0 )
			ui[ "token_count_icon_" .. type ] = ibCreateImage( 894, 482, 28, 28, "files/img/icon_coin_" .. type .. ".png", ui.bg ):ibData( "alpha", selected_tab == type and 255 or 0 )

			-- ваш баланс
			ui[ "token_count_" .. type ] = ibCreateImage( ui.coin:ibGetAfterX( 8 ), 106, 20, 20, "files/img/icon_coin_" .. type .. ".png", ui.bg ):ibData( "alpha", selected_tab == type and 255 or 0 )
		end

		-- количество жетонов
		ibCreateLabel( 826, 383, 0, 0, "1", ui.bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )
		ibCreateImage( 888 + 25, 383, 27, 22, "files/img/icon_hard.png", ui.bg )
		ui.token_count = ibCreateLabel( 875, 485, 0, 0, token_count, ui.bg, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_16 )
		ui.token_cost = ibCreateLabel( 888, 383, 0, 0, localPlayer:GetCostRoullete( selected_tab ), ui.bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )

		-- плюс
		ui.plus = ibCreateButton(	942, 477, 40, 40, ui.bg, "files/img/plus.png", "files/img/plus.png", "files/img/plus.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if block_controls then return end
			ibClick( )
			UpdateTokenCount( true )
		end, false )

		-- минус
		ui.minus = ibCreateButton(	782, 477, 40, 40, ui.bg, "files/img/minus.png", "files/img/minus.png", "files/img/minus.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if block_controls then return end
			ibClick( )
			UpdateTokenCount( false )
		end, false )

		-- к оплате
		local cost = localPlayer:GetCostRoullete( selected_tab )		
		ui.token_cost_buy = ibCreateLabel( 877, 606, 0, 0, format_price( token_count * cost ), ui.bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.bold_20 )
		ui.token_icon_buy = ibCreateImage( ui.token_cost_buy:ibGetAfterX( 6 ), 605 - 12, 34, 28, "files/img/icon_hard.png", ui.bg )

		-- оплатить
		ui.buy = ibCreateButton(	807, 641, 150, 50, ui.bg, "files/img/btn_buy_i.png", "files/img/btn_buy_h.png", "files/img/btn_buy_h.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			if block_controls then return end
			ibClick( )
			triggerServerEvent( "BuyCoins", localPlayer, token_count, selected_tab )
		end, false )

		-- блокировка кнопок
		ui.block_controls = ibCreateArea( 685, 656, 36, 50, ui.bg ):ibData( "priority", -1 )

		-- звук
		ui.sound = ibCreateSlider( 685, 656, ui.bg, function( new_state )
			sound_state = new_state
		end, sound_state, "small" )

		-- анимация
		ui.animation = ibCreateSlider( 685, 686, ui.bg, function( new_state )
			animation_state = new_state
		end, animation_state, "small" )

		-- крутить
		ui.wheel_run = ibCreateButton( 309, 370, 247, 247, ui.bg, "files/img/run_i.png", "files/img/run_h.png", "files/img/run_h.png" ):ibData( "priority", 5 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			if wheel_state == WHEEL_STOP then
				triggerServerEvent( "SpinWheel", localPlayer, selected_tab, animation_state )
				wheel_state = localPlayer:GetCoins( selected_tab ) == 0 and WHEEL_STOP or WHEEL_RUN
				ibClick( )
			elseif wheel_state == WHEEL_CAN_STOP then
				ibClick( )
				StopSpinningWheel( )
			end
		end, false )

		ui.wheel_run_btn = ibCreateLabel( 122, 115, 0, 0, "КРУТИТЬ", ui.wheel_run, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.extrabold_18 )

		ProgressPoints( )
		ProgressRewards( )
		Wheel( )
	else
		showCursor( false )
		removeEventHandler( "onClientElementDataChange", root, UpdateBalanceTokenChangeData )
		DestroyTableElements( ui )
		ShowInfo( false )
	end
end
addEvent( "roulette:ShowUI", true )
addEventHandler( "roulette:ShowUI", root, ShowUI )

-- количество покупаемых жетов
function UpdateTokenCount( is_plus )
	if ( token_count == 1 and not is_plus ) or token_count == 1000 then return end

	token_count = is_plus and token_count + 1 or token_count - 1
	ui.token_count:ibData( "text", token_count )
	ui.token_cost_buy:ibData( "text", token_count * localPlayer:GetCostRoullete( selected_tab ) )
	ui.token_icon_buy:ibData( "px", ui.token_cost_buy:ibGetAfterX( 6 ) )
end

-- баланс hard
function UpdateDonateBalance( )
	if not ui.donate then return end

	ui.donate:ibData( "text", format_price( localPlayer:GetDonate( ) ) )
	ui.donate_img:ibData( "px", ui.donate:ibGetAfterX( 8 ) )
end

-- баланс жетонов
function UpdateTokenBalance( )
	if not ui[ "token_count_" .. selected_tab ] then return end

	ui.coin:ibData( "text", localPlayer:GetCoins( selected_tab ) )
	ui[ "token_count_" .. selected_tab ]:ibData( "px", ui.coin:ibGetAfterX( 8 ) )
end

-- обновить tooltip inventory
function UpdatePositionTooltip( )
	if not ui.black_bg or not ui.wheel.bg then return end

	ui.wheel.tooltip:ibData( "disabled", false )

	local x = ui.wheel.bg:ibGetCenterX( )
	local y = ui.wheel.bg:ibGetCenterY( )
	local position = Vector3( x, y, 0 )
	local offset = position:offset( 170, last_angle - 120 )

	ui.wheel.tooltip:ibBatchData( { px = offset.x - 30, py = offset.y - 30 } )

	local tooltip = ""

	for k, item in ipairs( INVENTORY_CONFIG[ selected_tab ][ current_boost ] ) do
		local type = item.reward.type
		local name, count

		if type == "box" then
			for k, v in pairs( item.reward.params.items ) do
				name = name and name .. " + " or ""
				name = name .. TOOLTIP_NAMES[ k ]
				count = v.count
			end
		else
			name = TOOLTIP_NAMES[ type ]
			count = item.reward.params.count
		end
		
		tooltip = tooltip .. name .. " ( " .. count .. " )" .. "\n"
	end

	ui.wheel.tooltip:ibAttachTooltip( tooltip )
end

-- колесо
function Wheel( )
	if not ui.black_bg then return end

	DestroyTableElements( ui.wheel )
	ui.wheel = { }

	local boost_type = next( WOF_DATA[ selected_tab ].last_wheel_reward ) and WOF_DATA[ selected_tab ].last_wheel_reward.boost_type or TYPE_BOOST_DEFAULT
	local boost_img = ( boost_type == TYPE_BOOST_PLUS_50 and "_plus_50" ) or ( boost_type == TYPE_BOOST_X2 and "_x2" ) or ""

	current_boost = boost_type

	ui.wheel.bg = ibCreateImage( 216, 280, 430, 430, "files/img/wheel_" .. selected_tab .. boost_img .. ".png", ui.bg ):ibData( "rotation", last_angle )

	ui.wheel.rewards = ibCreateRenderTarget( 216, 280, 430, 430, ui.bg )
	:ibData( "rotation", last_angle )
	:ibData( "disabled", true )

	local reward_position = 1
	for section, rewards in ipairs( REWARDS_CACHE.rewards[ selected_tab ] ) do

		if section == SECTION_JACKPOT then -- ячейка jackpot одна
			rewards = { rewards[ rewards.jackpot_index ] }
		elseif section == SECTION_INVENTORY then -- ячейка инвентарь одна
			local position = wheel_reward_positions[ reward_position ]
			ibCreateImage( position[ 1 ], position[ 2 ], 60, 60, WHEEL_REWARD_TYPES[ TYPE_INVENTORY ].img, ui.wheel.rewards ):ibData( "rotation", position[ 3 ] ):ibData( "disabled", true )

			ui.wheel.tooltip = ibCreateArea( position[ 1 ], position[ 2 ], 75, 75, ui.bg )

			reward_position = reward_position + 1
		end

		for k, v in ipairs( rewards ) do
			local position = wheel_reward_positions[ reward_position ]

			if v.type == TYPE_BOOST_PLUS_50 or v.type == TYPE_BOOST_X2 then
				ibCreateLabel( position[ 1 ], position[ 2 ], 60, 60, WHEEL_REWARD_TYPES[ v.type ].name, ui.wheel.rewards, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 ):ibData( "rotation", position[ 3 ] )
				:ibData( "rotation_center_x", position[ 1 ] + 30 )
				:ibData( "rotation_center_y", position[ 2 ] + 30 )
				:ibData( "disabled", true )
			elseif v.type == TYPE_SOFT then
				ibCreateImage( position[ 1 ], position[ 2 ], 60, 60, WHEEL_REWARD_TYPES[ v.type ].img, ui.wheel.rewards )
				:ibData( "rotation", position[ 3 ] )
				:ibData( "disabled", true )

				ibCreateLabel( position[ 1 ], position[ 2 ] + 15, 60, 60, format_price( v.count ), ui.wheel.rewards, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 ):ibData( "rotation", position[ 3 ] )
				:ibData( "rotation_center_x", position[ 1 ] + 30 )
				:ibData( "rotation_center_y", position[ 2 ] + 30 )
				:ibData( "disabled", true )
			elseif v.type == TYPE_EXP then
				ibCreateImage( position[ 1 ], position[ 2 ], 60, 60, WHEEL_REWARD_TYPES[ v.type ].img, ui.wheel.rewards )
				:ibData( "rotation", position[ 3 ] )
				:ibData( "disabled", true )

				ibCreateLabel( position[ 1 ], position[ 2 ] - 9, 60, 60, format_price( v.count ), ui.wheel.rewards, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_16 ):ibData( "rotation", position[ 3 ] )
				:ibData( "rotation_center_x", position[ 1 ] + 30 )
				:ibData( "rotation_center_y", position[ 2 ] + 30 )
				:ibData( "disabled", true )
			end

			reward_position = reward_position + 1
		end
	end

	ui.wheel.pointer = ibCreateImage( 592, 454, 67, 82, "files/img/pointer_" .. selected_tab .. ".png", ui.bg ):ibData( "disabled", true )
	--ui.wheel.type = ibCreateImage( 428, 508, 18, 18, "files/img/icon_coin_" .. selected_tab .. ".png", ui.bg ):ibData( "priority", 6 ):ibData( "disabled", true )

	ui.wheel.coin_bg = ibCreateImage( 100, 134, 44, 24, "files/img/coin_bg.png", ui.wheel_run ):ibData("disabled", true)
	ui.wheel.spin_cost = ibCreateLabel( 8, 0, 0, 24, "1", ui.wheel.coin_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.extrabold_16 ):ibData("disabled", true)
	ui.wheel.coin_img = ibCreateImage( 19, 3, 18, 18, "files/img/icon_coin_" .. selected_tab .. ".png", ui.wheel.coin_bg ):ibData( "disabled", true )

	UpdatePositionTooltip( )
end

-- прогресс очков
function ProgressPoints( )
	if not ui.black_bg then return end

	DestroyTableElements( ui.progress_points )
	ui.progress_points = { }

	local data = WOF_DATA[ selected_tab ]
	local progress_index = 1

	ui.progress_points.line = ibCreateImage( 32, 217 + 435, 56, 435, "files/img/progress_point.png", ui.bg )

	ui.progress_points.timer_tooltip = ibCreateArea( 32, 217, 56, 435, ui.bg )
	:ibAttachTooltip( "Таймер обновления шкалы очков.\nОбновляется каждые 24 часа" )

	ui.progress_points.timer = ibCreateImage( 50, 612, 20, 22, "files/img/timer.png", ui.bg ):ibData( "disabled", true )

	for k, v in ipairs( PROGRESS_POINTS[ selected_tab ] ) do
		local received = data.game_count_day >= v.games
		progress_index = data.game_count_day > v.games and progress_index + 1 or progress_index

		ui.progress_points[ "icon_" .. k ] = ibCreateImage( 34, point_positions[ k ], 50, 50, "files/img/point_" .. ( received and "received" or "available" ) .. ( k == #point_positions and "_gold" or "" ) .. ".png", ui.bg )
		ui.progress_points[ "point_" .. k ] = ibCreateLabel( 0, 0, 50, 50, "+" .. v.points, ui.progress_points[ "icon_" .. k ], COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
		if not received then
			ui.progress_points[ "game_lock_" .. k ] = ibCreateImage( 0, 18, 51, 45, "files/img/point_win.png", ui.progress_points[ "icon_" .. k ] )
			ui.progress_points[ "games_" .. k ] = ibCreateLabel( 26, 52, 0, 0, v.games - data.game_count_day, ui.progress_points[ "icon_" .. k ], 0xFF37495c, 1, 1, "center", "center", ibFonts.bold_10 )

			ui.progress_points[ "win_tooltip_" .. k ] = ibCreateArea( 0, 0, 50, 60, ui.progress_points[ "icon_" .. k ] )
			:ibAttachTooltip( "Крути колесо фортуны, чтобы\nразблокировать дополнительные\nочки для получения награды" )
		end
	end

	progress_index = math.min( #PROGRESS_POINTS[ selected_tab ], progress_index )
	local progress_games_received = progress_index == 1 and 0 or PROGRESS_POINTS[ selected_tab ][ progress_index - 1 ].games
	local games = data.game_count_day - progress_games_received
	local progress = ( games * 20.5 ) / ( PROGRESS_POINTS[ selected_tab ][ progress_index ].games - progress_games_received ) + ( 20.5 * ( progress_index - 1 ) )

	local progress_points = PROGRESS_POINTS[ selected_tab ]
	local games_max = progress_points[ #progress_points ].games

	if data.game_count_day >= games_max then
		progress = 100
	end

	ui.progress_points.line:ibData( "section", { px = 0, py = 0, sx = 56, sy = - ( ( 435 / 100 ) * progress ) } )

	ui.progress_points.points = ibCreateImage( 18, 159, 84, 84, "files/img/points.png", ui.bg )
	ui.progress_points.point_all = ibCreateLabel( 60, 196, 0, 0, WOF_DATA[ selected_tab ].season_points, ui.bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
end

-- прогресс товаров
--function ProgressRewards( )
--	if not ui.black_bg then return end

--	DestroyTableElements( ui.progress_rewards )
--	ui.progress_rewards = { }

--	local data = WOF_DATA[ selected_tab ]
--	local progress_index = 1

--	ui.progress_rewards.line = ibCreateImage( 86, 174, 840, 55, "files/img/progress_reward.png", ui.bg )
--	:ibData( "section", { px = 0, py = 0, sx = 0, sy = 55 } )
	
--	for k, v in ipairs( PROGRESS_REWARDS[ REWARDS_CACHE.season ].rewards[ selected_tab ] ) do
	--	local need_points = PROGRESS_REWARDS_POINTS[ k ]
	--	local received = data.season_points >= need_points
	--	progress_index = data.season_points >= need_points and progress_index + 1 or progress_index

	--	ui.progress_rewards[ "bg_" .. k ] = ibCreateImage( reward_positions[ k ], 155, 90, 90, received and "files/img/reward_bg_received.png" or "files/img/reward_bg.png", ui.bg )
	--	ui.progress_rewards[ "reward_" .. k ] = ibCreateContentImage( 0, 0, 90, 90, v.reward.type, v.reward.params.model or v.reward.params.id, ui.progress_rewards[ "bg_" .. k ] )
	--	:ibData( "alpha", received and 255*0.15 or 255 )

	--	if v.reward.params.temp_days then
	--		ui.progress_rewards[ "reward_" .. k ]:ibData( "py", -5 )
	--		ibCreateLabel( 45, 72, 0, 0, v.reward.params.temp_days * 24 .." ч", ui.progress_rewards[ "reward_" .. k ], _, 1, 1, "center", "center", ibFonts.bold_14 )
	--	end

	--	if received then
	--		ui.progress_rewards[ "received_" .. k ] = ibCreateImage( 0, 0, 90, 90, "files/img/reward_received.png", ui.progress_rewards[ "bg_" .. k ] )
	--	else
	--		ui.progress_rewards[ "reward_lock__" .. k ] = ibCreateImage( 0, 74, 90, 32, "files/img/reward_point.png", ui.progress_rewards[ "bg_" .. k ] )
	--		ui.progress_rewards[ "points_" .. k ] = ibCreateLabel( 26 + 19, 52 + 38, 0, 0, need_points - data.season_points, ui.progress_rewards[ "bg_" .. k ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_12 )
	--	end

	--	ui.progress_rewards[ "tooltip_" .. k ] = ibCreateArea( 0, 0, 90, 100, ui.progress_rewards[ "bg_" .. k ] ):ibData( "priority", 2 )
	--	:ibAttachTooltip( ( v.reward.params.temp_days and "Выдается на " .. 24 * v.reward.params.temp_days .. " ч.\n" or "" ) .. "Заработай " .. need_points .. " " .. plural( need_points, "очко", "очка", "очков" ) .. " для\nполучения награды" )
--	end

	--if progress_index > #PROGRESS_REWARDS[ REWARDS_CACHE.season ].rewards[ selected_tab ] then
--		ui.progress_rewards.line:ibData( "section", { px = 0, py = 0, sx = 840, sy = 55 } )
	--	return
--	end

	--local progress_point_received = progress_index == 1 and 0 or PROGRESS_REWARDS_POINTS[ progress_index - 1 ]
--	local points = data.season_points - progress_point_received
--	local progress_size = progress_index == 1 and 7.85 or 19.65
--	local progress = ( points * progress_size ) / ( PROGRESS_REWARDS_POINTS[ progress_index ] - progress_point_received )
--	local progress_offset_interval = progress_index > 2 and 19.65 * ( progress_index - 2 ) or 0
--	local progress_offset_reward = progress_index == 1 and 0 or 11 * ( progress_index - 1 ) + 7.85

--	ui.progress_rewards.line:ibData( "section", { px = 0, py = 0, sx = ( 840 / 100 ) * ( progress + progress_offset_interval + progress_offset_reward ), sy = 55 } )
--end

-- переключние обычная / вип
function SwitchTabMenu( tab_type )
    if selected_tab and ui[ "tab_name_" .. selected_tab ] then
		ui[ "tab_name_" .. selected_tab ]:ibData( "color", 0xFFC2C8CE )
	end

	if ui[ "token_cost_icon_" .. selected_tab ] then
		ui[ "token_cost_icon_" .. selected_tab ]:ibData( "alpha", 0 )
		ui[ "token_count_icon_" .. selected_tab ]:ibData( "alpha", 0 )
	end

	if ui[ "token_cost_icon_" .. tab_type ] then
		ui[ "token_cost_icon_" .. tab_type ]:ibData( "alpha", 255 )
		ui[ "token_count_icon_" .. tab_type ]:ibData( "alpha", 255 )
	end

	if ui[ "token_count_" .. selected_tab ] then
		ui[ "token_count_" .. selected_tab ]:ibData( "alpha", 0 )
	end

	if ui[ "token_count_" .. tab_type ] then
		ui[ "token_count_" .. tab_type ]:ibData( "alpha", 255 )
	end 

	ui.next_coin_time:ibData( "alpha", tab_type == "default" and 255 or 0 )
	
	selected_tab = tab_type
	UpdateTokenBalance( )
	UpdateTokenCount( )
	ProgressPoints( )
	--ProgressRewards( )
	Wheel( )

	ui[ "tab_name_" .. selected_tab ]:ibData( "color", COLOR_WHITE )

	if ui.token_cost then
		local cost = localPlayer:GetCostRoullete( selected_tab )
		ui.token_cost:ibData( "text", cost )
		ui.token_cost_buy:ibData( "text", token_count * cost )
	end

	if selected_tab == "default" then
		if isElement( ui.coupons ) then destroyElement( ui.coupons ) end
	elseif not isElement( ui.coupons ) then
		local cost, coupon_discount_value = localPlayer:GetCostRoullete( selected_tab )		
		if coupon_discount_value then
			ui.coupons = exports.nrp_shop:CreateDiscountCoupon( 765, 590, "special_vip_wof", coupon_discount_value, ui.bg )
		end
	end

    local px = ui[ "tab_button_" .. selected_tab ]:ibData( "px" )
    local sx = ui[ "tab_button_" .. selected_tab ]:ibData( "sx" )
    ui.tab_line_img:ibMoveTo( px, _, 250, "Linear" )
    ui.tab_line_img:ibResizeTo( sx, _, 250, "Linear" )
end

-- помощь
function ShowInfo( state )
    if not ui.black_bg then return end

	local sx, sy = 1024, 628

    if state then
        ShowInfo( )

        ui.info_rt = ibCreateRenderTarget( 0, 92, sx, sy, ui.bg ):ibData( "priority", 5 )
        ui.info = ibCreateImage( 0, -sx, sx, sy, "files/img/info.png", ui.info_rt )
        
		ibCreateButton(	458, 604 - 46, 108, 42, ui.info, "files/img/btn_hide_i.png", "files/img/btn_hide_h.png", "files/img/btn_hide_h.png" )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick( )
            ShowInfo( )
        end )

        ui.info:ibMoveTo( 0, 0, 300 )
        ibOverlaySound( )
    elseif isElement( ui.info_rt ) then
        ui.info:ibMoveTo( 0, -sy, 300 )
        :ibTimer( function()
            destroyElement( ui.info_rt )
        end, 300, 1 )
        ibOverlaySound( )
    end
end

function ShowReward_handler( wof_data, show_reward_data, update_rewards_cache, update_rewards_season )
	if update_rewards_cache then REWARDS_CACHE = update_rewards_cache end
	if update_rewards_season then REWARDS_CACHE.season = update_rewards_season	end

	if wof_data then 
		WOF_DATA = wof_data 
		Wheel( )
		ProgressPoints( )
		ProgressRewards( )
	end

	wheel_state = WHEEL_STOP

	if not show_reward_data or not ui.black_bg or not show_reward_data.reward then return end

    ShowTakeReward( ui.black_bg, show_reward_data.reward, function( data )
		for k, v in ipairs( PROGRESS_POINTS[ selected_tab ] ) do
			if WOF_DATA[ selected_tab ].game_count_day == v.games and not show_reward_data.is_season_reward and not show_reward_data.is_confirmation_passed then
				ui.progress_points_notification = ibCreateLabel( 61, 161, 0, 0, "+" .. v.points, ui.bg, 0xff9ccaff, 1, 1, "center", "center", ibFonts.bold_12 )

				ui.progress_points_notification:ibTimer( function( self )
					if not isElement( ui.progress_points_notification ) then return end
					ui.progress_points_notification:destroy( )
				end, 3000, 1 )
				break
			end
		end
		
		if show_reward_data.is_season_reward or show_reward_data.is_confirmation_passed then
			triggerServerEvent( "GiveSeasonReward", localPlayer, localPlayer, show_reward_data.roulette, show_reward_data.is_confirmation_passed, data )
		end
    end )
end
addEvent( "ShowReward", true )
addEventHandler( "ShowReward", resourceRoot, ShowReward_handler )

function SpinTheWheel_handler( section, index )
	UpdateTokenBalance( )

	if section == SECTION_INVENTORY then index = 1 end
	if section == SECTION_JACKPOT then index = 1 end

	if animation_state then 
		last_angle = SECTION_ROTATIONS[ section ][ index ]
		triggerServerEvent( "GiveWheelReward", localPlayer, localPlayer, selected_tab )
		return 
	end

	ui.wheel.tooltip:ibData( "disabled", true )

	local spin = 360 * math.random( 8, 12 )
	target_angle = spin + SECTION_ROTATIONS[ section ][ index ]
	start_tick = getTickCount( )
	current_angle = last_angle

	addEventHandler( "onClientRender", root, SpinningWheel )
	BlockControls( true )

	ui.wheel.coin_bg:ibAlphaTo( 0, 300 )

	setTimer( function( )
		ui.wheel_run_btn:ibData( "text", "СТОП" )
		wheel_state = WHEEL_CAN_STOP
	end, 1000, 1 )
end
addEvent( "SpinTheWheel", true )
addEventHandler( "SpinTheWheel", resourceRoot, SpinTheWheel_handler )

function onClientRefreshCouponsRoullete_handler()
	if selected_tab ~= "gold" then return end

	if isElement( ui.coupons ) then destroyElement( ui.coupons ) end
	local cost, coupon_discount_value = localPlayer:GetCostRoullete( selected_tab )		
	if coupon_discount_value then
		ui.coupons = exports.nrp_shop:CreateDiscountCoupon( 765, 590, "special_vip_wof", coupon_discount_value, ui.bg )
	end

	ui.token_cost:ibData( "text", cost )
	ui.token_cost_buy:ibData( "text", token_count * cost )
	ui.token_icon_buy:ibData( "px", ui.token_cost_buy:ibGetAfterX( 6 ) )
end
addEvent( "onClientRefreshCouponsRoullete", true )
addEventHandler( "onClientRefreshCouponsRoullete", resourceRoot, onClientRefreshCouponsRoullete_handler )

function StopSpinningWheel( )
	removeEventHandler( "onClientRender", root, SpinningWheel )

	ui.black_bg:ibTimer( function()
		BlockControls( false )
	end, 150, 1 )
	
	last_angle = target_angle - 360 * math.floor( target_angle / 360 )
	ui.wheel.bg:ibData( "rotation", last_angle )
	ui.wheel.rewards:ibData( "rotation", last_angle )
	ui.wheel_run_btn:ibData( "text", "КРУТИТЬ" )

	UpdatePositionTooltip( )
	triggerServerEvent( "GiveWheelReward", localPlayer, localPlayer, selected_tab )

	wheel_state = WHEEL_STOP

	ui.wheel.coin_bg:ibAlphaTo( 255, 300 )
end

function SpinningWheel( )
	local progress = ( ( getTickCount( ) - start_tick ) / 13000 ) / 2
	local angle = interpolateBetween( last_angle, 0, 0, target_angle, 0, 0, progress, "SineCurve" )
	ui.wheel.bg:ibData( "rotation", angle )
	ui.wheel.rewards:ibData( "rotation", angle )

	if sound_state and angle - current_angle > 30 then
		current_angle = angle
		playSound( "files/sound/wheel_fortune.wav" ).volume = 0.1
	end

	if progress >= 0.5 then
		removeEventHandler( "onClientRender", root, SpinningWheel )
		ui.black_bg:ibTimer( function()
			BlockControls( false )
		end, 150, 1 )

		wheel_state = WHEEL_STOP
		ui.wheel_run_btn:ibData( "text", "КРУТИТЬ" )
		triggerServerEvent( "GiveWheelReward", localPlayer, localPlayer, selected_tab )
		last_angle = angle - 360 * math.floor( angle / 360 )

		UpdatePositionTooltip( )
	end
end

function BlockControls( state )
	block_controls = state

	for k,v in pairs( ui ) do
		if isElement( v ) and v.type == "ibButton" and v ~= ui.wheel_run then
			v:ibData( "disabled", state )
		end
	end
	ui.block_controls:ibData( "priority", state and 5 or -1 )
	ui.black_bg:ibData( "can_destroy", not state )

	if state then
		addEventHandler( "onClientKey", root, OnClientKeyHandler )
	else
		removeEventHandler("onClientKey", root, OnClientKeyHandler )
	end
end

function OnClientKeyHandler( )
	cancelEvent( )
end

function UpdateBalanceTokenChangeData( key, old, new )
	if not isElement( ui.bg ) then return end
	if source ~= localPlayer then return end
	if key ~= "donate" and key ~= "_coins_default" and key ~= "_coins_gold" then return end

	if ( key == "_coins_default" or key == "_coins_gold" ) and new > ( old or 0 ) then
		UpdateTokenBalance( )
	else
		UpdateDonateBalance( )
	end
end