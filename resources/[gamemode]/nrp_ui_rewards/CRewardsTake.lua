Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ShUtils" )

local UIs = { }

function ShowTakeReward( parent, item_type, item )
	-- if not item or not isElement( UI.bg ) then return end
	-- if isElement( UI.reward_bg ) then return end

    parent:ibData( "can_destroy", false )
    ibUseRealFonts( true )

	local UI = {
		args = { parent, item_type, item },
	}
    
    UI.reward_bg = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, 0, parent, 0xF2394a5c )
        :ibData( "priority", 2 ):ibData( "alpha", 0 ):ibAlphaTo( 255, 700 )
	ibCreateImage( 0, 0, 1341, 791, "img/brush.png", UI.reward_bg ):center( )

	UI.reward_info_area = ibCreateArea( 0, 0, _SCREEN_X, _SCREEN_Y, UI.reward_bg )

    local reward_text = "Поздравляем! Вы получили:"
    UI.reward_text = ibCreateLabel( 0, 0, 0, 0, reward_text, UI.reward_info_area )
        :ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })
        :center( 0, -244 )

    local func_interpolate = function( self )
        self:ibInterpolate( function( self )
            if not isElement( self.element ) then return end
            self.easing_value = 1 + 0.2 * self.easing_value
            self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
        end, 350, "SineCurve" )
    end

	local item_class = REGISTERED_ITEMS[ item_type ]
    local description_data = item_class.uiGetDescriptionData( item_type, item.params )
    local title = ( description_data.reward_title or description_data.title or "" ):gsub( "\n", " " ):gsub( "  ", " " )
    ibCreateLabel( 0, 32, 0, 0, title, UI.reward_text, 0xffffe743 )
        :ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })
        :ibTimer( func_interpolate, 100, 1 )
        :ibTimer( func_interpolate, 1000, 0 )

	UI.reward_item_bg = ibCreateArea( 0, 0, 300, 396, UI.reward_info_area ):center( )
	item_class.uiCreateRewardItem( item_type, item.params, UI.reward_item_bg, fonts, true )

	local source = source
	UI.OnTake = function ( data )
		parent:ibData( "can_destroy", true )
		destroyElement( UI.reward_bg )
		triggerEvent( "ShowTakeReward_callback", source, data )
	end

	if item_class.uiCreateCustomTake and item_class.uiCreateCustomTake( UI.reward_info_area, UI.reward_item_bg, UI.OnTake, item.params ) then

	else
		UI.btn_take = ibCreateButton( 0, 0, 192, 110, UI.reward_bg,
				"img/btn_take_i.png", "img/btn_take_h.png", "img/btn_take_h.png",
				0xFFFFFFFF, 0xFFFFFFFF, 0xAAFFFFFF )
			:center( 0, 223 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				if item_class.OnPreTake then
					item_class.OnPreTake( UI.OnTake )
				else
					UI.OnTake( )
				end
			end, false )

		if item.params.exchange then
			UI.btn_take:ibData( "alpha", 0 )
			UI.item_data = { item_type, item }

			local item_uid = os.time( )
			while( UIs[ item_uid ] ) do
				item_uid = item_uid + 1
			end
			UIs[ item_uid ] = UI
			triggerServerEvent( "CheckIsExchangeAvailable", resourceRoot, item_uid, item_type, item.params )
		end
	end

	if item.rare and item.rare > 3 then
		playSound( ":nrp_shop/sfx/reward_big.wav" )
	else
		playSound( ":nrp_shop/sfx/reward_small.mp3" )
    end
    
    ibUseRealFonts( false )
end
addEvent( "ShowTakeReward", true )
addEventHandler( "ShowTakeReward", root, ShowTakeReward )

addEvent( "CheckIsExchangeAvailable_callback", true )
addEventHandler( "CheckIsExchangeAvailable_callback", resourceRoot, function( item_uid, is_exchange_available, can_take )
	local UI = UIs[ item_uid ]
	if not UI then return end

	UI.btn_take:ibData( "alpha", 255 )

	if is_exchange_available then
		local parent, item_type, item = unpack( UI.args )
		ibUseRealFonts( true )

		UI.reward_text:center( 0, -326 )
		UI.reward_item_bg:center( 0, -150 )
		if can_take then
			UI.btn_take:center( 0, 55 )
		else
			UI.btn_take:destroy( )
		end

		local bg = ibCreateImage( 0, 0, 366, 166, ":nrp_shop/img/cases/bg_exchange.png", UI.reward_bg )
			:center( 0, isElement( UI.btn_take ) and 225 or 130 )

		local text = can_take 
			and "Пол этого скина не совпадает с полом вашего персонажа. \nВы можете его обменять:"
			or "У вас в наличии уже есть полученный предмет. \nВы можете его обменять:"
		ibCreateLabel( 0, 0, 0, 0, text, bg )
			:ibBatchData( { font = ibFonts.regular_16, align_x = "center", align_y = "top" })
			:center_x( )

		ibCreateLabel( 68, 141, 0, 0, item.params.exchange.exp, bg )
			:ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })

		ibCreateButton( 18, 185, 100, 40, bg,
				":nrp_shop/img/cases/btn_exchange_i.png", ":nrp_shop/img/cases/btn_exchange_h.png", ":nrp_shop/img/cases/btn_exchange_h.png",
				0xFFFFFFFF, 0xFFFFFFFF, 0xAAFFFFFF )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				UI.OnTake( { exchange_to = "exp" } )
			end, false )

		ibCreateLabel( 298, 141, 0, 0, abbreviate_number( item.params.exchange.soft ), bg )
			:ibBatchData( { font = ibFonts.bold_22, align_x = "center", align_y = "center" })

		ibCreateButton( 248, 185, 100, 40, bg,
				":nrp_shop/img/cases/btn_exchange_i.png", ":nrp_shop/img/cases/btn_exchange_h.png", ":nrp_shop/img/cases/btn_exchange_h.png",
				0xFFFFFFFF, 0xFFFFFFFF, 0xAAFFFFFF )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				UI.OnTake( { exchange_to = "soft" } )
			end, false )

		ibUseRealFonts( false )
	end
end )

addEvent( "ShowTakeReward_callback" )

function CreateVehicleSelector( py, parent, with_moto, OnSelect )

    local scrollpane, scrollbar = ibCreateScrollpane( 0, py, parent:width(), parent:height() - py, parent, { scroll_px = -20 } )
    scrollbar:ibSetStyle( "slim_nobg" )

    local sx, sy = parent:width(), 74

    ibCreateImage( 30, py-1, sx-60, 1, nil, parent, 0x55ffffff )

    local pVehicles = localPlayer:GetVehicles( true, with_moto, true )

    local px, py = 0, 0
    for i, v in pairs( pVehicles ) do
        local hover = ibCreateImage( px, py, sx, sy, nil, scrollpane, 0x1cffffff ):ibData( "alpha", 0 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

        ibCreateImage( px+30, py+sy/2-16, 49, 33, ":nrp_shop/img/icon_vehicle.png", scrollpane ):ibData( "disabled", true )
        ibCreateLabel( px+100, py, 0, sy, VEHICLE_CONFIG[ v.model ].model .. " #aaaaaa(" .. v:GetNumberPlateHR( true ) .. ")", scrollpane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 ):ibData("disabled", true)
			:ibData( "colored", true )
        ibCreateButton( sx-152, py+sy/2-19, 126, 38, scrollpane, ":nrp_shop/img/btn_select.png", ":nrp_shop/img/btn_select_hover.png", ":nrp_shop/img/btn_select_hover.png" )
            :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                
                OnSelect( v )
            end )
        
        ibCreateImage( 30, py+sy-1, sx-60, 1, nil, scrollpane, 0x55ffffff )

        py = py + sy
    end

    scrollpane:AdaptHeightToContents( )
	scrollbar:UpdateScrollbarVisibility( scrollpane )
	
	if py > scrollpane:height( ) then
		ibCreateImage( 30, parent:height(), sx-60, 1, nil, parent, 0x55ffffff )
	end
end