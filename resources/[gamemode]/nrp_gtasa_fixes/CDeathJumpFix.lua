-- Фикс гташного бага, когда персонаж подыхает при перепрыгивании коллизии

local last_damage_tick = 0

addEventHandler( "onClientPlayerDamage", localPlayer, function( attacker, weapon, bodypart )
	if not attacker and weapon == 54 and bodypart == 3 then 
		local tick = getTickCount( )
		if isPedDoingTask( localPlayer, "TASK_SIMPLE_CLIMB" ) or tick - last_damage_tick < 1000 then
			cancelEvent( )
		end
		last_damage_tick = tick
	end
end )