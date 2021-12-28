
-- Показать меню работы
function Player.ShowJobUI( self, lobby_id, job_class, is_owner )
	-- Доступные и заблокированные работы для апгрейда
	local job_level = GetAvailableJobId( self, job_class )
	if not job_level then
		self:ShowError( "Низкий уровень для данной работы" )
		return false
	end

	if self:IsNewShiftDay() then
		self:ResetShift()
		self:ResetEarnedToday()
	end

	local conf =
	{
		shift = self:GetShiftActive(),
		search_state = SEARCH_STATE_WAIT,
		available = {},
		passed = {},
        earned_today = self:GetEarnedToday( job_class ),
		job_class = job_class,
	}

	local lobby = LOBBY_LIST[ lobby_id ]
	if lobby then
		lobby:RefreshCanStart()

		conf.participants = lobby.participants
		conf.owner 		  = lobby.owner
		conf.search_state = lobby.search_state
		conf.lobby_state  = lobby.lobby_state
        conf.reward_bonus = lobby.reward_bonus
		conf.can_start 	  = lobby.can_start
		conf.search_start_timestamp = lobby.search_start_timestamp
	end
	
	conf.current_job_position = JOB_DATA[ job_class ].conf_reverse[ job_level ].position

	for i, v in pairs( JOB_DATA[ job_class ].conf ) do
		if i <= conf.current_job_position then
			conf.passed[ v.position ] = true
		elseif v.condition( self ) then
			conf.available[ v.position ] = true
		end
	end

	triggerClientEvent( self, "onClientShowCoopJobUI", resourceRoot, true, conf )
end

function Player.CheckJoinJob( self, target_job_class, marker_id )
	local job_class = self:GetJobClass()
	if job_class and job_class ~= target_job_class then
        triggerClientEvent( self, "onClientJobDismissaOpenMenu", self, true, target_job_class, marker_id )
        return false
	end
	
    return true
end

function Player.HideJobUI( self )
    triggerClientEvent( self, "onClientShowCoopJobUI", resourceRoot, false )
end

function onPlayerPreLogout_handler( )
	local lobby = GetLobbyFromElement( source )
	if not lobby then return end

	lobby:PlayerLeave( source, 
	{
		failed = true, 
		fail_text = "Ключевой участник покинул смену",
		fail_type = "player_quit",
	} )
end

function onPlayerWasted_handler( ammo, attacker, weapon_id  )
	local lobby = GetLobbyFromElement( source )
	if not lobby then return end

	triggerEvent( "onPlayerPreWastedCoopJob", source, ammo, attacker, weapon_id )
	lobby:PlayerLeave( source, 
	{
		failed = true, 
		fail_text = "Ключевой участник погиб",
		fail_type = "player_wasted",
	} )
end

function Player.StartShift( self, city )
	if self:GetShiftActive( ) then
		return false, "Ты уже на смене!"
	end

	local shift = self:GetPermanentData( "job_shift" ) or { }
	shift.last_started = getRealTimestamp()
	shift.city 		   = city
    shift.exp_sum 	   = 0
    shift.receive_sum  = 0
	shift.is_coop_job = true

	self:SetPermanentData( "job_shift", shift )
	self:SetPrivateData( "job_shift", shift )
	self:setData( "onshift", true )

	triggerEvent( "PlayerAction_StartJobShift", self )
	setElementData( self, "onshift", true )

	-- Записываем и завершаем смену в момент выхода
	removeEventHandler( "onPlayerPreLogout", self, onPlayerPreLogout_handler )
	addEventHandler( "onPlayerPreLogout", self, onPlayerPreLogout_handler )

	removeEventHandler( "onPlayerWasted", self, onPlayerWasted_handler )
	addEventHandler( "onPlayerWasted", self, onPlayerWasted_handler, true, "low-99999999" )

	return true
end

function Player.EndShift( self )
	if isElement( self ) then
		if not self:GetShiftActive( ) then
			return false
		end

		local shift = self:GetPermanentData( "job_shift" ) or { }
		local passed = getRealTimestamp( ) - shift.last_started

		shift.passed = ( shift.passed or 0 ) + passed
		shift.last_started = nil
		shift.is_coop_job = nil
		shift.exp_sum = nil
    	shift.receive_sum = nil

		self:SetPermanentData( "job_shift", shift )
		self:SetPrivateData( "job_shift", shift )

		triggerEvent( "PlayerAction_EndJobShift", self, passed )
		removeElementData( self, "onshift" )

		removeEventHandler( "onPlayerPreLogout", self, onPlayerPreLogout_handler )
		removeEventHandler( "onPlayerWasted", self, onPlayerWasted_handler )

		self:SetJobClass()
    	self:SetJobID()
	end

	return true
end

function Player.GetShiftActive( self )
	return ( self:GetPermanentData( "job_shift" ) or { } ).last_started
end

function Player.SyncShift( self )
	local shift_info = self:GetPermanentData( "job_shift" ) or { }
	shift_info.job_class = self:GetJobClass( )
	self:SetPrivateData( "job_shift", shift_info )
end

function Player.ResetShift( self )
	local time = getRealTime( getRealTime( ).timestamp - SHIFT_CHANGE_TIME )
	self:SetPermanentData( "job_shift", { started_day = { time.month, time.monthday } } )
	self:SetPrivateData( "job_shift", false )
end

function Player.IsNewShiftDay( self )
	local time = getRealTime( getRealTime( ).timestamp - SHIFT_CHANGE_TIME )
	local shift = self:GetPermanentData( "job_shift" )

	if not shift or not shift.started_day then return true end

	return shift.started_day[ 1 ] ~= time.month or shift.started_day[ 2 ] ~= time.monthday
end

function Player.GetShiftRemainingTime( self )
	if not isElement( self ) then return end

	local shift = self:GetPermanentData( "job_shift" )
	if not shift then return self:GetShiftDuration( ) end
	shift.passed = shift.passed or 0

	local time_passed
	if shift.last_started then
		time_passed = shift.passed + ( getRealTime( ).timestamp - shift.last_started )
	else
		time_passed =  shift.passed
	end

	return math.max( 0, self:GetShiftDuration( ) - time_passed )
end

function Player.ResetEarnedToday( self )
	for k, v in pairs( JOB_ID ) do
		self:SetPermanentData( v .. "_earned_today", nil )
	end
end

function Player.GetEarnedToday( self, job_class )
	return math.floor( self:GetPermanentData( JOB_ID[ job_class and job_class or self:GetJobClass() ] .. "_earned_today" ) or 0 )
end

function Player.AddEarnedToday( self, amount )
	self:AddMoneyTaskEarned( amount )
	self:SetPermanentData( JOB_ID[ self:GetJobClass() ] .. "_earned_today", self:GetEarnedToday( ) + amount )
end

function Player.IsShiftAvailable( self )
    if self:GetShiftRemainingTime( ) <= 0 then
		if self:HasAnyApartment( ) then
			self:ShowInfo( "На сегодня работы больше нет! Приходи завтра" )
		else
			self:ShowInfo( "Твоя смена на сегодня закончилась!\nПриходи завтра утром!\nЕсли желаешь работать больше, то тебе нужна квартира, которая снимает ограничения смены." )
		end
		return false
    end

    return true
end

function onCoopJobEarnMoney_handler( amount )
	source:AddEarnedToday( amount )
end
addEvent( "onCoopJobEarnMoney" )
addEventHandler( "onCoopJobEarnMoney", root, onCoopJobEarnMoney_handler )

function onServerCoopQuestCompleted_handler( lobby_id, inner_quest_vehicle_health )
	local lobby = LOBBY_LIST[ lobby_id ]
	if not lobby then return false end

	if isElement( lobby.job_vehicle ) then
		local job_vehicle_health = lobby.job_vehicle.health
		inner_quest_vehicle_health = inner_quest_vehicle_health and inner_quest_vehicle_health or 1000

		for k, v in pairs( lobby.participants ) do
			v.player:GiveJobFineByVehicleHealth( math.min( job_vehicle_health, inner_quest_vehicle_health ) )
			v.player:ResetMoneyTaskEarned( )
		end
	end

	local work_continues = true
	for k, v in pairs( lobby.participants ) do
		if not v.player:IsShiftAvailable() then
			local is_destroy = lobby:PlayerLeave( v.player,
			{
				failed = true,
				fail_text = "Ключевой участник покинул смену"
			} )
			v.player:HideJobUI()

			-- Если лобби было уничтожено
			if is_destroy then
				work_continues = false
				break 
			end
		end
	end

	if work_continues and isElement( lobby.job_vehicle ) then
		fixVehicle( lobby.job_vehicle )
    	lobby.job_vehicle:SetFuel("full")
    	triggerEvent( "PingVehicle", lobby.job_vehicle )
	end
end
addEvent( "onServerCoopQuestCompleted" )
addEventHandler( "onServerCoopQuestCompleted", root, onServerCoopQuestCompleted_handler )

function GetAvailableJobId( player, job_class )
	local job_level = false
	for k, v in pairs( JOB_DATA[ job_class and job_class or player:GetJobClass() ].conf ) do
		if v.condition( player ) then
			job_level = v.id
		end
	end
	return job_level
end