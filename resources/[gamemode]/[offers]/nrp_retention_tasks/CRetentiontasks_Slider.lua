ibUseRealFonts( true )

local UI

function ShowRetentionTasksUI( state, conf )
    if state then
        ShowRetentionTasksUI( false )

        UI = { }

        UI.black_bg = ibCreateBackground( _, _, true )

        local x, y = guiGetScreenSize( )
        local sx, sy = 800, 580
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        
        UI.bg = ibCreateRenderTarget( px, py + 100, sx, sy, UI.black_bg ):ibData( "alpha", 0 )

        -- Слайдеры
        local sliders_list = { }
        for id, data in pairs( conf.tasks ) do
            if TASKS_CONFIG[ id ] and TASKS_CONFIG[ id ].fn_create_slider then
                local element = TASKS_CONFIG[ id ]:fn_create_slider( data, UI.bg )
                if element then
                    table.insert( sliders_list, element )
                    element:ibBatchData( { px = sx, retention_task_id = id } )
                end
            end
        end

        if #sliders_list <= 0 then
            localPlayer:ErrorWindow( "У тебя нет активных задач!" )
            ShowRetentionTasksUI( false )
            return
        end

        local animation_duration = 300
        local current_slider
        local sliders_indicator_boxes = { }

        -- Управление
        function SwitchSlider( num, animation_direction )
            local old_slider = current_slider and sliders_list[ current_slider ]
            local new_slider = sliders_list[ num ]

            for i, v in pairs( sliders_indicator_boxes ) do
                v:ibData( "color", i == num and 0xffffffff or ibApplyAlpha( 0xff000000, 75 ) )
            end

            -- Анимация влево
            if animation_direction == "left" then
                if old_slider then
                    local osx = old_slider:ibData( "sx" )
                    old_slider:ibMoveTo( -osx, _, animation_duration ):ibData( "priority", -1 )
                end
                new_slider:ibData( "px", sx ):ibMoveTo( 0, 0, animation_duration ):ibData( "priority", 0 )

            -- Анимация вправо
            elseif animation_direction == "right" then
                if old_slider then
                    old_slider:ibMoveTo( sx, _, animation_duration ):ibData( "priority", -1 )
                end
                new_slider:ibData( "px", -new_slider:ibData( "sx" ) ):ibMoveTo( 0, 0, animation_duration ):ibData( "priority", 0 )

            -- Без анимации
            else
                if old_slider then
                    old_slider:ibData( "px", sx ):ibData( "priority", -1 )
                end
                new_slider:ibData( "px", 0 ):ibData( "priority", 0 )
            end

            current_slider = num
        end

        if #sliders_list > 1 then
            ibCreateImage( 31, 278, 33, 24, "img/icon_slider_arrow.png", UI.bg )
                :ibData( "alpha", 200 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    local next_slider = 1 + ( current_slider - 2 ) % #sliders_list

                    SwitchSlider( next_slider, "right" )
                end )

            ibCreateImage( 737, 278, 33, 24, "img/icon_slider_arrow.png", UI.bg )
                :ibData( "alpha", 200 )
                :ibData( "rotation", 180 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    local next_slider = 1 + ( current_slider ) % #sliders_list

                    SwitchSlider( next_slider, "left" )
                end )

            local line_width, padding_width = 30, 10
            local area_width = #sliders_list * line_width + ( #sliders_list - 1 ) * padding_width
            local area = ibCreateArea( 400 - area_width / 2, 546, area_width, 4, UI.bg )

            local npx = 0
            for i, v in pairs( sliders_list ) do
                local btn
                    = ibCreateImage( npx, 0, line_width, 4, _, area, ibApplyAlpha( 0xff000000, 75 ) )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "down" then return end
                        if i == current_slider then return end
                        ibClick( )
                        SwitchSlider( i, i >= current_slider and "right" or "left" )
                    end )

                table.insert( sliders_indicator_boxes, btn )
                npx = npx + line_width + padding_width
            end
        end

        ibCreateButton( 748, 25, 24, 24, UI.bg,
                        ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowRetentionTasksUI( false )
            end )
        
        local found_slider = false
        if conf.id then
            for i, v in pairs( sliders_list ) do
                if v:ibData( "retention_task_id" ) == conf.id then
                    SwitchSlider( i )
                    found_slider = true
                    break
                end
            end
        end

        if not found_slider then SwitchSlider( 1 ) end

        UI.bg:ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 400 )

        showCursor( true )
    else
        DestroyTableElements( UI )
        showCursor( false )
    end
end

function ShowRetentionInterface_handler( tasks, current_id )
    ShowRetentionTasksUI( true, { tasks = tasks, id = current_id } )
end 
addEvent( "ShowRetentionInterface", true )
addEventHandler( "ShowRetentionInterface", root, ShowRetentionInterface_handler )