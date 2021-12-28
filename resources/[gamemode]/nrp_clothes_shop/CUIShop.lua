loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShSkin" )
Extend( "ShAccessories" )
Extend( "ShHelmet" )
Extend( "ShClothesShops" )

ibUseRealFonts( true )

local screen_size_x, screen_size_y = guiGetScreenSize( )
local pos_offset = 20
local bg_pos_y, bg_size_x = 157, 340
local bg_pos_x, bg_size_y = screen_size_x - bg_size_x - pos_offset, screen_size_y - bg_pos_y - pos_offset

local data = {
	-- Окружение
	interior = 1,
	dimension = 1000,
	weather = 1,
	time = {12,00},

	-- Камера
	camera_position 		= Vector3( -230.87744140625, -386.59646606445, 1360.6363525391 ),
	camera_target 			= Vector3( -150.80400085449, -327.39254760742, 1351.5183105469 ),
	camera_roll				= 0.0,
	camera_fov				= 70.0,

	-- Манекен
	ped_position 			= Vector3( -228.228, -384.3, 1360.343 ),
	ped_rotation 			= 110,
}

local UIe = { }

local skins = nil
local own_accessories = nil
local accessories = nil
local all_accessories = nil
local accessories_preview = nil

local TAB_LIST = nil

local selected_tab = nil
local selected_clothes = nil

local func_SwitchSlot = nil
local func_CreateSlotShopTab = nil
local func_CreateSlotInventoryTab = nil
local func_CreateSlotInventoryTab = nil


function ReciveShowUIShopData_hander( _skins, _own_accessories, _accessories )
	skins = { }
	for _, model in pairs( _skins ) do
		skins[ model ] = true
	end

	own_accessories = _own_accessories
	accessories = _accessories[ localPlayer.model ] or { }
	all_accessories = _accessories

	ShowUIShop( )
end
addEvent( "ReciveShowUIShopData", true )
addEventHandler( "ReciveShowUIShopData", resourceRoot, ReciveShowUIShopData_hander )

function ShowUIShop( )
	if isElement( UIe.black_bg ) then return end

	SetupClothesInterior( )

	showCursor( true )
	
	local main_hud_bg = exports.nrp_hud:GetMainBG( )
	if isElement( main_hud_bg ) then
		bg_pos_y, bg_size_x = main_hud_bg:ibGetAfterY( 10 ), 340
		bg_pos_x, bg_size_y = screen_size_x - bg_size_x - pos_offset, screen_size_y - bg_pos_y - pos_offset
	end

	UIe.black_bg 	= ibCreateBackground( 0x00000000, HideUIShop, true, true )
	UIe.bg_img		= ibCreateImage( bg_pos_x, bg_pos_y, bg_size_x, bg_size_y, _, UIe.black_bg, ibApplyAlpha( 0xff475d75, 95 ) )
	UIe.head_bg		= ibCreateImage( 0, 0, bg_size_x, 56, _, UIe.bg_img, ibApplyAlpha( 0xff95caff, 15 ) )
	UIe.worked_bg	= ibCreateRenderTarget( 0, 56, bg_size_x, bg_size_y - 56, UIe.bg_img )
	UIe.bottom_line	= ibCreateImage( 0, bg_size_y - 52, bg_size_x, 1, _, UIe.bg_img, ibApplyAlpha( COLOR_WHITE, 15 ) )

	SwitchTab( "main" )

	UpdateCurrentAccessories( )

	addEventHandler( "onClientClick", root, DetectClickOnPedDummy )
	addEventHandler( "onClientRender", root, DetectMouseOnPedDummy )
	addEventHandler( "onClientKey", root, DetectMouseScroll )
end

function HideUIShop( )
	if not isElement( UIe.black_bg ) then return end

	triggerServerEvent( "ClientRequestDataAndShowUIShop", resourceRoot, false )

	CleanupClothesInterior( )

	showCursor( false )

	destroyElement( UIe.black_bg )
	destroyElement( UIe.bg_accessories )

	removeEventHandler( "onClientClick", root, DetectClickOnPedDummy )
	removeEventHandler( "onClientRender", root, DetectMouseOnPedDummy )
	removeEventHandler( "onClientKey", root, DetectMouseScroll )
end
addEvent( "HideUIShop", true )
addEventHandler( "HideUIShop", resourceRoot, HideUIShop )

function UpdateCurrentAccessories( )
	local after_empty = false
	if isElement( UIe.bg_accessories ) then
		if UIe.btn_takeoff_all:ibData( "disabled" ) then
			after_empty = true
		end

		destroyElement( UIe.bg_accessories )
	end

	do
		local slot, info = next( accessories )
		if slot then
			if type( info ) == "string" then
				triggerServerEvent( "PlayerWantChangeAccessoriesSlot", resourceRoot, localPlayer.model )
				accessories = { }
			end
		end
	end

	local current_empty = true
	local size_y = 90 + 100 * #CONST_ACCESSORIES_SLOTS_NAME
	UIe.bg_accessories = ibCreateArea( 20, math.floor( ( screen_size_y - size_y ) / 2 ), 90, size_y )

	for slot, name in pairs( CONST_ACCESSORIES_SLOTS_NAME ) do
		local bg = ibCreateImage( 0, 100 * ( slot - 1 ), 90, 90, "images/accessory_slot_bg.png", UIe.bg_accessories )

		local s_slot = CONST_ACCESSORIES_SLOTS_IDS[ slot ]
		if accessories[ s_slot ] then
			ibCreateContentImage( 0, 0, 90, 90, "accessory", accessories[ s_slot ].id, bg )
			current_empty = false
		end
	end

	UIe.btn_takeoff_all = ibCreateButton( 0, 100 * #CONST_ACCESSORIES_SLOTS_NAME, 90, 90, UIe.bg_accessories, "images/btn_takeoff_all_i.png", "images/btn_takeoff_all_h.png", "images/btn_takeoff_all_c.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )

			HideAccessoryEdit( )

			accessories = { }
			accessories_preview = { }
			triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
				model = ped_dummy.model;
				list = accessories_preview;
			} )
			triggerServerEvent( "PlayerWantChangeAccessoriesSlot", resourceRoot, ped_dummy.model )

			UpdateCurrentAccessories( )

			UIe.btn_takeoff_all:ibAlphaTo( 0, 250 )
			UIe.btn_takeoff_all:ibData( "disabled", true )
			UIe.bg_accessories:ibMoveTo( UIe.bg_accessories:ibData( "px" ), UIe.bg_accessories:ibData( "py" ) + 45 )
		end)
	
	if after_empty and not current_empty then
		UIe.btn_takeoff_all:ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
		UIe.bg_accessories:ibData( "py", UIe.bg_accessories:ibData( "py" ) + 45 ):ibMoveTo( UIe.bg_accessories:ibData( "px" ), UIe.bg_accessories:ibData( "py" ) - 43 )
	elseif current_empty then
		UIe.btn_takeoff_all:ibData( "alpha", 0 )
		UIe.btn_takeoff_all:ibData( "disabled", true )
		UIe.bg_accessories:ibData( "py", UIe.bg_accessories:ibData( "py" ) + 45 )
	end
end

function SwitchTab( tab_id )
	if not TAB_LIST[ tab_id ] then return end

	selected_tab = tab_id

	if isElement( UIe.tab_bg ) then
		UIe.tab_bg:ibMoveTo( -25, 0, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
		UIe.head_label:ibMoveTo( -5, 28, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
		UIe.back_btn:ibMoveTo( -25, bg_size_y - 56 - 51, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
		
		UIe.tab_bg = nil
		UIe.head_label = nil
	end

	ped_dummy.model = localPlayer.model
	accessories_preview = table.copy( accessories )
	triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
		model = ped_dummy.model;
		list = accessories_preview;
	} )

	UIe.head_label	= ibCreateLabel( 20, 28, 0, 0, TAB_LIST[ tab_id ].name, UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_16 )
	UIe.tab_bg		= ibCreateArea( 0, 0, bg_size_x, UIe.worked_bg:ibData( "sy" ) - 52, UIe.worked_bg )
	TAB_LIST[ tab_id ]:create( )

	if tab_id == "main" then
		UIe.back_btn = ibCreateButton( 0, bg_size_y - 56 - 51, bg_size_x, 51, UIe.worked_bg, "images/btn_exit_i.png", "images/btn_exit_h.png", "images/btn_exit_c.png" )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				HideUIShop( )
			end)
	else
		UIe.back_btn = ibCreateButton( 0, bg_size_y - 56 - 51, bg_size_x, 51, UIe.worked_bg, "images/btn_back_i.png", "images/btn_back_h.png", "images/btn_back_c.png" )
			:ibOnClick( function( key, state ) 
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				SwitchTab( "main" )
			end)
	end

	UIe.tab_bg:ibBatchData( {
		alpha = 0;
		px = 25;
	} ):ibMoveTo( 0, 0, 250 ):ibAlphaTo( 255, 250 )
	UIe.head_label:ibBatchData( {
		alpha = 0;
		px = 45;
	} ):ibMoveTo( 20, 28, 250 ):ibAlphaTo( 255, 250 )
	UIe.back_btn:ibBatchData( {
		alpha = 0;
		px = 25;
	} ):ibMoveTo( 0, bg_size_y - 56 - 51, 250 ):ibAlphaTo( 255, 250 )
end

function ShowAccessoryEdit( id, slot, puton )
	if not isElement( UIe.bg_img ) then return end

	local edit_tabs = {
		{
			id = "pos";
			name = "Настройка положения";

			scroll_upd = {
				{
					get = function( )
						return accessories_preview[ slot ].position.x
					end;

					set = function( value )
						accessories_preview[ slot ].position.x = value
					end;
				};
				{
					get = function( )
						return accessories_preview[ slot ].position.y
					end;

					set = function( value )
						accessories_preview[ slot ].position.y = value
					end;
				};
				{
					get = function( )
						return accessories_preview[ slot ].position.z
					end;

					set = function( value )
						accessories_preview[ slot ].position.z = value
					end;
				};
			};

			scroll_upd_set_value = function( value )
				return ( value - 0.5 ) / 1.5
			end;

			scroll_upd_get_value = function( value )
				return value * 1.5 + 0.5
			end;
		};
		{
			id = "rot";
			name = "Настройка поворота";

			scroll_upd = {
				{
					get = function( )
						return accessories_preview[ slot ].rotation.x
					end;

					set = function( value )
						accessories_preview[ slot ].rotation.x = value
					end;
				};
				{
					get = function( )
						return accessories_preview[ slot ].rotation.y
					end;

					set = function( value )
						accessories_preview[ slot ].rotation.y = value
					end;
				};
				{
					get = function( )
						return accessories_preview[ slot ].rotation.z
					end;

					set = function( value )
						accessories_preview[ slot ].rotation.z = value
					end;
				};
			};

			scroll_upd_set_value = function( value )
				return ( value - 0.5 ) * 360
			end;

			scroll_upd_get_value = function( value )
				return value / 360 + 0.5
			end;
		};
		{
			id = "scale";
			name = "Настройка размера";

			scroll_upd = {
				{
					get = function( )
						return accessories_preview[ slot ].scale
					end;

					set = function( value )
						accessories_preview[ slot ].scale = value
					end;
				};
			};

			scroll_upd_set_value = function( value )
				return ( value * 0.5 + 0.75 )
			end;

			scroll_upd_get_value = function( value )
				return ( value - 0.75 ) / 0.5
			end;
		};
	}

	UIe.bg_img:ibMoveTo( screen_size_x, bg_pos_y, 250 )
	UIe.bg_aedit = ibCreateArea( -80, 0, 60, bg_size_y, UIe.bg_img ):center_y( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
	UIe.bg_aedit_list = ibCreateArea( 0, 0, 60, 3 * 60 + 2 * 7, UIe.bg_aedit ):center_y( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

	local current_edita_tab = nil
	func_SwitchEditATab = function( i, btn_tab )
		if current_edita_tab == i then return end

		if isElement( UIe.aedit_controller_bg ) then
			UIe.aedit_controller_bg:ibAlphaTo( 0, 250 ):ibMoveTo( -260, UIe.aedit_controller_bg:ibData( "py" ), 250 ):ibTimer( destroyElement, 250, 1 )
		end

		current_edita_tab = i
		local tab_data = edit_tabs[ i ]

		UIe.aedit_controller_bg = ibCreateImage( -260, 0, 266, 56 + 25 + 40 * #tab_data.scroll_upd, _, btn_tab, ibApplyAlpha( 0xff475d75, 95 ) )
			:center_y( )
		UIe.aedit_controller_bg:ibData( "alpha", 0 )
			:ibAlphaTo( 255, 250 )
			:ibMoveTo( -280, UIe.aedit_controller_bg:ibData( "py" ), 250 )

		ibCreateImage( 271, 0, 9, 13, "images/edit_a_arrow.png", UIe.aedit_controller_bg ):center_y()
		ibCreateImage( 0, 0, 266, 56, _, UIe.aedit_controller_bg, ibApplyAlpha( 0xff95caff, 15 ) )
		ibCreateLabel( 20, 28, 0, 0, tab_data.name, UIe.aedit_controller_bg ):ibBatchData( { font = ibFonts.bold_16, align_x = "left", align_y = "center" } )

		for i, func in pairs( tab_data.scroll_upd ) do
			ibCreateImage( 19, ( 56 + 31 + 40 * ( i - 1 ) ) - 16, 47, 32, _, UIe.aedit_controller_bg, 0x20ffffff )
			ibCreateImage( 20, ( 56 + 31 + 40 * ( i - 1 ) ) - 15, 45, 30, _, UIe.aedit_controller_bg, ibApplyAlpha( COLOR_BLACK, 25 ) )

			local value = tab_data.scroll_upd_get_value( func.get( ) )
			local value_edit = ibCreateEdit( 25, ( 56 + 31 + 40 * ( i - 1 ) ) - 10, 35, 20, math.floor( ( value - 0.5 ) * 1000 ), UIe.aedit_controller_bg, ibApplyAlpha( COLOR_WHITE, 75 ), 0, ibApplyAlpha( COLOR_WHITE, 75 ) )
				:ibData( "font", ibFonts.light_15 )
				:ibData( "max_length", 4 )
			value_edit:ibOnDataChange( function( key, value, old )
					if key == "text" then
						value = tonumber( value )
						if not value then return end

						if value < -500 or value > 500 then
							value_edit:ibData( "text", old )
							return
						end

						func.set( tab_data.scroll_upd_set_value( value / 1000 + 0.5 ) )

						triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
							model = ped_dummy.model;
							list = accessories_preview
						} )
					end
				end )
			ibScrollbarH( { px = 75, py = ( 56 + 30 + 40 * ( i - 1 ) ), sx = 171, sy = 40, parent = UIe.aedit_controller_bg } )
				:ibSetStyle( "tuning" ):ibData( "position", value )
				:ibOnDataChange( function( key, value )
					if key == "position" then
						value = math.floor( ( value - 0.5 ) * 1000 )
						value_edit:ibData( "text", value )
						value_edit:ibData( "caret_position", 0 )
					end
				end )
		end
	end

	for i, tab in pairs( edit_tabs ) do
		local btn = ibCreateButton( 0, 67 * ( i - 1 ), 60, 60, UIe.bg_aedit_list, "images/edit_a_".. tab.id .."_i.png", "images/edit_a_".. tab.id .."_h.png", "images/edit_a_".. tab.id .."_c.png" )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				func_SwitchEditATab( i, source )
			end )

		if i == 1 then
			func_SwitchEditATab( i, btn )
		end
	end

	ibCreateButton( 0, bg_size_y - 60 - 67, 60, 60, UIe.bg_aedit, "images/edit_a_save_i.png", "images/edit_a_save_h.png", "images/edit_a_save_c.png" )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				if puton then
					accessories[ slot ] = table.copy( accessories_preview[ slot ] )
					UpdateCurrentAccessories( )

					local info = accessories[ slot ]
					triggerServerEvent( "PlayerWantChangeAccessoriesSlot", resourceRoot, ped_dummy.model, slot, info.id, info.position, info.rotation, info.scale )
				end

				HideAccessoryEdit( puton )
			end )

	ibCreateButton( 0, bg_size_y - 60, 60, 60, UIe.bg_aedit, "images/edit_a_exit_i.png", "images/edit_a_exit_h.png", "images/edit_a_exit_c.png" )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				accessories_preview[ slot ] = accessories[ slot ] and table.copy( accessories[ slot ] )

				triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
					model = ped_dummy.model;
					list = accessories_preview
				} )

				HideAccessoryEdit( puton )
			end )
end

function HideAccessoryEdit( is_inventory )
	if isElement( UIe.bg_aedit ) then
		UIe.bg_img:ibMoveTo( bg_pos_x, bg_pos_y, 250 )
		UIe.bg_aedit:ibMoveTo( bg_pos_x, bg_pos_y, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )

		func_SwitchSlot( is_inventory and func_CreateSlotInventoryTab or func_CreateSlotShopTab, _, 1, true )
	end
end

TAB_LIST = {
	clothes = {
		global = true;
		name = "Одежда";

		create = function( )
			local current_tab = nil
			local tab_bg_sy = UIe.tab_bg:ibData( "sy" )
			local player_gender = localPlayer:GetGender( )
			
			local btn_bg = ibCreateImage( 0, 0, 170, 44, _, UIe.tab_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
			local btn_shop = ibCreateButton( 0, 0, 170, 44, UIe.tab_bg, "images/btn_tab_shop.png", "images/btn_tab_shop.png", "images/btn_tab_shop.png" )
			local btn_inventory = ibCreateButton( 170, 0, 170, 44, UIe.tab_bg, "images/btn_tab_inventory.png", "images/btn_tab_inventory.png", "images/btn_tab_inventory.png" ):ibData( "alpha", 128 )

			func_SwitchTab = function( func_CreateTab, move_type )
				if current_tab == func_CreateTab then return end

				if isElement( UIe.scrollpane ) then
					UIe.scrollpane:ibMoveTo( -340 * move_type, 44, 250 ):ibTimer( destroyElement, 250, 1 )
					UIe.scrollbar:ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
				end

				UIe.scrollpane, UIe.scrollbar	= ibCreateScrollpane( 0, 44, bg_size_x, bg_size_y - 56 - 52 - 44, UIe.tab_bg, { scroll_px = -15, bg_color = 0 } )
				UIe.scrollbar:ibBatchData( { absolute = true, sensivity = 50 } ):ibSetStyle( "slim_small_nobg" )

				func_CreateTab( move_type )
				current_tab = func_CreateTab

				UIe.scrollpane:AdaptHeightToContents( )
				UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )

				UIe.btn_buy:ibData( "priority", 1 )

				if func_CreateTab == func_CreateShopTab then
					btn_bg:ibMoveTo( 0, 0, 250 )
					btn_shop:ibAlphaTo( 255, 250 )
					btn_inventory:ibAlphaTo( 128, 250 )
				else
					btn_bg:ibMoveTo( 170, 0, 250 )
					btn_shop:ibAlphaTo( 128, 250 )
					btn_inventory:ibAlphaTo( 255, 250 )
				end
			end

			func_CreateShopTab = function( move_type )
				local real_timestamp = getRealTimestamp( )

				local boutique_assortiment = { }
				for model, info in pairs( BOUTIQUE_ASSORTMENT[ player_gender ] ) do
					local timestamp = true
					if info.time_start then
						if getTimestampFromString( info.time_start, true ) > real_timestamp then
							timestamp = false
						end
						if info.time_new == true then
							info.time_new = getTimestampFromString( info.time_start, true ) + 7 * 24 * 60 * 60
						end
					end
					if not skins[ model ] and timestamp then
						table.insert( boutique_assortiment, info )
					end
				end
				table.sort( boutique_assortiment, function( first, second )
					if first.time_new then
						if second.time_new then
							return first.cost < second.cost
						else
							return true
						end
					else
						if second.time_new then
							return false
						else
							return first.cost < second.cost
						end
					end
				end )

				selected_clothes = boutique_assortiment[ 1 ] and boutique_assortiment[ 1 ].model

				local timer_ticks = 50
				for i, info in pairs( boutique_assortiment ) do
					local bg	= ibCreateArea( 350 * move_type, 108 * ( i - 1 ), 340, 108, UIe.scrollpane )
									:ibTimer( function( self )
										self:ibMoveTo( 0, 108 * ( i - 1 ), 250 )
									end, timer_ticks, 1 )
					timer_ticks = timer_ticks + 50

					ibCreateImage( 0, 107, 340, 1, _, bg, 0x26FFFFFF )

					local bg_hover_img			= ibCreateImage( 0, -1, 340, 109, _, bg, 0xFF6988A8 ):ibData( "alpha", 0 )

					local item_blocked = false
					local blocked_text = ""
					if info.blocked then
						if info.blocked.unlock and not localPlayer:IsUnlocked( info.blocked.unlock ) then
							item_blocked = true
							blocked_text = info.blocked.hint
						end

						if info.blocked.premium and ( not localPlayer:IsPremiumActive( ) ) then
							item_blocked = true
							blocked_text = "Доступно с премиумом"
						end
					end

					local clothes_slot_bg		= ibCreateImage( 21, 13, 80, 80, "images/slot_bg".. ( selected_clothes == info.model and "_selected" or "" ) ..".png", bg )
					ibCreateImage( 21, 23, 38, 34, "images/".. ( item_blocked and "blocked" or "clothes" ) .."_icon.png", clothes_slot_bg )

					if selected_clothes == info.model then
						selected_clothes_element = clothes_slot_bg

						ped_dummy.model = info.model

						triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
							model = ped_dummy.model;
							list = all_accessories[ ped_dummy.model ]
						} )
					end

					if skins[ info.model ] then
						ibCreateImage( 56, 6, 18, 15, "images/okey_icon.png", clothes_slot_bg )
					end

					local is_new = info.time_new and info.time_new > real_timestamp
					local lbl_sx = is_new and 133 or 197
					ibCreateLabel( 124, 36, lbl_sx, 0, info.name, bg ):ibBatchData( { font = ibFonts.light_19, align_x = "left", align_y = "center", wordbreak = true } )

					local cost = info.cost
					if ( ( localPlayer:getData( "offer_skin" ) or { } ).time_to or 0 ) >= real_timestamp then
						cost = math.floor( cost * 0.85 ) -- 15% discount
					end

					local oy = dxGetTextWidth( info.name, 1, ibFonts.light_19 ) > lbl_sx and 8 or 0
					ibCreateImage( 124, 56 + oy, 28, 28, ":nrp_shared/img/money_icon.png", bg )
					ibCreateLabel( 160, 69 + oy, 0, 0, format_price( cost ), bg ):ibBatchData( { font = ibFonts.bold_20, align_x = "left", align_y = "center" } )

					if is_new then
						local bg = ibCreateArea( 257, 24, 64, 24, bg ):center_y( )
						
						local func_interpolate = function( self )
							self:ibInterpolate( function( self )
								if not isElement( self.element ) then return end
								self.easing_value = 1 - self.easing_value
								self.element:ibData( "rotation", 360 * self.easing_value )
									:ibBatchData( { sx = 64 * self.easing_value; sy = 24 * self.easing_value } )
									:center( )
							end, 500, "SineCurve" )
						end

						ibCreateImage( 0, 0, 64, 24, "images/big_new_indicator.png", bg )
							:ibTimer( func_interpolate, 5000, 0 )
							:ibTimer( func_interpolate, 500, 1 )
					end

					local clicked_bg = ibCreateArea( 0, 0, 340, 108, bg )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )

						selected_clothes_element:ibData( "texture", string.gsub( selected_clothes_element:ibData( "texture" ), "_selected", "" ) )
						clothes_slot_bg:ibData( "texture", string.gsub( clothes_slot_bg:ibData( "texture" ), ".png", "_selected.png" ) )

						selected_clothes = info.model
						selected_clothes_element = clothes_slot_bg

						ped_dummy.model = info.model

						triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
							model = ped_dummy.model;
							list = all_accessories[ ped_dummy.model ]
						} )
					end )

					if item_blocked then
						clicked_bg:ibAttachTooltip( blocked_text )
					end
				end

				UIe.btn_buy:ibAlphaTo( 255, 250 )
					:ibMoveTo( 0, tab_bg_sy - 51, 250 )
					:ibResizeTo( 340, 51, 250 )
			end

			func_CreateInventoryTab = function( move_type )
				selected_clothes = next( skins )

				local i = 0
				local timer_ticks = 50
				for model in pairs( skins ) do
					i = i + 1
					local bg	= ibCreateArea( 340 * move_type, 108 * ( i - 1 ), 340, 108, UIe.scrollpane )
									:ibTimer( function( self )
										self:ibMoveTo( 0, self:ibData( "py" ), 250 )
									end, timer_ticks, 1 )
					timer_ticks = timer_ticks + 50
					UIe[ "scroll_items".. i ] = bg

					ibCreateImage( 0, 107, 340, 1, _, bg, 0x26FFFFFF )

					local bg_hover_img			= ibCreateImage( 0, -1, 340, 109, _, bg, 0xFF6988A8 ):ibData( "alpha", 0 )
					local clothes_slot_bg		= ibCreateImage( 21, 13, 80, 80, "images/slot_bg".. ( selected_clothes == model and "_selected" or "" ) ..".png", bg )
					ibCreateImage( 21, 23, 38, 34, "images/clothes_icon.png", clothes_slot_bg )

					if selected_clothes == model then
						selected_clothes_element = clothes_slot_bg

						ped_dummy.model = model

						triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
							model = ped_dummy.model;
							list = all_accessories[ ped_dummy.model ]
						} )
					end

					local lbl_name = ibCreateLabel( 124, 36, 0, 0, SKINS_NAMES[ model ], bg ):ibBatchData( { font = ibFonts.light_19, align_x = "left", align_y = "center" } )

					ibCreateArea( 0, 0, 340, 108, bg )
						:ibOnClick( function( key, state )
							if key ~= "left" or state ~= "up" then return end
							ibClick( )

							selected_clothes_element:ibData( "texture", string.gsub( selected_clothes_element:ibData( "texture" ), "_selected", "" ) )
							clothes_slot_bg:ibData( "texture", string.gsub( clothes_slot_bg:ibData( "texture" ), ".png", "_selected.png" ) )

							selected_clothes = model
							selected_clothes_element = clothes_slot_bg

							ped_dummy.model = model

							triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
								model = ped_dummy.model;
								list = all_accessories[ ped_dummy.model ]
							} )
						end )
						:ibOnHover( function( )
							bg_hover_img:ibAlphaTo( 100, 250 )
						end )
						:ibOnLeave( function( )
							bg_hover_img:ibAlphaTo( 0, 250 )
						end )

					if model ~= localPlayer.model then
						ibCreateButton( 124, 60, 71, 22, bg, "images/btn_puton_i.png", "images/btn_puton_h.png", "images/btn_puton_c.png" )
							:ibOnClick( function( key, state ) 
								if key ~= "left" or state ~= "up" then return end
								ibClick( )

								triggerServerEvent( "PlayerWantUseSkin", resourceRoot, model )
							end)
					else
						ibCreateImage( 56, 6, 18, 15, "images/okey_icon.png", clothes_slot_bg )
						lbl_name:center_y( )
					end
				end

				UIe.btn_buy:ibAlphaTo( 0, 250 )
					:ibMoveTo( 0, tab_bg_sy, 250 )
					:ibResizeTo( 340, 0, 250 )
			end

			btn_shop:ibOnClick( function( key, state ) 
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchTab( func_CreateShopTab, -1 )
				end )
			btn_inventory:ibOnClick( function( key, state ) 
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchTab( func_CreateInventoryTab, 1 )
				end )

			UIe.btn_buy = ibCreateButton( 0, tab_bg_sy, 340, 0, UIe.tab_bg, "images/btn_buy_i.png", "images/btn_buy_h.png", "images/btn_buy_c.png" )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					local clothes = BOUTIQUE_ASSORTMENT[ player_gender ][ selected_clothes ]
					
					if not clothes then return end

					-- iprint( player_gender, selected_clothes, BOUTIQUE_ASSORTMENT[ player_gender ] )

					if skins[ clothes.model ] then
						localPlayer:ShowError( "Вы уже приобрели эту одежду" )
						return
					end

					local item_blocked = false
					local blocked_text = ""
					if clothes.blocked then
						if clothes.blocked.unlock and not localPlayer:IsUnlocked( clothes.blocked.unlock ) then
							item_blocked = true
							blocked_text = clothes.blocked.hint
						end
				
						if clothes.blocked.premium and ( not localPlayer:IsPremiumActive( ) ) then
							item_blocked = true
							blocked_text = "Доступно с премиумом"
						end
					end
				
					if item_blocked then
						localPlayer:ShowError( blocked_text )
						return
					end

					local cost = clothes.cost
					if ( ( localPlayer:getData( "offer_skin" ) or { } ).time_to or 0 ) >= getRealTimestamp( ) then
						cost = math.floor( cost * 0.85 ) -- 15% discount
					end

					ibConfirm( {
						title = "ПОКУПКА ОДЕЖДЫ",
						text = " Вы уверены что хотите приобрести скин\n" .. clothes.name .. " за " .. format_price( cost ) .. "р.?" ,
						fn = function( self )
							triggerServerEvent( "PlayerWantBuyClothes", resourceRoot, selected_clothes )
							self:destroy()
						end,
						escape_close = true,
					} )

				end )
				:ibData( "alpha", 0 )

			func_SwitchTab( func_CreateShopTab, 1 )
		end;
	};
	accessories = {
		global = true;
		name = "Аксессуары";

		create = function( )
			local real_timestamp = getRealTimestamp( )
			local current_slot = nil
			local current_slot_index = nil
			local tab_bg_sy = UIe.tab_bg:ibData( "sy" )
			local selected_accessory_id = nil
			local selected_accessory_element = nil
			local current_btn_cancel_preview = nil

			local accessories_ids_by_slots = { }
			for id, info in pairs( CONST_ACCESSORIES_INFO ) do
				if not accessories_ids_by_slots[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ info.slot ] ] then accessories_ids_by_slots[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ info.slot ] ] = { } end

				if not info.hidden or own_accessories[ id ] then

					if info.time_start then
						if getTimestampFromString( info.time_start, true ) < real_timestamp then
							table.insert( accessories_ids_by_slots[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ info.slot ] ], id )
						end
						
						if info.time_new == true then
							info.time_new = getTimestampFromString( info.time_start, true ) + 7 * 24 * 60 * 60
						end
					else
						table.insert( accessories_ids_by_slots[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ info.slot ] ], id )
					end
				end
			end

			func_CreateSellItem = function( bg, id )
				local info = CONST_ACCESSORIES_INFO[ id ]
				local bg_sy = bg:ibData( "sy" )
				
				local line_img				= ibCreateImage( 0, bg_sy - 1, 340, 1, _, bg, 0x26FFFFFF )

				local bg_hover_img			= ibCreateImage( 0, 0, 340, bg_sy - 1, _, bg, 0x806988a8 ):ibData( "alpha", 0 )

				local item_blocked = false
				local info_text = nil

				if info.premium and not localPlayer:IsPremiumActive( ) then
					item_blocked = true
					info_text = "Доступно с премиумом"

				elseif info.level and localPlayer:GetLevel() < info.level then
					item_blocked = true
					local txt = info.level == 2 and "Доступно со " or "Доступно с "
					info_text = txt.. info.level .." ур."

				elseif ACCESSORIES_FOR_DOWN_DAMAGE[id] then
					info_text = "Снижает урон от падений с байка на 80%"
				end

				local accessory_slot_bg		= ibCreateImage( 20, 15, 90, 90, "images/accessory_slot_bg.png", bg )
				local accessory_slot_img	= ibCreateContentImage( 0, 0, 90, 90, "accessory", id, accessory_slot_bg )

				local accessory_blocked_icon = nil
				if item_blocked then
					accessory_blocked_icon = ibCreateImage( 0, 0, 38, 34, "images/blocked_icon.png", accessory_slot_bg ):center( )
				end

				local y_lines = 0
				string.gsub( info.name, "\n", function( s ) y_lines = y_lines + 1 end )
				local line_size = 25 --Возможно стоит поправить, если строк больше двух
				local name_label = ibCreateLabel( 124, accessory_slot_bg:ibGetBeforeY( 28 ), 0, 0, info.name, bg )
					:ibBatchData( { font = ibFonts.light_16, align_x = "left", align_y = "top" } )

				local cost_oy = 7
				if own_accessories[ id ] or ( info.premium and localPlayer:IsPremiumActive( ) ) then
					ibCreateImage( 77, 19, 18, 15, "images/okey_icon.png", bg )
				else
					if info.soft_cost then
						local cost_img = ibCreateImage( 124, name_label:ibGetAfterY( line_size * y_lines + cost_oy ), 28, 28, ":nrp_shared/img/money_icon.png", bg )
						ibCreateLabel( 163, cost_img:ibGetCenterY(), 0, 0, format_price( info.soft_cost ), bg )
							:ibBatchData( { font = ibFonts.bold_20, align_x = "left", align_y = "center" } )

					elseif info.hard_cost then
						local cost_img = ibCreateImage( 124, name_label:ibGetAfterY( line_size * y_lines + cost_oy ), 28, 28, ":nrp_shared/img/hard_money_icon.png", bg )
						ibCreateLabel( 163, cost_img:ibGetCenterY(), 0, 0, format_price( info.hard_cost ), bg )
							:ibBatchData( { font = ibFonts.bold_20, align_x = "left", align_y = "center" } )

					elseif info.premium then
						local prem_img = ibCreateImage( 124, name_label:ibGetAfterY( line_size * y_lines + cost_oy ), 28, 28, ":nrp_shared/img/icon_premium.png", bg )
						ibCreateLabel( 163, prem_img:ibGetCenterY(), 0, 0, "Премиум", bg )
							:ibBatchData( { font = ibFonts.bold_20, align_x = "left", align_y = "center" } )
					end
				end
				
				if info.time_new and info.time_new > real_timestamp then
					ibCreateImage( accessory_slot_bg:width( ) - 17, 8, 11, 11, ":nrp_dancing_school/files/img/new_indicator.png", accessory_slot_bg )
				end

				local clicked_bg = ibCreateArea( 0, 0, 340, bg_sy, bg )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					if item_blocked then
						ibError( )
						accessory_blocked_icon:ibInterpolate( function( self )
							if not isElement( self.element ) then return end
							self.easing_value = self.easing_value - 0.5
							self.element:center_x( 10 * self.easing_value )
						end, 150, "CosineCurve" )

						return
					end

					ibClick( )

					if isElement( selected_accessory_element ) then
						selected_accessory_element:ibData( "texture", string.gsub( selected_accessory_element:ibData( "texture" ), "_selected", "" ) )
					end

					if selected_accessory_id == id then
						if not selected_accessory_id then return end

						accessory_slot_bg:ibData( "texture", string.gsub( accessory_slot_bg:ibData( "texture" ), "_selected", "" ) )

						selected_accessory_id = nil
						selected_accessory_element = nil

						UIe.btn_buy:ibAlphaTo( 0, 250 )
						:ibMoveTo( 0, tab_bg_sy, 250 )
						:ibResizeTo( 340, 0, 250 )
					else
						accessory_slot_bg:ibData( "texture", string.gsub( accessory_slot_bg:ibData( "texture" ), ".png", "_selected.png" ) )

						selected_accessory_id = id
						selected_accessory_element = accessory_slot_bg

						UIe.btn_buy:ibAlphaTo( 255, 250 )
						:ibMoveTo( 0, tab_bg_sy - 51, 250 )
						:ibResizeTo( 340, 51, 250 )
					end
				end )

				if info_text then
					clicked_bg:ibAttachTooltip( info_text )
				end

				local func_UpdBtnPreview = nil
				func_UpdBtnPreview = function( current )
					local slot = CONST_ACCESSORIES_SLOTS_IDS[ current_slot_index ]
					if accessories_preview[ slot ] and accessories_preview[ slot ].id == id then
						if isElement( current_btn_cancel_preview ) then
							destroyElement( current_btn_cancel_preview )
						end

						current_btn_cancel_preview = ibCreateButton( 120, accessory_slot_bg:ibGetBeforeY( 2 ), 110, 20, clicked_bg, "images/btn_cpreview_i.png", "images/btn_cpreview_h.png", "images/btn_cpreview_c.png" )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )

								accessories_preview[ slot ] = nil

								triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
									model = ped_dummy.model;
									list = accessories_preview
								} )

								func_UpdBtnPreview( true )
							end )
					else
						if current and isElement( current_btn_cancel_preview ) then
							destroyElement( current_btn_cancel_preview )
						end

						ibCreateButton( 120, accessory_slot_bg:ibGetBeforeY( 2 ), 125, 20, clicked_bg, "images/btn_preview_i.png", "images/btn_preview_h.png", "images/btn_preview_c.png" )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )

								accessories_preview[ slot ] = accessories_preview[ slot ] or {
									position = { x = 0, y = 0, z = 0 };
									rotation = { x = 0, y = 0, z = 0 };
									scale = 1;
								}
								accessories_preview[ slot ].id = id

								triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
									model = ped_dummy.model;
									list = accessories_preview
								} )
								localPlayer:CompleteDailyQuest( "try_accessoaries" )
								ShowAccessoryEdit( id, slot )
							end )
					end
				end

				func_UpdBtnPreview( )
			end
			
			func_CreateOwnItem = function( bg, id )
				local info = CONST_ACCESSORIES_INFO[ id ]
				local bg_sy = bg:ibData( "sy" )
				
				ibCreateImage( 0, bg_sy - 1, 340, 1, _, bg, 0x26FFFFFF )
				ibCreateImage( 0, 0, 340, bg_sy - 1, _, bg, 0x806988a8 ):ibData( "alpha", 0 )
				local accessory_slot_bg	= ibCreateImage( 20, 15, 90, 90, "images/accessory_slot_bg.png", bg )
				local accessory_slot_img = ibCreateContentImage( 0, 0, 90, 90, "accessory", id, accessory_slot_bg )

				local y_lines = 0
				string.gsub( info.name, "\n", function( s ) y_lines = y_lines + 1 end )
				local line_size = 20

				local name_label = ibCreateLabel( 124, accessory_slot_bg:ibGetBeforeY( 12 ), 0, 0, info.name, bg )
				:ibBatchData( { font = ibFonts.light_16, align_x = "left", align_y = "top" } )

				local slot = CONST_ACCESSORIES_SLOTS_IDS[ current_slot_index ]
				local clicked_bg = ibCreateArea( 0, 0, 340, 120, bg )

				local func_UpdBtnUseAsseccory = nil
				func_UpdBtnUseAsseccory = function( current )
					if accessories[ slot ] and accessories[ slot ].id == id then
						if isElement( current_okey_icon ) then
							destroyElement( current_okey_icon )
						end

						current_okey_icon = ibCreateImage( 62, 9, 18, 15, "images/okey_icon.png", accessory_slot_img )


						if isElement( current_btn_takeoff ) then
							destroyElement( current_btn_takeoff )
						end
						local py = y_lines > 0 and name_label:ibGetAfterY( line_size * y_lines + 10 ) or 68
						current_btn_takeoff = ibCreateButton( 124, py, 70, 22, clicked_bg, "images/btn_takeoff_i.png", "images/btn_takeoff_h.png", "images/btn_takeoff_c.png" )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )
								
								accessories[ slot ] = nil
								UpdateCurrentAccessories( )
								accessories_preview[ slot ] = nil

								triggerServerEvent( "PlayerWantChangeAccessoriesSlot", resourceRoot, ped_dummy.model, slot, accessories[ slot ] )

								triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
									model = ped_dummy.model;
									list = accessories_preview
								} )

								func_UpdBtnUseAsseccory( true )

								if not next( accessories ) then
									UIe.btn_takeoff_all:ibAlphaTo( 0, 250 )
									UIe.btn_takeoff_all:ibData( "disabled", true )
									UIe.bg_accessories:ibMoveTo( UIe.bg_accessories:ibData( "px" ), UIe.bg_accessories:ibData( "py" ) + 45 )
								end
							end )

						ibCreateButton( 76, 0, 39, 22, current_btn_takeoff, "images/btn_edit_i.png", "images/btn_edit_h.png", "images/btn_edit_c.png" )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )

								ShowAccessoryEdit( id, slot, true )
							end )
					else
						if current and isElement( current_btn_takeoff ) then
							destroyElement( current_btn_takeoff )

							if isElement( current_okey_icon ) then
								destroyElement( current_okey_icon )
							end
						end
						local py = y_lines > 0 and name_label:ibGetAfterY( line_size * y_lines + 10 ) or 68
						ibCreateButton( 124, py, 71, 22, clicked_bg, "images/btn_puton_i.png", "images/btn_puton_h.png", "images/btn_puton_c.png" )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )

								accessories_preview[ slot ] = ( accessories[ slot ] and table.copy( accessories[ slot ] ) ) or accessories_preview[ slot ] or {
									position = { x = 0, y = 0, z = 0 };
									rotation = { x = 0, y = 0, z = 0 };
									scale = 1;
								}
								accessories_preview[ slot ].id = id

								triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
									model = ped_dummy.model;
									list = accessories_preview
								} )

								ShowAccessoryEdit( id, slot, true )
							end )
					end
				end

				func_UpdBtnUseAsseccory( )
			end

			func_CreateSlotShopTab = function( slot, move_type )
				local accessories_ids = accessories_ids_by_slots[ slot ]

				table.sort( accessories_ids, function( a, b )
					local a = CONST_ACCESSORIES_INFO[ a ]
					local b = CONST_ACCESSORIES_INFO[ b ]
		
					if a.time_new and not b.time_new then
						return true
					elseif b.time_new then
						return false
					elseif a.soft_cost then
						if b.hard_cost then
							return true
						elseif b.premium then
							return true
						elseif b.soft_cost then
							return a.soft_cost < b.soft_cost
						end
					elseif a.premium then
						if b.soft_cost then
							return false
						elseif b.hard_cost then
							return true
						end
					elseif a.hard_cost then
						if b.soft_cost then
							return false
						elseif b.premium then
							return false
						elseif b.hard_cost then
							return a.hard_cost < b.hard_cost
						end
					end
		
					return false
				end )

				local i = 0
				local timer_ticks = 50
				local last_bg
				for _, id in pairs( accessories_ids ) do
					if not ( own_accessories[ id ] or ( CONST_ACCESSORIES_INFO[ id ].premium and localPlayer:IsPremiumActive( ) ) ) then
						i = i + 1
						local py = not last_bg and 120 * ( i - 1 ) or last_bg:ibGetAfterY()
						local y_lines = 0
						local line_size = 25 --Возможно стоит поправить, если строк больше двух
						string.gsub( CONST_ACCESSORIES_INFO[ id ].name, "\n", function( s ) y_lines = y_lines + 1 end )
						local bg	= ibCreateArea( 340 * move_type, py, 340, 120 + y_lines*line_size, UIe.scrollpane )
										:ibTimer( function( self )
											self:ibMoveTo( 0, self:ibData( "py" ), 250 )
										end, timer_ticks, 1 )
						timer_ticks = timer_ticks + 50
						last_bg = bg
						
						func_CreateSellItem( bg, id )
					end
				end
				last_bg = nil
			end

			func_CreateSlotInventoryTab = function( slot, move_type )
				local accessories_ids = accessories_ids_by_slots[ slot ]

				local i = 0
				local timer_ticks = 50
				local last_bg
				for _, id in pairs( accessories_ids ) do
					if own_accessories[ id ] or ( CONST_ACCESSORIES_INFO[ id ].premium and localPlayer:IsPremiumActive( ) ) then
						i = i + 1
						local py = not last_bg and 120 * ( i - 1 ) or last_bg:ibGetAfterY()
						local y_lines = 0
						local line_size = 20 --Возможно стоит поправить, если строк больше двух
						-- string.gsub( CONST_ACCESSORIES_INFO[ id ].name, "\n", function( s ) y_lines = y_lines + 1 end )
						local bg	= ibCreateArea( 340 * move_type, py, 340, 120 + y_lines*line_size, UIe.scrollpane )
										:ibTimer( function( self )
											self:ibMoveTo( 0, self:ibData( "py" ), 250 )
										end, timer_ticks, 1 )
						timer_ticks = timer_ticks + 50
						last_bg = bg
						func_CreateOwnItem( bg, id )
					end
				end
			end

			local btn_bg = ibCreateImage( 0, 0, 170, 44, _, UIe.tab_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
			local btn_shop = ibCreateButton( 0, 0, 170, 44, UIe.tab_bg, "images/btn_tab_shop.png", "images/btn_tab_shop.png", "images/btn_tab_shop.png" )
			local btn_inventory = ibCreateButton( 170, 0, 170, 44, UIe.tab_bg, "images/btn_tab_inventory.png", "images/btn_tab_inventory.png", "images/btn_tab_inventory.png" ):ibData( "alpha", 128 )

			func_SwitchSlot = function( func_CreateSlot, slot, move_type, hard_reset )
				if current_slot == func_CreateSlot and current_slot_index == slot and not hard_reset then return end

				-- Уффф, костылики
				if hard_reset then slot = current_slot_index end

				if isElement( UIe.scrollpane ) then
					UIe.scrollpane:ibMoveTo( -340 * move_type, 88, 250 ):ibTimer( destroyElement, 250, 1 )
					UIe.scrollbar:ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
					
					if current_slot_index ~= slot then
						UIe.slot_tab_name:ibMoveTo( 170 - 170 * move_type, 66, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
					end
				end

				UIe.scrollpane, UIe.scrollbar	= ibCreateScrollpane( 0, 88, bg_size_x, tab_bg_sy - 44 - 44, UIe.tab_bg, { scroll_px = -15, bg_color = 0 } )
				UIe.scrollbar:ibBatchData( { absolute = true, sensivity = 50 } ):ibSetStyle( "slim_small_nobg" )

				if current_slot_index ~= slot then
					UIe.slot_tab_name = ibCreateLabel( 0, 66, 0, 0, CONST_ACCESSORIES_SLOTS_NAME[ slot ], UIe.tab_bg )
						:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } ):center_x( )
				end

				selected_accessory_element = nil
				selected_accessory_id = nil
				current_slot_index = slot

				func_CreateSlot( slot, move_type )
				current_slot = func_CreateSlot

				UIe.scrollpane:AdaptHeightToContents( )
				UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )

				UIe.btn_buy:ibData( "priority", 1 )
					:ibAlphaTo( 0, 250 )
					:ibMoveTo( 0, tab_bg_sy, 250 )
					:ibResizeTo( 340, 0, 250 )
				
				if func_CreateSlot == func_CreateSlotShopTab then
					btn_bg:ibMoveTo( 0, 0, 250 )
					btn_shop:ibAlphaTo( 255, 250 )
					btn_inventory:ibAlphaTo( 128, 250 )
				else
					btn_bg:ibMoveTo( 170, 0, 250 )
					btn_shop:ibAlphaTo( 128, 250 )
					btn_inventory:ibAlphaTo( 255, 250 )
				end
			end

			btn_shop:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchSlot( func_CreateSlotShopTab, 1, -1 )
				end )
			btn_inventory:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchSlot( func_CreateSlotInventoryTab, 1, 1 )
				end )

			ibCreateImage( 0, 44, 340, 44, _, UIe.tab_bg, ibApplyAlpha( 0xff95caff, 15 ) )
			ibCreateButton( 25, 56, 24, 20, UIe.tab_bg, "images/arrow.png", "images/arrow.png", "images/arrow.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
				:ibData( "rotation", 180 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchSlot( current_slot, ( ( current_slot_index - 2 ) % #CONST_ACCESSORIES_SLOTS_NAME + 1 ), -1 )
				end )
			ibCreateButton( 295, 56, 24, 20, UIe.tab_bg, "images/arrow.png", "images/arrow.png", "images/arrow.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchSlot( current_slot, ( current_slot_index % #CONST_ACCESSORIES_SLOTS_NAME + 1 ), 1 )
				end )

			UIe.btn_buy = ibCreateButton( 0, tab_bg_sy, 340, 0, UIe.tab_bg, "images/btn_buy_i.png", "images/btn_buy_h.png", "images/btn_buy_c.png" )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )

					local info = CONST_ACCESSORIES_INFO[ selected_accessory_id ]
					if not info then
						localPlayer:ShowError( "Вы не выбрали аксессуар" )
						return
					end

					if own_accessories[ accessory_id ] then
						localPlayer:ShowError( "Вы уже приобрели данный аксессуар" )
						return
					end

					if info.level and localPlayer:GetLevel() < info.level then
						localPlayer:ShowError( "Доступно только с ".. info.level .." уровня" )
						return
					end

					if info.premium then
						localPlayer:ShowError( "Доступно только с премиумом" )
						return
					end

					if info.soft_cost then
						-- if not localPlayer:HasMoney( info.soft_cost ) then
						-- 	localPlayer:ShowError( "У вас недостаточно средств" )
						-- 	return
						-- end

						triggerServerEvent( "PlayerWantBuyAccessory", resourceRoot, selected_accessory_id )
				
					elseif info.hard_cost then
						if not localPlayer:HasDonate( info.hard_cost ) then
							localPlayer:ShowError( "У вас недостаточно средств" )
							return
						end

						triggerServerEvent( "PlayerWantBuyAccessory", resourceRoot, selected_accessory_id )
					
					else
						localPlayer:ShowError( "Это аксессуар уже принадлежит вам" )
					end
				end )
				:ibData( "alpha", 0 )

			func_SwitchSlot( func_CreateSlotShopTab, 1, 1 )
		end;
	};
	main = {
		name = "Магазин";

		create = function( )
			local scrollpane, scrollbar	= ibCreateScrollpane( 0, 0, bg_size_x, bg_size_y - 56 - 52, UIe.tab_bg, { scroll_px = -15, bg_color = 0 } )
			scrollbar:ibData( "sensivity", 0.1 ):ibSetStyle( "slim_small_nobg" )

			local pos_y = 0
			for id, tab in pairs( TAB_LIST ) do
				if tab.global then
					local bg = ibCreateButton( 0, pos_y, bg_size_x, 54, scrollpane, _, _, _, 0x00FFFFFF, ibApplyAlpha( 0xFF6988a8, 85 ), ibApplyAlpha( 0xFF6988a8, 85 ) )
						:ibOnClick( function( key, state ) 
							if key ~= "left" or state ~= "up" then return end
							ibClick( )

							SwitchTab( id )
						end)
					
					ibCreateLabel( 20, 27, 0, 0, tab.name, bg, ibApplyAlpha( COLOR_WHITE, 75 ) ):ibBatchData( { font = ibFonts.regular_15, align_x = "left", align_y = "center" } )
					ibCreateImage( 295, 22, 18, 10, "images/icon_arrow.png", bg )
					ibCreateImage( 0, 54, bg_size_x, 1, _, bg, ibApplyAlpha( COLOR_WHITE, 15 ) )

					pos_y = pos_y + 55
				end
			end

			scrollpane:AdaptHeightToContents( )
			scrollbar:UpdateScrollbarVisibility( scrollpane )
		end;
	};
}

function UpdatePlayerBuyAccessory_handler( accessory_id )
	own_accessories[ accessory_id ] = true

	if selected_tab == "accessories" and func_SwitchSlot then
		func_SwitchSlot( func_CreateSlotInventoryTab, 1, 1 )
	end
end
addEvent( "UpdatePlayerBuyAccessory", true )
addEventHandler( "UpdatePlayerBuyAccessory", resourceRoot, UpdatePlayerBuyAccessory_handler )

function UpdatePlayerBuyCloth_handler( model_id )
	skins[ model_id ] = true

	if selected_tab == "clothes" and func_SwitchTab then
		func_SwitchTab( func_CreateInventoryTab, 1, 1 )
	end
end
addEvent( "UpdatePlayerBuyCloth", true )
addEventHandler( "UpdatePlayerBuyCloth", resourceRoot, UpdatePlayerBuyCloth_handler )

function IsDanceSchoolQuest( )
	local quest_data = localPlayer:getData( "current_quest" )
	return quest_data and quest_data.id == "angela_dance_school"
end

function SetupClothesInterior( )
	SAVED_DATA = { localPlayer.dimension, localPlayer.interior, localPlayer.position }

	localPlayer.alpha = 0
	localPlayer.collisions = false
	localPlayer.frozen = true

	if not IsDanceSchoolQuest( ) then
		localPlayer.interior = data.interior
		localPlayer.dimension = data.dimension
		localPlayer.position = localPlayer.position + Vector3( 0, 0, 300 )
	end

	ped_dummy = createPed( localPlayer.model, data.ped_position, data.ped_rotation )
	ped_dummy.frozen = true
	ped_dummy.interior = IsDanceSchoolQuest( ) and localPlayer.interior or data.interior
	ped_dummy.dimension = IsDanceSchoolQuest( ) and localPlayer.dimension or data.dimension
	addEventHandler( "onClientElementStreamIn", ped_dummy, function()
		ped_dummy:setCollidableWith( localPlayer, false )
	end)

	if math.random( 1, 1000 ) == 42 then
		setPedAnimation( ped_dummy, "CUSTOM_BLOCK_1", "crckdeth2", -1, true, false, false, false)
	end

	--setWeather( data.weather )
	--setTime( unpack( data.time ) )

	setCameraMatrix( data.camera_position, data.camera_target, data.camera_roll, data.camera_fov )

	localPlayer:setData( "is_in_clothes_shop", true, false )
	--setPlayerHudComponentVisible( "radar", false )

	addEventHandler( "onClientPlayerWasted", localPlayer, HideUIShop )
end

function CleanupClothesInterior( )
	localPlayer.frozen = false

	localPlayer.alpha = 255
	localPlayer.collisions = true

	if not IsDanceSchoolQuest( ) then
		localPlayer:Teleport( SAVED_DATA[ 3 ], SAVED_DATA[ 1 ], SAVED_DATA[ 2 ] )
	end
		
	SAVED_DATA = nil

	if isElement( ped_dummy ) then
		destroyElement( ped_dummy )
	end

	setCameraTarget( localPlayer )
	setCursorAlpha( 255 )
	localPlayer:setData( "is_in_clothes_shop", false, false )

	triggerServerEvent( "onGameTimeRequest", localPlayer )
	removeEventHandler( "onClientPlayerWasted", localPlayer, HideUIShop )
end

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	for idx in pairs( CLOTHES_SHOPS_LIST ) do
		local shop_marker = TeleportPoint( {
			x = -228.228, y = -383.845, z = 1360.343;
			interior = 1;
			dimension = idx;
			radius = 2;
			marker_text = "Переодеться";
		} )

		shop_marker.text = "ALT Взаимодействие"
		shop_marker.marker:setColor( 128, 245, 128, 10 )

		shop_marker:SetImage( "images/marker.png" )
		shop_marker.element:setData( "material", true, false )
    	shop_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 245, 128, 255, 1.5 } )

		shop_marker.PostJoin = function( self, player )
			triggerServerEvent( "ClientRequestDataAndShowUIShop", resourceRoot, true )
		end

		shop_marker.PostLeave = function( self, player )
			HideUIShop( )
		end
	end
end )

addEventHandler( "onClientResourceStop", resourceRoot, function()
	if isElement( UIe.bg_img ) then
		CleanupClothesInterior( )
	end
end )



local cursor_pushed = false
local curson_alphed = false

function DetectMouseOnPedDummy( )
	local screenx, screeny, worldx, worldy, worldz = getCursorPosition( )

	if cursor_pushed then
		dxDrawImage( screenx * screen_size_x - 12, screeny * screen_size_y - 12, 24, 24, "images/rotate_clicked.png" )
	else
		local px, py, pz = getCameraMatrix()
		local hit, _, _, _, elementHit = processLineOfSight ( px, py, pz, worldx, worldy, worldz )

		if hit and elementHit == ped_dummy then
			if not curson_alphed then
				setCursorAlpha( 0 )
				curson_alphed = true
			end

			dxDrawImage( screenx * screen_size_x - 12, screeny * screen_size_y - 12, 24, 24, "images/rotate_hover.png" )
		else
			if curson_alphed then
				setCursorAlpha( 255 )
				curson_alphed = false
			end
		end
	end
end

local last_cursor_x = 0
function DetectClickOnPedDummy( button, state, _, _, _, _, _, element )
	if button ~= "left" then return end

	if state == "down" then
		if element ~= ped_dummy then return end

		last_cursor_x = getCursorPosition( )
		cursor_pushed = true
		addEventHandler( "onClientCursorMove", root, RotatePedDummyByCursorMove )
	elseif state == "up" then
		cursor_pushed = false
		removeEventHandler( "onClientCursorMove", root, RotatePedDummyByCursorMove )
	end
end

function RotatePedDummyByCursorMove( cursor_x )
	if not isElement( ped_dummy ) then
		removeEventHandler( "onClientCursorMove", root, RotatePedDummyByCursorMove )
		return
	end

	ped_dummy.rotation = ped_dummy.rotation + Vector3( 0, 0, ( cursor_x - last_cursor_x ) * 2 * 360 )
	last_cursor_x = cursor_x
end

local camera_interpolate_progress = 0
function DetectMouseScroll( key )
	if not curson_alphed then return end
	if key ~= "mouse_wheel_up" and key ~= "mouse_wheel_down" then return end

	if key == "mouse_wheel_up" then
		if camera_interpolate_progress >= 0.8 then return end
		camera_interpolate_progress = camera_interpolate_progress + 0.05
	else
		if camera_interpolate_progress <= 0 then return end
		camera_interpolate_progress = camera_interpolate_progress - 0.05
	end

	local b_p_x, b_p_y, b_p_z = getPedBonePosition( ped_dummy, 8 )
	local c_p_x, c_p_y, c_p_z = interpolateBetween( data.camera_position, Vector3( b_p_x, b_p_y, b_p_z + 0.2 ), camera_interpolate_progress, "Linear" )
	local c_t_x, c_t_y, c_t_z = interpolateBetween( data.camera_target, Vector3( b_p_x, b_p_y, b_p_z + 0.2 ), camera_interpolate_progress, "Linear" )

	setCameraMatrix( c_p_x, c_p_y, c_p_z, c_t_x, c_t_y, c_t_z, data.camera_roll, data.camera_fov )
end