Extend( "SPlayer" )
Extend( "SVehicle" )

function onServerJobInterfaceOpenRequest_handler( marker_id, job_class )
    if not JOB_DATA[ job_class ] or not JOB_DATA[ job_class ].marker_postions[ marker_id ] then return end

    local player = client or source
    if not player:CheckJoinJob( job_class, marker_id ) then return end

    if player:IsNewShiftDay( ) then
        if player:GetOnShift() then
            triggerEvent( "onJobEndShiftRequest", player, { type = "quest_end_job_shift", fail_text = "Ты завершил смену" } )
        end

        player:ResetShift( )
        player:ResetFinishedTasks( )
        player:ResetEarnedToday( )
    end

    local marker = JOB_DATA[ job_class ].marker_postions[ marker_id ]
    if marker and marker.fn then
        local result, err = marker.fn( player, job_class )
        if not result then
            player:ErrorWindow( err )
            return false
        end
    end

    player:ShowJobUI( job_class )
end
addEvent( "onServerJobInterfaceOpenRequest", true )
addEventHandler( "onServerJobInterfaceOpenRequest", root, onServerJobInterfaceOpenRequest_handler )

function onJobStartShiftRequest_handler( job_class, city )
    if not JOB_DATA[ job_class ] or not tonumber( city ) then return end

    local player = client or source
    local job_id = player:GetAvailableJobId( job_class )
    if not job_id then 
        local f_company_data = JOB_DATA[ job_class ].conf[ 1 ]
        local f_company_condition, err_msg = f_company_data.condition( player )
        if f_company_condition and f_company_data.require_license and not player:HasLicense( f_company_data.require_license ) then
            err_msg = GetHintAboutLackLicense( f_company_data.require_license )
        end
        if err_msg then player:ShowError( err_msg ) end
        return false 
    end

    if JOB_DATA[ job_class ].conf_reverse[ job_id ].pre_start_check and not JOB_DATA[ job_class ].conf_reverse[ job_id ].pre_start_check( player ) then
        return false
    end

    local result, err = player:StartShift( job_class, job_id, city )
    if result and not err then
        if JOB_DATA[ job_class ].conf_reverse[ job_id ].require_vehicle then
            CreateJobVehicle( player, city )
        end

        player:HideJobUI()
        setTimer( onJobRequestAnotherTask_handler, 50, 1, player, true )


        player:CompleteDailyQuest( "start_shift" )
        player:CompleteDailyQuest( "np_start_shift" )

        triggerEvent( "onPlayerSomeDo", player, "start_work" ) -- achievements
    else
        player:ErrorWindow( err )
    end
end
addEvent( "onJobStartShiftRequest", true )
addEventHandler( "onJobStartShiftRequest", root, onJobStartShiftRequest_handler )

function onJobEndShiftRequest_handler( reason_data )
    local player = getElementType( source ) == "player" and source or client
    
    local job_class, job_id = player:GetJobClass(), player:GetJobID()
    local result, err = player:EndShift( "finish" )
    if result and not err then
        player:SetPermanentData( JOB_ID[ job_class ] .. "_ended_shift", true )
        
        TryToFinePlayer( player )
        
        local fail_type, fail_text = "quest_fail", nil
        if type( reason_data ) == "table" then
            fail_type = reason_data.type or fail_type
            fail_text = reason_data.fail_text or fail_text
        
        elseif type( reason_data ) == "string" then
            fail_text = reason_data
        end

        triggerEvent( "PlayerFailStopQuest", player, { type = fail_type, fail_text = fail_text } )
    else
        player:ErrorWindow( err )
    end
end
addEvent( "onJobEndShiftRequest", true )
addEventHandler( "onJobEndShiftRequest", root, onJobEndShiftRequest_handler )

function onJobRequestAnotherTask_handler( player, is_start_shift )
    local player = player or source
    if player:GetShiftRemainingTime( ) <= 0 then
        if player:GetShiftActive( ) then player:EndShift( "finish" ) end
        return false, player:HasAnyApartment( true ) and "" or "Твоя смена на сегодня закончилась!\nПриходи завтра утром!\nЕсли желаешь работать больше, то тебе нужна квартира, которая снимает ограничения смены."
    end
    
    if not player:GetShiftActive( ) then
        return false, "Ты не на смене!"
    end

    local job_class = player:GetJobClass()
    local job_id = player:GetJobID( )
    local job_data = JOB_DATA[ job_class ]
    local job_conf = job_data.conf_reverse[ job_id ]

    local vehicle = player:getData( "job_vehicle" )
    if isElement( vehicle ) and job_conf.destroy_vehicle_restart then
        
        destroyElement(vehicle)
    elseif isElement( vehicle ) then
        TryToFinePlayer( player, vehicle )
        fixVehicle( vehicle )
        vehicle:SetFuel("full")

        triggerEvent( "PingVehicle", vehicle )
    end
    
    if not is_start_shift then
        for i, task in pairs( job_conf.tasks ) do
            if task.fn_finish then
                task.fn_finish( player )
            end
        end
    end

    if job_conf.pre_start then
        job_conf.pre_start( player )
    end

    if type( job_conf.event ) == "table" then
        triggerEvent( job_conf.event[ math.random(1, #job_conf.event)], player )
    elseif job_conf.event then
        triggerEvent( job_conf.event, player )
    end
end
addEvent( "onJobRequestAnotherTask", true )
addEventHandler( "onJobRequestAnotherTask", root, onJobRequestAnotherTask_handler )

function TryToFinePlayer( player, vehicle )
    if player:GetShiftActive( ) then
        local quest_vehicle = vehicle or player:getData( "job_vehicle" )
        if isElement( quest_vehicle ) then
            local fine_sum = player:GiveJobFineByVehicleHealth( quest_vehicle.health )
            if fine_sum > 0 then
                local shift = player:GetPermanentData( "job_shift" )
                shift.receive_sum = shift.receive_sum - fine_sum
                player:SetPermanentData( "job_shift", shift )
            end
        end
    end
    player:ResetMoneyTaskEarned( )
end



function onFarmerEndHelperQuest_handler( player )
    if not isElement( player ) then return end
    
    if not player:GetShiftActive( ) then
        return false, "Ты не на смене!"
    end

    local shift = player:GetPermanentData( "job_shift" )
    CreateJobVehicle( player, shift.city )
end
addEvent( "onFarmerEndHelperQuest" )
addEventHandler( "onFarmerEndHelperQuest", root, onFarmerEndHelperQuest_handler )


function onTaxiKillPed_handler( )
    TryToFinePlayer( client )

	client:SetPermanentData( client:GetJobClass() .. "_ended_shift", true )
	client:EndShift( "kill_ped" )
	triggerEvent( "PlayerFailStopQuest", client, { type = "quest_fail", fail_text = "Не убивай граждан, ты не алкоголизм" } )
end
addEvent( "onTaxiKillPed", true )
addEventHandler( "onTaxiKillPed", root, onTaxiKillPed_handler )

function onDriverRouteFail_handler( )
	TryToFinePlayer( client )
	
    client:SetPermanentData( client:GetJobClass() .. "_ended_shift", true )
	client:EndShift( "didnt_follow_route" )
	triggerEvent( "PlayerFailStopQuest", client, { type = "quest_fail", fail_text = "Ты не следовал маршруту" } )
end
addEvent( "onDriverRouteFail", true )
addEventHandler( "onDriverRouteFail", root, onDriverRouteFail_handler )

function onStop()
    for k, v in pairs( getElementsByType( "player" ) ) do
        local shift = v:GetPermanentData( "job_shift" ) or { }
        if shift.is_coop_job == false and shift.last_started then
            local passed = getRealTimestamp( ) - (shift.last_started or 0)
            shift.passed       = ( shift.passed or 0 ) + passed
            shift.last_started = nil
            shift.is_coop_job  = nil
            shift.job_class    = nil 
            shift.job_id       = nil

            v:SetPermanentData( "job_shift", shift )
            v:SetPrivateData( "job_shift", shift )

            if v:GetShiftActive( )  then
                triggerEvent( "onJobEndShiftRequest", v, "Работа была приостановлена сервером\nПриносим свои извинения" )
            end

            v:SetJobClass()
            v:SetJobID()
        end
    end
end
addEventHandler( "onResourceStop", resourceRoot, onStop )