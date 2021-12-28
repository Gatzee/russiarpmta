CURRENT_QUEST_INFO = nil
CEs = {}
GEs = {}

function CQuestCoop( data )
	local self = data
	
	self.SetupTask = function( self, task )
		if task.Setup and task.Setup.client then
			local setup_event_name = self.id .."_".. task.id .."_SetupClient"

			addEvent( setup_event_name, true )
			addEventHandler( setup_event_name, root, function( lobby_data )
				LOBBY_DATA = lobby_data
				local role_id = localPlayer:getData( "coop_job_role_id" )
				if task.Setup.client[ role_id ].fn then
					task.Setup.client[ role_id ].fn( lobby_data )
				end
			end )
		end

		local cleanup_event_name = self.id .."_".. task.id .."_CleanUpClient"

		addEvent( cleanup_event_name, true)
		addEventHandler( cleanup_event_name, root, function( reason_data )
			if task.CleanUp and task.CleanUp.client then
				task.CleanUp.client( reason_data )
			end

			DestroyClientElements()
			if reason_data and reason_data.failed and reason_data.fail_text then
				DestroyTableElements( GEs )
				GEs = { }
				LOBBY_DATA = nil
				
				if reason_data.fail_type == "quest_end_job_shift" then
					triggerEvent( "ShowPlayerUIQuestSuccess", root )
				else
					triggerEvent( "ShowPlayerUIQuestFailed", root, reason_data.fail_text, self.id )
				end
			end
		end )

	end

	self.onAnyFinishQuest = function( reason_data, lobby_data )
		if self.OnAnyFinish and self.OnAnyFinish.client then
			self.OnAnyFinish.client( reason_data, lobby_data )
		end
		DestroyTableElements( GEs )
		GEs = { }
		LOBBY_DATA = nil
	end
	addEvent( self.id .. "_OnAnyFinish", true )
	addEventHandler( self.id .. "_OnAnyFinish", root, self.onAnyFinishQuest )

	self.onResourceStop = function()
		triggerEvent( "RemoveClientCoopQuestInfo", root, self.id )

		if localPlayer:IsInGame() then
			local quests_data = localPlayer:GetQuestsData()
			local current_quest = localPlayer:getData( "current_quest" )

			if current_quest and current_quest.id == self.id then
				local task = self.tasks[ quests_data.task ]
				if not task then return end

				triggerEvent( self.id .."_".. task.id .."_CleanUpClient", resourceRoot )
				setCameraTarget( localPlayer )
			end
		end
	end
	addEventHandler( "onClientResourceStop", resourceRoot, self.onResourceStop )

	CURRENT_QUEST_INFO = 
	{
		id = self.id;
		title = self.title;
		description = self.description;
		rewards = self.rewards;

		func_CheckToStart = self.CheckToStart;
		func_HideCondition = self.HideCondition;

		tasks = {};
	}

	for i, task in pairs( self.tasks ) do
		task.id = i
		self:SetupTask( task )

		for task_role_id, task_data in pairs( task.Setup.client ) do
			if not CURRENT_QUEST_INFO.tasks[ i ] then
				CURRENT_QUEST_INFO.tasks[ i ] = {}
			end

			CURRENT_QUEST_INFO.tasks[ i ][ task_role_id ] = task_data.name
		end
	end

	triggerEvent( "AddClientCoopQuestInfo", source, self.id, CURRENT_QUEST_INFO )

	local max_players = 0
	for k, v in pairs( QUEST_DATA.roles ) do
	    max_players = max_players + v.max_count
	end
	
	QUEST_DATA.max_players = max_players

	return self
end

function GetLobbyPlayersByRole( lobby_data, role, is_single )
	local players = {}
	for k, v in pairs( lobby_data.participants ) do
		if v.role == role then
			if is_single then return v.player end
			table.insert( players, v.player )
		end
	end

	return players
end

-----------------------------------------------------------------------------
-- Вспомогательный функционал
-----------------------------------------------------------------------------

function GetQuestInfo( check_to_start, check_hide_condition )
	if check_hide_condition then
		if CURRENT_QUEST_INFO.func_HideCondition and not CURRENT_QUEST_INFO.func_HideCondition( localPlayer ) then return end
	end
	if check_to_start then
		if not CURRENT_QUEST_INFO.func_CheckToStart or CURRENT_QUEST_INFO.func_CheckToStart( localPlayer ) then
			return CURRENT_QUEST_INFO
		end
	else
		return CURRENT_QUEST_INFO
	end
end

function CreateQuestPoint(position, callback_func, name, radius, interior, dimension, check_func, keypress, keytext, marker_type, r, g, b, a, slowdown_coefficient )
	name = name or "marker"

	CEs[name] = TeleportPoint( 
		{ 
			x = position.x, y = position.y, z = position.z, 
			radius = radius or 4,
			gps = true,
			quest_state = false,
			keypress = keypress or false, text = keytext or false, 
			interior = interior or localPlayer.interior, 
			dimension = dimension or localPlayer.dimension 
		}
	)

	CEs[name].slowdown_coefficient = slowdown_coefficient
	CEs[name].accepted_elements = { player = true, vehicle = true }
	CEs[name].marker.markerType = marker_type or "checkpoint"
	CEs[name].marker:setColor( r or 130, g or 173, b or 221, a or 150 )
	CEs[name].elements = {}
	CEs[name].elements.blip = createBlipAttachedTo(CEs[name].marker, 41, 5, 250, 100, 100)
	CEs[name].elements.blip.position = CEs[name].marker.position
	CEs[name].elements.blip:setData( "extra_blip", 81, false )

	triggerEvent( "RefreshRadarBlips", localPlayer )

	if type( callback_func ) == "function" then
		CEs[name].PostJoin = callback_func
		CEs[name].PreJoin = check_func
	elseif type( callback_func ) == "string" then
		CEs[name].PostJoin = function()
			if not check_func or check_func() then
				CEs[name].destroy()
				triggerEvent( "RefreshRadarBlips", localPlayer )
				triggerServerEvent( callback_func, localPlayer )
			end
		end
	end
end

function StartQuestTimerWait( time, name, success_callback, fail_callback, func_succ )
	if isTimer( CEs._timer_wait ) then killTimer( CEs._timer_wait ) end
	
	CEs._timer_wait = Timer( function( )
		localPlayer:setData( "CoopQuestTimerFail", false, false )

		local success = true
		if func_succ then
			success = func_succ( )
		end

		if success and success_callback then
			success_callback()
		elseif not success and fail_callback then
			fail_callback()
		end
	end, time, 1 )

	localPlayer:setData( "CoopQuestTimerFail", { name, math.floor( time / 1000 )  }, false )
end

function DestroyClientElements( )
	DestroyTableElements( CEs )
	CEs = { }

	showCursor(false)
end

function FailCurrentQuest( reason, reason_type )
	triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = reason_type or "quest_fail", fail_text = reason } )
end

function CheckFailIfVehicle()
	if isElement( localPlayer.vehicle ) then
		localPlayer:ShowError( "Покинь транспортное средство" )
		return false
	end
	return true
end

function CheckFailNotVehicle()
	if not isElement( localPlayer.vehicle ) then
		localPlayer:ShowError( "Вы не в транспортном средстве" )
		return false
	end
	return true
end

--------------------------------------------------------------------------
-- Проверка на удаленность игрока от тачки
--------------------------------------------------------------------------

function TryStartCheckDistanceElementTimer( target_element, max_distance, time, warning_text, fail_text )
	if isTimer( GEs.CHECK_DISTANCE_TMR ) then return end

	target_element = target_element or localPlayer:getData( "job_vehicle" )
	max_distance = max_distance or 50
	time = time or 30 * 1000
	warning_text = warning_text or "Вернитесь к служебной машине или ваша смена будет закончена через:"
	fail_text = fail_text or "слишком далеко удалился от служебной машины"

	GEs.CHECK_DISTANCE_TMR = setTimer( function()
		if isElement( target_element ) and (target_element.position - localPlayer.position).length > max_distance then
			if isTimer( GEs.FAIL_TMR ) then return end
			StartFailTimer( time, warning_text, fail_text )
		else
			StopFailTimer()
		end
	end, 5000, 0 )
end

function StopCheckDistanceTimer()
	if isTimer( GEs.CHECK_DISTANCE_TMR ) then
		killTimer( GEs.CHECK_DISTANCE_TMR )
	end
	StopFailTimer()
end

function StartFailTimer( time, warning_text, fail_text )
	StopFailTimer()
	
	GEs.FAIL_TIME_MS = time
	
	if isTimer( GEs.FAIL_TMR ) then return end
	GEs.FAIL_TMR = setTimer( function()
		StopFailTimer()
		triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, fail_text )
	end, GEs.FAIL_TIME_MS, 1 )

	GEs.FAIL_TEXT_AREA = ibCreateArea( 0, 0, 0, 0 ):center( 0, _SCREEN_Y / 3 )
	ibCreateLabel( 0, -40, 0, 0, warning_text, GEs.FAIL_TEXT_AREA, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
		:ibData( "outline", 1 )

	local func_interpolate = function( self )
		self:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
		end, 350, "SineCurve" )
	end

	local FAIL_TIME_SEC = GEs.FAIL_TIME_MS / 1000
	ibCreateLabel( 0, 0, 0, 0, FAIL_TIME_SEC .. " сек", GEs.FAIL_TEXT_AREA, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
		:ibData( "timestamp", getRealTimestamp() + FAIL_TIME_SEC )
		:ibData( "outline", 1 )
		:ibTimer( func_interpolate, 100, 1 )
		:ibTimer( function( self )
			func_interpolate( self )
			local timestamp = self:ibData( "timestamp" )
			if timestamp then
				self:ibData( "text", (timestamp - getRealTimestamp()) .. " сек" )
			end
		end, 1000, 0 )
end

function StopFailTimer()
	if isTimer( GEs.FAIL_TMR ) then
		killTimer( GEs.FAIL_TMR )
	end
	if isElement( GEs.FAIL_TEXT_AREA ) then
		destroyElement( GEs.FAIL_TEXT_AREA )
	end
end

function WatchElementCondition( element, conf )
	local self = {
		element = element,
	}

	local function on_destroy( )
		self:destroy( )
	end

	self.destroy = function( )
		if isTimer( self.timer ) then killTimer( self.timer ) end
		if isElement( element ) then
			removeEventHandler( "onClientElementDestroy", element, on_destroy )
		end
	end

	local function check_condition( )
		if conf.condition then
			local result = conf.condition( self, conf )
			if result == true then
				self:destroy( )
			end
		end
	end

	self.timer = setTimer( check_condition, conf.interval or 1000, 0 )
	addEventHandler( "onClientElementDestroy", element, on_destroy )

	return self
end