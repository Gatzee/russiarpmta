local UI_elements

function isBusinessWindowActive( )
    local _, element = next( UI_elements or { } )
    return isElement( element )
end

function ShowBusinessUI_handler( state, conf )
    if state then
        --iprint( "Open interface of", conf.business_id )

        ibInterfaceSound()
        ShowBusinessUI_handler( false )

        ibUseRealFonts( true )

        UI_elements = { }

        local x, y = guiGetScreenSize()

        UI_elements.black_bg = ibCreateBackground( _, ShowBusinessUI_handler, true, true ):ibData( "alpha", 0 )
        local sx, sy = 800, 580
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg_main.png", UI_elements.black_bg )
        UI_elements.bg = ibCreateRenderTarget( 0, 0, sx, sy, UI_elements.bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 26, 24, 24, 24, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "priority", 10 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessUI_handler( false )
        end, false )

        local TABS = { "Управление", "Правила ведения" }
        local TABS_ELEMENT_NAMES = { "tab_controls", "tab_rules" }
        local TABS_AREAS = { }

        for i, v in pairs( TABS_ELEMENT_NAMES ) do
            UI_elements[ v ] = ibCreateArea( 0, 0, sx, sy, UI_elements.bg )
            table.insert( TABS_AREAS, UI_elements[ v ] )
        end

        local current_tab

        local row_py = 127
        local function SwitchTabTo( i )
            current_tab = i
            local area = UI_elements[ "tab_area_" .. i ]
            local lbl = UI_elements[ "tab_lbl_" .. i ]
            local lbl_px = area:ibData( "px" )

            for n, v in pairs( TABS ) do
                local tab_area = TABS_AREAS[ n ]
                local is_current_tab = current_tab == n
                UI_elements[ "tab_lbl_" .. n ]:ibData( "color", is_current_tab and 0xffffffff or 0x88ffffff )
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

            if isElement( UI_elements[ "tab_needle" ] ) then
                UI_elements[ "tab_needle" ]:ibMoveTo( lbl_px, row_py, 100 )
                UI_elements[ "tab_needle" ]:ibResizeTo( lbl:width( ), 4, 100 )
            else
                UI_elements[ "tab_needle" ] = ibCreateImage( lbl_px, row_py, lbl:width( ), 4, _, UI_elements.bg, 0xffff9759 )
            end
        end

        local npx, npy = 30, 97
        for i, v in pairs( TABS ) do
            local bg = ibCreateArea( npx, npy, 0, 0, UI_elements.bg )
            local lbl = ibCreateLabel( 0, 0, 0, 0, v, bg ):ibData( "font", ibFonts.bold_14 )

            UI_elements[ "tab_area_" .. i ] = bg
            UI_elements[ "tab_lbl_" .. i ] = lbl

            local btn = ibCreateButton( npx, 85, lbl:width( ), 38, UI_elements.bg, nil, nil, nil, 0, 0, 0 )
            addEventHandler( "ibOnElementMouseClick", btn, function( key, state )
                if key ~= "left" or state ~= "down" then return end
                if current_tab == i then return end
                ibClick( )
                SwitchTabTo( i )
            end, false )   

            npx = npx + lbl:width( ) + 30
        end

        SwitchTabTo( 1 )

        --------------------------
        -- Вкладка управления

		UI_elements.btn_gov_sell = ibCreateButton( 538, 96, 242, 24, UI_elements.tab_controls, "img/btn_gov_sell", true )
			:ibOnClick( function( button, state ) 
				if button ~= "left" or state ~= "up" then return end

                if UI_elements.confirmation then UI_elements.confirmation:destroy() end

				UI_elements.confirmation = ibConfirm({
					title = "ПРОДАЖА БИЗНЕСА",
					text = "Вы действительно хотите продать этот\nбизнес за ".. format_price( math.floor( conf.cost / 2 ) ) .." руб.?" ,
					fn = function( self )
						ShowBusinessUI_handler( false )
						triggerServerEvent( "onBusinessGovSellRequest", resourceRoot, conf.business_id )
						self:destroy()
                        end,
                    escape_close = true,
                } )
			end)

        local image = conf.icon and split( conf.business_id, "_" )[ 1 ] or string.gsub( conf.business_id, "_%d+$", "" )

        ibCreateImage( 0, 128, 800, 155, "img/bg_main_info.png", UI_elements.tab_controls )

        ibCreateImage( 92 - 110 / 2, 206 - 110 / 2, 110, 110, "img/icons/128x128/" .. image .. ".png", UI_elements.tab_controls )
        ibCreateLabel( 181, 168, 0, 0, "Наименование бизнеса:", UI_elements.tab_controls ):ibBatchData( { font = ibFonts.regular_12, alpha = 255 * 0.5 } )
        ibCreateLabel( 181, 183, 0, 0, conf.name or "Пиздатый бизнес", UI_elements.tab_controls ):ibBatchData( { font = ibFonts.regular_24 } )
        ibCreateLabel( 181, 220, 0, 0, "(" .. ( conf.task_short or "Продажа товара" ) .. ")", UI_elements.tab_controls ):ibBatchData( { font = ibFonts.regular_18, color = 0xaaffffff } )

        -- ПОДНЯТЬ УРОВЕНЬ
        UI_elements.btn_add = ibCreateButton(   601, 163, 170, 35, UI_elements.tab_controls,
                                                "img/btn_levelup.png", "img/btn_levelup_h.png", "img/btn_levelup_h.png",
                                                0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibAttachTooltip( "Прибыль будет увеличена в 1,5 раза. \nТакже появится возможность получать откаты: \nизменение соц. рейтинга + опыт клана или фракции \n(в зависимости от принадлежности)" )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            if conf.succes_value ~= MAX_SUCCES_VALUE then
                localPlayer:ErrorWindow( "Необходимо заполнить шкалу успешности" )
                return
            end

            if UI_elements.confirmation then UI_elements.confirmation:destroy() end

            UI_elements.confirmation = ibConfirm({
                title = "ПОДТВЕРЖДЕНИЕ",
                text = "Вы действительно хотите \nподнять уровень этого бизнеса за ",
                cost = conf.default_cost * ( conf.level + 1 ),
                cost_is_soft = true,
                fn = function( self )
                    triggerServerEvent( "onBusinessLevelUpRequest", resourceRoot, conf.business_id )
                    self:destroy()
                end,
                escape_close = true,
            } )
        end, false )

        if conf.level == MAX_BUSINESS_LEVEL then
            UI_elements.btn_add:ibData( "disabled", true ):ibData( "alpha", 100 )
        end

        -- Успешность
        RefreshSuccesLevel( conf.level, conf.succes_value )

        ibCreateLabel( 34, 277, 0, 0, "Лицевой счёт:", UI_elements.tab_controls ):ibBatchData( { font = ibFonts.regular_16, color = 0xffffd892 } )
        RefreshBalance( conf.balance or 0 )

        -- ПОЛУЧИТЬ ОТКАТ
        UI_elements.btn_add = ibCreateButton(   30, 308, 160, 35, UI_elements.tab_controls,
                                                "img/btn_take_bribe.png", "img/btn_take_bribe_h.png", "img/btn_take_bribe_h.png",
                                                0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            if conf.level < BRIBE_BUSINESS_LEVEL then
                localPlayer:ErrorWindow( "Необходимо прокачать бизнес до 2 уровня" )
                return
            end

            ShowTakeBribeOverlay( UI_elements.bg, conf )
        end, false )

        -- Пополнение счёта
        UI_elements.btn_add = ibCreateButton(   520, 276, 250, 34, UI_elements.tab_controls,
                                                "img/btn_add.png", "img/btn_add.png", "img/btn_add.png",
                                                0xFFFFFFFF, 0xFFEEEEEE, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            if UI_elements.input then UI_elements.input:destroy() end
            UI_elements.input = ibInput(
                {
                    title = "Пополнение лицевого счёта", 
                    text = "",
                    edit_text = "Введите сумму пополнения",
                    btn_text = "ПОПОЛНИТЬ",
                    fn = function( self, text )
                        local amount = tonumber( text )
                        if not amount or amount ~= math.floor( amount ) then
                            localPlayer:ErrorWindow( "Неверная сумма для пополнения!" )
                            return
                        end

                        triggerServerEvent( "onBusinessAddMoneyRequest", resourceRoot, conf.business_id, amount )
                        self:destroy()
                    end
                }
            )

            local max_sum = math.min( localPlayer:GetMoney( ), conf.max_balance - CURRENT_BALANCE )
            local bg = UI_elements.input.elements.bg
            
            local lbl_balance = ibCreateLabel( 38, 105, 0, 0, "Ваш текущий баланс:", bg ):ibBatchData( { color = 0xffffdf93, font = ibFonts.regular_12 } )
            local lbl_amount = ibCreateLabel( 38 + lbl_balance:width( ) + 10, 105, 0, 0, format_price( CURRENT_BALANCE ), bg ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_12 } )
            ibCreateImage( 38 + lbl_balance:width( ) + 10 + lbl_amount:width( ) + 10, 103, 24, 24, ":nrp_shared/img/money_icon.png", bg )
            ibCreateLabel( UI_elements.input.sx - 54, 166, 0, 0, "Макс. сумма - " .. format_price( max_sum ), bg, 0xFFBBBBBB ):ibBatchData( { font = ibFonts.regular_10, align_x = "right" } )
        end, false )

        -- Снятие со счёта
        UI_elements.btn_withdraw = ibCreateButton(  520, 320, 250, 34, UI_elements.tab_controls,
                                                    "img/btn_withdraw.png", "img/btn_withdraw_hover.png", "img/btn_withdraw_hover.png",
                                                    0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            if UI_elements.input then UI_elements.input:destroy() end
            UI_elements.input = ibInput(
                {
                    title = "Вывод с лицевого счёта", 
                    text = "",
                    edit_text = "Введите сумму вывода",
                    btn_text = "ВЫВОД",
                    fn = function( self, text )
                        local amount = tonumber( text )
                        if not amount or amount ~= math.floor( amount ) then
                            localPlayer:ErrorWindow( "Неверная сумма для вывода!" )
                            return
                        end

                        triggerServerEvent( "onBusinessTakeMoneyRequest", resourceRoot, conf.business_id, amount )
                        self:destroy()
                    end
                }
            )

            local max_sum = CURRENT_BALANCE --conf.max_balance - CURRENT_BALANCE
            local bg = UI_elements.input.elements.bg
            
            local lbl_balance = ibCreateLabel( 38, 105, 0, 0, "Ваш текущий баланс:", bg ):ibBatchData( { color = 0xffffdf93, font = ibFonts.regular_12 } )
            local lbl_amount = ibCreateLabel( 38 + lbl_balance:width( ) + 10, 105, 0, 0, format_price( CURRENT_BALANCE ), bg ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_12 } )
            ibCreateImage( 38 + lbl_balance:width( ) + 10 + lbl_amount:width( ) + 10, 103, 24, 24, ":nrp_shared/img/money_icon.png", bg )
            ibCreateLabel( UI_elements.input.sx - 54, 166, 0, 0, "Макс. сумма - " .. format_price( max_sum ), bg, 0xFFBBBBBB ):ibBatchData( { font = ibFonts.regular_10, align_x = "right" } )
        end, false )

        ibCreateImage( 30, 365, 740, 1, _, UI_elements.tab_controls, ibApplyAlpha( COLOR_WHITE, 10 ) )

        -- Продукция
        ibCreateLabel( 30, 378, 0, 0, "Ваша продукция:", UI_elements.tab_controls ):ibBatchData( { font = ibFonts.regular_12, color = 0xffffffff } )
        RefreshMaterials( conf.materials or 0 )

        -- Покупка сырья
        ibCreateLabel( 30, 434, 0, 0, "Покупка продукции:", UI_elements.tab_controls ):ibBatchData( { font = ibFonts.regular_14, color = 0xffffffff } )

        local npx, npy = 181, 430
        for i, v in pairs( { 58, 107, "max" } ) do
            local file = "img/btn_add_" .. v .. ".png"
            local file_hover = "img/btn_add_" .. v .. "_hover.png"

            UI_elements[ "btn_add_texture_" .. v ] = dxCreateTexture( file )
            local bsx, bsy = dxGetMaterialSize( UI_elements[ "btn_add_texture_" .. v ] )
            UI_elements[ "btn_add_" .. v ] = ibCreateButton(    npx, npy, bsx, bsy, UI_elements.tab_controls,
                                                                file, file_hover, file_hover,
                                                                0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "onBusinessBuyMaterialsAskForCost", resourceRoot, conf.business_id, v )
                -- onBusinessBuyMaterialsAskForCost
                --triggerServerEvent( "onBusinessBuyMaterialsRequest", resourceRoot, conf.business_id, v )
            end, false )
            npx = npx + bsx + 10
        end

        --"Максимальный доход в неделю N"
        local bg = ibCreateImage( sx / 2 - 740 / 2, sy - 50, 740, 30, "img/stroke.png", UI_elements.tab_controls )
        local lbl = ibCreateLabel( 10, 0, bg:width( ), bg:height( ), "Максимальный доход в неделю: ", bg ):ibBatchData( { font = ibFonts.regular_14, color = 0xfff6d190, align_y = "center" } )
        local lbl_amount = ibCreateLabel( 10 + lbl:width( ) + 5, 0, 0, bg:height( ), format_price( conf.max_weekly_income ), bg ):ibBatchData( { font = ibFonts.bold_14, color = 0xffffffff, align_y = "center" } )
        ibCreateImage( 10 + lbl:width( ) + 5 + lbl_amount:width( ) + 5 , 4, 22, 22, ":nrp_shared/img/money_icon.png", bg )

        --"Расходы на содержание бизнеса в неделю N"
        local bg = ibCreateImage( sx / 2 - 740 / 2, sy - 90, 740, 30, "img/stroke.png", UI_elements.tab_controls )
        local lbl = ibCreateLabel( 10, 0, bg:width( ), bg:height( ), "Расходы на содержание бизнеса в неделю: ", bg ):ibBatchData( { font = ibFonts.regular_14, color = 0xfff6d190, align_y = "center" } )
        local lbl_amount = ibCreateLabel( 10 + lbl:width( ) + 5, 0, 0, bg:height( ), format_price( conf.weekly_cost ), bg ):ibBatchData( { font = ibFonts.bold_14, color = 0xffffffff, align_y = "center" } )
        ibCreateImage( 10 + lbl:width( ) + 5 + lbl_amount:width( ) + 5 , 4, 22, 22, ":nrp_shared/img/money_icon.png", bg )
        ---------------------------
        -- Вкладка правил
        ibCreateImage( 0, 0, sx, sy, "img/rules.png", UI_elements.tab_rules )

        -- Запускаем анимацию
        UI_elements.black_bg:ibAlphaTo( 255, 300 )

        showCursor( true )
    else
        if isElement( UI_elements and UI_elements.black_bg ) then
            destroyElement( UI_elements.black_bg )
        end
        UI_elements = nil
        showCursor( false )
        ibUseRealFonts( false )
    end
end
addEvent( "ShowBusinessUI", true )
addEventHandler( "ShowBusinessUI", root, ShowBusinessUI_handler )

function ShowTakeBribeOverlay( parent, conf )
    local header_sy = 72

    if isElement( BG_OVERLAY ) then
        BG_OVERLAY
            :ibMoveTo( _, BG_OVERLAY:height( ) + header_sy, 200 )
            :ibTimer( destroyElement, 200, 1 )
    end
    if not parent then return end

    ibOverlaySound( )

    BG_OVERLAY = ibCreateImage( 0, parent:height( ), parent:width( ), parent:height( ) - header_sy, _, parent, ibApplyAlpha( 0xff23303f, 95 ) )
        :ibData( "priority", 2 )
        :ibMoveTo( 0, header_sy, 250 )

    local function format_social_rating( value )
        return value > 0 and ( "+ " .. value ) or ( "- " .. -value )
    end

    if not localPlayer:IsInFaction() and not localPlayer:IsInClan() then
        ibCreateImage( 0, 0, 0, 0, "img/bribe/bg_choice.png", BG_OVERLAY ):ibSetRealSize()
        ibCreateLabel( 224, 361, 0, 0, format_social_rating( BRIBE_ITEMS.choice[ 1 ].social_rating ), BG_OVERLAY, _, _, _, "center", "center", ibFonts.bold_34 )
        ibCreateLabel( 567, 361, 0, 0, format_social_rating( BRIBE_ITEMS.choice[ 2 ].social_rating ), BG_OVERLAY, _, _, _, "center", "center", ibFonts.bold_34 )

        -- ВЫБРАТЬ 1
        ibCreateButton(  181, 443, 100, 35, BG_OVERLAY,
                        "img/bribe/btn_select.png", "img/bribe/btn_select_h.png", "img/bribe/btn_select_h.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            triggerServerEvent( "onBusinessTakeBribeRequest", resourceRoot, conf.business_id, 1 )
        end, false )

        -- ВЫБРАТЬ 2
        ibCreateButton(  520, 443, 100, 35, BG_OVERLAY,
                        "img/bribe/btn_select.png", "img/bribe/btn_select_h.png", "img/bribe/btn_select_h.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            triggerServerEvent( "onBusinessTakeBribeRequest", resourceRoot, conf.business_id, 2 )
        end, false )

    else
        if localPlayer:IsInFaction() then
            ibCreateImage( 0, 0, 0, 0, "img/bribe/bg_faction.png", BG_OVERLAY ):ibSetRealSize()
            ibCreateLabel( 283, 361, 0, 0, format_social_rating( BRIBE_ITEMS.faction.social_rating ), BG_OVERLAY, _, _, _, "center", "center", ibFonts.bold_34 )
            ibCreateLabel( 517, 361, 0, 0, BRIBE_ITEMS.faction.faction_exp, BG_OVERLAY, _, _, _, "center", "center", ibFonts.bold_34 )
        elseif localPlayer:IsInClan() then
            ibCreateImage( 0, 0, 0, 0, "img/bribe/bg_clan.png", BG_OVERLAY ):ibSetRealSize()
            ibCreateLabel( 160, 361, 0, 0, format_price( BRIBE_ITEMS.clan.clan_money ), BG_OVERLAY, _, _, _, "center", "center", ibFonts.bold_34 )
            ibCreateLabel( 398, 361, 0, 0, format_social_rating( BRIBE_ITEMS.clan.social_rating ), BG_OVERLAY, _, _, _, "center", "center", ibFonts.bold_34 )
            ibCreateLabel( 632, 361, 0, 0, BRIBE_ITEMS.clan.clan_exp, BG_OVERLAY, _, _, _, "center", "center", ibFonts.bold_34 )
        end

        -- ЗАБРАТЬ
        ibCreateButton(  350, 443, 100, 35, BG_OVERLAY,
                        "img/bribe/btn_take.png", "img/bribe/btn_take_h.png", "img/bribe/btn_take_h.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            triggerServerEvent( "onBusinessTakeBribeRequest", resourceRoot, conf.business_id )
        end, false )
    end

    -- Вернуться
    ibCreateButton( 35, 30, 103, 17, BG_OVERLAY, "img/bribe/btn_back.png", _, _, 0xBBffffff, _, 0xFFAAAAAA )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowTakeBribeOverlay( false )
        end )
end

function onBusinessTakeBribe_handler()
    ShowTakeBribeOverlay( false )
end
addEvent( "onBusinessTakeBribeCallback", true )
addEventHandler( "onBusinessTakeBribeCallback", root, onBusinessTakeBribe_handler )

function RefreshBalance( balance )
    if not UI_elements then return end
    local elements = { UI_elements.lbl_balance, UI_elements.icon_balance, UI_elements.lbl_balance_desc, UI_elements.lbl_balance_2, UI_elements.icon_balance_2 }
    for i, v in pairs( elements ) do
        if isElement( v ) then destroyElement( v ) end
    end

    UI_elements.lbl_balance = ibCreateLabel( 154, 277, 0, 0, format_price( balance ), UI_elements.tab_controls ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_16 } )
    UI_elements.icon_balance = ibCreateImage( UI_elements.lbl_balance:ibGetAfterX() + 8, 275, 24, 24, ":nrp_shared/img/money_icon.png", UI_elements.tab_controls )

    UI_elements.icon_balance_2 = ibCreateImage( 770-24, 97-4, 24, 24, ":nrp_shared/img/money_icon.png", UI_elements.tab_rules )
    UI_elements.lbl_balance_2 = ibCreateLabel( 770-24-10, 97, 0, 0, format_price( balance ), UI_elements.tab_rules ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_14, align_x = "right" } )
    UI_elements.lbl_balance_desc = ibCreateLabel( 770-24-10-UI_elements.lbl_balance_2:width( )-10, 97, 0, 0, "Лицевой счёт:", UI_elements.tab_rules ):ibBatchData( { color = 0xffffdf93, font = ibFonts.bold_14, align_x = "right" } )

    CURRENT_BALANCE = balance
end
addEvent( "onBusinessRefreshBalanceRequest", true )
addEventHandler( "onBusinessRefreshBalanceRequest", root, RefreshBalance )

function RefreshMaterials( materials, max_materials )
    if not UI_elements then return end
    local max_materials = max_materials or 151

    local progress = math.min( 1, ( materials / max_materials ) )
    local width = 740 * progress
    local text = ( materials or 0 ) .. "#cccccc / " .. max_materials

    if isElement( UI_elements.lbl_materials ) then
        
        UI_elements.fg_progress:ibResizeTo( width, 14, 2000, "InOutQuad" )
        UI_elements.lbl_materials:ibInterpolate( 
            function( self )
                local progress = UI_elements.fg_progress:width( ) / 740
                local text = math.ceil( max_materials * progress ) .. "#cccccc / " .. max_materials
                UI_elements.lbl_materials:ibData( "text", text )
            end
        , 2000, "Linear", 
            function( self )
                UI_elements.lbl_materials:ibData( "text", text )
            end 
        )
    else
        UI_elements.lbl_materials = ibCreateLabel( 770, 377, 0, 0, text, UI_elements.tab_controls ):ibBatchData( { color = 0xffffffff, font = ibFonts.regular_14, align_x = "right", colored = true } )
        UI_elements.bg_progress = ibCreateImage( 30, 406, 740, 14, _, UI_elements.tab_controls, 0x77000000 )
        UI_elements.fg_progress = ibCreateImage( 30, 406, width, 14, _, UI_elements.tab_controls, 0xff00b4ff )
    end
end
addEvent( "onBusinessRefreshMaterialsRequest", true )
addEventHandler( "onBusinessRefreshMaterialsRequest", root, RefreshMaterials )

function RefreshSuccesLevel( level, succes_value )
    if not UI_elements then return end

    if level == MAX_BUSINESS_LEVEL then
        succes_value = MAX_SUCCES_VALUE
    end

    local progress = math.min( 1, ( succes_value / MAX_SUCCES_VALUE ) )
    local width = 218 * progress
    local text = ( succes_value or 0 ) .. "#cccccc / " .. MAX_SUCCES_VALUE

    if isElement( UI_elements.lbl_succes_value ) then
        UI_elements.lbl_level:ibData( "text", level .. " ур" )
        UI_elements.succes_progress:ibResizeTo( width, 14, 2000, "InOutQuad" )
        UI_elements.lbl_succes_value:ibData( "text", text )
    else
        UI_elements.lbl_level = ibCreateLabel( 552, 164, 0, 0, level .. " ур", UI_elements.tab_controls ):ibBatchData( { font = ibFonts.bold_20 } )
        UI_elements.lbl_succes_value = ibCreateLabel( 770, 208, 0, 0, text, UI_elements.tab_controls ):ibBatchData( { font = ibFonts.regular_14, align_x = "right", colored = true } )
        UI_elements.succes_progress = ibCreateImage( 552, 233, width, 14, _, UI_elements.tab_controls, 0xff00b4ff )
    end
end
addEvent( "onBusinessRefreshSuccesLevelRequest", true )
addEventHandler( "onBusinessRefreshSuccesLevelRequest", root, RefreshSuccesLevel )

function onBusinessBuyMaterialsAskForCostCallback_handler( business_id, cost, amount )
    if UI_elements.confirmation then UI_elements.confirmation:destroy() end
    UI_elements.confirmation = ibConfirm(
        {
            title = "ПОКУПКА ПРОДУКЦИИ",
            text = "Ты действительно хочешь купить " .. amount .. " ед. продукции за " .. cost .. " р.?\nСумма будет списана с лицевого счёта бизнеса",
            black_bg = 0xaa000000,
            fn = function( self )
                triggerServerEvent( "onBusinessBuyMaterialsRequest", resourceRoot, business_id, amount )
                self:destroy()
            end,
            escape_close = true,
        }
    )
end
addEvent( "onBusinessBuyMaterialsAskForCostCallback", true )
addEventHandler( "onBusinessBuyMaterialsAskForCostCallback", root, onBusinessBuyMaterialsAskForCostCallback_handler )