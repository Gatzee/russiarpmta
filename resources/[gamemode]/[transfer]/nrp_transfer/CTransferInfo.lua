local UI

function ShowTransferInfoUI( state, conf )
    InitModules( )

    if state then
        ShowTransferInfoUI( false )

        UI = { }

        UI.black_bg = ibCreateBackground( _, _, true ):ibData( "priority", 5 )
        UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg_list.png", UI.black_bg ):ibSetRealSize( ):center( )

        UI.btn_close = ibCreateButton(  UI.bg:width( ) - 24 - 24, 33, 24, 24, UI.bg,
                            ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowTransferInfoUI( false )
            end )

        UI.rt_left, UI.sc_left = ibCreateScrollpane( 0, 261, 511, 356, UI.bg, { scroll_px = -20 } )
        UI.sc_left:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

        local function build_currency( name, amount, px, py, parent, font )
            local font = font or ibFonts.bold_18
            local area = ibCreateArea( px, py, 0, 24, parent )
            local icon = name == "soft" and ":nrp_shared/img/money_icon.png" or name == "hard" and ":nrp_shared/img/hard_money_icon.png" or name == "business_coins" and ":nrp_shared/img/business_coin_icon.png"
            local img = ibCreateImage( 0, 0, 0, 0, icon, area ):ibSetRealSize( ):ibSetInBoundSize( 24, 24 )
            local lbl = ibCreateLabel( img:ibGetAfterX( 8 ), img:ibGetCenterX( ), 0, 0, format_price( amount ), area, COLOR_WHITE, _, _, "left", "center", font )

            area:ibData( "sx", lbl:ibGetAfterX( ) )

            return area
        end

        local function build_FUCKING_currency( name, amount, px, py, parent, font )
            local font = font or ibFonts.bold_18
            local area = ibCreateArea( px, py, 0, 16, parent )
            local icon = name == "soft" and ":nrp_shared/img/money_icon.png" or name == "hard" and ":nrp_shared/img/hard_money_icon.png" or name == "business_coins" and ":nrp_shared/img/business_coin_icon.png"
            local lbl = ibCreateLabel( 0, 0, 0, 16, format_price( amount ), area, COLOR_WHITE, _, _, "left", "center", font )
            local img = ibCreateImage( lbl:ibGetAfterX( 6 ), lbl:ibGetCenterX( ), 0, 0, icon, area ):ibSetRealSize( ):ibSetInBoundSize( 20, 20 ):center_y( )

            area:ibData( "sx", img:ibGetAfterX( ) )

            return area
        end

        local function BuildList( rt, sc, list )
            local black = true
            local npy = 0
            local line_height = 50
            for i, v in ipairs( list or { } ) do
                local bg = ibCreateImage( 0, npy, rt:width( ), line_height, _, rt, black and ibApplyAlpha( 0xff314050, 25 ) or 0 )

                if v.text then
                    local lbl = ibCreateLabel( 30, 0, 0, 0, v.text, bg, COLOR_WHITE, _, _, _, "center", ibFonts.regular_16 ):center_y( ):ibData( "colored", true )
                end

                if v.cost and v.type then
                    local area = build_FUCKING_currency( v.type, v.cost, 0, 0, bg, ibFonts.bold_16 )
                    area:ibData( "px", bg:width( ) - area:width( ) - 30 ):center_y( )
                end

                npy = npy + line_height
                black = not black
            end

            sc:ibData( "priority", 1 )
            rt:AdaptHeightToContents( )
            sc:UpdateScrollbarVisibility( rt )
        end

        local function build_currency_line( currency, px, py, parent )
            local areas = { }
            table.insert( areas, build_currency( "soft", currency.soft, px, py, parent ) )

            if currency.hard and currency.hard > 0 then
                table.insert( areas, build_currency( "hard", currency.hard, px, py, parent ) )
            end

            if currency.business_coins and currency.business_coins > 0 then
                table.insert( areas, build_currency( "business_coins", currency.business_coins, px, py, parent ) )
            end

            local npx = px
            for i, v in pairs( areas ) do
                v:ibData( "px", npx )

                npx = npx + v:width( ) + 10

                if i ~= #areas then
                    local divider = ibCreateLabel( npx, v:ibGetCenterY( ), 0, 0, "/", parent, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, _, "center", ibFonts.regular_28 )
                    npx = npx + divider:width( ) + 10
                end
            end
        end

        BuildList( UI.rt_left, UI.sc_left, conf.list_saved )

        if conf.list_sold and #conf.list_sold > 0 then
            UI.rt_right, UI.sc_right = ibCreateScrollpane( 513, 261, 511, 266, UI.bg, { scroll_px = -20 } )
            UI.sc_right:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

            BuildList( UI.rt_right, UI.sc_right, conf.list_sold )

            local total_area = ibCreateImage( 513, 527, 511, 91, "img/sold_total.png", UI.bg )
            build_currency_line( conf.currency, 30, 47, total_area )
        else
            ibCreateLabel( 513, 261, 511, 356, "Отсутствует имущество для продажи", UI.bg, ibApplyAlpha( COLOR_WHITE, 50 ), _ ,_, "center", "center", ibFonts.regular_20 )
        end

        UI.btn_transfer = ibCreateButton( 0, 643, 0, 0, UI.bg, "img/btn_transfer_big.png", "img/btn_transfer_big.png", "img/btn_transfer_big.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibSetRealSize( )
            :center_x( )
            :ibData( "priority", 2 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                UI.confirmation = ibConfirm(
                    {
                        title = "ПЕРЕНОС АККАУНТА",
                        text = "Ты действительно хочешь перенести аккаунт на новый сервер?\nЭТО ДЕЙСТВИЕ НЕЛЬЗЯ ОТМЕНИТЬ" ,
                        priority = 10,
                        fn = function( self )
                            UI.loading = ibLoading( { text = "Переносим...", font = ibFonts.regular_12 } ):ibData( "priority", 5 )
                            triggerServerEvent( "onPlayerRequestStartTransfer", resourceRoot )
                            self:destroy()
                        end,
                        escape_close = true,
                    }
                )
            end )

        UI.bg:ibData( "alpha", 0 ):ibData( "py", UI.bg:ibData( "py" ) + 100 ):ibAlphaTo( 255, 300 ):ibMoveTo( _, UI.bg:ibData( "py" ) - 100, 500 )

        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil

        showCursor( false )
    end
end

function ShowChangeNicknameOverlay( )
    if not UI or UI.overlay_bg then return end

    UI.overlay_bg = ibCreateImage( 0, 92, 1024, 628, _, UI.bg, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "alpha", 0 )
        :ibAlphaTo( 255 )
        :ibData( "priority", 3 )

    ibCreateLabel( 0, 186, 0, 0, "Введи желаемое имя персонажа:", UI.overlay_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_20 ):center_x( )
    ibCreateLabel( 0, 215, 0, 0, "Запрещено: Мать Админа, Молодой Человек и т.д.", UI.overlay_bg, ibApplyAlpha( COLOR_WHITE, 30 ), _, _, "center", "center", ibFonts.regular_14 ):center_x( )

    local bg_edit = ibCreateImage( 0, 240, 575, 58, "img/edit_bg.png", UI.overlay_bg )
        :ibData( "alpha", 255 * 0.7 )
        :center_x( )
    local edit_name = ibCreateEdit( bg_edit:ibData( "px" ) + 20, 240, bg_edit:width( ) - 40, bg_edit:height( ), "", UI.overlay_bg, COLOR_WHITE )
        :ibBatchData( {
            font = ibFonts.regular_16,
            caret_color = ibApplyAlpha( COLOR_WHITE, 70 ),
            bg_color = 0,
            align_x = "center",
        } )
        :ibOnFocusChange( function( focused )
            bg_edit:ibAlphaTo( focused and 255 or 255 * 0.7, 100 )
        end )

    local btn = ibCreateImage( 0, 328, 166, 49, "img/btn_apply.png", UI.overlay_bg )
        :center_x( )
        :ibData( "alpha", 255 * 0.5 )
        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) source:ibAlphaTo( 255 * 0.5, 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            local nickname = edit_name:ibData( "text" )
            UI.loading = ibLoading( { text = "Переносим...", font = ibFonts.regular_12 } ):ibData( "priority", 5 )
            triggerServerEvent( "onPlayerRequestStartTransfer", resourceRoot , nickname )
        end )
    ibCreateLabel( 0, 0, 0, 0, "ПРИМЕНИТЬ", btn, _, _, _, "center", "center", ibFonts.bold_18 ):center( )
end

function onClientPlayerShowTransferInfo_handler( data )
    if data.clan_data then
        ShowTransferClanInfoUI( true, data )
    else
        ShowTransferInfoUI( true, data )
    end
end
addEvent( "onClientPlayerShowTransferInfo", true )
addEventHandler( "onClientPlayerShowTransferInfo", root, onClientPlayerShowTransferInfo_handler )

function onClientPlayerRequestCancelLoadingAnimation_handler( show_success, transfer, message )
    if UI and isElement( UI.loading ) then
        UI.loading:destroy( )
        UI.loading = nil
    end

    if show_success then
        ShowTransferInfoUI( false )
        ShowTransferFinishedUI( true, { transfer = transfer } )
    else
        if message == "Перенос невозможен NT02: Данный никнейм уже существует на сервере" then
            UI.confirmation = ibConfirm(
                {
                    title = "ПЕРЕНОС АККАУНТА",
                    text = "Такой ник уже используется на сервере. Для совершения перехода необходимо изменить ник" ,
                    priority = 10,
                    fn = function( self )
                        self:destroy()
                        ShowChangeNicknameOverlay( )
                    end,
                    fn_cancel = function( self )
                        ShowTransferInfoUI( false )
                    end,
                    escape_close = true,
                }
            )
        else
            localPlayer:ErrorWindow( message )
            ibError( )
        end
    end
end
addEvent( "onClientPlayerRequestCancelLoadingAnimation", true )
addEventHandler( "onClientPlayerRequestCancelLoadingAnimation", resourceRoot, onClientPlayerRequestCancelLoadingAnimation_handler )