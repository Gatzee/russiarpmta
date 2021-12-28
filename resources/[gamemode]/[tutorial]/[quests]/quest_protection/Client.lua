loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function AddExitVehiclePattern( ped, callback, ... )
	AddAIPedPatternInQueue( ped, AI_PED_PATTERN_VEHICLE_EXIT, { 
		end_callback = {
			func = callback or (function() return true end),
			args = { ... },
		}
	} )
end

function AddEnterVehiclePattern( ped, vehicle, seat, callback, ... )
	AddAIPedPatternInQueue( ped, AI_PED_PATTERN_VEHICLE_ENTER, {
		vehicle = vehicle;
		seat = seat;
		end_callback = {
			func = callback or (function() return true end),
			args = { ... },
		}
	} )
end

function CreateEnterVehicleHint()
	CEs.hint = CreateSutiationalHint( {
		text = "Нажми key=F чтобы сесть на водительское место",
		condition = function( )
			local vehicle = localPlayer:getData( "temp_vehicle" )
			return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
		end
	} )
end

function AddCheckVehicleCondition( vehicle )
	table.insert( GEs, WatchElementCondition( vehicle, {
		condition = function( self, conf )
			if self.element.health <= 370 or self.element.inWater then
				FailCurrentQuest( "Машина картеля уничтожена", "fail_destroy_vehicle" )
				return true
			elseif self.element:GetFuel() <= 0 then
				FailCurrentQuest( "Кончилось топливо!" )
				return true
			end
		end,
	} ) )
end

function CreateGates( positions )
	GEs.west_gates = createObject( 6282, positions.west_gates.pos, positions.west_gates.rot )
	setObjectScale( GEs.west_gates, 1.13 )
	LocalizeQuestElement( GEs.west_gates )
								
	GEs.OpenGate = function()
		GEs.gate_state = true
		moveObject( GEs.west_gates, 2000, positions.west_gates.pos - Vector3( 0.85, -5, 0 ) )
	end

	GEs.CloseGate = function()
		GEs.gate_state = false
		moveObject( GEs.west_gates, 2000, positions.west_gates.pos )
	end

	GEs.ChangeCanOpenGate = function( state )
		GEs.can_open_gate = state
	end
	
	GEs.col_gate = createColCircle( positions.west_gates.pos.x, positions.west_gates.pos.y, 50 )
	GEs.OnLeave = function( element )
		if element == localPlayer and GEs.gate_state then
			GEs.CloseGate()
		end
	end
	addEventHandler( "onClientColShapeLeave", GEs.col_gate, GEs.OnLeave )

	GEs.OnEnter = function( element )
		if element == localPlayer and not GEs.gate_state and GEs.can_open_gate then
			GEs.OpenGate()
		end
	end
	addEventHandler( "onClientColShapeHit", GEs.col_gate, GEs.OnEnter )
end


function InitAttackedInterface( callback_event, count_dead_bots_finish )
	GEs.interface_attacked = {}
	GEs.shoots = {}
	GEs.count_dead_bots_finish = count_dead_bots_finish
	GEs.friend_targets = table.copy( GEs.friend_bots )
	GEs.enemy_targets =  table.copy( GEs.enemy_bots )
	table.insert( GEs.friend_targets, localPlayer )
	
	GEs.interface_attacked.getTarget = function( attacker, team )
		local key, min_distance = nil, 10000
		local attacker_position = attacker.position

		for k, v in pairs( team ) do
			if not v.dead then
				local c_distnace = (v.position - attacker_position).length
				if c_distnace < min_distance then					
					key, min_distance = k, c_distnace
				end
			end
		end
		
		return key and team[ key ]
	end
	
	GEs.RefreshTarget = function()
		for _, team_data in pairs( { { GEs.friend_targets, GEs.enemy_targets }, { GEs.enemy_targets, GEs.friend_targets } } ) do
			for _, ped in pairs( team_data[ 1 ] ) do
				if GEs.shoots[ ped ] then
					local target_ped = GEs.interface_attacked.getTarget( ped, team_data[ 2 ] )
					if target_ped then GEs.shoots[ ped ]:start( target_ped ) end
				end
			end
		end
	end
	CEs.refresh_target_tmr = setTimer( GEs.RefreshTarget, 1000, 0 )

	GEs.interface_attacked.attackEnemy = function( ped, enemy_team )
		local target_ped = GEs.interface_attacked.getTarget( ped, enemy_team )
		if target_ped then
			CleanupAIPedPatternQueue( ped )
			removePedTask( ped )
			ResetAIPedPattern( ped )
			
			local shoot = GEs.shoots[ ped ]
			if not shoot then
				shoot = CreatePedShoot( ped, true )
				shoot.speed_spread = { 2.5, 4 }
				shoot.distance_no_spread = 5
				GEs.shoots[ ped ] = shoot
			end

			shoot:start( target_ped )
		end
	end

	GEs.interface_attacked.onWasted = function( killer )
		local count_wasted = 0
		for k, v in pairs( GEs.enemy_targets ) do
			if v.dead or v == source then 
				count_wasted = count_wasted + 1
			end
		end

		if GEs.shoots[ source ] then GEs.shoots[ source ]:destroy() end

		if count_wasted == GEs.count_dead_bots_finish  then
			DestroyAttackedInterface()
			triggerServerEvent( callback_event, localPlayer )
		end
	end
	addEventHandler( "onClientPedWasted", root, GEs.interface_attacked.onWasted )
end

function DestroyAttackedInterface()
	if isTimer( CEs.refresh_target_tmr ) then killTimer( CEs.refresh_target_tmr ) end

	for k, v in pairs( GEs.shoots ) do
		v:destroy()	
	end
	if GEs.interface_attacked then
		removeEventHandler( "onClientPedWasted", root, GEs.interface_attacked.onWasted )
		GEs.interface_attacked = nil
	end
end
