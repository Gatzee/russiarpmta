
function ShowCoopFinesUI( state, job_class )
    local UI_elements = GetMainWindowElements( )
    if not UI_elements then return end

    local sx, sy = 1024, 676
    if state then
        ShowCoopFinesUI( false )

        UI_elements.fines_bg_rt = ibCreateRenderTarget( 0, 92, sx, sy, UI_elements.bg )
        UI_elements.fines_bg = ibCreateImage( 0, -sx, sx, sy, "img/" .. JOB_ID[ job_class ] .. "/bg_fines.png", UI_elements.fines_bg_rt )

        ibCreateButton( 458, 604, 108, 42, UI_elements.fines_bg, "img/hide.png", "img/hide.png", "img/hide.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end

            ShowCoopFinesUI( false )
            ibClick( )
        end )

        UI_elements.fines_bg:ibMoveTo( 0, 0, 300 )
        ibOverlaySound()
    elseif isElement( UI_elements.fines_bg_rt ) then
        UI_elements.fines_bg:ibMoveTo( 0, -sy, 300 )
        :ibTimer( function()
            destroyElement( UI_elements.fines_bg_rt )
        end, 300, 1 )
        ibOverlaySound()
    end
end