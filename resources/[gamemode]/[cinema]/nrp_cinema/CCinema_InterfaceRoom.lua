local UI_elements = { }
local px, py, sx, sy
local conf = { }

function ShowRoomUI_handler( state, cnf )
    if state then
        ShowRoomUI_handler( false )

        conf = cnf or { }

        UI_elements.bg_texture = dxCreateTexture( "img/bg_cinema.png" )
        local x, y = guiGetScreenSize( )
        sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        px, py = x / 2 - sx / 2, y / 2 - sy / 2

        UI_elements.black_bg = ibCreateBackground( 0x99000000, ShowRoomUI_handler, true, true )
        UI_elements.bg = ibCreateImage( px, py - 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg ):ibData( "alpha", 0 )

        -- Закрыть
        UI_elements.btn_close
            = ibCreateButton(   sx - 24 - 24, 24, 22, 22, UI_elements.bg,
                                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowRoomUI_handler( false )
            end )

        -- Изменение плейлиста
        UI_elements.btn_playlist_edit
            = ibCreateButton(   644, 196, 126, 30, UI_elements.bg,  
                                "img/btn_playlist_edit.png", "img/btn_playlist_edit.png", "img/btn_playlist_edit.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                --triggerServerEvent( "onCinemaRequestPlayerPlaylist", resourceRoot )
                ShowRoomUI_handler( false )
                --iprint( "OPENING", conf, conf.is_vip )
                ShowPlaylistUI_handler( true, { is_vip = conf.is_vip } )
            end )

        -- Просмотр РП ролика
        UI_elements.btn_tutorial
            = ibCreateButton(   592, 21, 126, 30, UI_elements.bg,  
                                "img/btn_tutorial.png", "img/btn_tutorial.png", "img/btn_tutorial.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                local bg = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, _, UI_elements.bg, 0xcc000000 )

                local width = _SCREEN_X
                local nsx, nsy = width, math.floor( width / 16 * 9 )
                local npx, npy = sx / 2 - nsx / 2, sy / 2 - nsy / 2

                local url = URLAppendParameters( PROXY_URL, { url = "wKbYYUfU2yk" } )

                ibCreateBrowser( npx, npy, nsx, nsy, bg, false, false )
                    :ibOnCreated( function( )
                        source:Navigate( url )
                    end )

                ibCreateButton( npx + nsx - 22, npy + 2, 22, 22, bg,
                                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        if isElement( bg ) then destroyElement( bg ) end
                    end )
            end )

        -- Пополнение кассы
        UI_elements.btn_cash_add
            = ibCreateButton(   303, 87, 126, 30, UI_elements.bg,
                                "img/btn_cash_add.png", "img/btn_cash_add.png", "img/btn_cash_add.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                if input then input:destroy() end
                input = ibInput(
                    {
                        title = "Пополнение кассы", 
                        text = "",
                        edit_text = "Введите сумму для пополнения кассы",
                        btn_text = "ПОПОЛНИТЬ",
                        fn = function( self, text )
                            local amount = tonumber( text )
                            if not amount or amount ~= math.floor( amount ) then
                                localPlayer:ErrorWindow( "Неверная сумма для пополнения!" )
                                return
                            end

                            if localPlayer:GetMoney( ) < amount then
                                localPlayer:ErrorWindow( "Недостаточно средств!" )
                                return
                            end

                            triggerServerEvent( "onCinemaAddMoneyReqeuest", resourceRoot, amount )
                            self:destroy()
                        end
                    }
                )

                local max_sum = localPlayer:GetMoney( )
                local bg = input.elements.bg
                
                local lbl_balance = ibCreateLabel( 38, 105, 0, 0, "Ваш текущий баланс:", bg ):ibBatchData( { color = 0xffffdf93, font = ibFonts.regular_12 } )
                local lbl_amount = ibCreateLabel( 38 + lbl_balance:width( ) + 10, 105, 0, 0, format_price( conf.balance or 0 ), bg ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_12 } )
                ibCreateImage( 38 + lbl_balance:width( ) + 10 + lbl_amount:width( ) + 10, 103, 24, 24, ":nrp_shared/img/money_icon.png", bg )
                ibCreateLabel( input.sx - 54, 166, 0, 0, "Макс. сумма - " .. format_price( max_sum ), bg, 0xFFBBBBBB ):ibBatchData( { font = ibFonts.regular_10, align_x = "right" } )
            end )

        UpdateBalanceInfo( conf.balance )

        -- Общая длительность плейлиста
        local duration = 0
        for i, v in pairs( PLAYLIST ) do duration = duration + v.duration_seconds end
        ibCreateLabel( 259, 192, 0, 0, GetReadableDuration( duration ), UI_elements.bg, _, _, _, "left", "center", ibFonts.bold_16 )

        -- Стоимость плейлиста
        local cost = 0
        for i, v in pairs( PLAYLIST ) do cost = cost + GetVideoCost( v, conf.is_vip ) end
        local lbl = ibCreateLabel( 288, 228, 0, 0, cost, UI_elements.bg, _, _, _, "left", "center", ibFonts.bold_16 )
        ibCreateImage( lbl:ibGetAfterX( 5 ), lbl:ibGetCenterY( ) - 12, 24, 24, ":nrp_shared/img/money_icon.png", UI_elements.bg )

        -- Количество перед игроком
        ibCreateLabel( 234, 263, 0, 0, conf.before_in_queue or "-", UI_elements.bg, _, _, _, "left", "center", ibFonts.bold_16 )

        -- Отметка вип зала
        if conf.is_vip then ibCreateLabel( 706, 102, 0, 0, "VIP Зал", UI_elements.bg, _, _, _, _, "center", ibFonts.bold_18 ) end

        UI_elements.bg:ibAlphaTo( 255, 500 ):ibMoveTo( px, py, 700 )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        showCursor( false )
    end
end
addEvent( "ShowRoomUI", true )
addEventHandler( "ShowRoomUI", root, ShowRoomUI_handler )

function UpdateBalanceInfo( balance )
    if not isElement( UI_elements.bg ) then return end

    conf.balance = balance

    DestroyTableElements( { UI_elements.lbl_balance, UI_elements.icon_balance } )

    local lbl = ibCreateLabel( 206, 101, 0, 0, format_price( balance or 0 ), UI_elements.bg, _, _, _, "left", "center", ibFonts.bold_18 )
    local icon = ibCreateImage( lbl:ibGetAfterX( 5 ), lbl:ibGetCenterY( ) - 12, 24, 24, ":nrp_shared/img/money_icon.png", UI_elements.bg )

    UI_elements.btn_cash_add:ibData( "px", icon:ibGetAfterX( 20 ) )

    UI_elements.lbl_balance = lbl
    UI_elements.icon_balance = icon
end
addEvent( "onCinemaUpdateBalanceInfo", true )
addEventHandler( "onCinemaUpdateBalanceInfo", root, UpdateBalanceInfo )