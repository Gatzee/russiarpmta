pTabs[TAB_EVENTS] = {
	title = "Events",
	parent = false,
	disabled = false,
	access_level = ACCESS_LEVEL_GAME_MASTER,
	content = function( self )
		local parent = self.parent

		local sx, sy = parent:getSize( false )

		self.tab_events = guiCreateTabPanel( 0, 0, sx, sy, false, parent )
		self.tabs = { }
		for i, tab in pairs( EVENTS_TABS ) do
			local parent = guiCreateTab( tab.title, self.tab_events )
			self.tabs[ tab.key ] = { tab = parent }
			tab.content( self.tabs[ tab.key ], parent )
		end
	end,
}

local function UpdatePlayerGridlists( old_event_players )
	for i, tab in pairs( pTabs[ TAB_EVENTS ].tabs ) do
		if tab.UpdatePlayerGridlist then
			tab.UpdatePlayerGridlist( old_event_players )
		end
	end
end

EVENT_PLAYERS = { }
EVENT_PLAYERS_REWARDS_SUM = { }
EVENT_GIVEN_REWARDS_SUM = 0
EVENT_VEHICLES = { }

EVENTS_TABS = {
	{
		key = "tab_start",
		title = "Events Start",
		content = function( self, parent )
			local sx, sy = parent:getSize( false )
	
			guiCreateLabel( 20, 20, 360, 25, "Название ивента: ", false, parent )
			self.edit_event_name = guiCreateEdit( 20, 45, 250, 25, "", false, parent )
			self.edit_event_name.maxLength = 20
	
			guiCreateLabel( 20, 90, 360, 25, "Количество игроков: ", false, parent )
			self.edit_player_count = guiCreateEdit( 20, 115, 250, 25, "", false, parent )
			self.edit_player_count.maxLength = 3
			self.edit_player_count:setProperty( "ValidationString", "^[0-9]*$")
	
			guiCreateLabel( 20, 160, 360, 25, "Время работы телепорта (в секундах): ", false, parent )
			self.edit_teleport_enabled_duration = guiCreateEdit( 20, 185, 250, 25, "", false, parent )
			self.edit_teleport_enabled_duration.maxLength = 3
			self.edit_teleport_enabled_duration:setProperty( "ValidationString", "^[0-9]*$")
				
			self.btn_start_event = guiCreateButton( 20, 230, 250, 35, "Начать ивент", false, parent )
			self.btn_stop_event = guiCreateButton( 20, 270, 250, 35, "Завершить ивент", false, parent )

			self.btn_hp_player 		 = guiCreateButton( 20, 310, 250, 35, "Здоровье", false, parent )
			self.btn_armour_player   = guiCreateButton( 20, 350, 250, 35, "Броня", false, parent )
			self.btn_calories_player = guiCreateButton( 20, 390, 250, 35, "Еда", false, parent )
			self.btn_frozen_player   = guiCreateButton( 20, 430, 250, 35, "Заморозить", false, parent )
			self.btn_unfrozen_player = guiCreateButton( 20, 470, 250, 35, "Разморозить", false, parent )

			self.list_players = guiCreateGridList( 290, 20, sx - 310, sy - 100, false, parent )
			self.list_players.sortingEnabled = false
			self.list_players.selectionMode = 1
			self.list_players:addColumn( "№", 0.12 ) 
			self.list_players:addColumn( "userID", 0.3 ) 
			self.list_players:addColumn( "Имя", 0.5 )
			guiCreateLabel( 560, sy - 80, 360, 25, "Ctrl + ЛКМ чтобы выделить сразу несколько", false, parent ).font = "default-small"

			self.UpdatePlayerGridlist = function( old_event_players )
				local players_selected = { }
				for i, item in pairs ( self.list_players.selectedItems ) do
					local player = old_event_players[ item.row + 1 ] or false
					players_selected[ player ] = true
				end

				self.list_players:clear( )

				for i, player in pairs( EVENT_PLAYERS ) do
					if isElement( player ) then
						local row = self.list_players:addRow( i, player:GetUserID( ), player:GetNickName( ) )
						if players_selected[ player ] then
							self.list_players:setSelectedItem( row, 1, false )
						end
					end
				end
			end

			self.btn_remove = guiCreateButton( 290, sy - 60, 120, 40, "Убрать из ивента", false, parent )
			self.btn_refresh = guiCreateButton( sx - 368, sy - 60, 120, 40, "Обновить список", false, parent )

			self.btn_clear_select = guiCreateButton( sx - 244, sy - 60, 120, 40, "Убрать выделение", false, parent )
			self.btn_select_all = guiCreateButton( sx - 120, sy - 60, 100, 40, "Выделить все", false, parent )

			self.GetSelectedPlayers = function( self )
				local selected_players = { }
				for i, item in pairs( self.list_players.selectedItems ) do
					if item.column == 0 then
						local player = EVENT_PLAYERS[ item.row + 1 ]
						table.insert( selected_players, player )
					end
				end
				return selected_players
			end

			addEventHandler( "onClientGUIClick", parent, function( key )
				if key ~= "left" then return end

				if source == self.btn_start_event then
					local name = self.edit_event_name.text
					if name == "" then
						localPlayer:ShowError( "Введите название ивента" )
						return
					end
					local max_player_count = tonumber( self.edit_player_count.text )
					if not max_player_count or max_player_count < 1 then
						localPlayer:ShowError( "Введите количество игроков" )
						return
					end
					local teleport_enabled_duration = tonumber( self.edit_teleport_enabled_duration.text )
					if not teleport_enabled_duration then
						localPlayer:ShowError( "Введите время работы телепорта" )
						return
					elseif teleport_enabled_duration < 0 or teleport_enabled_duration > 180 then
						localPlayer:ShowError( "Введите корректное время работы телепорта (макс. 180 с)" )
						return
					end
					tryTriggerServerEvent( "AP:StartAdminEvent", localPlayer, name, max_player_count, teleport_enabled_duration )

				elseif source == self.btn_stop_event then
					ShowUI( false )
					local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 80, "Вы уверены, что хотите завершить ивент?", false )
					local btn_accept = guiCreateButton( 40, 30, 90, 40, "Подтвердить", false, window )
					local btn_cancel = guiCreateButton( 160, 30, 90, 40, "ОТМЕНА", false, window )

					addEventHandler( "onClientGUIClick", window, function( )
						if source == btn_accept then
							if tryTriggerServerEvent( "AP:StopAdminEvent", localPlayer, name ) then
								self.btn_stop_event.enabled = false
								onAdminEventStop_handler( )
							end
							destroyElement( window )
							ShowUI( true )
						elseif source == btn_cancel then
							destroyElement( window )
							ShowUI( true )
						end
					end )

				elseif source == self.btn_clear_select then
					self.list_players:setSelectedItem( 0, 0 )

				elseif source == self.btn_select_all then
					for i = 0, self.list_players.rowCount - 1 do
						self.list_players:setSelectedItem( i, 1, false )
					end

				elseif source == self.btn_remove then
					local players_selected = { }
					local selected_players = { }
					for i, item in pairs( self.list_players.selectedItems ) do
						if item.column == 0 then
							local player = EVENT_PLAYERS[ item.row + 1 ]
							table.insert( selected_players, player )
							players_selected[ player ] = true
						end
					end
					if not next( selected_players ) then return end
					
					if tryTriggerServerEvent( "AP:RemovePlayersFromEvent", localPlayer, selected_players ) then
						local old_event_players = table.copy( EVENT_PLAYERS )
						for i = #EVENT_PLAYERS, 1, -1 do
							local player = EVENT_PLAYERS[ i ]
							if players_selected[ player ] then
								table.remove( EVENT_PLAYERS, i )
								removeEventHandler( "onClientPlayerWasted", player, onPlayerLeaveEvent )
								removeEventHandler( "onClientPlayerQuit", player, onPlayerLeaveEvent )
							end
						end
						UpdatePlayerGridlists( old_event_players )
					end
				elseif source == self.btn_refresh then
					UpdatePlayerGridlists( EVENT_PLAYERS )
				elseif source == self.btn_hp_player then
					local selected_players = self:GetSelectedPlayers()
					if not next( selected_players ) then return end

					local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 150, "Введите уровень здоровья для игроков:", false )
					local edf_value = guiCreateEdit( 40, 50, 210, 35, "0-100", false, window )
					local btn_accept = guiCreateButton( 40, 115, 90, 25, "Подтвердить", false, window )
					local btn_cancel = guiCreateButton( 160, 115, 90, 25, "Отмена", false, window )

					addEventHandler( "onClientGUIClick", window, function( )
						if source == btn_accept then
							local value = tonumber( guiGetText( edf_value ) )
							if not value then return end

							tryTriggerServerEvent( "AP:SetEventPlayerHealth", localPlayer, selected_players, value )
							destroyElement( window )
							ShowUI( true )
						elseif source == btn_cancel then
							destroyElement( window )
							ShowUI( true )
						end
					end )

					
				elseif source == self.btn_armour_player then
					local selected_players = self:GetSelectedPlayers()
					if not next( selected_players ) then return end

					local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 150, "Введите уровень брони для игроков:", false )
					local edf_value = guiCreateEdit( 40, 50, 210, 35, "0-100", false, window )
					local btn_accept = guiCreateButton( 40, 115, 90, 25, "Подтвердить", false, window )
					local btn_cancel = guiCreateButton( 160, 115, 90, 25, "Отмена", false, window )

					addEventHandler( "onClientGUIClick", window, function( )
						if source == btn_accept then
							local value = tonumber( guiGetText( edf_value ) )
							if not value then return end

							tryTriggerServerEvent( "AP:SetEventPlayerArmour", localPlayer, selected_players, value )
							destroyElement( window )
							ShowUI( true )
						elseif source == btn_cancel then
							destroyElement( window )
							ShowUI( true )
						end
					end )
				elseif source == self.btn_calories_player then
					local selected_players = self:GetSelectedPlayers()
					if not next( selected_players ) then return end

					local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 150, "Введите уровень калорий для игроков:", false )
					local edf_value = guiCreateEdit( 40, 50, 210, 35, "0-100", false, window )
					local btn_accept = guiCreateButton( 40, 115, 90, 25, "Подтвердить", false, window )
					local btn_cancel = guiCreateButton( 160, 115, 90, 25, "Отмена", false, window )

					addEventHandler( "onClientGUIClick", window, function( )
						if source == btn_accept then
							local value = tonumber( guiGetText( edf_value ) )
							if not value then return end

							tryTriggerServerEvent( "AP:SetEventPlayerCalories", localPlayer, selected_players, value )
							destroyElement( window )
							ShowUI( true )
						elseif source == btn_cancel then
							destroyElement( window )
							ShowUI( true )
						end
					end )
				elseif source == self.btn_frozen_player then
					local selected_players = self:GetSelectedPlayers()
					if not next( selected_players ) then return end

					local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 100, "Вы уверены что хотите заморозить игроков?", false )
					local btn_accept = guiCreateButton( 40, 45, 90, 25, "Подтвердить", false, window )
					local btn_cancel = guiCreateButton( 160, 45, 90, 25, "Отмена", false, window )

					addEventHandler( "onClientGUIClick", window, function( )
						if source == btn_accept then
							tryTriggerServerEvent( "AP:SetEventPlayerFrozen", localPlayer, selected_players, true )
							destroyElement( window )
							ShowUI( true )
						elseif source == btn_cancel then
							destroyElement( window )
							ShowUI( true )
						end
					end )
				elseif source == self.btn_unfrozen_player then
					local selected_players = self:GetSelectedPlayers()
					if not next( selected_players ) then return end

					local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 100, "Вы уверены что хотите разморозить игроков?", false )
					local btn_accept = guiCreateButton( 40, 45, 90, 25, "Подтвердить", false, window )
					local btn_cancel = guiCreateButton( 160, 45, 90, 25, "Отмена", false, window )

					addEventHandler( "onClientGUIClick", window, function( )
						if source == btn_accept then
							tryTriggerServerEvent( "AP:SetEventPlayerFrozen", localPlayer, selected_players, false )
							destroyElement( window )
							ShowUI( true )
						elseif source == btn_cancel then
							destroyElement( window )
							ShowUI( true )
						end
					end )
				end
			end )
		end,
	},

	{
		key = "tab_inventory",
		title = "Events Inventory",
		content = function( self, parent )
			local sx, sy = parent:getSize( false )
	
			local skins_panel = guiCreateTabPanel( 20, 20, 250, 80, false, parent )
			local skins_panel = guiCreateTab( "Скины", skins_panel )
			guiCreateLabel( 10, 15, 360, 25, "ID скина:", false, skins_panel )
			self.edit_skin_id = guiCreateEdit( 75, 13, 85, 25, "", false, skins_panel )
			self.edit_skin_id.maxLength = 4
			self.edit_skin_id:setProperty( "ValidationString", "^[0-9]*$")
			self.btn_set_skin = guiCreateButton( 170, 13, 70, 25, "Выдать", false, skins_panel )
	
			local inventory_panel = guiCreateTabPanel( 20, 120, 250, 324, false, parent )
			local inventory_panel = guiCreateTab( "Инвентарь", inventory_panel )
			guiCreateLabel( 10, 15, 300, 25, "Оружие:", false, inventory_panel )
			self.list_weapons = guiCreateComboBox( 75, 12, 165, 260, "", false, inventory_panel )
			
			local accepted_weapons = {
				{ "Кастет", 1 },
				{ "Клюшка", 2 },
				{ "Дубинка", 3 },
				{ "Нож", 4 },
				{ "Бита", 5 },
				{ "Лопата", 6 },
				{ "Кий", 7 },
				{ "Катана", 8 },
				{ "Бензопила", 9 },
				{ "Кольт 45", 22 },
				{ "Тайзер", 23 },
				{ "Дигл", 24 },
				{ "Дробовик", 25 },
				{ "Обрез", 26 },
				{ "Помповый дробовик", 27 },
				{ "Узи", 28 },
				{ "МП5", 29 },
				{ "Тек-9", 32 },
				{ "АК-47", 30 },
				{ "М4", 31 },
				{ "Ружье", 33 },
				{ "Снайп.винтовка", 34 },
				{ "РПГ", 35 },
				{ "Ракетница", 36 },
				{ "Миниган", 38 },
				{ "Граната", 16 },
				{ "Граната слезоточивая", 17 },
				{ "Граната ранец", 39 },
				{ "Детонатор г. ранец", 40 },
				{ "Дефибриллятор", 10 },
				{ "Дилдо 2", 11 },
				{ "Жезл", 12 },
				{ "Цветы", 14 },
				{ "Топор", 15 },
				{ "Ночное виденье", 44 },
				{ "Инфракрасное", 45 },
				{ "Парашют", 46 },
				{ "Камера", 43 },
				{ "Баллончик", 41 },
				{ "Огнетушитель", 42 },
			}
			for k, v in pairs( accepted_weapons ) do
				self.list_weapons:addItem( v[ 1 ] ) 
			end
			self.list_weapons.selected = 0

			guiCreateLabel( 10, 45, 300, 25, "Патроны:", false, inventory_panel )
			self.edit_ammo = guiCreateEdit( 75, 43, 85, 25, "", false, inventory_panel )
			self.edit_ammo.maxLength = 4
			self.edit_ammo:setProperty( "ValidationString", "^[0-9]*$")
			self.btn_give_wepon = guiCreateButton( 170, 43, 70, 25, "Выдать", false, inventory_panel )

			self.list_players = guiCreateGridList( 290, 20, sx - 310, sy - 100, false, parent )
			self.list_players.sortingEnabled = false
			self.list_players.selectionMode = 1
			self.list_players:addColumn( "№", 0.12 ) 
			self.list_players:addColumn( "userID", 0.3 ) 
			self.list_players:addColumn( "Имя", 0.5 )
			guiCreateLabel( 560, sy - 80, 360, 25, "Ctrl + ЛКМ чтобы выделить сразу несколько", false, parent ).font = "default-small"

			self.UpdatePlayerGridlist = function( old_event_players )
				local players_selected = { }
				for i, item in pairs ( self.list_players.selectedItems ) do
					local player = old_event_players[ item.row + 1 ] or false
					players_selected[ player ] = true
				end

				self.list_players:clear( )

				for i, player in pairs( EVENT_PLAYERS ) do
					if isElement( player ) then
						local row = self.list_players:addRow( i, player:GetUserID( ), player:GetNickName( ) )
						if players_selected[ player ] then
							self.list_players:setSelectedItem( row, 1, false )
						end
					end
				end
			end

			self.btn_clear_select = guiCreateButton( sx - 260, sy - 60, 120, 40, "Убрать выделение", false, parent )
			self.btn_select_all = guiCreateButton( sx - 120, sy - 60, 100, 40, "Выделить макс.", false, parent )

			local function GetSelectedPlayers( )
				local selected_players = { }
				for i, item in pairs( self.list_players.selectedItems ) do
					if item.column == 0 then
						table.insert( selected_players, EVENT_PLAYERS[ item.row + 1 ] )
					end
				end
				if not next( selected_players ) then
					localPlayer:ShowError( "Выберите в списке игроков" )
					return false
				end
				return selected_players
			end

			addEventHandler( "onClientGUIClick", parent, function( key )
				if key ~= "left" then return end

				if source == self.btn_clear_select then
					self.list_players:setSelectedItem( 0, 0 )

				elseif source == self.btn_select_all then
					for i = 0, math.min( 10, self.list_players.rowCount - 1 ) do
						self.list_players:setSelectedItem( i, 1, false )
					end

				elseif source == self.btn_set_skin then
					local skin_id = tonumber( self.edit_skin_id.text )
					if not skin_id then
						localPlayer:ShowError( "Введите ID скина" )
						return
					end
					local selected_players = GetSelectedPlayers( )
					if not selected_players then return end
					tryTriggerServerEvent( "AP:GiveItemToPlayers", localPlayer, selected_players, "skin", skin_id )

				elseif source == self.btn_give_wepon then
					local weapon_id = accepted_weapons[ self.list_weapons.selected + 1 ][ 2 ]
					if not weapon_id then
						localPlayer:ShowError( "Выберите оружие из списка" )
						return
					end
					local ammo = tonumber( self.edit_ammo.text )
					if not ammo or ammo < 0 then
						localPlayer:ShowError( "Введите количество патронов" )
						return
					end
					local selected_players = GetSelectedPlayers( )
					if not selected_players then return end
					tryTriggerServerEvent( "AP:GiveItemToPlayers", localPlayer, selected_players, "weapon", { weapon_id, ammo } )

				end
			end )
		end,
	},

	{
		key = "tab_vehicles",
		title = "Events Vehicles",
		content = function( self, parent )
			local sx, sy = parent:getSize( false )
	
			local panel = GuiTab( "Список машин для спавна", GuiTabPanel( 19, 15, sx / 2-38, sy - 30, false, parent ) )
			self.veh_list = guiCreateGridList( 1, 1, sx / 2 - 40, sy - 150, false, panel )
			self.veh_list.selectionMode = 1
			self.veh_list:addColumn( "ID", 0.17 ) 
			self.veh_list:addColumn( "Название", 0.7 )

			local vehicle_ids_to_names = { }
			for id, data in pairs( VEHICLE_CONFIG ) do
				vehicle_ids_to_names[ id ] = data.model
			end
			vehicle_ids_to_names[ 432 ] = "Танк"
			vehicle_ids_to_names[ 407 ] = "Пожарная"
			vehicle_ids_to_names[ 601 ] = "SWAT"
			vehicle_ids_to_names[ 428 ] = "Инкассация"
			vehicle_ids_to_names[ 453 ] = "Pershing 50"
			vehicle_ids_to_names[ 472 ] = "SpeedBoat Noname"
			vehicle_ids_to_names[ 430 ] = "Sports FishingBoat"

			for id, name in pairs( vehicle_ids_to_names ) do
				local row = self.veh_list:addRow( )
				-- self.veh_list:setItemText( row, 1, row, false, false )
				self.veh_list:setItemText( row, 1, id, false, true )
				self.veh_list:setItemText( row, 2, name, false, false )
			end

			-- self.btn_clear_select = guiCreateButton( sx - 260, sy - 50, 120, 30, "Убрать выделение", false, parent )
			-- self.btn_select_all = guiCreateButton( sx - 120, sy - 50, 100, 30, "Выделить все", false, parent )

			guiCreateLabel( 20, sy - 135, 300, 20, "ID:", false, panel )
			self.edit_veh_ids = guiCreateEdit( 80, sy - 138, 250, 20, "", false, panel )
			self.edit_veh_ids:setProperty( "ValidationString", "^[0-9,]*$")

			local accepted_colors = {
				{ "Aqua", { 000, 255, 255 } },
				{ "Black", { 000, 000, 000 } },
				{ "Blue", { 000, 000, 255 } },
				{ "Fuchsia", { 255, 000, 255 } },
				{ "Gray", { 128, 128, 128 } },
				{ "Green", { 000, 128, 000 } },
				{ "Lime", { 000, 255, 000 } },
				{ "Maroon", { 128, 000, 000 } },
				{ "Navy", { 000, 000, 128 } },
				{ "Olive", { 128, 128, 000 } },
				{ "Purple", { 128, 000, 128 } },
				{ "Red", { 255, 000, 000 } },
				{ "Silver", { 192, 192, 192 } },
				{ "Teal", { 000, 128, 128 } },
				{ "White", { 255, 255, 255 } },
				{ "Yellow", { 255, 255, 000 } },
			}
			guiCreateLabel( 20, sy - 110, 300, 25, "Цвет:", false, panel )
			self.list_colors = guiCreateComboBox( 80, sy - 114, 120, 200, "", false, panel )
			self.list_colors:setProperty( "ClippedByParent", "False" )
			for i, color in pairs( accepted_colors ) do
				self.list_colors:addItem( color[ 1 ] )
			end

			guiCreateLabel( 20, sy - 85, 300, 20, "Кол-во:", false, panel )
			self.edit_veh_count = guiCreateEdit( 80, sy - 88, 120, 20, "1", false, panel )
			self.edit_veh_count.maxLength = 2
			self.edit_veh_count:setProperty( "ValidationString", "^[0-9]*$")

			self.btn_spawn_veh = guiCreateButton( sx / 2 - 180, sy - 90, 120, 30, "Заспавнить", false, panel )

			addEventHandler( "onClientGUIClick", parent, function( key )
				if key ~= "left" then return end

				if source == self.veh_list then
					local ids = { }
					for i, item in pairs( self.veh_list.selectedItems ) do
						if item.column == 0 then
							table.insert( ids, self.veh_list:getItemText( item.row, 1 ) )
						end
					end
					self.edit_veh_ids.text = table.concat( ids, "," )

				elseif source == self.btn_spawn_veh then
					local selected_ids = fromJSON( "[[" .. self.edit_veh_ids.text .. "]]" )
					if not selected_ids or #selected_ids == 0 then
						localPlayer:ShowError( "Введите ID транспорта или выберите из списка" )
						return
					end
					for i, id in pairs( selected_ids ) do
						if not vehicle_ids_to_names[ id ] or not next( engineGetModelTextureNames( id ) ) then
							localPlayer:ShowError( "Введите корректные ID транспорта" )
							return
						end
					end
					if #selected_ids > 10 then
						localPlayer:ShowError( "Максимум 10 ID транспорта" )
						return
					end
					local color = accepted_colors[ self.list_colors.selected + 1 ]
					if not color then
						localPlayer:ShowError( "Выберите цвет" )
						return
					end
					local count = tonumber( self.edit_veh_count.text )
					if not count or count == 0 then
						localPlayer:ShowError( "Введите количество" )
						return
					elseif #selected_ids * count > 10 then
						localPlayer:ShowError( "Вы не можете создать за раз больше 10 ТС" )
						return
					end
					tryTriggerServerEvent( "AP:CreateEventVehicles", localPlayer, selected_ids, count, unpack( color[ 2 ] ) )
				end
			end )
	
			local panel = GuiTab( "Заспавненные машины", GuiTabPanel( sx / 2 + 20, 15, sx / 2 - 38, sy - 30, false, parent ) )
			self.spawned_veh_list = guiCreateGridList( 1, 1, sx / 2 - 40, sy - 150, false, panel )
			self.spawned_veh_list.sortingEnabled = false
			self.spawned_veh_list.selectionMode = 1
			-- self.spawned_veh_list:addColumn( "№", 0.12 ) 
			self.spawned_veh_list:addColumn( "ID", 0.17 )  
			self.spawned_veh_list:addColumn( "sID", 0.17 )
			self.spawned_veh_list:addColumn( "Название", 0.53 )

			self.UpdateSpawnedVehiclesGridlist = function( old_event_vehicles )
				local vehicles_selected = { }
				for i, item in pairs ( self.spawned_veh_list.selectedItems ) do
					local vehicle = old_event_vehicles[ item.row + 1 ] or false
					if vehicle then
						vehicles_selected[ vehicle ] = true
					end
				end

				self.spawned_veh_list:clear( )

				for i, vehicle in pairs( EVENT_VEHICLES ) do
					if isElement( vehicle ) then
						local row = self.spawned_veh_list:addRow( vehicle.model, vehicle:GetID(), vehicle_ids_to_names[ vehicle.model ] )
						if vehicles_selected[ vehicle ] then
							self.spawned_veh_list:setSelectedItem( row, 1, false )
						end
					end
				end
			end

			self.btn_select_all_veh = guiCreateButton( sx / 2 - 180, sy - 140, 120, 30, "Выбрать все", false, panel )
			self.btn_clear_select = guiCreateButton( sx / 2 - 310, sy - 140, 120, 30, "Убрать выделение", false, panel )
			self.btn_delete_veh = guiCreateButton( sx / 2 - 180, sy - 90, 120, 30, "Удалить", false, panel )

			addEventHandler( "onClientGUIClick", parent, function( key )
				if key ~= "left" then return end

				if source == self.btn_clear_select then
					self.spawned_veh_list:setSelectedItem( 0, 0 )

				elseif source == self.btn_select_all_veh then
					for i = 0, self.spawned_veh_list.rowCount - 1 do
						self.spawned_veh_list:setSelectedItem( i, 1, false )
					end

				elseif source == self.btn_delete_veh then
					local selected_vehs = { }
					for i, item in pairs( self.spawned_veh_list.selectedItems ) do
						if item.column == 0 then
							table.insert( selected_vehs, EVENT_VEHICLES[ item.row + 1 ] )
						end
					end
					if not next( selected_vehs ) then
						localPlayer:ShowError( "Выберите необходимые машины из списка" )
						return
					end
					tryTriggerServerEvent( "AP:DestroyEventVehicles", localPlayer, selected_vehs )
				end
			end )
		end,
	},

	{
		key = "tab_rewards",
		title = "Events Rewards",
		content = function( self, parent )
			local sx, sy = parent:getSize( false )
			local list_sx = 520
			local list_px = sx / 2 - list_sx / 2

			guiCreateLabel( list_px, 20, 300, 20, "Поиск по нику:", false, parent )
			self.edit_search = guiCreateEdit( list_px + 100, 17, list_sx - 100, 20, "", false, parent )

			local list_bg = guiCreateGridList( list_px, 45, list_sx, sy - 110, false, parent )
			list_bg:addColumn( "", 0.95 )

			local columns = { 
				{ name = "№", 		px = 25 },
				{ name = "userID", 	px = 70 },
				{ name = "Имя", 	px = 170 },
				{ name = "Награда", px = 400 },
			}
			for i, col_data in pairs( columns ) do
				guiCreateLabel( 10 + col_data.px, 4, 300, 20, col_data.name, false, list_bg ).alpha = 0.5
			end

			local scrollpane
			local reward_edits = { }
			local position_edits = { }
			local checkboxes = { }
			local row_parents = { }
			local row_h = 30

			self.UpdatePlayerGridlist = function( old_event_players )
				local players_selected = { }
				for i, checkbox in pairs ( checkboxes ) do
					if checkbox.selected then
						local player = old_event_players[ i ] or false
						players_selected[ player ] = true
					end
				end
				
				local player_rewards = { }
				for i, edit in pairs ( reward_edits ) do
					local player = old_event_players[ i ] or false
					player_rewards[ player ] = edit.text
				end
				
				local player_positions = { }
				for i, edit in pairs ( position_edits ) do
					local player = old_event_players[ i ] or false
					player_positions[ player ] = edit.text
				end

				if scrollpane then
					scrollpane:destroy( )
					reward_edits = { }
					position_edits = { }
					checkboxes = { }
					row_parents = { }
				end
				scrollpane = guiCreateScrollPane( 10, 24, list_sx - 10, sy - 135, false, list_bg )
				scrollpane:setProperty( "VertStepSize", 0.1 )

				local search_str = self.edit_search.text
				local y = 0
				for i, player in pairs( EVENT_PLAYERS ) do
					local nickname = isElement( player ) and player:GetNickName( )
					if nickname and ( search_str == "" or utf8.find( utf8.lower( nickname ), utf8.lower( search_str ), 1, true ) ) then
						local row_parent = guiCreateCheckBox( 0, y + 5, list_sx - 30, 20, "", false, false, scrollpane )
						row_parent:setProperty( "ZOrderChangeEnabled", "False" )
						row_parents[ i ] = row_parent
						checkboxes[ i ] = row_parent
						if players_selected[ player ] then
							row_parent.selected = true
						end
		
						local col = 1
						position_edits[ i ] = guiCreateEdit( columns[ col ].px, -3, 35, 20, player_positions[ player ] or "", false, row_parent )
						position_edits[ i ].maxLength = 2
						position_edits[ i ]:setProperty( "ValidationString", "^[0-9]*$")
		
						col = col + 1
						guiCreateLabel( columns[ col ].px, 0, 200, 20, player:GetUserID( ), false, row_parent ).enabled = false
		
						col = col + 1
						guiCreateLabel( columns[ col ].px, 0, 190, 20, player:GetNickName( ), false, row_parent ).enabled = false
		
						col = col + 1
						reward_edits[ i ] = guiCreateEdit( columns[ col ].px, -3, 80, 20, player_rewards[ player ] or "0", false, row_parent )
						reward_edits[ i ].maxLength = 6
						reward_edits[ i ]:setProperty( "ValidationString", "^[0-9]*$")
		
						y = y + row_h
					end
				end
			end

			addEventHandler( "onClientGUIChanged", self.edit_search, function( )
				local search_str = self.edit_search.text

				local y = 0
				for i, player in pairs( EVENT_PLAYERS ) do
					local nickname = isElement( player ) and player:GetNickName( )
					local row_parent = row_parents[ i ]
					if nickname and ( search_str == "" or utf8.find( utf8.lower( nickname ), utf8.lower( search_str ), 1, true ) ) then
						row_parent.visible = true
						row_parent:setPosition( 0, y, false )
						y = y + row_h
					else
						row_parent.visible = false
						row_parent:setPosition( 0, 0, false )
					end
				end
			end, false )

			self.btn_clear_select = guiCreateButton( 20, sy - 50, 120, 30, "Убрать выделение", false, parent )
			self.btn_select_all = guiCreateButton( 150, sy - 50, 130, 30, "Выделить максимум", false, parent )

			self.btn_reward = guiCreateButton( sx - 290, sy - 50, 130, 30, "Выдать награду", false, parent )
			self.btn_remove_players = guiCreateButton( sx - 150, sy - 50, 130, 30, "Убрать игроков из ивента", false, parent )

			addEventHandler( "onClientGUIClick", parent, function( key )
				if key ~= "left" then return end

				if source == self.btn_clear_select then
					for i, checkbox in pairs( checkboxes ) do
						checkbox.selected = false
					end

				elseif source == self.btn_select_all then
					for i = 1, 10 do
						if checkboxes[ i ] then
							checkboxes[ i ].selected = true
						end
					end

				elseif source == self.btn_reward then
					local count = 0
					local players_rewards = { }
					for i, checkbox in pairs ( checkboxes ) do
						local player = EVENT_PLAYERS[ i ]
						if not isElement( player ) then
							RemovePlayerFromList( player )
							localPlayer:ShowError( "Неизвестная ошибка, попробуйте ещё раз" )
							return
						end
						if checkbox.selected then
							local position = tonumber( position_edits[ i ].text )
							if not position then
								localPlayer:ShowError( "Введите занятую позицию для игрока " .. player:GetNickName( ) )
								return
							elseif position <= 0 or position > 10 then
								localPlayer:ShowError( "Занятая позиция должна быть от 1 до 10" )
								return
							end

							local reward = tonumber( reward_edits[ i ].text )
							if not reward or reward <= 0 then
								localPlayer:ShowError( "Введите сумму награды для игрока " .. player:GetNickName( ) )
								return
							elseif reward > CONST_MAX_PLAYER_REWARD then
								localPlayer:ShowError( "Размер награды должен быть не больше " .. CONST_MAX_PLAYER_REWARD )
								return
							end
							players_rewards[ player ] = { reward = reward, position = position }
							count = count + 1
						end
					end
					if not next( players_rewards ) then
						localPlayer:ShowError( "Отметьте в списке игроков, которым вы хотите выдать награду" )
						return
					end
					
					tryTriggerServerEvent( "AP:RewardPlayers", localPlayer, players_rewards )

				elseif source == self.btn_remove_players then
					if not next( EVENT_PLAYERS ) then return end
					
					if tryTriggerServerEvent( "AP:RemovePlayersFromEvent", localPlayer ) then
						local old_event_players = table.copy( EVENT_PLAYERS )
						for i = #EVENT_PLAYERS, 1, -1 do
							local player = EVENT_PLAYERS[ i ]
							removeEventHandler( "onClientPlayerWasted", player, onPlayerLeaveEvent )
							removeEventHandler( "onClientPlayerQuit", player, onPlayerLeaveEvent )
						end
						EVENT_PLAYERS = { }
						UpdatePlayerGridlists( old_event_players )
					end
				end
			end )
		end,
	},

	{
		key = "tab_fc",
		title = "Бойцовский клуб",
		content = function( self, parent )
			self.restart = guiCreateButton( 20, 40, 200, 50, "Перезапуск турнира", false, parent )

			addEventHandler( "onClientGUIClick", parent, function( key )
				if key ~= "left" then return end

				if source == self.restart then
					tryTriggerServerEvent( "FC:OnTournamentForceRestartRequest", localPlayer )
				end
			end )
		end,
	},
}

function onEventStart( )
	EVENT_PLAYERS = { }
	EVENT_VEHICLES = { }
	pTabs[ TAB_EVENTS ].tabs.tab_start.btn_stop_event.enabled = true
end
addEvent( "AP:onEventStart", true )
addEventHandler( "AP:onEventStart", root, onEventStart )

function onAdminEventStop_handler( )
	EVENT_PLAYERS = { }
	EVENT_VEHICLES = { }
	UpdatePlayerGridlists( { } )
	pTabs[ TAB_EVENTS ].tabs.tab_vehicles.spawned_veh_list:clear( )
end

function onPlayerJoinEvent( )
	-- if source == localPlayer then return end

	local old_event_players = table.copy( EVENT_PLAYERS )
	table.insert( EVENT_PLAYERS, source )
	addEventHandler( "onClientPlayerWasted", source, onPlayerLeaveEvent )
	addEventHandler( "onClientPlayerQuit", source, onPlayerLeaveEvent )
	UpdatePlayerGridlists( old_event_players )
end
addEvent( "AP:onPlayerJoinEvent", true )
addEventHandler( "AP:onPlayerJoinEvent", root, onPlayerJoinEvent )

function RemovePlayerFromList( removing_player )
	local old_event_players = table.copy( EVENT_PLAYERS )
	for i, player in pairs( EVENT_PLAYERS ) do
		if player == removing_player then
			table.remove( EVENT_PLAYERS, i )
			break
		end
	end
	UpdatePlayerGridlists( old_event_players )
end

function onPlayerLeaveEvent( )
	RemovePlayerFromList( source )
	removeEventHandler( "onClientPlayerQuit", source, onPlayerLeaveEvent )
end
addEvent( "AP:onPlayerLeaveEvent", true )
addEventHandler( "AP:onPlayerLeaveEvent", root, onPlayerLeaveEvent )

function onEventVehiclesChange( new_vehicles )
	local old_event_vehicles = table.copy( EVENT_VEHICLES )
	if new_vehicles then
		for i, vehicle in pairs( new_vehicles ) do
			table.insert( EVENT_VEHICLES, vehicle )
		end
	else
		for i = #EVENT_VEHICLES, 1, -1 do
			if not isElement( EVENT_VEHICLES[ i ] ) then
				table.remove( EVENT_VEHICLES, i )
			end
		end
	end
	pTabs[ TAB_EVENTS ].tabs.tab_vehicles.UpdateSpawnedVehiclesGridlist( old_event_vehicles )
end
addEvent( "AP:onEventVehiclesChange", true )
addEventHandler( "AP:onEventVehiclesChange", root, onEventVehiclesChange )


