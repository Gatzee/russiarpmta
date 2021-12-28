function onJobDailyTasksCheckRequest_handler( player )
    local job_class = player:GetJobClass()
    if not JOB_DATA[ job_class ] then return end
    
    local tasks = player:GetTasks( job_class )
    for i, v in pairs( tasks ) do
        if not v.finished then
            ParseTask( player, v.id )
        end
    end
end
addEvent( "onJobDailyTasksCheckRequest", true )
addEventHandler( "onJobDailyTasksCheckRequest", root, onJobDailyTasksCheckRequest_handler )

function ParseTask( player, id )
    local job_class, job_id = player:GetJobClass(), player:GetJobID()
    local task = JOB_DATA[ job_class ].tasks_reverse[ id ]

    if task.check and task.check( player, job_class, job_id ) then
        player:FinishTask( task.id )
        if task.cleanup then task.cleanup( player ) end

        local reward = type( task.reward ) == "number" and task.reward or ( type( task.reward ) == "table" and task.reward[ job_id ] or task.reward[ 1 ] )
        reward = player:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyTaskMul * reward or reward
        player:GiveMoney( reward, "job_daily_task", JOB_ID[ job_class ] )
        player:outputChat( "Ты завершил задачу: " .. utf8.gsub( task.text, "\n", " " ) .. " [+" .. reward .. " р.]", 0, 255, 0 )
        player:AddEarnedToday( reward )

        triggerEvent( "onJobEarnMoney", player, job_class, reward, "Ежедневная задача", 0 ) -- Для аналитики

        return reward
    end
end

function Player.increment( self, key, value )
    self:SetPermanentData( key, ( self:GetPermanentData( key ) or 0 ) + ( value or 1 ) )
end

-- ДАЛЬНОБОЙЩИК: Разгрузиться в точках
function TruckerDaily_AddDelivery_handler( )
    local player = client or source
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.deliveries_2 or not finished_tasks.deliveries_3 or not finished_tasks.deliveries_4 then
        player:increment( "t_deliveries_counter" )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "TruckerDaily_AddDelivery", true )
addEventHandler( "TruckerDaily_AddDelivery", root, TruckerDaily_AddDelivery_handler )

-- ТАКСИ: Доставка пассажира
function TaxiDaily_AddDelivery_handler( meters_pickup, meters_delivery )
    local player = client or source
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.meters_5000 then
        player:increment( "tx_deliveries_meters", meters_pickup + meters_delivery )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "TaxiDaily_AddDelivery", true )
addEventHandler( "TaxiDaily_AddDelivery", root, TaxiDaily_AddDelivery_handler )

-- ТАКСИ-ЧАСТНИК: Проехал дистанцию
function TaxiPrivateDaily_AddDistance_handler( driver, distance, money )
    local player = driver
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.meters_3000 then
        player:increment( "txp_deliveries_meters", distance )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "TaxiPrivateDaily_AddDistance", true )
addEventHandler( "TaxiPrivateDaily_AddDistance", root, TaxiPrivateDaily_AddDistance_handler )

-- ТАКСИ-ЧАСТНИК: Доставил пассажира
function TaxiPrivateDaily_AddDelivery_handler( money )
    local player = client or source
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.passengers_20 then
        player:increment( "txp_deliveries_count" )
        onJobDailyTasksCheckRequest_handler( player )
    end
    if not finished_tasks.money_1000 then
        player:AddEarnedToday( money )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "TaxiPrivateDaily_AddDelivery" )
addEventHandler( "TaxiPrivateDaily_AddDelivery", root, TaxiPrivateDaily_AddDelivery_handler )

-- ГРУЗЧИК: Доставка коробки
function LoaderDaily_AddBox_handler( )
    local player = client or source
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.loads_20 and not finished_tasks.loads_30 then
        player:increment( "l_loads_counter" )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "LoaderDaily_AddBox" )
addEventHandler( "LoaderDaily_AddBox", root, LoaderDaily_AddBox_handler )


-- РАБОТНИК_ЖКХ: Починил объект
function onHcsFinishedCutting_handler()
    local repair_obj_count = source:GetPermanentData( "m_repair_objects" ) or 0
    source:SetPermanentData( "m_repair_objects", repair_obj_count + 1 )
end
addEvent( "onHcsFinishedCutting", true )
addEventHandler( "onHcsFinishedCutting", root, onHcsFinishedCutting_handler )


-- ФЕРМЕР: Посадка растения
function FarmerDaily_AddPutPlant_handler( )
    local finished_tasks = client:GetFinishedTasks( )
    if not finished_tasks.put_plants_30 then
        client:increment( "f_plants_put_counter" )
        onJobDailyTasksCheckRequest_handler( client )
    end
end
addEvent( "FarmerDaily_AddPutPlant", true )
addEventHandler( "FarmerDaily_AddPutPlant", root, FarmerDaily_AddPutPlant_handler )

-- ФЕРМЕР: Раскапывание растения
function FarmerDaily_AddPlant_handler( )
    local finished_tasks = client:GetFinishedTasks( )
    if not finished_tasks.plants_20 then
        client:increment( "f_plants_counter" )
        onJobDailyTasksCheckRequest_handler( client )
    end
end
addEvent( "FarmerDaily_AddPlant", true )
addEventHandler( "FarmerDaily_AddPlant", root, FarmerDaily_AddPlant_handler )

-- ФЕРМЕР: Относ ящика
function FarmerDaily_AddBox_handler( )
    local finished_tasks = client:GetFinishedTasks( )
    if not finished_tasks.boxes_2 then
        client:increment( "f_boxes_counter" )
        onJobDailyTasksCheckRequest_handler( client )
    end
end
addEvent( "FarmerDaily_AddBox", true )
addEventHandler( "FarmerDaily_AddBox", root, FarmerDaily_AddBox_handler )

-- ФЕРМЕР: Продажа ящика
function FarmerDaily_AddSell_handler( )
    local finished_tasks = client:GetFinishedTasks( )
    if not finished_tasks.sell_5 then
        client:increment( "f_sell_counter" )
        onJobDailyTasksCheckRequest_handler( client )
    end
end
addEvent( "FarmerDaily_AddSell", true )
addEventHandler( "FarmerDaily_AddSell", root, FarmerDaily_AddSell_handler )


-- ВОДИТЕЛЬ: Завершение маршрута
function DriverDaily_AddRoute_handler( )
    local player = client or source
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.routes_3 or not finished_tasks.routes_4 or not finished_tasks.routes_5 then
        player:increment( "d_routes_counter" )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "DriverDaily_AddRoute", true )
addEventHandler( "DriverDaily_AddRoute", root, DriverDaily_AddRoute_handler )


-- КУРЬЕР: Отвозка / относ коробки
function CourierDaily_AddDelivery_handler( )
    local player = client or source
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.deliveries_20 or not finished_tasks.deliveries_30 then
        player:increment( "c_deliveries_counter" )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "CourierDaily_AddDelivery", true )
addEventHandler( "CourierDaily_AddDelivery", root, CourierDaily_AddDelivery_handler )

-- ПИЛОТ: Доставка
function PilotDaily_AddDelivery_handler( )
    local player = client or source
    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.deliveries_2 or not finished_tasks.deliveries_3 or not finished_tasks.deliveries_4 then
        player:increment( "p_deliveries_counter" )
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "PilotDaily_AddDelivery", true )
addEventHandler( "PilotDaily_AddDelivery", root, PilotDaily_AddDelivery_handler )


-- МЕХАНИК: Осмотрел, починил авто 
function MechanicDaily_AddDetails_handler( count_details )
    local player = client
    if not isElement( player ) then return end

    local job_class = player:GetJobClass()
    if job_class ~= JOB_CLASS_MECHANIC or not player:GetOnShift() then return end

    local finished_tasks = player:GetFinishedTasks( )
    if not finished_tasks.repl_2be or not finished_tasks.repl_5be then
        
        player:increment( JOB_ID[ job_class ] .. "_find_details", count_details )
        player:increment( JOB_ID[ job_class ] .. "_repl_details", count_details )
        
        onJobDailyTasksCheckRequest_handler( player )
    end
end
addEvent( "MechanicDaily_AddDetails", true )
addEventHandler( "MechanicDaily_AddDetails", root, MechanicDaily_AddDetails_handler )