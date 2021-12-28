
SLOT_MACHINE_INTERFACE[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ] = function( conf )
	UI_elements.scoll_pane_background = ibCreateArea( 30 * cfX, 27 * cfY, 964, 473, UI_elements.window )

    local window_before_x = UI_elements.window:ibGetBeforeX()
	local window_before_y = UI_elements.window:ibGetBeforeY()

	local window_after_x = UI_elements.window:ibGetAfterX()
	local window_after_y = UI_elements.window:ibGetAfterY()
	
	local header_width = window_after_x - window_before_x
	
    ibCreateImage( 0, 0, 1008 * cfX, 202 * cfY, "img/games/" .. conf.game_string_id .. "/machine/selector.png", UI_elements.window ):center( 0, 3):ibData( "priority", 1 )
	ibCreateImage( 0, 0, 966 * cfX, 485 * cfY, "img/games/" .. conf.game_string_id .. "/machine/gradient.png", UI_elements.window ):center( 1, 0 ):ibData( "priority", 1 )

    UI_elements.header = ibCreateArea( window_before_x, window_before_y - 58 * cfY, header_width, window_before_y, UI_elements.black_bg )
	ibCreateImage( 0, window_before_y - 170 * cfX, 243 * cfX, 118 * cfY, "img/games/" .. conf.game_string_id .. "/machine/logo.png", UI_elements.black_bg ):center_x( )	
	
    local player_money = format_price( localPlayer:GetMoney( ) )
    UI_elements.money_info = ibCreateLabel( 20 * cfX, 0, 0, 0, "баланс", UI_elements.header, 0xFF9F9B9C, _, _, _, _, ibFonts[ "regular_" .. math.floor(12 * cfX) ] )
	UI_elements.balance = ibCreateLabel( 0, 15 * cfY, 0, 0, player_money, UI_elements.money_info, _, _, _, _, _, ibFonts[ "bold_" .. math.floor(21 * cfX) ] )
    UI_elements.balance_soft = ibCreateImage( UI_elements.balance:ibGetAfterX( 10 * cfX ), 2 * cfY, 28 * cfX, 23 * cfY, "img/soft.png", UI_elements.balance )
    
	UI_elements.balance
    :ibTimer( function( self )
        local player_money = format_price( localPlayer:GetMoney( ) )
		self:ibData( "text", player_money )
		
		UI_elements.balance_soft:ibData( "px", self:ibGetAfterX( 10 * cfX ) )
        UI_elements.money_info_bet:ibData( "px", UI_elements.balance_soft:ibGetAfterX( 40 * cfX ) )
    end, 750, 0 )
    
    UI_elements.money_info_bet = ibCreateImage( UI_elements.balance_soft:ibGetAfterX( 40 * cfX ), 7 * cfY, 1 * cfX, 34 * cfY, _, UI_elements.header, 0xAA9F9B9C )
    UI_elements.money_info_size = ibCreateLabel( 20 * cfX, -10 * cfY, 0, 0, "размер ставки", UI_elements.money_info_bet, 0xFF9F9B9C, _, _, _, _, ibFonts[ "regular_" .. math.floor(12 * cfX) ] )
	UI_elements.bet = ibCreateLabel( 0, 18 * cfY, 0, 0, format_price( BETS[ UI_elements.casino_id ][ 1 ] ), UI_elements.money_info_size, _, _, _, _, _, ibFonts[ "bold_" .. math.floor(21 * cfX) ] )
	UI_elements.bet_soft = ibCreateImage( dxGetTextWidth( BETS[ UI_elements.casino_id ][ 1 ], 1, ibFonts[ "bold_" .. math.floor(21 * cfX) ] ) + 10 * cfX, 2 * cfY, 28 * cfX, 23 * cfY, "img/soft.png", UI_elements.bet )
    
    UI_elements.btn_close = ibCreateButton( header_width - 93 * cfX, 13 * cfY, 93 * cfX, 33 * cfY, UI_elements.header, "img/btn_exit.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		ibClick( )

		OnTryLeftGame()
    end )
    
	UI_elements.btn_rules = ibCreateButton( header_width - 211 * cfX, 13 * cfY, 107 * cfX, 33 * cfY, UI_elements.header, "img/btn_rules.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		ibClick( )

		ShowRulesWindow( true )
    end )

    UI_elements.btn_combination = ibCreateButton( header_width - 371 * cfX, 13 * cfY, 142 * cfX, 33 * cfY, UI_elements.header, "img/btn_combination.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
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

    UI_elements.footer = ibCreateImage( window_before_x, window_after_y + 10, header_width, 112 * cfY, "img/games/gold_skull/machine/bg_footer.png", UI_elements.black_bg )
	UI_elements.btn_maxbet = ibCreateButton( 30 * cfX, 18 * cfY, 311 * cfX, 77 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/maxbet_i.png", "img/games/" .. conf.game_string_id .. "/buttons/maxbet_h.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_max_bet.mp3" )

		UpdateBetInfo( #BETS[ UI_elements.casino_id ] )
    end )
    
	UI_elements.btn_play = ibCreateButton( 372 * cfX, 7 * cfY, 125 * cfX, 98 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/play_i.png", "img/games/" .. conf.game_string_id .. "/buttons/play_h.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_click.mp3" )

		PreInvokePlay()
    end )
    
	UI_elements.btn_autoplay = ibCreateButton( 529 * cfX, 7 * cfY, 125 * cfX, 98 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/autoplay_i.png", "img/games/" .. conf.game_string_id .. "/buttons/autoplay_h.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_check.mp3" )
		
		UI_elements.game_statement.autoplay = not UI_elements.game_statement.autoplay	
		UI_elements.btn_autoplay:ibData( "texture", UI_elements.game_statement.autoplay and ("img/games/" .. conf.game_string_id .. "/buttons/autoplay_c.png") or ("img/games/" .. conf.game_string_id .. "/buttons/autoplay_i.png") )

		PreInvokePlay()
    end )
    
    UI_elements.btn_improvebet = ibCreateButton( 683 * cfX, 18 * cfY, 311 * cfX, 77 * cfY, UI_elements.footer, "img/games/" .. conf.game_string_id .. "/buttons/improvebet_i.png", "img/games/" .. conf.game_string_id .. "/buttons/improvebet_h.png" )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "down" then return end
		playSound( "sfx/slot_machine_max_bet.mp3" )
		
		local curBetIndex = GetCurrentBetIndex()
		UpdateBetInfo( next( BETS[ UI_elements.casino_id ], curBetIndex ) or 1 )
    end )
end