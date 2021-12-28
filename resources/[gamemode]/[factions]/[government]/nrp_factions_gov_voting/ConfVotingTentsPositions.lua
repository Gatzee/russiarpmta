loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

VOTING_TENTS_POSITIONS = {
	[ F_GOVERNMENT_NSK ] = {
		Vector3( 473.834, -2130.804 + 860, 20.582 );
		Vector3( 403.69, -2431.959 + 860, 20.804 );
		Vector3( 315.771, -2809.402 + 860, 20.819 );
		Vector3( 247.805, -2196.45 + 860, 20.821 );
		Vector3( -48.224, -1334.478 + 860, 20.808 );
		Vector3( -69.572, -1695.661 + 860, 20.813 );
		Vector3( -85.01, -1988.158 + 860, 20.802 );
		Vector3( -312.901, -1690.61 + 860, 20.984 );
		Vector3( -473.355, -1823.346 + 860, 20.789 );
		Vector3( -1193.68, -1282.614 + 860, 21.064 );
		Vector3( -820.319, -1154.668 + 860, 15.79 );
		Vector3( -1920.395, 504.071 + 860, 19.348 );
		Vector3( -2277.883, -31.297 + 860, 20.115 );
		Vector3( 174.635, -2391.167 + 860, 20.601 );
	};
	[ F_GOVERNMENT_GORKI ] = {
		Vector3( 2231.207, -972.561 + 860, 60.655 );
		Vector3( 2008.808, -801.018 + 860, 60.642 );
		Vector3( 1965.742, -278.477 + 860, 60.748 );
		Vector3( 2186.057, -1209.867 + 860, 60.652 );
		Vector3( 2211.794, -674.248 + 860, 60.829 );
		Vector3( 2375.781, -1754.817 + 860, 73.922 );
		Vector3( 1929.035, -504.353 + 860, 60.795 );
		Vector3( 1620.511, -323.529 + 860, 27.191 );
		Vector3( 2018.618, -1003.489 + 860, 60.68 );
	};
	--[[ [ F_GOVERNMENT_MSK ] = {  -- Это выбори МСК
		Vector3( 593.82, 2588.9, 12.92 ),
		Vector3( 429.34, 2692.64, 17.01 ),
		Vector3( 71.08, 2645.17, 21.17 ),
		Vector3( 28.94, 2560.99, 21.61 ),
		Vector3( -145.81, 2349.02, 21.6 ),
		Vector3( 1320.74, 2671.15, 9.97 ),
		Vector3( 924.53, 2738.33, 7.96 ),
		Vector3( 19.64, 2793.41, 15.44 ),
		Vector3( -406.05, 2656.98, 16.37 ),
		Vector3( -444.55, 2575.31, 17.28 ),
		Vector3( -556.32, 2536.38, 17.24 ),
		Vector3( -680.29, 2287.13, 19.57 ),
		Vector3( -691.17, 2164.24, 19.57 ),
		Vector3( -626.92, 2026.29, 15.64 ),
		Vector3( -596.02, 1851.9, 8.3 ),
		Vector3( -727.84, 1774.72, 10.25 ),
		Vector3( -817.34, 2335.47, 18.81 ),
		Vector3( -583.48, 2466.6, 16.94 ),
		Vector3( -1125.59, 2740.06, 15.31 ),
		Vector3( -1499.49, 2391.48, 10.51 ),
		Vector3( -1066.78, 2198.91, 12.25 ),
		Vector3( -668.34, 1850.94, 11.21 ),
		Vector3( -343.74, 2724.01, 14.93 ),
	};]]
}

--[[
if not localPlayer then
	local gov_id = F_GOVERNMENT_MSK
	addCommandHandler( "pos", function( player, cmd, id )
		player.position = VOTING_TENTS_POSITIONS[ gov_id ][ tonumber( id ) ] + Vector3( 0, 0, 1 )
	end )

	for k, v in pairs( VOTING_TENTS_POSITIONS[ gov_id ] ) do
		local obj = createObject( 744, v + Vector3( 0, 0, -1 ) )
		createBlipAttachedTo( obj, 0 )
	end
end
--]]