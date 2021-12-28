function CreateCases( data )
    UI_elements.bg_cases = ibCreateButton(  wCases.px, wCases.py, wCases.sx, wCases.sy, nil,
                                            "img/bg_cases.png", "img/bg_cases_hover.png", "img/bg_cases_hover.png", 
                                            0xffffffff, 0xffffffff, 0xffffffff )

    addEventHandler( "ibOnElementMouseClick", UI_elements.bg_cases, function( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        triggerServerEvent( "PlayerRequestRegisteredTuningCases", localPlayer )
    end, false )
end

function ShowCases( instant )
    if not isElement( UI_elements.bg_cases ) then return end
    if instant then
        UI_elements.bg_cases:ibBatchData(
            {
                px = wCases.px, py = wCases.py
            }
        )

    else
        UI_elements.bg_cases:ibMoveTo( wCases.px, wCases.py, 150 * ANIM_MUL, "OutQuad" )

    end
end

function HideCases( instant )
    if not isElement( UI_elements.bg_cases ) then return end
    if instant then
        UI_elements.bg_cases:ibBatchData(
            {
                px = x, py = wCases.py
            }
        )

    else
        UI_elements.bg_cases:ibMoveTo( x, wCases.py, 150 * ANIM_MUL, "OutQuad" )

    end
end