pTabs[ TAB_BANLIST_SERIAL ] = {
	title = "Banlist Serial",
	parent = false,
	access_level = ACCESS_LEVEL_SUPERVISOR,
	acl_only = false,
	content = function( self )
		local parent = self.parent
        self.label = guiCreateLabel( 20, 20, 130, 25, "Поиск по серийному: ", false, parent )
        guiLabelSetVerticalAlign( self.label, "center" )
        self.edit_serach = guiCreateEdit( 160, 20, 250, 25, "", false, parent )

		self.btn_serach = guiCreateButton( 430, 18, 100, 29, "Найти", false, parent )
		self.btn_update = guiCreateButton( 550, 18, 110, 29, "Обновить", false, parent )
		self.btn_clear = guiCreateButton( 680, 18, 110, 29, "Очистить поля", false, parent )

		self.label = guiCreateLabel( 20, 60, 120, 25, "Бан по серийному: ", false, parent )
        guiLabelSetVerticalAlign( self.label, "center" )
		self.edit_ban = guiCreateEdit( 160, 60, 250, 25, "", false, parent )
		
		self.btn_ban = guiCreateButton( 430, 58, 100, 29, "Заблокировать", false, parent )
		self.btn_unban = guiCreateButton( 550, 58, 100, 29, "Разблокировать", false, parent )

		self.ban_list_serial = guiCreateGridList( 20, 100, 820, 600 - 180, false, parent )
        guiGridListAddColumn( self.ban_list_serial, "SERIAL", 0.3 )
        guiGridListAddColumn( self.ban_list_serial, "DATE", 0.1 )
		guiGridListAddColumn( self.ban_list_serial, "S", 0.05 )
		guiGridListAddColumn( self.ban_list_serial, "S BAN", 0.05 )
		guiGridListAddColumn( self.ban_list_serial, "ADMIN ID", 0.13 )
		guiGridListAddColumn( self.ban_list_serial, "ADMIN NICK", 0.25 )
		guiGridListAddColumn( self.ban_list_serial, "REASON", 0.1 )

		addEventHandler("onClientGUITabSwitched", self.parent, function( selectedTab )
			if selectedTab == self.parent then
				triggerServerEvent( "UpdateBanListSerial", resourceRoot )
			end
		end)

		addEventHandler( "onClientGUIClick", parent, function( key )
			if key ~= "left" then return end
			if source == self.btn_update then
				tryTriggerServerEvent( "UpdateBanListSerial", resourceRoot )
			elseif source == self.btn_serach then
				local edit_serach = guiGetText( self.edit_serach )
				if edit_serach and utf8.len( edit_serach ) ~= 32 then localPlayer:ShowError( "Не верный формат серийного номера" ) return end
				guiGridListClear( self.ban_list_serial )
				tryTriggerServerEvent( "SearchBanListSerial", resourceRoot, edit_serach )
			elseif source == self.btn_ban then
				local accesslevel = localPlayer:GetAccessLevel()
				if accesslevel < 9 then localPlayer:ShowError( "Недостаточный уровень доступа" ) return end
				local serial_ban = guiGetText( self.edit_ban )
				if serial_ban and utf8.len( serial_ban ) ~= 32 then localPlayer:ShowError( "Не верный формат серийного номера" ) return end

				ShowOptionalBanListSerial( serial_ban )
			elseif source == self.btn_unban then
				local accesslevel = localPlayer:GetAccessLevel()
				if accesslevel < 9 then localPlayer:ShowError( "Недостаточный уровень доступа" ) return end
				local item = guiGridListGetSelectedItem( self.ban_list_serial )
				if item < 0 then localPlayer:ShowError( "Не выбрали из списка элемент" ) return end
				local serial = guiGridListGetItemText( self.ban_list_serial, item, 1)
				tryTriggerServerEvent( "SetUnBanSerial", resourceRoot, serial )
			elseif source == self.btn_clear then
				guiSetText( self.edit_serach, "" )
				guiSetText( self.edit_ban, "" )
			end
		end)

		addEventHandler("onClientGUIDoubleClick", self.ban_list_serial, function() 
			local item = guiGridListGetSelectedItem( source )
			if item and item >= 0 then
				local data = guiGridListGetItemData( source, item, 1 )
				ShowInfoBanListSerial( data )
			end
		end)

	end,
}

function ReceiveBanListSerial_handler( data )
	if isElement( pTabs[ TAB_BANLIST_SERIAL ].parent ) then
		local grid_list = pTabs[ TAB_BANLIST_SERIAL ].ban_list_serial
		guiGridListClear( grid_list )

		for k, v in pairs( data ) do
			local row = guiGridListAddRow( grid_list )
			local date_convert = convertUnixToDate( v.date )
			local date = tostring( date_convert.day ) .. "." .. tostring( date_convert.month ) .. ".".. tostring( date_convert.year )
			guiGridListSetItemText( grid_list, row, 1, v.serial, false, false )
			guiGridListSetItemText( grid_list, row, 2, date, false, false )
			guiGridListSetItemText( grid_list, row, 3, v.server, false, false )
			guiGridListSetItemText( grid_list, row, 4, v.server_create_ban, false, false )
			guiGridListSetItemText( grid_list, row, 5, v.admin_id, false, false )
			guiGridListSetItemText( grid_list, row, 6, v.admin_nickname, false, false )
			guiGridListSetItemText( grid_list, row, 7, "Подробнее", false, false )
			guiGridListSetItemData( grid_list, row, 1, v )
		end
	end
end
addEvent("ReceiveBanListSerial", true)
addEventHandler("ReceiveBanListSerial", resourceRoot, ReceiveBanListSerial_handler)

function ShowInfoBanListSerial( data )
	local window = guiCreateWindow( scx / 2 - 130, scy / 2 - 200, 600, 310, "Подробная информация", false )
	local btn_cancel = guiCreateButton( 20, 250, 140, 40, "Закрыть", false, window )
	local info = guiCreateMemo( 20, 30, 560, 200, "", false, window )
	local date_convert = convertUnixToDate( data.date )
	local date = tostring( date_convert.day ) .. "." .. tostring( date_convert.month ) .. ".".. tostring( date_convert.year )
	local str = "Серийный номер: " .. tostring( data.serial ) .. "\n" ..
				"Дата бана: " .. tostring( date ) .. "\n" ..
				"Сервер: " .. tostring( data.server ) .. "\n" ..
				"Сервер с которого выдан бан : " .. tostring( data.server_create_ban ) .. "\n" ..
				"Id администратора: " .. tostring( data.admin_id ) .. "\n" ..
				"Ник администратора: " .. tostring( data.admin_nickname ) .. "\n" ..
				"Причина: " .. tostring( data.reason )

	guiSetText( info, str )

	addEventHandler("onClientGUIClick", window, function( key )
		if key ~= "left" then return end
		if source ==  btn_cancel then
			destroyElement( window )
		end
	end)
end

function ShowOptionalBanListSerial( serial )
	local server_create_ban = localPlayer:getData( "_srv" )[ 1 ]
	local window = guiCreateWindow( scx / 2 - 130, scy / 2 - 200, 340, 180, "Параметры блокировки по серийному ", false )
	local list_type_ban = guiCreateComboBox( 20, 30, 300, 100, "Выберите тип блокировки", false, window )
	local edit_reason = guiCreateEdit( 20, 70, 300, 30, "Причина", false, window )
	local btn_accept = guiCreateButton( 20, 120, 140, 40, "Подтвердить", false, window )
	local btn_cancel = guiCreateButton( 180, 120, 140, 40, "ОТМЕНА", false, window )

	guiComboBoxAddItem( list_type_ban, "По всем серверам" )
	guiComboBoxAddItem( list_type_ban, "По серверу " .. server_create_ban, server_create_ban )

	addEventHandler("onClientGUIClick", window, function( key )
		if key ~= "left" then return end
		if source == btn_accept then
			local reason = guiGetText( edit_reason )
			local type_ban = guiComboBoxGetItemText( list_type_ban, guiComboBoxGetSelected( list_type_ban ) )

			if type_ban == "Выберите тип блокировки" then localPlayer:ShowError( "Не выбран тип блокировки" ) return end

			if type_ban == "По всем серверам" then
				tryTriggerServerEvent("SetBanSerial", resourceRoot, serial, 0, reason )
			else
				tryTriggerServerEvent("SetBanSerial", resourceRoot, serial, localPlayer:getData( "_srv" )[ 1 ], reason )
			end
	
			destroyElement( window )
		elseif source == btn_cancel then
			destroyElement( window )
		end
	end)
end