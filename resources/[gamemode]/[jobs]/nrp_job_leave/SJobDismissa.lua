loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "SPlayer" )

local coop_jobs =
{
	[ JOB_CLASS_TOWTRUCKER ] = true,
	[ JOB_CLASS_INKASSATOR ] = true,
	[ JOB_CLASS_TRASHMAN ] = true,
	[ JOB_CLASS_TRANSPORT_DELIVERY ] = true,
	[ JOB_CLASS_INDUSTRIAL_FISHING ] = true,
	[ JOB_CLASS_HIJACK_CARS ] = true,
}

function onServerJobDismissa_handler( target_job_class, marker_id )
	local job_class = client:GetJobClass()

	-- С обычной работы на обычную
	if not coop_jobs[ job_class ] and not coop_jobs[ target_job_class ] then
		LeaveJob( job_class, target_job_class, client, nil, nil, marker_id )
		ShowJobUI( client, marker_id, target_job_class )

	-- С обычной работы на кооперативную
	elseif not coop_jobs[ job_class ] and coop_jobs[ target_job_class ] then
		LeaveJob( job_class, target_job_class, client, true )
		ShowCoopJobUI( client, marker_id, target_job_class )
	
	-- С кооперативной работы на кооперативную
	elseif coop_jobs[ job_class ] and coop_jobs[ target_job_class ] then
		LeaveCoopJob( client )
		ShowCoopJobUI( client, marker_id, target_job_class )
	
	-- С кооперативной работы на обычную
	elseif coop_jobs[ job_class ] and not coop_jobs[ target_job_class ] then
		LeaveCoopJob( client )
		ShowJobUI( client, marker_id, target_job_class )
	end

end
addEvent( "onServerJobDismissa", true )
addEventHandler( "onServerJobDismissa", root, onServerJobDismissa_handler )


function LeaveJob( job_class, target_job_class, player, is_coop, hide_info, marker_id  )
	triggerEvent( "onJobEndShiftRequest", player )
end
addEvent( "onServerLeaveJob" )
addEventHandler( "onServerLeaveJob", root, LeaveJob )

function LeaveCoopJob( player )
	triggerEvent( "onServerLeaveCoopJobLobby", player )
end

function ShowJobUI( player, marker_id, target_job_class )
	triggerEvent( "onServerJobInterfaceOpenRequest", player, marker_id, target_job_class )
end

function ShowCoopJobUI( player, marker_id, target_job_class )
	triggerEvent( "onServerInterfaceOpenRequest", player, marker_id, target_job_class )
end