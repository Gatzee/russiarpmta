loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

-- Положения тюрем
PRISON_ROOM_POSITIONS =
{
      [ 1 ] =
      {
		name = "Петушатник",
		dimension = 1,
		interior = 1,

		rooms = {
                  --1 Этаж
                  { x = -2683.7770, y = 2628.1821,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2682.4721, 2626.0812, 1618.4262 ) },
                  { x = -2679.1977, y = 2628.1389,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2678.2551, 2626.0925, 1618.4262 ) },
                  { x = -2675.0268, y = 2627.9987,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2673.8293, 2626.0302, 1618.4262 ) },
                  { x = -2670.6191, y = 2627.9511,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2669.3464, 2626.2612, 1618.4262 ) },
                  { x = -2666.1140, y = 2627.9841,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2665.1376, 2626.2551, 1618.4262 ) },
                  { x = -2661.6428, y = 2627.7648,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2660.6918, 2626.3750, 1618.4262 ) },
                  { x = -2657.3923, y = 2628.1264,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2656.2978, 2626.2878, 1618.4262 ) },

                  --2 Этаж
                  { x = -2683.7770, y = 2628.1821,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2682.4721, 2626.0812, 1622.4262 ) },
                  { x = -2679.1977, y = 2628.1389,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2678.2551, 2626.0925, 1622.4262 ) },
                  { x = -2675.0268, y = 2627.9987,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2673.8293, 2626.0302, 1622.4262 ) },
                  { x = -2670.6191, y = 2627.9511,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2669.3464, 2626.2612, 1622.4262 ) },
                  { x = -2666.1140, y = 2627.9841,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2665.1376, 2626.2551, 1622.4262 ) },
                  { x = -2661.6428, y = 2627.7648,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2660.6918, 2626.3750, 1622.4262 ) },
                  { x = -2657.3923, y = 2628.1264,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2656.2978, 2626.2878, 1622.4262 ) },

            },

            out_job_marker = Vector3( -2472.7041, 1848.1845, 14.0847 );

		release_positions =
		{
			{ x = -2647.7512, y = 1535.0034, z = 14.086, interior = 0, dimension = 0 },
		},
	},

      [ 2 ] =
	{
		name = "Курятник",
		dimension = 2,
		interior = 1,

		rooms = {
			--1 Этаж
                  { x = -2683.7770, y = 2628.1821,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2682.4721, 2626.0812, 1618.4262 ) },
                  { x = -2679.1977, y = 2628.1389,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2678.2551, 2626.0925, 1618.4262 ) },
                  { x = -2675.0268, y = 2627.9987,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2673.8293, 2626.0302, 1618.4262 ) },
                  { x = -2670.6191, y = 2627.9511,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2669.3464, 2626.2612, 1618.4262 ) },
                  { x = -2666.1140, y = 2627.9841,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2665.1376, 2626.2551, 1618.4262 ) },
                  { x = -2661.6428, y = 2627.7648,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2660.6918, 2626.3750, 1618.4262 ) },
                  { x = -2657.3923, y = 2628.1264,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2656.2978, 2626.2878, 1618.4262 ) },

                  --2 Этаж
                  { x = -2683.7770, y = 2628.1821,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2682.4721, 2626.0812, 1622.4262 ) },
                  { x = -2679.1977, y = 2628.1389,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2678.2551, 2626.0925, 1622.4262 ) },
                  { x = -2675.0268, y = 2627.9987,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2673.8293, 2626.0302, 1622.4262 ) },
                  { x = -2670.6191, y = 2627.9511,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2669.3464, 2626.2612, 1622.4262 ) },
                  { x = -2666.1140, y = 2627.9841,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2665.1376, 2626.2551, 1622.4262 ) },
                  { x = -2661.6428, y = 2627.7648,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2660.6918, 2626.3750, 1622.4262 ) },
                  { x = -2657.3923, y = 2628.1264,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2656.2978, 2626.2878, 1622.4262 ) },
            },

            out_job_marker = Vector3( -2382.9536, 1706.4189, 14.0858 );

		release_positions =
		{
			{ x = -2655.7512, y = 1538.0034, z = 14.086, interior = 0, dimension = 0 },
		},
    },

    [ 3 ] =
    {
		name = "Бомжатник",
		dimension = 3,
		interior = 1,

		rooms = {
			--1 Этаж
                  { x = -2683.7770, y = 2628.1821,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2682.4721, 2626.0812, 1618.4262 ) },
                  { x = -2679.1977, y = 2628.1389,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2678.2551, 2626.0925, 1618.4262 ) },
                  { x = -2675.0268, y = 2627.9987,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2673.8293, 2626.0302, 1618.4262 ) },
                  { x = -2670.6191, y = 2627.9511,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2669.3464, 2626.2612, 1618.4262 ) },
                  { x = -2666.1140, y = 2627.9841,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2665.1376, 2626.2551, 1618.4262 ) },
                  { x = -2661.6428, y = 2627.7648,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2660.6918, 2626.3750, 1618.4262 ) },
                  { x = -2657.3923, y = 2628.1264,  z = 1618.4262, size = 4, capacity = 5, job_inside = Vector3( -2656.2978, 2626.2878, 1618.4262 ) },

                  --2 Этаж
                  { x = -2683.7770, y = 2628.1821,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2682.4721, 2626.0812, 1622.4262 ) },
                  { x = -2679.1977, y = 2628.1389,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2678.2551, 2626.0925, 1622.4262 ) },
                  { x = -2675.0268, y = 2627.9987,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2673.8293, 2626.0302, 1622.4262 ) },
                  { x = -2670.6191, y = 2627.9511,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2669.3464, 2626.2612, 1622.4262 ) },
                  { x = -2666.1140, y = 2627.9841,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2665.1376, 2626.2551, 1622.4262 ) },
                  { x = -2661.6428, y = 2627.7648,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2660.6918, 2626.3750, 1622.4262 ) },
                  { x = -2657.3923, y = 2628.1264,  z = 1622.4262, size = 4, capacity = 5, job_inside = Vector3( -2656.2978, 2626.2878, 1622.4262 ) },
            },

            out_job_marker = Vector3( -2475.3625, 1645.9948, 14.0858 );

		release_positions =
		{
			{ x = -2640.7512, y = 1534.0034, z = 14.086, interior = 0, dimension = 0 },
		},
	},
}

POSITION_JOB_MARKERS =
{
      --Грузчик
      {
            position = Vector3( -2867.6640, 1864.7290, 14.0874 ),
            callback = function()
                  DestroyJobsMarkers()
                  triggerServerEvent( "PlayeStartQuest_task_jail_1", localPlayer )
            end,
            dimension = 0,
            interior = 0,
            marker_text = "Грузчик",
            text = "ALT Взаимодействие",
            keypress = "lalt",
            quest_id = "task_jail_1",
      },

      --Маляр, возле цеха 1
      {
            position = Vector3( -2791.5871, 1952.2368, 14.0942 ),
            callback = function()
                  DestroyJobsMarkers()
                  triggerServerEvent( "PlayeStartQuest_task_jail_2", localPlayer )
            end,
            dimension = 0,
            interior = 0,
            marker_text = "Маляр",
            text = "ALT Взаимодействие",
            keypress = "lalt",
            quest_id = "task_jail_2",
      },

      --Маляр, возле цеха 2
      {
            position = Vector3( -2624.8728, 1928.9543, 14.0844 ),
            callback = function()
                  DestroyJobsMarkers()
                  triggerServerEvent( "PlayeStartQuest_task_jail_2", localPlayer )
            end,
            dimension = 0,
            interior = 0,
            marker_text = "Маляр",
            text = "ALT Взаимодействие",
            keypress = "lalt",
            quest_id = "task_jail_2",
      },

      --Пустышка для Цеха 1, указывает игру на интерьер
      {
            position = Vector3( -2798.7717, 1933.5070, 15.5955 ),
            callback = function() end,
            dimension = 0,
            interior = 0,
            marker_text = "Сборщик деталей",
            text = "ALT Взаимодействие",
            keypress = false,
            quest_id = nil,
      },
      --Сборщик деталей, Цех 1
      {
            position = Vector3( -2665.4570, 2933.0014, 1571.3427 ),
            callback = function()
                  DestroyJobsMarkers()
                  triggerServerEvent( "PlayeStartQuest_task_jail_3", localPlayer )
            end,
            dimension = 1,
            interior = 1,
            marker_text = "Сборщик деталей",
            text = "ALT Взаимодействие",
            keypress = "lalt",
            quest_id = "task_jail_3",
      },
      --Сборщик деталей, Цех 2
      {
            position = Vector3( -2665.4570, 2933.0014, 1571.3427 ),
            callback = function()
                  DestroyJobsMarkers()
                  triggerServerEvent( "PlayeStartQuest_task_jail_3", localPlayer )
            end,
            dimension = 2,
            interior = 1,
            marker_text = "Сборщик деталей",
            text = "ALT Взаимодействие",
            keypress = "lalt",
            quest_id = "task_jail_3",
      },
      --Пустышка для Цеха 2, указывает игру на интерьер
      {
            position = Vector3( -2645.3210, 1923.6513, 15.3731 ),
            callback = function() end,
            dimension = 0,
            interior = 0,
            marker_text = "Сборщик деталей",
            text = "ALT Взаимодействие",
            keypress = false,
            quest_id = nil,
      }
}


function GetClosestRoom( pPlayer )
	if isElement(pPlayer) then
		for k,v in pairs(PRISON_ROOM_POSITIONS) do
			if v.dimension == pPlayer.dimension and v.interior == pPlayer.interior then
				for i, room in pairs(v.rooms) do
					local distance = ( pPlayer.position - Vector3(room.x,room.y,room.z) ).length
                              if distance <= 4 then
						return k, i
					end
				end
			end
		end
	end
end

-- Подсчёт срока в соответствии со статьями
function GetTotalJailTime( pPlayer, pWantedList )
	if not pWantedList and not isElement( pPlayer ) then return end

	local iTotalTime = 0
	local pWantedList = pWantedList or pPlayer:GetWantedData( ) or { }

	for _, v in pairs( pWantedList ) do
		iTotalTime = iTotalTime + ( WANTED_REASONS_LIST[v].duration or 30 )
	end

	return math.min( iTotalTime, 120 ) * 60
end