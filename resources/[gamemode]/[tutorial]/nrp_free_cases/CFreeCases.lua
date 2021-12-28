loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ib" )

local UI_elements

function ShowFreeCaseMenu( state, data )
    if state then
        ShowFreeCaseMenu( false )
        
        UI_elements = {}
        UI_elements.black_bg = ibCreateBackground( 0x99000000, _, true ):ibData( "alpha", 0 )

        local bg = ibCreateImage( 0, 0, 0, 0, "img/bg_" .. data.case_id  .. ".png", UI_elements.black_bg ):ibSetRealSize():center()
        ibCreateButton(	436, 698, 154, 40, bg, "img/btn_desc.png", "img/btn_desc_hover.png", _, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowFreeCaseMenu( false )
                triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases", "get_free_quest_case" )
            end, false )

        local py = bg:ibData( "py" )
        bg:ibData( "py", py - 100 )
        bg:ibMoveTo( _, py, 250 )
        UI_elements.black_bg:ibAlphaTo( 255, 250 )

        showCursor( true )
    elseif UI_elements and isElement( UI_elements.black_bg ) then
        destroyElement( UI_elements.black_bg )
        showCursor( false )
    end
end


function onClientShowFreeCaseMenu_handler( data )
    if isTimer( CHECK_ANY_WINDOWS_TMR ) then return end

    CHECK_ANY_WINDOWS_TMR = setTimer( function( )
        if ibIsAnyWindowActive( ) then return end
        
        killTimer( CHECK_ANY_WINDOWS_TMR )
        ShowFreeCaseMenu( true, data )
    end, 1000, 0 )
end
addEvent( "onClientShowFreeCaseMenu", true )
addEventHandler( "onClientShowFreeCaseMenu", root, onClientShowFreeCaseMenu_handler )