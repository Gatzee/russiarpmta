Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI

function ShowFormInfo( state, conf )
    if state then
        ShowFormInfo( false )

        UI = { }
        UI.black_bg = ibCreateBackground( _, _, 0xaa000000 )

        local elastic_duration  = 2200
        local alpha_duration    = 700

        UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg.png", UI.black_bg )
        :ibSetRealSize( )
        :center( 0, -100 )
        :ibData( "alpha", 0 )
        :ibMoveTo( 0, 100, elastic_duration, "OutElastic", true ):ibAlphaTo( 255, alpha_duration )

        UI.button_close = ibCreateButton( UI.bg:ibData( "sx" ) - 24 - 26, 24, 24, 24, UI.bg,
  ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
   0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowFormInfo( false )
        end )

        local reward_type = conf.reward_type == "hard" and "донат валюты" or "игровых рублей"
        local text = "Ответь на все вопросы и получи " .. format_price( conf.reward ) .. " " .. reward_type

        ibCreateLabel( 0, 0, 0, 0, text, UI.bg, nil, nil, nil, "center", "center", ibFonts.bold_18 ):center( 0, 40 )
        local lbl_value = ibCreateLabel( 0, 0, 0, 0, format_price( conf.reward ), UI.bg, nil, nil, nil, "center", "center", ibFonts.bold_100 )
        local img_icon = ibCreateImage( 0, 0, 90, 75, "img/money_" .. conf.reward_type .. "_big.png", UI.bg ):center( 50, -40 )

        lbl_value:center( - 50, -40 )
        img_icon:center( 5 + lbl_value:width( ) / 2, -40 )

        UI.btn_more = ibCreateButton( 0, 502, 0, 0, UI.bg,
  "img/btn_more.png", "img/btn_more.png", "img/btn_more.png",
  0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibSetRealSize( )
        :center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowFormInfo( false )
            ShowFormWindow( true, conf.url )
        end )
    
        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil

        if not IsOneWindow( ) then
            showCursor( false )
        end
    end
end
addEvent( "onQuestionShowInfo", true )
addEventHandler( "onQuestionShowInfo", resourceRoot, ShowFormInfo )

function IsFormInfoOpen( )
    return UI ~= nil
end

function IsOneWindow( )
    return IsFormInfoOpen( ) or IsFormWindowOpen( ) or IsRewardUIOpen( )
end