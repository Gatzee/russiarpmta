Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }
local DATA = { }

function ShowFreezerUI( state, data )
    if state then
        ShowFreezerUI( false )
        ibInterfaceSound()
        showCursor( true )

        DATA = data
        DATA.freezer = DATA.freezer or { }

        UI.black_bg = ibCreateBackground( 0xBF1D252E, ShowFreezerUI, true, true )
        UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg ):center( )

        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 54, 33, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xAFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowFreezerUI( false )
            end )

        -------------------------------------------------------------------

        local area_items

        function UpdateFreezerItems( )
            if isElement( area_items ) then
                area_items:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            area_items = ibCreateArea( 0, 0, 0, 0, UI.bg )
            
            local px = 0
            local block_sx = UI.bg:width( ) / 2

            local UPGRADE_ID_BY_PRODUCT_TYPE = {
                [ "alco" ] = CLAN_UPGRADE_ALCO_FACTORY,
                [ "hash" ] = CLAN_UPGRADE_HASH_FACTORY,
            }
            for ti, product_type in pairs( { "hash", "alco" } ) do
                local area_block = ibCreateArea( px, 0, block_sx, 0, area_items )

                -- Партия алкоголя/петрушки
                local ready_batches_count = DATA.today_batches and DATA.today_batches[ product_type ] or 0
                local current_batch_number = ready_batches_count >= MAX_BATCHES_COUNT_IN_DAY and MAX_BATCHES_COUNT_IN_DAY or ready_batches_count
                local area_batch = ibCreateArea( 0, 166, 0, 0, area_block )
                local batch_text = product_type == "alco" and "Партия алкоголя " or "Партия петрушки "
                local lbl_batch_text = ibCreateLabel( 0, 1, 0, 0, batch_text, area_batch, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_16 )
                local lbl_batch_number = ibCreateLabel( lbl_batch_text:ibGetAfterX( ), 0, 0, 0, current_batch_number, area_batch, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_18 )
                local lbl_max_batches_count = ibCreateLabel( lbl_batch_number:ibGetAfterX( ), 2, 0, 0, " / " .. MAX_BATCHES_COUNT_IN_DAY, area_batch, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_14 )
                area_batch:ibData( "sx", lbl_max_batches_count:ibGetAfterX( ) ):center_x( )

                -- Собрано:
                local count = 0
                local upgrade_id = UPGRADE_ID_BY_PRODUCT_TYPE[ product_type ]
                local factory_lvl = localPlayer:GetClanUpgradeLevel( upgrade_id ) or 0
                local need_count_for_batch = FACTORY_UPGRADES[ factory_lvl > 0 and factory_lvl or 1 ].need_count_for_batch
                if ready_batches_count >= MAX_BATCHES_COUNT_IN_DAY then
                    count = need_count_for_batch
                else
                    count = DATA.freezer[ product_type ] and DATA.freezer[ product_type ].total_count or 0
                end
                local area_batch_count = ibCreateArea( 0, 422, 0, 0, area_block )
                local lbl_batch_count_text = ibCreateLabel( 0, 1, 0, 0, "Собрано: ", area_batch_count, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_16 )
                local lbl_batch_count = ibCreateLabel( lbl_batch_count_text:ibGetAfterX( 4 ), 0, 0, 0, count, area_batch_count, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_18 )
                local lbl_need_count_for_batch = ibCreateLabel( lbl_batch_count:ibGetAfterX( ), 2, 0, 0, " / " .. need_count_for_batch, area_batch_count, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_14 )
                area_batch_count:ibData( "sx", lbl_need_count_for_batch:ibGetAfterX( ) ):center_x( )

                local available_count_by_quality = { }
                local inv_item_id = PRODUCT_TYPE_TO_INV_ITEM_ID[ product_type ]
                local item_container = localPlayer:InventoryGetItem( inv_item_id )
                for i = 2, #item_container do
                    local quality = item_container[ i ].attributes[ 1 ]
                    available_count_by_quality[ quality ] = ( available_count_by_quality[ quality ] or 0 ) + ( item_container[ i ].count or 1 )
                end

                local py = 451
                local item_sy = 90
                for quality = 1, 3 do
                    local area_item = ibCreateArea( 0, py, 0, item_sy, area_block )

                    local available_count = available_count_by_quality[ quality ] or 0
                    local add_count = available_count
                    local btn_min = ibCreateButton( 175, 20, 30, 30, area_item, ":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png", ":nrp_shared/img/btn_min.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
                    local bg_count = ibCreateImage( 30 + 5, 0, 49, 30, ":nrp_shared/img/stroke.png", btn_min )
                    local edit_add_count = ibCreateEdit( 0, -1, bg_count:width( ), bg_count:height( ), add_count, bg_count, 0xFFFFFFFF, 0, 0xFFFFFFFF )
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
                    local btn_plus = ibCreateButton( 49 + 5, 0, 30, 30, bg_count, ":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png", ":nrp_shared/img/btn_plus.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
            
                    btn_min:ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        add_count = ( add_count - 2 ) % available_count + 1
                        edit_add_count:ibData( "text", add_count )
                    end )
                
                    btn_plus:ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                
                        add_count = add_count % available_count + 1
                        edit_add_count:ibData( "text", add_count )
                    end )
            
                    -- В наличии:
                    local area_available_count = ibCreateArea( 0, 43, 0, 0, bg_count )
                    local lbl_available_count_text = ibCreateLabel( 0, 1, 0, 0, "В наличии: ", area_available_count, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_12 )
                    local lbl_available_count = ibCreateLabel( lbl_available_count_text:ibGetAfterX( ), 0, 0, 0, available_count, area_available_count, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_14 )
                    area_available_count:ibData( "sx", lbl_available_count:ibGetAfterX( ) ):center_x( )

                    -- Добавить
                    local btn_add = ibCreateButton( 360, 30, 107, 30, area_item, "img/btn_add.png", "img/btn_add_h.png", "img/btn_add_h.png", _, _, 0xFFCCCCCC )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )

                            if add_count > available_count then
                                localPlayer:ShowError( "В наличии только " .. available_count .. " шт." )
                                return
                            end

                            triggerServerEvent( "CF:onPlayerAddItem", resourceRoot, product_type, quality, add_count )
                        end )
                    
                    if ( available_count or 0 ) == 0 then
                        edit_add_count:ibData( "disabled", true )
                        btn_min:ibData( "disabled", true ):ibData( "color_disabled", 0x80FFFFFF )
                        btn_plus:ibData( "disabled", true ):ibData( "color_disabled", 0x80FFFFFF )
                        btn_add:ibData( "disabled", true ):ibData( "color_disabled", 0x80FFFFFF )
                    end
                    
                    py = py + item_sy
                end

                if factory_lvl == 0 then
                    local bg_cooldown = ibCreateImage( 0, 390, 512, 330, "img/bg_cooldown.png", area_block )
                    ibCreateLabel( 0, 0, 0, 0, "НЕОБХОДИМО ПРИОБРЕСТИ "  .. utf8.upper( CLAN_UPGRADES_LIST[ upgrade_id ].name ), bg_cooldown, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_16 ):center( )
                    
                elseif ready_batches_count >= MAX_BATCHES_COUNT_IN_DAY then
                    local bg_cooldown = ibCreateImage( 0, 390, 512, 330, "img/bg_cooldown.png", area_block )
                    ibCreateLabel( 0, 0, 0, 0, "ВСЕ ПАРТИИ НА ТЕКУЩИЙ ДЕНЬ ВЫПОЛНЕНЫ", bg_cooldown, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_16 ):center( 0, -18 )

                    local area_timer = ibCreateArea( 0, 0, 0, 0, bg_cooldown ):center( 0, 10 )
                    ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
                    local lbl_timer_text = ibCreateLabel( 36, 0, 0, 0, "До обновления: ", area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
                    local lbl_timer = ibCreateLabel( lbl_timer_text:ibGetAfterX( ), 0, 0, 0, "", area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
                    local UpdateTimer = function( )
                        lbl_timer:ibData( "text", getTimerString( DATA.today_batches.reset_ts or 0, true ) )
                        area_timer:ibData( "sx", lbl_timer:ibGetAfterX( ) ):center_x( )
                    end
                    UpdateTimer( )
                    area_timer:ibTimer( UpdateTimer, 1000, 0 )
                end

                px = px + block_sx
            end
        end
        UpdateFreezerItems(  )
        AddUpdateEventHandler( "freezer", "UpdateFreezerItems", UpdateFreezerItems )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end
addEvent( "CF:ShowUI", true )
addEventHandler( "CF:ShowUI", resourceRoot, ShowFreezerUI )

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
addEvent( "CF:UpdateUI", true )
addEventHandler( "CF:UpdateUI", resourceRoot, UpdateUI )