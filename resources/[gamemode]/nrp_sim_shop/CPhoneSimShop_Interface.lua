local UI_elements
local ticks = 0
local timeout = 1000

function InitSimShop( )
    if not _SIMSHOP_INIT then
        loadstring( exports.interfacer:extend( "Interfacer" ) )()
        Extend( "ib" )
        Extend( "ShUtils" )
        fonts = {
            light_12 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Light.ttf", 12, false, "default"),
            regular_10 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 10, false, "default"),
            regular_12 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 12, false, "default"),
            bold_9 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 9, false, "default"),
            bold_10 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 10, false, "default"),
            bold_11 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 11, false, "default"),
            bold_12 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 12, false, "default"),
            bold_13 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 13, false, "default"),
            bold_14 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 14, false, "default"),
            bold_16 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-SemiBold.ttf", 16, false, "default"),
            bold_26 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 26, false, "default"),
            bold_36 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 36, false, "default"),
        }
        _SIMSHOP_INIT = true
    end
end

function ShowSimShopUI_handler( state, conf )
    if state then
        InitSimShop( )
        ibInterfaceSound()
        
        ShowSimShopUI_handler( false )

        _SIM_SHOP_OPEN = true

        UI_elements = { }

        x, y = guiGetScreenSize( )
        sx, sy = 669, 580
        px, py = ( x - sx ) / 2, ( y - sy ) / 2

        UI_elements.black_bg = ibCreateBackground( _, ShowSimShopUI_handler, true, true )
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg.png", UI_elements.black_bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 30, 25, 24, 24, UI_elements.bg, 
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "priority", 10 )

        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ibClick( )
            ShowSimShopUI_handler( false )
        end, false )
        
        UI_elements.tab_unique = ibCreateArea( 0, 0, sx, sy, UI_elements.bg )
        UI_elements.tab_normal = ibCreateArea( 0, 0, sx, sy, UI_elements.bg )

        local TABS = { "Уникальные номера", "Обычные номера" }
        local TABS_AREAS = { UI_elements.tab_unique, UI_elements.tab_normal }
        local current_tab

        local row_py = 118
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
                    tab_area:ibMoveTo( 0, 0, 250 )
                    tab_area:ibAlphaTo( 255, 100 )
                    tab_area:ibData( "disabled", false )
                else
                    tab_area:ibMoveTo( 0, -20, 250 )
                    tab_area:ibAlphaTo( 0, 100 )
                    tab_area:ibData( "disabled", true )
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
            local lbl = ibCreateLabel( 0, 0, 0, 0, v, bg ):ibData( "font", fonts.bold_10 )

            UI_elements[ "tab_area_" .. i ] = bg
            UI_elements[ "tab_lbl_" .. i ] = lbl

            local btn = ibCreateButton( npx, 85, lbl:width( ), 38, UI_elements.bg, nil, nil, nil, 0, 0, 0 )
            addEventHandler( "ibOnElementMouseClick", btn, function( key, state )
                if key ~= "left" or state ~= "down" then return end
                ibClick( )
                SwitchTabTo( i )
            end, false )   

            npx = npx + lbl:width( ) + 30
        end

        SwitchTabTo( 1 )

        UI_elements.lbl_myphone = ibCreateLabel( 576, 93, 0, 0, "", UI_elements.bg, 0xFFFFFFFF ):ibData( "font", fonts.bold_10 )

        ibCreateLabel( 30, 150, 0, 0, "Телефонный номер", UI_elements.tab_unique, 0x77FFFFFF ):ibData( "font", fonts.bold_10 )
        ibCreateLabel( 315, 150, 0, 0, "Стоимость", UI_elements.tab_unique, 0x77FFFFFF ):ibData( "font", fonts.bold_10 )
        
        UI_elements.rt, UI_elements.sc = ibCreateScrollpane( 0, 174, sx, sy - 174, UI_elements.tab_unique, 
            {
                scroll_px = -22,
                bg_sx = 0,
                handle_sy = 40,
                handle_sx = 16,
                handle_texture = ":nrp_shared/img/scroll_bg_small.png",
                handle_upper_limit = -40 - 20,
                handle_lower_limit = 20,
            }
        )
        UI_elements.sc:ibData( "sensivity", 0.05 )
        if conf.available_numbers then UpdateSimShopList_handler( conf.available_numbers, conf.current_number ) end

        -- Вкладка обычных номеров
        ibCreateImage( 251, 177, 17, 24, "img/sim_normal.png", UI_elements.tab_normal )
        ibCreateLabel( 281, 167, 0, 0, "? ??? ???", UI_elements.tab_normal, 0xFFFFFFFF ):ibData( "font", fonts.bold_26 )

        ibCreateLabel( 0, 0, 0, 0, "Обычные номера мы подбираем для вас автоматически, после покупки", UI_elements.tab_normal, 0x99ffffff, 1, 1, "center" ):ibData( "font", fonts.regular_12 ):center( ):ibData( "py", 221 )
        
        ibCreateLabel( 253, 267, 0, 0, "Стоимость:", UI_elements.tab_normal, 0xFFFFFFFF ):ibData( "font", fonts.regular_12 )
        ibCreateLabel( 342, 265, 0, 0, "1000", UI_elements.tab_normal, 0xFFFFFFFF ):ibData( "font", fonts.bold_14 )
        ibCreateImage( 393, 264, 24, 24, ":nrp_shared/img/money_icon.png", UI_elements.tab_normal )

        local buy_random_number = ibCreateButton(  275, 309, 120, 38, UI_elements.tab_normal, 
                                                    "img/btn_buy_big.png", "img/btn_buy_big.png", "img/btn_buy_big.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )

        addEventHandler( "ibOnElementMouseClick", buy_random_number, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            
            local cticks = getTickCount()
            if cticks - ticks < timeout then return end
            ticks = cticks

            -- TODO показывать только если номер уже есть
            if isElement( UI_elements.confirmation ) then UI_elements.confirmation:destroy() end

            ibClick( )

            local text = "Ты действительно хочешь купить\nобычный номер за 1000 р. ?"
            if conf.current_number then
                text = "Вы уверены, что хотите заменить старый номер и купить обычный номер за 1000 р. ?"
            end

            UI_elements.confirmation = ibConfirm(
                {
                    title = "ПОДТВЕРЖДЕНИЕ ПОКУПКИ",
                    text = text,
                    black_bg = 0xaa000000,
                    priority = 10,
                    fn = function( self )
                        self:destroy()
                        triggerServerEvent( "onSimShopRandomNumberPurchaseRequest", resourceRoot )
                    end,
                    escape_close = true,
                }
            )
        end, false )

        showCursor( true )
    else
        _SIM_SHOP_OPEN = nil
        showCursor( false )
        if isElement(UI_elements and UI_elements.black_bg) then
            destroyElement( UI_elements.black_bg )
        end
        UI_elements = nil
    end
end
addEvent( "ShowSimShopUI", true )
addEventHandler( "ShowSimShopUI", root, ShowSimShopUI_handler )

function UpdateSimShopList_handler( new_available_numbers, new_number )
    if not isElement( UI_elements.bg ) then return end
    UI_elements.lbl_myphone:ibData( "text", new_number and format_price( new_number ) or "Нет номера" )

    local element_prefix = "list_bg_"
    local element_num = 1
    while isElement( UI_elements[ element_prefix .. element_num ] ) do
        destroyElement( UI_elements[ element_prefix .. element_num ] )
        element_num = element_num + 1
    end

    local npx, npy = 0, 0
    local row_height = 48
    local is_black_bg = true
    
    element_num = 1
    for number_type, numbers in pairs( new_available_numbers ) do
        for i = 1, #numbers do
            local number_info = numbers[ i ]
            -- Фон
            local element_id = element_prefix .. element_num
            local bg = ibCreateImage( npx, npy, sx, row_height, _, UI_elements.rt, is_black_bg and 0x33000000 or 0 )

            -- Иконка симки и номер + премиум
            local number = format_price( string.gsub( number_info.number, "+", "" ) )
            ibCreateImage( 30, 15, 13, 18, "img/sim_premium.png", bg )
            local premium = false
            if number_info.type == "unique" or number_info.type == "premium" or number_info.type == "luxury" then
                premium = true
            end
            local lbl_number = ibCreateLabel( 57, 0, 0, row_height, number, bg, premium and 0xffffb723 or 0xffffffff, 1, 1, "left", "center" ):ibData( "font", fonts.bold_16 )
            
            local bg_type = ibCreateImage( 57 + lbl_number:width( ) + 10, 15, 100, 19, "img/premium.png", bg )
            ibCreateLabel( 0, 0, 100, 19, NUMBERS[ number_info.type ].name, bg_type, 0xffffb723, 1, 1, "center", "center" ):ibData( "font", fonts.bold_10 )

            -- Цена
            local cost = format_price( number_info.cost )
            local lbl_cost = ibCreateLabel( 315, 0, 0, row_height, cost, bg, 0xffffffff, 1, 1, "left", "center" ):ibData( "font", fonts.bold_12 )
            ibCreateImage( 315 + lbl_cost:width( ) + 10, 12, 24, 24, ":nrp_shared/img/money_icon.png", bg )

            -- Кнопка "Купить"
            local btn_buy = ibCreateButton( 540, 8, 100, 32, bg,
                                            "img/btn_buy.png", "img/btn_buy.png", "img/btn_buy.png",
                                            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "color_disabled", 0x55ffffff )

            addEventHandler( "ibOnElementMouseClick", btn_buy, function( key, state )
                if key ~= "left" or state ~= "up" then return end

                local cticks = getTickCount()
                if cticks - ticks < timeout then return end
                ticks = cticks

                if isElement( UI_elements.confirmation ) then UI_elements.confirmation:destroy() end

                ibClick( )

                local text = "Ты действительно хочешь купить\nномер " .. number .. " за " .. cost .. " р.?"
                if new_number then
                    text = "Вы уверены, что хотите заменить старый номер и купить номер " .. number .. " за " .. cost .. " р.?"
                end

                UI_elements.confirmation = ibConfirm(
                    {
                        title = "ПОДТВЕРЖДЕНИЕ ПОКУПКИ",
                        text = text,
                        black_bg = 0xaa000000,
                        priority = 10,
                        fn = function( self )
                            self:destroy()
                            triggerServerEvent( "onSimShopPurcahseRequest", resourceRoot, number_info )
                        end,
                        escape_close = true,
                    }
                )

            end, false )


            UI_elements[ element_id ] = bg

            element_num = element_num + 1
            is_black_bg = not is_black_bg
            npy = npy + row_height
        end
    end

    UI_elements.rt:AdaptHeightToContents( )

    --iprint( "Update list", new_available_numbers )
end
addEvent( "UpdateSimShopList", true )
addEventHandler( "UpdateSimShopList", root, UpdateSimShopList_handler )

function onPlayerNewNumberReward_handler( available_numbers, new_number )
    if isElement( UI_elements.reward_bg ) then return end

    UpdateSimShopList_handler( available_numbers, new_number )

    local function close( )
        if isElement( UI_elements.reward_bg  ) then 
            destroyElement( UI_elements.reward_bg ) 
        end
	end

    UI_elements.reward_bg = ibCreateBackground( 0xdd394a5c, close, true, true ):ibData( "alpha", 0 )
    ibCreateImage( 0, 0, 800, 570, "img/brush.png", UI_elements.reward_bg ):center( 0, 0 )
    
    ibCreateImage( 251, 177, 223, 49, "img/reward_info.png", UI_elements.reward_bg ):center( 0, 70 )
    ibCreateLabel( 0, 0, 0, 0, "Поздравляем! Ваш номер:", UI_elements.reward_bg, 0xFFFFFFFF, 1, 1, "center" ):ibData( "font", fonts.bold_14 ):center( 0, -150 )
    ibCreateLabel( 0, 0, 0, 0, format_price( new_number ), UI_elements.reward_bg, 0xFFFFFFFF, 1, 1, "center" ):ibData( "font", fonts.bold_36 ):center( 0, -75 )

    local btn_open_plan = ibCreateButton(	0, 0, 250, 54, UI_elements.reward_bg,
												"img/btn_open_plan.png", "img/btn_open_plan.png", "img/btn_open_plan.png", 
												0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):center( 0, 200 )
	addEventHandler( "ibOnElementMouseClick", btn_open_plan, function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )

		close( )
		ShowPlanUI_handler( state )
    end, false )
    
    UI_elements.reward_bg:ibAlphaTo( 255, 500 )
end
addEvent( "onPlayerNewNumberReward", true )
addEventHandler( "onPlayerNewNumberReward", root, onPlayerNewNumberReward_handler )