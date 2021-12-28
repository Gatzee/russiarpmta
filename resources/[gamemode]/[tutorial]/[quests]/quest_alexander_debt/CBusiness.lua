local UI

local BUSINESS_CONF = {
    business_id = "shop_1",
    name = "Магазин",
    cost = 5000000,
    balance = 100000,
    daily_income = 120699,
    daily_business_coins = 56,
    material_cost = 1000,
    weekly_cost = 100000,
    max_balance = 580000,
    task = "Данный бизнес занимается продажей продуктов питания",
    task_short = "Продажа прод. питания",
    max_weekly_income = 844891,
}

function ShowBusinessUI( state )
    if state then
        ShowBusinessUI( false )

        local conf = BUSINESS_CONF

        UI = { }

        local x, y = guiGetScreenSize()

        UI.black_bg = ibCreateBackground( _, _, true ):ibData( "alpha", 0 )
        local sx, sy = 800, 580
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        UI.bg = ibCreateImage( px, py, sx, sy, ":nrp_businesses/img/bg_main.png", UI.black_bg )

        local TABS = { "Управление", "Правила ведения" }
        local TABS_ELEMENT_NAMES = { "tab_controls", "tab_rules" }
        local TABS_AREAS = { }

        for i, v in pairs( TABS_ELEMENT_NAMES ) do
            UI[ v ] = ibCreateArea( 0, 0, sx, sy, UI.bg )
            table.insert( TABS_AREAS, UI[ v ] )
        end

        local current_tab

        local row_py = 127
        local function SwitchTabTo( i )
            current_tab = i
            local area = UI[ "tab_area_" .. i ]
            local lbl = UI[ "tab_lbl_" .. i ]
            local lbl_px = area:ibData( "px" )

            for n, v in pairs( TABS ) do
                local tab_area = TABS_AREAS[ n ]
                local is_current_tab = current_tab == n
                UI[ "tab_lbl_" .. n ]:ibData( "color", is_current_tab and 0xffffffff or 0x88ffffff )
                if is_current_tab then
                    tab_area:ibData( "py", -20 )
                    tab_area:ibMoveTo( 0, 0, 250 )
                    tab_area:ibAlphaTo( 255, 100 )
                    tab_area:ibData( "disabled", false )
                    tab_area:ibData( "priority", 0 )
                else
                    tab_area:ibMoveTo( 0, 20, 250 )
                    tab_area:ibAlphaTo( 0, 100 )
                    tab_area:ibData( "disabled", true )
                    tab_area:ibData( "priority", -1 )
                end
            end

            if isElement( UI[ "tab_needle" ] ) then
                UI[ "tab_needle" ]:ibMoveTo( lbl_px, row_py, 100 )
                UI[ "tab_needle" ]:ibResizeTo( lbl:width( ), 4, 100 )
            else
                UI[ "tab_needle" ] = ibCreateImage( lbl_px, row_py, lbl:width( ), 4, _, UI.bg, 0xffff9759 )
            end
        end

        local npx, npy = 30, 97
        for i, v in pairs( TABS ) do
            local bg = ibCreateArea( npx, npy, 0, 0, UI.bg )
            local lbl = ibCreateLabel( 0, 0, 0, 0, v, bg ):ibData( "font", ibFonts.bold_10 )

            UI[ "tab_area_" .. i ] = bg
            UI[ "tab_lbl_" .. i ] = lbl

            local btn = ibCreateButton( npx, 85, lbl:width( ), 38, UI.bg, nil, nil, nil, 0, 0, 0 )
            btn:ibOnClick( function( key, state )
                if key ~= "left" or state ~= "down" then return end
                if current_tab == i then return end
                ibClick( )
                SwitchTabTo( i )
            end )   

            npx = npx + lbl:width( ) + 30
        end

        SwitchTabTo( 1 )

        --------------------------
        -- Вкладка управления

		UI.btn_gov_sell = ibCreateButton( 538, 96, 242, 24, UI.tab_controls, ":nrp_businesses/img/btn_gov_sell", true )
			:ibOnClick( function( button, state ) 
                if button ~= "left" or state ~= "up" then return end
                localPlayer:InfoWindow( "Нажми 'Вывод с лицевого счета' чтобы забрать деньги" )
			end)

        local image = split( conf.business_id, "_" )[ 1 ]
        ibCreateImage( 92 - 128 / 2, 235 - 128 / 2, 128, 128, ":nrp_businesses/img/icons/128x128/" .. image .. ".png", UI.tab_controls )
        local lbl_name = ibCreateLabel( 181, 204, 0, 0, conf.name or "Пиздатый бизнес", UI.tab_controls ):ibBatchData( { font = ibFonts.bold_14 } )
        ibCreateLabel( 181 + lbl_name:width( ) + 10, 207, 0, 0, "(" .. ( conf.task_short or "Продажа товара" ) .. ")", UI.tab_controls ):ibBatchData( { font = ibFonts.bold_12, color = 0xaaffffff } )
        ibCreateLabel( 181, 240, 0, 0, "Лицевой счёт:", UI.tab_controls ):ibBatchData( { font = ibFonts.regular_12, color = 0xffffd892 } )

        RefreshBalance( conf.balance or 0 )

        -- Продукция
        ibCreateLabel( 30, 354, 0, 0, "Ваша продукция:", UI.tab_controls ):ibBatchData( { font = ibFonts.regular_10, color = 0xffffffff } )
        RefreshMaterials( conf.materials or 0 )

        -- Покупка сырья
        ibCreateLabel( 30, 428, 0, 0, "Покупка продукции:", UI.tab_controls ):ibBatchData( { font = ibFonts.regular_11, color = 0xffffffff } )

        local npx, npy = 181, 422
        for i, v in pairs( { 58, 107, "max" } ) do
            local file = ":nrp_businesses/img/btn_add_" .. v .. ".png"
            local file_hover = ":nrp_businesses/img/btn_add_" .. v .. "_hover.png"

            UI[ "btn_add_texture_" .. v ] = dxCreateTexture( file )
            local bsx, bsy = dxGetMaterialSize( UI[ "btn_add_texture_" .. v ] )
            UI[ "btn_add_" .. v ] = ibCreateButton(    npx, npy, bsx, bsy, UI.tab_controls,
                                                                file, file_hover, file_hover,
                                                                0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            npx = npx + bsx + 10

            UI[ "btn_add_" .. v ]:ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                localPlayer:InfoWindow( "Нажми 'Вывод с лицевого счета' чтобы забрать деньги" )
            end, false )
        end

        -- Снятие со счёта
        UI.btn_withdraw = ibCreateButton( 520, 231, 250, 34, UI.tab_controls, "img/btn_withdraw.png", "img/btn_withdraw_hover.png", "img/btn_withdraw_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "alexander_debt_step_5", localPlayer )
            end )

        -- Пополнение счёта
        UI.btn_add = ibCreateButton(   520, 187, 250, 34, UI.tab_controls,
                                                ":nrp_businesses/img/btn_add.png", ":nrp_businesses/img/btn_add.png", ":nrp_businesses/img/btn_add.png",
                                                0xFFFFFFFF, 0xFFEEEEEE, 0xFFCCCCCC )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                localPlayer:InfoWindow( "Нажми 'Вывод с лицевого счета' чтобы забрать деньги" )
            end )

        --"Максимальный доход в неделю N"
        local bg = ibCreateImage( sx / 2 - 740 / 2, sy - 50, 740, 30, ":nrp_businesses/img/stroke.png", UI.tab_controls )
        local lbl = ibCreateLabel( 10, 0, bg:width( ), bg:height( ), "Максимальный доход в неделю: ", bg ):ibBatchData( { font = ibFonts.regular_10, color = 0xfff6d190, align_y = "center" } )
        local lbl_amount = ibCreateLabel( 10 + lbl:width( ) + 5, 0, 0, bg:height( ), format_price( conf.max_weekly_income ), bg ):ibBatchData( { font = ibFonts.bold_10, color = 0xffffffff, align_y = "center" } )
        ibCreateImage( 10 + lbl:width( ) + 5 + lbl_amount:width( ) + 5 , 4, 22, 22, ":nrp_shared/img/money_icon.png", bg )

        --"Расходы на содержание бизнеса в неделю N"
        local bg = ibCreateImage( sx / 2 - 740 / 2, sy - 90, 740, 30, ":nrp_businesses/img/stroke.png", UI.tab_controls )
        local lbl = ibCreateLabel( 10, 0, bg:width( ), bg:height( ), "Расходы на содержание бизнеса в неделю: ", bg ):ibBatchData( { font = ibFonts.regular_10, color = 0xfff6d190, align_y = "center" } )
        local lbl_amount = ibCreateLabel( 10 + lbl:width( ) + 5, 0, 0, bg:height( ), format_price( conf.weekly_cost ), bg ):ibBatchData( { font = ibFonts.bold_10, color = 0xffffffff, align_y = "center" } )
        ibCreateImage( 10 + lbl:width( ) + 5 + lbl_amount:width( ) + 5 , 4, 22, 22, ":nrp_shared/img/money_icon.png", bg )
        ---------------------------
        -- Вкладка правил
        ibCreateImage( 0, 0, sx, sy, ":nrp_businesses/img/rules.png", UI.tab_rules )

        -- Запускаем анимацию
        UI.black_bg:ibAlphaTo( 255, 300 )

        showCursor( true )
        
    else
        DestroyTableElements( UI )
        UI = nil
        showCursor( false )
    end
end

function RefreshBalance( balance )
    if not UI then return end
    local elements = { UI.lbl_balance, UI.icon_balance, UI.lbl_balance_desc, UI.lbl_balance_2, UI.icon_balance_2 }
    for i, v in pairs( elements ) do
        if isElement( v ) then destroyElement( v ) end
    end

    UI.lbl_balance = ibCreateLabel( 300, 240, 0, 0, format_price( balance ), UI.tab_controls ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_12 } )
    UI.icon_balance = ibCreateImage( 300 + UI.lbl_balance:width( ) + 8, 238, 24, 24, ":nrp_shared/img/money_icon.png", UI.tab_controls )

    UI.icon_balance_2 = ibCreateImage( 770-24, 97-4, 24, 24, ":nrp_shared/img/money_icon.png", UI.tab_rules )
    UI.lbl_balance_2 = ibCreateLabel( 770-24-10, 97, 0, 0, format_price( balance ), UI.tab_rules ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_10, align_x = "right" } )
    UI.lbl_balance_desc = ibCreateLabel( 770-24-10-UI.lbl_balance_2:width( )-10, 97, 0, 0, "Лицевой счёт:", UI.tab_rules ):ibBatchData( { color = 0xffffdf93, font = ibFonts.bold_10, align_x = "right" } )

    CURRENT_BALANCE = balance
end

function RefreshMaterials( materials, max_materials )
    if not UI then return end
    local max_materials = max_materials or 151

    local progress = math.min( 1, ( materials / max_materials ) )
    local width = 740 * progress
    local text = ( materials or 0 ) .. "#cccccc / " .. max_materials

    if isElement( UI.lbl_materials ) then
        
        UI.fg_progress:ibResizeTo( width, 14, 2000, "InOutQuad" )
        UI.lbl_materials:ibInterpolate( 
            function( self )
                local progress = UI.fg_progress:width( ) / 740
                local text = math.ceil( max_materials * progress ) .. "#cccccc / " .. max_materials
                UI.lbl_materials:ibData( "text", text )
            end
        , 2000, "Linear", 
            function( self )
                UI.lbl_materials:ibData( "text", text )
            end 
        )
    else
        UI.lbl_materials = ibCreateLabel( 770, 354, 0, 0, text, UI.tab_controls ):ibBatchData( { color = 0xffffffff, font = ibFonts.regular_10, align_x = "right", colored = true } )
        UI.bg_progress = ibCreateImage( 30, 378, 740, 14, _, UI.tab_controls, 0x77000000 )
        UI.fg_progress = ibCreateImage( 30, 378, width, 14, _, UI.tab_controls, 0xff00b4ff )
    end
end