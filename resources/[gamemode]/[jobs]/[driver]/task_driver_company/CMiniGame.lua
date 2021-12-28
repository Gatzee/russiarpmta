loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "ib" )

ibUseRealFonts( true )

local a_LCDNova46 = dxCreateFont( "fonts/a_LCDNova.ttf", 46 / 1.25 + 0.5 )

toggleMiniGame = function ( state, data )
	if state then
		toggleMiniGame( false )

		local self = data

		self.moneyTypes = { 
			{ money = 5, 	amount = 0}, 
			{ money = 10, 	amount = 0}, 
			{ money = 50, 	amount = 0}, 
			{ money = 100, 	amount = 0}, 
			{ money = 500, 	amount = 0}, 
		}

		self.current_passenger = 1
		self.cost = 55
		self.time = 60
		self.surrender = 0
		self.fails = 0

		self.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255 )
		self.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", self.black_bg ):center( )

		ibCreateButton( 971, 28, 24, 24, self.bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
	    :ibOnClick( function( key, state )
	        if key ~= "left" or state ~= "up" then return end

	        ibClick( )
	        toggleMiniGame( false )
	        self.callback_func( "fail" )
	    end, false )

	    ibCreateImage( 721, 77, 303, 691, "img/examples.png", self.bg )
	    self.bg_wnd = ibCreateImage( 0, 77, 723, 688, "img/bg_wnd.png", self.bg )

	    self.bg_cashbox = ibCreateImage( 0, 293, 723, 475, "img/cashbox.png", self.bg )

	    self.timer_bg = ibCreateImage( 0, 100, 723, 65, "img/timer.png", self.bg )

	    self.timer_label_bg = ibCreateLabel( 0, 0, 0, 0, "00", self.timer_bg, tocolor(255, 255, 255, 55), nil, nil, "center", "center", a_LCDNova46):center( 0, 5 )
	    self.timer_label = ibCreateLabel( 0, 0, 0, 0, self.time, self.timer_bg, tocolor(229, 217, 17, 255), nil, nil, "center", "center", a_LCDNova46):center( 0, 5 )
	    self.label_passengers = ibCreateLabel(225, 0, 0, 0, "1/5", self.timer_bg, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_30 ):center_y( 12 )
	    self.label_round = ibCreateLabel(480, 0, 0, 0, "1", self.timer_bg, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_30 ):center_y( 12 )

	    self.pay_area = ibCreateArea(0, 400, 0, 63, self.bg_cashbox)

	    self.pre_surrender_label = ibCreateLabel(0, 0, 0, 0, "Сдача:", self.pay_area, nil, nil, nil, "center", "center", ibFonts.regular_18 ):center_y( )
	    self.surrender_label = ibCreateLabel( self.pre_surrender_label:ibGetAfterX( 35 ), 0, 0, 0, "9999", self.pay_area, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_24 ):center_y( )
	    self.surrender_icon = ibCreateImage( self.surrender_label:ibGetAfterX( 10 ), 0, 28, 28, ":nrp_shared/img/money_icon.png", self.pay_area ):center_y( )
	    self.pay_button = ibCreateButton( self.surrender_icon:ibGetAfterX( 12 ), 0, 158, 63, self.pay_area, "img/pay_i.png", "img/pay_h.png", "img/pay_h.png" )
	    :ibOnClick( function( key, state )
	        if key ~= "left" or state ~= "up" then return end

	        ibClick( )
	        
	        if self.passengers[ self.current_passenger ].money - self.cost ~= self.surrender then
	        	self.fails = self.fails + 1
	        	self.error_text:ibAlphaTo( 255, 100 )

	        	if isTimer( self.error_text ) then killTimer( self.error_text ) end

	        	self.error_text:ibTimer( function ( )
	        		self.error_text:ibAlphaTo( 0, 500 )
	        	end, 3000, 1 )
	        end
	        if self.current_passenger >= #self.passengers then

	        	if self.fails >= #self.passengers * 0.5 then
	        		self.callback_func( "fail" )
	        	else
	        		self.callback_func( "success" )
	        	end
	        	toggleMiniGame( false )
	        else
	        	self.nextPassanger( )
	        end

	    end, false )
	    self.pay_area:ibData( "sx", self.pay_button:ibGetAfterX( ) ):center_x( 15 )
	    self.error_text = ibCreateImage( self.pay_button:ibGetAfterX( 8 ), 0, 120, 28, "img/error_text.png", self.pay_area):center_y( ):ibData( "alpha", 0 )

	    self.money_area = ibCreateArea(0, 0, 0, 169, self.bg_cashbox)

		self.current_money_label = ibCreateLabel(0, 110, 0, 0, "0", self.bg_cashbox, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_44 ):center_x( )

		self.money_blocks = { }

		for i, data in pairs(self.moneyTypes) do
			self.money_blocks[ i ] = { }

			self.money_blocks[ i ].bg = ibCreateArea( self.money_area:ibGetAfterX( 10 ), 0, 100, 169, self.money_area )
			ibCreateImage( 0, 0, 100, 169, "img/bets.png", self.money_blocks[ i ].bg )
			self.money_area:ibData( "sx", self.money_blocks[ i ].bg:ibGetAfterX( ) )

			ibCreateButton( 0, 1, 50, 30, self.money_blocks[ i ].bg, "img/minus_i.png", "img/minus_h.png", "img/minus_h.png" )
			:ibOnClick( function( key, state )
		        if key ~= "left" or state ~= "up" then return end

		        ibClick( )

		        data.amount = math.max( data.amount - 1, 0 )
		        self.updateBets( )
		    end, false )

			ibCreateButton( 50, 1, 50, 30, self.money_blocks[ i ].bg, "img/plus_i.png", "img/plus_h.png", "img/plus_h.png" )
			:ibOnClick( function( key, state )
		        if key ~= "left" or state ~= "up" then return end

		        ibClick( )

		        data.amount = math.min( data.amount + 1, 5 )
		        self.updateBets( )

		    end, false )

			self.money_blocks[ i ].area = ibCreateArea(0, 143, 0, 49, self.money_blocks[ i ].bg )

			self.money_blocks[ i ].moneyLabel = ibCreateLabel( self.money_blocks[ i ].area:ibGetAfterX( ), 0, 0, 0, data.money, self.money_blocks[ i ].area, nil, nil, nil, "left", "center", ibFonts.oxaniumbold_26 )
			self.money_blocks[ i ].moneyIcon = ibCreateImage( self.money_blocks[ i ].moneyLabel:ibGetAfterX( 8 ), -15, 28, 28, ":nrp_shared/img/money_icon.png", self.money_blocks[ i ].area )

			self.money_blocks[ i ].area:ibData("sx", self.money_blocks[ i ].moneyIcon:ibGetAfterX( ) ):center_x( )

			self.money_blocks[ i ].bets = { }
			for k = 1, 5 do
				self.money_blocks[ i ].bets[ k ] = ibCreateImage(1, 102-17.5*(k-1), 98, 17, "img/bet_passive.png", self.money_blocks[ i ].bg)
				:ibOnHover( function( )
                    self.money_blocks[ i ].bets[ k ]:ibData( "texture", "img/bet_hover.png")
                end )
                :ibOnLeave( function( )
                	self.updateBets( )
                end )
                :ibOnClick(function ( key, state )
                	if key ~= "left" or state ~= "up" then return end

                	ibClick( )

                	if data.amount == k then
                		data.amount = math.max(data.amount - 1, 0)
                	else
                		data.amount = k
                	end

                	self.updateBets( )
                end )
			end
		end

		self.money_area:center( 0, 50 )


		self.nextPassanger = function ( )
			self.current_passenger = self.current_passenger + 1

	        self.updatePassenger( )
	        self.updateBets( )
		end

		self.updateBets = function ( )
			self.surrender = 0
			for i, data in pairs(self.moneyTypes) do
				for k = 1, 5 do
					if data.amount >= k then
						self.surrender = self.surrender + data.money
		            	self.money_blocks[ i ].bets[ k ]:ibData( "texture", "img/bet_active.png")
		            else
		            	self.money_blocks[ i ].bets[ k ]:ibData( "texture", "img/bet_passive.png")
		            end
				end
			end
			self.surrender_label:ibData("text", self.surrender)
		end

		self.updatePassenger = function ( )
			self.surrender = 0
			for i, data in pairs(self.moneyTypes) do
				data.amount = 0
			end
	
			self.current_money_label:ibData( "text", self.passengers[ self.current_passenger ].money )
			if isElement( self.skin_img ) then
				destroyElement( self.skin_img )
			end
			self.skin_img = ibCreateContentImage( 0, 40, 300, 220, "skin", self.passengers[ self.current_passenger ].skin or 1, self.bg_wnd ):center( 0, -140 )
		
			self.label_round:ibData( "text", self.current_passenger )
			self.label_passengers:ibData( "text", self.current_passenger.."/"..#self.passengers )
		end

		self.updateTimer = function ( )
			if self.time == 0 then
				self.callback_func( "fail" )
				toggleMiniGame( false )
			else
				self.time = self.time - 1
				self.timer_label:ibData("text", string.format( "%02d", self.time) )
			end
		end
		self.failTimer = setTimer(self.updateTimer, 1000, 0)

		self.updatePassenger( )
		self.updateBets( )

		self.destroy = function( )
            destroyElement( self.black_bg )
            showCursor( false )

            if isTimer(self.failTimer) then
            	killTimer( self.failTimer )
            end
            
            setmetatable( self, nil )
        end

		showCursor( true )

		CEs.ui_minigame = self
	elseif CEs.ui_minigame then
        CEs.ui_minigame:destroy( )
        CEs.ui_minigame = nil
	end
end

---addCommandHandler("mg", function ()
---
---	local moneys = {60, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 150, 250, 350, 450, 550, 650, 750, 850, 950}
---	local skins = {7, 9, 11, 14, 263, 269, 270, 272, 291, 293}
---	local array = { }
---	for i=1, math.random(3, 5) do
---		table.insert(array, {skin = skins[math.random(1, #skins)], money = moneys[math.random(1, #moneys)]})
---	end
---	toggleMiniGame( true, {
---		passengers = array,
---		success_callback = function()
---			print( "Заебок" )
---	    end,
---	    fail_callback = function()
---			print( "Проебал лох" )
---	    end,
---	} )
---end)