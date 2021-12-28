
local IGNORE_FADE_CAMERA_JOBS =
{
	[ JOB_CLASS_INDUSTRIAL_FISHING ] = true,
}


-- Создание эвакуатора
function CreateJobVehicle( lobby )
	local vehicle_data = JOB_DATA[ lobby.owner:GetJobClass() ].vehicle_data[ lobby.city ]
	local spawn_info = vehicle_data.positions[ math.random( 1, #vehicle_data.positions ) ]
	local allowed_formated = { }
	local all_controllers_formated = { }

	for _, v in ipairs( lobby.participants ) do
		table.insert( all_controllers_formated, v.player )
		allowed_formated[ v.player ] = true
	end

	triggerEvent( "CreateJobVehicleRequest", lobby.owner,
	{
		position = spawn_info.position,
		rotation = spawn_info.rotation,
		model = vehicle_data.vehicle_model,
		block_repair = vehicle_data.block_repair,

		max_idle = (vehicle_data.idle_time or 15) * 60000,
		destroy_on_shift_end = false,
		damage_threshold = 400,
		
		allowed_players = allowed_formated,
		all_controllers = all_controllers_formated,
		ignore_warp_vehicle = vehicle_data.ignore_warp_vehicle,

		callback_event = "onCoopJobVehicleCreated",
	} )
end

function warpPedIntoVehicle_delayed( controller, vehicle, job_class )
	if not isElement( controller ) then return end
	
	if not IGNORE_FADE_CAMERA_JOBS[ job_class ] then
		fadeCamera( controller, true, 0.5 )
	end

	if not isElement( vehicle ) then return end

	local lobby = GetLobbyFromElement( controller )
	if not lobby or lobby.lobby_id ~= vehicle:getData( "work_lobby_id" ) then return end
	removePedFromVehicle( controller )

	local player_role = controller:GetJobRole()
	local role_data = lobby.roles[ player_role ]
	if (role_data.license or role_data.is_driver) and (not role_data.priority_seat or role_data.priority_seat == 0) then
		warpPedIntoVehicle( controller, vehicle, vehicle.occupants[ 0 ] and #vehicle.occupants + 1 or 0 )
	else
		warpPedIntoVehicle( controller, vehicle, #vehicle.occupants + 1 )
	end
	
	setCameraTarget( controller )
end

function onCoopJobVehicleCreated_handler( vehicle, data )
	vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )

	local lobby = GetLobbyFromElement( data.player, true )
	local job_class = lobby.owner:GetJobClass()

	for k, controller in ipairs( data.all_controllers ) do
		if not data.ignore_warp_vehicle then
			if not IGNORE_FADE_CAMERA_JOBS[ job_class ] then
				fadeCamera( controller, false, 0.5 )
			end
			setTimer( warpPedIntoVehicle_delayed, 1000, 1, controller, vehicle, job_class )
		end

		controller:SetPrivateData( "job_vehicle", vehicle )
	end

	local vehicle_data = JOB_DATA[ job_class ].vehicle_data[ lobby.city ]
	if vehicle_data.apply_fn then vehicle_data.apply_fn( vehicle ) end

	vehicle:setData( "work_lobby_id", lobby.lobby_id, false )
	if JOB_DATA[ job_class ].company_name == "tow" then
		vehicle:setData( "ignore_removal", true, false )
	end

	lobby:AddJobVehicle( vehicle )

	addEventHandler( "onJobVehicleDamage", vehicle, function( data )
		local lobby = GetLobbyFromElement( vehicle )
		if lobby then
			for k, v in pairs( lobby.participants ) do
				v.player:GiveJobFineByVehicleHealth( vehicle.health )
			end
			
			lobby:Destroy( true, 
			{ 
				failed = true, 
				fail_text = "Рабочая машина была разбита",
				fail_type = "vehicle_destroy",
			} )
		end
	end )

	addEventHandler( "onJobVehicleIdle", vehicle, function( data ) 
		local lobby = GetLobbyFromElement( vehicle )
		if lobby then
			for k, v in pairs( lobby.participants ) do
				v.player:GiveJobFineByVehicleHealth( vehicle.health )
			end
			
			lobby:Destroy( true, 
			{ 
				failed = true, 
				fail_text = "Рабочая машина была забрана за бездействие",
				fail_type = "vehicle_idle",
			} )
		end
    end )
end
addEvent( "onCoopJobVehicleCreated", true )
addEventHandler( "onCoopJobVehicleCreated", resourceRoot, onCoopJobVehicleCreated_handler )

addEvent( "onJobVehicleIdle", true )
addEvent( "onJobVehicleDamage", true )