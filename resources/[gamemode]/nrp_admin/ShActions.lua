if localPlayer then
	scx,scy = guiGetScreenSize()
end

ADMIN_ACTIONS_LIST = 
{
	{
		iCategory = 1,
		sTitle = "Основные показатели",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-200, scy/2-150, 400, 300, pTarget:GetNickName(), false )
			self.data = {}
			local bars = 
			{
				{"Здоровье", getElementHealth(pTarget) or 0},
				{"Броня", getPedArmor(pTarget) or 0},
				{"Голод", pTarget:GetCalories() or 0},
			}

			local py = 60
			for k, v in pairs(bars) do
				local bar = guiCreateScrollBar( 20, py, 340, 20, true, false, self.ui )
				local label = guiCreateLabel( 20, py-20, 340, 20, v[1]..": "..math.floor(v[2]), false, self.ui)
				guiLabelSetHorizontalAlign( label, "center" ) guiLabelSetVerticalAlign( label, "center" )

				guiScrollBarSetScrollPosition( bar, v[2] )

				self.data[k] = v[2]

				py = py + 70

				addEventHandler("onClientGUIScroll", bar, function()
					local iScroll = guiScrollBarGetScrollPosition( bar )
					self.data[k] = math.floor(iScroll)
					guiSetText(label, v[1]..": "..self.data[k])
				end)
			end

			local btn_accept = guiCreateButton(20, 240, 140, 40, "Применить", false, self.ui)
			local btn_cancel = guiCreateButton(400-180, 240, 140, 40, "Отмена", false, self.ui)

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget, self.data)
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			self.data = nil
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, data )
			pTarget:SetHP( tonumber(data[1]) or 100 )
			setPedArmor( pTarget, tonumber(data[2]) or 100 )
			pTarget:SetCalories( tonumber(data[3]) or 100 )
		end
	},

	{
		iCategory = 1,
		icon = 2,
		sTitle = "Вкл/выкл бессмертие",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			local state = not pTarget:IsImmortal()
			pTarget:SetImmortal( state )
			client:ShowInfo("Бессмертие ".. (state and "включено" or "отключено"))
		end
	},

	{
		iCategory = 1,
		icon = 2,
		sTitle = "Заморозить",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			local state = not isElementFrozen(pTarget)
			if isPedInVehicle(pTarget) then
				local pVehicle = getPedOccupiedVehicle( pTarget )
				pVehicle:SetStatic(state)
			end
			setElementFrozen( pTarget, state )
			toggleAllControls( pTarget, not state )
			client:ShowInfo("Игрок ".. (state and "заморожен" or "разморожен"))
		end
	},

	{
		iCategory = 1,
		icon = 2,
		sTitle = "Телепортировать",
		iAccessLevel = ACCESS_LEVEL_HELPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )

			if pTarget:getData("in_clan_event_lobby") then
				client:ShowError("Игрок находится в ивенте банды!")
				return
			end

			local pVehicle = getPedOccupiedVehicle( pTarget )
			if pVehicle then
				pVehicle.position = client.position + Vector3(0,3,0)
				pVehicle.interior = client.interior
				pVehicle.dimension = client.dimension
			else
				pTarget.position = client.position + Vector3(0,3,0)
			end

			pTarget.interior = client.interior
			pTarget.dimension = client.dimension
		end
	},

	{
		iCategory = 1,
		icon = 2,
		sTitle = "Телепортироваться",
		iAccessLevel = ACCESS_LEVEL_HELPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			local pVehicle = getPedOccupiedVehicle( client )
			local tVehicle = getPedOccupiedVehicle( pTarget )
			if pVehicle and not tVehicle then
				pVehicle.position = pTarget.position + Vector3(0,3,0)
				pVehicle.interior = pTarget.interior
				pVehicle.dimension = pTarget.dimension
			elseif tVehicle then
				removePedFromVehicle( client )
				warpPedIntoVehicle( client, tVehicle, tVehicle:GetFreeSeat() )
			else
				client.position = pTarget.position + Vector3(0,3,0)
			end

			client.interior = pTarget.interior
			client.dimension = pTarget.dimension
		end
	},

	{
		iCategory = 1,
		icon = 2,
		sTitle = "Выдать админку",
		iAccessLevel = ACCESS_LEVEL_SUPERVISOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Выдать "..pTarget:GetNickName().." права администратора?", false )

			local edit_value = guiCreateEdit( 30, 60, 240, 30, "Причина", false, self.ui )
			local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					local value = guiGetText( edit_value )
					tryTriggerServerEvent("AP:RightsActionAttempt", localPlayer, 3, pTarget:GetUserID(), value)
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "Кик",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-75, 300, 150, "Кикнуть "..pTarget:GetNickName(), false )

			local edit = guiCreateEdit( 30, 30, 240, 30, "Причина", false, self.ui )
			local btn_accept = guiCreateButton( 40, 80, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 80, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "pkick", pTarget:GetID() .." "..guiGetText(edit))
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "Бан",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Забанить "..pTarget:GetNickName(), false )

			local edit_reason = guiCreateEdit( 30, 30, 240, 30, "Причина", false, self.ui )
			local edit_duration = guiCreateEdit( 30, 70, 240, 30, "Срок(минуты)", false, self.ui )

			local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "pban", pTarget:GetID() .." "..guiGetText(edit_duration).." "..guiGetText(edit_reason))
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "Мут",
		iAccessLevel = ACCESS_LEVEL_HELPER,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Заглушить "..pTarget:GetNickName(), false )

			local edit_reason = guiCreateEdit( 30, 30, 240, 30, "Причина", false, self.ui )
			local edit_duration = guiCreateEdit( 30, 70, 240, 30, "Срок(минуты)", false, self.ui )

			local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "pmute", pTarget:GetID() .." "..guiGetText(edit_duration).." "..guiGetText(edit_reason))
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "КПЗ",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Заключить "..pTarget:GetNickName(), false )

			local edit_reason = guiCreateEdit( 30, 30, 240, 30, "Причина", false, self.ui )
			local edit_duration = guiCreateEdit( 30, 70, 240, 30, "Срок(минуты)", false, self.ui )

			local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "jail", pTarget:GetID() .." "..guiGetText(edit_duration).." "..guiGetText(edit_reason))
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "Выпустить из КПЗ",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "unjail", pTarget:GetID())
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "Снять мут",
		iAccessLevel = ACCESS_LEVEL_HELPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "punmute", pTarget:GetID())
		end,

		fOnTriggered = function( self, pTarget )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "Из КПЗ в колонию",
		iAccessLevel = ACCESS_LEVEL_HELPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "toprison", pTarget:GetID())
		end,

		fOnTriggered = function( self, pTarget )
			-- EMPTY
		end
	},

	{
		iCategory = 2,
		icon = 2,
		sTitle = "Выпустить из тюрьмы",
		iAccessLevel = ACCESS_LEVEL_HELPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "freeprison", pTarget:GetID())
		end,

		fOnTriggered = function( self, pTarget )
			-- EMPTY
		end
	},

	{
		iCategory = 3,
		icon = 2,
		sTitle = "Выдать оружие",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			local accepted_weapons = {
				["Тайзер"] = 23,
				["Дигл"] = 24,
				["Дробовик"] = 25,
				["Обрез"] = 26,
				["Помповый дробовик"] = 27,
				["Узи"] = 28,
				["МП5"] = 29,
				["Тек-9"] = 32,
				["АК-47"] = 30,
				["М4"] = 31,
				["Ружье"] = 33,
				["Снайп.винтовка"] = 34,
				["Камера"] = 43,
				["Баллончик"] = 41,
				["Огнетушитель"] = 42,
			}

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 240, "Выдать временное оружие "..pTarget:GetNickName(), false )

			local list_weapons = guiCreateComboBox( 30, 30, 240, 100, "Выберите оружие", false, self.ui )
			for k,v in pairs(accepted_weapons) do
				guiComboBoxAddItem( list_weapons, k )
			end
			local edit_ammo = guiCreateEdit( 30, 100, 240, 30, "Кол-во патронов", false, self.ui )

			local btn_accept = guiCreateButton( 40, 160, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 160, 90, 40, "Отмена", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					local sWeapon = guiComboBoxGetItemText( list_weapons, guiComboBoxGetSelected( list_weapons ) )
					tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "weapongive", pTarget:GetID() .." "..accepted_weapons[sWeapon].." "..guiGetText(edit_ammo))
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget )
			-- EMPTY
		end
	},

	{
		iCategory = 3,
		icon = 2,
		sTitle = "Отобрать оружие",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			local accepted_weapons = {
				["Тайзер"] = 23,
				["Дигл"] = 24,
				["Дробовик"] = 25,
				["Обрез"] = 26,
				["Помповый дробовик"] = 27,
				["Узи"] = 28,
				["МП5"] = 29,
				["Тек-9"] = 32,
				["АК-47"] = 30,
				["М4"] = 31,
				["Ружье"] = 33,
				["Снайп.винтовка"] = 34,
				["Камера"] = 43,
				["Баллончик"] = 41,
				["Огнетушитель"] = 42,
			}

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 240, "Отобрать оружие у "..pTarget:GetNickName(), false )

			local list_weapons = guiCreateComboBox( 30, 30, 240, 100, "Выберите оружие", false, self.ui )
			for k,v in pairs(accepted_weapons) do
				guiComboBoxAddItem( list_weapons, k )
			end
			local edit_ammo = guiCreateEdit( 30, 100, 240, 30, "Кол-во патронов", false, self.ui )

			local btn_accept = guiCreateButton( 40, 160, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 160, 90, 40, "Отмена", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					local sWeapon = guiComboBoxGetItemText( list_weapons, guiComboBoxGetSelected( list_weapons ) )
					tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "weapontake", pTarget:GetID() .." "..accepted_weapons[sWeapon].." "..guiGetText(edit_ammo))
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget )
			-- EMPTY
		end
	},

	{
		iCategory = 3,
		icon = 2,
		sTitle = "Список оружия",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			local weapons = {}
			for i=1, 12 do
				local wep = getPedWeapon( pTarget, i )
				local ammo = getPedTotalAmmo( pTarget, i )

				if wep and wep ~= 0 and ammo then
					table.insert(weapons, { wep, getWeaponNameFromID(wep), ammo })
				end
			end

			client:outputChat("[Оружие игрока #22dd22"..pTarget:GetNickName().."#ffffff]", 255, 255, 255, true)
			for k,v in pairs(weapons) do
				client:outputChat( v[1].." ("..v[2]..") - "..v[3], 255, 255, 255 )
			end
		end
	},

	{
		iCategory = 3,
		icon = 2,
		sTitle = "Отобрать всё оружие",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			client:outputChat("Вы отобрали всё оружие у игрока #22dd22"..pTarget:GetNickName(), 255, 255, 255, true)
			pTarget:TakeAllWeapons()
		end
	},

	{
		iCategory = 4,
		icon = 2,
		sTitle = "Изменить фракцию",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Назначить фракцию "..pTarget:GetNickName(), false )

			local edit_value = guiCreateEdit( 30, 60, 240, 30, "Значение от 1 до " .. #FACTIONS_NAMES, false, self.ui )
			local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					local value = tonumber(guiGetText( edit_value ))
					if not value or value < 0 or value > #FACTIONS_NAMES then
						outputChatBox("Некорректное значение!", 200, 50, 50)
						return 
					end

					tryTriggerServerEvent("AP:ExecuteCommand", localPlayer, "setfaction", pTarget:GetID(), value)
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			-- EMPTY
		end
	},

	{
		iCategory = 4,
		icon = 2,
		sTitle = "Исключить из клана",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Исключить "..pTarget:GetNickName().." из клана?", false )

			local edit_value = guiCreateEdit( 30, 60, 240, 30, "Причина", false, self.ui )
			local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					local value = guiGetText( edit_value )
					tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget, value)
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			if not pTarget:GetClanID() then
				client:outputChat("Игрок не состоит в клане!", 50, 200, 50)
				return false
			end

			if pTarget:GetClanRole( ) == CLAN_ROLE_LEADER then
				client:outputChat("Игрока нельзя исключить, т.к. он является лидером клана!", 50, 200, 50)
				return false
			end

			client:outputChat("Вы исключили игрока "..pTarget:GetNickName().." из клана.", 50, 200, 50)
			pTarget:outputChat("Вас исключили из клана! ("..sReason..")", 200, 50, 50)
			
			triggerEvent( "onPlayerWantLeaveClan", pTarget )

			LogSlackCommand( "%s исключил игрока %s из клана по причине %s", client, pTarget, sReason )
		end
	},

	{
		iCategory = 4,
		icon = 2,
		sTitle = "Запрет кланов",
		iAccessLevel = ACCESS_LEVEL_MODERATOR,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Заблокировать доступ к кланам?", false )

			local edit_value = guiCreateEdit( 30, 60, 240, 30, "Причина", false, self.ui )
			local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					local value = guiGetText( edit_value )
					tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget, value)
					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sReason )
			local is_blocked = pTarget:GetPermanentData("clan_banned")
			client:outputChat("Вы "..(not is_blocked and "заблокировали" or "разблокировали").." игроку"..pTarget:GetNickName().." доступ к кланам.", 50, 200, 50)
			pTarget:outputChat("Вам "..(not is_blocked and "заблокировали" or "разблокировали").." доступ к кланам. ("..sReason..")", 50, 200, 50)
			
			pTarget:SetPermanentData("clan_banned", not is_blocked and sReason or false)

			LogSlackCommand( "%s "..(not is_blocked and "заблокировал" or "разблокировал").." доступ к бандам игроку %s по причине %s", client, pTarget, sReason )
		end
	},

	{
		iCategory = 5,
		icon = 2,
		sTitle = "Выдать предмет",
		iAccessLevel = ACCESS_LEVEL_DEVELOPER,

		fOnClick = function( self, pTarget )
			ShowUI(false)

			local accepted_items = {
				["Ремкомплект"] = { IN_REPAIRBOX, {} },
				["Аптечка"] = { IN_FIRSTAID, {} },
				["Канистра"] = { IN_CANISTER, {} },
				["Ланч с собой"] = { IN_FOOD_LUNCHBOX },
				["Тайзер"] = { IN_WEAPON, {23} },
				["Дигл"] = { IN_WEAPON, {24} },
				["АК47"] = { IN_WEAPON, {30} },
				["М4"] = { IN_WEAPON, {31} },
			}

			self.ui = guiCreateWindow( scx/2-150, scy/2-110, 300, 240, "Выдать предмет игроку "..pTarget:GetNickName(), false )

			local list_items = guiCreateComboBox( 30, 30, 240, 100, "Выберите предмет", false, self.ui )
			for k,v in pairs(accepted_items) do
				guiComboBoxAddItem( list_items, k )
			end
			local edit_amount = guiCreateEdit( 30, 100, 240, 30, "Количество", false, self.ui )

			local btn_accept = guiCreateButton( 40, 160, 90, 40, "Подтвердить", false, self.ui )
			local btn_cancel = guiCreateButton( 160, 160, 90, 40, "Отмена", false, self.ui )

			addEventHandler("onClientGUIClick", self.ui, function( key )
				if key ~= "left" then return end
				if source == btn_accept then
					local sItem = guiComboBoxGetItemText( list_items, guiComboBoxGetSelected( list_items ) )
					local pItem = accepted_items[sItem]

					tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget, sItem, pItem, tonumber(guiGetText(edit_amount)))

					self:Destroy()
				elseif source == btn_cancel then
					self:Destroy()
				end
			end)
		end,

		Destroy = function( self )
			if isElement(self.ui) then destroyElement( self.ui ) end
			ShowUI(true)
		end,

		fOnTriggered = function( self, pTarget, sItem, pItem, iAmount )
			pTarget:InventoryAddItem( pItem[1], pItem[2] or {}, iAmount )
			client:outputChat("Вы выдали игроку #22dd22"..pTarget:GetNickName().." #aa2222"..sItem.."(x"..iAmount..")", 200, 255, 200, true)
			WriteLog( "admin/inventory_give", "%s выдал %s предмет %s (%s шт.)", client, pTarget, sItem or "Неизв.", iAmount or 1 )
		end
	},

	{
		iCategory = 5,
		icon = 2,
		sTitle = "Скопировать к себе",
		iAccessLevel = ACCESS_LEVEL_DEVELOPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			triggerEvent("AdminForceInventoryOverwrite", root, client, pTarget)
			client:outputChat("Вы успешно скопировали себе инвентарь игрока #22dd22"..pTarget:GetNickName(), 200, 255, 200, true)
		end
	},

	{
		iCategory = 5,
		icon = 2,
		sTitle = "Передать свой игроку",
		iAccessLevel = ACCESS_LEVEL_DEVELOPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			triggerEvent("AdminForceInventoryOverwrite", root, pTarget, client)
			client:outputChat("Вы успешно скопировали свой инвентарь игроку #22dd22"..pTarget:GetNickName(), 200, 255, 200, true)
		end
	},

	{
		iCategory = 5,
		icon = 2,
		sTitle = "Очистить инвентарь",
		iAccessLevel = ACCESS_LEVEL_DEVELOPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			triggerEvent("AdminForceInventoryOverwrite", root, pTarget, {})
			client:outputChat("Вы успешно очистили инвентарь игрока #22dd22"..pTarget:GetNickName(), 200, 255, 200, true)
		end
	},

	{
		iCategory = 5,
		icon = 2,
		sTitle = "Вернуть свой настоящий",
		iAccessLevel = ACCESS_LEVEL_DEVELOPER,

		fOnClick = function( self, pTarget )
			tryTriggerServerEvent("AP:OnPlayerActionApply", localPlayer, self.id, pTarget)
		end,

		fOnTriggered = function( self, pTarget )
			if triggerEvent("AdminForceInventoryOverwrite", root, client) then
				client:outputChat("Ваш инвентарь успешно восстановлен", 200, 255, 200, true)
			else
				client:outputChat("Ваш инвентарь потерялся :C", 200, 255, 200, true)
			end
		end
	},
}

for k,v in pairs(ADMIN_ACTIONS_LIST) do
	v.id = k
end

function GetActionFromName( sName )
	for k,v in pairs(ADMIN_ACTIONS_LIST) do
		if v.sTitle == sName then
			return v
		end
	end
end