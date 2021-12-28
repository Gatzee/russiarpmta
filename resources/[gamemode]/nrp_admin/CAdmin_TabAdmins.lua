ADMINS_DATA = { }

pTabs[ TAB_ADMINS ] = {
	title = "Admins",
	parent = false,
	access_level = ACCESS_LEVEL_SUPERVISOR,
	acl_only = false,
	content = function( self )
		local sx, sy = self.parent:getSize( false )

		self.list = guiCreateGridList( 0, 20, sx, 450, false, self.parent )
		self.list:addColumn( "UserID", 0.12 )
		self.list:addColumn( "Nickname", 0.27 )
		self.list:addColumn( "Access Level", 0.1 )
		self.list:addColumn( "Time", 0.12 )
		self.list:addColumn( "Achiev", 0.05 )
		self.list:addColumn( "Rating", 0.08 )
		self.list:addColumn( "Payout", 0.15 )
		self.list:addColumn( "Online", 0.05 )

		self.UpdateAdminsGridlist = function( admins )
			self.list:clear( )

			for k, v in pairs( admins ) do
				local time = v.worked_time
				local h = math.floor( time / 60 / 60 )
				local m = math.floor( time / 60 % 60 )
				local s = math.floor( time % 60 )
				local time_str = ( "%02d:%02d:%02d" ):format( h, m, s )
				local payout_info = ADMIN_PAYOUT_INFO[ v.accesslevel ]
				local payout = not payout_info and "-" or v.payout or payout_info.value
				local row = self.list:addRow( 
					v.id, v.nickname, v.accesslevel, time_str, v.tasks_completed, 
					( "%.3f" ):format( v.rating ), payout, GetPlayer( v.id ) and "Yes" or "No" 
				)
				self.list:setItemData( row, 1, k )
			end
		end

		if localPlayer:GetAccessLevel( ) >= ACCESS_LEVEL_SUPERVISOR then
			self.btn_remove = guiCreateButton( 20, 480, 150, 50, "Обнулить права", false, self.parent )
			self.btn_set_access = guiCreateButton( 200, 480, 150, 50, "Изменить права", false, self.parent )
			self.btn_set_payout = guiCreateButton( 380, 480, 150, 50, "Изменить зарплату", false, self.parent )
			self.btn_set_refresh = guiCreateButton( 560, 480, 150, 50, "Обновить", false, self.parent )
		end

		addEventHandler( "onClientGUITabSwitched", self.parent, function( )
			triggerServerEvent( "AP:UpdateAdminsList", localPlayer )
		end, false )

		addEventHandler( "onClientGUIClick", self.parent, function( )
			local selected_i = self.list:getItemData( self.list:getSelectedItem( ), 1 )
			local selected_admin = ADMINS_DATA[ selected_i ]
			if not selected_admin then return end

			if source == self.btn_remove then
				tryTriggerServerEvent( "AP:RightsActionAttempt", localPlayer, 1, selected_admin.id )

			elseif source == self.btn_set_access then
				ShowUI( false )
				local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Изменить уровень прав " .. selected_admin.nickname, false )
				local edit_value = guiCreateEdit( 30, 60, 240, 30, selected_admin.accesslevel, false, window )
				local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, window )
				local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, window )

				addEventHandler( "onClientGUIClick", window, function( )
					if source == btn_accept then
						local value = tonumber( guiGetText( edit_value ) )
						if not value or value <= 0 then
							localPlayer:ShowError( "Некорректное значение" )
							return 
						end

						tryTriggerServerEvent( "AP:RightsActionAttempt", localPlayer, 2, selected_admin.id, value )
						destroyElement( window )
						ShowUI( true )

					elseif source == btn_cancel then
						destroyElement( window )
						ShowUI( true )
					end
				end )

			elseif source == self.btn_set_payout then
				ShowUI( false )
				local window = guiCreateWindow( scx/2-150, scy/2-110, 300, 180, "Изменить зарплату " .. selected_admin.nickname, false )
				local edit_value = guiCreateEdit( 30, 60, 240, 30, selected_admin.payout or "", false, window )
				local btn_accept = guiCreateButton( 40, 120, 90, 40, "Подтвердить", false, window )
				local btn_cancel = guiCreateButton( 160, 120, 90, 40, "ОТМЕНА", false, window )

				addEventHandler( "onClientGUIClick", window, function( )
					if source == btn_accept then
						local value = tonumber( guiGetText( edit_value ) )
						if not value or value <= 0 then
							localPlayer:ShowError( "Некорректное значение" )
							return 
						end

						tryTriggerServerEvent( "AP:ChangeAdminPayout", localPlayer, selected_admin.id, value )
						destroyElement( window )
						ShowUI( true )

					elseif source == btn_cancel then
						destroyElement( window )
						ShowUI( true )
					end
				end )
			elseif source == self.btn_set_refresh then
				tryTriggerServerEvent( "AP:UpdateAdminsList", localPlayer )
			end
		end )
	end,
}

function ReceiveAdminsList( data )
	ADMINS_DATA = data
	if isElement( pTabs[ TAB_ADMINS ].list ) then
		pTabs[ TAB_ADMINS ].UpdateAdminsGridlist( data )
	end
end
addEvent( "AP:ReceiveAdminsList", true )
addEventHandler( "AP:ReceiveAdminsList", root, ReceiveAdminsList )