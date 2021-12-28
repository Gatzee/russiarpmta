WORK_DATA = { }

pTabs[ TAB_WORK_INFO ] = {
	title = "Info",
	parent = false,
	access_level = ACCESS_LEVEL_INTERN,
	content = function( self )
		local parent = self.parent

		local sizeX, sizeY = parent:getSize( false )

		self.label = guiCreateLabel( 20, 23, 360, 25, "Укажите игровой сервер, на который высылать вашу зарплату: ", false, parent )
		
		self.server_select = guiCreateComboBox( 390, 20, 150, 210, "", false, parent )

		local servers = GetServers()
		
		if localPlayer:getData( "_srv" )[ 1 ] > 100 then
			for i = 1, 3 do
				servers[ 200 + i ] = { id = "Тестинг " .. i, name = "Тестинг " .. i }
				self.server_select:addItem (  (200 + i ) .. " - Тестинг " .. i )
			end
		else
			for i, v in ipairs( servers ) do
				self.server_select:addItem ( v.id .. " - " .. v.name )
			end
		end
		if not ADMIN_PAYOUT_INFO[ localPlayer:GetAccessLevel( ) ] then
			self.server_select.enabled = false
		end
		addEventHandler ( "onClientGUIComboBoxAccepted", self.server_select, function ( )
			local server_id = source.selected + 1
			if localPlayer:getData( "_srv" )[ 1 ] > 100 then
				server_id = 200 + server_id
			end

			if server_id == localPlayer:getData( "_srv" )[ 1 ] then
				localPlayer:ShowError( "Нельзя выбрать этот сервер" )
				self.server_select.selected = -1
				return
			end

			ShowUI( false )
			local window = guiCreateWindow( scx/2-180, scy/2-110, 360, 160, "Подтверждение", false )

			guiCreateLabel( 20, 40, 360, 25, "Вы уверены, что хотите выбрать сервер '" .. servers[ server_id ].name .. "'?", false, window )
			guiCreateLabel( 20, 65 , 360, 25, "Вы больше не сможете указать другой сервер.", false, window )
			local btn_accept = guiCreateButton( 80, 100, 90, 40, "ДА", false, window )
			local btn_cancel = guiCreateButton( 190, 100, 90, 40, "НЕТ", false, window )

			addEventHandler("onClientGUIClick", window, function()
				if source == btn_accept then
					tryTriggerServerEvent( "AP:SetPayoutServer", localPlayer, server_id )
					self.server_select.enabled = false
					destroyElement( window )
					ShowUI(true)
				elseif source == btn_cancel then
					self.server_select.selected = -1
					destroyElement( window )
					ShowUI(true)
				end
			end)
		end, false )

		self.worked_time_label = guiCreateLabel( sizeX - 180, 23, 200, 25, "", false, parent )

		function UpdateWorkedTimeLabel( reset_timer )
			if not isElement( self.worked_time_label ) then return end
			if reset_timer and isTimer( self.work_timer ) then 
				killTimer( self.work_timer ) 
			end
			local worked_time = WORK_DATA.worked_time
			local time = worked_time.month.time + worked_time.session
			self.worked_time_label.text = "Рабочий таймер: " .. getTimerString( time, true )

			if worked_time.day.time + worked_time.session >= MAX_WORKED_TIME_IN_DAY then
				if not reset_timer then
					localPlayer:ShowInfo( "Рабочий таймер остановлен, \nтак как вы отработали макс. кол-во часов за день" )
				end
				return
			end

			self.work_timer = setTimer( UpdateWorkedTimeLabel, 1000, 1 )
			worked_time.session = worked_time.session + 1
		end

		local tasks_list = guiCreateGridList( 0, 60, sizeX, sizeY-100, false, parent )
		tasks_list.sortingEnabled = false
		tasks_list:addColumn( "", 0.04 ) 
		tasks_list:addColumn( "Цель достижения", 0.45 ) 
		tasks_list:addColumn( "Награда", 0.22 )
		tasks_list:addColumn( "Время до обновления", 0.27 )
		tasks_list:setItemText( tasks_list:addRow( ), 2, "Загрузка данных...", true, false )

		function UpdateTasksList( tasks, worked_time, reports_accepted )
			tasks_list:clear( )

			for task_id, task_info in pairs( TASKS_INFO ) do
				local task = WORK_DATA.tasks[ task_id ]
				local row = tasks_list:addRow( )
				if task.completed then
					tasks_list:setItemText( row, 1, "✔", false, false )
					tasks_list:setItemColor( row, 1, 50, 255, 50 )
				end
				local value = 0
				local need_value = task_info.need_value
				if task_info.type == ADMIN_TASK_WORKED_TIME then
					value = math.floor( ( WORK_DATA.worked_time[ task_info.need_period ].time + WORK_DATA.worked_time.session ) / 60 / 60 )
					need_value = need_value / 60 / 60
				elseif task_info.type == ADMIN_TASK_REPORTS then
					value = WORK_DATA.reports_accepted[ task_info.need_period ].count + WORK_DATA.reports_accepted.session
				end
				value = task.completed and need_value or math.min( value, need_value )
				tasks_list:setItemText( row, 2, task_info.text .. " (" .. value .. "/" .. need_value .. ")", false, false )
				tasks_list:setItemText( row, 3, task_info.reward .. " донат валюты", false, false )
				tasks_list:setItemText( row, 4, getHumanTimeString( task.reset_date ), false, false )
			end
		end

		addEventHandler( "onClientGUITabSwitched", parent, function( )
			if WORK_DATA.is_loaded then
				if not WORK_DATA.tasks then return end
				UpdateTasksList( )
			else
				triggerServerEvent( "AP:RequestWorkData", localPlayer )
				WORK_DATA.is_loaded = true
			end
		end, false )
	end,
}

function ReceiveWorkData( tasks, worked_time, reports_accepted, payout_server_id )
	WORK_DATA = { 
		is_loaded = true, 
		tasks = tasks, 
		worked_time = worked_time, 
		reports_accepted = reports_accepted, 
		payout_server_id = payout_server_id or WORK_DATA.payout_server_id, 
	}

	if isElement( pTabs[ TAB_WORK_INFO ].parent ) then
		if payout_server_id and payout_server_id ~= 0 then
			if localPlayer:getData( "_srv" )[ 1 ] > 100 then
				payout_server_id = payout_server_id - 200
			end
			pTabs[ TAB_WORK_INFO ].server_select.selected = payout_server_id - 1
			pTabs[ TAB_WORK_INFO ].server_select.enabled = false
		end
		UpdateWorkedTimeLabel( true )
		UpdateTasksList( )
	end
end
addEvent( "AP:ReceiveWorkData", true )
addEventHandler( "AP:ReceiveWorkData", root, ReceiveWorkData )

function UpdateReportsAccepted( )
	if not WORK_DATA.reports_accepted then return end
	WORK_DATA.reports_accepted.session = WORK_DATA.reports_accepted.session + 1

	if isElement( pTabs[ TAB_WORK_INFO ].parent ) then
		UpdateTasksList( )
	end
end
addEvent( "AP:NewReportAccepted", true )
addEventHandler( "AP:NewReportAccepted", root, UpdateReportsAccepted )

function UpdateTaskCompleted( task_id )
	localPlayer:ShowInfo( "Вы выполнили достижение №" .. task_id .. " / " .. #TASKS_INFO )
	
	if not WORK_DATA.tasks then return end
	WORK_DATA.tasks[ task_id ].completed = true

	if isElement( pTabs[ TAB_WORK_INFO ].parent ) then
		UpdateTasksList( )
	end
end
addEvent( "AP:TaskCompleted", true )
addEventHandler( "AP:TaskCompleted", root, UpdateTaskCompleted )