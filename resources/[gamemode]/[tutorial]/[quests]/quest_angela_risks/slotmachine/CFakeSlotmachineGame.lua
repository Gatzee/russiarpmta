
enum "eSlotMachineItems" {
	"SLOT_MACHNIE_ITEM_1",
	"SLOT_MACHNIE_ITEM_2",
	"SLOT_MACHNIE_ITEM_3",
	"SLOT_MACHNIE_ITEM_4",
	"SLOT_MACHNIE_ITEM_5",
	"SLOT_MACHNIE_ITEM_6",
	"SLOT_MACHNIE_ITEM_7",
	"SLOT_MACHNIE_ITEM_8",
}

function CreateFakeSlotmachineGame()
    local self = {
        count_game = 0,
        elements = {},
        casino_id = CASINO_THREE_AXE,
        bets = {
            [ CASINO_THREE_AXE ] =
            {
                100,
                500,
                1000,
                2000,
                4000,
                5000,
            },
        },
        registered_items = {
            { id = SLOT_MACHNIE_ITEM_1 },
	        { id = SLOT_MACHNIE_ITEM_2 },
	        { id = SLOT_MACHNIE_ITEM_3 },
	        { id = SLOT_MACHNIE_ITEM_4 },
	        { id = SLOT_MACHNIE_ITEM_5 },
	        { id = SLOT_MACHNIE_ITEM_6 },
	        { id = SLOT_MACHNIE_ITEM_7 },
	        { id = SLOT_MACHNIE_ITEM_8 },
        },
        combinations = 
        {
        	[ SLOT_MACHNIE_ITEM_1 ] = { [ 2 ] = 5, [ 3 ] = 25, [ 4 ] = 200, [ 5 ] = 2000 },
        	[ SLOT_MACHNIE_ITEM_2 ] = { [ 2 ] = 3, [ 3 ] = 20, [ 4 ] = 100, [ 5 ] = 1000 },
        	[ SLOT_MACHNIE_ITEM_3 ] = { [ 2 ] = 2, [ 3 ] = 15, [ 4 ] = 50,  [ 5 ] = 500  },
        	[ SLOT_MACHNIE_ITEM_4 ] = { [ 2 ] = 2, [ 3 ] = 10, [ 4 ] = 25,  [ 5 ] = 250  },
        	[ SLOT_MACHNIE_ITEM_5 ] = { [ 2 ] = 2, [ 3 ] = 10, [ 4 ] = 20,  [ 5 ] = 150  },
        	[ SLOT_MACHNIE_ITEM_6 ] = { 		   [ 3 ] = 5,  [ 4 ] = 15,  [ 5 ] = 100  },
        	[ SLOT_MACHNIE_ITEM_7 ] = { 		   [ 3 ] = 5,  [ 4 ] = 10,  [ 5 ] = 75   },
        	[ SLOT_MACHNIE_ITEM_8 ] = { 		   [ 3 ] = 5,  [ 4 ] = 10,  [ 5 ] = 50   },
        },
    }

    local cfX, cfY = 1, 1
    if _SCREEN_Y < 768 then
    	cfX, cfY = _SCREEN_X / 1920, _SCREEN_Y / 1080
    end

    self.game_statement = { running = false, bet = self.bets[ self.casino_id ][ 1 ], autoplay = false }

    self.elements.black_bg = ibCreateBackground( 0x801B1E25 ):ibData( "alpha", 0 ):ibAlphaTo( 255, 400 )
	self.elements.background_image = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, ":nrp_casino_game_slot_machine/img/games/valhalla/machine/bg.png", self.elements.black_bg ):center()
	
    self.elements.window = ibCreateImage( 0, 0, 0, 0, ":nrp_casino_game_slot_machine/img/games/valhalla/machine/window.png", self.elements.black_bg ):ibSetRealSize()
    self.elements.window:ibBatchData( { sx = self.elements.window:ibData("sx") * cfX, sy = self.elements.window:ibData("sy") * cfY } ):center()

    self.music_state = true

	self.elements.scoll_pane_background = ibCreateArea( 70 * cfX, 58 * cfY, 964, 473, self.elements.window )

    local window_before_x = self.elements.window:ibGetBeforeX( )
	local window_before_y = self.elements.window:ibGetBeforeY( )
	
	local window_after_x = self.elements.window:ibGetAfterX( )
	local window_after_y = self.elements.window:ibGetAfterY( )
	
	local header_width = window_after_x - window_before_x
    
    ibCreateImage( -16 * cfX, -14 * cfY, 1151 * cfX, 605 * cfY, ":nrp_casino_game_slot_machine/img/games/valhalla/machine/window_dcore.png", self.elements.window ):ibData( "priority", 2 )
    ibCreateImage( 70 * cfX, 42 * cfY, 964 * cfX, 480 * cfY, ":nrp_casino_game_slot_machine/img/games/valhalla/machine/gradient.png", self.elements.window ):ibData( "priority", 1 )
	ibCreateImage( 0, 0, 999 * cfX, 216 * cfY, ":nrp_casino_game_slot_machine/img/games/valhalla/machine/selector.png", self.elements.window ):center(0, 16 * cfY):ibData( "priority", 1 )
    
    self.elements.header = ibCreateArea( window_before_x, window_before_y - 59 * cfX, header_width, window_before_y, self.elements.black_bg )	
    self.elements.balance_info = ibCreateLabel( 40 * cfX, 0, 0, 0, "баланс", self.elements.header, 0xFF9F9B9C, _, _, _, _, ibFonts[ "regular_" .. math.floor(12 * cfX) ] )
	self.elements.balance = ibCreateLabel( -1 * cfX, 15 * cfY, 0, 0, format_price( localPlayer:GetMoney( ) ), self.elements.balance_info, _, _, _, _, _, ibFonts[ "bold_" .. math.floor(21 * cfX) ] )
    self.elements.balance_soft = ibCreateImage( self.elements.balance:ibGetAfterX( 11 * cfX ), 2 * cfY, 28 * cfX, 23 * cfY, ":nrp_casino_game_slot_machine/img/soft.png", self.elements.balance )
    
	self.elements.money_info_line = ibCreateImage( self.elements.balance_soft:ibGetAfterX( 60 * cfX ), 7 * cfY, 1 * cfX, 34 * cfY, _, self.elements.header, 0x509F9B9C )
	
    self.elements.money_info_size = ibCreateLabel( 20 * cfX, -10 * cfY, 0, 0, "размер ставки", self.elements.money_info_line, 0xFF9F9B9C, _, _, _, _, ibFonts[ "regular_" .. math.floor(12 * cfX) ] )
	self.elements.bet = ibCreateLabel( 0, 18 * cfY, 0, 0, format_price( self.bets[ self.casino_id ][ 1 ] ), self.elements.money_info_size, _, _, _, _, _, ibFonts[ "bold_" .. math.floor(21 * cfX) ] )
	self.elements.bet_soft = ibCreateImage( self.elements.bet:ibGetAfterX( 11 * cfX ), 2 * cfY, 28 * cfX, 23 * cfY, ":nrp_casino_game_slot_machine/img/soft.png", self.elements.bet )
	
	self.elements.balance
        :ibTimer( function( self_element )
	    	self_element:ibData( "text", format_price( localPlayer:GetMoney() ) )
        
	    	self.elements.balance_soft:ibData( "px", self_element:ibGetAfterX( 11 * cfX ) )
            self.elements.money_info_line:ibData( "px", self.elements.balance_soft:ibGetAfterX( 60 * cfX ) )
        end, 750, 0 )

	self.elements.btn_close = ibCreateButton( header_width - 134 * cfX, 3 * cfY, 93 * cfX, 33 * cfY, self.elements.header, ":nrp_casino_game_slot_machine/img/btn_exit.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	ibClick( )

	    	localPlayer:ShowInfo( "Попробуй сыграть, Анжела платит")
        end )
    
	self.elements.btn_rules = ibCreateButton( self.elements.btn_close:ibGetBeforeX() - 122 * cfX, self.elements.btn_close:ibGetBeforeY( ), 107 * cfX, 33 * cfY, self.elements.header, ":nrp_casino_game_slot_machine/img/btn_rules.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	ibClick( )
	    	self:func_show_rules_window( true )
        end )

	self.elements.btn_combination = ibCreateButton( self.elements.btn_rules:ibGetBeforeX() - 160 * cfX, self.elements.btn_close:ibGetBeforeY( ), 142 * cfX, 33 * cfY, self.elements.header, ":nrp_casino_game_slot_machine/img/btn_combination.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, _ )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	ibClick( )

	    	self:func_show_combination_window( true )
	    end )
	
	self.elements.btn_music = ibCreateImage( self.elements.btn_combination:ibGetBeforeX() - 147 * cfX, self.elements.btn_close:ibGetBeforeY( ), 134 * cfX, 33 * cfY, ":nrp_casino_game_slot_machine/img/btn_music_on.png", self.elements.header, 0xFFCCCCCC )
	    :ibOnHover( function( )
	    	self.elements.btn_music:ibData( "color", 0xFFFFFFFF )
	    end )
	    :ibOnLeave( function( )
	    	self.elements.btn_music:ibData( "color", 0xFFCCCCCC )
	    end )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	ibClick( )

	    	self.music_state = not self.music_state
	    	self:change_background_music_state( self.music_state )
        
	    	self.elements.btn_music:ibData( "texture", self.music_state and ":nrp_casino_game_slot_machine/img/btn_music_on.png" or ":nrp_casino_game_slot_machine/img/btn_music_off.png" )
	    end )
	
	ibCreateImage( 0, 0, 1 * cfX, 33 * cfY, _, self.elements.btn_close, 0x509F9B9C )
	ibCreateImage( 0, 0, 1 * cfX, 33 * cfY, _, self.elements.btn_rules, 0x509F9B9C )
	ibCreateImage( 0, 0, 1 * cfX, 33 * cfY, _, self.elements.btn_combination, 0x509F9B9C )

    self.elements.footer = ibCreateArea( window_before_x + 30 * cfX, window_after_y, header_width, 160 * cfY, self.elements.black_bg )
	self.elements.btn_maxbet = ibCreateButton( 0, 41 * cfY, 307 * cfX, 58 * cfY, self.elements.footer, ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/maxbet_i.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/maxbet_h.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/maxbet_p.png" )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	playSound( ":nrp_casino_game_slot_machine/sfx/slot_machine_max_bet.mp3" )

	    	self:func_update_bet_info( #self.bets[ self.casino_id ] )
        end )
    
	self.elements.btn_play = ibCreateButton( 331 * cfX, 36 * cfY, 182 * cfX, 70 * cfY, self.elements.footer, ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/play_i.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/play_h.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/play_p.png" )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	playSound( ":nrp_casino_game_slot_machine/sfx/slot_machine_click.mp3" )

	    	self:pre_invoke_play()
        end )
    
    self.func_off_auto_play_effect = function( self )
        if isElement( self.elements.btn_autoplay_dummy ) then
            destroyElement( self.elements.btn_autoplay_dummy )
        end
    end

    self.func_on_auto_play_effect = function( self )
        for i = 1, 2 do 
            self.elements.btn_autoplay_effect:ibTimer( function( self )
                self:ibAlphaTo(	i % 2 == 0 and 255 or 50, 500 )
            end, (i - 1) * 500, 1 )
        end
    end

	self.elements.btn_autoplay = ibCreateButton( 531 * cfX, 36 * cfY, 182 * cfX, 70 * cfY, self.elements.footer, ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/autoplay_i.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/autoplay_h.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/autoplay_p.png" )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	playSound( ":nrp_casino_game_slot_machine/sfx/slot_machine_check.mp3" )

	    	self.game_statement.autoplay = not self.game_statement.autoplay
	    	self:func_off_auto_play_effect()

	    	if self.game_statement.autoplay then
	    		self.elements.btn_autoplay_dummy = ibCreateImage( 0, 0, 182 * cfX, 70 * cfY, ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/autoplay_h.png", self.elements.btn_autoplay )
	    		    :ibData( "disabled", true )
	    		self.elements.btn_autoplay_effect = ibCreateImage( -24 * cfX, -37 * cfY, 230 * cfX, 135 * cfY, ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/autoplay_on.png", self.elements.btn_autoplay_dummy )
	    		    :ibData( "disabled", true )
            
                self:func_on_auto_play_effect()
	    		self.elements.btn_autoplay_effect:ibTimer( function()
                    self:func_on_auto_play_effect() 
                end, 1000, 0 )
	    	end

	    	self:pre_invoke_play()
        end )

	self.elements.btn_improvebet = ibCreateButton( 737 * cfX, 41 * cfY, 307 * cfX, 58 * cfY, self.elements.footer, ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/improvebet_i.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/improvebet_h.png", ":nrp_casino_game_slot_machine/img/games/valhalla/buttons/improvebet_p.png" )
	    :ibOnClick( function( key, state )
	    	if key ~= "left" or state ~= "down" then return end
	    	playSound( ":nrp_casino_game_slot_machine/sfx/slot_machine_max_bet.mp3" )

	    	local cur_bet_index = self:func_get_current_bet_index()
	    	self:func_update_bet_info( next( self.bets[ self.casino_id ], cur_bet_index ) or 1 )
        end )


    self.func_get_current_bet_index = function( self )
	    if not self.elements.bet then return end
        
	    local text = string.gsub( self.elements.bet:ibData( "text" ), "%s+", "" )
	    local bet = tonumber( text )
	    for i, v in pairs( self.bets[ self.casino_id ] ) do 
	    	if bet == v then 
                return i, v 
            end
	    end
    end

    self.func_update_bet_info = function( self, index )
        local bet_value = format_price( self.bets[ self.casino_id ][ index ] )
        self.elements.bet:ibData( "text", bet_value )
        self.elements.bet_soft:ibData( "px", dxGetTextWidth( bet_value, 1, ibFonts[ "bold_" .. math.floor(21 * cfX) ] ) + 10 * cfX )
    end

    self.func_show_combination_window = function( self, state )
        if state then
            self:func_show_combination_window( false )
            self.elements.rules_window = ibCreateImage( 0, 0, 1024 * cfX, 769 * cfY, ":nrp_casino_game_slot_machine/img/games/valhalla/machine/bg_combinations.png", self.elements.black_bg ):ibData( "alpha", 0 ):ibAlphaTo( 255 ):center( )
            ibCreateButton( self.elements.rules_window:ibData( "sx" ) - 60 * cfX, 30 * cfY, 30 * cfX, 30 * cfY, self.elements.rules_window, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end

                    ibClick( )
                    destroyElement( self.elements.rules_window )
                end )
    
        elseif isElement( self.elements.combination_window ) then 
            destroyElement( self.elements.combination_window )
        end
    end

    self.func_show_rules_window = function( self, state )
        if state then
            self:func_show_combination_window( false )
            self.elements.rules_window = ibCreateImage( 0, 0, 1024 * cfX, 769 * cfY, ":nrp_casino_game_slot_machine/img/bg_rules.png", self.elements.black_bg ):ibData( "alpha", 0 ):ibAlphaTo( 255 ):center( )
            ibCreateButton( self.elements.rules_window:ibData( "sx" ) - 60 * cfX, 30 * cfY, 30 * cfX, 30 * cfY, self.elements.rules_window, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    
                    ibClick( )
                    destroyElement( self.elements.rules_window )
                end )
        elseif isElement( self.elements.rules_window ) then 
            destroyElement( self.elements.rules_window )
        end
    end

    self.func_start_casino_background_sound = function( self )
        if isElement( self.elements.sound ) then return end

        local background_sound_path = ":nrp_casino_game_slot_machine/sfx/slot_machine_bg_valhalla.mp3"
        self.elements.sound = playSound( background_sound_path, true )
        setSoundVolume( self.elements.sound, 0.5 )
    end
    
    self.change_background_music_state = function( self, state )
        if state then
            self:func_start_casino_background_sound()
        else
            self:stop_casino_background_sound()
        end
    end
    
    self.stop_casino_background_sound = function( self )
        if not isElement( self.elements.sound ) then return end
        stopSound( self.elements.sound )
        self.elements.sound = nil
    end

    self.func_create_new_pannels = function( self, results_row )
        for i = 1, 5 do 
            table.insert( self.elements.rows_of_panels, i, self:func_create_items_pane( i - 1, results_row[ i ] ) )
        end
    end

    self.func_remove_old_panels = function( self )
        for i = 1, 5 do 
            destroyElement( self.elements.rows_of_panels[ i ].items_pane )
            self.elements.rows_of_panels[ i ] = nil
        end
    end

    self.func_create_items_pane = function( self, column_id, generated_item )
        local row = {}
        row.items = {}
    
        row.items_pane, row.scroll_v = ibCreateScrollpane( column_id * 197 * cfX, 0, 178 * cfX, 485 * cfY,  self.elements.scoll_pane_background )
    
        row.item = self:func_create_scroll_item( generated_item.id, 0, (98 * 198) * cfY, row.items_pane )
        for i = 0, 3 do
            local item_id = math.random( 1, #self.registered_items )
            table.insert( row.items, self:func_create_scroll_item( item_id, 0, i * 198 * cfY, row.items_pane ) )
        end
        
        row.items_pane:AdaptHeightToContents( )
        row.scroll_v:ibBatchData( { position = 0.00215, sensivity = 0, visible = false } )
        
        return row
    end

    self.func_create_scroll_item = function( self, item_id, pos_x, pos_y, bg )
        local item = ibCreateImage( pos_x, pos_y, 0, 0, ":nrp_casino_game_slot_machine/img/games/valhalla/machine/variations/" .. item_id .. ".png", bg ):ibSetRealSize()
        item:ibBatchData( { sx = item:ibData("sx") * cfX, sy = item:ibData("sy") * cfY } )
        return item
    end

    self.func_start_animation = function( self )
        for i = 1, 5 do
            local duration = 3000 + ( i - 1 ) * 500
            self.elements.rows_of_panels[ i ].scroll_v:ibScrollTo( 0.9975, duration, "Linear" )
            self.elements.rows_of_panels[ i ].scroll_v:ibTimer( function()
                self:func_start_slot_sound() 
            end, duration - 50, 1 )
        end
    end

    self.start_lazy_loading = function( self )
        for i = 1, 5 do 
            self.elements.rows_of_panels[ i ].itemCounter = 4
            self.elements.rows_of_panels[ i ].items_pane:ibTimer( function( self_element )
                local itemCount = self.elements.rows_of_panels[ i ].itemCounter
                for j = itemCount, itemCount + 3 do
                    local item_id = math.random( 1, #self.registered_items )
                    if item_id and j ~= 98 then
                        table.insert( self.elements.rows_of_panels[ i ].items, self:func_create_scroll_item( item_id, 0, (j * 198) * cfY, self_element ) )
                    end
                    if j == 99 then self_element:AdaptHeightToContents( ) end
                end
                self.elements.rows_of_panels[ i ].itemCounter = itemCount + 4
            end, 80, 24 )
            
            self.elements.rows_of_panels[ i ].items_pane:ibTimer( function( self_element )
                local children = self_element:getChildren( )
                destroyElement( children[ 2 ] )
            end, 81, 97 )
        end
    end

    self.func_on_scroll_finished = function( self, self_element, winning_amount, combination_coeff, winning_slots  )
        if combination_coeff then
            self.elements.dummy = ibCreateArea( 0, 0, 0, 0, self.elements.black_bg )
            self.elements.dummy:ibTimer( function()
                for k, v in pairs( winning_slots ) do
                    for j = 1, 2 do 
                        self.elements.rows_of_panels[ v ].item:ibTimer( function( self_element )
                            self_element:ibAlphaTo(	j % 2 == 0 and 255 or 100, 500 )
                        end, (j - 1) * 500, 1 )
                    end
                end
            end, 1000, 0 )
        end
    
        self.elements.window:ibTimer( function()
            self.game_statement.running = false
            self:func_stop_spin_sound()

            self.count_game = self.count_game + 1
            if self.count_game == 3 then
                triggerServerEvent( "angela_risks_step_6", localPlayer )
            
            elseif self.count_game < 3 then -- lags/huyags
                if self.game_statement.autoplay then
                    self.elements.black_bg:ibTimer( function()
                        if not self.game_statement.autoplay then 
                            localPlayer:ShowInfo( "Попробуй ещё раз...")
                            return 
                        end
                        self:pre_invoke_play()
                    end, 500, 1 )
                else
                    localPlayer:ShowInfo( "Попробуй ещё раз...")
                end
            end
        end, 1500, 1 )
    end

    self.func_start_slot_sound = function( self )
        self.slot_sound = playSound( ":nrp_casino_game_slot_machine/sfx/slot_machine_slot_sound.mp3" )
        setSoundVolume( self.slot_sound, 0.7 )
    end

    self.func_start_spin_sound = function( self )
        self.spinning_sound = playSound( ":nrp_casino_game_slot_machine/sfx/slot_machine_spin.mp3", true )
        setSoundVolume( self.spinning_sound, 0.9 )
    end
    
    self.func_stop_spin_sound = function( self )
        if self.spinning_sound and isElement( self.spinning_sound ) then 
            stopSound( self.spinning_sound )
            self.spinning_sound = nil
        end
    end

    self.func_calculate_combinations_coefficient = function( self, combinations )
        local combos = {  }
        local counter = 1
        for i, v in pairs( combinations ) do 
            if i + 1 <= #combinations and combinations[ i + 1 ].id == v.id then
                counter = counter + 1
            else 
                if counter ~= 1 then
                    table.insert( combos, { id = v.id, count = counter } )
                    counter = 1
                end
            end
        end
        
        table.sort( combos, function( a, b )
            return a.count > b.count or ( a.count == b.count and a.id < b.id )
        end )
        
        local combination = combos[ 1 ] or { id = SLOT_MACHNIE_ITEM_1, count = 0 }
        local win_combination = self.combinations[ combination.id ][ combination.count ] or false
    
        return win_combination, combination
    end

    self.func_get_winning_slots = function( self, result_items, combination_data )
        local result = {}
        for k, v in pairs( result_items ) do
            if v.id == combination_data.id then
                table.insert( result, k )
                if #result == combination_data.count then break end
            else
                result = {}
            end
        end	
        return result
    end

    self.pre_invoke_play = function( self )
        if self.game_statement.running then return end
        self.game_statement.running = true
        
        self.game_statement.bet = self:func_get_current_bet_index()
        if isElement( self.elements.dummy ) then
            destroyElement( self.elements.dummy )
        end
        
        self:invoke_play( { { id = math.random( 1, 2 ) }, { id = math.random( 3, 4 ) }, { id = 1 }, { id = math.random( 2, 4 ) }, { id = 1 } } )
    end

    self.invoke_play = function( self, result_items )
        self:func_remove_old_panels( )
	    self:func_create_new_pannels( result_items )

	    local combination_coeff, combination_data = self:func_calculate_combinations_coefficient( result_items )
	    local winning_slots = self:func_get_winning_slots( result_items, combination_data )

	    self:func_start_animation( )
	    self:start_lazy_loading()
	    self:func_start_spin_sound( )
        
	    self.elements.black_bg:ibTimer( function( self_element )
            self:func_on_scroll_finished( self_element, winning_amount, combination_coeff, winning_slots )
        end, 3700, 1 )
    end

    self.elements.rows_of_panels = {}
	self:func_create_new_pannels( { { id = 1 }, { id = 1 }, { id = 1 }, { id = 1 }, { id = 1 } } )

    self.destroy = function( self )
        self:func_stop_spin_sound()
		self:stop_casino_background_sound()
		
		destroyElement( self.elements.black_bg )
        showCursor( false )

        setmetatable( self, nil )
    end

    showCursor( true )
    self:func_start_casino_background_sound()

    CEs.slot_machine_game = self
end