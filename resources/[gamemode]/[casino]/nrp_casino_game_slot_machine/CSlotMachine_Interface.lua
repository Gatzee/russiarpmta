
cfX, cfY = 1, 1

if _SCREEN_Y < 768 then
	cfX, cfY = _SCREEN_X / 1920, _SCREEN_Y / 1080
end

function ShowInterface_Handler( state, game_id )
	if state then
		ShowInterface_Handler( false )

		local conf = { game_string_id = CASINO_GAME_STRING_IDS[ game_id ], game_id = game_id }
		
		UI_elements.black_bg = ibCreateBackground( 0x801B1E25, OnTryLeftGame, true, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 400 )
		UI_elements.background_image = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/games/" .. conf.game_string_id .. "/machine/bg.png", UI_elements.black_bg ):center()
		UI_elements.window = ibCreateImage( 0, 0, 0, 0, "img/games/" .. conf.game_string_id .. "/machine/window.png", UI_elements.black_bg )
		:ibSetRealSize()
		
		UI_elements.window
		:ibBatchData( { sx = UI_elements.window:ibData("sx") * cfX, sy = UI_elements.window:ibData("sy") * cfY } )
		:center()
		
		UI_elements.music_state = true
		SLOT_MACHINE_INTERFACE[ game_id ]( conf )
		
		UI_elements.rows_of_panels = {  }
		CreateNewPanels( conf, { { id = 1 }, { id = 1 }, { id = 1 }, { id = 1 }, { id = 1 } } )

		StartCasinoBackgroundSound( game_id )		
	elseif isElement( UI_elements.black_bg ) then
		StopSpinSound()
		StopCasinoBackgroundSound()
		
		destroyElement( UI_elements.black_bg )

		UI_elements = { }
	end
	
	showCursor( state )
end

function UpdateBetInfo( index )
	local bet = format_price( BETS[ UI_elements.casino_id ][ index ] )
	UI_elements.bet:ibData( "text", bet )
	UI_elements.bet_soft:ibData( "px", dxGetTextWidth( bet, 1, ibFonts[ "bold_" .. math.floor(21 * cfX) ] ) + 10 * cfX )
end

function StartSpinSound()
	UI_elements.spinning_sound = playSound( "sfx/slot_machine_spin.mp3", true )
	setSoundVolume( UI_elements.spinning_sound, 0.9 )
end


function StopSpinSound()
	if UI_elements.spinning_sound and isElement( UI_elements.spinning_sound ) then 
		stopSound( UI_elements.spinning_sound )
		UI_elements.spinning_sound = nil
	end
end

function StartSlotSound()
	UI_elements.slot_sound = playSound( "sfx/slot_machine_slot_sound.mp3" )
	setSoundVolume( UI_elements.slot_sound, 0.7 )
end

function StartCasinoBackgroundSound( game_id )
	local background_sound_path = ":nrp_casino_game_dice/sfx/bg1.ogg"
	
	local conf = { game_string_id = CASINO_GAME_STRING_IDS[ game_id ] }
	local game_sound_path = "sfx/slot_machine_bg_" .. conf.game_string_id .. ".mp3"
	if fileExists( game_sound_path ) then
		background_sound_path = game_sound_path
	end

	UI_elements.sound = playSound( background_sound_path, true )
	setSoundVolume( UI_elements.sound, 0.5 )
end

function ChangeBackgroundMusicState( state, game_id )
	if state then
		StartCasinoBackgroundSound( game_id )
	else
		StopCasinoBackgroundSound()
	end
end

function StopCasinoBackgroundSound()
	if UI_elements.sound and isElement( UI_elements.sound ) then
		stopSound( UI_elements.sound )
		UI_elements.sound = nil
	end
end

function OffAutoPlayUI()
	if isElement( UI_elements.btn_autoplay_dummy ) then
		destroyElement( UI_elements.btn_autoplay_dummy )
	end
end

function OnTryLeftGame()
	if UI_elements.confirmation then return end

	UI_elements.confirmation = ibConfirm( {
		title = "Выход",
		text = "Вы действительно хотите покинуть игровой автомат?" ,

		fn = function( self )
			if isElement( UI_elements.black_bg_result ) then
				UI_elements.black_bg_result:destroy( )
			end

			ibClick()
			triggerServerEvent( "onServerSlotMachineLeaveRequest", resourceRoot, localPlayer, "exit" )
			ShowInterface_Handler( false )

			self:destroy()
		end,

		fn_cancel = function( self )
			ibClick()
			UI_elements.black_bg:ibData( "can_destroy", true )
			UI_elements.confirmation = nil
			self:destroy()
		end
	} )
end

function ShowSuccess( _, _, state, money )
	if state then
		ShowSuccess( )
		
    	UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, function( ) unbindKey( "space", "down", ShowSuccess ) end, true )
    	ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/result_info/bg_green.png", UI_elements.black_bg_result )
		
		UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfY, _SCREEN_X, 26 * cfY, "img/result_info/green_text_effect.png", UI_elements.black_bg_result )
    	ibCreateLabel( 0, 0, _SCREEN_X, 26 * cfY, "ВЫ ПОБЕДИЛИ", UI_elements.text_effect_result, 0xFF54FF68, _, _, "center", "center", ibFonts[ "bold_36"  ] )
		
    	UI_elements.bg_reward_text = ibCreateImage( _SCREEN_X_HALF - 469 * cfX, _SCREEN_Y - 500 * cfY, 939 * cfX, 416 * cfY, "img/result_info/reward_text_effect.png", UI_elements.black_bg_result )
    	ibCreateLabel( 0, 0, 939 * cfX, 416 * cfY, "ПОЗДРАВЛЯЕМ! ВАШ ВЫИГРЫШ:", UI_elements.bg_reward_text, 0xFFFFD339, _, _, "center", "center", ibFonts[ "bold_21" ] )

    	UI_elements.box_reward = ibCreateImage( _SCREEN_X_HALF - 60 * cfX, _SCREEN_Y - 235 * cfY, 120 * cfX, 120 * cfY, "img/result_info/block_reward.png", UI_elements.black_bg_result )
    	ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, "img/result_info/big_soft.png", UI_elements.box_reward )
    	ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( tonumber( money ) or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_20" ] )
		
    	ibCreateButton( _SCREEN_X_HALF - 50 * cfX, _SCREEN_Y - 95 * cfY, 100 * cfX, 54 * cfY, UI_elements.black_bg_result, "img/result_info/btn_ok.png", "img/result_info/btn_ok_hovered.png", "img/result_info/btn_ok_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			ibClick( )

			triggerServerEvent( "onServerCasinoTryTakeReward", resourceRoot )
			ShowSuccess()
		end )
		playSound( "sfx/slot_machine_win_sound.mp3" )

		bindKey( "space", "down", ShowSuccess, false, money )
	elseif isElement( UI_elements.black_bg_result ) then
		if money then
			triggerServerEvent( "onServerCasinoTryTakeReward", resourceRoot )
		end
		destroyElement( UI_elements.black_bg_result )
	end
end

function ShowRulesWindow( state )
	if state then
		ShowCombinationWindow( false )
		UI_elements.rules_window = ibCreateImage( 0, 0, 1024 * cfX, 769 * cfY, "img/bg_rules.png", UI_elements.black_bg ):ibData( "alpha", 0 ):ibAlphaTo( 255 ):center( )
		ibCreateButton( UI_elements.rules_window:ibData( "sx" ) - 60 * cfX, 30 * cfY, 30 * cfX, 30 * cfY, UI_elements.rules_window, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "up" then return end
			
			ibClick( )
			destroyElement( UI_elements.rules_window )
		end )
	elseif isElement( UI_elements.rules_window ) then 
		destroyElement( UI_elements.rules_window )
	end
end

function ShowCombinationWindow( state, conf )
	if state then
		ShowCombinationWindow( false )
		UI_elements.rules_window = ibCreateImage( 0, 0, 1024 * cfX, 769 * cfY, "img/games/" .. conf.game_string_id .. "/machine/bg_combinations.png", UI_elements.black_bg ):ibData( "alpha", 0 ):ibAlphaTo( 255 ):center( )
		ibCreateButton( UI_elements.rules_window:ibData( "sx" ) - 60 * cfX, 30 * cfY, 30 * cfX, 30 * cfY, UI_elements.rules_window, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "up" then return end
			
			ibClick( )
			destroyElement( UI_elements.rules_window )
		end )

	elseif isElement( UI_elements.combination_window ) then 
		destroyElement( UI_elements.combination_window )
	end
end