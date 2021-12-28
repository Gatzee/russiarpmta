local scx, scy = guiGetScreenSize( )
local fonts = {
	bold_30 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 30, false, "default"),
}

local CLICK_COUNT = 5
local CLICK_COUNT_MAX_FAILED = 3
local LOOP_TIME = 2 * 1000
local CLICK_TIME = 0.75 * 1000
local HEART_TIME = LOOP_TIME - CLICK_TIME
local CLICK_TIMEOUT = 500
local INFO_TEXT_TIME = 0.5 * 1000

local started = false
local loop_start_tick = 0
local click_success = 0
local click_failed = 0
local last_click_tick = 0
local click_results = { }

local callback_event_success = nil
local callback_event_fail = nil
local callback_element = nil


function StartPlayerReanimation_handler( _callback_event_success, _callback_event_fail )
	if started then
		if _callback_event_fail then
			triggerEvent( _callback_event_fail, source, "Вы уже начали реанимацию" )
		end
		return
	end

	callback_event_success = _callback_event_success
	callback_event_fail = _callback_event_fail
	callback_element = source

	started = true
	loop_start_tick = getTickCount( )
	last_click_tick = loop_start_tick
	click_success = 0
	click_failed = 0
	click_results = { }

	addEventHandler( "onClientRender", root, DrawReanimationMiniGame )
	bindKey( "mouse1", "up", MouseClick_handler )
	showCursor( true )
end
addEvent( "StartPlayerReanimation" )
addEventHandler( "StartPlayerReanimation", root, StartPlayerReanimation_handler )

function StopPlayerReanimation_handler( )
	if not started then return end

	started = false
	callback_event_success = nil
	callback_event_fail = nil

	removeEventHandler( "onClientRender", root, DrawReanimationMiniGame )
	unbindKey( "mouse1", "up", MouseClick_handler )
	showCursor( false )
end
addEvent( "StopPlayerReanimation" )
addEventHandler( "StopPlayerReanimation", root, StopPlayerReanimation_handler )

function MouseClick_handler( )
	if not started then return end

	if ( last_click_tick + CLICK_TIMEOUT ) > getTickCount( ) then return end

	last_click_tick = getTickCount( )
	local tmp_loop_tick = last_click_tick - loop_start_tick

	if tmp_loop_tick > HEART_TIME then
		click_success = click_success + 1
		table.insert( click_results, { true, last_click_tick } )
	else
		click_failed = click_failed + 1
		table.insert( click_results, { false, last_click_tick } )
	end

	loop_start_tick = last_click_tick

	if click_failed >= CLICK_COUNT_MAX_FAILED then
		if callback_event_fail then
			triggerEvent( callback_event_fail, callback_element, "Реанимация не удалась" )
		end
		
		StopPlayerReanimation_handler( )
		return
	end
	
	if click_success >= CLICK_COUNT then
		if callback_event_success then
			triggerEvent( callback_event_success, callback_element )
		end
		
		StopPlayerReanimation_handler( )
		return
	end
end

function DrawReanimationMiniGame( )
	if not started then return end

	local heart_progress
	local heart_rotation = 0
	local click_progress = 0

	local tmp_loop_tick = getTickCount( ) - loop_start_tick

	if tmp_loop_tick <= HEART_TIME then
		heart_progress = tmp_loop_tick / HEART_TIME
	else	
		click_progress = ( tmp_loop_tick - HEART_TIME ) / CLICK_TIME

		heart_progress = 1
		heart_rotation = math.random( -10 * click_progress - 2, 10 * click_progress + 2 )
	end


	if click_progress > 1 then
		heart_progress = 0
		heart_rotation = 0
		click_progress = 0

		loop_start_tick = getTickCount( )
		last_click_tick = loop_start_tick
		click_failed = click_failed + 1

		table.insert( click_results, { false, last_click_tick } )

		if click_failed >= CLICK_COUNT_MAX_FAILED then
			if callback_event_fail then
				triggerEvent( callback_event_fail, callback_element, "Реанимация не удалась" )
			end
			
			StopPlayerReanimation_handler( )
			return
		end
	end


	dxDrawImage( ( scx - 200 ) / 2, ( scy - 200 ) / 2, 200, 200, "images/bg.png", 0, 0, 0, 0x80FFFFFF )
	
	if click_progress > 0 then
		dxDrawImage( ( scx - 200 ) / 2, ( scy - 200 ) / 2, 200, 200, "images/bg.png", 0, 0, 0, tocolor( 255, 0, 0, ( 128 * click_progress ) ) )
	end

	local gradient_size = 150 + 50 * heart_progress
	dxDrawImage( ( scx - gradient_size ) / 2, ( scy - gradient_size ) / 2, gradient_size, gradient_size, "images/gradient_bg.png" )

	local heart_size_x, heart_size_y = 75 * ( 0.75 + 0.25 * heart_progress ), 118 * ( 0.75 + 0.25 * heart_progress )
	dxDrawImage( ( scx - heart_size_x ) / 2, ( scy - heart_size_y ) / 2, heart_size_x, heart_size_y, "images/heart.png", heart_rotation )


	for i, info in pairs( click_results ) do
		local progress = 1 - ( getTickCount( ) - info[2] ) / INFO_TEXT_TIME
		if progress <= 0 then
			click_results[ i ] = nil
		else
			local pos_x, pos_y = scx / 2, scy / 2 - 100 + 50 * progress
			local color = info[1] and tocolor( 120, 250, 120, 255 * progress ) or tocolor( 250, 120, 120, 255 * progress )
			dxDrawText( info[1] and "УСПЕХ" or "ПРОВАЛ", pos_x, pos_y, pos_x, pos_y, color, progress, fonts.bold_30, "center", "center" )
		end
	end
end