local UI_elements = { }
local px, py, sx, sy
local conf = { }

function ShowEntranceUI_handler( state, cnf )
    if state then
        ShowEntranceUI_handler( false )

        conf = cnf or { }

        UI_elements.bg_texture = dxCreateTexture( "img/bg_entrance.png" )
        local x, y = guiGetScreenSize( )
        sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        px, py = x / 2 - sx / 2, y / 2 - sy / 2

        UI_elements.black_bg = ibCreateBackground( 0x99000000, ShowEntranceUI_handler, true, true )
        UI_elements.bg = ibCreateImage( px, py - 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg ):ibData( "alpha", 0 )

        UI_elements.lbl_title = ibCreateLabel( 30, 35, 0, 0, "Этажи кинозалов", UI_elements.bg, _, _, _, "left", "center", ibFonts.bold_24 )

        -- Закрыть
        UI_elements.btn_close
            = ibCreateButton(   sx - 24 - 24, 24, 22, 22, UI_elements.bg,
                                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowEntranceUI_handler( false )
            end )

        UI_elements.bg:ibAlphaTo( 255, 500 ):ibMoveTo( px, py, 700 )

        local npx, npy = 45, 140
        local selected_floor
        local backgrounds = { }
        for i = 1, 2 do
            local bg_hover = ibCreateImage( npx, npy, 340, 300, "img/selection_bg.png", UI_elements.bg ):ibData( "alpha", 0 )
            
            ibCreateImage( npx, npy, 340, 300, "img/entrance_" .. i .. ".png", UI_elements.bg )
                :ibOnHover( function( )
                    if selected_floor ~= i then
                        bg_hover:ibAlphaTo( 150, 100 )
                    end
                end )
                :ibOnLeave( function( )
                    if selected_floor ~= i then
                        bg_hover:ibAlphaTo( 0, 100 )
                    end
                end )
                :ibOnClick( function( )
                    selected_floor = i
                    for n = 1, 2 do
                        backgrounds[ n ]:ibAlphaTo( n == i and 255 or 0 )
                    end
                end )

            table.insert( backgrounds, bg_hover )
            npx = npx + 340 + 30
        end

        UI_elements.btn_enter
            = ibCreateButton(   313, 490, 174, 56, UI_elements.bg, 
                                "img/btn_enter.png", "img/btn_enter.png", "img/btn_enter.png", 
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "down" then return end
                ibClick( )

                if not selected_floor then
                    localPlayer:ErrorWindow( "Выбери этаж!" )
                    return
                end

                if localPlayer.vehicle or localPlayer.interior ~= 0 or localPlayer.dimension ~= 0 then
                    localPlayer:ErrorWindow( "А ты хитёр. Но нет, так нельзя" )
                    return
                end

                localPlayer:Teleport( conf.inside_tpoint.colshape.position, conf.base_dimension + selected_floor - 1, conf.inside_tpoint.interior, 1000 )
                localPlayer:CompleteDailyQuest("np_visit_kino" )

                ShowEntranceUI_handler( false )
                triggerServerEvent( "SwitchPosition", resourceRoot )
                CheckInsideCinema( )
            end )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        showCursor( false )
    end
end
addEvent( "ShowEntranceUI", true )
addEventHandler( "ShowEntranceUI", root, ShowEntranceUI_handler )