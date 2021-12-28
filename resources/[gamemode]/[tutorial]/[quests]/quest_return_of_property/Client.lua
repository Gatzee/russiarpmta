loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function CreatePedAttackMultipleTargets( ped, conf )
	local self = conf or { }

	local current_target
	local targets = { }

	self.add_target = function( self, target )
		table.insert( targets, target )
	end

	self.remove_target = function( self, target )
		for i = 1, #targets do
			if targets[ i ] == target then
				return table.remove( targets, i )
			end
		end
	end

	self.destroy = function( )
		if isElement( ped ) then
			CleanupAIPedPatternQueue( ped )
			removePedTask( ped )
		end

		DestroyTableElements( self )
		setmetatable( self, nil )
	end

	self.check_target_in_view = function( )
		if not isElement( ped ) then
			self:destroy( )
			return
		end

		if not isElement( current_target ) or not isLineOfSightClear( ped.position, current_target.position, _, _, _, _, _, _, _, current_target ) then
			local ped_position = ped.position
			for i = #targets, 1, -1 do
				local target = targets[ i ]

				if not isElement( target ) then
					self.remove_target( target )
					
				elseif isLineOfSightClear( ped_position, target.position, _, _, _, _, _, _, _, target ) then
					current_target = target
					CleanupAIPedPatternQueue( ped )
					removePedTask( ped )
					AddAIPedPatternInQueue( ped, AI_PED_PATTERN_ATTACK_PED, {
						target_ped = target;
					} )
					if self.attack_start_callback then
						self:attack_start_callback( )
					end
					return true
				end
			end

			if self.attack_stop_callback then
				self:attack_stop_callback( )
			end
		end
	end
	self.timer = setTimer( self.check_target_in_view, 300, 0 )

	return self
end

function IsInFirstRoom( ped )
	local position = ped.position

	return position.x < -90.083  and position.y < -2471.303
	   and position.x > -110.532 and position.y > -2479.786
end