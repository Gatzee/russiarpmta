function CreateNeonsList( )
    ibUseRealFonts(true)

    if isElement( UI_elements.neons_area ) then destroyElement( UI_elements.neons_area ) end
    UI_elements.neons_area = ibCreateArea( wSide.px, wSide.py, 340, wSide.sy )

    UI_elements.bg         = ibCreateImage( 0, 0, wSide.sx, wSide.sy, _, UI_elements.neons_area, 0xf1475d75 )

    -- Заголовок
    UI_elements.img_neons_header = ibCreateImage( 0, 0, wInventory.sx, 100, _, UI_elements.neons_area, 0x2595caff )
    UI_elements.lbl_neons_header = ibCreateLabel( 20, 0, 0, 50, "Установка неонов", UI_elements.img_neons_header ):ibBatchData( { align_y = "center", font = ibFonts.bold_16 } )

    ibUseRealFonts(false)

    CreateNeonsInventoryAndShop( )

    UI_elements.neons_area:ibTimer( function( )
        triggerServerEvent( "OnPlayerRequestNeonsList", localPlayer )
    end, 250, 1 )
end

function CreateNeonsInventoryAndShop( )
    -- Выбор вкладки
    UI_elements.bg_shop         = ibCreateImage( 0, 56, wInventory.sx / 2, 44, _, UI_elements.neons_area, 0 )
    UI_elements.lbl_shop        = ibCreateLabel( 0, 0, wInventory.sx / 2, 44, "Магазин", UI_elements.bg_shop ):ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.semibold_12 } )
    UI_elements.area_shop       = ibCreateArea( 0, 0, wInventory.sx / 2, 44, UI_elements.bg_shop )

    UI_elements.bg_inventory        = ibCreateImage( wInventory.sx / 2, 56, wInventory.sx / 2, 44, _, UI_elements.neons_area, 0 )
    UI_elements.lbl_inventory       = ibCreateLabel( 0, 0, wInventory.sx / 2, 44, "Инвентарь", UI_elements.bg_inventory ):ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.semibold_12 } )
    UI_elements.area_inventory      = ibCreateArea( 0, 0, wInventory.sx / 2, 44, UI_elements.bg_inventory )

    local tab_current = UI_elements.bg_shop

    function ParseTabChange( key, state, initial )
        if key ~= "left" or state ~= "up" then return end

        local source_targets = {
            [ UI_elements.area_shop ] = UI_elements.bg_shop,
            [ UI_elements.area_inventory ] = UI_elements.bg_inventory,
        }
        if source_targets[ source ] then
            tab_current = source_targets[ source ]
            ibClick()
        end

        local data_current = tab_current == UI_elements.bg_shop and DATA.purchase_neons or DATA.inventory_neons
        if not initial then
            RefreshNeonsTabContent( data_current )
        end

        UI_elements.is_style = UI_elements.bg_shop and tab_current == UI_elements.bg_shop or false

        UI_elements.bg_shop:ibData( "color", 0xF0637A92 )
        UI_elements.bg_inventory:ibData( "color", 0xF0637A92 )

        UI_elements.lbl_shop:ibData( "color", 0x90FFFFFF )
        UI_elements.lbl_inventory:ibData( "color", 0x90FFFFFF )

        tab_current:ibData( "color", 0xF08698AB )
        getElementsByType( "ibLabel", tab_current )[ 1 ]:ibData( "color", 0xFFFFFFFF )
    end
    addEventHandler( "ibOnElementMouseClick", UI_elements.area_shop, ParseTabChange, false )
    addEventHandler( "ibOnElementMouseClick", UI_elements.area_inventory, ParseTabChange, false )

    -- Скроллпейн
    UI_elements.inventory_rt, UI_elements.inventory_sc  = ibCreateScrollpane( 0, 100, wInventory.sx, wInventory.sy - 22, UI_elements.neons_area,
        {
            scroll_px = -25,
            bg_sx = 0,
            handle_sy = 40,
            handle_sx = 16,
            handle_texture = "img/scroll.png",
            handle_upper_limit = -40 - 20,
            handle_lower_limit = 20,
        }
    )

    addEvent( "OnClientNeonsListUpdate" )
    addEventHandler( "OnClientNeonsListUpdate", UI_elements.neons_area, function( )
        ParseTabChange( "left", "up" )
    end )

    ParseTabChange( "left", "up", true )
end

function RefreshNeonsTabContent( content )

    DestroyTableElements( getElementChildren( UI_elements.inventory_rt ) )

    local content = content or { }

    local npy = 0
    for i, neon_data in ipairs( content ) do
        local area = CreateNeonElement( neon_data, { parent = UI_elements.inventory_rt, px = 0, py = npy } )
        npy = npy + area:ibData( "sy" )
        local line = ibCreateImage( 0, npy, area:ibData( "sx" ), 1, _, UI_elements.inventory_rt, ibApplyAlpha( COLOR_WHITE, 15 ) )
        npy = npy + 1
    end

    if #content <= 0 then
        ibUseRealFonts( true )
        local lbl_empty = ibCreateLabel( 0, 0, 0, 0, "У вас нет неонов в наличии.\nПриобретите неоны в магазине.", UI_elements.inventory_rt, ibApplyAlpha( COLOR_WHITE, 50 ) , _, _, "center", "center", ibFonts.semibold_15 )
            :ibData( "wordbreak", true )
            :center( )
        ibUseRealFonts( false )
    end

    UI_elements.inventory_rt:AdaptHeightToContents( )
    UI_elements.inventory_sc:UpdateScrollbarVisibility( UI_elements.inventory_rt )
    UI_elements.inventory_sc:ibData("position", 0)
end

function ShowNeonsList( instant )
    if instant then
        UI_elements.neons_area:ibBatchData(
            {
                px = wSide.px, py = wSide.py
            }
        )
        UI_elements.neons_area:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.neons_area:ibMoveTo( wSide.px, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.neons_area:ibBatchData( { disabled = false } )
        UI_elements.neons_area:ibAlphaTo( 255, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideNeonsList( instant )
    if not isElement( UI_elements.neons_area ) then return end
    if instant then
        UI_elements.neons_area:ibBatchData(
            {
                px = x, py = wSide.py
            }
        )
        UI_elements.neons_area:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.neons_area:ibMoveTo( x, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.neons_area:ibBatchData( { disabled = true } )
        UI_elements.neons_area:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end

    UI_elements.vehicle:SetNeon( DATA.neon_image )
end

function OnClientNeonsReceive_handler( purchase_neons, inventory_neons )
    DATA.purchase_neons = purchase_neons
    DATA.inventory_neons = inventory_neons
    triggerEvent( "OnClientNeonsListUpdate", root )
end
addEvent( "OnClientNeonsReceive", true )
addEventHandler( "OnClientNeonsReceive", root, OnClientNeonsReceive_handler )

function CreateNeonElement( neon_data, params )
    ibUseRealFonts( true )
    local neon_area = ibCreateArea( params.px or 0, params.py or 0, 340, 284, params.parent )
    local neon_bg = ibCreateImage( 20, 15, 300, 160, "img/bg_neon.png", neon_area )
    local cost = ApplyDiscount( neon_data.cost )
    
    local function create_buy_btn( )
        ibCreateButton( 200, 220, 135, 69, neon_area,
                        "img/btn_buy_neon.png", "img/btn_buy_neon_hover.png", "img/btn_buy_neon_hover.png",
                        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                confirmation = ibConfirm( {
                    title = "ПОКУПКА НЕОНА",
                    text = "Ты точно хочешь купить данный неон за " .. format_price( cost ) .. " рублей?" ,
                    fn = function( self )
                        self:destroy()
                        triggerServerEvent( "onClientRequestShopNeonPurchase", resourceRoot, neon_data )
                    end,
                    escape_close = true,
                } )
                ibClick()
            end )

    end

    local function create_preview_btn( )
        ibCreateImage( 202, 197, 0, 0, "img/icon_preview.png", neon_area )
            :ibSetRealSize( )
            :ibData( "alpha", 200 )
            :ibOnHover( function( )
                source:ibAlphaTo( 255 )
            end )
            :ibOnLeave( function( )
                source:ibAlphaTo( 200 )
            end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                iprint( UI_elements.vehicle:GetNeon( ), neon_data.neon_image )
                UI_elements.vehicle:SetNeon( neon_data.neon_image )
            end )
    end

    local function create_sell_btn( )
        ibCreateButton( 2, 218, 139, 73, neon_area,
            "img/btn_sell_neon.png", "img/btn_sell_neon_hover.png", "img/btn_sell_neon_hover.png",
            0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    confirmation = ibConfirm( {
                        title = "ПРОДАЖА НЕОНА",
                        text = "Ты точно хочешь продать данный неон за " .. format_price( neon_data.sell_cost ) .. " внутриигровой валюты?" ,
                        fn = function( self )
                            self:destroy()
                            triggerServerEvent( "onClientRequestNeonSell", resourceRoot, neon_data )
                        end,
                        escape_close = true,
                    } )
                    ibClick()
                end )
    end

    local function create_install_btn( )
        ibCreateButton( 189, 220, 149, 69, neon_area,
        "img/btn_install_neon.png", "img/btn_install_neon_hover.png", "img/btn_install_neon_hover.png",
        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                confirmation = ibConfirm( {
                    title = "УСТАНОВКА НЕОНА",
                    text = "Ты точно хочешь установить данный неон? Снять его с машины можно лишь ограниченное количество раз!" ,
                    fn = function( self )
                        self:destroy()
                        triggerServerEvent( "onClientRequestNeonInstall", resourceRoot, neon_data )
                    end,
                    escape_close = true,
                } )
                ibClick()
            end )
    end

    local function create_takeoff_btn( )
        ibCreateButton( 199, 220, 136, 69, neon_area,
        "img/btn_takeoff_neon.png", "img/btn_takeoff_neon_hover.png", "img/btn_takeoff_neon_hover.png",
        0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                confirmation = ibConfirm( {
                    title = "СНЯТИЕ НЕОНА",
                    text = "Ты точно хочешь снять данный неон?" ,
                    fn = function( self )
                        self:destroy()
                        triggerServerEvent( "onClientRequestNeonTakeoff", resourceRoot, neon_data )
                    end,
                    escape_close = true,
                } )
                ibClick()
            end )
    end

    ibCreateContentImage( 0, 0, 300, 160, "neon", neon_data.neon_image, neon_bg )
    :center( )

    ibCreateLabel( 20, 207, 155, 0, NEONS_RU_NAMES[ neon_data.neon_image ], neon_area, COLOR_WHITE, _, _, _, "center", ibFonts.bold_16 )
        :ibData( "wordbreak", true )

    if not neon_data.sell_cost then
        ibCreateLabel( 20, 243, 0, 0, "Стоимость:", neon_area, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, _, _, ibFonts.regular_14 )
        local lbl_cost = ibCreateLabel( 103, 240, 0, 0, format_price( cost ), neon_area, 0xffffffff, _, _, _, _, ibFonts.bold_18 )
        ibCreateImage( lbl_cost:ibGetAfterX( 5 ), 243, 22, 20, ":nrp_shared/img/money_icon.png", neon_area )
        
        create_buy_btn( )
        create_preview_btn( )
    else
        if neon_data.current then
            ibCreateImage( 274, 8, 18, 15, "img/icon_installed.png", neon_bg )
            create_takeoff_btn( )
        else
            create_install_btn( )
        end
        create_sell_btn( )
    end
    ibUseRealFonts( false )

    return neon_area
end