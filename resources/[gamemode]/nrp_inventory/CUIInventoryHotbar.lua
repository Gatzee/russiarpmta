HOTBAR = nil

local slots_count = 5
local slot_sx = 70
local gap = 10

function CreateInventoryHotbar( items )
    HOTBAR = {
        is_visible = true,
        items = items,
        elements = {},
        SetSlotActive = {},
        UpdateSlot = {},
    }
    
    HOTBAR.IsItemAdded = function( self, item_id )
        for slot = 1, 5 do
            if HOTBAR.items[ slot ] and HOTBAR.items[ slot ].item_id == item_id then
                return true
            end
        end
        return false
    end
    
    HOTBAR.AddItem = function( self, slot, item_id, attributes )
        HOTBAR.items[ slot ] = {
            item_id = item_id,
            attributes = attributes,
        }
        return true
    end
    
    HOTBAR.AddItemIfExists = function( self, slot, item_id )
        local item_container = PLAYER_INVENTORY.data[ item_id ]
        if item_container and not HOTBAR:IsItemAdded( item_id ) then
            if item_container[ 1 ] > 0 then
                return HOTBAR:AddItem( slot, item_id )
            elseif item_container[ 2 ] then
                return HOTBAR:AddItem( slot, item_id, item_container[ 2 ].attributes )
            end
        end
        return false
    end

    -- Автозаполнение

    local DEFAULT_HOTBAR_ITEMS = {
        [ 1 ] = { IN_WEAPON },
        [ 2 ] = { IN_WEAPON },
        [ 3 ] = { IN_FOOD, IN_FIRSTAID, IN_DRUGS },
        [ 4 ] = { IN_FIRSTAID, IN_DRUGS, IN_FOOD },
        [ 5 ] = { IN_CANISTER, IN_REPAIRBOX },
    }

    DEFAULT_HOTBAR_ITEMS_REVERSE = {}
    for slot = 1, 5 do
        for i, item_type in pairs( DEFAULT_HOTBAR_ITEMS[ slot ] ) do
            if not DEFAULT_HOTBAR_ITEMS_REVERSE[ item_type ] then
                DEFAULT_HOTBAR_ITEMS_REVERSE[ item_type ] = {}
            end
            table.insert( DEFAULT_HOTBAR_ITEMS_REVERSE[ item_type ], slot )
        end
    end
    
    for slot = 1, 5 do
        if not HOTBAR.items[ slot ] then
            for i, item_type in pairs( DEFAULT_HOTBAR_ITEMS[ slot ] ) do
                local is_added = false
                if ITEM_IDS_BY_TYPE[ item_type ] then
                    for i, item_id in pairs( ITEM_IDS_BY_TYPE[ item_type ] ) do
                        is_added = HOTBAR:AddItemIfExists( slot, item_id ) 
                        if is_added then break end
                    end
                else
                    is_added = HOTBAR:AddItemIfExists( slot, item_type )
                end
                if is_added then break end
            end
        end
    end
    
    HOTBAR.AddItemToFreeSlot = function( self, item_id, attributes )
        local item_type = ITEMS_CONFIG[ item_id ][ TYPE ]
        if DEFAULT_HOTBAR_ITEMS_REVERSE[ item_type ] and not HOTBAR.IsItemAdded( item_id ) then
            for i, slot in pairs( DEFAULT_HOTBAR_ITEMS_REVERSE[ item_type ] ) do
                if not HOTBAR.items[ slot ] then
                    return HOTBAR:AddItem( slot, item_id, attributes )
                end
            end
        end
    end

    -- UI

    HOTBAR.elements.slots = {}

    local cols = 3
    local area = ibCreateArea( 278, _SCREEN_Y - 20, slots_count * ( slot_sx + gap ) - gap, 0 )

    for slot = 1, slots_count do
        local hovered = false
        local px = ( ( slot - 1 ) % cols ) * ( slot_sx + gap )
        local py = -math.ceil( slot / cols ) * ( slot_sx + gap ) + gap
        local area_slot = ibCreateArea( px, py, slot_sx, slot_sx, area )
            :ibData( "alpha", 255 * 0.3 )

        local bg = ibCreateImage( 0, 0, slot_sx, slot_sx, _, area_slot, 0xFF364658 )
            :ibData( "alpha", 255 * 0.6 )
            :ibAttachTooltip( "ПКМ - очистить слот" )
            :ibOnHover( function( )
                hovered = true
                this:ibAlphaTo( 255, 100 )
            end )
            :ibOnLeave( function( )
                hovered = false
                this:ibAlphaTo( 255 * 0.6, 100 )
            end )
            :ibOnAnyClick( function( button, state )
				if not hovered then return end

                if button == "left" then
                    if state == "down" then
                        if not HOTBAR.items[ slot ] then return end
                        if CreateDraggedItem( HOTBAR.items[ slot ], PLAYER_INVENTORY ) then
                            DRAGGED_ITEM.hotbar_slot = slot
                        end
                    else
                        local item_id, attributes = Inventory_GetDraggedItem( )
                        if not item_id then return end
                        DestroyItem( DRAGGED_ITEM )

                        if DRAGGED_ITEM.hotbar_slot then
                            HOTBAR.items[ DRAGGED_ITEM.hotbar_slot ] = HOTBAR.items[ slot ]
                            HOTBAR.UpdateSlot[ DRAGGED_ITEM.hotbar_slot ]()
                            triggerServerEvent( "InventoryHotbarChange", resourceRoot, DRAGGED_ITEM.hotbar_slot, HOTBAR.items[ slot ] )
                        end

                        HOTBAR.items[ slot ] = {
                            item_id = item_id,
                            attributes = attributes,
                        }
                        HOTBAR.UpdateSlot[ slot ]()
                        triggerServerEvent( "InventoryHotbarChange", resourceRoot, slot, HOTBAR.items[ slot ] )
                    end

                -- Очистка слота на ПКМ
                elseif button == "right" and state == "up" then
                    HOTBAR.items[ slot ] = nil
                    HOTBAR.UpdateSlot[ slot ]()
                    triggerServerEvent( "InventoryHotbarChange", resourceRoot, slot )
                end
			end )

        HOTBAR.elements.slots[ slot ] = bg

        local border = ibCreateImage( 0, 0, slot_sx, slot_sx, "img/slot_hotbar.png", area_slot )
            :ibData( "disabled", true )
            :ibData( "alpha", 0 )

        local bg_slot_key = ibCreateImage( 0, 50, 20, 20, _, area_slot, ibApplyAlpha( 0xFF78afeb, 50 ) )
            :ibData( "priority", 1 ):ibData( "disabled", true )
        ibCreateLabel( 0, 0, 20, 20, slot, bg_slot_key, COLOR_WHITE, _, _, "center", "center", ibFonts.oxaniumbold_13 )
            :ibData( "outline", true )
            :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 50 ) )

        local img = ibCreateImage( 0, 0, 0, 0, nil, area_slot ):ibData( "disabled", true )
        local lbl_count = ibCreateLabel( slot_sx - 6, 11, 0, 0, "", area_slot, COLOR_WHITE, _, _, "right", "center", ibFonts.oxaniumregular_11 )
            :ibData( "outline", true )
            :ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 50 ) )

        local disactivate_timer
        HOTBAR.SetSlotActive[ slot ] = function( state, duration )
            area_slot:ibAlphaTo( state and 255 or 255 * 0.3 )
            border:ibAlphaTo( state and 255 or 0 )

            if isTimer( disactivate_timer ) then disactivate_timer:destroy() end
            if duration then
                disactivate_timer = setTimer( HOTBAR.SetSlotActive[ slot ], duration * 1000, 1, false )
            end
        end

        HOTBAR.UpdateSlot[ slot ] = function()
            if HOTBAR.items[ slot ] then
                local item_id = HOTBAR.items[ slot ].item_id
                local attributes = HOTBAR.items[ slot ].attributes
                local item_conf = ITEMS_CONFIG[ item_id ]

                local item_count = PLAYER_INVENTORY:GetItemCount( item_id, attributes )
                local visual_data = item_conf[ VISUAL_CONSTRUCT ] and item_conf[ VISUAL_CONSTRUCT ]( item_conf, item_id, attributes or {} ) or { }
                img:ibData( "alpha", item_count > 0 and 255 or 80 ):ibData( "texture", visual_data.image ):ibSetRealSize( ):ibSetInBoundSize( slot_sx, slot_sx ):center( )
                lbl_count:ibData( "text", item_count > 1 and item_count or "" )
            else
                img:ibData( "alpha", 0 )
                lbl_count:ibData( "text", "" )
            end
        end
        HOTBAR.UpdateSlot[ slot ]()
    end

    HOTBAR.Show = function( self, state )
        HOTBAR.is_visible = state
        area:ibData( "visible", state )
    end

    HOTBAR.Update = function( self )
        for slot = 1, slots_count do
            HOTBAR.UpdateSlot[ slot ]()
        end
    end

    HOTBAR.onInventoryShow = function( self, state )
        area:ibMoveTo( state and 480 or 278 )
        for slot = 1, slots_count do
            HOTBAR.SetSlotActive[ slot ]( state )
            HOTBAR.elements.slots[ slot ]:ibData( "disabled", not state )
        end
    end

    HOTBAR.onOtherInventoryOpen = function( self, state )
        area:ibAlphaTo( 0 )
        OTHER_INVENTORY.UI.bg:ibOnDestroy( function()
            area:ibAlphaTo( 255 )
        end )
    end

    for slot = 1, slots_count do
        bindKey( slot, "down", function()
            if not HOTBAR.is_visible then return end
            if not HOTBAR.items[ slot ] then return end

            local item_id = HOTBAR.items[ slot ].item_id
            if not item_id then return end

            local attributes = HOTBAR.items[ slot ].attributes
            if PLAYER_INVENTORY:GetItemCount( item_id, attributes ) <= 0 then return end

            UseItem( item_id, attributes, localPlayer )
            HOTBAR.SetSlotActive[ slot ]( true, 10 )
        end )
    end
end

local disabled_by = {}
addEvent( "ShowInventoryHotbar", true )
addEventHandler( "ShowInventoryHotbar", root, function( state, custom_source )
    disabled_by[ custom_source or sourceResource ] = not state or nil
    HOTBAR:Show( not next( disabled_by ) )
end )