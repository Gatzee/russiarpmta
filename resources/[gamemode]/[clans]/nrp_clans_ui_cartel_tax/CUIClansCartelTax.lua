loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShClans" )
Extend( "ShUtils" )
Extend( "ib" )

ibUseRealFonts( true )

local UI = { }

function ShowClanCartelTaxUI( state, cartel_name, expires_date )
    if state then
        ShowClanCartelTaxUI( false )
        ibInterfaceSound()

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowClanCartelTaxUI, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 95 ) ):center( )

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 90, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                      ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
        UI.head_lbl = ibCreateLabel( 30, 0, 0, UI.head_bg:ibData( "sy" ), "Налог", UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
        
        -- UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
        --     :ibOnClick( function( button, state )
        --         if button ~= "left" or state ~= "up" then return end
        --         ibClick( )
        --         ShowClanCartelTaxUI( false )
        --     end )
		
		ibCreateButton( UI.head_bg:ibGetAfterX( -30 - 102 ), 30, 102, 31, UI.bg, "img/btn_info.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
			:ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowCartelTaxInfo( )
            end )
        
        
        UI.area_timer = ibCreateArea( 0, 44, 0, 0, UI.head_bg )
        UI.lbl_text = ibCreateLabel( 0, 2, 0, 0, "Осталось времени: ",
                UI.area_timer, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_14 )
        UI.lbl_timer = ibCreateLabel( UI.lbl_text:ibGetAfterX( ), 0, 0, 0, getTimerString( expires_date, true ),
                UI.area_timer, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
        UI.area_timer:ibData( "px", UI.head_bg:ibGetAfterX( -30 - 102 - 20 - UI.lbl_timer:ibGetAfterX( ) ) )
            :ibTimer( function( self )
                local timer_str, time_left = getTimerString( expires_date, true )
                if time_left == 0 then
                    ShowClanCartelTaxUI( false )
                else
                    UI.lbl_timer:ibData( "text", timer_str )
                    self:ibData( "px", UI.head_bg:ibGetAfterX( -30 - 102 - 20 - UI.lbl_timer:ibGetAfterX( ) ) )
                end
            end, 1000, 0 )

        UI.body = ibCreateArea( 0, UI.head_bg:ibGetAfterY( ), UI.bg:width( ), 0, UI.bg )

        ibCreateImage( 0, 0, 1003, 648, "img/bg.png", UI.body )
            :ibData( "disabled", true )
            :center_x( 1 )

        ibCreateLabel( 0, 27, 0, 0, "Картель \"" .. ( cartel_name or "Groove Street" ) .. "\"",
                UI.body, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
            :center_x( )
        
        UI.bg_left_hover = ibCreateImage( 28, 117, 476, 533, "img/bg_panel_hover.png", UI.body )
            :ibData( "priority", -1 )
            :ibData( "alpha", 0 )
            :ibOnHover( function() source:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnLeave( function() source:ibAlphaTo( 0, 500, "OutQuad" ) end)

        UI.btn_create = ibCreateButton( 154, UI.bg_left_hover:ibGetAfterY( -2 - 30 - 45 ), 226, 45, UI.body, 
                "img/btn_transfer.png", _, _, 0, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnHover( function() UI.bg_left_hover:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanCartelTaxUI( false )
                triggerServerEvent( "onPlayerCartelTaxResponse", localPlayer, true )
            end )
        
        UI.bg_right_hover = ibCreateImage( 521, 117, 476, 533, "img/bg_panel_hover.png", UI.body )
            :ibData( "priority", -1 )
            :ibData( "alpha", 0 )
            :ibOnHover( function() source:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnLeave( function() source:ibAlphaTo( 0, 500, "OutQuad" ) end)

        UI.btn_join = ibCreateButton( 646, UI.bg_right_hover:ibGetAfterY( -2 - 30 - 45 ), 226, 45, UI.body, 
                "img/btn_not_transfer.png", _, _, 0, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnHover( function() UI.bg_right_hover:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowClanCartelTaxUI( false )
                triggerServerEvent( "onPlayerCartelTaxResponse", localPlayer, false )
            end )

        local py = UI.bg:ibData( "py" )
        UI.bg:ibBatchData( { py = py - 100, alpha = 0 } )
            :ibAlphaTo( 255, 500 )
            :ibMoveTo( _, py, 500 )
        
        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "ShowClanCartelTaxUI", true )
addEventHandler( "ShowClanCartelTaxUI", root, ShowClanCartelTaxUI )

function onClientCartelRequestMoney_handler( cartel_clan_id, expires_date )
    local cartel_name = GetClanName( cartel_clan_id ) or "Groove Street"
    if localPlayer:GetClanRole( ) == CLAN_ROLE_LEADER then
        ShowClanCartelTaxUI( true, cartel_name, expires_date )
    else
        localPlayer:PhoneNotification( {
            title = "Картель",
            msg = "Картель \"" .. cartel_name .. "\" запросил налог с вашего клана. Свяжитесь с вашим лидером для принятия решения.",
        } )
    end
end
addEvent( "onClientCartelRequestMoney", true )
addEventHandler( "onClientCartelRequestMoney", root, onClientCartelRequestMoney_handler )

function HideClanCartelTaxUI( )
    ShowClanCartelTaxUI( false )
end
addEvent( "HideAllClanUI", true )
addEventHandler( "HideAllClanUI", root, HideClanCartelTaxUI )

local TAX_RULES = {
    "Картель может запросить у Клана налог на 25% от его общака (но не превышая указанных лимитов по налогу).",
    "Если у Клана меньше 3 000 000р., то такой Клан считается слишком мелким и Картель не может запросить налог у такого Клана.",
    "Время, когда Картель может запросить налог: по окончании сезона, в воскресенье с 12:00 до 18:00 мск.",
    "Если Клан, у которого был запрошен налог, добровольно согласился его оплатить, то в общак Картеля поступит 25% от общака клана (но не превышая указанных лимитов по налогу).",
    "Два Картеля не могут запросить налог у одного и того же Клана.",
    "Если Клан, у которого был запрошен налог, отказался его выплачивать, то Картель может объявить войну такому Клану. После чего через событие \"Война за общак\" Картель может ограбить такой Клан на 50% от общака в случае победы (но не превышая указанные лимиты).",
    "Если Клан, которому была объявлена \"Война за общак\", побеждает в событии, то все деньги общака остаются внутри такого Клана.",
    "После того, как Картель запросил налог у Клана, у лидера такого клана есть 2 часа на принятие решения.",
    "Если лидер Клана, у которого был запрошен налог, не смог принять решение по налогу в течение 2-х часов после запроса, то добровольный налог в 25% от общака Клана будет списан автоматически (но не превышая указанные лимиты).",
    "Начиная с момента, когда Картель запросил налог с Клана, и до момента, когда добровольный налог будет уплачен или не пройдет \"Война за общак\", деньги общака такого Клана будут \"заморожены\".",
    "Время, когда Картель может объявить \"Войну за общак\": по окончании сезона, в воскресенье с 12:00 до 21:00 мск",
    "В том случае, если Картель не успел в указаное время объявить \"Войну за общак\" Клану, который отказался платить налог, то все обязательства такого клана будут отменены.",
    "Роли в Картеле, которые могут запрашивать налог: Лидер, модераторы.",
    "Количество кланов, у которых можно запросить налог за сезон - 3 Клана (для одного Картеля)",
    "Несгораемая сумма общака клана - 3 000 000р.",
    "Максимальная сумма на выплату добровольного налога - 10 000 000р.",
    "Максимальная сумма ограбления клана - 20 000 000р.",

    -- "Картель может запросить у Клана налог на 25% от его общака.", -- (но не превышая указанных лимитов по налогу).",
    -- "Если у Клана в общаке менее 3 000 000р., то такой Клан считается слишком мелким и Картель не может запросить у него налог.",
    -- "Время, когда Картель может запросить налог: по окончании сезона, в воскресенье с 12:00 до 18:00 мск.",
    -- "После того, как Картель запросил налог у Клана, у лидера этого Клана есть 2 часа на принятие решения.",
    -- "Если Клан не успел принять решение в течение 2-х часов после запроса, то налог будет выплачен автоматически.", -- (но не превышая указанные лимиты).",
    -- "Если Клан согласился добровольно выплатить налог, то 25% денег из общака Клана будут перечислены в общак Картеля.", -- (но не превышая указанных лимитов по налогу).",

    -- "Если Клан отказался его выплачивать, то Картель может объявить войну этому Клану. После чего Картель и Клан сражаются в событии \"Война за общак\".",
    -- "Если Картель побеждает в \"Войне за общак\", то он грабит 50% общака Клана.", -- (но не превышая указанные лимиты).",
    -- "Если Клан побеждает в \"Войне за общак\", то все деньги общака остаются внутри этого Клана.",
    -- "Время, когда Картель может объявить \"Войну за общак\": по окончании сезона, в воскресенье с 12:00 до 21:00 мск.",
    -- "Если Картель не успел в указаное время объявить \"Войну за общак\" Клану, который отказался платить налог, то все обязательства клана будут отменены.",

    -- "После того, как Картель запросил налог с Клана, деньги в общаке этого Клана будут \"заморожены\" до тех пор, пока не будет выплачен налог или не пройдет \"Война за общак\".",
    -- "Роли в Картеле, которые могут запрашивать налог: Лидер, модераторы.",
    -- "Один Картель может запросить налог только у 3-х кланов за сезон.",
    -- "Два Картеля не могут запросить налог у одного и того же Клана.",
    -- "Несгораемая сумма общака клана - 3 000 000р.",
    -- "Максимальная сумма на добровольную выплату налога - 10 000 000р.",
    -- "Максимальная сумма ограбления клана - 20 000 000р.",
}

function GetTaxRules( )
    return TAX_RULES
end

function ShowCartelTaxInfo( )
    if isElement( UI.info_bg ) then
        UI.info_bg:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        return
    end

    UI.info_bg = ibCreateImage( 0, 0, UI.bg:width( ), UI.bg:height( ) - UI.head_bg:ibGetAfterY( ), nil, UI.body, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )

    ibCreateLabel( 0, 0, UI.info_bg:width( ), 80, "Правила сбора налога Картелем у кланов", UI.info_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_20 )
    
    local pane_head_bg = ibCreateImage( 0, 80, UI.info_bg:width( ), 40, _, UI.info_bg, 0xff3f5266 )
    ibCreateLabel( 0, 0, 44, 40, "№", pane_head_bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.regular_12 )
    ibCreateLabel( 60, 0, 0, 40, "Описание правил", pane_head_bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_12 )
    
    ibCreateImage( 0, 120, UI.info_bg:ibData( "sx" ), UI.info_bg:ibData( "sy" ) - 120 - 30 - 42 - 30, _, UI.info_bg, 0xff1f2934 )
    local scrollpane, scrollbar = ibCreateScrollpane( 0, 120, 
        UI.info_bg:ibData( "sx" ), UI.info_bg:ibData( "sy" ) - 120 - 30 - 42 - 30, 
        UI.info_bg, { scroll_px = -20 }
    )
    scrollbar:ibSetStyle( "slim_nobg" )

    local row_sx = UI.info_bg:width( )
    local row_sy = 50
    for i, text in pairs( TAX_RULES ) do
        local bg_row = ibCreateImage( 0, ( i - 1 ) * row_sy, row_sx, row_sy, _, scrollpane, 0x40314050 * ( ( i - 1 ) % 2 ) )
        ibCreateLabel( 0, 0, 44, row_sy, i, bg_row, _, 1, 1, "center", "center", ibFonts.regular_14 )
        ibCreateLabel( 60, 0, row_sx - 60 - 30, row_sy, text, bg_row, _, 1, 1, "left", "center", ibFonts.regular_14 )
            :ibData( "wordbreak", true )
    end

    scrollpane:AdaptHeightToContents( )
    scrollbar:UpdateScrollbarVisibility( scrollpane )

    ibCreateLine( 45, 80, _, scrollpane:ibGetAfterY( ), ibApplyAlpha( COLOR_WHITE, 10 ), 1, UI.info_bg )

    local btn_hide = ibCreateButton( 0, UI.info_bg:height( ) - 30 - 42, 108, 42, UI.info_bg, 
            ":nrp_clans_ui_manage/img/shop/btn_hide.png", ":nrp_clans_ui_manage/img/shop/btn_hide_hover.png", ":nrp_clans_ui_manage/img/shop/btn_hide_hover.png", _, _, 0xFFAAAAAA )
        :center_x( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            UI.info_bg:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        end )
end