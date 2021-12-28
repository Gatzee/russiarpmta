loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ib" )

local scx, scy = guiGetScreenSize( )
local fonts = {
	regular_12 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 12, false, "default"),
	sbold_20 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 20, false, "default"),
}

local started = false
local selected_port = false
local selected_number = { 0, 0, 0, 0 }
local secret_number = { 0, 0, 0, 0 }
local attempts_count = 3

local callback_event_success = nil
local callback_event_fail = nil
local callback_element = nil

local ui_elements = { }


function StartPlayerDemining_handler( _callback_event_success, _callback_event_fail )
	if started then
		if _callback_event_fail then
			triggerEvent( _callback_event_fail, source, "Вы уже начали разминирование" )
		end
		return
	end

	started = true
	selected_port = false
	selected_number = { 0, 0, 0, 0 }
	secret_number = { math.random( 0, 9 ), math.random( 0, 9 ), math.random( 0, 9 ), math.random( 0, 9 ) }
	attempts_count = 3

	iprint( "bomb code", secret_number )

	callback_event_success = _callback_event_success
	callback_event_fail = _callback_event_fail
	callback_element = source
	
	showCursor( true )

	ui_elements.black_bg	= ibCreateBackground( _, StopPlayerDemining_handler )
	ui_elements.bg			= ibCreateImage( ( scx - 601 ) / 2, ( scy - 267 ) / 2 + 50, 601, 267, "images/bg.png", ui_elements.black_bg )
	ui_elements.bg:ibData( "alpha", 0 )
	ui_elements.bg:ibMoveTo( ( scx - 601 ) / 2, ( scy - 267 ) / 2, 500 ):ibAlphaTo( 255, 400 )
	
	for i = 1, 4 do
		ui_elements[ "btn_port_".. i ] 	= ibCreateButton(	10 + 70 * ( i- 1 ), 180, 66, 80, ui_elements.bg,
															"images/button_port_idle.png", "images/button_port_idle.png", "images/button_port_active.png",
															0xFFFFFFFF, 0xFFCCCCCC, 0xFFFFFFFF )
		addEventHandler( "ibOnElementMouseClick", ui_elements[ "btn_port_".. i ], function( key, state )
			if key ~= "left" or state ~= "down" then return end

			ui_elements[ "number_line_".. i ]:ibData( "color", 0xff6788ff )
			selected_port = i

			playSound( "sounds/port_setup.wav" ):setVolume( 0.1 )
		end, false )

		ui_elements[ "number_".. i ] = ibCreateLabel( 375 + 50 * ( i - 1), 58, 0, 0, "0", ui_elements.bg, 0xffadbfff )
		ui_elements[ "number_".. i ]:ibBatchData( { font = fonts.sbold_20, align_x = "center", align_y = "center" } )

		ui_elements[ "number_line_".. i ] = ibCreateImage( 357 + 50 * ( i - 1), 77, 36, 2, nil, ui_elements.bg, 0x506788ff )
	end

	ui_elements.attempts_text = ibCreateLabel( 450, 108, 0, 0, "Количество попыток: 3", ui_elements.bg, 0xffea9b9b )
	ui_elements.attempts_text:ibBatchData( { font = fonts.regular_12, align_x = "center", align_y = "center" } )

	ui_elements.btn_try 	= ibCreateButton(	380, 137, 138, 46, ui_elements.bg,
												nil, nil, nil, 0xff345832, 0xf0345832, 0xff345832 )
	ui_elements.btn_try_text = ibCreateLabel( 450, 108, 0, 0, "Применить", ui_elements.btn_try )
	ui_elements.btn_try_text:ibBatchData( { font = fonts.regular_12, align_x = "center", align_y = "center" } ):center( )
	addEventHandler( "ibOnElementMouseClick", ui_elements.btn_try, function( key, state )
		if key ~= "left" or state ~= "up" then return end

		for port = 1, 4 do
			if selected_number[ port ] ~= secret_number[ port ] then
				attempts_count = attempts_count - 1

				ui_elements.attempts_text:ibData( "text", "Количество попыток: ".. attempts_count )
				playSound( "sounds/code_error.wav" ):setVolume( 0.1 )

				if attempts_count == 0 then
					if callback_event_fail then
						triggerEvent( callback_event_fail, callback_element, "Деактивация не удалась" )
					end

					StopPlayerDemining_handler()
				end

				return
			end
		end

		playSound( "sounds/code_success.wav" ):setVolume( 0.1 )

		if callback_event_success then
			triggerEvent( callback_event_success, callback_element )
		end
		
		StopPlayerDemining_handler( )
	end, false )

	bindKey( "mouse_wheel_up", "down", PlayerChangeSelectedNumber, 1 )
	bindKey( "mouse_wheel_down", "down", PlayerChangeSelectedNumber, -1 )
end
addEvent( "StartPlayerDemining" )
addEventHandler( "StartPlayerDemining", root, StartPlayerDemining_handler )

function StopPlayerDemining_handler( )
	if not started then return end

	showCursor( false )

	started = false
	callback_event_success = nil
	callback_event_fail = nil

	unbindKey( "mouse_wheel_up", "down", PlayerChangeSelectedNumber )
	unbindKey( "mouse_wheel_down", "down", PlayerChangeSelectedNumber )

	destroyElement( ui_elements.black_bg )
end
addEvent( "StopPlayerDemining" )
addEventHandler( "StopPlayerDemining", root, StopPlayerDemining_handler )


function PlayerChangeSelectedNumber( _, _, change )
	if not selected_port then return end

	selected_number[ selected_port ] = ( selected_number[ selected_port ] + change ) % 10

	ui_elements[ "number_".. selected_port ]:ibData( "text", selected_number[ selected_port ] )

	if selected_number[ selected_port ] == secret_number[ selected_port ] or math.random( 0, 4 ) == 0 then
		playSound( "sounds/number_true.wav" ):setVolume( 0.1 )
	else
		playSound( "sounds/number_false.wav" ):setVolume( 0.1 )
	end
end

addEventHandler( "onClientClick", root, function( button, state )
	if not selected_port or button ~= "left" or state ~= "up" then return end

	ui_elements[ "number_line_".. selected_port ]:ibData( "color", 0x506788ff )
	selected_port = false
	playSound( "sounds/port_cleanup.wav" ):setVolume( 0.1 )
end, true )