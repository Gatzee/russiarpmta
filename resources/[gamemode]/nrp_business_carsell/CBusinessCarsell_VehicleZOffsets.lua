local additional_heights = {
	[ 400 ] = 0.976,
	[ 401 ] = 0.900,
	[ 402 ] = 0.591,
	[ 404 ] = 0.814,
	[ 405 ] = 0.582,
	[ 411 ] = 0.604,
	[ 415 ] = 0.653,
	[ 418 ] = 1.091,
	[ 420 ] = 0.681,
	[ 421 ] = 0.695,
	[ 426 ] = 0.786,
	[ 429 ] = 0.660,
	[ 436 ] = 0.667,
	[ 438 ] = 0.877,
	[ 439 ] = 0.851,
	[ 448 ] = 0.454,
	[ 451 ] = 0.693,
	[ 458 ] = 1.300,
	[ 463 ] = 0.354,
	[ 466 ] = 0.830,
	[ 467 ] = 0.777,
	[ 470 ] = 0.810,
	[ 474 ] = 0.623,
	[ 475 ] = 0.639,
	[ 477 ] = 0.827,
	[ 479 ] = 1.001,
	[ 491 ] = 0.607,
	[ 492 ] = 0.860,
	[ 496 ] = 0.664,
	[ 502 ] = 0.550,
	[ 506 ] = 0.576,
	[ 507 ] = 0.536,
	[ 516 ] = 0.789,
	[ 517 ] = 0.789,
	[ 518 ] = 0.541,
	[ 521 ] = 0.463,
	[ 526 ] = 0.620,
	[ 527 ] = 0.619,
	[ 529 ] = 0.774,
	[ 534 ] = 0.853,
	[ 535 ] = 0.807,
	[ 536 ] = 0.542,
	[ 540 ] = 0.792,
	[ 542 ] = 0.698,
	[ 543 ] = 0.724,
	[ 546 ] = 0.750,
	[ 547 ] = 0.694,
	[ 549 ] = 0.583,
	[ 550 ] = 0.434,
	[ 551 ] = 0.848,
	[ 554 ] = 0.892,
	[ 559 ] = 0.653,
	[ 560 ] = 0.546,
	[ 562 ] = 0.763,
	[ 566 ] = 0.734,
	[ 579 ] = 1.046,
	[ 581 ] = 0.585,
	[ 582 ] = 1.008,
	[ 585 ] = 0.836,
	[ 586 ] = 0.582,
	[ 587 ] = 0.604,
	[ 589 ] = 0.618,
	[ 602 ] = 0.720,
	[ 603 ] = 0.644,
	[ 600 ] = 0.537,
	[ 558 ] = 0.529,
	[ 576 ] = 0.804,
	[ 412 ] = 0.733,
	-- Значения можно получать с помощью команды fixcarsellz
}

Vehicle.FixPositionZ = function( self )
	local vx,vy,vz = getElementPosition( self )
	local vx1,vy1,vz1 = vx, vy, vz - 5
	local hit,px,py,pz = processLineOfSight( vx,vy,vz,vx1,vy1,vz1,true,false,false,true,true,true,false,false,self )
	local additional_z = additional_heights[ self.model ] or 0.75
	self.position = Vector3( vx, vy, pz + additional_z )

	for k, v in pairs( VEHICLE_CONFIG[ self.model ].variants[ self:GetVariant( ) ].handling ) do
		self:setHandling( k, v )
	end
end




----------------------------------------------------------------------------

addCommandHandler( "fixcarsellz", function ( )
	if localPlayer:getData( "_srv" )[ 1 ] < 100 then return end
	if not isElement( VEHICLE ) then return end
	setGameSpeed( 10 )
	VEHICLE.frozen = false
	VEHICLE.position = VEHICLE.position + Vector3( 0, 0, 1 )
	VEHICLE.velocity = Vector3( 0, 0, -0.02 )
	local frst = nil
	local i = 0
	local str = ""
	setTimer( function( )
		if not isElement( VEHICLE ) then return end
		local vx,vy,vz = getElementPosition( VEHICLE )
		local vx1,vy1,vz1 = vx, vy, vz - 5
		local hit,px,py,pz = processLineOfSight( vx,vy,vz,vx1,vy1,vz1,true,false,false,true,true,true,false,false,VEHICLE )
		additional_heights[ VEHICLE.model ] = VEHICLE.position.z - pz
		outputConsole( "[ " .. VEHICLE.model .. " ] = " .. string.format( "%.3f", VEHICLE.position.z - pz ) .. "," )
		VEHICLE.frozen = true
		setGameSpeed( 1 )
	end, 500, 1 )
end )