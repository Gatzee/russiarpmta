
JOB_DATA[ JOB_CLASS_INDUSTRIAL_FISHING ] =
{
    task_resource = "task_industrial_fishing_coop",
	onStartWork = "onServerIndustrialFishingStartWork",
	onEndWork = "onServerIndustrialFishingEndWork",

    markers_positions = 
    {
    	{
    		city = 2,
    		name = "Промышленная рыбалка",
			x = -2065.4414, y = 2843.9982 + 860, z = 3.3932,
    	},
	},
	
	blip_id = 79,
	company_name = JOB_ID[ JOB_CLASS_INDUSTRIAL_FISHING ],

	coop_mul = 2,
    conf = 
    {
    	{
			level = 19,
    	},
    	{
    		level = 22,
    	},
    	{
    		level = 25,
		},
    },

    vehicle_data = 
    {
    	[ 2 ] = 
    	{
			vehicle_model = 595,
			positions = 
			{
				{ position = Vector3( -2519.2060, 2570.2160 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
				{ position = Vector3( -2363.2060, 2570.2160 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
				{ position = Vector3( -2281.2060, 2570.2160 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
				{ position = Vector3( -2044.2060, 2570.2160 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
				{ position = Vector3( -1806.0812, 2673.7041 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
				{ position = Vector3( -1806.0821, 2578.1430 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
				{ position = Vector3( -2760.3266, 2669.8999 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
				{ position = Vector3( -2760.2785, 2583.8354 + 860, 2.962 ), rotation = Vector3( 0, 0, 180 ) },
			},
    	},
    }
}
