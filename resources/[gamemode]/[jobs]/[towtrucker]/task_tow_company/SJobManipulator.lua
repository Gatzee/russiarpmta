
MANIPULATOR_VEHICLE_TYPES = 
{
	[ 404 ]  = "sedan",
	[ 426 ]  = "sedan",
	[ 467 ]  = "sedan",
	[ 492 ]  = "sedan",
	[ 516 ]  = "sedan",
	[ 517 ]  = "sedan",
	[ 540 ]  = "sedan",
	[ 566 ]  = "sedan",
	[ 585 ]  = "sedan",
	[ 405 ]  = "sedan",
	[ 410 ]  = "sedan",
	[ 420 ]  = "sedan",
	[ 436 ]  = "sedan",
	[ 466 ]  = "sedan",
	[ 477 ]  = "sedan",
	[ 529 ]  = "sedan",
	[ 536 ]  = "sedan",
	[ 560 ]  = "sedan",
	[ 475 ]  = "sedan",
	[ 491 ]  = "sedan",
	[ 546 ]  = "sedan",
	[ 549 ]  = "sedan",
	[ 587 ]  = "sedan",
	[ 412 ]  = "sedan",
	[ 507 ]  = "sedan",
	[ 518 ]  = "sedan",
	[ 562 ]  = "sedan",
	[ 567 ]  = "sedan",
	[ 575 ]  = "sedan",
	[ 576 ]  = "sedan",
	[ 603 ]  = "sedan",
	[ 401 ]  = "sedan",
	[ 411 ]  = "sedan",
	[ 415 ]  = "sedan",
	[ 429 ]  = "sedan",
	[ 451 ]  = "sedan",
	[ 496 ]  = "sedan",
	[ 506 ]  = "sedan",
	[ 526 ]  = "sedan",
	[ 527 ]  = "sedan",
	[ 534 ]  = "sedan",
	[ 535 ]  = "sedan",
	[ 541 ]  = "sedan",
	[ 545 ]  = "sedan",
	[ 562 ]  = "sedan",
	[ 602 ]  = "sedan",
	[ 543 ]  = "sedan",
	[ 439 ]  = "sedan",
	[ 470 ]  = "sedan",
	[ 547 ]  = "sedan",
	[ 580 ]  = "sedan",
	[ 6526 ] = "sedan",
	[ 6529 ] = "sedan",
	[ 6533 ] = "sedan",
	[ 6550 ] = "sedan",
	[ 6552 ] = "sedan",
	[ 6533 ] = "sedan",
	[ 6528 ] = "sedan",
	[ 6532 ] = "sedan",
	[ 6535 ] = "sedan",
	[ 6537 ] = "sedan",

	[ 400 ]  = "suv",
	[ 490 ]  = "suv",
	[ 418 ]  = "suv",
	[ 479 ]  = "suv",
	[ 554 ]  = "suv",
	[ 421 ]  = "suv",
	[ 551 ]  = "suv",
	[ 579 ]  = "suv",
	[ 445 ]  = "suv",
	[ 596 ]  = "suv",
	[ 6531 ] = "suv",
	[ 6527 ] = "suv",	
}

MANIPULATOR_VEHICLE_OFFSET_DEFAULT = { x = 0, y = -2.5, z = 0.43 }
MANIPULATOR_VEHICLE_OFFSET = 
{
	[ "sedan" ] = MANIPULATOR_VEHICLE_OFFSET_DEFAULT,
	[ "suv" ]   = { x = 0, y = -2.6, z = 0.5  },
}


function Player.ManipulatorControlEnabled( self, lobby_data, state )
	triggerClientEvent( self, "onClientManipulatorControlEnabled", resourceRoot, state, lobby_data.job_vehicle, lobby_data.evacuated_vehicle )
end

function onServerAttachVehicleToManipulator_handler()
	local lobby_data = GetLobbyDataByPlayer( client )
	if not lobby_data then return end

	lobby_data.evacuated_vehicle:setFrozen( false )
	for k, v in pairs( lobby_data.participants ) do
		triggerClientEvent( v.player, "onClientAttachVehicleToManipulator", resourceRoot, lobby_data.job_vehicle, lobby_data.evacuated_vehicle )
	end
end
addEvent( "onServerAttachVehicleToManipulator", true )
addEventHandler( "onServerAttachVehicleToManipulator", root, onServerAttachVehicleToManipulator_handler )

function onServerAttachVehicleToTowtucker_handler()
	local lobby_data = GetLobbyDataByPlayer( client )
	if not lobby_data then return end

	RemoveOrderVehicleShapeZone( lobby_data )

	local vehicle_model = lobby_data.evacuated_vehicle:getModel()
	local offset_data = MANIPULATOR_VEHICLE_TYPES[ vehicle_model ] and MANIPULATOR_VEHICLE_OFFSET[ MANIPULATOR_VEHICLE_TYPES[ vehicle_model ] ] or MANIPULATOR_VEHICLE_OFFSET_DEFAULT
	lobby_data.evacuated_vehicle:attach( lobby_data.job_vehicle, offset_data.x, offset_data.y, offset_data.z, 0, 0, 0 )

	for k, v in pairs( lobby_data.participants ) do
		if isElement( v.player ) then
			triggerClientEvent( v.player, "onClientManipulatorReset", resourceRoot, lobby_data.job_vehicle, lobby_data.evacuated_vehicle, true )
			lobby_data.duration_to_evac = getRealTimestamp()
			v.player:ShowInfo( "Автомобиль успешно погружен" )
		end
	end

	lobby_data.job_vehicle.frozen = false
	triggerEvent( "task_towtrucker_coop_end_step_3", client )
end
addEvent( "onServerAttachVehicleToTowtucker", true )
addEventHandler( "onServerAttachVehicleToTowtucker", root, onServerAttachVehicleToTowtucker_handler )

function onServerManipulatorChangeState_handler( state )
	if not isElement( client ) then return false end

	local lobby_id = client:GetCoopJobLobbyId()
	if not lobby_id then return end

	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	lobby_data.job_vehicle.frozen = state
end
addEvent( "onServerManipulatorChangeState", true )
addEventHandler( "onServerManipulatorChangeState", resourceRoot, onServerManipulatorChangeState_handler )

function onServerSyncManipulator_handler( target_y, target_rz )
	if not isElement( client ) then return false end

	local lobby_id = client:GetCoopJobLobbyId()
	if not lobby_id then return end

	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end
	
	for k, v in pairs( lobby_data.participants ) do
		if isElement( v.player ) and v.player ~= client then
			triggerClientEvent( v.player, "onClientSyncManipulator", resourceRoot, target_y, target_rz )
		end
	end
end
addEvent( "onServerSyncManipulator", true )
addEventHandler( "onServerSyncManipulator", root, onServerSyncManipulator_handler )