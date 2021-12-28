TABS_CONF.donate = {
    elements = { },

    fn_create = function( self, parent )
        ----------
        -- Паки --
        ----------
        
        local packs = { 100, 250, 500, 1000, 2000, 5000 }
        local target_price = { 100, 250, 500, 1000, 2000, 5000 }

        if localPlayer:getData( "segmented_packs" ) then
            packs = { 149, 299, 799, 2499, 4999, 9999 }
            target_price = { 149, 299, 799, 2499, 4999, 9999 }
        end

        local npx, npy = 30, 65
        for i, v in pairs( packs ) do
            -- Обычный пак
            local bg = ibCreateImage( npx, npy, 149, 155, "img/packs/bg_pack.png", parent )
            ibCreateImage( 0, 0, 149, 155, "img/packs/pack_" .. i .. ".png", bg )
            ibCreateImage( 0, 24, 0, 0, "img/packs/price_" .. v .. ".png", bg )
                :ibSetRealSize( )
                :center_x( )

            -- Наведение
            local area = ibCreateArea( npx, npy, 149, 155, parent ):ibData( "alpha", 0 )
            ibCreateImage( 0, 0, 149, 155, "img/packs/bg_pack_hover.png", area )
            ibCreateImage( 0, 8, 0, 0, "img/packs/price_" .. v .. ".png", area )
                :ibSetRealSize( )
                :center_x( )
            ibCreateLabel( 0, 75, 0, 0, "За " .. target_price[ i ] .. " руб.", area, 0xff00ff89, _, _, "center", "top", ibFonts.semibold_14 )
                :center_x( )
            ibCreateImage( 0, 55, 219, 133, "img/packs/btn_add.png", area )
                :center_x( )
            
            local hover = ibCreateImage( 0, 55, 219, 133, "img/packs/btn_add_hover.png", area )
            hover
                :center_x( )
                :ibOnRender( function( )
                    hover:ibData( "alpha", math.abs( math.sin( getTickCount( ) / 500 ) * 255 ) )
                end )

            
            ibCreateArea( npx, npy, 149, 155, parent )
                :ibOnHover( function( )
                    bg:ibAlphaTo( 0, 200 )
                    area:ibAlphaTo( 255, 200 )
                end )
                :ibOnLeave( function( )
                    bg:ibAlphaTo( 255, 200 )
                    area:ibAlphaTo( 0, 200 )
                end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    localPlayer:ShowInfo( "Покупка доната через дискорд -\nBasapen#8535 и Geeldon#9786" )
                end )


            if i > 0 and i % 3 == 0 then
                npx = 30
                npy = npy + 155 + 10
            else
                npx = npx + 149 + 10
            end
        end


        ------------------------------
        -- Пополнение другой суммой --
        ------------------------------

        ibCreateLabel( 30, 457, 0, 0, "Другая сумма?", parent, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_16 )

        do
            local edit_bg = ibCreateImage( 189, 438, 149, 40, "img/packs/bg_input.png", parent )
            local edit = ibCreateEdit( 15, 0, 100, 40, "500", edit_bg, ibApplyAlpha( COLOR_WHITE, 75 ), 0, ibApplyAlpha( COLOR_WHITE, 75 ) )
                :ibData( "font", ibFonts.regular_14 )
            ibCreateImage( 117, 11, 18, 18, ":nrp_shared/img/hard_money_icon.png", edit_bg )

            local ERR_MIN_50 = 1
            local ERR_CLEAN = 2

            local function shake( )
                local diff      = 5
                local speed     = 50
                local base_pos  = 189
                local right_pos = base_pos + diff
                local left_pos  = base_pos - diff
                
                edit_bg
                    :ibMoveTo( left_pos, _, speed )
                    :ibTimer( function( self )
                        self:ibMoveTo( right_pos, _, speed )
                    end, speed, 1 )
                    :ibTimer( function( self )
                        self:ibMoveTo( base_pos, _, speed )
                    end, speed * 2, 1 )
            end

            local err_area
            local function err( type )
                if isElement( err_area ) then destroyElement( err_area ) end

                if type ~= ERR_CLEAN then
                    edit_bg:ibData( "texture", "img/packs/bg_input_error.png" )
                    shake( )
                    ibError( )
                    err_area = ibCreateArea( 260, 420, 0, 0, parent )
                    if type == ERR_MIN_50 then
                        ibCreateImage( 0, 0, 0, 0, "img/packs/err_line_50.png", err_area ):ibSetRealSize( ):center( )
                    end
                else
                    edit_bg:ibData( "texture", "img/packs/bg_input.png" )
                end
            end
            
            edit:ibOnDataChange( function( key, value )
                if key == "text" then
                    err( ERR_CLEAN )    
                end
            end )

            ibCreateImage( 320, 392, 219, 133, "img/packs/btn_add.png", parent )
            local hover = ibCreateImage( 320, 392, 219, 133, "img/packs/btn_add_hover.png", parent ):ibData( "alpha", 0 )
            hover
                :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    local amount = math.floor( tonumber( edit:ibData( "text" ) ) or 0 )
                    if amount < 50 or not isnumber( amount ) then
                        err( ERR_MIN_50 )
                        return
                    end
                    localPlayer:ShowInfo( "Покупка доната через дискорд -\nBasapen#8535 и Geeldon#9786" )
                end )
        end
        ------------------------
        --     Промокоды      --
        ------------------------

        do
            local editweb_bg = ibCreateImage( 540, 65, 240, 40, "img/packs/bg_input_wide.png", parent )
            local lbl_placeholder = ibCreateLabel( 15, 0, 190, 40, "Введите промокод", editweb_bg, ibApplyAlpha( COLOR_WHITE, 40 ), 1, 1, "left", "center" )
                :ibData( "font", ibFonts.regular_12 )
            local editweb = ibCreateEdit( 15, 0, 210, 40, "", editweb_bg, ibApplyAlpha( COLOR_WHITE, 75 ), 0, ibApplyAlpha( COLOR_WHITE, 75 ) )
                :ibData( "font", ibFonts.regular_12 )
                :ibOnFocusChange( function( focused ) 
                    lbl_placeholder:ibData( "visible", not focused and source:ibData( "text" ) == "" )
                end )
                -- :ibBatchData( { 
                --     placeholder = "Введите промокод", 
                --     placeholder_color = ibApplyAlpha( COLOR_WHITE, 75 ) 
                -- } )

            local btnApply = ibCreateImage( 590, 131, 130, 39, "img/donate/btn_apply.png", parent ):ibSetRealSize()
            :ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                local text = editweb:ibData( "text" ) or ""
                if key ~= "left" or state ~= "up" or text == "" or text == " " then return end
                ibClick( )
                
                source:ibData( "disabled", true )
                source:ibTimer( function( self )
                    self:ibData( "disabled", false )
                end, 1000, 1 )
                
                triggerServerEvent( "onClientPromocodeApplyRequest", localPlayer, text )
            end )

            local error_img = ibCreateImage( 0, 0, 240, 40, nil, editweb_bg )
                :ibData( "alpha", 0 )
                :ibData( "disabled", true )

            local function resetError( ) 
                error_img:ibAlphaTo( 0 )
            end

            editweb_bg:ibOnClick( function( key, state ) 
                if key ~= "left" or state ~= "up" then return end

                resetError( )
            end )

            editweb:ibOnFocusChange( function( focused ) 
                if not focused then return end

                resetError( )
            end )

            ERROR_TEXTURES = {
                [ "Incorrect code" ] = "img/packs/err_promo.png",
                [ "Used code" ]      = "img/packs/err_used_code.png",
                [ "Bruteforce ban" ] = "img/packs/err_ban.png",
            }

            addEvent( "onPromocodeApplyCallback", true )
            addEventHandler( "onPromocodeApplyCallback", root, function( err ) 
                if err and ERROR_TEXTURES[ err ] and isElement( editweb ) then
                    ibError()
                    error_img:ibData( "texture", ERROR_TEXTURES[ err ] )
                    error_img:ibAlphaTo( 255 )
                end
            end )

        end

        ibCreateLine( 540, 197, 780, _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, parent )

        ------------------------
        -- Конвертация валюты --
        ------------------------

        local offset_py = 0

        ibCreateLine( 520, 65, _, 488, ibApplyAlpha( COLOR_WHITE, 10 ), 1, parent )
        ibCreateLabel( 655, 218 + offset_py, 0, 0, "Обмен валют", parent, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "center", "center", ibFonts.regular_14 )

        do
            local edit_bg = ibCreateImage( 540, 249 + offset_py, 240, 40, "img/packs/bg_input_wide.png", parent )
            local edit = ibCreateEdit( 15, 0, 190, 40, "10", edit_bg, ibApplyAlpha( COLOR_WHITE, 75 ), 0, ibApplyAlpha( COLOR_WHITE, 75 ) )
                :ibData( "font", ibFonts.regular_12 )
            ibCreateImage( 208, 11, 18, 18, ":nrp_shared/img/hard_money_icon.png", edit_bg )

            local balance_area
            local function RefreshBalance( )
                if isElement( balance_area ) then destroyElement( balance_area ) end
                balance_area = ibCreateArea( 657, 461 + offset_py, 0, 0, parent )

                local inner_area = ibCreateArea( 0, 0, 0, 0, balance_area )
                local lbl_yourbalance = ibCreateLabel( 0, 0, 0, 0, "Ваш баланс:", inner_area ):ibData( "font", ibFonts.regular_14 )
                local lbl_balance = ibCreateLabel( lbl_yourbalance:width( ) + 10, -3, 0, 0, localPlayer:GetMoney( ), inner_area ):ibData( "font", ibFonts.bold_18 )
                local icon_money = ibCreateImage( lbl_balance:ibGetAfterX( 10 ), 1, 18, 18, ":nrp_shared/img/money_icon.png", inner_area )

                inner_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center( )
            end
            RefreshBalance( )
            edit:ibTimer( function( ) RefreshBalance( ) end, 500, 0 )

            ibCreateImage( 642, 299 + offset_py, 27, 33, "img/packs/icon_arrow_down.png", parent )

            local convert_bg = ibCreateImage( 540, 342 + offset_py, 240, 40, "img/packs/bg_input_wide.png", parent )
            local lbl_to_convert = ibCreateLabel( 15, 10, 190, 40, "10000", convert_bg, ibApplyAlpha( COLOR_WHITE, 75 ) )
                :ibData( "font", ibFonts.regular_12 )
            ibCreateImage( 208, 11, 18, 18, ":nrp_shared/img/money_icon.png", convert_bg )

            edit:ibOnDataChange( function( key, value )
                if key == "text" then
                    local amount = math.floor( tonumber( edit:ibData( "text" ) ) or 0 )
                    lbl_to_convert:ibData( "text", isnumber( amount ) and format_price( amount * 1000 ) or 0 )
                end
            end )
            
            ibCreateImage( 590, 402 + offset_py, 130, 39, "img/packs/btn_convert.png", parent )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
					SendElasticGameEvent( "f4r_f4_currency_exchange_button_click" )
                    local amount = math.floor( tonumber( edit:ibData( "text" ) ) or 0 )
                    local amount = isnumber( amount ) and amount or 0
                    if amount <= 0 then
                        onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Введена некорректная сумма для перевода!" } )
                        return
                    end

                    if localPlayer:GetDonate( ) < amount then
                        onOverlayNotificationRequest_handler( OVERLAY_ERROR, { text = "Недостаточно средств для перевода валюты!" } )
                        return
                    end

                    triggerServerEvent( "onDonateExchangeRequest", resourceRoot, amount )
                end )
        end
    end,
    fn_destroy = function( self, parent )


    end,
}

function ShowPromocodeReward( item )

    local reward_bg = ibCreateBackground( 0xE6394A5C ):ibData( "alpha", 0 ):ibAlphaTo( 255, 700 )
	local reward_brash	= ibCreateImage( 0, 0, 1174, 692, "img/cases/reward_bg.png", reward_bg ):center( )

	local item_class = REGISTERED_ITEMS[ item.id ]
	local description_data = item_class.uiGetDescriptionData_func( item.id, item.params )
	if description_data then
		reward_text = ibCreateLabel( 0, 0, 0, 0, "Поздравляем! Вы получили:", reward_bg )
			:ibBatchData( { font = ibFonts.bold_20, align_x = "center", align_y = "center" })
			:center( 0, -260 )

		local func_interpolate = function( self )
			self:ibInterpolate( function( self )
				if not isElement( self.element ) then return end
				self.easing_value = 1 + 0.2 * self.easing_value
				self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
			end, 350, "SineCurve" )
		end

		ibCreateLabel( 0, 25, 0, 0, description_data.reward_title or description_data.title, reward_text, 0xffffe743 )
			:ibBatchData( { font = ibFonts.bold_25, align_x = "center", align_y = "top" })
			:ibTimer( func_interpolate, 100, 1 )
			:ibTimer( func_interpolate, 1000, 0 )
	end

	reward_item_bg = ibCreateArea( 0, 0, 370, 370, reward_bg ):center( 0, -45 )
	item_class.uiCreateRewardItem_func( item.id, item.params, reward_item_bg, fonts, true )

	btn_take = ibCreateButton( 0, 0, 192, 110, reward_bg,
			"img/cases/btn_take_i.png", "img/cases/btn_take_h.png", "img/cases/btn_take_h.png",
			0xFFFFFFFF, 0xFFFFFFFF, 0xAAFFFFFF )
		:center( 0, 190 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			
			UI.black_bg:ibData( "can_destroy", true )
			destroyElement( reward_bg )
	end, false )

end
addEvent( "ShowPromocodeReward", true )
addEventHandler( "ShowPromocodeReward", root, ShowPromocodeReward )