loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend("CVehicle")
Extend("ShVehicleConfig")
Extend("CPlayer")
Extend( "ShClans" )
Extend( "ShUtils" )

local scx,scy = guiGetScreenSize()
local sizeX,sizeY = 980, 600
local posX,posY = (scx-sizeX)/2, (scy-sizeY)/2

FACTIONS_NAMES[ F_POLICE_PPS_NSK ] = "ППС НСК"
FACTIONS_NAMES[ F_POLICE_DPS_NSK ] = "ДПС НСК"
FACTIONS_NAMES[ F_POLICE_PPS_GORKI ] = "ППС ГРК"
FACTIONS_NAMES[ F_POLICE_DPS_GORKI ] = "ДПС ГРК"
FACTIONS_NAMES[ F_POLICE_PPS_MSK ] = "ППС МСК"
FACTIONS_NAMES[ F_POLICE_DPS_MSK ] = "ДПС МСК"
FACTIONS_NAMES[ F_GOVERNMENT_NSK ] = "Мэрия НСК"
FACTIONS_NAMES[ F_GOVERNMENT_GORKI ] = "Мэрия ГРК"
FACTIONS_NAMES[ F_GOVERNMENT_MSK ] = "Мэрия МСК"
FACTIONS_NAMES[ F_MEDIC_MSK ] = "Медики МСК"
FACTIONS_NAMES[ F_MEDIC ] = "Медики НСК"

enum "eTabNames" {
	"TAB_PLAYER_INFO",
	"TAB_PLAYERS",
	"TAB_FACTIONS",
	"TAB_CLANS",
	"TAB_EVENTS",
	"TAB_BANLIST",
	"TAB_BANLIST_SERIAL",
	"TAB_ACCOUNTS",
	"TAB_ADMINS",
	"TAB_GENERAL",
	"TAB_REPORTS",
	"TAB_FACTION_REPORTS",
	"TAB_WORK_INFO",
}


local pLastBanlist
local iAccessLevel = 0
local bIsACLAdmin = false
local pAccounts = {}
local queue_trigger_events = { }
local TRIGGER_COOLDOWN = 5000
local _triggerServerEvent = triggerServerEvent

SERVER_LIST = {}
ui = {}

tryTriggerServerEvent = function( event, ... )
	if localPlayer:getData( "_srv" )[ 1 ] < 100 then
		if queue_trigger_events[ event ] and queue_trigger_events[ event ] > getTickCount( ) then 
			localPlayer:ShowError( "Не так часто" ) 
			return false
		end
		queue_trigger_events[ event ] = getTickCount( ) + TRIGGER_COOLDOWN
	end
    return _triggerServerEvent( event, ... )
end

pTabs = 
{
	[TAB_GENERAL] = 
	{
		title = "General",
		parent = false,
		access_level = ACCESS_LEVEL_INTERN,
		content = function(self)
			local parent = self.parent

			self.btn_switch_blips = guiCreateCheckBox( 40, 20, 200, 30, "Отображать блипы игроков", bPlayerBlipsEnabled, false, parent)
			self.btn_switch_chat = guiCreateCheckBox( 40, 50, 200, 30, "Отображать чат кланов", bPlayerBlipsEnabled, false, parent)

			addEventHandler("onClientGUIClick", parent, function( key )
				if key ~= "left" then return end
				if source == self.btn_switch_blips then
					SwitchPlayerBlips()
					guiCheckBoxSetSelected( self.btn_switch_blips, bPlayerBlipsEnabled )
				elseif source == self.btn_switch_chat then
					triggerServerEvent( "AP:OnPlayerSwitchClansChat", localPlayer )
				end
			end)

			addEventHandler("onClientGUITabSwitched", self.parent, function(selectedTab)
				guiCheckBoxSetSelected( self.btn_switch_blips, bPlayerBlipsEnabled )
				guiCheckBoxSetSelected( self.btn_switch_chat, localPlayer:getData("band_chat_enabled") )
			end)
		end
	},
	[TAB_PLAYER_INFO] = {
		title = "Search Players",
		parent = false,
		access_level = ACCESS_LEVEL_MODERATOR,
		content = function( self )
			local parent = self.parent

			self.label = guiCreateLabel( 20, 20, 60, 25, "UID: ", false, parent )
			guiLabelSetVerticalAlign( self.label, "center" )
			self.edit_id = guiCreateEdit( 70, 20, 160, 25, "", false, parent )

			self.label = guiCreateLabel( 20, 60, 60, 25, "Имя: ", false, parent )
			guiLabelSetVerticalAlign( self.label, "center" )
			self.edit_name = guiCreateEdit( 70, 60, 160, 25, "", false, parent )

			self.label = guiCreateLabel( 20, 100, 60, 25, "SERIAL: ", false, parent )
			guiLabelSetVerticalAlign( self.label, "center" )
			self.edit_serial = guiCreateEdit( 70, 100, 160, 25, "", false, parent )

			self.label = guiCreateLabel( 20, 140, 60, 25, "IP: ", false, parent )
			guiLabelSetVerticalAlign( self.label, "center" )
			self.edit_ip = guiCreateEdit( 70, 140, 160, 25, "", false, parent )

			self.label = guiCreateLabel( 20, 180, 60, 25, "CID: ", false, parent )
			guiLabelSetVerticalAlign( self.label, "center" )
			self.edit_client_id = guiCreateEdit( 70, 180, 160, 25, "", false, parent )

			self.btn_search = guiCreateButton( 20, 230, 210, 35, "Искать", false, parent )
			self.btn_clear = guiCreateButton( 20, 280, 210, 35, "Очистить поля", false, parent )

			self.players_list = guiCreateGridList( 250, 20, 500, sizeY-150, false, parent )
			guiGridListAddColumn( self.players_list, "ID", 0.1 ) 
			guiGridListAddColumn( self.players_list, "Имя", 0.3 )
			guiGridListAddColumn( self.players_list, "SERIAL", 0.3 )
			guiGridListAddColumn( self.players_list, "LAST IP", 0.2 )
			guiGridListSetSortingEnabled( self.players_list, false )

--			self.player_info = guiCreateMemo( 10, 60, sizeX/2-20, sizeY-150, "", false, parent )
--			self.vehicles_info = guiCreateMemo( sizeX/2, 60, sizeX/2-30, sizeY-150, "", false, parent )

--			guiMemoSetReadOnly( self.player_info, true ) guiMemoSetReadOnly( self.vehicles_info, true )

			addEventHandler("onClientGUIClick", parent, function( key )
				if key ~= "left" then return end
				if source == self.btn_search then
					local read_sequence = { "id", "name", "serial", "ip", "client_id" }
					local sKey, sText = "id", "1"
					for i, key in pairs(read_sequence) do
						local text = guiGetText(self["edit_"..key])
						if text and utf8.len(text) > 1 then
							sKey = key 
							sText = text
							break
						end
					end

					tryTriggerServerEvent( "AP:OnPlayersInformationRequested", localPlayer, sKey, sText )
				elseif source == self.btn_clear then
					guiSetText( self.edit_id, "" )
					guiSetText( self.edit_name, "" )
					guiSetText( self.edit_serial, "" )
					guiSetText( self.edit_ip, "" )
					guiSetText( self.edit_client_id, "" )
				end
			end)

			addEventHandler("onClientGUIDoubleClick", self.players_list, function() 
				local iSelectedRow = guiGridListGetSelectedItem( source )
				if iSelectedRow and iSelectedRow >= 0 then
					local uid = guiGridListGetItemData( source, iSelectedRow, 1 )
					tryTriggerServerEvent( "AP:OnPlayerInformationRequested", localPlayer, tonumber(uid) )
				end
			end)
		end,
	},

	[TAB_BANLIST] = {
		title = "Banlist",
		parent = false,
		access_level = ACCESS_LEVEL_MODERATOR,
		content = function( self )
			local parent = self.parent
			self.label = guiCreateLabel( 20, 20, 60, 25, "Фильтр: ", false, parent )
			guiLabelSetVerticalAlign( self.label, "center" )
			self.edit = guiCreateEdit( 80, 20, 150, 25, "", false, parent )

			self.btn_update = guiCreateButton( 260, 18, 100, 29, "Обновить", false, parent )

			self.bans = guiCreateGridList( 20, 60, 500, sizeY-150, false, parent )
			guiGridListAddColumn( self.bans, "UID", 0.2 ) 
			guiGridListAddColumn( self.bans, "Имя", 0.4 )
			guiGridListAddColumn( self.bans, "Истекает через", 0.3 )

			self.details = guiCreateMemo( 530, 60, 240, 200, "", false, parent )
			guiMemoSetReadOnly( self.details, true )

			self.btn_unban = guiCreateButton( 590, 310, 120, 40, "Разбанить", false, parent )

			addEventHandler("onClientGUIClick", parent, function( key )
				if key ~= "left" then return end
				if source == self.btn_update then
					tryTriggerServerEvent( "AP:OnPlayerRequestBanlist", localPlayer )
				elseif source == self.bans then
					local item = guiGridListGetSelectedItem( self.bans )
					if item and item >= 0 then
						local data = guiGridListGetItemData( self.bans, item, 1 )

						local str = "[Список серийников]\n"
						for k,v in pairs( fromJSON(data.banned_serials or {}) ) do
							str = str..v.."\n"
						end

						str = str.."\n[Детали]\nАдмин: "..(data.admin or "UNKNOWN").."\nПричина: "..(data.reason or "UNKNOWN").."\nВыдан: "..(data.time and formatTimestamp(data.time) or "UNKNOWN")

						guiSetText(self.details, str)
					end
				elseif source == self.btn_unban then
					local accesslevel = localPlayer:GetAccessLevel()
					if accesslevel < 9 then localPlayer:ShowError( "Недостаточный уровень доступа" ) return end
					local item = guiGridListGetSelectedItem( self.bans )
					if item and item >= 0 then
						local data = guiGridListGetItemData( self.bans, item, 1 )
						tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "punban", data.id)
					end
				end
			end)

			addEventHandler("onClientGUIChanged", self.edit, function()
				local str = utf8.lower( guiGetText(self.edit) )
				if str then
					-- UPDATE GRIDLIST
					guiGridListClear(self.bans)
					for k,v in pairs(pLastBanlist) do
						if utf8.find( utf8.lower(v.nickname), str ) then
							local row = guiGridListAddRow( self.bans )
							guiGridListSetItemText( self.bans, row, 1, v.id, false, false )
							guiGridListSetItemData( self.bans, row, 1, v)
							guiGridListSetItemText( self.bans, row, 2, v.nickname, false, false )
							guiGridListSetItemText( self.bans, row, 3, math.floor( ( v.banned - getRealTime().timestamp )/60/60 ).."ч", false, false )
						end
					end
				end
			end)
		end,
	},

	[TAB_PLAYERS] = {
		title = "Players",
		parent = false,
		disabled = false,
		access_level = ACCESS_LEVEL_INTERN,
		content = function( self )
			local parent = self.parent
			self.label = guiCreateLabel( 20, 20, 60, 25, "Фильтр: ", false, parent )
			guiLabelSetVerticalAlign( self.label, "center" )
			self.edit = guiCreateEdit( 80, 20, 150, 25, "", false, parent )

			self.btn_update = guiCreateButton( 260, 18, 100, 29, "Обновить", false, parent )

			self.players = guiCreateGridList( 20, 60, 300, sizeY-150, false, parent )
			guiGridListAddColumn( self.players, "ID", 0.3 )
			guiGridListAddColumn( self.players, "Имя", 0.6 )
			guiGridListSetSortingEnabled( self.players, false )
			for k,v in pairs(getElementsByType("player")) do
				local row = guiGridListAddRow( self.players )
				guiGridListSetItemText( self.players, row, 1, v:GetID() or "-", false, false )
				guiGridListSetItemData( self.players, row, 1, v)
				guiGridListSetItemText( self.players, row, 2, v:GetNickName() or "-", false, false )

				if v == localPlayer then
					guiGridListSetSelectedItem( self.players, row, 1 )
				end
			end

			self.details = guiCreateMemo( 330, 60, 440, 150, "", false, parent )
			guiMemoSetReadOnly( self.details, true )

			local tempTabs = {"Общее","Наказания","Оружие","Фракция"}

			self.tabs = guiCreateTabPanel( 330, 230, 440, 280, false, parent )
			for k,v in pairs(tempTabs) do
				local tab = guiCreateTab(v, self.tabs)
				local px, py = 10, 20
				for i, action in pairs(ADMIN_ACTIONS_LIST) do
					if action.iCategory == k then
						if action.iAccessLevel <= iAccessLevel then
							local btn = guiCreateButton( px, py, 200, 34, action.sTitle, false, tab )
							guiCreateStaticImage( 10, 9, 16, 16, "img/icons/icon"..(action.icon or 1)..".png", false, btn )

							addEventHandler("onClientGUIClick", btn, function( key )
								if key ~= "left" then return end
								if source == btn then
									local item = guiGridListGetSelectedItem( self.players )
									if item and item >= 0 then
										local ply = guiGridListGetItemData( self.players, item, 1 )
										action:fOnClick( ply )
									end
								end
							end)

							py = py + 45
							if py >= 45*5 then
								py = 20
								px = 440-210
							end
						end
					end
				end
			end

			addEventHandler("onClientGUIClick", parent, function( key )
				if key ~= "left" then return end
				if source == self.btn_update then
					-- UPDATE GRIDLIST
					guiGridListClear(self.players)
					for k,v in pairs(getElementsByType("player")) do
						local name = v:GetNickName() or v:getName()
						local str = utf8.lower( guiGetText(self.edit) )
						if str and utf8.find( utf8.lower(name), str ) or #str <= 1 then
							local row = guiGridListAddRow( self.players )
							guiGridListSetItemText( self.players, row, 1, v:GetID() or "-", false, false )
							guiGridListSetItemData( self.players, row, 1, v)
							guiGridListSetItemText( self.players, row, 2, name, false, false )
						end
					end
				elseif source == self.players then
					local item = guiGridListGetSelectedItem( self.players )
					if item and item >= 0 then
						local data = guiGridListGetItemData( self.players, item, 1 )

						local str = isElement( data ) and ( "[ "..data:GetNickName().." ]\n Loading..." ) or "Игрок вышел из игры"
						guiSetText(self.details, str)

						tryTriggerServerEvent("AP:RequestPlayerData", localPlayer, data)
					end
				end
			end)

			addEventHandler("onClientGUIChanged", self.edit, function()
				local str = utf8.lower( guiGetText(self.edit) )
				if str then
					-- UPDATE GRIDLIST
					guiGridListClear(self.players)
					for k,v in pairs(getElementsByType("player")) do
						local name = v:GetNickName() or v:getName()
						if utf8.find( utf8.lower(name), str ) or #str <= 1 then
							local row = guiGridListAddRow( self.players )
							guiGridListSetItemText( self.players, row, 1, v:GetID() or "-", false, false )
							guiGridListSetItemData( self.players, row, 1, v)
							guiGridListSetItemText( self.players, row, 2, name, false, false )
						end
					end
				end
			end)
		end,
	},

	[TAB_FACTIONS] = {
		title = "Factions",
		parent = false,
		disabled = false,
		access_level = ACCESS_LEVEL_MODERATOR,
		content = function( self )
			local parent = self.parent

			self.tab_factions = guiCreateTabPanel( 0, 0, sizeX, sizeY, false, parent )
			for k,v in pairs(FACTIONS_NAMES) do
				local parent = guiCreateTab(v, self.tab_factions)
				self[k] = {}
				self[k].tab = parent
				--self[k].label = guiCreateLabel( 20, 20, 60, 25, "Фильтр: ", false, parent )
				--guiLabelSetVerticalAlign( self[k].label, "center" )
				--self[k].edit = guiCreateEdit( 80, 20, 150, 25, "", false, parent )

				self[k].btn_update = guiCreateButton( 20, 18, 100, 29, "Обновить", false, parent )

				self[k].list = guiCreateGridList( 20, 60, 300, sizeY-150, false, parent )
				guiGridListAddColumn( self[k].list, "UID", 0.2 ) 
				guiGridListAddColumn( self[k].list, "Имя", 0.4 )
				guiGridListAddColumn( self[k].list, "Ранг", 0.2 )

				self[k].details = guiCreateMemo( 330, 60, 440, 150, "", false, parent )
				guiMemoSetReadOnly( self[k].details, true )

				self[k].setrank = guiCreateButton( 330, 230, 120, 40, "Изменить ранг", false, parent )
				--self[k].giveexp = guiCreateButton( 490, 230, 120, 40, "Выдать опыт", false, parent )
				self[k].remove = guiCreateButton( 650, 230, 120, 40, "Исключить", false, parent )

				local data = nil

				addEventHandler("onClientGUIClick", parent, function( key )
					if key ~= "left" then return end
					if source == self[k].btn_update then
						tryTriggerServerEvent("AP:OnFactionsMembersListRequest", localPlayer, k)
					elseif source == self[k].list then
						local item = guiGridListGetSelectedItem( self[k].list )
						if item and item >= 0 then
							data = guiGridListGetItemData( self[k].list, item, 1 )

							local str = "Онлайн: "..( GetPlayer( data.id, true ) and ("Да (ID:"..GetPlayer( data.id, true ):GetID()..")") or "Нет")..
							"\nРанг: "..data.faction_level.."\nОпыт: "..data.faction_exp.."\nПредупреждений: "..data.faction_warns

							guiSetText(self[k].details, str)
						end
					elseif source == self[k].setrank then
						if not data then return end
						ShowUI(false)
						local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Изменить ранг "..data.nickname, false )
						local edit_value = guiCreateEdit( 30, 60, 240, 30, "Значение (1-" .. FACTION_OWNER_LEVEL .. ")", false, window )
						local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, window )
						local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, window )

						addEventHandler("onClientGUIClick", window, function()
							if source == btn_accept then
								local value = tonumber(guiGetText( edit_value ))
								if not value or value <= 0 or value > FACTION_OWNER_LEVEL then
									outputChatBox("Некорректное значение!", 200, 50, 50)
									return 
								end

								tryTriggerServerEvent("AP:OnPlayerApplyFactionAction", localPlayer, "setrank", {value = value, uid = data.id})
								destroyElement( window )

								tryTriggerServerEvent("AP:OnFactionsMembersListRequest", localPlayer, k)
								ShowUI(true)
							elseif source == btn_cancel then
								destroyElement( window )
								ShowUI(true)
							end
						end)
					elseif source == self[k].giveexp then
						if not data then return end
						ShowUI(false)
						local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Выдать опыт фракции "..data.nickname, false )
						local edit_value = guiCreateEdit( 30, 60, 240, 30, "Значение (0-10000)", false, window )
						local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, window )
						local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, window )

						addEventHandler("onClientGUIClick", window, function()
							if source == btn_accept then
								local value = tonumber(guiGetText( edit_value ))
								if not value or value > 10000 or value <= 0 then
									outputChatBox("Некорректное значение!", 200, 50, 50)
									return 
								end

								tryTriggerServerEvent("AP:OnPlayerApplyFactionAction", localPlayer, "giveexp", {oldvalue = data.faction_exp, value = value, uid = data.id})
								destroyElement( window )

								tryTriggerServerEvent("AP:OnFactionsMembersListRequest", localPlayer, k)
								ShowUI(true)
							elseif source == btn_cancel then
								destroyElement( window )
								ShowUI(true)
							end
						end)
					elseif source == self[k].remove then
						if not data then return end
						ShowUI(false)
						local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 120, "Исключить "..data.nickname.." из фракции?", false )
						local btn_accept = guiCreateButton( 40, 50, 90, 40, "ИСКЛЮЧИТЬ", false, window )
						local btn_cancel = guiCreateButton( 160, 50, 90, 40, "ОТМЕНА", false, window )

						addEventHandler("onClientGUIClick", window, function()
							if source == btn_accept then
								tryTriggerServerEvent("AP:OnPlayerApplyFactionAction", localPlayer, "remove", {uid = data.id})
								destroyElement( window )

								tryTriggerServerEvent("AP:OnFactionsMembersListRequest", localPlayer, k)
								ShowUI(true)
							elseif source == btn_cancel then
								destroyElement( window )
								ShowUI(true)
							end
						end)
					end
				end)
			end

			addEventHandler("onClientGUITabSwitched", self.tab_factions, function(selectedTab)
				for i=1, #FACTIONS_NAMES do
					if selectedTab == self[i].tab then
						triggerServerEvent("AP:OnFactionsMembersListRequest", localPlayer, i)
					end
				end
			end)
		end,
	},

	[TAB_ACCOUNTS] = {
		title = "Accounts",
		parent = false,
		access_level = ACCESS_LEVEL_DEVELOPER,
		acl_only = true,
		content = function( self )
			self.list = guiCreateGridList(0,20,sizeX,450,false,self.parent)
			guiGridListAddColumn( self.list, "UserID", 0.2 ) guiGridListAddColumn( self.list, "Nickname", 0.6 ) guiGridListAddColumn( self.list, "Current", 0.1 )

			for k,v in pairs(pAccounts) do
				local row = guiGridListAddRow(self.list)
				guiGridListSetItemData(self.list, row, 1, v)
				guiGridListSetItemText(self.list, row, 1, v.id, false, true)
				guiGridListSetItemText(self.list, row, 2, v.nickname, false, true)
				if v.id == localPlayer:GetUserID() then
					guiGridListSetItemText(self.list, row, 3, "Yes", false, false)
				else
					guiGridListSetItemText(self.list, row, 3, "No", false, false)
				end
			end

			self.bDelete = guiCreateButton(160, 480, 150, 50, "Удалить выбранный(НАВСЕГДА)", false, self.parent)
			self.bStash = guiCreateButton(320, 480, 150, 50, "Отключить текущий", false, self.parent)
			self.bSwitch = guiCreateButton(480, 480, 150, 50, "Переключиться на выбранный", false, self.parent)

			addEventHandler("onClientGUITabSwitched", self.parent, function(selectedTab)
				if selectedTab == self.parent then
					triggerServerEvent( "AP:UpdateAccountsList", localPlayer )
				end
			end)

			addEventHandler("onClientGUIClick",self.parent,function()
				local row = guiGridListGetSelectedItem( self.list )
				local iSelectedUserID = false
				if row and row >= 0 then
					local sID = guiGridListGetItemText(self.list,row,1)
					if sID then
						iSelectedUserID = tonumber(sID)
					end
				end
				if source == self.bClose then
					ReceiveAccountsList()
				elseif source == self.bDelete then
					if not iSelectedUserID then return end
					tryTriggerServerEvent("AP:AccountActionAttempt",localPlayer,1,iSelectedUserID)
				elseif source == self.bStash then
					tryTriggerServerEvent("AP:AccountActionAttempt",localPlayer,2,iSelectedUserID)
				elseif source == self.bSwitch then
					if not iSelectedUserID then return end
					tryTriggerServerEvent("AP:AccountActionAttempt",localPlayer,3,iSelectedUserID)
				end
			end)
		end,
	},

	[TAB_REPORTS] = {
		title = "Reports",
		parent = false,
		access_level = ACCESS_LEVEL_INTERN,
		content = function( self )
			
			--Обновление текста информативного лейбла
			function SetInfoLabelText( text, r, g, b )			
			    self.info_lbl:setText( text or "" )
				guiLabelSetColor( self.info_lbl, r, g, b )
				setTimer( function( label)
					if label then
						label:setText( "" )
					end
				end, 5000, 1, self.info_lbl )
			end
			
			--Заполнение списка репортов
			function FillReportList()
			
				self.logs_memo:setText("")
			    self.report_glist:clear()
			
			    for k, v in pairs( REPORTS ) do
			        AddRowToGirdList( k, v )
			    end
			
			end
			
			--Обновление списка репортов
			function RefreshGridList( report_id, report )
			    local row_count = self.report_glist:getRowCount()
				local find = false
				for row = 0, row_count do 
				
					local row_data = self.report_glist:getItemData( row, 1 )
			        if row_data and row_data.report_id == report_id then
					
			            local date = formatTimestamp( report[ TIMESTAMP ] )
			            self.report_glist:setItemData( row, 1, { report_id = report_id, report = report } )
					
			            self.report_glist:setItemText( row, 1, report_id, false, true )
			            self.report_glist:setItemText( row, 2, report[ SOURCE  ], false, true )
			            self.report_glist:setItemText( row, 3, report[ THEME ], false, false )
			            self.report_glist:setItemText( row, 4, date, false, false )
					
			            local selected_row =  self.report_glist:getSelectedItem()
			            if row == selected_row then
			                self.logs_memo:setText( "Название: " .. report[ NAME ] .. "\n" .. "Тема: " .. report[ THEME ] .. "\n\n" ..  table.concat( report[ MSG_HISTORY ], "\n") )
			            end
					
			            local playerId = localPlayer:GetUserID()
			            if not report[ CURRENT_HELPER ] then
			                SetRowColor( row,  255, 255, 255 )
			            elseif report[ CURRENT_HELPER ] == playerId then
			                SetRowColor( row, 0, 255, 0 )
			            else
			                SetRowColor( row, 100, 100, 100 )
			            end
						find = true
			            break
					end
					
				end 
				
				if not find then
					AddRowToGirdList( report_id, report )
					if row_count == 0 then
						self.report_glist:setSelectedItem( 0, 1 )
						self.logs_memo:setText( "Название: " .. report[ NAME ] .. "\n" .. "Тема: " .. report[ THEME ] .. "\n\n" ..  table.concat( report[ MSG_HISTORY ], "\n") )
					end
				end
			end

			function AddRowToGirdList( report_id, report )

				local date = formatTimestamp( report[ TIMESTAMP ] )
				local row = self.report_glist:addRow( 
					report_id, 
					report[ SOURCE ], 
					report[ THEME ],
					date 
				)
				self.report_glist:setItemData( row, 1, { report_id = report_id, report = report } )
				
				local playerId = localPlayer:GetUserID()
				if not report[ CURRENT_HELPER ] then
					SetRowColor( row, 255, 255, 255 )
				elseif report[ CURRENT_HELPER ] == playerId then
					SetRowColor( row, 0, 255, 0 )
				else
					SetRowColor( row, 100, 100, 100 )
				end
			end

			function SetRowColor( row, r, g, b )
				for i = 1, 5 do
					self.report_glist:setItemColor( row, i, r, g, b )
				end
			end

			function RemoveRowFromGridList( report_number )

				local selected_row =  self.report_glist:getSelectedItem()
				for row = 0, self.report_glist:getRowCount() do 
					local row_data = self.report_glist:getItemData( row, 1 )
					if row_data and row_data.report_id == report_number then
						if selected_row == row then
							self.logs_memo:setText( "" )
						end
						self.report_glist:removeRow( row )
						break
					end
				end
			end

			--Окно подтверждения
			function GuiPrompt( message, yes_text, no_text, ycallback, ncallback, include_edit )
			    if not ( message and type( ycallback ) == "function" ) then return end
			
			    local x, y, width, height = GuiMiddlePosition( 380, 170 )
			    local window = GuiWindow(x, y, width, height, "Подтверждение", false, self.parent)
			    guiWindowSetSizable( window, false )
			    window:setAlpha( 1 )
			
			    local label = GuiLabel( 5, -5, width - 5, height, message, false, window )
			    guiLabelSetHorizontalAlign( label, "center", true )
			    guiLabelSetVerticalAlign( label, "center" )
			
			    local edit
			    if include_edit then 
			        edit = GuiEdit( 50, 80, 280, 30, "", false, window )
			        edit:setMaxLength( 96 )
			        label:setPosition( 5, 40, false )
			        guiLabelSetVerticalAlign( label, "top" )
			    end
			
			    local btn_yes = GuiButton( 43, 125, 115, 24, yes_text or "Да", false, window )
			    local btn_no  = GuiButton( 222, 125, 115, 24, no_text or "Нет", false, window )
			
			    addEventHandler( "onClientGUIClick", btn_yes, function( button, state )
			        if button ~= "left" or state ~= "up" then  return end
			        ycallback( include_edit and edit.text or nil )
			        window:destroy()
			    end, false )
			
			    addEventHandler( "onClientGUIClick", btn_no, function( button, state )
			        if button ~= "left" or state ~= "up" then  return end
			        if ncallback then  ncallback()  end
			        window:destroy()
			    end, false )
			
			    return window
			end


			--Получение позиции в центре экрана относительно ширины и высоты
			function GuiMiddlePosition( width, height )
			    local x = ( scx  - width ) / 2
			    local y = ( scy - height ) / 2
			    return x, y, width, height
			end

			self.report_g_lbl = GuiLabel( 30, 15, 200, 25, "Cписок заявок: ", false, self.parent )
			
			self.report_glist =  GuiGridList( 20, 40, 420, 450, false, self.parent )
			self.report_glist:setSelectionMode( 0 )
			self.report_glist:addColumn( "ID", 0.1 )
			self.report_glist:addColumn( "UID", 0.2  )
			self.report_glist:addColumn( "Тема", 0.33  )
			self.report_glist:addColumn( "Дата", 0.3 )

			addEventHandler( "onClientGUIClick",  self.report_glist, function(element) 
				local row = self.report_glist:getSelectedItem( )
				if row == -1 then  return  end
				local row_data = self.report_glist:getItemData( row, 1 )
				self.logs_memo:setText( "Название: " .. row_data.report[ NAME ] .. "\n" .. "Тема: " .. row_data.report[ THEME ] .. "\n\n" .. table.concat( row_data.report[ MSG_HISTORY ], "\n") )
			 end, false )

			self.btn_refresh = GuiButton( 20, 500, 115, 24, "Обновить", false, self.parent )
			addEventHandler( "onClientGUIClick", self.btn_refresh, RefreshReports, false )

			if localPlayer:GetAccessLevel() >= ACCESS_LEVEL_SUPERVISOR then
				self.btn_reset_reports = GuiButton( 150, 500, 115, 24, "Сбросить репорты", false, self.parent )
				addEventHandler( "onClientGUIClick", self.btn_reset_reports, function()
					if isElement( self.accept_window ) then 
						self.accept_window:bringToFront()
						return 
					end
					self.accept_window = GuiPrompt( "Вы действительно хотите сбросить \nсчётчик репортов?", nil, nil, 
					function()
						tryTriggerServerEvent( "onServerResetReportCounter", localPlayer )
					end )
				end, false )
			end

			self.info_lbl = GuiLabel( 25, 526, 400, 25, "", false, self.parent )

			self.histroy_lbl = GuiLabel( 470, 15, 200, 25, "История переписки с игроком:", false, self.parent )
			self.logs_memo = guiCreateMemo( 460, 40, 310, 350, "", false, self.parent )
			guiMemoSetReadOnly( self.logs_memo, true )

			self.actions_lbl = GuiLabel( 470, 405, 200, 25, "Действия с заявкой", false, self.parent )

			self.btn_send_answer = GuiButton( 460, 427, 115, 24, "Ответить игроку", false, self.parent )
			addEventHandler( "onClientGUIClick", self.btn_send_answer, function()
			
				if isElement( self.accept_window ) then 
					self.accept_window:bringToFront()
					return 
				end
			
				local row = self.report_glist:getSelectedItem( )
				if row == -1 then  
				    SetInfoLabelText( "Выберите заявку", 255, 0, 0 )
				    return  
				end
			
				local row_data = self.report_glist:getItemData( row, 1 )

				local report = row_data.report
				if report[ CURRENT_HELPER ] and report[ CURRENT_HELPER ] ~= localPlayer:GetUserID() then
					SetInfoLabelText( "Данная заявка уже рассматривается другим администратором", 255, 0, 0 )
					return
				end
				
				self.accept_window = GuiPrompt( "Вы собиратесь взять заявку\nВведите ответ для начала", "Взять", "Отмена", 
					function( answer )
						if not answer or answer == "" then
						    SetInfoLabelText( "Ответ не был введен, операция отменена!", 255, 0, 0 )
						    return
						end
						local row = self.report_glist:getSelectedItem( )
						if row == -1 then  
						    SetInfoLabelText( "Выберите заявку", 255, 0, 0 )
						    return  
						end
						local row_data = self.report_glist:getItemData( row, 1 )
						SendAnswerToUser( answer, row_data.report_id, row_data.report )
					end, 
				nil, true )

			end, false )

			self.btn_teleport_to_player = GuiButton( 460, 460, 115, 24, "ТП к игроку", false, self.parent )
			addEventHandler( "onClientGUIClick", self.btn_teleport_to_player, function()

				local row = self.report_glist:getSelectedItem( )
				if row == -1 then  
				    SetInfoLabelText( "Выберите заявку", 255, 0, 0 )
				    return  
				end
			
				local row_data = self.report_glist:getItemData( row, 1 )
				local report = row_data.report
				
				if report[ SOURCE_PLAYER ] then
					tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, 5, report[ SOURCE_PLAYER ] )
				end

			end, false )

			self.btn_teleport_player = GuiButton( 585, 460, 115, 24, "ТП игрока", false, self.parent )
			addEventHandler( "onClientGUIClick", self.btn_teleport_player, function()

				local row = self.report_glist:getSelectedItem( )
				if row == -1 then  
				    SetInfoLabelText( "Выберите заявку", 255, 0, 0 )
				    return  
				end
			
				local row_data = self.report_glist:getItemData( row, 1 )
				local report = row_data.report
				
				if report[ SOURCE_PLAYER ] then
					tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, 4, report[ SOURCE_PLAYER ] )
				end

			end, false )

			self.btn_spectate_player = GuiButton( 460, 493, 115, 24, "Наблюдать", false, self.parent )
			addEventHandler( "onClientGUIClick", self.btn_spectate_player, function()

				local row = self.report_glist:getSelectedItem( )
				if row == -1 then  
				    SetInfoLabelText( "Выберите заявку", 255, 0, 0 )
				    return  
				end
			
				local row_data = self.report_glist:getItemData( row, 1 )
				local report = row_data.report
				
				if report[ SOURCE_PLAYER ] then
					tryTriggerServerEvent("AP:OnSpectateRequest", localPlayer, report[ SOURCE_PLAYER ] )
				end

			end, false )

			self.btn_close_report = GuiButton( 585, 427, 115, 24, "Закрыть заявку", false, self.parent )
			addEventHandler( "onClientGUIClick", self.btn_close_report, function()
			
				if isElement( self.accept_window ) then 
					self.accept_window:bringToFront()
					return 
				end
			
				local row = self.report_glist:getSelectedItem( )
				if row == -1 then  
					SetInfoLabelText( "Выберите заявку", 255, 0, 0 )
					return  
				end
			
				self.accept_window = GuiPrompt( "Вы действительно хотите закрыть заявку?\nВведите причину", nil, nil, 
				function( reason )
					if not reason or reason == "" then
						SetInfoLabelText( "Причина не была введена, операция отменена!", 255, 0, 0 )
						return
					end
					local row = self.report_glist:getSelectedItem( )
					if row == -1 then  
						SetInfoLabelText( "Выберите заявку", 255, 0, 0 )
						return  
					end
					local row_data = self.report_glist:getItemData( row, 1 )
					CloseUserReport( reason, row_data.report_id, row_data.report )
				end, nil, true )
			
			end, false )

			FillReportList()
		end,
	},

	[TAB_FACTION_REPORTS] = {
		title = "Faction Reports",
		parent = false,
		access_level = ACCESS_LEVEL_HELPER,
		content = function( self )
			local parent = self.parent
			self.btn_update = guiCreateButton( 20, 18, 100, 29, "Обновить", false, parent )

			self.reports_list = guiCreateGridList( 20, 60, 500, sizeY-150, false, parent )
			guiGridListAddColumn( self.reports_list, "ID", 0.15 ) 
			guiGridListAddColumn( self.reports_list, "Отправитель", 0.4 ) 
			guiGridListAddColumn( self.reports_list, "Получатель", 0.4 )

			self.details = guiCreateMemo( 530, 60, 240, 200, "", false, parent )
			guiMemoSetReadOnly( self.details, true )

			self.btn_delete = guiCreateButton( 590, 310, 120, 40, "Удалить", false, parent )

			addEventHandler("onClientGUIClick", parent, function( key )
				if key ~= "left" then return end
				if source == self.btn_update then
					tryTriggerServerEvent( "AP:OnAdminRequestFactionReportsList", localPlayer )
				elseif source == self.reports_list then
					local item = guiGridListGetSelectedItem( self.reports_list )
					if item and item >= 0 then
						local data = guiGridListGetItemData( self.reports_list, item, 1 )

						local str = "[Комментарий]\n"..data.desc

						guiSetText(self.details, str)
					end
				elseif source == self.btn_delete then
					local item = guiGridListGetSelectedItem( self.reports_list )
					if item and item >= 0 then
						local data = guiGridListGetItemData( self.reports_list, item, 1 )
						local id = guiGridListGetItemText( self.reports_list, item, 1 )
						tryTriggerServerEvent( "AP:OnAdminRequestDeleteFactionReport", localPlayer, data.target, id, { name = data.source_name, created = data.created  })
					end
				end
			end)
		end,
	},
}
function GetServers()
	return SERVER_LIST or {}
end
function InitUI( iRights, bACLRights )
	local bExists = isElement(ui.main)
	if bExists then
		ShowUI(not guiGetVisible(ui.main))
		showCursor( guiGetVisible(ui.main) )
	else
		showCursor(true)
		iAccessLevel = bACLRights and ACCESS_LEVEL_DEVELOPER or iRights or 0
		bIsACLAdmin = bACLRights or false

		ui.main = guiCreateWindow( posX, posY, sizeX, sizeY, "NRP Admin Panel", false )
		ui.tabs = guiCreateTabPanel( 0, 20, sizeX, sizeY, false, ui.main )

		for i, tab in ipairs(pTabs) do
			if not tab.disabled and iAccessLevel >= tab.access_level then
				if tab.acl_only then
					if bIsACLAdmin then
						tab.parent = guiCreateTab( tab.title, ui.tabs )
						tab:content()
					end
				else
					tab.parent = guiCreateTab( tab.title, ui.tabs )
					tab:content()
				end
			end
			--guiSetSelectedTab( ui.tabs, tab.parent)
		end
	end
end

function ShowUI(state)
	guiSetVisible( ui.main, state )
end

bindKey("x", "down", function()
	triggerServerEvent("AP:InitUI", localPlayer)
end)

function ReceivePlayerInformation( data )
	local pAssocNames = 
	{
		{ "online", "Онлайн", function(val) return val and "Да" or "Нет" end},
		{ "id", "ID"},
		{ "nickname", "Никнейм"},
		{ "accesslevel", "Уровень доступа"},
		{ "money", "Деньги"},
		{ "donate", "Донат"},
		{ "level", "Уровень"},
		{ "exp", "Опыт"},
		{ "skin", "Скин"},
		{ "gender", "Пол", function(val) return val == 0 and "Муж" or "Жен" end},
		{ "reg_date", "Дата регистрации", function(val) return formatTimestamp(val) end},
		{ "last_date", "Последний вход", function(val) return formatTimestamp(val) end},
		{ "playing_time", "Время в игре", function(val) return math.floor(val/60/60).."ч" end},
		{ "muted", "Мут(осталось)", function(val) return math.floor(val/60).."мин" end},
		{ "banned", "Бан(осталось)", function(val) return math.floor(val/60).."мин" end},
		{ "reg_serial", "Рег. серийник"},
		{ "last_serial", "Посл. серийник"},
		{ "reg_ip", "Рег. IP"},
		{ "last_ip", "Последний IP"},
		{ "faction_id", "Фракция", function(val) return FACTIONS_NAMES[val] or "-" end},
		{ "faction_level", "Уровень во фракции"},
		{ "clan_id", "Клан" },
		{ "clan_level", "Уровень в клане" },
		{ "military_date", "Военный билет", function(val) return val and "Получен ("..formatTimestamp(val)..")" or "НЕ ПОЛУЧЕН" end},
	}

	if data then
		if isElement(pTabs[TAB_PLAYER_INFO].parent) then
			local new_window = guiCreateWindow( 100, 100, sizeX, sizeY, data.nickname, false )
			local player_info = guiCreateMemo( 10, 40, sizeX/2-20, sizeY-120, "", false, new_window )
			local vehicles_info = guiCreateMemo( sizeX/2, 40, sizeX/2-30, sizeY-120, "", false, new_window )
			local btn_close = guiCreateButton( sizeX-160, 540, 120, 40, "Закрыть", false, new_window )
			addEventHandler("onClientGUIClick", btn_close, function( key )
				if key ~= "left" then return end
				if source ~= btn_close then return end
				new_window:destroy()
			end)


			guiMemoSetReadOnly( player_info, true ) guiMemoSetReadOnly( vehicles_info, true )

			local sPlayer = ""
			local sVehicles = "[Автомобили]\n"

			for k,v in pairs(pAssocNames) do
				local str = data[ v[1] ]
				if v[3] then str = v[3](str) end
				sPlayer = sPlayer..v[2]..": "..tostring(str).."\n"
			end

			if data.licenses then
				sPlayer = sPlayer.."\n[Имеющиеся лицензии]\n"
				for k,v in pairs(data.licenses) do
					if v == LICENSE_STATE_TYPE_PASSED then
						sPlayer = sPlayer.."Категория "..(LICENSES_DATA[tonumber(k)] and LICENSES_DATA[tonumber(k)].sName or "Неизвестно").."\n"
					end
				end
			end

			if data.banned and data.banned > getRealTime().timestamp then
				sPlayer = sPlayer.."\n[Забаненные серийники]"
				for k,v in pairs(data.banned_serials or {}) do
					sPlayer = sPlayer..v..'\n'
				end
			end

			guiSetText(player_info, sPlayer)


			for k, veh in pairs(data.vehicles) do
				local str = "\n(ID: "..veh.id..") "..GetVehicleNameFromModel(veh.model).." - "..tostring(veh.number_plate)
				if veh.deleted then
					str = str.."\n УДАЛЁН "..formatTimestamp(veh.deleted[1]).." Причина: "..veh.deleted[2].."\n"
				end

				sVehicles = sVehicles..str
			end

			guiSetText(vehicles_info, sVehicles)
		end
	end
end
addEvent("AP:ReceivePlayerInformation", true)
addEventHandler("AP:ReceivePlayerInformation", root, ReceivePlayerInformation)

function ReceiveBanlist( data )
	if data then
		if isElement(pTabs[TAB_BANLIST].parent) then
			pLastBanlist = data
			guiGridListClear(pTabs[TAB_BANLIST].bans)
			for k,v in pairs(data) do
				local row = guiGridListAddRow( pTabs[TAB_BANLIST].bans )
				guiGridListSetItemText( pTabs[TAB_BANLIST].bans, row, 1, v.id, false, false )
				guiGridListSetItemData( pTabs[TAB_BANLIST].bans, row, 1, v)
				guiGridListSetItemText( pTabs[TAB_BANLIST].bans, row, 2, v.nickname, false, false )
				guiGridListSetItemText( pTabs[TAB_BANLIST].bans, row, 3, math.floor( ( v.banned - getRealTime().timestamp )/60/60 ).."ч", false, false )
			end
		end
	end
end
addEvent("AP:ReceiveBanlist", true)
addEventHandler("AP:ReceiveBanlist", root, ReceiveBanlist)

function ReceiveAccountsList( accounts, acc_name )
	pAccounts = accounts
	if isElement(pTabs[TAB_ACCOUNTS].list) then
		guiGridListClear(pTabs[TAB_ACCOUNTS].list)
		for k,v in pairs(pAccounts) do
			local row = guiGridListAddRow(pTabs[TAB_ACCOUNTS].list)
			guiGridListSetItemData(pTabs[TAB_ACCOUNTS].list, row, 1, v)
			guiGridListSetItemText(pTabs[TAB_ACCOUNTS].list, row, 1, v.id, false, true)
			guiGridListSetItemText(pTabs[TAB_ACCOUNTS].list, row, 2, v.nickname, false, true)
			if v.id == localPlayer:GetUserID() then
				guiGridListSetItemText(pTabs[TAB_ACCOUNTS].list, row, 3, "Yes", false, false)
			else
				guiGridListSetItemText(pTabs[TAB_ACCOUNTS].list, row, 3, "No", false, false)
			end
		end
	end
end
addEvent("AP:ReceiveAccountsList", true)
addEventHandler("AP:ReceiveAccountsList", root, ReceiveAccountsList)

function ReceiveFactionMembers( iFactionID, data )
	if data then
		if isElement(pTabs[TAB_FACTIONS].parent) then
			local list = pTabs[TAB_FACTIONS][iFactionID].list
			guiGridListClear(list)

			for k,v in pairs(data) do
				local row = guiGridListAddRow( list )
				guiGridListSetItemText( list, row, 1, v.id, false, false )
				guiGridListSetItemData( list, row, 1, v )
				guiGridListSetItemText( list, row, 2, v.nickname, false, false )
				guiGridListSetItemText( list, row, 3, v.faction_level, false, false )
			end
		end
	end
end
addEvent("AP:ReceiveFactionMembers", true)
addEventHandler("AP:ReceiveFactionMembers", root, ReceiveFactionMembers)

function ReceivePlayerData( data )
	if isElement(pTabs[TAB_PLAYERS].parent) then
		local memo = pTabs[TAB_PLAYERS].details

		local str = "[ "..data.element:GetNickName().." ]"

		local assoc_names = 
		{
			rating = { "Социальный рейтинг", function(val) return val end },
			muted = { "В муте", function(val) return val and "Да" or "Нет" end },
			immortal = { "Неуязвимость", function(val) return val and "Да" or "Нет" end },
			jailed = { "В тюрьме", function(val) return val and "Да" or "Нет" end },
			frozen = { "Заморожен", function(val) return val and "Да" or "Нет" end },
			clan_banned = { "Блокировка банд", function(val) return val and "Да" or "Нет" end },
		}

		for k,v in pairs(assoc_names) do
			str = str.."\n"..v[1].." : "..v[2](data[k])
		end

		guiSetText(memo, str)
	end
end
addEvent("AP:ReceivePlayerData", true)
addEventHandler("AP:ReceivePlayerData", resourceRoot, ReceivePlayerData)

function ReceivePlayersList( data )
	if isElement(pTabs[TAB_PLAYER_INFO].parent) then
		local gridlist = pTabs[TAB_PLAYER_INFO].players_list

		guiGridListClear(gridlist)
		for k,v in pairs(data) do
			local row = guiGridListAddRow( gridlist )
			guiGridListSetItemText( gridlist, row, 1, v.id, false, false )
			guiGridListSetItemData( gridlist, row, 1, v.id)
			guiGridListSetItemText( gridlist, row, 2, v.nickname, false, false )
			guiGridListSetItemText( gridlist, row, 3, v.serial or "???", false, false )
			guiGridListSetItemText( gridlist, row, 4, v.ip or "???", false, false )
		end
	end
end
addEvent("AP:ReceivePlayersList", true)
addEventHandler("AP:ReceivePlayersList", resourceRoot, ReceivePlayersList)

function ReceiveFactionReportsList( data )
	if isElement(pTabs[TAB_FACTION_REPORTS].parent) then
		local gridlist = pTabs[TAB_FACTION_REPORTS].reports_list
		guiGridListClear(gridlist)
		for k,v in pairs(data) do
			local row = guiGridListAddRow( gridlist )
			guiGridListSetItemText( gridlist, row, 1, k, false, false )
			guiGridListSetItemText( gridlist, row, 2, v.source_name, false, false )
			guiGridListSetItemData( gridlist, row, 1, v )
			guiGridListSetItemText( gridlist, row, 3, v.target_name, false, false )
		end
	end
end
addEvent("AP:ReceiveFactionReportsList", true)
addEventHandler("AP:ReceiveFactionReportsList", root, ReceiveFactionReportsList)

function SortByID_comparator( a, b )
	return a.id < b.id
end
function ServerListUpdate_Callback( responseData, error, iRights, bACLRights )
    if error == 0 then
		local servers = fromJSON( responseData ).data
		
		--Сортируем по айди сервера
		table.sort( servers, SortByID_comparator )

		--Форматируем чтобы не отсылать лишних данных на клиент
		local formattedServers = {}

		for i,v in pairs(servers) do 
			formattedServers[i] = {} 
			formattedServers[i].id = v.id
			formattedServers[i].name = v.name
		end
		-- Храним в памяти
		SERVER_LIST = formattedServers
	end

	-- iprint( error, iRights, bACLRights )
	InitUI( iRights, bACLRights )
end

function RequestServerList( iRights, bACLRights )
	fetchRemote ( "https://webclient.gamecluster.nextrp.ru/online", ServerListUpdate_Callback, "", false, iRights, bACLRights )
end
addEvent( "AP:InitUI", true )
addEventHandler( "AP:InitUI", root, RequestServerList )