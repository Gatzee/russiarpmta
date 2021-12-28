loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend("ShUtils")

ACCEPTED_MODELS = 
{
	{1340, "Стена", 0},
	{2991, "Коробки 1", 0.6},
	{3066, "Коробки 2", 1},
	{2973, "Большая коробка", 0},
	{2974, "Ящик с надписью", 0},
	{2935, "Контейнер 1", 1.4},
	{2932, "Контейнер 2", 1.4},
	{3015, "Оружейный ящик", 0.1},
	{2912, "Коробка", 0},
}

RACE_TYPES = {
	"Круг на время",
	"Дрифт",
	"Драг",
}

CURRENT_TRACK = { static_objects = {}, spawns = {}, markers = {}, dynamic_objects = {} }

local scx, scy = guiGetScreenSize()
local sizeX, sizeY = 400, 500
local posX, posY = 10, (scy-sizeY)/2

local ui = {}

local current_mode = 1
local current_model = 1340
local z_bias = 0

local last_actions = {}

local modes_list = 
{
	"Спавны",
	"Маркера",
	"Объекты",
	"Дин.объекты"
}

local element
local e_x, e_y, e_z, e_rx, e_ry, e_rz = 0,0,0,0,0,0

function ShowUI( state )
	if state then
		ShowUI(false)
		showCursor(true)
		addEventHandler("onClientRender", root, UpdatePointPosition)
		addEventHandler("onClientKey", root, KeyHandler)

		CURRENT_TRACK = { static_objects = {}, spawns = {}, markers = {}, dynamic_objects = {} }
		element = createVehicle(560, 0,0,0)
		setElementAlpha(element, 200)
		setElementCollisionsEnabled( element, false )
		current_mode = 1
		current_model = 1340
		z_bias = 1

		ui.main = guiCreateWindow( posX, posY, sizeX, sizeY, "Track Constructor", false )
		ui.tab_panel = guiCreateTabPanel( 0, 20, sizeX, sizeY, false, ui.main )
		for k,v in pairs(modes_list) do
			ui["tab"..k] = guiCreateTab( v, ui.tab_panel )
			ui["list"..k] = guiCreateGridList( 20, 20, sizeX-60, 150, false, ui["tab"..k] )
			guiGridListAddColumn( ui["list"..k], "Element", 0.9 )
			if k == 2 or k == 3 then
				guiGridListSetSelectionMode( ui["list"..k], 1)
			end

			ui["btn_destroy"..k] = guiCreateButton( 20, 180, 120, 40, "Удалить", false, ui["tab"..k] )
			ui["btn_properties"..k] = guiCreateButton( 240, 180, 120, 40, "Свойства", false, ui["tab"..k] )

			ui["btn_clear"..k] = guiCreateButton( 20, 370, 120, 40, "Очистить", false, ui["tab"..k] )

			if k == 3 or k == 4 then
				ui["list_models"..k] = guiCreateGridList( 20, 230, sizeX-60, 120, false, ui["tab"..k] )
				guiGridListAddColumn( ui["list_models"..k], "Model", 0.3 )
				guiGridListAddColumn( ui["list_models"..k], "Name", 0.6 )

				for i,model in pairs(ACCEPTED_MODELS) do
					local row = guiGridListAddRow( ui["list_models"..k] )
					guiGridListSetItemText( ui["list_models"..k], row, 1, model[1], false, false )
					guiGridListSetItemText( ui["list_models"..k], row, 2, model[2], false, false )
					guiGridListSetItemData( ui["list_models"..k], row, 1, model )
				end
			end

			addEventHandler("onClientGUIClick", ui["tab"..k], function( btn )
				if btn ~= "left" then return end
				if source == ui["btn_destroy"..k] then
					local selection = guiGridListGetSelectedItems( ui["list"..k] )
					if selection and #selection >= 1 then
						local selected_objects = {}

						for i, row in pairs(selection) do
							local key = guiGridListGetItemData( ui["list"..k], row.row, 1 )
							if k == 2 then
								table.insert(selected_objects, CURRENT_TRACK.markers[key].temp)
							elseif k == 3 then
								table.insert(selected_objects, CURRENT_TRACK.static_objects[key].temp)
							end
						end

						local key = guiGridListGetItemData( ui["list"..k], selection[1].row, 1 )

						if k == 1 then
							destroyElement( CURRENT_TRACK.spawns[key].temp )
							table.remove(CURRENT_TRACK.spawns, key)
						elseif k == 2 then
							for i,obj in pairs(selected_objects) do
								for index, value in pairs(CURRENT_TRACK.markers) do
									if value.temp == obj then
										destroyElement( CURRENT_TRACK.markers[index].temp )
										table.remove(CURRENT_TRACK.markers, index)
										break
									end
								end
							end
						elseif k == 3 then
							for i,obj in pairs(selected_objects) do
								for index, value in pairs(CURRENT_TRACK.static_objects) do
									if value.temp == obj then
										destroyElement( CURRENT_TRACK.static_objects[index].temp )
										table.remove(CURRENT_TRACK.static_objects, index)
										break
									end
								end
							end
						elseif k == 4 then
							for i, obj in pairs(CURRENT_TRACK.dynamic_objects[key]) do
								destroyElement( obj.temp )
							end
							table.remove(CURRENT_TRACK.dynamic_objects, key)
						end
						RefreshTab(k)
					end
				elseif source == ui["btn_clear"..k] then
					CleanupElements(k)
					RefreshTab(k)
				elseif source == ui["list_models"..k] then
					local selection = guiGridListGetSelectedItem( ui["list_models"..k] )
					if selection and selection >= 0 then
						local data = guiGridListGetItemData( ui["list_models"..k], selection, 1 )
						current_model = data[1]
						z_bias = data[3] or 0
						if getElementType(element) == "object" then
							setElementModel(element, current_model)
						end
					end
				end
			end)
		end


		ui.tab_settings = guiCreateTab( "Прочее", ui.tab_panel )

		ui.label_name = guiCreateLabel( 20, 30, 300, 20, "Название трека (ТОЛЬКО ЛАТИНИЦА!)", false, ui.tab_settings )
		ui.edit_name = guiCreateEdit( 20, 50, 200, 30, "", false, ui.tab_settings )
		ui.btn_save = guiCreateButton( 240, 50, 120, 30, "Сохранить трек", false, ui.tab_settings )


		ui.label_checkpoints = guiCreateLabel( 20, 100, 150, 20, "Всего чекпоинтов: 0", false, ui.tab_settings )
		ui.label_participants = guiCreateLabel( 20, 130, 150, 20, "Макс.участников: 0", false, ui.tab_settings )
		ui.label_objects = guiCreateLabel( 20, 160, 150, 20, "Всего объектов: 0", false, ui.tab_settings )
		ui.label_length = guiCreateLabel( 20, 190, 150, 20, "Общая длина: 0м", false, ui.tab_settings )

		local px, py = 250, 100
		for k,v in pairs(RACE_TYPES) do
			ui["check"..k] = guiCreateCheckBox( px, py, 150, 15, v, false, false, ui.tab_settings)
			py = py + 20
		end

		ui.btn_clear = guiCreateButton( 20, 220, 120, 30, "Очистить", false, ui.tab_settings )
		ui.btn_reverse = guiCreateButton( 160, 220, 120, 30, "Реверс", false, ui.tab_settings )

		ui.label_load = guiCreateLabel( 20, 280, 300, 20, "Загрузить трек(название)", false, ui.tab_settings )
		ui.edit_load = guiCreateEdit( 20, 300, 200, 25, "", false, ui.tab_settings )
		ui.btn_load = guiCreateButton( 240, 298, 120, 30, "Загрузить", false, ui.tab_settings )

		ui.btn_close = guiCreateButton( 120, 380, 140, 40, "ВЫХОД", false, ui.tab_settings )

		addEventHandler("onClientGUIClick", ui.tab_settings, function( btn )
			if btn ~= "left" then return end
			if source == ui.btn_save then
				CURRENT_TRACK.name = "track_"..guiGetText(ui.edit_name)
				CURRENT_TRACK.allowed_types = {  }
				for k,v in pairs(RACE_TYPES) do
					if guiCheckBoxGetSelected( ui["check"..k] ) then
						table.insert(CURRENT_TRACK.allowed_types, k)
					end
				end
				triggerServerEvent( "OnPlayerTrySaveTrack", localPlayer, CURRENT_TRACK )
			elseif source == ui.btn_load then
				sTrackName = "track_"..guiGetText(ui.edit_load)
				triggerServerEvent( "OnPlayerTryLoadTrack", localPlayer, sTrackName )
			elseif source == ui.btn_clear then
				for i = 1, 4 do
					CleanupElements(i)
				end
			elseif source == ui.btn_close then
				ShowUI(false)
			elseif source == ui.btn_reverse then
				local stored = table.copy( CURRENT_TRACK.markers )
				CleanupElements(2)

				CURRENT_TRACK.markers[1] = stored[1]
				local id = 1
				for i = #stored, 2, -1 do
					id = id + 1
					CURRENT_TRACK.markers[id] = stored[i]
				end

				for k,v in pairs(CURRENT_TRACK.markers) do
					if k == 1 then
						v.temp = createMarker( v.x, v.y, v.z-1.1, "cylinder", 3, 50, 200, 50 )
					else
						if v.is_visible then
							v.temp = createMarker( v.x, v.y, v.z, "checkpoint", 20, 200, 50, 50 )
						else
							v.temp = createMarker( v.x, v.y, v.z, "checkpoint", 20, 50, 50, 150, 50 )
						end
					end
				end

				for k,v in pairs(CURRENT_TRACK.static_objects) do
					if v.model == 1340 then
						if v.ry == 180 then
							v.ry = 0
							v.z = v.z - 3
						else
							v.ry = 180
							v.z = v.z + 3
						end
						setElementPosition( v.temp, v.x, v.y, v.z )
						setElementRotation( v.temp, v.rx or 0, v.ry or 0, v.rz or 0 )
					end
				end
			end
		end)

		addEventHandler("onClientGUITabSwitched", ui.main, function( tab )
			if tab == ui.tab1 then
				SwitchMode(1)
				z_bias = 1
			elseif tab == ui.tab2 then
				SwitchMode(2)
			elseif tab == ui.tab3 then
				SwitchMode(3)
			elseif tab == ui.tab4 then
				SwitchMode(4)
			elseif tab == ui.tab_settings then
				local total_distance = 0
				for k,v in pairs(CURRENT_TRACK.markers) do
					local pNextMarker = CURRENT_TRACK.markers[k+1]
					if pNextMarker then
						total_distance = total_distance + getDistanceBetweenPoints3D( v.x, v.y, v.z, pNextMarker.x, pNextMarker.y, pNextMarker.z )
					end
				end

				guiSetText( ui.label_length, "Общая длина: "..math.floor( total_distance ) )
				guiSetText( ui.label_participants, "Макс.участников: ".. #CURRENT_TRACK.spawns )
				guiSetText( ui.label_checkpoints, "Всего чекпоинтов: ".. #CURRENT_TRACK.markers )
				guiSetText( ui.label_objects, "Всего объектов: ".. #CURRENT_TRACK.static_objects + #CURRENT_TRACK.dynamic_objects )
			end
		end)
	else
		if isElement(ui.main) then destroyElement( ui.main ) end
		if isElement(element) then destroyElement( element ) end
		showCursor(false)
		removeEventHandler("onClientRender", root, UpdatePointPosition)
		removeEventHandler("onClientKey", root, KeyHandler)

		for i =1, 4 do
			CleanupElements(i)
		end
	end
end
addEvent("TC:ShowUI", true)
addEventHandler("TC:ShowUI", root, ShowUI)

function SwitchMode( iMode )
	if isElement(element) then destroyElement( element ) end
	if iMode == 1 then
		element = createVehicle(560,0,0,0)
		setElementCollisionsEnabled( element, false )
	elseif iMode == 2 then
		element = createMarker( 0, 0, 0, "checkpoint", 20, 200, 50, 50 )
	else
		element = createObject( current_model, 0, 0, 0 )
		setElementCollisionsEnabled( element, false )
	end
	setElementAlpha(element, 200)
	current_mode = iMode
	RefreshTab( iMode )
end

function RefreshTab( iTab )
	if isElement(ui["tab"..iTab]) then
		local list = ui["list"..iTab]
		guiGridListClear( list )

		if iTab == 1 then
			for k,v in pairs(CURRENT_TRACK.spawns) do
				local row = guiGridListAddRow( list )
				guiGridListSetItemText( list, row, 1, "SPAWN : "..k, false, false )
				guiGridListSetItemData( list, row, 1, k )
			end
		elseif iTab == 2 then
			for k,v in pairs(CURRENT_TRACK.markers) do
				local row = guiGridListAddRow( list )
				guiGridListSetItemText( list, row, 1, "MARKER : "..k, false, false )
				guiGridListSetItemData( list, row, 1, k )
			end
		elseif iTab == 3 then
			for k,v in pairs(CURRENT_TRACK.static_objects) do
				local row = guiGridListAddRow( list )
				guiGridListSetItemText( list, row, 1, "OBJ : "..k, false, false )
				guiGridListSetItemData( list, row, 1, k )
			end
		elseif iTab == 4 then
			for k,v in pairs(CURRENT_TRACK.dynamic_objects) do
				local row = guiGridListAddRow( list )
				guiGridListSetItemText( list, row, 1, "D-OBJ : "..k, false, false )
				guiGridListSetItemData( list, row, 1, k )
			end
		end
	end
end

function CleanupElements( iMode )
	if iMode == 1 then
		for k,v in pairs(CURRENT_TRACK.spawns) do
			destroyElement( v.temp )
		end
		CURRENT_TRACK.spawns = {}
	elseif iMode == 2 then
		for k,v in pairs(CURRENT_TRACK.markers) do
			destroyElement( v.temp )
		end
		CURRENT_TRACK.markers = {}
	elseif iMode == 3 then
		for k,v in pairs(CURRENT_TRACK.static_objects) do
			destroyElement( v.temp )
		end
		CURRENT_TRACK.static_objects = {}
	elseif iMode == 4 then
		for k,v in pairs(CURRENT_TRACK.dynamic_objects) do
			for i, obj in pairs(v) do
				destroyElement( obj.temp )
			end
		end
		CURRENT_TRACK.dynamic_objects = {}
	end
end

function UpdatePointPosition()
	local wx, wy, wz = 0,0,0
	if isCursorShowing() then
		_, _, wx, wy, wz = getCursorPosition()
	else
		wx, wy, wz = getWorldFromScreenPosition( scx/2, scy/2, 500)
	end

	hit, e_x, e_y, e_z = processLineOfSight( getCamera().position, wx, wy, wz, true, true, true, true, true, false, false, false, element )
	if not hit then
		e_x, e_y, e_z = wx, wy, wz
	end

	setElementPosition(element, e_x, e_y, e_z+z_bias)
	setElementRotation(element, e_rx, e_ry, e_rz)

	-- Draw Objects
	for k,v in pairs(CURRENT_TRACK.static_objects) do
		Draw3DText( v.x, v.y, v.z, "OBJ : "..k )
		--[[
		if isElementStreamedIn( v.temp ) and not v.fixed then
			local fixed_z = getGroundPosition( v.x, v.y, 100 )
			if fixed_z > 1 then
				v.z = fixed_z + (v.ry == 180 and 3 or 0)
				setElementPosition( v.temp, v.x, v.y, v.z )
				v.fixed = true
			else
				v.fixed = true
			end
		end
		]]
	end
	-- Draw D-Objects
	for k,v in pairs(CURRENT_TRACK.dynamic_objects) do
		for i, var in pairs(v) do
			Draw3DText( var.x, var.y, var.z, "D-OBJ : "..k.."[VAR-"..i.."]" )
		end
	end
	-- Draw Spawns
	for k,v in pairs(CURRENT_TRACK.spawns) do
		Draw3DText( v.x, v.y, v.z, "SPAWN : "..k )
	end
	-- Draw Route
	for k,v in pairs(CURRENT_TRACK.markers) do
		Draw3DText( v.x, v.y, v.z, "MARKER : "..k )

		if k > 1 then
			local pNextMarker = CURRENT_TRACK.markers[k+1]
			if pNextMarker then
				dxDrawLine3D( v.temp.position, pNextMarker.temp.position, tocolor( 30, 230, 30 ), 20 )
			end
		end
	end
end

function Draw3DText( x, y, z, text )
	local distance = getDistanceBetweenPoints3D( getCamera().position, x, y, z )
	if distance <= 300 then
		local sx, sy = getScreenFromWorldPosition( x, y, z )
		if sx and sy then
			dxDrawText( text, sx-1, sy-1, sx-1, sy-1, tocolor(0,0,0), 1, "default-bold", "center", "center" )
			dxDrawText( text, sx+1, sy+1, sx+1, sy+1, tocolor(0,0,0), 1, "default-bold", "center", "center" )
			dxDrawText( text, sx, sy, sx, sy, tocolor(255,255,255), 1, "default-bold", "center", "center" )
		end
	end
end

function KeyHandler( key, state )
	if not state then return end

	if isCursorShowing() then
		local cx, cy = getCursorPosition()
		local sx, sy = cx*scx, cy*scy
		if sx >= posX and sx <= posX+sizeX and sy >= posY and sy <= posY+sizeY then
			return
		end
	end

	if key == "mouse_wheel_down" then
		e_rz = e_rz + 1
	elseif key == "mouse_wheel_up" then
		e_rz = e_rz - 1
	elseif key == "r" then
		showCursor(not isCursorShowing())
	elseif key == "mouse1" then
		if current_mode == 1 then
			local temp_object = createVehicle( 560, e_x, e_y, e_z+z_bias, 0, 0, e_rz )
			setElementAlpha(temp_object, 200)
			setElementCollisionsEnabled( temp_object, false )
			setElementFrozen(temp_object, true)
			table.insert(CURRENT_TRACK.spawns, { x = e_x, y = e_y, z = e_z+z_bias, rz = e_rz, temp = temp_object } )
			AddAction( temp_object, "spawns", current_mode )
		elseif current_mode == 2 then
			local is_first = #CURRENT_TRACK.markers == 0 
			local temp_object = createMarker( e_x, e_y, e_z+z_bias - (is_first and 1.1 or 0), is_first and "cylinder" or "checkpoint", is_first and 3 or 20, is_first and 50 or 200, is_first and 200 or 50, 50 )
			table.insert(CURRENT_TRACK.markers, { x = e_x, y = e_y, z = e_z+z_bias - (is_first and 1.1 or 0), is_visible = true, temp = temp_object } )
			AddAction( temp_object, "markers", current_mode )
		elseif current_mode == 3 then
			local temp_object = createObject( current_model, e_x, e_y, e_z+z_bias, 0, e_ry, e_rz )
			setElementFrozen(temp_object, true)
			table.insert(CURRENT_TRACK.static_objects, { model = current_model, x = e_x, y = e_y, z = e_z+z_bias, ry = e_ry, rz = e_rz, temp = temp_object } )
			AddAction( temp_object, "static_objects", current_mode )
		elseif current_mode == 4 then
			local temp_object = createObject( current_model, e_x, e_y, e_z+z_bias, 0, 0, e_rz )
			setElementAlpha(temp_object, 150)
			setElementFrozen(temp_object, true)
			table.insert(CURRENT_TRACK.dynamic_objects, { { model = current_model, x = e_x, y = e_y, z = e_z+z_bias, rz = e_rz, temp = temp_object } } )
		end
		RefreshTab( current_mode )
	elseif key == "mouse2" then
		if current_mode == 4 then
			local last_object = CURRENT_TRACK.dynamic_objects[#CURRENT_TRACK.dynamic_objects]
			if last_object then
				local temp_object = createObject( current_model, e_x, e_y, e_z, 0, 0, e_rz )
				setElementAlpha(temp_object, 150)
				setElementFrozen(temp_object, true)
				table.insert( last_object, { model = current_model, x = e_x, y = e_y, z = e_z, rz = e_rz, temp = temp_object } )
				AddAction( temp_object, "markers", current_mode )
			else
				--iprint("ERROR 004")
			end
		elseif current_mode == 2 then
			if #CURRENT_TRACK.markers == 0 then return end
			local temp_object = createMarker( e_x, e_y, e_z+z_bias, "checkpoint", 20, 50, 50, 150, 50 )
			table.insert(CURRENT_TRACK.markers, { x = e_x, y = e_y, z = e_z+z_bias, temp = temp_object } )
			AddAction( temp_object, "markers", current_mode )
		end
	elseif key == "mouse3" then
		if current_mode == 3 then
			if e_ry == 180 then
				e_ry = 0
				z_bias = 0
			else
				e_ry = 180
				z_bias = 3
			end
		end
	elseif key == "e" then
		if current_mode == 3 then
			local last_object = CURRENT_TRACK.static_objects[ #CURRENT_TRACK.static_objects ]
			if last_object then
				local rz = -math.rad(last_object.rz-last_object.ry)
				local vecLastDirection = Vector3( math.sin(rz), math.cos(rz), 0 )*1.505
				local vecLastPosition = Vector3( last_object.x, last_object.y, last_object.z ) + vecLastDirection
				
				rz = -math.rad(e_rz-e_ry)
				local vecNextDirection =  Vector3( math.sin(rz), math.cos(rz), 0 )*1.5
				local vecNextPosition = vecLastPosition + vecNextDirection

				e_x, e_y, e_z = vecNextPosition.x, vecNextPosition.y, vecNextPosition.z

				e_z = getGroundPosition( e_x, e_y, e_z+1 ) + (e_ry == 180 and 3 or 0)

				local temp_object = createObject( current_model, e_x, e_y, e_z, 0, e_ry, e_rz )
				setElementCollisionsEnabled( temp_object, false )
				setElementFrozen(temp_object, true)
				table.insert(CURRENT_TRACK.static_objects, { model = current_model, x = e_x, y = e_y, z = e_z, ry = e_ry, rz = e_rz, temp = temp_object } )
				RefreshTab( current_mode )
				AddAction( temp_object, "static_objects", current_mode )
			end
		end
	elseif key == "q" then
		cancelEvent()
		if current_mode == 3 then
			local last_object = CURRENT_TRACK.static_objects[ #CURRENT_TRACK.static_objects ]
			if last_object then
				local rz = -math.rad(last_object.rz-last_object.ry)
				local vecLastDirection = -Vector3( math.sin(rz), math.cos(rz), 0 )*1.505
				local vecLastPosition = Vector3( last_object.x, last_object.y, last_object.z ) + vecLastDirection
				
				rz = -math.rad(e_rz-e_ry)
				local vecNextDirection =  Vector3( math.sin(rz), math.cos(rz), 0 )*1.5
				local vecNextPosition = vecLastPosition - vecNextDirection

				e_x, e_y, e_z = vecNextPosition.x, vecNextPosition.y, vecNextPosition.z

				e_z = getGroundPosition( e_x, e_y, e_z+1 ) + (e_ry == 180 and 3 or 0)

				local temp_object = createObject( current_model, e_x, e_y, e_z, 0, e_ry, e_rz )
				setElementCollisionsEnabled( temp_object, false )
				setElementFrozen(temp_object, true)
				table.insert(CURRENT_TRACK.static_objects, { model = current_model, x = e_x, y = e_y, z = e_z, ry = e_ry, rz = e_rz, temp = temp_object } )
				RefreshTab( current_mode )
				AddAction( temp_object, "static_objects", current_mode )
			end
		end
	elseif key == "z" then
		cancelEvent()
		local last_action = last_actions[#last_actions]
		if last_action then
			for k,v in pairs(CURRENT_TRACK[last_action.mode]) do
				if v.temp == last_action.element then
					destroyElement( v.temp )
					table.remove( CURRENT_TRACK[last_action.mode], k )
					RefreshTab( last_action.index )
					table.remove( last_actions, #last_actions )
				end
			end
		end
	end
end

function AddAction( element, tab_name, index )
	table.insert(last_actions, { element = element, mode = tab_name, index = index })
end

function LoadTrack( data )
	for k,v in pairs(data.markers) do
		if k == 1 then
			v.temp = createMarker( v.x, v.y, v.z-1.1, "cylinder", 3, 50, 200, 50 )
		else
			if v.is_visible then
				v.temp = createMarker( v.x, v.y, v.z, "checkpoint", 20, 200, 50, 50 )
			else
				v.temp = createMarker( v.x, v.y, v.z, "checkpoint", 20, 50, 50, 150, 50 )
			end
		end
	end

	for k,v in pairs(data.spawns) do
		v.temp = createVehicle( 560, v.x, v.y, v.z, 0, 0, v.rz )
		setElementAlpha(v.temp, 200)
		setElementCollisionsEnabled( v.temp, false )
		setElementFrozen(v.temp, true)
	end

	for k,v in pairs(data.static_objects) do
		--v.z = 0
		--v.z = v.z + (v.ry == 180 and 3 or 0)
		v.temp = createObject( v.model, v.x, v.y, v.z, 0, v.ry or 0, v.rz )
		setElementFrozen(v.temp, true)
		setElementCollisionsEnabled( v.temp, false )
	end

	for k,v in pairs(data.dynamic_objects) do
		for i, obj in pairs(v) do
			obj.temp = createObject( obj.model, obj.x, obj.y, obj.z, 0, 0, obj.rz )
			setElementFrozen(obj.temp, true)
			setElementAlpha(obj.temp, 150)
		end
	end

	CURRENT_TRACK = data

	for i = 1, 4 do
		RefreshTab(i)
	end
end

function OnTrackDataReceived( data )
	LoadTrack( data )
end
addEvent("TC:OnTrackDataReceived", true)
addEventHandler("TC:OnTrackDataReceived", root, OnTrackDataReceived)