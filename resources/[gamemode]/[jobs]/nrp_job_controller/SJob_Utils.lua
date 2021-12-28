
function Player.GetShiftRemainingTime( self )
    local shift = self:GetPermanentData( "job_shift" )

    -- Нет информации о смене - доступно полное время
    if not shift then return self:GetShiftDuration( ) end
    shift.passed = shift.passed or 0

    local time_passed
    -- Если смена начала, считаем относительно начала
    if shift.last_started then 
        time_passed = shift.passed + ( getRealTimestamp() - shift.last_started )

    -- В ином случае, считаем относительно сохраненного значения
    else
        time_passed =  shift.passed
    end

    return math.max( 0, self:GetShiftDuration( ) - time_passed )
end

function onPlayerPreLogout_handler( )
    TryToFinePlayer( source )
    source:EndShift( "exit" )
end

function onPlayerWasted_handler( )
    TryToFinePlayer( source )
    source:EndShift( "death" )
end

function OnPlayerJailed_handler( )
    TryToFinePlayer( source )
    source:EndShift( "jail" )
end

addEvent( "OnPlayerJailed", true )

-- Начать новую смену
function Player.StartShift( self, job_class, job_id, city )
    local result, err = JOB_DATA[ job_class ].conf_reverse[ job_id ].condition( self, false )
    if not result then
        return false, err
    end

    if self:getData( "current_quest" ) then
		return false, "Заверши текущую задачу!"
    end
    
    if self:GetShiftRemainingTime( ) <= 0 then
        return false, "На сегодня работы больше нет! Приходи завтра"
    end
    
    local cur_job_class = self:GetJobClass()
    -- Если уже на смене или в кооперативном лобби
    if self:GetShiftActive( ) or (cur_job_class and not JOB_DATA[ cur_job_class ]) then
        return false, "Ты уже на смене!"
    end

    self:SetJobClass( job_class )
    self:SetJobID( job_id )

    self:SetShiftID( GenerateUniqId() )

    local shift = self:GetPermanentData( "job_shift" ) or { }
    shift.last_started = getRealTimestamp()
    shift.city         = city
    shift.exp_sum      = 0
    shift.receive_sum  = 0
    shift.job_class    = job_class 
    shift.job_id       = job_id
    shift.is_coop_job  = false

    self:SetPermanentData( "job_shift", shift )
    self:SetPrivateData( "job_shift", shift )

    -- Для совместимости со старым говном
    triggerEvent( "PlayerAction_StartJobShift", self )
    setElementData( self, "onshift", true )

    -- Записываем и завершаем смену в момент выхода
    removeEventHandler( "onPlayerPreLogout", self, onPlayerPreLogout_handler )
    addEventHandler( "onPlayerPreLogout", self, onPlayerPreLogout_handler )

    removeEventHandler( "onPlayerWasted", self, onPlayerWasted_handler )
    addEventHandler( "onPlayerWasted", self, onPlayerWasted_handler )
    
    removeEventHandler( "OnPlayerJailed", self, OnPlayerJailed_handler )
    addEventHandler( "OnPlayerJailed", self, OnPlayerJailed_handler)

    if JOB_DATA[ job_class ].conf_reverse[ job_id ].on_start_shift then
        JOB_DATA[ job_class ].conf_reverse[ job_id ].on_start_shift( self )
    end

    local unique_job_analytics = UNIQUE_JOB_ANALYTICS[ job_class ]
    if unique_job_analytics and unique_job_analytics.onJobStarted then 
        unique_job_analytics.onJobStarted( self )
    else
        onJobStarted( self )
    end

    -- Для интерфейсов
    triggerClientEvent( self, "SetShiftState", resourceRoot, false, job_class )

    return true
end

-- Находится игрок на смене или нет
function Player.GetShiftActive( self )
    return ( self:GetPermanentData( "job_shift" ) or { } ).last_started
end

-- Закончить смену
function Player.EndShift( self, finish_reason )
    if not self:GetShiftActive( ) then 
        return false, "Ты не на смене чтобы завершить ее!" 
    end

    local job_class, job_id = self:GetJobClass(), self:GetJobID()
    
    local unique_job_analytics = UNIQUE_JOB_ANALYTICS[ job_class ]
    if unique_job_analytics and unique_job_analytics.onJobFinished then 
        unique_job_analytics.onJobFinished( self, finish_reason ) 
    else
        onJobFinished( self, finish_reason )
    end

    self:SetShiftID( false )

    local shift = self:GetPermanentData( "job_shift" ) or { }
    local passed = getRealTimestamp( ) - shift.last_started
    shift.passed       = ( shift.passed or 0 ) + passed
    shift.last_started = nil
    shift.job_class    = nil 
    shift.job_id       = nil
    shift.is_coop_job  = nil

    self:SetPermanentData( "job_shift", shift )
    self:SetPrivateData( "job_shift", shift )

    -- Для совместимости со старым говном
    triggerEvent( "PlayerAction_EndJobShift", self, passed )
    removeElementData( self, "onshift" )

    -- Отрубаем проверку на выход
    removeEventHandler( "onPlayerPreLogout", self, onPlayerPreLogout_handler )
    removeEventHandler( "onPlayerWasted", self, onPlayerWasted_handler )
    removeEventHandler( "OnPlayerJailed", self, OnPlayerJailed_handler )
    
    -- Для интерфейсов
    triggerClientEvent( self, "SetShiftState", resourceRoot, true, job_class )
    
    if job_class and job_id and JOB_DATA[ job_class ].conf_reverse[ job_id ].on_end_shift then
        JOB_DATA[ job_class ].conf_reverse[ job_id ].on_end_shift( self )
    end

    --Обнуляем все переменные на клиенте
    self:ResetClientData()

    self:SetJobClass()
    self:SetJobID()

    return true
end

function Player.ResetShift( self )
    local time = getRealTime( getRealTimestamp() )
    self:SetPermanentData( "job_shift", { started_day = { time.month, time.monthday } } )
    self:SetPrivateData( "job_shift", false )
end

function Player.IsNewShiftDay( self )
    local shift = self:GetPermanentData( "job_shift" )
    if not shift or not shift.started_day then return true end

    local time = getRealTime( getRealTimestamp() )
    return shift.started_day[ 1 ] ~= time.month or shift.started_day[ 2 ] ~= time.monthday
end

function Player.CheckJoinJob( self, target_job_class, marker_id )
    local job_class = self:GetJobClass( )
    if job_class and job_class ~= target_job_class then
        triggerClientEvent( self, "onClientJobDismissaOpenMenu", self, true, target_job_class, marker_id )
        return false
    elseif self:IsInFaction( ) and not self:IsOnFactionDayOff( ) then
        self:ErrorWindow( "Ты находишься во фракции, возьми отгул и приходи!" )
        return false
    end
    return true
end

function Player.ShowJobUI( self, job_class )
    local conf = {
        shift             = self:GetShiftActive( ),
        tasks             = self:GetTasks( job_class ),
        earned_today      = self:GetEarnedToday( job_class ),
        licenses_data     = job_class == JOB_CLASS_TAXI_PRIVATE and self:GetTaxiLicensesInfo( ),
        vehicles_data     = job_class == JOB_CLASS_TAXI_PRIVATE and self:GetAvailableVehicleIDs(),
        current_job_class = job_class,
        current_job_id    = self:GetAvailableJobId( job_class ),
    }

    triggerClientEvent( self, "ShowJobUI", resourceRoot, true, conf )
end

function Player.HideJobUI( self )
    triggerClientEvent( self, "ShowJobUI", resourceRoot )
end

function Player.GetAvailableJobId( self, job_class )
    if job_class == self:GetJobClass() then
        return self:GetJobID()
    end

	local job_id = false
	for k, v in pairs( JOB_DATA[ job_class and job_class or self:GetJobClass() ].conf ) do
		if v.condition( self, true ) and (not v.require_license or self:HasLicense( v.require_license )) then
			job_id = v.id
		end
	end
	return job_id
end

function Player.GetFinishedTasks( self, job_class )
    local job_id = job_class == self:GetJobClass( ) and self:GetJobID() or self:GetAvailableJobId( job_class )
    if not job_id then return {} end

    local tasks = self:GetPermanentData( job_id .. "_tasks" ) or { }
    return tasks
end

function Player.ResetFinishedTasks( self )
    for job_class, job_data in pairs( JOB_DATA ) do
        for i, task_conf in pairs( job_data.tasks ) do
            local job_id = self:GetAvailableJobId( job_class )
            
            if task_conf.cleanup then task_conf.cleanup( self, job_class, job_id ) end
            if task_conf.cleanup_full then task_conf.cleanup_full( self, job_class, job_id ) end
        end
        
        for k, v in pairs( job_data.conf ) do
            self:SetPermanentData( v.id .. "_tasks", nil )
        end
    end
end

function Player.FinishTask( self, task_id )
    local job_id = self:GetJobID()
    if not job_id then return end

    local tasks = self:GetFinishedTasks( )
    if not tasks[ task_id ] then
        tasks[ task_id ] = true
        self:SetPermanentData( job_id .. "_tasks", tasks )
    end
end

function Player.GetLastJobIdByJobClass( self, job_class )
    local job_ids_data = self:GetPermanentData( "last_job_ids_data" ) or { }
    return job_ids_data[ job_class ]
end

function Player.SetLastJobId( self, job_class, job_id )
    local job_ids_data = self:GetPermanentData( "last_job_ids_data" ) or { }
    if job_ids_data[ job_class ] == job_id then return end

    job_ids_data[ job_class ] = job_id
    return self:SetPermanentData( "last_job_ids_data", job_ids_data )
end

function Player.GetTasks( self, job_class )
    local job_id = self:GetAvailableJobId( job_class )
    local last_job_id = self:GetLastJobIdByJobClass( job_class )

    -- Reset progress when promotedd
    if last_job_id ~= job_id then
        for i, task_conf in pairs( JOB_DATA[ job_class ].tasks ) do
            if task_conf.company == last_job_id then
                if task_conf.cleanup then task_conf.cleanup( self, job_class, job_id ) end
                if task_conf.cleanup_full then task_conf.cleanup_full( self, job_class, job_id ) end
            end
        end

        self:SetLastJobId( job_class, job_id )
    end

    local finished_tasks = self:GetFinishedTasks( job_class )
    local available_tasks_list = {}
    for k, v in pairs( JOB_DATA[ job_class ].tasks ) do
        if not available_tasks_list[ v.company ] then
            available_tasks_list[ v.company ] = {}
        end
        available_tasks_list[ v.company ][ v.id ] = true
    end

    local available_tasks = available_tasks_list[ job_id ]
    local resulting_table = { }
    for i, v in pairs( available_tasks or {} ) do
        local task = JOB_DATA[ job_class ].tasks_reverse[ i ]
        if task then
            local task_progress = not finished_tasks[ i ] and task.get_progress and task:get_progress( self, job_class, job_id )
            table.insert( resulting_table, { id = i, finished = finished_tasks[ i ], progress = task_progress } )
        end
    end

    return resulting_table
end

function Player.ResetEarnedToday( self )
    for job_class, job_data in pairs( JOB_DATA ) do
        for k, v in pairs( job_data.conf ) do
            self:SetPermanentData( v.id .. "_earned_today", nil )
        end
    end
end

function Player.GetEarnedToday( self, job_class )
    local job_id = job_class == self:GetJobClass() and self:GetJobID() or self:GetAvailableJobId( job_class )
    if not job_id then return 0 end
    
    return math.floor( self:GetPermanentData( job_id .. "_earned_today" ) or 0 )
end

function Player.AddEarnedToday( self, amount )
    self:AddMoneyTaskEarned( amount )
    self:SetPermanentData( self:GetJobID() .. "_earned_today", self:GetEarnedToday() + amount )
end

function Player.ResetClientData( self )
    self:TakeWeapon( 15 )    

    local job_class, job_id = self:GetJobClass( ), self:GetJobID( )
    if job_class and job_id and JOB_DATA[ job_class ].conf_reverse[ job_id ].reset_event then
        triggerClientEvent( self, JOB_DATA[ job_class ].conf_reverse[ job_id ].reset_event, self )
    end
end

function onJobCoreEarnedMoney_handler( amount )
    source:AddEarnedToday( amount )
    onJobDailyTasksCheckRequest_handler( source )
end
addEvent( "onJobCoreEarnedMoney" )
addEventHandler( "onJobCoreEarnedMoney", root, onJobCoreEarnedMoney_handler )
