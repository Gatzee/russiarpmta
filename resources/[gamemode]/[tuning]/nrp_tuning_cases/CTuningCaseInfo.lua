CONST_RARE_COLORS = {
    tuning = {
        [1] = 0xffa975ff;
        [2] = 0xff5792ff;
        [3] = 0xff5bd07d;
        [4] = 0xffffb346;
        [5] = 0xffff6464;
    },

    vinyl = {
        [1] = 0xffb7e1cd;
        [2] = 0xff9900ff;
        [3] = 0xffff00ff;
        [4] = 0xffff0000;
        [5] = 0xffffff00;
    },
}

local SEND_DATA_TIMEOUT = 0

function ShowUICaseInfo( case_info, case_discount )
    local is_tuning_case = case_info.type == "tuning"

    local function GoBack( )
        UI.bg
            :ibData( "px", -_SCREEN_X)
            :ibMoveTo( _SCREEN_X / 2 - UI.bg:ibData( "sx" ) / 2, _, 500, "OutBack" )
        UI.info_bg
            :ibData( "px", _SCREEN_X / 2 - UI.info_bg:ibData( "sx" ) / 2 )
            :ibMoveTo( _SCREEN_X, _, 500, "OutBack" )
            :ibTimer( destroyElement, 500, 1 )
    end

    if isElement( UI.info_bg ) then
        UI.info_bg:destroy( )
    end

    UI.info_bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, 0xFF475d75 ):center( )

    local head_bg = ibCreateImage( 0, 0, UI.info_bg:ibData( "sx" ), 80, _, UI.info_bg, 0x1A000000 )
    
    ibCreateLabel( 0, 0, head_bg:ibData( "sx" ), head_bg:ibData( "sy" ), 
        case_info.name, head_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_21 )
    
    ibCreateButton( 21, 0, 130, 40, head_bg,
        "images/btn_back.png", "images/btn_back.png", "images/btn_back.png",
        0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
        :center_y( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            GoBack( )
        end )
    
    ibCreateButton( UI.info_bg:ibData( "sx" ) - 55, 24, 25, 25, head_bg, 
        ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
        0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            ShowUICasesList( false )
        end )

    ibCreateImage( 0, head_bg:ibGetAfterY( -1 ), UI.info_bg:ibData( "sx" ), 1, _, head_bg, 0x1Affffff )

    ---------------------------------------------------------------------------------------------------------------

    local left_col_bg = ibCreateImage( 0, head_bg:ibGetAfterY( ), 420, 
        UI.info_bg:ibData( "sy" ) - head_bg:ibData( "sy" ), _, UI.info_bg, ibApplyAlpha( 0xFF4f647b, 75 ) )

    local case_img = ibCreateContentImage( 0, 0, 472, 360, "case", case_info.img, left_col_bg )
        :ibSetInBoundSize( left_col_bg:ibData( "sx" ) ):center_x( )

    local class_img = ibCreateImage( 0, 0, 30, 21, "images/class_bg.png", case_img )
        :center( 137, 86 )
    ibCreateLabel( 0, 0, 30, 21, case_info.class, class_img )
        :ibBatchData( { font = ibFonts.bold_12, align_x = "center", align_y = "center" } ):center( )

    local buy_count = 1
    local selected_subtype = 1
    local case_cost = case_discount and case_discount.cost or case_info.cost
    case_cost = exports.nrp_tuning_shop:ApplyDiscount( case_cost )

    local cost_area = ibCreateArea( 0, 338, 0, 0, left_col_bg )
    local cost_lbl = ibCreateLabel( 0, 0, 0, 0, format_price( case_cost ), cost_area )
        :ibBatchData( { font = ibFonts.bold_26 } ):center_y( )
    local cost_img = ibCreateImage( cost_lbl:ibGetAfterX( 10 ), 4, 28, 28, 
        ":nrp_shared/img/".. ( case_info.cost_is_soft and "" or "hard_" ) .."money_icon.png", cost_area )
    cost_area:ibData( "sx", cost_img:ibGetAfterX( ) ):center_x( )

    -- Если у кейса скидка
    local old_cost_lbl, line_old_cost
    if case_discount then
        old_cost_lbl = ibCreateLabel( 0, -20, 0, 0, 0, cost_area )
            :ibBatchData( { font = ibFonts.regular_16, align_x = "center", color = 0x77ffffff } )
        line_old_cost = ibCreateImage( 0, old_cost_lbl:ibGetCenterY( ), 0, 1, _, cost_area, 0xffffffff )
    end
    
    ibCreateLabel( 0, 380, left_col_bg:ibData( "sx" ), 0, case_info.name, left_col_bg )
        :ibBatchData( { font = ibFonts.regular_18, align_x = "center" } )
    
    local count_area = ibCreateArea( 0, 450, 0, 0, left_col_bg )
    local btn_min = ibCreateButton( 0, 0, 30, 30, count_area,
        ":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png",
        0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
    local case_count_bg = ibCreateImage( btn_min:ibGetAfterX( 5 ), 0, 48, 30, "images/cases_count_bg.png", count_area )
    local case_count = ibCreateLabel( 0, 0, 0, 0, buy_count, case_count_bg )
        :center( ):ibBatchData( { font = ibFonts.bold_18, align_x = "center", align_y = "center" } )
    local btn_plus = ibCreateButton( case_count_bg:ibGetAfterX( 5 ), 0, 30, 30, count_area,
        ":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png",
        0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
    count_area:ibData( "sx", btn_plus:ibGetAfterX( ) ):center_x( )

    local type_area = ibCreateArea( 0, 500, 0, 0, left_col_bg )

    local function filterItemsBySubtype( items, subtype )
        local filteredItems = { }

        for _, item in pairs( items ) do
            local charOfSubType = INTERNAL_PARTS_NAMES_TYPES[ subtype ]
            if item[ charOfSubType ] then
                local part = getTuningPartByID( item[ charOfSubType ], case_info.tier )

                part.img = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. "_m.png"
                if case_info.tier ~= 6 or not fileExists( part.img ) then
                    part.img = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. ".png"
                end

                local pathImgForMoto = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. "_m.png"
                if part.is_moto and fileExists( pathImgForMoto ) then
                    part.img = pathImgForMoto
                end

                table.insert( filteredItems, part )
            end
        end

        for st, charOfType in ipairs( INTERNAL_PARTS_NAMES_TYPES ) do
            local partOfButtonPath = string.lower( "images/btn_type_" .. charOfType )

            if st == subtype and UI[ "btn_set_subtype_" .. st ] then
                UI[ "btn_set_subtype_" .. st ]:ibData( "texture", partOfButtonPath .. "_s.png" )
                selected_subtype = subtype
            elseif UI[ "btn_set_subtype_" .. st ] then
                UI[ "btn_set_subtype_" .. st ]:ibData( "texture", partOfButtonPath .. ".png" )
            end
        end

        return filteredItems
    end

    local case_btn_img = case_discount and "images/btn_buy_discount" or "images/btn_buy"
    local case_btn = ibCreateButton( 0, type_area:ibGetAfterY( is_tuning_case and 76 or 0 ), 0, 0, left_col_bg,
    case_btn_img .. "_i.png", case_btn_img .. "_h.png", case_btn_img .. "_h.png",
    0xFFFFFFFF, 0xFFFFFFFF, 0xBBFFFFFF )
    :ibSetRealSize( ):center_x( )

    local function isHasSubtype( items, subtype )
        for _, item in pairs( items ) do
            local charOfSubType = INTERNAL_PARTS_NAMES_TYPES[ subtype ]
            if item[ charOfSubType ] then
                return true
            end
        end
    end

    if is_tuning_case then
        local descriptionsOfSubtypes = {
            "Идеальное сочетание скорости и управления",
            "Идеально подходят для прямых заездов",
            "Созданы для затяжных заносов",
        }

        for subtype, charOfType in ipairs( INTERNAL_PARTS_NAMES_TYPES ) do
            if isHasSubtype( case_info.items, subtype ) then
                local partOfButtonPath = string.lower( "images/btn_type_" .. charOfType )

                UI[ "btn_set_subtype_" .. subtype ] = ibCreateButton( 70 + ( subtype - ( case_info.tier == 6 and 0 or 1 ) ) * 96, 0, 87, 42, type_area,
                partOfButtonPath .. ".png", partOfButtonPath .. "_h.png", partOfButtonPath .. "_s.png" )
                :ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    local filteredItems = filterItemsBySubtype( case_info.items, subtype )
                    updateCaseItems( filteredItems, is_tuning_case )

                    UI.desc_type_lbl:ibData( "text", descriptionsOfSubtypes[ subtype ] or "" )
                end )
            end
        end

        UI.desc_type_lbl = ibCreateLabel( 0, type_area:ibGetAfterY( 43 ), 420, 50, descriptionsOfSubtypes[ INTERNAL_PART_TYPE_R ], left_col_bg )
        :ibBatchData( { font = ibFonts.regular_14, align_x = "center", align_y = "center", alpha = 190 } )
    end

    local function SetCaseButtonType( btype )
        if btype == "open" then
            case_btn:ibBatchData( {
                texture       = "images/btn_open_i.png",
                texture_hover = "images/btn_open_h.png",
                texture_click = "images/btn_open_h.png",
            } )
        else
            case_btn:ibBatchData( {
                texture       = case_btn_img .. "_i.png",
                texture_hover = case_btn_img .. "_h.png",
                texture_click = case_btn_img .. "_h.png",
            } )
        end
        case_btn:ibSetRealSize( ):center_x( )
    end

    local function UpdateCost( )
        cost_lbl:ibData( "text", format_price( case_cost * buy_count ) )
        cost_img:ibData( "px", cost_lbl:ibGetAfterX( 10 ) )
        cost_area:ibData( "sx", cost_img:ibGetAfterX( ) ):center_x( )

        if old_cost_lbl then
            old_cost_lbl:ibBatchData( {
                px = cost_lbl:ibGetCenterX( ),
                text = format_price( case_info.cost * buy_count ),
            } )
            line_old_cost:ibBatchData( {
                px = old_cost_lbl:ibGetBeforeX( -2 ),
                sx = old_cost_lbl:width( ) + 4,
            } )
        end
    end
    UpdateCost( )

    local function UpdateCaseInfo( )
        if localPlayer:HasCase( case_info.type, case_info.id, case_info.tier, is_tuning_case and selected_subtype or nil ) then
            buy_count = 1
            local player_cases = localPlayer:GetCases( case_info.type )
            local count = 0

            if is_tuning_case then count = ( ( player_cases[ case_info.id ] or { })[ case_info.tier ] or { } )[ selected_subtype ] or 0
            else count = player_cases[ case_info.id ] or 0 end

            case_count:ibData( "text", count )
            btn_min:ibBatchData( { disabled = true, alpha = 0 } )
            btn_plus:ibBatchData( { disabled = true, alpha = 0 } )

            SetCaseButtonType( "open" )
        else
            case_count:ibData( "text", buy_count )
            btn_min:ibBatchData( { disabled = false, alpha = 255 } )
            btn_plus:ibBatchData( { disabled = false, alpha = 255 } )

            SetCaseButtonType( "buy" )
        end

        UpdateCost( )
    end

    UpdateCaseInfo( )
    UI.info_bg:ibTimer( UpdateCaseInfo, 250, 0 )

    local max_count = 20

    btn_min:ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )

        buy_count = ( buy_count - 2 ) % max_count + 1
        case_count:ibData( "text", buy_count )
        UpdateCost( )
    end, false )

    btn_plus:ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )

        buy_count = buy_count % max_count + 1
        case_count:ibData( "text", buy_count )
        UpdateCost( )
    end, false )

    case_btn:ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        
        if SEND_DATA_TIMEOUT > getTickCount( ) then return end
        SEND_DATA_TIMEOUT = getTickCount( ) + 500

        if localPlayer:HasCase( case_info.type, case_info.id, case_info.tier, is_tuning_case and selected_subtype or nil ) then

            local open_event = is_tuning_case and "PlayerWantOpenTuningCase" or "PlayerWantOpenVinylCase"
            triggerServerEvent( open_event, resourceRoot, case_info.id, selected_subtype )

            ibClick( )
        else
            -- if case_info.cost_is_soft then
            if not case_info.cost_is_soft then
            --     if not localPlayer:HasMoney( case_cost * buy_count ) then
            --         localPlayer:ShowError( "Недостаточно средств" )
            --         return
            --     end
            -- else
                if not localPlayer:HasDonate( case_cost * buy_count ) then
                    localPlayer:ShowError( "Недостаточно средств" )
                    return
                end
            end

            local buy_event = is_tuning_case and "PlayerWantBuyTuningCase" or "PlayerWantBuyVinylCase"
            triggerServerEvent( buy_event, resourceRoot, case_info.id, buy_count, selected_subtype )

			if case_info.cost_is_soft then
				if localPlayer:HasMoney( case_cost * buy_count ) then
					ibBuyProductSound( 1 )
				end
            else
                ibBuyDonateSound( 1 )
            end
        end
    end )

    ibCreateImage( left_col_bg:ibData( "sx" ) - 1, 0, 1, left_col_bg:ibData( "sy" ), _, left_col_bg, 0x1Affffff )

    --------------------------------------------------------------------------------------------------------------------

    local right_col_bg = ibCreateArea( left_col_bg:ibGetAfterX( ), head_bg:ibGetAfterY( ), 
        UI.info_bg:ibData( "sx" ) - left_col_bg:ibData( "sx" ), left_col_bg:ibData( "sy" ), UI.info_bg )

    local balance_bg = ibCreateImage( 0, 0, right_col_bg:ibData( "sx" ), 60, _, right_col_bg, ibApplyAlpha( 0xFF4f647b, 75 ) )

    local balance_text_lbl = ibCreateLabel( 30, 40, 0, 0, "Ваш баланс:", balance_bg )
        :ibBatchData( { font = ibFonts.regular_18, align_y = "bottom" } )
    local balance_lbl = ibCreateLabel( balance_text_lbl:ibGetAfterX( 8 ), 40, 0, 0, 
        format_price( case_info.cost_is_soft and localPlayer:GetMoney( ) or localPlayer:GetDonate( ) ), balance_bg )
        :ibBatchData( { font = ibFonts.bold_18, align_y = "bottom" } )

    local balance_img = ibCreateImage( balance_lbl:ibGetAfterX( 10 ), 0, 24, 24, 
        ":nrp_shared/img/".. ( case_info.cost_is_soft and "" or "hard_" ) .."money_icon.png", balance_bg )
        :center_y( -4 )
    balance_img:ibTimer( function( )
        balance_lbl:ibData( "text", format_price( case_info.cost_is_soft and localPlayer:GetMoney( ) or localPlayer:GetDonate( ) ) )
        balance_img:ibData( "px", balance_lbl:ibGetAfterX( 10 ) )
    end, 1000, 0 )

    local balance_btn = ibCreateButton( balance_bg:ibGetAfterX( -30 - 126 ), 0, 126, 34, balance_bg,
        "images/btn_balance_i.png", "images/btn_balance_h.png", "images/btn_balance_h.png",
        0xFFFFFFFF, 0xFFFFFFFF, 0xBBFFFFFF )
        :center_y( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "tuning_cases_case_menu" )
            ShowUICasesList( false )
        end )

    ibCreateImage( 0, balance_bg:ibData( "sy" ) - 1, balance_bg:ibData( "sx" ), 1, _, balance_bg, 0x1Affffff )

    --------------------------------------------------------------------------------------------------------------------

    UI.items_area = ibCreateArea( 0, balance_bg:ibData( "sy" ), right_col_bg:ibData( "sx" ),
        right_col_bg:ibData( "sy" ) - balance_bg:ibData( "sy" ), right_col_bg )

    ibCreateLabel( 0, 26, UI.items_area:ibData( "sx" ), 0, "Содержимое кейса:", UI.items_area )
        :ibBatchData( { font = ibFonts.bold_18, align_x = "center" } )

    UI.desc_lbl = ibCreateLabel( 0, 55, 415, 50, case_info.description, UI.items_area )
        :ibBatchData( { font = ibFonts.regular_14, align_y = "center", wordbreak = true, alpha = 190 } )

    local filteredItems = case_info.items
    if is_tuning_case then
        local available_cases_subtype
        if case_info.tier == 6 then
            available_cases_subtype = 1
        else
            for subtype, charOfType in ipairs( INTERNAL_PARTS_NAMES_TYPES ) do
                if localPlayer:HasCase( case_info.type, case_info.id, case_info.tier, subtype ) then
                    available_cases_subtype = subtype
                    break
                end
            end
        end

        filteredItems = filterItemsBySubtype( case_info.items, available_cases_subtype or INTERNAL_PART_TYPE_R )
    end

    updateCaseItems( filteredItems, is_tuning_case )
end

function updateCaseItems( items, is_tuning_case )
    if not next( items ) then return end
    if isElement( UI.items_pane ) then
        UI.items_pane:destroy( )
        UI.items_scroll_v:destroy( )
    end

    local items_py = 113
    UI.items_pane, UI.items_scroll_v = ibCreateScrollpane( 0, items_py, UI.items_area:ibData( "sx" ),
            UI.items_area:ibData( "sy" ) - items_py, UI.items_area, { scroll_px = -20, bg_color = 0x00FFFFFF } )
    UI.items_scroll_v:ibSetStyle( "slim_nobg" )

    local cols_count = is_tuning_case and 4 or 3
    local sx = is_tuning_case and 96 or 142
    local sy = sx
    local gap = is_tuning_case and 12 or 19
    local ox = ( UI.items_area:ibData( "sx" ) - ( ( sx + gap ) * cols_count - gap ) ) / 2

    for j, item in pairs( items ) do
        local px = ox + ( sx + gap ) * ( ( j - 1 ) % cols_count )
        local py = ( sy + gap ) * math.floor( ( j - 1 ) / cols_count )

        CreateCaseItem( item, px, py, UI.items_pane, is_tuning_case )
    end

    UI.desc_lbl:ibBatchData( {
        px = ox + 4,
        sx = ( sx + gap ) * cols_count - gap,
    } )

    UI.items_pane:AdaptHeightToContents( )
    UI.items_scroll_v:UpdateScrollbarVisibility( UI.items_pane )
end

function CreateCaseItem( item, pos_x, pos_y, bg, is_tuning_case )
    local bg_texture = is_tuning_case and "images/item_bg.png" or "images/item_big_bg.png"
    local item_bg = ibCreateImage( pos_x, pos_y, 96, 96, bg_texture, bg, is_tuning_case and CONST_RARE_COLORS.tuning[ item.category ] or nil )
        :ibSetRealSize( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 350 )
    local bg_hover_texture = is_tuning_case and "images/item_bg_hover.png" or "images/item_big_bg_hover.png"
    local item_bg_hover = ibCreateImage( 0, 0, 96, 96, bg_hover_texture, item_bg )
        :ibSetRealSize( ):ibData( "alpha", 0 )

    ibCreateImage( 0, 0, 0, 0, item.img, item_bg )
        :ibSetRealSize( ):ibSetInBoundSize( is_tuning_case and 90 or 120 ):center()

    local rare_texture = is_tuning_case and "images/rare.png" or "images/rare_big.png"
    local rare_px = is_tuning_case and -9 or -11
    local rare_color = CONST_RARE_COLORS[ is_tuning_case and "tuning" or "vinyl" ][ is_tuning_case and item.category or ( item.rare or 1 ) ]
    ibCreateImage( 0, rare_px, 65, 29, rare_texture, item_bg, rare_color )
        :ibSetRealSize( ):center_x( 1 )

    ibCreateArea( 3, 3, item_bg:ibData( "sx" ) - 6, item_bg:ibData( "sy" ) - 6, item_bg )
        :ibOnHover( function( )
            item_bg_hover:ibAlphaTo( 255, 350 )

            if is_tuning_case then
                CreatePartHint( item )
            end
        end )
        :ibOnLeave( function( )
            item_bg_hover:ibAlphaTo( 0, 350 )

            if is_tuning_case then
                DestroyPartHint( )
            end
        end )
end

function CreatePartHint( part )
    DestroyPartHint( )

    local cx, cy = getCursorPosition( )
    cx, cy = cx * _SCREEN_X, cy * _SCREEN_Y

    local hint_sx, hint_sy = 200, 117
    local bg = ibCreateImage( cx + 10, cy + 10, hint_sx, hint_sy, ":nrp_tuning_shop/img/bg_hint.png", _, 0xffffffff )
        :ibBatchData( { alpha = 0, disabled = true } )
        :ibAlphaTo( 255, 250, "OutQuad" )
        :ibOnRender( function ( )
            local cx, cy = getCursorPosition( )
            cx, cy = cx * _SCREEN_X, cy * _SCREEN_Y
            UI.part_hint:ibBatchData( { px = cx + 10, py = cy + 10 } )
        end )

    ibCreateLabel( 20, 10, 0, 0, PARTS_NAMES[ part.type ] .. " - " .. part.name .. " (" .. PARTS_TIER_NAMES[ part.category ] .. ")", bg )
    :ibBatchData( { font = ibFonts.bold_13, color = 0xffffffff } )

    local value_positions = {
        { 42, 43 },
        { 42, 65 },
        { 42, 87 },
        { 130, 53 },
        { 130, 76 },
    }

    local values = {
        part.controllability, part.clutch, part.slip, part.speed, part.acceleration
    }

    for i, v in pairs( values ) do
        local width = dxGetTextWidth( math.abs( v ), 1, ibFonts.regular_12 )

        local px, py = unpack( value_positions[ i ] )
        local is_changed = v ~= 0
        ibCreateLabel( px + 4, py, 0, 0, math.abs( v ), bg )
            :ibBatchData( { font = ibFonts.bold_10, color = v < 0 and 0xffff3a3a or v > 0 and 0xff00ff63 or 0xffffffff } )

        if is_changed then
            local icon_texture = v < 0 and ":nrp_tuning_shop/img/icon_arrowdown_red.png" or v > 0 and ":nrp_tuning_shop/img/icon_arrowup_green.png"
            local icon_px, icon_py = px + 5 + width, py + 1
            local icon_sx, icon_sy = 27 * 0.6, 24 * 0.6
            ibCreateImage( icon_px, icon_py, icon_sx, icon_sy, icon_texture, bg )
        end
    end

    UI.part_hint = bg
end

function DestroyPartHint( )
    if isElement( UI.part_hint ) then destroyElement( UI.part_hint ) end
end