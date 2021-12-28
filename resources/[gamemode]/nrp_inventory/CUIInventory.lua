CATEGORIES = {
	{
		name = "Предметы",
		category  = "stuff",
	},
	{
		name = "Документы",
		category  = "documents",
	},
	{
		name = "Оружие",
		category  = "weapon",
	},
}

local OWNER_TYPE_TO_INFO = {
	[ "player"  ] = { title = "Инвентарь", icon = "backpack"  },
	[ "vehicle" ] = { title = "Багажник" , icon = "car_trunk" },
	[ "house"   ] = { title = "Ящик"     , icon = "house_box" },
}

PLAYER_INVENTORY_UI = { }
OTHER_INVENTORY_UI = nil
HOVERED_INVENTORY_UI = nil

local DESCRIPTION = {}

INVENTORY_LOCKED = nil

InventoryUI = {
	Create = function( inventory )
		local UI = setmetatable( { inventory = inventory }, { __index = InventoryUI } )
		inventory.UI = UI

		local animation_duration = 250
		local sx, sy = 450, 516
		local px, py = 20, _SCREEN_Y - sy - 20
		if inventory.owner ~= localPlayer then
			px = 530
		end

		UI.bg = ibCreateImage( px, py + 100, sx, sy, nil, nil, 0xF2475d75 )
			:ibData( "alpha", 0 ):ibAlphaTo( 255, animation_duration )
			:ibMoveTo( px, py, animation_duration, "OutQuad" )

		if inventory.owner == localPlayer then
			UI.key_action_close = ibAddKeyAction( _, _, UI.bg, function()
				ShowUIInventory( false )
			end )
		end

		UI.head_bg = ibCreateImage( 0, 0, sx, 73, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
		ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), sx, 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		UI.head_label = ibCreateLabel( 30, 36, 0, 0, OWNER_TYPE_TO_INFO[ inventory.owner_type ].title, UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
		UI.btn_close = ibCreateButton( sx - 55, 24, 25, 25, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )
				if inventory.owner == localPlayer then
					ShowUIInventory( false )
				else
					UI:Destroy()
				end
			end )

		if inventory.owner ~= localPlayer then
			ibCreateImage( -47, 237, 37, 42, "img/icon_sharing.png", UI.bg )
		end

		-- Общий вес
		UI.total_weight_area = ibCreateArea( 0, 36, 0, 0, UI.head_bg )
		UI.total_weight_lbl = ibCreateLabel( 0, 0, 0, 0, "Общий вес: ", UI.total_weight_area, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "left", "center", ibFonts.regular_14 )
		UI.total_weight = ibCreateLabel( UI.total_weight_lbl:ibGetAfterX( ), -1, 0, 0, "", UI.total_weight_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.oxaniumbold_15 )
		UI.max_weight = ibCreateLabel( UI.total_weight:ibGetAfterX( ), 0, 0, 0, "", UI.total_weight_area, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "left", "center", ibFonts.oxaniumregular_12 )

		UI.UpdateTotalWeight = function( )
			UI.total_weight
				:ibData( "text", string.format( "%.2f", UI.inventory.total_weight ):gsub( "(%..-)0+$", "%1" ):gsub( "%.$", "" ) )
				:ibData( "color", UI.inventory.total_weight > UI.inventory.max_weight and 0xFFff4e4e or COLOR_WHITE )
			UI.max_weight
				:ibData( "px", UI.total_weight:ibGetAfterX( ) )
				:ibData( "text", " / " .. UI.inventory.max_weight  .. " кг" )
			UI.total_weight_area:ibData( "px", UI.btn_close:ibGetBeforeX( ) - 30 - UI.max_weight:ibGetAfterX( ) )

			UI.inventory_icon:ibData( "color", UI.inventory.total_weight > UI.inventory.max_weight and 0xFFff4e4e or COLOR_WHITE )
		end

		UI.navbar = ibCreateNavbar( {
			px = 30,
			py = 72,
			parent = UI.bg,
			tabs = CATEGORIES,
			current = 1,
			font = ibFonts.regular_14,

			fn_OnSwitch = function( selected_category_id )
				if UI.rt then
					UI:Update( selected_category_id )

					if selected_category_id == 2 then return end

					local other_inventory_ui = UI ~= PLAYER_INVENTORY_UI and PLAYER_INVENTORY_UI or OTHER_INVENTORY.UI
					if other_inventory_ui and other_inventory_ui.selected_category_id ~= selected_category_id then
						other_inventory_ui.navbar:Switch( selected_category_id )
					end
				end
			end
		} )

		-- Мегакостыль, чтобы скрыть вкладку документов
		if inventory.owner ~= localPlayer then
			local navbar = UI.navbar.elements.tabs
			navbar[ 2 ].lbl:ibData( "visible", false )
			navbar[ 2 ].area:ibData( "visible", false )
			navbar[ 3 ].lbl:ibData( "px", navbar[ 2 ].lbl:ibData( "px" ) )
			navbar[ 3 ].area:ibData( "px", navbar[ 2 ].area:ibData( "px" ) )
		end

		UI.rt, UI.sc = ibCreateScrollpane( 0, 119, sx, 327, UI.bg, { scroll_px = -20 } )
		UI.sc:ibSetStyle( "slim_nobg" )
		UI.rt
			:ibOnHover( function( )
				HOVERED_INVENTORY_UI = UI
			end, true )
			:ibOnLeave( function( )
				HOVERED_INVENTORY_UI = nil
			end, true )

		UI.footer = ibCreateImage( 0, 446, sx, 70, _, UI.bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		ibCreateImage( 0, 0, sx, 1, _, UI.footer, ibApplyAlpha( COLOR_WHITE, 10 ) )

		UI.inventory_icon = ibCreateImage( 30, 467, 0, 0, "img/icon_" .. OWNER_TYPE_TO_INFO[ inventory.owner_type ].icon .. ".png", UI.bg ):ibSetRealSize()

		UI.item_name_lbl = ibCreateLabel( 74, 471, 0, 0, "Название: ", UI.bg, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "left", "center", ibFonts.regular_12 )
		UI.item_name = ibCreateLabel( UI.item_name_lbl:ibGetAfterX( ), 471, 0, 0, "", UI.bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_12 )

		UI.item_weight = ibCreateLabel( 366, 471, 0, 0, "0 кг", UI.bg, COLOR_WHITE, 1, 1, "right", "center", ibFonts.bold_12 )
		UI.item_weight_lbl = ibCreateLabel( UI.item_weight:ibGetBeforeX( -4 ), 471, 0, 0, "Вес:", UI.bg, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "right", "center", ibFonts.regular_12 )

		UI.UpdateSelectedItem = function( ui_item )
			UI.item_name:ibData( "text", ui_item.visual_data.text or "---" )

			local weight = GetItemWeight( ui_item.item_id, { attributes = ui_item.attributes }, ui_item.count )
			UI.item_weight:ibData( "text", weight .. " кг" )
			UI.item_weight_lbl:ibData( "px", UI.item_weight:ibGetBeforeX( -4 ) )
		end

		local weight_bar_sx = 290
		ibCreateImage( 74, 486, weight_bar_sx + 2, 10, _, UI.bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		UI.weight_bar_bg = ibCreateImage( 75, 487, weight_bar_sx, 8, _, UI.bg, 0xFF5a6e83 )

		UI.total_weight_bar = ibCreateImage( 0, 0, 0, 8, _, UI.weight_bar_bg, COLOR_WHITE )
		UI.category_weight_bar = ibCreateImage( 0, 0, 0, 8, _, UI.weight_bar_bg, 0xFFfb9769 )

		-- Ты можешь увеличить вместимость в магазине
		UI.bg_increase_max_weight = ibCreateImage( 0, 366, 450, 87, "img/bg_increase_max_size.png", UI.bg ):ibData( "alpha", 0 ):ibData( "disabled", true )
		ibCreateButton( 310, 20, 110, 40, UI.bg_increase_max_weight, "img/btn_details.png", _, _, 0, 0xFFFFFFFF, 0xFFcccccc )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )
				UI.bg_increase_max_weight:ibData( "alpha", 0 )
				triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "services" )
			end )

		UI.UpdateWeightBar = function()
			local sx = math.min( weight_bar_sx, weight_bar_sx * ( inventory.total_weight / inventory.max_weight ) )
			UI.total_weight_bar:ibData( "sx", sx )
			UI.total_weight_bar:ibData( "color", sx >= weight_bar_sx and 0xFFff4e4e or COLOR_WHITE )

			local ox = 0
			if inventory.total_weight > 0 then
				for category_id, cat_info in ipairs( CATEGORIES ) do
					if category_id ~= UI.selected_category_id then
						local category_weight = inventory.categories_weights[ cat_info.category ]
						ox = ox + sx * category_weight / inventory.total_weight
						break
					end
				end
				local category_weight = inventory.categories_weights[ SELECTED_CATEGORY ]
				UI.category_weight_bar:ibMoveTo( ox ):ibResizeTo( math.ceil( sx * category_weight / inventory.total_weight ) )
			else
				UI.category_weight_bar:ibResizeTo( 0 )
			end

			UI.bg_increase_max_weight:ibAlphaTo( UI.inventory.total_weight > UI.inventory.max_weight and 255 or 0 )
		end

		local hovered = false
		ibCreateImage( 393, 466, 30, 30, "img/btn_delete.png", UI.bg )
			:ibData( "alpha", 255 * 0.75 )
            :ibOnHover( function( )
                hovered = true
                this:ibAlphaTo( 255, 100 )
            end )
            :ibOnLeave( function( )
                hovered = false
                this:ibAlphaTo( 255 * 0.75, 100 )
            end )
            :ibOnAnyClick( function( button, state )
				if not hovered then return end

                if button == "left" and state == "up" then
					local item_id, attributes = Inventory_GetDraggedItem( )
					if not item_id then return end
					DestroyItem( DRAGGED_ITEM )

					local item_conf = ITEMS_CONFIG[ item_id ]
					if item_conf[ STATIC ] then
						localPlayer:ShowError( "Нельзя уничтожить этот предмет" )
						return
					end

					local is_from_player_inventory = DRAGGED_ITEM.inventory.owner == localPlayer
					local item_count = DRAGGED_ITEM.inventory:GetItemCount( item_id, attributes )
					if UI.popup then UI.popup:destroy() end
					if item_count > 1 then
						UI.popup = ibInput(
							{
								title = "УДАЛЕНИЕ ПРЕДМЕТА", 
								text = "Введи, сколько штук уничтожить",
								edit_text = "В наличии " .. item_count .. " шт.",
								edit_value = item_count,
								btn_text = "ОК",
								fn = function( self, text )
									local remove_count = tonumber( text )
									if not remove_count or remove_count <= 0 or remove_count ~= math.floor( remove_count ) then
										localPlayer:ErrorWindow( "Введи количество!" )
										return
									end
		
									self:destroy()
									triggerServerEvent( "InventoryDelete", resourceRoot, item_id, attributes, remove_count, is_from_player_inventory )
								end
							}
						)
					else
						UI.popup = ibConfirm(
							{
								title = "УДАЛЕНИЕ ПРЕДМЕТА", 
								text = "Ты хочешь уничтожить этот предмет?" ,
								fn = function( self )
									triggerServerEvent( "InventoryDelete", resourceRoot, item_id, attributes, 1, is_from_player_inventory )
									self:destroy()
								end,
								escape_close = true,
							}
						)
					end
                end
			end )

		UI:Update( )

		return UI
	end,

	Update = function ( UI, selected_category_id )
		if not isElement( UI.bg ) then return end

		local old_category_id = UI.selected_category_id or 1
		UI.selected_category_id = selected_category_id or old_category_id
		SELECTED_CATEGORY = CATEGORIES[ UI.selected_category_id ].category

		local item_sx = 90
		local gap = 10
		local cols = 4

		local old_items_area = UI.items_area
		UI.items_area = ibCreateArea( 30, 17, ( item_sx + gap ) * cols, 0, UI.rt )

		if isElement( old_items_area ) then
			if old_category_id ~= UI.selected_category_id then
				local animation_duration = 300
				local move_offset = UI.selected_category_id > old_category_id and 100 or -100
				old_items_area
					:ibMoveTo( 30 - move_offset, _, animation_duration )
					:ibAlphaTo( 0, animation_duration )
					:ibTimer( destroyElement, animation_duration, 1 )
				UI.items_area
					:ibData( "px", 30 + move_offset )
					:ibMoveTo( 30, _, animation_duration )
					:ibData( "alpha", 0 )
					:ibAlphaTo( 255, animation_duration )
			else
				old_items_area:destroy( )
			end
			-- 	old_scroll_pos = UI.sc:ibData( "position" )
		end

		UI.items = { }
		UI.hovered_item = nil
		local i, px, py = 0, 0, 0
		local function AddItemToGrid( item_id, item_data )
			i = i + 1
			px = ( ( i - 1 ) % cols ) * ( item_sx + gap )
			py = math.floor( ( i - 1 ) / cols ) * ( item_sx + gap )

			local ui_item = CreateItem( px, py, item_sx, UI.items_area, UI.inventory, item_id, item_data.attributes )
			ui_item.bg
				:ibOnHover( function( )
					UI.hovered_item = ui_item
					ui_item.bg:ibData( "color", 0xFF242d3a )

					UI.UpdateSelectedItem( ui_item )
					CreateDescription( ui_item )
				end )
				:ibOnLeave( function( )
					UI.hovered_item = nil
					ui_item.bg:ibData( "color", 0xFF364658 )

					DestroyDescription( )
				end )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" or INVENTORY_LOCKED then return end
					CreateDraggedItem( UI.hovered_item, UI.inventory )
				end )

			UI.items[ i ] = ui_item
		end

		for order_i, item_id in pairs( ITEMS_IDS_BY_CATEGORY[ SELECTED_CATEGORY ] ) do
			local item_container = UI.inventory.data[ item_id ]
			if item_container then
				if item_container[ 1 ] > 0 then
					AddItemToGrid( item_id, { count = item_container[ 1 ] } )
				end
				for i = 2, #item_container do
					AddItemToGrid( item_id, item_container[ i ] ) 
				end
			end
		end

		for i = i + 1, ( math.ceil( math.max( i, 3 * cols ) / cols ) * cols ) do
			px = ( ( i - 1 ) % cols ) * ( item_sx + gap )
			py = math.floor( ( i - 1 ) / cols ) * ( item_sx + gap )
			ibCreateImage( px, py, item_sx, item_sx, nil, UI.items_area, 0xFF364658 )
				:ibOnHover( function( )
					source:ibData( "color", 0xFF242d3a )
				end )
				:ibOnLeave( function( )
					source:ibData( "color", 0xFF364658 )
				end )
		end

		UI.items_area:ibData( "sy", py + item_sx + 17 )
		UI.rt:ibData( "sy", 17 + py + item_sx + 17 )
		UI.sc:UpdateScrollbarVisibility( UI.rt ):ibData( "position", old_scroll_pos or 0 )

		if not selected_category_id then
			UI.UpdateTotalWeight( )
		end
		UI.UpdateWeightBar( )
	end,

	Destroy = function( UI, on_close_button_press )
		if isElement( UI.bg ) then UI.bg:destroy( ) end
		if UI.popup then UI.popup:destroy( ) end
		DestroyDescription( )
		DestroyItem( DRAGGED_ITEM )
		UI.inventory.UI = nil
	end
}

function CreateItem( px, py, sx, parent, inventory, item_id, attributes )
	local item_conf = ITEMS_CONFIG[ item_id ]
	local ui_item = {
    	item_id = item_id,
    	attributes = attributes,
    	count = inventory:GetItemCount( item_id, attributes ),
		visual_data = item_conf[ VISUAL_CONSTRUCT ] and item_conf[ VISUAL_CONSTRUCT ]( item_conf, item_id, attributes or {} ) or { },
	}

	ui_item.bg = ibCreateImage( px, py, sx, sx, nil, parent, 0xFF364658 )
	if ui_item.visual_data.highlight then
		ui_item.bg_highlight = ibCreateImage( 0, 0, 0, 0, "img/highlight.png", ui_item.bg )
			:ibSetRealSize( ):center( ):ibData( "disabled", true )
	end

	ui_item.icon_img = ibCreateImage( 0, 0, 60, 60, ui_item.visual_data.image, ui_item.bg )
		:ibSetRealSize( ):center( ):ibData( "disabled", true )
	
	if ui_item.count > 1 then
		ui_item.count_text = ibCreateLabel( 82, 13, 0, 0, ui_item.count, ui_item.bg, 0xFFb9bec5, _, _, "right", "center", ibFonts.oxaniumregular_11 )
	end

	return ui_item
end

function DestroyItem( ui_item )
	if isElement( ui_item.bg ) then  ui_item.bg:destroy( ) end
end

function CreateDescription( ui_item )
	if isElement( DRAGGED_ITEM.bg ) then return end
	DestroyDescription( )

    local header_text = ui_item.visual_data.text or "---"
    local desc_text = ui_item.visual_data.description or header_text

	local titleWidth = math.max( dxGetTextWidth( header_text, 1, ibFonts.bold_14, false ), 170 )

	DESCRIPTION.bg = ibCreateImage( 0, 0, titleWidth + 30, 83, nil, nil, 0xff4e6680 )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
		:ibAttachToCursor( 15, 15 )
	DESCRIPTION.title_text = ibCreateLabel( 8, 7, 0, 0, header_text, DESCRIPTION.bg, _, _, _, _, _, ibFonts.bold_14 )
	DESCRIPTION.info_text = ibCreateLabel( 8, 25, titleWidth + 16, 50, desc_text, DESCRIPTION.bg, _, _, _, _, _, ibFonts.regular_12 )
		:ibData( "wordbreak", true )
end

function DestroyDescription( )
	if isElement( DESCRIPTION.bg ) then DESCRIPTION.bg:destroy( ) end
end

function ShowUIInventory( state )
	if state then
		if isElement( PLAYER_INVENTORY_UI.bg ) then return end
		if localPlayer:getData( "photo_mode" ) then return end
		if localPlayer:getData( "block_inventory" ) then return end
		if localPlayer.dead or not localPlayer:IsInGame( ) then return end

		-- Не мешаем летать на вертолете и других видах транспорта, где используется Q
		local types_forbidden = {
			Helicopter = true,
			Plane = true,
		}
		local vehicle = localPlayer.vehicle
		if isElement( vehicle ) and types_forbidden[ vehicle.vehicleType ] then
			return
		end

		showCursor( true, not localPlayer:getData( "bFirstPerson" ) )
		triggerEvent( "onClientChangeInterfaceState", root, true, { open_inventory = true } )
		PLAYER_INVENTORY_UI = InventoryUI.Create( PLAYER_INVENTORY )
		HOTBAR:onInventoryShow( true )
		return true
	else
		if not isElement( PLAYER_INVENTORY_UI.bg ) then return end
		PLAYER_INVENTORY_UI:Destroy( )
		if OTHER_INVENTORY.UI then
			OTHER_INVENTORY.UI:Destroy()
		end
		HOTBAR:onInventoryShow( false )
		triggerEvent( "onClientChangeInterfaceState", root, false, { open_inventory = true } )
		showCursor( false, not localPlayer:getData( "bFirstPerson" ) )

		LAST_OPEN_WAS_TOGGLE = nil
	end
end
addEvent( "ShowUIInventory", true )
addEventHandler( "ShowUIInventory", root, ShowUIInventory )
addEventHandler( "onClientPlayerWasted", localPlayer, function() ShowUIInventory( false ) end )

bindKey( "q", "both", function( key, key_state )
	if key_state == "down" then
		if ShowUIInventory( true ) then
			LAST_OPEN_TIME = getTickCount( )
		end

	elseif key_state == "up" and isElement( PLAYER_INVENTORY_UI.bg ) then
		if isElement( DRAGGED_ITEM.bg ) then return end

		if LAST_OPEN_TIME and getTickCount( ) - LAST_OPEN_TIME < 300 and not LAST_OPEN_WAS_TOGGLE then
			LAST_OPEN_WAS_TOGGLE = true
		else
			ShowUIInventory( false )
		end
	end
end )	