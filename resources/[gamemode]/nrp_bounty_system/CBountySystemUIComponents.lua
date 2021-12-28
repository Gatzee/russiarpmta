local ui = { }

ibUseRealFonts( true )

local function setStateComponent( component, state )
    if state and isElement( component ) then return false
    elseif not state then
        if isElement( component ) then
            destroyElement( component )

            if not isElement( ui.orientationsMenu ) and not isElement( ui.resultWindow ) and not isElement( ui.orderMenu ) then
                showCursor( false )
            end
        end

        return false
    end

    return true
end

function fillOrientationsMenu( orientations )
    if not isElement( ui.orientScroll ) then return end

    if #orientations < 1 then
        ibCreateLabel( 0, 270, 1024, 0, "Список ориентировок пуст, ожидайте поступление от граждан", ui.orientScroll, 0xbbffffff, nil, nil, "center", "center", ibFonts.regular_22 )
    end

    for i, d in pairs( orientations ) do
        local player = GetPlayer( d.target_uid )

        if player then
            local img = ibCreateImage( 0, ( i - 1 ) * 165 + ( i - 1 ) * 20, 967, 165, "img/orientation.png", ui.orientScroll )

            -- nickname
            ibCreateLabel( 154, 54, 0, 0, player:GetNickName( ) or "", img, 0xffffffff, nil, nil, "left", "top", ibFonts.regular_16 )
            ibCreateContentImage( 3, 2, 130, 160, "skin", d.skin, img )

            -- time left
            ibCreateLabel( 440, 30, 0, 0, "", img, 0xffffffff, nil, nil, "right", "top", ibFonts.regular_14 )
            :ibTimer( function ( self )
                d.time_left = d.time_left - 1

                local hour = math.floor( d.time_left / 3600 )
                local min = math.floor( ( d.time_left - hour * 3600 ) / 60 )
                local sec = math.floor( d.time_left - hour * 3600 - min * 60 )

                self:ibData( "text", string.format( "%2d ч %02d мин %02d сек", hour, min, sec ) )

                if d.time_left < 0 then
                    img:destroy( )
                    ui.orientScroll:AdaptHeightToContents( )
                    ui.orientBar:UpdateScrollbarVisibility( ui.orientScroll )
                end
            end, 1000, 0 )

            -- reward
            local label_r = ibCreateLabel( 154, 110, 0, 0, format_price( COP_REWARD ), img, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )
            ibCreateImage( label_r:ibGetAfterX( 10 ), 112, 25, 25, ":nrp_shared/img/money_icon.png", img )

            -- find
            ibCreateButton(
                624, 90, 202, 38, img,
                "img/btn_find.png", "img/btn_find_hover.png", "img/btn_find_hover.png",
                nil, nil, 0xFFAAAAAA
            )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )

                if not isElement( player ) then
                    localPlayer:ShowError( "Данный игрок вышел из игры" )
                    return
                elseif player:IsNickNameHidden( ) then
                    localPlayer:ShowError( "Спутник не может определить\nместоположение игрока" )
                    return
                end

                triggerServerEvent( "updateTargetPositionBySputnik", localPlayer, d.target_uid )
            end )
        end
    end

    ui.orientScroll:AdaptHeightToContents( )
    ui.orientBar:UpdateScrollbarVisibility( ui.orientScroll )
end

components = {
    orientationsMenu = function ( state )
        if not setStateComponent( ui.orientationsMenu, state ) then return end

        -- background
        ui.orientationsMenu = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

        -- window
        local window = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", ui.orientationsMenu ):center( )

        -- close button
        ibCreateButton( 960, 30, 30, 30, window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.orientationsMenu, false )
        end )
        :ibData( "priority", 1 )

        -- header
        ibCreateLabel( 30, 30, 0, 0, "Список ориентировок", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )

        -- scroll
        ui.orientScroll, ui.orientBar = ibCreateScrollpane( 30, 123, 964, 615, window, { scroll_px = 10 } )
        ui.orientBar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.02 )

        triggerServerEvent( "onPlayerGetOrientations", localPlayer )

        showCursor( true )
    end,

    resultWindow = function ( state, result, nickname, skin_id )
        if not setStateComponent( ui.resultWindow, state ) then return end

        -- background
        ui.resultWindow = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

        -- window
        local window = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", ui.resultWindow ):center( )

        -- close button
        ibCreateButton( 960, 30, 30, 30, window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.resultWindow, false )
        end )
        :ibData( "priority", 1 )

        -- header
        ibCreateLabel( 30, 30, 0, 0, "Заказ", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )

        -- content
        local bg = ibCreateImage( 0, 93, 1024, 675, "img/bg_result.png", window )

        ibCreateLabel( 0, 50, 1024, 0, nickname or "-", bg, nil, nil, nil, "center", "center", ibFonts.bold_22 )

        local texts = {
            fail = { "Ушёл от преследования!", 0xffff5959 },
            arrest = { "Был предан правосудию!", 0xff1fd064 },
            death = { "Был убит!", 0xffff5959 }
        }
        ibCreateLabel( 0, 105, 1024, 0, texts[ result ][ 1 ], bg, texts[ result ][ 2 ], nil, nil, "center", "center", ibFonts.regular_22 )

        ibCreateContentImage( 0, 0, 300, 280, "skin", skin_id, bg ):center( 0, -55 )
        ibCreateImage( 0, 0, 280, 280, "img/bg_" .. ( result or "fail" ) .. ".png", bg ):center( 0, -40 )

        if result == "arrest" then
            ibCreateImage( 0, 525, 1024, 53, "img/bg_cash.png", bg ):center_x( )
            local lbl_price = ibCreateLabel( 600, 535, 0, 0, format_price( PRICES_FOR_ORDERS[ 2 ].price ), bg, nil, nil, nil, nil, nil, ibFonts.bold_20 )
            ibCreateImage( lbl_price:ibGetAfterX( 10 ), 535, 25, 25, ":nrp_shared/img/money_icon.png", bg )
        else
            local text = result == "fail" and "Заказ был отозван" or "Заказ выполнен"
            ibCreateLabel( 0, 555, 1024, 0, text, bg, ibApplyAlpha( COLOR_WHITE, 50 ), nil, nil, "center", "center", ibFonts.regular_18 )
        end

        ibCreateButton( 0, 600, 100, 47, bg, "img/btn_ok", true ):center_x( )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.resultWindow, false )
        end )

        showCursor( true )
    end,

    orderMenu = function ( state, nickname )
        if not setStateComponent( ui.orderMenu, state ) then return end

        -- background
        ui.orderMenu = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

        -- window
        local window = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", ui.orderMenu ):center( )
        :ibOnDestroy( function ( )
            if ui.confirm then
                ui.confirm:destroy( )
            end
        end )

        -- close button
        ibCreateButton( 960, 30, 30, 30, window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.orderMenu, false )
        end )
        :ibData( "priority", 1 )

        -- header
        ibCreateLabel( 30, 30, 0, 0, "Заказ", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )

        -- balance
        ibCreateImage( 675, 27, 0, 0, ":nrp_shared/img/icon_account.png", window ):ibSetRealSize( )

        local lbl_balance = ibCreateLabel( 730, 27, 0, 0, "Ваш баланс:", window, 0xffffffff, nil, nil, "left", "top", ibFonts.regular_14 )
        local lbl_balance_amount = ibCreateLabel( lbl_balance:ibGetAfterX( 10 ), 24, 0, 0, "0", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_18 )
        local icon_balance_amount = ibCreateImage( 0, 24, 25, 25, ":nrp_shared/img/money_icon.png", window )

        local function UpdateBalance( )
            lbl_balance_amount:ibData( "text", format_price( localPlayer:getData( "money" ) ) )
            icon_balance_amount:ibData( "px", lbl_balance_amount:ibGetAfterX( 10 ) )
        end
        UpdateBalance( )
        icon_balance_amount:ibTimer( UpdateBalance, 500, 0 )

        ibCreateButton( 730, 53, 112, 10, window, ":nrp_shared/img/btn_header_add.png", nil, nil, 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, 2 )
        end )

        -- choose
        local choose_bg = ibCreateImage( 30, 123, 471, 616, "img/unselected_bg.png", window )
        local img = ibCreateImage( 0, 0, 471, 616, "img/order_by_clan.png", choose_bg )
        local label_price = ibCreateLabel( 292, 495, 0, 0, format_price( PRICES_FOR_ORDERS[1].price ), img, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_18 )
        ibCreateImage( label_price:ibGetAfterX( 10 ), 496, 25, 25, ":nrp_shared/img/money_icon.png", img )

        local area = ibCreateArea( 30, 123, 471, 616, window )
        :ibOnHover( function ( ) choose_bg:ibData( "texture", "img/selected_bg.png" ) end )
        :ibOnLeave( function ( ) choose_bg:ibData( "texture", "img/unselected_bg.png" ) end )

        ibCreateButton(
            145, 552, 182, 45, area,
            "img/btn_pay.png", "img/btn_pay_hover.png", "img/btn_pay_hover.png",
            nil, nil, 0xFFAAAAAA
        )
        :ibOnHover( function ( ) choose_bg:ibData( "texture", "img/selected_bg.png" ) end )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            ui.confirm = ibConfirm( {
                title = "ЗАКАЗ",
                text = "Вы уверены что хотите заказать голову " .. nickname .. "\nза " .. format_price( PRICES_FOR_ORDERS[1].price ) .. " рублей?" ,
                fn = function( self )
                    self:destroy( )
                    triggerServerEvent( "onPlayerOrderRequest", localPlayer, 1 )
                end
            } )
        end )

        local choose_bg2 = ibCreateImage( 522, 123, 471, 616, "img/unselected_bg.png", window )
        local img2 = ibCreateImage( 0, 0, 471, 616, "img/order_by_faction.png", choose_bg2 )
        local label_price2 = ibCreateLabel( 340, 495, 0, 0, format_price( PRICES_FOR_ORDERS[2].price ), img2, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_18 )
        ibCreateImage( label_price2:ibGetAfterX( 10 ), 496, 25, 25, ":nrp_shared/img/money_icon.png", img2 )

        local area2 = ibCreateArea( 522, 123, 471, 616, window )
        :ibOnHover( function ( ) choose_bg2:ibData( "texture", "img/selected_bg.png" ) end )
        :ibOnLeave( function ( ) choose_bg2:ibData( "texture", "img/unselected_bg.png" ) end )

        ibCreateButton(145, 552, 182, 45, area2, "img/btn_select.png", "img/btn_select_hover.png", "img/btn_select_hover.png", nil, nil, 0xFFAAAAAA )
        :ibOnHover( function ( ) choose_bg2:ibData( "texture", "img/selected_bg.png" ) end )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ui.confirm = ibConfirm( {
                title = "ЗАКАЗ",
                text = "Вы уверены что хотите передать ориентировку\nна " .. nickname .. " полиции за " .. format_price( PRICES_FOR_ORDERS[2].price ) .. " рублей? Судебные издержки возвращаются в случае неуспешной поимки",
                fn = function( self )
                    self:destroy( )
                    triggerServerEvent( "onPlayerOrderRequest", localPlayer, 2 )
                end
            } )

            ibClick( )
        end )

        showCursor( true )
    end
}