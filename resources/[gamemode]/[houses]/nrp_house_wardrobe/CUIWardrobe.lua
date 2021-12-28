loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShApartments" )
Extend( "ShVipHouses" )
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShSkin" )
Extend( "ShAccessories" )

ibUseRealFonts( true )

local screen_size_x, screen_size_y = guiGetScreenSize( )

local pos_offset = 20
local bg_pos_y, bg_size_x = 157, 340
local bg_pos_x, bg_size_y = screen_size_x - bg_size_x - pos_offset, screen_size_y - bg_pos_y - pos_offset

local wardrobe_data = {}

local UIe = { }

local skins = nil
local own_accessories = nil
local accessories = nil
local all_accessories = nil
local accessories_preview = nil

local TAB_LIST = nil

local selected_tab = nil
local selected_clothes = nil

local tick_last_triggerServerEvent = 0

local func_SwitchSlot = nil
local func_CreateClothesTab = nil
local func_CreateSlotAccessoriesTab = nil

function ReceiveShowUIWardrobeData_hander( id, number, _skins, _own_accessories, _accessories )
    local class_id = id > 0 and APARTMENTS_LIST[ id ].class or VIP_HOUSES_LIST[ number ].apartments_class or 0
	local house_data = class_id > 0 and APARTMENTS_CLASSES[ class_id ] or VIP_HOUSES_LIST[ number ]

	wardrobe_data = {
		-- Окружение
		interior = localPlayer.interior,
		dimension = 4,
	
		-- Камера
		camera_position 		= Vector3( house_data.wardrobe_camera_position ),
		camera_target 			= Vector3( house_data.wardrobe_camera_target ),
		camera_roll				= 0.0,
		camera_fov				= 70.0,
	
		-- Манекен
		ped_position 			= Vector3( house_data.wardrobe_ped_position ),
		ped_rotation 			= house_data.wardrobe_ped_rotation,
	}

	skins = { }
	for _, model in pairs( _skins ) do
		skins[ model ] = true
	end

	own_accessories = _own_accessories
	accessories = _accessories[ localPlayer.model ] or { }
	all_accessories = _accessories

	ShowUIWardrobe( )
end
addEvent( "ReceiveShowUIWardrobeData", true )
addEventHandler( "ReceiveShowUIWardrobeData", root, ReceiveShowUIWardrobeData_hander )

function ShowUIWardrobe( )
	if isElement( UIe.black_bg ) then return end

	SetupClothesInterior( )

	showCursor( true )
	ibInterfaceSound()

	local main_hud_bg = exports.nrp_hud:GetMainBG( )
	if isElement( main_hud_bg ) then
		bg_pos_y, bg_size_x = main_hud_bg:ibGetAfterY( 10 ), 340
		bg_pos_x, bg_size_y = screen_size_x - bg_size_x - pos_offset, screen_size_y - bg_pos_y - pos_offset
	end

	UIe.black_bg = ibCreateBackground( _, HideUIWardrobe, _, true )
	UIe.bg_img		= ibCreateImage( bg_pos_x, bg_pos_y, bg_size_x, bg_size_y, _, UIe.black_bg, ibApplyAlpha( 0xff475d75, 95 ) )
	UIe.head_bg		= ibCreateImage( 0, 0, bg_size_x, 56, _, UIe.bg_img, ibApplyAlpha( 0xff95caff, 15 ) )
	UIe.head_label	= ibCreateLabel( 20, 28, 0, 0, "Гардероб", UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_16 )
			
	UIe.btn_bg = ibCreateImage( 0, 56, 170, 44, _, UIe.bg_img, ibApplyAlpha( COLOR_WHITE, 10 ) )
	UIe.btn_clothes = ibCreateButton( 0, 56, 170, 44, UIe.bg_img, "images/btn_tab_clothes.png", "images/btn_tab_clothes.png", "images/btn_tab_clothes.png" )
	UIe.btn_accessories = ibCreateButton( 170, 56, 170, 44, UIe.bg_img, "images/btn_tab_accessories.png", "images/btn_tab_accessories.png", "images/btn_tab_accessories.png" ):ibData( "alpha", 128 )
	
	UIe.btn_clothes:ibOnClick( function( key, state ) 
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			UIe.btn_bg:ibMoveTo( 0, 56, 250 )
			source:ibAlphaTo( 255, 250 )
			UIe.btn_accessories:ibAlphaTo( 128, 250 )

			SwitchTab( "clothes", -1 )
		end )
	UIe.btn_accessories:ibOnClick( function( key, state ) 
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			UIe.btn_bg:ibMoveTo( 170, 56, 250 )
			UIe.btn_clothes:ibAlphaTo( 128, 250 )
			source:ibAlphaTo( 255, 250 )

			SwitchTab( "accessories", 1 )
		end )

	UIe.worked_bg	= ibCreateRenderTarget( 0, 100, bg_size_x, bg_size_y - 100 - 52, UIe.bg_img )
	UIe.bottom_line	= ibCreateImage( 0, bg_size_y - 52, bg_size_x, 1, _, UIe.bg_img, ibApplyAlpha( COLOR_WHITE, 15 ) )

	UIe.back_btn = ibCreateButton( 0, bg_size_y - 51, bg_size_x, 51, UIe.bg_img, "images/btn_exit_i.png", "images/btn_exit_h.png", "images/btn_exit_c.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			HideUIWardrobe( )
		end)

	SwitchTab( "clothes", 1 )

	UpdateCurrentAccessories( )

	addEventHandler( "onClientClick", root, DetectClickOnPedDummy )
	addEventHandler( "onClientRender", root, DetectMouseOnPedDummy )
	addEventHandler( "onClientKey", root, DetectMouseScroll )
end

function HideUIWardrobe( )
	if not isElement( UIe.black_bg ) then return end

	triggerServerEvent( "PlayerWantShowUIWardrobe", localPlayer, false )

	CleanupClothesInterior( )

	showCursor( false )

	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	selected_tab = nil

	removeEventHandler( "onClientClick", root, DetectClickOnPedDummy )
	removeEventHandler( "onClientRender", root, DetectMouseOnPedDummy )
	removeEventHandler( "onClientKey", root, DetectMouseScroll )
end
addEvent( "HideUIWardrobe", true )
addEventHandler( "HideUIWardrobe", root, HideUIWardrobe )

function UpdateCurrentAccessories( )
	all_accessories[ ped_dummy.model ] = accessories

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
	UIe.bg_accessories = ibCreateArea( 20, math.floor( ( screen_size_y - size_y ) / 2 ), 86, size_y, UIe.black_bg )

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
			if getTickCount( ) - tick_last_triggerServerEvent < 1000 then return end

			ibClick( )

			HideAccessoryEdit( )

			accessories = { }
			accessories_preview = { }
			triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
				model = ped_dummy.model;
				list = accessories_preview;
			} )
			triggerServerEvent( "PlayerWantChangeAccessoriesSlot", resourceRoot, ped_dummy.model )
			tick_last_triggerServerEvent = getTickCount( )

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

function SwitchTab( tab_id, move_type )
	if not TAB_LIST[ tab_id ] then return end
	if selected_tab == tab_id then return end

	selected_tab = tab_id

	if isElement( UIe.tab_bg ) then
		UIe.tab_bg:ibMoveTo( -25 * move_type, 0, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
		
		UIe.tab_bg = nil
	end

	ped_dummy.model = localPlayer.model
	accessories = all_accessories[ ped_dummy.model ] or { }
	accessories_preview = table.copy( accessories )
	triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
		model = ped_dummy.model;
		list = accessories_preview;
	} )
	UpdateCurrentAccessories( )

	UIe.tab_bg = ibCreateArea( 0, 0, bg_size_x, UIe.worked_bg:ibData( "sy" ), UIe.worked_bg )
	TAB_LIST[ tab_id ]:create( )

	UIe.tab_bg:ibBatchData( {
		alpha = 0;
		px = 25;
	} ):ibMoveTo( 0, 0, 250 ):ibAlphaTo( 255, 250 )
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

		func_SwitchSlot( _, 1, true )
	end
end

TAB_LIST = {
	clothes = {
		global = true;
		name = "Одежда";

		create = function( )
			local tab_bg_sy = UIe.tab_bg:ibData( "sy" )
			local player_gender = localPlayer:GetGender( )

			func_CreateClothesTab = function( move_type )
				selected_clothes = localPlayer.model

				UIe.current_clothes = nil

				if not next( skins ) then
					ibCreateLabel( 0, 0, 0, 0, "У вас нет одежды в наличии. \nПриобретите её в магазине.", UIe.scrollpane, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.semibold_14 ):center( )
					return
				end

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

					local SelectPedDummyClothes = function ()
						if selected_clothes_element and selected_clothes_element:ibData( "texture" ) then
							selected_clothes_element:ibData( "texture", string.gsub( selected_clothes_element:ibData( "texture" ), "_selected", "" ) )
						end
						clothes_slot_bg:ibData( "texture", string.gsub( clothes_slot_bg:ibData( "texture" ), ".png", "_selected.png" ) )

						selected_clothes = model
						selected_clothes_element = clothes_slot_bg

						ped_dummy.model = model

						triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
							model = ped_dummy.model;
							list = all_accessories[ ped_dummy.model ]
						} )

						accessories = all_accessories[ model ] or { }

						UpdateCurrentAccessories( )
					end

					ibCreateArea( 0, 0, 340, 108, bg )
						:ibOnClick( function( key, state )
							if key ~= "left" or state ~= "up" then return end
							ibClick( )

							SelectPedDummyClothes( )
						end )
						:ibOnHover( function( )
							bg_hover_img:ibAlphaTo( 100, 250 )
						end )
						:ibOnLeave( function( )
							bg_hover_img:ibAlphaTo( 0, 250 )
						end )

					local okey_img = ibCreateImage( 56, 6, 18, 15, "images/okey_icon.png", clothes_slot_bg )
						:ibData( "alpha", model == localPlayer.model and 255 or 0 )

					local btn_puton = ibCreateButton( 124, 60, 71, 22, bg, "images/btn_puton_i.png", "images/btn_puton_h.png", "images/btn_puton_c.png" )
						:ibData( "alpha", model ~= localPlayer.model and 255 or 0 )
						:ibOnClick( function( key, state ) 
							if key ~= "left" or state ~= "up" then return end
							if getTickCount( ) - tick_last_triggerServerEvent < 1000 then return end
							ibClick( )

							if UIe.current_clothes then
								UIe.current_clothes.btn_puton:ibData( "alpha", 255 )
								UIe.current_clothes.okey_img:ibData( "alpha", 0 )
								UIe.current_clothes.lbl_name:ibData( "py", 36 )
							end
							source:ibData( "alpha", 0 )
							okey_img:ibData( "alpha", 255 )
							lbl_name:center_y( )

							UIe.current_clothes = 
							{
								btn_puton = source,
								okey_img = okey_img,
								lbl_name = lbl_name,
							}

							SelectPedDummyClothes( )

							triggerServerEvent( "PlayerWantUseSkin", resourceRoot, model )							
							tick_last_triggerServerEvent = getTickCount( )
						end)

					if model == localPlayer.model then
						lbl_name:center_y( )
						UIe.current_clothes = 
						{
							btn_puton = btn_puton,
							okey_img = okey_img,
							lbl_name = lbl_name,
						}
					end
				end
			end

			UIe.scrollpane, UIe.scrollbar	= ibCreateScrollpane( 0, 0, bg_size_x, tab_bg_sy, UIe.tab_bg, { scroll_px = -15, bg_color = 0 } )
			UIe.scrollbar:ibBatchData( { absolute = true, sensivity = 50 } ):ibSetStyle( "slim_small_nobg" )

			func_CreateClothesTab( -1 )

			UIe.scrollpane:AdaptHeightToContents( )
			UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )
		end;
	};
	accessories = {
		global = true;
		name = "Аксессуары";

		create = function( )
			local current_slot_index = nil
			local tab_bg_sy = UIe.tab_bg:ibData( "sy" )
			local selected_accessory_id = nil
			local selected_accessory_element = nil
			local current_btn_cancel_preview = nil

			local accessories_ids_by_slots = { }
			for id, info in pairs( CONST_ACCESSORIES_INFO ) do
				if not accessories_ids_by_slots[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ info.slot ] ] then
					accessories_ids_by_slots[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ info.slot ] ] = { }
				end

				if own_accessories[ id ] or ( CONST_ACCESSORIES_INFO[ id ].premium and localPlayer:IsPremiumActive( ) ) then
					table.insert( accessories_ids_by_slots[ CONST_ACCESSORIES_SLOTS_IDS_REVERT[ info.slot ] ], id )
				end
			end
			
			func_CreateOwnItem = function( bg, id )
				local info = CONST_ACCESSORIES_INFO[ id ]

				local bg_sy = bg:ibData( "sy" )
				local line_img				= ibCreateImage( 0, bg_sy - 1, 340, 1, _, bg, 0x26FFFFFF )
				local bg_hover_img			= ibCreateImage( 0, 0, 340, bg_sy - 1, _, bg, 0x806988a8 ):ibData( "alpha", 0 )

				local accessory_slot_bg		= ibCreateImage( 20, 15, 90, 90, "images/accessory_slot_bg.png", bg )
				local accessory_slot_img	= ibCreateContentImage( 0, 0, 90, 90, "accessory", id, accessory_slot_bg )

				ibCreateLabel( 124, 36, 0, 0, info.name, bg )
					:ibBatchData( { font = ibFonts.light_16, align_x = "left", align_y = "center" } )

				local slot = CONST_ACCESSORIES_SLOTS_IDS[ current_slot_index ]

				local clicked_bg			= ibCreateArea( 0, 0, 340, bg_sy, bg )
				clicked_bg:ibOnHover( function( )
						if source ~= clicked_bg and getElementParent( source ) ~= clicked_bg then return end

						bg_hover_img:ibAlphaTo( 255, 250 )

						if isElement( UIe.description_box ) then
							destroyElement( UIe.description_box )
						end

						if item_blocked then
							local title_len = dxGetTextWidth( blocked_text, 1, ibFonts.bold_15 ) + 30
							local box_s_x = title_len
							local box_s_y = 35

							local pos_x, pos_y = getCursorPosition( )
							pos_x, pos_y = pos_x * screen_size_x, pos_y * screen_size_y

							UIe.description_box = ibCreateImage( pos_x - 5, pos_y - box_s_y - 5, box_s_x, box_s_y, nil, nil, 0xCC000000 ):ibData( "alpha", 0 )
							ibCreateLabel( 0, 17, box_s_x, 0, blocked_text, UIe.description_box ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" })
							UIe.description_box:ibAlphaTo( 255, 250 )
							addEventHandler( "onClientCursorMove", root, UpdateDescriptionByMouseMove )
						end
					end, true )
					:ibOnLeave( function( )
						if source ~= clicked_bg and getElementParent( source ) ~= clicked_bg then return end

						bg_hover_img:ibAlphaTo( 0, 250 )

						if isElement( UIe.description_box ) then
							removeEventHandler( "onClientCursorMove", root, UpdateDescriptionByMouseMove )
							destroyElement( UIe.description_box )
						end
					end, true )

				local func_UpdBtnUseAsseccory = nil
				func_UpdBtnUseAsseccory = function( current )
					if accessories[ slot ] and accessories[ slot ].id == id then
						if isElement( current_okey_icon ) then
							destroyElement( current_okey_icon )
						end

						current_okey_icon = ibCreateImage( 87, 19, 18, 15, "images/okey_icon.png", bg )


						if isElement( current_btn_takeoff ) then
							destroyElement( current_btn_takeoff )
						end

						current_btn_takeoff = ibCreateButton( 124, 68, 70, 22, clicked_bg, "images/btn_takeoff_i.png", "images/btn_takeoff_h.png", "images/btn_takeoff_c.png" )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								if getTickCount( ) - tick_last_triggerServerEvent < 1000 then return end
								ibClick( )

								accessories[ slot ] = nil
								UpdateCurrentAccessories( )
								accessories_preview[ slot ] = nil

								triggerServerEvent( "PlayerWantChangeAccessoriesSlot", resourceRoot, ped_dummy.model, slot, accessories[ slot ] )
								tick_last_triggerServerEvent = getTickCount( )

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

						ibCreateButton( 124, 68, 71, 22, clicked_bg, "images/btn_puton_i.png", "images/btn_puton_h.png", "images/btn_puton_c.png" )
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

			func_CreateSlotAccessoriesTab = function( slot, move_type )
				local accessories_ids = accessories_ids_by_slots[ slot ]

				if #accessories_ids == 0 then
					ibCreateLabel( 0, 0, 0, 0, "У вас нет аксессуаров в наличии. \nПриобретите их в магазине.", UIe.scrollpane, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.semibold_14 ):center( )
					return
				end

				for i, id in pairs( accessories_ids ) do
					local bg = ibCreateArea( 340 * move_type, 120 * ( i - 1 ), 340, 120, UIe.scrollpane )
						:ibTimer( function( self )
							self:ibMoveTo( 0, self:ibData( "py" ), 250 )
						end, 50 * i, 1 )
					
					func_CreateOwnItem( bg, id )
				end
			end

			func_SwitchSlot = function( slot, move_type, hard_reset )
				if current_slot_index == slot and not hard_reset then return end

				-- Уффф, костылики
				if hard_reset then slot = current_slot_index end

				if current_slot_index then
					UIe.scrollpane:ibMoveTo( -340 * move_type, 44, 250 ):ibTimer( destroyElement, 250, 1 )
					UIe.scrollbar:ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
					
					if current_slot_index ~= slot then
						UIe.slot_tab_name:ibMoveTo( 170 - 170 * move_type, 22, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
					end
				end

				UIe.scrollpane, UIe.scrollbar	= ibCreateScrollpane( 0, 44, bg_size_x, tab_bg_sy - 44, UIe.tab_bg, { scroll_px = -15, bg_color = 0 } )
				UIe.scrollbar:ibBatchData( { absolute = true, sensivity = 50 } ):ibSetStyle( "slim_small_nobg" )

				if current_slot_index ~= slot then
					UIe.slot_tab_name = ibCreateLabel( 0, 22, 0, 0, CONST_ACCESSORIES_SLOTS_NAME[ slot ], UIe.tab_bg )
						:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } ):center_x( )
				end

				selected_accessory_element = nil
				selected_accessory_id = nil
				current_slot_index = slot

				func_CreateSlotAccessoriesTab( slot, move_type )

				UIe.scrollpane:AdaptHeightToContents( )
				UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )
			end

			ibCreateImage( 0, 0, 340, 44, _, UIe.tab_bg, ibApplyAlpha( 0xff95caff, 15 ) )
			ibCreateButton( 25, 12, 24, 20, UIe.tab_bg, "images/arrow.png", "images/arrow.png", "images/arrow.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
				:ibData( "rotation", 180 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchSlot( ( ( current_slot_index - 2 ) % #CONST_ACCESSORIES_SLOTS_NAME + 1 ), -1 )
				end )
			ibCreateButton( 295, 12, 24, 20, UIe.tab_bg, "images/arrow.png", "images/arrow.png", "images/arrow.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end

					ibClick( )
					func_SwitchSlot( ( current_slot_index % #CONST_ACCESSORIES_SLOTS_NAME + 1 ), 1 )
				end )

			func_SwitchSlot( 1, 1 )
		end;
	};
}



function UpdateDescriptionByMouseMove( _, _, pos_x, pos_y )
	if isElement( UIe.description_box ) then
		UIe.description_box:ibBatchData( { px = pos_x - 5, py = pos_y - UIe.description_box:ibData( "sy" ) - 5 } )
	end
end

function SetupClothesInterior( )
	SAVED_DATA = { 
		dimension = localPlayer.dimension
	}

	localPlayer.dimension = wardrobe_data.dimension
	localPlayer.alpha = 0
	localPlayer.collisions = false
	localPlayer.frozen = true

	ped_dummy = createPed( localPlayer.model, wardrobe_data.ped_position, wardrobe_data.ped_rotation )
	ped_dummy.frozen = true
	ped_dummy.interior = wardrobe_data.interior
	ped_dummy.dimension = wardrobe_data.dimension
	addEventHandler( "onClientElementStreamIn", ped_dummy, function()
		ped_dummy:setCollidableWith( localPlayer, false )
	end)
	
	if math.random( 1, 1000 ) == 42 then
		setPedAnimation( ped_dummy, "CUSTOM_BLOCK_1", "crckdeth2", -1, true, false, false, false)
	end

	setCameraMatrix( wardrobe_data.camera_position, wardrobe_data.camera_target, wardrobe_data.camera_roll, wardrobe_data.camera_fov )

	localPlayer:setData( "is_in_wardrobe", true, false )
	--setPlayerHudComponentVisible( "radar", false )

	addEventHandler( "onClientPlayerWasted", localPlayer, HideUIWardrobe )
end

function CleanupClothesInterior( )
	localPlayer.frozen = false
	localPlayer.alpha = 255
	localPlayer.collisions = true
	localPlayer.dimension = SAVED_DATA.dimension
	
	SAVED_DATA = nil

	if isElement( ped_dummy ) then
		triggerEvent( "UpdatePedAccessories", root, ped_dummy, {
			model = ped_dummy.model;
			list = {};
		} )
		destroyElement( ped_dummy )
	end

	setCameraTarget( localPlayer )

	localPlayer:setData( "is_in_wardrobe", false, false )
	setCursorAlpha( 255 )

	removeEventHandler( "onClientPlayerWasted", localPlayer, HideUIWardrobe )
end

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
	local c_p_x, c_p_y, c_p_z = interpolateBetween( wardrobe_data.camera_position, Vector3( b_p_x, b_p_y, b_p_z + 0.2 ), camera_interpolate_progress, "Linear" )
	local c_t_x, c_t_y, c_t_z = interpolateBetween( wardrobe_data.camera_target, Vector3( b_p_x, b_p_y, b_p_z + 0.2 ), camera_interpolate_progress, "Linear" )

	setCameraMatrix( c_p_x, c_p_y, c_p_z, c_t_x, c_t_y, c_t_z, wardrobe_data.camera_roll, wardrobe_data.camera_fov )
end