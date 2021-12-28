Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }
local DATA = { }

function ShowAlcoFactoryUI( state, data )
    if state then
        ShowAlcoFactoryUI( false )
        ibInterfaceSound()
        showCursor( true )

        DATA = data
        DATA.items = DATA.items or { }

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowAlcoFactoryUI, true, true )
        UI.bg = ibCreateImage( 0, 0, 800, 600, _, UI.black_bg, ibApplyAlpha( 0xFF475d75, 95 ) ):center( )

        -------------------------------------------------------------------
        -- Header 

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 92, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
        
        UI.lbl_header = ibCreateLabel( 30, 0, 0, 0, "Брожение алкоголя", UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
            :center_y( )

        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowAlcoFactoryUI( false )
            end )

        UI.ready_area = ibCreateArea( UI.head_bg:ibData( "sx" ) - 261, 0, 0, 0, UI.head_bg )
        ibCreateImage( 0, 28, 14, 32, "img/icon_alco.png", UI.ready_area )
        UI.ready_text_lbl = ibCreateLabel( 28, 27, 0, 0, "Готовых бутылок:", UI.ready_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
        UI.ready_lbl = ibCreateLabel( UI.ready_text_lbl:ibGetAfterX( 8 ), 25, 0, 0, 0, UI.ready_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )
        UI.btn_takeall = ibCreateButton( 28 - 10, 45, 108, 22, UI.ready_area, "img/btn_takeall.png", _, _, 0x8FFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                if UI.ready_lbl:ibData( "text" ) == 0 then return end
                ibClick( )
                triggerServerEvent( "CAF:onPlayerWantTakeAllAlco", resourceRoot )
            end )
        
        UI.UpdateReadyCount = function( )
            local ready_count = 0
            for slot, item in pairs( DATA.items ) do
                if item.finish_ts and item.finish_ts <= getRealTimestamp( ) then
                    ready_count = ready_count + 1
                end
            end
            UI.ready_lbl:ibData( "text", ready_count )
        end
        UI.UpdateReadyCount( )
        AddUpdateEventHandler( "items", "ready_count", UI.UpdateReadyCount )

        ibCreateLine( 0, UI.head_bg:height( ) - 1, UI.head_bg:ibData( "sx" ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, UI.head_bg )

        -------------------------------------------------------------------

        ibCreateLabel( 0, 120, 0, 0, "Производственный «Алко-цех»", UI.head_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 ):center_x( )
        ibCreateLabel( 0, 147, 0, 0, "Время, которое осталось до конца брожения алкоголя", UI.head_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_16 ):center_x( )
            :ibData( "alpha", 255 * 0.75 )
        
        UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 30, 177, UI.bg:width( ) - 60, UI.bg:height( ) - 177 - 30 - 46 - 20, UI.bg, { scroll_px = 10 } )
        UI.scrollbar:ibSetStyle( "slim_nobg" )

        local item_sx, item_sy = 147, 154
        local col_count = 5
        local function create_item( slot, px, py )
            local item = DATA.items[ slot ]
            local slot_bg = ibCreateImage( px, py, item_sx, item_sy, "img/slot_locked.png", UI.scrollpane )
                :ibData( "alpha", 0 ):ibAlphaTo( 255 )

            -- Недоступно
            if slot > FACTORY_UPGRADES[ DATA.upgrade_lvl ].max_slots then
                slot_bg:ibData( "texture", "img/slot_locked.png" )
                local need_upgrade_lvl
                for lvl, conf in ipairs( FACTORY_UPGRADES ) do
                    if conf.max_slots >= slot then
                        need_upgrade_lvl = lvl
                        break
                    end
                end
                ibCreateLabel( item_sx / 2, 107, 0, 0, "Требуется\n" .. need_upgrade_lvl .. " ур. цеха", slot_bg, _,_,_, "center", _, ibFonts.regular_12 )
                    :ibData( "alpha", 255 * 0.5 )

            -- Свободно
            elseif not item then
                slot_bg:ibData( "texture", "img/slot_free.png" )

                local hover_img = ibCreateImage( 0, 29, 147, 125, _, slot_bg, 0xD81f2934 )
                    :ibData( "alpha", 1 )
                    :ibOnHover( function( ) source:ibAlphaTo( 155, 100 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 1, 100 ) end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end

                        if localPlayer:InventoryGetItemCount( IN_BOTTLE ) <= 0 then
                            localPlayer:ShowError( "У тебя нет чистых бутылок" )
                            return
                        end
                        triggerServerEvent( "CAF:onPlayerWantAddBottle", resourceRoot, slot )
                    end )

            -- Не запущено
            elseif not item.finish_ts then
                slot_bg:ibData( "texture", "img/slot_not_started.png" )

            -- В процессе
            elseif item.finish_ts > getRealTimestamp( ) then
                slot_bg:ibData( "texture", "img/slot_in_progress.png" )
                local timer_area = ibCreateArea( 0, 0, 0, 0, slot_bg )
                ibCreateImage( 0, 7, 13, 15, "img/icon_timer.png", timer_area )
                local timer_lbl = ibCreateLabel( 18, 5, 0, 0, getTimerString( item.finish_ts ), timer_area, _,_,_,_,_, ibFonts.regular_14 )
                    :ibData( "alpha", 255 * 0.75 )
                    :ibTimer( function( timer_lbl )
                        timer_lbl:ibData( "text", getTimerString( item.finish_ts ) )
                        timer_area:ibData( "sx", timer_lbl:ibGetAfterX( ) ):center_x( )

                        if getRealTimestamp( ) > item.finish_ts then
                            UI.UpdateReadyCount( )

                            slot_bg:ibAlphaTo( 0 ):ibTimer( destroyElement, 200, 1 )
                            create_item( slot, px, py )
                        end
                    end, 1000, 0 )
                timer_area:ibData( "sx", timer_lbl:ibGetAfterX( ) ):center_x( )

            -- Готово
            else
                slot_bg:ibData( "texture", "img/slot_ready.png" )

                for i = 3, 1, -1 do
                    ibCreateImage( 92, 55 + ( i - 1 ) * 25, 18, 18, "img/icon_star.png", slot_bg )
                        :ibData( "disabled", true )
                        :ibData( "color", item.quality > ( 3 - i ) and 0xFFff965d or 0xFF293744 )
                end

                local btn = ibCreateImage( 0, 29, 147, 125, "img/btn_take.png", slot_bg )
                    :ibData( "disabled", true ):ibData( "alpha", 0 )
                ibCreateArea( 0, 29, 147, 125, slot_bg )
                    :ibOnHover( function( ) btn:ibAlphaTo( 255 ) end )
                    :ibOnLeave( function( ) btn:ibAlphaTo( 0 ) end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        ibClick( )
                        triggerServerEvent( "CAF:onPlayerWantTakeAlco", resourceRoot, slot )
                    end )
            end
            
            AddUpdateEventHandler( "items", "slot" .. slot, function( old_data )
                if not table.compare( DATA.items[ slot ], old_data.items[ slot ] ) then
                    slot_bg:ibAlphaTo( 0 ):ibTimer( destroyElement, 200, 1 )
                    create_item( slot, px, py )
                end
            end )
        end

        for slot = 1, 20 do
            local px = ( item_sx + 1 ) * ( ( slot - 1 ) % col_count )
            local py = ( item_sy + 1 ) * math.floor( ( slot - 1 ) / col_count )
            create_item( slot, px, py )
        end

        UI.scrollpane:AdaptHeightToContents( )
        UI.scrollbar:UpdateScrollbarVisibility( UI.scrollpane )

        -- НАЧАТЬ БРОЖЕНИЕ
        UI.btn_start = ibCreateButton( 0, UI.bg:height( ) - 30 - 46, 216, 46, UI.bg, "img/btn_start.png", "img/btn_start_h.png", "img/btn_start_h.png", _, _, 0xFFCCCCCC )
            :center_x( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )

                for slot, item in pairs( DATA.items ) do
                    if not item.finish_ts then
                        triggerServerEvent( "CAF:onPlayerWantStartMakingAlco", resourceRoot )
                        return
                    end
                end

                localPlayer:ShowError( "Ты не поставил чистые бутылки" )
            end )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "CAF:ShowUI", true )
addEventHandler( "CAF:ShowUI", resourceRoot, ShowAlcoFactoryUI )

function AddUpdateEventHandler( data_key, unique_key, fn_handler )
    if not UI.update_handlers then
        UI.update_handlers = { }
    end
    if not UI.update_handlers[ data_key ] then
        UI.update_handlers[ data_key ] = { }
    end
    UI.update_handlers[ data_key ][ unique_key ] = fn_handler
end

function UpdateUI( data )
    if not isElement( UI.bg ) then return end
    
    local old_data = table.copy( DATA )
    for k, v in pairs( data ) do
        DATA[ k ] = data[ k ]
    end
    
    for k, v in pairs( data ) do
        if UI.update_handlers[ k ] then
            for unique_key, fn_handler in pairs( UI.update_handlers[ k ] ) do
                fn_handler( old_data )
            end
        end
    end
end
addEvent( "CAF:UpdateUI", true )
addEventHandler( "CAF:UpdateUI", resourceRoot, UpdateUI )