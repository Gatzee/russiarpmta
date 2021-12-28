function CreateVinylCases( data )
    UI_elements.bg_vinyl_cases = ibCreateButton(  wCases.px, wCases.py, wCases.sx, wCases.sy, nil,
                                            "img/vinyl_setting/bg_cases.png", "img/vinyl_setting/bg_cases_hover.png", "img/vinyl_setting/bg_cases_hover.png", 
                                            0xffffffff, 0xffffffff, 0xffffffff )

    addEventHandler( "ibOnElementMouseClick", UI_elements.bg_vinyl_cases, function( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        triggerServerEvent( "PlayerRequestRegisteredVinylCases", localPlayer )
    end, false )
end

function ShowVinylCases( instant )
    if not isElement( UI_elements.bg_vinyl_cases ) then return end
    if instant then
        UI_elements.bg_vinyl_cases:ibBatchData(
            {
                px = wCases.px, py = wCases.py
            }
        )

    else
        UI_elements.bg_vinyl_cases:ibMoveTo( wCases.px, wCases.py, 150 * ANIM_MUL, "OutQuad" )

    end
end

function HideVinylCases( instant )
    if not isElement( UI_elements.bg_vinyl_cases ) then return end
    if instant then
        UI_elements.bg_vinyl_cases:ibBatchData(
            {
                px = x, py = wCases.py
            }
        )

    else
        UI_elements.bg_vinyl_cases:ibMoveTo( x, wCases.py, 150 * ANIM_MUL, "OutQuad" )

    end
end