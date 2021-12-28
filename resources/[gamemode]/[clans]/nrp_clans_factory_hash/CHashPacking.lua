local PACKING_MARKERS = { }

addEvent( "CHF:onClientCreateMarkers", true )
addEventHandler( "CHF:onClientCreateMarkers", resourceRoot, function( marker_cooldowns )
    for i = 1, 2 do
        for j = 1, 6 do
            local conf = { x = -79.4, y = -34.015, z = 1998.980 }
            conf.x = conf.x + ( i - 1 ) * 2.1
            conf.y = conf.y + ( j - 1 ) * 3.959
            conf.interior = 9
            conf.dimension = localPlayer.dimension
            conf.radius = 1
            conf.color = { 0, 0, 0, 0 }
            -- conf.marker_text = "Стол фасовки"
            conf.keypress = "lalt"
            conf.text = "ALT Взаимодействие"

            local tpoint = TeleportPoint( conf )
            tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
            tpoint:SetImage( "img/marker_packing.png" )
            -- tpoint.element:setData( "material", true, false )
                
            tpoint.PostJoin = function( self, player )
                triggerServerEvent( "CHF:onPlayerWantShowPackingUI", resourceRoot )
            end

            PACKING_MARKERS[ i .. "_" .. j ] = tpoint
        end
    end
end )

addEvent( "onClientPlayerEnterClanBunker", true )
addEventHandler( "onClientPlayerEnterClanBunker", root, function( )
    for i, marker in pairs( PACKING_MARKERS ) do
        if isElement( marker.element ) then
            marker.dimension = localPlayer.dimension
            marker.element.dimension = marker.dimension
        end
    end
end )

local UI = { }
local DATA = { }

function ShowPackingUI( state, data )
    if state then
        ShowPackingUI( false )
        ibInterfaceSound()
        showCursor( true )

        DATA = data -- { available_count = 5 }

        UI.TryClose = function( )
            if isTimer( UI.process_timer ) then
                ibConfirm(
                    {
                        title = "ПОДТВЕРЖДЕНИЕ", 
                        text = "Ты точно хочешь прекратить фасовку?" ,
                        fn = function( self )
                            triggerServerEvent( "CHF:onPlayerStopPacking", resourceRoot )
                            ShowPackingUI( false )
                            self:destroy()
                        end,
                        escape_close = true,
                    }
                )
            else
                ShowPackingUI( false )
            end
        end

        UI.black_bg = ibCreateBackground( 0xBF1D252E, UI.TryClose, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/packing/bg.png", UI.black_bg ):center( )

        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                UI.TryClose( )
            end )

        -------------------------------------------------------------------

        UI.area_timer = ibCreateArea( 0, 242, 0, 0, UI.bg )
        ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
        UI.timer_text = ibCreateLabel( 36, 0, 0, 0, "До окончания фасовки: ", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
        UI.timer = ibCreateLabel( UI.timer_text:ibGetAfterX( ), 0, 0, 0, "", UI.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
        UI.UpdateTimer = function( )
            UI.timer:ibData( "text", getTimerString( DATA.finish_ts or 0 ) )
            UI.area_timer:ibData( "sx", UI.timer:ibGetAfterX( ) ):center_x( -280 )
        end
        UI.UpdateTimer( )
        UI.area_timer:ibTimer( UI.UpdateTimer, 1000, 0 )

        -------------------------------------------------------------------

        -- Готовых товаров:
        UI.start_count = ibCreateLabel( 344, 502, 0, 0, " /0", UI.bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "right", "center", ibFonts.bold_14 )
        UI.ready_count = ibCreateLabel( UI.start_count:ibGetBeforeX( ), 501, 0, 0, "0", UI.bg, COLOR_WHITE, _, _, "right", "center", ibFonts.bold_16 )
        UI.progressbar = ibCreateImage( 110, 516, 0, 12, _, UI.bg, 0xFF47afff )
            :ibOnRender( function( )
                local progress = DATA.finish_tick and math.min( 1, 1 - ( DATA.finish_tick - getTickCount( ) ) / (DATA.duration * 1000) ) or 0
                UI.progressbar:ibData( "sx", 244 * progress )
            end )

        -- Количество готового товара:
        DATA.ready_count_by_quality = { }
        UI.total_ready_count_by_quality = { }
        UI.total_ready_count_by_quality[ 1 ] = ibCreateLabel( 762, 330, 0, 0, "0 шт.", UI.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
        UI.total_ready_count_by_quality[ 2 ] = ibCreateLabel( 762, 488, 0, 0, "0 шт.", UI.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
        UI.total_ready_count_by_quality[ 3 ] = ibCreateLabel( 762, 653, 0, 0, "0 шт.", UI.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )

        local add_count = DATA.available_count or 0

        UI.btn_min = ibCreateButton( 172, 558, 30, 30, UI.bg, ":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
        UI.add_count = ibCreateEdit( 232 - 49 / 2, 572 - 30 / 2, 49, 30, add_count, UI.bg, 0xFFFFFFFF, 0, 0xFFFFFFFF )
            :ibBatchData( {
                font = ibFonts.bold_18,
                align_x = "center",
                max_length = 3,
                viewable_characters = 3,
                pattern = "%d+",
            } )
            :ibOnDataChange( function( key, value )
                value = tonumber( value )
                if key ~= "text" or not value then return end
                add_count = value
            end )
        UI.btn_plus = ibCreateButton( 262, 558, 30, 30, UI.bg, ":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )

        UI.btn_min:ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
    
            add_count = ( add_count - 2 ) % DATA.available_count + 1
            UI.add_count:ibData( "text", add_count )
        end )
    
        UI.btn_plus:ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
    
            add_count = add_count % DATA.available_count + 1
            UI.add_count:ibData( "text", add_count )
        end )
        
        UI.UpdateCounters = function( quality )
            UI.start_count:ibData( "text", " /" .. DATA.start_count )
            UI.ready_count:ibData( "text", DATA.ready_count ):ibData( "px", UI.start_count:ibGetBeforeX( ) )

            if quality then
                UI.total_ready_count_by_quality[ quality ]:ibData( "text", DATA.ready_count_by_quality[ quality ] .. " шт." )

                add_count = math.min( add_count, DATA.available_count )
                UI.add_count:ibData( "text", add_count )
            end
        end

        -- Начать фасовку
        UI.btn_start = ibCreateButton( 132, 618, 200, 45, UI.bg, "img/packing/btn_start.png", "img/packing/btn_start_h.png", "img/packing/btn_start_h.png", _, _, 0xFFCCCCCC )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )

                if add_count > DATA.available_count then
                    localPlayer:ShowError( "В наличии только " .. DATA.available_count .. " шт." )
                    return
                end

                StartPacking( add_count )
            end )
        
        UI.SetButtonsEnabled = function( state )
            UI.add_count:ibData( "disabled", not state )
            UI.btn_min:ibData( "disabled", not state ):ibData( "color_disabled", 0x80FFFFFF )
            UI.btn_plus:ibData( "disabled", not state ):ibData( "color_disabled", 0x80FFFFFF )
            UI.btn_start:ibData( "disabled", not state ):ibData( "color_disabled", 0x80FFFFFF )
        end

        if DATA.available_count == 0 then
            UI.SetButtonsEnabled( false )
        end

        addEventHandler( "AddInventory", root, onAddInventory )
    else
        removeEventHandler( "AddInventory", root, onAddInventory )

        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "CHF:ShowPackingUI", true )
addEventHandler( "CHF:ShowPackingUI", resourceRoot, ShowPackingUI )

function StartPacking( start_count )
    if isTimer( UI.process_timer ) then return end
    
    triggerServerEvent( "CHF:onPlayerStartPacking", resourceRoot )
    
    UI.SetButtonsEnabled( false )

    DATA.start_count = start_count
    DATA.ready_count = 0
    DATA.duration = PACKING_DURATION * start_count
    DATA.finish_ts = getRealTimestamp( ) + DATA.duration
    DATA.finish_tick = getTickCount( ) + DATA.duration * 1000
    UI.UpdateTimer( )
    UI.UpdateCounters( )

    UI.process_timer = setTimer( function( )
        triggerServerEvent( "CHF:onPlayerPackHash", resourceRoot )

        DATA.ready_count = ( DATA.ready_count or 0 ) + 1
        DATA.available_count = math.max( 0, DATA.available_count - 1 )

        if DATA.start_count == DATA.ready_count then
            UI.process_timer:destroy( )
            triggerServerEvent( "CHF:onPlayerStopPacking", resourceRoot )
            DATA.finish_ts = nil
            DATA.finish_tick = nil
            UI.SetButtonsEnabled( DATA.available_count > 0 and true )
        end
    end, PACKING_DURATION * 1000, start_count )
end

function onAddInventory( owner, item_type, attributes, count )
    if owner == localPlayer and item_type == IN_HASH then
        local quality = attributes[ 1 ]
        DATA.ready_count_by_quality[ quality ] = ( DATA.ready_count_by_quality[ quality ] or 0 ) + 1
        UI.UpdateCounters( quality )
    end
end