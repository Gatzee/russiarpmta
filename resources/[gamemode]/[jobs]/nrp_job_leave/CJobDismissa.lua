loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ib" )

local UI_elements = nil

function onClientJobDismissaOpenMenu_handler( state, target_job_class, marker_id )
    
    if isElement( UI_elements and UI_elements.black_bg ) then
        destroyElement( UI_elements.black_bg )
        UI_elements = nil

        showCursor( false )
    end
    
    if state then
        
        UI_elements = {}
        local x, y = guiGetScreenSize()

        UI_elements.black_bg    = ibCreateBackground( _, onClientJobDismissaOpenMenu_handler, 0xaa000000, true )

        UI_elements.bg_texture  = dxCreateTexture( "img/bg_main.png" )
        local sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2

        local elastic_duration  = 750
        local alpha_duration    = 1200
        UI_elements.bg = ibCreateImage( px, py + 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg )
        UI_elements.bg:ibData( "alpha", 0 )
        UI_elements.bg:ibMoveTo( px, py, elastic_duration, "OutElastic" ):ibAlphaTo( 255, alpha_duration )

        -- Закрыть
        UI_elements.button_close = ibCreateButton(  px + sx - 24, py - 42, 24, 24, UI_elements.black_bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            onClientJobDismissaOpenMenu_handler( false )
            ibClick()
        end, false )

        --Принять
        UI_elements.btn_accept = ibCreateButton(  295, 285, 162, 61, UI_elements.bg,
                                                    "img/btn_accept.png", "img/btn_accept_hovered.png", "img/btn_accept_hovered.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            triggerServerEvent( "onServerJobDismissa", localPlayer, target_job_class, marker_id )
            onClientJobDismissaOpenMenu_handler( false )
            ibClick()
        end, false )

        --Отмена
        UI_elements.btn_cancel = ibCreateButton(  469, 285, 162, 61, UI_elements.bg,
                                                    "img/btn_cancel.png", "img/btn_cancel_hovered.png", "img/btn_cancel_hovered.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            onClientJobDismissaOpenMenu_handler( false )
            ibClick()
        end, false )

        showCursor( true )
    end

end
addEvent( "onClientJobDismissaOpenMenu", true )
addEventHandler( "onClientJobDismissaOpenMenu", root, onClientJobDismissaOpenMenu_handler )