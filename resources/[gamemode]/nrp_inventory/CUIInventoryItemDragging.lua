DRAGGED_ITEM = {}

function CreateDraggedItem( item, inventory )
	if isElement( DRAGGED_ITEM.bg ) then return end
	DRAGGED_ITEM = CreateItem( 0, 0, 90, nil, PLAYER_INVENTORY, item.item_id, item.attributes )
	DRAGGED_ITEM.bg
		:ibAttachToCursor( 15, 15 )
		:ibOnAnyClick( function( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedWorld )
			if button ~= "left" or state ~= "up" then return end
			DropDraggedItem( clickedWorld )
		end )
	DRAGGED_ITEM.inventory = inventory
	DestroyDescription( )
	return true
end

function DropDraggedItem( clickedWorld )
	if not isElement( DRAGGED_ITEM.bg ) then return end

	local item_id = DRAGGED_ITEM.item_id
	local attributes = DRAGGED_ITEM.attributes
	local is_from_player_inventory = DRAGGED_ITEM.inventory.owner == localPlayer
	DestroyItem( DRAGGED_ITEM )

	if HOVERED_INVENTORY_UI then
		if HOVERED_INVENTORY_UI.inventory.owner ~= DRAGGED_ITEM.inventory.owner then
			local item_conf = ITEMS_CONFIG[ item_id ]
			if item_conf[ STATIC ] or attributes and attributes._temp then
				localPlayer:ShowError( "Нельзя переложить этот предмет" )
				return
			end

			local item_count = DRAGGED_ITEM.inventory:GetItemCount( item_id, attributes )
			if item_count > 1 then
				local item_weight = GetItemWeight( item_id, { attributes = attributes }, 1 )
				local free_weight = HOVERED_INVENTORY_UI.inventory.max_weight - HOVERED_INVENTORY_UI.inventory.total_weight
				local max_movable_count = math.floor( free_weight / item_weight )

				if max_movable_count <= 0 then
					localPlayer:ShowError( "Недостаточно места" )
					return
				end

				if HOVERED_INVENTORY_UI.popup then HOVERED_INVENTORY_UI.popup:destroy() end
				HOVERED_INVENTORY_UI.popup = ibInput(
					{
						title = "ПЕРЕНОС ПРЕДМЕТА", 
						text = "Введи, сколько штук переложить",
						edit_text = "В наличии " .. item_count .. " шт.",
						edit_right_text = "Вместится " .. max_movable_count .. " шт.",
						edit_value = math.min( item_count, max_movable_count ),
						btn_text = "ОК",
						fn = function( self, text )
							local move_count = tonumber( text )
							if not move_count or move_count <= 0 or move_count ~= math.floor( move_count ) then
								localPlayer:ErrorWindow( "Введи количество!" )
								return
							end

							self:destroy()
							triggerServerEvent( "InventoryMove", resourceRoot, item_id, attributes, move_count, is_from_player_inventory )
						end
					}
				)
			else
				triggerServerEvent( "InventoryMove", resourceRoot, item_id, attributes, 1, is_from_player_inventory )
			end
		end
	elseif is_from_player_inventory then
		UseItem( item_id, attributes, clickedWorld )
	end
end

function Inventory_GetDraggedItem( )
	if isElement( DRAGGED_ITEM.bg ) then
		return DRAGGED_ITEM.item_id, DRAGGED_ITEM.attributes
	end
end