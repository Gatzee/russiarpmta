local UI_elements

function ShowRewardUI( state, reward, reward_type )
    if state then
        ShowRewardUI( false )

        UI_elements = { }

        UI_elements.reward_bg = ibCreateBackground( 0xdd394a5c, _, true ):ibData( "alpha", 0 )
        ibCreateImage( 0, 0, 800, 570, "img/brush.png", UI_elements.reward_bg ):center( 0, 0 )

        UI_elements.lbl_title = ibCreateLabel( 0, 0, 0, 0, "Поздравляем!\nТы выполнил условия акции, забери награду!", UI_elements.reward_bg, 0xFFFFFFFF, 1, 1, "center" )
        :ibData( "font", ibFonts.semibold_16 )
        :center( 0, -180 )

        UI_elements.area_money = ibCreateArea( 0, 0, 0, 0, UI_elements.reward_bg )
        UI_elements.lbl_money = ibCreateLabel( 0, 0, 0, 0, format_price( reward ), UI_elements.area_money )
        :ibData( "font", ibFonts.semibold_72 )

        UI_elements.img_money = ibCreateImage( UI_elements.lbl_money:width( ) + 20, 15, 90, 75, "img/money_" .. reward_type .. "_big.png", UI_elements.area_money )

        UI_elements.area_money
        :ibData( "sx", UI_elements.lbl_money:width( ) + 20 + UI_elements.img_money:width( ) )
        :center( 0, -70 )
        
        UI_elements.lbl_hint = ibCreateLabel( 0, 0, 0, 0, "Ты ответил на все вопросы", UI_elements.reward_bg, 0xaaFFFFFF, 1, 1, "center" )
        :ibData( "font", ibFonts.regular_14 )
        :center( 0, 105 )
        
        UI_elements.btn_take = ibCreateButton(	0, 0, 0, 0, UI_elements.reward_bg,
    "img/btn_take.png", "img/btn_take.png", "img/btn_take.png",
    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibSetRealSize( )
        :center( 0, 170 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowRewardUI( false )
        end )
        
        UI_elements.reward_bg:ibAlphaTo( 255, 500 )

        showCursor( true )

        playSound( ":nrp_shop/sfx/reward_small.mp3" )
    else
        DestroyTableElements( UI_elements )
        UI_elements = nil

        if not IsOneWindow( ) then
            showCursor( false )
        end
    end
end

function ShowQuestionFormRewardUI_handler( reward, reward_type )
    ShowRewardUI( true, reward, reward_type )

    -- add delay for bad connection
    Timer( function ( )
        ShowFormWindow( false )
    end, 1000, 1 )
end
addEvent( "ShowQuestionFormRewardUI", true )
addEventHandler( "ShowQuestionFormRewardUI", resourceRoot, ShowQuestionFormRewardUI_handler )

function IsRewardUIOpen( )
    return UI_elements ~= nil
end