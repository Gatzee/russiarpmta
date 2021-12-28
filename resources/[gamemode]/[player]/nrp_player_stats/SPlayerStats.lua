local stats = {
	[69] = 500,  -- Pistol
	[71] = 999,  -- Desert eagle
	[72] = 999,  -- Shotgun
	[73] = 500,  -- Sawnoff, 999 for duel wield
	[74] = 999,  -- Spas-12
	[75] = 500,  -- Micro-uzi & Tec-9, 999 for duel wield
	[76] = 999,  -- MP5
	[77] = 999,  -- AK-47
	[78] = 999,  -- M4
	[79] = 999,  -- Sniper rifle & country rifle
	[160] = 999, -- Driving
	--[229] = 999, -- Biking
}

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source
    for stat, value in pairs( stats ) do
        setPedStat( player, stat, value )
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function onResourceStart_handler()
    for i, v in pairs( getElementsByType( "player" ) ) do
        onPlayerCompleteLogin_handler( v )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )