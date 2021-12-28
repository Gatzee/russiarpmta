loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )

-- Положения КПЗ
JAIL_ROOM_POSITIONS = {
	-- Первое КПЗ
	{
		name = "Петушатник",
		dimension = 1,
		interior = 1,

		rooms = {
			{ x = -387.5, y = -802.1,  z = 1062.1, size = 3, capacity = 10 },
			{ x = -387.5, y = -797.65, z = 1062.1, size = 3, capacity = 10 },
			{ x = -387.5, y = -792.95, z = 1062.1, size = 3, capacity = 10 },
			{ x = -387.5, y = -788.5,  z = 1062.1, size = 3, capacity = 10 },
			{ x = -387.5, y = -783.8,  z = 1062.1, size = 3, capacity = 10 },
		},

		release_positions = 
		{
			{ x = -356.471, y = -1671.005 + 860, z = 20.852, interior = 0, dimension = 0},
		},
	},

	-- Второе КПЗ
	{
		name = "Курятник",
		dimension = 1,
		interior = 1,

		rooms = {
			{ x = 1930.7, y = 119.181, z = 631.421, size = 3, capacity = 10},
			{ x = 1930.7, y = 123.549, z = 631.421, size = 3, capacity = 10},
			{ x = 1930.7, y = 128.372, z = 631.421, size = 3, capacity = 10},
			{ x = 1930.7, y = 132.672, z = 631.421, size = 3, capacity = 10},
			{ x = 1930.7, y = 137.515, z = 631.421, size = 3, capacity = 10},
		},

		release_positions = 
		{
			{ x = 1940.023, y = -739.052 + 860, z = 60.773, interior = 0, dimension = 0},
		},
	},
}

-- Подсчёт срока в соответствии со статьями
function GetTotalJailTime( pPlayer, pWantedList )
	if not pWantedList and not isElement(pPlayer) then return end

	local iTotalTime = 0
	local pWantedList = pWantedList or pPlayer:GetWantedData( ) or { }
	local hunting = pPlayer:getData( "hunting" )

	if hunting and hunting.timeTo then
		local timeLeft = hunting.timeTo - getRealTimestamp( )
		if timeLeft > 0 then iTotalTime = 30 end
	end

	for _, v in pairs(pWantedList) do
		iTotalTime = iTotalTime + ( WANTED_REASONS_LIST[ v ] and WANTED_REASONS_LIST[ v ].duration or 30 )
		if not WANTED_REASONS_LIST[ v ] then
			-- Есть какая-то статья из-за которой не могли посадить чувака, будем ловить
			outputDebugString( "NON_EXIST_WANTED_REASON №" .. v, 1, 255, 0, 0 )
		end
	end

	return math.min(iTotalTime, 120) * 60
end

function GetClosestJail( pPlayer )
	if isElement( pPlayer ) then
		for k,v in pairs( JAIL_ROOM_POSITIONS ) do
			if v.dimension == pPlayer.dimension and v.interior == pPlayer.interior then
				for i, room in pairs( v.rooms ) do
					local distance = ( pPlayer.position - Vector3( room.x,room.y,room.z ) ).length
					if distance <= 5 then
						return k
					end
				end
			end
		end
	end
end