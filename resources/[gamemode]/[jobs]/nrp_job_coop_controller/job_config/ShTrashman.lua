
JOB_DATA[ JOB_CLASS_TRASHMAN ] =
{
    task_resource = "task_trashman_coop",
	onStartWork = "onServerTrashmanStartWork",
	onEndWork = "onServerTrashmanEndWork",

    markers_positions = 
    {
        {
    		city = 0,
    		name = "Работа мусорщиком",
			x = 2269.531, y = 527.433 + 860, z = 16.801,
			blip_size = 1.8,
    	},
    },
    blip_id = 76,

	company_name = JOB_ID[ JOB_CLASS_TRASHMAN ],
    conf = 
    {
    	{
			level = 4,
    	},
    	{
    		level = 6,
    	},
    	{
    		level = 8,
		},
	},
	
	job_join_condition = function( lobby, player, is_start, show_player )
		return true
	end,

    vehicle_data = {
    	[ 0 ] = {
			vehicle_model = 524,
			block_repair = true,
			positions = {
				{ position = Vector3{ x = 2252.64, y = 516.77 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2264.24, y = 514.15 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2265.2 , y = 510.62 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2266.4 , y = 506.52 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2267.34, y = 503.04 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2268.22, y = 499.18 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2269.21, y = 495.12 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2269.98, y = 491.93 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2271.02, y = 487.64 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2261.43, y = 484.98 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2260.24, y = 488.46 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2259.28, y = 492.1 + 860 , z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2258.29, y = 495.9 + 860 , z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2257.31, y = 499.64 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2256.27, y = 503.59 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2255.3 , y = 507.48 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
				{ position = Vector3{ x = 2254.12, y = 512.07 + 860, z = 16.9 }, rotation = Vector3( 0, 0, 303 ), },
			},
			idle_time = 15,
            apply_fn = function( vehicle )
				setVehiclePaintjob( vehicle, 0 )
				setVehicleColor( vehicle, 250, 240, 185 )
			end,
    	},
    }
}
