loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )

local TOOL = nil
local ACRT = 2

function OnStart()
	local self = {
		ui_elements = {},
		elements_data = {},
		
		record_position = true,
		record_rotation = false,
		record_camera_matrix = false,

		interactive_mode = false,
	}

	self.copy_clipboard = function( self )
		local str = "{\n"
		for i, v in pairs( self.elements_data ) do
			local cortage_export = (v.x and v.rz) or (v.x and v.cx) -- pos + rot or pos + camera
			if cortage_export then
				str = str .. "\n\t{ "
				if v.x then
					str = str .. "pos = Vector3( "..v.x..", "..v.y..", "..v.z.." ), "
				end

				if v.rz then
					str = str .. "rot = Vector3( 0, 0, " .. v.rz .. " ), "
				end

				if v.cx and v.cy and v.cz and v.lx and v.ly and v.lz then
					str = str .. "c_matrix = { " .. v.cx .. ", " .. v.cy .. ", " .. v.cz .. ", " .. v.lx .. ", " .. v.ly .. ", " .. v.lz .. " }"
				end

				str = str .. " },"
			elseif v.x then
				str = str .. "\tVector3( "..v.x..", "..v.y..", "..v.z.." ),\n"
			elseif v.cx then
				str = str .. "{ " .. v.cx .. ", " .. v.cy .. ", " .. v.cz .. ", " .. v.lx .. ", " .. v.ly .. ", " .. v.lz .. " },\n"
			end
		end
		str = str.."\n}"

		localPlayer:ShowInfo( setClipboard( str ) and "Успешно скопировано" or "Что-то пошло не так" ) 
	end

	self.push_back = function()
		if not self.record_position and not self.record_camera_matrix then 
			localPlayer:ShowError( "Ошибка: не включена запись" )
			return 
		end

		local vehicle = localPlayer.vehicle
		local pos = vehicle and vehicle.position or localPlayer.position

		if self.record_position then
			for k, v in pairs( self.elements_data ) do
				if v.x and getDistanceBetweenPoints3D( pos.x, pos.y, pos.z, v.x, v.y, v.z ) < 3 then
					localPlayer:ShowError( "Ошибка: дубликат точки" )
					return
				end
			end
		end

		table.insert( self.elements_data, { name = "Без названия" } )

		local element_data = self.elements_data[ #self.elements_data ]
		if self.record_position then
			element_data.x, element_data.y, element_data.z = math.round( pos.x, ACRT ), math.round( pos.y, ACRT ), math.round( pos.z, ACRT )
		end

		if self.record_position and self.record_rotation then
			local rot = vehicle and vehicle.rotation or localPlayer.rotation
			element_data.rx, element_data.ry, element_data.rz = 0, 0, math.ceil( rot.z )			
		end

		if self.record_camera_matrix then
			local cx, cy, cz, lx, ly, lz = getCameraMatrix()
			cx, cy, cz, lx, ly, lz = math.round( cx, ACRT ), math.round( cy, ACRT ), math.round( cz, ACRT ), math.round( lx, ACRT ), math.round( ly, ACRT ), math.round( lz, ACRT )
			element_data.cx, element_data.cy, element_data.cz, element_data.lx, element_data.ly, element_data.lz = cx, cy, cz, lx, ly, lz
		end

		element_data.blip = createBlip( pos )
		self:refresh_scrollpane()
	end

	self.remove_element = function( self, index )
		destroyElement( self.elements_data[ index ].blip )
		table.remove( self.elements_data, index )
		self:refresh_scrollpane()
	end

	self.enable_cursor = function()
		showCursor( not isCursorShowing() )
	end

	self.render_elements_data = function()
		for i, v in pairs( self.elements_data ) do
			if v.x then
				dxDrawLine3D( v.x, v.y, v.z - 1, v.x, v.y, v.z + 2, i == #self.elements_data and 0xFF00FF00 or 0xFFFFFF00, 2 )
			end
		end
	end
	addEventHandler( "onClientRender", root, self.render_elements_data )
	
	self.refresh_scrollpane = function( self )
		if not isElement( self.ui_elements.bg ) then return end
		if isElement( self.ui_elements.scrollpane) then 
			destroyElement( self.ui_elements.scrollpane )
			destroyElement( self.ui_elements.scrollbar )  
		end

		self.ui_elements.scrollpane, self.ui_elements.scrollbar = ibCreateScrollpane( 10, 70, 990, 320, self.ui_elements.bg, { scroll_px = -2, bg_color = 0xFF315168 } )
		self.ui_elements.scrollbar:ibSetStyle( "slim_nobg" )

		ibCreateImage( 0, 0, 165, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
		ibCreateLabel( 0, 0, 165, 40, "Название", self.ui_elements.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

		ibCreateImage( 175, 0, 200, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
		ibCreateLabel( 175, 0, 200, 40, "Координаты", self.ui_elements.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

		ibCreateImage( 385, 0, 200, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
		ibCreateLabel( 385, 0, 200, 40, "Поворот", self.ui_elements.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

		ibCreateImage( 595, 0, 400, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
		ibCreateLabel( 595, 0, 400, 40, "Камера", self.ui_elements.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

		local func_edit_name_handler = function()
			if key ~= "text" then return end
			self.elements_data[ source:ibData( "id" ) ].name = value
		end

		for i, v in ipairs( self.elements_data ) do 
			local py = i * 50

			ibCreateImage( 0, py, 165, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
			ibCreateEdit( 10, py, 155, 40, v.name, self.ui_elements.scrollpane, 0xFFFFFFFF, 0xFF315168, 0xFFFFFFFF ):ibData( "id", i ):ibOnDataChange( func_edit_name_handler )

			ibCreateImage( 175, py, 200, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
			ibCreateLabel( 185, py, 200, 40, "X: " .. (v.x or "-") .. "  Y: " .. (v.y or "-") .. "  Z: " .. (v.z or "-"), self.ui_elements.scrollpane, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )

			ibCreateImage( 385, py, 200, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
			ibCreateLabel( 395, py, 200, 40, "RX: " .. (v.rx or "-") .. "  RY: " .. (v.ry or "-") .. "  RZ: " .. (v.rz or "-"), self.ui_elements.scrollpane, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )

			ibCreateImage( 595, py, 400, 40, nil, self.ui_elements.scrollpane, 0xFF315168 )
			ibCreateLabel( 605, py, 400, 40, "X: "..(v.cx or "-").."  Y: "..(v.cy or "-").."  Z: "..(v.cz or "-") .. "  LX: "..(v.lx or "-").."  LY: "..(v.ly or "-").."  LZ: "..(v.lz or "-"), self.ui_elements.scrollpane, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
		end

		self.ui_elements.scrollpane:AdaptHeightToContents()
		self.ui_elements.scrollbar:UpdateScrollbarVisibility( self.ui_elements.scrollpane )
	end

	self.show_menu = function( self, state )
		if state then
			self:show_menu( false )

			self.ui_elements.bg = ibCreateImage( 20, 20, 1010, 500, nil, nil, 0xFF385B74 )
			self.ui_elements.header_bg = ibCreateImage( 0, 0, 1010, 60, nil, self.ui_elements.bg, 0xFF315168 )
			ibCreateLabel( 0, 0, 990, 60, "Интерактив - F7", self.ui_elements.header_bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_15 )
			self.ui_elements.horizontal_line = ibCreateImage( 0, 61, 400, 1, nil, self.ui_elements.header_bg, 0xFF476378 )

			self:refresh_scrollpane( )

			self.ui_elements.record_position_area = ibCreateImage( 10, 450, 180, 40, nil, self.ui_elements.bg, 0xFF315168 )
			self.ui_elements.record_position_lbl = ibCreateLabel( 0, 0, 180, 40, "Запись позиции(" .. (self.record_position and "Вкл" or "Выкл") .. ")", self.ui_elements.record_position_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick()
					self.record_position = not self.record_position
					self.ui_elements.record_position_lbl:ibData( "text", "Запись позиции(" .. (self.record_position and "Вкл" or "Выкл") .. ")" )
				end )

			self.ui_elements.record_rotation_area = ibCreateImage( self.ui_elements.record_position_area:ibGetAfterX( 10 ), 450, 180, 40, nil, self.ui_elements.bg, 0xFF315168 )
			self.ui_elements.record_rotation_lbl = ibCreateLabel( 0, 0, 180, 40, "Запись поворота(" .. (self.record_rotation and "Вкл" or "Выкл") .. ")", self.ui_elements.record_rotation_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick()
					self.record_rotation = not self.record_rotation
					self.ui_elements.record_rotation_lbl:ibData( "text", "Запись поворота(" .. (self.record_rotation and "Вкл" or "Выкл") .. ")" )
				end )

			self.ui_elements.record_camera_area = ibCreateImage( self.ui_elements.record_rotation_area:ibGetAfterX( 10 ), 450, 180, 40, nil, self.ui_elements.bg, 0xFF315168 )
			self.ui_elements.record_camera_lbl = ibCreateLabel( 0, 0, 180, 40, "Запись камеры(" .. (self.record_camera_matrix and "Вкл" or "Выкл") .. ")", self.ui_elements.record_camera_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick()
					self.record_camera_matrix = not self.record_camera_matrix
					self.ui_elements.record_camera_lbl:ibData( "text", "Запись камеры(" .. (self.record_camera_matrix and "Вкл" or "Выкл") .. ")" )
				end )

			self.ui_elements.record_area = ibCreateImage( self.ui_elements.record_camera_area:ibGetAfterX( 10 ), 450, 90, 40, nil, self.ui_elements.bg, 0xFF315168 )
			ibCreateLabel( 0, 0, 90, 40, "Запись", self.ui_elements.record_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick()
					
					self:push_back()
				end )

			self.ui_elements.area_copy = ibCreateImage( self.ui_elements.record_area:ibGetAfterX( 10 ), 450, 100, 40, nil, self.ui_elements.bg, 0xFF315168 )
			ibCreateLabel( 0, 0, 100, 40, "Скопировать", self.ui_elements.area_copy, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick()

					self:copy_clipboard()
				end )

			self.ui_elements.area_clear = ibCreateImage( self.ui_elements.area_copy:ibGetAfterX( 10 ), 450, 100, 40, nil, self.ui_elements.bg, 0xFF315168 )
			ibCreateLabel( 0, 0, 100, 40, "Очистить", self.ui_elements.area_clear, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick()

					self.elements_data = {}
					self:refresh_scrollpane()
				end )

			self.ui_elements.exit_area = ibCreateImage( self.ui_elements.area_clear:ibGetAfterX( 10 ), 450, 100, 40, nil, self.ui_elements.bg, 0xFF315168 )
			ibCreateLabel( 0, 0, 100, 40, "Выход", self.ui_elements.exit_area, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick()

					self:show_menu( false )
				end )

			self.try_remove_element = function()
				local player_position = localPlayer.position
				local index = nil
				
				local min_distance = 10
				for k, v in pairs( self.elements_data ) do
					local cur_distance = getDistanceBetweenPoints3D( player_position.x, player_position.y, player_position.z, v.x, v.y, v.z )
					if cur_distance < min_distance then
						index = k
						min_distance = cur_distance
					end
				end

				if index then
					self:remove_element( index )
					localPlayer:ShowInfo( "Точка удалена" )
				else
					localPlayer:ShowError( "Точка не найдена" )
				end
			end

			self.enable_interfactive = function()
				self.interactive_mode = not self.interactive_mode
				if self.interactive_mode then
					bindKey( "e", "down", self.push_back )
					bindKey( "z", "down", self.try_remove_element )
				else
					unbindKey( "e", "down", self.push_back )
					unbindKey( "z", "down", self.try_remove_element )
				end
				localPlayer:ShowInfo( "Интерактивный режим " .. (self.interactive_mode and "активирован:\nE - добавить, Z - удалить" or "деактивирован"))
			end

			bindKey( "r", "down", self.enable_cursor )
			bindKey( "f7", "down", self.enable_interfactive )
			
			showCursor( true )
		elseif isElement( self.ui_elements.bg ) then
			unbindKey( "r", "down", self.enable_cursor )
			unbindKey( "f7", "down", self.enable_interfactive )

			destroyElement( self.ui_elements.bg )
			showCursor( false ) 
		end
	end

	addCommandHandler( "ceo_recorder", function( )
		self:show_menu( not isElement( self.ui_elements.bg ) )
	end )
	TOOL = self
end
addEventHandler( "onClientResourceStart", resourceRoot, OnStart )

function math.round( num, numDecimalPlaces )
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end