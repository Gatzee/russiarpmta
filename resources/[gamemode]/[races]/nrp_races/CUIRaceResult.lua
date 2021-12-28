
local RESULT_DATA = 
{
	[ RACE_STATE_WIN ] 	  = { 0xFF4BDF71, "ВЫ ПОБЕДИЛИ",  "win"    },
	[ RACE_STATE_LOSE ]   = { 0xFFD42D2D, "ВЫ ПРОИГРАЛИ", "lose"   },
	[ RACE_STATE_FINISH ] = { 0xFFF2BE21, "ФИНИШ", 		  "finish" },
}

local timer_value = 0
local time_hide = 0
local is_reverse = false

function ShowFinishUI( state, result, data )
	if state then
		if isElement( UI_elements.start_timer_bg ) then
			destroyElement( UI_elements.start_timer_bg )
		end

		playSound( "files/sfx/finish.wav" )

		UI_elements.black_bg_finish = ibCreateBackground( _, _, 0xD7000000, _, true )
		UI_elements.bg_finish = ibCreateImage( 0, 0, scX, scY, "files/img/reward/bg_" .. RESULT_DATA[ result ][ 3 ] .. ".png", UI_elements.black_bg_finish)
		UI_elements.text_effect = ibCreateImage( 0, 120, scX, 26, "files/img/reward/" .. RESULT_DATA[ result ][ 3 ] .. "_text_effect.png", UI_elements.bg_finish )
		:center_x()

		local offset_px = 0
		if result == RACE_STATE_FINISH then
			offset_px = 90
			ibCreateImage( scX / 2 - 150, -20, 141, 67, "files/img/reward/finish_icon.png", UI_elements.text_effect )
		end

		ibCreateLabel( 0 + offset_px, 0, scX, 24, RESULT_DATA[ result ][ 2 ], UI_elements.text_effect, RESULT_DATA[ result ][ 1 ], 1, 1, "center", "center", ibFonts.bold_30 )
		:ibData( "outline", 1 )

		ibCreateImage( 0, 173, 827, 1, "files/img/reward/divided_line.png", UI_elements.bg_finish )
		:center_x()

		ConstructFinishContainerByResult( result, data, UI_elements.bg_finish )

		if result == RACE_STATE_WIN then
			ibCreateButton( 0, scY - 94, 100, 54, UI_elements.bg_finish, "files/img/reward/btn_ok.png", "files/img/reward/btn_ok_hovered.png", "files/img/reward/btn_ok_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end
				triggerServerEvent( "RC:OnPlayerPostFinishRace", resourceRoot )
				OnRacePostFinished()
			end )
			:center_x()

			removeEventHandler( "onClientKey", root, onResultClientKey_handler )
			addEventHandler( "onClientKey", root, onResultClientKey_handler )
		else
			local time = 15
			local function formatStr( time )
				local s = math.abs( time )
				local m = math.floor( s / 60 )
				local s = math.floor( s - m * 60 )
		
				return ( m > 0 and ( m .. " " .. plural( m, "минута", "минуты", "минут" ) .. " " ) or "" ) .. ( s > 0 and ( s .. " " .. plural( s, "секунда", "секунды", "секунд" ) ) or "" )
			end
			
			local offset = RACE_DATA.race_type == RACE_TYPE_DRAG and 80 or 200
			UI_elements.timehide = ibCreateArea( 0, scY - offset, 0, 0, UI_elements.black_bg_finish)
			UI_elements.lbl_name= ibCreateLabel( 0, 0, 0, 0, "Автовыход:", UI_elements.timehide, ibApplyAlpha( COLOR_WHITE, 80 ), _, _, "left", "center", ibFonts.bold_24 )
			:ibData( "outline", 1 )

			local lbl_time = ibCreateLabel( UI_elements.lbl_name:ibGetAfterX( 8 ), 0, 0, 0, formatStr( time ), UI_elements.timehide, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_26 )
			:ibData( "timestamp", getRealTimestamp() + time )
			:ibData( "outline", 1 )
			:ibTimer( function( self )
				local timestamp = self:ibData( "timestamp" )
				if timestamp then
					local diff = timestamp - getRealTimestamp()
					if diff < 0 then
						UI_elements.timehide:destroy()
						triggerServerEvent( "RC:OnPlayerPostFinishRace", resourceRoot )
						OnRacePostFinished()
					else
						self:ibData( "text", formatStr( diff ) )
						UI_elements.timehide:ibData( "sx", self:ibGetAfterX( ) ):center_x( )
					end
				end
			end, 1000, 0 )
			UI_elements.timehide:ibData( "sx", lbl_time:ibGetAfterX( ) ):center_x()
		end

	elseif isElement( UI_elements.black_bg_finish ) then
		destroyElement( UI_elements.black_bg_finish )
	end
end

function onResultClientKey_handler( key )
	if key == "space" then
		removeEventHandler( "onClientKey", root, onResultClientKey_handler )
		triggerServerEvent( "RC:OnPlayerPostFinishRace", resourceRoot )
		OnRacePostFinished()
	end
end

function ConstructFinishContainerByResult( result, data, parent )
	if RACE_DATA.race_type == RACE_TYPE_DRAG then
		local container = ibCreateArea( 0, 211, 252, 97, parent )
		:center_x()
		ibCreateLabel( 0, 7, 0, 0, "Вы заняли", container, 0xFFC7CAC5, 1, 1, "left", "center", ibFonts.regular_26 )
		:ibData( "outline", 1 )
		
		local oxanium_26 = dxCreateFont( "files/fonts/Oxanium-Bold.ttf", 26, false, "antialiased" )
		ibCreateLabel( 145, 4, 0, 0, data.place, container, 0xFFFFFFFF, 1, 1, "left", "center", oxanium_26 )
		:ibData( "outline", 1 )

		ibCreateLabel( 179, 7, 0, 0, "место", container, 0xFFC7CAC5, 1, 1, "left", "center", ibFonts.regular_26 )
		:ibData( "outline", 1 )

		ibCreateImage( 0, 47, 36, 41, "files/img/drag/timer.png", container )
		ibCreateLabel( 57, 69, 0, 0, MODES[ RACE_DATA.race_type ].prepare_points( data.points ), container, 0xFFFFFFFF, 1, 1, "left", "center", oxanium_26 )
		:ibData( "outline", 1 )

		if result == RACE_STATE_WIN then
			ibCreateImage( 0, scY - 462, 775, 377, "files/img/reward/reward_text_effect.png", parent )
			:center_x()
		else
			ibCreateLabel( 0, scY - 283, scX, 0, "ВАШ ПРОИГРЫШ", parent, RESULT_DATA[ result ][ 1 ], 1, 1, "center", "center", ibFonts.bold_20 )
			:ibData( "outline", 1 )
		end

		local block_reward = ibCreateImage( 0, scY - 234, 120, 120, "files/img/reward/block_reward.png", parent )
		:center_x()

		ibCreateImage( 0, 20, 47, 40, "files/img/reward/big_soft.png", block_reward )
		:center_x()

		ibCreateLabel( 0, 75, 120, 0, format_price( data.reward ), block_reward, 0xFFFFFFFF,  1, 1, "center", "top", ibFonts.bold_21 )
	elseif result == RACE_STATE_LOSE then
		ibCreateLabel( 0, 200, scX, 0, data.reason, parent, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_26 )
		:ibData( "outline", 1 )
	elseif RACE_DATA.race_type == RACE_TYPE_CIRCLE_TIME then
		local container = ibCreateArea( 0, 211, 300, 300, parent )
		:center_x()
		ibCreateLabel( 0, 0, 300, 0, "Занятое место " .. data.place .. " - " .. MODES[ RACE_DATA.race_type ].prepare_points( data.points ), container, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_26 )
		:ibData( "outline", 1 )

		ibCreateLabel( 0, 45, 300, 0, "Текущая позиция в общем списке " .. data.g_place .. ", лучшее время - " .. MODES[ RACE_DATA.race_type ].prepare_points( data.g_points ), container, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_26 )
		:ibData( "outline", 1 )
	elseif RACE_DATA.race_type == RACE_TYPE_DRIFT then
		local container = ibCreateArea( 0, 211, 300, 300, parent )
		:center_x()
		ibCreateLabel( 0, 0, 300, 0, "Занятое место " .. data.place .. " - " .. MODES[ RACE_DATA.race_type ].prepare_points( data.points ), container, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_26 )
		:ibData( "outline", 1 )
		
		if data.g_place then
			ibCreateLabel( 0, 45, 300, 0, "Текущая позиция в общем рейтинге дрифта " .. data.g_place .. " - " .. MODES[ RACE_DATA.race_type ].prepare_points( data.g_points ), container, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_26 )
			:ibData( "outline", 1 )
		end
	end
end

