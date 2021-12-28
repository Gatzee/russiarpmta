loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
ibUseRealFonts( true )

UI = { }

function ShowPremiumGiveawayUI( premium_days )
    if isElement( UI.bg ) then return end

    local function close( )
        if isElement( UI.bg ) then destroyElement( UI.bg ) end
		showCursor( false )
	end

    UI.bg = ibCreateBackground( 0xF2394a5c, _, true )
        :ibData( "alpha", 0 )
        :ibAlphaTo( 255, 500 )

    ibCreateImage( 0, 0, 0, 0, ":nrp_tuning_cases/images/brush.png", UI.bg )
        :ibSetRealSize( )
        :center( )

	UI.reward_text = ibCreateLabel( 0, 0, 0, 0, "Поздравляем! Вы получили:", UI.bg )
		:ibBatchData( { font = ibFonts.bold_20, align_x = "center", align_y = "center" })
		:center( 0, -260 )

	local func_interpolate = function( self )
		self:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
		end, 350, "SineCurve" )
	end

	ibCreateLabel( 0, 25, 0, 0, "Премиум на " .. premium_days .. " дня", UI.reward_text, 0xffffe743 )
		:ibBatchData( { font = ibFonts.bold_25, align_x = "center", align_y = "top" })
		:ibTimer( func_interpolate, 100, 1 )
		:ibTimer( func_interpolate, 1000, 0 )

	UI.reward_item_bg = ibCreateArea( 0, 0, 370, 370, UI.bg )
		:center( 0, -45 )
	ibCreateImage( 0, 0, 0, 0, ":nrp_shop/img/cases/items/big/premium.png", UI.reward_item_bg )
		:ibSetRealSize( ):center( )
	ibCreateLabel( 0, 0, 0, 0, premium_days .. " дн.", UI.reward_item_bg )
		:ibBatchData( { font = ibFonts.bold_40, align_x = "center", align_y = "center" })
		:center( 0, 65 )

    ibCreateButton( 0, 0, 192, 110, UI.bg,
			":nrp_tuning_cases/images/btn_take_i.png", ":nrp_tuning_cases/images/btn_take_h.png", ":nrp_tuning_cases/images/btn_take_h.png",
			0xFFFFFFFF, 0xFFFFFFFF, 0xBBFFFFFF )
        :center( 0, 277 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            close( )
        end )

	playSound( ":nrp_shop/sfx/reward_small.mp3" )
	
	showCursor( true )
end
addEvent( "onClientPremiumGiveaway", true )
addEventHandler( "onClientPremiumGiveaway", resourceRoot, ShowPremiumGiveawayUI )