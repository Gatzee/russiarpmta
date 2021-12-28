pTabs[ TAB_CLANS ] = {
	title = "Clans",
	parent = false,
	disabled = false,
	access_level = ACCESS_LEVEL_GAME_MASTER,
	content = function( self )
		local parent = self.parent

		if localPlayer:getData( "_srv" )[ 1 ] < 100 then
			guiCreateLabel( 20, 20, 750, 20, "В разработке", false, parent )
			return
		end

		local SETTING_VARS_LIST = {
			"SEASON_DURATION",
			"LOCKED_SEASON_DURATION",
			"CARTEL_WARS_WAITING_DURATION",
			"REGISTER_AVAILABLE_AFTER_DURATION",
			"REGISTER_AVAILABLE_DURATION",
			"ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION",
			"DISALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION",
			"DISALLOW_CARTELS_TAX_WARS_WAITING_DURATION",
			"CARTEL_TAX_WAIT_DURATION",
			"NEW_SEASON_START_AFTER_TIME",
		}

		local SETTING_VARS = {
			SEASON_DURATION = "Длительность сезона",
			LOCKED_SEASON_DURATION = "Длительность межсезонья",
			CARTEL_WARS_WAITING_DURATION = "Длительность ожидания назначения войн за дома картелей",
			REGISTER_AVAILABLE_AFTER_DURATION = "Длительность ожидания начала регистрации на войну за дома картелей (сюда же и война за общак)",
			REGISTER_AVAILABLE_DURATION = "Длительность регистрации на войну за дома картелей (сюда же и война за общак)",
			ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION = "Промежуток времени после окончания сезона, через которое картели смогут начать запрашивать налоги",
			DISALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION = "Промежуток времени, в течение которого картели могут запрашивать налоги",
			DISALLOW_CARTELS_TAX_WARS_WAITING_DURATION = "Промежуток времени, в течение которого картели могут объявлять войну за общак",
			CARTEL_TAX_WAIT_DURATION = "Время на ожидание ответа на запрос налога",
			NEW_SEASON_START_AFTER_TIME = "Время, через которое через которое начнётся сезон",
		}

		local SETTING_VARS_DEFAULT_VALUES = {
			SEASON_DURATION = "14 * 24 * 60 * 60 - ( 32 * 60 * 60 )",
			LOCKED_SEASON_DURATION = "32 * 60 * 60",
			CARTEL_WARS_WAITING_DURATION = "3 * 60 * 60",
			REGISTER_AVAILABLE_AFTER_DURATION = "15 * 60",
			REGISTER_AVAILABLE_DURATION = "15 * 60",
			ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION = "6 * 60 * 60",
			DISALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION = "6 * 60 * 60",
			DISALLOW_CARTELS_TAX_WARS_WAITING_DURATION = "9 * 60 * 60",
			CARTEL_TAX_WAIT_DURATION = "2 * 60 * 60",
			NEW_SEASON_START_AFTER_TIME = "0",
		}

		local SETTING_EDITS = { }

		local y = 5
		for k, v in pairs( SETTING_VARS_LIST ) do
			SETTING_VARS[ v ] = k .. ") " .. SETTING_VARS[ v ]
			self.lbl = guiCreateLabel( 20, y, 750, 20, SETTING_VARS[ v ], false, parent )
			SETTING_EDITS[ v ] = guiCreateEdit( 35, y + 20, 240, 22, SETTING_VARS_DEFAULT_VALUES[ v ], false, parent )
			y = y + 52
		end
		

		self.btn_set = guiCreateButton( 540, 490, 210, 40, "Начать первый сезон", false, parent )

		addEventHandler( "onClientGUIClick", self.btn_set, function( key, state )
			iprint(state)

			local values = { }
			for var, edit in pairs( SETTING_EDITS ) do
				local result, value = pcall( loadstring( "return " .. edit.text, "", false ) )
				if not result or not tonumber( value ) then
					localPlayer:ShowError( "Ошибка в " .. SETTING_VARS[ var ] )
					return
				end
				values[ var ] = tonumber( value )
			end

			triggerServerEvent( "SetSeasonSettings", localPlayer, values )
		end, false )







		do return end








		local current_clan = nil
		local current_member = nil

		-- Clans

		self.title1 = guiCreateLabel( 20, 20, 250, 20, "Список кланов", false, parent )
		self.clans_list = guiCreateGridList( 20, 40, 250, 250, false,  parent )
		guiGridListAddColumn( self.clans_list, "Название", 0.5 )
		guiGridListAddColumn( self.clans_list, "Рейтинг", 0.2 )
		guiGridListAddColumn( self.clans_list, "Члены", 0.2 )
		guiGridListSetSortingEnabled( self.clans_list, false )

		self.btn_clan_rating = guiCreateButton( 20, 300, 250, 50, "Изменить рейтинг", false, parent )
		self.btn_clan_block = guiCreateButton( 20, 360, 250, 50, "Заблокировать клан", false, parent )
		self.btn_clan_delete = guiCreateButton( 20, 420, 250, 50, "Удалить клан", false, parent )

		-- Members

		self.title2 = guiCreateLabel( 290, 20, 250, 20, "Список членов клана", false, parent )
		self.members_list = guiCreateGridList( 290, 40, 250, 480, false,  parent )
		guiGridListAddColumn( self.members_list, "UID", 0.15 )
		guiGridListAddColumn( self.members_list, "Имя", 0.3 )
		guiGridListAddColumn( self.members_list, "Ранг", 0.2 )
		guiGridListAddColumn( self.members_list, "Онлайн", 0.25 )

		self.member_memo = guiCreateMemo( 550, 40, 220, 200, "", false, parent )

		self.btn_member_kick_band = guiCreateButton( 550, 260, 220, 50, "Выгнать из банды", false, parent )
		self.btn_member_kick_clan = guiCreateButton( 550, 320, 220, 50, "Выгнать из клана", false, parent )
		self.btn_member_block = guiCreateButton( 550, 380, 220, 50, "Блокировка банд", false, parent )

		addEventHandler( "onClientGUIClick", parent, function( key )
			if key ~= "left" then return end

			if source == self.btn_clan_rating then
				if not current_clan then return end
				ShowUI( false )
				local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Изменить рейтинг клана "..current_clan.name, false )
				local edit_value = guiCreateEdit( 30, 60, 240, 30, current_clan.exp, false, window )
				local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, window )
				local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, window )

				addEventHandler( "onClientGUIClick", window, function( )
					if source == btn_accept then
						local value = tonumber( guiGetText( edit_value ) )
						if not value or value > 100000 or value <= 0 then
							outputChatBox( "Некорректное значение!", 200, 50, 50 )
							return 
						end

						triggerServerEvent( "AP:OnPlayerApplyClanAction", localPlayer, "setexp", current_clan.id, { value = value } )
						destroyElement( window )
						ShowUI( true )
					elseif source == btn_cancel then
						destroyElement( window )
						ShowUI( true )
					end
				end )

			elseif source == self.btn_clan_block then
				if not current_clan then return end
				ShowUI( false )
				local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Заблокировать клан "..current_clan.name, false )
				local edit_reason = guiCreateEdit( 30, 30, 240, 30, "ПРИЧИНА", false, window )
				local edit_time = guiCreateEdit( 30, 70, 240, 30, "Время( в минутах )", false, window )
				local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, window )
				local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, window )

				addEventHandler( "onClientGUIClick", window, function( )
					if source == btn_accept then
						local reason = guiGetText( edit_reason )
						local minutes = tonumber( guiGetText( edit_time ) )

						if not minutes or utf8.len( reason ) < 3 then
							outputChatBox( "Некорректное значение!", 200, 50, 50 )
							return 
						end

						triggerServerEvent( "AP:OnPlayerApplyClanAction", localPlayer, "block", current_clan.id, { time = minutes, reason = reason } )
						destroyElement( window )
						ShowUI( true )
					elseif source == btn_cancel then
						destroyElement( window )
						ShowUI( true )
					end
				end )

			elseif source == self.btn_clan_delete then
				if not current_clan then return end
				ShowUI( false )
				local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 120, "Удалить клан "..current_clan.name.."?", false )
				local btn_accept = guiCreateButton( 40, 50, 90, 40, "УДАЛИТЬ", false, window )
				local btn_cancel = guiCreateButton( 160, 50, 90, 40, "ОТМЕНА", false, window )

				addEventHandler( "onClientGUIClick", window, function( )
					if source == btn_accept then
						triggerServerEvent( "AP:OnPlayerApplyClanAction", localPlayer, "delete", current_clan.id )
						destroyElement( window )
						ShowUI( true )
					elseif source == btn_cancel then
						destroyElement( window )
						ShowUI( true )
					end
				end )

			elseif source == self.btn_member_kick_clan then
				if not current_member then return end
				if not isElement( current_member.element ) then return end
				local pAction = GetActionFromName( "Исключить из клана" )
				pAction:fOnClick( current_member.element )

			elseif source == self.btn_member_block then
				if not current_member then return end
				if not isElement( current_member.element ) then return end
				local pAction = GetActionFromName( "Запрет кланов" )
				pAction:fOnClick( current_member.element )

			elseif source == self.members_list then
				local item = guiGridListGetSelectedItem( self.members_list )
				if item and item >= 0 then
					local data = guiGridListGetItemData( self.members_list, item, 1 )
					current_member = data
					local str = ""
					local data_seq = 
					{
						{ "user_id", "UserID" },
						{ "name", "Имя" },
						{ "rank", "Ранг" },
						{ "role", "Роль", function( val ) return CLAN_ROLES_NAMES[ val ] end },
						{ "element", "Онлайн", function( val ) return val and "ДА" or "НЕТ" end },
					}

					for i, values in pairs( data_seq ) do
						str = str..values[2]..": "..( values[3] and values[3]( data[ values[1] ] ) or data[ values[1] ] ).."\n"
					end

					guiSetText( self.member_memo, str )
				end

			elseif source == self.clans_list then
				local item = guiGridListGetSelectedItem( self.clans_list )
				if item and item >= 0 then
					local data = guiGridListGetItemData( self.clans_list, item, 1 )
					current_clan = data

					guiGridListClear( self.members_list )
					if not data.members then
						triggerServerEvent( "AP:OnPlayerRequestClanMembers", localPlayer, data.id )
					else
						for k, v in pairs( data.members ) do
							local data = 
							{
								rank = v.rank,
								owner = v.owner,
								uid = v.user_id,
								name = v.basic[1],
								element = GetPlayer( v.user_id, true ),
							}
							
							local row = guiGridListAddRow( self.members_list )
							guiGridListSetItemText( self.members_list, row, 1, data.uid, false, false )
							guiGridListSetItemText( self.members_list, row, 2, data.name, false, false )
							guiGridListSetItemText( self.members_list, row, 3, data.rank, false, false )
							guiGridListSetItemText( self.members_list, row, 4, data.element and "Yes" or "No", false, false )
							guiGridListSetItemData( self.members_list, row, 1, data )
						end
					end
				end
			end
		end )

		addEventHandler( "onClientGUITabSwitched", self.parent, function( selectedTab )
			if selectedTab == self.parent then
				triggerServerEvent( "AP:OnPlayerRequestClansData", localPlayer )
			end
		end )
	end
}

function ReceiveClansData( clans )
	if clans then
		if isElement(pTabs[TAB_CLANS].parent) then
			local list = pTabs[TAB_CLANS].clans_list
			guiGridListClear(list)
			for k,v in pairs(clans) do
				local row = guiGridListAddRow(list)
				guiGridListSetItemText( list, row, 1, v.name, false, false )
				guiGridListSetItemText( list, row, 2, v.exp, false, false )
				guiGridListSetItemText( list, row, 3, v.members and #v.members or 0, false, false )
				guiGridListSetItemData( list, row, 1, v )

				for i = 1, 3 do
					guiGridListSetItemColor( list, row, i, unpack(v.color or {255,255,255,255}) )
				end
			end
		end
	end
end
addEvent("AP:ReceiveClansData", true)
addEventHandler("AP:ReceiveClansData", root, ReceiveClansData)