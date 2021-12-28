local UI_elements

function ShowRewardUI( state )
    if state then
        ShowRewardUI( false )

        UI_elements = { }
        local x, y = guiGetScreenSize()

        UI_elements.reward_bg = ibCreateBackground( 0xdd394a5c, _, true ):ibData( "alpha", 0 )
        ibCreateImage( 0, 0, 800, 570, "img/brush.png", UI_elements.reward_bg ):center( 0, 0 )

        UI_elements.lbl_title
            = ibCreateLabel( 0, 0, 0, 0, "Поздравляем!\nВы выполнили условия акции, заберите награду", UI_elements.reward_bg, 0xFFFFFFFF, 1, 1, "center" )
            :ibData( "font", ibFonts.semibold_16 )
            :center( 0, -180 )

        UI_elements.area_money = ibCreateArea( 0, 0, 0, 0, UI_elements.reward_bg )
        UI_elements.lbl_money
            = ibCreateLabel( 0, 0, 0, 0, "250 000", UI_elements.area_money )
            :ibData( "font", ibFonts.semibold_75 )

        UI_elements.img_money
            = ibCreateImage( UI_elements.lbl_money:width( ) + 20, 15, 90, 75, "img/money_big.png", UI_elements.area_money )

        UI_elements.area_money
            :ibData( "sx", UI_elements.lbl_money:width( ) + 20 + UI_elements.img_money:width( ) )
            :center( 0, -70 )
        
        UI_elements.lbl_hint
            = ibCreateLabel( 0, 0, 0, 0, "Вы достигли 6 уровня!", UI_elements.reward_bg, 0xaaFFFFFF, 1, 1, "center" )
            :ibData( "font", ibFonts.regular_14 )
            :center( 0, 105 )
        
        UI_elements.btn_take 
            = ibCreateButton(	0, 0, 0, 0, UI_elements.reward_bg,
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
        showCursor( false )
    end
end

function Show7SRewardUI_handler( )
    ShowRewardUI( true )
end
addEvent( "Show7SRewardUI", true )
addEventHandler( "Show7SRewardUI", root, Show7SRewardUI_handler )