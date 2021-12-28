local event_id = "mayevent_victory_drag"

local CONST_TEXT_TO_START = { "3", "2", "1", "GO", }

local CONST_TIME_SHOW_RESULT_ROUND_IN_SEC = 10

local CONST_TIME_TO_TEXT_START_IN_MS = 1500

local CONST_TIME_TO_EVENT_END_IN_MS = 5 * 60 * 1000

local CONST_NUMBER_DRAG_RACE = 3
local CONST_VEHICLE_MODEL = 6584

local CONST_SPAWN_POSITIONS = {
	{  x = -2765.15, y = 2802.98, z = 2.97, rz = 270 },
	{  x = -2765.15, y = 2812.98, z = 2.97, rz = 270 },
}

local CONST_GAME_ZONE = {
	-2778, 2773,
	-1200, 2785,
	-1200, 2842,
	-2778, 2842,
	-2778, 2773,
}

local CONST_DRAG_FINISH = Vector3( -1785.0393, 2807.9660, 2.97 )
local CONST_FINISH_COL_POSITION = { -1785, 2784, 83, 48 }

local CONST_DRAG_ITEMS_CHANCES = {
	{ name = "Двигатель 1",   id = "engine_1", color = 0xFFa975FF, chance = 11.11, speed = 15, acceleration = 0  },
	{ name = "Турбонаддув 1", id = "turbo_1",  color = 0xFFa975FF, chance = 11.11, speed = 0,  acceleration = 15 },
	{ name = "Чиповка 1",     id = "ecu_1",    color = 0xFFa975FF, chance = 11.11, speed = 8,  acceleration = 5  },
	{ name = "Двигатель 2",   id = "engine_2", color = 0xFF5792FF, chance = 11.11, speed = 20, acceleration = 0  },
	{ name = "Турбонаддув 2", id = "turbo_2",  color = 0xFF5792FF, chance = 11.11, speed = 0,  acceleration = 19 },
	{ name = "Чиповка 2",     id = "ecu_2",    color = 0xFF5792FF, chance = 11.11, speed = 16, acceleration = 10 },
	{ name = "Двигатель 3",   id = "engine_3", color = 0xFF5BD07D, chance = 11.11, speed = 35, acceleration = 0  },
	{ name = "Турбонаддув 3", id = "turbo_3",  color = 0xFF5BD07D, chance = 11.11, speed = 0,  acceleration = 29 },
	{ name = "Чиповка 3",     id = "ecu_3",    color = 0xFF5BD07D, chance = 11.11, speed = 16, acceleration = 12 },
}

local CONST_HIDE_HUD_BLOCKS = { "main", "notifications", "daily_quest", "factionradio", "cases_discounts", "quest", "ksusha", "wanted", "radar", "nodamage", "weapons", "offers", "offer_ingame_draw", "7cases", }
local CONST_HIDE_DRAG_RACE_BLOCKS = { "vehicle", }

local CLIENT_VAR_bg_sound = nil
local CLIENT_VAR_rival_player = nil
local CLIENT_VAR_installed_drag_items = nil
local CLIENT_VAR_finish_rounds_data = nil
local CLIENT_VAR_exit_zone_colshape = nil
local CLIENT_VAR_exit_zone_texture = nil
local CLIENT_VAR_game_zone_exit_tmr = nil
local CONST_TIME_TO_ZONE_EXIT_IN_SEC = 15

local function CLIENT_CancelEventKeys()
	cancelEvent()
end

local function CLIENT_ShowInstalledItemsUI( state )
	if state then
		CLIENT_ShowInstalledItemsUI( false )
		
		UIe.bg_installed_items = ibCreateDummy()

		local positions = { { x = 324, y = 383 }, { x = 400, y = 351 }, { x = 454, y = 290 } }
		for i = 1, 3 do
			local item_data = CONST_DRAG_ITEMS_CHANCES[ CLIENT_VAR_installed_drag_items[ i ] ]
			if item_data then
				local bg = ibCreateImage( _SCREEN_X - positions[ i ].x, _SCREEN_Y - positions[ i ].y, 134, 134, "img/may_events/bg_drag_item_installed.png", UIe.bg_installed_items )
				ibCreateImage( 0, 0, 134, 134, "img/may_events/bg_drag_item_installed_fill.png", bg ):ibData( "color", item_data.color )
				local drag_item_type = string.match( item_data.id , "(%a+)_")
				ibCreateImage( 0, 0, 40, 40, "img/may_events/" .. drag_item_type .. "_icon.png", bg ):center()
			else
				ibCreateImage( _SCREEN_X - positions[ i ].x, _SCREEN_Y - positions[ i ].y, 134, 134, "img/may_events/bg_drag_item_locked.png", UIe.bg_installed_items )
			end
		end
	elseif isElement( UIe and UIe.bg_installed_items ) then
		UIe.bg_installed_items:destroy()
	end
end

local function CLIENT_ShowSelectDragItemUI( state, data )
	if state then
		CLIENT_ShowSelectDragItemUI( false )
		
		local autoclose_in_sec = 5
		local progressbar_width = 228

		local vehicle = localPlayer.vehicle
		local vehicle_id = vehicle.model
		local veh_conf = table.copy( VEHICLE_CONFIG[ vehicle_id ].variants[ vehicle.variant or 1 ] )

		for k, v in pairs( CLIENT_VAR_installed_drag_items ) do
			local data = CONST_DRAG_ITEMS_CHANCES[ v ]
			veh_conf.max_speed = veh_conf.max_speed + (data.speed or 0)
			veh_conf.stats_acceleration = veh_conf.stats_acceleration + (data.acceleration or 0)
		end

		local self = {}
		self.elements = {}
		self.elements.selected_btn = {}
		self.elements.headers = {}

		self.last_index = 32
		self.finish_scroll = 0
		self.drag_select_textures = {}
		
		self.func_start_autoclose = function()
			local count_seconds = autoclose_in_sec
			self.finish_ts = getRealTimestamp() + autoclose_in_sec
			self.elements.time_lbl:ibTimer( function()
				count_seconds = count_seconds - 1
				if count_seconds > 0 then
					self.elements.time_lbl:ibData( "text", count_seconds )
					self.elements.time_unit:ibData( "px", self.elements.time_lbl:ibGetAfterX() + 4 )
				else
					if not self.selected_item then 
						self.selected_item = data[ math.random( 1, 3 ) ]
						setSoundVolume( playSound( ":nrp_tuning_shop/sfx/install1.mp3" ), 0.5 )
					end

					table.insert( CLIENT_VAR_installed_drag_items, self.selected_item )
					TriggerCustomServerEvent( "ClientSelectedDragItem", self.selected_item )
					
					CLIENT_ShowInstalledItemsUI( true )
					CLIENT_ShowSelectDragItemUI( false )
				end
			end, 1000, autoclose_in_sec + 1 )
		end

		self.func_get_progress_width = function( value, maximum )
			return ( ( value / maximum ) * progressbar_width ) > progressbar_width and progressbar_width or ( value / maximum ) * progressbar_width
		end

		self.func_create_row_item = function( item_id, pos_x, pos_y, bg )
			local item = ibCreateImage( pos_x, pos_y, 0, 0, self.drag_select_textures[ item_id ], bg ):ibSetRealSize()
			return item
		end

		self.func_create_column = function( column_id, item_index )
			local column = {}
			column.items_pane, column.scroll_v = ibCreateScrollpane( column_id * 328, 0, 308, 340, self.elements.rt_select_drag_items )
			column.item = self.func_create_row_item( CONST_DRAG_ITEMS_CHANCES[ item_index ].id, 0, (self.last_index * 400), column.items_pane )
			
			column.items = {}
			
			table.insert( column.items, self.func_create_row_item( CONST_DRAG_ITEMS_CHANCES[ math.random( 1, #CONST_DRAG_ITEMS_CHANCES ) ].id, 0, 0, column.items_pane ) )
			column.items_pane:AdaptHeightToContents( )
			
			column.scroll_v:ibBatchData( { position = 0, sensivity = 0, visible = false } )

			return column
		end

		self.func_start_anim = function()
			for i = 1, 3 do
				local duration = 2500 + (i - 1) * 500
				self.elements.columns[ i ].scroll_v:ibScrollTo( 1, duration, "Linear" )
				self.elements.columns[ i ].scroll_v:ibTimer( function()
					self.func_on_finish_scroll_column( i )
				end, duration + 1, 1 )
			end
		end

		self.func_start_lazy_loading = function()
			local add_time = 80
			local count_items = self.last_index
			local count_items_per_cycle = 4

			for i = 1, 3 do 
				self.elements.columns[ i ].itemCounter = 1
				self.elements.columns[ i ].items_pane:ibTimer( function( self_element )
					local itemCount = self.elements.columns[ i ].itemCounter
					for j = itemCount, itemCount + 3 do
						if j ~= self.last_index then
							table.insert( self.elements.columns[ i ].items, self.func_create_row_item( CONST_DRAG_ITEMS_CHANCES[ math.random( 1, #CONST_DRAG_ITEMS_CHANCES ) ].id, 0, (j * 400), self_element ) )
						end
						if j == self.last_index + 1 then self_element:AdaptHeightToContents( ) end
					end
					self.elements.columns[ i ].itemCounter = itemCount + 4
				end, add_time, count_items / count_items_per_cycle )
				
				self.elements.columns[ i ].items_pane:ibTimer( function( self_element )
					local children = self_element:getChildren( )
					destroyElement( children[ 2 ] )
				end, add_time + 150, count_items - 1 )
			end
		end

		self.func_on_finish_scroll_column = function( finished_index )
			local item_index = data[ finished_index ]

			local px, py = 30 + (finished_index - 1) * 328, 122
			self.elements.headers[ finished_index ] = ibCreateImage( px + 28, py - 40, 252, 109, "img/may_events/header.png", self.elements.bg_select_drag_items )
			ibCreateLabel( 0, 0, 252, 109, CONST_DRAG_ITEMS_CHANCES[ item_index ].name, self.elements.headers[ finished_index ], nil, nil, nil, "center", "center", ibFonts.bold_16 )
			
			self.elements.selected_btn[ finished_index ] = ibCreateButton( px + 84, py + 276, 139, 42, self.elements.bg_select_drag_items, "img/may_events/btn_select.png", "img/may_events/btn_select_h.png", "img/may_events/btn_select_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" or self.selected_item then return end
					ibClick( )
					destroyElement( self.elements.selected_btn[ finished_index ] )

					self.func_on_selected_item( finished_index )
					self.selected_item = data[ finished_index ]
				end )

			self.roll_stop_sound = playSound( "sfx/roll_stop.ogg" )
			self.roll_stop_sound.volume = 0.7

			if self.selected_item then
				self.func_disable_column( finished_index )
			end

			self.finish_scroll = self.finish_scroll + 1
			if self.finish_scroll == 3 then
				if isElement( self.roll_sound ) then stopSound( self.roll_sound ) end
				self.func_on_finish_scroll()
			end
		end

		self.func_disable_column = function( index )
			local alpha = 120
			self.elements.columns[ index ].items_pane:ibData( "alpha", alpha )
			self.elements.selected_btn[ index ]:ibBatchData( { disabled = true, alpha = alpha } )
			self.elements.headers[ index ]:ibData( "alpha", 240 )
		end

		self.func_on_selected_item = function( selected_index )
			for i = 1, 3 do
				if self.elements.selected_btn[ i ] and i ~= selected_index then self.func_disable_column( i ) end
			end

			local item_data = CONST_DRAG_ITEMS_CHANCES[ data[ selected_index ] ]
			if item_data.speed > 0 then
				local new_speed = veh_conf.max_speed + item_data.speed
				self.elements.max_speed_lbl:ibData( "text", new_speed )

				local px = self.elements.max_speed_line:ibData( "px" )
				self.elements.add_new_max_speed_line = ibCreateLine( px, 598, px, 598, 0xFF61C400, 17, self.elements.bg_select_drag_items ):ibMoveTo( 530 + self.func_get_progress_width( new_speed, 400 ), _, 400, "InOutQuad" )
			end

			if item_data.acceleration > 0 then
				local new_acceleration = veh_conf.stats_acceleration + item_data.acceleration
				self.elements.accleration_lbl:ibData( "text", new_acceleration )

				local px = self.elements.accleration_line:ibData( "px" )
				self.elements.add_accleration_line = ibCreateLine( px, 654, px, 654, 0xFF61C400, 17, self.elements.bg_select_drag_items ):ibMoveTo( 530 + self.func_get_progress_width( new_acceleration, 400 ), _, 400, "InOutQuad" )
			end

			ibCreateLabel( 30 + (selected_index - 1) * 328, 420, 308, 0, "Деталь установлена", self.elements.bg_select_drag_items, 0xFFDDE1ED, _, _, "center", "center", ibFonts.bold_14 )
			setSoundVolume( playSound( ":nrp_tuning_shop/sfx/install1.mp3" ), 0.5 )
		end

		self.func_on_finish_scroll = function()
			if isElement( self.roll_sound ) then stopSound( self.roll_sound ) end
			self.func_start_autoclose()
		end

		self.start_process_scroll = function( self )
			setCameraTarget( localPlayer )

			local fade_time = 0.5
			fadeCamera( true, fade_time )
			self.start_anim_tmr = setTimer( function()
				
				self.func_start_lazy_loading()
				self.roll_sound = playSound( "sfx/roll_click.ogg", true )
				self.roll_sound.volume = 0.3
				self.start_roll_tmr = setTimer( self.func_start_anim, 150, 1 ) 
			end, 150, 1 )
		end

		self.destroy = function( self )
			if isTimer( self.start_anim_tmr ) then killTimer( self.start_anim_tmr ) end
			if isTimer( self.start_roll_tmr ) then killTimer( self.start_roll_tmr ) end

			if isElement( self.roll_sound ) then stopSound( self.roll_sound ) end
			if isElement( self.roll_stop_sound ) then stopSound( self.roll_stop_sound ) end
			
			if isElement( self.elements.area_select_drag_items ) then
				destroyElement( self.elements.area_select_drag_items )
				self.elements.area_select_drag_items = nil
	
				for k, v in pairs( self.drag_select_textures ) do
					destroyElement( v )
				end
			end
			
			setmetatable( self, nil)
			showCursor( false )
		end

		self.elements.area_select_drag_items = ibCreateImage( 0, 0, 1024, 720, nil, nil, 0xFF44566d ):center()
		self.elements.bg_select_drag_items = ibCreateImage( 0, 0, 1024, 720, "img/may_events/bg_drag_select_detail.png", self.elements.area_select_drag_items ):ibBatchData( { priority = 2, disabled = true } )
		self.elements.rt_select_drag_items = ibCreateRenderTarget( 30, 122, 964, 340, self.elements.area_select_drag_items ):ibData( "priority", 1 )
		
		local timer_icon = ibCreateImage( 764, 34, 181, 24, "img/may_events/timer_select.png", self.elements.bg_select_drag_items )
		self.elements.time_lbl = ibCreateLabel( timer_icon:ibGetAfterX(), 36, 0, 0, autoclose_in_sec, self.elements.bg_select_drag_items, nil, nil, nil, "left", "top", ibFonts.bold_16 )
		self.elements.time_unit = ibCreateLabel( self.elements.time_lbl:ibGetAfterX() + 4, 36, 0, 0, "сек", self.elements.bg_select_drag_items, nil, nil, nil, "left", "top", ibFonts.regular_16 )
	
		self.elements.max_speed_lbl = ibCreateLabel( 530, 571, progressbar_width, 0, veh_conf.max_speed, self.elements.bg_select_drag_items, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
		self.elements.max_speed_line = ibCreateLine( 530, 598, 530, 598, 0xFFFF965D, 17, self.elements.bg_select_drag_items ):ibMoveTo( 530 + self.func_get_progress_width( veh_conf.max_speed, 400 ), _, 800, "InOutQuad" )

		self.elements.accleration_lbl = ibCreateLabel( 530, 627, progressbar_width, 0, veh_conf.stats_acceleration, self.elements.bg_select_drag_items, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
		self.elements.accleration_line = ibCreateLine( 530, 654, 530, 654, 0xFFFF965D, 17, self.elements.bg_select_drag_items ):ibMoveTo( 530 + self.func_get_progress_width( veh_conf.stats_acceleration, 400 ), _, 800, "InOutQuad" )
		
		self.elements.triangle_params = exports.nrp_tuning_shop:generateTriangleTexture( 285, 570, self.elements.bg_select_drag_items, getVehicleOriginalParameters( vehicle_id ) )

		for k, v in pairs( { "engine", "turbo", "ecu" } ) do
			for i = 1, 3 do
				local item_id = v .. "_" .. i
				self.drag_select_textures[ item_id ] = dxCreateTexture( "img/may_events/" .. item_id .. ".png" )
			end
		end

		self.elements.columns = {}
		for i = 1, 3 do
			table.insert( self.elements.columns, i, self.func_create_column( i - 1, data[ i ] ) )
		end
		
		CLIENT_ShowInstalledItemsUI( false )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_DRAG_RACE_BLOCKS, true )
		showCursor( true )
		
		self:start_process_scroll()
		UIe.select_drag_item = self
	elseif (UIe and UIe.select_drag_item) then
		UIe.select_drag_item:destroy()
		UIe.select_drag_item = nil
	end
end

local function CLIENT_ShowDragRaceUI( state )
	if state then
		CLIENT_ShowDragRaceUI( false )

		local self = {}
		self.elements = {}
		self.vehicle = localPlayer.vehicle

		self.curreng_gear = 0
		self.neutral_rpm = 0
		self.max_neutral_rpm = 1000
		self.vehicle:setData( "custom_gear", 0, false )
		triggerEvent( "onClientDragChangeGear", root, self.vehicle, { max_rpm = self.max_neutral_rpm, gear = 0 } )

		self.prev_place = 1

		self.gear_setting = {
			[ 0 ] = {
    		    name = "R",
    		    zones = { y = 0.44, g = 0.7, r = 0.85 },
    		    gear_coeff = -200,
    		    accl_coeff = 10,
    		},
    		[ 1 ] = {
    		    name = "1",
    		    zones = { y = 0.5, g = 0.72, r = 0.85 },
    		    gear_coeff = -80,
    		    accl_coeff = 100,
    		},
    		[ 2 ] = {
    		    name = "2",
    		    zones = { y = 0.57, g = 0.75, r = 0.85 },
    		    gear_coeff = -60,
    		    accl_coeff = 60,
    		},
    		[ 3 ] = {
    		    name = "3",
    		    zones = { y = 0.63, g = 0.78, r = 0.85 },
    		    gear_coeff = -50,
    		    accl_coeff = 40,
    		},
    		[ 4 ] = {
    		    name = "4",
    		    zones = { y = 0.67, g = 0.8, r = 0.85 },
    		    gear_coeff = -30,
    		    accl_coeff = 40,
    		},
    		[ 5 ] = {
    		    name = "5",
    		    gear_coeff = 0,
    		    accl_coeff = 0,
    		},
		}

		self.switch_early = 1
		self.switch_good = 2
		self.switch_nice = 3
		self.switch_bad = 4
		
		self.switch_reverse = 50
		self.switch_result = {
			[ self.switch_early ] = { start_value = 0,  value = 28, text = "Неудача!",  color = 0xFFDF3333 },
			[ self.switch_good  ] = { start_value = 10, value = 23, text = "Хорошо!",   color = 0xFFDCDF33 },
			[ self.switch_nice ]  = { start_value = 15, value = 18,  text = "Идеально!", color = 0xFF54FF58 },
			[ self.switch_bad ]   = { start_value = 5,  value = 21, text = "Неплохо!",  color = 0xFFDF3333 },
		}

		self.func_prepare_points = function( value )
			local minute = math.floor( value / 60000 )
			local seconds = math.floor( (value - minute * 60000) / 1000 )
			local milliseconds = value - minute * 60000 - seconds * 1000
			return string.format( "%02d:%02d:%02d", minute, seconds, milliseconds )
		end

		self.func_get_vehicle_speed = function()
			return math.max( 0.01, ( Vector3( getElementVelocity( self.vehicle ) ) * 180 ).length )
		end

		self.func_get_vehicle_rpm = function()
			return self.curreng_gear == 0 and self.neutral_rpm or math.floor( self.func_get_vehicle_speed() * 180 + 0.5 )
		end

		self.func_change_current_gear = function( direction )
			self.curreng_gear = math.max( 1, math.min( self.curreng_gear + direction, 5 ) )
			self.vehicle:setData( "custom_gear", self.curreng_gear, false )
			
			self.elements.cur_gear:ibData( "text", self.gear_setting[ self.curreng_gear ].name )
			
			resetVehicleParameters( self.vehicle )
			local offset_speed = (self.def_setting.speed / (6 - self.curreng_gear)) + self.gear_setting[ self.curreng_gear ].gear_coeff
			setVehicleParameters( self.vehicle, offset_speed, self.def_setting.accleration + self.gear_setting[ self.curreng_gear ].accl_coeff, self.def_setting.handling )
		
			local max_speed = getVehicleHandling( self.vehicle )[ "maxVelocity" ]
			self.def_setting.max_rpm = math.floor( (max_speed + max_speed / 10) * 180 + 0.5 )	
			triggerEvent( "onClientDragChangeGear", root, self.vehicle, { max_rpm = self.def_setting.max_rpm * 0.85, gear = self.curreng_gear } )	
		end

		self.func_set_vehicle_speed = function( speed )
    		local x, y, z = getElementVelocity( self.vehicle )
			local c_speed = self.func_get_vehicle_speed()
			local diff = speed / c_speed
    		setElementVelocity( self.vehicle, x * diff, y * diff, z * diff )
		end

		self.func_show_drag_change_gear_result = function( text, color )
			self.elements.drag_change_gear_result
				:ibBatchData({ text = text, alpha = 255, color = color })
				:ibInterpolate( function( self )
					if not isElement( self.element ) then return end
					self.easing_value = 1 + 0.2 * self.easing_value
					self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
					if self.easing_value >= 1 then
						self.element:ibAlphaTo( 0, 1000 )
					end
				end, 350, "SineCurve" )
		end

		self.func_reset_speed = function( direction, current_rpm )
			local gear = math.max( 1, self.curreng_gear - 1 )
			if self.gear_setting[ gear ].zones and direction then
				local switch_type = self.switch_early
				if current_rpm >= self.gear_setting[ gear ].zones.y and current_rpm <= self.gear_setting[ gear ].zones.g then
					switch_type = self.switch_good
				elseif current_rpm >= self.gear_setting[ gear ].zones.g and current_rpm <= self.gear_setting[ gear ].zones.r then
					switch_type = self.switch_nice
				elseif current_rpm >= self.gear_setting[ gear ].zones.r then
					switch_type = self.switch_bad
				end

				if CURRENT_GEAR ~= 1 then
					self.func_set_vehicle_speed( self.func_get_vehicle_speed() - self.switch_result[ switch_type ].value )
				else
					self.func_set_vehicle_speed( self.switch_result[ switch_type ].start_value )
				end
				self.func_show_drag_change_gear_result( self.switch_result[ switch_type ].text, self.switch_result[ switch_type ].color )
			elseif not direction and self.func_get_vehicle_speed() >= 50 then
				self.func_set_vehicle_speed( self.func_get_vehicle_speed() - self.switch_reverse )
			end
		end

		self.func_get_veh_params = function()
			local result = { speed = 0, acceleration = 0, handling = 0}
			for k, v in pairs( CLIENT_VAR_installed_drag_items ) do
				local data = CONST_DRAG_ITEMS_CHANCES[ v ]
				result.speed = result.speed + (data.speed or 0)
				result.acceleration = result.acceleration + (data.acceleration or 0)
				result.handling = result.handling + (data.handling or 0) 
			end
			return result
		end

		self.func_set_move_controls_state = function( state )
			toggleControl( "accelerate", state )
			toggleControl( "brake_reverse", state )
			toggleControl( "backwards", state )
			setPedControlState( localPlayer, "handbrake", not state )
		end

		self.func_start_drag = function( self )
			self.start_time = getTickCount()
		end

		self.destroy = function( self )			
			removeEventHandler( "onClientPreRender", root, self.func_on_neutral_rpm )
			removeEventHandler( "onClientKey", root, self.func_on_client_key )

			if isElement( self.elements.bg_area_drag_race ) then
				destroyElement( self.elements.bg_area_drag_race )
			end

			for k, v in pairs( { self.elements.ox_bold_25, self.elements.ox_regular_41, self.elements.ox_regular_28 } ) do
				if isElement( v ) then destroyElement( v ) end
			end

			self.func_set_move_controls_state( true )

			CLIENT_ShowInstalledItemsUI( false )
			setPedControlState( localPlayer, "handbrake", false )
			setmetatable( self, nil )
		end

		local result = self.func_get_veh_params( self.vehicle )
		self.def_setting = {
			max_rpm = self.max_neutral_rpm,
			speed = result.speed,
			accleration = result.acceleration,
			handling = result.handling,
		}
		
		self.elements.ox_bold_25 = dxCreateFont( ":nrp_races/files/fonts/Oxanium-Bold.ttf", 25, false, "antialiased" )
		self.elements.ox_regular_41 = dxCreateFont( ":nrp_races/files/fonts/Oxanium-Regular.ttf", 41, false, "antialiased" )
		self.elements.ox_regular_28 = dxCreateFont( ":nrp_races/files/fonts/Oxanium-Regular.ttf", 28, false, "antialiased" ) 

		self.elements.bg_area_drag_race = ibCreateArea( 0, 0, _SCREEN_X, _SCREEN_Y )
		self.elements.bg_tachometer = ibCreateImage( 60, 0, 296, 646, ":nrp_races/files/img/drag/bg_tachometer.png", self.elements.bg_area_drag_race ):center_y()

		self.elements.race_name = ibCreateLabel( _SCREEN_X - 29, 29, 0, 0, "ДРАГ-РЕЙСИНГ", self.elements.bg_area_drag_race, 0xFFFFFFFF, 1, 1, "right", "top", ibFonts.bold_34 ):ibData( "outline", 1 )
		self.elements.race_icon = ibCreateImage( _SCREEN_X - 66, 89, 36, 42, ":nrp_races/files/img/drag/timer.png", self.elements.bg_area_drag_race )
		self.elements.race_time = ibCreateLabel( _SCREEN_X - 87, 92, 0, 42, self.func_prepare_points( 0 ), self.elements.bg_area_drag_race, 0xFFFFFFFF, 1, 1, "right", "center", self.elements.ox_bold_25 ):ibData( "outline", 1 )
		
		self.elements.podium_icon = ibCreateImage( _SCREEN_X - 65, 229, 36, 42, ":nrp_races/files/img/drag/podium.png", self.elements.bg_area_drag_race )
        self.elements.race_place = ibCreateLabel( _SCREEN_X - 130, 228, 0, 42, "1", self.elements.bg_area_drag_race, 0xFFFFFFFF, 1, 1, "right", "center", self.elements.ox_regular_41 ):ibData( "outline", 1 )
        self.elements.count_places = ibCreateLabel( _SCREEN_X - 88, 236, 0, 42, "/2", self.elements.bg_area_drag_race, 0xFF8B8B8B, 1, 1, "right", "center", self.elements.ox_regular_28 )

		ibCreateImage( _SCREEN_X - 65, 156, 36, 42, "img/may_events/flag.png", self.elements.bg_area_drag_race )
        ibCreateLabel( _SCREEN_X - 130, 155, 0, 42, #CLIENT_VAR_finish_rounds_data + 1, self.elements.bg_area_drag_race, 0xFFFFFFFF, 1, 1, "right", "center", self.elements.ox_regular_41 ):ibData( "outline", 1 )
        ibCreateLabel( _SCREEN_X - 88, 163, 0, 42, "/" .. CONST_NUMBER_DRAG_RACE, self.elements.bg_area_drag_race, 0xFF8B8B8B, 1, 1, "right", "center", self.elements.ox_regular_28 )

		self.elements.rpm_line = ibCreateImage( 18, 106, 140, 281, ":nrp_races/files/img/drag/gear_0.png", self.elements.bg_tachometer ):ibData( "disabled", true )
        	:ibTimer( function( self_element )
				local count = (self_element:ibData( "count" ) or 0) + 1
				self_element:ibData( "count", count )

				if count == 4 then
					playSound( ":nrp_races/files/sfx/start.wav" )
					self:func_start_drag()
				else
					playSound( ":nrp_races/files/sfx/timer_tick.wav" )
				end
			end, CONST_TIME_TO_TEXT_START_IN_MS - 300, 4 )

		self.elements.cur_gear = ibCreateLabel( 207, 416, 0, 0, "N", self.elements.bg_tachometer, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_50 )

		ibCreateImage( 0, 0, 262, 646, ":nrp_races/files/img/drag/tachometer_arrows.png", self.elements.bg_tachometer )

		self.elements.arrow_rpm = ibCreateImage( 205, 285, 34, 243, ":nrp_races/files/img/drag/arrow.png", self.elements.bg_tachometer )
        	:ibBatchData( { rotation_offset_x = 0, rotation_offset_y = -77 } )
			:ibOnRender( function()
        	    if self.curreng_gear > 0 then
        	        self.elements.arrow_rpm:ibData( "rotation", math.min( 185, (self.func_get_vehicle_rpm( ) / self.def_setting.max_rpm ) * 180 ) )
        	        self.elements.rpm_line:ibData( "texture", ":nrp_races/files/img/drag/gear_" .. self.curreng_gear .. ".png" )
        	    end
        	end )
			:ibTimer( function()
				if not self.start_time then return end
        	        
        	    self.elements.race_time:ibData( "text", self.func_prepare_points( getTickCount() - self.start_time ) )
				local race_place = getDistanceBetweenPoints3D( localPlayer.position, CONST_DRAG_FINISH ) > getDistanceBetweenPoints3D( CLIENT_VAR_rival_player.position, CONST_DRAG_FINISH ) and 2 or 1
        	    if self.prev_place ~= race_place then
        	        self.prev_place = race_place
        	        self.elements.race_place:ibData( "text", race_place )
        	    end
			end, 100, 0 )

		ibCreateImage( 0, _SCREEN_Y - 100, 601, 70, ":nrp_races/files/img/drag/hint_shift.png", self.elements.bg_area_drag_race ):center_x()
        	:ibTimer( function( self )
        	    self:ibAlphaTo( 0, 150 )
        	end, 5000, 1 )
		
		self.elements.drag_change_gear_result = ibCreateLabel( 0, 200, _SCREEN_X, 0, "", self.elements.bg_area_drag_race, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_32 ):ibData( "outline", true )
		
		self.keys_forward = getBoundKeys( "forwards" )
		self.func_on_neutral_rpm = function( time_slice )
			local is_key_forward = false
			for k, v in pairs( self.keys_forward ) do
				if getKeyState( k ) then 
					is_key_forward = true
					break
				end
			end
			
			self.neutral_rpm = is_key_forward and math.min( self.neutral_rpm + time_slice, self.max_neutral_rpm ) or math.max( 0, self.neutral_rpm - time_slice )
			self.elements.arrow_rpm:ibData( "rotation", self.neutral_rpm / self.max_neutral_rpm * 180 )
		end
		addEventHandler( "onClientPreRender", root, self.func_on_neutral_rpm )

		self.func_on_client_key = function( key, state )
			if not state or not self.start_time then return end
    
    		if key == "arrow_u" and self.curreng_gear ~= 5 then
    		    cancelEvent()
    		    if self.curreng_gear == 0 then
					removeEventHandler( "onClientPreRender", root, self.func_on_neutral_rpm )
					self.func_set_move_controls_state( true )

					local current_rpm = self.neutral_rpm / self.def_setting.max_rpm
    		        self.func_change_current_gear( 1 )
    		        self.func_reset_speed( true, current_rpm )
    		    elseif self.curreng_gear < 5 then
					local current_rpm = self.func_get_vehicle_rpm( vehicle ) / self.def_setting.max_rpm
    		        self.func_change_current_gear( 1 )
    		        self.func_reset_speed( true, current_rpm )
    		    end
    		elseif key == "arrow_d" and self.curreng_gear ~= 0 then
				cancelEvent()

				local current_rpm = self.func_get_vehicle_rpm() / self.def_setting.max_rpm
    		    self.func_change_current_gear( -1 )
    		    self.func_reset_speed( false, current_rpm )
    		end
		end
		addEventHandler( "onClientKey", root, self.func_on_client_key )

		self.vehicle :setData( "custom_gear", self.curreng_gear, false )

		CLIENT_ShowInstalledItemsUI( true )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_DRAG_RACE_BLOCKS, false )
		
		self.func_set_move_controls_state( false )
		DisableHUD( false )
		triggerEvent( "onClientSetChatState", localPlayer, false )

		UIe.drag_interface = self
	elseif (UIe and UIe.drag_interface) then
		UIe.drag_interface:destroy()
		UIe.drag_interface = nil
	end
end

local function CLIENT_ShowDragRoundResult( state, data )
	if state then
		CLIENT_ShowDragRaceUI( false )
		CLIENT_ShowDragRoundResult( false )

		for k, v in pairs( { "accelerate", "brake_reverse", "backwards" } ) do
			setPedControlState( localPlayer, v, false )
			toggleControl( v, false )
		end
			
		setPedControlState( localPlayer, "handbrake", true )
		addEventHandler( "onClientKey", root, CLIENT_CancelEventKeys )

		UIe.black_bg_round_result = ibCreateBackground( 0xF4181818, nil ):ibData( "alpha", 0 ):ibAlphaTo( 255, 1500 )
			:ibTimer( function( self )
				self:ibAlphaTo( 0, 500 )
				self:ibTimer( function()
					CLIENT_ShowDragRoundResult( false )
				end, 500, 1 )
			end, CONST_TIME_SHOW_RESULT_ROUND_IN_SEC * 1000 - 1000, 1 )

		UIe.bg_glow = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/may_events/bg_glow.png", UIe.black_bg_round_result )
		UIe.bg_round_result = ibCreateImage( 0, 0, 1024, 720, "img/may_events/bg_drag_result_round.png", UIe.black_bg_round_result ):center()
			
		local is_localplayer_winner = localPlayer == data[ #data ]
		local player_result = is_localplayer_winner and "win" or "lose"
		local rival_result = is_localplayer_winner and "lose" or "win"

		UIe.bg_result_round_left = ibCreateImage( 0, 103, 512, 200, "img/may_events/bg_result_round_left_" .. player_result .. ".png", UIe.bg_round_result )
		ibCreateLabel( 284, 68, 0, 0, localPlayer:GetNickName(), UIe.bg_result_round_left, 0xFFD8D6D6, nil, nil, "right", "top", ibFonts.bold_22 ):ibData( "outline", 1 )
		ibCreateContentImage( 302, 20, 130, 160, "skin", localPlayer.model, UIe.bg_result_round_left )
		ibCreateImage( 302, 20, 130, 160, "img/may_events/" .. player_result .. "_stroke.png", UIe.bg_result_round_left )
		

		UIe.bg_result_round_right = ibCreateImage( 512, 103, 512, 200, "img/may_events/bg_result_round_right_" .. rival_result .. ".png", UIe.bg_round_result )
		ibCreateLabel( 229, 68, 0, 0, CLIENT_VAR_rival_player:GetNickName(), UIe.bg_result_round_right, 0xFFD8D6D6, nil, nil, "left", "top", ibFonts.bold_22 ):ibData( "outline", 1 )
		ibCreateContentImage( 80, 20, 130, 160, "skin", CLIENT_VAR_rival_player.model, UIe.bg_result_round_right )
		ibCreateImage( 80, 20, 130, 160, "img/may_events/" .. rival_result .. "_stroke.png", UIe.bg_result_round_right )

		ibCreateImage( 456, 107, 110, 192, "img/may_events/vs_icon.png", UIe.bg_round_result  )

		local px_round, py_round = 344, 341
		local px_item, py_item = 342, 518
		for i = 1, 3 do
			local winner = data[ i ]
			local round_result = winner and (winner == localPlayer and "win" or "lose") or (i == 3 and not data[ 2 ] and "blocked" or "next")
			ibCreateImage( px_round, py_round, 128, 128, "img/may_events/circle_round_" .. round_result .. ".png", UIe.bg_round_result )
			px_round = px_round + 104

			local drag_item_index = CLIENT_VAR_installed_drag_items[ i ]
			local bg_drag_item = ibCreateImage( px_item, py_item, 100, 100, "img/may_events/bg_drag_item.png", UIe.bg_round_result )
			if drag_item_index then
				bg_drag_item:ibData( "color", CONST_DRAG_ITEMS_CHANCES[ drag_item_index ].color )
				local drag_item_type = string.match( CONST_DRAG_ITEMS_CHANCES[ drag_item_index ].id , "(%a+)_")
				ibCreateImage( 0, 0, 100, 100, "img/may_events/" .. drag_item_type .. "_icon.png", bg_drag_item )
			elseif data[ i - 1 ] and not data[ i ] then
				bg_drag_item:ibData( "color", 0xFFF2BE21 )
				ibCreateLabel( 0, 0, 100, 100, "Доступна\nдеталь", bg_drag_item, 0xFFF2BE21, nil, nil, "center", "center", ibFonts.regular_14 )
			else
				ibCreateLabel( 0, 0, 100, 100, "Доступно\nна " .. i .. " раунде", bg_drag_item, 0xFFD7D6D6, nil, nil, "center", "center", ibFonts.regular_14 )
			end
			px_item = px_item + 120
		end

		local btn_continue = ibCreateButton( 0, 658, 164, 54, UIe.bg_round_result, "img/may_events/continue.png", "img/may_events/continue_h.png", "img/may_events/continue_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC ):center_x()
			:ibData( "disabled", true )
			:ibData( "alpha", 128 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				CLIENT_ShowDragRoundResult( false )
			end )
		
		ibCreateLabel( 0, 30, 164, 54, "5 секунд", btn_continue, 0xFFB1C6E1, nil, nil, "center", "top", ibFonts.regular_12 ):ibData( "disabled", true )
			:ibData( "count_tick", CONST_TIME_SHOW_RESULT_ROUND_IN_SEC - 2 )
			:ibTimer( function( self )
				local count_tick = tonumber( self:ibData( "count_tick" ) ) - 1
				self:ibData( "count_tick", count_tick )
				if count_tick > 0 then
					self:ibData( "text", count_tick .. " " .. plural( count_tick, "секунда", "секунды", "секунд" ) )
				else
					bindKey( "space", "up", CLIENT_DestroyDragRoundResult )
					self:ibData( "text", "[ПРОБЕЛ]" )
					btn_continue:ibData( "disabled", false )
					btn_continue:ibAlphaTo( 255, 250 )
				end
			end, 1000, 10 )

		table.insert( CLIENT_VAR_finish_rounds_data, data )
		DisableHUD( true )
		showCursor( true )
	else
		if isElement( UIe and UIe.black_bg_round_result ) then
			destroyElement( UIe.black_bg_round_result )
		end

		showCursor( false )
	end
end

function CLIENT_DestroyDragRoundResult()
	unbindKey( "space", "up", CLIENT_DestroyDragRoundResult )
	CLIENT_ShowDragRoundResult( false )
end

function ShowDragEventResult( state, number, coins, booster_coins, data )
	if state then
		ShowDragEventResult( false )
		
		UIe.reward_bg = ibCreateBackground( 0xBF000000, _, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 1500 )
		UIe.bg_glow = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/may_events/bg_glow.png", UIe.reward_bg )
		UIe.bg_drag_result = ibCreateImage( 0, 0, 1024, 720, "img/may_events/bg_drag_result.png", UIe.reward_bg ):center()
		
		local is_winner = number == 1
		ibCreateLabel( 774, 65, 0, 38, is_winner and "ВЫ ПОБЕДИЛИ!" or "ВЫ ПРОИГРАЛИ!", UIe.bg_drag_result, nil, nil, nil, "center", "center", ibFonts.bold_18 ):ibData( "outline", 1 ):center_x()
		
		UIe.bg_result_drag_place = ibCreateImage( 0, 103, 1024, 200, "img/may_events/bg_result_drag_place_" .. (is_winner and "win" or "lose") .. ".png", UIe.bg_drag_result, is_winner and 0xFF54FF68 or 0xFFCB2C2C )
		ibCreateLabel( 487, 69, 0, 0, localPlayer:GetNickName(), UIe.bg_result_drag_place, 0xFFD8D6D6, nil, nil, "left", "top", ibFonts.bold_22 ):ibData( "outline", 1 )
		ibCreateContentImage( 337, 20, 130, 160, "skin", localPlayer.model, UIe.bg_result_drag_place )
		ibCreateImage( 337, 20, 130, 160, "img/may_events/" .. (is_winner and "win" or "lose") .. "_stroke.png", UIe.bg_result_drag_place )

		local px_round, py_round = 344, UIe.bg_result_drag_place:ibGetAfterY( 38 )
		for i = 1, 3 do
			local winner = data.rounds_data[ i ]
			local round_result = winner and (winner == localPlayer and "win" or "lose") or "blocked"
			ibCreateImage( px_round, py_round, 128, 128, "img/may_events/circle_round_" .. round_result .. ".png", UIe.bg_drag_result )
			px_round = px_round + 104
		end

		local reward_tittle_bg = ibCreateImage( 0, UIe.bg_result_drag_place:ibGetAfterY( 70 ), 588, 213, "img/reward_tittle_bg.png", UIe.bg_drag_result ):center_x( )
		ibCreateLabel( 0, 0, 0, 0, "ПОЗДРАВЛЯЕМ! ВЫ ПОЛУЧИЛИ НАГРАДУ:", reward_tittle_bg, 0xFFFFD339, 1, 1, "center", "center", ibFonts.bold_19 ):center( 0, -8 )

		local rewards_bg = ibCreateArea( 0, py_round + 165, 100, 100, UIe.bg_drag_result ):center_x( )
		local reward_bg = ibCreateImage( 0, 0, 100, 100, "img/reward_item_bg.png", rewards_bg )
		if booster_coins then
			ibCreateImage( 0, 0, 28, 28, "img/reward_coins_icon.png", reward_bg ):center( 0, -14 )
			ibCreateLabel( 0, 74, 0, 0, coins, reward_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_25 ):center_x( )
		else
			ibCreateImage( 0, 0, 38, 34, "img/reward_booster_icon.png", reward_bg ):center( 0, -17 )
			ibCreateLabel( 0, 74, 0, 0, coins, reward_bg, 0xFFFFD339, 1, 1, "center", "center", ibFonts.bold_25 ):center_x( )
		end

		local offset_x = false
		if booster_coins then
			local func_interpolate = function( self )
				self:ibInterpolate( function( self )
					if not isElement( self.element ) then return end
					self.easing_value = 1 + 0.1 * self.easing_value
					self.element:ibBatchData( { scale_x = 	( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
				end, 350, "SineCurve" )
			end
	
			local reward_bg = ibCreateImage( 120, 0, 100, 100, "img/reward_item_bg.png", rewards_bg )
			ibCreateImage( 0, 0, 38, 34, "img/reward_booster_icon.png", reward_bg ):center( 0, -17 )
			ibCreateLabel( 0, 74, 0, 0, booster_coins, reward_bg, 0xFFFFD339, 1, 1, "center", "center", ibFonts.bold_25 ):center_x( )
				:ibTimer( func_interpolate, 100, 1 )
				:ibTimer( func_interpolate, 1000, 0 )
			ibCreateLabel( 0, 120, 0, 0, "С подарками в 2 раза\nбольше пуль", reward_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.semibold_11 ):center_x( )
				:ibTimer( func_interpolate, 100, 1 )
				:ibTimer( func_interpolate, 1000, 0 )
	
	
			rewards_bg:ibData( "sx", 220 ):center_x( )
	
			ibCreateButton( 0, 658, 184, 54, UIe.bg_drag_result, "img/may_events/btn_more_coins", true ):center_x( 55 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "up" then return end
					ibClick( )
	
					DestroyShowUIEventReward( )
					triggerEvent( "ShowUIEventBoosters", root )
				end )

			offset_x = true
		end
	
		local btn_ok = ibCreateButton( 0, rewards_bg:ibGetAfterY() + 50, 100, 54, UIe.bg_drag_result, "img/btn_ok", true ):center_x( offset_x and -98 or 0 )
			:ibData( "disabled", true )
			:ibData( "alpha", 128 )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )
	
				DestroyShowUIEventReward( )
			end )
	
		ibCreateLabel( 0, 0, 0, 0, "5 секунд", btn_ok, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.regular_12 ):center( 0, 10 )
			:ibData( "count_tick", 5 )
			:ibTimer( function( self )
				local count_tick = tonumber( self:ibData( "count_tick" ) ) - 1
				self:ibData( "count_tick", count_tick )
				if count_tick > 0 then
					self:ibData( "text", count_tick .. " " .. plural( count_tick, "секунда", "секунды", "секунд" ) )
				else
					bindKey( "space", "up", DestroyShowUIEventReward )
					self:ibData( "text", "[ПРОБЕЛ]" )
					btn_ok:ibData( "disabled", false )
					btn_ok:ibAlphaTo( 255, 250 )
				end
			end, 1000, 5 )

		showCursor( true )
	elseif isElement( UIe and UIe.reward_bg ) then
		destroyElement( UIe.reward_bg )
		showCursor( false )
	end
end

local function CLIENT_StartCountdown()
	CLIENT_ShowDragRaceUI( true )
	CreateUIStartTimer( CONST_TEXT_TO_START, CONST_TIME_TO_TEXT_START_IN_MS, ibFonts.bold_42 )
	removeEventHandler( "onClientKey", root, CLIENT_CancelEventKeys )
end

local function SERVER_SetVehiclesStartPosition( self )
	local counter = 1
	for player in pairs( self.players ) do
		local spawn = CONST_SPAWN_POSITIONS[ counter ]

		self.vehicles[ player ].frozen = true
		self.vehicles[ player ].health = 1000
		self.vehicles[ player ].position = Vector3( spawn.x, spawn.y, spawn.z )
		self.vehicles[ player ].rotation = Vector3( 0, 0, spawn.rz )
		
		counter = counter + 1
	end
end

local function SERVER_ShowSelectDragItem( player )
	local function GetRandomItem( items )
		local total_chance_sum = 0
		for _, item in pairs( items ) do
			total_chance_sum = total_chance_sum + item.chance
		end
		
		if total_chance_sum <= 0 then return end
	
		local dot = math.random( ) * total_chance_sum
		local current_sum = 0
		
		for i, item in pairs( items ) do
			local item_chance = item.chance
	
			if current_sum <= dot and dot < ( current_sum + item_chance ) then
				return i
			end
	
			current_sum = current_sum + item_chance
		end
	end

	local function GenerateDragItems()
		local results = {}
		for i = 1, 3 do 
			table.insert( results, GetRandomItem( CONST_DRAG_ITEMS_CHANCES ) )
		end
		return results
	end

	local selectable_drag_items = GenerateDragItems()
	player:setData( "selectable_drag_items", selectable_drag_items, false )

	triggerClientEvent( player, event_id .."_ShowSelectDragItemUI", resourceRoot, true, selectable_drag_items )
end

local function SERVER_StartNewRound( self )
	self.selected_item_players = 0
	for player in pairs( self.players ) do
		SERVER_ShowSelectDragItem( player )
	end
end

local function SERVER_CreateFinishPoint( self )
	self.finished_players = {}

	self.finish_colshape = createColRectangle( unpack( CONST_FINISH_COL_POSITION ) )
	self.finish_colshape.dimension = self.dimension
	
	addEventHandler( "onColShapeHit", self.finish_colshape, function( element, dimension )
		if getElementType( element ) ~= "vehicle" then return end

		local player = element.controller
		if not self.players[ player ] or not dimension or next( self.finished_players ) then return end
		destroyElement( self.finish_colshape )

		self.finished_players[ player ] = true
		table.insert( self.rounds_data, player )

		if #self.rounds_data == CONST_NUMBER_DRAG_RACE then
			local points_data = { }
			local fade_time = 1
			for player in pairs( self.players ) do
				fadeCamera( player, false, fade_time )
				table.insert( points_data, { player = player, points = 0 } )
			end

			for _, winner in pairs( self.rounds_data ) do
				for k, v in ipairs( points_data ) do
					if v.player == winner then
						v.points = v.points + 1
						break
					end
				end
			end
			table.sort( points_data, function( a, b )
				return a.points > b.points
			end )

			self.pre_end_tmr = setTimer( function()
				for k, v in ipairs( points_data ) do
					PlayerEndEvent( v.player, "Вы заняли ".. k .." место", _, k, true, { is_drag = true, rounds_data = self.rounds_data } )
				end
			end, fade_time * 1000, 1 )
		else
			local fade_time = 1
			self.start_tmr = setTimer( function()
				for player in pairs( self.players ) do
					fadeCamera( player, false, fade_time )
				end

				self.pre_start_tmr = setTimer( function()
					SERVER_SetVehiclesStartPosition( self )
					SERVER_StartNewRound( self )
				end, fade_time * 1000 + 1000, 1 )
			end, CONST_TIME_SHOW_RESULT_ROUND_IN_SEC * 1000 - fade_time * 1000, 1 )

			local target_players = {}
			for player in pairs( self.players ) do
				table.insert( target_players, player )
			end
			triggerClientEvent( target_players, event_id .."_ShowDragRoundResult", resourceRoot, true, self.rounds_data )
		end
	end, false, "high+999" )
end

local function SERVER_StartCountdown( self )
	local target_players = {}
	for player in pairs( self.players ) do
		table.insert( target_players, player )
	end
	triggerClientEvent( target_players, event_id .."_StartCountdown", resourceRoot )
	
	self.start_new_round_tmr = setTimer( function( )
		for player in pairs( self.players ) do
			if isElement( player ) and isElement( player.vehicle ) then
				player.vehicle.frozen = false
			end
		end
		SERVER_CreateFinishPoint( self )
	end, CONST_TIME_TO_TEXT_START_IN_MS * 4 - 1500, 1 )
end

local function SERVER_ClientSelectedDragItem( self, item_index )
	local selectable_drag_items = client:getData( "selectable_drag_items" )
	if not selectable_drag_items then return end	

	local is_item_exists = false
	for k, v in pairs( selectable_drag_items ) do
		if v == item_index then
			is_item_exists = true
			break
		end
	end

	if not is_item_exists then
		PlayerEndEvent( client, "Деталь не найдена", nil, nil, nil, { is_drag = true, rounds_data = self.rounds_data or {} } )
		return
	end
	client:setData( "selectable_drag_items", false, false )

	local item_data = CONST_DRAG_ITEMS_CHANCES[ item_index ]
	local cur_speed, cur_accleration, cur_handling = getVehicleParameters( self.vehicles[ client ] )
	setVehicleParameters( self.vehicles[ client ], cur_speed + (item_data.speed or 0), cur_accleration + (item_data.acceleration or 0), cur_handling + (item_data.handling or 0) )

	self.selected_item_players = self.selected_item_players + 1
	if self.selected_item_players == self.number_players_in_drag then
		SERVER_StartCountdown( self )
	end
end

local function SERVER_onPlayerPreWasted_handler( )
	cancelEvent( )
	PlayerEndEvent( source, "Вы покинули состязание", true )
end

local function CLIENT_PlayerExitFromGameZone( element, dim )
	if not dim or element ~= localPlayer then return end

	if isTimer( CLIENT_VAR_game_zone_exit_tmr ) then
		killTimer( CLIENT_VAR_game_zone_exit_tmr )
	end

	CLIENT_VAR_game_zone_exit_tmr = setTimer( function( )
		localPlayer.health = 0
		CLIENT_VAR_game_zone_exit_tmr = false
	end, CONST_TIME_TO_ZONE_EXIT_IN_SEC * 1000, 1 )

	CreateUIZoneExit( CONST_TIME_TO_ZONE_EXIT_IN_SEC )
end

local function CLIENT_PlayerEnterToGameZone( element, dim )
	if not dim or element ~= localPlayer then return end

	if isTimer( CLIENT_VAR_game_zone_exit_tmr ) then
		killTimer( CLIENT_VAR_game_zone_exit_tmr )
	end

	DeleteUIZoneExit( )
end

local function CLIENT_render_handler( )
	for i = 1, #CONST_GAME_ZONE, 2 do
        local x, y = CONST_GAME_ZONE[ i ], CONST_GAME_ZONE[ i + 1 ]

        local i_next = ( i + 2 ) >= #CONST_GAME_ZONE and 1 or ( i + 2 )
        local x_next, y_next = CONST_GAME_ZONE[ i_next ], CONST_GAME_ZONE[ i_next + 1 ]

        local _, _, z = getElementPosition( localPlayer )
        z = z - 10

        dxDrawMaterialLine3D( x, y, z, x_next, y_next, z, CLIENT_VAR_exit_zone_texture, 75, tocolor( 255, 128, 128, math.floor( 0.7 * 128 ) ), x_next + 1, y_next + 1, z )
	end
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Победный драг";
	group = "may_events";
	count_players = 2;

	coins_reward = {
		[ 1 ] = 40;
		[ 2 ] = 17;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}
		for player in pairs( self.players ) do
			fadeCamera( player, false, 0 )
			self.number_players_in_drag = (self.number_players_in_drag or 0) + 1

			local spawn = CONST_SPAWN_POSITIONS[ self.number_players_in_drag ]
			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, spawn.x, spawn.y, spawn.z, 0, 0, spawn.rz )
			vehicle.dimension = self.dimension
			vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )
			vehicle:setColor( 245, 245, 220  )
			self.vehicles[ player ] = vehicle

			setTimer( function( )
				player.vehicle = vehicle
				vehicle.frozen = true
			end, 100, 1 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )
		end

		AddCustomServerEventHandler( self, "ClientSelectedDragItem", SERVER_ClientSelectedDragItem )
	end;

	Setup_S_delay_handler = function( self, players )
		self.check_init_tmr = setTimer( function()
			for player in pairs( self.players ) do
				if not isElement( player.vehicle ) then
					PlayerEndEvent( player, "Ошибка инициализации", nil, nil, nil, { is_drag = true, rounds_data = self.rounds_data or {} } )
					return false
				end
			end

			self.rounds_data = {}
			SERVER_StartNewRound( self )
		end, 1000, 1 )

		self.end_tmr = setTimer( function( )
			for player in pairs( self.players ) do
				PlayerEndEvent( player, "Время вышло", nil, nil, nil, { is_drag = true, rounds_data = self.rounds_data or {} } )
			end
		end, CONST_TIME_TO_EVENT_END_IN_MS, 1 )
	end;

	Cleanup_S_handler = function( self )
        for k, v in pairs( { self.check_init_tmr, self.start_tmr, self.start_new_round_tmr, self.pre_start_tmr, self.pre_end_tmr, self.end_tmr } ) do
            if isTimer( v ) then killTimer( v ) end
        end

		RemoveCustomServerEventHandler( self, "ClientSelectedDragItem" )
	end;


	CleanupPlayer_S_handler = function( self, player )
		player:setData( "selectable_drag_items", false, false )
		removeEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler  )

		if isElement( self.finish_colshape ) then destroyElement( self.finish_colshape ) end
		if isElement( self.vehicles[ player ] ) then
			destroyElement( self.vehicles[ player ] )
		end
	end;

	Setup_C_handler = function( players, vehicles )
		DisableHUD( true )

		CLIENT_VAR_bg_sound = playSound( "sfx/bg_drag.ogg", true )
		setSoundVolume( CLIENT_VAR_bg_sound, 0.1 )

		CLIENT_VAR_installed_drag_items = {}
		CLIENT_VAR_finish_rounds_data = {}

		for player in pairs( players ) do
			if player ~= localPlayer then
				CLIENT_VAR_rival_player = player
				break
			end
		end

		CLIENT_VAR_exit_zone_texture = dxCreateRenderTarget( 1, 1 )
		dxSetRenderTarget( CLIENT_VAR_exit_zone_texture, true )
		dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
		dxSetRenderTarget( )
		addEventHandler( "onClientRender", root, CLIENT_render_handler )

		CLIENT_VAR_exit_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE ) )
		CLIENT_VAR_exit_zone_colshape.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeLeave", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerExitFromGameZone )
		addEventHandler( "onClientColShapeHit", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerEnterToGameZone )

		addEvent( event_id .."_ShowSelectDragItemUI", true )
		addEventHandler( event_id .."_ShowSelectDragItemUI", resourceRoot, CLIENT_ShowSelectDragItemUI )

		addEvent( event_id .."_StartCountdown", true )
		addEventHandler( event_id .."_StartCountdown", resourceRoot, CLIENT_StartCountdown )

		addEvent( event_id .."_ShowDragRoundResult", true )
		addEventHandler( event_id .."_ShowDragRoundResult", resourceRoot, CLIENT_ShowDragRoundResult )

		toggleControl( "enter_exit", false )
		
		localPlayer:setData( "drag_race", true, false )
		localPlayer:setData( "block_radio", true, false )
		
		triggerEvent( "onClientSetChatState", localPlayer, false )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_HUD_BLOCKS, true )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_DRAG_RACE_BLOCKS, true )
	end;

	Cleanup_C_handler = function( )
		fadeCamera( true )
		DisableHUD( false )

		CLIENT_ShowInstalledItemsUI( false )
		CLIENT_ShowSelectDragItemUI( false )
		CLIENT_ShowDragRaceUI( false )
		CLIENT_ShowDragRoundResult( false )
		
		removeEventHandler( "onClientRender", root, CLIENT_render_handler )
		removeEventHandler( event_id .. "_ShowSelectDragItemUI", resourceRoot, CLIENT_ShowSelectDragItemUI )
		removeEventHandler( event_id .. "_StartCountdown", resourceRoot, CLIENT_StartCountdown )
		removeEventHandler( event_id .. "_ShowDragRoundResult", resourceRoot, CLIENT_ShowDragRoundResult )
		
		if isElement( CLIENT_VAR_bg_sound ) then 
			stopSound( CLIENT_VAR_bg_sound ) 
			CLIENT_VAR_bg_sound = nil
		end

		CLIENT_VAR_installed_drag_items = nil
		CLIENT_VAR_finish_rounds_data = nil
		CLIENT_VAR_rival_player = nil
		
		for k, v in pairs( { CLIENT_VAR_game_zone_exit_tmr } ) do
			if isTimer( v ) then killTimer( v ) end
		end

		for k, v in pairs( { CLIENT_VAR_exit_zone_texture, CLIENT_VAR_exit_zone_colshape, CLIENT_VAR_exit_zone_texture } ) do
			if isElement( v ) then destroyElement( v ) end
		end

        toggleControl( "enter_exit", true )
		
		localPlayer:setData( "drag_race", false, false )
		localPlayer:setData( "block_radio", false, false )
		
		triggerEvent( "onClientSetChatState", localPlayer, true )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_HUD_BLOCKS, false )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_DRAG_RACE_BLOCKS, false )

		removeEventHandler( "onClientKey", root, CLIENT_CancelEventKeys )
		for k, v in pairs( { "accelerate", "brake_reverse", "backwards" } ) do
			toggleControl( v, true )
		end
	end;
}