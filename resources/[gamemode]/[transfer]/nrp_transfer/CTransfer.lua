local CONST_HEADER_TEXT = [[Перенос персонажа на новый сервер - $name]]
local CONST_DEFAULT_DESC_TEXT = [[Твой новый сервер - $name. Переходи, получай бонусы и наслаждайся спокойной игрой на менее загруженном сервере!]]

function ApplyTransferToText( text, transfer )
    return utf8.gsub( utf8.gsub( text, "%$(%w+)", transfer ), "%$(%w+)", transfer.server_config )
end

local UI

-- finish_date, is_first_time, exp_bonus, job_bonus, transfer
function onClientPlayerTransferShow_handler( finish_date, is_first_time, exp_bonus, job_bonus, duration, transfer )
    local data = { finish_date = finish_date, exp_bonus = exp_bonus, job_bonus = job_bonus, duration = duration, transfer = transfer }
    setElementData( localPlayer, "account_transfer", data, false )
    if is_first_time then
        ShowTransferUI( true, data )
    end
end
addEvent( "onClientPlayerTransferShow", true )
addEventHandler( "onClientPlayerTransferShow", root, onClientPlayerTransferShow_handler )

function onClientPlayerShowTransferAgain_handler( )
    local data = getElementData( localPlayer, "account_transfer" )
    if data and data.finish_date then
        data.from_f4 = true
        ShowTransferUI( true, data )
    end
end
addEvent( "onClientPlayerShowTransferAgain" )
addEventHandler( "onClientPlayerShowTransferAgain", root, onClientPlayerShowTransferAgain_handler )

function onClientPlayerTransferHide_handler( )
    setElementData( localPlayer, "account_transfer", false, false )
    ShowTransferUI( false )
end
addEvent( "onClientPlayerTransferHide", true )
addEventHandler( "onClientPlayerTransferHide", root, onClientPlayerTransferHide_handler )

function InitModules( )
    if not _MODULES_LOADED then
        loadstring( exports.interfacer:extend( "Interfacer" ) )( )
        Extend( "ib" )
        Extend( "ShUtils" )
        Extend( "CPlayer" )
        ibUseRealFonts( true )
        _MODULES_LOADED = true
    end
end

function ShowTransferUI( state, conf )
    InitModules( )

    if state then
        ShowTransferUI( false )

        UI = { }

        UI.black_bg = ibCreateBackground( _, _, true ):ibData( "priority", 5 )
        UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg_info.png", UI.black_bg ):ibSetRealSize( ):center( )

        ibCreateLabel( 30, 33, 550, 0, ApplyTransferToText( CONST_HEADER_TEXT, conf.transfer ), UI.bg, 0xffffffff, _, _, "left", "top", ibFonts.bold_20 )
        ibCreateLabel( 30, 148, 620, 0, ApplyTransferToText( conf.transfer.text_desc or CONST_DEFAULT_DESC_TEXT, conf.transfer ), UI.bg, ibApplyAlpha( 0xffffffff, 75 ), _, _, "left", "top", ibFonts.regular_16 ):ibData( "wordbreak", true )

        UI.btn_close = ibCreateButton(  UI.bg:width( ) - 24 - 24, 33, 24, 24, UI.bg,
                            ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowTransferUI( false )
            end )

        local text = ""
        local give_offers = conf.transfer.give_offers
        if give_offers and next( give_offers ) then
            if give_offers.premium_3d then
                text = "Премиум на 3 дня в подарок и "
            end
            local count = table.size( give_offers )
            text = text .. ( count == 1 and " персональная акция" or ( count .. " персональные акции" ) )
        end
        -- local text = "%s ко всему игровому опыту и %s к зарплате на работах в течение %s дней \nпосле перехода на новый сервер"
        -- text = string.format( text, conf.exp_bonus .. "%", conf.job_bonus .. "%", conf.duration )
        ibCreateLabel( 172, 662, 430, 0, text, UI.bg, ibApplyAlpha( 0xffffffff, 75 ), _, _, "left", "top", ibFonts.regular_14 )

        UI.btn_transfer = ibCreateButton(  845, 642, 0, 0, UI.bg, "img/btn_transfer.png", "img/btn_transfer.png", "img/btn_transfer.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                
                ShowTransferUI( false )
                triggerServerEvent( "onPlayerRequestTransferList", resourceRoot, conf.from_f4 )
            end )

        UI.bg:ibData( "alpha", 0 ):ibData( "py", UI.bg:ibData( "py" ) + 100 ):ibAlphaTo( 255, 300 ):ibMoveTo( _, UI.bg:ibData( "py" ) - 100, 500 )

        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil

        showCursor( false )
    end
end