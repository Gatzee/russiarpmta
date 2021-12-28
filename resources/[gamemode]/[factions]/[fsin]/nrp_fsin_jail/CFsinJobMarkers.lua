
-- Создание маркера телепорта из камеры на улицу и обратно
function CreateToJobMarker( iJailID, iRoomID )

    if iJailID and iRoomID then
        local inside_conf = {
            x           = PRISON_ROOM_POSITIONS[ iJailID ].rooms[ iRoomID ].job_inside.x,
            y           = PRISON_ROOM_POSITIONS[ iJailID ].rooms[ iRoomID ].job_inside.y,
            z           = PRISON_ROOM_POSITIONS[ iJailID ].rooms[ iRoomID ].job_inside.z,
            dimension   = PRISON_ROOM_POSITIONS[ iJailID ].dimension,
            interior    = PRISON_ROOM_POSITIONS[ iJailID ].interior,
            radius      = 1,
            marker_text = "На работу",
            text        = "ALT Взаимодействие",
            keypress    = "lalt",
            color       = { 0, 150, 255, 50 },
        }

        local outside_conf = {
            x           = PRISON_ROOM_POSITIONS[ iJailID ].out_job_marker.x,
            y           = PRISON_ROOM_POSITIONS[ iJailID ].out_job_marker.y,
            z           = PRISON_ROOM_POSITIONS[ iJailID ].out_job_marker.z,
            dimension   = 0,
            interior    = 0,
            radius      = 2,
            marker_text = "В камеру",
            text        = "ALT Взаимодействие",
            keypress    = "lalt",
            color       = { 0, 150, 255, 50 },
        }

        CURRENT_JAIL_DATA.insidePoint = TeleportPoint( inside_conf )
        CURRENT_JAIL_DATA.outsidePoint = TeleportPoint( outside_conf )

        CURRENT_JAIL_DATA.insidePoint.element:setData( "material", true, false )
        CURRENT_JAIL_DATA.insidePoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 150, 255, 255, 0.8 } )
        
        CURRENT_JAIL_DATA.outsidePoint.element:setData( "material", true, false )
    	CURRENT_JAIL_DATA.outsidePoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 150, 255, 255, 1.55 } )

        CURRENT_JAIL_DATA.outsidePoint.PostJoin = function( self )
            OnPlayerGoToJailRoom()
            DestroyJobsMarkers()

            triggerServerEvent( "SwitchPosition", resourceRoot )
            triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Вы покинули зону задания" } )

            local position = CURRENT_JAIL_DATA.insidePoint.colshape.position
            localPlayer:Teleport( position, inside_conf.dimension, inside_conf.interior, 1000 )
        end

        CURRENT_JAIL_DATA.insidePoint.PostJoin = function( self )

            local block_job = localPlayer:getData( "block_go_to_jobs" )
            if block_job and CURRENT_JAIL_DATA.block_go_to_jobs then

                local iTimeLeft = math.max( ( CURRENT_JAIL_DATA.block_go_to_jobs - getTickCount() ) / 1000, 0 )
	            local iHours    = math.floor( iTimeLeft / 3600 )
                local iMinutes  = math.ceil(  iTimeLeft / 60 ) - iHours * 60

                localPlayer:ShowError( "Выйти из камеры можно будет через " .. iMinutes .. plural( iMinutes, " минуту", " минуты", " минут" ) ) 
                return
            end

            OnPlayerGoToJob()
            CreateJobsMarkers()

            triggerServerEvent( "SwitchPosition", resourceRoot )
            triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Вы покинули зону задания" } )

            local position = CURRENT_JAIL_DATA.outsidePoint.colshape.position
            localPlayer:Teleport( position, outside_conf.dimension, outside_conf.interior, 1000 )
        end
    else
        --("NOT_EXIST_JAIL_OR_ROOM", iJailID, iRoomID )
    end

end

JOB_MARKERS = {}

function CreateJobsMarkers()

    for _, v in pairs( POSITION_JOB_MARKERS ) do
        local conf = {
            x = v.position.x,
            y = v.position.y,
            z = v.position.z,
            dimension = v.dimension,
            interior = v.interior,
            radius = 2,
            marker_text = v.marker_text,
            text = v.text,
            color = { 130, 173, 221, 50 },
            gps = true,
            quest_state = false,
        }
        local point = TeleportPoint( conf )
        point.element:setData( "material", true, false )
        point:SetDropImage( { ":nrp_shared/img/dropimage.png", 130, 173, 221, 255, 1.55 } )
        point.PostJoin = function( self )
            if not v.quest_id then return end
            
            local block_time = localPlayer:getData( v.quest_id )
            if block_time and CURRENT_JAIL_DATA[ v.quest_id ] then

                local iTimeLeft = math.max( ( CURRENT_JAIL_DATA[ v.quest_id ] - getTickCount() ) / 1000, 0 )
	            local iHours    = math.floor( iTimeLeft / 3600 )
                local iMinutes  = math.ceil(  iTimeLeft / 60 ) - iHours * 60

                localPlayer:ShowError( "Работа будет доступна через " .. iMinutes .. plural( iMinutes, " минуту", " минуты", " минут" ) ) 

            elseif v.callback then
                v:callback()
            end
        end
        table.insert( JOB_MARKERS, point )
    end

end
addEvent( "onClientCreateJobMarkers", true )
addEventHandler( "onClientCreateJobMarkers", root, CreateJobsMarkers )

function DestroyJobsMarkers()
    for _, v in pairs( JOB_MARKERS ) do
        v:destroy()
    end
end

function DestroyToJobMarker()
    if CURRENT_JAIL_DATA.insidePoint then
        CURRENT_JAIL_DATA.insidePoint:destroy()
        CURRENT_JAIL_DATA.outsidePoint:destroy()

        CURRENT_JAIL_DATA.insidePoint = nil
        CURRENT_JAIL_DATA.outsidePoint = nil
    end
end

-- При провале квеста блокируем егго
function OnPlayerFailQuest( quest_id, time )
    CURRENT_JAIL_DATA[ quest_id ] = getTickCount() + time * 1000
    localPlayer:setData( quest_id, time, false )
end
addEvent( "prison:OnPlayerFailQuest", true )
addEventHandler( "prison:OnPlayerFailQuest", root, OnPlayerFailQuest )

-- При смерти, побеге, посадкой охранником блокируем выход из камеры
function OnPlayerBlockGoToJobs_handler( time )
    CURRENT_JAIL_DATA.block_go_to_jobs = getTickCount() + time * 1000
    localPlayer:setData( "block_go_to_jobs", time, false )
end
addEvent( "prison:OnPlayerBlockGoToJobs", true )
addEventHandler( "prison:OnPlayerBlockGoToJobs", root, OnPlayerBlockGoToJobs_handler )