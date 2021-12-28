UI = { }

function ShowCarsellUI( state )
    if not state then
		DestroyTableElements( UI )
		UI = { }
        return
    end

    ShowCarsellUI( false )

    UI.black_bg = ibCreateBackground( 0x00000000, Carsell_ShowUI, _, true )
    UI.bg = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/bg.png", UI.black_bg )

    --------------------------------------------------------------------------------------
    -- Header

    ibCreateImage( 3, 3, 0, 0, "img/logo/" .. DATA.assortment_id .. ".png", UI.bg ):ibSetRealSize( )

    UI.header_right_area = ibCreateArea( 0, 0, 0, 0, UI.bg )

    ibCreateImage( 0, 21, 146, 44, "img/header/lbl_slots.png", UI.header_right_area )
    UI.have_slots = ibCreateLabel( 143, 25, 0, 0, math.max( 0, DATA.free_slots ), UI.header_right_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.oxaniumregular_20 )
        :ibData( "outline", true )
        :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 50 ) )
    UI.free_slots = ibCreateLabel( 0, 28, 0, 0, " /" .. DATA.have_slots, UI.header_right_area, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.oxaniumregular_18 )
        :ibData( "outline", true )
        :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 25 ) )
    
    UI.UpdateSlots = function( )
        UI.have_slots:ibData( "text", math.max( 0, DATA.free_slots ) )
        UI.free_slots:ibData( "text", " /" .. DATA.have_slots )
        UI.UpdateHeaderRightAreaPosition( )
    end
        
    UI.btn_buy_slots = ibCreateButton( 0, 28 - 17, 59, 59, UI.header_right_area,
            "img/header/btn_buy_slot.png", "img/header/btn_buy_slot_h.png", "img/header/btn_buy_slot_h.png", 0xFFffffff, 0xFFffffff, 0xFFaaaaaa )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            SendElasticGameEvent( "f4r_auto_showroom_slot_purchase_button_click" )
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "services" )
        end )

    UI.bg_lvl = ibCreateImage( 0, 5, 116, 68, "img/header/bg_lvl.png", UI.header_right_area )
    ibCreateLabel( 76, 34, 0, 0, localPlayer:GetLevel( ), UI.bg_lvl, COLOR_WHITE, 1, 1, "center", "center", ibFonts.oxaniumbold_14 )

    UI.icon_soft = ibCreateImage( 0, 13, 60, 55, "img/header/icon_soft.png", UI.header_right_area )
    UI.balance = ibCreateLabel( 0, 23, 0, 0, format_price( localPlayer:GetMoney( ) ), UI.header_right_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.oxaniumbold_22 )
        :ibData( "outline", true )
        :ibTimer( function( self )
            local text = format_price( localPlayer:GetMoney( ) )
            if self:ibData( "text" ) == text then return end
            self:ibData( "text", text )
            UI.UpdateHeaderRightAreaPosition( )
        end, 1000, 0 )
    
    UI.btn_recharge = ibCreateButton( 0, 17, 162, 44, UI.header_right_area, "img/header/btn_recharge.png", _, _, 0xAAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
        end )
    
    UI.btn_exit = ibCreateButton( 0, 14, 108, 53, UI.header_right_area, "img/header/btn_exit.png", _, _, 0xAAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            Carsell_ShowUI( false )
        end )
    
    UI.UpdateHeaderRightAreaPosition = function( )
        UI.free_slots:ibData( "px", UI.have_slots:ibGetAfterX( ) )
        UI.btn_buy_slots:ibData( "px", UI.free_slots:ibGetAfterX( 10 - 17 ) )
        UI.bg_lvl:ibData( "px", UI.btn_buy_slots:ibGetAfterX( -17 + 20 ) )
        UI.icon_soft:ibData( "px", UI.bg_lvl:ibGetAfterX( 20 - 15 ) )
        UI.balance:ibData( "px", UI.icon_soft:ibGetAfterX( -15 + 10 ) )
        UI.btn_recharge:ibData( "px", UI.balance:ibGetAfterX( 20 - 16 ) )
        UI.btn_exit:ibData( "px", UI.btn_recharge:ibGetAfterX( ) )

        UI.header_right_area:ibData( "px", _SCREEN_X - 20 - UI.btn_exit:ibGetAfterX( -15 ) )
    end
    UI.UpdateHeaderRightAreaPosition( )

    ibCreateLine( 20, 77, _SCREEN_X - 20, _, ibApplyAlpha( COLOR_WHITE, 70 ), 1, UI.bg )

    --------------------------------------------------------------------------------------
    -- Левая панель с статами авто

    ibCreateImage( 4, 80, 609, 522, "img/bg_left_panel.png", UI.bg ):ibData( "disabled", true )

    UI.icon_new = ibCreateImage( 333, 105, 23, 23, ":nrp_shared/img/icon_indicator_new.png", UI.bg )

    UI.model      = ibCreateLabel( 38,  129, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_22 )
    UI.mod        = ibCreateLabel( 38,  2,   0, 0, "", UI.model, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_16 )
    
    UI.class      = ibCreateLabel( 349, 202, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "right", "center", ibFonts.regular_24 )
    UI.drive_type = ibCreateLabel( 349, 259, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "right", "center", ibFonts.regular_18 )

    UI.UpdateInfo = function( )
        UI.icon_new:ibData( "visible", not not VEHICLE_DATA.time_new )

        UI.model:ibData( "text", VEHICLE_DATA.model )
        UI.mod:ibData( "text", VARIANT_DATA.mod )
        local i = 0
        while ( dxGetTextWidth( VEHICLE_DATA.model, 1, ibFonts[ "bold_" .. ( 22 - i ) ] ) + 10 + dxGetTextWidth( VARIANT_DATA.mod , 1, ibFonts[ "regular_" .. ( 16 - i ) ] ) ) > 305 do
            i = i + 1
        end
        UI.model:ibData( "font", ibFonts[ "bold_" .. ( 22 - i ) ] )
        UI.mod:ibData( "font", ibFonts[ "regular_" .. ( 16 - i ) ] ):ibData( "px", UI.model:width( ) + 10 )

        UI.class:ibData( "text", VEHICLE_CLASSES_NAMES[ VEHICLE:GetTier( ) ] )
        UI.drive_type:ibData( "text", DRIVE_TYPE_NAMES[ VARIANT_DATA.handling.driveType ] )
    end
    
    local stats = {
        { key = "power"              , max_value = 800 , unit = " л.с." },
        { key = "stats_speed"        , max_value = 400 , unit = " км/ч" },
        { key = "stats_acceleration" , max_value = 400 , unit = ""      },
        { key = "ftc"                , max_value = 30  , unit = " c"    },
        { key = "fuel_loss"          , max_value = 30  , get_unit = function( ) return ( VEHICLE_DATA.is_electric and " %" or " л" ) end },
    }
    for i, stat in pairs( stats ) do
        UI[ stat.key ] = { }
        UI[ stat.key ].label = ibCreateLabel( 349, 320 + ( i - 1 ) * 57, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "right", "center", ibFonts.regular_12 )
        UI[ stat.key ].progressbar = ibCreateImage( 118, 332 + ( i - 1 ) * 57, 0, 12, _, UI.bg, 0xFFff975e )
    end

    UI.UpdateStats = function( )
        for i, stat in pairs( stats ) do
            UI[ stat.key ].label:ibData( "text", VARIANT_DATA[ stat.key ] .. ( stat.unit or stat.get_unit( ) ) )
            UI[ stat.key ].progressbar:ibResizeTo( math.min( VARIANT_DATA[ stat.key ] / stat.max_value, 1 ) * 231, _, 800, "InOutQuad" )
        end

        -- if isElement( UI.triangle ) then UI.triangle:destroy( ) end
        -- UI.triangle = exports.nrp_tuning_shop:generateTriangleTexture( 425, 395, UI.bg, getVehicleOriginalParameters( VEHICLE.model ) )
    end

    -- Стоимость автомобиля
    ibCreateImage( 360, 85, 401, 141, "img/bg_cost.png", UI.bg )
    UI.cost = ibCreateLabel( 460, 158, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.oxaniumbold_54 )
        :ibData( "outline", true )
        :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 50 ) )

    UI.old_cost_area = ibCreateArea( 410, 199, 0, 0, UI.bg )
    ibCreateImage( 5, 0, 28, 28, ":nrp_shared/img/money_icon.png", UI.old_cost_area, ibApplyAlpha( COLOR_WHITE, 50 ) )
    UI.old_cost = ibCreateLabel( 53, 14, 0, 0, "", UI.old_cost_area, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.oxaniumbold_26 )
        :ibData( "outline", true )
        :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 10 ) )
    UI.old_cost_line = ibCreateImage( 1, UI.old_cost:ibGetCenterY( ), 0, 1, _, UI.old_cost_area, ibApplyAlpha( COLOR_WHITE, 50 ) )
    
    UI.cartrade_lvl = ibCreateLabel( 392, 182 + 24, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_20 )
    -- UI.cartrade_lvl = ibCreateLabel( 392, 182 + 10, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_14 )
        :ibData( "outline", true )
        :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 50 ) )

    UI.UpdateCost = function( )
        UI.cost:ibData( "text", format_price( VARIANT_DATA.discount_cost or VARIANT_DATA.cost ) )
        if VARIANT_DATA.discount_cost then
            UI.old_cost_area:ibData( "visible", true )
            UI.old_cost:ibData( "text", format_price( VARIANT_DATA.cost ) )
            UI.old_cost_line:ibData( "sx", UI.old_cost:ibGetAfterX( 4 ) )
        else
            UI.old_cost_area:ibData( "visible", false )
        end

        if not VARIANT_DATA.untradable and VARIANT_DATA.level then
            UI.cartrade_lvl:ibData( "visible", true )
            UI.cartrade_lvl:ibData( "text", "Доступно на БУ с " .. VARIANT_DATA.level .. " уровня" )
            UI.cartrade_lvl:ibData( "py", VARIANT_DATA.discount_cost and ( 182 + 43 + 24 ) or ( 182 + 24 ) )
        else
            UI.cartrade_lvl:ibData( "visible", false )
        end
    end

    -- Выбор цвета
	COLORS = { "#ffffff", "#808080", "#0d0c0c", "#ff3232", "#ffaf32", "#3289ff" }
    COLOR = COLOR or 1

    local btn_sx = 26
    local gap = 25
    UI.color_selector = ibCreateImage( 0, 98, 15 + #COLORS * ( btn_sx + gap ) - 25 + 15, 55, _, UI.bg, ibApplyAlpha( 0xFF2a323c, 75 ) )
    UI.color_btns = { }
    for i, color in pairs( COLORS ) do
        local px = 15 + ( btn_sx + gap ) * ( i - 1 )
        local py = 14
        local color_img = ibCreateImage( px, py, 26, 26, _, UI.color_selector, tonumber( "0xFF" .. color:sub( 2 ) ) )
        local btn_img = ibCreateImage( -14, -14, 54, 54, "img/btn_color.png", color_img )
        UI.color_btns[ i ] = btn_img
        ibCreateArea( px, py, 26, 26, UI.color_selector )
            :ibOnHover( function( )
                if i == COLOR then return end
                btn_img:ibData( "texture", "img/btn_color_selected.png" )
                btn_img:ibData( "alpha", 150 )
            end )
            :ibOnLeave( function( )
                if i == COLOR then return end
                btn_img:ibData( "texture", "img/btn_color.png" )
                btn_img:ibData( "alpha", 255 )
            end )
            -- :ibOnLeave( function( ) if i ~= COLOR then color_img:ibAlphaTo( 185 ) end end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                if i == COLOR then return end
                ibClick( )

                COLOR = i
                UI.UpdateSelectedColor( )
                Carsell_ParseVehicleColor( )
            end )
        
        if i == COLOR then
        end
    end
    local icon_color = ibCreateImage( UI.color_selector:width( ) - 17, -17, 95, 89, "img/icon_color.png", UI.color_selector )
    UI.color_selector:ibData( "px", _SCREEN_X - 20 - ( icon_color:ibGetAfterX( ) - 17 ) )

    UI.UpdateSelectedColor = function( )
        if UI.color_selected_btn then
            UI.color_selected_btn:ibData( "texture", "img/btn_color.png" )
        end
        UI.color_selected_btn = UI.color_btns[ COLOR ]:ibData( "texture", "img/btn_color_selected.png" ):ibAlphaTo( 255, 100 )
    end
    
    -- Доступно с премиумом и т.д.
    UI.bg_blocked = ibCreateImage( _SCREEN_X - 20 - ( 95 - 17 ), 81, 95, 89, "img/icon_blocked.png", UI.bg )
    UI.bg_blocked_reason = ibCreateImage( 17, 17, -100, 55, _, UI.bg_blocked, ibApplyAlpha( 0xFF202f3a, 75 ) )
    UI.blocked_reason = ibCreateLabel( -15, 0, 0, 55, "0", UI.bg_blocked_reason, COLOR_WHITE, 1, 1, "right", "center", ibFonts.regular_14 )

    UI.UpdateBlockedReason = function( )
        local blocked_reason = GetVehicleBlockedReason( ) or false
        UI.bg_blocked:ibData( "visible", blocked_reason )
        UI.blocked_reason:ibData( "text", blocked_reason or "" )
        UI.bg_blocked_reason:ibData( "sx", -15 - UI.blocked_reason:width( ) - 15 )

        UI.color_selector:ibData( "visible", not blocked_reason )
    end
    
    -- Вместимость багажника:
    UI.icon_trunk = ibCreateImage( _SCREEN_X - 20 - ( 95 - 17 ), 146, 95, 89, "img/icon_trunk.png", UI.bg )
    UI.bg_trunk = ibCreateImage( 17, 17, 100, 55, _, UI.icon_trunk, ibApplyAlpha( 0xFF202f3a, 75 ) )
    UI.trunk_size_lbl = ibCreateLabel( 17, 0, 0, 55, "Вместимость багажника: ", UI.bg_trunk, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_14 )
    UI.trunk_size = ibCreateLabel( UI.trunk_size_lbl:ibGetAfterX(), 0, 0, 55, "0", UI.bg_trunk, COLOR_WHITE, 1, 1, "left", "center", ibFonts.oxaniumbold_14 )
    UI.trunk_size_kg = ibCreateLabel( UI.trunk_size:ibGetAfterX(), 0, 0, 55, " кг", UI.bg_trunk, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_14 )

    UI.UpdateTrunkSize = function( )
        local size = VEHICLES_MAX_WEIGHTS[ VEHICLE_DATA.vmodel ]
        if size then
            UI.icon_trunk:ibData( "visible", true )
            UI.trunk_size:ibData( "text", size )
            UI.trunk_size_kg:ibData( "px", UI.trunk_size:ibGetAfterX() )
            UI.bg_trunk:ibData( "px", -UI.trunk_size_kg:ibGetAfterX() )
            UI.bg_trunk:ibData( "sx", UI.trunk_size_kg:ibGetAfterX() + 17 )
        else
            UI.icon_trunk:ibData( "visible", false )
        end
    end

    -----------------------------------------------------------------------------------
    -- Скролл панель с машинами

    UI.btn_left = ibCreateImage( _SCREEN_X - 20 - 14 - 20 - 14 - 15, _SCREEN_Y - 270, 44, 52, "img/btn_arrow_left.png", UI.bg )
        :ibBatchData( { disabled = true, alpha = 150 } )
    ibCreateArea( 0, 0, 22, 26, UI.btn_left ):center( )
        :ibOnHover( function( ) UI.btn_left:ibAlphaTo( 255 ) end )
        :ibOnLeave( function( ) UI.btn_left:ibAlphaTo( 150 ) end )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            Carsell_ChangeVehicle( _, _, -1 )
        end )

    UI.btn_right = ibCreateImage( _SCREEN_X - 20 - 14 - 15, _SCREEN_Y - 270, 44, 52, "img/btn_arrow_right.png", UI.bg )
        :ibBatchData( { disabled = true, alpha = 150 } )
    ibCreateArea( 0, 0, 22, 26, UI.btn_right ):center( )
        :ibOnHover( function( ) UI.btn_right:ibAlphaTo( 255 ) end )
        :ibOnLeave( function( ) UI.btn_right:ibAlphaTo( 150 ) end )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            Carsell_ChangeVehicle( _, _, 1 )
        end )

    ibCreateImage( UI.btn_left:ibGetBeforeX( -111 + 14 ), _SCREEN_Y - 288, 123, 91, "img/bg_counter.png", UI.bg )
        :ibData( "disabled", true )
    UI.total_count = ibCreateLabel( UI.btn_left:ibGetBeforeX( -20 + 15 ), _SCREEN_Y - 263, 0, 0, "/" .. #VEHICLES_LIST, UI.bg, 0xFFb3b7ba, 1, 1, "right", "top", ibFonts.oxaniumregular_26 )
        :ibData( "outline", true )
        :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 25 ) )
    UI.current_veh = ibCreateLabel( UI.total_count:ibGetBeforeX( -2 ), _SCREEN_Y - 268, 0, 0, VEH, UI.bg, COLOR_WHITE, 1, 1, "right", "top", ibFonts.oxaniumregular_30 )
        :ibData( "outline", true )
        :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 50 ) )

    local item_sx = 260
    local item_sy = 150
    local gap = 20
    local pane_sx = gap
    
    local scrollpane, scrollbar = ibCreateScrollpane( 0, _SCREEN_Y - 214 - 28, _SCREEN_X, 206, UI.bg, { horizontal = true } )
    scrollpane:ibData( "priority", -1 )
    scrollbar:ibBatchData( { handle_color = 0, bg_color = 0, absolute = true, sensivity = item_sx * 0.025 } )
    
    UI.bg_item_selected = { }
    for i, vehicle_data in pairs( VEHICLES_LIST ) do
        local bg_item = ibCreateImage( pane_sx, 28, item_sx, item_sy, "img/bg_vehicle.png", scrollpane )
        local bg_item_selected = ibCreateImage( -28, -28, 316, 206, "img/bg_vehicle_selected.png", bg_item )
            :ibData( "alpha", 0 )
        UI.bg_item_selected[ i ] = bg_item_selected

        local img_vehicle = ibCreateContentImage( 0, 0, 300, 160, "vehicle", vehicle_data.vmodel, bg_item )
            :ibSetInBoundSize( 220 ):center( 0, 7 )
        
        if i > 1 and vehicle_data.vmodel == VEHICLES_LIST[ i - 1 ].vmodel then
            ibCreateLabel( 10, 8, 0, 0, "Модификация:", bg_item, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.regular_12 )
            ibCreateLabel( 10, 22, 0, 0, vehicle_data.variant_data.mod, bg_item, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
        end

        if GetVehicleBlockedReason( vehicle_data, vehicle_data.variant_data ) then
            img_vehicle:ibData( "alpha", 255 * 0.7 )
            ibCreateImage( 0, 0, item_sx, item_sy, "img/bg_vehicle_locked_top_layer.png", bg_item )
            ibCreateLabel( 0, 108, item_sx, 0, GetVehicleBlockedReason( vehicle_data, vehicle_data.variant_data ), bg_item, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "center", "center", ibFonts.bold_16 )
        end

        if vehicle_data.time_new then
            ibCreateImage( 228, 9, 23, 23, ":nrp_shared/img/icon_indicator_new.png", bg_item )
        end

        ibCreateArea( 0, 0, item_sx, item_sy, bg_item )
            :ibOnHover( function( ) if i ~= VEH then bg_item_selected:ibAlphaTo( 128 ) end end )
            :ibOnLeave( function( ) if i ~= VEH then bg_item_selected:ibAlphaTo( 0 ) end end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                if i == VEH then return end
                ibClick( )

                VEH = i
                UI.current_veh:ibData( "text", VEH )
                UI.current_bg_item_selected:ibAlphaTo( 0 )
                UI.current_bg_item_selected = bg_item_selected:ibAlphaTo( 255 )
                Carsell_ParseCurrentVehicle( )
            end )

        pane_sx = pane_sx + item_sx + gap
    end
    UI.current_bg_item_selected = UI.bg_item_selected[ VEH ]:ibAlphaTo( 255 )

    UI.UpdateSelectedVehicle = function(  )
        UI.current_veh:ibData( "text", VEH )
        UI.current_bg_item_selected:ibAlphaTo( 0 )
        UI.current_bg_item_selected = UI.bg_item_selected[ VEH ]:ibAlphaTo( 255 )

        local vehicle_index = VEH

        local position = scrollbar:ibData( "position" )
        local viewport_sx = scrollpane:ibData( "viewport_sx" )
        local item_full_sx = item_sx + gap
        local first_fully_visible_index = math.ceil( ( ( pane_sx - viewport_sx ) * position + item_full_sx ) / item_full_sx )
        local last_fully_visible_index = math.ceil( ( ( pane_sx - viewport_sx ) * position + viewport_sx - item_full_sx ) / item_full_sx )
        if vehicle_index < first_fully_visible_index then
            scrollbar:ibScrollTo( item_full_sx * ( vehicle_index - 1 ) / ( pane_sx - viewport_sx ) )
        elseif vehicle_index > last_fully_visible_index then
            scrollbar:ibScrollTo( ( item_full_sx * vehicle_index + gap - viewport_sx ) / ( pane_sx - viewport_sx ) )
        end
    end
    
    scrollpane:ibData( "sx", pane_sx )

    ibCreateImage( 3, _SCREEN_Y - 3 - 59, 0, 0, "img/hint.png", UI.bg ):ibSetRealSize( )
end