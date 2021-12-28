local UI_elements = nil

function ShowPaymentWindow( state, conf )
    if state then
        UI_elements = { }

        local px, py, sx, sy = 20, 20, _SCREEN_X - 20 * 2, _SCREEN_Y - 20 * 2
        
        if UI_elements.loading then UI_elements.loading:destroy( ) UI_elements.loading = nil end
        UI_elements.loading = ibLoading( )
        
        UI_elements.browser = ibCreateBrowser( px, py + 100, sx, sy, _, false, false ):ibData( "alpha", 0 )
            :ibOnCreated( function( )
                source:Navigate( conf.url .. "/" .. conf.pmethod, conf.post_data )
            end )
            :ibOnDocumentReady( function( )
                if UI_elements.loading then UI_elements.loading:destroy( ) UI_elements.loading = nil end
                source:ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )
                
                -- Кнопка "Проблема с оплатой?" - должна быть только после загрузки страницы
                if conf.pmethod == "gamemoney" then
                    local bsx, bsy = 446, 70
                    local bpx, bpy = sx - bsx - 10, sy - bsy - 10
                    ibCreateButton( bpx, bpy, bsx, bsy, UI_elements.browser, ":nrp_shared/img/payments/change_hover.png", ":nrp_shared/img/payments/change.png", ":nrp_shared/img/payments/change_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        source:destroy( )

                        conf.pmethod = "unitpay"
                        UI_elements.browser:Navigate( conf.url  .. "/" .. conf.pmethod, conf.post_data )
                    end )
                end
            end )

        ibCreateButton( sx - 24 - 30, 25, 24, 24, UI_elements.browser, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFF000000, 0xFF333333, 0xFF555555 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowPaymentWindow( false )
        end )

        showCursor( true, UI_elements.browser )
    elseif UI_elements then
        DestroyTableElements( UI_elements )
        if UI_elements.loading then UI_elements.loading:destroy( ) end
        UI_elements = nil
        showCursor( false )
    end
end

function SetupPaymentWindow( pack_id, sum, url )
    local data = {
        pack_id     = pack_id,
        client_id   = localPlayer:GetClientID( ),
        game_server = localPlayer:getData( "_srv" )[ 1 ],
        sum         = sum,
    }
    local conf = {
        post_data = toJSON( data, true ):sub( 2, -2 ),
        url       = url,
        pmethod   = localPlayer:GetPMethod( ),
    }
    ShowPaymentWindow( true, conf )
end
