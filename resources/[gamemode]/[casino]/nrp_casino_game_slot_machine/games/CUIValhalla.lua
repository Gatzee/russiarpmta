
SLOT_MACHINE_INTERFACE[ CASINO_GAME_SLOT_MACHINE_VALHALLA ] = function( conf )

	UI_elements.window:ibData( "py", UI_elements.window:ibData( "py" ) - 20 )

	UI_elements.scoll_pane_background = ibCreateArea( 70 * cfX, 58 * cfY, 964, 473, UI_elements.window )

    local window_before_x = UI_elements.window:ibGetBeforeX( )
	local window_before_y = UI_elements.window:ibGetBeforeY( )
	
	local window_after_x = UI_elements.window:ibGetAfterX( )
	local window_after_y = UI_elements.window:ibGetAfterY( )
	
	local header_width = window_after_x - window_before_x
    
    ibCreateImage( -16 * cfX, -14 * cfY, 1151 * cfX, 605 * cfY, "img/games/" .. conf.game_string_id .. "/machine/window_dcore.png", UI_elements.window ):ibData( "priority", 2 )
    ibCreateImage( 70 * cfX, 42 * cfY, 964 * cfX, 480 * cfY, "img/games/" .. conf.game_string_id .. "/machine/gradient.png", UI_elements.window ):ibData( "priority", 1 )
	ibCreateImage( 0, 0, 999 * cfX, 216 * cfY, "img/games/" .. conf.game_string_id .. "/machine/selector.png", UI_elements.window ):center(0, 16 * cfY):ibData( "priority", 1 )
    
    UI_elements.header = ibCreateArea( window_before_x, window_before_y - 59 * cfX, header_width, window_before_y, UI_elements.black_bg )	
    UI_elements.balance_info = ibCreateLabel( 40 * cfX, 0, 0, 0, "баланс", UI_elements.header, 0xFF9F9B9C, _, _, _, _, ibFonts[ "regular_" .. math.floor(12 * cfX) ] )
	UI_elements.balance = ibCreateLabel( -1 * cfX, 15 * cfY, 0, 0, format_price( localPlayer:GetMoney( ) ), UI_elements.balance_info, _, _, _, _, _, ibFonts[ "bold_" .. math.floor(21 * cfX) ] )
    UI_elements.balance_soft = ibCreateImage( UI_elements.balance:ibGetAfterX( 11 * cfX ), 2 * cfY, 28 * cfX, 23 * cfY, "img/soft.png", UI_elements.balance )
    
	UI_elements.money_info_line = ibCreateImage( UI_elements.balance_soft:ibGetAfterX( 60 * cfX ), 7 * cfY, 1 * cfX, 34 * cfY, _, UI_elements.header, 0x509F9B9C )
	
    UI_elements.money_info_size = ibCreateLabel( 20 * cfX, -10 * cfY, 0, 0, "размер ставки", UI_elements.money_info_line, 0xFF9F9B9C, _, _, _, _, ibFonts[ "regular_" .. math.floor(12 * cfX) ] )
	UI_elements.bet = ibCreateLabel( 0, 18 * cfY, 0, 0, format_price( BETS[ UI_elements.casino_id ][ 1 ] ), UI_elements.money_info_size, _, _, _, _, _, ibFonts[ "bold_" .. math.floor(21 * cfX) ] )
	UI_elements.bet_soft = ibCreateImage( UI_elements.bet:ibGetAfterX( 11 * cfX ), 2 * cfY, 28 * cfX, 23 * cfY, "img/soft.png", UI_elements.bet )
	
	UI_elements.balance
    :ibTimer( function( self )
		self:ibData( "text", format_price( localPlayer:GetMoney() ) )
		
		UI_elements.balance_soft:ibData( "px", self:ibGetAfterX( 11 * cfX ) )
        UI_elements.money_info_line:ibData( "px", UI_elements.balance_soft:ibGetAfterX( 60 * cfX ) )
    end, 750, 0 )

	UI_elements.btn_close = ibCreateButton( header_width - 134 * cfX, 3 * cfY, 93 * cfX, 33 * cfY, UI_elements.header, "img/btn_exit.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		ibClick( )

		OnTryLeftGame()
    end )
    
	UI_elements.btn_rules = ibCreateButton( UI_elements.btn_close:ibGetBeforeX() - 122 * cfX, UI_elements.btn_close:ibGetBeforeY( ), 107 * cfX, 33 * cfY, UI_elements.header, "img/btn_rules.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		ibClick( )
		ShowRulesWindow( true )
    end )

	UI_elements.btn_combination = ibCreateButton( UI_elements.btn_rules:ibGetBeforeX() - 160 * cfX, UI_elements.btn_close:ibGetBeforeY( ), 142 * cfX, 33 * cfY, UI_elements.header, "img/btn_combination.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		ibClick( )

		ShowCombinationWindow( true, conf )
	end )
	
	UI_elements.btn_music = ibCreateImage( UI_elements.btn_combination:ibGetBeforeX() - 147 * cfX, UI_elements.btn_close:ibGetBeforeY( ), 134 * cfX, 33 * cfY, "img/btn_music_on.png", UI_elements.header, 0xFFCCCCCC )
	:ibOnHover( function( )
		UI_elements.btn_music:ibData( "color", 0xFFFFFFFF )
	end )
	:ibOnLeave( function( )
		UI_elements.btn_music:ibData( "color", 0xFFCCCCCC )
	end )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		ibClick( )

		UI_elements.music_state = not UI_elements.music_state
		ChangeBackgroundMusicState( UI_elements.music_state, conf.game_id )
		
		UI_elements.btn_music:ibData( "texture", UI_elements.music_state and "img/btn_music_on.png" or "img/btn_music_off.png" )
	end )
	
	ibCreateImage( 0, 0, 1 * cfX, 33 * cfY, _, UI_elements.btn_close, 0x509F9B9C )
	ibCreateImage( 0, 0, 1 * cfX, 33 * cfY, _, UI_elements.btn_rules, 0x509F9B9C )
	ibCreateImage( 0, 0, 1 * cfX, 33 * cfY, _, UI_elements.btn_combination, 0x509F9B9C )

    UI_elements.footer = ibCreateArea( window_before_x + 30 * cfX, window_after_y, header_width, 160 * cfY, UI_elements.black_bg )
	UI_elements.btn_maxbet = ibCreateButton( 0, 41 * cfY, 307 * cfX, 58 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/maxbet_i.png", "img/games/" .. conf.game_string_id .. "/buttons/maxbet_h.png", "img/games/" .. conf.game_string_id .. "/buttons/maxbet_p.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_max_bet.mp3" )

		UpdateBetInfo( #BETS[ UI_elements.casino_id ] )
    end )
    
	UI_elements.btn_play = ibCreateButton( 331 * cfX, 36 * cfY, 182 * cfX, 70 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/play_i.png", "img/games/" .. conf.game_string_id .. "/buttons/play_h.png", "img/games/" .. conf.game_string_id .. "/buttons/play_p.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_click.mp3" )

		PreInvokePlay()
    end )
    
	UI_elements.btn_autoplay = ibCreateButton( 531 * cfX, 36 * cfY, 182 * cfX, 70 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/autoplay_i.png", "img/games/" .. conf.game_string_id .. "/buttons/autoplay_h.png", "img/games/" .. conf.game_string_id .. "/buttons/autoplay_p.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_check.mp3" )

		UI_elements.game_statement.autoplay = not UI_elements.game_statement.autoplay
		OffAutoPlayUI()

		if UI_elements.game_statement.autoplay then
			UI_elements.btn_autoplay_dummy = ibCreateImage( 0, 0, 182 * cfX, 70 * cfY, "img/games/" .. conf.game_string_id .. "/buttons/autoplay_h.png", UI_elements.btn_autoplay )
			:ibData( "disabled", true )
			UI_elements.btn_autoplay_effect = ibCreateImage( -24 * cfX, -37 * cfY, 230 * cfX, 135 * cfY, "img/games/" .. conf.game_string_id .. "/buttons/autoplay_on.png", UI_elements.btn_autoplay_dummy )
			:ibData( "disabled", true )
			
			local function AutoplayEffect()
				for i = 1, 2 do 
					UI_elements.btn_autoplay_effect:ibTimer( function( self )
						self:ibAlphaTo(	i % 2 == 0 and 255 or 50, 500 )
					end, (i - 1) * 500, 1 )
				end
			end
			
			AutoplayEffect()
			UI_elements.btn_autoplay_effect:ibTimer( AutoplayEffect, 1000, 0 )
		end

		PreInvokePlay()
    end )

	UI_elements.btn_improvebet = ibCreateButton( 737 * cfX, 41 * cfY, 307 * cfX, 58 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/improvebet_i.png", "img/games/" .. conf.game_string_id .. "/buttons/improvebet_h.png", "img/games/" .. conf.game_string_id .. "/buttons/improvebet_p.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_max_bet.mp3" )

		local curBetIndex = GetCurrentBetIndex()
		UpdateBetInfo( next( BETS[ UI_elements.casino_id ], curBetIndex ) or 1 )
    end )
end