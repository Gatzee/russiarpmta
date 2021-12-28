local CONST_FINISHED_TEXT = [[Поздравляем, Ваш персонаж был успешно перенесен на новый сервер -  “$name”. Сейчас проходит активное формирование фракций и в ближайшее время количество игроков заполнится для комфортной и интересной игры. Просим Вас подождать.]]
local CONST_HEADER_TEXT = [[Поздравляем, Ваш новый сервер - $name]]
local UI

function ShowTransferFinishedUI( state, conf )
    InitModules( )

    if state then
        ShowTransferFinishedUI( false )

        UI = { }

        UI.black_bg = ibCreateBackground( _, _, true ):ibData( "priority", 5 )
        UI.bg = ibCreateImage( 0, 0, 0, 0, "img/finished_north.png", UI.black_bg ):ibSetRealSize( ):center( )

        ibCreateLabel( 30, 33, 550, 0, ApplyTransferToText( CONST_HEADER_TEXT, conf.transfer ), UI.bg, 0xffffffff, _, _, "left", "top", ibFonts.bold_20 )

        local server = conf.transfer.server_config

        ibCreateLabel( 512, 368, 0, 0, server.name, UI.bg, 0xffffffff, _, _, "center", "center", ibFonts.bold_30 )
        
        
        if not conf or not conf.welcome then
            local timer = 10
            local lbl_timeleft = ibCreateLabel( 0, 555, 0, 0, "", UI.bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "center", "top", ibFonts.regular_18 ):center_x( )
            local function update( )
                lbl_timeleft:ibData( "text", "Вы будете автоматически перенаправлены на новый сервер через " .. timer .. " сек." )

                if timer == 0 then
                    lbl_timeleft:ibKillTimers( )
                end

                timer = timer - 1
            end
            update( )
            lbl_timeleft:ibTimer( update, 1000, 0 )
        else
            ibCreateLabel( 100, 550, UI.bg:width( ) - 200, 0, ApplyTransferToText( conf.transfer.text_finish or CONST_FINISHED_TEXT, conf.transfer ), UI.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "center", "top", ibFonts.regular_18 ):ibData( "wordbreak", true )
        end

        ibCreateImage( 0, 643, 0, 0, "img/btn_thanks.png", UI.bg ):ibSetRealSize( ):center_x( ):ibData( "alpha", 200 )
            :ibOnHover( function( ) source:ibAlphaTo( 255 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowTransferFinishedUI( false )

                if not conf or not conf.welcome then
                    triggerServerEvent( "onPlayerAcceptConnect", localPlayer )
                end
            end )

        UI.bg:ibData( "alpha", 0 ):ibData( "py", UI.bg:ibData( "py" ) + 100 ):ibAlphaTo( 255, 300 ):ibMoveTo( _, UI.bg:ibData( "py" ) - 100, 500 )
        
        showCursor( true )
    else
        showCursor( false )
        DestroyTableElements( UI )
        UI = nil
    end
end

function ShowWelcomeTransferWindow_handler( transfer )
    ShowTransferFinishedUI( true, { welcome = true, transfer = transfer } )
end
addEvent( "ShowWelcomeTransferWindow", true )
addEventHandler( "ShowWelcomeTransferWindow", root, ShowWelcomeTransferWindow_handler )